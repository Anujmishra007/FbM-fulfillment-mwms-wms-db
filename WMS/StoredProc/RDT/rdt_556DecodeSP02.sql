SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
 
/************************************************************************/
/* Store procedure: rdt_556DecodeSP02                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: QR Code decode for Inquiry (SKU, Batch, Mfg, Exp, Dept)     */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author      Purposes                                */
/* 2025-12-15  1.0  SSR259      FCR-9646 Created                        */
/************************************************************************/
 
CREATE or ALTER PROCEDURE [RDT].[rdt_556DecodeSP02] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cStorerKey     NVARCHAR( 15),
   @cBarcode       NVARCHAR( 60),
   @cSKU           NVARCHAR( 20)  OUTPUT,
   @cLOC           NVARCHAR( 10)  OUTPUT,
   @cLottable01    NVARCHAR( 18)  OUTPUT,
   @cLottable02    NVARCHAR( 18)  OUTPUT,
   @cLottable03    NVARCHAR( 18)  OUTPUT,
   @dLottable04    DATETIME       OUTPUT,
   @dLottable05    DATETIME       OUTPUT,
   @cLottable06    NVARCHAR( 30)  OUTPUT,
   @cLottable07    NVARCHAR( 30)  OUTPUT,
   @cLottable08    NVARCHAR( 30)  OUTPUT,
   @cLottable09    NVARCHAR( 30)  OUTPUT,
   @cLottable10    NVARCHAR( 30)  OUTPUT,
   @cLottable11    NVARCHAR( 30)  OUTPUT,
   @cLottable12    NVARCHAR( 30)  OUTPUT,
   @dLottable13    DATETIME       OUTPUT,
   @dLottable14    DATETIME       OUTPUT,
   @dLottable15    DATETIME       OUTPUT,
   @cUserDefine01  NVARCHAR( 60)  OUTPUT,
   @cUserDefine02  NVARCHAR( 60)  OUTPUT,
   @cUserDefine03  NVARCHAR( 60)  OUTPUT,
   @cUserDefine04  NVARCHAR( 60)  OUTPUT,
   @cUserDefine05  NVARCHAR( 60)  OUTPUT,
   @nErrNo         INT            OUTPUT,
   @cErrMsg        NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
 
   DECLARE @nDebugFlag  INT = 0
 
   DECLARE
      @cTempSKU            NVARCHAR( 20)
      ,@cTempLottable01    NVARCHAR( 18)
      ,@cTempLottable02    NVARCHAR( 18)
      ,@cTempLottable04    NVARCHAR(100)
      ,@cTempLottable13    NVARCHAR(100)
      ,@nRowCount    INT
 
    DECLARE @tDecodeList TABLE
   (
      ItemIndex   INT NOT NULL,
      Item        NVARCHAR (100)      
   )
 
   SET @nErrNo = 0
 
   IF @nFunc = 556 -- SKU Inquiry
   BEGIN
      IF @nStep = 1 -- LOC/SKU
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Check if it is a QR code (contains &)
            -- Decode: extract SKU only (keep errors for bad format / parse)
			
            IF CHARINDEX('&', @cBarcode) > 0
            BEGIN
			
                -- Expect exactly 4 ampersands for the QR format
                IF (LEN(@cBarcode) - LEN(REPLACE(@cBarcode, '&',''))) <> 4
                BEGIN
                   SET @nErrNo = 253901 -- Error InvFormat
                   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                   SET @cSKU = '' 
                   GOTO Quit
                END
 
                BEGIN TRY
                   INSERT INTO @tDecodeList
                   SELECT [key]+1 AS ItemIndex, value AS Item
                   FROM OPENJSON('["' + REPLACE(@cBarcode, '&', '","') + '"]');
                END TRY
                BEGIN CATCH
                   SET @nErrNo = 253902 -- Error DecodeFailure
                   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                   SET @cSKU = '' 
                   GOTO Quit
                END CATCH
		
                -- Only read SKU (index 1) and attach to output
                SELECT @cTempSKU = Item FROM @tDecodeList WHERE ItemIndex = 1;
 
                SET @cSKU = @cTempSKU;
            END
            ELSE
            BEGIN
                -- Barcode (no '&'): treat entire barcode as SKU
                SET @cSKU = @cBarcode;
            END
 
 
            -- SKU Validation (Common for both QR and Barcode)
            IF NOT EXISTS (SELECT 1 FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU)
            BEGIN
               SET @nErrNo = 253905 -- Error InvalidSKU
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               SET @cSKU = '' 
               GOTO Quit
            END
         END
      END
   END



   
Quit:
   IF @nDebugFlag = 1 AND @nErrNo <> 0
   BEGIN
      INSERT INTO dbo.TraceInfo
      (
         TraceName,
         TimeIn,
         Step1,
         Step2,
         Col1,
         Col2,
         Col3,
         Col4,
         Col5
      )
      VALUES
      (
         'rdt_556DecodeSP02',
         GETDATE(),
         CAST(@nMobile AS NVARCHAR(10)),
         @cStorerKey,
         CAST(@nErrNo AS NVARCHAR(10)),
         @cBarcode,
         '',
         '',
         ''
      )
   END

   IF @nDebugFlag = 1
      SELECT 'Quit', @nErrNo AS ErrNo, @cSKU AS SKU, @dLottable13 AS LOT13, @dLottable04 AS LOT4,
               @cLottable02 AS LOT2
END
GO

GRANT EXECUTE ON rdt.rdt_556DecodeSP02 TO NSQL
GO