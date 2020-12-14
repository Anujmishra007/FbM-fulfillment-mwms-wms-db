IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[isp_PackListBySku18_rdt]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[isp_PackListBySku18_rdt]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Proc: isp_PackListBySku18_rdt                                 */
/* Creation Date: 07-Dec-2020                                           */
/* Copyright: LF Logistics                                              */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: WMS-15806 - SKE Packing List                                */
/*        :                                                             */
/* Called By: r_dw_packing_list_by_sku18_rdt                            */
/*          :                                                           */
/* GitLab Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/************************************************************************/
CREATE PROC [dbo].[isp_PackListBySku18_rdt]
            @c_Pickslipno NVARCHAR(10),
            @c_Type       NVARCHAR(10) = 'H'
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt       INT
         , @n_Continue        INT 
         , @n_Err             INT = 0
         , @c_ErrMsg          NVARCHAR(255) = ''
         , @b_success         INT = 1
   
   IF ISNULL(@c_Type,'') = '' SET @c_Type = 'H'
   
   IF @c_Type = 'H'
   BEGIN
      SELECT @c_Pickslipno, '1'
      UNION ALL
      SELECT @c_Pickslipno, '2'
      GOTO QUIT_SP
   END

   SELECT LTRIM(RTRIM(ISNULL(OH.C_Company,''))) AS C_Company
        , LTRIM(RTRIM(ISNULL(OH.C_City,''))) AS C_City
        , LTRIM(RTRIM(ISNULL(OH.C_Address1,''))) + LTRIM(RTRIM(ISNULL(OH.C_Address2,''))) +
          LTRIM(RTRIM(ISNULL(OH.C_Address3,''))) + LTRIM(RTRIM(ISNULL(OH.C_Address4,''))) AS C_Addresses
        , LTRIM(RTRIM(ISNULL(OH.C_Contact1,''))) AS C_Contact1
        , LTRIM(RTRIM(ISNULL(OH.C_Phone1,''))) AS C_Phone1
        , OH.ExternOrderKey
        , OH.LoadKey
        , PD.CartonNo
        , PD.SKU
        , ISNULL(S.DESCR,'') AS DESCR
        , ISNULL(S.Style,'') AS Style
        , ISNULL(S.Size,'')  AS Size
        , ISNULL(S.Color,'') AS Color
        , ISNULL(S.BUSR9,'') AS BUSR9
        , SUM(PD.Qty) AS Qty
        , P.PackUOM3
        , @c_Pickslipno AS Pickslipno 
   INTO #TMP_SKU18
   FROM PACKHEADER PH (NOLOCK)
   JOIN PACKDETAIL PD (NOLOCK) ON PH.Pickslipno = PD.PickSlipNo
   JOIN LoadPlanDetail LPD (NOLOCK) ON LPD.LoadKey = PH.LoadKey
   JOIN ORDERS OH (NOLOCK) ON OH.OrderKey = LPD.OrderKey
   JOIN SKU S (NOLOCK) ON S.Sku = PD.SKU AND S.StorerKey = PD.StorerKey
   JOIN PACK P (NOLOCK) ON P.PackKey = S.PACKKey
   WHERE PH.Pickslipno = @c_Pickslipno
   AND OH.DocType = 'N'
   GROUP BY LTRIM(RTRIM(ISNULL(OH.C_Company,'')))
          , LTRIM(RTRIM(ISNULL(OH.C_City,'')))
          , LTRIM(RTRIM(ISNULL(OH.C_Address1,''))) + LTRIM(RTRIM(ISNULL(OH.C_Address2,''))) +
            LTRIM(RTRIM(ISNULL(OH.C_Address3,''))) + LTRIM(RTRIM(ISNULL(OH.C_Address4,'')))
          , LTRIM(RTRIM(ISNULL(OH.C_Contact1,'')))
          , LTRIM(RTRIM(ISNULL(OH.C_Phone1,'')))
          , OH.ExternOrderKey
          , OH.LoadKey
          , PD.CartonNo
          , PD.SKU
          , ISNULL(S.DESCR,'')
          , ISNULL(S.Style,'')
          , ISNULL(S.Size,'') 
          , ISNULL(S.Color,'')
          , ISNULL(S.BUSR9,'')
          , P.PackUOM3
          
   IF @c_Type = 'H1'
   BEGIN
   	SELECT *
   	FROM #TMP_SKU18
   	ORDER BY Style, CartonNo
             , SKU, Size
             , Color, BUSR9
   END
   ELSE
   BEGIN
   	SELECT *
   	FROM #TMP_SKU18
   	ORDER BY CartonNo, SKU
             , Style, Size
             , Color, BUSR9
   END

QUIT_SP:
   IF OBJECT_ID('tempdb..#TMP_SKU18') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_SKU18
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
       execute nsp_logerror @n_err, @c_errmsg, "isp_PackListBySku18_rdt"  
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
GRANT EXECUTE ON [dbo].[isp_PackListBySku18_rdt] TO nSQL 
GO