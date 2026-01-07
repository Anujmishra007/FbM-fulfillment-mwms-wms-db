SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_LottableProcess_POSM_MICHE01                          */
/* Copyright      : Maersk WMS                                                */
/* Customer       : Michelin IDN                                              */
/*                                                                            */
/* Purpose: Dynamic lottable                                                  */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 2025-12-27   NYE018    1.0.0 FCR-9252                                      */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_LottableProcess_POSM_MICHE01]
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

   DECLARE  @cUserDefine01       NVARCHAR( 60),
            @TargetDate          DATETIME,
            @FirstWeekDay        DATETIME,
            @JanuaryFirst        DATETIME,
            @Week                INT,
            @Year                INT,
            @WeekYear            NVARCHAR(20),
            @cID                 NVARCHAR(30),
            @WeekRange           INT,
            @ReceiptKey          NVARCHAR(30)

   IF @cType = 'POST'
   BEGIN
      IF @nLottableNo = 2 
      BEGIN
         SET DATEFIRST 1 -- Monday as first day

         DECLARE @cSKUType NVARCHAR(10) = ''
         SELECT @cSKUType = itemclass 
           FROM SKU (NOLOCK)
          WHERE SKU = @cSKU
            AND StorerKey = @cStorerKey

         IF (ISNULL(@cSKUType,'') = 'POSM')
         BEGIN
            GOTO Quit
         END

         SELECT @WeekRange = TRY_CAST(S.SUSR4 AS int)
           FROM STORER S (NOLOCK)
          WHERE S.StorerKey = @cStorerKey

         SELECT @cID = V_ID,
                @ReceiptKey = V_ReceiptKey
           FROM rdt.rdtMobRec WITH (NOLOCK) 
          WHERE Mobile = @nMobile

         SET @WeekYear = @cLottable02
         -- Check if the input is exactly 4 characters and is a valid week and year
         IF LEN(@WeekYear) = 4 AND ISNUMERIC(SUBSTRING(@WeekYear, 1, 2)) > 0 AND ISNUMERIC(SUBSTRING(@WeekYear, 3, 2)) > 0
         BEGIN

            SET @Week = CAST(SUBSTRING(@WeekYear, 1, 2) AS INT);
            SET @Year = CAST(SUBSTRING(@WeekYear, 3, 2) AS INT);

            -- Check if the week number is between 1 and 53
            IF @Week BETWEEN 1 AND 53
            BEGIN
               -- Determine the January 1st of the given year
               SET @JanuaryFirst = CAST(('20' + RIGHT(@Year + 2000, 2) + '-01-01') AS DATE); -- Assuming the year is within 2000-2099

                  --IOS FIRST WEEK START AT Thursday
               IF DATEPART(WEEKDAY, @JanuaryFirst) < 5
                  SET @FirstWeekDay = @JanuaryFirst;
               ELSE
                  SET @FirstWeekDay = DATEADD(WEEK, 1, @JanuaryFirst);

                  -- Calculate the target date based on the week number and assuming the week starts on Monday
                  SET @TargetDate = DATEADD(WEEK, @Week - 1, @FirstWeekDay);
                  --SET to monday
                  SET @TargetDate = DATEADD(DAY,(1-DATEPART(WEEKDAY,@TargetDate)),@TargetDate)

                  IF (YEAR(@TargetDate) < 2000+@Year)
                     SET @TargetDate = @JanuaryFirst
            END
            ELSE
            BEGIN
               SET @nErrNo = 254954
               SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, N'DSP') --'Invalid week, must be between 1 and 53.'
               GOTO Quit
            END
         END
         ELSE
         BEGIN
            SET @nErrNo = 254955
            SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, N'DSP') --'Invalid input, must be a 4-digit'
            GOTO Quit
         END

         SET @dLottable04 = @TargetDate

         DECLARE @CurrentDate DATETIME
         SET @CurrentDate = GETDATE()

         IF @TargetDate>@CurrentDate
         BEGIN
            SET @nErrNo = 254956
            SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, N'DSP') --'WeekYear can not in future.'
            GOTO Quit
         END
         
         DECLARE @ThursdayOfThisWk DATETIME

         SET @ThursdayOfThisWk = DATEADD(DAY,(4-DATEPART(WEEKDAY,@TargetDate)),@TargetDate)
         --ThursdayOfThisWeek must in this year
         IF YEAR(@ThursdayOfThisWk) > 2000+@Year
         BEGIN
            SET @nErrNo = 254957
            SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, N'DSP') --'WeekNumber Invalid.'
            GOTO Quit
         END

         IF EXISTS(
         SELECT 1
           FROM RECEIPTDETAIL rptl WITH(NOLOCK)
          WHERE rptl.StorerKey = @cStorerKey
            AND rptl.receiptkey = @ReceiptKey
            AND rptl.ToId = @cID
            AND rptl.Sku  = @cSKU
            AND LEN(rptl.lottable02) = 4
            AND (
                   SUBSTRING(rptl.Lottable02,3,2) <> SUBSTRING(@cLottable02,3,2)
                OR CAST(SUBSTRING(rptl.Lottable02,1,2) AS int) < CAST(SUBSTRING(@cLottable02,1,2) AS int) - @WeekRange
                OR CAST(SUBSTRING(rptl.Lottable02,1,2) AS int) > CAST(SUBSTRING(@cLottable02,1,2) AS int) + @WeekRange
                ))
         BEGIN
             SET @nErrNo = 254958  -- 'More than SUSR4 allowed'
             SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, N'DSP')
             GOTO Quit
         END
      END
   END
   Quit:
   
END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
GRANT EXECUTE ON [rdt].[rdt_LottableProcess_POSM_MICHE01] TO NSQL
GO