IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_PackingList_detail_06]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_PackingList_detail_06]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

  
/************************************************************************/    
/* Trigger: isp_PackingList_detail_06                                   */    
/* Creation Date: 26-MAR-2020                                           */    
/* Copyright: LF Logistics                                              */    
/* Written by: CSCHONG                                                  */    
/*                                                                      */    
/* Purpose: WMS-12513 - [CN]Nike-Cord Packing list-CR                   */    
/*        :                                                             */    
/* Called By: r_dw_packinglist_detail_06_21                             */    
/*          :                                                           */    
/* PVCS Version: 1.0                                                    */    
/*                                                                      */    
/* Version: 7.0                                                         */    
/*                                                                      */    
/* Data Modifications:                                                  */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date         Author    Ver Purposes                                  */ 
/* 2020-08-06   WLChooi   1.1 WMS-14613 - Change to M_Company and add   */
/*                            column (WL01)                             */   
/* 2021-01-21   WLChooi   1.2 WMS-16158 - Cater for Type = '51' (WL02)  */ 
/************************************************************************/    
CREATE PROC isp_PackingList_detail_06  
            @c_PickSlipNo     NVARCHAR(10)   
           ,@c_ohtype         NVARCHAR(10) = ''  
AS    
BEGIN    
   SET NOCOUNT ON    
   SET ANSI_NULLS OFF    
   SET QUOTED_IDENTIFIER OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
    
   DECLARE    
           @n_StartTCnt       INT    
         , @n_Continue        INT    
         , @b_Success         INT    
         , @n_Err             INT    
         , @c_Errmsg          NVARCHAR(255)    
    
   SET @n_StartTCnt= @@TRANCOUNT    
   SET @n_Continue = 1    
   SET @b_Success  = 1    
   SET @n_Err      = 0    
   SET @c_Errmsg   = ''     
   
   CREATE TABLE #TMP_PACKLISTDET06  
      ( Orderkey               NVARCHAR(10)   NOT NULL
      , ExternOrderkey         NVARCHAR(50)   NOT NULL
      , c_city                 NVARCHAR(45)   NULL
      , C_Contact1             NVARCHAR(45)   NULL    
      , C_Address1             NVARCHAR(45)   NULL     
      , c_phone1               NVARCHAR(20)   NULL    
      , C_Address2             NVARCHAR(45)   NULL    
      , PickSlipno             NVARCHAR(10)   NULL    
      , c_State                NVARCHAR(45)   NULL    
      , SKU                    NVARCHAR(20)   NULL    
      , Descr                  NVARCHAR(60)   NULL      
      , OpenQty                INT    
      , ExtOrdKey              NVARCHAR(50)   NULL   --WL01
      , C_Zip                  NVARCHAR(45)   NULL   --WL01
      , NKStoreID              NVARCHAR(255)  NULL   --WL02
      , NKStoreAddr            NVARCHAR(500)  NULL   --WL02
      , RTNQR                  NVARCHAR(255)  NULL   --WL02
      , NKEQR                  NVARCHAR(255)  NULL   --WL02
   )  
      
   --WL02 S
   IF @c_ohtype = '51'
   BEGIN
      INSERT INTO #TMP_PACKLISTDET06    
      SELECT OH.Orderkey,    
             OH.M_Company,  
             OH.C_city,    
             OH.C_Contact1,    
             OH.C_Address1,    
             OH.C_phone1,    
             OH.C_Address2,    
             PH.PickSlipno,    
             OH.C_state,  
             LTRIM(RTRIM(ISNULL(SKU.Style,''))) + '-' + 
             LTRIM(RTRIM(ISNULL(SKU.Color,''))) + '-' + 
             LTRIM(RTRIM(ISNULL(SKU.Size,''))),      
             SKU.Descr,    
             OD.OriginalQty, 
             SUBSTRING(OH.ExternOrderKey,1,CHARINDEX('/',OH.ExternOrderkey) - 1),  
             OH.C_Zip,
             ISNULL(CL1.[Description],''),   
             LTRIM(RTRIM(ISNULL(OH.M_State,''))) + LTRIM(RTRIM(ISNULL(OH.M_City,''))) +
             LTRIM(RTRIM(ISNULL(OH.M_Address1,''))) + LTRIM(RTRIM(ISNULL(OH.M_Address2,''))) +
             LTRIM(RTRIM(ISNULL(OH.M_Address3,''))) + LTRIM(RTRIM(ISNULL(OH.M_Address4,''))),
             LTRIM(RTRIM(ISNULL(CL2.Long,''))) + LTRIM(RTRIM(ISNULL(OH.RTNTrackingNo,''))),
             ISNULL(CL1.Code2,'')
      FROM PACKHEADER        PH  WITH (NOLOCK)    
      JOIN ORDERS            OH  WITH (NOLOCK) ON (PH.Orderkey = OH.Orderkey)    
      JOIN ORDERDETAIL       OD  WITH (NOLOCK) ON (OD.Orderkey = OH.Orderkey )  
      JOIN SKU               SKU WITH (NOLOCK) ON (OD.Storerkey= SKU.Storerkey) AND (OD.Sku = SKU.Sku)  
      --CROSS APPLY (SELECT TOP 1 ORDERDETAIL.Channel 
      --             FROM ORDERDETAIL (NOLOCK) 
      --             WHERE ORDERDETAIL.OrderKey = OH.Orderkey) AS OD1
      LEFT JOIN CODELKUP     CL1 WITH (NOLOCK) ON (CL1.LISTNAME = 'NKSTOREID') AND (CL1.Code = OH.CountryOfOrigin)
                                              AND (CL1.Storerkey = OH.StorerKey)
      LEFT JOIN CODELKUP     CL2 WITH (NOLOCK) ON (CL2.LISTNAME = 'RTNQR')
                                              AND (CL2.Storerkey = OH.StorerKey)
      --LEFT JOIN CODELKUP     CL3 WITH (NOLOCK) ON (CL3.LISTNAME = 'NKEQR')
      --                                        AND (CL3.Storerkey = OH.StorerKey)
      --                                        AND (CL3.Code = CL1.Code)
      WHERE   PH.PickSlipNo = @c_PickSlipNo  
      AND OH.[Type] = @c_ohtype  
   END
   ELSE
   BEGIN
      INSERT INTO #TMP_PACKLISTDET06  
      (  Orderkey      
       , ExternOrderkey
       , c_city        
       , C_Contact1    
       , C_Address1    
       , c_phone1      
       , C_Address2    
       , PickSlipno    
       , c_State       
       , SKU           
       , Descr         
       , OpenQty       
       , ExtOrdKey     
       , C_Zip
      )   
      --WL02 E	
      SELECT OH.Orderkey,    
             OH.M_Company,   --OH.ExternOrderkey,   --WL01    
             OH.C_city,    
             OH.C_Contact1,    
             OH.C_Address1,    
             OH.C_phone1,    
             OH.C_Address2,    
             PH.PickSlipno,    
             OH.C_state,  
             CASE WHEN @c_ohtype = '41' THEN LTRIM(RTRIM(ISNULL(SKU.Style,''))) + '-' + LTRIM(RTRIM(ISNULL(SKU.Color,''))) + '-' + LTRIM(RTRIM(ISNULL(SKU.Size,''))) ELSE OD.SKU END,   --WL01    
             SKU.Descr,    
             CASE WHEN @c_ohtype = '41' THEN OD.OriginalQty ELSE OD.OpenQty END,   --WL01
             SUBSTRING(OH.ExternOrderKey,1,CHARINDEX('/',OH.ExternOrderkey) - 1),  --WL01  
             OH.C_Zip   --WL01
      FROM PACKHEADER        PH  WITH (NOLOCK)    
      -- JOIN PACKDETAIL        PD  WITH (NOLOCK) ON (PH.PickSlipNo = PD.PickSlipNo)    
      JOIN ORDERS            OH  WITH (NOLOCK) ON (PH.Orderkey = OH.Orderkey)    
      JOIN ORDERDETAIL       OD  WITH (NOLOCK) ON (OD.Orderkey = OH.ORderkey )  
      JOIN SKU               SKU WITH (NOLOCK) ON (OD.Storerkey= SKU.Storerkey) AND (OD.Sku = SKU.Sku)    
      WHERE   PH.PickSlipNo = @c_PickSlipNo  
      AND OH.type = @c_ohtype
   END   --WL02  
   
QUIT_SP: 
   IF @n_Continue = 3    
   BEGIN    
      IF @@TRANCOUNT > 0    
      BEGIN    
         ROLLBACK TRAN    
      END    
   END    
   ELSE    
   BEGIN    
      WHILE @@TRANCOUNT > @n_StartTCnt    
      BEGIN    
         COMMIT TRAN    
      END    
   END    
    
   WHILE @@TRANCOUNT < @n_StartTCnt    
   BEGIN    
      BEGIN TRAN    
   END    
    
   --WL02 S  
   --SELECT * FROM #TMP_PACKLISTDET06  
   --ORDER BY Pickslipno,sku  
  
   IF @c_ohtype = '51'
   BEGIN
      SELECT Orderkey      
           , ExternOrderkey
           , c_city        
           , C_Contact1    
           , C_Address1    
           , c_phone1      
           , C_Address2    
           , PickSlipno    
           , c_State       
           , SKU           
           , Descr         
           , OpenQty       
           , ExtOrdKey     
           , C_Zip         
           , NKStoreID     
           , NKStoreAddr   
           , RTNQR         
           , NKEQR         
      FROM #TMP_PACKLISTDET06
      ORDER BY Pickslipno,sku  
   END
   ELSE
   BEGIN
      SELECT Orderkey      
           , ExternOrderkey
           , c_city        
           , C_Contact1    
           , C_Address1    
           , c_phone1      
           , C_Address2    
           , PickSlipno    
           , c_State       
           , SKU           
           , Descr         
           , OpenQty       
           , ExtOrdKey     
           , C_Zip              
      FROM #TMP_PACKLISTDET06
      ORDER BY Pickslipno,sku  
   END
   
   IF OBJECT_ID('tempdb..#TMP_PACKLISTDET06') IS NOT NULL
       DROP TABLE #TMP_PACKLISTDET06
   --WL02 E
      
END -- procedure    

GO
GRANT EXECUTE ON [dbo].[isp_PackingList_detail_06] TO nsql
GO

