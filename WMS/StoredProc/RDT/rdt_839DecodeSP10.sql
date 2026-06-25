SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_839DecodeSP10                                         */
/* Copyright      : Maersk                                                    */
/* Customer       : PAGEIND                                                   */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2026-06-23  1.0   NYE018     FCR-12865 Custom decode for Screen 3 SKU scan */
/*                              Barcode format: SKU:LOTTABLE01                */
/*                              Delimiter: ':'                                */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_839DecodeSP10] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),
   @cStorerKey   NVARCHAR( 15),
   @cBarcode     NVARCHAR( 2000),
   @cPickSlipNo  NVARCHAR( 10),
   @cPickZone    NVARCHAR( 10),
   @cDropID      NVARCHAR( 20),
   @cLOC         NVARCHAR( 10),
   @cUPC         NVARCHAR( 30)  OUTPUT,
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
   @cErrMsg      NVARCHAR( 250)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cDecodedSKU        NVARCHAR(50),
      @cDecodedLottable01 NVARCHAR(18),
      @cPickDetailLot     NVARCHAR(10),
      @cLotAttrLottable01 NVARCHAR(18),
      @nDelimiterPos      INT

   IF @nFunc = 839
   BEGIN
      IF @nStep = 3
      BEGIN
         IF @cBarcode <> ''
         BEGIN
            SET @nDelimiterPos = CHARINDEX(':', @cBarcode)

            IF @nDelimiterPos = 0
            BEGIN
               SET @nErrNo = 270901
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 270901 InvBarcode
               GOTO Quit
            END

            SET @cDecodedSKU = LEFT(@cBarcode, @nDelimiterPos - 1)
            SET @cDecodedLottable01 = SUBSTRING(@cBarcode, @nDelimiterPos + 1, LEN(@cBarcode) - @nDelimiterPos)

            IF ISNULL(@cDecodedSKU, '') = '' OR ISNULL(@cDecodedLottable01, '') = ''
            BEGIN
               SET @nErrNo = 270904
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 270904 InvBarcode
               GOTO Quit
            END

            IF NOT EXISTS(
                SELECT 1
                FROM dbo.PickDetail WITH(NOLOCK)
                WHERE PickSlipNo = @cPickSlipNo
                    AND SKU = @cDecodedSKU
                    AND StorerKey = @cStorerKey
            )
            BEGIN
                SET @nErrNo = 270902
                SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 270902 WrongSKU
                GOTO Quit
            END

            SELECT TOP 1 @cPickDetailLot = Lot
            FROM dbo.PickDetail WITH(NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo
               AND SKU = @cDecodedSKU
               AND StorerKey = @cStorerKey

            SELECT @cLotAttrLottable01 = Lottable01
            FROM dbo.LotAttribute WITH(NOLOCK)
            WHERE Lot = @cPickDetailLot
               AND SKU = @cDecodedSKU
               AND StorerKey = @cStorerKey

            IF @cDecodedLottable01 <> ISNULL(@cLotAttrLottable01, '')
            BEGIN
               SET @nErrNo = 270903
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 270903 Wrong Lottable01
               GOTO Quit
            END

            SET @cUPC = @cDecodedSKU
            SET @cLottable01 = @cDecodedLottable01

            GOTO Quit
         END
      END -- IF @nStep = 3
   END -- IF @nFunc = 839

   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_839DecodeSP10 TO NSQL
GO
