SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: rdt_555DecodeSP02                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: QR Code decode for Inquiry (SKU, Batch, Mfg, Exp, Dept)     */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author      Purposes                                */
/* 2025-12-14  1.0  NYE018      FCR-9626 Created                        */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_555DecodeSP02] (
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
      ,@nRowCount    INT

    DECLARE @tDecodeList TABLE
   (
      ItemIndex   INT NOT NULL,
      Item        NVARCHAR (100)      
   )

   IF @nFunc = 555 -- Inquiry
   BEGIN
      IF @nStep = 1 -- LOC/ID/SKU
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Check if it is a QR code (contains &)
            IF CHARINDEX('&', @cBarcode) > 0
            BEGIN
                -- check for '&'
                IF (LEN(@cBarcode) - LEN(REPLACE(@cBarcode, '&',''))) <> 4
                BEGIN
                   SET @nErrNo = 253851 -- Error InvFormat
                   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
                   GOTO Quit 
                END

                BEGIN TRY
                   INSERT INTO @tDecodeList
                   SELECT [key]+1 AS ItemIndex, value AS Item
                   FROM OPENJSON('["' + REPLACE(@cBarcode, '&', '","') + '"]');
                END TRY
                BEGIN CATCH
                   SET @nErrNo = 253852 -- Error DecodeFailure
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

                -- Validate and Convert Mfg Date (Lottable13)
                IF @cTempLottable13 <> ''
                BEGIN
                   IF rdt.rdtIsValidDate( @cTempLottable13) = 0
                   BEGIN
                      SET @nErrNo = 253853 -- Error InvalidDate
                      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
                      GOTO Quit
                   END
                   ELSE
                   BEGIN
                      BEGIN TRY
                         SET @dLottable13 = rdt.rdtConvertToDate(@cTempLottable13)
                      END TRY
                      BEGIN CATCH
                         SET @nErrNo = 253854 -- Error ConvDateFail
                         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
                         GOTO Quit
                      END CATCH
                   END
                END
                ELSE
                   SET @dLottable13 = ISNULL(@cTempLottable13, '')

                -- Validate and Convert Exp Date (Lottable04)
                IF @cTempLottable04 <> ''
                BEGIN
                   IF rdt.rdtIsValidDate( @cTempLottable04) = 0
                   BEGIN
                      SET @nErrNo = 253853 -- Error InvalidDate
                      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
                      GOTO Quit
                   END
                   ELSE
                   BEGIN
                      BEGIN TRY
                         SET @dLottable04 = rdt.rdtConvertToDate(@cTempLottable04)
                      END TRY
                      BEGIN CATCH
                         SET @nErrNo = 253854 -- Error ConvDateFail
                         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
                         GOTO Quit
                      END CATCH
                   END
                END
                ELSE
                   SET @dLottable04 = ISNULL(@cTempLottable04, '')
            END
            ELSE
            BEGIN
                -- Barcode Logic (SKU only)
                SET @cSKU = @cBarcode
            END

            -- SKU Validation (Common for both QR and Barcode)
            IF NOT EXISTS (SELECT 1 FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU)
            BEGIN
               SET @nErrNo = 253855 -- Error InvalidSKU
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
GRANT EXECUTE ON rdt.rdt_555DecodeSP02 TO NSQL 
GO  