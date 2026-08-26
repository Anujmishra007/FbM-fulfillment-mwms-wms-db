SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_840DecodeSP09                                   */
/* Copyright      : MAERSK                                              */
/*                                                                      */
/* Purpose: Decode SKU barcode (V_Max) for Pack By TrackNo              */
/*          Format: URL?SERIALNO!ALTSKU                                 */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author      Purposes                                */
/* 2026-08-12  1.0  Dennis      FCR-15090 Created                       */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_840DecodeSP09
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR(  3),
   @nStep        INT,
   @nInputKey    INT,
   @cStorerKey   NVARCHAR( 15),
   @cBarcode     NVARCHAR(2000),
   @cDropID      NVARCHAR( 20),
   @cOrderKey    NVARCHAR( 10)  OUTPUT,
   @cSKU         NVARCHAR( 20)  OUTPUT,
   @cTrackingNo  NVARCHAR( 20)  OUTPUT,
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
   @cSerialNo    NVARCHAR( 30)  OUTPUT,
   @nSerialQTY   INT            OUTPUT,
   @nErrNo       INT            OUTPUT,
   @cErrMsg      NVARCHAR( 20)  OUTPUT,
   @cPickSlipNo  NVARCHAR( 10)  OUTPUT

AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @nPosQ             INT,
      @nPosEx            INT,
      @cDecodedSerialNo  NVARCHAR(100),
      @cDecodedAltSKU    NVARCHAR( 50),
      @cPattern          NVARCHAR(500),
      @cRawBarcode       NVARCHAR(1000)

   SELECT @cRawBarcode = ISNULL(V_Max, '')
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 840
   BEGIN
      IF @nStep = 3 -- SKU
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Locate delimiters: URL?SERIALNO!ALTSKU
            SET @nPosQ  = CHARINDEX('?', @cRawBarcode)
            SET @nPosEx = CHARINDEX('!', @cRawBarcode)

            -- Validate format: must have ? before !
            IF @nPosQ = 0 OR @nPosEx = 0 OR @nPosEx <= @nPosQ
            BEGIN
               SET @nErrNo = 277651
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid QR Code
               GOTO Quit
            END

            -- Decode
            SET @cDecodedSerialNo = SUBSTRING(@cRawBarcode, @nPosQ  + 1, @nPosEx - @nPosQ - 1)
            SET @cDecodedAltSKU   = SUBSTRING(@cRawBarcode, @nPosEx + 1, LEN(@cRawBarcode))

            IF ISNULL(RTRIM(@cDecodedSerialNo), '') = '' OR ISNULL(RTRIM(@cDecodedAltSKU), '') = ''
            BEGIN
               SET @nErrNo = 277651
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid QR Code
               GOTO Quit
            END

            -- Fetch SKU from ALTSKU
            SELECT @cSKU = SKU
            FROM dbo.SKU WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
            AND   AltSKU    = @cDecodedAltSKU

            IF ISNULL(@cSKU, '') = ''
            BEGIN
               SET @nErrNo = 277652
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid QR Code
               GOTO Quit
            END

            -- Validate SERIALNO format from CODELKUP
            SELECT @cPattern = Long
            FROM dbo.CODELKUP WITH (NOLOCK)
            WHERE ListName  = 'RDTFormat'
            AND   Code      = '840-SERIALNO'
            AND   StorerKey = @cStorerKey

            IF ISNULL(@cPattern, '') <> ''
            BEGIN
               IF PATINDEX(@cPattern, @cDecodedSerialNo) = 0
               BEGIN
                  SET @nErrNo = 277653
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Serial No
                  GOTO Quit
               END
            END

            SET @cSerialNo = @cDecodedSerialNo
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

GRANT EXECUTE ON rdt.rdt_840DecodeSP09 TO NSQL
GO
