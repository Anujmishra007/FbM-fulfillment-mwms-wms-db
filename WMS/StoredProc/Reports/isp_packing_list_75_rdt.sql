IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[isp_packing_list_75_rdt]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[isp_packing_list_75_rdt]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Proc: isp_packing_list_75_rdt                                 */
/* Creation Date: 04-May-2020                                           */
/* Copyright: LF Logistics                                              */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: WMS-13212 - Sephora B2B Packing List                        */
/*        :                                                             */
/* Called By: r_dw_packing_list_75_rdt                                  */
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
CREATE PROC isp_packing_list_75_rdt
           @c_Storerkey       NVARCHAR(15),
           @c_LabelNo         NVARCHAR(50)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt       INT
         , @n_Continue        INT 
         , @c_ExternOrderkey1 NVARCHAR(4000) = ''
         , @c_ExternOrderkey2 NVARCHAR(4000) = ''
         , @c_ExternOrderkey3 NVARCHAR(4000) = ''
         , @c_ExternOrderkey4 NVARCHAR(4000) = ''
         , @c_ExternOrderkey5 NVARCHAR(4000) = ''
         , @c_PickSlipNo      NVARCHAR(10) = ''
         , @c_Loadkey         NVARCHAR(10) = ''
         , @c_Orderkey        NVARCHAR(10) = ''
         , @n_Err             INT = 0
         , @c_ErrMsg          NVARCHAR(255) = ''
         , @b_success         INT = 1

   CREATE TABLE #TMP_DECRYPTEDDATA (
      Orderkey     NVARCHAR(10) NULL,
      C_Company    NVARCHAR(45) NULL,
      C_Address2   NVARCHAR(45) NULL,
      C_Address3   NVARCHAR(45) NULL
   )
   CREATE NONCLUSTERED INDEX IDX_TMP_DECRYPTEDDATA ON #TMP_DECRYPTEDDATA (Orderkey)

   CREATE TABLE #TMP_Externorderkey (
      RowRef            INT NOT NULL IDENTITY(1,1),
      Externorderkey    NVARCHAR(50)
   )

   SET @n_StartTCnt = @@TRANCOUNT

   EXEC isp_Open_Key_Cert_Orders_PI
      @n_Err    = @n_Err    OUTPUT,
      @c_ErrMsg = @c_ErrMsg OUTPUT

   IF ISNULL(@c_ErrMsg,'') <> ''
   BEGIN
      SET @n_Continue = 3
      GOTO QUIT_SP
   END

   INSERT INTO #TMP_Externorderkey
   SELECT DISTINCT ORDERS.Externorderkey
   FROM ORDERS (NOLOCK)
   JOIN LOADPLANDETAIL (NOLOCK) ON LOADPLANDETAIL.Loadkey = ORDERS.Loadkey
   JOIN PACKHEADER (NOLOCK) ON PACKHEADER.Loadkey = LOADPLANDETAIL.Loadkey
   JOIN PACKDETAIL (NOLOCK) ON PACKDETAIL.Pickslipno = PACKHEADER.Pickslipno
   JOIN PICKDETAIL (NOLOCK) ON PICKDETAIL.CaseID = PACKDETAIL.LabelNo AND PICKDETAIL.Orderkey = ORDERS.Orderkey
   WHERE PACKDETAIL.Storerkey = @c_Storerkey
   AND PACKDETAIL.LabelNo = @c_LabelNo
   ORDER BY ORDERS.Externorderkey

   SELECT @c_ExternOrderkey1 = STUFF((SELECT ', ' + RTRIM(Externorderkey) FROM #TMP_Externorderkey WHERE RowRef BETWEEN 1 AND 3 ORDER BY Externorderkey FOR XML PATH('')),1,1,'' )
   SELECT @c_ExternOrderkey2 = STUFF((SELECT ', ' + RTRIM(Externorderkey) FROM #TMP_Externorderkey WHERE RowRef BETWEEN 4 AND 6 ORDER BY Externorderkey FOR XML PATH('')),1,1,'' )
   SELECT @c_ExternOrderkey3 = STUFF((SELECT ', ' + RTRIM(Externorderkey) FROM #TMP_Externorderkey WHERE RowRef BETWEEN 7 AND 9 ORDER BY Externorderkey FOR XML PATH('')),1,1,'' )
   SELECT @c_ExternOrderkey4 = STUFF((SELECT ', ' + RTRIM(Externorderkey) FROM #TMP_Externorderkey WHERE RowRef BETWEEN 10 AND 12 ORDER BY Externorderkey FOR XML PATH('')),1,1,'' )
   SELECT @c_ExternOrderkey5 = STUFF((SELECT ', ' + RTRIM(Externorderkey) FROM #TMP_Externorderkey WHERE RowRef BETWEEN 13 AND 15 ORDER BY Externorderkey FOR XML PATH('')),1,1,'' )

   --SELECT @c_ExternOrderkey2 = SUBSTRING(@c_ExternOrderkeys,CHARINDEX(',',@c_ExternOrderkeys,30) + 1,LEN(@c_ExternOrderkeys) - LEN(@c_ExternOrderkey1) )

   SELECT @c_Loadkey = PACKHEADER.Loadkey
   FROM PACKDETAIL (NOLOCK)
   JOIN PACKHEADER (NOLOCK) ON PACKHEADER.Pickslipno = PACKDETAIL.Pickslipno
   WHERE PACKDETAIL.Storerkey = @c_Storerkey
   AND PACKDETAIL.LabelNo = @c_LabelNo

   DECLARE CUR_LOOP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT DISTINCT LPD.Orderkey
   FROM LOADPLANDETAIL LPD (NOLOCK)
   WHERE LPD.Loadkey = @c_Loadkey

   OPEN CUR_LOOP

   FETCH NEXT FROM CUR_LOOP INTO @c_Orderkey

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      INSERT INTO #TMP_DECRYPTEDDATA
      SELECT Orderkey, C_Company, C_Address2, C_Address3 FROM fnc_GetDecryptedOrderPI(@c_Orderkey)

      FETCH NEXT FROM CUR_LOOP INTO @c_Orderkey
   END

   --SELECT @c_ExternOrderkey1 ,@c_ExternOrderkey2 
   SELECT  PDET.LabelNo
         , OH.Loadkey
         , ISNULL(F.Contact1,'') AS FContact1
         , ISNULL(F.Address1,'') AS FAddress1
         , ISNULL(F.Address2,'') AS FAddress2
         , ISNULL(F.Address3,'') AS FAddress3
         , ISNULL(F.Address4,'') AS FAddress4
         , MAX(ISNULL(t.C_Company,'')) AS C_Company
         , MAX(ISNULL(t.C_Address2,'')) AS C_Address2
         , MAX(ISNULL(t.C_Address3,'')) AS C_Address3
         , RIGHT(PDET.LabelNo, 7) AS CaseID
         , ISNULL(PDET.UPC,'') AS UPC
         , PDET.SKU
         , SKU.DESCR
         , ISNULL(SKU.SUSR2,'') AS SUSR2
         , CASE WHEN LEN(ISNULL(SKU.BUSR4,'')) > 10 THEN SUBSTRING(ISNULL(SKU.BUSR4,''),1,10) + ' ' + SUBSTRING(ISNULL(SKU.BUSR4,''),11,LEN(ISNULL(SKU.BUSR4,'')) - 10)
                                                    ELSE ISNULL(SKU.BUSR4,'') END AS BUSR4
         , SUM(PD.Qty)
         , CASE WHEN ISNULL(CL.Short,'N') = 'Y' THEN LA.Lottable03 ELSE '' END AS Lottable03
         , CASE WHEN ISNULL(CL.Short,'N') = 'Y' THEN LA.Lottable04 ELSE NULL END AS Lottable04
         , LTRIM(RTRIM(@c_ExternOrderkey1)) AS ExternOrderkey1
         , LTRIM(RTRIM(@c_ExternOrderkey2)) AS ExternOrderkey2
         , LTRIM(RTRIM(@c_ExternOrderkey3)) AS ExternOrderkey3
         , LTRIM(RTRIM(@c_ExternOrderkey4)) AS ExternOrderkey4
         , LTRIM(RTRIM(@c_ExternOrderkey5)) AS ExternOrderkey5
   FROM PACKHEADER PH WITH (NOLOCK)
   JOIN PACKDETAIL PDET WITH (NOLOCK) ON (PDET.Pickslipno = PH.Pickslipno)
   JOIN LOADPLANDETAIL LPD WITH (NOLOCK) ON (PH.Loadkey = LPD.Loadkey)
   JOIN ORDERS     OH WITH (NOLOCK) ON (LPD.Orderkey = OH.Orderkey)
   JOIN PICKDETAIL PD WITH (NOLOCK) ON (OH.Orderkey = PD.Orderkey) AND (PD.SKU = PDET.SKU) AND (PDET.LabelNo = PD.CaseID)
   JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON (LA.LOT = PD.LOT)
   JOIN SKU       SKU WITH (NOLOCK) ON (PD.Storerkey = SKU.Storerkey)
                                   AND (PD.Sku = SKU.Sku)
   JOIN FACILITY F WITH (NOLOCK) ON (F.Facility = OH.Facility)
   JOIN #TMP_DECRYPTEDDATA t WITH (NOLOCK) ON (t.Orderkey = OH.Orderkey)
   LEFT JOIN CODELKUP CL WITH (NOLOCK) ON (CL.Listname = 'SephoraPKL' AND CL.Code = SKU.BUSR4 AND CL.Storerkey = OH.Storerkey)
   WHERE PH.Storerkey = @c_Storerkey
   AND PDET.LabelNo = @c_LabelNo
   AND OH.DocType = 'N'
   GROUP BY PDET.LabelNo
         , OH.Loadkey
         , ISNULL(F.Contact1,'') 
         , ISNULL(F.Address1,'') 
         , ISNULL(F.Address2,'') 
         , ISNULL(F.Address3,'') 
         , ISNULL(F.Address4,'') 
         , RIGHT(PDET.LabelNo, 7) 
         , ISNULL(PDET.UPC,'')
         , PDET.SKU
         , SKU.DESCR
         , ISNULL(SKU.SUSR2,'') 
         , CASE WHEN LEN(ISNULL(SKU.BUSR4,'')) > 10 THEN SUBSTRING(ISNULL(SKU.BUSR4,''),1,10) + ' ' + SUBSTRING(ISNULL(SKU.BUSR4,''),11,LEN(ISNULL(SKU.BUSR4,'')) - 10)
                                                    ELSE ISNULL(SKU.BUSR4,'') END
         --, PDET.Qty
         , CASE WHEN ISNULL(CL.Short,'N') = 'Y' THEN LA.Lottable03 ELSE '' END 
         , CASE WHEN ISNULL(CL.Short,'N') = 'Y' THEN LA.Lottable04 ELSE NULL END 

QUIT_SP:
   IF CURSOR_STATUS('LOCAL' , 'CUR_LOOP') in (0 , 1)
   BEGIN
      CLOSE CUR_LOOP
      DEALLOCATE CUR_LOOP   
   END

   IF OBJECT_ID('tempdb..#TMP_Externorderkey') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_Externorderkey
   END

   IF OBJECT_ID('tempdb..#TMP_DECRYPTEDDATA') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_DECRYPTEDDATA
   END

   IF @n_continue=3  -- Error Occured - Process And Return  
    BEGIN  
       SELECT @b_success = 0  
       IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_starttcnt  
       BEGIN  
          ROLLBACK TRAN  
       END  
       ELSE  
       BEGIN  
          WHILE @@TRANCOUNT > @n_starttcnt  
          BEGIN  
             COMMIT TRAN  
          END  
       END  
       execute nsp_logerror @n_err, @c_errmsg, "isp_packing_list_75_rdt"  
       RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012  
       RETURN  
    END  
    ELSE  
    BEGIN  
       SELECT @b_success = 1  
       WHILE @@TRANCOUNT > @n_starttcnt  
       BEGIN  
          COMMIT TRAN  
       END  
       RETURN  
    END
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_packing_list_75_rdt] TO nSQL 
GO