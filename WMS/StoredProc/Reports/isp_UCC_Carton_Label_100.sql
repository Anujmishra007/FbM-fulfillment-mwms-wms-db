IF EXISTS ( SELECT * FROM sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_UCC_Carton_Label_100]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[isp_UCC_Carton_Label_100]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: isp_UCC_Carton_Label_100                                */
/* Creation Date: 27-Jan-2021                                           */
/* Copyright: LF Logistics                                              */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose:  WMS-16187 - [CN] CONVERSE_UCC Label_ Change_CR             */
/*        :                                                             */
/* Called By: r_dw_ucc_carton_label_100                                 */
/*          :                                                           */
/* GitLab Version: 1.2                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/* 2021-11-16   WLChooi   1.1 WMS-18335 Add VirtualDCName & Flag (WL01) */
/* 2021-11-16   WLChooi   1.1 DevOps Combine Script                     */
/* 2021-12-07   WLChooi   1.2 WMS-18335 - Add ShowDCName Flag (WL02)    */
/************************************************************************/
CREATE PROC [dbo].[isp_UCC_Carton_Label_100]
           @c_Storerkey       NVARCHAR(15)
         , @c_PickSlipNo      NVARCHAR(10)
         , @c_StartCartonNo   NVARCHAR(10)
         , @c_EndCartonNo     NVARCHAR(10) --Could be CartonNo / NL - (Print New Layout Only)
         , @c_Type            NVARCHAR(10) = 'H'   --H,D1,D2,D3,D4
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt             INT
         , @n_Continue              INT
         
         , @n_PrintOrderAddresses   INT
         , @n_TotalQty              INT
         , @n_TotalPackedQty        INT
         , @c_Loadkey               NVARCHAR(10)
         , @c_OnlyPrintNewLayout    NVARCHAR(1) = 'N'
         , @c_ShowFlag              NVARCHAR(1) = 'Y'   --WL01
         , @c_GetPickslipno         NVARCHAR(10) = ''   --WL01
         , @n_CartonNo              INT = 0             --WL01
         , @n_CountPickzone         INT = 0             --WL01
         , @n_CountCertainPickzone  INT = 0             --WL01
         , @c_ShowDCName            NVARCHAR(10)        --WL02
         
   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1
   
   SET @n_PrintOrderAddresses = 0
   
   SELECT @n_PrintOrderAddresses = MAX(CASE WHEN Code = 'PrintOrderAddresses' THEN 1 ELSE 0 END)
   FROM CODELKUP WITH (NOLOCK)
   WHERE ListName = 'REPORTCFG'
   AND   Storerkey = @c_Storerkey
   AND   Long = 'r_dw_ucc_carton_label_100'
   AND   ISNULL(Short,'') <> 'N'
   
   SELECT @c_Loadkey = LoadKey
   FROM PACKHEADER (NOLOCK)
   WHERE PickSlipNo = @c_PickSlipNo
   
   SELECT @n_TotalQty = SUM(PD.Qty)
   FROM LOADPLANDETAIL LPD (NOLOCK)
   JOIN PICKDETAIL PD (NOLOCK) ON PD.OrderKey = LPD.OrderKey
   WHERE LPD.LoadKey = @c_Loadkey

   --WL01 S
   CREATE TABLE #TMP_DCUSER (
      Pickslipno    NVARCHAR(10)
    , CartonNo      INT
    , VirtualDCName NVARCHAR(50)
    , Flag          NVARCHAR(50)
   )

   CREATE TABLE #TMP_Pickzone (
      Loadkey       NVARCHAR(10)
    , Pickzone      NVARCHAR(20)
   )

   INSERT INTO #TMP_Pickzone(Loadkey, Pickzone)
   SELECT DISTINCT LPD.LoadKey, L.PickZone
   FROM LOADPLANDETAIL LPD (NOLOCK)
   JOIN PICKDETAIL PD (NOLOCK) ON PD.OrderKey = LPD.OrderKey
   JOIN LOC L (NOLOCK) ON L.Loc = PD.Loc
   WHERE LPD.LoadKey = @c_Loadkey

   SELECT @n_CountPickzone = COUNT(DISTINCT TP.Pickzone)
   FROM #TMP_Pickzone TP
   WHERE TP.Loadkey = @c_Loadkey

   SELECT @n_CountCertainPickzone = COUNT(DISTINCT TP.Pickzone)
   FROM #TMP_Pickzone TP
   WHERE TP.Loadkey = @c_Loadkey
   AND TP.Pickzone IN ('BS01','BS08')

   IF EXISTS (SELECT 1
              FROM #TMP_Pickzone PZ
              WHERE PZ.LoadKey = @c_Loadkey
              AND PZ.PickZone = 'BS08'
              AND @n_CountPickzone = 1)
   BEGIN
      SET @c_ShowFlag = 'N'
   END

   IF EXISTS (SELECT 1
              FROM #TMP_Pickzone PZ
              WHERE PZ.LoadKey = @c_Loadkey
              AND PZ.PickZone = 'BS01'
              AND @n_CountPickzone = 1 )
   BEGIN
      SET @c_ShowFlag = 'N'
   END

   /*
   IF EXISTS (SELECT 1
              FROM #TMP_Pickzone PZ
              WHERE PZ.LoadKey = @c_Loadkey
              AND PZ.PickZone IN ('BS08','BS01')
              AND @n_CountPickzone = 2 )
   BEGIN
      SET @c_ShowFlag = 'N'
   END
   */

   IF EXISTS (SELECT 1
              FROM #TMP_Pickzone PZ
              WHERE PZ.LoadKey = @c_Loadkey
              AND PZ.PickZone IN ('BS01','BS08')
              AND @n_CountPickzone = 2 
              AND @n_CountPickzone = @n_CountCertainPickzone)
   BEGIN
      SET @c_ShowFlag = 'N'
   END

   --WL02 S
   IF EXISTS (SELECT 1
              FROM #TMP_Pickzone PZ
              JOIN CODELKUP CL (NOLOCK) ON CL.LISTNAME = 'CONSUBDCPZ'
                                       AND CL.Code = PZ.Pickzone
                                       AND CL.Storerkey = @c_Storerkey
                                       AND CL.UDF01 = '1'
              WHERE PZ.LoadKey = @c_Loadkey) 
   BEGIN
      SET @c_ShowDCName = 'Y'
   END
   
   DECLARE CUR_LOOP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT DISTINCT PD.Pickslipno, PD.CartonNo
   FROM PACKDETAIL PD (NOLOCK)
   WHERE (PD.PickSlipNo = @c_PickSlipNo)
   AND (PD.Storerkey = @c_Storerkey)
   AND (PD.CartonNo BETWEEN @c_StartCartonNo AND @c_EndCartonNo)
   ORDER BY PD.CartonNo

   OPEN CUR_LOOP

   FETCH NEXT FROM CUR_LOOP INTO @c_GetPickslipno, @n_CartonNo

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      INSERT INTO #TMP_DCUSER (Pickslipno, CartonNo, VirtualDCName, Flag)
      SELECT @c_GetPickslipno, @n_CartonNo, ISNULL(CL.Short,''), ISNULL(CL.Long,'')
      FROM CODELKUP CL (NOLOCK)
      WHERE CL.LISTNAME = 'DCUSER'
      AND CL.Code IN (SELECT TOP 1 PD.Addwho
                      FROM PACKDETAIL PD (NOLOCK)
                      WHERE PD.PickSlipNo = @c_GetPickslipno
                      AND PD.CartonNo = @n_CartonNo)
      AND CL.Storerkey = @c_Storerkey

      FETCH NEXT FROM CUR_LOOP INTO @c_GetPickslipno, @n_CartonNo
   END
   CLOSE CUR_LOOP
   DEALLOCATE CUR_LOOP
   --WL02 E
   --WL01 E
   
   IF @c_EndCartonNo = 'NL'
   BEGIN
   	SET @c_EndCartonNo = '1'
      SET @c_OnlyPrintNewLayout = 'Y'
   END

   IF ISNULL(@c_Type,'') = ''
   BEGIN
      SET @c_Type = 'H'
   END
   
   IF @c_Type = 'H'
   BEGIN
      SELECT ExternOrderkey= MAX(ISNULL(RTRIM(ORDERS.ExternOrderkey),''))
           , ConsigneeKey  = MAX(ISNULL(RTRIM(ORDERS.ConsigneeKey),''))
           , C_Contact1    = MAX(ISNULL(RTRIM(ORDERS.C_Contact1),''))
           , C_Company     = MAX(ISNULL(RTRIM(ORDERS.C_Company),''))
           , C_Address1    = MAX(ISNULL(RTRIM(ORDERS.C_Address1),''))
           , C_Address2    = MAX(ISNULL(RTRIM(ORDERS.C_Address2),'')) 
           , C_Address3    = MAX(ISNULL(RTRIM(ORDERS.C_Address3),''))  
           , C_Address4    = MAX(ISNULL(RTRIM(ORDERS.C_Address4),'')) 
           , C_State       = MAX(ISNULL(RTRIM(ORDERS.C_State),'')) 
           , C_City        = MAX(ISNULL(RTRIM(ORDERS.C_City),'')) 
           , C_Country     = MAX(ISNULL(RTRIM(ORDERS.C_Country),'')) 
           , C_Phone1      = MAX(ISNULL(RTRIM(ORDERS.C_Phone1),'')) 
           , BillToKey     = MAX(ISNULL(RTRIM(ORDERS.BillToKey),''))
           , MarkForKey    = MAX(ISNULL(RTRIM(ORDERS.MarkForKey),'')) 
           , PACKDETAIL.PickSlipNo
           , PACKDETAIL.CartonNo
           , LabelNo       = SUBSTRING(ISNULL(LTRIM(RTRIM(PACKDETAIL.LabelNo)),''),1, LEN(ISNULL(LTRIM(RTRIM(PACKDETAIL.LabelNo)),'')) - 4)
           , Qty = SUM(PACKDETAIL.Qty)
           , CS_Storerkey  = CASE WHEN @n_PrintOrderAddresses = 1 THEN NULL ELSE STORER.Storerkey END
           , CS_Contact1   = ISNULL(RTRIM(STORER.Contact1),'') 
           , CS_Company    = ISNULL(RTRIM(STORER.Company),'') 
           , CS_Address1   = ISNULL(RTRIM(STORER.Address1),'')  
           , CS_Address2   = ISNULL(RTRIM(STORER.Address2),'')  
           , CS_Address3   = ISNULL(RTRIM(STORER.Address3),'')  
           , CS_Address4   = ISNULL(RTRIM(STORER.Address4),'')  
           , CS_State      = ISNULL(RTRIM(STORER.State),'')  
           , CS_City       = ISNULL(RTRIM(STORER.City),'')  
           , CS_Phone1     = ISNULL(RTRIM(STORER.Phone1),'')  
           , TotalCarton   = (SELECT COUNT(DISTINCT CARTONNO) FROM PACKDETAIL WITH (NOLOCK) 
                              WHERE PickSlipNo = @c_PickSlipNo)
           , CS_SUSR2      = ISNULL(RTRIM(STORER.SUSR2),'')  
           , Last4LabelNo  = RIGHT(ISNULL(LTRIM(RTRIM(PACKDETAIL.LabelNo)),''),4)
           , Loadkey       = SUBSTRING(ISNULL(LTRIM(RTRIM(PACKHEADER.LoadKey)),''),1, LEN(ISNULL(LTRIM(RTRIM(PACKHEADER.LoadKey)),'')) - 4)
           , Last4Loadkey  = RIGHT(ISNULL(LTRIM(RTRIM(PACKHEADER.LoadKey)),''),4)
           , NewLayout     = 'N'
           , VirtualDCName = CASE WHEN @c_ShowDCName = 'N' THEN '' ELSE ISNULL(TD.VirtualDCName,'') END   --WL01   --WL02
           , Flag          = CASE WHEN @c_ShowFlag = 'N' THEN '' ELSE ISNULL(TD.Flag,'')          END   --WL01
      INTO #TMP_CtnLbl100
      FROM PACKHEADER WITH (NOLOCK) 
      JOIN PACKDETAIL WITH (NOLOCK) ON (PACKHEADER.PickSlipNo = PACKDETAIL.PickSlipNo) 
      JOIN LOADPLANDETAIL LPD WITH (NOLOCK) ON LPD.Loadkey = PACKHEADER.LoadKey
      JOIN ORDERS WITH (NOLOCK) ON LPD.Orderkey = ORDERS.Orderkey
      LEFT JOIN STORER WITH (NOLOCK) ON (STORER.Storerkey =  RTRIM(ORDERS.ConsigneeKey))
      LEFT JOIN #TMP_DCUSER TD ON TD.Pickslipno = PackDetail.PickSlipNo AND TD.CartonNo = PackDetail.CartonNo   --WL01
      WHERE (PACKHEADER.PickSlipNo= @c_PickSlipNo)
         AND (PACKHEADER.Storerkey = @c_Storerkey)
         AND (PACKDETAIL.CartonNo BETWEEN @c_StartCartonNo AND @c_EndCartonNo)
      GROUP BY PACKDETAIL.PickSlipNo
             , PACKDETAIL.CartonNo
             , SUBSTRING(ISNULL(LTRIM(RTRIM(PACKDETAIL.LabelNo)),''),1, LEN(ISNULL(LTRIM(RTRIM(PACKDETAIL.LabelNo)),'')) - 4)
             , STORER.Storerkey
             , ISNULL(RTRIM(STORER.Contact1),'') 
             , ISNULL(RTRIM(STORER.Company),'') 
             , ISNULL(RTRIM(STORER.Address1),'')  
             , ISNULL(RTRIM(STORER.Address2),'')  
             , ISNULL(RTRIM(STORER.Address3),'')  
             , ISNULL(RTRIM(STORER.Address4),'')  
             , ISNULL(RTRIM(STORER.State),'')  
             , ISNULL(RTRIM(STORER.City),'')  
             , ISNULL(RTRIM(STORER.Phone1),'')  
             , ISNULL(RTRIM(STORER.SUSR2),'')  
             , RIGHT(ISNULL(LTRIM(RTRIM(PACKDETAIL.LabelNo)),''),4)
             , SUBSTRING(ISNULL(LTRIM(RTRIM(PACKHEADER.LoadKey)),''),1, LEN(ISNULL(LTRIM(RTRIM(PACKHEADER.LoadKey)),'')) - 4)
             , RIGHT(ISNULL(LTRIM(RTRIM(PACKHEADER.LoadKey)),''),4)
             , CASE WHEN @c_ShowDCName = 'N' THEN '' ELSE ISNULL(TD.VirtualDCName,'') END   --WL01   --WL02
             , CASE WHEN @c_ShowFlag = 'N' THEN '' ELSE ISNULL(TD.Flag,'') END             --WL01
             
      IF (@c_StartCartonNo <> @c_EndCartonNo) OR @c_OnlyPrintNewLayout = 'Y'
      BEGIN
         INSERT INTO #TMP_CtnLbl100
         SELECT TOP 1 ExternOrderkey
              , ConsigneeKey
              , C_Contact1  
              , C_Company   
              , C_Address1  
              , C_Address2  
              , C_Address3  
              , C_Address4  
              , C_State     
              , C_City      
              , C_Country   
              , C_Phone1    
              , BillToKey   
              , MarkForKey  
              , PickSlipNo
              , '99999'
              , ''
              , 0
              , CS_Storerkey 
              , CS_Contact1  
              , CS_Company   
              , CS_Address1  
              , CS_Address2  
              , CS_Address3  
              , CS_Address4  
              , CS_State     
              , CS_City      
              , CS_Phone1    
              , TotalCarton           
              , CS_SUSR2     
              , '' 
              , Loadkey      
              , Last4Loadkey 
              , 'Y'
              , VirtualDCName   --WL01
              , Flag            --WL01
         FROM #TMP_CtnLbl100 WITH (NOLOCK) 
      END
      
      IF @c_OnlyPrintNewLayout = 'Y'
      BEGIN
         SELECT * FROM #TMP_CtnLbl100
         WHERE NewLayout = 'Y'
      END
      ELSE
      BEGIN
         SELECT * FROM #TMP_CtnLbl100
         ORDER BY CartonNo
      END
   END

   IF @c_Type = 'D1'
   BEGIN
      SELECT PackDetail.CartonNo as Cartonno
           , SKU.Style as style
           , SKU.Color as color
           , CASE WHEN ISNULL(C.short,'')='Y' THEN 
             CASE WHEN sku.measurement IN ('','U') THEN SKU.Size ELSE ISNULL(sku.measurement,'') END
                  ELSE SKU.Size END [Size]
           , PackDetail.Qty as qty
      FROM PackDetail WITH (NOLOCK) 
      JOIN SKU WITH (NOLOCK) ON (Sku.Storerkey = PackDetail.Storerkey)  
                                AND (Sku.Sku = PackDetail.Sku)
      LEFT JOIN CODELKUP C WITH (nolock) ON C.Storerkey = PackDetail.Storerkey
                                        AND C.listname = 'REPORTCFG' and C.Code = 'GetSkuMeasurement'
                                        AND C.Long = 'r_dw_ucc_carton_label_100'
      WHERE (PackDetail.PickSlipNo = @c_PickSlipNo)
        AND (PackDetail.CartonNo = @c_StartCartonNo)
   END
   
   IF @c_Type = 'D2'
   BEGIN
      SELECT @n_TotalPackedQty = SUM(PDET.Qty)
      FROM PACKDETAIL PDET (NOLOCK)
      WHERE PDET.PickSlipNo = @c_PickSlipNo
      AND PDET.CartonNo BETWEEN 1 AND CAST(@c_StartCartonNo AS INT)
      
      --SELECT @n_TotalQty, @n_TotalPackedQty
      
      SELECT @c_StartCartonNo AS CartonNo, 
             Qty = (SELECT SUM(Qty) FROM PACKDETAIL WITH (NOLOCK) WHERE PickSlipNo = @c_PickSlipNo AND CartonNo = @c_StartCartonNo),
             COUNT(Distinct dbo.PackDetail.CartonNo) AS totalCarton,
             PackHeader.[Status],
             LastCarton = CASE WHEN @n_TotalQty = @n_TotalPackedQty THEN 'Y' ELSE 'N' END 
      FROM PackHeader WITH (NOLOCK) 
      JOIN PackDetail WITH (NOLOCK) ON dbo.Packheader.Pickslipno = dbo.Packdetail.Pickslipno
      WHERE (PackHeader.PickSlipNo = @c_PickSlipNo)
      GROUP BY PackHeader.[Status]
   END
   
   IF @c_Type = 'D3'
   BEGIN
      SELECT OH.ExternOrderkey, SUM(PD.Qty)
      FROM LoadPlanDetail LPD (NOLOCK)
      JOIN ORDERS OH (NOLOCK) ON LPD.OrderKey = OH.OrderKey
      JOIN PICKDETAIL PD (NOLOCK) ON PD.OrderKey = OH.OrderKey
      WHERE LPD.LoadKey = @c_Loadkey
      GROUP BY OH.ExternOrderKey
   END
   
   IF @c_Type = 'D4'
   BEGIN
      SELECT COUNT(DISTINCT OH.ExternOrderkey), SUM(PD.Qty)
      FROM LoadPlanDetail LPD (NOLOCK)
      JOIN ORDERS OH (NOLOCK) ON LPD.OrderKey = OH.OrderKey
      JOIN PICKDETAIL PD (NOLOCK) ON PD.OrderKey = OH.OrderKey
      WHERE LPD.LoadKey = @c_Loadkey
   END

QUIT_SP:
   --WL01 S
   IF OBJECT_ID('tempdb..#TMP_CtnLbl100') IS NOT NULL
      DROP TABLE #TMP_CtnLbl100

   IF OBJECT_ID('tempdb..#TMP_DCUSER') IS NOT NULL
      DROP TABLE #TMP_DCUSER
   
   IF CURSOR_STATUS('LOCAL', 'CUR_LOOP') IN (0 , 1)
   BEGIN
      CLOSE CUR_LOOP
      DEALLOCATE CUR_LOOP   
   END
   --WL01 E
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_UCC_Carton_Label_100] TO nSQL 
GO
