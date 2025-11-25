
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_922DecodeSP01                                         */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Purpose: Decode for PMI case                                               */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2024-10-26  PXL009    1.0   FCR-759 ID and UCC Length Issue                */
/* 2025-07-03  JackC     1.1   FCR-2961 Adapt for new types labels ()         */
/* 2025-11-10  Cuize     1.2   FCR-8407 Swedish label58                       */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_922DecodeSP01 ( 
   @nMobile          INT, 
   @nFunc            INT, 
   @cLangCode        NVARCHAR( 3), 
   @nStep            INT, 
   @nInputKey        INT, 
   @cStorerKey       NVARCHAR( 15),
   @cMBOLKey         NVARCHAR( 10),
   @cLoadKey         NVARCHAR( 10),
   @cOrderKey        NVARCHAR( 10),
   @cBarcode         NVARCHAR(MAX)  OUTPUT,
   @cFieldName       NVARCHAR( 10),
   @cLabelNo         NVARCHAR( 20)  OUTPUT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cUCC     NVARCHAR( 20)
   DECLARE @cSKU     NVARCHAR(20) 

   IF @nFunc = 922
   BEGIN
      IF @nStep = 2 
      BEGIN
         IF @nInputKey = 1
         BEGIN

            IF @cBarcode <> ''
            BEGIN
               SET @cBarcode = LTRIM(RTRIM(@cBarcode))

               IF LEN(@cBarcode) <= 20
               BEGIN
                  --V1.0 loigc
                  SET @cUCC = @cBarcode
               END
               ELSE IF LEN(@cBarcode) = 40
               BEGIN
                  --V1.0 logic
                  SET @cUCC = RIGHT(LTRIM(RTRIM(@cBarcode)), 20)
               END
               ELSE IF LEN(@cBarcode) = 49 --Fertin label
               BEGIN
                  SET @cUCC = SUBSTRING(@cBarcode, 19, 17)
                  SET @cSKU = SUBSTRING(@cBarcode, 39, 11)

                  IF LEFT(@cSKU, 2) <> 'NP'
                  BEGIN
                     SET @nErrNo = 227002
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU)
                  BEGIN
                     SET @nErrNo = 227003
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END
               END--Fertin label
               ELSE IF LEN(@cBarCode) = 57 --Swedish label
               BEGIN
                  SET @cUCC = SUBSTRING(@cBarcode, 19, 17)
                  SET @cSKU = SUBSTRING(@cBarcode, 39, 11)

                  IF LEFT(@cSKU, 2) <> 'NP'
                  BEGIN
                     SET @nErrNo = 227004
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU)
                  BEGIN
                     SET @nErrNo = 227005
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END
               END -- swedish label
               ELSE IF LEN(@cBarCode) = 58 --Swedish label58
               BEGIN
                  SET @cUCC = SUBSTRING(@cBarcode, 19, 18)
                  SET @cSKU = SUBSTRING(@cBarcode, 40, 11)

                  IF LEFT(@cSKU, 2) <> 'NP'
                  BEGIN
                     SET @nErrNo = 227006
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU)
                  BEGIN
                     SET @nErrNo = 227007
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END
               END -- swedish label
               ELSE
               BEGIN
                  SET @nErrNo = 227001
                  SET @cErrMsg = [rdt].[rdtgetmessage]( @nErrNo, @cLangCode, N'DSP') -- Invalid UCC(40 digit)
                  GOTO Quit
               END

               SET @cLabelNo = @cUCC 
            END

            GOTO Quit
         END --inputkey
      END
   END --922

   Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_922DecodeSP01 TO NSQL
GO
