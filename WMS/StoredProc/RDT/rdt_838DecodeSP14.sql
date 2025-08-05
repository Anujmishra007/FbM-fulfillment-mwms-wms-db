SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_838DecodeSP14                                   */
/* Copyright      : Maersk                                              */
/* Customer       : HILLSHK                                             */
/*                                                                      */
/* Note: Copied from rdt_838DecodeSP01                                  */
/*                                                                      */
/* Purpose: Get UPC SKU and Qty                                         */
/*                                                                      */
/* Date        Rev    Author      Purposes                              */
/* 2025-06-19  1.0.0  NickT       FCR-5535 Created                      */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_838DecodeSP14]
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
            DECLARE @cUPC     NVARCHAR( 30)
            DECLARE @nUPCQTY  INT

            SELECT 
               @cUPC = LEFT( @cBarcode, 30),
               @nUPCQTY = 0

            -- Get SKU
            EXEC rdt.rdt_GetSKU
               @cStorerKey    = @cStorerKey
               ,@cSKU         = @cUPC      OUTPUT
               ,@bSuccess     = @bSuccess  OUTPUT
               ,@nErr         = @nErrNo    OUTPUT
               ,@cErrMsg      = @cErrMsg   OUTPUT
               ,@nUPCQTY      = @nUPCQTY   OUTPUT

            IF @bSuccess <> 1
               GOTO Quit

            SET @cSKU = @cUPC

            IF ISNULL(@nUPCQTY, 0) > 0
               SET @nQTY = @nUPCQTY
         END
      END
   END

Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_838DecodeSP14] TO [NSQL]
GO
