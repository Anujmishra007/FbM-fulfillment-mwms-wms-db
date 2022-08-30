SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_LottableProcess_GenLot3Lot4ByLot02_02                 */
/* Copyright      : LF Logistics                                              */
/*                                                                            */
/* Purpose: Dynamic lottable                                                  */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 09-Aug-2022  Ung       1.0   WMS-20425 Created                             */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_LottableProcess_GenLot3Lot4ByLot02_02]
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
   SET CONCAT_NULL_YIELDS_NULL OFF

   BEGIN TRY
      -- Remove space, dash
      SET @cLottable02Value = REPLACE( @cLottable02Value, ' ', '')
      SET @cLottable02Value = REPLACE( @cLottable02Value, '-', '')
      
      -- Check empty
      IF @cLottable02Value <> ''
      BEGIN
         DECLARE @cYear  NVARCHAR( 2)
         DECLARE @cMonth NVARCHAR( 2)
         DECLARE @cDay   NVARCHAR( 2) = '01'
         DECLARE @nLen   INT = LEN( @cLottable02Value)
         
         IF @nLen = 4
         BEGIN
            SET @cMonth = SUBSTRING( @cLottable02Value, 3, 1)
            SET @cYear = SUBSTRING( @cLottable02Value, 4, 1)
            
            -- Convert month to 2 digits
            SELECT @cMonth = 
               CASE @cMonth 
                  WHEN 'A' THEN '01'
                  WHEN 'B' THEN '02'
                  WHEN 'C' THEN '03'
                  WHEN 'D' THEN '04'
                  WHEN 'E' THEN '05'
                  WHEN 'F' THEN '06'
                  WHEN 'G' THEN '07'
                  WHEN 'H' THEN '08'
                  WHEN 'I' THEN '09'
                  WHEN 'J' THEN '10'
                  WHEN 'K' THEN '11'
                  WHEN 'L' THEN '12'
                  ELSE ''
               END
               
            -- Convert year to 2 digits
            SELECT @cYear = '2' + @cYear 
         
            DECLARE @nCurrentYear INT = YEAR( GETDATE())
            DECLARE @nInputYear INT = CAST( '20' + @cYear AS INT)
            
            -- Check future date
            IF @nInputYear > @nCurrentYear
               RAISERROR (189551, 16, 1) 
         END

         ELSE IF @nLen = 6
         BEGIN
            DECLARE @cWeek NVARCHAR( 2)
            SET @cYear = SUBSTRING( @cLottable02Value, 1, 2)
            SET @cWeek = SUBSTRING( @cLottable02Value, 3, 2)
            
            DECLARE @dDate DATETIME
            SET @dDate = CONVERT( DATETIME, '01/01/' + @cYear, 1) -- 1 = mm/dd/yy
            SET @dDate = DATEADD( wk, CAST( @cWeek AS INT) - 1, @dDate)
            SET @cMonth = DATEPART( mm, @dDate)
         END

         ELSE IF @nLen > 6
         BEGIN
            SET @cMonth = SUBSTRING( @cLottable02Value, 4, 2)
            SET @cYear = SUBSTRING( @cLottable02Value, 6, 2)
            
            SET @cYear = CAST( @cYear AS INT) - 10
         END
         
         -- Calc L03
         DECLARE @dLottable03Value DATETIME
         SET @cLottable03Value = @cMonth + '/' + @cDay + '/' + @cYear
         SET @dLottable03Value = CONVERT( DATETIME, @cLottable03Value, 1) -- 1 = mm/dd/yy
         
         -- Get SKU info
         DECLARE @nShelfLife INT = 0
         SELECT @nShelfLife = ISNULL( ShelfLife, 0)
         FROM dbo.SKU WITH (NOLOCK) 
         WHERE StorerKey = @cStorerKey 
            AND SKU = @cSKU
         
         -- Calc L04
         SELECT @dLottable04Value = DATEADD( dd, @nShelfLife, @dLottable03Value)
   
         -- Set 1st day of month
         SELECT @dLottable04Value = CONVERT( DATETIME, CAST( MONTH( @dLottable04Value) AS NVARCHAR(2)) + '/01/' + CAST( YEAR( @dLottable04Value) AS NVARCHAR(4)), 101) -- 101 = mm/dd/yyyy

         -- Output
         SELECT @cLottable03 = @cLottable03Value
         SELECT @dLottable04 = @dLottable04Value
      END
   END TRY
   BEGIN CATCH
      SET @nErrNo = 189551
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Decode Error
   END CATCH
END
GO

GRANT EXECUTE ON  [RDT].[rdt_LottableProcess_GenLot3Lot4ByLot02_02] TO [NSQL]
GO
