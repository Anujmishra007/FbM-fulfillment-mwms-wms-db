
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_1580DecodeSP01                                        */
/* Copyright: LF Logistics                                                    */
/*                                                                            */
/* Purpose: Decode RFID label                                                 */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2023-03-20  James     1.0   WMS-21943 Created                              */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_1580DecodeSP01 (
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR( 3),
   @nStep               INT,
   @nInputKey           INT,
   @cStorerKey          NVARCHAR( 15),
   @cReceiptKey         NVARCHAR( 10),
   @cPOKey              NVARCHAR( 10),
   @cLOC                NVARCHAR( 10),
   @cID                 NVARCHAR( 18),
   @cBarcode            NVARCHAR( 120),
   @cSKU                NVARCHAR( 20)     OUTPUT,
   @nQTY                INT               OUTPUT,
   @cLottable01         NVARCHAR( 18)     OUTPUT,
   @cLottable02         NVARCHAR( 18)     OUTPUT,
   @cLottable03         NVARCHAR( 18)     OUTPUT,
   @dLottable04         DATETIME          OUTPUT,
   @cSerialNoCapture    NVARCHAR(1) = 0   OUTPUT,
   @nErrNo              INT               OUTPUT,
   @cErrMsg             NVARCHAR( 20)     OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nBarcodeLen INT
   DECLARE @bSuccess    INT
   DECLARE @cTempSKU    NVARCHAR( 20)
   DECLARE @cErrMsg1    NVARCHAR( 125)
   DECLARE @cErrMsg2    NVARCHAR( 125)

   SET @cErrMsg1 = ''
   SET @cErrMsg2 = ''

   IF @nStep = 5 -- SKU/QTY
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         IF @cBarcode <> ''
         BEGIN
            SELECT TOP 1 @cTempSKU = SKU
            FROM dbo.UCC WITH (NOLOCK) 
            WHERE Storerkey = @cStorerKey 
            AND   UCCNo = @cBarcode
            AND   [Status] = '0'
            ORDER BY 1

            IF ISNULL( @cTempSKU, '') <> ''
            BEGIN
            	SELECT @nQTY = ISNULL( SUM( Qty), 0)
            	FROM dbo.UCC WITH (NOLOCK)
               WHERE Storerkey = @cStorerKey 
               AND   UCCNo = @cBarcode
               AND   [Status] = '0'

            	SET @cSKU = @cTempSKU
               SET @cSerialNoCapture = 2
            END
            ELSE
            BEGIN
         	   SET @nBarcodeLen = LEN( @cBarcode)
         	
         	   IF @nBarcodeLen <> 24
         	   BEGIN
                  EXEC [RDT].[rdt_GETSKU]
                      @cStorerKey  = @cStorerKey
                     ,@cSKU        = @cBarcode      OUTPUT
                     ,@bSuccess    = @bSuccess      OUTPUT
                     ,@nErr        = @nErrNo        OUTPUT
                     ,@cErrMsg     = @cErrMsg       OUTPUT
               
                  IF @nErrNo <> 0
                     GOTO Quit
                     
                  IF EXISTS ( SELECT 1
                              FROM dbo.SKU WITH (NOLOCK)
                              WHERE StorerKey = @cStorerKey
                              AND   Sku = @cBarcode
                              AND   SerialNoCapture = 1)
                  BEGIN
               	   SET @nErrNo = 197851
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Need Scan EPC
                     GOTO Quit
                  END

                  SET @cSKU = @cBarcode
         	   END
         	   ELSE
               BEGIN
                  SET @cTempSKU = SUBSTRING( @cBarcode, 1, 18)
               
                  EXEC [RDT].[rdt_GETSKU]
                      @cStorerKey  = @cStorerKey
                     ,@cSKU        = @cTempSKU      OUTPUT
                     ,@bSuccess    = @bSuccess      OUTPUT
                     ,@nErr        = @nErrNo        OUTPUT
                     ,@cErrMsg     = @cErrMsg       OUTPUT
               
                  IF @nErrNo <> 0
                  BEGIN
               	   SET @nErrNo = 197852
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  SKU Not In EPC
                     GOTO Quit
                  END 
               
                  SET @cSKU = @cTempSKU
               END
               
               SET @nQTY = 1
            END
         END
      END
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1580DecodeSP01 TO NSQL
GO
