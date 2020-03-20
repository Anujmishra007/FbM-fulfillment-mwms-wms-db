if exists (select * from  dbo.sysobjects where id = object_id(N'[dbo].[isp_CartonManifestLabel31_rdt]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [dbo].[isp_CartonManifestLabel31_rdt]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/
/* Store Procedure:  isp_CartonManifestLabel31_rdt                      */
/* Creation Date: 11-Feb-2019                                           */
/* Copyright: IDS                                                       */
/* Written by: CSCHONG                                                  */
/*                                                                      */
/* Purpose:  WMS-7938: Lululemon HK - New NSO manifest Label            */
/*                                                                      */
/* Input Parameters: @c_PickslipNo, @c_CartonNoStart, @c_CartonNoEnd    */
/*                    - 1) RDT    - PickslipNo, Start Carton# &         */
/*                                  End Carton#                         */                                        
/*                                                                      */
/* Called By:  dw = r_dw_carton_manifest_label_31_rdt                   */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/************************************************************************/
CREATE PROC [dbo].[isp_CartonManifestLabel31_rdt] (
      @c_PickslipNo     NVARCHAR(10) 
   ,  @c_CartonNoStart  NVARCHAR(20)
   ,  @c_CartonNoEnd    NVARCHAR(20)
) 
AS
BEGIN
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_IsRDT     INT
         , @n_StartTCnt INT

   SET @n_IsRDT     = 0
   SET @n_StartTCnt = @@TRANCOUNT

   WHILE @@TRANCOUNT > 0 
   BEGIN
      COMMIT TRAN
   END

      SELECT PACKHEADER.PickSlipNo      
            ,ExternOrderkey = ISNULL(RTRIM(ORDERS.ExternOrderkey),'')
            ,PACKDETAIL.CartonNo 
            ,PACKDETAIL.LabelNo 
            ,Style = ISNULL(RTRIM(SKU.Style),'')
            ,Color = ''--ISNULL(RTRIM(SKU.Color),'')
            ,SDESCR = substring(Max(SKU.DESCR),1,len(Max(SKU.DESCR))-4)
            ,Qty = SUM(PACKDETAIL.Qty)
        FROM ORDERS     WITH (NOLOCK) 
        JOIN PACKHEADER WITH (NOLOCK) ON (ORDERS.OrderKey = PACKHEADER.OrderKey)
        JOIN PACKDETAIL WITH (NOLOCK) ON (PACKHEADER.PickSlipNo = PACKDETAIL.PickSlipNo)
        JOIN SKU        WITH (NOLOCK) ON (PACKDETAIL.Storerkey = SKU.Storerkey) AND (PACKDETAIL.Sku = SKU.Sku)
       WHERE PACKHEADER.PickSlipNo = @c_PickslipNo
         AND PACKDETAIL.CartonNo   BETWEEN CAST(@c_CartonNoStart AS INT) AND CAST(@c_CartonNoEnd AS INT)
       GROUP BY PACKHEADER.PickSlipNo
               ,ISNULL(RTRIM(ORDERS.ExternOrderkey),'')
               ,PACKDETAIL.CartonNo
               ,PACKDETAIL.LabelNo 
               ,ISNULL(RTRIM(SKU.Style),'')
              -- ,ISNULL(RTRIM(SKU.Color),'')
       ORDER BY ISNULL(RTRIM(ORDERS.ExternOrderkey),'')
	           ,PACKDETAIL.LabelNo
               ,PACKDETAIL.CartonNo 
               ,ISNULL(RTRIM(SKU.Style),'')
             --  ,ISNULL(RTRIM(SKU.Color),'')

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXECUTE ON dbo.isp_CartonManifestLabel31_rdt TO NSQL
GO