USE [GBRWMS]
GO


SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE OR ALTER PROC [BI].[isp_RPT_JCB_EMG03_Marshall_Lane_Outbound_Sumarize]
AS
BEGIN
  SET NOCOUNT ON;
  SET ANSI_NULLS OFF;
  SET QUOTED_IDENTIFIER OFF;
  SET CONCAT_NULL_YIELDS_NULL OFF;

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

		-- 2) Físico desde LOTxLOCxID (solo muelles listados, JCB, Qty>0)
		lli_base AS (
		  SELECT lli.StorerKey, lli.Loc, lli.Id AS PalletId, lli.Qty
		  FROM LOTxLOCxID lli WITH (NOLOCK)
		  JOIN lanes ln ON ln.Loc = lli.Loc
		  WHERE lli.StorerKey = 'JCB'
			AND lli.Qty > 0
		),

		-- 3) Expandir pallets a “unidades” (cajas si existen, si no el propio pallet)
		--    Solo órdenes de EMG03 con Status <> '9'
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
			ON o.OrderKey  = pd.OrderKey
		   AND o.StorerKey = pd.StorerKey
		   AND o.Facility  = 'EMG03'
		   AND o.Status   <> '9'
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

		universe AS (        -- deduplicar por (StorerKey, Loc, UnitLPN)
		  SELECT StorerKey, Loc, UnitLPN
		  FROM (
			SELECT *,
				   ROW_NUMBER() OVER (
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

		/* 4) PICKDETAIL + Orders normalizado a UnitLPN
			  MODIFICADO: si es SplitOrder, usar datos de la orden madre (parent) */
		pd_orders AS (
		  SELECT DISTINCT
			pd.StorerKey,
			pd.OrderKey,
			pd.UOM,
			pd.ID,
			pd.DropID,
			CASE
			  WHEN pd.DropID IS NULL OR pd.DropID = '' OR pd.DropID = pd.ID
				THEN pd.ID          -- UnitLPN: pallet
			  ELSE pd.DropID        -- UnitLPN: caja
			END AS UnitLPN,

			COALESCE(parent.MBOLKey, o.MBOLKey)                 AS MBOLKey,
			COALESCE(parent.Facility, o.Facility)               AS Facility,
			COALESCE(parent.Status, o.Status)                   AS Status,
			COALESCE(parent.[Type], o.[Type])                   AS OrderType,
			COALESCE(parent.DeliveryDate, o.DeliveryDate)       AS DeliveryDate

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

		-- 5) URNNo para escaneo según el reporte
		pd_scan AS (
		  SELECT
			po.StorerKey,
			po.UnitLPN,
			po.OrderKey,
			po.MBOLKey,
			CASE
			  WHEN po.UOM = '1' THEN COALESCE(NULLIF(po.ID,''), po.DropID)
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

		-- 8) Estado por unidad (UNKNOWN => CANC) + FILTRO: solo NO escaneados
		labelled AS (
		  SELECT
			u.Loc,
			u.UnitLPN AS LPN,
			CASE 
			  WHEN co.Status = 'CANC'                      THEN 'CANC'
			  WHEN co.OrderType = '7'                      THEN 'DECANT'
			  WHEN co.DeliveryDate IS NULL                 THEN 'CANC'    -- UNKNOWN => CANC
			  WHEN DATEDIFF(MINUTE, @now, co.DeliveryDate) <  0   THEN 'LATE'
			  WHEN DATEDIFF(MINUTE, @now, co.DeliveryDate) <= 120 THEN 'LT2H'
			  WHEN DATEDIFF(MINUTE, @now, co.DeliveryDate) <= 240 THEN 'H2_4H'
			  ELSE 'GT4H'
			END AS Estado
		  FROM universe u
		  LEFT JOIN chosen_order  co ON co.StorerKey = u.StorerKey AND co.UnitLPN = u.UnitLPN
		  LEFT JOIN scan_by_unit sb ON sb.StorerKey = u.StorerKey AND sb.UnitLPN = u.UnitLPN
		  WHERE ISNULL(sb.IsScanned, 0) = 0
		),

		-- 9) Flags por muelle (cuenta unidades: cajas o pallet)
		loc_counts_agg AS (
		  SELECT
			Loc,
			SUM(CASE WHEN Estado = 'LATE'   THEN 1 ELSE 0 END) AS Late_Flag,
			SUM(CASE WHEN Estado = 'LT2H'   THEN 1 ELSE 0 END) AS LT2H_Flag,
			SUM(CASE WHEN Estado = 'H2_4H'  THEN 1 ELSE 0 END) AS H2_4H_Flag,
			SUM(CASE WHEN Estado = 'GT4H'   THEN 1 ELSE 0 END) AS GT4H_Flag,
			SUM(CASE WHEN Estado = 'DECANT' THEN 1 ELSE 0 END) AS Decant_Flag,
			SUM(CASE WHEN Estado = 'CANC'   THEN 1 ELSE 0 END) AS CANC_Flag,
			COUNT(DISTINCT LPN)                                 AS Total_Flag
		  FROM labelled
		  GROUP BY Loc
		),

		-- 10) Resumen con lanes sin stock (ceros)
		lane_summary AS (
		  SELECT
			ln.Loc AS MarshallLane,
			ISNULL(a.Late_Flag,   0) AS Late_Flag,
			ISNULL(a.LT2H_Flag,   0) AS LT2H_Flag,
			ISNULL(a.H2_4H_Flag,  0) AS H2_4H_Flag,
			ISNULL(a.GT4H_Flag,   0) AS GT4H_Flag,
			ISNULL(a.Decant_Flag, 0) AS Decant_Flag,
			ISNULL(a.CANC_Flag,   0) AS CANC_Flag,
			ISNULL(a.Total_Flag,  0) AS Total_Flag
		  FROM lanes ln
		  LEFT JOIN loc_counts_agg a
			ON a.Loc = ln.Loc
		),

		-- 11) UNPIVOT: filas = métrica, columnas = lane
		unpivoted AS (
		  SELECT
			ls.MarshallLane,
			v.Metric,
			v.Value
		  FROM lane_summary ls
		  CROSS APPLY (VALUES
			('Late LPNs',          ls.Late_Flag),
			('<2 Hours LPNs',      ls.LT2H_Flag),
			('2-4 Hours LPNs',     ls.H2_4H_Flag),
			('>4 Hours LPNs',      ls.GT4H_Flag),
			('Decant LPNs',        ls.Decant_Flag),
			('LPNs with no order', ls.CANC_Flag),
			('Total LPNs',         ls.Total_Flag)
		  ) v(Metric, Value)
		)

		-- 12) PIVOT final: columnas = MarshallLane, filas = Metric
		SELECT
		  Metric,
		  [ESM041],[ESM041B],[ESM041C],
		  [ESM042],[ESM042B],[ESM042C],
		  [ESM043],
		  [ESM044],
		  [ESM045],[ESM046],[ESM047],
		  [ESM048],[ESM049],
		  [ESM050],[ESM051],
		  [ESM052],[ESM053],[ESM054],
		  [ESM055],[ESM056],[ESM057],
		  [ESM058],[ESM059],
		  [ESM060],
		  [ESM061],[ESM062]
		FROM unpivoted
		PIVOT (
		  SUM(Value) FOR MarshallLane IN (
			[ESM041],[ESM041B],[ESM041C],
			[ESM042],[ESM042B],[ESM042C],
			[ESM043],
			[ESM044],
			[ESM045],[ESM046],[ESM047],
			[ESM048],[ESM049],
			[ESM050],[ESM051],
			[ESM052],[ESM053],[ESM054],
			[ESM055],[ESM056],[ESM057],
			[ESM058],[ESM059],
			[ESM060],
			[ESM061],[ESM062]
		  )
		) p
		ORDER BY
		  CASE Metric
			WHEN 'Late LPNs'          THEN 1
			WHEN '<2 Hours LPNs'      THEN 2
			WHEN '2-4 Hours LPNs'     THEN 3
			WHEN '>4 Hours LPNs'      THEN 4
			WHEN 'Decant LPNs'        THEN 5
			WHEN 'LPNs with no order' THEN 6
			WHEN 'Total LPNs'         THEN 7
			ELSE 99
		  END;

END
GO


