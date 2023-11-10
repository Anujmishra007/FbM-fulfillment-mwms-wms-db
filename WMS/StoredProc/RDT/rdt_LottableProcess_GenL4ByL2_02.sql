SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_LottableProcess_GenL4ByL2_02                          */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: Dynamic lottable                                                  */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 24-Oct-2023  Ung       1.0   WMS-23917 Created                             */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_LottableProcess_GenL4ByL2_02]
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

   DECLARE @cPrevLottable02 NVARCHAR( 18)
   SELECT @cPrevLottable02 = V_Lottable02 FROM rdt.rdtMobRec WITH (NOLOCK) WHERE Mobile = @nMobile

   IF @cLottable02Value <> '' AND (@cLottable02Value <> @cPrevLottable02)
   BEGIN
      DECLARE @cYearCode   NVARCHAR(4)
      DECLARE @cJulianDate NVARCHAR(7)
      DECLARE @nLength     INT
      DECLARE @nYear       INT
      DECLARE @nDayOfYear  INT

      SET @nLength = LEN( @cLottable02Value)

      IF @nLength = 0
         GOTO Quit
      
      IF @cLottable02Value = 'NB'
      BEGIN
         SET @dLottable04 = CONVERT( DATETIME, '2099/12/31', 111) -- 111=YYYY/MM/DD
         SET @nErrNo = -1
      END

      -- Digit (e.g. 1002021193)
      ELSE IF @cLottable02Value NOT LIKE '%[^0-9]%'
      BEGIN
         SET @cYearCode = SUBSTRING( @cLottable02Value, 4, 4)
         SET @nYear = TRY_CAST( @cYearCode AS INT)
         SET @nDayOfYear = TRY_CAST( RIGHT( @cLottable02Value, 3) AS INT)
         
         -- Check year abstracted
         IF @nYear IS NULL
         BEGIN
            SET @nErrNo = 207551
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Year
            GOTO Quit
         END

         -- Check day of year abstracted
         IF @nDayOfYear IS NULL
         BEGIN
            SET @nErrNo = 207552
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Day
            GOTO Quit
         END
         
         -- Top up year, day of year
         SET @nYear += 3
         SET @nDayOfYear += 1
         
         -- Check day of year in range
         IF ((@nYear % 4 = 0 AND @nYear % 100 <> 0) OR @nYear % 400 = 0)
         BEGIN
            IF @nDayOfYear > 366 OR @nDayOfYear = 0
            BEGIN
               SET @nErrNo = 207553
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Day
               GOTO Quit
            END
         END
         ELSE
         BEGIN
            IF @nDayOfYear > 365 OR @nDayOfYear = 0
            BEGIN
               SET @nErrNo = 207554
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Day
               GOTO Quit
            END
         END

         SET @cJulianDate = RIGHT( '000' + CAST( @nYear AS NVARCHAR( 4)), 4) + RIGHT( '00' + CAST( @nDayOfYear AS NVARCHAR( 3)), 3)
         SET @dLottable04 = CONVERT( DATETIME, (DATEADD(dd, (@cJulianDate - ((@cJulianDate/1000) * 1000)) - 1, DATEADD(yy, @cJulianDate/1000 - 1900, 0)) ),103)
         SET @nErrNo = -1
      END

      -- Alpha (e.g. 102265B3B1)
      ELSE
      BEGIN
         DECLARE @nYearDigit INT
         SET @nYearDigit = TRY_CAST( SUBSTRING( @cLottable02Value, 3, 1) AS INT)
         SET @nDayOfYear = TRY_CAST( SUBSTRING( @cLottable02Value, 4, 3) AS INT)
         
         -- Check year abstracted
         IF @nYearDigit IS NULL
         BEGIN
            SET @nErrNo = 207555
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Year
            GOTO Quit
         END

         -- Check day of year abstracted
         IF @nDayOfYear IS NULL
         BEGIN
            SET @nErrNo = 207556
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Day
            GOTO Quit
         END

         -- Calc 
         SET @nYear = (YEAR( GETDATE()) / 10 * 10) + (@nYearDigit + 3)  -- (get decade) + year
         SET @nDayOfYear += 1
         
         -- Check day of year in range
         IF ((@nYear % 4 = 0 AND @nYear % 100 <> 0) OR @nYear % 400 = 0)
         BEGIN
            IF @nDayOfYear > 366 OR @nDayOfYear = 0
            BEGIN
               SET @nErrNo = 207557
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Day
               GOTO Quit
            END
         END
         ELSE
         BEGIN
            IF @nDayOfYear > 365 OR @nDayOfYear = 0
            BEGIN
               SET @nErrNo = 207558
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Day
               GOTO Quit
            END
         END
         
         SET @cJulianDate = RIGHT( '000' + CAST( @nYear AS NVARCHAR( 4)), 4) + RIGHT( '00' + CAST( @nDayOfYear AS NVARCHAR( 3)), 3)
         SET @dLottable04 = CONVERT( DATETIME, (DATEADD(dd, (@cJulianDate - ((@cJulianDate/1000) * 1000)) - 1, DATEADD(yy, @cJulianDate/1000 - 1900, 0)) ),103)
         SET @nErrNo = -1
      END
   END
   
Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_LottableProcess_GenL4ByL2_02] TO [NSQL]
GO
