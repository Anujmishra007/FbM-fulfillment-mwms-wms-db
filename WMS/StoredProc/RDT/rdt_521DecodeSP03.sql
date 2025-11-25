
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************/
/* Store procedure: rdt_521DecodeSP03                                         */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Purpose: Decode For PMI                                                    */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2025-11-10  Cuize    1.0    FCR-8407 Created                               */
/******************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_521DecodeSP03] (
   @nMobile           INT,           
   @nFunc             INT,           
   @cLangCode         NVARCHAR( 3),  
   @nStep             INT,           
   @nInputKey         INT,           
   @cFacility         NVARCHAR( 5),  
   @cStorerKey        NVARCHAR( 15),
   @cBarcode          NVARCHAR( MAX),
   @cUCCNo            NVARCHAR( 20) OUTPUT,
   @nErrNo            INT            OUTPUT, 
   @cErrMsg           NVARCHAR( 120)  OUTPUT    
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cUCCSKU  NVARCHAR (20)

   IF @nFunc = 521
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
                  SET @cUCCNo = @cBarcode
                  GOTO Quit
               END
               ELSE IF LEN(@cBarcode) = 40
               BEGIN
                  SET @cUCCNo = RIGHT(@cBarcode, 20)
                  GOTO Quit
               END --40
               ELSE IF LEN(@cBarcode) = 49 --Fertin label
               BEGIN
                  SET @cUCCNo = SUBSTRING(@cBarcode, 19, 17)
                  SET @cUCCSKU = SUBSTRING(@cBarcode, 39, 11)

                  IF LEFT(@cUCCSKU, 2) <> 'NP'
                  BEGIN
                     SET @nErrNo = 256051
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 256052
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  GOTO Quit
               END--Fertin label
               ELSE IF LEN(@cBarcode) = 57 --Swedish label 57
               BEGIN
                  SET @cUCCNo = SUBSTRING(@cBarcode, 19, 17)
                  SET @cUCCSKU = SUBSTRING(@cBarcode, 39, 11)

                  IF LEFT(@cUCCSKU, 2) <> 'NP'
                     BEGIN
                        SET @nErrNo = 256053
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                        GOTO Quit
                     END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                     BEGIN
                        SET @nErrNo = 256054
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                        GOTO Quit
                     END

                  GOTO Quit
               END -- swedish label
               ELSE IF LEN(@cBarcode) = 58 --Swedish label 58
               BEGIN
                  SET @cUCCNo = SUBSTRING(@cBarcode, 19, 18)
                  SET @cUCCSKU = SUBSTRING(@cBarcode, 40, 11)

                  IF LEFT(@cUCCSKU, 2) <> 'NP'
                  BEGIN
                     SET @nErrNo = 256056
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 256057
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  GOTO Quit
               END -- swedish label
               ELSE
               BEGIN
                  SET @nErrNo = 256055
                  SET @cErrMsg = [rdt].[rdtgetmessage]( @nErrNo, @cLangCode, N'DSP') -- Invalid UCC
                  GOTO Quit
               END

            END--barcodeUCC
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

GRANT EXECUTE ON rdt.rdt_521DecodeSP03 TO NSQL
GO

