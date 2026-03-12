SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
 
/************************************************************************/
/* Store procedure: rdt_629DecodeSP01                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: QR Code decode for SKU (SKU, Batch, Mfg, Exp, Dept)         */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author      Purposes                                */
/* 2025-12-15  1.0  BHA212     FCR-9582 Created                         */
/* 2026-03-04  1.1  BHA212     FCR-9582 Fix date format DD/MM/YYYY      */
/* 2026-03-05  1.2  BHA212     FCR-9582 Custom DD/MM/YYYY validation    */
/*                             (rdtIsValidDate uses user date format)   */
/************************************************************************/
 
CREATE OR ALTER PROCEDURE [RDT].[rdt_629DecodeSP01] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cStorerKey     NVARCHAR( 15),
   @cBarcode       NVARCHAR( 60),
   @cID            NVARCHAR( 18)  OUTPUT,
   @cSKU           NVARCHAR( 20)  OUTPUT,
   @nQTY           INT            OUTPUT,
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
      ,@cConvertedDate     NVARCHAR(100)
      ,@nRowCount          INT
      -- DD/MM/YYYY validation variables
      ,@nDD                INT
      ,@nMM                INT
      ,@nYYYY              INT
      ,@nLastDayOfMonth    INT
 
    DECLARE @tDecodeList TABLE
   (
      ItemIndex   INT NOT NULL,
      Item        NVARCHAR (100)      
   )
 
   IF @nFunc = 629 -- Move SKU Lottable V7
   BEGIN
      IF @nStep = 3 -- SKU
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Check if it is a QR code (contains &)
            IF CHARINDEX('&', @cBarcode) > 0
            BEGIN
                -- check for '&'
                IF (LEN(@cBarcode) - LEN(REPLACE(@cBarcode, '&',''))) <> 4
                BEGIN
                   SET @nErrNo = 254051 -- Error InvFormat
                   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                   GOTO Quit
                END
 
                BEGIN TRY
                   INSERT INTO @tDecodeList
                   SELECT [key]+1 AS ItemIndex, value AS Item
                   FROM OPENJSON('["' + REPLACE(@cBarcode, '&', '","') + '"]');
                END TRY
                BEGIN CATCH
                   SET @nErrNo = 254052 -- Error DecodeFailure
                   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                   GOTO Quit
                END CATCH
 
                -- Extract values based on index mapping:
                -- 1: SKU
                -- 2: Batch (Lottable01)
                -- 3: Mfg Date (Lottable13)
                -- 4: Exp Date (Lottable04)
                -- 5: Dept Code (Lottable02)
                SELECT @cTempSKU        = Item FROM @tDecodeList WHERE ItemIndex = 1
                SELECT @cTempLottable01 = Item FROM @tDecodeList WHERE ItemIndex = 2
                SELECT @cTempLottable13 = Item FROM @tDecodeList WHERE ItemIndex = 3
                SELECT @cTempLottable04 = Item FROM @tDecodeList WHERE ItemIndex = 4
                SELECT @cTempLottable02 = Item FROM @tDecodeList WHERE ItemIndex = 5
 
                IF @nDebugFlag = 1
                   SELECT 'DecodeValues', @cTempSKU AS SKU, @cTempLottable01 AS LOT1,
                            @cTempLottable13 AS LOT13, @cTempLottable04 AS LOT4, @cTempLottable02 AS LOT2
 
                SET @cSKU = @cTempSKU
                SET @cLottable01 = @cTempLottable01
                SET @cLottable02 = @cTempLottable02
 
                -- Validate and Convert Mfg Date (Lottable13) - QR code format is DD/MM/YYYY
                IF @cTempLottable13 <> ''
                BEGIN
                   -- Validate DD/MM/YYYY format (length must be 10)
                   IF LEN(@cTempLottable13) <> 10 OR
                      SUBSTRING(@cTempLottable13, 3, 1) <> '/' OR
                      SUBSTRING(@cTempLottable13, 6, 1) <> '/'
                   BEGIN
                      SET @nErrNo = 254053 -- Error InvalidDate
                      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                      GOTO Quit
                   END

                   -- Extract and validate DD, MM, YYYY
                   BEGIN TRY
                      SET @nDD = CAST(SUBSTRING(@cTempLottable13, 1, 2) AS INT)
                      SET @nMM = CAST(SUBSTRING(@cTempLottable13, 4, 2) AS INT)
                      SET @nYYYY = CAST(SUBSTRING(@cTempLottable13, 7, 4) AS INT)
                   END TRY
                   BEGIN CATCH
                      SET @nErrNo = 254053 -- Error InvalidDate
                      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                      GOTO Quit
                   END CATCH

                   -- Validate ranges
                   IF @nMM < 1 OR @nMM > 12 OR @nDD < 1 OR @nDD > 31 OR @nYYYY < 1900 OR @nYYYY > 9999
                   BEGIN
                      SET @nErrNo = 254053 -- Error InvalidDate
                      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                      GOTO Quit
                   END

                   -- Validate last day of month
                   IF @nMM IN (1, 3, 5, 7, 8, 10, 12) SET @nLastDayOfMonth = 31
                   ELSE IF @nMM IN (4, 6, 9, 11) SET @nLastDayOfMonth = 30
                   ELSE IF @nMM = 2
                   BEGIN
                      IF (@nYYYY % 4 = 0 AND @nYYYY % 100 <> 0) OR (@nYYYY % 400 = 0)
                         SET @nLastDayOfMonth = 29
                      ELSE
                         SET @nLastDayOfMonth = 28
                   END

                   IF @nDD > @nLastDayOfMonth
                   BEGIN
                      SET @nErrNo = 254053 -- Error InvalidDate
                      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                      GOTO Quit
                   END

                   -- Convert DD/MM/YYYY to DATETIME
                   BEGIN TRY
                      SET @dLottable13 = DATEFROMPARTS(@nYYYY, @nMM, @nDD)
                   END TRY
                   BEGIN CATCH
                      SET @nErrNo = 254054 -- Error ConvDateFail
                      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                      GOTO Quit
                   END CATCH
                END
                ELSE
                   SET @dLottable13 = NULL
 
                -- Validate and Convert Exp Date (Lottable04) - QR code format is DD/MM/YYYY
                IF @cTempLottable04 <> ''
                BEGIN
                   -- Validate DD/MM/YYYY format (length must be 10)
                   IF LEN(@cTempLottable04) <> 10 OR
                      SUBSTRING(@cTempLottable04, 3, 1) <> '/' OR
                      SUBSTRING(@cTempLottable04, 6, 1) <> '/'
                   BEGIN
                      SET @nErrNo = 254053 -- Error InvalidDate
                      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                      GOTO Quit
                   END

                   -- Extract and validate DD, MM, YYYY
                   BEGIN TRY
                      SET @nDD = CAST(SUBSTRING(@cTempLottable04, 1, 2) AS INT)
                      SET @nMM = CAST(SUBSTRING(@cTempLottable04, 4, 2) AS INT)
                      SET @nYYYY = CAST(SUBSTRING(@cTempLottable04, 7, 4) AS INT)
                   END TRY
                   BEGIN CATCH
                      SET @nErrNo = 254053 -- Error InvalidDate
                      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                      GOTO Quit
                   END CATCH

                   -- Validate ranges
                   IF @nMM < 1 OR @nMM > 12 OR @nDD < 1 OR @nDD > 31 OR @nYYYY < 1900 OR @nYYYY > 9999
                   BEGIN
                      SET @nErrNo = 254053 -- Error InvalidDate
                      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                      GOTO Quit
                   END

                   -- Validate last day of month
                   IF @nMM IN (1, 3, 5, 7, 8, 10, 12) SET @nLastDayOfMonth = 31
                   ELSE IF @nMM IN (4, 6, 9, 11) SET @nLastDayOfMonth = 30
                   ELSE IF @nMM = 2
                   BEGIN
                      IF (@nYYYY % 4 = 0 AND @nYYYY % 100 <> 0) OR (@nYYYY % 400 = 0)
                         SET @nLastDayOfMonth = 29
                      ELSE
                         SET @nLastDayOfMonth = 28
                   END

                   IF @nDD > @nLastDayOfMonth
                   BEGIN
                      SET @nErrNo = 254053 -- Error InvalidDate
                      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                      GOTO Quit
                   END

                   -- Convert DD/MM/YYYY to DATETIME
                   BEGIN TRY
                      SET @dLottable04 = DATEFROMPARTS(@nYYYY, @nMM, @nDD)
                   END TRY
                   BEGIN CATCH
                      SET @nErrNo = 254054 -- Error ConvDateFail
                      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                      GOTO Quit
                   END CATCH
                END
                ELSE
                   SET @dLottable04 = NULL
               
               -- Only compare dates if both are NOT NULL
               IF @dLottable13 IS NOT NULL AND @dLottable04 IS NOT NULL
               BEGIN
                  IF @dLottable13 >= @dLottable04
                  BEGIN
                     SET @nErrNo = 254056 -- Invalid MFG Date
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END
               END

            END
            ELSE
            BEGIN
                -- Barcode Logic (SKU only)
                SET @cSKU = @cBarcode
            END
 
            -- SKU Validation (Common for both QR and Barcode)
            IF NOT EXISTS (SELECT 1 FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU)
            BEGIN
               SET @nErrNo = 254055 -- Error InvalidSKU
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END
         END
      END
   END
 
Quit:
   IF @nDebugFlag = 1
      SELECT 'Quit', @nErrNo AS ErrNo, @cSKU AS SKU, @dLottable13 AS LOT13, @dLottable04 AS LOT4,
               @cLottable02 AS LOT2
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON rdt.rdt_629DecodeSP01 TO NSQL
GO  
 