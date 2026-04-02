
/************************************************************************/
/* Store procedure: rdtfnc_PalletConsolidate_BESE                       */
/* Copyright      : MAersk                                              */
/*                                                                      */
/* Purpose: Customized pallet consolidate for Schneider BE              */
/*                                                                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2026-03-11 1.0.1  Jackc    FCR-9676 Created                          */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdtfnc_PalletConsolidate_BESE] (
   @nMobile    INT,
   @nErrNo     INT  OUTPUT,
   @cErrMsg    NVARCHAR(1024) OUTPUT -- screen limitation, 20 char max
) AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF

-- Misc variable
DECLARE
   @cChkFacility        NVARCHAR( 5),
   @nSKUCnt             INT, 
   @nRowCount           INT = 0, 
   @bSuccess            INT 

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
   @cChkStorerKey       NVARCHAR( 15),
   @cFacility           NVARCHAR( 5),	

   @cFromLOC            NVARCHAR( 10), -- From Loc
   @cToLOC              NVARCHAR( 10), -- To Loc
   @cFromID             NVARCHAR( 18), -- From ID
   @cToID               NVARCHAR( 18), -- To ID
   @cSKU                NVARCHAR( 20),
   @cLot                NVARCHAR( 10),
   @cPalletLabel        NVARCHAR( 20),
   @cPaperPrinter       NVARCHAR( 10),
   @cLabelPrinter       NVARCHAR( 10),
   @cNewIDFlag          NVARCHAR( 1),
   @nScannedCount       INT,
   @nQty                INT,

   @b_success           INT,
   @n_err               INT,
   @c_errmsg            NVARCHAR( 255),
   @cUserName           NVARCHAR( 18), 

   @cOption             NVARCHAR( 1),
   @cExtendedInfo01     NVARCHAR( 20), 
   @cExtendedInfoSP     NVARCHAR( 20), 
   @cExtendedValidateSP NVARCHAR( 20),
   @cSkipIDExistCheck   NVARCHAR( 1),
   @cNewIDDefOpt        NVARCHAR( 1), 
   @cSQL                NVARCHAR(1000),   
   @cSQLParam           NVARCHAR(1000),   

   @cDefaultOpt         NVARCHAR( 1), 
   @cExtendedDefaultOptSP NVARCHAR( 20), 
   @nMultiStorer        INT,
   @cExtendedUpdateSP   NVARCHAR(30), -- (ChewKP01) 
   @nFromScn            INT,
   @nFromStep           INT,
   
   @cGenID              NVARCHAR(20), 
   @tExtData            VariableTable,
   @cAutoID             NVARCHAR(18),

   @cLottable01  NVARCHAR( 18),
   @cLottable02  NVARCHAR( 18),
   @cLottable03  NVARCHAR( 18),
   @dLottable04  DATETIME,
   @dLottable05  DATETIME,
   @cLottable06  NVARCHAR( 30),
   @cLottable07  NVARCHAR( 30),
   @cLottable08  NVARCHAR( 30),
   @cLottable09  NVARCHAR( 30),
   @cLottable10  NVARCHAR( 30),
   @cLottable11  NVARCHAR( 30),
   @cLottable12  NVARCHAR( 30),
   @dLottable13  DATETIME,
   @dLottable14  DATETIME,
   @dLottable15  DATETIME,

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
   @cInField15 NVARCHAR( 60),   @cOutField15 NVARCHAR( 60),

   @cFieldAttr01 NVARCHAR( 1), @cFieldAttr02 NVARCHAR( 1),
   @cFieldAttr03 NVARCHAR( 1), @cFieldAttr04 NVARCHAR( 1),
   @cFieldAttr05 NVARCHAR( 1), @cFieldAttr06 NVARCHAR( 1),
   @cFieldAttr07 NVARCHAR( 1), @cFieldAttr08 NVARCHAR( 1),
   @cFieldAttr09 NVARCHAR( 1), @cFieldAttr10 NVARCHAR( 1),
   @cFieldAttr11 NVARCHAR( 1), @cFieldAttr12 NVARCHAR( 1),
   @cFieldAttr13 NVARCHAR( 1), @cFieldAttr14 NVARCHAR( 1),
   @cFieldAttr15 NVARCHAR( 1)
   
-- Load RDT.RDTMobRec
SELECT
   @nFunc               = Func,
   @nScn                = Scn,
   @nStep               = Step,
   @nInputKey           = InputKey,
   @nMenu               = Menu,
   @cLangCode           = Lang_code,

   @cStorerGroup        = StorerGroup, 
   @cStorerKey          = V_StorerKey,
   @cFacility           = Facility,
   @cUserName           = UserName,
   @cPaperPrinter       = Printer_Paper,
   @cLabelPrinter       = Printer,
   @cToID	            = V_ID,
   @cSKU                = V_SKU,

   @cFromID             = V_String1,
   @cNewIDFlag          = V_String2,
   @cOption             = V_String3, 
   @cExtendedUpdateSP   = V_String4,
   @cExtendedValidateSP = V_String5,
   @cToLOC              = V_String6,
   @cFromLOC            = V_String7,
   @cPalletLabel        = V_String8,

   @nScannedCount       = V_Integer1,

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
   @cInField15 = I_Field15,   @cOutField15 = O_Field15,

   @cFieldAttr01  = FieldAttr01,    @cFieldAttr02   = FieldAttr02,
   @cFieldAttr03 =  FieldAttr03,    @cFieldAttr04   = FieldAttr04,
   @cFieldAttr05 =  FieldAttr05,    @cFieldAttr06   = FieldAttr06,
   @cFieldAttr07 =  FieldAttr07,    @cFieldAttr08   = FieldAttr08,
   @cFieldAttr09 =  FieldAttr09,    @cFieldAttr10   = FieldAttr10,
   @cFieldAttr11 =  FieldAttr11,    @cFieldAttr12   = FieldAttr12,
   @cFieldAttr13 =  FieldAttr13,    @cFieldAttr14   = FieldAttr14,
   @cFieldAttr15 =  FieldAttr15

FROM rdt.RDTMOBREC (NOLOCK)
WHERE Mobile = @nMobile

-- Redirect to respective screen
IF @nFunc = 1878 
BEGIN
   IF @nStep = 0 GOTO Step_0   -- Menu. Func = 1878
   IF @nStep = 1 GOTO Step_1   -- Scn = 6850. To ID
   IF @nStep = 2 GOTO Step_2   -- Scn = 6851. Create New Pallet?
   IF @nStep = 3 GOTO Step_3   -- Scn = 6852. From ID
   IF @nStep = 4 GOTO Step_4   -- Scn = 6853. Success message
   IF @nStep = 5 GOTO Step_5   -- Scn = 6854. print label?
END

RETURN -- Do nothing if incorrect step

/********************************************************************************
Step 0. Called from menu (func = 515)
********************************************************************************/
Step_0:
BEGIN
   SET @cOutField01 = ''
   SET @cOutField02 = ''
   SET @cOutField03 = ''
   SET @cOutField04 = ''
   SET @cOutField05 = ''
   SET @cOutField06 = ''
   SET @cOutField07 = ''
   SET @cOutField08 = ''
   SET @cOutField09 = ''
   SET @cOutField10 = ''
   SET @cOutField11 = ''
   SET @cOutField12 = ''
   SET @cOutField13 = ''
   SET @cOutField14 = ''
   SET @cOutField15 = ''

   -- Set the entry point
   SET @nScn = 6850
   SET @nStep = 1

   -- EventLog - Sign In Function
   EXEC RDT.rdt_STD_EventLog
      @cActionType = '1', -- Sign in function
      @cUserID     = @cUserName,
      @nMobileNo   = @nMobile,
      @nFunctionID = @nFunc,
      @cFacility   = @cFacility,
      @cStorerKey  = @cStorerkey

   SET @cExtendedUpdateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)
   IF @cExtendedUpdateSP = '0'
      SET @cExtendedUpdateSP = ''

   SET @cExtendedValidateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)
   IF @cExtendedValidateSP = '0'
      SET @cExtendedValidateSP = ''

   SET @cPalletLabel = rdt.RDTGetConfig( @nFunc, 'PalletLabel', @cStorerKey)
   IF @cPalletLabel = '0'
      SET @cPalletLabel = ''

   -- Prep next screen var
   SET @cFromID = ''
   SET @cToID = ''
   SET @cToLoc = ''
   SET @cOutField01 = ''         -- To ID
   
   SET @cFieldAttr01 = '' 
   SET @cFieldAttr02 = ''
   SET @cFieldAttr03 = '' 
   SET @cFieldAttr04 = ''
   SET @cFieldAttr05 = '' 
   SET @cFieldAttr06 = ''
   SET @cFieldAttr07 = '' 
   SET @cFieldAttr08 = ''
   SET @cFieldAttr09 = ''
   SET @cFieldAttr10 = ''
   SET @cFieldAttr11 = '' 
   SET @cFieldAttr12 = ''
   SET @cFieldAttr13 = ''
   SET @cFieldAttr14 = ''
   SET @cFieldAttr15 = ''

   EXEC rdt.rdtSetFocusField @nMobile, 1
END
GOTO Quit

/********************************************************************************
Step 1. Screen = 6850
   To PALLET ID
   (Field01, input)
********************************************************************************/
Step_1:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cToID = @cInField01

      SET @cNewIDFlag = '0' --reset value

      IF ISNULL(@cToID, '') = ''
      BEGIN
         SET @nErrNo = 260751
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID needed
         GOTO Step_1_Fail
      END

      -- Check from id format (james02)
      IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'ID', @cToID) = 0
      BEGIN
         SET @nErrNo = 260752
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format
         GOTO Step_1_Fail
      END

      SET @nRowCount = 0

      SELECT TOP 1 
         @cToLOC        = LLI.Loc,
         @cSKU          = LLI.SKU,
         @cLot          = LLI.Lot,
         @cLottable01   = Lottable01,
         @cLottable02   = Lottable02,
         @cLottable03   = Lottable03,
         @dLottable04   = ISNULL(Lottable04,''),
         @dLottable05   = ISNULL(Lottable05,''),
         @cLottable06   = Lottable06,
         @cLottable07   = Lottable07,
         @cLottable08   = Lottable08,
         @cLottable09   = Lottable09,
         @cLottable10   = Lottable10,
         @cLottable11   = Lottable11,
         @cLottable12   = Lottable12,
         @dLottable13   = ISNULL(Lottable13,''),
         @dLottable14   = ISNULL(Lottable14,''),
         @dLottable15   = ISNULL(Lottable15,'')
      FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
      JOIN dbo.LotAttribute LA WITH (NOLOCK)
         ON LLI.Lot = LA.Lot
      WHERE LLI.StorerKey = @cStorerKey
      AND   LLI.ID = @cToID 
      AND   Qty > 0
      ORDER BY LLI.SKU

      SET @nRowCount = @@ROWCOUNT

      -- Extended update
      IF @cExtendedValidateSP <> '' 
      BEGIN
         IF EXISTS(SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cOption, @cSKU, @cLot, @nQty, @cToID, ' +
               '@cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
               '@cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
               '@nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR(3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR(15), ' +
               '@cFromID         NVARCHAR(20), ' +
               '@cOption         NVARCHAR(1), '  +
               '@cSKU            NVARCHAR(20), ' +
               '@cLot            NVARCHAR(10), ' +
               '@nQty            INT, '          +
               '@cToID           NVARCHAR(20), ' +
               '@cLottable01     NVARCHAR(18), ' +
               '@cLottable02     NVARCHAR(18), ' +
               '@cLottable03     NVARCHAR(18), ' +
               '@dLottable04     DATETIME, ' +
               '@dLottable05     DATETIME, ' +
               '@cLottable06     NVARCHAR(30), ' +
               '@cLottable07     NVARCHAR(30), ' +
               '@cLottable08     NVARCHAR(30), ' +
               '@cLottable09     NVARCHAR(30), ' +
               '@cLottable10     NVARCHAR(30), ' +
               '@cLottable11     NVARCHAR(30), ' +
               '@cLottable12     NVARCHAR(30), ' +
               '@dLottable13     DATETIME, ' +
               '@dLottable14     DATETIME, ' +
               '@dLottable15     DATETIME, ' +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cOption, @cSKU, @cLot, @nQTY, @cToID,
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_1_Fail
         END
      END

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cOption, @cSKU, @cLot, @nQty, @cToID, ' +
               '@cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
               '@cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
               '@nScannedCount, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cFromID         NVARCHAR( 20), ' +
               '@cOption         NVARCHAR( 1), '  +
               '@cSKU            NVARCHAR( 20), ' +
               '@cLot            NVARCHAR( 10), ' +
               '@nQty            INT, '           +
               '@cToID           NVARCHAR( 20), ' +
               '@cLottable01     NVARCHAR( 18), ' +
               '@cLottable02     NVARCHAR( 18), ' +
               '@cLottable03     NVARCHAR( 18), ' +
               '@dLottable04     DATETIME, ' +
               '@dLottable05     DATETIME, ' +
               '@cLottable06     NVARCHAR( 30), ' +
               '@cLottable07     NVARCHAR( 30), ' +
               '@cLottable08     NVARCHAR( 30), ' +
               '@cLottable09     NVARCHAR( 30), ' +
               '@cLottable10     NVARCHAR( 30), ' +
               '@cLottable11     NVARCHAR( 30), ' +
               '@cLottable12     NVARCHAR( 30), ' +
               '@dLottable13     DATETIME, ' +
               '@dLottable14     DATETIME, ' +
               '@dLottable15     DATETIME, ' +
               '@nScannedCount   INT, '           +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR( 1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cOption, @cSKU, @cLot, @nQty, @cToID,
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               @nScannedCount, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_1_Fail
         END
      END

      IF @nRowCount > 0
      BEGIN
         --go to FromID screen
         SET @cNewIDFlag = '0'
         SET @nScannedCount = 0

         SET @nStep = 3
         SET @nScn = 6852
         
         SET @cOutField01 = @cToID
         SET @cOutField02 = ''
         SET @cOutField03 = '0'

         EXEC rdt.rdtSetFocusField @nMobile, 2

         GOTO Step_1_Quit
      END
      ELSE -- New ID
      BEGIN
         SET @cSkipIDExistCheck = rdt.rdtGetConfig( @nFunc, 'SkipIDExistCheck', @cStorerKey)
         IF @cSkipIDExistCheck = '0'
            SET @cSkipIDExistCheck = ''

         SET @cNewIDDefOpt = rdt.rdtGetConfig( @nFunc, 'NewIDDefOpt', @cStorerKey)
         IF @cNewIDDefOpt = '0'
            SET @cNewIDDefOpt = ''

         SET @cToLOC = ''
         
         IF @cSkipIDExistCheck = '1'
         BEGIN
            SET @cNewIDFlag = '1'
            SET @cOption = ''
            SET @nScannedCount = 0

            --From ID screen
            SET @nStep = 3
            SET @nScn  = 6852

            SET @cOutField01 = @cToID
            SET @cOutField02 = ''
            SET @cOutField03 = '0'

            EXEC rdt.rdtSetFocusField @nMobile, 2

            GOTO Step_1_Quit
         END

         SET @nStep = 2
         SET @nScn = 6851

         IF @cNewIDDefOpt = '1'
            SET @cOutField01 = '1' --default option
         ELSE
            SET @cOutField01 = ''

         SET @cOption = ''
         GOTO Step_1_Quit
      END -- New id
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- EventLog - Sign Out Function
      EXEC RDT.rdt_STD_EventLog
         @cActionType = '9', -- Sign Out function
         @cUserID     = @cUserName,
         @nMobileNo   = @nMobile,
         @nFunctionID = @nFunc,
         @cFacility   = @cFacility,
         @cStorerKey  = @cStorerkey

      -- Back to menu
      SET @nFunc = @nMenu
      SET @nScn  = @nMenu
      SET @nStep = 0
      SET @cOutField01 = '' -- Clean up for menu option


      SET @cToID = ''

      SET @cFieldAttr01 = '' 
      SET @cFieldAttr02 = ''
      SET @cFieldAttr03 = '' 
      SET @cFieldAttr04 = ''
      SET @cFieldAttr05 = '' 
      SET @cFieldAttr06 = ''
      SET @cFieldAttr07 = '' 
      SET @cFieldAttr08 = ''
      SET @cFieldAttr09 = ''
      SET @cFieldAttr10 = ''
      SET @cFieldAttr11 = '' 
      SET @cFieldAttr12 = ''
      SET @cFieldAttr13 = ''
      SET @cFieldAttr14 = ''
      SET @cFieldAttr15 = ''
   END

   Step_1_Quit:
      GOTO Quit

   Step_1_Fail:
   BEGIN
      SET @cToID = ''
      SET @cOutField01 = ''
      EXEC rdt.rdtSetFocusField @nMobile, 1
   END
END
GOTO Quit

/********************************************************************************
Step 2. Screen 6851
   Create new pallet: 
   1=YES  2=NO
   (Field01, input)
********************************************************************************/
Step_2:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cOption = @cInField01
      
      IF @cOption = ''
      BEGIN
         SET @nErrNo = 260753
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Option required
         GOTO Step_2_Fail
      END

      IF @cOption NOT IN ('1','2')
      BEGIN
         SET @nErrNo = 260754
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Option required
         GOTO Step_2_Fail
      END

      -- Extended Validation
      IF @cExtendedValidateSP <> '' 
      BEGIN
         IF EXISTS(SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cOption, @cSKU, @cLot, @nQty, @cToID, ' +
               '@cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
               '@cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
               '@nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR(3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR(15), ' +
               '@cFromID         NVARCHAR(20), ' +
               '@cOption         NVARCHAR(1), '  +
               '@cSKU            NVARCHAR(20), ' +
               '@cLot            NVARCHAR(10), ' +
               '@nQty            INT, '          +
               '@cToID           NVARCHAR(20), ' +
               '@cLottable01     NVARCHAR(18), ' +
               '@cLottable02     NVARCHAR(18), ' +
               '@cLottable03     NVARCHAR(18), ' +
               '@dLottable04     DATETIME, ' +
               '@dLottable05     DATETIME, ' +
               '@cLottable06     NVARCHAR(30), ' +
               '@cLottable07     NVARCHAR(30), ' +
               '@cLottable08     NVARCHAR(30), ' +
               '@cLottable09     NVARCHAR(30), ' +
               '@cLottable10     NVARCHAR(30), ' +
               '@cLottable11     NVARCHAR(30), ' +
               '@cLottable12     NVARCHAR(30), ' +
               '@dLottable13     DATETIME, ' +
               '@dLottable14     DATETIME, ' +
               '@dLottable15     DATETIME, ' +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cOption, @cSKU, @cLot, @nQTY, @cToID,
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               GOTO Step_2_Fail
            END
         END
      END

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cOption, @cSKU, @cLot, @nQty, @cToID, ' +
               '@cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
               '@cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
               '@nScannedCount, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cFromID         NVARCHAR( 20), ' +
               '@cOption         NVARCHAR( 1), '  +
               '@cSKU            NVARCHAR( 20), ' +
               '@cLot            NVARCHAR( 10), ' +
               '@nQty            INT, '           +
               '@cToID           NVARCHAR( 20), ' +
               '@cLottable01     NVARCHAR( 18), ' +
               '@cLottable02     NVARCHAR( 18), ' +
               '@cLottable03     NVARCHAR( 18), ' +
               '@dLottable04     DATETIME, ' +
               '@dLottable05     DATETIME, ' +
               '@cLottable06     NVARCHAR( 30), ' +
               '@cLottable07     NVARCHAR( 30), ' +
               '@cLottable08     NVARCHAR( 30), ' +
               '@cLottable09     NVARCHAR( 30), ' +
               '@cLottable10     NVARCHAR( 30), ' +
               '@cLottable11     NVARCHAR( 30), ' +
               '@cLottable12     NVARCHAR( 30), ' +
               '@dLottable13     DATETIME, ' +
               '@dLottable14     DATETIME, ' +
               '@dLottable15     DATETIME, ' +
               '@nScannedCount   INT, '           +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR( 1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cOption, @cSKU, @cLot, @nQty, @cToID,
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               @nScannedCount, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_2_Fail
         END
      END

      IF @cOption = '1'
      BEGIN
         SET @cNewIDFlag = '1'
         SET @nScannedCount = 0

         --From ID screen
         SET @nStep = 3
         SET @nScn  = 6852

         SET @cOutField01 = @cToID
         SET @cOutField02 = ''
         SET @cOutField03 = '0'
         
         EXEC rdt.rdtSetFocusField @nMobile, 2
      END
      ELSE
      BEGIN
         SET @cNewIDFlag = '0'

         --From ID screen
         SET @nStep = 1
         SET @nScn  = 6850

         SET @cOutField01 = ''
         SET @cToID = ''

         EXEC rdt.rdtSetFocusField @nMobile, 1
      END
   END

   IF @nInputKey = 0 -- Esc OR No
   BEGIN
      SET @cNewIDFlag = '0'

      --From ID screen
      SET @nStep = 1
      SET @nScn  = 6850

      SET @cOutField01 = ''
      SET @cToID = ''

      EXEC rdt.rdtSetFocusField @nMobile, 1
   END
   GOTO Quit

   Step_2_Fail:
   BEGIN
      SET @cOption = ''
      SET @cOutField01 = ''
      EXEC rdt.rdtSetFocusField @nMobile, 1
      GOTO Quit
   END
END
GOTO Quit

/********************************************************************************
Step 3. Screen 6852
   To ID: 
   (Field01)
   From ID:
   (Field02, input)
********************************************************************************/
Step_3:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      SET @cFromID = @cInField02

      IF ISNULL(@cFromID, '') = ''
      BEGIN
         IF @nScannedCount > 0
         BEGIN
            IF @cPalletLabel <> ''
            BEGIN
               --Print pallet label screen
               SET @cOutField01 = ''

               SET @nScn = 6854
               SET @nStep = 5

               GOTO Step_3_Quit
            END
            ELSE
            BEGIN
               --Success screen
               SET @nScn = 6853
               SET @nStep = 4

               GOTO Step_3_Quit
            END
         END
         ELSE
         BEGIN
            SET @nErrNo = 260755
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Option required
            GOTO Step_3_Fail
         END
      END

      IF @cFromID = @cToID
      BEGIN
         SET @nErrNo = 260758
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Option required
         GOTO Step_3_Fail
      END

      -- Check from id format (james02)
      IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'ID', @cFromID) = 0
      BEGIN
         SET @nErrNo = 260759
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format
         GOTO Step_3_Fail
      END

      SELECT TOP 1
         @cFromLOC = Loc
      FROM dbo.LOTxLOCxID WITH (NOLOCK) 
      WHERE StorerKey = @cStorerKey 
         AND ID = @cFromID 
         AND Qty > 0

      SET @nRowCount = @@ROWCOUNT

      IF @nRowCount = 0
      BEGIN
         SET @nErrNo = 260756
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --FromID not exists
         GOTO Step_3_Fail
      END

      -- Check pallet status
      IF EXISTS ( SELECT 1  
                  FROM dbo.PickDetail WITH (NOLOCK) 
                  WHERE StorerKey = @cStorerKey 
                  AND   ID = @cFromID
                  AND   [Status] = '5'
                  AND   ShipFlag = 'Y')
      BEGIN
         SET @nErrNo = 260757
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID is shipped
         GOTO Step_3_Fail
      END

      -- Extended Validation
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS(SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cOption, @cSKU, @cLot, @nQty, @cToID, ' +
               '@cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
               '@cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
               '@nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR(3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR(15), ' +
               '@cFromID         NVARCHAR(20), ' +
               '@cOption         NVARCHAR(1), '  +
               '@cSKU            NVARCHAR(20), ' +
               '@cLot            NVARCHAR(10), ' +
               '@nQty            INT, '          +
               '@cToID           NVARCHAR(20), ' +
               '@cLottable01     NVARCHAR(18), ' +
               '@cLottable02     NVARCHAR(18), ' +
               '@cLottable03     NVARCHAR(18), ' +
               '@dLottable04     DATETIME, ' +
               '@dLottable05     DATETIME, ' +
               '@cLottable06     NVARCHAR(30), ' +
               '@cLottable07     NVARCHAR(30), ' +
               '@cLottable08     NVARCHAR(30), ' +
               '@cLottable09     NVARCHAR(30), ' +
               '@cLottable10     NVARCHAR(30), ' +
               '@cLottable11     NVARCHAR(30), ' +
               '@cLottable12     NVARCHAR(30), ' +
               '@dLottable13     DATETIME, ' +
               '@dLottable14     DATETIME, ' +
               '@dLottable15     DATETIME, ' +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cOption, @cSKU, @cLot, @nQTY, @cToID,
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               GOTO Step_3_Fail
            END
         END
      END

      -- Confirm
      EXECUTE rdt.rdt_PalletConsolidate_BESE_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 
         @cToID, @cToLOC, @cLot, @cSKU, @nQty, @cFromLOC, @cFromID,
         @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, 
         @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, 
         @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, 
         @nErrNo OUTPUT, @cErrMsg OUTPUT 
      IF @nErrNo <> 0
         GOTO Quit
      
      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cOption, @cSKU, @cLot, @nQty, @cToID, ' +
               '@cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
               '@cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
               '@nScannedCount, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cFromID         NVARCHAR( 20), ' +
               '@cOption         NVARCHAR( 1), '  +
               '@cSKU            NVARCHAR( 20), ' +
               '@cLot            NVARCHAR( 10), ' +
               '@nQty            INT, '           +
               '@cToID           NVARCHAR( 20), ' +
               '@cLottable01     NVARCHAR( 18), ' +
               '@cLottable02     NVARCHAR( 18), ' +
               '@cLottable03     NVARCHAR( 18), ' +
               '@dLottable04     DATETIME, ' +
               '@dLottable05     DATETIME, ' +
               '@cLottable06     NVARCHAR( 30), ' +
               '@cLottable07     NVARCHAR( 30), ' +
               '@cLottable08     NVARCHAR( 30), ' +
               '@cLottable09     NVARCHAR( 30), ' +
               '@cLottable10     NVARCHAR( 30), ' +
               '@cLottable11     NVARCHAR( 30), ' +
               '@cLottable12     NVARCHAR( 30), ' +
               '@dLottable13     DATETIME, ' +
               '@dLottable14     DATETIME, ' +
               '@dLottable15     DATETIME, ' +
               '@nScannedCount   INT, '           +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR( 1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cOption, @cSKU, @cLot, @nQty, @cToID,
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               @nScannedCount, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_3_Fail
         END
      END


      --Back to the current screen
      SET @nScannedCount = @nScannedCount + 1

      SET @cOutField03 = TRY_CAST(@nScannedCount AS NVARCHAR(5))

      GOTO Step_3_Quit 
   END

   IF @nInputKey = 0 -- Esc OR No
   BEGIN
      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cOption, @cSKU, @cLot, @nQty, @cToID, ' +
               '@cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
               '@cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
               '@nScannedCount, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cFromID         NVARCHAR( 20), ' +
               '@cOption         NVARCHAR( 1), '  +
               '@cSKU            NVARCHAR( 20), ' +
               '@cLot            NVARCHAR( 10), ' +
               '@nQty            INT, '           +
               '@cToID           NVARCHAR( 20), ' +
               '@cLottable01     NVARCHAR( 18), ' +
               '@cLottable02     NVARCHAR( 18), ' +
               '@cLottable03     NVARCHAR( 18), ' +
               '@dLottable04     DATETIME, ' +
               '@dLottable05     DATETIME, ' +
               '@cLottable06     NVARCHAR( 30), ' +
               '@cLottable07     NVARCHAR( 30), ' +
               '@cLottable08     NVARCHAR( 30), ' +
               '@cLottable09     NVARCHAR( 30), ' +
               '@cLottable10     NVARCHAR( 30), ' +
               '@cLottable11     NVARCHAR( 30), ' +
               '@cLottable12     NVARCHAR( 30), ' +
               '@dLottable13     DATETIME, ' +
               '@dLottable14     DATETIME, ' +
               '@dLottable15     DATETIME, ' +
               '@nScannedCount   INT, '           +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR( 1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cOption, @cSKU, @cLot, @nQty, @cToID,
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               @nScannedCount, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_5_Fail
         END
      END

      IF @nScannedCount > 0
      BEGIN
         IF @cPalletLabel <> ''
         BEGIN
            --Print pallet label screen
            SET @cOutField01 = ''

            SET @nScn = 6854
            SET @nStep = 5

            GOTO Step_3_Quit
         END
         ELSE
         BEGIN
            --Success screen
            SET @nScn = 6853
            SET @nStep = 4

            GOTO Step_3_Quit
         END
      END
      ELSE
      BEGIN
         --From ID screen
         SET @cToID = ''
         SET @cFromID = ''
         SET @cOption = ''

         SET @cOutField01=''
         SET @cOutField02=''

         SET @nStep = 1
         SET @nScn = 6850

         EXEC rdt.rdtSetFocusField @nMobile, 1
      END
   END

   Step_3_Quit:
      GOTO Quit

   Step_3_Fail:
   BEGIN
      SET @cFromID = ''
      SET @cOutField02 = ''
      EXEC rdt.rdtSetFocusField @nMobile, 2
      GOTO Quit
   END
END
GOTO Quit

/********************************************************************************
Step 4. Screen = 6853
   Success Message
********************************************************************************/
Step_4:
BEGIN
   SET @nScn = 6850
   SET @nStep = 1

   SET @cOutField01 = ''
   SET @cToID = ''
   SET @cToLoc = ''
   SET @cFromID = ''
   SET @nScannedCount = 0

   EXEC rdt.rdtSetFocusField @nMobile, 1
END
GOTO Quit

/********************************************************************************
Step 5. Screen = 6854. Message. Print pallet label?
   Option (field01, input)
********************************************************************************/
Step_5:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cOption = @cInField01

      -- Validate blank
      IF @cOption = ''
      BEGIN
         SET @nErrNo = 260760
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --OptionRequired
         GOTO Quit
      END

      -- Validate option
      IF @cOption <> '1' AND @cOption <> '2'
      BEGIN
         SET @nErrNo = 260761
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option
         EXEC rdt.rdtSetFocusField @nMobile, 1  -- Option
         SET @cOutField01 = ''
         GOTO Quit
      END

      -- Extended Validation
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS(SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cOption, @cSKU, @cLot, @nQty, @cToID, ' +
               '@cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
               '@cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
               '@nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR(3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR(15), ' +
               '@cFromID         NVARCHAR(20), ' +
               '@cOption         NVARCHAR(1), '  +
               '@cSKU            NVARCHAR(20), ' +
               '@cLot            NVARCHAR(10), ' +
               '@nQty            INT, '          +
               '@cToID           NVARCHAR(20), ' +
               '@cLottable01     NVARCHAR(18), ' +
               '@cLottable02     NVARCHAR(18), ' +
               '@cLottable03     NVARCHAR(18), ' +
               '@dLottable04     DATETIME, ' +
               '@dLottable05     DATETIME, ' +
               '@cLottable06     NVARCHAR(30), ' +
               '@cLottable07     NVARCHAR(30), ' +
               '@cLottable08     NVARCHAR(30), ' +
               '@cLottable09     NVARCHAR(30), ' +
               '@cLottable10     NVARCHAR(30), ' +
               '@cLottable11     NVARCHAR(30), ' +
               '@cLottable12     NVARCHAR(30), ' +
               '@dLottable13     DATETIME, ' +
               '@dLottable14     DATETIME, ' +
               '@dLottable15     DATETIME, ' +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR(1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cOption, @cSKU, @cLot, @nQTY, @cToID,
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               GOTO Step_5_Fail
            END
         END
      END

      IF @cOption = '1'  -- Yes
      BEGIN
         -- Get report param
         DECLARE @tPalletLabel AS VariableTable
         INSERT INTO @tPalletLabel (Variable, Value) VALUES
            ( '@cStorerKey',  @cStorerKey),
            ( '@cID',         @cToID)

         -- Print packing list
         EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
            @cPalletLabel, -- Report type
            @tPalletLabel, -- Report params
            'rdtfnc_PalletConsolidate_BESE',
            @nErrNo  OUTPUT,
            @cErrMsg OUTPUT
         IF @nErrNo <> 0
            GOTO Step_5_Fail
      END

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cOption, @cSKU, @cLot, @nQty, @cToID, ' +
               '@cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
               '@cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
               '@nScannedCount, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,       '     +
               '@nFunc           INT,       '     +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,       '     +
               '@nInputKey       INT,       '     +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cFromID         NVARCHAR( 20), ' +
               '@cOption         NVARCHAR( 1), '  +
               '@cSKU            NVARCHAR( 20), ' +
               '@cLot            NVARCHAR( 10), ' +
               '@nQty            INT, '           +
               '@cToID           NVARCHAR( 20), ' +
               '@cLottable01     NVARCHAR( 18), ' +
               '@cLottable02     NVARCHAR( 18), ' +
               '@cLottable03     NVARCHAR( 18), ' +
               '@dLottable04     DATETIME, ' +
               '@dLottable05     DATETIME, ' +
               '@cLottable06     NVARCHAR( 30), ' +
               '@cLottable07     NVARCHAR( 30), ' +
               '@cLottable08     NVARCHAR( 30), ' +
               '@cLottable09     NVARCHAR( 30), ' +
               '@cLottable10     NVARCHAR( 30), ' +
               '@cLottable11     NVARCHAR( 30), ' +
               '@cLottable12     NVARCHAR( 30), ' +
               '@dLottable13     DATETIME, ' +
               '@dLottable14     DATETIME, ' +
               '@dLottable15     DATETIME, ' +
               '@nScannedCount   INT, '           +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR( 1024) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFromID, @cOption, @cSKU, @cLot, @nQty, @cToID,
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               @nScannedCount, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_5_Fail
         END
      END

      -- Go to success screen
      SET @nScn = 6853
      SET @nStep = 4
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      SET @cOutField01 = @cToID
      SET @cOutField02 = ''
      SET @cOutField03 = TRY_CAST(@nScannedCount AS NVARCHAR(5))

      -- Go to statistic screen
      SET @nScn = 6852
      SET @nStep = 3  
   END

   Step_5_Fail:
      SET @cOutField01 = ''
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

      V_StorerKey    = @cStorerKey, 
      Facility       = @cFacility, 
      -- UserName    = @cUserName,
      V_SKU          = @cSKU,
      V_ID           = @cToID,

      V_String1      = @cFromID,
      V_String2      = @cNewIDFlag,
      V_String3      = @cOption,
      V_String4      = @cExtendedUpdateSP,
      V_String5      = @cExtendedValidateSP,
      V_String6      = @cToLOC,
      V_String7      = @cFromLOC,
      V_String8      = @cPalletLabel,

      V_Integer1     = @nScannedCount,

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
      I_Field15 = @cInField15,  O_Field15 = @cOutField15,

      FieldAttr01  = @cFieldAttr01,   FieldAttr02  = @cFieldAttr02,
      FieldAttr03  = @cFieldAttr03,   FieldAttr04  = @cFieldAttr04,
      FieldAttr05  = @cFieldAttr05,   FieldAttr06  = @cFieldAttr06,
      FieldAttr07  = @cFieldAttr07,   FieldAttr08  = @cFieldAttr08,
      FieldAttr09  = @cFieldAttr09,   FieldAttr10  = @cFieldAttr10,
      FieldAttr11  = @cFieldAttr11,   FieldAttr12  = @cFieldAttr12,
      FieldAttr13  = @cFieldAttr13,   FieldAttr14  = @cFieldAttr14,
      FieldAttr15  = @cFieldAttr15 

   WHERE Mobile = @nMobile

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON RDT.rdtfnc_PalletConsolidate_BESE TO NSQL
GO