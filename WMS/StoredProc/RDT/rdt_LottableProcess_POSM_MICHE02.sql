SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_LottableProcess_POSM_MICHE02                          */
/* Copyright      : Maersk WMS                                                */
/* Customer       : Michelin VN                                               */
/*                                                                            */
/* Purpose: Dynamic lottable with REXLOG and MIN DOT validation               */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 2026-06-24   Sreeja    1.0.0 FCR-13976                                     */
/* 2026-06-25   Sreeja    1.1.0 FCR-13976 - Moved validation from ExtVal32    */
/*                              Added MIN DOT screen update logic             */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_LottableProcess_POSM_MICHE02]
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
   ,@cLottable02Value NVARCHAR( 18)   -- MIN DOT
   ,@cLottable03Value NVARCHAR( 18)
   ,@dLottable04Value DATETIME
   ,@dLottable05Value DATETIME
   ,@cLottable06Value NVARCHAR( 30)   -- COO
   ,@cLottable07Value NVARCHAR( 30)   -- PCS DOT
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
       @nWeek           INT,
       @nYear           INT,
       @WeekYear        VARCHAR(20),
       -- REXLOG validation variables
       @cREXLOGFlag     NVARCHAR(1),
       @nCurrentWkNo    INT,
       @nCurrentYY      INT,
       @nPCSDOT_Week    INT,
       @nPCSDOT_Year    INT,
       @nMINDOT_Week    INT,
       @nMINDOT_Year    INT,
       @nLongLifeWk     INT,
       @nREXLOGWk       INT,
       @cRexLogKey      NVARCHAR(50),
       @cRexLogCOO      NVARCHAR(30),
       @cSKU_BUSR5      NVARCHAR(30),
       @nWeekGap        INT,
       @n8WeekRange     INT

    SET @nErrNo = 0
    SET @cErrMsg = ''

    IF @cType = 'POST'
    BEGIN
        -- Handle Lottable07 (PCS DOT)
        IF @nLottableNo = 7
        BEGIN
            -- Allow blank value - Required check handled by rdtLottableCode
            IF ISNULL(LTRIM(RTRIM(@cLottable07Value)), '') = ''
                GOTO Quit

            SET @WeekYear = LTRIM(RTRIM(@cLottable07Value))

            -- Check length first to prevent SUBSTRING error
            IF LEN(@WeekYear) < 4
            BEGIN
                SET @nErrNo = 270501
                SET @cErrMsg = rdt.rdtGetMessage(@nErrNo, @cLangCode, N'DSP')
                GOTO Quit
            END

            -- Validate PCS DOT format (must be exactly 4 digits and numeric)
            IF LEN(@WeekYear) = 4 AND @WeekYear LIKE '[0-9][0-9][0-9][0-9]'
            BEGIN
                -- Parse week and year from XXYY format
                SET @nWeek = CAST(SUBSTRING(@WeekYear, 1, 2) AS INT)
                SET @nYear = CAST(SUBSTRING(@WeekYear, 3, 2) AS INT)

                -- Validate week range (01-53)
                IF @nWeek < 1 OR @nWeek > 53
                BEGIN
                    SET @nErrNo = 270502
                    SET @cErrMsg = rdt.rdtGetMessage(@nErrNo, @cLangCode, N'DSP')
                    GOTO Quit
                END
            END
            ELSE
            BEGIN
                SET @nErrNo = 270503
                SET @cErrMsg = rdt.rdtGetMessage(@nErrNo, @cLangCode, N'DSP')
                GOTO Quit
            END

            -----------------------------------------------------------------
            -- REXLOG AND MIN DOT VALIDATION
            -----------------------------------------------------------------
            
            -- Parse PCS DOT values
            SET @nPCSDOT_Week = @nWeek
            SET @nPCSDOT_Year = @nYear

            -- Get REXLOG flag from RDTMOBREC.C_String4
            SELECT @cREXLOGFlag = LTRIM(RTRIM(C_String4))
            FROM rdt.RDTMOBREC WITH (NOLOCK) 
            WHERE Mobile = @nMobile

            -- Get current week and year
            SET @nCurrentWkNo = DATEPART(ISO_WEEK, GETDATE())
            SET @nCurrentYY = TRY_CAST(RIGHT(CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR(4)), 2) AS INT)

            -----------------------------------------------------------------
            -- STEP 1: REXLOG CHECK - ONLY when REXLOG flag = '1' (YES)
            -----------------------------------------------------------------
            IF @cREXLOGFlag = '1'
            BEGIN
                -- Calculate Long-Life week
                IF @nCurrentYY > @nPCSDOT_Year
                BEGIN
                    -- Current year is greater than DOT year
                    SET @nLongLifeWk = (52 - @nPCSDOT_Week) + @nCurrentWkNo + (((@nCurrentYY - @nPCSDOT_Year) - 1) * 52)
                END
                ELSE IF @nCurrentYY = @nPCSDOT_Year
                BEGIN
                    -- Same year
                    SET @nLongLifeWk = @nCurrentWkNo - @nPCSDOT_Week
                END
                ELSE
                BEGIN
                    -- DOT year is in future
                    SET @nLongLifeWk = 0
                END

                -- Get REXLOG COO mapping from CODELKUP
                SELECT @cRexLogCOO = Short 
                FROM dbo.CODELKUP WITH (NOLOCK)
                WHERE ListName = 'MICREXLOGCOO' 
                    AND StorerKey = @cStorerKey 
                    AND Code = @cLottable06Value

                IF @cRexLogCOO IS NULL
                    SET @cRexLogCOO = @cLottable06Value

                -- Get SKU.BUSR5 for REXLOG key
                SELECT @cSKU_BUSR5 = BUSR5 
                FROM dbo.SKU WITH (NOLOCK)
                WHERE StorerKey = @cStorerKey 
                    AND SKU = @cSKU

                -- Build REXLOG key: SKU.BUSR5 + '-' + RexLogCOO
                SET @cRexLogKey = CONCAT(ISNULL(@cSKU_BUSR5, ''), '-', ISNULL(@cRexLogCOO, ''))

                -- Get REXLOG week from CODELKUP
                SELECT @nREXLOGWk = TRY_CAST(Short AS INT)
                FROM dbo.CODELKUP WITH (NOLOCK)
                WHERE ListName = 'MICREXLOG' 
                    AND StorerKey = @cStorerKey 
                    AND Code = @cRexLogKey

                -- If not found, try DEFAULT key
                IF @nREXLOGWk IS NULL
                BEGIN
                    SELECT @nREXLOGWk = TRY_CAST(Short AS INT)
                    FROM dbo.CODELKUP WITH (NOLOCK)
                    WHERE ListName = 'MICREXLOG' 
                        AND StorerKey = @cStorerKey 
                        AND Code = 'DEFAULT'
                END

                -- Compare Long-Life week with REXLOG week
                IF @nREXLOGWk IS NOT NULL AND @nLongLifeWk > @nREXLOGWk
                BEGIN
                    SET @nErrNo = 270504
                    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                    GOTO Quit
                END
                
                -----------------------------------------------------------------
                -- REXLOG passed: Set MIN DOT = PCS DOT (first time) or keep existing
                -----------------------------------------------------------------
                IF ISNULL(@cLottable02Value, '') = ''
                BEGIN
                    SET @cLottable02 = @cLottable07Value
                END
                GOTO Quit
            END

            -----------------------------------------------------------------
            -- STEPS 2-5: MIN DOT CHECK - ONLY when REXLOG flag = '2' (NO)
            -----------------------------------------------------------------
            IF @cREXLOGFlag = '2'
            BEGIN
                -- Get 8-week range from CODELKUP (default to 8 if not found)
                SELECT @n8WeekRange = TRY_CAST(Short AS INT)
                FROM dbo.CODELKUP WITH (NOLOCK)
                WHERE ListName = 'MICDOTWKRG' 
                    AND StorerKey = @cStorerKey 
                    AND Code = 'WEEKRANGE'

                IF @n8WeekRange IS NULL
                    SET @n8WeekRange = 8

                -- Check if MIN DOT (Lottable02) has value
                IF ISNULL(@cLottable02Value, '') <> '' AND LEN(@cLottable02Value) = 4
                   AND @cLottable02Value LIKE '[0-9][0-9][0-9][0-9]'
                BEGIN
                    -- Parse MIN DOT
                    SET @nMINDOT_Week = TRY_CAST(LEFT(@cLottable02Value, 2) AS INT)
                    SET @nMINDOT_Year = TRY_CAST(RIGHT(@cLottable02Value, 2) AS INT)

                    -- STEP 3.1: Check year match
                    IF @nPCSDOT_Year <> @nMINDOT_Year
                    BEGIN
                        SET @nErrNo = 270505
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                        GOTO Quit
                    END

                    -- STEP 3.2: Check 8-week gap rule
                    SET @nWeekGap = @nPCSDOT_Week - @nMINDOT_Week

                    IF @nWeekGap > @n8WeekRange OR @nWeekGap < -@n8WeekRange
                    BEGIN
                        SET @nErrNo = 270506
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                        GOTO Quit
                    END

                    -- STEP 5: If PCS DOT is older than MIN DOT, update MIN DOT
                    -- Older = smaller week number in same year
                    IF @nPCSDOT_Week < @nMINDOT_Week
                    BEGIN
                        -- PCS DOT is older, set it as new MIN DOT
                        SET @cLottable02 = @cLottable07Value
                    END
                    -- If PCS DOT is newer or equal, keep current MIN DOT (no update needed)
                END
                ELSE
                BEGIN
                    -- STEP 4: MIN DOT is blank, copy PCS DOT to MIN DOT
                    SET @cLottable02 = @cLottable07Value
                END
            END
        END
    END

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
GRANT EXECUTE ON [RDT].[rdt_LottableProcess_POSM_MICHE02] TO NSQL
GO
