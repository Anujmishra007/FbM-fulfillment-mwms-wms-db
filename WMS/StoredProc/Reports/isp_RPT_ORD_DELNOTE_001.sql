SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_RPT_ORD_DELNOTE_001                               */
/* Creation Date: 13-JAN-2022                                              */
/* Copyright: LFL                                                          */
/* Written by: PangWeiZhen                                                 */
/*                                                                         */
/* Purpose: WMS-19759                                                      */
/*                                                                         */
/* Called By: RPT_ORD_DELNOTE_001                                          */
/*                                                                         */
/* GitLab Version: 1.2                                                     */
/*                                                                         */
/* Version: 1.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 14-Jan-2022  WZPang  1.0   DevOps Combine Script                        */
/* 17-Nov-2023  WLChooi 1.1   UWP-10938 - Add Orderdetail.UDF01 (WL01)     */
/* 31-Oct-2023  WLChooi 1.2   UWP-10213 - Global Timezone (GTZ01)          */
/***************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_RPT_ORD_DELNOTE_001] @c_Orderkey NVARCHAR(20)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_FromStorerkey NVARCHAR(15)
         , @c_Type          NVARCHAR(1)  = N'1'
         , @c_DataWindow    NVARCHAR(60) = N'RPT_ORD_DELNOTE_001'
         , @c_RetVal        NVARCHAR(255)

   EXEC [dbo].[isp_GetCompanyInfo] @c_Storerkey = @c_FromStorerkey
                                 , @c_Type = @c_Type
                                 , @c_DataWindow = @c_DataWindow
                                 , @c_RetVal = @c_RetVal OUTPUT

   SELECT ORDERS.C_Company
        , ORDERS.C_Address1
        , ORDERS.C_Address2
        , ORDERS.C_Address3
        , ORDERS.C_Address4
        , ORDERS.Notes
        , STORER.Company
        , [dbo].[fnc_ConvSFTimeZone](ORDERS.StorerKey, ORDERS.Facility, ORDERS.AddDate) AS AddDate   --GTZ01
        , ORDERS.ExternOrderKey
        , ORDERS.OrderKey
        , ORDERS.Door
        , ORDERS.Route
        , SKU.DESCR
        , (ORDERDETAIL.QtyPicked + ORDERDETAIL.ShippedQty) AS QtyPicked
        , ORDERDETAIL.Sku
        , ORDERS.DeliveryNote
        , ORDERS.Rdd
        , STORER.Logo
        , ORDERDETAIL.OrderLineNumber
        , ORDERS.BuyerPO
        , ORDERS.StorerKey
        , SKU.RETAILSKU
        , ISNULL(CL.Short, 'N') AS 'ShowField'
        , ISNULL(f.UserDefine02, 'LF Asia') AS 'FCompany'
        , ISNULL(C.Short, 'N') AS 'ShowBuyerPO'
        , ISNULL(ORDERDETAIL.UserDefine03, '') AS 'odudf03'
        , ISNULL(CL1.Short, 'N') AS 'ShowBarcode'
        , ISNULL(CL2.Short, 'N') AS 'ShowDeliveryDate'
        , [dbo].[fnc_ConvSFTimeZone](ORDERS.StorerKey, ORDERS.Facility, ORDERS.DeliveryDate) AS DeliveryDate   --GTZ01
        , ISNULL(CL3.Short, 'N') AS 'ShowSPRemarks'
        , @c_RetVal AS 'LogoName'
        , [dbo].[fnc_ConvSFTimeZone](ORDERS.StorerKey, ORDERS.Facility, GETDATE()) AS CurrentDateTime   --WL01   --GTZ01
        , IIF(ISNULL(CL4.Short,'N') = 'Y', 'HEADER REF: ' + TRIM(ISNULL(ORDERDETAIL.UserDefine01, '')), '') AS SHOWODUDF01   --WL01
   FROM ORDERS WITH (NOLOCK)
   JOIN ORDERDETAIL WITH (NOLOCK) ON (ORDERS.OrderKey = ORDERDETAIL.OrderKey)
   JOIN SKU WITH (NOLOCK) ON (SKU.Sku = ORDERDETAIL.Sku) AND (ORDERDETAIL.StorerKey = SKU.StorerKey)
   JOIN STORER WITH (NOLOCK) ON (SKU.StorerKey = STORER.StorerKey)
   LEFT JOIN CODELKUP AS CL WITH (NOLOCK) ON  CL.LISTNAME = 'REPORTCFG'
                                          AND CL.Long = 'RPT_ORD_DELNOTE_001'   --WL01
                                          AND CL.Code = 'SHOWFIELD'
                                          AND CL.Storerkey = STORER.StorerKey
   LEFT JOIN CODELKUP AS C WITH (NOLOCK) ON  C.LISTNAME = 'REPORTCFG'
                                         AND C.Long = 'RPT_ORD_DELNOTE_001'   --WL01
                                         AND C.Code = 'SHOWBUYERPO'
                                         AND C.Storerkey = STORER.StorerKey
   LEFT JOIN CODELKUP AS CL1 WITH (NOLOCK) ON  CL1.LISTNAME = 'REPORTCFG'
                                           AND CL1.Long = 'RPT_ORD_DELNOTE_001'   --WL01
                                           AND CL1.Code = 'ShowBarcode'
                                           AND CL1.Storerkey = STORER.StorerKey
   LEFT JOIN CODELKUP AS CL2 WITH (NOLOCK) ON  CL2.LISTNAME = 'REPORTCFG'
                                           AND CL2.Long = 'RPT_ORD_DELNOTE_001'   --WL01
                                           AND CL2.Code = 'ShowDeliveryDate'
                                           AND CL2.Storerkey = STORER.StorerKey
   LEFT JOIN CODELKUP AS CL3 WITH (NOLOCK) ON  CL3.LISTNAME = 'REPORTCFG'
                                           AND CL3.Long = 'RPT_ORD_DELNOTE_001'   --WL01
                                           AND CL3.Code = 'SHOWSPREMARKS'
                                           AND CL3.Storerkey = STORER.StorerKey
   LEFT JOIN CODELKUP AS CL4 WITH (NOLOCK) ON  CL4.LISTNAME = 'REPORTCFG'   --WL01 S
                                           AND CL4.Long = 'RPT_ORD_DELNOTE_001'
                                           AND CL4.Code = 'SHOWODUDF01'
                                           AND CL4.Storerkey = STORER.StorerKey   --WL01 E
   LEFT JOIN FACILITY AS f WITH (NOLOCK) ON f.Facility = STORER.Facility
   WHERE ((ORDERS.OrderKey = @c_Orderkey))
   ORDER BY CASE WHEN ISNULL(C.Short, 'N') = 'Y' THEN ORDERDETAIL.UserDefine03 END DESC
          , CASE WHEN ISNULL(C.Short, 'N') = 'Y' THEN ORDERDETAIL.OrderLineNumber END
          , CASE WHEN ISNULL(C.Short, 'N') = 'Y' THEN ORDERDETAIL.Sku END ASC
          , CASE WHEN ISNULL(C.Short, 'N') = 'N' THEN ORDERDETAIL.OrderLineNumber END ASC
          , CASE WHEN ISNULL(C.Short, 'N') = 'N' THEN ORDERDETAIL.Sku END ASC
END