USE [GBRWMS]
GO


SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO



	  /***************************************************************************/
      /* Stored Procedure: isp_RPT_JCB_EMG03_Marshall_Lane_Outbound_V5           */
      /* Creation Date: 18/09/2025                                               */
      /* Copyright: Maersk CE EUR                                                */
      /* Written by: AGM046                                                      */
      /*                                                                         */
      /* Purpose:                                                                */
      /*                                                                         */
      /* GitHub Version: 1.0                                                     */
      /*                                                                         */
      /* Version: 1.0                                                            */
      /*                                                                         */
      /* Data Modifications:                                                     */
      /*                                                                         */
      /* Updates:                                                                */
      /* Date         Author  Ver   Purposes                                     */
      /*                                                                         */
      /***************************************************************************/
	  	  
      CREATE
      PROC [BI].[isp_RPT_JCB_EMG03_Marshall_Lane_Outbound_V5] 
      	    
	  AS
	 
	  BEGIN
	  
        SET NOCOUNT ON 
        SET ANSI_NULLS OFF 
        SET QUOTED_IDENTIFIER OFF 
        SET CONCAT_NULL_YIELDS_NULL OFF 
        
		--
		DECLARE @now datetime = GETDATE();

		;WITH
			-- 1) Lanes (columnas fijas)
			lanes AS (
			  SELECT Loc FROM (VALUES
				('ESM041'),('ESM041B'),('ESM041C'),
				('ESM042'),('ESM042B'),('ESM042C'),
				('ESM043'),
				('ESM044'),
				('ESM045'),('ESM046'),('ESM047'),
				('ESM048'),('ESM049'),
				('ESM050'),('ESM051'),
				('ESM052'),('ESM053'),('ESM054'),
				('ESM055'),('ESM056'),('ESM057'),
				('ESM058'),('ESM059'),
				('ESM060'),
				('ESM061'),('ESM062')
			  ) v(Loc)
			),

			-- 2) Físico desde LOTxLOCxID (sólo muelles listados)
			lli_base AS (
			  SELECT lli.StorerKey, lli.Loc, lli.Id AS PalletId, lli.Qty
			  FROM LOTxLOCxID lli WITH (NOLOCK)
			  JOIN lanes ln ON ln.Loc = lli.Loc
			  WHERE lli.StorerKey = 'JCB'
				AND lli.Qty > 0
			),

			-- 3) Expandir pallets a “unidades” (cajas si existen, si no el propio pallet)
			--    Solo consideramos cajas/palletes de órdenes NO '9'
			units_from_pd AS (
			  SELECT DISTINCT
				lb.StorerKey,
				lb.Loc,
				CASE
				  WHEN pd.DropID IS NULL OR pd.DropID = '' OR pd.DropID = pd.ID
					THEN pd.ID           -- pallet
				  ELSE pd.DropID         -- caja
				END AS UnitLPN
			  FROM lli_base lb
			  JOIN PICKDETAIL pd WITH (NOLOCK)
				ON pd.StorerKey = lb.StorerKey
			   AND pd.ID        = lb.PalletId
			  JOIN Orders o WITH (NOLOCK)
				ON o.OrderKey   = pd.OrderKey
			   AND o.StorerKey  = pd.StorerKey
			   AND o.Facility   = 'EMG03'
			   AND o.Status    <> '9'
			  WHERE (pd.DropID IS NOT NULL OR pd.ID IS NOT NULL)
			),

			units_fallback AS (  -- pallets sin PD: nos quedamos con el propio pallet
			  SELECT
				lb.StorerKey,
				lb.Loc,
				lb.PalletId AS UnitLPN
			  FROM lli_base lb
			  WHERE NOT EXISTS (
				SELECT 1
				FROM PICKDETAIL pd WITH (NOLOCK)
				WHERE pd.StorerKey = lb.StorerKey
				  AND pd.ID        = lb.PalletId
				  AND (pd.DropID IS NOT NULL OR pd.ID IS NOT NULL)
			  )
			),

			universe AS (        -- deduplicar por unidad física (loc + unitlpn)
			  SELECT StorerKey, Loc, UnitLPN
			  FROM (
				SELECT *, ROW_NUMBER() OVER (
						 PARTITION BY StorerKey, Loc, UnitLPN
						 ORDER BY UnitLPN
					   ) AS rn
				FROM (
				  SELECT * FROM units_from_pd
				  UNION ALL
				  SELECT * FROM units_fallback
				) x
			  ) d
			  WHERE rn = 1
			),

			/* 4) PICKDETAIL normalizado a UnitLPN + Orders (Facility/MBOLKey) 
				  ✅ MODIFICADO: si es SplitOrder, usar datos de la orden madre (parent) */
			pd_orders AS (
			  SELECT DISTINCT
				pd.StorerKey,
				pd.OrderKey,
				pd.UOM,
				pd.ID,
				pd.DropID,
				CASE
				  WHEN pd.DropID IS NULL OR pd.DropID = '' OR pd.DropID = pd.ID
					THEN pd.ID
				  ELSE pd.DropID
				END AS UnitLPN,

				-- order “efectiva” para etiquetar (parent si existe)
				COALESCE(parent.MBOLKey, o.MBOLKey)             AS MBOLKey,
				COALESCE(parent.Facility, o.Facility)           AS Facility,
				COALESCE(parent.Status, o.Status)               AS Status,
				COALESCE(parent.[Type], o.[Type])               AS OrderType,
				COALESCE(parent.DeliveryDate, o.DeliveryDate)   AS DeliveryDate

			  FROM PICKDETAIL pd WITH (NOLOCK)
			  JOIN Orders o WITH (NOLOCK)
				ON o.OrderKey   = pd.OrderKey
			   AND o.StorerKey  = pd.StorerKey

			  LEFT JOIN Orders parent WITH (NOLOCK)
				ON o.Rdd = 'SplitOrder'
			   AND parent.StorerKey = o.StorerKey
			   AND parent.OrderKey  = o.LoadKey

			  WHERE (pd.DropID IS NOT NULL OR pd.ID IS NOT NULL)
				AND COALESCE(parent.Facility, o.Facility) = 'EMG03'
				AND COALESCE(parent.Status, o.Status) <> '9'
			),

			-- 5) UrnNo para escaneo según el reporte
			pd_scan AS (
			  SELECT
				po.StorerKey,
				po.UnitLPN,
				po.OrderKey,
				po.MBOLKey,
				CASE
				  WHEN po.UOM = '1'
					THEN COALESCE(NULLIF(po.ID,''), po.DropID)
				  ELSE po.DropID
				END AS URNNo
			  FROM pd_orders po
			),

			-- 6) Flag de escaneo por UnitLPN: cualquier registro en STT cuenta como escaneado
			scan_by_unit AS (
			  SELECT
				ps.StorerKey,
				ps.UnitLPN,
				MAX(CASE WHEN stt.URNNo IS NOT NULL THEN 1 ELSE 0 END) AS IsScanned
			  FROM pd_scan ps
			  LEFT JOIN RDT.RDTSCANTOTRUCK AS stt WITH (NOLOCK)
				ON stt.MBOLKey = ps.MBOLKey
			   AND stt.URNNo   = ps.URNNo
			  GROUP BY ps.StorerKey, ps.UnitLPN
			),

			-- 7) “Mejor” orden por UnitLPN (para estado/fecha)
			best_order AS (
			  SELECT *,
					 ROW_NUMBER() OVER (
					   PARTITION BY StorerKey, UnitLPN
					   ORDER BY
						 CASE WHEN Status = 'CANC' THEN 1 ELSE 2 END,
						 CASE WHEN OrderType = '7' THEN 1 ELSE 2 END,
						 CASE WHEN DeliveryDate IS NULL THEN 2 ELSE 1 END,
						 DeliveryDate,
						 OrderKey DESC
					 ) AS rn
			  FROM pd_orders
			),

			chosen_order AS (
			  SELECT StorerKey, UnitLPN, Status, OrderType, DeliveryDate
			  FROM best_order
			  WHERE rn = 1
			),

			-- 8) Estado por unidad (UNKNOWN => CANC) y FILTRO: sólo no escaneados
			labelled AS (
			  SELECT
				u.Loc,
				u.UnitLPN AS LPN,
				CASE 
				  WHEN co.Status = 'CANC'                           THEN 'CANC'
				  WHEN co.OrderType = '7'                           THEN 'DECANT'
				  WHEN co.DeliveryDate IS NULL                      THEN 'CANC'    -- UNKNOWN => CANC
				  WHEN DATEDIFF(MINUTE, @now, co.DeliveryDate) <  0 THEN 'LATE'
				  WHEN DATEDIFF(MINUTE, @now, co.DeliveryDate) <= 120 THEN 'LT2H'
				  WHEN DATEDIFF(MINUTE, @now, co.DeliveryDate) <= 240 THEN 'H2_4H'
				  ELSE 'GT4H'
				END AS Estado
			  FROM universe u
			  LEFT JOIN chosen_order  co ON co.StorerKey = u.StorerKey AND co.UnitLPN = u.UnitLPN
			  LEFT JOIN scan_by_unit sb ON sb.StorerKey = u.StorerKey AND sb.UnitLPN = u.UnitLPN
			  WHERE ISNULL(sb.IsScanned, 0) = 0
			),

			-- 9) Numeración por muelle con tu prioridad de estado
			ranked AS (
			  SELECT
				l.Loc,
				l.LPN,
				l.Estado,
				ROW_NUMBER() OVER (
				  PARTITION BY l.Loc
				  ORDER BY
					CASE l.Estado
					  WHEN 'LATE'   THEN 1
					  WHEN 'LT2H'   THEN 2
					  WHEN 'H2_4H'  THEN 3
					  WHEN 'GT4H'   THEN 4
					  WHEN 'DECANT' THEN 5
					  WHEN 'CANC'   THEN 6
					  ELSE 99
					END,
					l.LPN
				) AS RowN
			  FROM labelled l
			)

			-- 10) Tabla final: por cada muelle, su columna de LPN y al lado la de ESTADO
			SELECT
			  r.RowN,

			  MAX(CASE WHEN r.Loc='ESM041'  THEN r.LPN    END) AS [ESM041],
			  MAX(CASE WHEN r.Loc='ESM041'  THEN r.Estado END) AS [ESM041_STATUS],

			  MAX(CASE WHEN r.Loc='ESM041B' THEN r.LPN    END) AS [ESM041B],
			  MAX(CASE WHEN r.Loc='ESM041B' THEN r.Estado END) AS [ESM041B_STATUS],

			  MAX(CASE WHEN r.Loc='ESM041C' THEN r.LPN    END) AS [ESM041C],
			  MAX(CASE WHEN r.Loc='ESM041C' THEN r.Estado END) AS [ESM041C_STATUS],

			  MAX(CASE WHEN r.Loc='ESM042'  THEN r.LPN    END) AS [ESM042],
			  MAX(CASE WHEN r.Loc='ESM042'  THEN r.Estado END) AS [ESM042_STATUS],

			  MAX(CASE WHEN r.Loc='ESM042B' THEN r.LPN    END) AS [ESM042B],
			  MAX(CASE WHEN r.Loc='ESM042B' THEN r.Estado END) AS [ESM042B_STATUS],

			  MAX(CASE WHEN r.Loc='ESM042C' THEN r.LPN    END) AS [ESM042C],
			  MAX(CASE WHEN r.Loc='ESM042C' THEN r.Estado END) AS [ESM042C_STATUS],

			  MAX(CASE WHEN r.Loc='ESM043'  THEN r.LPN    END) AS [ESM043],
			  MAX(CASE WHEN r.Loc='ESM043'  THEN r.Estado END) AS [ESM043_STATUS],

			  MAX(CASE WHEN r.Loc='ESM044'  THEN r.LPN    END) AS [ESM044],
			  MAX(CASE WHEN r.Loc='ESM044'  THEN r.Estado END) AS [ESM044_STATUS],

			  MAX(CASE WHEN r.Loc='ESM045'  THEN r.LPN    END) AS [ESM045],
			  MAX(CASE WHEN r.Loc='ESM045'  THEN r.Estado END) AS [ESM045_STATUS],

			  MAX(CASE WHEN r.Loc='ESM046'  THEN r.LPN    END) AS [ESM046],
			  MAX(CASE WHEN r.Loc='ESM046'  THEN r.Estado END) AS [ESM046_STATUS],

			  MAX(CASE WHEN r.Loc='ESM047'  THEN r.LPN    END) AS [ESM047],
			  MAX(CASE WHEN r.Loc='ESM047'  THEN r.Estado END) AS [ESM047_STATUS],

			  MAX(CASE WHEN r.Loc='ESM048'  THEN r.LPN    END) AS [ESM048],
			  MAX(CASE WHEN r.Loc='ESM048'  THEN r.Estado END) AS [ESM048_STATUS],

			  MAX(CASE WHEN r.Loc='ESM049'  THEN r.LPN    END) AS [ESM049],
			  MAX(CASE WHEN r.Loc='ESM049'  THEN r.Estado END) AS [ESM049_STATUS],

			  MAX(CASE WHEN r.Loc='ESM050'  THEN r.LPN    END) AS [ESM050],
			  MAX(CASE WHEN r.Loc='ESM050'  THEN r.Estado END) AS [ESM050_STATUS],

			  MAX(CASE WHEN r.Loc='ESM051'  THEN r.LPN    END) AS [ESM051],
			  MAX(CASE WHEN r.Loc='ESM051'  THEN r.Estado END) AS [ESM051_STATUS],

			  MAX(CASE WHEN r.Loc='ESM052'  THEN r.LPN    END) AS [ESM052],
			  MAX(CASE WHEN r.Loc='ESM052'  THEN r.Estado END) AS [ESM052_STATUS],

			  MAX(CASE WHEN r.Loc='ESM053'  THEN r.LPN    END) AS [ESM053],
			  MAX(CASE WHEN r.Loc='ESM053'  THEN r.Estado END) AS [ESM053_STATUS],

			  MAX(CASE WHEN r.Loc='ESM054'  THEN r.LPN    END) AS [ESM054],
			  MAX(CASE WHEN r.Loc='ESM054'  THEN r.Estado END) AS [ESM054_STATUS],

			  MAX(CASE WHEN r.Loc='ESM055'  THEN r.LPN    END) AS [ESM055],
			  MAX(CASE WHEN r.Loc='ESM055'  THEN r.Estado END) AS [ESM055_STATUS],

			  MAX(CASE WHEN r.Loc='ESM056'  THEN r.LPN    END) AS [ESM056],
			  MAX(CASE WHEN r.Loc='ESM056'  THEN r.Estado END) AS [ESM056_STATUS],

			  MAX(CASE WHEN r.Loc='ESM057'  THEN r.LPN    END) AS [ESM057],
			  MAX(CASE WHEN r.Loc='ESM057'  THEN r.Estado END) AS [ESM057_STATUS],

			  MAX(CASE WHEN r.Loc='ESM058'  THEN r.LPN    END) AS [ESM058],
			  MAX(CASE WHEN r.Loc='ESM058'  THEN r.Estado END) AS [ESM058_STATUS],

			  MAX(CASE WHEN r.Loc='ESM059'  THEN r.LPN    END) AS [ESM059],
			  MAX(CASE WHEN r.Loc='ESM059'  THEN r.Estado END) AS [ESM059_STATUS],

			  MAX(CASE WHEN r.Loc='ESM060'  THEN r.LPN    END) AS [ESM060],
			  MAX(CASE WHEN r.Loc='ESM060'  THEN r.Estado END) AS [ESM060_STATUS],

			  MAX(CASE WHEN r.Loc='ESM061'  THEN r.LPN    END) AS [ESM061],
			  MAX(CASE WHEN r.Loc='ESM061'  THEN r.Estado END) AS [ESM061_STATUS],

			  MAX(CASE WHEN r.Loc='ESM062'  THEN r.LPN    END) AS [ESM062],
			  MAX(CASE WHEN r.Loc='ESM062'  THEN r.Estado END) AS [ESM062_STATUS]

			FROM ranked r
			GROUP BY r.RowN
			ORDER BY r.RowN;


		--
		END
			  
GO


