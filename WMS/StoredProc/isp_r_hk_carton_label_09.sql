if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_r_hk_carton_label_09]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[isp_r_hk_carton_label_09]
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
/* 27/08/2018  ML       WMS-6130 Update Route logic for Converse (ML01)  */
/* 29/11/2018  ML       WMS-7117 Add generic route code (ML02)           */
/* 04/01/2019  ML       WMS-7468 Add ReportCfg ShowFields (ML03)         */
/*************************************************************************/
CREATE PROCEDURE [dbo].[isp_r_hk_carton_label_09] (
   @c_StorerKey NVARCHAR(15),--ang01
   @c_PickSlipNo NVARCHAR(40),
   @c_cartonNoStart NVARCHAR(5), --ang01
   @c_cartonNoEnd NVARCHAR(5)  --ang01
)
AS
BEGIN
   SET NOCOUNT ON   -- SQL 2005 Standard
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
   @c_startNumber          NVARCHAR(20),
   @c_selectedNumber       NVARCHAR(20),
   @c_endNumber            NVARCHAR(20),
   @c_externorderkey_start NVARCHAR(20),
   @c_externorderkey_end   NVARCHAR(20),
   @c_orderkey_start       NVARCHAR(10),
   @c_orderkey_end         NVARCHAR(10),
   @nPosStart int, @nPosEnd int,
   @nDashPos                int,
   @c_ExecStatements     nvarchar(4000),
   @c_ExecStatements1    nvarchar(4000),
   @c_ExecStatements2    nvarchar(4000),
   @c_ExecStatements3    nvarchar(4000),
   @c_ExecStatements4    nvarchar(4000),
   @c_ExecStatementsMain nvarchar(4000),
   @c_ExecArguments      nvarchar(4000)

   IF LEFT(@c_PickSlipNo, 1) <> 'P'
   BEGIN
      IF CHARINDEX('-',@c_PickSlipNo) > 0
      BEGIN
         SET @c_PickSlipNo = @c_PickSlipNo
         SET @nDashPos = CHARINDEX('-',@c_PickSlipNo)

         --To retrieve Orderkey/ExternOrderKey Start
         SET @nPosStart = 1
         SET @nPosEnd = @nDashPos - 1

         SET @c_startNumber=(SELECT SUBSTRING(@c_PickSlipNo, @nPosStart, @nPosEnd) AS StartOrderKey)

         SET @c_selectedNumber = (SELECT ISNULL(orderkey,0) FROM Orders (NOLOCK) WHERE orderkey = @c_startNumber)
         IF @c_selectedNumber <> NULL
         BEGIN
            SET @c_orderkey_start = @c_startNumber
         END
         ELSE
         BEGIN
            SET @c_externorderkey_start = @c_startNumber
         END

         --To retrieve Orderkey/ExternOrderKey End
         SET @nPosStart = @nDashPos + 1
         SET @nPosEnd =  LEN(@c_PickSlipNo) - @nDashPos
         SET @c_endNumber = (SELECT SUBSTRING(@c_PickSlipNo, @nPosStart, @nPosEnd) AS EndOrderKey)

         SET @c_selectedNumber = (SELECT ISNULL(orderkey,0) FROM orders (NOLOCK) WHERE orderkey = @c_endNumber)
         IF @c_selectedNumber <> NULL
         BEGIN
            SET @c_orderkey_end = @c_endNumber
         END
         ELSE
         BEGIN
            SET @c_externorderkey_end = @c_endNumber
         END
      END
      ELSE
      BEGIN
         SET @c_startNumber = (SELECT ISNULL(orderkey,0) FROM orders (NOLOCK) WHERE orderkey = @c_PickSlipNo)
         IF @c_startNumber <> NULL
         BEGIN
            SET @c_orderkey_start = @c_PickSlipNo
            SET @c_orderkey_end = @c_PickSlipNo
         END
         ELSE
         BEGIN
            SET @c_externorderkey_start = @c_PickSlipNo
            SET @c_externorderkey_end = @c_PickSlipNo
         END
      END
   END

   SET @c_ExecStatements = N'SELECT PACKHEADER.PickSlipNo,'+
      'PACKDETAIL.LabelNo, '+
      'ORDERS.InvoiceNo, '+
      'ORDERS.ExternOrderKey, '+
      'PACKDETAIL.CartonNo, '+
      'ORDERS.Userdefine04, '+
      'ORDERS.C_Company, '+
      'ORDERS.C_Address1, '+
      'ORDERS.C_Address2, '+
      'ORDERS.C_Address3, '+
      'ORDERS.C_Address4, '+
      'ORDERS.ConsigneeKey, '+  --(HFLiew01)
-- (ML01)      'PACKHEADER.Route, '+
      'Route = CASE WHEN ISNULL(PACKHEADER.Route,'''')='''' THEN ORDERS.Route ELSE PACKHEADER.Route END, '+   -- (ML01)
      'ORDERS.C_Zip, '+
      'SysDate=CONVERT(CHAR(19), CONVERT(CHAR(10), GetDate(), 103) + '' '' + CONVERT(CHAR(8), GetDate(), 108)),'

   IF LEFT(@c_PickSlipNo, 1) = 'P'
   BEGIN
      SET @c_ExecStatements1 = N'(SELECT COUNT(*)'+
         'FROM PACKHEADER P (NOLOCK) JOIN ORDERDETAIL OD (NOLOCK)'+
         'ON P.OrderKey = OD.OrderKey '+
         'WHERE P.PickSlipNo = @c_PickSlipNo '+
         'AND OD.UserDefine05 > ''0'') as PriceLabel,'+
         'SUBSTRING(ORDERS.Notes2, 1, 30) as Notes2,'+
         'CASE ORDERS.Type WHEN ''D'' THEN ''D'' WHEN ''R'' THEN ''R'' ELSE Orders.type END As CartonType,'+
         'ORDERS.OrderKey,CONVERT(NVARCHAR(8),ORDERS.DeliveryDate,3) AS DeliveryDate '                               --(CS01)
   END

   IF @c_orderkey_start <> NULL AND @c_orderkey_end <> NULL
   BEGIN
      SET @c_ExecStatements1 = N'(SELECT COUNT(*)'+
      'FROM PACKHEADER P (NOLOCK) JOIN ORDERDETAIL OD (NOLOCK)'+
      'ON P.OrderKey = OD.OrderKey '+
            'WHERE  P.OrderKey BETWEEN @c_orderkey_start AND @c_orderkey_end '+
      'AND OD.UserDefine05 > ''0'') as PriceLabel,'+
      'SUBSTRING(ORDERS.Notes2, 1, 30) as Notes2,'+
      'CASE ORDERS.Type WHEN ''D'' THEN ''D'' WHEN ''R'' THEN ''R'' ELSE Orders.type END As CartonType,'+
      'ORDERS.OrderKey,CONVERT(NVARCHAR(8),ORDERS.DeliveryDate,3) AS DeliveryDate '           --(CS01)
   END

   IF @c_externorderkey_start <> NULL AND @c_externorderkey_end <> NULL
   BEGIN
      SET @c_ExecStatements1 = N'(SELECT COUNT(*)'+
      'FROM PACKHEADER P (NOLOCK) JOIN ORDERDETAIL OD (NOLOCK)'+
      'ON P.OrderKey = OD.OrderKey '+
            'WHERE  P.OrderRefNo BETWEEN @c_externorderkey_start AND @c_externorderkey_end '+
      'AND OD.UserDefine05 > ''0'') as PriceLabel,'+
      'SUBSTRING(ORDERS.Notes2, 1, 30) as Notes2,'+
      'CASE ORDERS.Type WHEN ''D'' THEN ''D'' WHEN ''R'' THEN ''R'' ELSE Orders.type END As CartonType,'+
      'ORDERS.OrderKey,CONVERT(NVARCHAR(8),ORDERS.DeliveryDate,3) AS DeliveryDate '          --(CS01)
   END

   SET @c_ExecStatements1 = @c_ExecStatements1  -- (ML02)
     + ',ZipCodeFrom=MAX(ROUTEMASTER.ZipCodeFrom) '  -- (ML02)
     + ',ShowFields=MAX(RptCfg.ShowFields) '  -- (ML03)
     
   SET @c_ExecStatements2 = N'FROM ORDERS ORDERS (NOLOCK) '+
     'JOIN PACKHEADER PACKHEADER (NOLOCK) ON (ORDERS.OrderKey = PACKHEADER.OrderKey)'+
     'JOIN PACKDETAIL PACKDETAIL (NOLOCK) ON (PACKHEADER.PickSlipNo = PACKDETAIL.PickSlipNo)  '+
     'JOIN SKU SKU (NOLOCK) ON (PACKDETAIL.Sku = SKU.Sku AND PACKDETAIL.StorerKey = SKU.StorerKey)'+
     'JOIN STORER (NOLOCK) ON (ORDERS.StorerKey = STORER.StorerKey) '+
     'LEFT OUTER JOIN STORER STORERContact (NOLOCK) ON ( STORERContact.Type = ''2'' AND STORERContact.StorerKey = ORDERS.ConsigneeKey)  '+
     'LEFT OUTER JOIN STORER IDS (NOLOCK) ON (IDS.Storerkey = ''11301'')'
  + ' LEFT OUTER JOIN ROUTEMASTER (NOLOCK) ON (ORDERS.Route=ROUTEMASTER.Route)'  -- (ML02)
  + ' LEFT OUTER JOIN (SELECT Storerkey, ShowFields = LTRIM(RTRIM(UDF01)) + LOWER(LTRIM(RTRIM(Notes))) + LTRIM(RTRIM(UDF01))'  -- (ML03)
  +      ', SeqNo=ROW_NUMBER() OVER(PARTITION BY Storerkey ORDER BY Code2)'  -- (ML03)
  +      ' FROM dbo.CodeLkup (NOLOCK) WHERE Listname=''REPORTCFG'' AND Code=''SHOWFIELD'' AND Long=''r_hk_carton_label_09'' AND Short=''Y'''  -- (ML03)
  + ' ) RptCfg ON RptCfg.Storerkey=ORDERS.Storerkey AND RptCfg.SeqNo=1'  -- (ML03)

   IF LEFT(@c_PickSlipNo, 1) = 'P'
   BEGIN
      SET @c_ExecStatements3 = N'WHERE PACKHEADER.PickSlipNo = @c_PickSlipNo AND ORDERS.StorerKey = @c_StorerKey '+
      'AND PACKDETAIL.CartonNo BETWEEN CAST(@c_cartonNoStart as int) AND CAST(@c_cartonNoEnd as Int) '
   END

   IF @c_orderkey_start <> NULL AND @c_orderkey_end <> NULL
   BEGIN
      SET @c_ExecStatements3 = N'WHERE PACKHEADER.OrderKey BETWEEN @c_orderkey_start AND @c_orderkey_end '+
      'AND ORDERS.StorerKey = @c_StorerKey '+
      'AND PACKDETAIL.CartonNo BETWEEN CAST(@c_cartonNoStart as int) AND CAST(@c_cartonNoEnd as Int) '
   END

   IF @c_externorderkey_start <> NULL AND  @c_externorderkey_end <> NULL
   BEGIN
      SET @c_ExecStatements3 = N'WHERE PACKHEADER.OrderRefNo BETWEEN @c_externorderkey_start AND @c_externorderkey_end '+
      'AND ORDERS.StorerKey = @c_StorerKey '+
      'AND PACKDETAIL.CartonNo BETWEEN CAST(@c_cartonNoStart as int) AND CAST(@c_cartonNoEnd as Int) '
   END

   SET @c_ExecStatements4 = N'GROUP BY PACKHEADER.PickSlipNo, '+
   'PACKDETAIL.LabelNo, '+
   'ORDERS.InvoiceNo, '+
   'ORDERS.ExternOrderKey, '+
   'PACKDETAIL.CartonNo, '+
   'ORDERS.Userdefine04, '+
   'ORDERS.C_Company, '+
   'ORDERS.C_Address1, '+
   'ORDERS.C_Address2, '+
   'ORDERS.C_Address3, '+
   'ORDERS.C_Address4, '+
   'ORDERS.ConsigneeKey, '+
-- (ML01)   'PACKHEADER.Route, '+
   'CASE WHEN ISNULL(PACKHEADER.Route,'''')='''' THEN ORDERS.Route ELSE PACKHEADER.Route END, '+   -- (ML01)
   'ORDERS.C_Zip, '+
   'PACKHEADER.OrderKey,'+
   'SUBSTRING(ORDERS.Notes2, 1, 30),'+
   'ORDERS.Type,'+
   'ORDERS.OrderKey,'+
   'CONVERT(NVARCHAR(8),ORDERS.DeliveryDate,3) '                             --(CS01)

   SET @c_ExecStatementsMain = @c_ExecStatements + @c_ExecStatements1 + @c_ExecStatements2+ @c_ExecStatements3+ @c_ExecStatements4
   SET @c_ExecArguments = N'@c_PickSlipNo NVARCHAR(40), ' +
                           '@c_cartonNoStart NVARCHAR(5), ' + --ang01
                           '@c_cartonNoEnd NVARCHAR(5), ' + --ang01
                           '@c_StorerKey NVARCHAR(15), '+ --ang01
                           '@c_externorderkey_start NVARCHAR(20),'+
                           '@c_externorderkey_end   NVARCHAR(20),'+
                           '@c_orderkey_start NVARCHAR(10),'+
                           '@c_orderkey_end   NVARCHAR(10)'


   EXEC sp_ExecuteSql @c_ExecStatementsMain
                     ,@c_ExecArguments
                     ,@c_PickSlipNo
                     ,@c_cartonNoStart
                     ,@c_cartonNoEnd
                     ,@c_StorerKey
                     ,@c_externorderkey_start
                     ,@c_externorderkey_end
                     ,@c_orderkey_start
                     ,@c_orderkey_end

END
GO

GRANT EXECUTE ON isp_r_hk_carton_label_09 TO NSQL
GO