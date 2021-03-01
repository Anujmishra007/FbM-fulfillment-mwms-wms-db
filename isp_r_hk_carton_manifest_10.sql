IF EXISTS (SELECT * FROM dbo.sysobjects WHERE Id = OBJECT_ID(N'[dbo].[isp_r_hk_carton_manifest_10]') and OBJECTPROPERTY(Id, N'IsProcedure') = 1)
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


   IF OBJECT_ID('tempdb..#TEMP_PACKDETAIL') IS NOT NULL
      DROP TABLE #TEMP_PACKDETAIL
   IF OBJECT_ID('tempdb..#TEMP_PAKDT') IS NOT NULL
      DROP TABLE #TEMP_PAKDT

   DECLARE @c_DataWindow         NVARCHAR(40)  = 'r_hk_carton_manifest_10'
         , @c_ExecStatements     NVARCHAR(MAX)
         , @c_ExecArguments      NVARCHAR(MAX)
         , @c_StyleExp           NVARCHAR(4000)
         , @c_ColorExp           NVARCHAR(4000)
         , @c_SizeExp            NVARCHAR(4000)
         , @c_MeasurementExp     NVARCHAR(4000)
         , @c_RefnoExp           NVARCHAR(4000)
         , @c_Storerkey          NVARCHAR(15)

   CREATE TABLE #TEMP_PAKDT (
        PickSlipNo       NVARCHAR(10)
      , ExternOrderkey   NVARCHAR(50)
      , DischargePlace   NVARCHAR(30)
      , CartonNo         INT
      , LabelNo          NVARCHAR(20)
      , Style            NVARCHAR(40)
      , Color            NVARCHAR(10)
      , Size             NVARCHAR(10)
      , Measurement      NVARCHAR(5)
      , MaxCartonNo      NVARCHAR(5)
      , Qty              INT
      , PrintDate        DATETIME
      , RefNo            NVARCHAR(120)
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

      SELECT @c_ExecStatements = ''
           , @c_ExecArguments  = ''
           , @c_StyleExp       = ''
           , @c_ColorExp       = ''
           , @c_SizeExp        = ''
           , @c_MeasurementExp = ''
           , @c_RefnoExp       = ''

      ----------
      SELECT TOP 1
             @c_StyleExp           = ISNULL(RTRIM((select top 1 b.ColValue
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
           , @c_RefnoExp           = ISNULL(RTRIM((select top 1 b.ColValue
                                     from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                     where a.SeqNo=b.SeqNo and a.ColValue='Refno')), '' )
        FROM dbo.CodeLkup (NOLOCK)
       WHERE Listname='REPORTCFG' AND Code='MAPFIELD' AND Long=@c_DataWindow AND Short='Y'
         AND Storerkey = @c_Storerkey
       ORDER BY Code2


      SET @c_ExecStatements = N'INSERT INTO #TEMP_PAKDT'
          +' (PickSlipNo, ExternOrderkey, DischargePlace, CartonNo, LabelNo, Style, Color, Size, Measurement, MaxCartonNo, Qty, PrintDate, RefNo)'
          +' SELECT X.PickSlipNo'
          +     ' , X.ExternOrderkey'
          +     ' , X.DischargePlace'
          +     ' , X.CartonNo'
          +     ' , X.LabelNo'
          +     ' , X.Style'
          +     ' , X.Color'
          +     ' , X.Size'
          +     ' , X.Measurement'
          +     ' , X.MaxCartonNo'
          +     ' , SUM(X.Qty)'
          +     ' , GETDATE()'
          +     ' , X.RefNo'
          +  ' FROM ('
          +   ' SELECT PickSlipNo     = PH.PickSlipNo'
          +        ' , ExternOrderkey = ISNULL(RTRIM(OH.ExternOrderkey),'''')'
          +        ' , DischargePlace = ISNULL(RTRIM(OH.DischargePlace),'''')'
          +        ' , CartonNo       = PD.CartonNo'
          +        ' , LabelNo        = PD.LabelNo'
      SET @c_ExecStatements = @c_ExecStatements
                  + ', Style       = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_StyleExp          ,'')<>'' THEN @c_StyleExp           ELSE 'SKU.Style'                END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
                  + ', Color       = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_ColorExp          ,'')<>'' THEN @c_ColorExp           ELSE 'SKU.Color'                END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
                  + ', Size        = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_SizeExp           ,'')<>'' THEN @c_SizeExp            ELSE 'SKU.Size'                 END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
                  + ', Measurement = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_MeasurementExp    ,'')<>'' THEN @c_MeasurementExp     ELSE 'SKU.Measurement'          END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +         ', MaxCartonNo = ISNULL((SELECT CONVERT(VARCHAR(5), MAX(a.CartonNo))'
          +                              ' FROM PACKDETAIL a WITH (NOLOCK)'
          +                              ' JOIN PACKHEADER b WITH (NOLOCK) ON (a.PickSlipNo = b.PickSlipNo)'
          +                              ' WHERE b.PickSlipNo = PH.PickSlipNo'
          +                              ' GROUP BY b.Orderkey'
          +                              ' HAVING SUM(a.Qty) = (SELECT SUM(OD.QtyAllocated+OD.QtyPicked+OD.ShippedQty)'
          +                                                    ' FROM ORDERDETAIL OD WITH (NOLOCK)'
          +                                                    ' WHERE OD.Orderkey = PH.Orderkey)),'''')'
          +         ', Qty         = PD.Qty'
      SET @c_ExecStatements = @c_ExecStatements
                  + ', RefNo       = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_RefnoExp                ,'')<>'' THEN @c_RefnoExp           ELSE ''''''                     END + '),'''')'
      SET @c_ExecStatements = @c_ExecStatements
          +  ' FROM dbo.ORDERS       OH (NOLOCK)'
          +  ' JOIN dbo.PACKHEADER   PH (NOLOCK) ON (OH.OrderKey   = PH.OrderKey)'
          +  ' JOIN #TEMP_PACKDETAIL PD (NOLOCK) ON (PH.PickSlipNo = PD.PickSlipNo)'
          +  ' JOIN dbo.SKU          SKU(NOLOCK) ON (PD.Storerkey  = SKU.Storerkey) AND (PD.Sku = SKU.Sku)'
          +' ) X'
          +' GROUP BY X.PickSlipNo'
          +        ', X.ExternOrderkey'
          +        ', X.DischargePlace'
          +        ', X.CartonNo'
          +        ', X.LabelNo'
          +        ', X.Style'
          +        ', X.Color'
          +        ', X.Size'
          +        ', X.Measurement'
          +        ', X.MaxCartonNo'
          +        ', X.RefNo'

      EXEC sp_ExecuteSql @c_ExecStatements
   END

   CLOSE C_STORERKEY
   DEALLOCATE C_STORERKEY


   SELECT *
     FROM #TEMP_PAKDT
    ORDER BY ExternOrderkey, CartonNo, Style, Color, Size, Measurement
END
GO
GRANT EXECUTE ON isp_r_hk_carton_manifest_10 TO NSQL
GO