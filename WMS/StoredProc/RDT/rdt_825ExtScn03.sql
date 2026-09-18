SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_825ExtScn03                                           */
/*                                                                            */
/* Purpose: Confirmation screen (Screen 4) for Fn825 - Capture Pallet Info    */
/* Customer: Schneider Electric                                               */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2026-02-12 1.0  SSR259     FCR-9672 Add screen 4 (Confirmation screen)     */
/* 2026-09-09 1.1  NickT      FCR-14856 Add TRANSMITLOG2 insert on Scn 6829   */
/******************************************************************************/

CREATE OR ALTER PROC  [RDT].[rdt_825ExtScn03] (
    @nMobile          INT,
    @nFunc            INT,
    @cLangCode        NVARCHAR( 3),
    @nStep            INT,
    @nScn             INT,
    @nInputKey        INT,
    @cFacility        NVARCHAR( 5),
    @cStorerKey       NVARCHAR( 15),
    @tExtScnData      VariableTable READONLY,
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
    @nAction          INT, --0 Jump Screen, 1 Validation(pass through all input fields), 2 Update, 3 Prepare output fields .....
    @nAfterScn        INT OUTPUT, @nAfterStep    INT OUTPUT,
    @nErrNo           INT            OUTPUT,
    @cErrMsg          NVARCHAR( 20)  OUTPUT,
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

    -- Variable declarations
    DECLARE
        @nMobStep           INT,
        @nMobScn            INT

    -- RDT.RDTMobRec variables for volumetric data
    DECLARE
        @cPalletKey      NVARCHAR( 30),
        @cSavedPalletKey NVARCHAR( 30),  -- Preserved PalletKey (C_String1)
        @cOrigPalletKey  NVARCHAR( 30),  -- Original PalletKey from main SP (V_String41)
        @cLength         NVARCHAR( 10),
        @cWidth          NVARCHAR( 10),
        @cHeight         NVARCHAR( 10),
        @cWeight         NVARCHAR( 10),
        @cStackability   NVARCHAR( 10),
        @cCaptureInfo    NVARCHAR( 10)

    -- FCR-14856: TRANSMITLOG2 variables
    DECLARE
        @cTransmitLogKey        NVARCHAR( 10),  -- generated TransmitLogKey2
        @bSuccess               INT,            -- nspg_GetKey result
        @nRowCount              INT,
        @cLOT                   NVARCHAR( 10),  -- LOTxLOCxID.Lot
        @cLot03                 NVARCHAR( 18),  -- LOTATTRIBUTE.Lottable03 (avoid conflict with @cLottable03 param)
        @cReceiptKey            NVARCHAR( 10),  -- RECEIPTDETAIL.ReceiptKey (GRN path)
        @cReceiptLineNo         NVARCHAR(  5),   -- RECEIPTDETAIL.ReceiptLineNumber (GRN path)
        @cTransmitflag          NVARCHAR(  5),   -- TRANSMITLOG2.Transmitflag (GRN path)
        @cTransmitLogKey2       NVARCHAR( 10)   -- TRANSMITLOG2.TransmitLogKey (GRN path)

    -- Initialize output parameters
    SET @nAfterScn = @nScn
    SET @nAfterStep = @nStep

    -- Retrieve current mobile session data (for confirmation screen ESC handling)
    SELECT
        @nMobStep        = Step,
        @nMobScn         = Scn,
        @cCaptureInfo    = V_String16,
        @cOrigPalletKey  = V_String41,  -- Read original PalletKey from main SP
        @cSavedPalletKey = C_String1    -- ExtScn saved PalletKey
    FROM rdt.rdtMobRec (NOLOCK)
    WHERE Mobile = @nMobile


    IF @nFunc = 825
    BEGIN
        -- Handle confirmation screen (Screen 4 - Scn 6829)
        IF @nMobScn = 6829 -- Confirmation Screen
        BEGIN
            SET @cPalletKey = ISNULL(NULLIF(@cOrigPalletKey, ''), ISNULL(NULLIF(@cSavedPalletKey, ''), @cOrigPalletKey))
            IF @nInputKey = 1 -- ENTER - Confirm and proceed with update
            BEGIN
                -- FCR-14856: Insert TRANSMITLOG2 on Scn 6829 ENTER
                -- Get LOT from LOTxLOCxID using PalletKey (ID)
                SELECT TOP 1 @cLOT = Lot
                FROM dbo.LOTxLOCxID WITH (NOLOCK)
                WHERE Id = @cPalletKey
                  AND StorerKey = @cStorerKey
                  AND Qty > 0
                ORDER BY SKU, Lot
                SET @nRowCount = @@ROWCOUNT

                IF @nRowCount = 0
                BEGIN
                    SET @nErrNo = 280551
                    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 280551 Inventory not found for PalletKey
                    GOTO SCN_6829_Fail
                END

                -- Get Lottable03 from LOTATTRIBUTE (if LOT found; else @cLot03 stays NULL -> GRN Patch path)
                IF NULLIF(@cLOT, '') IS NOT NULL
                BEGIN
                    SELECT @cLot03 = Lottable03
                    FROM dbo.LOTATTRIBUTE WITH (NOLOCK)
                    WHERE Lot = @cLOT
                      AND StorerKey = @cStorerKey

                    SET @cLot03 = ISNULL(@cLot03, '')  -- Avoid NULL for comparison
                END

                -- Generate TransmitLogKey2
                EXECUTE dbo.nspg_GetKey
                    'TransmitLogKey2',
                    10,
                    @cTransmitLogKey OUTPUT,
                    @bSuccess        OUTPUT,
                    @nErrNo          OUTPUT,
                    @cErrMsg         OUTPUT
                IF @bSuccess <> 1
                BEGIN
                    SET @nErrNo = 280552
                    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 280552 TransmitLog2 key generation failed
                    GOTO SCN_6829_Fail
                END

                -- Route: GRN (Lottable03 = PalletKey) vs GRN Patch (all other cases incl. LOT not found)
                IF @cLot03 = @cPalletKey
                BEGIN
                    -- GRN path (WSNSCPRECCFM): get ReceiptKey + ReceiptLineNumber
                    SELECT TOP 1
                        @cReceiptKey    = ReceiptKey,
                        @cReceiptLineNo = ReceiptLineNumber
                    FROM dbo.RECEIPTDETAIL WITH (NOLOCK)
                    WHERE ToId = @cPalletKey
                      AND StorerKey = @cStorerKey
                    ORDER BY ReceiptKey ASC, ReceiptLineNumber ASC

                    IF NULLIF(@cReceiptKey, '') IS NULL
                    BEGIN
                        SET @nErrNo = 280553
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 280553 Receipt detail not found for pallet
                        GOTO SCN_6829_Fail
                    END

                    SET @cTransmitflag = ''
                    SET @cTransmitLogKey2 = ''
                    SELECT
                        @cTransmitflag = Transmitflag,
                        @cTransmitLogKey2 = TransmitLogKey
                    FROM dbo.TRANSMITLOG2 WITH (NOLOCK)
                    WHERE TableName = 'WSNSCPRECCFM'
                        AND Key1 = @cReceiptKey
                        AND Key2 = @cReceiptLineNo
                        AND Key3 = @cStorerKey
                    ORDER BY transmitlogkey DESC

                    SELECT @nRowCount = @@ROWCOUNT
                    SET @cTransmitflag = ISNULL(@cTransmitflag, '')  -- Avoid NULL for comparison
                    SET @cTransmitLogKey2 = ISNULL(@cTransmitLogKey2, '')  -- Avoid NULL for comparison

                    IF @nRowCount > 1
                    BEGIN
                        SET @nErrNo = 280554
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 280554 Multiple TransmitLog2 records found (GRN)
                        GOTO SCN_6829_Fail
                    END

                    IF @nRowCount = 1 AND @cTransmitflag = '9'
                    BEGIN
                        BEGIN TRY
                            UPDATE dbo.TRANSMITLOG2 WITH (ROWLOCK)
                            SET 
                                Transmitflag = 0,
                                EditDate = GETDATE(),
                                EditWho = SUSER_SNAME()
                            WHERE TransmitLogKey = @cTransmitLogKey2
                        END TRY
                        BEGIN CATCH
                            SET @nErrNo = 280555
                            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 280555 TransmitLog2 update failed (GRN)
                            GOTO SCN_6829_Fail
                        END CATCH
                    END
                    ELSE
                    BEGIN
                        BEGIN TRY
                            INSERT INTO dbo.TRANSMITLOG2 (TransmitLogKey, TableName, Key1, Key2, Key3, TransmitFlag)
                            VALUES (@cTransmitLogKey, 'WSNSCPRECCFM', @cReceiptKey, @cReceiptLineNo, @cStorerKey, '0')
                        END TRY
                        BEGIN CATCH
                            SET @nErrNo = 280556
                            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 280556 TransmitLog2 insert failed (GRN)
                            GOTO SCN_6829_Fail
                        END CATCH
                    END
                END
                ELSE
                BEGIN
                    -- GRN Patch path (WSNSCPPLTCFM): Key1 = first 10 chars of PalletKey, Key2 = full PalletKey
                    BEGIN TRY
                        IF NOT EXISTS(SELECT 1 FROM dbo.TRANSMITLOG2 WITH (NOLOCK)
                                       WHERE TableName = 'WSNSCPPLTCFM'
                                         AND Key1 = LEFT(@cPalletKey, 10)
                                         AND Key2 = @cPalletKey
                                         AND Key3 = @cStorerKey)
                        BEGIN
                            INSERT INTO dbo.TRANSMITLOG2 (TransmitLogKey, TableName, Key1, Key2, Key3, TransmitFlag)
                            VALUES (@cTransmitLogKey, 'WSNSCPPLTCFM', LEFT(@cPalletKey, 10), @cPalletKey, @cStorerKey, '0')
                        END
                    END TRY
                    BEGIN CATCH
                        SET @nErrNo = 280557
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 280557 TransmitLog2 insert failed (GRN Patch)
                        GOTO SCN_6829_Fail
                    END CATCH
                END

                -- Clear fields for next pallet
                SELECT @cFieldAttr01 = '', @cFieldAttr02 = '', @cFieldAttr03 = '', @cFieldAttr04 = '', @cFieldAttr05 = '', @cFieldAttr07 = ''

                SET @cOutField01 = ''   -- PalletKey
                SET @cOutField02 = ''   -- Length
                SET @cOutField03 = ''   -- Width
                SET @cOutField04 = ''   -- Height
                SET @cOutField05 = ''   -- Weight
                SET @cOutField06 = ''
                SET @cOutField07 = ''   -- Stackability

                -- Go back to PalletKey screen (Screen 2)
                SET @nAfterScn = 5111
                SET @nAfterStep = 2

                GOTO Quit
            END

            IF @nInputKey = 0 -- ESC - Go back to edit screen (Screen 3)
            BEGIN
                -- Use @cInField values (from confirmation screen) or saved PalletKey
                SET @cLength = @cInField02
                SET @cWidth = @cInField03
                SET @cHeight = @cInField04
                SET @cWeight = @cInField05
                SET @cStackability = @cInField07

                -- Set fields as editable
                SELECT @cFieldAttr02 = '', @cFieldAttr03 = '', @cFieldAttr04 = '', @cFieldAttr05 = '', @cFieldAttr07 = ''

                -- Restore values to output fields for editing
                SET @cOutField01 = @cPalletKey
                SET @cOutField02 = @cLength
                SET @cOutField03 = @cWidth
                SET @cOutField04 = @cHeight
                SET @cOutField05 = @cWeight
                SET @cOutField06 = @cCaptureInfo
                SET @cOutField07 = @cStackability

                -- Go back to volumetric data entry screen (Screen 3)
                SET @nAfterScn = 5112
                SET @nAfterStep = 3

                GOTO Quit
            END
            SCN_6829_Fail:
                SET @cLength = @cInField02
                SET @cWidth = @cInField03
                SET @cHeight = @cInField04
                SET @cWeight = @cInField05
                SET @cStackability = @cInField07

                -- Populate confirmation screen with display-only data
                SET @cOutField01 = @cPalletKey
                SET @cOutField02 = @cLength
                SET @cOutField03 = @cWidth
                SET @cOutField04 = @cHeight
                SET @cOutField05 = @cWeight
                SET @cOutField06 = @cCaptureInfo
                SET @cOutField07 = @cStackability
                GOTO Quit
        END

        -- Coming from Screen 3 (Scn 5112)
        IF @nMobScn = 5112
        BEGIN
            IF @nInputKey = 1 -- ENTER - Show confirmation screen
            BEGIN
                -- Use @cInField values directly (from screen input)
                -- PalletKey: try @cInField01, then saved C_String1, then original V_String41
                SET @cPalletKey = ISNULL(NULLIF(@cOrigPalletKey, ''), ISNULL(NULLIF(@cSavedPalletKey, ''), @cOrigPalletKey))
                SET @cLength = @cInField02
                SET @cWidth = @cInField03
                SET @cHeight = @cInField04
                SET @cWeight = @cInField05
                SET @cStackability = @cInField07

                -- Save PalletKey to C_String1 for preservation (main SP will clear V_String41)
                UPDATE rdt.rdtMobRec WITH (ROWLOCK)
                SET C_String1 = @cPalletKey
                WHERE Mobile = @nMobile

                -- Populate confirmation screen with display-only data
                SET @cOutField01 = @cPalletKey
                SET @cOutField02 = @cLength
                SET @cOutField03 = @cWidth
                SET @cOutField04 = @cHeight
                SET @cOutField05 = @cWeight
                SET @cOutField06 = @cCaptureInfo
                SET @cOutField07 = @cStackability

                -- Set to confirmation screen
                SET @nAfterScn = 6829
                SET @nAfterStep = 99

                GOTO Quit
            END

            IF @nInputKey = 0 -- ESC - Go back to Screen 2 (PalletKey)
            BEGIN
                -- Clear fields
                SELECT @cFieldAttr01 = '', @cFieldAttr02 = '', @cFieldAttr03 = '', @cFieldAttr04 = '', @cFieldAttr05 = '', @cFieldAttr07 = ''

                SET @cOutField01 = ''
                SET @cOutField02 = ''
                SET @cOutField03 = ''
                SET @cOutField04 = ''
                SET @cOutField05 = ''
                SET @cOutField06 = ''
                SET @cOutField07 = ''

                -- Go to Screen 2 (PalletKey)
                SET @nAfterScn = 5111
                SET @nAfterStep = 2

                GOTO Quit
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
GRANT EXECUTE ON rdt.rdt_825ExtScn03 TO NSQL
GO

