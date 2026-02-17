SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Stored Procedure: isp_RPT_HUDA_DGD_Report_001                        */  
/* CreatiON Date: 15-Nov-2024                                           */  
/* Copyright: Maersk                                                    */  
/* Written by: CLO091                                                   */  
/*                                                                      */  
/* Purpose: HUDA Logi report                                            */  
/*                                                                      */  
/* Called By: RPT_HUDA_DGD_Report                                       */  
/*                                                                      */  
/* VersiON: 1.0                                                         */  
/*                                                                      */  
/* Data ModificatiONs:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author   Ver  Purposes                                  */  
/* 15-Nov-2024  CLO091   1.0  DevOps Combine Script                     */  
/************************************************************************/  
CREATE OR ALTER PROC [dbo].[isp_RPT_HUDA_DGD_Report_001]  
(  
   @C_OrderKey  NVARCHAR(10)  
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

SELECT   FA.Descr AS ShipperName  
  , ShipperAdd1 = CONCAT(FA.Address1,' ', FA.Address2,' ', FA.Address3, ' ', FA.Address4)  
  , ShipperAdd2 = CONCAT(FA.City, '-', FA.Country)  
  , ShipperTel = CONCAT('TEL:', FA.Phone1,'', FA.Phone2)  
  , OS.C_Contact1 AS Consignee  
  , ConsigneeAdd1 = CONCAT(OS.C_Address1,' ', OS.C_Address2,' ', OS.C_Address3,' ', OS.C_Address4)  
  , ConsigneeAdd2 = CONCAT(OS.C_City,' ', OS.C_State)  
  , OS.C_Zip  
  , OS.C_Country  
  , ConsigneePH = CONCAT('Ph:', OS.C_Phone1)  
  , OS.TrackingNo AS AirWaybill  
  , 'DUBAI' AS DepartureAirport  
  , OS.C_City AS DestinationAirport  
  , 'ID8000' AS IDNo  
  , 'CONSUMER COMMODITY' AS ProperShippingName  
  , '9' AS Class  
  --, CONCAT(CTN.CTNo, ' ', 'FIBREBOARD BOX X 1.00 Kg G') AS CartonInfo   ,CONCAT(CTN.CTNo, ' ', 'FIBREBOARD BOX X ', CAST(ISNULL(SKU.TotalWeight+0.6, 0) AS VARCHAR), ' Kg G') AS CartonInfo   
  , 'Y963' AS PackingInst  
  , CL.Notes AS HandlingInfo  
  , CL.Long AS Name   
  , CL.UDF01 AS Place  
  , CONVERT(NVARCHAR(10), [dbo].[fnc_ConvSFTimeZone](OS.StorerKey, OS.Facility, GETDATE()), 101) AS CurrentDate  
  , CL.UDF02 AS Signature  
FROM ORDERS OS (NOLOCK)   
LEFT JOIN FACILITY FA (NOLOCK) ON FA.Facility = OS.Facility   
LEFT JOIN (SELECT COUNT(*) AS CTNo, CartonType, Weight, OrderKey FROM PackInfo (NOLOCK) PI  
   JOIN PackHeader PH (NOLOCK) ON PH.PickSlipNo = PI.PickSlipNo   
   WHERE PH.storerkey in ('HBDS','KYDS', 'KYDSDTC') GROUP BY OrderKey, CartonType, Weight) CTN   
  ON CTN.OrderKey = OS.OrderKey  
LEFT JOIN (SELECT * FROM CODELKUP (NOLOCK) WHERE storerkey in ('HBDS','KYDS', 'KYDSDTC') AND code = 'DGD' AND LISTNAME = 'LBLCONFIG') CL  
  ON CL.storerkey = OS.StorerKey  
LEFT JOIN (SELECT OD.OrderKey, CEILING(SUM(OD.OriginalQty * SKU.weight/100))/10 AS TotalWeight    FROM OrderDetail OD (NOLOCK)    JOIN SKU (NOLOCK) ON OD.SKU = SKU.SKU AND SKU.storerkey = OD.storerkey    GROUP BY OD.OrderKey) SKU ON SKU.OrderKey = OS.Orde
rKey  
WHERE OS.OrderKey = @C_OrderKey  
END