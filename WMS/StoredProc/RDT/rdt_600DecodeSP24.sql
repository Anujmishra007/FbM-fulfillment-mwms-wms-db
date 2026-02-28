
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_600DecodeSP24                                         */
/* Copyright:                                                                 */
/*                                                                            */
/* Purpose: For IndiGo                                                        */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2025-10-11  Jackc     1.0   FCR-7475 created                               */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_600DecodeSP24] (
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

   IF @nFunc = 600 -- Normal receiving
   BEGIN
      IF @nStep = 4 -- SKU
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF (LEN(@cBarcode) - LEN(REPLACE(@cBarcode, '&',''))) <> 4
            BEGIN
               SET @nErrNo = 248656
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format
               GOTO Quit 
            END

            BEGIN TRY
               INSERT INTO @tDecodeList
               SELECT [key]+1 AS ItemIndex, value AS Item
               FROM OPENJSON('["' + REPLACE(@cBarcode, '&', '","') + '"]');
            END TRY
            BEGIN CATCH
               SET @nErrNo = 248651
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Deocding Failure
               GOTO Quit 
            END CATCH

            SELECT @cTempSKU        = Item FROM @tDecodeList WHERE ItemIndex = '1'
            SELECT @cTempLottable01 = Item FROM @tDecodeList WHERE ItemIndex = '2'
            SELECT @cTempLottable13 = Item FROM @tDecodeList WHERE ItemIndex = '3'
            SELECT @cTempLottable04 = Item FROM @tDecodeList WHERE ItemIndex = '4'
            SELECT @cTempLottable02 = Item FROM @tDecodeList WHERE ItemIndex = '5'

            IF @nDebugFlag = 1
               SELECT 'DecodeValues', @cTempSKU AS SKU, @cTempLottable01 AS LOT1, 
                        @cTempLottable13 AS LOT13, @cTempLottable04 AS LOT4, @cTempLottable02 AS LOT2

            SET @cSKU = @cTempSKU
            SET @cLottable01 = @cTempLottable01
            SET @cLottable02 = @cTempLottable02

            IF @cTempLottable13 <> ''
            BEGIN
               IF rdt.rdtIsValidDate( @cTempLottable13) = 0
               BEGIN
                  SET @nErrNo = 248652
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid date
                  GOTO Quit
               END
               ELSE
               BEGIN
                  BEGIN TRY
                     SET @dLottable13 = rdt.rdtConvertToDate(@cTempLottable13)
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 248653
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid date
                     GOTO Quit
                  END CATCH
               END
            END
            ELSE
               SET @dLottable13 = ISNULL(@cTempLottable13, '')

            IF @cTempLottable04 <> ''
            BEGIN
               IF rdt.rdtIsValidDate( @cTempLottable04) = 0
               BEGIN
                  SET @nErrNo = 248654
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid date
                  GOTO Quit
               END
               ELSE
               BEGIN
                  BEGIN TRY
                     SET @dLottable04 = rdt.rdtConvertToDate(@cTempLottable04)
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 248655
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid date
                     GOTO Quit
                  END CATCH
               END
            END
            ELSE
               SET @dLottable04 = ISNULL(@cTempLottable04, '')
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

GRANT EXECUTE ON rdt.rdt_600DecodeSP24 TO NSQL
GO