SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_RPT_EMG03_JCB_IRT2_C2_DashBoard_JCB               */
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
	  	     
CREATE OR ALTER PROCEDURE [BI].[isp_RPT_EMG03_JCB_IRT2_C2_DashBoard_JCB]      	  
AS	 
BEGIN	  
   SET NOCOUNT ON 
   SET ANSI_NULLS OFF 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF 

   ;WITH base AS (
      SELECT
	     o.OrderKey,
		 Status_Calc = s.Status_Calc,
		 Status_Desc = 
		 CASE s.Status_Calc
		    WHEN '0' THEN 'Normal'
		    WHEN '1' THEN 'Partially Allocated'
		    WHEN '2' THEN 'Fully Allocated'
		    WHEN '3' THEN 'In Process'
		    WHEN '5' THEN 'Picked'
		    WHEN '6' THEN 'Marshalled'
		    WHEN '7' THEN 'Loaded'
		    WHEN '9' THEN 'Shipped'
		    ELSE 'Unknown'
         END,
         CASE
            WHEN o.ecom_platform IN ('3RDParty', '3RDPartyQty') THEN 'THIRD_PARTY'
			WHEN o.ecom_platform IN ('EMG_EMER', 'EMG') OR o.ecom_platform IS NULL OR o.ecom_platform = '' THEN 'EMG'
			ELSE 'OTHER'
		 END AS Order_Group,				
		 CASE
		    WHEN ISNULL(o.Priority, 0) = 1 THEN 'EMERGENCY'
			ELSE 'STANDARD'
		 END AS Order_Urgency
      FROM dbo.ORDERS o WITH (NOLOCK)
	     CROSS APPLY (
		    SELECT Status_Calc =
			   CASE
			      WHEN o.Status = '5'
				     AND EXISTS (
					    SELECT 1
						FROM PICKDETAIL pd WITH (NOLOCK)
						   INNER JOIN rdt.rdtScanToTruck stt WITH (NOLOCK)
						      ON stt.Orderkey = pd.Orderkey
							  AND stt.URNNo    = pd.DropID
							  AND stt.Status   = '9'
						WHERE pd.OrderKey  = o.OrderKey
						   AND pd.Storerkey = 'JCB'
						   AND pd.Status <> 9
					 )
                  THEN '7'
				  WHEN o.Status = '5'
				     AND NOT EXISTS (
					    SELECT 1
						FROM PICKDETAIL pd WITH (NOLOCK)
					       INNER JOIN rdt.rdtScanToTruck stt WITH (NOLOCK)
						      ON stt.Orderkey = pd.Orderkey
							  AND stt.URNNo    = pd.DropID
							  AND stt.Status   = '9'
						WHERE pd.OrderKey  = o.OrderKey
						   AND pd.Storerkey = 'JCB'
						   AND pd.Status <> 9
						)
					 AND EXISTS (
					    SELECT 1
						FROM PICKDETAIL pd WITH (NOLOCK)
						WHERE pd.OrderKey  = o.OrderKey
						   AND pd.Storerkey = 'JCB'
						   AND pd.Status <> 9
					 )
					 AND NOT EXISTS (
					    SELECT 1
						FROM PICKDETAIL pd WITH (NOLOCK)
						WHERE pd.OrderKey  = o.OrderKey
						   AND pd.Storerkey = 'JCB'
						   AND pd.Status <> 9
						   AND NOT EXISTS (
						      SELECT 1
						      FROM CODELKUP ck WITH (NOLOCK)
							  WHERE ck.ListName  = 'JCBCOMPML'
							     AND ck.Storerkey = 'JCB'
								 AND ck.Short     = pd.Loc
						   )
					 )
					 THEN '6'
					 ELSE o.Status
				  END
         ) s
		 WHERE o.StorerKey = 'JCB'
		    AND o.Facility = 'EMG03'
			AND o.OrderGroup <> 'XDOCK'
			AND o.Status <> '9'
			AND o.Type <> '9'        
			AND o.Type <> 'CANC'     
			AND (o.ecom_platform IS NOT NULL AND o.ecom_platform <> '')
			AND o.DeliveryDate < DATEADD(day, 1,
			CASE DATENAME(WEEKDAY, CONVERT(date, GETDATE()))
			   WHEN 'Friday'   THEN DATEADD(day, 3, CONVERT(date, GETDATE()))
			   WHEN 'Saturday' THEN DATEADD(day, 2, CONVERT(date, GETDATE()))
			   WHEN 'Sunday'   THEN DATEADD(day, 1, CONVERT(date, GETDATE()))
			   ELSE                 DATEADD(day, 1, CONVERT(date, GETDATE()))
			END)
			AND LTRIM(RTRIM(ISNULL(o.Status,''))) <> 'CANC'
			AND ISNULL(o.Type,'') <> 'CANC'
   )
   SELECT
      Status_Desc AS [IRT2C2_Status],
	  SUM(CASE WHEN Order_Group = 'EMG'         AND Order_Urgency = 'EMERGENCY' THEN 1 ELSE 0 END) AS [EMG_Emergency],
	  SUM(CASE WHEN Order_Group = 'EMG'         AND Order_Urgency = 'STANDARD'  THEN 1 ELSE 0 END) AS [EMG_Standard],
	  SUM(CASE WHEN Order_Group = 'THIRD_PARTY' AND Order_Urgency = 'EMERGENCY' THEN 1 ELSE 0 END) AS [ThirdParty_Emergency],
	  SUM(CASE WHEN Order_Group = 'THIRD_PARTY' AND Order_Urgency = 'STANDARD'  THEN 1 ELSE 0 END) AS [ThirdParty_Standard]
   FROM base
   WHERE Order_Group IN ('EMG', 'THIRD_PARTY')
   GROUP BY Status_Desc
   ORDER BY
      CASE Status_Desc
	     WHEN 'Normal' THEN 0
		 WHEN 'Partially Allocated' THEN 1
		 WHEN 'Fully Allocated' THEN 2
		 WHEN 'In Process' THEN 3
		 WHEN 'Picked' THEN 4
		 WHEN 'Marshalled' THEN 5
		 WHEN 'Loaded' THEN 6
		 ELSE 99
   END
END
