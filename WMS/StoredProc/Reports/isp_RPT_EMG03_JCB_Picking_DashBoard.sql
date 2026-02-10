SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_RPT_EMG03_JCB_Picking_DashBoard                   */
/* Creation Date: 01/12/2026                                               */
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
/* 23/01/2026   AGM046  1.0                                                */
/***************************************************************************/
	  	  
CREATE OR ALTER PROC [BI].[isp_RPT_EMG03_JCB_Picking_DashBoard]  @delivery_date_limit DATETIME 
AS
BEGIN	  
   SET NOCOUNT ON 
   SET ANSI_NULLS OFF 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF 
		 		
   ;WITH pdAgg AS (
      SELECT
	     pd.StorerKey,
	     pd.OrderKey,
	     COUNT(*) AS pkdsh_Total_CasPall,
	     SUM(CASE WHEN pd.Status <= 4 THEN 1 ELSE 0 END) AS pkdsh_Remain_CasPall,
	     SUM(CASE WHEN ad.AreaKey = 'EMGWA'      THEN 1 ELSE 0 END) AS [WIDE],
	     SUM(CASE WHEN ad.AreaKey = 'EMGVNA1'    THEN 1 ELSE 0 END) AS [VNA1],
	     SUM(CASE WHEN ad.AreaKey = 'EMGVNA2'    THEN 1 ELSE 0 END) AS [VNA2],
	     SUM(CASE WHEN ad.AreaKey = 'EMGVNA3'    THEN 1 ELSE 0 END) AS [VNA3],
	     SUM(CASE WHEN ad.AreaKey = 'EMGVNA4'    THEN 1 ELSE 0 END) AS [VNA4],
	     SUM(CASE WHEN ad.AreaKey = 'EMGVNA5'    THEN 1 ELSE 0 END) AS [VNA5],
	     SUM(CASE WHEN ad.AreaKey = 'EMGBULKINT' THEN 1 ELSE 0 END) AS [BULK-INT],
	     SUM(CASE WHEN ad.AreaKey = 'EMGBULKEXT' THEN 1 ELSE 0 END) AS [BULK-EXT],
	     SUM(CASE WHEN ad.AreaKey = 'EMGMEZZ'    THEN 1 ELSE 0 END) AS [MEZZ],
	     SUM(CASE WHEN ad.AreaKey = 'EMGPDOUT'   THEN 1 ELSE 0 END) AS [P&D],
	     SUM(CASE WHEN ad.AreaKey = 'EMGCABSKIT' THEN 1 ELSE 0 END) AS [CABSKIT],
	     SUM(CASE WHEN ad.AreaKey = 'EMGLPKIT'   THEN 1 ELSE 0 END) AS [LPKIT],
	     SUM(CASE WHEN ad.AreaKey = 'EMGT4KIT'   THEN 1 ELSE 0 END) AS [T4],
	     SUM(CASE WHEN ad.AreaKey = 'MOTHERSONS' THEN 1 ELSE 0 END) AS [MOTHERSONS]	
      FROM dbo.PICKDETAIL pd WITH (NOLOCK)
	     LEFT JOIN dbo.LOC l WITH (NOLOCK)
		    ON pd.Loc = l.Loc
			AND l.Facility = 'EMG03'
		 LEFT JOIN dbo.AreaDetail ad WITH (NOLOCK)
		    ON ad.PutawayZone = l.PutawayZone
      WHERE NULLIF(LTRIM(RTRIM(pd.OrderKey)), '') IS NOT NULL
      GROUP BY 
	     pd.StorerKey, 
		 pd.OrderKey
   ),
   od_sum AS (
      SELECT
         OrderKey,
		 StorerKey,
		 Facility,
		 SUM(OpenQty) AS OpenQtySum
      FROM dbo.ORDERDETAIL WITH (NOLOCK)
	  GROUP BY OrderKey, StorerKey, Facility
   ),
   td_sum AS (
      SELECT
	     OrderKey,
		 StorerKey,
		 SUM(Qty) AS TaskQtySum
	  FROM dbo.TASKDETAIL WITH (NOLOCK)
	  WHERE TaskType = 'FCP'
	  GROUP BY 
	     OrderKey, 
		 StorerKey
   ),
   tr AS (
      SELECT
	     d.OrderKey,
		 d.StorerKey,
		 d.Facility,
		 CASE
		    WHEN COALESCE(t.TaskQtySum, 0) = 0 THEN 'Not Released'
		    WHEN COALESCE(t.TaskQtySum, 0) < COALESCE(d.OpenQtySum, 0) THEN 'Partially Released'
		    WHEN COALESCE(t.TaskQtySum, 0) = COALESCE(d.OpenQtySum, 0) THEN 'Released'
		 ELSE 'Over Released'
		 END AS Task_Release
      FROM od_sum d
	     LEFT JOIN td_sum t
		    ON t.OrderKey  = d.OrderKey
			AND t.StorerKey = d.StorerKey
   )
   SELECT
      'DelDate: ' + FORMAT(od.DeliveryDate, 'dd/MM/yyyy') AS pkdsh_Hd_DeliveryDate,
	  FORMAT(od.DeliveryDate, 'dd/MM/yyyy HH:mm')         AS pkdsh_DeliveryDate,
	  od.OrderKey                                         AS pkdsh_OrderID,
	  od.UserDefine09                                     AS pkdsh_WaveID,
	  od.ExternOrderKey                                   AS pkdsh_SellerOrderID,
      od.Type                                             AS pkdsh_otINT,
	  CONCAT_WS(' - ', od.Type, COALESCE(ck.Description, 'No description')) AS pkdsh_OrderType,
	  od.C_Company                                        AS pkdsh_C_Company,
	  CASE 
	     WHEN od.Status = '2' THEN 'Allocated'
	     WHEN od.Status = '3' THEN 'In Progress'
      END                                                 AS pkdsh_Status,
	  od.Notes                                            AS pkdsh_Comments,
      CONCAT(
	     CASE 
		    WHEN d.DeltaSec < 0 THEN '-' ELSE '' 
		 END,
		 a.DaysAbs, ' days, ',
		 CONVERT(varchar(8), DATEADD(SECOND, a.RemSec, 0), 108),
		 CASE 
		    WHEN d.DeltaSec < 0 THEN ' late' ELSE ' left' 
		 END
	  )                                                   AS pkdsh_LATE,
      CASE 
	     WHEN GETDATE() <= od.DeliveryDate THEN 'ON-TIME'
		 ELSE 'DELAYED'
	  END                                                 AS pkdsh_LateStatus,
      COALESCE(pdAgg.pkdsh_Total_CasPall, 0)              AS pkdsh_Total_CasPall,
	  COALESCE(pdAgg.pkdsh_Remain_CasPall, 0)             AS pkdsh_Remain_CasPall,
      CAST(
	     CASE
		    WHEN COALESCE(pdAgg.pkdsh_Total_CasPall, 0) = 0 THEN 0
			ELSE ROUND(100.0 * (COALESCE(pdAgg.pkdsh_Total_CasPall, 0) - COALESCE(pdAgg.pkdsh_Remain_CasPall, 0)) /  COALESCE(pdAgg.pkdsh_Total_CasPall, 0),0)
		 END AS int)                                       AS pkdsh_PercentPicked_n,
      CONCAT(
         CAST(
		    CASE
			   WHEN COALESCE(pdAgg.pkdsh_Total_CasPall, 0) = 0 THEN 0
			   ELSE ROUND(100.0 * (COALESCE(pdAgg.pkdsh_Total_CasPall, 0) - COALESCE(pdAgg.pkdsh_Remain_CasPall, 0)) /  COALESCE(pdAgg.pkdsh_Total_CasPall, 0),0)
			END AS int
		 ),
		 ' %'
      )                                                   AS pkdsh_PercentPicked,
      COALESCE(tr.Task_Release, 'Not Released')           AS [pkdsh_Task_Release],
      COALESCE(pdAgg.[WIDE], 0)                           AS [pkdsh_WIDE],
	  COALESCE(pdAgg.[VNA1], 0)                           AS [pkdsh_VNA1],
	  COALESCE(pdAgg.[VNA2], 0)                           AS [pkdsh_VNA2],
	  COALESCE(pdAgg.[VNA3], 0)                           AS [pkdsh_VNA3],
	  COALESCE(pdAgg.[VNA4], 0)                           AS [pkdsh_VNA4],
	  COALESCE(pdAgg.[VNA5], 0)                           AS [pkdsh_VNA5],
	  COALESCE(pdAgg.[BULK-INT], 0)                       AS [pkdsh_BULK-INT],
	  COALESCE(pdAgg.[BULK-EXT], 0)                       AS [pkdsh_BULK-EXT],
	  COALESCE(pdAgg.[MEZZ], 0)                           AS [pkdsh_MEZZ],
	  COALESCE(pdAgg.[P&D], 0)                            AS [pkdsh_P&D],
	  COALESCE(pdAgg.[CABSKIT], 0)                        AS [pkdsh_CABSKIT],
	  COALESCE(pdAgg.[LPKIT], 0)                          AS [pkdsh_LPKIT],
	  COALESCE(pdAgg.[T4], 0)                             AS [pkdsh_T4],
	  COALESCE(pdAgg.[MOTHERSONS], 0)                     AS [pkdsh_MOTHERSONS]
   FROM dbo.orders od WITH (NOLOCK)
      LEFT JOIN dbo.CODELKUP ck WITH (NOLOCK)
	     ON od.storerkey = ck.Storerkey
		 AND od.Type      = ck.Short
		 AND ck.LISTNAME  = 'ORDERTYPE'
	  LEFT JOIN pdAgg
		 ON od.StorerKey = pdAgg.StorerKey
		 AND od.OrderKey  = pdAgg.OrderKey
	  LEFT JOIN tr
	     ON tr.OrderKey  = od.OrderKey
		 AND tr.StorerKey = od.StorerKey
		 AND tr.Facility  = od.Facility
	  CROSS APPLY (
	     SELECT DATEDIFF(SECOND, GETDATE(), od.DeliveryDate) AS DeltaSec
	  ) d
      CROSS APPLY (
	     SELECT
		    ABS(d.DeltaSec) / 86400 AS DaysAbs,
			ABS(d.DeltaSec) % 86400 AS RemSec
	  ) a
   WHERE od.storerkey = 'JCB'
      AND od.status IN ('2','3')
	  AND od.DeliveryDate <= @delivery_date_limit
   ORDER BY od.DeliveryDate ASC
END
