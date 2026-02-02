SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: rdt_610DecodeSP04                                         */
/* Copyright: MAERSK                                                          */
/*                                                                            */
/* Purpose: Nike decode QR barcode return UCC no                              */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2025-09-19  James     1.0   FCR-2614. Created                              */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_610DecodeSP04] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cStorerKey     NVARCHAR( 15),
   @cCCRefNo       NVARCHAR( 10),
   @cCCSheetNo     NVARCHAR( 10),
   @cBarcode       NVARCHAR( MAX),
   @cLOC           NVARCHAR( 10)  OUTPUT,
   @cID            NVARCHAR( 18)  OUTPUT,
   @cUCC           NVARCHAR( 20)  OUTPUT,
   @cUPC           NVARCHAR( 20)  OUTPUT,
   @nQTY           INT            OUTPUT,
   @cLottable01    NVARCHAR( 18)  OUTPUT,
   @cLottable02    NVARCHAR( 18)  OUTPUT,
   @cLottable03    NVARCHAR( 18)  OUTPUT,
   @dLottable04    DATETIME       OUTPUT,
   @dLottable05    DATETIME       OUTPUT,
   @cLottable06    NVARCHAR( 30)  OUTPUT,
   @cLottable07    NVARCHAR( 30)  OUTPUT,
   @cLottable08    NVARCHAR( 30)  OUTPUT,
   @cLottable09    NVARCHAR( 30)  OUTPUT,
   @cLottable10    NVARCHAR( 30)  OUTPUT,
   @cLottable11    NVARCHAR( 30)  OUTPUT,
   @cLottable12    NVARCHAR( 30)  OUTPUT,
   @dLottable13    DATETIME       OUTPUT,
   @dLottable14    DATETIME       OUTPUT,
   @dLottable15    DATETIME       OUTPUT,
   @cUserDefine01  NVARCHAR( 60)  OUTPUT,
   @cUserDefine02  NVARCHAR( 60)  OUTPUT,
   @cUserDefine03  NVARCHAR( 60)  OUTPUT,
   @cUserDefine04  NVARCHAR( 60)  OUTPUT,
   @cUserDefine05  NVARCHAR( 60)  OUTPUT,
   @nErrNo         INT            OUTPUT,
   @cErrMsg        NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cUCCSKU  NVARCHAR (20)

   IF @nFunc = 610
   BEGIN
      IF @nStep IN ( 9, 10)
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
                     SET @nErrNo = 247151
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM dbo.SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 247152
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
                     SET @nErrNo = 247153
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM dbo.SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 247154
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  GOTO Quit
               END -- swedish label
               ELSE
               BEGIN
                  SET @nErrNo = 247155
                  SET @cErrMsg = [rdt].[rdtgetmessage]( @nErrNo, @cLangCode, N'DSP') -- Invalid UCC(40 digit)
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

GRANT EXECUTE ON  [RDT].[rdt_610DecodeSP04] TO [NSQL]
GO