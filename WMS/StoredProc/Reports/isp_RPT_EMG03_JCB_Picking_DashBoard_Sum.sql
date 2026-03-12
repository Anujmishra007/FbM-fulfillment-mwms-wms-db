SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_RPT_EMG03_JCB_Picking_DashBoard_Sum               */
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
	  	  
CREATE OR ALTER PROC [BI].[isp_RPT_EMG03_JCB_Picking_DashBoard_Sum]  @delivery_date_limit DATETIME 
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
		 COUNT(*) AS Pallets
	  FROM dbo.PICKDETAIL pd WITH (NOLOCK)
	  WHERE NULLIF(LTRIM(RTRIM(pd.OrderKey)), '') IS NOT NULL
	  GROUP BY
	     pd.StorerKey,
		 pd.OrderKey
   ),
   base AS (
      SELECT
	     CAST(od.DeliveryDate AS date) AS [Date],
		 CASE
		    WHEN od.Status = '2' THEN 'Allocated'
			WHEN od.Status = '3' THEN 'In Progress'
		 END AS [Status],
		 CONCAT_WS(' - ', od.Type, COALESCE(ck.Description, 'No description')) AS [Order Type],
		 od.OrderKey,
		 CASE WHEN GETDATE() >  od.DeliveryDate THEN 1 ELSE 0 END AS IsLate,
		 CASE WHEN GETDATE() <= od.DeliveryDate THEN 1 ELSE 0 END AS IsOnTime,
		 COALESCE(p.Pallets, 0) AS Pallets
      FROM dbo.orders od WITH (NOLOCK)
	     LEFT JOIN dbo.CODELKUP ck WITH (NOLOCK)
		    ON  od.StorerKey = ck.StorerKey
			AND od.Type      = ck.Short
			AND ck.LISTNAME  = 'ORDERTYPE'
		 LEFT JOIN pdAgg p
		    ON  od.StorerKey = p.StorerKey
			AND od.OrderKey  = p.OrderKey
      WHERE od.StorerKey = 'JCB'
	     AND od.Status IN ('2','3')
	     AND od.OrderGroup <> 'XDOCK'
		 AND od.DeliveryDate <= @delivery_date_limit
   )
   SELECT
      FORMAT([Date], 'dd/MM/yyyy') AS [Date],
	  [Status],
	  [Order Type],
	  COUNT(*)      AS [Total Orders],
	  SUM(IsLate)   AS [Total Late],
	  SUM(IsOnTime) AS [Total On Time],
	  SUM(Pallets)  AS [Pallets]
   FROM base
   GROUP BY
      [Date],
	  [Status],
	  [Order Type]
   ORDER BY
      [Date],
	  [Status],
	  [Order Type];		
END
