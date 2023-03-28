SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store Procedure:  isp_CartonManifestLabel40_RDT                      */
/* Creation Date: 28-FEB-2023                                           */
/* Copyright: IDS                                                       */
/* Written by: CSCHONG                                                  */
/*                                                                      */
/* Purpose:  WMS-21802: ID-PUMA-B2B Carton Manifest                     */
/*                                                                      */
/* Input Parameters: @c_Orderkey, @c_dropid                             */
/*                                                                      */
/* Called By:  dw = r_dw_carton_manifest_label_40_Rdt                   */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 2023-02-28   CSCHONG       Devops Scripts Combine     				   */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_CartonManifestLabel40_RDT] (
      @c_Orderkey      NVARCHAR(10)
   ,  @c_Dropid        NVARCHAR(20)  = ''
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_IsRDT     INT
         , @n_StartTCnt INT
			, @n_weight   decimal(7,2)

   SET @n_IsRDT     = 0
   SET @n_StartTCnt = @@TRANCOUNT

   WHILE @@TRANCOUNT > 0
   BEGIN
      COMMIT TRAN
   END



 SELECT     Orderkey = ORDERS.Orderkey
         ,  ConsigneeKey = RTRIM(SUBSTRING(ORDERS.consigneekey,4,45))
         ,  C_Company  = ISNULL(RTRIM(ORDERS.C_Company),'')
         ,  C_Address1 = ISNULL(RTRIM(ORDERS.C_ADDRESS1),'')
         ,  C_Address2 = ISNULL(RTRIM(ORDERS.C_ADDRESS2),'')
         ,  C_Address3 = ISNULL(RTRIM(ORDERS.C_Address3),'')
         ,  C_Address4 = ISNULL(RTRIM(ORDERS.C_Address4),'')
         ,  C_City     = ISNULL(RTRIM(ORDERS.C_City),'')
         ,  C_Zip      = ISNULL(RTRIM(ORDERS.C_Zip),'')
         ,  OHUDF05      = ISNULL(RTRIM(ORDERS.userdefine05),'')
         ,  OHUDF09    = ISNULL(RTRIM(ORDERS.userdefine09),'')
         ,  ExternOrderkey = ISNULL(RTRIM(ORDERS.ExternOrderkey),'')
         ,  PickSlipNo = PACKHEADER.PickSlipNo
         ,  CartonNo = PACKDETAIL.CartonNo
         ,  SKU = PACKDETAIL.SKU
         ,  SSize = Sku.size
         ,  QTY = PACKDETAIL.QTY
         ,  DropID = ISNULL(RTRIM(PACKDETAIL.DropID),'')
         --,  TotalOrderQty = (SELECT SUM(PD.Qty)   FROM PACKDETAIL PD WITH (NOLOCK) WHERE PD.PickSlipNo = PACKHEADER.PickSlipNo)
         ,  TotalCarton   = (SELECT MAX(CartonNo) FROM PACKDETAIL PD WITH (NOLOCK) WHERE PD.PickSlipNo = PACKHEADER.PickSlipNo)
         ,  DESCR = SKU.DESCR			
			,  SKU.STYLE	
         ,  DetailBarcode = ISNULL(RTRIM(ORDERS.ExternOrderkey),'') + PACKDETAIL.SKU + RIGHT('000' + CAST(PACKDETAIL.QTY AS NVARCHAR(3)),3)
   FROM  PACKDETAIL  WITH (NOLOCK)
   JOIN  PACKHEADER  WITH (NOLOCK)  ON (PACKDETAIL.PickSlipNo = PACKHEADER.PickSlipNo)
   JOIN  ORDERS      WITH (NOLOCK)  ON (PACKHEADER.Orderkey = ORDERS.Orderkey)
   JOIN  SKU         WITH (NOLOCK)  ON (PACKDETAIL.Storerkey = SKU.Storerkey)
                                   AND (PACKDETAIL.Sku = SKU.Sku)
   JOIN  PACK        WITH (NOLOCK)  ON (SKU.Packkey = PACK.Packkey)
   WHERE PACKHEADER.Orderkey = @c_orderkey
   AND   PACKDETAIL.DropID   = CASE WHEN @c_dropid = '' THEN PACKDETAIL.DropID ELSE @c_dropid END
   AND   PACKHEADER.Status = '9'
   GROUP BY ORDERS.Orderkey
         ,  RTRIM(SUBSTRING(ORDERS.consigneekey,4,45))
         ,  ISNULL(RTRIM(ORDERS.C_Company),'')
         ,  ISNULL(RTRIM(ORDERS.C_ADDRESS1),'')
         ,  ISNULL(RTRIM(ORDERS.C_ADDRESS2),'')
         ,  ISNULL(RTRIM(ORDERS.C_Address3),'')
         ,  ISNULL(RTRIM(ORDERS.C_Address4),'')
         ,  ISNULL(RTRIM(ORDERS.C_City),'')
         ,  ISNULL(RTRIM(ORDERS.C_Zip),'')
         ,  ISNULL(RTRIM(ORDERS.userdefine05),'')
         ,  ISNULL(RTRIM(ORDERS.userdefine09),'')
         ,  ISNULL(RTRIM(ORDERS.ExternOrderkey),'')
         ,  PACKHEADER.PickSlipNo
         ,  PACKDETAIL.CartonNo
         ,  PACKDETAIL.SKU
         ,  Sku.size
         ,  PACKDETAIL.QTY
         ,  ISNULL(RTRIM(PACKDETAIL.DropID),'')
         ,  SKU.DESCR
			,  SKU.STYLE	

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
END
GO
GRANT EXECUTE ON  [dbo].[isp_CartonManifestLabel40_RDT] TO [NSQL]
GO






