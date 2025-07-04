SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/*********************************************************************************/
/* Store procedure: rdtfnc_MoveIDBeforeFinalization                              */
/* Copyright      : Maersk WMS                                                   */
/* Customer       : Netherlands                                                  */
/*                                                                               */
/* Purpose: Move ID before finalization                                          */
/*                                                                               */
/*                                                                               */
/* Date       Rev  Author      Purposes                                          */
/* 2025-05-06 1.0  NLT013      FCR-3830 Create                                   */
/*********************************************************************************/

CREATE OR ALTER PROCEDURE [rdt].[rdtfnc_MoveIDBeforeFinalization] (
   @nMobile    INT,
   @nErrNo     INT  OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT
) AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

-- Misc variable
DECLARE
   @b_Success           INT,
   @n_Err               INT,
   @c_ErrMsg            NVARCHAR( 250),
   @nInforMsgNo         INT,
   @cInforMsg           NVARCHAR(20),

   @cOption             NVARCHAR( 1),
   @cSQL                NVARCHAR( MAX),
   @cSQLParam           NVARCHAR( MAX),
   @nRowCount           INT,

   @cExtendedValidateSP NVARCHAR( 20),
   @cExtendedUpdateSP   NVARCHAR( 20),
   @cExtendedInfoSP     NVARCHAR( 20),

   -- Session variable
   @nFunc               INT,
   @nScn                INT,
   @nStep               INT,
   @cLangCode           NVARCHAR( 3),
   @nInputKey           INT,
   @nMenu               INT,
   @cUserName           NVARCHAR( 18),
   @cStorerGroup        NVARCHAR( 20),
   @cStorerKey          NVARCHAR( 15),
   @cFacility           NVARCHAR( 5),
   @cPrinter            NVARCHAR( 10),
   @cPrinter_Paper      NVARCHAR( 10),
   @cOutText1           NVARCHAR(20),
   @cOutText2           NVARCHAR(20),
   @cOutText3           NVARCHAR(20),

   @cID                 NVARCHAR( 18),
   @cFromLOC            NVARCHAR( 10),
   @cToLoc              NVARCHAR( 10),
   @cReceiptKey         NVARCHAR( 10),
   @cReceiptLineNumber  NVARCHAR( 5),
   @cSKU                NVARCHAR( 20),
   @cASNStatus          NVARCHAR( 10),
   @cDefaultFromLOC     NVARCHAR( 10),
   @cIDDefaultFromLOC   NVARCHAR( 10),
   @cLOCLookupSP        NVARCHAR( 20),
   @cToLOCLookupSP      NVARCHAR( 20),
   @cScannedLocFacility NVARCHAR( 5),
   @nTotalRec           INT,
   @nCurrentRec         INT,
   @nTranCount          INT,
   @nMultiStorer        INT,
   @cSuggToLoc          NVARCHAR( 10),

   @cSKUDescr           NVARCHAR( 60),
   @cPUOM_Desc          NVARCHAR( 5),
   @cMUOM_Desc          NVARCHAR( 5),
   @nPUOM_Div           INT,
   @cPUOM               NVARCHAR(1),
   @nQTY                INT,
   @nMQTY               INT,
   @nPQTY               INT,
   
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
   
   @cInField01 NVARCHAR( 60),   @cOutField01 NVARCHAR( 60),    @cFieldAttr01 NVARCHAR( 1),
   @cInField02 NVARCHAR( 60),   @cOutField02 NVARCHAR( 60),    @cFieldAttr02 NVARCHAR( 1),
   @cInField03 NVARCHAR( 60),   @cOutField03 NVARCHAR( 60),    @cFieldAttr03 NVARCHAR( 1),
   @cInField04 NVARCHAR( 60),   @cOutField04 NVARCHAR( 60),    @cFieldAttr04 NVARCHAR( 1),
   @cInField05 NVARCHAR( 60),   @cOutField05 NVARCHAR( 60),    @cFieldAttr05 NVARCHAR( 1),
   @cInField06 NVARCHAR( 60),   @cOutField06 NVARCHAR( 60),    @cFieldAttr06 NVARCHAR( 1),
   @cInField07 NVARCHAR( 60),   @cOutField07 NVARCHAR( 60),    @cFieldAttr07 NVARCHAR( 1),
   @cInField08 NVARCHAR( 60),   @cOutField08 NVARCHAR( 60),    @cFieldAttr08 NVARCHAR( 1), 
   @cInField09 NVARCHAR( 60),   @cOutField09 NVARCHAR( 60),    @cFieldAttr09 NVARCHAR( 1),
   @cInField10 NVARCHAR( 60),   @cOutField10 NVARCHAR( 60),    @cFieldAttr10 NVARCHAR( 1),
   @cInField11 NVARCHAR( 60),   @cOutField11 NVARCHAR( 60),    @cFieldAttr11 NVARCHAR( 1),
   @cInField12 NVARCHAR( 60),   @cOutField12 NVARCHAR( 60),    @cFieldAttr12 NVARCHAR( 1),
   @cInField13 NVARCHAR( 60),   @cOutField13 NVARCHAR( 60),    @cFieldAttr13 NVARCHAR( 1),
   @cInField14 NVARCHAR( 60),   @cOutField14 NVARCHAR( 60),    @cFieldAttr14 NVARCHAR( 1),
   @cInField15 NVARCHAR( 60),   @cOutField15 NVARCHAR( 60),    @cFieldAttr15 NVARCHAR( 1)

-- Load RDT.RDTMobRec
SELECT
   @nFunc                  = Func,
   @nScn                   = Scn,
   @nStep                  = Step,
   @nInputKey              = InputKey,
   @nMenu                  = Menu,
   @cLangCode              = Lang_code,

   @cStorerGroup           = StorerGroup,
   @cFacility              = Facility,
   @cPrinter               = Printer,
   @cUserName              = UserName,
   @cPrinter_Paper         = Printer_Paper,

   @cStorerKey             = V_StorerKey,
   @cSKU                   = V_SKU, 
   @cID                    = V_ID,
   @cPUOM                  = V_UOM,
   @cSKUDescr              = V_SKUDescr,

   @cLottable01            = V_Lottable01,
   @cLottable02            = V_Lottable02,
   @cLottable03            = V_Lottable03,
   @dLottable04            = V_Lottable04,
   @dLottable05            = V_Lottable05,
   @cLottable06            = V_Lottable06,
   @cLottable07            = V_Lottable07,
   @cLottable08            = V_Lottable08,
   @cLottable09            = V_Lottable09,
   @cLottable10            = V_Lottable10,
   @cLottable11            = V_Lottable11,
   @cLottable12            = V_Lottable12,
   @dLottable13            = V_Lottable13,
   @dLottable14            = V_Lottable14,
   @dLottable15            = V_Lottable15,

   @cReceiptKey            = V_String1,
   @cReceiptLineNumber     = V_String2,
   @cDefaultFromLOC        = V_String3,
   @cLOCLookupSP           = V_String4,

   @cFromLOC               = V_String5,
   @cPUOM_Desc             = V_String6,
   @cMUOM_Desc             = V_String7,
   @cToLOCLookupSP         = V_String8,
   @cIDDefaultFromLOC      = V_String9,
   @cSuggToLoc             = V_String10,

   @cExtendedValidateSP    = V_String30,
   @cExtendedUpdateSP      = V_String31,
   @cExtendedInfoSP        = V_String32,

   @nTotalRec              = V_Integer1,
   @nCurrentRec            = V_Integer2,
   @nPQTY                  = V_Integer3,
   @nMQTY                  = V_Integer4,
   @nMultiStorer           = V_Integer5,

   @cInField01 = I_Field01,   @cOutField01 = O_Field01,  @cFieldAttr01 = FieldAttr01,
   @cInField02 = I_Field02,   @cOutField02 = O_Field02,  @cFieldAttr02 = FieldAttr02,
   @cInField03 = I_Field03,   @cOutField03 = O_Field03,  @cFieldAttr03 = FieldAttr03,
   @cInField04 = I_Field04,   @cOutField04 = O_Field04,  @cFieldAttr04 = FieldAttr04,
   @cInField05 = I_Field05,   @cOutField05 = O_Field05,  @cFieldAttr05 = FieldAttr05,
   @cInField06 = I_Field06,   @cOutField06 = O_Field06,  @cFieldAttr06 = FieldAttr06,
   @cInField07 = I_Field07,   @cOutField07 = O_Field07,  @cFieldAttr07 = FieldAttr07,
   @cInField08 = I_Field08,   @cOutField08 = O_Field08,  @cFieldAttr08 = FieldAttr08,
   @cInField09 = I_Field09,   @cOutField09 = O_Field09,  @cFieldAttr09 = FieldAttr09,
   @cInField10 = I_Field10,   @cOutField10 = O_Field10,  @cFieldAttr10 = FieldAttr10,
   @cInField11 = I_Field11,   @cOutField11 = O_Field11,  @cFieldAttr11 = FieldAttr11,
   @cInField12 = I_Field12,   @cOutField12 = O_Field12,  @cFieldAttr12 = FieldAttr12,
   @cInField13 = I_Field13,   @cOutField13 = O_Field13,  @cFieldAttr13 = FieldAttr13,
   @cInField14 = I_Field14,   @cOutField14 = O_Field14,  @cFieldAttr14 = FieldAttr14,
   @cInField15 = I_Field15,   @cOutField15 = O_Field15,  @cFieldAttr15 = FieldAttr15
FROM RDT.RDTMOBREC WITH (NOLOCK)
WHERE Mobile = @nMobile

-- Screen constant
DECLARE
   @nStep_FromID           INT,     @nScn_FromID               INT,
   @nStep_FromLoc          INT,     @nScn_FromLoc              INT,
   @nStep_ToLoc            INT,     @nScn_ToLoc                INT,
   @nStep_Msg              INT,     @nScn_Msg                  INT

SELECT
   @nStep_FromID           = 1,     @nScn_FromID               = 6600,
   @nStep_FromLoc          = 2,     @nScn_FromLoc              = 6601,
   @nStep_ToLoc            = 3,     @nScn_ToLoc                = 6602,
   @nStep_Msg              = 4,     @nScn_Msg                  = 6603

-- Redirect to respective screen
IF @nFunc = 664
BEGIN
   IF @nStep = 0                 GOTO Step_0                -- Func = 664. Menu
   IF @nStep = @nStep_FromID     GOTO Step_FromID           -- Scn  = 6600. FromID
   IF @nStep = @nStep_FromLoc    GOTO Step_FromLoc          -- Scn  = 6601. FromLoc
   IF @nStep = @nStep_ToLoc      GOTO Step_ToLoc            -- Scn  = 6602. ToLoc
   IF @nStep = @nStep_Msg        GOTO Step_Msg              -- Scn  = 6603. Msg
END

RETURN -- Do nothing if incorrect step


/********************************************************************************
Step 0. func = 1157. Menu
   @nStep = 0
********************************************************************************/
Step_0:
BEGIN
   -- EventLog
   EXEC rdt.rdt_STD_EventLog
      @cActionType = '1', -- Sign-in
      @cUserID     = @cUserName,
      @nMobileNo   = @nMobile,
      @nFunctionID = @nFunc,
      @cFacility   = @cFacility,
      @cStorerKey  = @cStorerKey

   SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)
   IF @cExtendedValidateSP = '0'
      SET @cExtendedValidateSP = ''
   SET @cExtendedInfoSP = rdt.RDTGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerKey)
   IF @cExtendedInfoSP = '0'
      SET @cExtendedInfoSP = ''
   SET @cExtendedUpdateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)
   IF @cExtendedUpdateSP = '0'
      SET @cExtendedUpdateSP = ''

   SET @cDefaultFromLOC = ISNULL(rdt.RDTGetConfig( @nFunc, 'DefaultFromLoc', @cStorerKey), '')
   SET @cSuggToLoc = ISNULL(rdt.RDTGetConfig( @nFunc, 'SuggToLoc', @cStorerKey), '')

   SET @cLOCLookupSP = rdt.rdtGetConfig( @nFunc, 'LOCLookUPSP', @cStorerKey)
   IF @cLOCLookupSP = '0'
      SET @cLOCLookupSP = ''

   SET @cToLOCLookupSP = rdt.RDTGetConfig( @nFunc, 'MoveByIDToLOCLookup', @cStorerkey) --(ung01)
      IF @cToLOCLookupSP = '0'
         SET @cToLOCLookupSP = ''

   SET @nMultiStorer = 0
   IF EXISTS (SELECT 1 FROM dbo.StorerGroup WITH (NOLOCK) WHERE StorerGroup = @cStorerKey)
      SET @nMultiStorer = 1

   -- Get preferred UOM
   SELECT @cPUOM = DefaultUOM FROM rdt.rdtUser WITH (NOLOCK) WHERE UserName = SUSER_SNAME()

   SET @cIDDefaultFromLOC = ''
   SET @cSKUDescr = ''
   SET @cPUOM_Desc = ''
   SET @cMUOM_Desc = ''
   SET @nPUOM_Div  = ''
   SET @nMQTY = 0
   SET @nPQTY = 0

   -- Prepare next screen var
   SET @cOutField01 = '' -- FromID

   -- Set the entry point
   SET @nScn = @nScn_FromID
   SET @nStep = @nStep_FromID
END
GOTO Quit


/********************************************************************************
Step_ID (Step 1). Scn = 6600. FromID screen
   FromID           (field01, input)
********************************************************************************/
Step_FromID:
BEGIN
   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      SET @cID = @cInField01

      IF @cID = ''
      BEGIN
         SET @nErrNo = 237751
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID Needed
         GOTO Step_FromID_Fail
      END

      SELECT @nRowCount = COUNT(1)
      FROM dbo.LOTXLOCXID WITH(NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND ID = @cID
         AND Qty > 0

      IF @nRowCount > 0
      BEGIN
         SET @nErrNo = 237752
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Stock Exists
         GOTO Step_FromID_Fail
      END

      SELECT TOP 1 @cASNStatus = ASNStatus,
         @cIDDefaultFromLOC = ToLoc
      FROM dbo.RECEIPT RC WITH(NOLOCK)
      INNER JOIN dbo.RECEIPTDETAIL RCD WITH(NOLOCK) ON RC.StorerKey = RCD.StorerKey AND RC.ReceiptKey = RCD.ReceiptKey
      WHERE RC.StorerKey = @cStorerKey
         AND RCD.ToID = @cID

      SELECT @nRowCount = @@ROWCOUNT

      IF @nRowCount = 0
      BEGIN
         SET @nErrNo = 237753
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid ID
         GOTO Step_FromID_Fail
      END

      IF @cASNStatus IN ('9', 'CANC')
      BEGIN
         SET @nErrNo = 237754
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ASN is finalized or cancelled
         GOTO Step_FromID_Fail
      END

      SELECT @nRowCount = COUNT(DISTINCT RCD.ToLoc)
      FROM dbo.RECEIPT RC WITH(NOLOCK)
      INNER JOIN dbo.RECEIPTDETAIL RCD WITH(NOLOCK) ON RC.StorerKey = RCD.StorerKey AND RC.ReceiptKey = RCD.ReceiptKey
      WHERE RC.StorerKey = @cStorerKey
         AND RCD.ToID = @cID
         AND BeforeReceivedQty > 0
         AND ASNStatus NOT IN ('9', 'CANC')

      IF @nRowCount > 1
      BEGIN
         SET @nErrNo = 237759
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --From Loc > 1
         GOTO Step_FromID_Fail
      END

      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cID, @cFromLoc, @cToLoc, @cSKU, ' +
               ' @cReceiptKey, @cReceiptLineNumber, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile      INT,           ' +
               '@nFunc        INT,           ' +
               '@cLangCode    NVARCHAR( 3),  ' +
               '@nStep        INT,           ' +
               '@nInputKey    INT,           ' +
               '@cFacility    NVARCHAR( 5),  ' +
               '@cStorerKey   NVARCHAR( 15), ' +
               '@cID          NVARCHAR( 18), ' +
               '@cFromLOC     NVARCHAR( 10), ' +
               '@cToLOC       NVARCHAR( 10), ' +
               '@cSKU         NVARCHAR( 20), ' +
               '@cReceiptKey  NVARCHAR( 10), ' +
               '@cReceiptLineNumber NVARCHAR( 10), ' +
               '@nErrNo             INT            OUTPUT, ' +
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cID, @cFromLoc, @cToLoc, @cSKU,
               @cReceiptKey, @cReceiptLineNumber,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_FromID_Fail
         END
      END

      SET @nCurrentRec = 0

      SET @cOutField01 = @cID    -- ID

      IF @cDefaultFromLOC = '1'
      BEGIN
         SET @cInField02 = @cIDDefaultFromLOC -- FromLoc
         GOTO Step_FromLoc
      END
      ELSE
         SET @cOutField02 = ''

      SET @nScn  = @nScn_FromLoc
      SET @nStep = @nStep_FromLoc

      -- EventLog
      EXEC RDT.rdt_STD_EventLog
         @cUserID     = @cUserName,
         @nMobileNo   = @nMobile,
         @nFunctionID = @nFunc,
         @cFacility   = @cFacility,
         @cStorerKey  = @cStorerKey,
         @nStep       = @nStep,
         @cID         = @cID
   END

   IF @nInputKey = 0 -- Esc or No
   BEGIN
      -- EventLog
      EXEC RDT.rdt_STD_EventLog
         @cActionType = '9', -- Sign-Out
         @cUserID     = @cUserName,
         @nMobileNo   = @nMobile,
         @nFunctionID = @nFunc,
         @cFacility   = @cFacility,
         @cStorerKey  = @cStorerKey

      -- Back to menu
      SET @nFunc = @nMenu
      SET @nScn  = @nMenu
      SET @nStep = 0

      SET @cOutField01 = ''
   END
   GOTO Quit

   Step_FromID_Fail:
   BEGIN
      -- Reset this screen var
      SET @cOutField01 = '' -- ID
      SET @cID         = ''

     -- Go back to current screen again
      SET @nScn  = @nScn_FromID
      SET @nStep = @nStep_FromID
   END
END
GOTO Quit


/********************************************************************************
Step_FromLoc (Step 2). Scn = 6601. FromLoc screen
   From ID              (field01)
   From Loc             (field02, input)
********************************************************************************/
Step_FromLoc:
BEGIN
   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      SET @cFromLoc = @cInField02
      
      IF @cFromLoc = ''
      BEGIN
         SET @nErrNo = 237755
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Loc Needed
         GOTO Step_FromLoc_Fail
      END

      IF @cLOCLookupSP = '1'
      BEGIN
         EXEC rdt.rdt_LOCLookUp @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFacility,
            @cFromLoc   OUTPUT,
            @nErrNo     OUTPUT,
            @cErrMsg    OUTPUT

         IF @nErrNo <> 0
            GOTO Step_FromLoc_Fail
      END

      SELECT @cScannedLocFacility = Facility
      FROM dbo.LOC WITH(NOLOCK)
      WHERE Loc = @cFromLoc

      SELECT @nRowCount = @@ROWCOUNT

      IF @nRowCount = 0
      BEGIN
         SET @nErrNo = 237756
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Loc
         GOTO Step_FromLoc_Fail
      END

      IF @cScannedLocFacility <> @cFacility
      BEGIN
         SET @nErrNo = 237757
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Different facility
         GOTO Step_FromLoc_Fail
      END

      SELECT @cReceiptKey = ReceiptKey,
         @cReceiptLineNumber = ReceiptLineNumber
      FROM dbo.RECEIPTDETAIL WITH(NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND ToID = @cID
         AND ToLoc = @cFromLoc
         AND BeforeReceivedQty > 0

      SELECT @nRowCount = @@ROWCOUNT

      IF @nRowCount = 0
      BEGIN
         SET @nErrNo = 237758
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No record is found in ASN Details
         GOTO Step_FromLoc_Fail
      END

      SET @cScannedLocFacility = ''

      SELECT @cScannedLocFacility = Facility
      FROM dbo.LOC WITH(NOLOCK)
      WHERE LOC = @cFromLoc

      IF @@ROWCOUNT = 0
      BEGIN
         SET @nErrNo = 237760
         SET @cErrMsg = rdt.rdtgetmessage( 60604, @cLangCode, 'DSP') --Invalid Loc
         GOTO Step_FromLoc_Fail
      END

      -- Validate FromLoc's facility
      IF @cScannedLocFacility <> @cFacility
      BEGIN
         SET @nErrNo = 237761
         SET @cErrMsg = rdt.rdtgetmessage( 60605, @cLangCode, 'DSP') --Different facility
         GOTO Step_FromLoc_Fail
      END

      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cID, @cFromLoc, @cToLoc, @cSKU, ' +
               ' @cReceiptKey, @cReceiptLineNumber, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile      INT,           ' +
               '@nFunc        INT,           ' +
               '@cLangCode    NVARCHAR( 3),  ' +
               '@nStep        INT,           ' +
               '@nInputKey    INT,           ' +
               '@cFacility    NVARCHAR( 5),  ' +
               '@cStorerKey   NVARCHAR( 15), ' +
               '@cID          NVARCHAR( 18), ' +
               '@cFromLOC     NVARCHAR( 10), ' +
               '@cToLOC       NVARCHAR( 10), ' +
               '@cSKU         NVARCHAR( 20), ' +
               '@cReceiptKey  NVARCHAR( 10), ' +
               '@cReceiptLineNumber NVARCHAR( 10), ' +
               '@nErrNo             INT            OUTPUT, ' +
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cID, @cFromLoc, @cToLoc, @cSKU,
               @cReceiptKey, @cReceiptLineNumber,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_FromLoc_Fail
         END
      END

      SELECT
         @nTotalRec = COUNT( DISTINCT SKU.SKU) -- Total no of SKU
      FROM dbo.RECEIPTDETAIL RCD (NOLOCK)
      INNER JOIN dbo.SKU SKU (NOLOCK) ON (RCD.StorerKey = SKU.StorerKey AND RCD.SKU = SKU.SKU)
      WHERE RCD.StorerKey = @cStorerKey
         AND RCD.ToID = @cID
         AND RCD.ToLoc = @cFromLoc
         AND RCD.BeforeReceivedQty > 0

      SELECT TOP 1 @cSKU = SKU,
         @nQTY = SUM( BeforeReceivedQty) -- Total QTY
      FROM dbo.RECEIPTDETAIL WITH(NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND ToID = @cID
         AND ToLoc = @cFromLoc
         AND BeforeReceivedQty > 0
      GROUP BY SKU
      ORDER BY SKU

      SET @cSKUDescr = ''
      SET @cPUOM_Desc = ''
      SET @cMUOM_Desc = ''
      SET @nPUOM_Div  = ''
      SET @nMQTY = 0
      SET @nPQTY = 0

      -- Get Pack info
      SELECT
         @cSKUDescr = SKU.Descr,
         @cMUOM_Desc = Pack.PackUOM3,
         @cPUOM_Desc =
            CASE @cPUOM
               WHEN '2' THEN Pack.PackUOM1 -- Case
               WHEN '3' THEN Pack.PackUOM2 -- Inner pack
               WHEN '6' THEN Pack.PackUOM3 -- Master unit
               WHEN '1' THEN Pack.PackUOM4 -- Pallet
               WHEN '4' THEN Pack.PackUOM8 -- Other unit 1
               WHEN '5' THEN Pack.PackUOM9 -- Other unit 2
            END,
         @nPUOM_Div = CAST( IsNULL(
            CASE @cPUOM
               WHEN '2' THEN Pack.CaseCNT
               WHEN '3' THEN Pack.InnerPack
               WHEN '6' THEN Pack.QTY
               WHEN '1' THEN Pack.Pallet
               WHEN '4' THEN Pack.OtherUnit1
               WHEN '5' THEN Pack.OtherUnit2
            END, 1) AS INT)
      FROM dbo.SKU SKU (NOLOCK)
      INNER JOIN dbo.Pack Pack (NOLOCK) ON (SKU.PackKey = Pack.PackKey)
      WHERE SKU.StorerKey =  @cStorerKey
         AND SKU.SKU = @cSKU

      -- Convert to prefer UOM QTY
      IF @cPUOM = '6' OR -- When preferred UOM = master unit
         @nPUOM_Div = 0 -- UOM not setup
      BEGIN
         SET @cPUOM_Desc = ''
         SET @nPQTY = 0
         SET @nMQTY = @nQTY
      END
      ELSE
      BEGIN
         SET @nPQTY = @nQTY / @nPUOM_Div  -- Calc QTY in preferred UOM
         SET @nMQTY = @nQTY % @nPUOM_Div  -- Calc the remaining in master unit
      END

      -- Prep next screen var
      SET @nCurrentRec = 1
      SET @cToLOC = ''
      SET @cOutField01 = @cID
      SET @cOutField02 = @cFromLOC
      SET @cOutField03 = CAST( @nCurrentRec AS NVARCHAR( 5)) + '/' + CAST( @nTotalRec AS NVARCHAR( 5))
      SET @cOutField04 = @cSKU
      SET @cOutField05 = SUBSTRING( @cSKUDescr, 1, 20)
      SET @cOutField06 = SUBSTRING( @cSKUDescr, 21, 20)
      SET @cOutField07 = @cPUOM_Desc
      SET @cOutField08 = CASE WHEN @cPUOM_Desc = '' THEN '' ELSE CAST( @nPQTY AS NVARCHAR( 5)) END
      SET @cOutField09 = @cMUOM_Desc
      SET @cOutField10 = CAST( @nMQTY AS NVARCHAR( 5))
      SET @cOutField11 = ''   -- ToLoc

      SET @nScn  = @nScn_ToLoc
      SET @nStep = @nStep_ToLoc

      -- EventLog
      EXEC RDT.rdt_STD_EventLog
         @cUserID     = @cUserName,
         @nMobileNo   = @nMobile,
         @nFunctionID = @nFunc,
         @cFacility   = @cFacility,
         @cStorerKey  = @cStorerKey,
         @nStep       = @nStep,
         @cID         = @cID,
         @cLocation   = @cFromLoc
   END

   IF @nInputKey = 0 -- Esc or No
   BEGIN
      -- Reset this screen var
      SET @cOutField01 = '' -- ID
      SET @cID         = ''

     -- Go back to current screen again
      SET @nScn  = @nScn_FromID
      SET @nStep = @nStep_FromID
   END

   IF @cExtendedInfoSP <> '' 
   BEGIN
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
      BEGIN
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cID, @cFromLoc , @cToLOC, @cSKU, @cReceiptKey,@cReceiptLineNumber, @cOutText1 OUTPUT, @cOutText2 OUTPUT, @cOutText3 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
         SET @cSQLParam =
            '@nMobile         INT,                     ' +  
            '@nFunc           INT,                     ' + 
            '@cLangCode       NVARCHAR( 3),            ' + 
            '@nStep           INT,                     ' + 
            '@nInputKey       INT,                     ' + 
            '@cStorerKey      NVARCHAR( 15),           ' + 
            '@cID          NVARCHAR( 18),              ' +
            '@cFromLOC     NVARCHAR( 10),              ' +
            '@cToLOC       NVARCHAR( 10),              ' +
            '@cSKU         NVARCHAR( 20),              ' +
            '@cReceiptKey  NVARCHAR( 10),              ' +
            '@cReceiptLineNumber NVARCHAR( 10),        ' +
            '@cOutText1       NVARCHAR( 20) OUTPUT,    ' + 
            '@cOutText2       NVARCHAR( 20) OUTPUT,    ' + 
            '@cOutText3       NVARCHAR( 20) OUTPUT,    ' + 
            '@nErrNo          INT OUTPUT,              ' + 
            '@cErrMsg         NVARCHAR( 20) OUTPUT     ' 

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cID, @cFromLOC , @cToLoc, @cSKU, @cReceiptKey,@cReceiptLineNumber,  @cOutText1 OUTPUT, @cOutText2 OUTPUT, @cOutText3 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

         IF @nErrNo <> 0
         BEGIN
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
            GOTO Step_FromLoc_Fail
         END
         
         SET @cOutField12 = @cOutText1  -- Extended Info 1
      END
   END 
   GOTO Quit

   Step_FromLoc_Fail:
   BEGIN
      -- Reset this screen var
      SET @cOutField01     = @cID      -- ID

      IF @cDefaultFromLOC = '1'
         SET @cOutField02 = @cIDDefaultFromLOC
      ELSE
         SET @cOutField02 = ''
   END
END
GOTO Quit

/********************************************************************************
Step_ToLoc (Step 3). Scn = 6602. ToLoc screen
   From ID              (field01)
   From Loc             (field02)
   SKU                  (field03)
   SKU Code             (field04)
   SKU Desc1            (field05)
   SKU Desc2            (field06)
   UOM                  (field07, field09)
   Qty                  (field08, field10)
   To Loc               (field11, input)
********************************************************************************/
Step_ToLoc:
BEGIN
   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      SET @cToLoc = @cInField11

      -- If ToLoc is empty, then go to next SKU
      IF @cToLoc = ''
      BEGIN
         SELECT TOP 1 @cSKU = SKU,
             @nQTY = SUM(BeforeReceivedQty) -- Total QTY
         FROM dbo.RECEIPTDETAIL WITH(NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND ToID = @cID
            AND ToLoc = @cFromLoc
            AND BeforeReceivedQty > 0
            AND SKU > @cSKU
         GROUP BY SKU
         ORDER BY SKU

         IF @@ROWCOUNT = 0
         BEGIN
            SET @nErrNo = 237762
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No more SKU to process
            GOTO Step_ToLoc_Fail
         END

         SET @cSKUDescr = ''
         SET @cPUOM_Desc = ''
         SET @cMUOM_Desc = ''
         SET @nPUOM_Div  = ''
         SET @nMQTY = 0
         SET @nPQTY = 0

         -- Get Pack info
         SELECT
            @cSKUDescr = SKU.Descr,
            @cMUOM_Desc = Pack.PackUOM3,
            @cPUOM_Desc =
               CASE @cPUOM
                  WHEN '2' THEN Pack.PackUOM1 -- Case
                  WHEN '3' THEN Pack.PackUOM2 -- Inner pack
                  WHEN '6' THEN Pack.PackUOM3 -- Master unit
                  WHEN '1' THEN Pack.PackUOM4 -- Pallet
                  WHEN '4' THEN Pack.PackUOM8 -- Other unit 1
                  WHEN '5' THEN Pack.PackUOM9 -- Other unit 2
               END,
            @nPUOM_Div = CAST( IsNULL(
               CASE @cPUOM
                  WHEN '2' THEN Pack.CaseCNT
                  WHEN '3' THEN Pack.InnerPack
                  WHEN '6' THEN Pack.QTY
                  WHEN '1' THEN Pack.Pallet
                  WHEN '4' THEN Pack.OtherUnit1
                  WHEN '5' THEN Pack.OtherUnit2
               END, 1) AS INT)
         FROM dbo.SKU SKU (NOLOCK)
            INNER JOIN dbo.Pack Pack (NOLOCK) ON (SKU.PackKey = Pack.PackKey)
         WHERE SKU.StorerKey = @cStorerKey
            AND SKU.SKU = @cSKU

         -- Convert to prefer UOM QTY
         IF @cPUOM = '6' OR -- When preferred UOM = master unit
            @nPUOM_Div = 0 -- UOM not setup
         BEGIN
            SET @cPUOM_Desc = ''
            SET @nPQTY = 0
            SET @nMQTY = @nQTY
         END
         ELSE
         BEGIN
            SET @nPQTY = @nQTY / @nPUOM_Div  -- Calc QTY in preferred UOM
            SET @nMQTY = @nQTY % @nPUOM_Div  -- Calc the remaining in master unit
         END

         -- Prep next screen var
         SET @cToLOC = ''
         SET @cOutField01 = @cID
         SET @cOutField02 = @cFromLOC
         SET @cOutField03 = CAST( @nCurrentRec + 1 AS NVARCHAR( 5)) + '/' + CAST( @nTotalRec AS NVARCHAR( 5))
         SET @cOutField04 = @cSKU
         SET @cOutField05 = SUBSTRING( @cSKUDescr, 1, 20)
         SET @cOutField06 = SUBSTRING( @cSKUDescr, 21, 20)
         SET @cOutField07 = @cPUOM_Desc
         SET @cOutField08 = CASE WHEN @cPUOM_Desc = '' THEN '' ELSE CAST( @nPQTY AS NVARCHAR( 5)) END
         SET @cOutField09 = @cMUOM_Desc
         SET @cOutField10 = CAST( @nMQTY AS NVARCHAR( 5))
         SET @cOutField11 = ''   -- ToLoc

         SET @nScn  = @nScn_ToLoc
         SET @nStep = @nStep_ToLoc

         SET @nCurrentRec = @nCurrentRec + 1
      END
      ELSE -- If the ToLoc is not empty, then move the ID to the ToLoc
      BEGIN
         -- add loc prefix 
         IF @cLOCLookupSP = 1
         BEGIN
            EXEC rdt.rdt_LOCLookUp @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFacility,
               @cToLOC      OUTPUT,
               @nErrNo      OUTPUT,
               @cErrMsg     OUTPUT
            IF @nErrNo <> 0
               GOTO Step_ToLoc_Fail
         END

         -- ToLOC lookup 
         IF @cToLOCLookupSP <> ''
         BEGIN
            IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cToLOCLookupSP AND type = 'P')
            BEGIN
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cToLOCLookupSP) + ' @cReceiptKey, @cReceiptLineNumber, @cID, @cFromLOC, @cStorerKey, @cSKU, @cToLOC OUTPUT'
               SET @cSQLParam =
                  '@cReceiptKey  NVARCHAR( 10), ' +
                  '@cReceiptLineNumber NVARCHAR( 10), ' +
                  '@cID          NVARCHAR( 18), ' +
                  '@cFromLOC     NVARCHAR( 10), ' +
                  '@cStorerKey   NVARCHAR( 15), ' +
                  '@cSKU         NVARCHAR( 20), ' +
                  '@cToLOC       NVARCHAR( 10) OUTPUT'

               EXEC sp_ExecuteSQL @cSQL, @cSQLParam
                  ,@cReceiptKey
                  ,@cReceiptLineNumber
                  ,@cID
                  ,@cFromLOC
                  ,@cStorerKey
                  ,@cSKU
                  ,@cToLOC OUTPUT
            END
         END

         -- Get LOC info
         SELECT @cScannedLocFacility = Facility
         FROM dbo.LOC (NOLOCK)
         WHERE LOC = @cToLOC

         -- Validate LOC
         IF @@ROWCOUNT = 0
         BEGIN
            SET @nErrNo = 237763
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Loc
            GOTO Step_ToLoc_Fail
         END

         -- Validate LOC's facility
         IF @cScannedLocFacility <> @cFacility
         BEGIN
            SET @nErrNo = 237764
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Different facility
            GOTO Step_ToLoc_Fail
         END

         -- Validate FromLOC same as ToLOC
         IF @cFromLOC = @cToLOC
         BEGIN
            SET @nErrNo = 237765
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ToLoc cannot be the same as FromLoc
            GOTO Step_ToLoc_Fail
         END

         -- Extended validate
         IF @cExtendedValidateSP <> ''
         BEGIN
            IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
            BEGIN
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
                  ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cID, @cFromLoc, @cToLoc, @cSKU, ' +
                  ' @cReceiptKey, @cReceiptLineNumber, ' +
                  ' @nErrNo OUTPUT, @cErrMsg OUTPUT'
               SET @cSQLParam =
                  '@nMobile      INT,           ' +
                  '@nFunc        INT,           ' +
                  '@cLangCode    NVARCHAR( 3),  ' +
                  '@nStep        INT,           ' +
                  '@nInputKey    INT,           ' +
                  '@cFacility    NVARCHAR( 5),  ' +
                  '@cStorerKey   NVARCHAR( 15), ' +
                  '@cID          NVARCHAR( 18), ' +
                  '@cFromLOC     NVARCHAR( 10), ' +
                  '@cToLOC       NVARCHAR( 10), ' +
                  '@cSKU         NVARCHAR( 20), ' +
                  '@cReceiptKey  NVARCHAR( 10), ' +
                  '@cReceiptLineNumber NVARCHAR( 10), ' +
                  '@nErrNo             INT            OUTPUT, ' +
                  '@cErrMsg            NVARCHAR( 20)  OUTPUT'

               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                  @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cID, @cFromLoc, @cToLoc, @cSKU,
                  @cReceiptKey, @cReceiptLineNumber,
                  @nErrNo OUTPUT, @cErrMsg OUTPUT

               IF @nErrNo <> 0
                  GOTO Step_ToLoc_Fail
            END
         END

         SET @nTranCount = @@TRANCOUNT
         BEGIN TRAN
         SAVE TRAN rdtfnc_MoveIDBeforeFinalization

         BEGIN TRY
            UPDATE dbo.RECEIPTDETAIL WITH (ROWLOCK)
            SET ToLoc = @cToLoc
            WHERE StorerKey = @cStorerKey
               AND ToID = @cID
               AND ToLoc = @cFromLoc
               AND BeforeReceivedQty > 0

            -- Extended validate
            IF @cExtendedUpdateSP <> ''
            BEGIN
               IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')
               BEGIN
                  SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cID, @cFromLoc, @cToLoc, @cSKU, ' +
                     ' @cReceiptKey, @cReceiptLineNumber, ' +
                     ' @nErrNo OUTPUT, @cErrMsg OUTPUT'
                  SET @cSQLParam =
                     '@nMobile      INT,           ' +
                     '@nFunc        INT,           ' +
                     '@cLangCode    NVARCHAR( 3),  ' +
                     '@nStep        INT,           ' +
                     '@nInputKey    INT,           ' +
                     '@cFacility    NVARCHAR( 5),  ' +
                     '@cStorerKey   NVARCHAR( 15), ' +
                     '@cID          NVARCHAR( 18), ' +
                     '@cFromLOC     NVARCHAR( 10), ' +
                     '@cToLOC       NVARCHAR( 10), ' +
                     '@cSKU         NVARCHAR( 20), ' +
                     '@cReceiptKey  NVARCHAR( 10), ' +
                     '@cReceiptLineNumber NVARCHAR( 10), ' +
                     '@nErrNo             INT            OUTPUT, ' +
                     '@cErrMsg            NVARCHAR( 20)  OUTPUT'

                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                     @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cID, @cFromLoc, @cToLoc, @cSKU,
                     @cReceiptKey, @cReceiptLineNumber,
                     @nErrNo OUTPUT, @cErrMsg OUTPUT

                  IF @nErrNo <> 0
                     GOTO Step_ToLoc_Fail
               END
            END
         END TRY
         BEGIN CATCH
            ROLLBACK TRAN rdtfnc_MoveIDBeforeFinalization
            WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
               COMMIT TRAN
            GOTO Step_ToLoc_Fail
         END CATCH

         COMMIT TRAN rdtfnc_MoveIDBeforeFinalization
         WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
            COMMIT TRAN

         SET @cOutField01 = @cToLoc
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

         SET @nScn  = @nScn_Msg
         SET @nStep = @nStep_Msg
      END

      -- EventLog
      EXEC RDT.rdt_STD_EventLog
         @cUserID     = @cUserName,
         @nMobileNo   = @nMobile,
         @nFunctionID = @nFunc,
         @cFacility   = @cFacility,
         @cStorerKey  = @cStorerKey,
         @nStep       = @nStep,
         @cID         = @cID,
         @cLocation   = @cFromLoc,
         @cToLocation = @cToLoc
   END

   IF @nInputKey = 0 -- Esc or No
   BEGIN
      -- Reset this screen var
      SET @cOutField01 = @cID      -- ID

      IF @cDefaultFromLOC = '1'
         SET @cOutField02 = @cIDDefaultFromLOC
      ELSE
         SET @cOutField02 = ''

      --Go back to previous screen
      SET @nScn  = @nScn_FromLoc
      SET @nStep = @nStep_FromLoc
   END
   GOTO Quit

   Step_ToLoc_Fail:
   BEGIN
      -- Reset this screen var
      SET @cOutField01 = @cID
      SET @cOutField02 = @cFromLOC
      SET @cOutField03 = CAST( @nCurrentRec AS NVARCHAR( 5)) + '/' + CAST( @nTotalRec AS NVARCHAR( 5))
      SET @cOutField04 = @cSKU
      SET @cOutField05 = SUBSTRING( @cSKUDescr, 1, 20)
      SET @cOutField06 = SUBSTRING( @cSKUDescr, 21, 20)
      SET @cOutField07 = @cPUOM_Desc
      SET @cOutField08 = CASE WHEN @cPUOM_Desc = '' THEN '' ELSE CAST( @nPQTY AS NVARCHAR( 5)) END
      SET @cOutField09 = @cMUOM_Desc
      SET @cOutField10 = CAST( @nMQTY AS NVARCHAR( 5))
      SET @cOutField11 = ''
   END
END
GOTO Quit

/********************************************************************************
Step_Msg (Step 4). Scn = 6603. Msg screen
   Msg screen
   ID moved successfully
   To Loc:           (field01)
********************************************************************************/
Step_Msg:
BEGIN
   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      -- Prepare prev screen var
      SET @cOutField01 = ''
      SET @cOutField02 = ''

     --Go back to previous screen
      SET @nScn  = @nScn_FromID
      SET @nStep = @nStep_FromID
   END

   IF @nInputKey = 0 -- Esc or No
   BEGIN
      -- Prepare prev screen var
      SET @cOutField01 = ''
      SET @cOutField02 = ''

     --Go back to previous screen
      SET @nScn  = @nScn_FromID
      SET @nStep = @nStep_FromID
   END
   GOTO Quit

   Step_Msg_Fail:
   BEGIN
      -- Reset this screen var
      SET @cOutField01     = '' -- VAS Code, service type
      SET @cOutField02     = '' -- Option
      SET @cOutField03     = '' -- Information
   END
END
GOTO Quit


/********************************************************************************
Quit. Update back to I/O table, ready to be pick up by JBOSS
********************************************************************************/
Quit:
BEGIN
   UPDATE RDT.RDTMOBREC WITH (ROWLOCK) SET
      EditDate     = GETDATE(),
      ErrMsg       = @cErrMsg,
      Func         = @nFunc,
      Step         = @nStep,
      Scn          = @nScn,
      Facility     = @cFacility,
      Printer      = @cPrinter,

      V_StorerKey  = @cStorerKey,
      V_ID         = @cID,
      V_SKU        = @cSKU,
      V_UOM        = @cPUOM,
      V_SKUDescr   = @cSKUDescr,

      V_String1    = @cReceiptKey,
      V_String2    = @cReceiptLineNumber,
      V_String3    = @cDefaultFromLOC,
      V_String4    = @cLOCLookupSP,
      V_String5    = @cFromLOC,
      V_String6    = @cPUOM_Desc,
      V_String7    = @cMUOM_Desc,
      V_String8    = @cToLOCLookupSP,
      V_String9    = @cIDDefaultFromLOC,
      V_String10   = @cSuggToLoc,

      V_String30   = @cExtendedValidateSP,
      V_String31   = @cExtendedUpdateSP,
      V_String32   = @cExtendedInfoSP,

      V_Integer1   = @nTotalRec,
      V_Integer2   = @nCurrentRec, 
      V_Integer3   = @nPQTY,
      V_Integer4   = @nMQTY,
      V_Integer5   = @nMultiStorer,

      V_Lottable01 = @cLottable01,
      V_Lottable02 = @cLottable02,
      V_Lottable03 = @cLottable03,
      V_Lottable04 = @dLottable04,
      V_Lottable05 = @dLottable05,
      V_Lottable06 = @cLottable06,
      V_Lottable07 = @cLottable07,
      V_Lottable08 = @cLottable08,
      V_Lottable09 = @cLottable09,
      V_Lottable10 = @cLottable10,
      V_Lottable11 = @cLottable11,
      V_Lottable12 = @cLottable12,
      V_Lottable13 = @dLottable13,
      V_Lottable14 = @dLottable14,
      V_Lottable15 = @dLottable15,

     I_Field01 = @cInField01,  O_Field01 = @cOutField01,   FieldAttr01  = @cFieldAttr01,
      I_Field02 = @cInField02,  O_Field02 = @cOutField02,   FieldAttr02  = @cFieldAttr02,
      I_Field03 = @cInField03,  O_Field03 = @cOutField03,   FieldAttr03  = @cFieldAttr03,
      I_Field04 = @cInField04,  O_Field04 = @cOutField04,   FieldAttr04  = @cFieldAttr04,
      I_Field05 = @cInField05,  O_Field05 = @cOutField05,   FieldAttr05  = @cFieldAttr05,
      I_Field06 = @cInField06,  O_Field06 = @cOutField06,   FieldAttr06  = @cFieldAttr06,
      I_Field07 = @cInField07,  O_Field07 = @cOutField07,   FieldAttr07  = @cFieldAttr07,
      I_Field08 = @cInField08,  O_Field08 = @cOutField08,   FieldAttr08  = @cFieldAttr08,
      I_Field09 = @cInField09,  O_Field09 = @cOutField09,   FieldAttr09  = @cFieldAttr09,
      I_Field10 = @cInField10,  O_Field10 = @cOutField10,   FieldAttr10  = @cFieldAttr10,
      I_Field11 = @cInField11,  O_Field11 = @cOutField11,   FieldAttr11  = @cFieldAttr11,
      I_Field12 = @cInField12,  O_Field12 = @cOutField12,   FieldAttr12  = @cFieldAttr12,
      I_Field13 = @cInField13,  O_Field13 = @cOutField13,   FieldAttr13  = @cFieldAttr13,
      I_Field14 = @cInField14,  O_Field14 = @cOutField14,   FieldAttr14  = @cFieldAttr14,
      I_Field15 = @cInField15,  O_Field15 = @cOutField15,   FieldAttr15  = @cFieldAttr15 
   WHERE Mobile = @nMobile
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXEC ON rdt.rdtfnc_MoveIDBeforeFinalization TO NSQL
GO
