SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_LottableProcess_RIMVal                                */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: Validate LOTTABLE04 (expiry date) shelf-life during receiving     */
/*          for RIMAN storer (DE003, Germany)                                 */
/*                                                                            */
/* Date         Author     Ver.  Purposes                                     */
/* 2026-09-09   JACKC      1.0   FCR-15210. Created                           */
/******************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_LottableProcess_RIMVal
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

   DECLARE @nShelfLife INT

   SET @nErrNo = 0

   IF @cType = 'POST'
   BEGIN
      IF @nFunc = 600
      BEGIN
         IF @nLottableNo = 4
         BEGIN
            -- Check if expiry date is provided
            IF @dLottable04Value IS NULL
            BEGIN
               SET @nErrNo = 280501
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lottable04 req
               GOTO Quit
            END

            -- Get shelf life days from SKU master
            SELECT @nShelfLife = ShelfLife
            FROM dbo.SKU WITH (NOLOCK)
            WHERE SKU = @cSKU
            AND StorerKey = @cStorerKey

            -- If no shelf life configured, allow through
            IF @nShelfLife IS NULL OR @nShelfLife = 0
               GOTO Quit

            -- Validate remaining shelf life meets minimum requirement
            IF DATEDIFF(DAY, GETDATE(), @dLottable04Value) < @nShelfLife
            BEGIN
               SET @nErrNo = 280502
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Product close to expiry
               GOTO Quit
            END
         END
      END -- Func600
   END

   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON rdt.rdt_LottableProcess_RIMVal TO NSQL
GO
