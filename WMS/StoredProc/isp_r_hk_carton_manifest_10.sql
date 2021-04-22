IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[isp_r_hk_carton_manifest_10]') AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
   DROP PROCEDURE [dbo].[isp_r_hk_carton_manifest_10]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/*************************************************************************/
/* Stored Procedure: isp_r_hk_carton_manifest_10                         */
/* Creation Date: 22-Apr-2020                                            */
/* Copyright: LFL                                                        */
/* Written by: Michael Lam (HK LIT)                                      */
/*                                                                       */
/* Purpose: VF Carton Manifest Label                                     */
/*                                                                       */
/* Called By: Report Module. Datawidnow r_hk_carton_manifest_10          */
/*                                                                       */
/* PVCS Version: 1.0                                                     */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date         Author   Ver  Purposes                                   */
/* 26/03/2021   Michael  v1.1 WMS-16649 AEO - Manifest Label Modification*/
/*************************************************************************/

CREATE PROCEDURE [dbo].[isp_r_hk_carton_manifest_10] (
       @as_pickslipno     NVARCHAR(10)
     , @as_cartonnostart  NVARCHAR(20)
     , @as_cartonnoend    NVARCHAR(20)
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   SET ANSI_WARNINGS OFF

/* CODELKUP.REPORTCFG
   [MAPFIELD]
      ExternOrderkey, DischargePlace, CartonNo, LabelNo, Style, Color, Size, Measurement, MaxCartonNo, PrintDate, Qty, Refno

   [MAPVALUE]
      T_UCCNo, T_OBD, T_CARTON, T_TotalQty, T_Style, T_Color, T_Size_Dim, T_Qty

   [SHOWFIELD]

   [SQLJOIN]
*/

   IF OBJECT_ID('tempdb..#TEMP_PACKDETAIL') IS NOT NULL
      DROP TABLE #TEMP_PACKDETAIL
   IF OBJECT_ID('tempdb..#TEMP_PAKDT') IS NOT NULL
      DROP TABLE #TEMP_PAKDT

   DECLARE @c_DataWindow         NVARCHAR(40)  = 'r_hk_carton_manifest_10'
         , @c_ExecStatements     NVARCHAR(MAX)
         , @c_ExecArguments      NVARCHAR(MAX)
         , @c_JoinClause         NVARCHAR(MAX)
         , @c_ShowFields         NVARCHAR(MAX)
         , @c_ExternOrderkeyExp  NVARCHAR(MAX)
         , @c_DischargePlaceExp  NVARCHAR(MAX)
         , @c_CartonNoExp        NVARCHAR(MAX)
         , @c_LabelNoExp         NVARCHAR(MAX)
         , @c_StyleExp           NVARCHAR(MAX)
         , @c_ColorExp           NVARCHAR(MAX)
         , @c_SizeExp            NVARCHAR(MAX)
         , @c_MeasurementExp     NVARCHAR(MAX)
         , @c_MaxCartonNoExp     NVARCHAR(MAX)
         , @c_QtyExp             NVARCHAR(MAX)
         , @c_PrintDateExp       NVARCHAR(MAX)
         , @c_RefnoExp           NVARCHAR(MAX)
         , @c_Storerkey          NVARCHAR(15)

   CREATE TABLE #TEMP_PAKDT (
        PickSlipNo       NVARCHAR(10)
      , ExternOrderkey   NVARCHAR(50)
      , DischargePlace   NVARCHAR(50)
      , CartonNo         INT
      , LabelNo          NVARCHAR(50)
      , Style            NVARCHAR(50)
      , Color            NVARCHAR(50)
      , Size             NVARCHAR(50)
      , Measurement      NVARCHAR(50)
      , MaxCartonNo      NVARCHAR(50)
      , Qty              INT
      , PrintDate        NVARCHAR(50)
      , RefNo            NVARCHAR(500)
      , Storerkey        NVARCHAR(15)
   )

   SELECT *
     INTO #TEMP_PACKDETAIL
     FROM dbo.PACKDETAIL (NOLOCK)
    WHERE 1=2

   IF EXISTS (SELECT TOP 1 1 FROM PACKDETAIL WITH (NOLOCK) WHERE PickSlipNo = @as_pickslipno AND (LabelNo = @as_cartonnostart OR LabelNo = @as_cartonnoend) )
   BEGIN
      INSERT INTO #TEMP_PACKDETAIL
      SELECT *
        FROM dbo.PACKDETAIL (NOLOCK)
       WHERE PickSlipNo = @as_pickslipno
         AND LabelNo BETWEEN @as_cartonnostart AND @as_cartonnoend
   END
   ELSE
   BEGIN
      INSERT INTO #TEMP_PACKDETAIL
      SELECT *
        FROM dbo.PACKDETAIL (NOLOCK)
       WHERE PickSlipNo = @as_pickslipno
         AND CartonNo BETWEEN CAST(@as_cartonnostart AS INT) AND CAST(@as_cartonnoend AS INT)
   END


   -- Storerkey Loop
   DECLARE C_STORERKEY CURSOR FAST_FORWARD READ_ONLY FOR
   SELECT DISTINCT Storerkey
     FROM #TEMP_PACKDETAIL
    ORDER BY 1

   OPEN C_STORERKEY

   WHILE 1=1
   BEGIN
      FETCH NEXT FROM C_STORERKEY
       INTO @c_Storerkey

      IF @@FETCH_STATUS<>0
         BREAK

      SELECT @c_ExecStatements    = ''
           , @c_ExecArguments     = ''
           , @c_JoinClause        = ''
           , @c_ShowFields        = ''
           , @c_ExternOrderkeyExp = ''
           , @c_DischargePlaceExp = ''
           , @c_CartonNoExp       = ''
           , @c_LabelNoExp        = ''
           , @c_StyleExp          = ''
           , @c_ColorExp          = ''
           , @c_SizeExp           = ''
           , @c_MeasurementExp    = ''
           , @c_MaxCartonNoExp    = ''
           , @c_QtyExp            = ''
           , @c_PrintDateExp      = ''
           , @c_RefnoExp          = ''

      SELECT TOP 1
             @c_JoinClause = Notes
        FROM dbo.CodeLkup (NOLOCK)
       WHERE Listname='REPORTCFG' AND Code='SQLJOIN' AND Long=@c_DataWindow AND Short='Y'
         AND Storerkey = @c_Storerkey
       ORDER BY Code2

      SELECT TOP 1
             @c_ShowFields = LTRIM(RTRIM(UDF01)) + LOWER(LTRIM(RTRIM(Notes))) + LTRIM(RTRIM(UDF01))
      FROM dbo.CODELKUP (NOLOCK)
      WHERE Listname='REPORTCFG' AND Code='SHOWFIELD' AND Long=@c_DataWindow AND Short='Y'
         AND Storerkey = @c_Storerkey
       ORDER BY Code2

      ----------
      SELECT TOP 1
             @c_ExternOrderkeyExp  = ISNULL(RTRIM((select top 1 b.ColValue
                                     from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                     where a.SeqNo=b.SeqNo and a.ColValue='ExternOrderkey')), '' )
           , @c_DischargePlaceExp  = ISNULL(RTRIM((select top 1 b.ColValue
                                     from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                     where a.SeqNo=b.SeqNo and a.ColValue='DischargePlace')), '' )
           , @c_CartonNoExp        = ISNULL(RTRIM((select top 1 b.ColValue
                                     from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                     where a.SeqNo=b.SeqNo and a.ColValue='CartonNo')), '' )
           , @c_LabelNoExp         = ISNULL(RTRIM((select top 1 b.ColValue
                                     from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                     where a.SeqNo=b.SeqNo and a.ColValue='LabelNo')), '' )
           , @c_StyleExp           = ISNULL(RTRIM((select top 1 b.ColValue
                                     from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                     where a.SeqNo=b.SeqNo and a.ColValue='Style')), '' )
           , @c_ColorExp           = ISNULL(RTRIM((select top 1 b.ColValue
                                     from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                     where a.SeqNo=b.SeqNo and a.ColValue='Color')), '' )
           , @c_SizeExp            = ISNULL(RTRIM((select top 1 b.ColValue
                                     from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                     where a.SeqNo=b.SeqNo and a.ColValue='Size')), '' )
           , @c_MeasurementExp     = ISNULL(RTRIM((select top 1 b.ColValue
                                     from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                     where a.SeqNo=b.SeqNo and a.ColValue='Measurement')), '' )
           , @c_MaxCartonNoExp     = ISNULL(RTRIM((select top 1 b.ColValue
                                     from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                     where a.SeqNo=b.SeqNo and a.ColValue='MaxCartonNo')), '' )
           , @c_QtyExp             = ISNULL(RTRIM((select top 1 b.ColValue
                                     from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                     where a.SeqNo=b.SeqNo and a.ColValue='Qty')), '' )
           , @c_PrintDateExp       = ISNULL(RTRIM((select top 1 b.ColValue
                                     from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                     where a.SeqNo=b.SeqNo and a.ColValue='PrintDate')), '' )
           , @c_RefnoExp           = ISNULL(RTRIM((select top 1 b.ColValue
                                     from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                     where a.SeqNo=b.SeqNo and a.ColValue='Refno')), '' )
        FROM dbo.CodeLkup (NOLOCK)
       WHERE Listname='REPORTCFG' AND Code='MAPFIELD' AND Long=@c_DataWindow AND Short='Y'
         AND Storerkey = @c_Storerkey
       ORDER BY Code2


      SET @c_ExecStatements = N'INSERT INTO #TEMP_PAKDT'
        + ' (PickSlipNo, ExternOrderkey, DischargePlace, CartonNo, LabelNo, Style, Color, Size, Measurement, MaxCartonNo, Qty, PrintDate, RefNo, Storerkey)'
        +  ' SELECT PickSlipNo     = PH.PickSlipNo'
      SET @c_ExecStatements = @c_ExecStatements
        +        ', ExternOrderkey = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_ExternOrderkeyExp ,'')<>'' THEN @c_ExternOrderkeyExp  ELSE 'OH.ExternOrderkey'        END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
        +        ', DischargePlace = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_DischargePlaceExp ,'')<>'' THEN @c_DischargePlaceExp  ELSE 'OH.DischargePlace'        END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
        +        ', CartonNo       = '              + CASE WHEN ISNULL(@c_CartonNoExp       ,'')<>'' THEN @c_CartonNoExp        ELSE 'PD.CartonNo'              END
      SET @c_ExecStatements = @c_ExecStatements
        +        ', LabelNo        = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_LabelNoExp        ,'')<>'' THEN @c_LabelNoExp         ELSE 'FORMATMESSAGE(''(%s) %s %s %s %s %s'', LEFT(PD.LabelNo,2),SUBSTRING(PD.LabelNo,3,1),SUBSTRING(PD.LabelNo,4,2),SUBSTRING(PD.LabelNo,6,5),SUBSTRING(PD.LabelNo,11,9),SUBSTRING(PD.LabelNo,20,1))' END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
        +        ', Style          = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_StyleExp          ,'')<>'' THEN @c_StyleExp           ELSE 'SKU.Style'                END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
        +        ', Color          = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_ColorExp          ,'')<>'' THEN @c_ColorExp           ELSE 'SKU.Color'                END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
        +        ', Size           = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_SizeExp           ,'')<>'' THEN @c_SizeExp            ELSE 'SKU.Size'                 END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
        +        ', Measurement    = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_MeasurementExp    ,'')<>'' THEN @c_MeasurementExp     ELSE 'SKU.Measurement'          END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
        +        ', MaxCartonNo    = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_MaxCartonNoExp    ,'')<>'' THEN @c_MaxCartonNoExp     ELSE
        +                               '(SELECT ISNULL(CONVERT(NVARCHAR(10),MAX(P2.CartonNo)),'''')'
        +                               ' FROM PACKDETAIL P2(NOLOCK)'
        +                               ' WHERE P2.PickSlipNo=PH.PickSlipNo'
        +                               ' HAVING SUM(P2.Qty)>='
        +                                      '(SELECT SUM(ISNULL(c.Qty,e.Qty))'
        +                                      ' FROM PICKHEADER      a(NOLOCK)'
        +                                      ' LEFT JOIN ORDERS     b(NOLOCK) ON a.Orderkey=b.Orderkey AND a.Orderkey<>'''''
        +                                      ' LEFT JOIN PICKDETAIL c(NOLOCK) ON b.Orderkey=c.Orderkey'
        +                                      ' LEFT JOIN ORDERS     d(NOLOCK) ON a.ExternOrderkey = d.Loadkey AND a.ExternOrderkey<>'''' AND ISNULL(a.Orderkey,'''')='''''
        +                                      ' LEFT JOIN PICKDETAIL e(NOLOCK) ON d.Orderkey=e.Orderkey'
        +                                      ' WHERE a.PickHeaderkey=PH.PickSlipNo))'
                                               END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
        +        ', Qty            = ISNULL('       + CASE WHEN ISNULL(@c_QtyExp            ,'')<>'' THEN @c_QtyExp             ELSE 'PD.Qty'                   END + ','''')'
      SET @c_ExecStatements = @c_ExecStatements
        +        ', PrintDate      = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_PrintDateExp      ,'')<>'' THEN @c_PrintDateExp       ELSE 'CONVERT(NVARCHAR(10),GETDATE(),103)' END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
        +        ', RefNo          = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_RefnoExp          ,'')<>'' THEN @c_RefnoExp           ELSE ''''''                     END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
        +        ', Storerkey      = OH.Storerkey'
        +  ' FROM dbo.ORDERS       OH (NOLOCK)'
        +  ' JOIN dbo.PACKHEADER   PH (NOLOCK) ON (OH.OrderKey   = PH.OrderKey)'
        +  ' JOIN #TEMP_PACKDETAIL PD (NOLOCK) ON (PH.PickSlipNo = PD.PickSlipNo)'
        +  ' JOIN dbo.SKU          SKU(NOLOCK) ON (PD.Storerkey  = SKU.Storerkey) AND (PD.Sku = SKU.Sku)'
      SET @c_ExecStatements = @c_ExecStatements
        + CASE WHEN ISNULL(@c_JoinClause,'')='' THEN '' ELSE ' ' + ISNULL(LTRIM(RTRIM(@c_JoinClause)),'') END

      SET @c_ExecStatements = @c_ExecStatements
        +  ' WHERE OH.Storerkey = @c_Storerkey'


      SET @c_ExecArguments = N'@c_Storerkey   NVARCHAR(15)'
                           + ',@c_DataWindow  NVARCHAR(40)'
                           + ',@c_ShowFields  NVARCHAR(MAX)'

      EXEC sp_ExecuteSql @c_ExecStatements
                       , @c_ExecArguments
                       , @c_Storerkey
                       , @c_DataWindow
                       , @c_ShowFields
   END

   CLOSE C_STORERKEY
   DEALLOCATE C_STORERKEY


   SELECT PickSlipNo        = PAKDT.PickSlipNo
        , ExternOrderkey    = PAKDT.ExternOrderkey
        , DischargePlace    = PAKDT.DischargePlace
        , CartonNo          = PAKDT.CartonNo
        , LabelNo           = PAKDT.LabelNo
        , Style             = PAKDT.Style
        , Color             = PAKDT.Color
        , Size              = PAKDT.Size
        , Measurement       = PAKDT.Measurement
        , MaxCartonNo       = PAKDT.MaxCartonNo
        , Qty               = SUM( PAKDT.Qty )
        , PrintDate         = MAX( PAKDT.PrintDate )
        , RefNo             = PAKDT.RefNo
        , Lbl_UCCNo         = CAST( RTRIM( (select top 1 b.ColValue
                                   from dbo.fnc_DelimSplit(MAX(RptCfg3.Delim),MAX(RptCfg3.Notes)) a, dbo.fnc_DelimSplit(MAX(RptCfg3.Delim),MAX(RptCfg3.Notes2)) b
                                   where a.SeqNo=b.SeqNo and a.ColValue='T_UCCNo') ) AS NVARCHAR(500))
        , Lbl_OBD           = CAST( RTRIM( (select top 1 b.ColValue
                                   from dbo.fnc_DelimSplit(MAX(RptCfg3.Delim),MAX(RptCfg3.Notes)) a, dbo.fnc_DelimSplit(MAX(RptCfg3.Delim),MAX(RptCfg3.Notes2)) b
                                   where a.SeqNo=b.SeqNo and a.ColValue='T_OBD') ) AS NVARCHAR(500))
        , Lbl_CARTON        = CAST( RTRIM( (select top 1 b.ColValue
                                   from dbo.fnc_DelimSplit(MAX(RptCfg3.Delim),MAX(RptCfg3.Notes)) a, dbo.fnc_DelimSplit(MAX(RptCfg3.Delim),MAX(RptCfg3.Notes2)) b
                                   where a.SeqNo=b.SeqNo and a.ColValue='T_CARTON') ) AS NVARCHAR(500))
        , Lbl_TotalQty      = CAST( RTRIM( (select top 1 b.ColValue
                                   from dbo.fnc_DelimSplit(MAX(RptCfg3.Delim),MAX(RptCfg3.Notes)) a, dbo.fnc_DelimSplit(MAX(RptCfg3.Delim),MAX(RptCfg3.Notes2)) b
                                   where a.SeqNo=b.SeqNo and a.ColValue='T_TotalQty') ) AS NVARCHAR(500))
        , Lbl_Style         = CAST( RTRIM( (select top 1 b.ColValue
                                   from dbo.fnc_DelimSplit(MAX(RptCfg3.Delim),MAX(RptCfg3.Notes)) a, dbo.fnc_DelimSplit(MAX(RptCfg3.Delim),MAX(RptCfg3.Notes2)) b
                                   where a.SeqNo=b.SeqNo and a.ColValue='T_Style') ) AS NVARCHAR(500))
        , Lbl_Color         = CAST( RTRIM( (select top 1 b.ColValue
                                   from dbo.fnc_DelimSplit(MAX(RptCfg3.Delim),MAX(RptCfg3.Notes)) a, dbo.fnc_DelimSplit(MAX(RptCfg3.Delim),MAX(RptCfg3.Notes2)) b
                                   where a.SeqNo=b.SeqNo and a.ColValue='T_Color') ) AS NVARCHAR(500))
        , Lbl_Size_Dim      = CAST( RTRIM( (select top 1 b.ColValue
                                   from dbo.fnc_DelimSplit(MAX(RptCfg3.Delim),MAX(RptCfg3.Notes)) a, dbo.fnc_DelimSplit(MAX(RptCfg3.Delim),MAX(RptCfg3.Notes2)) b
                                   where a.SeqNo=b.SeqNo and a.ColValue='T_Size_Dim') ) AS NVARCHAR(500))
        , Lbl_Qty           = CAST( RTRIM( (select top 1 b.ColValue
                                   from dbo.fnc_DelimSplit(MAX(RptCfg3.Delim),MAX(RptCfg3.Notes)) a, dbo.fnc_DelimSplit(MAX(RptCfg3.Delim),MAX(RptCfg3.Notes2)) b
                                   where a.SeqNo=b.SeqNo and a.ColValue='T_Qty') ) AS NVARCHAR(500))
   FROM #TEMP_PAKDT PAKDT
   LEFT JOIN (
      SELECT Storerkey, Notes = RTRIM(Notes), Notes2 = RTRIM(Notes2), Delim = LTRIM(RTRIM(UDF01))
           , SeqNo=ROW_NUMBER() OVER(PARTITION BY Storerkey ORDER BY Code2)
        FROM dbo.CodeLkup (NOLOCK) WHERE Listname='REPORTCFG' AND Code='MAPVALUE' AND Long=@c_DataWindow AND Short='Y'
   ) RptCfg3
   ON RptCfg3.Storerkey=PAKDT.Storerkey AND RptCfg3.SeqNo=1

   GROUP BY PAKDT.PickSlipNo
          , PAKDT.ExternOrderkey
          , PAKDT.DischargePlace
          , PAKDT.CartonNo
          , PAKDT.LabelNo
          , PAKDT.Style
          , PAKDT.Color
          , PAKDT.Size
          , PAKDT.Measurement
          , PAKDT.MaxCartonNo
          , PAKDT.RefNo

   ORDER BY PickSlipNo, CartonNo, Style, Color, Size, Measurement
END
GO
GRANT EXECUTE ON isp_r_hk_carton_manifest_10 TO NSQL
GO