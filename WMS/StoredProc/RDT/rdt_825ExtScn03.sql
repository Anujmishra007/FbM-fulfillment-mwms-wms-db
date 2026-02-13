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
        @cPalletKey     NVARCHAR( 30),
        @cLength        NVARCHAR( 10),
        @cWidth         NVARCHAR( 10),
        @cHeight        NVARCHAR( 10),
        @cWeight        NVARCHAR( 10),
        @cStackability  NVARCHAR( 10),
        @cCaptureInfo   NVARCHAR( 10)

    -- Initialize output parameters
    SET @nAfterScn = @nScn
    SET @nAfterStep = @nStep

    -- Retrieve current mobile session data
    SELECT
        @nMobStep      = Step,
        @nMobScn       = Scn,
        @cLength       = V_String7,
        @cWidth        = V_String8,
        @cHeight       = V_String9,
        @cWeight       = V_String6,
        @cStackability = V_String17,
        @cCaptureInfo  = V_String16,
        @cPalletKey    = V_String41
    FROM rdt.rdtMobRec (NOLOCK)
    WHERE Mobile = @nMobile

    IF @nFunc = 825
    BEGIN
        -- Handle confirmation screen (Screen 4 - Scn 6829)
        IF @nMobScn = 6829 -- Confirmation Screen
        BEGIN
            IF @nInputKey = 1 -- ENTER - Confirm and proceed with update
            BEGIN

                -- Clear fields for next pallet
                SELECT @cFieldAttr02 = '', @cFieldAttr03 = '', @cFieldAttr04 = '', @cFieldAttr05 = '', @cFieldAttr07 = ''

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
        END

        -- Coming from Screen 3 (Scn 5112) - Show confirmation screen
        IF @nMobScn = 5112
        BEGIN
            -- Populate confirmation screen with display-only data
            SET @cOutField01 = @cPalletKey    -- PalletKey (display only)
            SET @cOutField02 = @cLength       -- Length (display only)
            SET @cOutField03 = @cWidth        -- Width (display only)
            SET @cOutField04 = @cHeight       -- Height (display only)
            SET @cOutField05 = @cWeight       -- Weight (display only)
            SET @cOutField06 = @cCaptureInfo  -- CaptureInfo (display only)
            SET @cOutField07 = @cStackability -- Stackability (display only)

            -- Set all fields to display only ('D')
            SET @cFieldAttr01 = 'D'
            SET @cFieldAttr02 = 'D'
            SET @cFieldAttr03 = 'D'
            SET @cFieldAttr04 = 'D'
            SET @cFieldAttr05 = 'D'
            SET @cFieldAttr06 = 'D'
            SET @cFieldAttr07 = 'D'

            -- Set to confirmation screen
            SET @nAfterScn = 6829
            SET @nAfterStep = 99

            GOTO Quit
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

