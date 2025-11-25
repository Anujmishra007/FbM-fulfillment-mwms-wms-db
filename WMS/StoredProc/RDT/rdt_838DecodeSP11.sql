SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_838DecodeSP11                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Decode for PMI case                                         */
/*                                                                      */
/* Date        Author   Ver.  Purposes                                  */
/* 2024-10-17  PXL009   1.0   FCR-759 ID and UCC Length Issue           */
/* 2025-09-08  Jackc    1.1   FCR-7545 ID and UCC Length Issue          */
/* 2025-11-10  Cuize    1.2   FCR-8407 Swedish label58                  */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_838DecodeSP11]
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

   DECLARE @cUCC        NVARCHAR( 20)
   DECLARE @cUCCSKU     NVARCHAR( 20)
   DECLARE @cID         NVARCHAR( 18)

   IF @nFunc = 838
   BEGIN
      IF @nStep = 1  -- FromDropID/ToDropID
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @cBarcode <> ''
            BEGIN
               SET @cID = ''
               EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,
                  @cID     = @cID        OUTPUT,
                  @nErrNo  = @nErrNo      OUTPUT,
                  @cErrMsg = @cErrMsg     OUTPUT,
                  @cType   = 'ID'

               IF @nErrNo <> 0
                  GOTO Quit

               SET @cFromDropIDDecode = @cID
            END

            IF @cBarcode2 <> ''
            BEGIN
               SET @cID = ''
               EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode2,
                  @cID     = @cID         OUTPUT,
                  @nErrNo  = @nErrNo      OUTPUT,
                  @cErrMsg = @cErrMsg     OUTPUT,
                  @cType   = 'ID'

               IF @nErrNo <> 0
                  GOTO Quit

               SET @cToDropIDDecode = @cID
            END

            GOTO Quit
         END
      END

      IF @nStep = 8  -- UCC
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @cBarcode <> ''
            BEGIN
               --V1.1 start
               SET @cBarcode = LTRIM(RTRIM(@cBarcode))

               IF LEN(@cBarCode) = 49 --Fertin label
               BEGIN
                  SET @cUCC = SUBSTRING(@cBarcode, 19, 17)
                  SET @cUCCSKU = SUBSTRING(@cBarcode, 39, 11)

                  IF LEFT(@cUCCSKU, 2) <> 'NP'
                  BEGIN
                     SET @nErrNo = 246101
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 246102
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END
               END--Fertin label
               ELSE IF LEN(@cBarcode) = 57 --Swedish label
               BEGIN
                  SET @cUCC = SUBSTRING(@cBarcode, 19, 17)
                  SET @cUCCSKU = SUBSTRING(@cBarcode, 39, 11)

                  IF LEFT(@cUCCSKU, 2) <> 'NP'
                  BEGIN
                     SET @nErrNo = 246103
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 246104
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END
               END -- swedish label
               ELSE IF LEN(@cBarcode) = 58 --Swedish label58
               BEGIN
                  SET @cUCC = SUBSTRING(@cBarcode, 19, 18)
                  SET @cUCCSKU = SUBSTRING(@cBarcode, 40, 11)

                  IF LEFT(@cUCCSKU, 2) <> 'NP'
                  BEGIN
                     SET @nErrNo = 246105
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 246106
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END
               END -- swedish label
               --V1.1 end
               ELSE --V1.0 existing logic
               BEGIN
                  SET @cUCC = ''
                  EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,
                     @cUCCNo  = @cUCC        OUTPUT,
                     @nErrNo  = @nErrNo      OUTPUT,
                     @cErrMsg = @cErrMsg     OUTPUT,
                     @cType   = 'UCCNo'

                  IF @nErrNo <> 0
                     GOTO Quit
               END

               SET @cUCCNo = @cUCC
            END --UCC decoding

            GOTO Quit
         END
      END
   END

Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_838DecodeSP11] TO [NSQL]
GO
