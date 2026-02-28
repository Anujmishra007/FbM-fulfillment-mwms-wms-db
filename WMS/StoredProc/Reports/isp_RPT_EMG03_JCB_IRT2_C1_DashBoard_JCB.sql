SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Stored Procedure: isp_RPT_EMG03_JCB_IRT2_C1_DashBoard_JCB               */
/* Creation Date: 18/01/2026                                               */
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
/* 18/01/2026   AGM046  1.0                                                */
/***************************************************************************/
	  	     
CREATE OR ALTER PROC [BI].[isp_RPT_EMG03_JCB_IRT2_C1_DashBoard_JCB]      	  
AS	 
BEGIN	  
   SET NOCOUNT ON 
   SET ANSI_NULLS OFF 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF 
		 
   ;WITH BU_Limits AS (
      SELECT *
	  FROM (
	     VALUES
		 ('JCBJ0', 5,  1),
		 ('JCBJ1', 5,  2),
		 ('JCBJ2', 5,  3),
		 ('JCBJ3', 5,  4),
		 ('JCBJ4', 5,  5),
		 ('JCBJ5', 8,  6),
		 ('JCBJ6', 5,  7),
		 ('JCBJ7', 5,  8),
		 ('JCBJ8', 5,  9),
		 ('JCBJX', 5, 10),
		 ('JCBJY', 0, 11),
		 ('JCBJZ', 3, 12)
      ) v(Businness_Unit, Emergency_Limit, SortOrder)
   ),
   Base AS (
      SELECT
	     od1.Businness_Unit,
		 SUM(CASE WHEN ISNULL(o.Priority, 0) = 1  THEN 1 ELSE 0 END) AS Emergency_Orders,
		 SUM(CASE WHEN ISNULL(o.Priority, 0) <> 1 THEN 1 ELSE 0 END) AS Standard_Orders
      FROM dbo.ORDERS o WITH (NOLOCK)
	     INNER JOIN (
		    SELECT
			   OrderKey,
			   StorerKey,
			   Facility,
			   MAX(Lottable03) AS Businness_Unit
			FROM dbo.ORDERDETAIL WITH (NOLOCK)
			WHERE StorerKey = 'JCB'
			   AND Facility  = 'EMG03'
		    GROUP BY OrderKey, StorerKey, Facility
		 ) od1
		    ON od1.OrderKey  = o.OrderKey
			AND od1.StorerKey = o.StorerKey
			AND od1.Facility  = o.Facility
      WHERE o.StorerKey = 'JCB'
	     AND o.Facility  = 'EMG03'
		 AND o.OrderGroup <> 'XDOCK' 
		 AND o.Status <> '9'
		 AND o.Status <> 'CANC'
		 AND o.Status <> ''
		 AND o.OpenQty > 0
      GROUP BY od1.Businness_Unit
   ),
   Totals AS (
      SELECT
	     Sum_J6J7 = SUM(CASE WHEN b.Businness_Unit IN ('JCBJ6','JCBJ7') THEN b.Emergency_Orders ELSE 0 END)
	  FROM Base b
   )
   SELECT
      COALESCE(l.Businness_Unit, b.Businness_Unit) AS Businness_Unit,
	  CASE
	     WHEN COALESCE(l.Businness_Unit, b.Businness_Unit) IN ('JCBJ6','JCBJ7')
		 THEN COALESCE(t.Sum_J6J7, 0)
		 ELSE COALESCE(b.Emergency_Orders, 0)
	  END AS Emergency_Orders,
      COALESCE(b.Standard_Orders, 0) AS Standard_Orders,
      CASE
	     WHEN l.Emergency_Limit IS NULL THEN 'UNDEF'
		 WHEN
		 CASE
		    WHEN COALESCE(l.Businness_Unit, b.Businness_Unit) IN ('JCBJ6','JCBJ7')
			THEN COALESCE(t.Sum_J6J7, 0)
			ELSE COALESCE(b.Emergency_Orders, 0)
		 END <= l.Emergency_Limit
		 THEN 'GREEN'
		 ELSE 'RED'
      END AS HL_Status
   FROM Base b
      FULL OUTER JOIN BU_Limits l
	     ON l.Businness_Unit = b.Businness_Unit
	  CROSS JOIN Totals t
   ORDER BY
      CASE WHEN l.SortOrder IS NULL THEN 1 ELSE 0 END,
	  l.SortOrder,
	  CASE WHEN l.SortOrder IS NULL THEN COALESCE(b.Emergency_Orders,0) END DESC,
	  COALESCE(l.Businness_Unit, b.Businness_Unit);
END
