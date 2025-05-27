SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/**************************************************************************/
/* Store procedure: rdt_600RcvFilter09                                    */
/* Copyright      : Maersk WMS                                            */
/* Customer       : HerbaLife                                             */
/*                                                                        */
/* Purpose: Filter By Lottables RCPDETFLTR                                */
/*                                                                        */
/* Date        Rev    Author      Purposes                                */
/* 2025-04-14  1.0.0  CYU027      FCR-3472 Create                         */
/* 2025-05-26  1.1.0  Dennis      UWP-34993 Fix Bugs                      */
/**************************************************************************/

CREATE OR ALTER PROC rdt.rdt_600RcvFilter09
    @nMobile     INT
   ,@nFunc       INT
   ,@cLangCode   NVARCHAR(  3)
   ,@cReceiptKey NVARCHAR( 10)
   ,@cPOKey      NVARCHAR( 10)
   ,@cToLOC      NVARCHAR( 10)
   ,@cToID       NVARCHAR( 18)
   ,@cSKU        NVARCHAR( 20)
   ,@cUCC        NVARCHAR( 20)
   ,@nQTY        INT
   ,@cLottable01 NVARCHAR( 18)
   ,@cLottable02 NVARCHAR( 18)
   ,@cLottable03 NVARCHAR( 18)
   ,@dLottable04 DATETIME
   ,@dLottable05 DATETIME
   ,@cLottable06 NVARCHAR( 30)
   ,@cLottable07 NVARCHAR( 30)
   ,@cLottable08 NVARCHAR( 30)
   ,@cLottable09 NVARCHAR( 30)
   ,@cLottable10 NVARCHAR( 30)
   ,@cLottable11 NVARCHAR( 30)
   ,@cLottable12 NVARCHAR( 30)
   ,@dLottable13 DATETIME
   ,@dLottable14 DATETIME
   ,@dLottable15 DATETIME
   ,@cCustomSQL  NVARCHAR( MAX) OUTPUT
   ,@nErrNo      INT            OUTPUT
   ,@cErrMsg     NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cStorerKey           NVARCHAR(15)
   DECLARE @CurrentField         NVARCHAR(30);


   DECLARE @Fields TABLE (
      ID INT IDENTITY(1,1) PRIMARY KEY,
      Fields NVARCHAR(30)
   );

   SELECT @cStorerKey = StorerKey FROM dbo.Receiptdetail WITH (NOLOCK) WHERE ReceiptKey = @cReceiptKey

   INSERT INTO @Fields (Fields)
   SELECT code2 FROM CODELKUP
   WHERE LISTNAME = 'RCPDETFLTR'
      AND Storerkey = @cStorerKey
      AND code = @nFunc


   DECLARE @RowCount INT = (SELECT COUNT(*) FROM @Fields);
   DECLARE @Index INT = 1;

   WHILE @Index <= @RowCount
   BEGIN

      SELECT @CurrentField = Fields
      FROM @Fields
      WHERE ID = @Index;

      SET @cCustomSQL = @cCustomSQL +
         CASE 
            WHEN @CurrentField = 'Lottable01' AND ISNULL(@cLottable01, '') <> '' THEN '     AND Lottable01 = ' + QUOTENAME(@cLottable01, '''')
            WHEN @CurrentField = 'Lottable02' AND ISNULL(@cLottable02, '') <> '' THEN '     AND Lottable02 = ' + QUOTENAME(@cLottable02, '''')
            WHEN @CurrentField = 'Lottable03' AND ISNULL(@cLottable03, '') <> '' THEN '     AND Lottable03 = ' + QUOTENAME(@cLottable03, '''')
            WHEN @CurrentField = 'Lottable04' AND ISNULL(@dLottable04, '') <> '' THEN '     AND Lottable04 = ' + QUOTENAME(CONVERT(NVARCHAR(20), @dLottable04, 120), '''')
            WHEN @CurrentField = 'Lottable05' AND ISNULL(@dLottable05, '') <> '' THEN '     AND Lottable05 = ' + QUOTENAME(CONVERT(NVARCHAR(20), @dLottable05, 120), '''')
            WHEN @CurrentField = 'Lottable06' AND ISNULL(@cLottable06, '') <> '' THEN '     AND Lottable06 = ' + QUOTENAME(@cLottable06, '''')
            WHEN @CurrentField = 'Lottable07' AND ISNULL(@cLottable07, '') <> '' THEN '     AND Lottable07 = ' + QUOTENAME(@cLottable07, '''')
            WHEN @CurrentField = 'Lottable08' AND ISNULL(@cLottable08, '') <> '' THEN '     AND Lottable08 = ' + QUOTENAME(@cLottable08, '''')
            WHEN @CurrentField = 'Lottable09' AND ISNULL(@cLottable09, '') <> '' THEN '     AND Lottable09 = ' + QUOTENAME(@cLottable09, '''')
            WHEN @CurrentField = 'Lottable10' AND ISNULL(@cLottable10, '') <> '' THEN '     AND Lottable10 = ' + QUOTENAME(@cLottable10, '''')
            WHEN @CurrentField = 'Lottable11' AND ISNULL(@cLottable11, '') <> '' THEN '     AND Lottable11 = ' + QUOTENAME(@cLottable11, '''')
            WHEN @CurrentField = 'Lottable12' AND ISNULL(@cLottable12, '') <> '' THEN '     AND Lottable12 = ' + QUOTENAME(@cLottable12, '''')
            WHEN @CurrentField = 'Lottable13' AND ISNULL(@dLottable13, '') <> '' THEN '     AND Lottable13 = ' + QUOTENAME(CONVERT(NVARCHAR(20), @dLottable13, 120), '''')
            WHEN @CurrentField = 'Lottable14' AND ISNULL(@dLottable14, '') <> '' THEN '     AND Lottable14 = ' + QUOTENAME(CONVERT(NVARCHAR(20), @dLottable14, 120), '''')
            WHEN @CurrentField = 'Lottable15' AND ISNULL(@dLottable15, '') <> '' THEN '     AND Lottable15 = ' + QUOTENAME(CONVERT(NVARCHAR(20), @dLottable15, 120), '''')
            ELSE ''
         END

      SET @Index = @Index + 1;
   END

QUIT:
END -- End Procedure
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXEC ON RDT.rdt_600RcvFilter09 TO NSQL
GO

