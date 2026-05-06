SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


/************************************************************************/
/* Copyright: Maersk                                                    */
/* Purpose: KIT Update                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2026-02-10 1.0  JackC    FCR-9763 Created                            */
/************************************************************************/

CREATE OR ALTER   PROCEDURE [RDT].[rdtfnc_KIT_Update] (
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
   @cChkFacility  NVARCHAR( 5),
   @cChkLoc       NVARCHAR(10),
   @cPUOM_Desc    NVARCHAR( 5), -- Preferred UOM desc
   @cMUOM_Desc    NVARCHAR( 5), -- Master unit desc
   @nPUOM_Div     INT, -- UOM divider
   @nPQTY         INT, -- Preferred UOM QTY
   @nMQTY         INT -- Master unit QTY
   

DECLARE 
   @cKitKey          NVARCHAR(10),
   @cKITLineNo       NVARCHAR( 5),
   @cKITType         NVARCHAR( 5),
   @cKitStatus       NVARCHAR(10),
   @cKitDtlStatus    NVARCHAR(10),
   @cUPC             NVARCHAR(30),
   @cQTY             NVARCHAR(6),
   @nQTY             INT,
   @nExpcectedQty    INT,
   @nHandledQty      INT,
   @nAfterStep       INT,
   @nUPCQty          INT,
   @bSuccess         INT


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
   @cUserName           NVARCHAR( 18), -- (Vicky06)
   @cID                 NVARCHAR( 18),
   @cSKU                NVARCHAR( 20),
   @cSKUDescr           NVARCHAR( 60),
   @cPUOM               NVARCHAR( 1), -- Prefer UOM  
   @cExtendedUpdateSP   NVARCHAR(20),
   @cChkStorerKey       NVARCHAR( 15), 
   @cExtendedValidateSP NVARCHAR( 20),           
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
   @cStorerKey          = V_StorerKey,
   @cID                 = V_ID,
   @cSKU                = V_SKU,
   @nQTY                = V_QTY,
   @cExtendedInfoSP     = V_String1,
   @cExtendedValidateSP = V_String2,
   @cExtendedUpdateSP   = V_String3,
   @cDecodeSP           = V_String4,
   @cKitKey             = V_String5,
   @cKITLineNo          = V_String6,
   @cKITType            = V_String7,
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

IF @nFunc = 1877 -- KIT Move ID
BEGIN
   -- Redirect to respective screen
   IF @nStep = 0 GOTO Step_0   -- Func = KIT Update
   IF @nStep = 1 GOTO Step_1   -- Scn = 6830. KIT
   IF @nStep = 2 GOTO Step_2   -- Scn = 6831. ID
   IF @nStep = 3 GOTO Step_3   -- Scn = 6832. SKU
   IF @nStep = 4 GOTO Step_4   -- Scn = 6833. Qty
   IF @nStep = 5 GOTO Step_5   -- Scn = 6834. Message
END
RETURN -- Do nothing if incorrect step


/********************************************************************************
Step 0. func = 1877. Menu
********************************************************************************/
Step_0:
BEGIN
   -- Set the entry point
   SET @nScn = 6830
   SET @nStep = 1

   -- Prep next screen var
   SET @cID = ''
   SET @cKitKey = ''
   SET @cKITLineNo = ''
   SET @cQTY = ''
   SET @cSKU = ''
   SET @cKITType = 'F'

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
   SET @cOutField01 = '' -- Kitkey
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
      SET @cKitKey = LEFT(@cInField01,10)

      -- Validate blank
      IF @cKitKey = '' OR @cKitKey IS NULL
      BEGIN
         SET @nErrNo = 258801
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'KIT needed'
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      SET @nRowCount = 0

      SELECT 
         @cChkStorerKey = StorerKey,
         @cChkFacility  = Facility,
         @cKitStatus    = Status
      FROM dbo.KIT WITH (NOLOCK)
      WHERE KITKey = @cKitKey

      SET @nRowCount = @@ROWCOUNT

      IF @nRowCount = 0
      BEGIN
         SET @nErrNo = 258802
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Invalid kit'
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      IF @cChkStorerKey <> @cStorerKey
      BEGIN
         SET @nErrNo = 258803
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Diff storer'
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      IF @cChkFacility <> @cFacility
      BEGIN
         SET @nErrNo = 258811
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Diff facility'
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      IF NOT EXISTS (SELECT 1 FROM dbo.KITDETAIL WITH (NOLOCK) WHERE KITKey = @cKitKey)
      BEGIN
         SET @nErrNo = 258804
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'No kit detail'
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      IF @cKitStatus = '9'
      BEGIN
         SET @nErrNo = 258805
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'KIT closed'
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END      

      -- Extended update
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKITKey         NVARCHAR( 10), ' +
               '@cID             NVARCHAR( 18), ' +
               '@cSKU            NVARCHAR( 20), ' +
               '@nQty           INT          , ' +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty, @nErrNo OUTPUT, @cErrMsg OUTPUT

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
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKITKey         NVARCHAR( 10), ' +
               '@cID             NVARCHAR( 18), ' +
               '@cSKU            NVARCHAR( 20), ' +
               '@nQty           INT          , ' +
               '@nErrNo         INT           OUTPUT, ' +
               '@cErrMsg        NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               GOTO Step_1_Fail
            END
         END
      END

      -- Prep next screen var
      SET @cOutField01 = @cKitKey
      SET @cOutField02 = '' -- ID

      -- Go to next ID screen  
      SET @nScn = 6831
      SET @nStep = 2

       -- Extended info
      IF @cExtendedInfoSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
         BEGIN
            SET @cExtendedInfo = ''

            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty, @cExtendedInfo OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nAfterStep      INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKITKey         NVARCHAR( 10), ' +
               '@cID             NVARCHAR( 18), ' +
               '@cSKU            NVARCHAR( 20), ' +
               '@nQty           INT          , ' +
               '@cExtendedInfo   NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, 1, @nStep, @nInputKey, @cStorerkey,@cKITKey, @cID, @cSKU, @nQty, @cExtendedInfo OUTPUT

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
      SET @cOutField01 = '' -- KITKey
   END
END
GOTO Quit


/********************************************************************************
Step 2. Scn = 6831. Pallet ID screen
   KitKey  (field01)
   ID      (field02, input)
********************************************************************************/
Step_2:
BEGIN
   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      -- Screen mapping
      SET @cID = @cInField02

      -- Validate blank
      IF @cID = '' OR @cID IS NULL
      BEGIN
         SET @nErrNo = 258806
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'ID required'
         GOTO Step_2_Fail
      END

      SET @nRowCount = 0
      SELECT @cChkLoc =  Loc
      FROM dbo.KITDetail WITH (NOLOCK)
      WHERE Kitkey = @cKITKey
         AND Type = @cKITType
         AND ID = @cID

      SET @nRowCount = @@ROWCOUNT

      IF @nRowCount = 0
      BEGIN
         SET @nErrNo = 258807
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'ID not under KIT'
         GOTO Step_2_Fail
      END

      IF NOT EXISTS (SELECT 1 
                     FROM dbo.LOC WITH (NOLOCK)
                     JOIN dbo.CODELKUP cl WITH (NOLOCK)
                     ON cl.StorerKey = @cStorerKey
                        AND cl.LISTNAME = 'CSVASZONE' 
                        AND LOC.PutawayZone = cl.code
                     WHERE LOC = @cChkLoc)
      BEGIN
         SET @nErrNo = 258812
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Invalid PAZone'
         GOTO Step_2_Fail
      END

      -- Extended update
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKITKey         NVARCHAR( 10), ' +
               '@cID             NVARCHAR( 18), ' +
               '@cSKU            NVARCHAR( 20), ' +
               '@nQty           INT          , ' +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty, @nErrNo OUTPUT, @cErrMsg OUTPUT

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
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKITKey         NVARCHAR( 10), ' +
               '@cID             NVARCHAR( 18), ' +
               '@cSKU            NVARCHAR( 20), ' +
               '@nQty           INT          , ' +
               '@nErrNo         INT           OUTPUT, ' +
               '@cErrMsg        NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               GOTO Step_2_Fail
            END
         END
      END

      SET @nRowCount = 0

      SELECT @nRowCount = COUNT(DISTINCT SKU)
      FROM dbo.KITDetail WITH (NOLOCK)
      WHERE KitKey = @cKitKey
         AND Type = @cKITType
         AND ID = @cID

      IF @nRowCount > 1 -- Muliple SKU on ID
      BEGIN
         -- Prep next screen var
         SET @cOutField02 = @cID
         SET @cOutField03 = '' --SKU

         -- Go to SKU screen
         SET @nScn = 6832
         SET @nStep = 3
      END
      ELSE IF @nRowCount = 1
      BEGIN
         SELECT TOP 1 
            @cSKU = SKU,
            @cKitDtlStatus = STATUS,
            @cKITLineNo = KITLineNumber
         FROM dbo.KITDetail WITH (NOLOCK)
         WHERE KitKey = @cKitKey
            AND Type = @cKITType
            AND ID = @cID
         ORDER BY KITLineNumber

         IF @cKitDtlStatus = '9'
         BEGIN
            SET @nErrNo = 258817
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Invalid PAZone'
            GOTO Step_2_Fail
         END

         SET @cOutField02 = @cID
         SET @cOutField03 = @cSKU
         SET @cOutField04 = '' --Qty

         -- Go to qty screen directly
         SET @nScn = 6833
         SET @nStep = 4
      END
      ELSE
      BEGIN
         SET @nErrNo = 258813
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'ID not under KIT'
         GOTO Step_2_Fail
      END
      
   END

   IF @nInputKey = 0 -- Esc or No
   BEGIN
      -- Prepare prev screen var
      SET @cKitKey = ''
      SET @cID = ''
      SET @cOutField01 = '' -- KitKey

      -- Go back to KITKey screen
      SET @nScn  = 6830
      SET @nStep = 1
   END

   -- Extended info
   IF @cExtendedInfoSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
      BEGIN
         SET @cExtendedInfo = ''

         SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty, @cExtendedInfo OUTPUT'
         SET @cSQLParam =
            '@nMobile         INT,       '     +
            '@nFunc           INT,       '     +
            '@cLangCode       NVARCHAR( 3),  ' +
            '@nStep           INT,       '     +
            '@nAfterStep      INT,       '     +
            '@nInputKey       INT,       '     +
            '@cStorerKey      NVARCHAR( 15), ' +
            '@cKITKey         NVARCHAR( 10), ' +
            '@cID             NVARCHAR( 18), ' +
            '@cSKU            NVARCHAR( 20), ' +
            '@nQty           INT          , ' +
            '@cExtendedInfo   NVARCHAR( 20)  OUTPUT'

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, 2, @nStep, @nInputKey, @cStorerkey,@cKITKey, @cID, @cSKU, @nQty, @cExtendedInfo OUTPUT

         SET @cOutField15 = CASE WHEN ISNULL( @cExtendedInfo, '') <> '' THEN @cExtendedInfo ELSE '' END
      END
   END

   GOTO Quit

   Step_2_Fail:
   BEGIN
      SET @cID  = ''
      SET @cOutField02 = '' -- ID
   END
END
GOTO Quit

/********************************************************************************
Step 3. Scn = 6832. SKU screen
   KitKey  (field01)
   ID      (field02)
   SKU     (field03, input)
********************************************************************************/
Step_3:
BEGIN
   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      -- Screen mapping
      SET @cUPC = @cInField03

      -- Validate blank
      IF @cUPC = '' OR @cUPC IS NULL
      BEGIN
         SET @nErrNo = 258808
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'ID required'
         GOTO Step_3_Fail
      END

      -- Get SKU count
      DECLARE @nSKUCnt INT
      SET @nSKUCnt = 0
      EXEC RDT.rdt_GetSKUCNT
         @cStorerKey  = @cStorerKey
         ,@cSKU        = @cUPC
         ,@nSKUCnt     = @nSKUCnt   OUTPUT
         ,@bSuccess    = @bSuccess  OUTPUT
         ,@nErr        = @nErrNo    OUTPUT
         ,@cErrMsg     = @cErrMsg   OUTPUT

      -- Check SKU
      IF @nSKUCnt = 0
      BEGIN
         SET @nErrNo = 258809
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid SKU
         GOTO Step_3_Fail
      END

      -- Validate barcode return multiple SKU
      IF @nSKUCnt > 1
      BEGIN
         SET @nErrNo = 258810
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MultiSKUBarcod
         GOTO Step_3_Fail
      END

      -- Get SKU
      EXEC rdt.rdt_GetSKU
         @cStorerKey  = @cStorerKey
         ,@cSKU        = @cUPC      OUTPUT
         ,@bSuccess    = @bSuccess  OUTPUT
         ,@nErr        = @nErrNo    OUTPUT
         ,@cErrMsg     = @cErrMsg   OUTPUT
         ,@nUPCQty     = @nUPCQty   OUTPUT

      IF @nErrNo <> 0
         GOTO Step_3_Fail

      SET @cSKU = @cUPC

      SET @nRowCount = 0

      SELECT TOP 1
         @cKitDtlStatus = STATUS,
         @cKITLineNo = KITLineNumber
      FROM dbo.KITDetail WITH (NOLOCK)
      WHERE KITKey = @cKITKey
         AND ID = @cID
         AND Type = @cKITType
         AND SKU = @cSKU
      ORDER BY KITLineNumber

      SET @nRowCount = @@ROWCOUNT

      IF @nRowCount = 0
      BEGIN
         SET @nErrNo = 258811
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU not in id
         GOTO Step_3_Fail
      END

      IF @cKitDtlStatus = '9'
      BEGIN
         SET @nErrNo = 258814
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Kit finalized
         GOTO Step_3_Fail
      END

      -- Extended update
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKITKey         NVARCHAR( 10), ' +
               '@cID             NVARCHAR( 18), ' +
               '@cSKU            NVARCHAR( 20), ' +
               '@nQty           INT          , ' +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty, @nErrNo OUTPUT, @cErrMsg OUTPUT

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
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKITKey         NVARCHAR( 10), ' +
               '@cID             NVARCHAR( 18), ' +
               '@cSKU            NVARCHAR( 20), ' +
               '@nQty           INT          , ' +
               '@nErrNo         INT           OUTPUT, ' +
               '@cErrMsg        NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               GOTO Step_3_Fail
            END
         END
      END

      -- Prep next screen var
      SET @cOutField03 = ''

      -- Go to next screen
      SET @nScn = 6833
      SET @nStep = 4
   END

   IF @nInputKey = 0 -- Esc or No
   BEGIN
      -- Prepare prev screen var
      SET @cID = ''
      SET @cSKU = ''
      SET @cOutField02 = '' -- ID

      -- Go back to KITKey screen
      SET @nScn  = 6831
      SET @nStep = 2
   END

   -- Extended info
   IF @cExtendedInfoSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
      BEGIN
         SET @cExtendedInfo = ''

         SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty, @cExtendedInfo OUTPUT'
         SET @cSQLParam =
            '@nMobile         INT,       '     +
            '@nFunc           INT,       '     +
            '@cLangCode       NVARCHAR( 3),  ' +
            '@nStep           INT,       '     +
            '@nAfterStep      INT,       '     +
            '@nInputKey       INT,       '     +
            '@cStorerKey      NVARCHAR( 15), ' +
            '@cKITKey         NVARCHAR( 10), ' +
            '@cID             NVARCHAR( 18), ' +
            '@cSKU            NVARCHAR( 20), ' +
            '@nQty           INT          , ' +
            '@cExtendedInfo   NVARCHAR( 20)  OUTPUT'

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, 3, @nStep, @nInputKey, @cStorerkey,@cKITKey, @cID, @cSKU, @nQty, @cExtendedInfo OUTPUT

         SET @cOutField15 = CASE WHEN ISNULL( @cExtendedInfo, '') <> '' THEN @cExtendedInfo ELSE '' END
      END
   END

   GOTO Quit

   Step_3_Fail:
   BEGIN
      SET @cUPC  = ''
      SET @cOutField03 = '' -- SKU
   END
END
GOTO Quit

/********************************************************************************
Step 4. Scn = 6833. Qty screen
   KitKey  (field01)
   ID      (field02)
   SKU     (field03)
   Qty     (field04, input)
********************************************************************************/
Step_4:
BEGIN
   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      -- Screen mapping
      SET @cQty = @cInField04

      -- Validate blank
      IF @cQty = '' OR @cQty IS NULL
      BEGIN
         SET @nErrNo = 258815
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Qty required'
         GOTO Step_4_Fail
      END

      -- Validate QTY
      IF @cQTY <> '' AND RDT.rdtIsValidQTY( @cQTY, 0) = 0
      BEGIN
         SET @nErrNo = 258816
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid QTY
         GOTO Step_4_Fail
      END

      SET @nQTY = CAST(@cQty AS INT)

      SELECT 
         @nExpcectedQty = ExpectedQty,
         @nHandledQty   = Qty
      FROM dbo.KITDetail WITH (NOLOCK)
      WHERE KitKey = @cKitKey
         AND Type = @cKITType
         AND KITLineNumber = @cKITLineNo

      IF @nQty > (@nExpcectedQty - @nHandledQty)
      BEGIN
         SET @nErrNo = 258818
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Qty excceed
         GOTO Step_4_Fail
      END

      -- Extended update
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKITKey         NVARCHAR( 10), ' +
               '@cID             NVARCHAR( 18), ' +
               '@cSKU            NVARCHAR( 20), ' +
               '@nQty           INT          , ' +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_4_Fail
         END
      END

      SET @nQty = CAST(@cQty AS INT)

      DECLARE @nTranCount  INT
      SET @nTranCount = @@TRANCOUNT
      BEGIN TRAN
      SAVE TRAN rdtfnc_KIT_Update

      EXEC RDT.rdt_KIT_Update_Confirm @nMobile, @nFunc, @cLangCode, @cFacility, @cStorerKey
            ,@cKitKey
            ,@cKITLineNo
            ,@cID
            ,@cSKU
            ,@nQTY
            ,@cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05
            ,@cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10
            ,@cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15
            ,@cKITType 
            ,@nErrNo      = @nErrNo  OUTPUT
            ,@cErrMsg     = @cErrMsg OUTPUT
      IF @nErrNo <> 0
      BEGIN
         ROLLBACK TRAN rdtfnc_KIT_Update
         WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
            COMMIT TRAN
         GOTO Step_4_Fail
      END

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKITKey         NVARCHAR( 10), ' +
               '@cID             NVARCHAR( 18), ' +
               '@cSKU            NVARCHAR( 20), ' +
               '@nQty           INT          , ' +
               '@nErrNo         INT           OUTPUT, ' +
               '@cErrMsg        NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               ROLLBACK TRAN rdtfnc_KIT_Update
               WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                  COMMIT TRAN
               GOTO Step_4_Fail
            END
         END
      END

      COMMIT TRAN rdtfnc_KIT_Update
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
         COMMIT TRAN

      -- Go to next screen
      SET @nScn = 6834
      SET @nStep = 5
   END

   IF @nInputKey = 0 -- Esc or No
   BEGIN
      -- Prepare prev screen var
      SET @cSKU = ''
      SET @cQty = ''
      SET @cUPC = ''

      SET @nRowCount = 0

      SELECT @nRowCount = COUNT(DISTINCT SKU)
      FROM dbo.KITDetail WITH (NOLOCK)
      WHERE KitKey = @cKitKey
         AND Type = @cKITType
         AND ID = @cID

      IF @nRowCount = 1 -- Single SKU
      BEGIN
         SET @cID = ''
         SET @cOutField02 = '' --ID

         -- Go to ID screen
         SET @nScn = 6831
         SET @nStep = 2
      END
      ELSE
      BEGIN
         SET @cOutField03 = '' --SKU

         -- Go back to SKU screen
         SET @nScn  = 6832
         SET @nStep = 3
      END
   END

   -- Extended info
   IF @cExtendedInfoSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
      BEGIN
         SET @cExtendedInfo = ''

         SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty, @cExtendedInfo OUTPUT'
         SET @cSQLParam =
            '@nMobile         INT,       '     +
            '@nFunc           INT,       '     +
            '@cLangCode       NVARCHAR( 3),  ' +
            '@nStep           INT,       '     +
            '@nAfterStep      INT,       '     +
            '@nInputKey       INT,       '     +
            '@cStorerKey      NVARCHAR( 15), ' +
            '@cKITKey         NVARCHAR( 10), ' +
            '@cID             NVARCHAR( 18), ' +
            '@cSKU            NVARCHAR( 20), ' +
            '@nQty           INT          , ' +
            '@cExtendedInfo   NVARCHAR( 20)  OUTPUT'

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, 4, @nStep, @nInputKey, @cStorerkey,@cKITKey, @cID, @cSKU, @nQty, @cExtendedInfo OUTPUT

         SET @cOutField15 = CASE WHEN ISNULL( @cExtendedInfo, '') <> '' THEN @cExtendedInfo ELSE '' END
      END
   END

   GOTO Quit

   Step_4_Fail:
   BEGIN
      SET @cQty  = ''
      SET @cOutField04 = '' -- Qty
   END
END
GOTO Quit


/********************************************************************************
Step 5. scn = 6834. Message screen
   Msg
********************************************************************************/
Step_5:
BEGIN
   -- Prep next screen var
   SET @cID = ''
   SET @cSKU = ''
   SET @cQty = ''

   SET @cOutField02 = '' -- ID
   -- Go back to ID screen
   SET @nScn  = 6831
   SET @nStep = 2

   -- Extended info
   IF @cExtendedInfoSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
      BEGIN
         SET @cExtendedInfo = ''

         SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cStorerkey, @cKITKey, @cID, @cSKU, @nQty, @cExtendedInfo OUTPUT'
         SET @cSQLParam =
            '@nMobile         INT,       '     +
            '@nFunc           INT,       '     +
            '@cLangCode       NVARCHAR( 3),  ' +
            '@nStep           INT,       '     +
            '@nAfterStep      INT,       '     +
            '@nInputKey       INT,       '     +
            '@cStorerKey      NVARCHAR( 15), ' +
            '@cKITKey         NVARCHAR( 10), ' +
            '@cID             NVARCHAR( 18), ' +
            '@cSKU            NVARCHAR( 20), ' +
            '@nQty           INT          , ' +
            '@cExtendedInfo   NVARCHAR( 20)  OUTPUT'

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, 5, @nStep, @nInputKey, @cStorerkey,@cKITKey, @cID, @cSKU, @nQty, @cExtendedInfo OUTPUT

         SET @cOutField15 = CASE WHEN ISNULL( @cExtendedInfo, '') <> '' THEN @cExtendedInfo ELSE '' END
      END
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
      V_StorerKey    = @cStorerKey,
      V_ID           = @cID,
      V_SKU          = @cSKU,
      V_QTY          = @nQty,
      V_String1      = @cExtendedInfoSP,
      V_String2      = @cExtendedValidateSP,
      V_String3      = @cExtendedUpdateSP,
      V_String4      = @cDecodeSP,
      V_String5      = @cKITKey,
      V_String6      = @cKITLineNo,
      V_String7      = @cKITType,
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

GRANT EXECUTE ON RDT.rdtfnc_KIT_Update TO NSQL
GO


