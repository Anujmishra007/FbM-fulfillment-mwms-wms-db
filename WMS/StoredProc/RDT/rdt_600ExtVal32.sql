SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Store procedure: rdt_600ExtVal32                                     */
/* CUSTOMER : MICHELIN VN                                               */
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2026-06-16 1.0  Sreeja     FCR-13976  Created                        */
/*                            REXLOG and MIN DOT Validation for PCS DOT */
/************************************************************************/  

CREATE OR ALTER PROC [RDT].[rdt_600ExtVal32] (
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,           
   @nInputKey    INT,           
   @cFacility    NVARCHAR( 5), 
   @cStorerKey   NVARCHAR( 15), 
   @cReceiptKey  NVARCHAR( 10), 
   @cPOKey       NVARCHAR( 10), 
   @cLOC         NVARCHAR( 10), 
   @cID          NVARCHAR( 18), 
   @cSKU         NVARCHAR( 20), 
   @cLottable01  NVARCHAR( 18), 
   @cLottable02  NVARCHAR( 18),   -- MIN DOT (XXYY format)
   @cLottable03  NVARCHAR( 18), 
   @dLottable04  DATETIME,      
   @dLottable05  DATETIME,      
   @cLottable06  NVARCHAR( 30),   -- COO
   @cLottable07  NVARCHAR( 30),   -- PCS DOT (XXYY format)
   @cLottable08  NVARCHAR( 30), 
   @cLottable09  NVARCHAR( 30), 
   @cLottable10  NVARCHAR( 30), 
   @cLottable11  NVARCHAR( 30), 
   @cLottable12  NVARCHAR( 30), 
   @dLottable13  DATETIME,      
   @dLottable14  DATETIME,      
   @dLottable15  DATETIME,      
   @nQTY         INT,           
   @cReasonCode  NVARCHAR( 10), 
   @cSuggToLOC   NVARCHAR( 10), 
   @cFinalLOC    NVARCHAR( 10), 
   @cReceiptLineNumber NVARCHAR( 10), 
   @nErrNo       INT            OUTPUT, 
   @cErrMsg      NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON
    SET ANSI_NULLS OFF
    SET QUOTED_IDENTIFIER OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE
        @cREXLOGFlag      NVARCHAR(1),
        @nCurrentWkNo     INT,
        @nCurrentYY       INT,
        @nPCSDOT_Week     INT,
        @nPCSDOT_Year     INT,
        @nMINDOT_Week     INT,
        @nMINDOT_Year     INT,
        @nLongLifeWk      INT,
        @nREXLOGWk        INT,
        @cRexLogKey       NVARCHAR(50),
        @cRexLogCOO       NVARCHAR(30),
        @cSKU_BUSR5       NVARCHAR(30),
        @nWeekGap         INT,
        @n8WeekRange      INT
    
    SET @nErrNo = 0
    SET @cErrMsg = ''

    IF @nFunc = 600 -- Normal receiving
    BEGIN
        IF @nStep = 5 -- Lottable screen
        BEGIN
            IF @nInputKey = 1 -- ENTER
            BEGIN
                -- Check if Lottable07 (PCS DOT) has value
                IF ISNULL(@cLottable07, '') = ''
                BEGIN
                    SET @nErrNo = 270501
                    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Invalid PCS DOT format
                    GOTO Quit
                END

                -- Validate PCS DOT format (must be 4 digits: XXYY)
                IF LEN(@cLottable07) <> 4 OR ISNUMERIC(@cLottable07) = 0
                BEGIN
                    SET @nErrNo = 270502
                    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  -- Invalid PCS DOT format
                    GOTO Quit
                END

                -- Parse PCS DOT (XXYY format: XX=week, YY=year)
                SET @nPCSDOT_Week = TRY_CAST(LEFT(@cLottable07, 2) AS INT)
                SET @nPCSDOT_Year = TRY_CAST(RIGHT(@cLottable07, 2) AS INT)

                -- Validate week range (01-52)
                IF @nPCSDOT_Week < 1 OR @nPCSDOT_Week > 52
                BEGIN
                    SET @nErrNo = 270503
                    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Invalid PCS DOT week
                    GOTO Quit
                END

                -- Get REXLOG flag from RDTMOBREC.C_String4
                SELECT @cREXLOGFlag = LTRIM(RTRIM(C_String4))
                FROM rdt.RDTMOBREC WITH (NOLOCK) 
                WHERE Mobile = @nMobile

                -- Get current week and year
                SET @nCurrentWkNo = DATEPART(ISO_WEEK, GETDATE())
                SET @nCurrentYY = TRY_CAST(RIGHT(CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR(4)), 2) AS INT)

                -------------------------------------------------------------
                -- STEP 1: REXLOG CHECK - ONLY when REXLOG flag = '1' (YES)
                -------------------------------------------------------------
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
                        AND Code = @cLottable06

                    IF @cRexLogCOO IS NULL
                        SET @cRexLogCOO = @cLottable06

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
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  -- Long life > REXLOG
                        GOTO Quit
                    END
                    
                    -- REXLOG check passed, skip MIN DOT validation (Steps 2-5)
                    GOTO Quit
                END

                -------------------------------------------------------------
                -- STEPS 2-3: MIN DOT CHECK - ONLY when REXLOG flag = '2' (NO)
                -- Steps 4-5 (update logic) are handled in ExtUpd SP
                -------------------------------------------------------------
                IF @cREXLOGFlag = '2'
                BEGIN
                    -- Get 8-week range from CODELKUP (default to 8 if not found)
                    SELECT @n8WeekRange = TRY_CAST(Short AS INT)
                    FROM dbo.CODELKUP WITH (NOLOCK)
                    WHERE ListName = 'MICDOTWEEKRANGE' 
                        AND StorerKey = @cStorerKey 
                        AND Code = 'WEEKRANGE'

                    IF @n8WeekRange IS NULL
                        SET @n8WeekRange = 8

                    -- STEP 2 & 3: Check if MIN DOT (Lottable02) has value
                    IF ISNULL(@cLottable02, '') <> '' AND LEN(@cLottable02) = 4
                    BEGIN
                        -- Parse MIN DOT
                        SET @nMINDOT_Week = TRY_CAST(LEFT(@cLottable02, 2) AS INT)
                        SET @nMINDOT_Year = TRY_CAST(RIGHT(@cLottable02, 2) AS INT)

                        -- STEP 3.1: Check year match
                        IF @nPCSDOT_Year <> @nMINDOT_Year
                        BEGIN
                            SET @nErrNo = 270505
                            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- DOT year mismatch
                            GOTO Quit
                        END

                        -- STEP 3.2: Check 8-week gap rule
                        SET @nWeekGap = @nPCSDOT_Week - @nMINDOT_Week

                        IF @nWeekGap > @n8WeekRange OR @nWeekGap < -@n8WeekRange
                        BEGIN
                            SET @nErrNo = 270506
                            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- DOT 8-week rule error
                            GOTO Quit
                        END
                    END
                -- STEP 4 & 5: Update logic handled in rdt_600ExtUpd12
                END
            END
        END
    END

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [RDT].[rdt_600ExtVal32] TO nSQL
GO
