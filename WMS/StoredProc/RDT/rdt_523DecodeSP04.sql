
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************/
/* Store procedure: rdt_523DecodeSP04                                         */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Purpose: Decode For PMI case                                               */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2024-10-22  ShaoAn    1.0   FCR-759-999 ID and UCC Length Issue            */
/* 2024-10-24  ShaoAn    1.0.1 Extended parameter definition                  */
/* 2025-07-31  Jackc     1.1.0 FCR-2961 Support new types of labels           */
/* 2025-11-10  Cuize     1.2   FCR-8407 Swedish label58                       */
/* 2025-10-16  Ung       1.3   FCR-8112 Add serial no                         */
/******************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_523DecodeSP04] (
   @nMobile           INT,           
   @nFunc             INT,           
   @cLangCode         NVARCHAR( 3),  
   @nStep             INT,           
   @nInputKey         INT,           
   @cFacility         NVARCHAR( 5),  
   @cStorerKey        NVARCHAR( 15), 
   @cBarcode          NVARCHAR( 60), 
   @cBarcodeUCC       NVARCHAR( 60), 
   @cID               NVARCHAR( 18)  OUTPUT, 
   @cUCC              NVARCHAR( 20)  OUTPUT, 
   @cLOC              NVARCHAR( 10)  OUTPUT, 
   @cSKU              NVARCHAR( 20)  OUTPUT, 
   @nQTY              INT            OUTPUT, 
   @cSerialNo         NVARCHAR( 30)  OUTPUT,
   @cLottable01       NVARCHAR( 18)  OUTPUT, 
   @cLottable02       NVARCHAR( 18)  OUTPUT, 
   @cLottable03       NVARCHAR( 18)  OUTPUT, 
   @dLottable04       DATETIME       OUTPUT, 
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

   SET @cBarcode = LTRIM(RTRIM(@cBarcode))
   IF @nFunc = 523
   BEGIN
      IF @nStep = 1 
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            If @cBarcode <> ''  -- ID  Decode
            BEGIN
               IF LEN(@cBarcode) = 18  
               BEGIN
                  SET @cID = @cBarcode
                  GOTO Quit
               END
               IF LEN(@cBarcode) <> 25
               BEGIN
                  SET @nErrNo = 243101
                  SET @cErrMsg = [rdt].[rdtgetmessage]( @nErrNo, @cLangCode, N'DSP') -- Invalid ID(25 digit)
                  GOTO Quit
               END
               SET @cID = RIGHT(@cBarcode, 18)
            END

            If @cBarcodeUCC <> '' -- UCC  Decode
            BEGIN
               SET @cBarcodeUCC = LTRIM(RTRIM(@cBarcodeUCC))
               IF LEN(@cBarcodeUCC) = 20 --V1.0.1 logic
               BEGIN
                  SET @cUCC = @cBarcodeUCC
                  GOTO Quit
               END
               ELSE IF LEN(@cBarcodeUCC) = 40 --V1.0.1 logic
               BEGIN
                  SET @cUCC = RIGHT(@cBarcodeUCC, 20)
                  GOTO Quit
               END --40
               ELSE IF LEN(@cBarcodeUCC) = 49 --Fertin label
               BEGIN
                  SET @cUCC = SUBSTRING(@cBarcodeUCC, 19, 17)
                  SET @cUCCSKU = SUBSTRING(@cBarcodeUCC, 39, 11)

                  IF LEFT(@cUCCSKU, 2) <> 'NP'
                  BEGIN
                     SET @nErrNo = 243103
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 243104
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  GOTO Quit
               END--Fertin label
               ELSE IF LEN(@cBarcodeUCC) = 57 --Swedish label 57
               BEGIN
                  SET @cUCC = SUBSTRING(@cBarcodeUCC, 19, 17)
                  SET @cUCCSKU = SUBSTRING(@cBarcodeUCC, 39, 11)

                  IF LEFT(@cUCCSKU, 2) <> 'NP'
                  BEGIN
                     SET @nErrNo = 243105
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 243106
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  GOTO Quit
               END -- swedish label
               ELSE IF LEN(@cBarcodeUCC) = 58 --Swedish label 58
               BEGIN
                  SET @cUCC = SUBSTRING(@cBarcodeUCC, 19, 18)
                  SET @cUCCSKU = SUBSTRING(@cBarcodeUCC, 40, 11)

                  IF LEFT(@cUCCSKU, 2) <> 'NP'
                  BEGIN
                     SET @nErrNo = 243107
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 243108
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  GOTO Quit
               END -- swedish label
               ELSE
               BEGIN
                  SET @nErrNo = 243102
                  SET @cErrMsg = [rdt].[rdtgetmessage]( @nErrNo, @cLangCode, N'DSP') -- Invalid UCC(40 digit)
                  GOTO Quit
               END
               
            END--barcodeUCC
         END --inputkey=1
      END

      IF @nStep = 2
      BEGIN
         SET @cSKU = @cBarcode
      END
   END

   Quit:
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_523DecodeSP04 TO NSQL
GO

