
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
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag  INT = 1
   DECLARE @cTempSKU            NVARCHAR( 20)
   DECLARE @tDecodeList TABLE (ItemIndex INT NOT NULL, Item NVARCHAR (100))
   DECLARE @cBarcodeClean NVARCHAR(60) = TRIM(@cBarcode)
   DECLARE @cUCCSKU  NVARCHAR (20)
   DECLARE @bValidateSKU BIT = 0
   SET @nErrNo = 0
   SET @cBarcodeUCC = replace(TRIM(@cBarcodeUCC),' ','')
   IF @nFunc = 523
   BEGIN
      IF @nStep = 1
      BEGIN
         IF LEN(@cBarcodeUCC) IN (40,44)
         BEGIN
            SELECT 
            @cUCC = CASE 
               WHEN CHARINDEX('(240)', @cBarcodeUCC) > 0 THEN
                     SUBSTRING(
                        @cBarcodeUCC,
                        CHARINDEX('(240)', @cBarcodeUCC) + 5,
                        LEN(@cBarcodeUCC)
                     )
               ELSE NULL
            END
         END
         ELSE IF LEN(@cBarcodeUCC) = 34
         BEGIN
            SELECT 
               @cUCC = RIGHT(@cBarcodeUCC, 20)
         END
         ELSE IF LEN(@cBarcodeUCC) = 67
         BEGIN
            SELECT 
               @cUCC = SUBSTRING(@cBarcodeUCC, 19, 19)
         END

      END
      IF @nStep = 2 -- Sku
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF LEN(@cBarcodeClean) > 0
            BEGIN
               IF CHARINDEX('&', @cBarcodeClean) > 0
               BEGIN
                  IF (LEN(@cBarcodeClean) - LEN(REPLACE(@cBarcodeClean, '&',''))) <> 4
                  BEGIN
                     SET @nErrNo = 254851
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                     SET @cSKU = ''
                     GOTO Quit
                  END

                  BEGIN TRY
                     INSERT INTO @tDecodeList
                     SELECT [key]+1 AS ItemIndex, value AS Item
                     FROM OPENJSON('["' + REPLACE(@cBarcodeClean, '&', '","') + '"]')
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 254852
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                     SET @cSKU = ''
                     GOTO Quit
                  END CATCH

                  SELECT @cTempSKU = Item FROM @tDecodeList WHERE ItemIndex = 1;
                  SET @cSKU = @cTempSKU
               END
               ELSE
               BEGIN
                  SET @cSKU = @cBarcodeClean
               END

               SET @bValidateSKU = 1
               GOTO Step2End
            END

            IF LEN(@cBarcodeUCC) = 17
            BEGIN
               SELECT @cSKU = 
               CASE 
                  WHEN CHARINDEX('(21)', @cBarcodeUCC) > 0 AND CHARINDEX('(241)', @cBarcodeUCC) > CHARINDEX('(21)', @cBarcodeUCC) THEN
                        SUBSTRING(
                           @cBarcodeUCC,
                           CHARINDEX('(21)', @cBarcodeUCC) + 4,
                           CHARINDEX('(241)', @cBarcodeUCC) - CHARINDEX('(21)', @cBarcodeUCC) - 4
                        )
                  ELSE NULL
               END
            END
            ELSE
            BEGIN 
               SELECT @cSKU = SKU FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND ALTSKU = @cBarcodeUCC
               IF @@ROWCOUNT = 0
                  SET @cSKU = @cBarcodeUCC
            END

            SET @bValidateSKU = 1
            Step2End:
            ;
         END
      END
   END

   IF @bValidateSKU = 1
   BEGIN
      IF ISNULL(@cSKU, '') = ''
      BEGIN
         SET @nErrNo = 254855
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         SET @cSKU = ''
      END

      IF NOT EXISTS (SELECT 1 FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU)
      BEGIN
         SET @nErrNo = 254855
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         SET @cSKU = '' 
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
      SELECT 'Quit', @nErrNo AS ErrNo, @cSKU AS SKU, @dLottable04 AS LOT4
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_523DecodeSP09 TO NSQL
GO

