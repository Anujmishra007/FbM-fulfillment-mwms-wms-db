IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[isp_r_hk_carton_label_08]') AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
   DROP PROCEDURE [dbo].[isp_r_hk_carton_label_08]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/*************************************************************************/
/* Stored Procedure: isp_r_hk_carton_label_08                            */
/* Creation Date: 24-May-2019                                            */
/* Copyright: LFL                                                        */
/* Written by: Michael Lam (HK LIT)                                      */
/*                                                                       */
/* Purpose: L'Oreal Carton Label                                         */
/*                                                                       */
/* Called By: Report Module. Datawidnow r_hk_carton_label_08             */
/*                                                                       */
/* PVCS Version: 1.0                                                     */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date         Author   Ver  Purposes                                   */
/*************************************************************************/

CREATE PROCEDURE [dbo].[isp_r_hk_carton_label_08] (
       @as_PickSlipNo         NVARCHAR(40)
     , @as_StartCartonNo      NVARCHAR(40)
     , @as_EndCartonNo        NVARCHAR(40)
     , @as_StartLabelNo       NVARCHAR(40)
     , @as_EndLabelNo         NVARCHAR(40)
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_DataWidnow      NVARCHAR(40)
         , @c_JobName         NVARCHAR(50)
         , @c_PickslipNo      NVARCHAR(10)
         , @n_CartonNo        INT
         , @c_LabelNo         NVARCHAR(20)
         , @c_Orderkey        NVARCHAR(10)
         , @c_ExternOrderkey  NVARCHAR(30)
         , @c_Storerkey       NVARCHAR(15)
         , @n_JobID           INT
         , @n_ErrNo           INT
         , @n_StartTCnt       INT

   SELECT @c_DataWidnow = 'r_hk_carton_label_08'
        , @n_StartTCnt  = @@TRANCOUNT
        , @c_JobName    = OBJECT_NAME(@@procid)

   IF OBJECT_ID('tempdb..#TEMP_PACKDETAIL') IS NOT NULL
      DROP TABLE #TEMP_PACKDETAIL


   SELECT PickSlipNo     = RTRIM( ORD.PickSlipNo )
        , Storerkey      = RTRIM( ORD.Storerkey )
        , Company        = RTRIM( ORD.Company )
        , Div            = CASE WHEN ORD.ConsolPick='N' AND ORD.Div IN (SELECT DISTINCT Long FROM dbo.CODELKUP WHERE Listname='LORBRAND' AND Storerkey=ORD.Storerkey AND Long<>'')
                                THEN ORD.Div ELSE '' END
        , Orderkey       = RTRIM( ORD.Orderkey )
        , ExternOrderKey = RTRIM( ORD.ExternOrderKey )
        , Consigneekey   = RTRIM( ORD.Consigneekey )
        , C_company      = RTRIM( ORD.C_company )
        , C_Address1     = RTRIM( ORD.C_Address1 )
        , C_Address2     = RTRIM( ORD.C_Address2 )
        , C_Address3     = RTRIM( ORD.C_Address3 )
        , C_Address4     = RTRIM( ORD.C_Address4 )
        , Notes2         = RTRIM( ORD.Notes2 )
        , Route          = RTRIM( ORD.Route )
        , Userdefine09   = RTRIM( ORD.Userdefine09 )
        , Deliverydate   = ORD.Deliverydate
        , ContainerQty   = ORD.ContainerQty
        , LabelNo        = RTRIM( PAK.LabelNo )
        , CartonNo       = PAK.CartonNo
        , SUSR3          = RTRIM( ORD.SUSR3 )
        , TotalCarton    = PAK.TotalCarton
        , Qty            = PAK.Qty
        , ConsolPick     = RTRIM( ORD.ConsolPick )
        , Storer_Logo    = RTRIM( RL.Notes )
   INTO #TEMP_PACKDETAIL
   FROM
   (
      SELECT PickSlipNo     = PIKHD.PickheaderKey
           , Storerkey      = OH.Storerkey
           , Company        = ST.Company
           , Div            = LEFT(OH.Notes,3)
           , Orderkey       = OH.Orderkey
           , ExternOrderKey = CASE WHEN PIKHD.ConsolPick='Y' THEN OH.Loadkey ELSE OH.ExternOrderKey END
           , Consigneekey   = OH.Consigneekey
           , C_Company      = OH.C_Company
           , C_Address1     = OH.C_Address1
           , C_Address2     = OH.C_Address2
           , C_Address3     = OH.C_Address3
           , C_Address4     = OH.C_Address4
           , Notes2         = OH.Notes2
           , Route          = OH.Route
           , Userdefine09   = OH.Userdefine09
           , Deliverydate   = OH.Deliverydate
           , ContainerQty   = OH.ContainerQty
           , SUSR3          = ST2.SUSR3
           , ConsolPick     = PIKHD.ConsolPick
           , SeqNo          = ROW_NUMBER() OVER(PARTITION BY PIKHD.PickheaderKey ORDER BY OH.Orderkey)
        FROM (
           SELECT DISTINCT
                  PickheaderKey = PH.PickheaderKey
                , ConsolPick    = CASE WHEN OH2.Orderkey IS NOT NULL THEN 'Y' ELSE 'N' END
                , Orderkey      = ISNULL(OH1.Orderkey, OH2.Orderkey)
           FROM dbo.PICKHEADER   PH(NOLOCK)
           LEFT JOIN dbo.ORDERS OH1(NOLOCK) ON (PH.Orderkey = OH1.Orderkey AND PH.Orderkey<>'')
           LEFT JOIN dbo.ORDERS OH2(NOLOCK) ON (PH.ExternOrderkey = OH2.Loadkey AND PH.ExternOrderkey<>'' AND ISNULL(PH.Orderkey,'')='')
           WHERE PH.PickheaderKey<>''
             AND PH.PickheaderKey = @as_PickSlipNo
             AND ISNULL(ISNULL(OH1.Orderkey, OH2.Orderkey),'')<>''
        ) PIKHD
        JOIN dbo.ORDERS OH(NOLOCK) ON PIKHD.Orderkey = OH.Orderkey
        JOIN STORER ST (NOLOCK) ON ST.Storerkey = OH.Storerkey
        LEFT OUTER JOIN STORER ST2(NOLOCK) ON ST2.Storerkey = OH.ConsigneeKey
   ) ORD
   JOIN (
      SELECT PickSlipNo     = PD.PickSlipNo
           , CartonNo       = PD.CartonNo
           , LabelNo        = PD.LabelNo
           , TotalCarton    = (SELECT ISNULL(MAX(P2.CartonNo), '')
                               FROM PACKDETAIL P2 (NOLOCK)
                               WHERE P2.PickSlipNo = PD.PickSlipNo
                               HAVING SUM(P2.Qty) >=
                                     (SELECT SUM(c.Qty)
                                      FROM ORDERS a(NOLOCK)
                                      JOIN PICKHEADER b(NOLOCK) ON ( (a.Orderkey = b.Orderkey AND b.Orderkey<>'')
                                                                  OR (a.Loadkey = b.ExternOrderkey AND a.Loadkey<>'' AND ISNULL(b.Orderkey,'')='') )
                                      JOIN PICKDETAIL c(NOLOCK) ON a.Orderkey = c.Orderkey
                                      WHERE b.Pickheaderkey = PD.PickSlipNo) )
           , Qty            = SUM( PD.Qty)
        FROM dbo.PACKDETAIL PD (NOLOCK)
       WHERE PD.PickSlipNo<>''
         AND PD.PickSlipNo = @as_PickSlipNo
         AND PD.CartonNo >= CAST(@as_StartCartonNo AS INT)
         AND PD.CartonNo <= CAST(@as_EndCartonNo AS INT)
         AND PD.LabelNo >= @as_StartLabelNo
         AND PD.LabelNo <= @as_EndLabelNo
       GROUP BY PD.PickSlipNo
              , PD.CartonNo
              , PD.LabelNo
   ) PAK
   ON ORD.PickSlipNo = PAK.PickSlipNo AND ORD.SeqNo = 1

   LEFT JOIN dbo.CODELKUP RL (NOLOCK) ON RL.Listname = 'RPTLOGO' AND RL.Code='LOGO' AND RL.Storerkey = ORD.Storerkey AND RL.Long = @c_DataWidnow


   IF @@ROWCOUNT > 0 AND ISNULL(@c_JobName,'')<>''
   BEGIN
      DECLARE C_PRINTLOG CURSOR FAST_FORWARD READ_ONLY FOR
       SELECT DISTINCT a.PickslipNo, a.CartonNo, a.LabelNo, a.Orderkey, a.ExternOrderkey, a.Storerkey
         FROM #TEMP_PACKDETAIL a
         JOIN (
            SELECT Storerkey, ShowFields = LTRIM(RTRIM(UDF01)) + LOWER(LTRIM(RTRIM(Notes))) + LTRIM(RTRIM(UDF01))
                 , SeqNo=ROW_NUMBER() OVER(PARTITION BY Storerkey ORDER BY Code2)
              FROM dbo.CodeLkup (NOLOCK) WHERE Listname='REPORTCFG' AND Code='SHOWFIELD' AND Long=@c_DataWidnow AND Short='Y'
         ) RptCfg
         ON RptCfg.Storerkey=a.Storerkey AND RptCfg.SeqNo=1
        WHERE RptCfg.ShowFields LIKE '%,GenPrintLog,%'
        ORDER BY PickslipNo, CartonNo

      OPEN C_PRINTLOG

      WHILE 1=1
      BEGIN
         FETCH NEXT FROM C_PRINTLOG
          INTO @c_PickslipNo, @n_CartonNo, @c_LabelNo, @c_Orderkey, @c_ExternOrderkey, @c_Storerkey

         IF @@FETCH_STATUS<>0
            BREAK

         INSERT INTO rdt.rdtPrintJob (
             JobName, ReportID, JobStatus, Datawindow, NoOfParms, Printer, NoOfCopy, Mobile, TargetDB, PrintData, JobType, StorerKey,
             Parm1, Parm2, Parm3, Parm4, Parm5, Parm6, Parm7, Parm8, Parm9, Parm10)
         VALUES(
             @c_JobName, 'UCCLABEL', '9', @c_DataWidnow, 0, '', 0, 0, DB_NAME(), '', '', @c_StorerKey,
             @c_PickslipNo, ISNULL(CONVERT(NVARCHAR(10),@n_CartonNo),''), @c_LabelNo, @c_Orderkey, @c_ExternOrderkey, '', '', '', '', ''
         )

         SELECT @n_JobID = SCOPE_IDENTITY(), @n_ErrNo = @@ERROR

         IF @n_ErrNo = 0
         BEGIN
            EXEC isp_UpdateRDTPrintJobStatus @n_JobID, '9', ''
         END
      END

      CLOSE C_PRINTLOG
      DEALLOCATE C_PRINTLOG
   END

   SELECT PickSlipNo
        , Storerkey
        , Company
        , Div
        , Orderkey
        , ExternOrderKey
        , Consigneekey
        , C_company
        , C_Address1
        , C_Address2
        , C_Address3
        , C_Address4
        , Notes2
        , Route
        , Userdefine09
        , Deliverydate
        , ContainerQty
        , LabelNo
        , CartonNo
        , SUSR3
        , TotalCarton
        , Qty
        , ConsolPick
        , Storer_Logo
     FROM #TEMP_PACKDETAIL
    ORDER BY PickslipNo, CartonNo


   WHILE @@TRANCOUNT > @n_StartTCnt
      COMMIT TRAN
   WHILE @@TRANCOUNT < @n_StartTCnt
      BEGIN TRAN
END
GO
GRANT EXECUTE ON isp_r_hk_carton_label_08 TO NSQL
GO