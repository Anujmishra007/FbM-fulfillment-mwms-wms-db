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
/* 2026-08-07 1.1  Dennis     FCR-14211  Restore LOC on ESC from REXLOG */
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
        @cOption             NVARCHAR(1),
        @cID                 NVARCHAR(18),
        @cReceiptKey         NVARCHAR(10),
        @cLOC                NVARCHAR(10),
        @nMobStep            INT,
        @nMobScn             INT,
        @cSKU                NVARCHAR(20),
        @cLottableCodeLocal  NVARCHAR(30),
        @nMorePageLocal      INT,
        @nLC_MinSeq          INT,
        @nLC_MaxSeq          INT,
        @cSavedMinDOT        NVARCHAR(18),
        @cSavedCOO           NVARCHAR(30),
        @cSavedSubInv        NVARCHAR(18),
        @cMax                NVARCHAR( MAX),
        @nQTY                INT,
        @cExistingSKU        NVARCHAR(20),
        @nFromScn            INT

    SET @cUDF01 = ''

    SELECT @cLOC              = ISNULL(V_Loc, ''),
           @nMobStep          = Step,
           @nMobScn           = Scn,
           @cID               = ISNULL(NULLIF(V_ID, ''), C_String3),
           @nFromScn          = ISNULL(V_FromScn, 0),
           @cSKU              = ISNULL(V_SKU, ''),
           @cReceiptKey       = ISNULL(V_ReceiptKey, ''),
           @cLottableCodeLocal = ISNULL(V_String3, '')
    FROM rdt.RDTMOBREC WITH (NOLOCK)
    WHERE Mobile = @nMobile

    IF @nFunc = 600
    BEGIN
        -- Case 1: Coming from TO ID screen (Step 3, Scn 4032) with ENTER
        -- Show REXLOG prompt screen
        IF @nMobStep = 3
        BEGIN
            IF @nMobScn = 4032
            BEGIN
                IF @nInputKey = 1
                BEGIN
                    -- Get TO ID from session data
                    SELECT @cID = Value FROM @tExtScnData WHERE Variable = '@cID'

                    BEGIN TRY
                        -- Update RDTMOBREC.C_String3 with TO ID for this mobile session
                        IF ISNULL(@cID, '') <> ''
                            UPDATE rdt.RDTMOBREC SET C_String3 = @cID WHERE Mobile = @nMobile
                    END TRY
                    BEGIN CATCH
                        SET @nErrNo = 270553
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  -- ID UPD Fail
                        GOTO Quit
                    END CATCH

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
                    SET @cOutField01 = @cLOC
                    SET @cOutField02 = ''    -- Clear ID field
                    GOTO Quit
                END
            END
        END

        -- Case 3: On SKU screen (Step 4, Scn 4033) with ENTER/ESC
        IF @nMobStep = 4
        BEGIN
            IF @nMobScn = 4033
            BEGIN
                IF @nInputKey = 1
                BEGIN
                    IF @nAfterStep <> 5
                        GOTO QUIT
                    -- Get session data
                    SELECT @cID = Value FROM @tExtScnData WHERE Variable = '@cID'
                    SELECT @cReceiptKey = Value FROM @tExtScnData WHERE Variable = '@cReceiptKey'
                    SELECT @cSKU = Value FROM @tExtScnData WHERE Variable = '@cSKU'

                    IF ISNULL(@cID, '') = ''
                        SELECT @cID = C_String3 FROM rdt.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile

                    IF @nErrNo <> 0 OR ISNULL(@cSKU, '') = ''
                        GOTO Quit

                    SET @cLottable02 = ''
                    
                    -- Find existing MIN DOT from previously received inventory on same pallet
                    SELECT TOP 1 @cLottable02 = Lottable02
                    FROM dbo.ReceiptDetail WITH (NOLOCK)
                    WHERE ReceiptKey = @cReceiptKey
                      AND StorerKey = @cStorerKey
                      AND ToID = @cID
                      AND SKU = @cSKU
                      AND QtyReceived > 0
                      AND ISNULL(Lottable02, '') <> ''
                    ORDER BY EditDate DESC

                    -- Save before POPULATE — POPULATE will wipe it with the blank session value
                    SET @cSavedMinDOT = @cLottable02

                    -- Clear PCS DOT so POPULATE does not pre-fill the previous SKU's value
                    SET @cLottable07 = ''

                    -- COO from plan rows (ASN has COO pre-set)
                    SELECT TOP 1 @cSavedCOO = Lottable06
                    FROM dbo.ReceiptDetail WITH (NOLOCK)
                    WHERE StorerKey  = @cStorerKey
                      AND ReceiptKey = @cReceiptKey
                      AND SKU        = @cSKU
                      AND ISNULL(Lottable06, '') <> ''
                    ORDER BY ReceiptLineNumber

                    -- SubInventory from confirmed received lines on this pallet (not plan rows — plan rows are blank)
                    SELECT TOP 1 @cSavedSubInv = Lottable03
                    FROM dbo.ReceiptDetail WITH (NOLOCK)
                    WHERE StorerKey  = @cStorerKey
                      AND ToID       = @cID
                      AND SKU        = @cSKU
                      AND QtyReceived > 0
                      AND ISNULL(Lottable03, '') <> ''
                    ORDER BY EditDate DESC

                    -- Pre-set Lottable03 in RDTMOBREC before POPULATE
                    IF ISNULL(@cSavedSubInv, '') <> ''
                        -- Old pallet: push confirmed ReceiptDetail value into RDTMOBREC
                        UPDATE rdt.RDTMOBREC WITH (ROWLOCK)
                        SET V_Lottable03 = @cSavedSubInv
                        WHERE Mobile = @nMobile
                    ELSE IF NOT EXISTS (
                        SELECT 1 FROM dbo.ReceiptDetail WITH (NOLOCK)
                        WHERE StorerKey = @cStorerKey
                          AND ToID      = @cID
                          AND SKU       = @cSKU
                          AND QtyReceived > 0
                    )
                    -- New pallet: clear stale session value so POPULATE shows blank
                    UPDATE rdt.RDTMOBREC WITH (ROWLOCK)
                    SET V_Lottable03 = NULL
                    WHERE Mobile = @nMobile

                    SET @cLottable02 = @cSavedMinDOT

                    -- MfgDate is system-calculated at confirm — clear the stale session value
                    SET @dLottable04 = NULL
                    UPDATE rdt.RDTMOBREC WITH (ROWLOCK)
                    SET V_Lottable04 = NULL
                    WHERE Mobile = @nMobile

                    -- Restore COO: use value fetched by rdt_600GetRcvInfo15 from plan rows first,
                    -- then fall back to broader search across confirmed receipts for same SKU
                    IF ISNULL(@cLottable06, '') = ''
                    BEGIN
                        IF ISNULL(@cSavedCOO, '') <> ''
                        BEGIN
                            SET @cLottable06 = @cSavedCOO
                            SET @cOutField06 = @cSavedCOO
                        END
                        ELSE
                        BEGIN
                            SELECT TOP 1 @cLottable06 = Lottable06
                            FROM dbo.ReceiptDetail WITH (NOLOCK)
                            WHERE StorerKey = @cStorerKey
                              AND ReceiptKey = @cReceiptKey
                              AND SKU = @cSKU
                              AND ISNULL(Lottable06, '') <> ''
                            ORDER BY EditDate DESC
                            SET @cOutField06 = ISNULL(@cLottable06, '')
                        END
                        -- Broader COO fallback: search any confirmed receipt for this storer+SKU
                        IF ISNULL(@cLottable06, '') = ''
                        BEGIN
                            SELECT TOP 1 @cLottable06 = Lottable06
                            FROM dbo.ReceiptDetail WITH (NOLOCK)
                            WHERE StorerKey = @cStorerKey
                            AND SKU = @cSKU
                            AND ISNULL(Lottable06, '') <> ''
                            AND QtyReceived > 0
                            ORDER BY EditDate DESC
                            SET @cOutField06 = ISNULL(@cLottable06, '')
                        END

                         -- Restore SubInventory from plan data if POPULATE cleared it
                        -- IF ISNULL(@cLottable03, '') = '' AND ISNULL(@cSavedSubInv, '') <> ''
                        --     SET @cLottable03 = @cSavedSubInv
                    END

                    -- Always sync SubInventory from confirmed pallet receipts.
                    -- Empty for new pallet = clears stale RDTMOBREC carry-over.
                    IF ISNULL(@cSavedSubInv, '') <> ''
                        SET @cLottable03 = @cSavedSubInv

                    SET @nAfterStep = 5
                    SET @nAfterScn = 3990
                    --SET @cUDF01 = 'NO UPD RDTMOBREC'
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
        IF @nMobStep = 5
        BEGIN
            IF @nInputKey = 1  -- ENTER
            BEGIN
                -- (4th lottable) sits in @cInField08; clear it now so the QTY
                SET @cInField08 = ''

                SELECT @cSKU = Value FROM @tExtScnData WHERE Variable = '@cSKU'
                IF ISNULL(@cSKU, '') = ''
                    SELECT @cSKU = V_SKU FROM rdt.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile

                DECLARE @cSKUClassLocal   NVARCHAR(10)
                DECLARE @cMasterUOMLocal  NVARCHAR(10)
                DECLARE @cDefaultQtyLocal NVARCHAR(10)

                SELECT TOP 1 @cSKUClassLocal = S.Class
                FROM dbo.SKU S WITH (NOLOCK)
                WHERE S.StorerKey = @cStorerKey AND S.SKU = @cSKU

                SET @cInField09 = ''
                IF ISNULL(@cSKUClassLocal, '') IN ('PC', 'TB')
                BEGIN
                    SELECT TOP 1 @cDefaultQtyLocal = Short
                    FROM dbo.CODELKUP WITH (NOLOCK)
                    WHERE ListName = 'MICPCSIBDF'
                        AND StorerKey = @cStorerKey
                    AND Code = @cSKUClassLocal
                    
                    IF ISNULL(@cDefaultQtyLocal, '') <> ''
                    BEGIN
                        SET @cInField09 = @cDefaultQtyLocal
                        IF ISNULL(@cOutField09, '') = ''
                            SET @cOutField09 = @cDefaultQtyLocal
                    END
                END
                SET @cInField08 = ''
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

        -- Case 5: On success screen with ENTER
        -- Loop back to Lottable screen with same SKU
        IF @nMobStep = 6 AND @nAfterStep = 3 AND @nInputKey = 1
        BEGIN
            SET @nQTY = 0
            SET @cMax = ''

            -- Reload lottable values from RDTMOBREC before POPULATE reads them
            SELECT
                @cLottable01 = V_Lottable01,
                @dLottable05 = V_Lottable05,
                @cLottable06 = V_Lottable06,
                @cLottable07 = '',
                @cLottable08 = V_Lottable08,
                @cLottable09 = V_Lottable09,
                @cLottable10 = V_Lottable10,
                @cLottable11 = V_Lottable11,
                @cLottable12 = V_Lottable12,
                @dLottable13 = V_Lottable13,
                @dLottable14 = V_Lottable14,
                @dLottable15 = V_Lottable15
            FROM rdt.RDTMOBREC WITH (NOLOCK)
            WHERE Mobile = @nMobile

            -- Refresh Lottable02 (MIN DOT), Lottable03 (SubInventory) and Lottable04 (MfgDate) from latest confirmed line on this pallet
            SELECT TOP 1
                @cLottable02 = Lottable02,
                @cLottable03 = Lottable03,
                @dLottable04 = Lottable04
            FROM dbo.ReceiptDetail WITH (NOLOCK)
            WHERE ReceiptKey  = @cReceiptKey
              AND StorerKey   = @cStorerKey
              AND ToID        = @cID
              AND SKU         = @cSKU
              AND QtyReceived > 0
            ORDER BY EditDate DESC

            -- Dynamic lottable
            EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, 1, @cStorerKey, @cSKU, @cLottableCodeLocal, 'CAPTURE', 'POPULATE', 5, 1,
                @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  @cLottable01 OUTPUT,
                @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  @cLottable02 OUTPUT,
                @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  @cLottable03 OUTPUT,
                @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  @dLottable04 OUTPUT,
                @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  @dLottable05 OUTPUT,
                @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  @cLottable06 OUTPUT,
                @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  @cLottable07 OUTPUT,
                @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  @cLottable08 OUTPUT,
                @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  @cLottable09 OUTPUT,
                @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  @cLottable10 OUTPUT,
                @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  @cLottable11 OUTPUT,
                @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  @cLottable12 OUTPUT,
                @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  @dLottable13 OUTPUT,
                @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  @dLottable14 OUTPUT,
                @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  @dLottable15 OUTPUT,
                @nMorePageLocal OUTPUT,
                @nErrNo      OUTPUT,
                @cErrMsg     OUTPUT,
                @cReceiptKey,
                @nFunc

            IF @nErrNo <> 0
                GOTO Quit
            
            IF @nMorePageLocal = 1
            BEGIN
                SET @nAfterStep  = 5
                SET @nAfterScn   = 3990
                SET @nFromScn = 4033
            END
            ELSE
            BEGIN
                SET @nAfterStep  = 4
                SET @nAfterScn  = 4033
                SET @cOutField01 = @cID  -- Restore TO ID
                SET @cOutField03 = ''    -- Clear SKU field
                SET @cOutField04 = ''    -- Clear SKU Desc1
                SET @cOutField05 = ''    -- Clear SKU Desc2
            END
            SET @cUDF01 = 'NO UPD RDTMOBREC'
        END
    END

Quit:
    IF @cUDF01 = 'NO UPD RDTMOBREC'
    BEGIN
        UPDATE rdt.RDTMOBREC WITH (ROWLOCK)
        SET
            V_QTY       = @nQTY,
            V_SKU       = @cSKU,
            EditDate    = GETDATE(),
            ErrMsg      = @cErrMsg,
            Func        = @nFunc,
            Step        = @nAfterStep,
            Scn         = @nAfterScn,
            V_Max       = @cMax,
            V_FromScn   = @nFromScn,
            V_Lottable01 = @cLottable01,  V_Lottable02 = @cLottable02,  V_Lottable03 = @cLottable03,
            V_Lottable04 = @dLottable04,  V_Lottable05 = @dLottable05,
            V_Lottable06 = @cLottable06,  V_Lottable07 = @cLottable07,  V_Lottable08 = @cLottable08,
            V_Lottable09 = @cLottable09,  V_Lottable10 = @cLottable10,  V_Lottable11 = @cLottable11,
            V_Lottable12 = @cLottable12,  V_Lottable13 = @dLottable13,  V_Lottable14 = @dLottable14,
            V_Lottable15 = @dLottable15,
            I_Field01 = @cInField01,  O_Field01 = @cOutField01,  FieldAttr01 = @cFieldAttr01,
            I_Field02 = @cInField02,  O_Field02 = @cOutField02,  FieldAttr02 = @cFieldAttr02,
            I_Field03 = @cInField03,  O_Field03 = @cOutField03,  FieldAttr03 = @cFieldAttr03,
            I_Field04 = @cInField04,  O_Field04 = @cOutField04,  FieldAttr04 = @cFieldAttr04,
            I_Field05 = @cInField05,  O_Field05 = @cOutField05,  FieldAttr05 = @cFieldAttr05,
            I_Field06 = @cInField06,  O_Field06 = @cOutField06,  FieldAttr06 = @cFieldAttr06,
            I_Field07 = @cInField07,  O_Field07 = @cOutField07,  FieldAttr07 = @cFieldAttr07,
            I_Field08 = @cInField08,  O_Field08 = @cOutField08,  FieldAttr08 = @cFieldAttr08,
            I_Field09 = @cInField09,  O_Field09 = @cOutField09,  FieldAttr09 = @cFieldAttr09,
            I_Field10 = @cInField10,  O_Field10 = @cOutField10,  FieldAttr10 = @cFieldAttr10,
            I_Field11 = @cInField11,  O_Field11 = @cOutField11,  FieldAttr11 = @cFieldAttr11,
            I_Field12 = @cInField12,  O_Field12 = @cOutField12,  FieldAttr12 = @cFieldAttr12,
            I_Field13 = @cInField13,  O_Field13 = @cOutField13,  FieldAttr13 = @cFieldAttr13,
            I_Field14 = @cInField14,  O_Field14 = @cOutField14,  FieldAttr14 = @cFieldAttr14,
            I_Field15 = @cInField15,  O_Field15 = @cOutField15,  FieldAttr15 = @cFieldAttr15
        WHERE Mobile = @nMobile
    END
END
GO


SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_600ExtScn12] TO NSQL
GO
