SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Store procedure: rdt_600ExtUpd18                                     */
/* CUSTOMER : MICHELIN VN                                               */
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2026-06-16 1.0  Sreeja     FCR-13976  Created                        */
/*                            MIN DOT Update Logic (Steps 5 & 6)        */
/************************************************************************/  

CREATE OR ALTER PROC [RDT].[rdt_600ExtUpd18] (
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
   @cID          NVARCHAR( 18),   -- Pallet ID (ToID)
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

    SET @nErrNo = 0
    SET @cErrMsg = ''

    -- Restore pallet ID when framework cleared V_ID after prior receipt confirm
    IF ISNULL(@cID, '') = ''
    BEGIN
        SELECT @cID = LTRIM(RTRIM(C_String3))
        FROM rdt.RDTMOBREC WITH (NOLOCK)
        WHERE Mobile = @nMobile
    END

    DECLARE @cREXLOGFlag NVARCHAR(1)

    IF @nFunc = 600
    BEGIN
        IF ISNULL(@cLottable07, '') = '' OR LEN(@cLottable07) <> 4
            OR @cLottable07 NOT LIKE '[0-9][0-9][0-9][0-9]'
            OR TRY_CAST(LEFT(@cLottable07, 2) AS INT) NOT BETWEEN 1 AND 52
            GOTO Quit


        SELECT @cREXLOGFlag = LTRIM(RTRIM(C_String4))
        FROM rdt.RDTMOBREC WITH (NOLOCK)
        WHERE Mobile = @nMobile

        IF @cREXLOGFlag IN ('1', '2')
        BEGIN
            IF @nStep = 5
            BEGIN
                -- Pre-calculate MfgDate from new MIN DOT (@cLottable07) for Lottable04 sync
                DECLARE @nW_Upd INT, @nY_Upd INT
                DECLARE @dJan1_Upd DATETIME, @dFirstWeekDay_Upd DATETIME, @dNewMfgDate DATETIME

                SET @nW_Upd = TRY_CAST(LEFT(@cLottable07, 2) AS INT)
                SET @nY_Upd = TRY_CAST(RIGHT(@cLottable07, 2) AS INT)

                IF @nW_Upd BETWEEN 1 AND 52 AND @nY_Upd IS NOT NULL
                BEGIN
                    SET DATEFIRST 1
                    SET @dJan1_Upd = CAST('20' + RIGHT(CAST(@nY_Upd + 2000 AS VARCHAR), 2) + '-01-01' AS DATE)
                    IF DATEPART(WEEKDAY, @dJan1_Upd) < 5
                        SET @dFirstWeekDay_Upd = @dJan1_Upd
                    ELSE
                        SET @dFirstWeekDay_Upd = DATEADD(WEEK, 1, @dJan1_Upd)
                    SET @dNewMfgDate = DATEADD(WEEK, @nW_Upd - 1, @dFirstWeekDay_Upd)
                    SET @dNewMfgDate = DATEADD(DAY, 1 - DATEPART(WEEKDAY, @dNewMfgDate), @dNewMfgDate)
                    IF YEAR(@dNewMfgDate) < 2000 + @nY_Upd
                        SET @dNewMfgDate = @dJan1_Upd
                END

                -- Recalculate Lottable03 (OLD/FRESH) from the new MfgDate
                DECLARE @cFacilityPfx   NVARCHAR(30)
                DECLARE @cNewLottable03 NVARCHAR(18) = NULL
                DECLARE @dNow           DATETIME     = GETDATE()

                SELECT @cFacilityPfx = UserDefine01
                FROM dbo.Facility WITH (NOLOCK)
                WHERE Facility = @cFacility

                IF @dNewMfgDate IS NOT NULL AND @dNewMfgDate <= @dNow
                BEGIN
                    IF (MONTH(@dNow) < 7 AND YEAR(@dNewMfgDate) < (YEAR(@dNow) - 1))
                    OR (MONTH(@dNow) >= 7 AND YEAR(@dNewMfgDate) < YEAR(@dNow))
                        SET @cNewLottable03 = @cFacilityPfx + '-OLD'
                    ELSE
                        SET @cNewLottable03 = @cFacilityPfx + '-FRESH'
                END

                -- BEGIN TRY
                --     -- Update all prior confirmed receipt lines on the same pallet
                --     UPDATE dbo.ReceiptDetail WITH (ROWLOCK)
                --     SET Lottable02 = @cLottable07,
                --         Lottable03 = ISNULL(@cNewLottable03, Lottable03),
                --         Lottable04 = @dNewMfgDate
                --     WHERE ReceiptKey  = @cReceiptKey
                --     AND StorerKey   = @cStorerKey
                --     AND ToID        = @cID
                --     AND SKU         = @cSKU
                --     AND QtyReceived > 0
                --     AND LEN(ISNULL(Lottable02, '')) = 4
                --     AND Lottable02 LIKE '[0-9][0-9][0-9][0-9]'
                --     AND (
                --             TRY_CAST(RIGHT(@cLottable07, 2) AS INT) < TRY_CAST(RIGHT(Lottable02, 2) AS INT)
                --             OR (
                --             TRY_CAST(RIGHT(@cLottable07, 2) AS INT) = TRY_CAST(RIGHT(Lottable02, 2) AS INT)
                --             AND TRY_CAST(LEFT(@cLottable07,  2) AS INT) < TRY_CAST(LEFT(Lottable02,  2) AS INT)
                --             )
                --         )
                -- END TRY
                -- BEGIN CATCH
                --     SET @nErrNo  = 270601
                --     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                --     GOTO Quit
                -- END CATCH

                -- MIN DOT update moved to rdt_600RcvCfm22 (runs AFTER receipt confirmed)
                -- to prevent updating inventory when receipt fails (e.g. over-received)
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
GRANT EXECUTE ON [RDT].[rdt_600ExtUpd18] TO NSQL
GO
