SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_1580DecodeSP06                                        */
/* Copyright: MAERSK                                                          */
/*                                                                            */
/* Purpose: Decode RFID label                                                 */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2025-09-30  Ung       1.0   FCR-8040. Created                              */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1580DecodeSP06] (
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

   IF @nStep = 5 -- SKU/QTY
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         -- Composite barcode
         IF CHARINDEX( '&', @cBarcode) > 0
         BEGIN
            DECLARE @nRowCount INT
            DECLARE @cStyle NVARCHAR( 30)
            DECLARE @cSize  NVARCHAR( 30)
            DECLARE @cL01P1 NVARCHAR( 18)
            DECLARE @cL01P2 NVARCHAR( 18)
            DECLARE @cSNOP1 NVARCHAR( 10)
            DECLARE @cSNOP2 NVARCHAR( 10)
            DECLARE @cSNOP3 NVARCHAR( 10)
            DECLARE @cMasterSerialNo NVARCHAR( 50)
            
            DECLARE @tValue TABLE
            (
               value       NVARCHAR( 100), 
               RowNumber   INT
            )
            
            INSERT INTO @tValue (value, RowNumber)
            SELECT value, ROW_NUMBER() OVER ( ORDER BY (SELECT 1)) RowNumber 
            FROM STRING_SPLIT( @cBarcode, '&')
            
            SELECT 
               @cStyle = CASE WHEN RowNumber = 2 THEN value ELSE @cStyle END, 
               @cSize  = CASE WHEN RowNumber = 3 THEN value ELSE @cSize  END, 
               @cSNOP1 = CASE WHEN RowNumber = 4 THEN value ELSE @cSNOP1 END, 
               @cSNOP2 = CASE WHEN RowNumber = 5 THEN value ELSE @cSNOP2 END, 
               @cL01P1 = CASE WHEN RowNumber = 6 THEN value ELSE @cL01P1 END, 
               @cSNOP3 = CASE WHEN RowNumber = 7 THEN value ELSE @cSNOP3 END, 
               @cL01P2 = CASE WHEN RowNumber = 8 THEN value ELSE @cL01P2 END
            FROM @tValue
            
            -- Invalid barcode
            IF @@ROWCOUNT <> 8
            BEGIN
               SET @nErrNo = 248201
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidBarcode
               GOTO Quit
            END

            -- Get SKU
            SELECT @cSKU = SKU
            FROM dbo.SKU WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND BUSR5 = @cStyle
               AND BUSR6 = @cSize
               
            SET @nRowCount = @@ROWCOUNT
            
            -- Invalid SKU
            IF @nRowCount = 0
            BEGIN
               SET @nErrNo = 248202
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid SKU
               GOTO Quit
            END
            
            -- Multi SKU barcode
            ELSE IF @nRowCount > 1
            BEGIN
               SET @cSKU = ''
               SET @nErrNo = 248203
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Multi SKU
               GOTO Quit
            END
            
            SET @cMasterSerialNo = @cSNOP1 + @cSNOP2 + @cSNOP3
            
            -- Check serial no 
            IF NOT EXISTS( SELECT 1
               FROM dbo.MasterSerialNo WITH (NOLOCK)
               WHERE SerialNo = @cMasterSerialNo
                  AND StorerKey = @cStorerKey
                  AND SKU = @cSKU
                  AND UnitType <> 'UCC')
            BEGIN
               SET @nErrNo = 248204
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Master serial no not found
               GOTO Quit
            END

            SET @cLottable01 = @cL01P1 + @cL01P2
            
            -- Check lottable01 in ASN and has balance
            IF NOT EXISTS( SELECT TOP 1 1 
               FROM dbo.ReceiptDetail WITH (NOLOCK)
               WHERE ReceiptKey = @cReceiptKey
                  AND SKU = @cSKU
                  AND Lottable01 = @cLottable01
                  AND QTYExpected > BeforeReceivedQTY)
            BEGIN
               SET @nErrNo = 248205
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU L01 over received
               GOTO Quit
            END
            
            SET @nQTY = 1

            -- Check SKU and Lottable01 are different for ID
            IF LEFT( @cID, 2) <> 'DM'
            BEGIN
               SELECT TOP 1 1
               FROM dbo.ReceiptDetail WITH (NOLOCK)
               WHERE ReceiptKey = @cReceiptKey
                  AND ToID = @cID
                  AND BeforeReceivedQTY > 0

               IF @@ROWCOUNT > 0
               BEGIN
                  IF NOT EXISTS( SELECT 1
                     FROM dbo.ReceiptDetail WITH (NOLOCK)
                     WHERE ReceiptKey = @cReceiptKey
                        AND ToID = @cID
                        AND SKU = @cSKU
                        AND Lottable01 = @cLottable01)
                  BEGIN
                     SET @nErrNo = 248206
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Mix SKU on ID
                     GOTO Quit
                  END
               END
            END

            -- Retain in same screen
            -- SET @nErrNo = -1
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
GRANT EXECUTE ON  [RDT].[rdt_1580DecodeSP06] TO [NSQL]
GO