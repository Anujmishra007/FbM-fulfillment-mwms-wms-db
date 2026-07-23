/******************************************************************************/
/* Store procedure: rdt_LottableProcess_ExpiredValL04_PGPE                    */
/* Copyright      : LF Logistics                                              */
/* Customer       : PGPE                                                      */
/*                                                                            */
/* Purpose: Dynamic lottable                                                  */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 2026-06-03   MLR024    1.0   RITM9002092/UWP-61806                         */
/*                              Validate Lottable04 is not less than today    */
/*                              for an A-type ASN                             */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_LottableProcess_ExpiredValL04_PGPE]
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

   DECLARE @cCode  NVARCHAR( 10)
   DECLARE @cNotes NVARCHAR( 4000)

   IF @cType = 'POST'
   BEGIN
      IF @nLottableNo = 4
      BEGIN
         IF ISNULL( @dLottable04Value, 0) = 0
         BEGIN
            SET @nErrNo = 275056
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lottable04 req
            GOTO Quit
         END

         IF DATEDIFF( DAY, GETDATE(), @dLottable04) < 0
            AND EXISTS (
               SELECT 1
               FROM dbo.RECEIPT WITH (NOLOCK)
               WHERE ReceiptKey = @cSourceKey
                  AND StorerKey = @cStorerKey
                  AND DOCTYPE = 'A'
            )
         BEGIN
            SET @nErrNo = 275057
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ExpDate<Today
            GOTO Quit
         END
      END
   END

Quit:
END
GO

GRANT EXECUTE ON [RDT].[rdt_LottableProcess_ExpiredValL04_PGPE] TO [NSQL]
GO
