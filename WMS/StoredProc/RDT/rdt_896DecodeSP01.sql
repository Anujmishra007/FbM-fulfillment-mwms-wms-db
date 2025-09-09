
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************/
/* Store procedure: rdt_896DecodeSP01                                         */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Purpose: Decode For PMI case                                               */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2025-09-08  Jackc     1.0.0 FCR-7545 created                               */
/******************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_896DecodeSP01] (
   @nMobile           INT,           
   @nFunc             INT,           
   @cLangCode         NVARCHAR( 3),  
   @nStep             INT,           
   @nInputKey         INT,
   @cStorerKey        NVARCHAR( 15),         
   @cFacility         NVARCHAR( 5),
   @cType             NVARCHAR( 10) = '',  
   @cBarcode          NVARCHAR( 2000), 
   @cFromID           NVARCHAR( 18)  OUTPUT,
   @cFromLOC          NVARCHAR( 10)  OUTPUT,
   @cToID             NVARCHAR( 18)  OUTPUT,
   @cToLOC            NVARCHAR( 10)  OUTPUT,
   @cUCCNo            NVARCHAR( 20)  OUTPUT, 
   @cSKU              NVARCHAR( 20)  OUTPUT, 
   @nQTY              INT            OUTPUT, 
   @cLottable01       NVARCHAR( 18)  OUTPUT, 
   @cLottable02       NVARCHAR( 18)  OUTPUT, 
   @cLottable03       NVARCHAR( 18)  OUTPUT, 
   @dLottable04       DATETIME       OUTPUT,
   @dLottable05       DATETIME       OUTPUT,
   @cLottable06       NVARCHAR( 30)  OUTPUT,
   @cLottable07       NVARCHAR( 30)  OUTPUT,
   @cLottable08       NVARCHAR( 30)  OUTPUT,
   @cLottable09       NVARCHAR( 30)  OUTPUT,
   @cLottable10       NVARCHAR( 30)  OUTPUT,
   @cLottable11       NVARCHAR( 30)  OUTPUT,
   @cLottable12       NVARCHAR( 30)  OUTPUT,
   @dLottable13       DATETIME       OUTPUT,
   @dLottable14       DATETIME       OUTPUT,
   @dLottable15       DATETIME       OUTPUT,
   @nErrNo            INT            OUTPUT, 
   @cErrMsg           NVARCHAR(1024)  OUTPUT    
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag  INT = 0
   DECLARE @cUCCSKU  NVARCHAR (20)

   SET @cBarcode = LTRIM(RTRIM(@cBarcode))
   IF @nFunc = 896
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Exuecuting rdt_896DecodeSP01'

      IF @nStep = 7 --UCC 
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'Step7, decode UCC', @cBarcode

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
                     SET @nErrNo = 246051
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 246052
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  GOTO Quit
               END--Fertin label
               ELSE IF LEN(@cBarcode) = 57 --Swedish label
               BEGIN
                  SET @cUCCNo = SUBSTRING(@cBarcode, 19, 17)
                  SET @cUCCSKU = SUBSTRING(@cBarcode, 39, 11)

                  IF LEFT(@cUCCSKU, 2) <> 'NP'
                  BEGIN
                     SET @nErrNo = 246053
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 246054
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  GOTO Quit
               END -- swedish label
               ELSE
               BEGIN
                  SET @nErrNo = 246055
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

GRANT EXECUTE ON rdt.rdt_896DecodeSP01 TO NSQL
GO

