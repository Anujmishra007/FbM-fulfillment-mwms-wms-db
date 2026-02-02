SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************/
/* Store procedure: rdt_557DecodeSP03                                         */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Purpose:                                                                   */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2025-11-10  Cuize     1.0   FCR-8407. Created                              */
/******************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_557DecodeSP03] (
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR( 3),
   @nStep               INT,
   @nInputKey           INT,
   @cFacility           NVARCHAR( 5),
   @cStorerKey          NVARCHAR( 15),
   @cBarcode            NVARCHAR( 60),
   @cID                 NVARCHAR( 18)  OUTPUT,
   @cUCC                NVARCHAR( 20)  OUTPUT,
   @nErrNo              INT            OUTPUT,
   @cErrMsg             NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cUCCSKU  NVARCHAR (20)

   SET @cBarcode = LTRIM(RTRIM(@cBarcode))
   IF @nFunc = 557
   BEGIN
      IF @nStep = 1 
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF @cBarcode <> '' -- UCC  Decode
            BEGIN
               SET @cBarcode = LTRIM(RTRIM(@cBarcode))
               IF LEN(@cBarcode) = 20
               BEGIN
                  SET @cUCC = @cBarcode
                  GOTO Quit
               END
               ELSE IF LEN(@cBarcode) = 40
               BEGIN
                  SET @cUCC = RIGHT(@cBarcode, 20)
                  GOTO Quit
               END --40
               ELSE IF LEN(@cBarcode) = 49 --Fertin label
               BEGIN
                  SET @cUCC = SUBSTRING(@cBarcode, 19, 17)
                  SET @cUCCSKU = SUBSTRING(@cBarcode, 39, 11)

                  IF LEFT(@cUCCSKU, 2) <> 'NP'
                  BEGIN
                     SET @nErrNo = 250801
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 250802
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  GOTO Quit
               END--Fertin label
               ELSE IF LEN(@cBarcode) = 57 --Swedish label
               BEGIN
                  SET @cUCC = SUBSTRING(@cBarcode, 19, 17)
                  SET @cUCCSKU = SUBSTRING(@cBarcode, 39, 11)

                  IF LEFT(@cUCCSKU, 2) <> 'NP'
                  BEGIN
                     SET @nErrNo = 250803
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 250804
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  GOTO Quit
               END -- swedish label
               ELSE IF LEN(@cBarcode) = 58 --Swedish label58
               BEGIN
                  SET @cUCC = SUBSTRING(@cBarcode, 19, 18)
                  SET @cUCCSKU = SUBSTRING(@cBarcode, 40, 11)

                  IF LEFT(@cUCCSKU, 2) <> 'NP'
                  BEGIN
                     SET @nErrNo = 250806
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 250807
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  GOTO Quit
               END -- swedish label
               ELSE
               BEGIN
                  SET @nErrNo = 250805
                  SET @cErrMsg = [rdt].[rdtgetmessage]( @nErrNo, @cLangCode, N'DSP') -- Invalid UCC
                  GOTO Quit
               END


            END --inputkey=1
         END --inputkey=1
      END
   END

   Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_557DecodeSP03] TO NSQL
GO
