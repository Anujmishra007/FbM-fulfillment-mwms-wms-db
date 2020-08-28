IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[isp_packinglist_detail_07]') AND type in (N'P', N'PC'))
   DROP PROCEDURE [dbo].[isp_packinglist_detail_07]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Stored Proc: isp_packinglist_detail_07                               */  
/* Creation Date: 06-May-2020                                           */  
/* Copyright: LF Logistics                                              */  
/* Written by: CSCHONG                                                  */  
/*                                                                      */  
/* Purpose: WMS-13023 - [CN] Sephora WMS_B2C_Packing_list               */  
/*        :                                                             */  
/* Called By: r_dw_packinglist_detail_07                                */  
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
  
CREATE PROC isp_packinglist_detail_07
            @c_Pickslipno        NVARCHAR(10),
            @c_Type              NVARCHAR(10) = 'H1'
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
         , @c_Storerkey       NVARCHAR(20)
         , @c_ExternOrderKey  NVARCHAR(50)  

         , @c_RptLogo             NVARCHAR(255)  
         , @c_ecomflag            NVARCHAR(50)
         , @n_MaxLineno           INT
         , @n_MaxId               INT
         , @n_MaxRec              INT
         , @n_CurrentRec          INT
         , @c_recgroup            INT
         , @n_MaxCartonNo         INT
         , @n_Loop                INT
         , @n_LoopCnt             INT
         , @c_Conso               NVARCHAR(10) = 'N'
         , @c_Orderkey            NVARCHAR(10)
         , @c_GetPickslipno       NVARCHAR(10)
         , @c_GetCartonNo         NVARCHAR(10)
         , @n_CountSKU            INT = 0
         , @n_MaxLineFirstPage    INT = 7
         , @n_MaxLineRemainPage   INT = 11
         , @n_CurrentPage         INT
         , @n_TotalPage           INT
         , @c_TotalRows           INT
         , @n_PageGroup           INT = 1
         , @n_Max                 INT
         , @c_GetOrderkey         NVARCHAR(10)
         , @c_showqrcode          NVARCHAR(5)
         , @c_OHUDF03             NVARCHAR(50)
  
   SET @n_StartTCnt = @@TRANCOUNT  
   SET @n_Continue  = 1  
   SET @b_Success   = 1  
   SET @n_Err       = 0  
   SET @c_Errmsg    = '' 
   SET @n_Loop      = 1

   SELECT @n_MaxCartonNo = MAX(CartonNo)
   FROM PACKDETAIL (NOLOCK) 
   WHERE Pickslipno = @c_Pickslipno

   CREATE TABLE #Temp_PACKDET07 (
        Externorderkey   NVARCHAR(50),
        c_contact1       NVARCHAR(30),
        OHNotes          NVARCHAR(4000),
        c_Company        NVARCHAR(45),
        DischargePlace   NVARCHAR(30),
        Wavekey          NVARCHAR(20),
        OHTYPE           NVARCHAR(10),
        PmtTerm          NVARCHAR(10),
        SKU              NVARCHAR(20),
        PACKQty          INT,
        LabelNo          NVARCHAR(20),
        Storerkey        NVARCHAR(15),
        Pickslipno       NVARCHAR(10),
        SDESCR           NVARCHAR(60),
        OHUDF10          NVARCHAR(10),
        QRCODE           NVARCHAR(1),
        RPTNotes1        NVARCHAR(4000),  
        RPTNotes2        NVARCHAR(4000),
        RPTNotes3        NVARCHAR(4000),
        RPTNotes4        NVARCHAR(4000)
   )

   CREATE TABLE #TMP_DECRYPTEDDATA (  
      Orderkey     NVARCHAR(10) NULL,  
      C_Company    NVARCHAR(45) NULL,  
      C_contact1   NVARCHAR(45) NULL
   )  
   CREATE NONCLUSTERED INDEX IDX_TMP_DECRYPTEDDATA ON #TMP_DECRYPTEDDATA (Orderkey)  

   SELECT @c_Orderkey = Orderkey
         ,@c_Storerkey = Storerkey 
   FROM PACKHEADER (NOLOCK)
   WHERE Pickslipno = @c_Pickslipno

 SET @n_StartTCnt = @@TRANCOUNT  
  
   EXEC isp_Open_Key_Cert_Orders_PI  
      @n_Err    = @n_Err    OUTPUT,  
      @c_ErrMsg = @c_ErrMsg OUTPUT  
  
   IF ISNULL(@c_ErrMsg,'') <> ''  
   BEGIN  
      SET @n_Continue = 3  
      GOTO QUIT_SP  
   END       

   DECLARE CUR_LOOP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
   SELECT OH.Orderkey  
   FROM PACKHEADER PH (NOLOCK)
   JOIN ORDERS OH WITH (NOLOCK) ON OH.OrderKey = PH.OrderKey 
   WHERE Pickslipno = @c_Pickslipno
   AND ISNULL(PH.orderkey,'') <> ''
   UNION
   SELECT OH.Orderkey  
   FROM PACKHEADER PH (NOLOCK)
   JOIN ORDERS OH WITH (NOLOCK) ON OH.loadkey = PH.loadkey 
   WHERE Pickslipno = @c_Pickslipno
   AND ISNULL(PH.orderkey,'') = ''
  
   OPEN CUR_LOOP  
  
   FETCH NEXT FROM CUR_LOOP INTO @c_GetOrderkey  
  
   WHILE @@FETCH_STATUS <> -1  
   BEGIN  
      INSERT INTO #TMP_DECRYPTEDDATA  
      SELECT Orderkey, C_Company, C_Contact1 FROM fnc_GetDecryptedOrderPI(@c_GetOrderkey)  
  
      FETCH NEXT FROM CUR_LOOP INTO @c_GetOrderkey  
   END   


   IF ISNULL(@c_Orderkey,'') = ''
   BEGIN
      SET @c_Conso = 'Y'
   END

   IF @c_Conso = 'Y'
   BEGIN
      INSERT INTO #Temp_PACKDET07
      SELECT MAX(OH.ExternOrderkey) AS ExternOrderkey
           , MAX(t.c_contact1) AS c_Contact1
           , MAX(ISNULL(OH.Notes,'')) AS OHNotes
           , MAX(t.c_Company) AS c_Company
           , MAX(ISNULL(OH.DischargePlace,'')) AS DischargePlace
           , MAX(OH.UserDefine09) AS wavekey
           , MAX(OH.type) AS OHTYPE
           , MAX(OH.PmtTerm) AS PmtTerm
           , PD.SKU
           , SUM(PD.Qty) AS PACKQty
           , PD.LabelNo
           , @c_Storerkey    
           , @c_Pickslipno   
           , S.DESCR AS SDESCR
           ,MAX(OH.UserDefine10) as OHUDF10
           ,'N'--CASE WHEN ISNULL(C.short,'') = '1' THEN 'Y' ELSE 'N' END
           ,MAX(ISNULL(C1.notes,''))
           ,MAX(ISNULL(C2.notes,''))
           ,MAX(ISNULL(C3.notes,''))
           ,MAX(ISNULL(C1.notes,''))
      FROM ORDERS OH (NOLOCK)
      --LEFT JOIN STORER St (NOLOCK) ON St.Storerkey = OH.ConsigneeKey
      JOIN LoadPlanDetail LPD (NOLOCK) ON LPD.Orderkey = OH.Orderkey
      JOIN PACKHEADER PH (NOLOCK) ON PH.LoadKey = LPD.LoadKey
      JOIN PACKDETAIL PD (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
      JOIN SKU S WITH (NOLOCK) ON S.StorerKey = PD.StorerKey AND S.sku = PD.sku
      LEFT JOIN CODELKUP C WITH (NOLOCK) ON C.LISTNAME = 'Sephora2C' AND C.code = OH.UserDefine03
                                           AND C.storerkey = OH.StorerKey
      LEFT JOIN CODELKUP C1 WITH (NOLOCK) ON C1.LISTNAME = 'Sephora2C2' AND C1.storerkey = OH.StorerKey  
      LEFT JOIN CODELKUP C2 WITH (NOLOCK) ON C2.LISTNAME = 'Sephora2C3' AND C2.storerkey = OH.StorerKey  
      LEFT JOIN CODELKUP C3 WITH (NOLOCK) ON C3.LISTNAME = 'Sephora2C4' AND C3.storerkey = OH.StorerKey   
      JOIN #TMP_DECRYPTEDDATA t WITH (NOLOCK) ON (t.Orderkey = OH.Orderkey)    
      WHERE PH.Storerkey = @c_Storerkey
      AND PH.PickSlipNo = @c_Pickslipno
      AND OH.DOCTYPE = 'E'
      GROUP BY  PD.SKU
              , PD.LabelNo
              , S.DESCR 
              , CASE WHEN ISNULL(C.short,'') = '1' THEN 'Y' ELSE 'N' END
   END
   ELSE
   BEGIN
      INSERT INTO #Temp_PACKDET07
      SELECT MAX(OH.ExternOrderkey) AS ExternOrderkey
           , MAX(t.c_contact1) AS c_Contact1
           , MAX(ISNULL(OH.Notes,'')) AS OHNotes
           , MAX(t.c_Company) AS c_Company
           , MAX(ISNULL(OH.DischargePlace,'')) AS DischargePlace
           , MAX(OH.UserDefine09) AS wavekey
           , MAX(OH.type) AS OHTYPE
           , MAX(OH.PmtTerm) AS PmtTerm
           , PD.SKU
           , SUM(PD.Qty) AS PACKQty
           , PD.LabelNo
           , @c_Storerkey    
           , @c_Pickslipno   
           , S.DESCR AS SDESCR
           ,MAX(OH.UserDefine10) as OHUDF10
           ,'N'--CASE WHEN ISNULL(C.short,'') = '1' THEN 'Y' ELSE 'N' END
           ,MAX(ISNULL(C1.notes,''))
           ,MAX(ISNULL(C2.notes,''))
           ,MAX(ISNULL(C3.notes,''))
           ,MAX(ISNULL(C.notes,''))  
      FROM ORDERS OH (NOLOCK)
      LEFT JOIN STORER St (NOLOCK) ON St.Storerkey = OH.ConsigneeKey
      JOIN PACKHEADER PH (NOLOCK) ON PH.OrderKey = OH.OrderKey
      JOIN PACKDETAIL PD (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
      JOIN SKU S WITH (NOLOCK) ON S.StorerKey = PD.StorerKey AND S.sku = PD.sku
      LEFT JOIN CODELKUP C WITH (NOLOCK) ON C.LISTNAME = 'Sephora2C' AND C.code = OH.UserDefine03
                                           AND C.storerkey = OH.StorerKey
      LEFT JOIN CODELKUP C1 WITH (NOLOCK) ON C1.LISTNAME = 'Sephora2C2' AND C1.storerkey = OH.StorerKey  
      LEFT JOIN CODELKUP C2 WITH (NOLOCK) ON C2.LISTNAME = 'Sephora2C3' AND C2.storerkey = OH.StorerKey  
      LEFT JOIN CODELKUP C3 WITH (NOLOCK) ON C3.LISTNAME = 'Sephora2C4' AND C3.storerkey = OH.StorerKey  
      JOIN #TMP_DECRYPTEDDATA t WITH (NOLOCK) ON (t.Orderkey = OH.Orderkey)  
      WHERE PH.Storerkey = @c_Storerkey
      AND PH.PickSlipNo = @c_Pickslipno
      AND OH.DOCTYPE = 'E'
      GROUP BY PD.SKU
              , PD.LabelNo
              , S.DESCR 
              , CASE WHEN ISNULL(C.short,'') = '1' THEN 'Y' ELSE 'N' END
   END
   
   SET @c_ExternOrderKey = ''
   SET @c_showqrcode     = ''
   SET @c_OHUDF03        = ''

   SELECT @c_ExternOrderKey = MAX(externorderkey)
   FROM #Temp_PACKDET07
   WHERE Pickslipno = @c_Pickslipno


   IF ISNULL(@c_ExternOrderKey,'') <> ''
   BEGIN
       SET @c_OHUDF03 = ''

       SELECT @c_OHUDF03 = MAX(OH.Userdefine03)
       FROM ORDERS OH WITH (NOLOCK)
       WHERE OH.ExternOrderKey = @c_ExternOrderKey


       IF ISNULL(@c_OHUDF03,'') <> ''
       BEGIN
          
         SELECT  @c_showqrcode = CASE WHEN ISNULL(C.short,'') = '1' THEN 'Y' ELSE 'N' END  
         FROM CODELKUP C WITH (NOLOCK) 
         WHERE C.listname = 'Sephora2C'
         AND c.Code = @c_OHUDF03
         AND C.storerkey = @c_Storerkey        
       END

       UPDATE #Temp_PACKDET07
       SET QRCODE = CASE WHEN ISNULL(@c_showqrcode,'') <> '' THEN @c_showqrcode ELSE QRCODE END
       WHERE Externorderkey = @c_ExternOrderKey
       AND Pickslipno = @c_Pickslipno
       AND Storerkey =@c_Storerkey
      END

   IF @c_Type = 'H1'
   BEGIN
      SELECT DISTINCT externorderkey,
               c_contact1, 
               DischargePlace,
               Wavekey,
               OHTYPE,
               PmtTerm,
               LabelNo,
               Storerkey,
               Pickslipno,
               OHUDF10,
               c_Company,
               QRCODE,
               RPTNotes1,  
               RPTNotes2,
               RPTNotes3,
               RPTNotes4
      FROM #Temp_PACKDET07
      WHERE Pickslipno = @c_Pickslipno 
      GROUP BY externorderkey,
               c_contact1, 
               c_Company,
               DischargePlace,
               Wavekey,
               OHTYPE,
               PmtTerm,
               LabelNo,
               Storerkey,
               Pickslipno,
               OHUDF10,
               QRCODE,
               RPTNotes1,  
               RPTNotes2,
               RPTNotes3,
               RPTNotes4
      ORDER BY Pickslipno
   END
   ELSE IF @c_Type = 'D1'
   BEGIN
      SELECT DISTINCT         
             sku        
           , sdescr         
           , pickslipno  
           , sum(PACKQty) as PACKQty 
           --, MAX(OHNotes) as OHNotes            
      FROM #Temp_PACKDET07
      WHERE Pickslipno = @c_Pickslipno
      GROUP BY pickslipno        
             , sku        
             , sdescr
   END
   ELSE IF @c_Type = 'D2'
   BEGIN
      SELECT Pickslipno, MAX(OHNotes) as OHNotes
      FROM #Temp_PACKDET07
      WHERE Pickslipno = @c_Pickslipno
      GROUP BY pickslipno  
   END
   
   IF OBJECT_ID('tempdb..#Temp_PACKDET07') IS NOT NULL
      DROP TABLE #Temp_PACKDET07


   IF CURSOR_STATUS('LOCAL' , 'CUR_LOOP') in (0 , 1)
   BEGIN
      CLOSE CUR_LOOP
      DEALLOCATE CUR_LOOP   
   END
   
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
   
END -- procedure

GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

GRANT EXECUTE ON [dbo].[isp_packinglist_detail_07] TO nSQL 
GO
