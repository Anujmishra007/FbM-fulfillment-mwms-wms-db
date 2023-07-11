SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/    
/* Stored Procedure: isp_RPT_MB_DO_001                                  */    
/* Creation Date: 11-April-2022                                         */    
/* Copyright: LF Logistics                                              */    
/* Written by: WZPang                                                   */    
/*                                                                      */    
/* Purpose: WMS-19850 - Convert to Logi Report - r_dw_delivery_note04   */   
/*                                                                      */    
/* Called By: RPT_MB_DO_001                                             */    
/*                                                                      */    
/* PVCS Version: 1.0                                                    */    
/*                                                                      */    
/* Version: 5.4                                                         */    
/*                                                                      */    
/* Data Modifications:                                                  */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date         Author  Ver   Purposes                                  */   
/* 05-May-2022  WLChooi  1.0  DevOps Combine Script                     */
/************************************************************************/    
CREATE OR ALTER PROC [dbo].[isp_RPT_MB_DO_001] (
      @c_mbolkey           NVARCHAR(10)
    , @c_PreGenRptData     NVARCHAR(10) = ''
)    
 AS    
 BEGIN    
    SET NOCOUNT ON    
    SET QUOTED_IDENTIFIER OFF    
    SET ANSI_NULLS OFF      
    SET CONCAT_NULL_YIELDS_NULL OFF    
  
    DECLARE @c_Storerkey       NVARCHAR(15)                           
          , @c_Type            NVARCHAR(1) = '1'                      
          , @c_DataWindow      NVARCHAR(60) = 'RPT_TRF_PRNTRFTKT_001'  
          , @c_RetVal          NVARCHAR(255)  
          , @c_Externorderkey NVARCHAR(20)   
          , @n_len INT = 0  
  
  
   SELECT @c_Externorderkey = ISNULL(RTRIM(ExternOrderKey),'')
        , @c_Storerkey      = StorerKey
   FROM orders(NOLOCK)  
   WHERE Mbolkey = @c_mbolkey 

   EXEC [dbo].[isp_GetCompanyInfo]  
      @c_Storerkey  = @c_Storerkey  
   ,  @c_Type       = @c_Type  
   ,  @c_DataWindow = @c_DataWindow  
   ,  @c_RetVal     = @c_RetVal           OUTPUT  

   SET @c_Externorderkey = SUBSTRING(@c_Externorderkey,8,10) + SUBSTRING(@c_Externorderkey,6,2)  
                 
   SELECT ORDERS.ExternOrderKey,    
          @c_Externorderkey AS ExternOrderKey2,   
          ORDERS.BillToKey,    
          ORDERS.B_Company,    
          ORDERS.B_Address1,    
          ORDERS.B_Address2,    
          ORDERS.B_Address3,    
          ORDERS.B_Address4,    
          ORDERS.B_Zip,    
          ORDERS.B_Country,    
          ORDERS.ConsigneeKey,      
          ORDERS.C_Company,      
          ORDERS.C_Address1,      
          ORDERS.C_Address2,      
          ORDERS.C_Address3,      
          ORDERS.C_Address4,      
          ORDERS.C_Zip,    
          ORDERS.C_Country,    
          ORDERS.IntermodalVehicle,     
          ORDERS.DeliveryPlace,      
          ORDERS.DischargePlace,    
          CAST(ORDERS.Notes AS NVARCHAR(250)) AS Notes,    
          ORDERS.BuyerPO,      
          ORDERS.OrderKey,     
          ORDERDETAIL.SKU,    
          SKU.DESCR,     
          LOTATTRIBUTE.Lottable02,    
          LOTATTRIBUTE.Lottable04,    
          SUM(PICKDETAIL.Qty) AS QtyPicked,    
          CASE WHEN ISNULL(PACK.PackUOM1, '') <> ''    
               THEN PACK.PackUOM1    
          ELSE PACK.PackUOM3 END AS UOM,    
          CASE WHEN ISNULL(PACK.PackUOM1, '') <> ''    
               THEN PACK.CaseCnt    
          ELSE PACK.Qty END AS PACKQty,    
          Storer.Company,    
          Storer.Address1,    
          Storer.Address2,    
          Storer.Address3,    
          Storer.Address4,    
          Storer.Zip,    
          Storer.Country,    
          ORDERS.Mbolkey,    
          ORDERS.Loadkey,    
          ORDERS.Printflag,    
          Storer.Logo,
          ISNULL(@c_RetVal,'') AS Logo2
   INTO #TMP_DO    
   FROM ORDERS (NOLOCK)
   JOIN ORDERDETAIL (NOLOCK) ON ( ORDERS.OrderKey = ORDERDETAIL.OrderKey )
   JOIN PICKDETAIL (NOLOCK) ON ( ORDERDETAIL.OrderKey = PICKDETAIL.OrderKey ) AND      
                               ( ORDERDETAIL.OrderLineNumber = PICKDETAIL.OrderLineNumber )
   JOIN LOTATTRIBUTE (NOLOCK) ON ( PICKDETAIL.Lot = LOTATTRIBUTE.Lot)
   JOIN SKU (NOLOCK) ON ( SKU.StorerKey = ORDERDETAIL.Storerkey ) AND     
                        ( SKU.Sku = ORDERDETAIL.Sku )
   JOIN PACK (NOLOCK) ON ( SKU.PackKey = PACK.PackKey )
   JOIN STORER (NOLOCK) ON ( ORDERS.StorerKey = STORER.Storerkey )
   WHERE ( ORDERS.[Status] >= '5' ) AND      
         ( ORDERS.Mbolkey = @c_mbolkey )        
   GROUP BY ORDERS.ExternOrderKey,    
            ORDERS.BillToKey,    
            ORDERS.B_Company,    
            ORDERS.B_Address1,    
            ORDERS.B_Address2,    
            ORDERS.B_Address3,    
            ORDERS.B_Address4,    
            ORDERS.B_Zip,    
            ORDERS.B_Country,    
            ORDERS.B_Phone1,    
            ORDERS.ConsigneeKey,      
            ORDERS.C_Company,      
            ORDERS.C_Address1,      
            ORDERS.C_Address2,      
            ORDERS.C_Address3,      
            ORDERS.C_Address4,     
            ORDERS.C_Zip,    
            ORDERS.C_Country,    
            ORDERS.C_Phone1,    
            ORDERS.IntermodalVehicle,      
            ORDERS.DeliveryPlace,    
            ORDERS.DischargePlace,     
            CAST(ORDERS.Notes AS NVARCHAR(250)),    
            ORDERS.BuyerPO,    
            ORDERS.OrderKey,      
            ORDERDETAIL.SKU,    
            SKU.DESCR,    
            LOTATTRIBUTE.Lottable02,    
            LOTATTRIBUTE.Lottable04,    
            CASE WHEN ISNULL(PACK.PackUOM1, '') <> ''    
                 THEN PACK.PackUOM1    
            ELSE PACK.PackUOM3 END,    
            CASE WHEN ISNULL(PACK.PackUOM1, '') <> ''    
                 THEN PACK.CaseCnt    
            ELSE PACK.Qty END,    
            Storer.Company,    
            Storer.Address1,    
            Storer.Address2,    
            Storer.Address3,    
            Storer.Address4,    
            Storer.Zip,    
            Storer.Country,      
            ORDERS.Mbolkey,    
            ORDERS.Loadkey,    
            ORDERS.Printflag,    
            Storer.Logo    
      
      IF ISNULL(@c_PreGenRptData,'') = 'Y'
      BEGIN
         UPDATE ORDERS WITH (ROWLOCK)    
         SET PrintFlag = 'Y',    
             EditDate = GETDATE(),     
             TrafficCop = NULL    
         WHERE Mbolkey = @c_mbolkey     
      END
      ELSE
      BEGIN    
         SELECT * FROM #TMP_DO    
      END
END   
GO
GRANT EXECUTE ON [dbo].[isp_RPT_MB_DO_001] TO [NSQL] 
GO
GRANT EXECUTE ON [dbo].[isp_RPT_MB_DO_001] TO LogiReportRoleWM 
GO