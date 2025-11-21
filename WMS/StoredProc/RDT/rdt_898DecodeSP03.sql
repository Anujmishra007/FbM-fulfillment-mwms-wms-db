
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************/
/* Store procedure: rdt_898DecodeSP03                                         */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Customer: Decode for PAGE                                                  */
/*                                                                            */
/* Date        Author   Ver.  Purposes                                        */
/* 2025-10-27  Dennis   1.0   FCR-8472 Created                                */
/******************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_898DecodeSP03] (
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
      ,@cFirstChar  NCHAR(1)
      ,@cSecondChar NCHAR(1)
      ,@cThirdChar  NCHAR(1)
      ,@cYearChar   NVARCHAR(10)
      ,@cMonthChar  NVARCHAR(10)
      ,@cDateChar   NVARCHAR(10)

   SET @cBarcode = replace(TRIM(@cUCC),' ','')
   IF @nFunc = 898 -- UCC receiving
   BEGIN
      IF @nStep = 6 -- UCC
      BEGIN
         IF LEN(@cBarcode) < 20
         BEGIN
            SET @nErrNO = 250753
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
            GOTO QUIT
         END
         SELECT @cLottable01 = EXTERNRECEIPTKEY FROM Receipt (NOLOCK) WHERE ReceiptKey = @cReceiptKey AND StorerKey = @cStorerKey
         IF LEN(@cBarcode) IN( 40 , 44)
         BEGIN
            SELECT 
            @cUCC = CASE 
               WHEN CHARINDEX('(240)', @cBarcode) > 0 THEN
                     SUBSTRING(
                        @cBarcode,
                        CHARINDEX('(240)', @cBarcode) + 5,
                        LEN(@cBarcode)
                     )
               ELSE NULL
            END,
            @cLottable02 = 
            CASE 
               WHEN CHARINDEX('(10)', @cBarcode) > 0 AND CHARINDEX('(11)', @cBarcode) > CHARINDEX('(10)', @cBarcode) THEN
                     SUBSTRING(
                        @cBarcode,
                        CHARINDEX('(10)', @cBarcode) + 4,
                        CHARINDEX('(11)', @cBarcode) - CHARINDEX('(10)', @cBarcode) - 4
                     )
               ELSE NULL
            END,
            @cLottable03 = 
            CASE 
               WHEN CHARINDEX('(11)', @cBarcode) > 0 AND CHARINDEX('(240)', @cBarcode) > CHARINDEX('(11)', @cBarcode) THEN
                     CASE 
                        WHEN ISNUMERIC(
                           SUBSTRING(
                                 @cBarcode,
                                 CHARINDEX('(11)', @cBarcode) + 4,
                                 CHARINDEX('(240)', @cBarcode) - CHARINDEX('(11)', @cBarcode) - 4
                           )
                        ) = 1 
                        AND LEN(
                           SUBSTRING(
                                 @cBarcode,
                                 CHARINDEX('(11)', @cBarcode) + 4,
                                 CHARINDEX('(240)', @cBarcode) - CHARINDEX('(11)', @cBarcode) - 4
                           )
                        ) = 6 THEN
                          
                           '20' + LEFT(
                                 SUBSTRING(
                                    @cBarcode,
                                    CHARINDEX('(11)', @cBarcode) + 4,
                                    CHARINDEX('(240)', @cBarcode) - CHARINDEX('(11)', @cBarcode) - 4
                                 ), 2
                           )  +
                           SUBSTRING(
                                 SUBSTRING(
                                    @cBarcode,
                                    CHARINDEX('(11)', @cBarcode) + 4,
                                    CHARINDEX('(240)', @cBarcode) - CHARINDEX('(11)', @cBarcode) - 4
                                 ), 3, 2
                           ) +
                           RIGHT(
                                 SUBSTRING(
                                    @cBarcode,
                                    CHARINDEX('(11)', @cBarcode) + 4,
                                    CHARINDEX('(240)', @cBarcode) - CHARINDEX('(11)', @cBarcode) - 4
                                 ), 2
                           ) 
                        ELSE NULL
                     END
               ELSE NULL
            END
         END
         ELSE IF LEN(@cBarcode) = 34
         BEGIN
            SELECT 
               @cUCC = RIGHT(@cBarcode, 20),
               
               @cUserDefine05 = LEFT(@cBarcode, LEN(@cBarcode) - 20),
               
               @cLottable02 = SUBSTRING(@cBarcode, 3, 7),
               
               @cLottable03 = CASE 
                  WHEN LEN(@cBarcode) >= 19 THEN
                        '20' + LEFT(SUBSTRING(@cBarcode, 14, 6), 2) +
                        SUBSTRING(SUBSTRING(@cBarcode, 14, 6), 3, 2) +
                        RIGHT(SUBSTRING(@cBarcode, 14, 6), 2) 
                  ELSE NULL
               END
         END
         ELSE IF LEN(@cBarcode) = 67
         BEGIN
            SELECT 
               @cUCC = SUBSTRING(@cBarcode, 19, 19),
               
               @cUserDefine01 = SUBSTRING(@cBarcode, 51, 8),
               
               @cLottable02 = SUBSTRING(@cBarcode, 40, 8),
               
               @cLottable03 = SUBSTRING(@cBarcode, 23, 3)
               
            SELECT @cFirstChar = SUBSTRING(@cLottable03,1,1),
                  @cSecondChar = SUBSTRING(@cLottable03,2,1),
                  @cThirdChar = SUBSTRING(@cLottable03,3,1);
            WITH CurrentDecade AS (
               SELECT 
                  number AS decade_index,
                  (YEAR(GETDATE()) / 10) * 10 + number AS decade_year
               FROM (
                  SELECT 0 AS number UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
                  UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
               ) numbers
            )
            SELECT 
               @cYearChar = decade_year
            FROM CurrentDecade
            WHERE decade_index = @cFirstChar

            SELECT 
               @cMonthChar = Short
            FROM CodeLKUP WITH (NOLOCK)
            WHERE ListName = 'BAT_MFGDT' AND StorerKey = @cStorerKey
            AND CODE2 = @cSecondChar AND Code = '2'

            SELECT 
               @cDateChar = Short
            FROM CodeLKUP WITH (NOLOCK)
            WHERE ListName = 'BAT_MFGDT' AND StorerKey = @cStorerKey
            AND CODE2 = @cThirdChar AND Code = '3'

            SET @cLottable03 =   @cYearChar + RIGHT(@cMonthChar, 2) + RIGHT(@cDateChar, 2) 
         END
      END
      IF @nStep = 8 -- Sku
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF LEN(@cBarcode) = 17
            BEGIN
               SELECT @cUserDefine01 = 
               CASE 
                  WHEN CHARINDEX('(21)', @cBarcode) > 0 AND CHARINDEX('(241)', @cBarcode) > CHARINDEX('(21)', @cBarcode) THEN
                        SUBSTRING(
                           @cBarcode,
                           CHARINDEX('(21)', @cBarcode) + 4,
                           CHARINDEX('(241)', @cBarcode) - CHARINDEX('(21)', @cBarcode) - 4
                        )
                  ELSE NULL
               END
               GOTO QUIT
            END
            SELECT @cUserDefine01 = SKU FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND ALTSKU = @cUCC

            IF @@ROWCOUNT = 0
               SET @cUserDefine01 = @cUCC
         END
      END
   END

   Quit:

END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_898DecodeSP03 TO NSQL
GO
