SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


/************************************************************************/
/* Copyright: Maersk                                                    */
/* Purpose: Kitting Scan                                                */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2026-04-09 1.0  Dennis   Created                                     */
/************************************************************************/

CREATE OR ALTER   PROCEDURE [RDT].[rdtfnc_KittingScan] (
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
   @cSQL          NVARCHAR(MAX),
   @cSQLParam     NVARCHAR(MAX),
   @bSuccess      INT

DECLARE
   @cKitKey          NVARCHAR(10),
   @cToLoc           NVARCHAR(10),
   @cToID            NVARCHAR(18),
   @cParentSKU       NVARCHAR(20),
   @cChildSKU        NVARCHAR(20),
   @cChildSKUDescr   NVARCHAR(60),
   @cQTY             NVARCHAR(6),
   @nQTY             INT,
   @nExpectedQty     INT,
   @nBOMQty          INT,
   @nAfterStep       INT,
   @cDefaultToLoc    NVARCHAR(10),
   @cDefaultToQty    NVARCHAR(10),
   @cConvertQTYSP    NVARCHAR(20),
   @nKitDetailQty    INT,
   @nRemainingQty    INT,
   @nConvertedQty    INT,
   @nTranCount       INT,
   -- Step 4 variables
   @nQTYExp          INT,            -- QTY Expected = ParentSKUQty * BOMQTY
   @nParentSKUQty    INT,            -- Parent SKU qty from Step 3
   @nChildSKUIndex   INT,            -- Current child SKU index (1st, 2nd, etc.)
   @cExpectedChildSKU NVARCHAR(20),  -- Expected Child SKU from BOM/KITDETAIL
   @nBOMParentQty    INT,            -- BILLOFMATERIAL.ParentQTY
   @cDYNBOM          NVARCHAR(1),    -- DYNBOM config flag
   @cLottableCode    NVARCHAR(20),   -- SKU.LottableCode
   @nTotalChildSKU   INT,            -- Total number of child SKUs
   @nChildSKUQty     INT,            -- Child SKU qty to update
   -- Step 5 Lottable variables
   @cLottable01      NVARCHAR(18),
   @cLottable02      NVARCHAR(18),
   @cLottable03      NVARCHAR(18),
   @dLottable04      DATETIME,
   @dLottable05      DATETIME,
   @cLottable06      NVARCHAR(30),
   @cLottable07      NVARCHAR(30),
   @cLottable08      NVARCHAR(30),
   @cLottable09      NVARCHAR(30),
   @cLottable10      NVARCHAR(30),
   @cLottable11      NVARCHAR(30),
   @cLottable12      NVARCHAR(30),
   @dLottable13      DATETIME,
   @dLottable14      DATETIME,
   @dLottable15      DATETIME,
   @nMorePage        INT,
   @bLottableMatch   BIT,            -- Flag to indicate if scanned lottables match KITDETAIL
   @nKitDetailLineNo INT,            -- KITLineNumber for new entry
   -- Field attributes for dynamic lottable screen
   @cFieldAttr01     NVARCHAR(5),
   @cFieldAttr02     NVARCHAR(5),
   @cFieldAttr03     NVARCHAR(5),
   @cFieldAttr04     NVARCHAR(5),
   @cFieldAttr05     NVARCHAR(5),
   @cFieldAttr06     NVARCHAR(5),
   @cFieldAttr07     NVARCHAR(5),
   @cFieldAttr08     NVARCHAR(5),
   @cFieldAttr09     NVARCHAR(5),
   @cFieldAttr10     NVARCHAR(5),
   @cFieldAttr11     NVARCHAR(5),
   @cFieldAttr12     NVARCHAR(5),
   @cFieldAttr13     NVARCHAR(5),
   @cFieldAttr14     NVARCHAR(5),
   @cFieldAttr15     NVARCHAR(5)


-- RDT.RDTMobRec variable
DECLARE
   @nFunc               INT,
   @nScn                INT,
   @nStep               INT,
   @cLangCode           NVARCHAR( 3),
   @nInputKey           INT,
   @nMenu               INT,

   @cStorerGroup        NVARCHAR( 20),
   @cStorerKey          NVARCHAR( 15),
   @cFacility           NVARCHAR( 5),
   @cUserName           NVARCHAR( 18),
   @cID                 NVARCHAR( 18),
   @cSKU                NVARCHAR( 20),
   @cSKUDescr           NVARCHAR( 60),
   @cExtendedUpdateSP   NVARCHAR(20),
   @cExtendedValidateSP NVARCHAR( 20),
   @cBarcode            NVARCHAR( 2000),
   @cDecodeSP           NVARCHAR( 20),
   @cExtendedInfo       NVARCHAR( 20),
   @cExtendedInfoSP     NVARCHAR( 20),

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
   @nFunc               = Func,
   @nScn                = Scn,
   @nStep               = Step,
   @nInputKey           = InputKey,
   @nMenu               = Menu,
   @cLangCode           = Lang_code,
   @cStorerGroup        = StorerGroup,
   @cFacility           = Facility,
   @cUserName           = UserName,
   @cStorerKey          = StorerKey,
   @cID                 = V_ID,
   @cSKU                = V_SKU,
   @nQTY                = V_QTY,
   @cBarcode            = V_Barcode,
   @cExtendedInfoSP     = V_String1,
   @cExtendedValidateSP = V_String2,
   @cExtendedUpdateSP   = V_String3,
   @cDecodeSP           = V_String4,
   @cKitKey             = V_String5,
   @cToLoc              = V_String6,
   @cToID               = V_String7,
   @cParentSKU          = V_String8,
   @cChildSKU           = V_String9,
   @nChildSKUIndex      = ISNULL(TRY_CAST(NULLIF(V_String10, '') AS INT), 1),
   @nParentSKUQty       = ISNULL(TRY_CAST(NULLIF(V_String11, '') AS INT), 0),
   @cDefaultToLoc       = V_String12,
   @cDefaultToQty       = V_String13,
   @cConvertQTYSP       = V_String14,
   @cDYNBOM             = V_String15,
   @cLottable01         = V_Lottable01,
   @cLottable02         = V_Lottable02,
   @cLottable03         = V_Lottable03,
   @dLottable04         = V_Lottable04,
   @dLottable05         = V_Lottable05,
   @cLottable06         = V_Lottable06,
   @cLottable07         = V_Lottable07,
   @cLottable08         = V_Lottable08,
   @cLottable09         = V_Lottable09,
   @cLottable10         = V_Lottable10,
   @cLottable11         = V_Lottable11,
   @cLottable12         = V_Lottable12,
   @dLottable13         = V_Lottable13,
   @dLottable14         = V_Lottable14,
   @dLottable15         = V_Lottable15,
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

IF @nFunc = 1880 -- Kitting Scan
BEGIN
   -- Redirect to respective screen
   IF @nStep = 0 GOTO Step_0   -- Func = Kitting Scan
   IF @nStep = 1 GOTO Step_1   -- Scn = 6880. KitKey
   IF @nStep = 2 GOTO Step_2   -- Scn = 6881. To LOC / To ID
   IF @nStep = 3 GOTO Step_3   -- Scn = 6882. Parent SKU / QTY
   IF @nStep = 4 GOTO Step_4   -- Scn = 6883. Child SKU
   IF @nStep = 5 GOTO Step_5   -- Scn = 3490. Dynamic Lottables
END
RETURN -- Do nothing if incorrect step


/********************************************************************************
Step 0. func = 1880. Menu
********************************************************************************/
Step_0:
BEGIN
   -- Set the entry point
   SET @nScn = 6880
   SET @nStep = 1

   -- Prep next screen var
   SET @cKitKey = ''
   SET @cToLoc = ''
   SET @cToID = ''
   SET @cParentSKU = ''
   SET @cChildSKU = ''
   SET @nQTY = 0

   -- Get storer configure
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

   -- Get default ToLoc from config
   SET @cDefaultToLoc = rdt.RDTGetConfig( @nFunc, 'DefaultToLoc', @cStorerKey)
   IF @cDefaultToLoc = '0'
      SET @cDefaultToLoc = ''

   -- Get default ToQty from config
   SET @cDefaultToQty = rdt.RDTGetConfig( @nFunc, 'DefaultToQty', @cStorerKey)
   IF @cDefaultToQty = '0'
      SET @cDefaultToQty = ''

   -- Get ConvertQTYSP from config
   SET @cConvertQTYSP = rdt.RDTGetConfig( @nFunc, 'ConvertQTYSP', @cStorerKey)
   IF @cConvertQTYSP = '0'
      SET @cConvertQTYSP = ''

   -- Get DYNBOM flag from config (if Y, use KITDETAIL instead of BILLOFMATERIAL)
   SET @cDYNBOM = rdt.RDTGetConfig( @nFunc, 'DYNBOM', @cStorerKey)
   IF @cDYNBOM = '0' OR @cDYNBOM = ''
      SET @cDYNBOM = 'N'

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
   SET @cOutField01 = '' -- KitKey
END
GOTO Quit


/********************************************************************************
Step 1. Scn = 6880. KitKey
   KitKey  (field01, input)

********************************************************************************/
Step_1:
BEGIN
   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      -- Screen mapping
      SET @cKitKey = LEFT(@cInField01, 10)

      -- Validate blank
      IF @cKitKey = '' OR @cKitKey IS NULL
      BEGIN
         SET @nErrNo = 263801
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Scan KitKey
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      -- Validate KitKey exists in KIT table and Status <> 9
      IF NOT EXISTS (
         SELECT 1 FROM dbo.KIT WITH (NOLOCK)
         WHERE KITKey = @cKitKey
         AND   [Status] <> '9'
         AND StorerKey = @cStorerKey
      )
      BEGIN
         SET @nErrNo = 263802
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid KIT Status
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKitKey         NVARCHAR( 10), ' +
               '@cToLoc          NVARCHAR( 10), ' +
               '@cToID           NVARCHAR( 18), ' +
               '@cParentSKU      NVARCHAR( 20), ' +
               '@cChildSKU       NVARCHAR( 20), ' +
               '@nQty            INT          , ' +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_1_Fail
         END
      END

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKitKey         NVARCHAR( 10), ' +
               '@cToLoc          NVARCHAR( 10), ' +
               '@cToID           NVARCHAR( 18), ' +
               '@cParentSKU      NVARCHAR( 20), ' +
               '@cChildSKU       NVARCHAR( 20), ' +
               '@nQty            INT          , ' +
               '@nErrNo         INT           OUTPUT, ' +
               '@cErrMsg        NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               GOTO Step_1_Fail
            END
         END
      END

      -- Prep next screen var
      SET @cOutField01 = '' -- To LOC
      SET @cOutField02 = '' -- To ID

      -- Go to next To LOC/ID screen
      SET @nScn = 6881
      SET @nStep = 2

      -- Extended info
      IF @cExtendedInfoSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
         BEGIN
            SET @cExtendedInfo = ''

            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty, @cExtendedInfo OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nAfterStep      INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKitKey         NVARCHAR( 10), ' +
               '@cToLoc          NVARCHAR( 10), ' +
               '@cToID           NVARCHAR( 18), ' +
               '@cParentSKU      NVARCHAR( 20), ' +
               '@cChildSKU       NVARCHAR( 20), ' +
               '@nQty            INT          , ' +
               '@cExtendedInfo   NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, 1, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty, @cExtendedInfo OUTPUT

            SET @cOutField15 = CASE WHEN ISNULL( @cExtendedInfo, '') <> '' THEN @cExtendedInfo ELSE '' END
         END
      END
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
      SET @cKitKey  = ''
      SET @cOutField01 = '' -- KitKey
   END
END
GOTO Quit


/********************************************************************************
Step 2. Scn = 6881. To LOC / To ID screen
   To LOC  (field01, input)
   To ID   (field02, input)
********************************************************************************/
Step_2:
BEGIN
   -- Clear barcode on entering Step 2
   SET @cBarcode = ''

   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      -- Screen mapping
      SET @cToLoc = @cInField01
      SET @cToID = @cInField02

      -- Apply default ToLoc if empty
      IF (@cToLoc = '' OR @cToLoc IS NULL) AND @cDefaultToLoc <> ''
         SET @cToLoc = @cDefaultToLoc

      -- Validate blank - To LOC (mandatory)
      IF @cToLoc = '' OR @cToLoc IS NULL
      BEGIN
         SET @nErrNo = 263803
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need To Loc
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_2_Fail
      END

      -- Validate To LOC exists, in RDT login facility, and LocationType = 'KIT'
      IF NOT EXISTS (
         SELECT 1 FROM dbo.LOC WITH (NOLOCK)
         WHERE LOC = @cToLoc
         AND   Facility = @cFacility
         AND   LocationType = 'KIT'
      )
      BEGIN
         SET @nErrNo = 263811
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid LOC
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_2_Fail
      END

      -- TO ID is optional, but if scanned, validate RDT Format
      IF @cToID <> '' AND @cToID IS NOT NULL
      BEGIN
         IF RDT.rdtIsValidFormat(@nFunc, @cStorerKey, 'TOID', @cToID) = 0
         BEGIN
            SET @nErrNo = 263814
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid ID format
            EXEC rdt.rdtSetFocusField @nMobile, 2
            GOTO Step_2_Fail
         END
      END

      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKitKey         NVARCHAR( 10), ' +
               '@cToLoc          NVARCHAR( 10), ' +
               '@cToID           NVARCHAR( 18), ' +
               '@cParentSKU      NVARCHAR( 20), ' +
               '@cChildSKU       NVARCHAR( 20), ' +
               '@nQty            INT          , ' +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_2_Fail
         END
      END

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKitKey         NVARCHAR( 10), ' +
               '@cToLoc          NVARCHAR( 10), ' +
               '@cToID           NVARCHAR( 18), ' +
               '@cParentSKU      NVARCHAR( 20), ' +
               '@cChildSKU       NVARCHAR( 20), ' +
               '@nQty            INT          , ' +
               '@nErrNo         INT           OUTPUT, ' +
               '@cErrMsg        NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               GOTO Step_2_Fail
            END
         END
      END

      -- Prep next screen var
      SET @cOutField01 = '' -- Parent SKU
      SET @cOutField02 = '' -- QTY

      -- Go to Parent SKU screen
      SET @nScn = 6882
      SET @nStep = 3

      -- Extended info
      IF @cExtendedInfoSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
         BEGIN
            SET @cExtendedInfo = ''

            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty, @cExtendedInfo OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nAfterStep      INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKitKey         NVARCHAR( 10), ' +
               '@cToLoc          NVARCHAR( 10), ' +
               '@cToID           NVARCHAR( 18), ' +
               '@cParentSKU      NVARCHAR( 20), ' +
               '@cChildSKU       NVARCHAR( 20), ' +
               '@nQty            INT          , ' +
               '@cExtendedInfo   NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, 2, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty, @cExtendedInfo OUTPUT

            SET @cOutField15 = CASE WHEN ISNULL( @cExtendedInfo, '') <> '' THEN @cExtendedInfo ELSE '' END
         END
      END
   END

   IF @nInputKey = 0 -- Esc or No
   BEGIN
      -- Prepare prev screen var
      SET @cKitKey = ''
      SET @cToLoc = ''
      SET @cToID = ''
      SET @cOutField01 = '' -- KitKey

      -- Go back to KitKey screen
      SET @nScn  = 6880
      SET @nStep = 1
   END
   GOTO Quit

   Step_2_Fail:
   BEGIN
      SET @cToLoc = ''
      SET @cToID = ''
      SET @cOutField01 = '' -- To LOC
      SET @cOutField02 = '' -- To ID
   END
END
GOTO Quit


/********************************************************************************
Step 3. Scn = 6882. Parent SKU / QTY screen
   Parent SKU  (field01, input)
   QTY         (field02, input)
********************************************************************************/
Step_3:
BEGIN
   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      -- Screen mapping - use V_Barcode for Parent SKU input
      SET @cQTY = @cInField02
      -- Two-step scan support:
      -- 1. If new barcode scanned, use it (allow user to change SKU)
      -- 2. If no new barcode but ParentSKU already saved, keep previous value
      IF @cBarcode <> '' AND @cBarcode IS NOT NULL
         SET @cParentSKU = LEFT(@cBarcode, 20)  -- Use newly scanned barcode

      -- Decode
      IF @cDecodeSP <> ''
      BEGIN
         -- Standard decode
         IF @cDecodeSP = '1'
         BEGIN
            EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,
               @cUPC      = @cParentSKU   OUTPUT,
               @nErrNo    = @nErrNo       OUTPUT,
               @cErrMsg   = @cErrMsg      OUTPUT

            IF @nErrNo <> 0
            BEGIN
               EXEC rdt.rdtSetFocusField @nMobile, 1
               GOTO Step_3_Fail
            END
         END

         -- Customize decode
         ELSE IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cDecodeSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM(@cDecodeSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cBarcode, ' +
               ' @cParentSKU OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,           ' +
               '@nFunc           INT,           ' +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,           ' +
               '@nInputKey       INT,           ' +
               '@cFacility       NVARCHAR( 5),  ' +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cBarcode        NVARCHAR( 2000), ' +
               '@cParentSKU      NVARCHAR( 20) OUTPUT, ' +
               '@nErrNo          INT            OUTPUT, ' +
               '@cErrMsg         NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cBarcode,
               @cParentSKU OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               EXEC rdt.rdtSetFocusField @nMobile, 1
               GOTO Step_3_Fail
            END
         END
      END

      -- Validate blank - Parent SKU
      IF @cParentSKU = '' OR @cParentSKU IS NULL
      BEGIN
         SET @nErrNo = 263805
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU is required
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_3_Fail
      END

      -- Validate Parent SKU exists in KITDETAIL where Type = 'T'
      IF NOT EXISTS (
         SELECT 1 FROM dbo.KITDETAIL WITH (NOLOCK)
         WHERE KITKey = @cKitKey
         AND   SKU = @cParentSKU
         AND   [Type] = 'T'
      )
      BEGIN
         SET @nErrNo = 263815
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU not in Kit
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_3_Fail
      END

      -- Get ExpectedQty and current Qty from KITDETAIL
      SET @nExpectedQty = 0
      SET @nKitDetailQty = 0
      SELECT @nExpectedQty = ISNULL(ExpectedQty, 0),
             @nKitDetailQty = ISNULL(Qty, 0)
      FROM dbo.KITDETAIL WITH (NOLOCK)
      WHERE KITKey = @cKitKey
      AND   SKU = @cParentSKU
      AND   [Type] = 'T'

      SET @nRemainingQty = @nExpectedQty - @nKitDetailQty

      -- Apply default ToQty if QTY is empty
      IF (@cQTY = '' OR @cQTY IS NULL) AND @cDefaultToQty <> ''
         SET @cQTY = @cDefaultToQty

      -- Validate blank - QTY
      IF @cQTY = '' OR @cQTY IS NULL
      BEGIN
         -- SKU validated, stay on screen waiting for QTY input
         SET @cOutField01 = @cParentSKU   -- Keep scanned SKU
         SET @cOutField02 = ''             -- QTY awaiting input
         EXEC rdt.rdtSetFocusField @nMobile, 2  -- Move focus to QTY field
         GOTO Quit   -- Stay on current screen
      END

      -- Validate QTY format (numeric, non-negative, non-zero, decimal)
      IF @cQTY <> '' AND RDT.rdtIsValidQTY( @cQTY, 1) = 0
      BEGIN
         SET @nErrNo = 263807
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid QTY
         EXEC rdt.rdtSetFocusField @nMobile, 2
         GOTO Step_3_Fail
      END

      SET @nQTY = ISNULL(TRY_CAST(@cQTY AS INT), 0)

      -- ConvertQTYSP support - convert input qty to actual qty
      SET @nConvertedQty = @nQTY
      IF @cConvertQTYSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cConvertQTYSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM(@cConvertQTYSP) +
               ' @cParentSKU, @nQTY, @cStorerkey, @nConvertedQty OUTPUT'
            SET @cSQLParam =
               '@cParentSKU      NVARCHAR( 20), ' +
               '@nQTY            INT,           ' +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@nConvertedQty   INT OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @cParentSKU, @nQTY, @cStorerkey, @nConvertedQty OUTPUT
         END
      END

      -- Validate QTY does not exceed remaining qty
      IF @nConvertedQty > @nRemainingQty
      BEGIN
         SET @nErrNo = 263816
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --QTY cannot exceed expected qty
         EXEC rdt.rdtSetFocusField @nMobile, 2
         GOTO Step_3_Fail
      END

      -- Store converted qty for later use
      SET @nQTY = @nConvertedQty

      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKitKey         NVARCHAR( 10), ' +
               '@cToLoc          NVARCHAR( 10), ' +
               '@cToID           NVARCHAR( 18), ' +
               '@cParentSKU      NVARCHAR( 20), ' +
               '@cChildSKU       NVARCHAR( 20), ' +
               '@nQty            INT          , ' +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_3_Fail
         END
      END

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKitKey         NVARCHAR( 10), ' +
               '@cToLoc          NVARCHAR( 10), ' +
               '@cToID           NVARCHAR( 18), ' +
               '@cParentSKU      NVARCHAR( 20), ' +
               '@cChildSKU       NVARCHAR( 20), ' +
               '@nQty            INT          , ' +
               '@nErrNo         INT           OUTPUT, ' +
               '@cErrMsg        NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               GOTO Step_3_Fail
            END
         END
      END

      -- Store Parent SKU qty for Step 4
      SET @nParentSKUQty = @nQTY
      SET @nChildSKUIndex = 1

      -- Get first Child SKU from BOM or KITDETAIL
      SET @cExpectedChildSKU = ''
      SET @nBOMQty = 0
      SET @nBOMParentQty = 1

      IF @cDYNBOM = 'Y'
      BEGIN
         -- DYNBOM mode: Get from KITDETAIL sorted by KITLineNumber
         SELECT TOP 1
            @cExpectedChildSKU = SKU,
            @nBOMQty = ISNULL(TRY_CAST(Channel AS INT), 1)
         FROM dbo.KITDETAIL WITH (NOLOCK)
         WHERE KITKey = @cKitKey
           AND StorerKey = @cStorerKey
           AND [Type] = 'F'
         ORDER BY KITLineNumber

         -- Get total child SKU count
         SELECT @nTotalChildSKU = COUNT(*)
         FROM dbo.KITDETAIL WITH (NOLOCK)
         WHERE KITKey = @cKitKey
           AND StorerKey = @cStorerKey
           AND [Type] = 'F'
      END
      ELSE
      BEGIN
         -- Standard mode: Get from BILLOFMATERIAL sorted by SEQUENCE
         SELECT TOP 1
            @cExpectedChildSKU = COMPONENTSKU,
            @nBOMQty = CASE WHEN ISNULL(ParentQTY, 1) = 1 THEN QTY
                            ELSE QTY / ParentQTY END,
            @nBOMParentQty = ISNULL(ParentQTY, 1)
         FROM dbo.BILLOFMATERIAL WITH (NOLOCK)
         WHERE SKU = @cParentSKU
           AND StorerKey = @cStorerKey
           AND BOMONLY = 'Y'
         ORDER BY SEQUENCE

         -- Get total child SKU count
         SELECT @nTotalChildSKU = COUNT(*)
         FROM dbo.BILLOFMATERIAL WITH (NOLOCK)
         WHERE SKU = @cParentSKU
           AND StorerKey = @cStorerKey
           AND BOMONLY = 'Y'
      END

      -- Calculate QTY Expected
      SET @nQTYExp = @nParentSKUQty * @nBOMQty

      -- Get Parent SKU description
      SET @cSKUDescr = ''
      IF @cParentSKU <> ''
      BEGIN
         SELECT @cSKUDescr = ISNULL(DESCR, '')
         FROM dbo.SKU WITH (NOLOCK)
         WHERE SKU = @cParentSKU
           AND StorerKey = @cStorerKey
      END

      -- Get Child SKU description
      SET @cChildSKUDescr = ''
      IF @cExpectedChildSKU <> ''
      BEGIN
         SELECT @cChildSKUDescr = ISNULL(DESCR, '')
         FROM dbo.SKU WITH (NOLOCK)
         WHERE SKU = @cExpectedChildSKU
           AND StorerKey = @cStorerKey
      END

      -- Prep next screen var - Child SKU screen
      SET @cOutField01 = @cParentSKU                                  -- Parent SKU
      SET @cOutField02 = @cSKUDescr                                   -- Parent SKU Descr
      SET @cOutField03 = @cExpectedChildSKU                           -- Child SKU (display)
      SET @cOutField04 = @cChildSKUDescr                              -- Child SKU Descr
      SET @cOutField05 = ''                                           -- Child SKU (input)
      SET @cOutField06 = CAST(@nQTYExp AS NVARCHAR(10))               -- QTY Exp
      SET @cOutField07 = CAST(@nBOMQty AS NVARCHAR(10))               -- BOM QTY
      SET @cOutField08 = ''                                           -- QTY (input)

      -- Clear barcode before entering Step 4
      SET @cBarcode = ''

      -- Go to Child SKU screen
      SET @nScn = 6883
      SET @nStep = 4

      -- Extended info
      IF @cExtendedInfoSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
         BEGIN
            SET @cExtendedInfo = ''

            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty, @cExtendedInfo OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nAfterStep      INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKitKey         NVARCHAR( 10), ' +
               '@cToLoc          NVARCHAR( 10), ' +
               '@cToID           NVARCHAR( 18), ' +
               '@cParentSKU      NVARCHAR( 20), ' +
               '@cChildSKU       NVARCHAR( 20), ' +
               '@nQty            INT          , ' +
               '@cExtendedInfo   NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, 3, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty, @cExtendedInfo OUTPUT

            SET @cOutField15 = CASE WHEN ISNULL( @cExtendedInfo, '') <> '' THEN @cExtendedInfo ELSE '' END
         END
      END
   END

   IF @nInputKey = 0 -- Esc or No
   BEGIN
      -- Prepare prev screen var
      SET @cBarcode = ''
      SET @cToLoc = ''
      SET @cToID = ''
      SET @cParentSKU = ''
      SET @nQTY = 0
      SET @cOutField01 = '' -- To LOC
      SET @cOutField02 = '' -- To ID
      EXEC rdt.rdtSetFocusField @nMobile, 1

      -- Go back to To LOC/ID screen
      SET @nScn  = 6881
      SET @nStep = 2
   END
   GOTO Quit

   Step_3_Fail:
   BEGIN
      SET @cParentSKU = ''
      SET @nQTY = 0
      SET @cOutField01 = '' -- Parent SKU
      SET @cOutField02 = '' -- QTY
   END
END
GOTO Quit


/********************************************************************************
Step 4. Scn = 6883. Child SKU screen (Loop)
   Parent SKU       (field01, display)
   Parent SKU Descr (field02, display)
   Child SKU        (field03, display) - Expected child SKU from BOM
   Child SKU Descr  (field04, display)
   Child SKU        (field05, input)
   QTY Exp          (field06, display)
   BOM QTY          (field07, display)
   QTY              (field08, input)
********************************************************************************/
Step_4:
BEGIN
   -- Restore state from MOBREC
   SET @cExpectedChildSKU = @cOutField03
   SET @nQTYExp = ISNULL(TRY_CAST(NULLIF(@cOutField06, '') AS INT), 0)
   SET @nBOMQty = ISNULL(TRY_CAST(NULLIF(@cOutField07, '') AS INT), 0)

   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      -- Screen mapping
      SET @cQTY = @cInField08

      -- Two-step scan support for Child SKU (similar to Step 3)
      IF @cBarcode <> '' AND @cBarcode IS NOT NULL
         SET @cChildSKU = LEFT(@cBarcode, 20)

      -- Decode Child SKU
      IF @cDecodeSP <> '' AND @cChildSKU <> ''
      BEGIN
         IF @cDecodeSP = '1'
         BEGIN
            EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,
               @cUPC      = @cChildSKU   OUTPUT,
               @nErrNo    = @nErrNo      OUTPUT,
               @cErrMsg   = @cErrMsg     OUTPUT

            IF @nErrNo <> 0
            BEGIN
               EXEC rdt.rdtSetFocusField @nMobile, 5
               GOTO Step_4_Fail
            END
         END
         ELSE IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cDecodeSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM(@cDecodeSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cBarcode, ' +
               ' @cChildSKU OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,           ' +
               '@nFunc           INT,           ' +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,           ' +
               '@nInputKey       INT,           ' +
               '@cFacility       NVARCHAR( 5),  ' +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cBarcode        NVARCHAR( 2000), ' +
               '@cChildSKU       NVARCHAR( 20) OUTPUT, ' +
               '@nErrNo          INT            OUTPUT, ' +
               '@cErrMsg         NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cBarcode,
               @cChildSKU OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               EXEC rdt.rdtSetFocusField @nMobile, 5
               GOTO Step_4_Fail
            END
         END
      END

      -- Validate blank - Child SKU
      IF @cChildSKU = '' OR @cChildSKU IS NULL
      BEGIN
         SET @nErrNo = 263808
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU is required
         EXEC rdt.rdtSetFocusField @nMobile, 5
         GOTO Step_4_Fail
      END

      -- Validate Child SKU exists in KITDETAIL (Type = 'F')
      IF NOT EXISTS (
         SELECT 1 FROM dbo.KITDETAIL WITH (NOLOCK)
         WHERE KITKey = @cKitKey
           AND SKU = @cChildSKU
           AND [Type] = 'F'
           AND StorerKey = @cStorerKey
      )
      BEGIN
         SET @nErrNo = 263817
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU not in Kit
         EXEC rdt.rdtSetFocusField @nMobile, 5
         GOTO Step_4_Fail
      END

      -- If QTY is empty, stay on screen and move cursor to QTY field
      IF @cQTY = '' OR @cQTY IS NULL
      BEGIN
         SET @cOutField03 = @cExpectedChildSKU
         SET @cOutField05 = @cChildSKU
         SET @cOutField08 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 8
         GOTO Quit
      END

      -- Validate QTY format
      IF RDT.rdtIsValidQTY( @cQTY, 0) = 0
      BEGIN
         SET @nErrNo = 263810
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid QTY
         EXEC rdt.rdtSetFocusField @nMobile, 8
         GOTO Step_4_Fail
      END

      SET @nQTY = ISNULL(TRY_CAST(@cQTY AS INT), 0)

      -- ConvertQTYSP support
      SET @nConvertedQty = @nQTY
      IF @cConvertQTYSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cConvertQTYSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM(@cConvertQTYSP) +
               ' @cChildSKU, @nQTY, @cStorerkey, @nConvertedQty OUTPUT'
            SET @cSQLParam =
               '@cChildSKU       NVARCHAR( 20), ' +
               '@nQTY            INT,           ' +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@nConvertedQty   INT OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @cChildSKU, @nQTY, @cStorerkey, @nConvertedQty OUTPUT
         END
      END
      SET @nChildSKUQty = @nConvertedQty

      -- QTY validation based on Child SKU index
      IF @nChildSKUIndex = 1
      BEGIN
         -- First child SKU: qty <= QTYExp and must be multiple of BOMQTY
         IF @nChildSKUQty > @nQTYExp
         BEGIN
            SET @nErrNo = 263818
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --QTY cannot exceed expected qty
            EXEC rdt.rdtSetFocusField @nMobile, 8
            GOTO Step_4_Fail
         END

         -- Check if qty is multiple of BOMQTY
         IF @nBOMQty > 0 AND (@nChildSKUQty % @nBOMQty) <> 0
         BEGIN
            SET @nErrNo = 263810
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid QTY
            EXEC rdt.rdtSetFocusField @nMobile, 8
            GOTO Step_4_Fail
         END

         -- If qty < QTYExp, update ParentSKUQty
         IF @nChildSKUQty < @nQTYExp AND @nBOMQty > 0
         BEGIN
            SET @nParentSKUQty = @nChildSKUQty / @nBOMQty
         END
      END
      ELSE
      BEGIN
         -- Subsequent child SKUs: qty must equal QTYExp
         IF @nChildSKUQty <> @nQTYExp
         BEGIN
            SET @nErrNo = 263819
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --QTY mismatch
            EXEC rdt.rdtSetFocusField @nMobile, 8
            GOTO Step_4_Fail
         END
      END

      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKitKey         NVARCHAR( 10), ' +
               '@cToLoc          NVARCHAR( 10), ' +
               '@cToID           NVARCHAR( 18), ' +
               '@cParentSKU      NVARCHAR( 20), ' +
               '@cChildSKU       NVARCHAR( 20), ' +
               '@nQty            INT          , ' +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nChildSKUQty, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_4_Fail
         END
      END

      -- Check if Child SKU has LottableCode that requires Lottable screen
      SET @cLottableCode = ''
      SELECT @cLottableCode = ISNULL(LottableCode, '')
      FROM dbo.SKU WITH (NOLOCK)
      WHERE SKU = @cChildSKU AND StorerKey = @cStorerKey

      IF @cLottableCode <> '' AND EXISTS (
         SELECT 1 FROM rdt.RDTLOTTABLECODE WITH (NOLOCK)
         WHERE LottableCode = @cLottableCode AND Function_ID = @nFunc
      )
      BEGIN
         -- Navigate to Lottable screen (Step 5)
         -- Populate dynamic lottable fields
         EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cChildSKU, @cLottableCode, 'CAPTURE', 'POPULATE', 5, 1,
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
            @nMorePage   OUTPUT,
            @nErrNo      OUTPUT,
            @cErrMsg     OUTPUT,
            @cKitKey,
            @nFunc
         IF @nErrNo <> 0
            GOTO Quit

         IF @nMorePage = 1 -- Yes
         BEGIN
            -- Go to dynamic lottable screen
            SET @nScn = 3990
            SET @nStep = 5
            GOTO QUIT
         END
      END

      -- Begin transaction for updates
      SET @nTranCount = @@TRANCOUNT
      BEGIN TRAN
      SAVE TRAN rdtfnc_KittingScan

      -- Update KITDETAIL for Parent SKU (Type = 'T')
      UPDATE dbo.KITDETAIL
      SET LOC = @cToLoc,
          ID = @cToID,
          QTY = QTY + @nParentSKUQty
      WHERE KITKey = @cKitKey
        AND SKU = @cParentSKU
        AND [Type] = 'T'
        AND StorerKey = @cStorerKey

      -- Update KITDETAIL for Child SKU (Type = 'F')
      UPDATE dbo.KITDETAIL
      SET LOC = @cToLoc,
          ID = @cToID,
          QTY = QTY + @nChildSKUQty
      WHERE KITKey = @cKitKey
        AND SKU = @cChildSKU
        AND [Type] = 'F'
        AND StorerKey = @cStorerKey

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKitKey         NVARCHAR( 10), ' +
               '@cToLoc          NVARCHAR( 10), ' +
               '@cToID           NVARCHAR( 18), ' +
               '@cParentSKU      NVARCHAR( 20), ' +
               '@cChildSKU       NVARCHAR( 20), ' +
               '@nQty            INT          , ' +
               '@nErrNo         INT           OUTPUT, ' +
               '@cErrMsg        NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nChildSKUQty,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               ROLLBACK TRAN rdtfnc_KittingScan
               WHILE @@TRANCOUNT > @nTranCount
                  COMMIT TRAN
               GOTO Step_4_Fail
            END
         END
      END

      COMMIT TRAN rdtfnc_KittingScan
      WHILE @@TRANCOUNT > @nTranCount
         COMMIT TRAN

      -- Move to next Child SKU
      SET @nChildSKUIndex = @nChildSKUIndex + 1

      -- Get next Child SKU from BOM or KITDETAIL
      SET @cExpectedChildSKU = ''
      SET @nBOMQty = 0

      IF @cDYNBOM = 'Y'
      BEGIN
         -- DYNBOM mode: Get next from KITDETAIL
         SELECT
            @cExpectedChildSKU = SKU,
            @nBOMQty = ISNULL(TRY_CAST(Channel AS INT), 1)
         FROM dbo.KITDETAIL WITH (NOLOCK)
         WHERE KITKey = @cKitKey
           AND StorerKey = @cStorerKey
           AND [Type] = 'F'
         ORDER BY KITLineNumber
         OFFSET (@nChildSKUIndex - 1) ROWS FETCH NEXT 1 ROWS ONLY
      END
      ELSE
      BEGIN
         -- Standard mode: Get next from BILLOFMATERIAL
         SELECT
            @cExpectedChildSKU = COMPONENTSKU,
            @nBOMQty = CASE WHEN ISNULL(ParentQTY, 1) = 1 THEN QTY
                            ELSE QTY / ParentQTY END
         FROM dbo.BILLOFMATERIAL WITH (NOLOCK)
         WHERE SKU = @cParentSKU
           AND StorerKey = @cStorerKey
           AND BOMONLY = 'Y'
         ORDER BY SEQUENCE
         OFFSET (@nChildSKUIndex - 1) ROWS FETCH NEXT 1 ROWS ONLY
      END

      -- Check if all Child SKUs scanned
      IF @cExpectedChildSKU = ''
      BEGIN
         -- All done, go back to Parent SKU screen for next parent
         SET @cParentSKU = ''
         SET @cChildSKU = ''
         SET @nChildSKUIndex = 1
         SET @cBarcode = ''
         SET @cOutField01 = '' -- Parent SKU
         SET @cOutField02 = '' -- QTY
         SET @nScn  = 6882
         SET @nStep = 3
         GOTO Quit
      END

      -- Calculate new QTY Expected
      SET @nQTYExp = @nParentSKUQty * @nBOMQty

      -- Get Parent SKU description (for display on next screen)
      SET @cSKUDescr = ''
      SELECT @cSKUDescr = ISNULL(DESCR, '')
      FROM dbo.SKU WITH (NOLOCK)
      WHERE SKU = @cParentSKU AND StorerKey = @cStorerKey

      -- Get Child SKU description
      SET @cChildSKUDescr = ''
      SELECT @cChildSKUDescr = ISNULL(DESCR, '')
      FROM dbo.SKU WITH (NOLOCK)
      WHERE SKU = @cExpectedChildSKU AND StorerKey = @cStorerKey

      -- Prep next screen var - Next Child SKU
      SET @cOutField01 = @cParentSKU
      SET @cOutField02 = @cSKUDescr
      SET @cOutField03 = @cExpectedChildSKU
      SET @cOutField04 = @cChildSKUDescr
      SET @cOutField05 = ''
      SET @cOutField06 = CAST(@nQTYExp AS NVARCHAR(10))
      SET @cOutField07 = CAST(@nBOMQty AS NVARCHAR(10))
      SET @cOutField08 = ''
      SET @cChildSKU = ''

      SET @nScn = 6883
      SET @nStep = 4

      -- Extended info
      IF @cExtendedInfoSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
         BEGIN
            SET @cExtendedInfo = ''

            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cChildSKU, @nQty, @cExtendedInfo OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nAfterStep      INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKitKey         NVARCHAR( 10), ' +
               '@cToLoc          NVARCHAR( 10), ' +
               '@cToID           NVARCHAR( 18), ' +
               '@cParentSKU      NVARCHAR( 20), ' +
               '@cChildSKU       NVARCHAR( 20), ' +
               '@nQty            INT          , ' +
               '@cExtendedInfo   NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, 4, @nStep, @nInputKey, @cStorerkey, @cKitKey, @cToLoc, @cToID, @cParentSKU, @cExpectedChildSKU, @nChildSKUQty, @cExtendedInfo OUTPUT

            SET @cOutField15 = CASE WHEN ISNULL( @cExtendedInfo, '') <> '' THEN @cExtendedInfo ELSE '' END
         END
      END
   END

   IF @nInputKey = 0 -- Esc or No
   BEGIN
      -- Prepare prev screen var
      SET @cBarcode = ''
      SET @cParentSKU = ''
      SET @cChildSKU = ''
      SET @nQTY = 0
      SET @nChildSKUIndex = 1
      SET @cOutField01 = '' -- Parent SKU
      SET @cOutField02 = '' -- QTY
      EXEC rdt.rdtSetFocusField @nMobile, 1

      -- Go back to Parent SKU screen
      SET @nScn  = 6882
      SET @nStep = 3
   END
   GOTO Quit

   Step_4_Fail:
   BEGIN
      SET @cChildSKU = ''
      SET @cOutField05 = '' -- Child SKU input
      SET @cOutField08 = '' -- QTY input
   END
END
GOTO Quit


/********************************************************************************
Step 5. Scn = 3490. Dynamic Lottables
   Label01    (field01)
   Lottable01 (field02, input)
   Label02    (field03)
   Lottable02 (field04, input)
   Label03    (field05)
   Lottable03 (field06, input)
   Label04    (field07)
   Lottable04 (field08, input)
   Label05    (field09)
   Lottable05 (field10, input)
********************************************************************************/
Step_5:
BEGIN
   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      -- Validate dynamic lottables
      EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cChildSKU, @cLottableCode, 'CAPTURE', 'CHECK', 5, 1,
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
         @nMorePage   OUTPUT,
         @nErrNo      OUTPUT,
         @cErrMsg     OUTPUT,
         @cKitKey,
         @nFunc

      IF @nErrNo <> 0
         GOTO Step_5_Fail

      -- If more pages, stay on lottable screen
      IF @nMorePage = 1
         GOTO Quit

      -- Check if scanned lottables match existing KITDETAIL entry
      -- Only compare lottables that are configured as Visible in RDTLOTTABLECODE
      DECLARE @nFuncForLottable INT = @nFunc
      -- If function specific lottablecode not setup, use generic one (Function_ID = 0)
      IF NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK)
                     WHERE LottableCode = @cLottableCode AND Function_ID = @nFunc AND StorerKey = @cStorerKey)
         SET @nFuncForLottable = 0

      SET @bLottableMatch = 0
      IF EXISTS (
         SELECT 1 FROM dbo.KITDETAIL KD WITH (NOLOCK)
         WHERE KD.KITKey = @cKitKey
           AND KD.SKU = @cChildSKU
           AND KD.[Type] = 'F'
           AND KD.StorerKey = @cStorerKey
           -- Only compare configured lottables (Visible = 1)
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 1 AND Visible = '1')
                OR ISNULL(KD.Lottable01, '') = ISNULL(@cLottable01, ''))
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 2 AND Visible = '1')
                OR ISNULL(KD.Lottable02, '') = ISNULL(@cLottable02, ''))
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 3 AND Visible = '1')
                OR ISNULL(KD.Lottable03, '') = ISNULL(@cLottable03, ''))
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 4 AND Visible = '1')
                OR ISNULL(KD.Lottable04, CAST('19000101' AS DATETIME)) = ISNULL(@dLottable04, CAST('19000101' AS DATETIME)))
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 5 AND Visible = '1')
                OR ISNULL(KD.Lottable05, CAST('19000101' AS DATETIME)) = ISNULL(@dLottable05, CAST('19000101' AS DATETIME)))
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 6 AND Visible = '1')
                OR ISNULL(KD.Lottable06, '') = ISNULL(@cLottable06, ''))
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 7 AND Visible = '1')
                OR ISNULL(KD.Lottable07, '') = ISNULL(@cLottable07, ''))
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 8 AND Visible = '1')
                OR ISNULL(KD.Lottable08, '') = ISNULL(@cLottable08, ''))
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 9 AND Visible = '1')
                OR ISNULL(KD.Lottable09, '') = ISNULL(@cLottable09, ''))
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 10 AND Visible = '1')
                OR ISNULL(KD.Lottable10, '') = ISNULL(@cLottable10, ''))
      )
      BEGIN
         SET @bLottableMatch = 1
      END

      -- Begin transaction for updates
      SET @nTranCount = @@TRANCOUNT
      BEGIN TRAN
      SAVE TRAN rdtfnc_KittingScan

      IF @bLottableMatch = 1
      BEGIN
         -- Lottables match: Add qty to existing entry
         -- Use same dynamic lottable matching logic
         UPDATE dbo.KITDETAIL
         SET LOC = @cToLoc,
             ID = @cToID,
             QTY = QTY + @nChildSKUQty
         WHERE KITKey = @cKitKey
           AND SKU = @cChildSKU
           AND [Type] = 'F'
           AND StorerKey = @cStorerKey
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 1 AND Visible = '1')
                OR ISNULL(Lottable01, '') = ISNULL(@cLottable01, ''))
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 2 AND Visible = '1')
                OR ISNULL(Lottable02, '') = ISNULL(@cLottable02, ''))
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 3 AND Visible = '1')
                OR ISNULL(Lottable03, '') = ISNULL(@cLottable03, ''))
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 4 AND Visible = '1')
                OR ISNULL(Lottable04, CAST('19000101' AS DATETIME)) = ISNULL(@dLottable04, CAST('19000101' AS DATETIME)))
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 5 AND Visible = '1')
                OR ISNULL(Lottable05, CAST('19000101' AS DATETIME)) = ISNULL(@dLottable05, CAST('19000101' AS DATETIME)))
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 6 AND Visible = '1')
                OR ISNULL(Lottable06, '') = ISNULL(@cLottable06, ''))
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 7 AND Visible = '1')
                OR ISNULL(Lottable07, '') = ISNULL(@cLottable07, ''))
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 8 AND Visible = '1')
                OR ISNULL(Lottable08, '') = ISNULL(@cLottable08, ''))
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 9 AND Visible = '1')
                OR ISNULL(Lottable09, '') = ISNULL(@cLottable09, ''))
           AND (NOT EXISTS (SELECT 1 FROM rdt.rdtLottableCode WITH (NOLOCK) WHERE LottableCode = @cLottableCode AND Function_ID = @nFuncForLottable AND StorerKey = @cStorerKey AND LottableNo = 10 AND Visible = '1')
                OR ISNULL(Lottable10, '') = ISNULL(@cLottable10, ''))
      END
      ELSE
      BEGIN
         -- Lottables don't match: Create new entry
         -- Get next KITLineNumber
         SELECT @nKitDetailLineNo = ISNULL(MAX(KITLineNumber), 0) + 1
         FROM dbo.KITDETAIL WITH (NOLOCK)
         WHERE KITKey = @cKitKey

         INSERT INTO dbo.KITDETAIL (
            KITKey, StorerKey, KITLineNumber, SKU, [Type], QTY, LOC, ID,
            Lottable01, Lottable02, Lottable03, Lottable04, Lottable05,
            Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
            AddDate, AddWho, EditDate, EditWho
         )
         VALUES (
            @cKitKey, @cStorerKey, @nKitDetailLineNo, @cChildSKU, 'F', @nChildSKUQty, @cToLoc, @cToID,
            @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
            @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
            GETDATE(), @cUserName, GETDATE(), @cUserName
         )
      END

      -- Update KITDETAIL for Parent SKU (Type = 'T')
      UPDATE dbo.KITDETAIL
      SET LOC = @cToLoc,
          ID = @cToID,
          QTY = QTY + @nParentSKUQty
      WHERE KITKey = @cKitKey
        AND SKU = @cParentSKU
        AND [Type] = 'T'
        AND StorerKey = @cStorerKey

      -- Check if current Lottable04 is the earliest expiry date among all child SKUs
      -- If yes, copy all lottable values from this child SKU to parent SKU
      IF @dLottable04 IS NOT NULL
      BEGIN
         DECLARE @dMinExpiryDate DATETIME
         SELECT @dMinExpiryDate = MIN(Lottable04)
         FROM dbo.KITDETAIL WITH (NOLOCK)
         WHERE KITKey = @cKitKey
           AND StorerKey = @cStorerKey
           AND [Type] = 'F'
           AND Lottable04 IS NOT NULL

         -- If current child's expiry date is the earliest, update parent SKU with all lottables
         IF @dMinExpiryDate IS NOT NULL AND @dLottable04 <= @dMinExpiryDate
         BEGIN
            UPDATE dbo.KITDETAIL
            SET Lottable01 = @cLottable01,
                Lottable02 = @cLottable02,
                Lottable03 = @cLottable03,
                Lottable04 = @dLottable04,
                Lottable05 = @dLottable05,
                Lottable06 = @cLottable06,
                Lottable07 = @cLottable07,
                Lottable08 = @cLottable08,
                Lottable09 = @cLottable09,
                Lottable10 = @cLottable10,
                EditDate = GETDATE(),
                EditWho = @cUserName
            WHERE KITKey = @cKitKey
              AND SKU = @cParentSKU
              AND [Type] = 'T'
              AND StorerKey = @cStorerKey
         END
      END

      COMMIT TRAN rdtfnc_KittingScan
      WHILE @@TRANCOUNT > @nTranCount
         COMMIT TRAN

      -- Clear lottable values for next scan
      SET @cLottable01 = ''
      SET @cLottable02 = ''
      SET @cLottable03 = ''
      SET @dLottable04 = NULL
      SET @dLottable05 = NULL
      SET @cLottable06 = ''
      SET @cLottable07 = ''
      SET @cLottable08 = ''
      SET @cLottable09 = ''
      SET @cLottable10 = ''

      -- Move to next Child SKU (same logic as Step_4)
      SET @nChildSKUIndex = @nChildSKUIndex + 1

      -- Get next Child SKU from BOM or KITDETAIL
      SET @cExpectedChildSKU = ''
      SET @nBOMQty = 0

      IF @cDYNBOM = 'Y'
      BEGIN
         SELECT
            @cExpectedChildSKU = SKU,
            @nBOMQty = ISNULL(TRY_CAST(Channel AS INT), 1)
         FROM dbo.KITDETAIL WITH (NOLOCK)
         WHERE KITKey = @cKitKey
           AND StorerKey = @cStorerKey
           AND [Type] = 'F'
         ORDER BY KITLineNumber
         OFFSET (@nChildSKUIndex - 1) ROWS FETCH NEXT 1 ROWS ONLY
      END
      ELSE
      BEGIN
         SELECT
            @cExpectedChildSKU = COMPONENTSKU,
            @nBOMQty = CASE WHEN ISNULL(ParentQTY, 1) = 1 THEN QTY
                            ELSE QTY / ParentQTY END
         FROM dbo.BILLOFMATERIAL WITH (NOLOCK)
         WHERE SKU = @cParentSKU
           AND StorerKey = @cStorerKey
           AND BOMONLY = 'Y'
         ORDER BY SEQUENCE
         OFFSET (@nChildSKUIndex - 1) ROWS FETCH NEXT 1 ROWS ONLY
      END

      -- Check if all Child SKUs scanned
      IF @cExpectedChildSKU = ''
      BEGIN
         -- All done, go back to Parent SKU screen for next parent
         SET @cParentSKU = ''
         SET @cChildSKU = ''
         SET @nChildSKUIndex = 1
         SET @cOutField01 = ''
         SET @cOutField02 = ''
         SET @nScn  = 6882
         SET @nStep = 3
         GOTO Quit
      END

      -- Calculate new QTY Expected
      SET @nQTYExp = @nParentSKUQty * @nBOMQty

      -- Get Child SKU description
      SET @cChildSKUDescr = ''
      SELECT @cChildSKUDescr = ISNULL(DESCR, '')
      FROM dbo.SKU WITH (NOLOCK)
      WHERE SKU = @cExpectedChildSKU AND StorerKey = @cStorerKey

      -- Get Parent SKU description
      SET @cSKUDescr = ''
      SELECT @cSKUDescr = ISNULL(DESCR, '')
      FROM dbo.SKU WITH (NOLOCK)
      WHERE SKU = @cParentSKU AND StorerKey = @cStorerKey

      -- Go back to Child SKU screen for next child
      SET @cOutField01 = @cParentSKU
      SET @cOutField02 = @cSKUDescr
      SET @cOutField03 = @cExpectedChildSKU
      SET @cOutField04 = @cChildSKUDescr
      SET @cOutField05 = ''
      SET @cOutField06 = CAST(@nQTYExp AS NVARCHAR(10))
      SET @cOutField07 = CAST(@nBOMQty AS NVARCHAR(10))
      SET @cOutField08 = ''
      SET @cChildSKU = ''

      SET @nScn = 6883
      SET @nStep = 4
   END

   IF @nInputKey = 0 -- Esc or No
   BEGIN
      -- Go back to previous lottable page or Child SKU screen
      EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cChildSKU, @cLottableCode, 'CAPTURE', 'POPULATE', 5, 1,
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
         @nMorePage   OUTPUT,
         @nErrNo      OUTPUT,
         @cErrMsg     OUTPUT,
         @cKitKey,
         @nFunc

      IF @nMorePage = 1
         GOTO Quit

      -- Clear barcode before returning to Step 4
      SET @cBarcode = ''

      -- Go back to Child SKU screen
      SET @cOutField01 = @cParentSKU
      SET @cOutField03 = @cExpectedChildSKU
      SET @cOutField05 = ''
      SET @cOutField06 = CAST(@nQTYExp AS NVARCHAR(10))
      SET @cOutField07 = CAST(@nBOMQty AS NVARCHAR(10))
      SET @cOutField08 = ''
      SET @nScn  = 6883
      SET @nStep = 4
   END
   GOTO Quit

   Step_5_Fail:
   BEGIN
      -- Stay on lottable screen
      GOTO QUIT
   END
END
GOTO Quit


/********************************************************************************
Quit. Update back to I/O table, ready to be pick up by JBOSS
********************************************************************************/
Quit:
BEGIN
   UPDATE rdt.RDTMOBREC WITH (ROWLOCK) SET
      EditDate       = GETDATE(),
      ErrMsg         = @cErrMsg,
      Func           = @nFunc,
      Step           = @nStep,
      Scn            = @nScn,
      Facility       = @cFacility,
      StorerKey      = @cStorerKey,
      V_ID           = @cID,
      V_SKU          = @cSKU,
      V_QTY          = @nQty,
      V_Barcode      = @cBarcode,
      V_String1      = @cExtendedInfoSP,
      V_String2      = @cExtendedValidateSP,
      V_String3      = @cExtendedUpdateSP,
      V_String4      = @cDecodeSP,
      V_String5      = @cKitKey,
      V_String6      = @cToLoc,
      V_String7      = @cToID,
      V_String8      = @cParentSKU,
      V_String9      = @cChildSKU,
      V_String10     = CAST(@nChildSKUIndex AS NVARCHAR(10)),
      V_String11     = CAST(@nParentSKUQty AS NVARCHAR(10)),
      V_String12     = @cDefaultToLoc,
      V_String13     = @cDefaultToQty,
      V_String14     = @cConvertQTYSP,
      V_String15     = @cDYNBOM,
      V_Lottable01   = @cLottable01,
      V_Lottable02   = @cLottable02,
      V_Lottable03   = @cLottable03,
      V_Lottable04   = @dLottable04,
      V_Lottable05   = @dLottable05,
      V_Lottable06   = @cLottable06,
      V_Lottable07   = @cLottable07,
      V_Lottable08   = @cLottable08,
      V_Lottable09   = @cLottable09,
      V_Lottable10   = @cLottable10,
      V_Lottable11   = @cLottable11,
      V_Lottable12   = @cLottable12,
      V_Lottable13   = @dLottable13,
      V_Lottable14   = @dLottable14,
      V_Lottable15   = @dLottable15,
      I_Field01      = @cInField01,  O_Field01 = @cOutField01,
      I_Field02      = @cInField02,  O_Field02 = @cOutField02,
      I_Field03      = @cInField03,  O_Field03 = @cOutField03,
      I_Field04      = @cInField04,  O_Field04 = @cOutField04,
      I_Field05      = @cInField05,  O_Field05 = @cOutField05,
      I_Field06      = @cInField06,  O_Field06 = @cOutField06,
      I_Field07      = @cInField07,  O_Field07 = @cOutField07,
      I_Field08      = @cInField08,  O_Field08 = @cOutField08,
      I_Field09      = @cInField09,  O_Field09 = @cOutField09,
      I_Field10      = @cInField10,  O_Field10 = @cOutField10,
      I_Field11      = @cInField11,  O_Field11 = @cOutField11,
      I_Field12      = @cInField12,  O_Field12 = @cOutField12,
      I_Field13      = @cInField13,  O_Field13 = @cOutField13,
      I_Field14      = @cInField14,  O_Field14 = @cOutField14,
      I_Field15      = @cInField15,  O_Field15 = @cOutField15

   WHERE Mobile = @nMobile
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdtfnc_KittingScan TO NSQL
GO


