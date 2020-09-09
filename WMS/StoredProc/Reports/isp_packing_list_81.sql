IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_packing_list_81]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_packing_list_81]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: isp_Packing_List_81                                */
/* Creation Date: 28-AUG-2020                                           */
/* Copyright: IDS                                                       */
/* Written by: CSCHONG                                                  */
/*                                                                      */
/* Purpose:WMS-14913 -[CN] Natural Beauty Packing List by carton        */
/*        :                                                             */
/* Called By: r_dw_packing_list_81                                      */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/************************************************************************/
CREATE PROC isp_packing_list_81
         @c_PickSlipNo     NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt       INT
         , @n_Continue        INT 

         , @n_MaxCartonNo     INT
		   , @n_NoOfLine        INT

   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_NoOfLine = 8

   SET @n_MaxCartonNo = 0
   SELECT TOP 1 @n_MaxCartonNo = PD.CartonNo
   FROM PACKDETAIL PD WITH (NOLOCK) 
   WHERE PD.PickSlipNo = @c_PickSlipNo
   ORDER BY PD.CartonNo DESC

   SELECT Facility      = ISNULL(RTRIM(FACILITY.Descr),'')
		,STR_Company		= ISNULL(RTRIM(STORER.Company),'')
		,ExternOrderkey   = ISNULL(RTRIM(ORDERS.ExternOrderkey),'')
		,Loadkey          = ISNULL(RTRIM(ORDERS.Loadkey),'')
		,ConsigneeKey     = ISNULL(RTRIM(ORDERS.ConsigneeKey),'')
		,C_Company        = ISNULL(RTRIM(ORDERS.C_Company),'')
		,C_Address1       = ISNULL(RTRIM(ORDERS.C_Address1),'')
		,C_Address2       = ISNULL(RTRIM(ORDERS.C_Address2),'')
		,C_Address3       = ISNULL(RTRIM(ORDERS.C_Address3),'')
		,C_Address4       = ISNULL(RTRIM(ORDERS.C_Address4),'')
		,InterModalVehicle= ISNULL(RTRIM(ORDERS.Shipperkey),'')
		,PickSlipNo       = ISNULL(PACKDETAIL.PickSlipNo,0)
		,CartonNo         = ISNULL(PACKDETAIL.CartonNo,0)
		,Sku              = ISNULL(RTRIM(PACKDETAIL.Sku),'')
		,SkuDescr         = ISNULL(RTRIM(SKU.Descr),'')
		,Qty              = ISNULL(SUM(PACKDETAIL.Qty),0)
		,UnitPrice        = CASE WHEN RTRIM(ISNULL(ORDERS.Userdefine01,'')) = 'N' THEN 
                               0
                          ELSE 
                            (SELECT TOP 1 ISNULL(UnitPrice,0)
									  FROM ORDERDETAIL WITH (NOLOCK) 
									  WHERE ORDERDETAIL.Orderkey = ISNULL(RTRIM(ORDERS.Orderkey),'')
									  AND   ORDERDETAIL.Storerkey= ISNULL(RTRIM(PACKDETAIL.Storerkey),'')
									  AND   ORDERDETAIL.Sku      = ISNULL(RTRIM(PACKDETAIL.Sku),''))
                          END 
      ,Notes2_1           = SUBSTRING(CONVERT(NVARCHAR(250), ORDERS.Notes2),1,41) 
      ,Notes2_2           = SUBSTRING(CONVERT(NVARCHAR(250), ORDERS.Notes2),42,41) 
      ,Notes2_3           = SUBSTRING(CONVERT(NVARCHAR(250), ORDERS.Notes2),83,41) 
      ,Notes2_4           = SUBSTRING(CONVERT(NVARCHAR(250), ORDERS.Notes2),124,41) 
      ,Notes2_5           = SUBSTRING(CONVERT(NVARCHAR(250), ORDERS.Notes2),165,41) 
      ,sku_notes1         = ISNULL(SKU.notes1,'')
      ,sku_busr5          = ISNULL(SKU.BUSR5,'')
      ,MissPQty =  (SELECT CASE WHEN SUM(openqty) > SUM(qtypicked) then 'Y' ELSE 'N' END
									  FROM ORDERDETAIL WITH (NOLOCK) 
									  WHERE ORDERDETAIL.Orderkey = ISNULL(RTRIM(ORDERS.Orderkey),'')
									  AND   ORDERDETAIL.Storerkey= ISNULL(RTRIM(PACKDETAIL.Storerkey),'')
									  AND   ORDERDETAIL.Sku      = ISNULL(RTRIM(PACKDETAIL.Sku),''))
     ,C_Zip               = ISNULL(RTRIM(ORDERS.C_Zip),'')
     ,Orderkey   = ISNULL(RTRIM(ORDERS.Orderkey),'')
	FROM PACKHEADER WITH (NOLOCK)
	JOIN ORDERS     WITH (NOLOCK) ON (PACKHEADER.Orderkey = ORDERS.Orderkey)
	JOIN FACILITY   WITH (NOLOCK) ON (ORDERS.Facility = FACILITY.Facility)
	JOIN STORER     WITH (NOLOCK) ON (ORDERS.Storerkey = STORER.Storerkey)
	JOIN PACKDETAIL WITH (NOLOCK) ON (PACKHEADER.PickSlipNo = PACKDETAIL.PickSlipNo)
	JOIN SKU        WITH (NOLOCK) ON (PACKDETAIL.Storerkey = SKU.Storerkey)
											AND(PACKDETAIL.Sku = SKU.Sku)
	WHERE PACKDETAIL.PickSlipNo = @c_PickSlipNo
	GROUP BY	ISNULL(RTRIM(FACILITY.Descr),'')
			,  ISNULL(RTRIM(STORER.Company),'')
			,  ISNULL(RTRIM(ORDERS.Orderkey),'')
			,  ISNULL(RTRIM(ORDERS.ExternOrderkey),'')
			,  ISNULL(RTRIM(ORDERS.Loadkey),'')
			,  ISNULL(RTRIM(ORDERS.ConsigneeKey),'')
			,  ISNULL(RTRIM(ORDERS.C_Company),'')
			,  ISNULL(RTRIM(ORDERS.C_Address1),'')
			,  ISNULL(RTRIM(ORDERS.C_Address2),'')
			,  ISNULL(RTRIM(ORDERS.C_Address3),'')
			,  ISNULL(RTRIM(ORDERS.C_Address4),'')
			,  ISNULL(RTRIM(ORDERS.Shipperkey),'')
			,  ISNULL(PACKDETAIL.PickSlipNo,0)
			,  ISNULL(PACKDETAIL.CartonNo,0)
			,  ISNULL(RTRIM(PACKDETAIL.Storerkey),'')
			,  ISNULL(RTRIM(PACKDETAIL.Sku),'')
			,  ISNULL(RTRIM(SKU.Descr),'') 
         ,  ORDERS.Userdefine01 
         ,  SUBSTRING(CONVERT(NVARCHAR(250), ORDERS.Notes2),1,41) 
         ,  SUBSTRING(CONVERT(NVARCHAR(250), ORDERS.Notes2),42,41) 
         ,  SUBSTRING(CONVERT(NVARCHAR(250), ORDERS.Notes2),83,41) 
         ,  SUBSTRING(CONVERT(NVARCHAR(250), ORDERS.Notes2),124,41) 
         ,  SUBSTRING(CONVERT(NVARCHAR(250), ORDERS.Notes2),165,41) 
         ,  ISNULL(SKU.notes1,'')
         ,  ISNULL(SKU.BUSR5,'')
         ,  ISNULL(RTRIM(ORDERS.Orderkey),'')
         ,  ISNULL(RTRIM(ORDERS.C_Zip),'')
    ORDER BY ISNULL(PACKDETAIL.CartonNo,0)
			,  ISNULL(RTRIM(PACKDETAIL.Sku),'')


END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_packing_list_81] TO nSQL 
GO