
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************/
/* Store procedure: rdt_898DecodeSP02                                         */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Customer: Decode for PAGE                                                  */
/*                                                                            */
/* Date        Author   Ver.  Purposes                                        */
/* 2025-09-19  Jackc    1.0   FCR-7818 Created                                */
/******************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_898DecodeSP02] (
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR( 3),
   @nStep               INT,
   @nInputKey           INT,
   @cStorerKey          NVARCHAR( 15),
   @cReceiptKey         NVARCHAR( 10),
   @cPOKey              NVARCHAR( 10),
   @cLOC                NVARCHAR( 10),
   @cUCC                NVARCHAR( MAX)  OUTPUT,
   @nUCCQTY             INT            OUTPUT,
   @cUserDefine01       NVARCHAR(30)   OUTPUT,
   @cUserDefine02       NVARCHAR(30)   OUTPUT,
   @cUserDefine03       NVARCHAR(30)   OUTPUT,
   @cUserDefine04       NVARCHAR(30)   OUTPUT,
   @cUserDefine05       NVARCHAR(30)   OUTPUT,
   @cUserDefine06       NVARCHAR(30)   OUTPUT,
   @cUserDefine07       NVARCHAR(30)   OUTPUT,
   @cUserDefine08       NVARCHAR(30)   OUTPUT,
   @cUserDefine09       NVARCHAR(30)   OUTPUT,
   @cLottable01         NVARCHAR( 18)  OUTPUT,
   @cLottable02         NVARCHAR( 18)  OUTPUT,
   @cLottable03         NVARCHAR( 18)  OUTPUT,
   @dLottable04         DATETIME       OUTPUT,
   @dLottable05         DATETIME       OUTPUT,
   @cLottable06         NVARCHAR( 30)  OUTPUT,
   @cLottable07         NVARCHAR( 30)  OUTPUT,
   @cLottable08         NVARCHAR( 30)  OUTPUT,
   @cLottable09         NVARCHAR( 30)  OUTPUT,
   @cLottable10         NVARCHAR( 30)  OUTPUT,
   @cLottable11         NVARCHAR( 30)  OUTPUT,
   @cLottable12         NVARCHAR( 30)  OUTPUT,
   @dLottable13         DATETIME       OUTPUT,
   @dLottable14         DATETIME       OUTPUT,
   @dLottable15         DATETIME       OUTPUT,
   @nErrNo              INT            OUTPUT,
   @cErrMsg             NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag  INT = 0

   DECLARE 
      @cBarcode      NVARCHAR(MAX)
      ,@cLocaleUCC   NVARCHAR( 20)
      ,@cSKU         NVARCHAR( 20)
      ,@cSKUBUSR5    NVARCHAR( 30)
      ,@cSKUBUSR6    NVARCHAR( 30)
      ,@cAttribute1  NVARCHAR( 50)
      ,@nRowCount    INT


   DECLARE @tDecodeList TABLE
   (
      ItemIndex   INT NOT NULL,
      Item        NVARCHAR (100)      
   )

   IF @nFunc = 898 -- UCC receiving
   BEGIN
      IF @nStep = 6 -- UCC
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SET @cBarcode = @cUCC
            SET @cUCC = ''

            IF (LEN(@cBarcode) - LEN(REPLACE(@cBarcode, '&',''))) <> 8
            BEGIN
               SET @nErrNo = 246801
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format
               GOTO Quit 
            END

            BEGIN TRY
               INSERT INTO @tDecodeList
               SELECT [key]+1 AS ItemIndex, value AS Item
               FROM OPENJSON('["' + REPLACE(@cBarcode, '&', '","') + '"]');
            END TRY
            BEGIN CATCH
               SET @nErrNo = 246802
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Deocding Failure
               GOTO Quit 
            END CATCH

            IF @nDebugFlag = 1
            BEGIN
               SELECT 'Decoding ', @cBarcode
               SELECT * FROM @tDecodeList
            END

            -- set values
            SELECT @cLocaleUCC = 
                  CONCAT(
                     (SELECT Item FROM @tDecodeList WHERE ItemIndex = 4),
                     '&',
                     (SELECT Item FROM @tDecodeList WHERE ItemIndex = 5),
                     '&',
                     (SELECT Item FROM @tDecodeList WHERE ItemIndex = 7)
                  );

            IF ISNULL(@cLocaleUCC, '') = '' OR LEN(@cLocaleUCC) > 20
            BEGIN
               SET @nErrNo = 246803
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid UCC No.
               GOTO Quit
            END

            IF NOT EXISTS (
                  SELECT 1 
                  FROM dbo.UCC WITH (NOLOCK) 
                  WHERE StorerKey = @cStorerKey 
                     AND UCCNo = @cLocaleUCC
            )
            BEGIN
               SET @nErrNo = 246804
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC NOT Found
               GOTO Quit
            END

            SELECT @cSKUBUSR5 = Item FROM @tDecodeList WHERE ItemIndex = 2
            SELECT @cSKUBUSR6 = Item FROM @tDecodeList WHERE ItemIndex = 3

            SELECT @cSKU = SKU
            FROM dbo.SKU WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND BUSR5 = @cSKUBUSR5
               AND BUSR6 = @cSKUBUSR6

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount = 0
            BEGIN
               SET @nErrNo = 246805
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU NOT Found
               GOTO Quit
            END

            IF @nRowCount > 1
            BEGIN
               SET @nErrNo = 246806
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Mulit SKU
               GOTO Quit
            END

           SELECT @cAttribute1 = 
                  CONCAT(
                     (SELECT Item FROM @tDecodeList WHERE ItemIndex = 6),
                     (SELECT Item FROM @tDecodeList WHERE ItemIndex = 9)
                  );

            IF @nDebugFlag = 1
               SELECT @cLocaleUCC AS UCC, @cSKU AS SKU, @cAttribute1 AS Attritbute1,
                     @cSKUBUSR5 AS BUSR5, @cSKUBUSR6 AS BUSR6

            IF NOT EXISTS (
               SELECT 1 FROM dbo.MasterSerialNo WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND SerialNo = @cLocaleUCC
                  AND Attribute1 = @cAttribute1
                  AND SKU = @cSKU
                  AND UnitType = 'UCC'
            )
            BEGIN
               SET @nErrNo = 246807
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Validation failed
               GOTO Quit
            END

            IF NOT EXISTS (
               SELECT 1 FROM dbo.ReceiptDetail WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND ReceiptKey = @cReceiptKey
                  AND userdefine01 = @cLocaleUCC
            )
            BEGIN
               SET @nErrNo = 246808
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Not found in ASN
               GOTO Quit
            END

            SET @cUCC = @cLocaleUCC
            SET @cLottable01 = @cAttribute1
         END
      END
   END

   Quit:

END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_898DecodeSP02 TO NSQL
GO
