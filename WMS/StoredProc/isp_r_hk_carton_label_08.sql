if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_r_hk_carton_label_08]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[isp_r_hk_carton_label_08]
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
/* 03/08/2020   Michael  1.1  Handle print from RDT                      */
/* 02/09/2021   Michael  1.2  WMS-17862 - LEGO HK CR                     */
/*                            Convert to Dynamic SQL                     */
/*************************************************************************/

CREATE PROCEDURE [dbo].[isp_r_hk_carton_label_08] (
       @as_PickSlipNo         NVARCHAR(40)
     , @as_StartCartonNo      NVARCHAR(40)
     , @as_EndCartonNo        NVARCHAR(40)
     , @as_StartLabelNo       NVARCHAR(40) = ''
     , @as_EndLabelNo         NVARCHAR(40) = ''
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

/* CODELKUP.REPORTCFG
   [MAPFIELD]
      ExternOrderKey, Company, Div, Consigneekey, C_Company, C_Address1, C_Address2, C_Address3, C_Address4, Notes2
      Route, Wavekey, Deliverydate, ContainerQty, LabelNo, StorerLogo, StoreNo, Qty
      T_Dock, T_Div, T_ExternOrderkey, T_ShipTo, T_Remark, T_Route, T_Wavekey, T_DeliveryOn, T_Carton, T_StoreNo

   [MAPVALUE]

   [SHOWFIELD]
      GenPrintLog

   [SQLJOIN]
*/
   DECLARE @c_DataWindow          NVARCHAR(40) = 'r_hk_carton_label_08'
         , @c_JobName             NVARCHAR(50) = OBJECT_NAME(@@procid)
         , @n_StartTCnt           INT          = @@TRANCOUNT
         , @n_CartonNoFrom        INT          = ISNULL( IIF(ISNULL(@as_StartCartonNo,'')='', 0, TRY_PARSE(@as_StartCartonNo AS FLOAT)), 0 )
         , @n_CartonNoTo          INT          = ISNULL( IIF(ISNULL(@as_EndCartonNo  ,'')='', 0, TRY_PARSE(@as_EndCartonNo   AS FLOAT)), 0 )
         , @c_PickslipNo          NVARCHAR(20)
         , @n_CartonNo            INT
         , @c_LabelNo             NVARCHAR(50)
         , @c_Orderkey            NVARCHAR(10)
         , @c_ExternOrderkey      NVARCHAR(50)
         , @c_Storerkey           NVARCHAR(15)
         , @n_JobID               INT
         , @n_ErrNo               INT
         , @c_ExternOrderKeyExp   NVARCHAR(MAX)
         , @c_CompanyExp          NVARCHAR(MAX)
         , @c_DivExp              NVARCHAR(MAX)
         , @c_ConsigneekeyExp     NVARCHAR(MAX)
         , @c_C_CompanyExp        NVARCHAR(MAX)
         , @c_C_Address1Exp       NVARCHAR(MAX)
         , @c_C_Address2Exp       NVARCHAR(MAX)
         , @c_C_Address3Exp       NVARCHAR(MAX)
         , @c_C_Address4Exp       NVARCHAR(MAX)
         , @c_Notes2Exp           NVARCHAR(MAX)
         , @c_RouteExp            NVARCHAR(MAX)
         , @c_WavekeyExp          NVARCHAR(MAX)
         , @c_DeliverydateExp     NVARCHAR(MAX)
         , @c_ContainerQtyExp     NVARCHAR(MAX)
         , @c_LabelNoExp          NVARCHAR(MAX)
         , @c_StorerLogoExp       NVARCHAR(MAX)
         , @c_StoreNoExp          NVARCHAR(MAX)
         , @c_QtyExp              NVARCHAR(MAX)
         , @c_T_DockExp           NVARCHAR(MAX)
         , @c_T_DivExp            NVARCHAR(MAX)
         , @c_T_ExternOrderkeyExp NVARCHAR(MAX)
         , @c_T_ShipToExp         NVARCHAR(MAX)
         , @c_T_RemarkExp         NVARCHAR(MAX)
         , @c_T_RouteExp          NVARCHAR(MAX)
         , @c_T_WavekeyExp        NVARCHAR(MAX)
         , @c_T_DeliveryOnExp     NVARCHAR(MAX)
         , @c_T_CartonExp         NVARCHAR(MAX)
         , @c_T_StoreNoExp        NVARCHAR(MAX)
         , @c_ExecStatements      NVARCHAR(MAX)
         , @c_ExecArguments       NVARCHAR(MAX)
         , @c_JoinClause          NVARCHAR(MAX)


   IF OBJECT_ID('tempdb..#TEMP_PAKDT') IS NOT NULL
      DROP TABLE #TEMP_PAKDT

   CREATE TABLE #TEMP_PAKDT (
        PickSlipNo       NVARCHAR(20)
      , Storerkey        NVARCHAR(15)
      , Orderkey         NVARCHAR(10)
      , ExternOrderKey   NVARCHAR(50)
      , Company          NVARCHAR(50)
      , Div              NVARCHAR(50)
      , Consigneekey     NVARCHAR(50)
      , C_company        NVARCHAR(500)
      , C_Address1       NVARCHAR(500)
      , C_Address2       NVARCHAR(500)
      , C_Address3       NVARCHAR(500)
      , C_Address4       NVARCHAR(500)
      , Notes2           NVARCHAR(500)
      , Route            NVARCHAR(50)
      , Wavekey          NVARCHAR(50)
      , Deliverydate     DATETIME
      , ContainerQty     INT
      , LabelNo          NVARCHAR(50)
      , Storer_Logo      NVARCHAR(50)
      , StoreNo          NVARCHAR(50)
      , Qty              INT
      , CartonNo         INT
      , TotalCarton      INT
      , ConsolPick       NVARCHAR(1)
      , T_Dock           NVARCHAR(50)
      , T_Div            NVARCHAR(50)
      , T_ExternOrderkey NVARCHAR(50)
      , T_ShipTo         NVARCHAR(50)
      , T_Remark         NVARCHAR(50)
      , T_Route          NVARCHAR(50)
      , T_Wavekey        NVARCHAR(50)
      , T_DeliveryOn     NVARCHAR(50)
      , T_Carton         NVARCHAR(50)
      , T_StoreNo        NVARCHAR(50)
   )

   -- Final Orderkey
   CREATE TABLE #TEMP_FINALORDERKEY (
        PickslipNo       NVARCHAR(10)
      , Orderkey         NVARCHAR(10)
      , Loadkey          NVARCHAR(10)
      , ConsolPick       NVARCHAR(1)
      , Storerkey        NVARCHAR(15)
      , TotPikQty        INT
      , TotPakQty        INT
      , CartonMax        INT
   )
   SELECT *
     INTO #TEMP_FINALORDERKEY2
     FROM #TEMP_FINALORDERKEY
    WHERE 1=2

   INSERT INTO #TEMP_FINALORDERKEY(Orderkey, PickslipNo, Loadkey, ConsolPick, Storerkey)
   SELECT OH.Orderkey
        , PH.PickslipNo
        , OH.Loadkey
        , 'N'
        , OH.Storerkey
     FROM dbo.PACKHEADER PH (NOLOCK)
     JOIN dbo.ORDERS     OH (NOLOCK) ON PH.Orderkey = OH.Orderkey AND ISNULL(PH.Orderkey,'')<>''
    WHERE PH.PickSlipNo = @as_PickSlipNo

   INSERT INTO #TEMP_FINALORDERKEY(Orderkey, PickslipNo, Loadkey, ConsolPick, Storerkey)
   SELECT OH.Orderkey
        , PH.PickslipNo
        , OH.Loadkey
        , 'Y'
        , OH.Storerkey
     FROM dbo.PACKHEADER PH (NOLOCK)
     JOIN dbo.ORDERS     OH (NOLOCK) ON PH.Loadkey = OH.Loadkey AND ISNULL(PH.Loadkey,'')<>'' AND ISNULL(PH.Orderkey,'')=''
     LEFT JOIN #TEMP_FINALORDERKEY FOK ON PH.PickslipNo = FOK.PickslipNo
    WHERE PH.PickSlipNo = @as_PickSlipNo
      AND FOK.Orderkey IS NULL


   UPDATE FOK
      SET TotPikQty     = PIK.TotPikQty
     FROM #TEMP_FINALORDERKEY FOK
     JOIN (
        SELECT DISTINCT
               PickslipNo    = FOK.PickslipNo
             , TotPikQty     = SUM(PD.Qty)
          FROM #TEMP_FINALORDERKEY FOK
          JOIN dbo.PICKDETAIL      PD (NOLOCK) ON FOK.Orderkey = PD.Orderkey
         GROUP BY FOK.PickslipNo
     ) PIK ON FOK.PickslipNo = PIK.PickslipNo


    INSERT INTO #TEMP_FINALORDERKEY2 (PickslipNo, Orderkey, Loadkey, ConsolPick, Storerkey, TotPikQty, TotPakQty, CartonMax)
    SELECT DISTINCT
           PickslipNo        = FOK.PickslipNo
         , Orderkey          = FIRST_VALUE(FOK.Orderkey)   OVER(PARTITION BY FOK.PickslipNo ORDER BY FOK.Orderkey)
         , Loadkey           = FIRST_VALUE(FOK.Loadkey)    OVER(PARTITION BY FOK.PickslipNo ORDER BY FOK.Orderkey)
         , ConsolPick        = FIRST_VALUE(FOK.ConsolPick) OVER(PARTITION BY FOK.PickslipNo ORDER BY FOK.Orderkey)
         , Storerkey         = FIRST_VALUE(FOK.Storerkey)  OVER(PARTITION BY FOK.PickslipNo ORDER BY FOK.Orderkey)
         , TotPikQty         = FIRST_VALUE(FOK.TotPikQty)  OVER(PARTITION BY FOK.PickslipNo ORDER BY FOK.Orderkey)
         , TotPakQty         = 0
         , CartonMax         = 0
      FROM #TEMP_FINALORDERKEY FOK


   UPDATE FOK
      SET TotPakQty     = PAK.TotPakQty
        , CartonMax     = CASE WHEN PAK.TotPakQty>=FOK.TotPikQty THEN PAK.CartonMax END
     FROM #TEMP_FINALORDERKEY2 FOK
     JOIN (
        SELECT DISTINCT
               PickslipNo    = FOK.PickslipNo
             , TotPakQty     = SUM(PD.Qty)
             , CartonMax     = MAX(PD.CartonNo)
          FROM #TEMP_FINALORDERKEY2 FOK
          JOIN dbo.PACKDETAIL       PD (NOLOCK) ON FOK.PickslipNo = PD.PickslipNo
         GROUP BY FOK.PickslipNo
     ) PAK ON FOK.PickslipNo = PAK.PickslipNo



   -- Storerkey Loop
   DECLARE CUR_STORERKEY CURSOR FAST_FORWARD READ_ONLY FOR
   SELECT DISTINCT Storerkey
     FROM #TEMP_FINALORDERKEY2
    ORDER BY 1

   OPEN CUR_STORERKEY

   WHILE 1=1
   BEGIN
      FETCH NEXT FROM CUR_STORERKEY
       INTO @c_Storerkey

      IF @@FETCH_STATUS<>0
         BREAK

      SELECT @c_ExternOrderKeyExp   = ''
           , @c_CompanyExp          = ''
           , @c_DivExp              = ''
           , @c_ConsigneekeyExp     = ''
           , @c_C_CompanyExp        = ''
           , @c_C_Address1Exp       = ''
           , @c_C_Address2Exp       = ''
           , @c_C_Address3Exp       = ''
           , @c_C_Address4Exp       = ''
           , @c_Notes2Exp           = ''
           , @c_RouteExp            = ''
           , @c_WavekeyExp          = ''
           , @c_DeliverydateExp     = ''
           , @c_ContainerQtyExp     = ''
           , @c_LabelNoExp          = ''
           , @c_StorerLogoExp       = ''
           , @c_StoreNoExp          = ''
           , @c_QtyExp              = ''
           , @c_T_DockExp           = ''
           , @c_T_DivExp            = ''
           , @c_T_ExternOrderkeyExp = ''
           , @c_T_ShipToExp         = ''
           , @c_T_RemarkExp         = ''
           , @c_T_RouteExp          = ''
           , @c_T_WavekeyExp        = ''
           , @c_T_DeliveryOnExp     = ''
           , @c_T_CartonExp         = ''
           , @c_T_StoreNoExp        = ''
           , @c_JoinClause          = ''

      SELECT TOP 1
             @c_JoinClause  = Notes
        FROM dbo.CodeLkup (NOLOCK)
       WHERE Listname='REPORTCFG' AND Code='SQLJOIN' AND Long=@c_DataWindow AND Short='Y'
         AND Storerkey = @c_Storerkey
       ORDER BY Code2

      SELECT TOP 1
             @c_ExternOrderKeyExp   = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='ExternOrderKey')), '' )
           , @c_CompanyExp          = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='Company')), '' )
           , @c_DivExp              = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='Div')), '' )
           , @c_ConsigneekeyExp     = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='Consigneekey')), '' )
           , @c_C_CompanyExp        = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='C_Company')), '' )
           , @c_C_Address1Exp       = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='C_Address1')), '' )
           , @c_C_Address2Exp       = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='C_Address2')), '' )
           , @c_C_Address3Exp       = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='C_Address3')), '' )
           , @c_C_Address4Exp       = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='C_Address4')), '' )
           , @c_Notes2Exp           = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='Notes2')), '' )
           , @c_RouteExp            = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='Route')), '' )
           , @c_WavekeyExp          = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='Wavekey')), '' )
           , @c_DeliverydateExp     = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='Deliverydate')), '' )
           , @c_ContainerQtyExp     = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='ContainerQty')), '' )
           , @c_LabelNoExp          = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='LabelNo')), '' )
           , @c_StorerLogoExp       = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='StorerLogo')), '' )
           , @c_StoreNoExp          = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='StoreNo')), '' )
           , @c_QtyExp              = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='Qty')), '' )
           , @c_T_DockExp           = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='T_Dock')), '' )
           , @c_T_DivExp            = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='T_Div')), '' )
           , @c_T_ExternOrderkeyExp = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='T_ExternOrderKey')), '' )
           , @c_T_ShipToExp         = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='T_ShipTo')), '' )
           , @c_T_RemarkExp         = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='T_Remark')), '' )
           , @c_T_RouteExp          = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='T_Route')), '' )
           , @c_T_WavekeyExp        = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='T_Wavekey')), '' )
           , @c_T_DeliveryOnExp     = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='T_DeliveryOn')), '' )
           , @c_T_CartonExp         = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='T_Carton')), '' )
           , @c_T_StoreNoExp        = ISNULL(RTRIM((select top 1 b.ColValue
                                      from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                      where a.SeqNo=b.SeqNo and a.ColValue='T_StoreNo')), '' )
        FROM dbo.CodeLkup (NOLOCK)
       WHERE Listname='REPORTCFG' AND Code='MAPFIELD' AND Long=@c_DataWindow AND Short='Y'
         AND Storerkey = @c_Storerkey
       ORDER BY Code2


      ----------
      SET @c_ExecStatements = N'INSERT INTO #TEMP_PAKDT'
          +' (PickSlipNo, Storerkey, Orderkey, ExternOrderKey, Company, Div, Consigneekey, C_company, C_Address1, C_Address2,'
          + ' C_Address3, C_Address4, Notes2, Route, Wavekey, Deliverydate, ContainerQty, LabelNo, Storer_Logo,'
          + ' StoreNo, Qty, CartonNo, TotalCarton, ConsolPick,'
          + ' T_Dock, T_Div, T_ExternOrderkey, T_ShipTo, T_Remark, T_Route, T_Wavekey, T_DeliveryOn, T_Carton, T_StoreNo)'
          +' SELECT FOK.PickslipNo'
          +      ', OH.Storerkey'
          +      ', OH.OrderKey'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_ExternOrderKeyExp  ,'')<>'' THEN @c_ExternOrderKeyExp   ELSE 'CASE WHEN FOK.ConsolPick=''Y'' THEN OH.Loadkey ELSE OH.ExternOrderKey END' END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_CompanyExp         ,'')<>'' THEN @c_CompanyExp          ELSE 'ST.Company'        END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_DivExp             ,'')<>'' THEN @c_DivExp              ELSE 'NULL'              END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_ConsigneekeyExp    ,'')<>'' THEN @c_ConsigneekeyExp     ELSE 'OH.Consigneekey'   END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_C_CompanyExp       ,'')<>'' THEN @c_C_CompanyExp        ELSE 'OH.C_Company'      END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_C_Address1Exp      ,'')<>'' THEN @c_C_Address1Exp       ELSE 'OH.C_Address1'     END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_C_Address2Exp      ,'')<>'' THEN @c_C_Address2Exp       ELSE 'OH.C_Address2'     END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_C_Address3Exp      ,'')<>'' THEN @c_C_Address3Exp       ELSE 'OH.C_Address3'     END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_C_Address4Exp      ,'')<>'' THEN @c_C_Address4Exp       ELSE 'OH.C_Address4'     END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_Notes2Exp          ,'')<>'' THEN @c_Notes2Exp           ELSE 'OH.Notes2'         END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_RouteExp           ,'')<>'' THEN @c_RouteExp            ELSE 'OH.Route'          END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_WavekeyExp         ,'')<>'' THEN @c_WavekeyExp          ELSE 'OH.Userdefine09'   END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +                   ', ' + CASE WHEN ISNULL(@c_DeliverydateExp    ,'')<>'' THEN @c_DeliverydateExp     ELSE 'OH.Deliverydate'   END
      SET @c_ExecStatements = @c_ExecStatements
          +                   ', ' + CASE WHEN ISNULL(@c_ContainerQtyExp    ,'')<>'' THEN @c_ContainerQtyExp     ELSE 'OH.ContainerQty'   END
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_LabelNoExp         ,'')<>'' THEN @c_LabelNoExp          ELSE 'PD.LabelNo'        END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_StorerLogoExp      ,'')<>'' THEN @c_StorerLogoExp       ELSE 'RL.Notes'          END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_StoreNoExp         ,'')<>'' THEN @c_StoreNoExp          ELSE 'NULL'              END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +            ', ISNULL(' + CASE WHEN ISNULL(@c_QtyExp             ,'')<>'' THEN @c_QtyExp              ELSE 'PD.Qty'            END + ',0)'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', PD.CartonNo'
          +      ', FOK.CartonMax'
          +      ', FOK.ConsolPick'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_T_DockExp          ,'')<>'' THEN @c_T_DockExp           ELSE '''Dock#'''         END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_T_DivExp           ,'')<>'' THEN @c_T_DivExp            ELSE '''Div :'''         END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_T_ExternOrderkeyExp,'')<>'' THEN @c_T_ExternOrderkeyExp ELSE 'CASE WHEN FOK.ConsolPick=''Y'' THEN ''LP#:'' ELSE ''SO#'' END' END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_T_ShipToExp        ,'')<>'' THEN @c_T_ShipToExp         ELSE '''Ship To :'''     END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_T_RemarkExp        ,'')<>'' THEN @c_T_RemarkExp         ELSE '''Remark :'''      END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_T_RouteExp         ,'')<>'' THEN @c_T_RouteExp          ELSE '''Route :'''       END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_T_WavekeyExp       ,'')<>'' THEN @c_T_WavekeyExp        ELSE '''Wavekey :'''     END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_T_DeliveryOnExp    ,'')<>'' THEN @c_T_DeliveryOnExp     ELSE '''Deliver on :'''  END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_T_CartonExp        ,'')<>'' THEN @c_T_CartonExp         ELSE '''Carton'''        END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +      ', ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_T_StoreNoExp       ,'')<>'' THEN @c_T_StoreNoExp        ELSE '''Store #'''       END + '),'''')'

      SET @c_ExecStatements = @c_ExecStatements
          +' FROM #TEMP_FINALORDERKEY2 FOK'
          +' JOIN dbo.ORDERS        OH (NOLOCK) ON FOK.Orderkey=OH.Orderkey'
          +' JOIN dbo.PACKDETAIL    PD (NOLOCK) ON FOK.PickslipNo=PD.PickslipNo'
          +' JOIN dbo.STORER        ST (NOLOCK) ON OH.Storerkey=ST.Storerkey'
          +' LEFT JOIN dbo.CODELKUP RL (NOLOCK) ON RL.Listname=''RPTLOGO'' AND RL.Code=''LOGO'' AND RL.Storerkey=OH.Storerkey AND RL.Long=@c_DataWindow'
      SET @c_ExecStatements = @c_ExecStatements
          + CASE WHEN ISNULL(@c_JoinClause,'')='' THEN '' ELSE ' ' + ISNULL(LTRIM(RTRIM(@c_JoinClause)),'') END

      SET @c_ExecStatements = @c_ExecStatements
          +' WHERE OH.Storerkey=@c_Storerkey'
          +  ' AND PD.CartonNo >= @n_CartonNoFrom'
          +  ' AND PD.CartonNo <= @n_CartonNoTo'
      IF ISNULL(@as_StartLabelNo,'')<>'' OR ISNULL(@as_EndLabelNo,'')<>''
         SET @c_ExecStatements = @c_ExecStatements
             +  ' AND PD.LabelNo >= ISNULL(@as_StartLabelNo,'''')'
             +  ' AND PD.LabelNo <= ISNULL(@as_EndLabelNo,'''')'

      SET @c_ExecArguments = N'@c_DataWindow    NVARCHAR(40)'
                           + ',@c_Storerkey     NVARCHAR(15)'
                           + ',@n_CartonNoFrom  INT'
                           + ',@n_CartonNoTo    INT'
                           + ',@as_StartLabelNo NVARCHAR(40)'
                           + ',@as_EndLabelNo   NVARCHAR(40)'

      EXEC sp_ExecuteSql @c_ExecStatements
                       , @c_ExecArguments
                       , @c_DataWindow
                       , @c_Storerkey
                       , @n_CartonNoFrom
                       , @n_CartonNoTo
                       , @as_StartLabelNo
                       , @as_EndLabelNo
   END

   CLOSE CUR_STORERKEY
   DEALLOCATE CUR_STORERKEY


   -- Insert Print Log
   IF ISNULL(@c_JobName,'')<>'' AND ISNULL(@as_StartLabelNo,'') <> ''
      AND EXISTS(SELECT TOP 1 1 FROM #TEMP_PAKDT)
   BEGIN
      DECLARE C_PRINTLOG CURSOR FAST_FORWARD READ_ONLY FOR
       SELECT DISTINCT a.PickslipNo, a.CartonNo, a.LabelNo, a.Orderkey, a.ExternOrderkey, a.Storerkey
         FROM #TEMP_PAKDT a
         JOIN (
            SELECT Storerkey, ShowFields = LTRIM(RTRIM(UDF01)) + LOWER(LTRIM(RTRIM(Notes))) + LTRIM(RTRIM(UDF01))
                 , SeqNo=ROW_NUMBER() OVER(PARTITION BY Storerkey ORDER BY Code2)
              FROM dbo.CodeLkup (NOLOCK) WHERE Listname='REPORTCFG' AND Code='SHOWFIELD' AND Long=@c_DataWindow AND Short='Y'
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
             @c_JobName, 'UCCLABEL', '9', @c_DataWindow, 0, '', 0, 0, DB_NAME(), '', '', @c_StorerKey,
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



   SELECT PickSlipNo         = PAKDT.PickSlipNo
        , Storerkey          = MAX( PAKDT.Storerkey )
        , Company            = MAX( PAKDT.Company )
        , Div                = MAX( PAKDT.Div )
        , Orderkey           = MAX( PAKDT.Orderkey )
        , ExternOrderKey     = MAX( PAKDT.ExternOrderKey )
        , Consigneekey       = MAX( PAKDT.Consigneekey )
        , C_company          = MAX( PAKDT.C_company )
        , C_Address1         = MAX( PAKDT.C_Address1 )
        , C_Address2         = MAX( PAKDT.C_Address2 )
        , C_Address3         = MAX( PAKDT.C_Address3 )
        , C_Address4         = MAX( PAKDT.C_Address4 )
        , Notes2             = MAX( PAKDT.Notes2 )
        , Route              = MAX( PAKDT.Route )
        , Wavekey            = MAX( PAKDT.Wavekey )
        , Deliverydate       = MAX( PAKDT.Deliverydate )
        , ContainerQty       = MAX( PAKDT.ContainerQty )
        , LabelNo            = PAKDT.LabelNo
        , CartonNo           = PAKDT.CartonNo
        , StoreNo            = MAX( PAKDT.StoreNo )
        , TotalCarton        = MAX( PAKDT.TotalCarton )
        , Qty                = SUM( PAKDT.Qty )
        , ConsolPick         = MAX( PAKDT.ConsolPick )
        , Storer_Logo        = MAX( PAKDT.Storer_Logo )
        , Lbl_Dock           = MAX( PAKDT.T_Dock )
        , Lbl_Div            = MAX( PAKDT.T_Div )
        , Lbl_ExternOrderkey = MAX( PAKDT.T_ExternOrderkey )
        , Lbl_ShipTo         = MAX( PAKDT.T_ShipTo )
        , Lbl_Remark         = MAX( PAKDT.T_Remark )
        , Lbl_Route          = MAX( PAKDT.T_Route )
        , Lbl_Wavekey        = MAX( PAKDT.T_Wavekey )
        , Lbl_DeliveryOn     = MAX( PAKDT.T_DeliveryOn )
        , Lbl_Carton         = MAX( PAKDT.T_Carton )
        , Lbl_StoreNo        = MAX( PAKDT.T_StoreNo )
   FROM #TEMP_PAKDT PAKDT

   GROUP BY PAKDT.PickSlipNo
          , PAKDT.CartonNo
          , PAKDT.LabelNo

   ORDER BY PickSlipNo
          , CartonNo
          , LabelNo


   WHILE @@TRANCOUNT > @n_StartTCnt
      COMMIT TRAN
   WHILE @@TRANCOUNT < @n_StartTCnt
      BEGIN TRAN
END
GO

GRANT EXECUTE ON isp_r_hk_carton_label_08 TO NSQL
GO