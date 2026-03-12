SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


/************************************************************************/
/* Copyright: Maersk                                                    */
/* Purpose:                                                             */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2025-12-22 1.0  Dennis   FCR-9733 Created                            */
/************************************************************************/

CREATE OR ALTER   PROCEDURE [RDT].[rdtfnc_COL_UCCSort] (
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
   @cPutawayZone    NVARCHAR(20),
   @cAreakey        NVARCHAR(10),
   @cStorerGroup    NVARCHAR( 20),
   @cStorerKey      NVARCHAR( 15),
   @cFacility       NVARCHAR( 5),
   @cUserName       NVARCHAR(18), -- (Vicky06)
   
   @cLocationType  NVARCHAR( 10),
   @cTempLocationType  NVARCHAR( 10),
   @cSKU          NVARCHAR( 20),
   @cSKUDescr     NVARCHAR( 60),
   @cPUOM         NVARCHAR( 1), -- Prefer UOM
   @cLOCCheckDigitSP    NVARCHAR( 20),
   @cLocConfirm         NVARCHAR( 5),
   @cCheckDigitLOC      NVARCHAR( 20),
   @cFromLOC            NVARCHAR( 10),
   @cFromID             NVARCHAR( 18),
   @cToLOC              NVARCHAR( 10),
   @nTotalRec           INT,
   @nCurrentRec         INT,
   @cToLOCLookupSP      NVARCHAR(20),  -- (ung01)
   @cExtendedUpdateSP   NVARCHAR(20),
   @cChkStorerKey       NVARCHAR( 15), -- (james04)
   @cExtendedValidateSP NVARCHAR( 20), -- (james05)
   @cSQL                NVARCHAR(MAX), -- (james05)
   @cSQLParam           NVARCHAR(MAX), -- (james05)
   @cMoveQTYAlloc       NVARCHAR( 1),  -- (ChewKP04)
   @cMoveQTYPick        NVARCHAR( 1),  -- (ChewKP04)
   @nQTYPick            INT,           -- (james07)
   @nQTYAlloc           INT,           -- (james07)
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
   @cExtendedInfo       NVARCHAR( 20),    -- (james09)
   @cExtendedInfoSP     NVARCHAR( 20),    -- (james09)
   @cSuggestLocSP       NVARCHAR( 20),    -- (CYU027)
   @cLOCLookupSP        NVARCHAR( 20),    -- (yeekung01)
   @cDefaultFromLOC     NVARCHAR( 1),
   @cMax                NVARCHAR( MAX),
   @cUCC                 NVARCHAR(20),
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
   @cUCC       = V_UCC,

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
   @cLocConfirm         = V_String15, --(CYU027)

   @cMax                = V_Max,
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

IF @nFunc = 1874
BEGIN
   -- Redirect to respective screen
   IF @nStep = 0 GOTO Step_0   -- 
   IF @nStep = 1 GOTO Step_1   -- Scn = 6760. UCC
   IF @nStep = 2 GOTO Step_2   -- Scn = 6741. ToLoc
END
RETURN -- Do nothing if incorrect step


/********************************************************************************
Step 0. func = 1873. Menu
********************************************************************************/
Step_0:
BEGIN
   -- Set the entry point
   SET @nScn = 6760
   SET @nStep = 1

   -- Prep next screen var
   SET @cUCC = ''
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
   SET @cLocConfirm = rdt.rdtGetConfig(@nFunc, 'LocConfirmation', @cStorerKey)

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
      -- Validate blank
      IF @cMax = '' OR @cMax IS NULL
      BEGIN
         SET @nErrNo = 254551
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'ucc needed'
         GOTO Step_1_Fail
      END

      -- Decode
      SET @cUCC = LEFT(@cMax,20)

      IF NOT EXISTS( SELECT 1 FROM dbo.UCC (NOLOCK) WHERE UCCNo = @cUCC AND StorerKey = @cStorerKey)
      BEGIN
         SET @nErrNo = 254552
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Invalid UCC'
         GOTO Step_1_Fail
      END

      SELECT @cLocationType =  LOC.LocationType,
         @cPutawayZone = LOC.PUTAWAYZONE,
         @cAreakey = AD.AreaKey
      FROM dbo.TASKDETAIL TD (NOLOCK) 
      JOIN LOC LOC (NOLOCK) ON LOC.LOC = TD.TOLOC AND LOC.FACILITY = @cFacility
      LEFT JOIN AREADETAIL AD (NOLOCK) ON AD.PutawayZone = LOC.PUTAWAYZONE
      WHERE TD.CASEID = @cUCC AND TD.StorerKey = @cStorerKey
      AND TD.TASKTYPE IN ('RPF','RP1','RPT','ASTTPA','ASTMV') AND TD.STATUS <> '9'

      SET @nRowCount = @@ROWCOUNT

      IF @nRowCount = 0
      BEGIN
         SET @nErrNo = 254553
         SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') --'UCC has no open replenishment task'
         GOTO Step_1_Fail
      END

      IF ISNULL(@cLocationType ,'') = ''
      BEGIN
         SET @nErrNo = 254554
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'NO LOCATION TYPE'
         GOTO Step_1_Fail
      END

      IF @cLocationType <> 'DYNAMICPK'
      BEGIN
         IF ISNULL(@cPutawayZone,'') = ''
         BEGIN
            SET @nErrNo = 254555
            SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') --'NO LOCATION TYPE'
            GOTO Step_1_Fail
         END
         IF ISNULL(@cAreakey,'') = ''
         BEGIN
            SET @nErrNo = 254556
            SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') --'NO LOCATION TYPE'
            GOTO Step_1_Fail
         END
         SET @cOutField01 = @cAreakey
         SET @cLocationType = @cAreakey
      END
      ELSE
      BEGIN
         SET @cOutField01 = @cLocationType
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
      SET @cUCC = ''
      SET @cMax = ''
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
      SET @cTempLocationType = @cInField02

      IF @cLocConfirm <> '1' AND ISNULL(@cTempLocationType,'') = ''
      BEGIN
         -- Prepare prev screen var
         SET @cMax = ''
         SET @cUCC = ''
         SET @cOutField01 = ''

         -- Go back to prev screen
         SET @nScn  = @nScn - 1
         SET @nStep = @nStep - 1
         GOTO QUIT
      END

      -- Validate blank
      IF @cTempLocationType <> @cOutField01
      BEGIN
         SET @nErrNo = 254557
         SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP')
         GOTO Step_2_Fail
      END
      
      -- Prepare prev screen var
      SET @cMax = ''
      SET @cUCC = ''
      SET @cOutField01 = ''

      -- Go back to prev screen
      SET @nScn  = @nScn - 1
      SET @nStep = @nStep - 1
   END

   IF @nInputKey = 0 -- Esc or No
   BEGIN
      -- Prepare prev screen var
      SET @cMax = ''
      SET @cUCC = ''
      SET @cOutField01 = ''

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
      V_UCC       = @cUCC,
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
      V_String14  = @cSuggestLocSP,
      V_String15  = @cLocConfirm,
      V_Max       = @cMax,

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

GRANT EXECUTE ON RDT.rdtfnc_COL_UCCSort TO NSQL
GO


