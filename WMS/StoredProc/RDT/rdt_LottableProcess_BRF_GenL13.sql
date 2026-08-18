SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_LottableProcess_BRF_GenL13                  */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Key in L04 (Expiry date) and populate L13 (Production date) */
/*          L13 = L04 - ShelfLife                                       */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 2026-05-28  1.0  Cuize      FCR-12670. Created for BRF Saudi MLP       */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_LottableProcess_BRF_GenL13]
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

   DECLARE @nShelfLife  INT

   SET @nErrNo = 0

   -- PRE type: Clear values for initial display
   IF @cType = 'PRE'
   BEGIN
      SET @dLottable04 = NULL
      SET @dLottable13 = NULL
      GOTO Quit
   END

   -- Check if Expiry date (L04) is provided
   IF ISNULL(@dLottable04Value, 0) = 0
   BEGIN
      SET @nErrNo = -1  -- Remain on screen
      GOTO Quit
   END

   -- If both L04 and L13 are provided, skip calculation
   IF ISNULL(@dLottable04Value, 0) <> 0 AND ISNULL(@dLottable13Value, 0) <> 0
   BEGIN
      SET @dLottable04 = @dLottable04Value
      SET @dLottable13 = @dLottable13Value
      GOTO Validate_Lottable
   END

   -- Get SKU Shelf Life
   SELECT @nShelfLife = ShelfLife
   FROM dbo.SKU WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
     AND SKU = @cSKU

   -- Validate Shelf Life
   IF ISNULL(@nShelfLife, 0) = 0
   BEGIN
      SET @nErrNo = 268201
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Shelf life is missing
      GOTO Quit
   END

   -- Calculate Production Date: L13 = L04 - ShelfLife
   IF @nLottableNo = 4 AND ISNULL(@dLottable04Value, 0) <> 0
   BEGIN
      SET @dLottable13 = DATEADD(DAY, -@nShelfLife, @dLottable04Value)
      SET @dLottable13 = CONVERT(DATETIME, CONVERT(NVARCHAR(10), @dLottable13, 103), 103)

      SET @nErrNo = -1  -- Display calculated value, next ENTER proceeds
      GOTO Validate_Lottable
   END

Validate_Lottable:

   -- Check: Production date should not be in the future
   IF DATEDIFF(D, GETDATE(), @dLottable13) > 0
   BEGIN
      SET @nErrNo = 268202
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Production date in Future
      GOTO Quit
   END

   -- Check: Production date < Expiry date
   IF DATEDIFF(D, @dLottable13, @dLottable04Value) <= 0
   BEGIN
      SET @nErrNo = 268203
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Expiry is too old
      GOTO Quit
   END

Quit:

END -- End Procedure
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_LottableProcess_BRF_GenL13 TO NSQL
GO
