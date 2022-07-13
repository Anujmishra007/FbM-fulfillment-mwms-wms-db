SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Stored Procedure: isp_Packing_List_125_rdt                           */
/* Creation Date: 2022-06-16                                            */
/* Copyright: LFL                                                       */
/* Written by: Mingle                                                   */
/*                                                                      */
/* Purpose: WMS-19893 CN-MHD PACKING LIST                               */
/*                                                                      */
/* Called By: r_dw_Packing_List_125_rdt                                 */
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

CREATE OR ALTER PROC [dbo].[isp_Packing_List_125_rdt] (
   @c_Pickslipno     NVARCHAR(10)
)
AS
BEGIN
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF 

   IF LEFT(@c_Pickslipno,1) = 'P' -- Print from ECOM Packing    
   BEGIN    
      SELECT @c_Pickslipno = Orderkey    
      FROM PICKHEADER WITH (NOLOCK)    
      WHERE PickHeaderKey = @c_Pickslipno    
   END    
   
   --IF EXISTS (SELECT 1 FROM ORDERS (NOLOCK) WHERE OrderKey = @c_Pickslipno)
   --BEGIN
   --	SELECT @c_Pickslipno = Pickheaderkey
   --	FROM PICKHEADER (NOLOCK)
   --	WHERE OrderKey = @c_Pickslipno
   --END

   SELECT ORDERS.C_contact1
        , LTRIM(RTRIM(ISNULL(ORDERS.C_Address2,'')))
        , ORDERS.C_Phone1
        , ORDERS.M_Company
        , PACKDETAIL.LabelNo
        , ORDERS.Adddate
        , SKU.Descr
        , SUM(PACKDETAIL.Qty) AS Qty
        , PACKDETAIL.PickSlipNo
   FROM ORDERS (NOLOCK)
   JOIN PACKHEADER(NOLOCK) ON PackHeader.OrderKey = ORDERS.OrderKey
   JOIN PACKDETAIL (NOLOCK) ON PackDetail.PickSlipNo = PackHeader.PickSlipNo
   JOIN SKU (NOLOCK) ON PACKDETAIL.StorerKey = SKU.StorerKey AND PACKDETAIL.Sku = SKU.Sku
   WHERE ORDERS.ORDERKEY = @c_Pickslipno
   GROUP BY ORDERS.C_contact1
        , LTRIM(RTRIM(ISNULL(ORDERS.C_Address2,'')))
        , ORDERS.C_Phone1
        , ORDERS.M_Company
        , PACKDETAIL.LabelNo
        , ORDERS.Adddate
        , PACKDETAIL.PickSlipNo
        , SKU.Descr

END     
GO
GRANT EXECUTE ON isp_Packing_List_125_rdt TO NSQL
GO    




