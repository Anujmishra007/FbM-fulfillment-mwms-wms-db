IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[isp_Packing_List_91_rdt]') AND type in (N'P', N'PC'))
   DROP PROCEDURE [dbo].[isp_Packing_List_91_rdt]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Stored Procedure: isp_Packing_List_91_rdt                            */
/* Creation Date: 2020-12-04                                            */
/* Copyright: LFL                                                       */
/* Written by: CSCHONG                                                  */
/*                                                                      */
/* Purpose: WMS-15786 - [CN] Gant_Ecom Packing List_CR                  */
/*                                                                      */
/* Called By: r_dw_Packing_List_91_rdt                                  */
/*                                                                      */
/* GitLab Version: 1.0                                                  */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver   Purposes                                  */
/************************************************************************/

CREATE PROC [dbo].[isp_Packing_List_91_rdt] (
   @c_Pickslipno     NVARCHAR(10)
)
AS
BEGIN
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF 
   
   IF EXISTS (SELECT 1 FROM ORDERS (NOLOCK) WHERE OrderKey = @c_Pickslipno)
   BEGIN
      SELECT @c_Pickslipno = Pickheaderkey
      FROM PICKHEADER (NOLOCK)
      WHERE OrderKey = @c_Pickslipno
   END

   SELECT ORDERS.M_Company
        , ORDERS.C_contact1
        , ORDERS.DeliveryNote
        , ORDERS.C_zip
        , LTRIM(RTRIM(ISNULL(ORDERS.C_State,''))) + LTRIM(RTRIM(ISNULL(ORDERS.C_City,''))) + LTRIM(RTRIM(ISNULL(ORDERS.C_Address1,''))) + 
          LTRIM(RTRIM(ISNULL(ORDERS.C_Address2,''))) + LTRIM(RTRIM(ISNULL(ORDERS.C_Address3,''))) + LTRIM(RTRIM(ISNULL(ORDERS.C_Address4,''))) AS C_Addresses
        , ORDERS.Orderkey
        , ORDERS.ExternOrderkey
        , GETDATE() AS TodayDate
        , ORDERDETAIL.SKU
        , SKU.Descr
        , SKU.Color
        , SKU.size
        , SUM(PICKDETAIL.qty) AS Qty
        , ORDERS.c_phone1
   FROM PICKHEADER (NOLOCK)
   JOIN ORDERS (NOLOCK) ON ORDERS.OrderKey = PICKHEADER.OrderKey
   JOIN ORDERDETAIL (NOLOCK) ON ORDERS.OrderKey = ORDERDETAIL.OrderKey
   JOIN SKU (NOLOCK) ON SKU.StorerKey = ORDERS.StorerKey AND SKU.SKU = ORDERDETAIL.SKU
   JOIN PICKDETAIL (NOLOCK) ON PICKDETAIL.OrderKey = ORDERS.OrderKey AND PICKDETAIL.OrderLineNumber = ORDERDETAIL.OrderLineNumber AND
                               PICKDETAIL.Sku = ORDERDETAIL.Sku
   WHERE PICKHEADER.Pickheaderkey = @c_Pickslipno
   GROUP BY ORDERS.M_Company
          , ORDERS.C_contact1
          , ORDERS.DeliveryNote
          , ORDERS.C_zip
          , LTRIM(RTRIM(ISNULL(ORDERS.C_State,''))) + LTRIM(RTRIM(ISNULL(ORDERS.C_City,''))) + LTRIM(RTRIM(ISNULL(ORDERS.C_Address1,''))) + 
            LTRIM(RTRIM(ISNULL(ORDERS.C_Address2,''))) + LTRIM(RTRIM(ISNULL(ORDERS.C_Address3,''))) + LTRIM(RTRIM(ISNULL(ORDERS.C_Address4,'')))
          , ORDERS.Orderkey
          , ORDERS.ExternOrderkey
          , ORDERS.M_Company
          , ORDERDETAIL.SKU
          , SKU.Descr
          , SKU.Color
          , SKU.size
          , ORDERS.c_phone1

END     
GO
GRANT EXECUTE ON isp_Packing_List_91_rdt TO NSQL
GO    
       
