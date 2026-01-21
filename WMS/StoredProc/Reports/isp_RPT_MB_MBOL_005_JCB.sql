SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/          
/* Stored Procedure: isp_RPT_MB_MBOL_005_JCB                            */          
/* CreatiON Date: 13-JUN-2023                                           */      
/* Copyright: Maersk                                                    */      
/* Written by: WSE016                                                   */      
/*                                                                      */      
/* Purpose: WMS-22767 (DU)                                              */        
/*                                                                      */          
/* Called By: RPT_MB_MBOL_005                                           */          
/*                                                                      */          
/* PVCS VersiON: 1.0                                                    */          
/*                                                                      */          
/* VersiON: 1.0                                                         */          
/*                                                                      */          
/* Data ModificatiONs:                                                  */          
/*                                                                      */          
/* Updates:                                                             */          
/* Date         Author   Ver  Purposes                                  */  
/* 03/10/2024   WSE016   1.0  New SP based on  isp_RPT_MB_MBOL_005      */  
/*                            STT.RefNo changed to STT.Door             */    
/* 11/11/2024   VMA237   1.1  Add SKU + Qty (WCEET-2547)                */  
/* 04/12/2024   TPT001   1.2  Changing link from OrderDEtail Pickdetail */  
/*                                                                      */     
/************************************************************************/          
CREATE OR ALTER PROC [dbo].[isp_RPT_MB_MBOL_005_JCB] (  
      @c_Mbolkey NVARCHAR(10)      
)          
 AS          
 BEGIN          
              
   SET NOCOUNT ON          
   SET ANSI_NULLS ON          
   SET QUOTED_IDENTIFIER OFF          
   SET CONCAT_NULL_YIELDS_NULL OFF          
   SET ANSI_WARNINGS ON          
  
    SELECT  MBOL.MbolKey  
  --, MBOL.ExternMbolKey  
         , MBOL.OtherReference  
         , MBOL.Vessel  
         , MBOL.PlaceOfLoadingQualifier  
         , MBOL.PlaceOfDischarge  
         , [dbo].[fnc_ConvSFTimeZone](ORDERS.StorerKey, ORDERS.Facility, MBOL.ArrivalDateFinalDestination) AS ArrivalDateFinalDestination  
         , MBOL.CarrierKey  
         , MBOL.VoyageNumber  
         , MBOL.ContainerNo  
         , MBOL.Equipment  
         , MBOL.PlaceOfLoading  
         , ORDERS.ExternOrderKey  
   , ORDERS.IntermodalVehicle  
         , ORDERDETAIL.Lottable03  
         , ORDERS.UserDefine09  
         , PICKDETAIL.PickSlipNo  
         -- 07.01.2025 change by Vera start 1/2  
   --, PICKDETAIL.ID  
   , CASE WHEN PICKDETAIL.UOM='1' THEN CASE WHEN ISNULL(PICKDETAIL.ID,'') <> '' THEN PICKDETAIL.ID ELSE PICKDETAIL.DropID END ELSE PICKDETAIL.DropID END AS ID  
   -- 07.01.2025 change by Vera end 1/2  
   -- 11.11.2024 changed by VMA237 for WCEET-2547 start 1/2  
   , PICKDETAIL.Sku  
   , PICKDETAIL.Qty as Qty  
   -- 11.11.2024 changed by VMA237 for WCEET-2547 end 1/2  
         , STORER.Company  
         , CASE WHEN ISNULL(STT.Door,'') = '' THEN 'N' ELSE 'Y' END AS Scanned   
   , CASE WHEN ISNULL(STT.Door,'') != '' THEN STT.EditDate END as [Time Stamp]  
   --, (SELECT O.MBOLKey, PD.ID, STT.RefNo, CASE WHEN ISNULL(STT.RefNo,'') = '' THEN 'N' ELSE 'Y' END  
         --   FROM dbo.ORDERS O WITH (NOLOCK)  
         --   INNER JOIN dbo.PICKDETAIL PD WITH (NOLOCK) ON O.OrderKey = PD.OrderKey  
         --   LEFT OUTER JOIN RDT.RDTSCANTOTRUCK STT (NOLOCK) ON STT.MBOLKey = O.MBOLKey AND STT.RefNo = PD.ID  
         --   WHERE O.MBOLKey = @c_MBOLKey) AS Scanned        
         , [dbo].[fnc_ConvSFTimeZone](ORDERS.StorerKey, ORDERS.Facility, GETDATE()) AS CurrentDateTime  
   FROM MBOL (NOLOCK)  
   JOIN MBOLDETAIL (NOLOCK) ON MBOL.MbolKey = MBOLDETAIL.MbolKey  
   JOIN ORDERS (NOLOCK) ON MBOLDETAIL.OrderKey = ORDERS.OrderKey  
   JOIN ORDERDETAIL (NOLOCK) ON ORDERS.OrderKey = ORDERDETAIL.OrderKey           
   JOIN PICKDETAIL (NOLOCK) ON ORDERDETAIL.OrderKey = PICKDETAIL.OrderKey AND ORDERDETAIL.OrderLineNumber=PICKDETAIL.OrderLineNumber  
   JOIN STORER (NOLOCK) ON ORDERS.StorerKey = STORER.StorerKey  
   --LEFT OUTER JOIN RDT.RDTSCANTOTRUCK STT (NOLOCK) ON STT.MBOLKey = ORDERS.MBOLKey AND STT.RefNo = PICKDETAIL.ID  
   -- 24.01.2025 change by Vera start 1/1  
   --   LEFT OUTER JOIN RDT.RDTSCANTOTRUCK STT (NOLOCK) ON STT.MBOLKey = ORDERS.MBOLKey AND STT.URNNo = PICKDETAIL.ID  
   LEFT OUTER JOIN RDT.RDTSCANTOTRUCK STT (NOLOCK) ON STT.MBOLKey = ORDERS.MBOLKey AND STT.URNNo = (CASE WHEN PICKDETAIL.UOM='1' THEN CASE WHEN ISNULL(PICKDETAIL.ID,'') <> '' THEN PICKDETAIL.ID ELSE PICKDETAIL.DropID END ELSE PICKDETAIL.DropID END)  
   -- 24.01.2025 change by Vera end 1/1  
   WHERE MBOL.MbolKey = @c_Mbolkey   
   GROUP BY MBOL.MbolKey   
    --, MBOL.ExternMbolKey  
         , MBOL.OtherReference  
         , MBOL.Vessel  
         , MBOL.PlaceOfLoadingQualifier  
         , MBOL.PlaceOfDischarge  
         , ArrivalDateFinalDestination  
         , MBOL.CarrierKey  
         , MBOL.VoyageNumber  
         , MBOL.ContainerNo  
         , MBOL.Equipment  
         , MBOL.PlaceOfLoading  
         , ORDERS.StorerKey  
         , ORDERS.Facility  
         , ORDERS.ExternOrderKey  
   , ORDERS.IntermodalVehicle  
         , ORDERDETAIL.Lottable03  
         , ORDERS.UserDefine09  
         , PICKDETAIL.PickSlipNo  
         , PICKDETAIL.ID  
   -- 07.01.2025 change by Vera start 2/2  
   , PICKDETAIL.DropID  
   -- 07.01.2025 change by Vera end 2/2  
   -- 11.11.2024 changed by VMA237 for WCEET-2547 start 2/2  
   , PICKDETAIL.Sku
   , PICKDETAIL.Qty
   -- 11.11.2024 changed by VMA237 for WCEET-2547 end 2/2  
         , STORER.Company  
         , STT.Door  
   , PICKDETAIL.UOM  
   , STT.EditDate  
     
  
END -- procedure
