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
      )  
  
      INSERT INTO #TMP_PACKLISTDET06  
      SELECT OH.Orderkey,  
             OH.ExternOrderkey,  
             OH.C_city,  
             OH.C_Contact1,  
             OH.C_Address1,  
             OH.C_phone1,  
             OH.C_Address2,  
             PH.PickSlipno,  
             OH.C_state,
             OD.SKU,  
             SKU.Descr,  
             OD.OpenQty
      FROM PACKHEADER        PH  WITH (NOLOCK)  
     -- JOIN PACKDETAIL        PD  WITH (NOLOCK) ON (PH.PickSlipNo = PD.PickSlipNo)  
      JOIN ORDERS            OH  WITH (NOLOCK) ON (PH.Orderkey = OH.Orderkey)  
      JOIN ORDERDETAIL       OD  WITH (NOLOCK) ON (OD.Orderkey = OH.ORderkey )
      JOIN SKU               SKU WITH (NOLOCK) ON (OD.Storerkey= SKU.Storerkey) AND (OD.Sku = SKU.Sku)  
      WHERE   PH.PickSlipNo = @c_PickSlipNo
     AND OH.type = @c_ohtype

        
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
  
  
  SELECT * FROM #TMP_PACKLISTDET06
  ORDER BY Pickslipno,sku

END -- procedure  

GO
GRANT EXECUTE ON [dbo].[isp_PackingList_detail_06] TO nsql
GO

