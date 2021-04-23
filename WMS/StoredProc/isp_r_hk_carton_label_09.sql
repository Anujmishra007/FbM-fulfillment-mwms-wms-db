IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[isp_r_hk_carton_label_09]') AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
   DROP PROCEDURE [dbo].[isp_r_hk_carton_label_09]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/*************************************************************************/
/* Store Procedure: isp_r_hk_carton_label_09                             */
/* Creation Date: 24-Apr-2018                                            */
/* Copyright: LFL                                                        */
/* Written by: Michael Lam (HK LIT)                                      */
/*                                                                       */
/* Purpose: WMS-4791 - Copy from nsp_UCC_CartonLabel_40 for Skechers     */
/*                                                                       */
/* Called By: Report Module. Datawidnow r_hk_carton_label_09             */
/*                                                                       */
/* PVCS Version: 1.0                                                     */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author   Purposes                                         */
/* 27/08/2018  ML       WMS-6130  Update Route logic for Converse        */
/* 29/11/2018  ML       WMS-7117  Add generic route code                 */
/* 04/01/2019  ML       WMS-7468  Add ReportCfg ShowFields               */
/* 05/03/2021  ML       WMS-16440 Add MapField: UDF04ShowBarcode         */
/* 18/03/2021  ML       WMS-16440 Add MapField: UserDefine04             */
/*************************************************************************/
CREATE PROCEDURE [dbo].[isp_r_hk_carton_label_09] (
   @c_StorerKey     NVARCHAR(15)
 , @c_PickSlipNo    NVARCHAR(40)
 , @c_cartonNoStart NVARCHAR(5)
 , @c_cartonNoEnd   NVARCHAR(5)
)
AS
BEGIN
   SET NOCOUNT ON   -- SQL 2005 Standard
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_DataWindow          NVARCHAR(40) = 'r_hk_carton_label_09'
         , @c_UserDefine04Exp     NVARCHAR(MAX)
         , @c_UDF04ShowBarcodeExp NVARCHAR(MAX)
         , @c_ExecStatements      NVARCHAR(MAX)
         , @c_ExecArguments       NVARCHAR(MAX)

   SELECT @c_UserDefine04Exp     = ''
        , @c_UDF04ShowBarcodeExp = ''

   SELECT TOP 1
          @c_UserDefine04Exp     = ISNULL(RTRIM((select top 1 b.ColValue
                                   from dbo.fnc_DelimSplit(TRIM(UDF01),RTRIM(Notes)) a, dbo.fnc_DelimSplit(TRIM(UDF01),RTRIM(Notes2)) b
                                   where a.SeqNo=b.SeqNo and a.ColValue='UserDefine04')), '' )
        , @c_UDF04ShowBarcodeExp = ISNULL(RTRIM((select top 1 b.ColValue
                                   from dbo.fnc_DelimSplit(TRIM(UDF01),RTRIM(Notes)) a, dbo.fnc_DelimSplit(TRIM(UDF01),RTRIM(Notes2)) b
                                   where a.SeqNo=b.SeqNo and a.ColValue='UDF04ShowBarcode')), '' )
     FROM dbo.CodeLkup (NOLOCK)
    WHERE Listname='REPORTCFG' AND Code='MAPFIELD' AND Long=@c_DataWindow AND Short='Y'
      AND Storerkey = @c_Storerkey
    ORDER BY Code2

   SET @c_ExecStatements =
     N'SELECT PickSlipNo       = PH.PickSlipNo'
     +     ', LabelNo          = PD.LabelNo'
     +     ', InvoiceNo        = OH.InvoiceNo'
     +     ', ExternOrderKey   = OH.ExternOrderKey'
     +     ', CartonNo         = PD.CartonNo'
   SET @c_ExecStatements = @c_ExecStatements
     +     ', Userdefine04     = ISNULL(RTRIM(MAX(' + CASE WHEN ISNULL(@c_UserDefine04Exp,'')<>'' THEN @c_UserDefine04Exp ELSE 'OH.Userdefine04' END + ')),'''')'
   SET @c_ExecStatements = @c_ExecStatements
     +     ', C_Company        = OH.C_Company'
     +     ', C_Address1       = OH.C_Address1'
     +     ', C_Address2       = OH.C_Address2'
     +     ', C_Address3       = OH.C_Address3'
     +     ', C_Address4       = OH.C_Address4'
     +     ', ConsigneeKey     = OH.ConsigneeKey'
     +     ', Route            = CASE WHEN ISNULL(PH.Route,'''')='''' THEN OH.Route ELSE PH.Route END'
     +     ', C_Zip            = OH.C_Zip'
     +     ', SysDate          = CONVERT(CHAR(19), CONVERT(CHAR(10),GETDATE(),103) + '' '' + CONVERT(CHAR(8),GETDATE(),108))'
     +     ', PriceLabel       = (SELECT COUNT(1)'
     +                          ' FROM PACKHEADER P (NOLOCK)'
     +                          ' JOIN ORDERDETAIL OD (NOLOCK) ON P.OrderKey = OD.OrderKey'
     +                          ' WHERE P.PickSlipNo = @c_PickSlipNo AND OD.UserDefine05 > ''0'')'
     +     ', Notes2           = OH.Notes2'
     +     ', CartonType       = CASE OH.Type WHEN ''D'' THEN ''D'' WHEN ''R'' THEN ''R'' ELSE OH.type END'
     +     ', OrderKey         = OH.OrderKey'
     +     ', DeliveryDate     = CONVERT(NVARCHAR(8),OH.DeliveryDate,3)'
     +     ', ZipCodeFrom      = MAX(RM.ZipCodeFrom)'
     +     ', ShowFields       = MAX(RptCfg.ShowFields)'
   SET @c_ExecStatements = @c_ExecStatements
     +     ', UDF04ShowBarcode = ISNULL(RTRIM(MAX(' + CASE WHEN ISNULL(@c_UDF04ShowBarcodeExp,'')<>'' THEN @c_UDF04ShowBarcodeExp ELSE '''''' END + ')),'''')'
   SET @c_ExecStatements = @c_ExecStatements
     +N' FROM dbo.ORDERS     OH (NOLOCK) '
     + ' JOIN dbo.PACKHEADER PH (NOLOCK) ON (OH.OrderKey = PH.OrderKey)'
     + ' JOIN dbo.PACKDETAIL PD (NOLOCK) ON (PH.PickSlipNo = PD.PickSlipNo)'
     + ' JOIN dbo.SKU        SKU(NOLOCK) ON (PD.Sku = SKU.Sku AND PD.StorerKey = SKU.StorerKey)'
     + ' JOIN dbo.STORER     ST (NOLOCK) ON (OH.StorerKey = ST.StorerKey)'
     + ' LEFT OUTER JOIN dbo.STORER      SHIPTO(NOLOCK) ON (SHIPTO.Type = ''2'' AND SHIPTO.StorerKey = OH.ConsigneeKey)'
     + ' LEFT OUTER JOIN dbo.STORER      IDS   (NOLOCK) ON (IDS.Storerkey = ''11301'')'
     + ' LEFT OUTER JOIN dbo.ROUTEMASTER RM    (NOLOCK) ON (OH.Route=RM.Route)'
   SET @c_ExecStatements = @c_ExecStatements
     + ' LEFT OUTER JOIN ('
     +    ' SELECT Storerkey, ShowFields = LTRIM(RTRIM(UDF01)) + LOWER(LTRIM(RTRIM(Notes))) + LTRIM(RTRIM(UDF01))'
     +          ', SeqNo=ROW_NUMBER() OVER(PARTITION BY Storerkey ORDER BY Code2)'
     +      ' FROM dbo.CodeLkup (NOLOCK) WHERE Listname=''REPORTCFG'' AND Code=''SHOWFIELD'' AND Long=@c_DataWindow AND Short=''Y'''
     + ' ) RptCfg ON RptCfg.Storerkey=OH.Storerkey AND RptCfg.SeqNo=1'
     + ' WHERE PH.PickSlipNo = @c_PickSlipNo AND OH.StorerKey = @c_StorerKey '
     +   ' AND PD.CartonNo BETWEEN CAST(@c_cartonNoStart AS INT) AND CAST(@c_cartonNoEnd AS INT) '

   SET @c_ExecStatements = @c_ExecStatements
     + N'GROUP BY PH.PickSlipNo'
     +         ', PD.LabelNo'
     +         ', OH.InvoiceNo'
     +         ', OH.ExternOrderKey'
     +         ', PD.CartonNo'
     +         ', OH.C_Company'
     +         ', OH.C_Address1'
     +         ', OH.C_Address2'
     +         ', OH.C_Address3'
     +         ', OH.C_Address4'
     +         ', OH.ConsigneeKey'
     +         ', CASE WHEN ISNULL(PH.Route,'''')='''' THEN OH.Route ELSE PH.Route END'
     +         ', OH.C_Zip'
     +         ', PH.OrderKey'
     +         ', OH.Notes2'
     +         ', OH.Type'
     +         ', OH.OrderKey'
     +         ', CONVERT(NVARCHAR(8),OH.DeliveryDate,3)'

   SET @c_ExecArguments = N'@c_PickSlipNo    NVARCHAR(40)'
                        + ',@c_cartonNoStart NVARCHAR(5)'
                        + ',@c_cartonNoEnd   NVARCHAR(5)'
                        + ',@c_StorerKey     NVARCHAR(15)'
                        + ',@c_DataWindow    NVARCHAR(40)'

   EXEC sp_ExecuteSql @c_ExecStatements
                    , @c_ExecArguments
                    , @c_PickSlipNo
                    , @c_cartonNoStart
                    , @c_cartonNoEnd
                    , @c_StorerKey
                    , @c_DataWindow
END
GO
GRANT EXECUTE ON isp_r_hk_carton_label_09 TO NSQL
GO