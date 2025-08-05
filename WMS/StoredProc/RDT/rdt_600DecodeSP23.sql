
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_600DecodeSP23                                         */
/* Copyright:                                                                 */
/*                                                                            */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2025-06-23  Dennis    1.0   FCR-5716 Decode Sp                             */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_600DecodeSP23] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cStorerKey   NVARCHAR( 15),
   @cReceiptKey  NVARCHAR( 10),
   @cPOKey       NVARCHAR( 10),
   @cLOC         NVARCHAR( 10),
   @cBarcode     NVARCHAR( 2000)  OUTPUT,
   @cFieldName   NVARCHAR( 10),
   @cID          NVARCHAR( 18)  OUTPUT,
   @cSKU         NVARCHAR( 20)  OUTPUT,
   @nQTY         INT            OUTPUT,
   @cLottable01  NVARCHAR( 18)  OUTPUT,
   @cLottable02  NVARCHAR( 18)  OUTPUT,
   @cLottable03  NVARCHAR( 18)  OUTPUT,
   @dLottable04  DATETIME       OUTPUT,
   @dLottable05  DATETIME       OUTPUT,
   @cLottable06  NVARCHAR( 30)  OUTPUT,
   @cLottable07  NVARCHAR( 30)  OUTPUT,
   @cLottable08  NVARCHAR( 30)  OUTPUT,
   @cLottable09  NVARCHAR( 30)  OUTPUT,
   @cLottable10  NVARCHAR( 30)  OUTPUT,
   @cLottable11  NVARCHAR( 30)  OUTPUT,
   @cLottable12  NVARCHAR( 30)  OUTPUT,
   @dLottable13  DATETIME       OUTPUT,
   @dLottable14  DATETIME       OUTPUT,
   @dLottable15  DATETIME       OUTPUT,
   @nErrNo       INT            OUTPUT,
   @cErrMsg      NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nSKUCnt INT
   DECLARE @cUOM NVARCHAR(20)
   DECLARE @cPackKey NVARCHAR(20),
   @cBUSR10              NVARCHAR(20),      
   @cOption              NVARCHAR(1),
   @cCaseID              NVARCHAR(12),
   @nNetWt               INT

   IF @nFunc = 600 -- Normal receiving
   BEGIN
      IF @nStep = 4 -- SKU
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT @cSKU = SUBSTRING(@cBarcode, 5, 14)
            BEGIN TRY
               IF EXISTS (SELECT 1 FROM SKU WHERE itemclass='PVAR' AND AltSKU = @cSKU AND StorerKey = @cStorerKey AND BUSR10 = 'NewZealand')
               BEGIN
                  --NewZealand
                  SELECT 
                     @nQty = CAST(SUBSTRING(@cBarcode, 35, 6) AS DECIMAL(8,2)) * 10,
                     @cCaseID = SUBSTRING(@cBarcode, 45, 12)
                  SELECT @cSKU = SKU FROM SKU WHERE AltSKU = @cSKU AND StorerKey = @cStorerKey
                  IF EXISTS (SELECT 1 FROM ReceiptDetail(NOLOCK) WHERE @cReceiptKey = ReceiptKey AND UserDefine10 = @cCaseID)
                  BEGIN
                     SET @nErrNo = 240751
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --case already received
                     GOTO Quit
                  END
               END
               ELSE IF EXISTS (SELECT 1 FROM SKU WHERE itemclass='PVAR' AND AltSKU = @cSKU AND StorerKey = @cStorerKey AND BUSR10 ='BRAZIL')
               BEGIN
                  -- Check if its a Brazil SKU
                  SELECT @cSKU = SKU FROM SKU WHERE AltSKU = @cSKU AND StorerKey = @cStorerKey
                  SELECT @nQty = CAST(SUBSTRING(@cBarcode, 25, 6) AS INT)
               END
               ELSE IF EXISTS (SELECT 1 FROM SKU WHERE itemclass='PVAR' AND SKU = @cBarcode AND StorerKey = @cStorerKey AND BUSR10 IN('BRAZIL','NewZealand'))
               BEGIN
                  SET @nErrNo = 240753
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid barcode format
                  GOTO Quit
               END
               ELSE
                  SELECT @cSKU = @cBarcode
            END TRY
            BEGIN CATCH
               SET @nErrNo = 240752
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid barcode format
               GOTO Quit
            END CATCH
         END
      END
   END

Quit:
   UPDATE RDT.RDTMOBREC WITH (ROWLOCK) SET
      C_String1 = @cCaseID
   WHERE Mobile = @nMobile
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_600DecodeSP23 TO NSQL
GO