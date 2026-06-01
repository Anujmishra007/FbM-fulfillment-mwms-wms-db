SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: rdt_610DecodeSP05                                         */
/* Copyright: MAERSK                                                          */
/*                                                                            */
/* Purpose: Decode For PMI                                                    */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2025-11-10  Cuize     1.0   FCR-8407. Created                              */
/* 2026-05-29  Sreeja    1.1   FCR-13447  Pallet ID Decode in Screen-5        */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_610DecodeSP05] (
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

   SELECT TOP 1
      @cStorerKey = StorerKey -- SHONG002
   --,@cStorer = StorerKey -- SHONG001
   FROM dbo.CCDETAIL (NOLOCK)
   WHERE CCKey = @cCCRefNo
     --AND   CCSheetNo = @cCCSheetNo
     AND CCSheetNo = CASE WHEN ISNULL(@cCCSheetNo, '') = '' THEN CCSheetNo ELSE @cCCSheetNo END
     AND LOC = @cLOC

   IF @nFunc = 610
   BEGIN
      -- FCR-13447: Pallet ID Decode - Take rightmost 18 characters
      IF @nStep = 8
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Fall back to @cID if @cBarcode is empty (caller should normally pass the scanned value in @cBarcode)
            SET @cBarcode = LTRIM(RTRIM(COALESCE(NULLIF(@cBarcode, ''), @cID, '')))

            IF @cBarcode <> ''
            BEGIN
               -- Only decode if barcode is more than 18 characters
               IF LEN(@cBarcode) > 18
               BEGIN
                  SET @cID = RIGHT(@cBarcode, 18)
               END
               ELSE
               BEGIN
                  -- If 18 characters or less, use as-is
                  SET @cID = @cBarcode
               END

               GOTO Quit
            END
         END
      END

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
                     SET @nErrNo = 250701
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 250702
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
                     SET @nErrNo = 250703
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 250704
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  GOTO Quit
               END -- swedish label
               ELSE IF LEN(@cBarcode) = 58 --Swedish label 58
               BEGIN
                  SET @cUCC = SUBSTRING(@cBarcode, 19, 18)
                  SET @cUCCSKU = SUBSTRING(@cBarcode, 40, 11)

                  IF LEFT(@cUCCSKU, 2) <> 'NP'
                  BEGIN
                     SET @nErrNo = 250706
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 250707
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  GOTO Quit
               END -- swedish label
               ELSE
               BEGIN
                  SET @nErrNo = 250705
                  SET @cErrMsg = [rdt].[rdtgetmessage]( @nErrNo, @cLangCode, N'DSP') -- Invalid UCC
                  GOTO Quit
               END


            END --inputkey=1
      END
   END
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  [RDT].[rdt_610DecodeSP05] TO [NSQL]
GO