SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_600ExtScn12                                     */
/* CUSTOMER : MICHELIN VN                                               */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-06-16 1.0  Sreeja     FCR-13976  Created                        */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_600ExtScn12] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nScn         INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),
   @cStorerKey   NVARCHAR( 15),

   @tExtScnData   VariableTable READONLY,

   @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,  @cLottable01 NVARCHAR( 18) OUTPUT,
   @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,  @cLottable02 NVARCHAR( 18) OUTPUT,
   @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,  @cLottable03 NVARCHAR( 18) OUTPUT,
   @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,  @dLottable04 DATETIME      OUTPUT,
   @cInField05       NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,  @dLottable05 DATETIME      OUTPUT,
   @cInField06       NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,  @cLottable06 NVARCHAR( 30) OUTPUT,
   @cInField07       NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,  @cLottable07 NVARCHAR( 30) OUTPUT,
   @cInField08       NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,  @cLottable08 NVARCHAR( 30) OUTPUT,
   @cInField09       NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,  @cLottable09 NVARCHAR( 30) OUTPUT,
   @cInField10       NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,  @cLottable10 NVARCHAR( 30) OUTPUT,
   @cInField11       NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,  @cLottable11 NVARCHAR( 30) OUTPUT,
   @cInField12       NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,  @cLottable12 NVARCHAR( 30) OUTPUT,
   @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,  @dLottable13 DATETIME      OUTPUT,
   @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,  @dLottable14 DATETIME      OUTPUT,
   @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,  @dLottable15 DATETIME      OUTPUT,
   @nAction      INT,
   @nAfterScn    INT OUTPUT, @nAfterStep    INT OUTPUT,
   @nErrNo             INT            OUTPUT,
   @cErrMsg            NVARCHAR( 20)  OUTPUT,
   @cUDF01  NVARCHAR( 250) OUTPUT, @cUDF02 NVARCHAR( 250) OUTPUT, @cUDF03 NVARCHAR( 250) OUTPUT,
   @cUDF04  NVARCHAR( 250) OUTPUT, @cUDF05 NVARCHAR( 250) OUTPUT, @cUDF06 NVARCHAR( 250) OUTPUT,
   @cUDF07  NVARCHAR( 250) OUTPUT, @cUDF08 NVARCHAR( 250) OUTPUT, @cUDF09 NVARCHAR( 250) OUTPUT,
   @cUDF10  NVARCHAR( 250) OUTPUT, @cUDF11 NVARCHAR( 250) OUTPUT, @cUDF12 NVARCHAR( 250) OUTPUT,
   @cUDF13  NVARCHAR( 250) OUTPUT, @cUDF14 NVARCHAR( 250) OUTPUT, @cUDF15 NVARCHAR( 250) OUTPUT,
   @cUDF16  NVARCHAR( 250) OUTPUT, @cUDF17 NVARCHAR( 250) OUTPUT, @cUDF18 NVARCHAR( 250) OUTPUT,
   @cUDF19  NVARCHAR( 250) OUTPUT, @cUDF20 NVARCHAR( 250) OUTPUT, @cUDF21 NVARCHAR( 250) OUTPUT,
   @cUDF22  NVARCHAR( 250) OUTPUT, @cUDF23 NVARCHAR( 250) OUTPUT, @cUDF24 NVARCHAR( 250) OUTPUT,
   @cUDF25  NVARCHAR( 250) OUTPUT, @cUDF26 NVARCHAR( 250) OUTPUT, @cUDF27 NVARCHAR( 250) OUTPUT,
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT, @cUDF30 NVARCHAR( 250) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE
        @cOption         NVARCHAR(1),
        @cID             NVARCHAR(18),
        @cReceiptKey     NVARCHAR(10),
        @cLOC            NVARCHAR(10),
        @cSKU            NVARCHAR(20)

    SET @nErrNo = 0
    SET @cErrMsg = ''

    SET @nAfterStep = @nStep
    SET @nAfterScn = @nScn

    IF @nFunc = 600
    BEGIN
        -- Case 1: Coming from TO ID screen (Step 3, Scn 4032) with ENTER
        -- Show REXLOG prompt screen
        IF @nStep = 3
        BEGIN
            IF @nScn = 4032
            BEGIN
                IF @nInputKey = 1
                BEGIN
                    -- Get TO ID from session data
                    SELECT @cID = Value FROM @tExtScnData WHERE Variable = '@cID'

                    -- Show REXLOG prompt screen
                    SET @nAfterScn = 6916
                    SET @nAfterStep = 98
                    SET @cOutField01 = ''
                    GOTO Quit
                END
            END
        END

        -- Case 2: On REXLOG screen (Scn 6916) with ENTER/ESC
        -- Validate option and proceed to SKU screen
        IF @nStep = 98
        BEGIN
            IF @nScn = 6916
            BEGIN
                IF @nInputKey = 1
                BEGIN
                    -- Get user selected option from input field
                    SET @cOption = LTRIM(RTRIM(@cInField01))

                    -- Validate option input (must be 1 or 2)
                    IF @cOption NOT IN ('1', '2')
                    BEGIN
                        SET @nErrNo = 270551
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                        SET @nAfterScn = 6916
                        SET @nAfterStep = 98
                        SET @cOutField01 = ''
                        GOTO Quit
                    END

                    -- Store REXLOG flag in RDTMOBREC.C_String4 for this mobile session
                    -- 1 = YES (REXLOG check enabled), 2 = NO (REXLOG check disabled)
                    BEGIN TRY
                        UPDATE rdt.RDTMOBREC WITH (ROWLOCK)
                        SET C_String4 = @cOption
                        WHERE Mobile = @nMobile
                    END TRY
                    BEGIN CATCH
                        SET @nErrNo = 270552
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  -- UPD Fail
                        GOTO Quit
                    END CATCH

                    -- Get TO ID to pass to next screen
                    SELECT @cID = Value FROM @tExtScnData WHERE Variable = '@cID'

                    -- Proceed to SKU screen (step 4, screen 4033)
                    SET @nAfterScn = 4033
                    SET @nAfterStep = 4
                    SET @cOutField01 = @cID  -- Pass TO ID to SKU screen
                    SET @cOutField02 = ''    -- Clear SKU field
                    SET @cOutField03 = ''    -- Clear SKU Desc1
                    SET @cOutField04 = ''    -- Clear SKU Desc2
                    GOTO Quit
                END
                IF @nInputKey = 0
                BEGIN
                    -- Go back to TO ID screen (step 3, screen 4032)
                    SET @nAfterScn = 4032
                    SET @nAfterStep = 3
                    SET @cOutField01 = ''    -- Clear LOC field
                    SET @cOutField02 = ''    -- Clear ID field
                    GOTO Quit
                END
            END
        END

        -- Case 3: On SKU screen (Step 4, Scn 4033) with ENTER/ESC
        IF @nStep = 4
        BEGIN
            IF @nScn = 4033
            BEGIN
                IF @nInputKey = 1
                BEGIN
                    -- Get LOC from RDTMOBREC since it's not in @tExtScnData
                    SELECT @cLOC = V_Loc FROM rdt.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile

                    -- Get session data
                    SELECT @cID = Value FROM @tExtScnData WHERE Variable = '@cID'
                    SELECT @cReceiptKey = Value FROM @tExtScnData WHERE Variable = '@cReceiptKey'
                    SELECT @cLOC = Value FROM @tExtScnData WHERE Variable = '@cLOC'
                    SELECT @cSKU = Value FROM @tExtScnData WHERE Variable = '@cSKU'

                    -- Find existing MIN DOT from previously received inventory on same pallet
                    SELECT TOP 1 @cLottable02 = Lottable02
                    FROM dbo.ReceiptDetail WITH (NOLOCK)
                    WHERE ReceiptKey = @cReceiptKey
                      AND StorerKey = @cStorerKey
                      AND ToID = @cID
                      AND ToLoc = @cLOC
                      AND SKU = @cSKU
                      AND QtyReceived > 0
                      AND ISNULL(Lottable02, '') <> ''
                    ORDER BY EditDate DESC

                    SET @nAfterStep = 5
                    SET @nAfterScn = 3990
                    GOTO Quit
                END

                IF @nInputKey = 0
                BEGIN
                    -- Go back to REXLOG prompt screen
                    SET @nAfterScn = 6916
                    SET @nAfterStep = 98
                    SET @cOutField01 = ''    -- Clear option field for input
                    GOTO Quit
                END
            END
        END

        -- Case 4: On Lottable screen (Step 5) with ENTER/ESC
        IF @nStep = 5
        BEGIN
            IF @nInputKey = 1  -- ENTER
            BEGIN
                -- Set next screen to QTY screen
                -- ExtVal32 validation must pass for framework to proceed
                SET @nAfterStep = 6
                SET @nAfterScn = 4035
            END

            IF @nInputKey = 0  -- ESC
            BEGIN
                -- Go back to SKU screen
                SET @nAfterStep = 4
                SET @nAfterScn = 4033
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

GRANT EXECUTE ON [RDT].[rdt_600ExtScn12] TO nSQL
GO
