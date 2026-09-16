
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/************************************************************************/
/* Store procedure: rdt_1580ColDataSP01                                 */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Date         Rev   Author   Purposes                                 */
/* 2026-09-03   1.0   DWE324   Collect receipt/SKU/serial data for     */
/*                             scn 6928 V_DATA field                   */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1580ColDataSP01] (
   @nMobile    INT,
   @nStep      INT,
   @nScn       INT,
   @cXML       NVARCHAR( MAX) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nScn <> 1754 RETURN

   DECLARE @cStorerKey          NVARCHAR( 15)
   DECLARE @cReceiptKey         NVARCHAR( 10)
   DECLARE @cExternReceiptKey   NVARCHAR( 50)
   DECLARE @cData               NVARCHAR( MAX)
   DECLARE @cSkuRows            NVARCHAR( MAX)
   DECLARE @cReceiptDetailRows  NVARCHAR( MAX)
   DECLARE @cMasterSerialRows   NVARCHAR( MAX)

   SELECT
      @cStorerKey  = StorerKey,
      @cReceiptKey = V_ReceiptKey
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SELECT @cExternReceiptKey = RTRIM( ISNULL( ExternReceiptKey, ''))
   FROM dbo.RECEIPT WITH (NOLOCK)
   WHERE ReceiptKey  = @cReceiptKey
     AND StorerKey   = @cStorerKey

   -- skuRows
   SELECT @cSkuRows = (
      SELECT S.SKU   AS sku,
             S.BUSR5 AS busr5,
             S.BUSR6 AS busr6
      FROM dbo.RECEIPTDETAIL RD WITH (NOLOCK)
      JOIN dbo.SKU S WITH (NOLOCK)
         ON S.SKU       = RD.SKU
        AND S.StorerKey = RD.StorerKey
      WHERE RD.ReceiptKey  = @cReceiptKey
        AND RD.StorerKey   = @cStorerKey
        AND RD.QtyExpected > RD.QtyReceived
      FOR JSON PATH
   )

   -- receiptDetailRows
   SELECT @cReceiptDetailRows = (
      SELECT RD.SKU        AS sku,
             RD.Lottable01 AS lottable01
      FROM dbo.RECEIPTDETAIL RD WITH (NOLOCK)
      WHERE RD.ReceiptKey  = @cReceiptKey
        AND RD.StorerKey   = @cStorerKey
        AND RD.QtyExpected > RD.QtyReceived
      FOR JSON PATH
   )

   -- masterSerialRows
   SELECT @cMasterSerialRows = (
      SELECT MS.Sku      AS sku,
             MS.SerialNo AS serialNo
      FROM dbo.MASTERSERIALNO MS WITH (NOLOCK)
      WHERE MS.Attribute3 = @cExternReceiptKey
        AND MS.Storerkey  = @cStorerKey
      FOR JSON PATH
   )

   SET @cData = '{"skuRows":'           + ISNULL( @cSkuRows,           '[]') +
                ',"receiptDetailRows":' + ISNULL( @cReceiptDetailRows, '[]') +
                ',"masterSerialRows":'  + ISNULL( @cMasterSerialRows,  '[]') + '}'

   -- Base64-encode the JSON so FE can parse without HTML-entity unescaping
   DECLARE @vbData  VARBINARY(MAX)
   DECLARE @b64Data NVARCHAR(MAX)

   IF ISNULL( @cData, '') <> ''
   BEGIN
      SET @vbData  = CONVERT( VARBINARY(MAX), CONVERT( VARCHAR(MAX), @cData COLLATE Latin1_General_100_CI_AS_SC_UTF8))
      SET CONCAT_NULL_YIELDS_NULL ON
      SELECT @b64Data = CAST( N'' AS XML).value( 'xs:base64Binary(sql:variable("@vbData"))', 'VARCHAR(MAX)')
      SET CONCAT_NULL_YIELDS_NULL OFF
   END

   -- Append V_DATA input field to XML
   SET @cXML = @cXML + '<field typ="hidden" id="V_DATA" default="' + ISNULL( @b64Data, '') + '"/>'
END
GO
GRANT EXECUTE ON [RDT].[rdt_1580ColDataSP01] TO [NSQL]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
