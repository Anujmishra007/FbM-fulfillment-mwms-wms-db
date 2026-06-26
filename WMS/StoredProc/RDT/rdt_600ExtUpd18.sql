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
/*                            MIN DOT Update Logic (Steps 4 & 5)        */
/* 2026-06-25 1.1  Sreeja     FCR-13976  Fixed step check, removed      */
/*                            step 5 restriction for DB update          */
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

    DECLARE
        @cREXLOGFlag      NVARCHAR(1),
        @nPCSDOT_Week     INT,
        @nPCSDOT_Year     INT,
        @nMINDOT_Week     INT,
        @nMINDOT_Year     INT,
        @bPCSDOT_Older    BIT

    IF @nFunc = 600 -- Normal receiving
    BEGIN
        -- Check if Lottable07 (PCS DOT) has value
        IF ISNULL(@cLottable07, '') = '' OR LEN(@cLottable07) <> 4
        BEGIN
            GOTO Quit
        END

        -- Get REXLOG flag from RDTMOBREC.C_String4
        SELECT @cREXLOGFlag = LTRIM(RTRIM(C_String4))
        FROM rdt.RDTMOBREC WITH (NOLOCK) 
        WHERE Mobile = @nMobile

        -------------------------------------------------------------
        -- STEPS 4 & 5: Only when REXLOG flag = '2' (NO)
        -------------------------------------------------------------
        IF @cREXLOGFlag = '2'
        BEGIN 
            IF @nStep IN (5, 6)
            BEGIN
                -- Parse PCS DOT
                SET @nPCSDOT_Week = TRY_CAST(LEFT(@cLottable07, 2) AS INT)
                SET @nPCSDOT_Year = TRY_CAST(RIGHT(@cLottable07, 2) AS INT)

                -- STEP 4: If MIN DOT (Lottable02) is blank, skip DB update (MIN DOT will be set earlier in the flow)
                IF ISNULL(@cLottable02, '') = ''
                BEGIN
                    GOTO Quit
                END

                -- STEP 5: Compare PCS DOT with MIN DOT
                -- If PCS DOT is older than MIN DOT, update all RECEIPTDETAIL entries
                IF LEN(@cLottable02) = 4
                BEGIN
                    SET @nMINDOT_Week = TRY_CAST(LEFT(@cLottable02, 2) AS INT)
                    SET @nMINDOT_Year = TRY_CAST(RIGHT(@cLottable02, 2) AS INT)

                    -- Check if PCS DOT is older than MIN DOT
                    -- Older means: same year with smaller week (years must match per validation)
                    SET @bPCSDOT_Older = 0
                    
                    IF @nPCSDOT_Year = @nMINDOT_Year AND @nPCSDOT_Week < @nMINDOT_Week
                    BEGIN
                        SET @bPCSDOT_Older = 1
                    END

                    -- If PCS DOT is older, update Lottable02 for all RECEIPTDETAIL entries
                    IF @bPCSDOT_Older = 1
                    BEGIN
                        BEGIN TRY
                            -- Update all previously received entries on same pallet, location, SKU
                            UPDATE dbo.ReceiptDetail WITH (ROWLOCK)
                            SET Lottable02 = @cLottable07
                            WHERE ReceiptKey = @cReceiptKey
                            AND StorerKey = @cStorerKey
                            AND ToID = @cID
                            AND ToLoc = @cLOC
                            AND SKU = @cSKU
                            AND QtyReceived > 0
                            
                        END TRY
                        BEGIN CATCH
                            -- Handle any errors that occur during the update
                            SET @nErrNo = 270601
                            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') 
                            GOTO Quit
                        END CATCH
                    END
                    -- If PCS DOT is newer or equal, keep the current MIN DOT
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
GRANT EXECUTE ON [RDT].[rdt_600ExtUpd18] TO NSQL
GO
