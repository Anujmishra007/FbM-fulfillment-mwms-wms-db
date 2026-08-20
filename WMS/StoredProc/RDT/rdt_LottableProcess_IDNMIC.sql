SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_LottableProcess_IDNMIC                                */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: POST - Update ReceiptDetail lottable column when a lottable       */
/*          value is captured on screen 3990 (step 99).                       */
/*          ReceiptKey: V_ReceiptKey if set, else V_String22.                 */
/*          Target row: ReceiptKey + ToID (V_ID).                             */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 18-08-2026   JCH507    1.0   FCR-14878 Created                             */
/******************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_LottableProcess_IDNMIC
    @nMobile          INT
   ,@nFunc            INT
   ,@cLangCode        NVARCHAR( 3)
   ,@nInputKey        INT
   ,@cStorerKey       NVARCHAR( 15)
   ,@cSKU             NVARCHAR( 20)
   ,@cLottableCode    NVARCHAR( 30)
   ,@nLottableNo      INT
   ,@cLottable        NVARCHAR( 30)
   ,@cType            NVARCHAR( 10)
   ,@cSourceKey       NVARCHAR( 15)
   ,@cLottable01Value NVARCHAR( 18)
   ,@cLottable02Value NVARCHAR( 18)
   ,@cLottable03Value NVARCHAR( 18)
   ,@dLottable04Value DATETIME
   ,@dLottable05Value DATETIME
   ,@cLottable06Value NVARCHAR( 30)
   ,@cLottable07Value NVARCHAR( 30)
   ,@cLottable08Value NVARCHAR( 30)
   ,@cLottable09Value NVARCHAR( 30)
   ,@cLottable10Value NVARCHAR( 30)
   ,@cLottable11Value NVARCHAR( 30)
   ,@cLottable12Value NVARCHAR( 30)
   ,@dLottable13Value DATETIME
   ,@dLottable14Value DATETIME
   ,@dLottable15Value DATETIME
   ,@cLottable01      NVARCHAR( 18) OUTPUT
   ,@cLottable02      NVARCHAR( 18) OUTPUT
   ,@cLottable03      NVARCHAR( 18) OUTPUT
   ,@dLottable04      DATETIME      OUTPUT
   ,@dLottable05      DATETIME      OUTPUT
   ,@cLottable06      NVARCHAR( 30) OUTPUT
   ,@cLottable07      NVARCHAR( 30) OUTPUT
   ,@cLottable08      NVARCHAR( 30) OUTPUT
   ,@cLottable09      NVARCHAR( 30) OUTPUT
   ,@cLottable10      NVARCHAR( 30) OUTPUT
   ,@cLottable11      NVARCHAR( 30) OUTPUT
   ,@cLottable12      NVARCHAR( 30) OUTPUT
   ,@dLottable13      DATETIME      OUTPUT
   ,@dLottable14      DATETIME      OUTPUT
   ,@dLottable15      DATETIME      OUTPUT
   ,@nErrNo           INT           OUTPUT
   ,@cErrMsg          NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag  INT = 0

   DECLARE @cReceiptKey NVARCHAR(10)
   DECLARE @cID         NVARCHAR(18)

   IF @nDebugFlag = 1
      SELECT @cLottableCode AS LottableCode, @nLottableNo AS LottableNo, @cLottable AS LottableValue, @cType AS Type

   IF @cType = 'POST'
   BEGIN
      SELECT @cReceiptKey = CASE WHEN ISNULL(V_ReceiptKey, '') = '' THEN V_String22 ELSE V_ReceiptKey END,
             @cID         = V_ID
      FROM rdt.rdtMobRec WITH (NOLOCK)
      WHERE Mobile = @nMobile

      IF @nDebugFlag = 1
         SELECT 'Update ReceiptDetail', @cReceiptKey AS ReceiptKey, @cID AS ToID

      BEGIN TRY
         IF @nLottableNo = 1  AND @cLottable        <> ''         UPDATE dbo.ReceiptDetail WITH (ROWLOCK) SET Lottable01 = @cLottable    WHERE ReceiptKey = @cReceiptKey AND ToID = @cID AND FinalizeFlag <> 'Y' ELSE
         IF @nLottableNo = 2  AND @cLottable        <> ''         UPDATE dbo.ReceiptDetail WITH (ROWLOCK) SET Lottable02 = @cLottable    WHERE ReceiptKey = @cReceiptKey AND ToID = @cID AND FinalizeFlag <> 'Y' ELSE
         IF @nLottableNo = 3  AND @cLottable        <> ''         UPDATE dbo.ReceiptDetail WITH (ROWLOCK) SET Lottable03 = @cLottable    WHERE ReceiptKey = @cReceiptKey AND ToID = @cID AND FinalizeFlag <> 'Y' ELSE
         IF @nLottableNo = 4  AND @dLottable04Value IS NOT NULL   UPDATE dbo.ReceiptDetail WITH (ROWLOCK) SET Lottable04 = @dLottable04Value  WHERE ReceiptKey = @cReceiptKey AND ToID = @cID AND FinalizeFlag <> 'Y' ELSE
         IF @nLottableNo = 5  AND @dLottable05Value IS NOT NULL   UPDATE dbo.ReceiptDetail WITH (ROWLOCK) SET Lottable05 = @dLottable05Value  WHERE ReceiptKey = @cReceiptKey AND ToID = @cID AND FinalizeFlag <> 'Y' ELSE
         IF @nLottableNo = 6  AND @cLottable        <> ''         UPDATE dbo.ReceiptDetail WITH (ROWLOCK) SET Lottable06 = @cLottable    WHERE ReceiptKey = @cReceiptKey AND ToID = @cID AND FinalizeFlag <> 'Y' ELSE
         IF @nLottableNo = 7  AND @cLottable        <> ''         UPDATE dbo.ReceiptDetail WITH (ROWLOCK) SET Lottable07 = @cLottable    WHERE ReceiptKey = @cReceiptKey AND ToID = @cID AND FinalizeFlag <> 'Y' ELSE
         IF @nLottableNo = 8  AND @cLottable        <> ''         UPDATE dbo.ReceiptDetail WITH (ROWLOCK) SET Lottable08 = @cLottable    WHERE ReceiptKey = @cReceiptKey AND ToID = @cID AND FinalizeFlag <> 'Y' ELSE
         IF @nLottableNo = 9  AND @cLottable        <> ''         UPDATE dbo.ReceiptDetail WITH (ROWLOCK) SET Lottable09 = @cLottable    WHERE ReceiptKey = @cReceiptKey AND ToID = @cID AND FinalizeFlag <> 'Y' ELSE
         IF @nLottableNo = 10 AND @cLottable        <> ''         UPDATE dbo.ReceiptDetail WITH (ROWLOCK) SET Lottable10 = @cLottable    WHERE ReceiptKey = @cReceiptKey AND ToID = @cID AND FinalizeFlag <> 'Y' ELSE
         IF @nLottableNo = 11 AND @cLottable        <> ''         UPDATE dbo.ReceiptDetail WITH (ROWLOCK) SET Lottable11 = @cLottable    WHERE ReceiptKey = @cReceiptKey AND ToID = @cID AND FinalizeFlag <> 'Y' ELSE
         IF @nLottableNo = 12 AND @cLottable        <> ''         UPDATE dbo.ReceiptDetail WITH (ROWLOCK) SET Lottable12 = @cLottable    WHERE ReceiptKey = @cReceiptKey AND ToID = @cID AND FinalizeFlag <> 'Y' ELSE
         IF @nLottableNo = 13 AND @dLottable13Value IS NOT NULL   UPDATE dbo.ReceiptDetail WITH (ROWLOCK) SET Lottable13 = @dLottable13Value  WHERE ReceiptKey = @cReceiptKey AND ToID = @cID AND FinalizeFlag <> 'Y' ELSE
         IF @nLottableNo = 14 AND @dLottable14Value IS NOT NULL   UPDATE dbo.ReceiptDetail WITH (ROWLOCK) SET Lottable14 = @dLottable14Value  WHERE ReceiptKey = @cReceiptKey AND ToID = @cID AND FinalizeFlag <> 'Y' ELSE
         IF @nLottableNo = 15 AND @dLottable15Value IS NOT NULL   UPDATE dbo.ReceiptDetail WITH (ROWLOCK) SET Lottable15 = @dLottable15Value  WHERE ReceiptKey = @cReceiptKey AND ToID = @cID AND FinalizeFlag <> 'Y'
      END TRY
      BEGIN CATCH
         SET @nErrNo  = 278701
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO Quit
      END CATCH
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON rdt.rdt_LottableProcess_IDNMIC TO NSQL
GO
