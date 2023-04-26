SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO   
/************************************************************************/    
/* Store Procedure:  isp_RPT_RP_LP_PLIST_001                            */    
/* Creation Date: 2023-03-01                                            */    
/* Copyright: IDS                                                       */    
/* Written by: CSCHONG                                                  */    
/*                                                                      */    
/* Purpose:WMS-21847 SG – MNC – Non MTO Picking Slip                    */  
/*                                                                      */    
/* Input Parameters:  @c_loadKey  - loadkey                             */    
/*                    @c_orderkey - orderkey                            */   
/*                                                                      */    
/* Output Parameters:  None                                             */    
/*                                                                      */    
/* Return Status:  None                                                 */    
/*                                                                      */    
/* Usage: RPT_RP_LP_PLIST_001                                           */    
/*                                                                      */    
/* Local Variables:                                                     */    
/*                                                                      */    
/* Called By:                                                           */    
/*                                                                      */    
/* PVCS Version: 1.3                                                    */    
/*                                                                      */    
/* Version: 1.0                                                         */    
/*                                                                      */    
/* Data Modifications:                                                  */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date         Author     Purposes                                     */    
/* 2023-03-01   CHONGCS   Devops Scripts Combine                        */                      
/************************************************************************/    
CREATE   PROC dbo.isp_RPT_RP_LP_PLIST_001 ( @c_loadKey         NVARCHAR(10) = '',  
                                            @c_orderkey        NVARCHAR(10) = ''  
  
)    
 AS    
BEGIN    
    SET NOCOUNT ON    
    SET QUOTED_IDENTIFIER OFF    
    SET CONCAT_NULL_YIELDS_NULL OFF    
    
    DECLARE @n_continue       INT    
         ,  @c_errmsg         NVARCHAR(255)    
         ,  @b_success        INT    
         ,  @n_err            INT    
         ,  @n_StartTCnt      INT    
    
         ,  @c_SQL            NVARCHAR(MAX)    
         ,  @c_Storerkey      NVARCHAR(15)    
       
    
   SET @n_StartTCnt = @@TRANCOUNT    
  
DECLARE    @c_Type        NVARCHAR(1) = '1'                            
         , @c_DataWindow  NVARCHAR(60) = 'RPT_RP_LP_PLIST_001'        
         , @c_RetVal      NVARCHAR(255)       
  
  
SET @c_RetVal = ''     
  
  
               SELECT TOP 1 @c_Storerkey = O.StorerKey  
               FROM ORDERS O WITH (NOLOCK)  
               WHERE (O.LoadKey = @c_LoadKey or O.OrderKey = @c_OrderKey)  
    
IF ISNULL(@c_Storerkey,'') <> ''        
BEGIN        
        
EXEC [dbo].[isp_GetCompanyInfo]        
         @c_Storerkey  = @c_Storerkey        
      ,  @c_Type       = @c_Type        
      ,  @c_DataWindow = @c_DataWindow        
      ,  @c_RetVal     = @c_RetVal           OUTPUT        
         
END    
     
         SELECT   O.LoadKey,  
                  O.Orderkey,  
                  OrderKey_Barcode =  O.Orderkey ,   
                  O.ExternOrderKey,   
                  O.InvoiceNo,  
                  CONVERT(NVARCHAR(10),O.deliverydate,103) DeliveryDate,  
                  ISNULL(O.BillToKey, '') AS ConsigneeKey,    
                  ISNULL(O.c_Company, '') AS Company,    
                  ISNULL(O.c_Address1, '') AS Addr1,    
                  ISNULL(O.c_Address2, '') AS Addr2,    
                  ISNULL(O.c_Address3, '') AS Addr3,    
                  ISNULL(O.c_Zip, '') AS PostCode,    
                  ISNULL(UPPER(O.Route), '') AS Route,    
                  ISNULL(RM.Descr, '') Route_Desc,    
                  O.Door AS TrfRoom,    
                  CONVERT(NVARCHAR(200), ISNULL(O.Notes, '')) Notes1,    
                  CONVERT(NVARCHAR(200), ISNULL(O.Notes2, '')) Notes2,    
                 '' CarrierKey,    
                  '' AS VehicleNo,  
                  OD.SKU,    
                  ISNULL(S.Descr, '') SkuDesc,    
                  S.SUSR3,  
                  SUM(OD.ORIGINALQTY) AS OrderQty,    
                  OD.UOM,  
                  OD.PACKKEY,  
                  Location = IsNull(INV.Loc, ''),  
                   FamilyGroup = S.BUSR10,  
                  Box = S.BUSR5,  
                  Powers = RTRIM(S.Style),  
                  CYC = S.Size,  
                  Axis = S.Measurement,  
                  Type =  O.Type,  
                  CONVERT(NVARCHAR(10),O.adddate,103) AS OHAddDate,  
                  S.RETAILSKU, ISNULL(O.OrderGroup,'') AS ORDGRP,  
                  ISNULL(@c_Retval,'')    AS Logo,  
                  S.SKUGROUP AS skugroup,  
                  CASE WHEN  S.SKUGROUP <>'Rx' THEN  S.RETAILSKU ELSE '' END AS skugrpbarcode   
            FROM dbo.ORDERS O WITH (NOLOCK)  INNER JOIN dbo.V_ORDERDETAIL OD WITH (NOLOCK) ON (OD.STORERKEY = O.StorerKey and OD.Orderkey = O.Orderkey)    
            INNER JOIN dbo.Sku S WITH (NOLOCK) ON (S.StorerKey = OD.StorerKey AND S.Sku = OD.Sku)    
            INNER JOIN dbo.Pack P WITH (NOLOCK) ON (P.PackKey = S.PackKey)   
            LEFT OUTER JOIN dbo.RouteMaster RM WITH (NOLOCK) ON (RM.Route = O.Route)    
  
            LEFT OUTER JOIN  
  
            (Select LLID.StorerKey, LLID.SKU, MIN(LLID.Loc) Loc  
            From [BI].[V_Inv_LotByLocByID] LLID with (nolock) Inner Join dbo.LOC L with (nolock) ON L.Loc = LLID.Loc  
            Where LLID.storerkey = @c_Storerkey  
            and L.hostwhcode = 'FWDPICK'  
            Group By LLID.StorerKey, LLID.SKU) INV ON INV.StorerKey = O.StorerKey and INV.SKU = OD.SKU  
            --WHERE (O.LoadKey LIKE '%' + @c_LoadKey or O.OrderKey LIKE '%' + @c_OrderKey)  
            WHERE (O.LoadKey = @c_LoadKey or O.OrderKey = @c_OrderKey)  
            GROUP BY O.LoadKey,   
                  O.OrderKey,  
                   O.ExternOrderKey,   
                  O.InvoiceNo,  
                   CONVERT(NVARCHAR(10),O.deliverydate,103),  
                  ISNULL(O.BillToKey, ''),    
                  ISNULL(O.c_Company, ''),    
                  ISNULL(O.c_Address1, ''),    
                  ISNULL(O.c_Address2, ''),    
                  ISNULL(O.c_Address3, ''),    
                  ISNULL(O.c_Zip, ''),    
                  ISNULL(UPPER(O.Route), '') ,    
                  ISNULL(RM.Descr, ''),    
                  O.Door,    
                  CONVERT(NVARCHAR(200), ISNULL(O.Notes, '')),    
                  CONVERT(NVARCHAR(200), ISNULL(O.Notes2, '')),    
                  OD.SKU,    
                  ISNULL(S.Descr, ''),    
                  S.SUSR3,  
                  OD.UOM,  
                  OD.PACKKEY,  
                  ISNULL(INV.Loc, ''),  
                  S.BUSR10,     
                  S.BUSR5,  
                  S.Style,  
                  S.Size,  
                  S.Measurement,  
                  O.Type,  
                  CONVERT(NVARCHAR(10),O.adddate,103),  
                  S.RETAILSKU , ISNULL(O.OrderGroup,''),  
                  S.SKUGROUP   
             ORDER BY O.LoadKey,   
                      O.OrderKey,  
                      IsNull(INV.Loc, ''),  
                      S.BUSR10,S.Size,S.Measurement,  
         CASE WHEN ISNULL(S.Style,'') <> '' AND ISNUMERIC(S.Style) = 1 THEN CAST(RTRIM(S.Style) AS DECIMAL(10,2)) ELSE 0.00 END desc,  
                      s.SKUGROUP DESC  
 QUIT_SP:    
    
   WHILE @@TRANCOUNT < @n_StartTCnt    
      BEGIN TRAN    
    
   /* #INCLUDE <SPTPA01_2.SQL> */    
   IF @n_continue=3  -- Error Occured - Process And Return    
   BEGIN    
      SELECT @b_success = 0    
      IF @@TRANCOUNT > @n_StartTCnt    
      BEGIN    
         ROLLBACK TRAN    
      END    
      ELSE    
      BEGIN    
         WHILE @@TRANCOUNT > @n_StartTCnt    
         BEGIN    
            COMMIT TRAN    
         END    
      END    
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'isp_RPT_RP_LP_PLIST_001'    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012    
      RETURN    
   END    
   ELSE    
   BEGIN    
      SELECT @b_success = 1    
      WHILE @@TRANCOUNT > @n_StartTCnt    
      BEGIN    
         COMMIT TRAN    
      END    
   END    
    
END    
GO
GRANT EXECUTE ON [isp_RPT_RP_LP_PLIST_001]  TO NSQL
GO  
GRANT EXECUTE ON [isp_RPT_RP_LP_PLIST_001] TO LogiReportRoleWM 
GO   