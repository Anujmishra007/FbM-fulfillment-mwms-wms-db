IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_PackListByCtn08]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_PackListByCtn08]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: isp_PackListByCtn08                                     */
/* Creation Date: 17-JAN-2017                                           */
/* Copyright: LF Logistics                                              */
/* Written by: YTWan                                                    */
/*                                                                      */
/* Purpose:  WMS-944 - CN SPEEDO CARTON LABEL CR                        */
/*        :                                                             */
/* Called By: r_dw_packing_list_by_ctn08                                */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/************************************************************************/
CREATE PROC isp_PackListByCtn08
           @c_PickSlipNo      NVARCHAR(10)
         , @c_Orderkey        NVARCHAR(10) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt             INT
         , @n_Continue              INT
         
         , @n_PrintOrderAddresses   INT
         
   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1

  	SELECT  dbo.ORDERS.Storerkey
         , dbo.ORDERS.Orderkey
         , ExternOrderkey= ISNULL(RTRIM(dbo.ORDERS.ExternOrderkey),'')
         , ConsigneeKey  = ISNULL(RTRIM(dbo.ORDERS.ConsigneeKey),'')
         , C_Company     = ISNULL(RTRIM(dbo.ORDERS.C_Company),'')
         , C_Address1    = ISNULL(RTRIM(dbo.ORDERS.C_Address1),'') 
         , C_Address2    = ISNULL(RTRIM(dbo.ORDERS.C_Address2),'')  
         , C_Address3    = ISNULL(RTRIM(dbo.ORDERS.C_Address3),'')  
         , C_Address4    = ISNULL(RTRIM(dbo.ORDERS.C_Address4),'') 
         , C_State       = ISNULL(RTRIM(dbo.ORDERS.C_State),'') 
         , C_City        = ISNULL(RTRIM(dbo.ORDERS.C_City),'') 
         , C_Contact1    = ISNULL(RTRIM(dbo.ORDERS.C_Contact1),'')
         , C_Contact2    = ISNULL(RTRIM(dbo.ORDERS.C_Contact2),'')         
         , C_Phone1      = ISNULL(RTRIM(dbo.ORDERS.C_Phone1),'') 
         , Customerpo    = ISNULL(RTRIM(dbo.ORDERS.UserDefine01),'') 
         , ORD_Notes     = ISNULL(RTRIM(dbo.ORDERS.Notes),'') 
         , dbo.PACKDETAIL.PickSlipNo
         , dbo.PACKDETAIL.CartonNo
         , dbo.PACKDETAIL.LabelNo
         , DropID        = ISNULL(RTRIM(dbo.PACKDETAIL.DropID),'') 
         , Material      = ISNULL(RTRIM(dbo.SKU.ManufacturerSku),'') 
         , Descr         = ISNULL(RTRIM(dbo.SKU.Notes1),'') 
         , Size          = ISNULL(RTRIM(dbo.SKU.Size),'') 
         , Qty           = SUM(dbo.PACKDETAIL.Qty) 
     FROM dbo.PACKHEADER WITH (NOLOCK) 
     JOIN dbo.ORDERS WITH (NOLOCK)   
	    ON (dbo.PACKHEADER.Orderkey = dbo.ORDERS.Orderkey) 
     JOIN dbo.PACKDETAIL WITH (NOLOCK) 
	    ON (dbo.PACKHEADER.PickSlipNo = dbo.PACKDETAIL.PickSlipNo) 
     JOIN dbo.SKU WITH (NOLOCK) 
	    ON (dbo.PACKDETAIL.Storerkey = dbo.SKU.Storerkey) 
       AND(dbo.PACKDETAIL.Sku = dbo.SKU.Sku)
    WHERE (dbo.PACKHEADER.PickSlipNo= @c_PickSlipNo)
 GROUP BY dbo.ORDERS.Storerkey
        , dbo.ORDERS.Orderkey
        , ISNULL(RTRIM(dbo.ORDERS.ExternOrderkey),'')
		  , ISNULL(RTRIM(dbo.ORDERS.ConsigneeKey),'')
	  	  , ISNULL(RTRIM(dbo.ORDERS.C_Company),'')
	  	  , ISNULL(RTRIM(dbo.ORDERS.C_Address1),'') 
	  	  , ISNULL(RTRIM(dbo.ORDERS.C_Address2),'')  
	  	  , ISNULL(RTRIM(dbo.ORDERS.C_Address3),'')  
	  	  , ISNULL(RTRIM(dbo.ORDERS.C_Address4),'') 
	  	  , ISNULL(RTRIM(dbo.ORDERS.C_State),'') 
	  	  , ISNULL(RTRIM(dbo.ORDERS.C_City),'')
	  	  , ISNULL(RTRIM(dbo.ORDERS.C_Contact1),'')         
	  	  , ISNULL(RTRIM(dbo.ORDERS.C_Contact2),'')    
	  	  , ISNULL(RTRIM(dbo.ORDERS.C_Phone1),'') 
        , ISNULL(RTRIM(dbo.ORDERS.UserDefine01),'') 
        , ISNULL(RTRIM(dbo.ORDERS.Notes),'') 
        , dbo.PACKDETAIL.PickSlipNo
        , dbo.PACKDETAIL.CartonNo
        , dbo.PACKDETAIL.LabelNo
        , ISNULL(RTRIM(dbo.PACKDETAIL.DropID),'') 
        , ISNULL(RTRIM(dbo.SKU.ManufacturerSku),'') 
        , ISNULL(RTRIM(dbo.SKU.Size),'') 
        , ISNULL(RTRIM(dbo.SKU.Notes1),'') 
 ORDER BY dbo.PACKDETAIL.CartonNo

QUIT_SP:
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_PackListByCtn08] TO nSQL 
GO
