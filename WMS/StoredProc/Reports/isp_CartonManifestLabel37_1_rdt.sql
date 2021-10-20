IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[isp_CartonManifestLabel37_1_rdt]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[isp_CartonManifestLabel37_1_rdt]
GO
 
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO   

/************************************************************************/    
/* Stored Procedure: isp_CartonManifestLabel37_1_rdt                    */    
/* Creation Date: 14-Jun-2021                                           */    
/* Copyright: LFL                                                       */    
/* Written by: WLChooi                                                  */    
/*                                                                      */    
/* Purpose: WMS-17265 - Adidas UCC Shipping & Carton Label              */    
/*                                                                      */    
/* Called By: r_dw_carton_manifest_label_37_1_rdt                       */    
/*                                                                      */    
/* GitLab Version: 1.0                                                  */    
/*                                                                      */    
/* Version: 5.4                                                         */    
/*                                                                      */    
/* Data Modifications:                                                  */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date         Author  Ver   Purposes                                  */ 
/* 2021-06-14  WLChooi  1.0   Created - DevOps Combine Script           */     
/************************************************************************/    
CREATE PROC dbo.isp_CartonManifestLabel37_1_rdt (    
       @c_Loadkey          NVARCHAR(10),     
       @c_Dropid           NVARCHAR(20),    
       @c_Externorderkey   NVARCHAR(50),
       @c_Style            NVARCHAR(20)
)    
AS    
BEGIN    
   SET NOCOUNT ON 
   SET ANSI_NULLS OFF 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF  
   
   DECLARE @n_continue    INT,    
           @c_errmsg      NVARCHAR(255),    
           @b_success     INT,    
           @n_err         INT,     
           @b_debug       INT    
       
   SET @b_debug = 0    
    
   SELECT SkuSize       = ISNULL(RTRIM(SKU.Size),'') + '/'  
                        + CONVERT(VARCHAR(5), SUM(PACKDETAIL.Qty))
         ,Seperator     = ', '
   FROM PACKHEADER  WITH (NOLOCK) 
   JOIN PACKDETAIL  WITH (NOLOCK) ON (PACKHEADER.PickSlipNo = PACKDETAIL.PickSlipNo)
   JOIN ORDERS WITH (NOLOCK) ON (PACKHEADER.Orderkey    = ORDERS.Orderkey) 
   JOIN SKU         WITH (NOLOCK) ON (PACKDETAIL.Storerkey  = SKU.Storerkey)     
                                  AND(PACKDETAIL.Sku        = SKU.Sku)
   LEFT JOIN CODELKUP WITH (NOLOCK) ON (CODELKUP.ListName = 'SIZELSTORD')
                                    AND(CODELKUP.Storerkey= PACKDETAIL.Storerkey)
                                    AND(CODELKUP.Code = ISNULL(RTRIM(SKU.Size),''))
   WHERE PACKHEADER.Loadkey = @c_Loadkey
   AND   PACKDETAIL.LabelNo  = @c_dropid
   AND   ORDERS.ExternOrderkey = @c_externorderkey
   AND   SKU.Style = @c_style
   GROUP BY ISNULL(RTRIM(SKU.Size),'')
         ,  CONVERT(INT, CASE WHEN CODELKUP.Short IS NULL THEN '99999' ELSE CODELKUP.Short END)
	ORDER BY CONVERT(INT, CASE WHEN CODELKUP.Short IS NULL THEN '99999' ELSE CODELKUP.Short END) 

END 
GO
GRANT EXECUTE ON isp_CartonManifestLabel37_1_rdt TO NSQL
GO

