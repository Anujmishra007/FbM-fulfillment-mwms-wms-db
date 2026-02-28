SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/**************************************************************************/
/* Store procedure: rdt_898RcvFilter10                                    */
/* Copyright      : Maersk WMS                                            */
/* Customer       :                                                       */
/*                                                                        */
/* Purpose: Filter By Lottables RCPDETFLTR                                */
/*                                                                        */
/* Date        Rev    Author      Purposes                                */
/* 2025-11-02  1.0.0  Dennis      FCR-8472 Create                         */
/* 2026-02-25  1.1.0  NYE018      FCR-10500 Consider only YYYYMM for lot3 */
/**************************************************************************/

CREATE OR ALTER PROC rdt.rdt_898RcvFilter10
@nMobile     INT
,@nFunc       INT
,@cLangCode   NVARCHAR(  3)
,@cReceiptKey NVARCHAR( 10)
,@cPOKey      NVARCHAR( 10)
,@cToLOC      NVARCHAR( 10)
,@cToID       NVARCHAR( 18)
,@cLottable01 NVARCHAR( 18)
,@cLottable02 NVARCHAR( 18)
,@cLottable03 NVARCHAR( 18)
,@dLottable04 DATETIME
,@cSKU        NVARCHAR( 20)
,@cUCC        NVARCHAR( 20)
,@nQTY        INT
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
         CASE @CurrentField
            WHEN 'Lottable01' THEN '     AND Lottable01 = ' + QUOTENAME(@cLottable01,'''')
            WHEN 'Lottable02' THEN '     AND Lottable02 = ' + QUOTENAME(@cLottable02,'''')
            WHEN 'Lottable03' THEN '     AND LEFT(Lottable03, 6) = ' + QUOTENAME(LEFT(@cLottable03, 6),'''') -- FCR-10500 (NYE018)
            WHEN 'Lottable04' THEN '     AND Lottable04 = ' + QUOTENAME(CONVERT( NVARCHAR(20), @dLottable04,120),'''')
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
GRANT EXECUTE ON RDT.rdt_898RcvFilter10 TO NSQL
GO

