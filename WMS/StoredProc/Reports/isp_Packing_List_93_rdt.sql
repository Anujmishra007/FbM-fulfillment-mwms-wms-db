IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[isp_Packing_List_93_rdt]') AND type in (N'P', N'PC'))
   DROP PROCEDURE [dbo].[isp_Packing_List_93_rdt]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Stored Proc: isp_Packing_List_93_rdt                                 */  
/* Creation Date: 12-Dec-2020                                           */  
/* Copyright: LF Logistics                                              */  
/* Written by: WLChooi                                                  */  
/*                                                                      */  
/* Purpose: WMS-15848 - VF Packing List                                 */  
/*        :                                                             */  
/* Called By: r_dw_packing_list_93_rdt                                  */  
/*          :                                                           */  
/* GitLab Version: 1.1                                                  */  
/*                                                                      */  
/* Version: 7.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author    Ver Purposes                                  */ 
/* 2021-01-28   WLChooi   1.1 Do not join Packdetail to get Qty, use    */
/*                            SUM(PICKDETAIL.Qty) instead (WL01)        */
/************************************************************************/  
CREATE PROC [dbo].[isp_Packing_List_93_rdt]
            @c_Pickslipno    NVARCHAR(15),      --Could be Storerkey/Pickslipno/Orderkey
            @c_Orderkey      NVARCHAR(10) = ''  --Could be Orderkey
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

   SET @n_StartTCnt = @@TRANCOUNT  
   SET @n_Continue  = 1  
   SET @b_Success   = 1  
   SET @n_Err       = 0  
   SET @c_Errmsg    = '' 

   IF ISNULL(@c_Orderkey,'') = '' SET @c_Orderkey = ''
   
   CREATE TABLE #TMP_Orders (
   	Orderkey   NVARCHAR(10)
   )
   
   IF EXISTS (SELECT 1 FROM PACKHEADER (NOLOCK) WHERE Pickslipno = @c_Pickslipno AND @c_Pickslipno <> '')
   BEGIN
      INSERT INTO #TMP_Orders (Orderkey)
      SELECT Orderkey 
      FROM PACKHEADER (NOLOCK)
      WHERE PickSlipNo = @c_Pickslipno
   END   
   ELSE IF EXISTS (SELECT 1 FROM ORDERS (NOLOCK) WHERE Orderkey = @c_Pickslipno AND @c_Pickslipno <> '')
   BEGIN
      INSERT INTO #TMP_Orders (Orderkey)
      SELECT @c_Pickslipno
   END
   ELSE
   BEGIN
   	INSERT INTO #TMP_Orders (Orderkey)
      SELECT Orderkey
      FROM ORDERS (NOLOCK)
      WHERE Storerkey = @c_Pickslipno 
      AND OrderKey = @c_Orderkey
   END
   
   SELECT ISNULL(OH.Externorderkey,'') AS Externorderkey
        , ISNULL(OH.M_Company,'') AS M_Company
        , LTRIM(RTRIM(ISNULL(OH.C_Contact1,''''))) + ' ' + LTRIM(RTRIM(ISNULL(OH.C_Contact2,''''))) AS C_Contact
        , LTRIM(RTRIM(ISNULL(OH.C_Address2,''''))) + ' ' + LTRIM(RTRIM(ISNULL(OH.C_Address3,''''))) + ' ' + LTRIM(RTRIM(ISNULL(OH.C_Address4,''''))) AS C_Addresses
        , OH.C_Phone1
        , ISNULL(OH.Salesman,'') AS Salesman
        , OH.Shipperkey
        , S.ALTSKU
        , PID.LOC
        , SUM(PID.QTY) AS Qty   --WL01 Use PICKDETAIL.Qty Instead
        , S.SKU
        , PH.PickSlipNo
        , OH.OrderKey
        , ISNULL(CL.Long,'') AS QRCode
   FROM ORDERS OH (NOLOCK)
   JOIN PACKHEADER PH (NOLOCK) ON OH.OrderKey = PH.OrderKey
   --JOIN PACKDETAIL PD (NOLOCK) ON PH.Pickslipno = PD.PickSlipNo                      --WL01
   --JOIN PICKDETAIL PID (NOLOCK) ON PID.OrderKey = OH.OrderKey AND PID.SKU = PD.SKU   --WL01
   JOIN PICKDETAIL PID (NOLOCK) ON PID.OrderKey = OH.OrderKey                          --WL01
   JOIN SKU S (NOLOCK) ON S.SKU = PID.SKU AND S.StorerKey = OH.StorerKey
   JOIN #TMP_Orders t ON t.Orderkey = OH.Orderkey
   LEFT JOIN CODELKUP CL (NOLOCK) ON CL.Listname = 'TNFQRCode' AND CL.Code = OH.Salesman
                                 AND CL.Storerkey = OH.StorerKey
   WHERE OH.UserDefine01 = 'VC30'
   AND OH.DocType = 'E'
   --WL01 S
   GROUP BY ISNULL(OH.Externorderkey,'')
          , ISNULL(OH.M_Company,'')
          , LTRIM(RTRIM(ISNULL(OH.C_Contact1,''''))) + ' ' + LTRIM(RTRIM(ISNULL(OH.C_Contact2,'''')))
          , LTRIM(RTRIM(ISNULL(OH.C_Address2,''''))) + ' ' + LTRIM(RTRIM(ISNULL(OH.C_Address3,''''))) + ' ' + LTRIM(RTRIM(ISNULL(OH.C_Address4,'''')))
          , OH.C_Phone1
          , ISNULL(OH.Salesman,'')
          , OH.Shipperkey
          , S.ALTSKU
          , PID.LOC
          , S.SKU
          , PH.PickSlipNo
          , OH.OrderKey
          , ISNULL(CL.Long,'')
   --WL01 E

QUIT_SP:  
   IF OBJECT_ID('tempdb..#TMP_Orders') IS NOT NULL
      DROP TABLE #TMP_Orders
END -- procedure
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

GRANT EXECUTE ON [dbo].[isp_Packing_List_93_rdt] TO nSQL 
GO
