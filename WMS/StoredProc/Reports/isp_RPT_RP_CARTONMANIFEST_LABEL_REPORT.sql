SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_RPT_RP_CARTONMANIFEST_LABEL_REPORT                */
/* Creation Date: 14-SEP-2023                                              */
/* Copyright: MAERSK                                                       */
/* Written by: CSCHONG                                                     */
/*                                                                         */
/* Purpose: WMS-23694 Convert to Logi Report- r_cartonmanifest_label_report*/
/*                                                                         */
/* Called By: RPT_RP_CARTONMANIFEST_LABEL_REPORT                           */
/*                                                                         */
/* GitHub Version: 1.1                                                     */
/*                                                                         */
/* Version: 1.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver.   Purposes                                    */
/* 14-SEP-2023  CSCHONG 1.0    Devops Scripts Combine                      */
/* 15-Mar-2024  WLChooi 1.1    UWP-16863 Rewrite SP (WL01)                 */
/***************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_RPT_RP_CARTONMANIFEST_LABEL_REPORT] @c_Mbolkey NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   --WL01
   ;WITH CTE AS
   (
      SELECT ORDERS.StorerKey
           , STORER.Company
           , ORDERS.C_Address1
           , ORDERS.C_Address2
           , PackHeader.[Route]
           , PackHeader.OrderKey
           , ORDERS.ExternOrderKey
           , PackHeader.LoadKey
           , PackHeader.PickSlipNo
           , PackDetail.CartonNo
           , ORDERS.OrderDate
           , ORDERS.DeliveryDate
           , TRANSPORTER = ISNULL(LoadPlan.CarrierKey, '')
           , SKU.SUSR4 GPC
           , PackDetail.SKU
           , SKU.DESCR
           , SIZE = SUBSTRING(PackDetail.SKU, 16, 5)
           , UOM = PACK.PackUOM3
           , PackDetail.Qty
           , Group1 = PackHeader.OrderKey
           , Group2 = CAST(PackDetail.CartonNo AS NVARCHAR(10)) + PackHeader.PickSlipNo
           , CurrentDateTime = [dbo].[fnc_ConvSFTimeZone](ORDERS.StorerKey, ORDERS.Facility, GETDATE())
           , SumQty = CAST(PDET.SumQty AS NVARCHAR) + '   UOM'
           , CountSKU = CAST(PDET.CountSKU AS NVARCHAR) + '   Line(s)'
           , CountDistinctSKU = CAST(PDET.CountDistinctSKU AS NVARCHAR) + '   Products(s)'
           , RecNo = (ROW_NUMBER() OVER (PARTITION BY ORDERS.OrderKey
                                                    , PackDetail.CartonNo
                                         ORDER BY ORDERS.OrderKey
                                                , PackDetail.CartonNo ASC))
           , CountDistinctCtnNo = PDET.CountDistinctCtnNo
      FROM PackDetail (NOLOCK)
      JOIN PackHeader WITH (NOLOCK) ON (PackDetail.PickSlipNo = PackHeader.PickSlipNo)
      JOIN ORDERS WITH (NOLOCK) ON (PackHeader.OrderKey = ORDERS.OrderKey)
      JOIN STORER WITH (NOLOCK) ON (ORDERS.StorerKey = STORER.StorerKey)
      JOIN SKU WITH (NOLOCK) ON (PackDetail.StorerKey = SKU.StorerKey AND PackDetail.SKU = SKU.Sku)
      JOIN PACK WITH (NOLOCK) ON (SKU.PACKKey = PACK.PackKey)
      JOIN LoadPlan WITH (NOLOCK) ON (PackHeader.LoadKey = LoadPlan.LoadKey)
      JOIN MBOLDETAIL WITH (NOLOCK) ON (MBOLDETAIL.OrderKey = ORDERS.OrderKey)
      CROSS APPLY (  SELECT SUM(PD.Qty) AS SumQty
                          , COUNT(PD.SKU) AS CountSKU
                          , COUNT(DISTINCT PD.SKU) AS CountDistinctSKU
                          , COUNT(DISTINCT PD.CartonNo) AS CountDistinctCtnNo
                     FROM PackHeader PH (NOLOCK)
                     JOIN PackDetail PD (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
                     WHERE PH.OrderKey = PackHeader.OrderKey) AS PDET
      WHERE MBOLDETAIL.MbolKey = @c_Mbolkey
   )
   SELECT StorerKey
        , Company
        , C_Address1
        , C_Address2
        , [Route]
        , OrderKey
        , ExternOrderKey
        , LoadKey
        , PickSlipNo
        , CartonNo
        , OrderDate
        , DeliveryDate
        , TRANSPORTER
        , GPC
        , SKU
        , DESCR
        , SIZE
        , UOM
        , Qty
        , Group1
        , Group2
        , CurrentDateTime
        , SumQty
        , CountSKU
        , CountDistinctSKU
        , RecNo
        , CartonCount = CAST((SELECT MAX(RecNo) FROM CTE C WHERE C.OrderKey = CTE.OrderKey AND C.CartonNo = CTE.CartonNo) AS NVARCHAR)
                        + '  /  '
                        + CAST(CountDistinctCtnNo AS NVARCHAR)
   FROM CTE
   ORDER BY CTE.OrderKey, CTE.CartonNo
END
GO
GRANT EXECUTE ON [dbo].[isp_RPT_RP_CARTONMANIFEST_LABEL_REPORT] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_RP_CARTONMANIFEST_LABEL_REPORT] TO [LogiReportRoleWM]
GO