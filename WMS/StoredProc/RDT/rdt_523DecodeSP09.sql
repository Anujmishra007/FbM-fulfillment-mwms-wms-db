
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************/
/* Store procedure: rdt_523DecodeSP09                                         */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Purpose: QRCode Decode                                               */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2025-12-29  SSR259    1.0   FCR-9024 Created                               */
/******************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_523DecodeSP09] (
   @nMobile           INT,           
   @nFunc             INT,           
   @cLangCode         NVARCHAR( 3),  
   @nStep             INT,           
   @nInputKey         INT,           
   @cFacility         NVARCHAR( 5),  
   @cStorerKey        NVARCHAR( 15), 
   @cBarcode          NVARCHAR( 60), 
   @cBarcodeUCC       NVARCHAR( 200), 
   @cID               NVARCHAR( 18)  OUTPUT, 
   @cUCC              NVARCHAR( 20)  OUTPUT, 
   @cLOC              NVARCHAR( 10)  OUTPUT, 
   @cSKU              NVARCHAR( 20)  OUTPUT, 
   @nQTY              INT            OUTPUT, 
   @cSerialNo         NVARCHAR( 30)  OUTPUT, 
   @cLottable01       NVARCHAR( 18)  OUTPUT, 
   @cLottable02       NVARCHAR( 18)  OUTPUT, 
   @cLottable03       NVARCHAR( 18)  OUTPUT, 
   @dLottable04       DATETIME       OUTPUT, 
   @nErrNo            INT            OUTPUT, 
   @cErrMsg           NVARCHAR( 120)  OUTPUT    
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
 
   DECLARE @nDebugFlag  INT = 0
 
   DECLARE
      @cTempSKU            NVARCHAR( 20)
      -- ,@cTempLottable01    NVARCHAR( 18)
      -- ,@cTempLottable02    NVARCHAR( 18)
      -- ,@cTempLottable03    NVARCHAR(100)
      -- ,@cTempLottable04    NVARCHAR(100)
      ,@nRowCount    INT
 
    DECLARE @tDecodeList TABLE
   (
      ItemIndex   INT NOT NULL,
      Item        NVARCHAR (100)      
   )
 
   SET @nErrNo = 0
 
   IF @nFunc = 523 -- SKU Inquiry
   BEGIN
      IF @nStep = 2 -- LOC/SKU
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
                   SET @nErrNo = 254851 -- Error InvFormat
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
                   SET @nErrNo = 254852 -- Error DecodeFailure
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
               SET @nErrNo = 254855 -- Error InvalidSKU
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
         'rdt_523DecodeSP09',
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
      SELECT 'Quit', @nErrNo AS ErrNo, @cSKU AS SKU
END
GO

GRANT EXECUTE ON rdt.rdt_523DecodeSP09 TO NSQL
GO