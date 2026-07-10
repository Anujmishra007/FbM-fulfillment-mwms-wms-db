SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_LottableProcess_BRF_GenL2                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Generate L02 (Batch) based on SKU Group after L04 input     */
/*          Julian:     999 + Y + DDD (from Production Date L13)        */
/*          Non-Julian: 999 + MM + YY (from Expiry Date L04)            */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 2026-05-28  1.0  Cuize      FCR-12670. Created for BRF Saudi MLP       */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_LottableProcess_BRF_GenL2]
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

   DECLARE @cSKUGroup  NVARCHAR(30)
   DECLARE @nShelfLife INT

   SET @nErrNo = 0

   -- PRE type: Clear values for initial display
   IF @cType = 'PRE'
   BEGIN
      SET @cLottable02 = NULL
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

   -- Get SKU info
   SELECT @cSKUGroup = SKUGroup,
          @nShelfLife = ShelfLife
   FROM dbo.SKU WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
     AND SKU = @cSKU

   -- Validate Shelf Life
   IF ISNULL(@nShelfLife, 0) = 0
   BEGIN
      SET @nErrNo = 268251
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Shelf life is missing
      GOTO Quit
   END

   -- Calculate Production Date if not provided: L13 = L04 - ShelfLife
   IF ISNULL(@dLottable13Value, 0) = 0
   BEGIN
      SET @dLottable13 = DATEADD(DAY, -@nShelfLife, @dLottable04Value)
      SET @dLottable13 = CONVERT(DATETIME, CONVERT(NVARCHAR(10), @dLottable13, 103), 103)
   END
   ELSE
   BEGIN
      SET @dLottable13 = @dLottable13Value
   END

   -- Validate: Production date should not be in the future
   IF DATEDIFF(D, GETDATE(), @dLottable13) > 0
   BEGIN
      SET @nErrNo = 268252
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Production date in Future
      GOTO Quit
   END

   -- Validate: Production date < Expiry date
   IF DATEDIFF(D, @dLottable13, @dLottable04Value) <= 0
   BEGIN
      SET @nErrNo = 268253
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Expiry is too old
      GOTO Quit
   END

   -- Generate Batch (L02) based on SKU Group
   IF @cSKUGroup = 'Julian'
   BEGIN
      -- Julian: 999 + Y (last digit of year) + DDD (day of year from Production Date)
      -- Example: Production 03-03-2025 → 9995062
      SET @cLottable02 = '999'
         + RIGHT(CAST(YEAR(@dLottable13) AS VARCHAR), 1)
         + RIGHT('000' + CAST(DATEPART(DAYOFYEAR, @dLottable13) AS VARCHAR), 3)
   END
   ELSE
   BEGIN
      -- Non-Julian: 999 + MM + YY (from Expiry Date)
      -- Example: Expiry 30-04-2026 → 9990426
      SET @cLottable02 = '999'
         + RIGHT('00' + CAST(MONTH(@dLottable04Value) AS VARCHAR), 2)
         + RIGHT(CAST(YEAR(@dLottable04Value) AS VARCHAR), 2)
   END

   -- Set output values
   SET @dLottable04 = @dLottable04Value

Quit:

END -- End Procedure
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_LottableProcess_BRF_GenL2 TO NSQL
GO
