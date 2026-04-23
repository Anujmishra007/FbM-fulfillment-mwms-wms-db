
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: rdt_838DecodeSP20                                   */
/* Copyright      : Maersk WMS                                          */
/* Customer       : Brazil - CDS01 - LAQUILA                            */
/*                                                                      */
/* Purpose: Return UPC.Qty by PickDetail.UOM                            */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2026-04-21  1.0  NickT       FCR-12178 Created                       */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_838DecodeSP20
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR( 3),
   @nStep               INT,
   @nInputKey           INT,
   @cFacility           NVARCHAR( 5),
   @cStorerKey          NVARCHAR( 15),
   @cPickSlipNo         NVARCHAR( 10),
   @cFromDropID         NVARCHAR( 20),
   @cBarcode            NVARCHAR( 60),
   @cBarcode2           NVARCHAR( 60),
   @cSKU                NVARCHAR( 20)  OUTPUT,
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
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 838
   BEGIN
      IF @nStep = 3  -- SKU QTY
      BEGIN
         IF @nInputKey = 1
         BEGIN

            DECLARE @bSuccess INT
            DECLARE @cUPC NVARCHAR( 30)
            DECLARE @nUPCQty INT
            DECLARE @cPUOM NVARCHAR( 1)
            DECLARE @cOrderKey NVARCHAR( 10)

            SELECT TOP 1
               @cOrderKey = OrderKey
            FROM dbo.PickHeader WITH (NOLOCK)
            WHERE PickHeaderKey = @cPickSlipNo

            SELECT @cPUOM = UOM
            FROM dbo.PickDetail WITH (NOLOCK) 
            WHERE StorerKey = @cStorerKey
               AND DropID = @cFromDropID
               AND OrderKey = @cOrderKey

            SELECT @cUPC = LEFT( @cBarcode, 30)

            IF EXISTS(SELECT 1 FROM dbo.UPC WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND UPC = @cUPC)
            BEGIN
               -- Get SKU
               EXEC rdt.rdt_GetSKU
                  @cStorerKey  = @cStorerKey
                  ,@cSKU        = @cUPC      OUTPUT
                  ,@bSuccess    = @bSuccess  OUTPUT
                  ,@nErr        = @nErrNo    OUTPUT
                  ,@cErrMsg     = @cErrMsg   OUTPUT
                  ,@nUPCQTY     = @nUPCQty   OUTPUT

               IF @bSuccess <> 1
               BEGIN
                  IF @nErrNo <> 0
                     GOTO Quit
                  ELSE
                  BEGIN
                     SET @nErrNo = 264701
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Get UPC data failed
                     GOTO Quit
                  END
               END

               SET @cSKU = @cUPC
               SET @nQTY = @nUPCQty
            END
         END
      END
   END

Quit:

END
GO

GRANT EXECUTE ON rdt.rdt_838DecodeSP20 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
