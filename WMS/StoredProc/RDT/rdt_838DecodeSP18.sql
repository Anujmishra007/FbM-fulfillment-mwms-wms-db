SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_838DecodeSP18                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: QR decode for the SKU in the function 838                   */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev    Author      Purposes                              */
/* 2026-03-31  1.0.0  Dennis      FCR-7820 Multi DropId                 */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_838DecodeSP18](
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR( 3),
   @nStep               INT,
   @nInputKey           INT,
   @cFacility           NVARCHAR( 5),
   @cStorerKey          NVARCHAR( 15),
   @cPickSlipNo         NVARCHAR( 10),
   @cFromDropID         NVARCHAR( 20),
   @cBarcode            NVARCHAR( 2000),
   @cBarcode2           NVARCHAR( 60),
   @cSKU                NVARCHAR( 30)  OUTPUT,
   @nQTY                INT            OUTPUT,
   @cPackDtlRefNo       NVARCHAR( 20)  OUTPUT,
   @cPackDtlRefNo2      NVARCHAR( 20)  OUTPUT,
   @cPackDtlUPC         NVARCHAR( 30)  OUTPUT,
   @cPackDtlDropID      NVARCHAR( 20)  OUTPUT,
   @cSerialNo           NVARCHAR( 30)  OUTPUT,
   @cFromDropIDDecode   NVARCHAR( 20)  OUTPUT,
   @cToDropIDDecode     NVARCHAR( 20)  OUTPUT,
   @cUCCNo              NVARCHAR( 20)  OUTPUT,
   @nErrNo              INT            OUTPUT,
   @cErrMsg             NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag  INT = 0,
   @cLottable01         NVARCHAR(30)
   
   DECLARE @tDecodeList TABLE
   (
      ItemIndex   INT NOT NULL,
      Item        NVARCHAR (100)      
   )
   
   DECLARE @cTempSKU NVARCHAR(30)

   IF @nFunc = 838  -- Pack 
   BEGIN
      IF @nStep = 3  -- SKU & QTY
      BEGIN
         IF @nInputKey = 1
         BEGIN
            -- Check if it is a QR code (contains &)
            IF CHARINDEX('&', @cBarcode) > 0
            BEGIN
               SELECT 
                  @cSerialNo = CONCAT([4], [5], [7]) ,
                  @cLottable01 = CONCAT([6], [8]) 
               FROM (
                  SELECT 
                     ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn,
                     value
                  FROM STRING_SPLIT(@cBarcode, '&')
               ) AS src
               PIVOT (
                  MAX(value)
                  FOR rn IN ([1], [2], [3], [4], [5], [6], [7], [8])
               ) AS pvt

               IF EXISTS (SELECT 1 FROM PACKSERIALNO PS WITH (NOLOCK) 
               JOIN SerialNo SN WITH (NOLOCK) ON PS.StorerKey = SN.StorerKey AND PS.SerialNo = SN.SerialNo AND SN.Status IN ('1','6')
               WHERE PS.StorerKey = @cStorerKey AND PS.SerialNo = @cSerialNo AND PS.PickSlipNo = @cPickSlipNo)
               BEGIN
                  SET @nErrNo = 255761
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --255761 SN Already Scanned
                  GOTO Quit
               END

               IF NOT EXISTS (SELECT 1 FROM SerialNo SN WITH (NOLOCK)
                  JOIN PickDetail PD (NOLOCK) ON PD.StorerKey = @cStorerKey AND PD.Status <= '5' AND PD.SKU = SN.SKU
                  JOIN RDT.rdtPickLog PL (NOLOCK) ON PD.DropID = PL.DropID AND PL.StorerKey = @cStorerKey AND PL.Mobile = @nMobile AND PL.Status = '0'
                  JOIN LOTAttribute LA (NOLOCK) ON PD.LOT = LA.LOT AND PD.SKU = LA.SKU AND PD.StorerKey = LA.StorerKey
                  WHERE SN.StorerKey = @cStorerKey
                  AND SN.SerialNo = @cSerialNo
                  AND LA.Lottable01 = @cLottable01
               )
               BEGIN
                  SET @nErrNo = 255759
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --255659 Invalid SerialNo
                  GOTO Quit
               END
 
               SELECT @cSKU = SKU FROM SerialNo WHERE SerialNo = @cSerialNo AND StorerKey = @cStorerKey
            END
            ELSE
            BEGIN
               SET @nErrNo = 255760 -- Error BadQRCode
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
               GOTO Quit
            END

            IF NOT EXISTS (SELECT 1 FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU)
            BEGIN
               SET @nErrNo = 254753 -- Error InvalidSKU
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
               GOTO Quit
            END
            UPDATE RDT.RDTMOBREC SET V_Lottable01 = @cLottable01 WHERE Mobile = @nMobile
         END
      END -- st3

   END

Quit:
    IF @nDebugFlag = 1
      SELECT 'Quit', @nErrNo AS ErrNo, @cSKU AS SKU

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON  [RDT].[rdt_838DecodeSP18] TO [NSQL]
GO
