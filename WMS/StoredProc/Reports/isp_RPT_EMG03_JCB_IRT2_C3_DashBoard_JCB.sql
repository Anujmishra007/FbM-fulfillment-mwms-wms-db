SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Stored Procedure: isp_RPT_EMG03_JCB_IRT2_C3_DashBoard_JCB               */
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
	  	     
CREATE OR ALTER PROCEDURE [BI].[isp_RPT_EMG03_JCB_IRT2_C3_DashBoard_JCB]      	  
AS	 
BEGIN	  
   SET NOCOUNT ON 
   SET ANSI_NULLS OFF 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF 

   SELECT 
      o.C_Company AS IRT2C3_Delivey_Address,
	  od1.Bussines_Unit AS IRT2C3_Bussines_Unit,
	  o.ExternOrderKey AS IRT2C3_Order_Name,
	  o.OrderKey AS IRT2C3_Order_Number,
	  FORMAT(o.DeliveryDate, 'dd/MM/yyyy HH:mm') AS IRT2C3_Del_Date_Time,
	  CASE o.Type
	     WHEN '0' THEN 'Standard'
		 WHEN '2' THEN 'Cabs Kitting'
		 WHEN '6' THEN 'Tier IV Kitting'
		 WHEN '7' THEN 'Decant'
		 WHEN '8' THEN 'LandPower Kitting'
		 ELSE 'Unknown'
      END AS IRT2C3_Order_Type,
	  CASE s.Status_Calc
	     WHEN '0' THEN 'Normal'
	     WHEN '1' THEN 'Partially Allocated'
		 WHEN '2' THEN 'Fully Allocated'
		 WHEN '3' THEN 'In Process'
		 WHEN '5' THEN 'Picked'
		 WHEN '6' THEN 'Marshalled'
		 WHEN '7' THEN 'Loaded'
		 WHEN '8' THEN 'Loaded'
		 WHEN '9' THEN 'Shipped'
		 ELSE 'Unknown'
      END AS IRT2C3_Order_Status,
	  CASE o.ECOM_Platform
         WHEN 'EMG'         THEN 'EMG'
		 WHEN 'EMG_EMER'    THEN 'EMG'
		 WHEN '3RDParty'    THEN '3rd Party'
		 WHEN '3RDPartyQty' THEN '3rd Party'
		 ELSE 'Unknown'
      END AS IRT2C3_Order_Site,
	  o.IntermodalVehicle AS IRT2C3_Trailer,
	  o.Notes AS IRT2C3_Notes,
	  o.MBOLKey AS IRT2C3_MBOL_Key,				
      CASE WHEN ISNULL(o.Priority, 0) = 1 THEN 'Emergency' END AS IRT2C3_Order_Priority
	  FROM dbo.ORDERS o WITH (NOLOCK)
	     INNER JOIN (
		    SELECT
			   OrderKey, 
			   StorerKey, 
			   Facility,
			   MAX(Lottable03) AS Bussines_Unit
			FROM dbo.ORDERDETAIL WITH (NOLOCK)
			GROUP BY OrderKey, StorerKey, Facility
		 ) od1
	        ON od1.OrderKey  = o.OrderKey
			AND od1.StorerKey = o.StorerKey
			AND od1.Facility  = o.Facility
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
      AND o.Facility  = 'EMG03'
	  AND o.OrderGroup <> 'XDOCK'
	  AND o.Status <> '9'
	  AND o.Status <> 'CANC'
	  AND o.Status <> ''
	  AND o.DeliveryDate < DATEADD(day, 1,
	  CASE DATENAME(WEEKDAY, CONVERT(date, GETDATE()))
	     WHEN 'Friday'   THEN DATEADD(day, 3, CONVERT(date, GETDATE()))
		 WHEN 'Saturday' THEN DATEADD(day, 2, CONVERT(date, GETDATE()))
		 WHEN 'Sunday'   THEN DATEADD(day, 1, CONVERT(date, GETDATE()))
		 ELSE                 DATEADD(day, 1, CONVERT(date, GETDATE()))
	  END)
   ORDER BY o.DeliveryDate
END
