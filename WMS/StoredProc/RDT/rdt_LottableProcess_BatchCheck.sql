
/************************************************************************/
/* Store procedure: rdt_LottableProcess_BatchCheck                      */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2024-09-19 1.0  YYS027     FCR-827 Add BatchCheck Normal receipt     */
/*                            for HUDA.                                 */
/*                            this is a ProcessSP for lottableCode      */
/************************************************************************/
CREATE OR ALTER PROCEDURE rdt.rdt_LottableProcess_BatchCheck(
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
   ,@dLottable04      DATETIME      OUTPUT      --dExpDate
   ,@dLottable05      DATETIME      OUTPUT
   ,@cLottable06      NVARCHAR( 30) OUTPUT
   ,@cLottable07      NVARCHAR( 30) OUTPUT
   ,@cLottable08      NVARCHAR( 30) OUTPUT
   ,@cLottable09      NVARCHAR( 30) OUTPUT
   ,@cLottable10      NVARCHAR( 30) OUTPUT
   ,@cLottable11      NVARCHAR( 30) OUTPUT
   ,@cLottable12      NVARCHAR( 30) OUTPUT
   ,@dLottable13      DATETIME      OUTPUT      --dProdDate
   ,@dLottable14      DATETIME      OUTPUT
   ,@dLottable15      DATETIME      OUTPUT
   ,@nErrNo           INT           OUTPUT
   ,@cErrMsg          NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cLottableV   NVARCHAR(30)
   DECLARE @nLength     INT
   DECLARE @nDays       INT
   DECLARE @cYearCode   NVARCHAR(4)
   DECLARE @nYear       INT
   DECLARE @nShelfLife  INT
   DECLARE @cFacility   NVARCHAR( 5)

   SELECT @cFacility  = Facility FROM RDT.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile
   DECLARE @cBatchCheck NVARCHAR(20)
   SELECT @cBatchCheck = SValue
         FROM rdt.StorerConfig (NOLOCK)
         WHERE Function_ID = @nFunc AND StorerKey = @cStorerKey AND ConfigKey = 'BatchCheck'
   IF ISNULL(@cBatchCheck,'')=''
   BEGIN
      GOTO Quit
   END
   ELSE IF ISNULL(@cBatchCheck,'') IN ('1','Lottable01','Lottable1')
      SELECT @cLottableV=@cLottable01
   ELSE IF ISNULL(@cBatchCheck,'') IN ('2','Lottable02','Lottable2')
	   SELECT @cLottableV=@cLottable02
   ELSE IF ISNULL(@cBatchCheck,'') IN ('3','Lottable03','Lottable3')
	   SELECT @cLottableV=@cLottable03
   ELSE IF ISNULL(@cBatchCheck,'') IN ('6','Lottable06','Lottable6')
	   SELECT @cLottableV=@cLottable06
   ELSE IF ISNULL(@cBatchCheck,'') IN ('7','Lottable07','Lottable7')
	   SELECT @cLottableV=@cLottable07
   ELSE IF ISNULL(@cBatchCheck,'') IN ('8','Lottable08','Lottable8')
	   SELECT @cLottableV=@cLottable08
   ELSE IF ISNULL(@cBatchCheck,'') IN ('9','Lottable09','Lottable9')
	   SELECT @cLottableV=@cLottable09
   ELSE IF ISNULL(@cBatchCheck,'') IN ('10','Lottable10','Lottable10')
	   SELECT @cLottableV=@cLottable10
   ELSE IF ISNULL(@cBatchCheck,'') IN ('11','Lottable11','Lottable11')
	   SELECT @cLottableV=@cLottable11
   ELSE IF ISNULL(@cBatchCheck,'') IN ('12','Lottable12','Lottable12')
	   SELECT @cLottableV=@cLottable12
   ELSE
   BEGIN
      SET @nErrNo = 223703
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Config
      GOTO Quit
   END

   IF @cLottableV='9999'
   BEGIN
      SELECT @dLottable13=convert(datetime,'31-12-2099',103),@dLottable04=NULL
      GOTO Quit
   END


   SET @nLength = LEN( @cLottableV)

   IF @nLength NOT IN (4,5)
   BEGIN
	  ----Message 223701 to 223750
      SET @nErrNo = 223701
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid format
      GOTO Quit
   END

   -- first 4 chars, should be numeric
   IF ISNUMERIC(LEFT(@cLottableV,4))=0
   BEGIN
	  ----Message 223701 to 223750
      SET @nErrNo = 223701
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid format
      GOTO Quit
   END
   --first 3 chars, be days of year, should be less than 366
   SELECT @nDays=CONVERT(INT,LEFT(@cLottableV,3))
   IF @nDays>=366 OR @nDays<0
   BEGIN
	  ----Message 223701 to 223750
      SET @nErrNo = 223701
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid format
      GOTO Quit
   END
   SELECT @cYearCode=UserDefine03 FROM FACILITY WHERE Facility=@cFacility		--hard code HBDB to @cFacility
   IF isnumeric(@cYearCode)=0
   BEGIN
      SET @nErrNo = 223702
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid BaseYear
      GOTO Quit
   END
   SELECT @nShelfLife=ShelfLife FROM SKU WHERE StorerKey=@cStorerKey AND Sku=@cSKU
   SELECT @nYear=CONVERT(INT,@cYearCode)+CONVERT(INT,substring(@cLottableV,4,1))
   SELECT @dLottable13=CONVERT(DATETIME,'01/01/'+CONVERT(VARCHAR(20),@nYear),103)
   SELECT @dLottable13=DATEADD(DAY,@nDays,@dLottable13)                                --Production Date
   SELECT @dLottable04=DATEADD(DAY,ISNULL(@nShelfLife,0),@dLottable13)                 --Exp Date

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_LottableProcess_BatchCheck] TO NSQL
GO

