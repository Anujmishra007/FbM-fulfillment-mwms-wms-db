SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_LottableProcess_CS_GenL2ByL13                   */
/* Copyright      : MWMS                                                */
/*                                                                      */
/* Purpose: Key in L13 (Production date) and populate L2 (Batch)        */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 28-04-2025  1.0  Abarna S   FCR-4005. Created BRF: Julian Batch conv */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_LottableProcess_CS_GenL2ByL13] 
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

   DECLARE @cSKUgroup  nvarchar(30)

   SET @nErrNo = 0

   IF @cType = 'PRE'
   BEGIN
      SET @cLottable02 = NULL
      SET @dLottable13 = NULL

      GOTO Quit
   END

   IF @dLottable13 = '' OR @dLottable13 IS NULL
      GOTO Fail

   -- Get SKUgroup  info to validate Julian Batch or not
   SELECT @cSKUgroup = skugroup 
   FROM dbo.SKU WITH(NOLOCK) 
   WHERE StorerKey = @cStorerKey 
      AND sku= @cSKU

   --AddJuliandate
   IF @cSKUgroup = 'Julian'
      SET @cLottable02 = '999' + RIGHT(CAST(YEAR(@dLottable13) AS VARCHAR), 1) + RIGHT('000' + CAST(DATEPART(DAYOFYEAR, @dLottable13) AS VARCHAR), 3) 
      -- Non-Julian
      --ELSE IF @cSKUgroup <> 'Julian'
      --SET @cLottable02 = '999' +  RIGHT(CONCAT('0', MONTH(@dLottable04)), 2) + RIGHT(CAST(YEAR(@dLottable04) AS VARCHAR), 2)
   ELSE 
      GOTO Quit

Fail:
   -- Setup error, or L02/L13 empty
   IF (@cLottable02 = 0 OR @cLottable02 IS NULL) OR (@dLottable13 = 0 OR @dLottable13 IS NULL) 
   BEGIN
      -- Remain in current screen
      SET @nErrNo = -1 
      GOTO Quit
   END
Quit:

END -- End Procedure
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON rdt.rdt_LottableProcess_CS_GenL2ByL13 TO NSQL
GO


