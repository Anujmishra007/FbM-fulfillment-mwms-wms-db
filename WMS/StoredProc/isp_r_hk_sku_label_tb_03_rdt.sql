if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_r_hk_sku_label_tb_03_rdt]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[isp_r_hk_sku_label_tb_03_rdt]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/*************************************************************************/
/* Stored Procedure: isp_r_hk_sku_label_tb_03_rdt                        */
/* Creation Date: 16-Oct-2023                                            */
/* Copyright: Maersk                                                     */
/* Written by: Michael Lam                                               */
/*                                                                       */
/* Purpose: Toryburch SKU Label for Taiwan                               */
/*                                                                       */
/* Called By: Report Module. Datawidnow r_hk_sku_label_tb_03_rdt         */
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

CREATE PROCEDURE [dbo].[isp_r_hk_sku_label_tb_03_rdt] (
       @as_Storerkey       NVARCHAR(15)
     , @as_LabelNo         NVARCHAR(30)
     , @as_Sku             NVARCHAR(20) = ''
     , @as_Qty             NVARCHAR(10) = ''
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
      ExternOrderkey, B_Company, B_Address, B_GUI, B_Phone, Currency1, Currency2

   [MAPVALUE]
      ConfigType, COO_Lang, COO_Undef

   [SQLWHERE]
*/

   DECLARE @c_Datawindow         NVARCHAR(40) = N'r_hk_sku_label_tb_03_rdt'
         , @c_ExecStatements     NVARCHAR(MAX)
         , @c_SQLWhere           NVARCHAR(MAX)
         , @c_ExtOrderKeyExp     NVARCHAR(MAX)
         , @c_B_CompanyExp       NVARCHAR(MAX)
         , @c_B_AddressExp       NVARCHAR(MAX)
         , @c_B_GUIExp           NVARCHAR(MAX)
         , @c_B_PhoneExp         NVARCHAR(MAX)
         , @c_Currency1Exp       NVARCHAR(MAX)
         , @c_Currency2Exp       NVARCHAR(MAX)
         , @c_ConfigType         NVARCHAR(50)
         , @c_COO_Lang           NVARCHAR(10)
         , @c_COO_Undef          NVARCHAR(500)
         , @n_Qty                INT

   SET @n_Qty = ISNULL(TRY_PARSE(ISNULL(@as_Qty,'') AS INT),0)


   IF OBJECT_ID('tempdb..#TEMP_PICKDET') IS NOT NULL
      DROP TABLE #TEMP_PICKDET
   IF OBJECT_ID('tempdb..#TEMP_PICKDET_2') IS NOT NULL
      DROP TABLE #TEMP_PICKDET_2

   CREATE TABLE #TEMP_PICKDET (
        PickslipNo       NVARCHAR(10)   NULL
      , ExternOrderkey   NVARCHAR(50)   NULL
      , CartonNo         INT            NULL
      , LabelNo          NVARCHAR(20)   NULL
      , Storerkey        NVARCHAR(15)   NULL
      , Sku              NVARCHAR(20)   NULL
      , Sku_BC           NVARCHAR(50)   NULL
      , Descr            NVARCHAR(50)   NULL
      , Style            NVARCHAR(30)   NULL
      , Color            NVARCHAR(10)   NULL
      , Size             NVARCHAR(10)   NULL
      , UnitPrice        FLOAT          NULL
      , Currency1        NVARCHAR(50)   NULL
      , Currency2        NVARCHAR(50)   NULL
      , Content          NVARCHAR(100)  NULL
      , Lining           NVARCHAR(50)   NULL
      , ProdDate         DATE           NULL
      , COO              NVARCHAR(30)   NULL
      , COO_Descr        NVARCHAR(100)  NULL
      , B_Company        NVARCHAR(100)  NULL
      , B_Address        NVARCHAR(200)  NULL
      , B_GUI            NVARCHAR(50)   NULL
      , B_Phone          NVARCHAR(50)   NULL
      , MultiCOO         NVARCHAR(1)    NULL
      , Qty              INT            NULL
   )

   SELECT @c_SQLWhere       = ''
        , @c_ExtOrderKeyExp = ''
        , @c_B_CompanyExp   = ''
        , @c_B_AddressExp   = ''
        , @c_B_GUIExp       = ''
        , @c_B_PhoneExp     = ''
        , @c_Currency1Exp   = ''
        , @c_Currency2Exp   = ''
        , @c_ConfigType     = '1'
        , @c_COO_Lang       = 'CHT'
        , @c_COO_Undef      = ''

   ----------
   SELECT TOP 1
          @c_SQLWhere = Notes
     FROM dbo.CodeLkup (NOLOCK)
    WHERE Listname='REPORTCFG' AND Code='SQLWHERE' AND Long=@c_DataWindow AND Short='Y'
      AND Storerkey = @as_Storerkey
    ORDER BY Code2

   ----------
   SELECT TOP 1
          @c_ExtOrderKeyExp     = ISNULL(RTRIM((select top 1 b.ColValue
                                  from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                  where a.SeqNo=b.SeqNo and a.ColValue='ExternOrderkey')), '' )
        , @c_B_CompanyExp       = ISNULL(RTRIM((select top 1 b.ColValue
                                  from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                  where a.SeqNo=b.SeqNo and a.ColValue='B_Company')), '' )
        , @c_B_AddressExp       = ISNULL(RTRIM((select top 1 b.ColValue
                                  from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                  where a.SeqNo=b.SeqNo and a.ColValue='B_Address')), '' )
        , @c_B_GUIExp           = ISNULL(RTRIM((select top 1 b.ColValue
                                  from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                  where a.SeqNo=b.SeqNo and a.ColValue='B_GUI')), '' )
        , @c_B_PhoneExp         = ISNULL(RTRIM((select top 1 b.ColValue
                                  from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                  where a.SeqNo=b.SeqNo and a.ColValue='B_Phone')), '' )
        , @c_Currency1Exp       = ISNULL(RTRIM((select top 1 b.ColValue
                                  from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                  where a.SeqNo=b.SeqNo and a.ColValue='Currency1')), '' )
        , @c_Currency2Exp       = ISNULL(RTRIM((select top 1 b.ColValue
                                  from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                  where a.SeqNo=b.SeqNo and a.ColValue='Currency2')), '' )
     FROM dbo.CodeLkup (NOLOCK)
    WHERE Listname='REPORTCFG' AND Code='MAPFIELD' AND Long=@c_DataWindow AND Short='Y'
      AND Storerkey = @as_Storerkey
    ORDER BY Code2

   ----------
   SELECT TOP 1
          @c_ConfigType         = ISNULL(RTRIM((select top 1 b.ColValue
                                  from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                  where a.SeqNo=b.SeqNo and a.ColValue='ConfigType')), '' )
        , @c_COO_Lang           = ISNULL(RTRIM((select top 1 b.ColValue
                                  from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                  where a.SeqNo=b.SeqNo and a.ColValue='COO_Lang')), '' )
        , @c_COO_Undef          = ISNULL(RTRIM((select top 1 b.ColValue
                                  from dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes)) a, dbo.fnc_DelimSplit(LTRIM(RTRIM(UDF01)),RTRIM(Notes2)) b
                                  where a.SeqNo=b.SeqNo and a.ColValue='COO_Undef')), '' )
     FROM dbo.CodeLkup (NOLOCK)
    WHERE Listname='REPORTCFG' AND Code='MAPVALUE' AND Long=@c_DataWindow AND Short='Y'
      AND Storerkey = @as_Storerkey
    ORDER BY Code2


   ----------
   SET @c_ExecStatements = N'INSERT INTO #TEMP_PICKDET'
       +' (PickslipNo, ExternOrderkey, CartonNo, LabelNo, Storerkey, Sku, Sku_BC, Descr, Style, Color, Size,'
       + ' UnitPrice, Currency1, Currency2, Content, Lining, ProdDate, COO, COO_Descr, B_Company, B_Address,'
       + ' B_GUI, B_Phone, MultiCOO, Qty)'
       +' SELECT PickslipNo = X.PickslipNo'
   SET @c_ExecStatements = @c_ExecStatements
       +      ', ExternOrderkey = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_ExtOrderKeyExp    ,'')<>'' THEN @c_ExtOrderKeyExp     ELSE 'OH.ExternOrderkey'        END + '),'''')'
   SET @c_ExecStatements = @c_ExecStatements
       +      ', CartonNo       = X.CartonNo'
       +      ', LabelNo        = X.LabelNo'
       +      ', Storerkey      = PD.Storerkey'
       +      ', Sku            = PD.Sku'
       +      ', Sku_BC         = dbo.fn_Encode_IDA_Code128(PD.Sku)'
       +      ', Descr          = ISNULL(RTRIM(CAT.Description),'''')'
       +      ', Style          = ISNULL(RTRIM(SC.Sku),'''')'
       +      ', Color          = ISNULL(RTRIM(SKU.Color),'''')'
       +      ', Size           = ISNULL(RTRIM(SKU.Size),'''')'
       +      ', UnitPrice      = TRY_PARSE(ISNULL(REPLACE(SC.userdefine02,'','',''''),'''') AS FLOAT)'
   SET @c_ExecStatements = @c_ExecStatements
       +      ', Currency1      = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_Currency1Exp      ,'')<>'' THEN @c_Currency1Exp       ELSE ''''''                     END + '),'''')'
   SET @c_ExecStatements = @c_ExecStatements
       +      ', Currency2      = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_Currency2Exp      ,'')<>'' THEN @c_Currency2Exp       ELSE ''''''                     END + '),'''')'
       +      ', Content        = ISNULL(RTRIM(SC.userdefine08),'''')'
       +      ', Lining         = ISNULL(RTRIM(SC.userdefine03),'''')'
       +      ', ProdDate       = CONVERT(DATE, DATEADD(DAY,-60,OH.AddDate))'
   SET @c_ExecStatements = @c_ExecStatements
       +      ', COO            = ISNULL(' + CASE WHEN ISNULL(@c_COO_Undef,'')<>''
                                           THEN 'CASE WHEN EXISTS(SELECT TOP 1 1 FROM STRING_SPLIT(''' + ISNULL(REPLACE(@c_COO_Undef,'''',''''''),'')
                                              + ''','','') WHERE value=LEFT(LA.Lottable03,2) AND value<>'''') THEN SKU.CountryOfOrigin ELSE LEFT(LA.Lottable03,2) END'
                                           ELSE 'LEFT(LA.Lottable03,2)'
                                      END + ','''')'
       +      ', COO_Descr      = COO.Description'
   SET @c_ExecStatements = @c_ExecStatements
       +      ', B_Company      = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_B_CompanyExp      ,'')<>'' THEN @c_B_CompanyExp       ELSE ''''''                     END + '),'''')'
   SET @c_ExecStatements = @c_ExecStatements
       +      ', B_Address      = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_B_AddressExp      ,'')<>'' THEN @c_B_AddressExp       ELSE ''''''                     END + '),'''')'
   SET @c_ExecStatements = @c_ExecStatements
       +      ', B_GUI          = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_B_GUIExp          ,'')<>'' THEN @c_B_GUIExp           ELSE ''''''                     END + '),'''')'
   SET @c_ExecStatements = @c_ExecStatements
       +      ', B_Phone        = ISNULL(RTRIM(' + CASE WHEN ISNULL(@c_B_PhoneExp        ,'')<>'' THEN @c_B_PhoneExp         ELSE ''''''                     END + '),'''')'
   SET @c_ExecStatements = @c_ExecStatements
       +      ', MultiCOO       = ''N'''
       +      ', Qty            = ' + CASE WHEN ISNULL(@as_Qty,'')<>''
                                           THEN 'CASE WHEN PD.Qty<' + CONVERT(VARCHAR(10),ISNULL(@n_Qty,0)) + ' THEN PD.Qty ELSE ' + CONVERT(VARCHAR(10),ISNULL(@n_Qty,0)) + ' END'
                                           ELSE 'PD.Qty'
                                      END
       +' FROM ('
       +   ' SELECT PickDetailKey = PIKD.PickDetailKey'
       +         ', PickslipNo    = MAX(PAKD.PickslipNo)'
       +         ', CartonNo      = MAX(PAKD.CartonNo)'
       +         ', LabelNo       = MAX(PAKD.LabelNo)'
       +   ' FROM dbo.PACKDETAIL PAKD WITH(NOLOCK)'
       +   ' JOIN dbo.PACKHEADER PAKH WITH(NOLOCK) ON PAKD.PickslipNo=PAKH.PickSlipNo'
       +   ' JOIN dbo.PICKDETAIL PIKD WITH(NOLOCK) ON PAKH.Orderkey=PIKD.Orderkey AND PAKD.RefNo=PIKD.AltSku AND PAKD.RefNo<>'''' AND PAKD.Storerkey=PIKD.Storerkey AND PAKD.Sku=PIKD.Sku'
       +   ' WHERE PAKD.Storerkey=''' + ISNULL(REPLACE(@as_Storerkey,'''',''''''),'') + ''''
       +     ' AND PAKD.LabelNo=''' + ISNULL(REPLACE(@as_LabelNo,'''',''''''),'') + ''''
       +     ' AND PIKD.CartonType=''FCP'''
   IF ISNULL(@as_Sku,'')<>''
      SET @c_ExecStatements = @c_ExecStatements
       +     ' AND PAKD.Sku=''' + ISNULL(REPLACE(@as_Sku,'''',''''''),'') + ''''

   SET @c_ExecStatements = @c_ExecStatements
       +   ' GROUP BY PIKD.PickDetailKey'
       +   ' UNION'
       +   ' SELECT PickDetailKey = PIKD.PickDetailKey'
       +         ', PickslipNo    = MAX(PAKD.PickslipNo)'
       +         ', CartonNo      = MAX(PAKD.CartonNo)'
       +         ', LabelNo       = MAX(PAKD.LabelNo)'
       +   ' FROM dbo.PACKDETAIL PAKD WITH(NOLOCK) '
       +   ' JOIN dbo.PACKHEADER PAKH WITH(NOLOCK) ON PAKD.PickslipNo=PAKH.PickSlipNo'
       +   ' JOIN dbo.PICKDETAIL PIKD WITH(NOLOCK) ON PAKH.Orderkey=PIKD.Orderkey AND PAKD.LabelNo=PIKD.DropID AND PAKD.Storerkey=PIKD.Storerkey AND PAKD.Sku=PIKD.Sku'
       +   ' WHERE PAKD.Storerkey=''' + ISNULL(REPLACE(@as_Storerkey,'''',''''''),'') + ''''
       +     ' AND PAKD.LabelNo = ''' + ISNULL(REPLACE(@as_LabelNo,'''',''''''),'') + ''''
       +     ' AND ISNULL(PIKD.CartonType,'''')<>''FCP'''
   IF ISNULL(@as_Sku,'')<>''
      SET @c_ExecStatements = @c_ExecStatements
       +     ' AND PAKD.Sku=''' + ISNULL(REPLACE(@as_Sku,'''',''''''),'') + ''''

   SET @c_ExecStatements = @c_ExecStatements
       +   ' GROUP BY PIKD.PickDetailKey'
       + ') X'
       +' JOIN dbo.PICKDETAIL     PD  WITH(NOLOCK) ON X.PickDetailKey = PD.PickDetailKey'
       +' JOIN dbo.ORDERS         OH  WITH(NOLOCK) ON PD.Orderkey = OH.Orderkey'
       +' JOIN dbo.LOTATTRIBUTE   LA  WITH(NOLOCK) ON PD.Lot = LA.Lot'
       +' JOIN dbo.SKU            SKU WITH(NOLOCK) ON PD.Storerkey = SKU.StorerKey AND PD.Sku = SKU.Sku'
       +' JOIN dbo.SKUCONFIG      SC  WITH(NOLOCK) ON SKU.Storerkey = SC.StorerKey AND SKU.ABCSku = SC.SKU AND SC.ConfigType = ''' + ISNULL(REPLACE(@c_ConfigType,'''',''''''),'') + ''''
       +' LEFT JOIN dbo.CODELKUP  CAT WITH(NOLOCK) ON CAT.LISTNAME = ''TBPDTCAT'' AND SKU.Storerkey = CAT.Storerkey AND SKU.BUSR3 = CAT.Code AND SKU.BUSR5 = CAT.Code2'
       +' LEFT JOIN dbo.CODELKUP  COO WITH(NOLOCK) ON COO.LISTNAME = ''TBCOO'' AND PD.Storerkey = COO.Storerkey AND COO.Code2 = ''' + ISNULL(REPLACE(@c_COO_Lang,'''',''''''),'') + ''''
       +  CASE WHEN ISNULL(@c_COO_Undef,'')<>''
               THEN ' AND COO.Code = CASE WHEN EXISTS(SELECT TOP 1 1 FROM STRING_SPLIT(''' + ISNULL(REPLACE(@c_COO_Undef,'''',''''''),'')
                  + ''','','') WHERE value = LEFT(LA.Lottable03,2) AND value<>'''') THEN SKU.CountryOfOrigin ELSE LEFT(LA.Lottable03,2) END'
               ELSE ' AND COO.Code = LEFT(LA.Lottable03,2)'
          END
       +' WHERE PD.Storerkey = ''' + ISNULL(REPLACE(@as_Storerkey,'''',''''''),'') + ''''
       +  ' AND ISNULL(CAT.UDF01,'''')<>''N'''

   IF ISNULL(@c_SQLWhere,'')<>''
      SET @c_ExecStatements = @c_ExecStatements
          +  ' AND (' + @c_SQLWhere + ')'

   EXEC sp_ExecuteSql @c_ExecStatements

   DELETE #TEMP_PICKDET WHERE Qty<=0

   UPDATE #TEMP_PICKDET
      SET COO_Descr = COO
    WHERE ISNULL(COO_Descr,'')=''

   UPDATE PD SET MultiCOO='Y'
   FROM #TEMP_PICKDET PD
   JOIN (
      SELECT Storerkey, Sku
      FROM #TEMP_PICKDET PD
      GROUP BY Storerkey, Sku
      HAVING COUNT(DISTINCT COO)>1
   ) MCOO ON PD.Storerkey = MCOO.Storerkey AND PD.Sku = MCOO.Sku

   SELECT PickslipNo, ExternOrderkey, CartonNo, LabelNo, Storerkey, Sku, Sku_BC, Descr, Style, Color, Size
        , UnitPrice, Currency1, Currency2, Content, Lining, ProdDate, COO, COO_Descr, B_Company, B_Address
        , B_GUI, B_Phone, MultiCOO
        , Qty = CASE WHEN ISNULL(@as_Qty,'')<>'' THEN IIF(@n_Qty<SUM(Qty),@n_Qty,SUM(Qty)) ELSE SUM(Qty) END
   INTO #TEMP_PICKDET_2
   FROM #TEMP_PICKDET PD
   GROUP BY PickslipNo, ExternOrderkey, CartonNo, LabelNo, Storerkey, Sku, Sku_BC, Descr, Style, Color, Size
          , UnitPrice, Currency1, Currency2, Content, Lining, ProdDate, COO, COO_Descr, B_Company, B_Address
          , B_GUI, B_Phone, MultiCOO


   -- Final Result
   SELECT *
   FROM #TEMP_PICKDET_2 PD
   JOIN dbo.SEQKey SQ WITH(NOLOCK) ON SQ.Rowref<=PD.Qty
   UNION
   SELECT PickslipNo, ExternOrderkey, CartonNo, LabelNo, '', '', '', '', '', '', ''
        , NULL, '', '', '', '', NULL, '', '', '', ''
        , '', '', MultiCOO, SUM(Qty), 0
   FROM #TEMP_PICKDET_2
   GROUP BY PickslipNo, ExternOrderkey, CartonNo, LabelNo, MultiCOO

   ORDER BY LabelNo DESC, MultiCOO DESC, Storerkey DESC, Sku DESC, COO DESC, Rowref DESC
END
GO

GRANT EXECUTE ON isp_r_hk_sku_label_tb_03_rdt TO NSQL
GO