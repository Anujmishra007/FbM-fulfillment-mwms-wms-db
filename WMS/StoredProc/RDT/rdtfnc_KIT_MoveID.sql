SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


/************************************************************************/
/* Copyright: Maersk                                                    */
/* Purpose: KIT Move pallet                                             */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2025-12-01 1.0  JackC    FCR-7406 Created                            */
/************************************************************************/

CREATE OR ALTER   PROCEDURE [RDT].[rdtfnc_KIT_MoveID] (
   @nMobile    INT,
   @nErrNo     INT           OUTPUT,
   @cErrMsg    NVARCHAR( 1024) OUTPUT
) AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

-- Misc variable
DECLARE
   @i             INT,
   @nRowCount     INT,
   @cChkFacility  NVARCHAR( 5),
   @cPUOM_Desc    NVARCHAR( 5), -- Preferred UOM desc
   @cMUOM_Desc    NVARCHAR( 5), -- Master unit desc
   @nPUOM_Div     INT, -- UOM divider
   @nPQTY         INT, -- Preferred UOM QTY
   @nMQTY         INT, -- Master unit QTY
   @nQTY          INT,

   @cLoop_StorerKey     NVARCHAR( 15),    -- (james02)
   @cSKU_StorerKey      NVARCHAR( 15)     -- (james02)

-- RDT.RDTMobRec variable
DECLARE
   @nFunc      INT,
   @nScn       INT,
   @nStep      INT,
   @cLangCode  NVARCHAR( 3),
   @nInputKey  INT,
   @nMenu      INT,

   @cStorerGroup    NVARCHAR( 20),
   @cStorerKey      NVARCHAR( 15),
   @cFacility       NVARCHAR( 5),
   @cUserName       NVARCHAR(18), -- (Vicky06)

   @cSKU          NVARCHAR( 20),
   @cSKUDescr     NVARCHAR( 60),
   @cPUOM         NVARCHAR( 1), -- Prefer UOM
   @cLOCCheckDigitSP    NVARCHAR( 20),
   @cCheckDigitLOC      NVARCHAR( 20),
   @cFromLOC            NVARCHAR( 10),
   @cFromID             NVARCHAR( 18),
   @cToLOC              NVARCHAR( 10),
   @nTotalRec           INT,
   @nCurrentRec         INT,
   @cToLOCLookupSP      NVARCHAR(20),  
   @cExtendedUpdateSP   NVARCHAR(20),
   @cChkStorerKey       NVARCHAR( 15), 
   @cExtendedValidateSP NVARCHAR( 20), 
   @cSQL                NVARCHAR(MAX), 
   @cSQLParam           NVARCHAR(MAX), 
   @cMoveQTYAlloc       NVARCHAR( 1),  
   @cMoveQTYPick        NVARCHAR( 1),  
   @nQTYPick            INT,           
   @nQTYAlloc           INT,           
   @cBarcode            NVARCHAR( 60),
   @cDecodeSP           NVARCHAR( 20),
   @cLottable01         NVARCHAR( 18),
   @cLottable02         NVARCHAR( 18),
   @cLottable03         NVARCHAR( 18),
   @dLottable04         DATETIME,
   @dLottable05         DATETIME,
   @cLottable06         NVARCHAR( 30),
   @cLottable07         NVARCHAR( 30),
   @cLottable08         NVARCHAR( 30),
   @cLottable09         NVARCHAR( 30),
   @cLottable10         NVARCHAR( 30),
   @cLottable11         NVARCHAR( 30),
   @cLottable12         NVARCHAR( 30),
   @dLottable13         DATETIME,
   @dLottable14         DATETIME,
   @dLottable15         DATETIME,
   @cExtendedInfo       NVARCHAR( 20),    
   @cExtendedInfoSP     NVARCHAR( 20),   
   @cSuggestLocSP       NVARCHAR( 20), 
   @cLOCLookupSP        NVARCHAR( 20),   
   @cDefaultFromLOC     NVARCHAR( 1),

   @cInField01 NVARCHAR( 60),   @cOutField01 NVARCHAR( 60),
   @cInField02 NVARCHAR( 60),   @cOutField02 NVARCHAR( 60),
   @cInField03 NVARCHAR( 60),   @cOutField03 NVARCHAR( 60),
   @cInField04 NVARCHAR( 60),   @cOutField04 NVARCHAR( 60),
   @cInField05 NVARCHAR( 60),   @cOutField05 NVARCHAR( 60),
   @cInField06 NVARCHAR( 60),   @cOutField06 NVARCHAR( 60),
   @cInField07 NVARCHAR( 60),   @cOutField07 NVARCHAR( 60),
   @cInField08 NVARCHAR( 60),   @cOutField08 NVARCHAR( 60),
   @cInField09 NVARCHAR( 60),   @cOutField09 NVARCHAR( 60),
   @cInField10 NVARCHAR( 60),   @cOutField10 NVARCHAR( 60),
   @cInField11 NVARCHAR( 60),   @cOutField11 NVARCHAR( 60),
   @cInField12 NVARCHAR( 60),   @cOutField12 NVARCHAR( 60),
   @cInField13 NVARCHAR( 60),   @cOutField13 NVARCHAR( 60),
   @cInField14 NVARCHAR( 60),   @cOutField14 NVARCHAR( 60),
   @cInField15 NVARCHAR( 60),   @cOutField15 NVARCHAR( 60)

-- Load RDT.RDTMobRec
SELECT
   @nFunc      = Func,
   @nScn       = Scn,
   @nStep      = Step,
   @nInputKey  = InputKey,
   @nMenu      = Menu,
   @cLangCode  = Lang_code,

   @cStorerGroup  = StorerGroup,
   @cFacility   = Facility,
   @cUserName   = UserName,-- (Vicky06)

   @cStorerKey = V_StorerKey,

   @cFromID             = V_String1,
   @cToLOC              = V_String2,
   @cExtendedInfoSP     = V_String4,
   @cExtendedValidateSP = V_String5,
   @cToLOCLookupSP      = V_String6, --(ung01)
   @cExtendedUpdateSP   = V_String8,
   @cMoveQTYPick        = V_String9, -- (ChewKP04)
   @cMoveQTYAlloc       = V_String10,-- (ChewKP04)
   @cDecodeSP           = V_String11,
   @cLOCLookupSP        = V_String12, --(yeekung01)
   @cSuggestLocSP       = V_String14, --(CYU027)

   @nTotalRec           = V_Integer1,
   @nCurrentRec         = V_Integer2,

   @cLOCCheckDigitSP    = C_String1,

   @cInField01 = I_Field01,   @cOutField01 = O_Field01,
   @cInField02 = I_Field02,   @cOutField02 = O_Field02,
   @cInField03 = I_Field03,   @cOutField03 = O_Field03,
   @cInField04 = I_Field04,   @cOutField04 = O_Field04,
   @cInField05 = I_Field05,   @cOutField05 = O_Field05,
   @cInField06 = I_Field06,   @cOutField06 = O_Field06,
   @cInField07 = I_Field07,   @cOutField07 = O_Field07,
   @cInField08 = I_Field08,   @cOutField08 = O_Field08,
   @cInField09 = I_Field09,   @cOutField09 = O_Field09,
   @cInField10 = I_Field10,   @cOutField10 = O_Field10,
   @cInField11 = I_Field11,   @cOutField11 = O_Field11,
   @cInField12 = I_Field12,   @cOutField12 = O_Field12,
   @cInField13 = I_Field13,   @cOutField13 = O_Field13,
   @cInField14 = I_Field14,   @cOutField14 = O_Field14,
   @cInField15 = I_Field15,   @cOutField15 = O_Field15

FROM rdt.rdtMobRec WITH (NOLOCK)
WHERE Mobile = @nMobile

IF @nFunc = 1873 -- KIT Move ID
BEGIN
   -- Redirect to respective screen
   IF @nStep = 0 GOTO Step_0   -- Func = Move (generic)
   IF @nStep = 1 GOTO Step_1   -- Scn = 6740. FromID
   IF @nStep = 2 GOTO Step_2   -- Scn = 6741. ToLoc
   IF @nStep = 3 GOTO Step_3   -- Scn = 6742. Message
END
RETURN -- Do nothing if incorrect step


/********************************************************************************
Step 0. func = 1873. Menu
********************************************************************************/
Step_0:
BEGIN
   -- Set the entry point
   SET @nScn = 6740
   SET @nStep = 1

   -- Prep next screen var
   SET @cFromID = ''
   SET @cToLOC = ''

   SET @nTotalRec = 0
   SET @nCurrentRec = 0

   -- Get storer configure
   SET @cLOCLookupSP = rdt.rdtGetConfig(@nFunc, 'LOCLookupSP', @cStorerKey)

   SET @cDecodeSP = rdt.RDTGetConfig( @nFunc, 'DecodeSP', @cStorerKey)
   IF @cDecodeSP = '0'
      SET @cDecodeSP = ''
   SET @cExtendedInfoSP = rdt.rdtGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerKey)
   IF @cExtendedInfoSP = '0'
      SET @cExtendedInfoSP = ''
   SET @cExtendedValidateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)
   IF @cExtendedValidateSP = '0'
      SET @cExtendedValidateSP = ''
   SET @cExtendedUpdateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)
   IF @cExtendedUpdateSP = '0'
      SET @cExtendedUpdateSP = ''
   SET @cSuggestLocSP = rdt.rdtGetConfig( @nFunc, 'SuggestLocSP', @cStorerKey)
   IF @cSuggestLocSP = '0'
       SET @cSuggestLocSP = ''
   SET @cLOCCheckDigitSP = rdt.rdtGetConfig(@nFunc, 'LOCCheckDigitSP', @cStorerKey)

   -- EventLog
   EXEC RDT.rdt_STD_EventLog
      @cActionType = '1', -- Sign-in
      @cUserID     = @cUserName,
      @nMobileNo   = @nMobile,
      @nFunctionID = @nFunc,
      @cFacility   = @cFacility,
      @cStorerKey  = @cStorerkey,
      @nStep       = @nStep

   -- Init screen
   SET @cOutField01 = '' -- FromID
END
GOTO Quit


/********************************************************************************
Step 1. Scn = 6740. FromID
   PalletID  (field01, input)

********************************************************************************/
Step_1:
BEGIN
   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      -- Screen mapping
      SET @cFromID = LEFT(@cInField01,18)
      SET @cBarcode = @cInField01

      -- Validate blank
      IF @cFromID = '' OR @cFromID IS NULL
      BEGIN
         SET @nErrNo = 25901
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'ID needed'
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      -- Decode
      IF @cDecodeSP <> ''
      BEGIN
         -- Standard decode
         IF @cDecodeSP = '1'
         BEGIN
            EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,
               @cID     = @cFromID OUTPUT,
               @cUPC    = @cSKU    OUTPUT,
               @nQTY    = @nQTY    OUTPUT,
               @cType   = 'ID'
         END

         -- Customize decode
         ELSE IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cDecodeSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cDecodeSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cBarcode, ' +
               ' @cID         OUTPUT, @cFromLOC    OUTPUT, @cToLOC      OUTPUT, ' +
               ' @nErrNo      OUTPUT, @cErrMsg     OUTPUT'
            SET @cSQLParam =
               ' @nMobile      INT,             ' +
               ' @nFunc        INT,             ' +
               ' @cLangCode    NVARCHAR( 3),    ' +
               ' @nStep        INT,             ' +
               ' @nInputKey    INT,             ' +
               ' @cStorerKey   NVARCHAR( 15),   ' +
               ' @cBarcode     NVARCHAR( 2000), ' +
               ' @cID          NVARCHAR( 18)  OUTPUT, ' +
               ' @cFromLOC     NVARCHAR( 10)  OUTPUT, ' +
               ' @cToLOC       NVARCHAR( 10)  OUTPUT, ' +
               ' @nErrNo       INT            OUTPUT, ' +
               ' @cErrMsg      NVARCHAR( 1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cBarcode,
               @cFromID     OUTPUT, @cFromLOC    OUTPUT, @cToLOC      OUTPUT,
               @nErrNo      OUTPUT, @cErrMsg     OUTPUT
         END

         IF @nErrNo <> 0
            GOTO Step_1_Fail
      END

      IF NOT EXISTS( SELECT 1 FROM dbo.KIT WITH (NOLOCK)
                     JOIN dbo.KITDETAIL KID WITH (NOLOCK)
                        ON KIT.KitKey = KID.KitKey
                     WHERE KIT.StorerKey = @cStorerkey
                        AND KIT.Status <> '9'
                        AND KID.ID = @cFromID
                        AND KID.Type = 'T'
      )
      BEGIN
         SET @nErrNo = 252902
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Invalid ID'
         GOTO Step_1_Fail
      END

      -- Extended update
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cFromID         NVARCHAR( 18), ' +
               '@cToLOC          NVARCHAR( 10), ' +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO Step_1_Fail
            END
         END
      END

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cFromID, @cToLoc, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile        INT,           ' +
               '@nFunc          INT,           ' +
               '@cLangCode      NVARCHAR( 3),  ' +
               '@nStep          INT,           ' +
               '@nInputKey      INT,           ' +
               '@cFacility      NVARCHAR( 5),  ' +
               '@cStorerKey     NVARCHAR( 15), ' +
               '@cFromID        NVARCHAR( 18), ' +
               '@cToLOC         NVARCHAR( 10), ' +
               '@nErrNo         INT           OUTPUT, ' +
               '@cErrMsg        NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cFromID, @cToLoc,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               GOTO Step_1_Fail
            END
         END
      END

      -- Extended info
      IF @cExtendedInfoSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
         BEGIN
            SET @cExtendedInfo = ''

            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cToLOC, @cExtendedInfo OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cFromID         NVARCHAR( 18), ' +
               '@cToLOC          NVARCHAR( 10), ' +
               '@cExtendedInfo   NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cToLOC, @cExtendedInfo OUTPUT

            SET @cOutField15 = CASE WHEN ISNULL( @cExtendedInfo, '') <> '' THEN @cExtendedInfo ELSE '' END
         END
      END

      -- Prep next screen var
      SET @cOutField01 = @cFromID
      SET @cOutField02 = ''

      -- Go to next screen
      SET @nScn = @nScn + 1
      SET @nStep = @nStep + 1
   END

   IF @nInputKey = 0 -- Esc or No
   BEGIN
     EXEC RDT.rdt_STD_EventLog
       @cActionType = '9', -- Sign Out function
       @cUserID     = @cUserName,
       @nMobileNo   = @nMobile,
       @nFunctionID = @nFunc,
       @cFacility   = @cFacility,
       @cStorerKey  = @cStorerkey,
       @nStep       = @nStep

      -- Back to menu
      SET @nFunc = @nMenu
      SET @nScn  = @nMenu
      SET @nStep = 0
      SET @cOutField01 = ''
   END
   GOTO Quit

   Step_1_Fail:
   BEGIN
      SET @cFromID  = ''
      SET @cOutField01 = '' -- ID
   END
END
GOTO Quit


/********************************************************************************
Step 2. Scn = 6471. ToLoc
   PalletID  (field01)
   ToLoc (field02, input)
********************************************************************************/
Step_2:
BEGIN
   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      -- Screen mapping
      SET @cToLOC = @cInField02

      -- Validate blank
      IF @cToLOC = '' OR @cToLOC IS NULL
      BEGIN
         SET @nErrNo = 252903
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'LOC needed'
         GOTO Step_2_Fail
      END
      SET @cCheckDigitLOC = @cInField02
      IF @cLOCCheckDigitSP = '1'
      BEGIN
         EXEC rdt.rdt_LOCLookUp_CheckDigit @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFacility,
            @cCheckDigitLOC    OUTPUT,
            @nErrNo      OUTPUT,
            @cErrMsg     OUTPUT
         IF @nErrNo <> 0
            GOTO Step_2_Fail
         SET @cToLOC = @cCheckDigitLOC
      END

      -- add loc prefix (yeekung01)
      IF @cLOCLookupSP = 1
      BEGIN
         EXEC rdt.rdt_LOCLookUp @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFacility,
            @cToLOC    OUTPUT,
            @nErrNo      OUTPUT,
            @cErrMsg     OUTPUT
         IF @nErrNo <> 0
            GOTO Step_2_Fail
      END

      -- Get LOC info
      SELECT 
         @cChkFacility = Facility
      FROM dbo.LOC (NOLOCK)
      WHERE LOC = @cToLOC

      -- Validate LOC
      IF @@ROWCOUNT = 0
      BEGIN
         SET @nErrNo = 252904
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Invalid LOC'
         GOTO Step_2_Fail
      END

      -- Validate LOC's facility
      IF @cChkFacility <> @cFacility
      BEGIN
         SET @nErrNo = 252905
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Diff facility'
         GOTO Step_2_Fail
      END

      -- Extended Validation
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cFromID         NVARCHAR( 18), ' +
               '@cToLOC          NVARCHAR( 10), ' +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO Step_2_Fail
            END
         END
      END

      DECLARE @nTranCount  INT
      SET @nTranCount = @@TRANCOUNT
      BEGIN TRAN
      SAVE TRAN rdtfnc_KIT_MoveID

      BEGIN TRY
         UPDATE dbo.KITDETAIL WITH (ROWLOCK)
         SET Loc = @cToLoc
         WHERE StorerKey = @cStorerKey
            AND ID = @cFromID
            AND Type = 'T'
            AND Status <> '9'
      END TRY
      BEGIN CATCH
         SET @nErrNo = 252906
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Exceed max pallet'
         ROLLBACK TRAN rdtfnc_KIT_MoveID
         WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
            COMMIT TRAN
         GOTO Step_2_Fail
      END CATCH

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cFromID, @cToLoc, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile        INT,           ' +
               '@nFunc          INT,           ' +
               '@cLangCode      NVARCHAR( 3),  ' +
               '@nStep          INT,           ' +
               '@nInputKey      INT,           ' +
               '@cFacility      NVARCHAR( 5),  ' +
               '@cStorerKey     NVARCHAR( 15), ' +
               '@cFromID        NVARCHAR( 18), ' +
               '@cToLOC         NVARCHAR( 10), ' +
               '@nErrNo         INT           OUTPUT, ' +
               '@cErrMsg        NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cFromID, @cToLoc,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               ROLLBACK TRAN rdtfnc_KIT_MoveID
               WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                  COMMIT TRAN
               GOTO Step_2_Fail
            END
         END
      END

      COMMIT TRAN rdtfnc_Move_ID
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
         COMMIT TRAN

      SET @cOutField11 = '' -- ToLOC
      IF @cSuggestLocSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cSuggestLocSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cSuggestLocSP) +
                        ' @nMobile, @nFunc, @cLangCode, @cStorerKey, @cFacility, @cFromLOC, @cFromID, @cSKU, @nQTY, @cToID, @cToLOC, @cType, ' +
                        ' @cOutField01 OUTPUT, @cOutField02 OUTPUT, @cOutField03 OUTPUT, @cOutField04 OUTPUT, @cOutField05 OUTPUT, ' +
                        ' @cOutField06 OUTPUT, @cOutField07 OUTPUT, @cOutField08 OUTPUT, @cOutField09 OUTPUT, @cOutField10 OUTPUT, ' +
                        ' @cOutField11 OUTPUT, @cOutField12 OUTPUT, @cOutField13 OUTPUT, @cOutField14 OUTPUT, @cOutField15 OUTPUT, ' +
                        ' @nErrNo      OUTPUT, @cErrMsg     OUTPUT'
            SET @cSQLParam =
                          ' @nMobile         INT,                  ' +
                          ' @nFunc  INT,                  ' +
                          ' @cLangCode       NVARCHAR( 3),         ' +
                          ' @cStorerKey      NVARCHAR( 15),        ' +
                          ' @cFacility       NVARCHAR(  5),        ' +
                          ' @cFromLOC        NVARCHAR( 10),        ' +
                          ' @cFromID         NVARCHAR( 18),        ' +
                          ' @cSKU            NVARCHAR( 20),        ' +
                          ' @nQTY            INT,                  ' +
                          ' @cToID           NVARCHAR( 18),        ' +
                          ' @cToLOC          NVARCHAR( 10),        ' +
                          ' @cType           NVARCHAR( 10),        ' +
                          ' @cOutField01     NVARCHAR( 20) OUTPUT, ' +
                          ' @cOutField02     NVARCHAR( 20) OUTPUT, ' +
                          ' @cOutField03     NVARCHAR( 20) OUTPUT, ' +
                          ' @cOutField04     NVARCHAR( 20) OUTPUT, ' +
                          ' @cOutField05     NVARCHAR( 20) OUTPUT, ' +
                          ' @cOutField06     NVARCHAR( 20) OUTPUT, ' +
                          ' @cOutField07     NVARCHAR( 20) OUTPUT, ' +
                          ' @cOutField08     NVARCHAR( 20) OUTPUT, ' +
                          ' @cOutField09     NVARCHAR( 20) OUTPUT, ' +
                          ' @cOutField10     NVARCHAR( 20) OUTPUT, ' +
                          ' @cOutField11     NVARCHAR( 20) OUTPUT, ' +
                          ' @cOutField12     NVARCHAR( 20) OUTPUT, ' +
                          ' @cOutField13     NVARCHAR( 20) OUTPUT, ' +
                          ' @cOutField14     NVARCHAR( 20) OUTPUT, ' +
                          ' @cOutField15     NVARCHAR( 20) OUTPUT, ' +
                          ' @nErrNo          INT           OUTPUT, ' +
                          ' @cErrMsg         NVARCHAR(1024) OUTPUT  '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                  @nMobile, @nFunc, @cLangCode, @cStorerKey, @cFacility, @cFromLOC, @cFromID, @cSKU, @nQTY, @cFromID, @cToLOC, 'VAS',
                  @cOutField01 OUTPUT, @cOutField02 OUTPUT, @cOutField03 OUTPUT, @cOutField04 OUTPUT, @cOutField05 OUTPUT,
                  @cOutField06 OUTPUT, @cOutField07 OUTPUT, @cOutField08 OUTPUT, @cOutField09 OUTPUT, @cOutField10 OUTPUT,
                  @cOutField11 OUTPUT, @cOutField12 OUTPUT, @cOutField13 OUTPUT, @cOutField14 OUTPUT, @cOutField15 OUTPUT,
                  @nErrNo      OUTPUT, @cErrMsg     OUTPUT

            IF @nErrNo <> 0 AND
               @nErrNo <> -1
                GOTO Quit
         END
      END

      -- Prep next screen var
      SET @cOutField01 = ''

      -- Go to next screen
      SET @nScn = @nScn + 1
      SET @nStep = @nStep + 1
   END

   IF @nInputKey = 0 -- Esc or No
   BEGIN
      -- Prepare prev screen var
      SET @cFromID = ''
      SET @cToLOC = ''
      SET @cOutField01 = '' -- FromID

      -- Go back to prev screen
      SET @nScn  = @nScn - 1
      SET @nStep = @nStep - 1
   END
   GOTO Quit

   Step_2_Fail:
   BEGIN
      SET @cToLOC  = ''
      SET @cOutField02 = '' -- ToLoc
   END
END
GOTO Quit


/********************************************************************************
Step 3. scn = 6473. Message screen
   Msg
********************************************************************************/
Step_3:
BEGIN
   -- Go back to 1st screen
   SET @nScn  = @nScn - 2
   SET @nStep = @nStep - 2

   -- Prep next screen var
   SET @cFromID = ''
   SET @cToLOC = ''

   SET @cOutField01 = '' -- FromID
END
GOTO Quit


/********************************************************************************
Quit. Update back to I/O table, ready to be pick up by JBOSS
********************************************************************************/
Quit:
BEGIN
   UPDATE rdt.RDTMOBREC WITH (ROWLOCK) SET
      EditDate = GETDATE(),
      ErrMsg = @cErrMsg,
      Func   = @nFunc,
      Step   = @nStep,
      Scn    = @nScn,

      Facility  = @cFacility,
      -- UserName  = @cUserName,-- (Vicky06)

      V_StorerKey = @cStorerKey,
      V_String1   = @cFromID,
      V_String2   = @cToLOC,
      V_String4   = @cExtendedInfoSP,
      V_String5   = @cExtendedValidateSP,
      V_String6   = @cToLOCLookupSP,
      V_String8   = @cExtendedUpdateSP,
      V_string9   = @cMoveQTYPick, 
      V_String10  = @cMoveQTYAlloc, 
      V_String11  = @cDecodeSP,
      V_String12  = @cLOCLookupSP, 
      V_String14 =  @cSuggestLocSP,

      V_Integer1  = @nTotalRec,
      V_Integer2  = @nCurrentRec,

      C_String1   = @cLOCCheckDigitSP,

      I_Field01 = @cInField01,  O_Field01 = @cOutField01,
      I_Field02 = @cInField02,  O_Field02 = @cOutField02,
      I_Field03 = @cInField03,  O_Field03 = @cOutField03,
      I_Field04 = @cInField04,  O_Field04 = @cOutField04,
      I_Field05 = @cInField05,  O_Field05 = @cOutField05,
      I_Field06 = @cInField06,  O_Field06 = @cOutField06,
      I_Field07 = @cInField07,  O_Field07 = @cOutField07,
      I_Field08 = @cInField08,  O_Field08 = @cOutField08,
      I_Field09 = @cInField09,  O_Field09 = @cOutField09,
      I_Field10 = @cInField10,  O_Field10 = @cOutField10,
      I_Field11 = @cInField11,  O_Field11 = @cOutField11,
      I_Field12 = @cInField12,  O_Field12 = @cOutField12,
      I_Field13 = @cInField13,  O_Field13 = @cOutField13,
      I_Field14 = @cInField14,  O_Field14 = @cOutField14,
      I_Field15 = @cInField15,  O_Field15 = @cOutField15

   WHERE Mobile = @nMobile
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdtfnc_KIT_MoveID TO NSQL
GO


