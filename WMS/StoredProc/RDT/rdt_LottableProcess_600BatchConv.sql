SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_LottableProcess_600BatchConv                          */
/* Copyright      : Maersk WMS                                                */
/* Customer       : Chanel or can be setup for anyothers require this process */
/*                                                                            */
/* Purpose: Dynamic lottable processing for FN600 Normal Receiving            */
/*          Derives Expiry Date from Batch Code (Lottable02)                  */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 2026-01-14   NYE018    1.0   FCR-9980                                      */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_LottableProcess_600BatchConv]
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

   IF @cType = 'POST'
   BEGIN
      -- Processing for Batch Code (Lottable02)
      IF @nLottableNo = 2 
      BEGIN
         -- 1.1 Validate Format: Must be exactly 4 digits, all numeric
         IF LEN(@cLottable02) <> 4 
         BEGIN
             SET @nErrNo = 256351
             SET @cErrMsg = rdt.rdtGetMessage(@nErrNo, @cLangCode, N'DSP') -- InvalidBatchCodeLength
             GOTO Quit
         END

        -- 1.2 Validate Format: Must be numeric
         IF @cLottable02 LIKE '%[^0-9]%'
         BEGIN
             SET @nErrNo = 256352
             SET @cErrMsg = rdt.rdtGetMessage(@nErrNo, @cLangCode, N'DSP') -- InvalidBatchCodeNumeric
             GOTO Quit
         END

         DECLARE @nBatchCodePrefix INT
         DECLARE @dProductionDate DATE
         DECLARE @dExpiryDate DATE
         DECLARE @nCurrentDate DATE = GETDATE()
         
         -- Parse first two digits
         SET @nBatchCodePrefix = TRY_CAST(SUBSTRING(@cLottable02, 1, 2) AS INT)

         -- Validate Prefix Range (01-96 covers the 8-year cycle)
         IF @nBatchCodePrefix < 1 OR @nBatchCodePrefix > 96
         BEGIN
             SET @nErrNo = 256353
             SET @cErrMsg = rdt.rdtGetMessage(@nErrNo, @cLangCode, N'DSP') -- InvalidBatchMonth
             GOTO Quit
         END

         -- 2. Calculate Production Date
         -- Mapping: 01 = Jan 2024 ... 96 = Dec 2031
         -- Formula: 
         --   YearOffset = (Prefix - 1) / 12
         --   Month      = (Prefix - 1) % 12 + 1
         --   Base Year  = 2024
         
         DECLARE @nProdYear INT
         DECLARE @nProdMonth INT
         
         SET @nProdYear = 2024 + ((@nBatchCodePrefix - 1) / 12)
         SET @nProdMonth = ((@nBatchCodePrefix - 1) % 12) + 1
         
         SET @dProductionDate = DATEFROMPARTS(@nProdYear, @nProdMonth, 1)

         -- 4. Calculate Expiry Date
         -- Rule: Production Date + 3 Years. Expiry is the LAST day of that month.
         SET @dExpiryDate = DATEADD(YEAR, 3, @dProductionDate)
         -- Set to End Of Month
         SET @dExpiryDate = EOMONTH(@dExpiryDate)

         -- 5. Set Output Parameter (Lottable04)
         SET @dLottable04 = @dExpiryDate

      END
   END

   Quit:
   
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
GRANT EXECUTE ON [rdt].[rdt_LottableProcess_600BatchConv] TO NSQL
GO