IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[isp_Delivery_Receipt09]') AND type in (N'P', N'PC'))
   DROP PROCEDURE [dbo].[isp_Delivery_Receipt09]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Stored Proc: isp_Delivery_Receipt09                                  */  
/* Creation Date: 01-Feb-2021                                           */  
/* Copyright: LF Logistics                                              */  
/* Written by: WLChooi                                                  */  
/*                                                                      */  
/* Purpose: WMS-16276 - LEGO Delivery Note                              */  
/*        :                                                             */  
/* Called By: r_dw_delivery_receipt09                                   */  
/*          :                                                           */  
/* GitLab Version: 1.1                                                  */  
/*                                                                      */  
/* Version: 7.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author    Ver Purposes                                  */ 
/* 2021-03-16   WLChooi   1.1 WMS-16276 - Add new columns (WL01)        */
/************************************************************************/  
CREATE PROC [dbo].[isp_Delivery_Receipt09]
            @c_MBOLKey    NVARCHAR(10)
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
         , @c_Orderkey        NVARCHAR(10) = ''
         , @c_SKU             NVARCHAR(20)
         , @n_SumInCtn        INT
         , @n_SumInQty        INT
         , @c_Notes           NVARCHAR(4000)
         , @c_Notes2          NVARCHAR(4000)
         , @n_STDGROSSWGT     DECIMAL(10,2)
         , @n_GrossWgt        DECIMAL(10,2)
         , @c_PrevOrderkey    NVARCHAR(10)
         , @n_TTLWeight       DECIMAL(10,2) = 0.00
         , @n_TTLCBM          DECIMAL(10,2) = 0.00
         , @n_Cube            DECIMAL(10,2) = 0.00
         , @n_StdCube         DECIMAL(10,2) = 0.00
         , @c_Storerkey       NVARCHAR(15)
         , @c_Notes2A         NVARCHAR(4000) = ''
         , @c_Notes2B         NVARCHAR(4000) = ''
         , @n_Notes2AStart    INT
         , @n_Notes2AEnd      INT
         , @n_Notes2BStart    INT
         , @n_Notes2BEnd      INT
         , @c_Containerkey    NVARCHAR(10)
              
   SET @n_StartTCnt = @@TRANCOUNT  
   SET @n_Continue  = 1  
   SET @b_Success   = 1  
   SET @n_Err       = 0  
   SET @c_Errmsg    = ''
   
   CREATE TABLE #TMP_DATA (
   	STCompany       NVARCHAR(45)
    , STAddress1      NVARCHAR(45)
    , STAddress2      NVARCHAR(45)
    , STAddress3      NVARCHAR(45)
    , STAddress4      NVARCHAR(45)
    , STZip           NVARCHAR(45)
    , STCountry       NVARCHAR(45)
    , C_Contact1      NVARCHAR(45)
    , C_Company       NVARCHAR(45)
    , Address1        NVARCHAR(45)
    , Address2        NVARCHAR(45)
    , Address3        NVARCHAR(45)
    , Address4        NVARCHAR(45)
    , Zip             NVARCHAR(45)
    , Country         NVARCHAR(45)
    , MbolKey         NVARCHAR(10)
    , OrderKey        NVARCHAR(10)
    , ExternOrderKey  NVARCHAR(50)
    , EffectiveDate   DATETIME
    , DeliveryDate    DATETIME
    , Notes           NVARCHAR(4000)
    , Notes2A         NVARCHAR(4000)
    , Notes2B         NVARCHAR(4000)
    , UserDefine02    NVARCHAR(50)
    , SKU             NVARCHAR(50)
    , UPC             NVARCHAR(50)
    , DESCR           NVARCHAR(255)
    , SUMInCtn        INT
    , SUMInQty        INT
    , UserDefine04    NVARCHAR(50)
    , StorerKey       NVARCHAR(15)
    , TTLWeight       DECIMAL(10,2)
    , TTLCBM          DECIMAL(10,2)
    , ContainerKey    NVARCHAR(10)
    , InvoiceNo       NVARCHAR(40)
    , C_State         NVARCHAR(45)
    , Notes2          NVARCHAR(30)
    , SumQty          INT   --WL01
   )
   --IF EXISTS (SELECT 1 FROM CONTAINER (NOLOCK) WHERE MBOLKey = @c_MBOLKey)
   --BEGIN
   
   INSERT INTO #TMP_DATA   --With Containerkey
   SELECT ST.Company
        , ISNULL(ST.Address1,'')   AS STAddress1
        , ISNULL(ST.Address2,'')   AS STAddress2
        , ISNULL(ST.Address3,'')   AS STAddress3
        , ISNULL(ST.Address4,'')   AS STAddress4
        , ISNULL(ST.Zip,'')        AS STZip
        --, ISNULL(ST.Country,'')    AS STCountry  
        , CASE ISNULL(CK1.LONG, '') WHEN '' THEN ISNULL(ST.Country,'') ELSE CK1.LONG END AS STCountry  
        , ISNULL(OH.C_Contact1,'') AS C_Contact1
        , ISNULL(OH.C_Company,'')  AS C_Company
        , ISNULL(OH.C_Address1,'') AS Address1
        , ISNULL(OH.C_Address2,'') AS Address2
        , ISNULL(OH.C_Address3,'') AS Address3
        , ISNULL(OH.C_Address4,'') AS Address4
        , ISNULL(OH.C_Zip,'')      AS Zip
        --, ISNULL(OH.C_Country,'')  AS Country  
        , CASE ISNULL(CK.LONG, '') WHEN '' THEN ISNULL(OH.C_Country,'') ELSE CK.LONG END AS Country 
        , M.MbolKey
        , OH.OrderKey
        --, OH.ExternOrderKey  Get New DeliveryNo  
        , CASE ISNULL(EXO2.UserDefine09,'') WHEN '' THEN OH.ExternOrderKey ELSE EXO2.UserDefine09 END  
        , OH.EffectiveDate
        , OH.DeliveryDate
        , OH.Notes
        , Notes2A = OH.Notes2
        , Notes2B = ''
        , OD.UserDefine02
        , CASE WHEN OD.ConsoOrderLineNo > 0 THEN '_' + LTRIM(RTRIM(S.SKU)) ELSE LTRIM(RTRIM(S.SKU)) END AS SKU
        , CASE WHEN ISNULL(OD.UserDefine03,'') = 'Y' 
               THEN CASE WHEN ISNULL(OD.RetailSku,'') <> '' THEN OD.RetailSku ELSE S.AltSku END 
               ELSE CASE WHEN LEN(EOD.Notes) > 101 THEN SUBSTRING(EOD.Notes,101, 20) ELSE S.AltSku END 
          END AS UPC
        , S.DESCR
        , CASE WHEN P.CaseCnt > 0 THEN FLOOR(MAX(PIDET.Qty)/P.CaseCnt) ELSE 0 END AS SUMInCtn   --WL01
        , MAX(PIDET.Qty) -  CASE WHEN P.CaseCnt > 0 THEN (FLOOR(MAX(PIDET.Qty)/P.CaseCnt) * P.CaseCnt) ELSE 0 END AS SUMInQty   --WL01
        , OD.UserDefine04
        , OH.StorerKey
        , TTLWeight = CAST(0.00 AS DECIMAL(10,2))
        , TTLCBM    = CAST(0.00 AS DECIMAL(10,2))
        , C.Containerkey
        , OH.UserDefine04
        , ISNULL(OH.C_State,'') AS C_State
        , OD.Notes2
        , MAX(PIDET.Qty)   --WL01
   FROM ORDERS OH (NOLOCK)
   JOIN ORDERDETAIL OD (NOLOCK) ON OH.OrderKey = OD.OrderKey
   CROSS APPLY (SELECT TOP 1 ExternOrdersDetail.Orderkey, ExternOrdersDetail.OrderLineNumber, ExternOrdersDetail.Notes
                FROM ExternOrdersDetail (NOLOCK) 
                WHERE ExternOrdersDetail.OrderKey = OD.OrderKey AND ExternOrdersDetail.OrderLineNumber = OD.OrderLineNumber) AS EOD
   JOIN MBOL M (NOLOCK) ON OH.MBOLKey = M.MbolKey
   JOIN SKU S (NOLOCK) ON S.SKU = OD.SKU AND S.StorerKey = OD.StorerKey
   --JOIN PICKDETAIL PD (NOLOCK) ON OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber AND OD.SKU = PD.Sku
   JOIN CONTAINER C (NOLOCK) ON C.MbolKey = M.MbolKey
   JOIN CONTAINERDETAIL CD (NOLOCK) ON CD.ContainerKey = C.ContainerKey
   JOIN PALLETDETAIL PLTD (NOLOCK) ON PLTD.PalletKey = CD.PalletKey
   JOIN PACKDETAIL PD (NOLOCK) ON PD.LabelNo = PLTD.CaseId AND PD.StorerKey = PLTD.StorerKey
   JOIN PACK P (NOLOCK) ON P.PackKey = S.PACKKey
   JOIN STORER ST (NOLOCK) ON ST.StorerKey = OH.StorerKey
   JOIN ExternOrders EXO1 (NOLOCK) ON EXO1.EXTERNORDERKEY = M.MbolKey AND EXO1.ORDERKEY = 'C888888888' AND EXO1.[Source] = C.ContainerKey        
   JOIN ExternOrders EXO2 (NOLOCK) ON EXO2.EXTERNORDERKEY = EXO1.ExternOrdersKey AND EXO2.ORDERKEY =  OH.OrderKey  
   CROSS APPLY (SELECT SUM(Qty) AS Qty FROM PICKDETAIL (NOLOCK) WHERE OrderKey = OD.OrderKey AND SKU = OD.SKU AND OrderLineNumber = OD.OrderLineNumber) AS PIDET   --WL01
   LEFT JOIN CODELKUP CK (NOLOCK) ON CK.LISTNAME = 'ISOCOUNTRY' AND CK.CODE = OH.C_COUNTRY  
   LEFT JOIN CODELKUP CK1 (NOLOCK) ON CK1.LISTNAME = 'ISOCOUNTRY' AND CK1.CODE = ST.COUNTRY  
   WHERE M.MbolKey = @c_MBOLKey
   GROUP BY ST.Company
          , ISNULL(ST.Address1,'')  
          , ISNULL(ST.Address2,'')  
          , ISNULL(ST.Address3,'')  
          , ISNULL(ST.Address4,'')  
          , ISNULL(ST.Zip,'')       
          , CASE ISNULL(CK1.LONG, '') WHEN '' THEN ISNULL(ST.Country,'') ELSE CK1.LONG END  
          , ISNULL(OH.C_Contact1,'')
          , ISNULL(OH.C_Company,'') 
          , ISNULL(OH.C_Address1,'')  
          , ISNULL(OH.C_Address2,'')  
          , ISNULL(OH.C_Address3,'')  
          , ISNULL(OH.C_Address4,'')  
          , ISNULL(OH.C_Zip,'')       
          , CASE ISNULL(CK.LONG, '') WHEN '' THEN ISNULL(OH.C_Country,'') ELSE CK.LONG END 
          , M.MbolKey
          , OH.OrderKey
          , CASE ISNULL(EXO2.UserDefine09,'') WHEN '' THEN OH.ExternOrderKey ELSE EXO2.UserDefine09 END  
          , OH.EffectiveDate
          , OH.DeliveryDate
          , OH.Notes
          , OH.Notes2
          , OD.UserDefine02
          , CASE WHEN OD.ConsoOrderLineNo > 0 THEN '_' + LTRIM(RTRIM(S.SKU)) ELSE LTRIM(RTRIM(S.SKU)) END
          , CASE WHEN ISNULL(OD.UserDefine03,'') = 'Y' 
                 THEN CASE WHEN ISNULL(OD.RetailSku,'') <> '' THEN OD.RetailSku ELSE S.AltSku END 
                 ELSE CASE WHEN LEN(EOD.Notes) > 101 THEN SUBSTRING(EOD.Notes,101, 20) ELSE S.AltSku END 
            END
          , S.DESCR
          , P.CaseCnt
          , OD.UserDefine04
          , OH.StorerKey
          , C.Containerkey
          , OH.UserDefine04
          , ISNULL(OH.C_State,'')
          , OD.Notes2
   UNION ALL   --WithOUT Containerkey
   SELECT ST.Company
        , ISNULL(ST.Address1,'')   AS STAddress1
        , ISNULL(ST.Address2,'')   AS STAddress2
        , ISNULL(ST.Address3,'')   AS STAddress3
        , ISNULL(ST.Address4,'')   AS STAddress4
        , ISNULL(ST.Zip,'')        AS STZip
        --, ISNULL(ST.Country,'')    AS STCountry  
        , CASE ISNULL(CK1.LONG, '') WHEN '' THEN ISNULL(ST.Country,'') ELSE CK1.LONG END AS STCountry  
        , ISNULL(OH.C_Contact1,'') AS C_Contact1
        , ISNULL(OH.C_Company,'')  AS C_Company
        , ISNULL(OH.C_Address1,'') AS Address1
        , ISNULL(OH.C_Address2,'') AS Address2
        , ISNULL(OH.C_Address3,'') AS Address3
        , ISNULL(OH.C_Address4,'') AS Address4
        , ISNULL(OH.C_Zip,'')      AS Zip
        --, ISNULL(OH.C_Country,'')  AS Country  
        , CASE ISNULL(CK.LONG, '') WHEN '' THEN ISNULL(OH.C_Country,'') ELSE CK.LONG END AS Country  
        , M.MbolKey
        , OH.OrderKey
        , OH.ExternOrderKey
        , OH.EffectiveDate
        , OH.DeliveryDate
        , OH.Notes
        , Notes2A = OH.Notes2
        , Notes2B = ''
        , OD.UserDefine02
        , CASE WHEN OD.ConsoOrderLineNo > 0 THEN '_' + LTRIM(RTRIM(S.SKU)) ELSE LTRIM(RTRIM(S.SKU)) END AS SKU
        , CASE WHEN ISNULL(OD.UserDefine03,'') = 'Y' 
               THEN CASE WHEN ISNULL(OD.RetailSku,'') <> '' THEN OD.RetailSku ELSE S.AltSku END 
               ELSE CASE WHEN LEN(EOD.Notes) > 101 THEN SUBSTRING(EOD.Notes,101, 20) ELSE S.AltSku END 
          END AS UPC
        , S.DESCR
        , CASE WHEN P.CaseCnt > 0 THEN FLOOR(MAX(PIDET.Qty)/P.CaseCnt) ELSE 0 END AS SUMInCtn   --WL01
        , MAX(PIDET.Qty) -  CASE WHEN P.CaseCnt > 0 THEN (FLOOR(MAX(PIDET.Qty)/P.CaseCnt) * P.CaseCnt) ELSE 0 END AS SUMInQty   --WL01
        , OD.UserDefine04
        , OH.StorerKey
        , TTLWeight = CAST(0.00 AS DECIMAL(10,2))
        , TTLCBM    = CAST(0.00 AS DECIMAL(10,2))
        , ''
        , OH.UserDefine04
        , ISNULL(OH.C_State,'') AS C_State
        , OD.Notes2
        , MAX(PIDET.Qty)   --WL01
   FROM ORDERS OH (NOLOCK)
   JOIN ORDERDETAIL OD (NOLOCK) ON OH.OrderKey = OD.OrderKey
   CROSS APPLY (SELECT TOP 1 ExternOrdersDetail.Orderkey, ExternOrdersDetail.OrderLineNumber, ExternOrdersDetail.Notes
                FROM ExternOrdersDetail (NOLOCK) 
                WHERE ExternOrdersDetail.OrderKey = OD.OrderKey AND ExternOrdersDetail.OrderLineNumber = OD.OrderLineNumber) AS EOD
   JOIN MBOL M (NOLOCK) ON OH.MBOLKey = M.MbolKey
   JOIN SKU S (NOLOCK) ON S.SKU = OD.SKU AND S.StorerKey = OD.StorerKey
   JOIN PICKDETAIL PD (NOLOCK) ON OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber AND OD.SKU = PD.Sku
   JOIN PACK P (NOLOCK) ON P.PackKey = S.PACKKey
   JOIN STORER ST (NOLOCK) ON ST.StorerKey = OH.StorerKey
   CROSS APPLY (SELECT SUM(Qty) AS Qty FROM PICKDETAIL (NOLOCK) WHERE OrderKey = OD.OrderKey AND SKU = OD.SKU AND OrderLineNumber = OD.OrderLineNumber) AS PIDET   --WL01
   LEFT JOIN CODELKUP CK (NOLOCK) ON CK.LISTNAME = 'ISOCOUNTRY' AND CK.CODE = OH.C_COUNTRY  
   LEFT JOIN CODELKUP CK1 (NOLOCK) ON CK1.LISTNAME = 'ISOCOUNTRY' AND CK1.CODE = ST.COUNTRY  
   WHERE M.MbolKey = @c_MBOLKey  
   AND NOT EXISTS (SELECT 1 FROM CONTAINERDETAIL CTD1 (NOLOCK)
                   JOIN PALLETDETAIL PLTD1 (NOLOCK) ON CTD1.PalletKey = PLTD1.PalletKey
                   JOIN PACKDETAIL   PKD1  (NOLOCK) ON PLTD1.CaseId = PKD1.LabelNo  
                   JOIN PackHeader   PKDH1 (NOLOCK) ON PKD1.PickSlipNo = PKDH1.PickSlipNo AND PKDH1.OrderKey = OH.OrderKey)
   GROUP BY ST.Company
          , ISNULL(ST.Address1,'')  
          , ISNULL(ST.Address2,'')  
          , ISNULL(ST.Address3,'')  
          , ISNULL(ST.Address4,'')  
          , ISNULL(ST.Zip,'')       
          , CASE ISNULL(CK1.LONG, '') WHEN '' THEN ISNULL(ST.Country,'') ELSE CK1.LONG END  
          , ISNULL(OH.C_Contact1,'')
          , ISNULL(OH.C_Company,'') 
          , ISNULL(OH.C_Address1,'')  
          , ISNULL(OH.C_Address2,'')  
          , ISNULL(OH.C_Address3,'')  
          , ISNULL(OH.C_Address4,'')  
          , ISNULL(OH.C_Zip,'')       
          , CASE ISNULL(CK.LONG, '') WHEN '' THEN ISNULL(OH.C_Country,'') ELSE CK.LONG END  
          , M.MbolKey
          , OH.OrderKey
          , OH.ExternOrderKey
          , OH.EffectiveDate
          , OH.DeliveryDate
          , OH.Notes
          , OH.Notes2
          , OD.UserDefine02
          , CASE WHEN OD.ConsoOrderLineNo > 0 THEN '_' + LTRIM(RTRIM(S.SKU)) ELSE LTRIM(RTRIM(S.SKU)) END
          , CASE WHEN ISNULL(OD.UserDefine03,'') = 'Y' 
                 THEN CASE WHEN ISNULL(OD.RetailSku,'') <> '' THEN OD.RetailSku ELSE S.AltSku END 
                 ELSE CASE WHEN LEN(EOD.Notes) > 101 THEN SUBSTRING(EOD.Notes,101, 20) ELSE S.AltSku END 
            END
          , S.DESCR
          , P.CaseCnt
          , OD.UserDefine04
          , OH.StorerKey
          , OH.UserDefine04
          , ISNULL(OH.C_State,'')
          , OD.Notes2

   DECLARE CUR_LOOP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT Orderkey, SKU, SUM(SUMInCtn), SUM(SUMInQty), Notes2A, Storerkey, Containerkey
      FROM #TMP_DATA 
      GROUP BY Orderkey, SKU, Notes2A, Storerkey, Containerkey
      ORDER BY Orderkey, SKU
   
   OPEN CUR_LOOP
   	
   FETCH NEXT FROM CUR_LOOP INTO @c_Orderkey, @c_SKU, @n_SumInCtn, @n_SumInQty, @c_Notes2, @c_Storerkey, @c_Containerkey
                                                                               
   WHILE @@FETCH_STATUS <> -1
   BEGIN
   	IF @c_PrevOrderkey <> @c_Orderkey
   	BEGIN
         SET @c_Notes2B = ''  
         SET @c_Notes2A = ''  
         SET @n_Notes2AEnd = 0  
         SET @n_Notes2BEnd = 0  
         
         SELECT @n_Notes2AStart = PATINDEX('%SHIPPING%', @c_Notes2)  
         
         IF @n_Notes2AStart > 0  
         BEGIN  
            SELECT @n_Notes2AEnd = @n_Notes2AStart + LEN('SHIPPING')  
         END  

         SELECT @n_Notes2BStart = PATINDEX('%BOOKING%', @c_Notes2)  
         
         IF @n_Notes2BStart > 0  
         BEGIN  
            SELECT @n_Notes2BEnd = @n_Notes2BStart + LEN('BOOKING')  
            SELECT @c_Notes2B    = RIGHT(@c_Notes2, (LEN(@c_Notes2) - @n_Notes2BEnd))  
            SELECT @c_Notes2     = LEFT(@c_Notes2, @n_Notes2BStart - 2)  
         END  
           
         IF @n_Notes2AStart > 0  
         BEGIN  
            SELECT @c_Notes2A = SUBSTRING(@c_Notes2, @n_Notes2AEnd + 1, LEN(@c_Notes2) - @n_Notes2AEnd)  
         END  
         
         --SELECT @c_Notes2A = ColValue FROM dbo.fnc_delimsplit ('|',@c_Notes2) WHERE SeqNo = 3
         --SELECT @c_Notes2B = ColValue FROM dbo.fnc_delimsplit ('|',@c_Notes2) WHERE SeqNo = 5
   	END
   	
   	SELECT @n_STDGROSSWGT = SKU.STDGROSSWGT
   	     , @n_GrossWgt    = SKU.GrossWgt   
   	     , @n_Cube        = SKU.[Cube]       
   	     , @n_StdCube     = SKU.StdCube    
   	FROM SKU (NOLOCK)
   	WHERE SKU.SKU = @c_SKU AND SKU.StorerKey = @c_Storerkey
   	
   	SET @n_TTLWeight = (@n_SumInCtn * @n_GrossWgt)      --Full Case
   	SET @n_TTLWeight = @n_TTLWeight + (@n_SumInQty * @n_STDGROSSWGT)   --Loose
   	
      SET @n_TTLCBM = (@n_SumInCtn * @n_Cube)      --Full Case
   	SET @n_TTLCBM = @n_TTLCBM + (@n_SumInQty * @n_StdCube)   --Loose
   	
      --SELECT @n_TTLWeight 
      --     , @n_TTLCBM
      --     , @n_STDGROSSWGT
      --     , @n_GrossWgt   
      --     , @n_Cube       
      --     , @n_StdCube    
   	
   	UPDATE #TMP_DATA
   	SET TTLWeight = TTLWeight + @n_TTLWeight
   	  , TTLCBM    = TTLCBM + @n_TTLCBM
   	  , Notes2A   = @c_Notes2A
   	  , Notes2B   = @c_Notes2B
   	WHERE Orderkey = @c_Orderkey AND SKU = @c_SKU AND ContainerKey = @c_Containerkey
   	
   	SET @n_TTLWeight = 0.00
   	SET @n_TTLCBM    = 0.00
   	SET @c_Notes2A   = ''
   	SET @c_Notes2B   = ''
   	                            
      FETCH NEXT FROM CUR_LOOP INTO @c_Orderkey, @c_SKU, @n_SumInCtn, @n_SumInQty, @c_Notes2, @c_Storerkey, @c_Containerkey
   END
   
   SELECT * FROM #TMP_DATA ORDER BY Containerkey, OrderKey, UserDefine04  
   
QUIT_SP:  
   IF OBJECT_ID('tempdb..#TMP_DATA') IS NOT NULL
      DROP TABLE #TMP_DATA
END -- procedure
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

GRANT EXECUTE ON [dbo].[isp_Delivery_Receipt09] TO nSQL 
GO
