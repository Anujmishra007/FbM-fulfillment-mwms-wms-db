

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_LottableProcess_GenL4ByL3JulianDateBACARDI            */
/* Copyright      :                                                           */
/*                                                                            */
/* Purpose:  Generate Receiptdetail Lottable13 & Lottable04                   */
/*           By JulianDate (format 5 digits) in Lottable03                    */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 2026-08-01   FRO014     1.0  RITM8516320. Created                          */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_LottableProcess_GenL4ByL3JulianDateBACARDI]
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

   DECLARE 
      @nBatchYear         INT,
      @nDaysInYear        INT,
      @cBatchYear         NVARCHAR( 2),
      @cDaysInYear        NVARCHAR( 3),
      @nShelflife         INT,
      @bDebug             INT,
      @cJuliandate         VARCHAR(5),
      @dt_ManufDate        DATETIME

   IF @cType = 'PRE'
   BEGIN
      SET @cLottable03 = ''
      GOTO Quit
   END

   IF @cLottable03Value <> ''
   BEGIN 

     SELECT @nShelflife = Shelflife 
      FROM SKU (NOLOCK)
      WHERE Storerkey = @cStorerKey
      AND   SKU = @cSKU
     
     -- format - Eg. 25218 
     --Validate length
     IF LEN(@cLottable03Value) <> 5
     BEGIN 
         SET @nErrNo = 142006
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'invalid Julian date'
         GOTO QUIT
     END 

     -- Validate data type         
     IF ISNUMERIC(@cLottable03Value) = 0
     BEGIN 
       
         SET @nErrNo = 142007
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'invalid Julian date'
         GOTO QUIT
     END 
     
     -- format - Eg. 25218 
     SET @cBatchYear = LEFT(@cLottable03Value, 2) -- 25
      SET @cDaysInYear = SUBSTRING(@cLottable03Value, 3, 5) -- 218

      -- Validate year
     IF ISNUMERIC(@cBatchYear) = 0
      BEGIN

         SET @nErrNo = 142008
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'invalid year - Julian date'
         GOTO QUIT
      END

      -- Validate day
     IF ISNUMERIC(@cDaysInYear) >= 366 or ISNUMERIC(@cDaysInYear) = 0
      BEGIN
         
         SET @nErrNo = 142009
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'invalid day - Julian date'
         GOTO QUIT
      END
     
     SET @cJuliandate = @cLottable03Value
     
     SET @dt_ManufDate = DATEADD(DAY,RIGHT(@cJuliandate, 3) - 1,DATEFROMPARTS(2000 + LEFT(@cJuliandate, 2),1,1)) 

      
     SET @dLottable13 = @dt_ManufDate
     SET @dLottable04 = @dt_ManufDate + @nShelflife

      IF @bDebug = 1
      BEGIN
         SELECT '@@dLottable13', @dLottable13
         SELECT '@@dLottable04', @dLottable04
      END         
   END

   
   Quit:

END
 -- End Procedure

GO

GRANT EXECUTE ON rdt.rdt_LottableProcess_GenL4ByL3JulianDateBACARDI TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
