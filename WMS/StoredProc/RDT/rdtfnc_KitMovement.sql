SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdtfnc_KitMovement                                  */
/* Copyright: Maersk WMS                                                */
/*                                                                      */
/* Purpose:   UWP-61451. Kit Movement                                   */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2026-07-15 1.0  Dennis   UWP-61451. Created                         */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdtfnc_KitMovement] (
   @nMobile    INT,
   @nErrNo     INT            OUTPUT,
   @cErrMsg    NVARCHAR( 1024) OUTPUT
) AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF

-- RDT.RDTMobRec variables
DECLARE
   @nFunc        INT,
   @nScn         INT,
   @nStep        INT,
   @nInputKey    INT,
   @nMenu        INT,
   @cLangCode    NVARCHAR( 3),
   @cStorerKey   NVARCHAR( 15),
   @cFacility    NVARCHAR( 5),
   @cUserName    NVARCHAR( 18)

-- Business variables
DECLARE
   @cKitTicketNo  NVARCHAR( 20),
   @cLoc          NVARCHAR( 20),
   @cPalletID     NVARCHAR( 20),
   @cSKU          NVARCHAR( 20),
   @cKITFacility     NVARCHAR( 5),
   @cKITStorerKey    NVARCHAR( 15),
   @cKITStatus       NVARCHAR( 10),
   @cKITDetailStatus NVARCHAR( 10),
   @cDispSingleSKU   NVARCHAR( 1),
   @nSKUCount        INT,
   @cAutoSKU         NVARCHAR( 20),
   @cDefaultQTY      NVARCHAR( 10),
   @cDefaultKITQty   NVARCHAR( 1),
   @cLottable01      NVARCHAR( 18),
   @cLottable02      NVARCHAR( 18),
   @cLottable03      NVARCHAR( 18),
   @dLottable04      DATETIME,
   @dLottable05      DATETIME,
   @cLottable06      NVARCHAR( 30),
   @cLottable07      NVARCHAR( 30),
   @cLottable08      NVARCHAR( 30),
   @cLottable09      NVARCHAR( 30),
   @cLottable10      NVARCHAR( 30),
   @cLottable11      NVARCHAR( 30),
   @cLottable12      NVARCHAR( 30),
   @dLottable13      DATETIME,
   @dLottable14      DATETIME,
   @dLottable15      DATETIME,
   @cLottableCode     NVARCHAR( 30),
   @nMorePage         INT,
   @nFromScn          INT,
   @nErrNoBackup      INT,
   @cErrMsgBackup     NVARCHAR( 20),
   @cOutField15Backup NVARCHAR( 60),
   @ctemp_OutField15  NVARCHAR( 60),
   @cQTY              NVARCHAR( 6),
   @nQTY              INT,
   @nExpectedQty      INT,
   @cToPalletID       NVARCHAR( 20),
   @cSkipToID         NVARCHAR( 1),
   @cToLoc            NVARCHAR( 20),
   @cDefaultToLoc     NVARCHAR( 20),
   @cMoveFromID       NVARCHAR( 40),
   @cMoveToID         NVARCHAR( 40),
   @nTranCount        INT

-- Screen field variables
DECLARE
   @cInField01   NVARCHAR( 60),   @cOutField01  NVARCHAR( 60),
   @cInField02   NVARCHAR( 60),   @cOutField02  NVARCHAR( 60),
   @cInField03   NVARCHAR( 60),   @cOutField03  NVARCHAR( 60),
   @cInField04   NVARCHAR( 60),   @cOutField04  NVARCHAR( 60),
   @cInField05   NVARCHAR( 60),   @cOutField05  NVARCHAR( 60),
   @cInField06   NVARCHAR( 60),   @cOutField06  NVARCHAR( 60),
   @cInField07   NVARCHAR( 60),   @cOutField07  NVARCHAR( 60),
   @cInField08   NVARCHAR( 60),   @cOutField08  NVARCHAR( 60),
   @cInField09   NVARCHAR( 60),   @cOutField09  NVARCHAR( 60),
   @cInField10   NVARCHAR( 60),   @cOutField10  NVARCHAR( 60),
   @cInField11   NVARCHAR( 60),   @cOutField11  NVARCHAR( 60),
   @cInField12   NVARCHAR( 60),   @cOutField12  NVARCHAR( 60),
   @cInField13   NVARCHAR( 60),   @cOutField13  NVARCHAR( 60),
   @cInField14   NVARCHAR( 60),   @cOutField14  NVARCHAR( 60),
   @cInField15   NVARCHAR( 60),   @cOutField15  NVARCHAR( 60),

   @cFieldAttr01 NVARCHAR( 1),    @cFieldAttr02 NVARCHAR( 1),
   @cFieldAttr03 NVARCHAR( 1),    @cFieldAttr04 NVARCHAR( 1),
   @cFieldAttr05 NVARCHAR( 1),    @cFieldAttr06 NVARCHAR( 1),
   @cFieldAttr07 NVARCHAR( 1),    @cFieldAttr08 NVARCHAR( 1),
   @cFieldAttr09 NVARCHAR( 1),    @cFieldAttr10 NVARCHAR( 1),
   @cFieldAttr11 NVARCHAR( 1),    @cFieldAttr12 NVARCHAR( 1),
   @cFieldAttr13 NVARCHAR( 1),    @cFieldAttr14 NVARCHAR( 1),
   @cFieldAttr15 NVARCHAR( 1)

-- Load RDT.RDTMobRec
SELECT
   @nFunc        = Func,
   @nScn         = Scn,
   @nStep        = Step,
   @nInputKey    = InputKey,
   @nMenu        = Menu,
   @cLangCode    = Lang_code,
   @cStorerKey   = StorerKey,
   @cFacility    = Facility,
   @cUserName    = UserName,

   @cKitTicketNo   = V_String1,
   @cLoc           = V_String2,
   @cPalletID      = V_String3,
   @cSKU           = V_String4,
   @cDispSingleSKU = V_String5,
   @cDefaultQTY    = V_String6,
   @cDefaultKITQty = V_String7,
   @cSkipToID      = V_String8,
   @cToPalletID    = V_String9,
   @cToLoc         = V_String10,
   @cDefaultToLoc  = V_String11,

   @cLottable01 = V_Lottable01,
   @cLottable02 = V_Lottable02,
   @cLottable03 = V_Lottable03,
   @dLottable04 = V_Lottable04,
   @dLottable05 = V_Lottable05,
   @cLottable06 = V_Lottable06,
   @cLottable07 = V_Lottable07,
   @cLottable08 = V_Lottable08,
   @cLottable09 = V_Lottable09,
   @cLottable10 = V_Lottable10,
   @cLottable11 = V_Lottable11,
   @cLottable12 = V_Lottable12,
   @dLottable13 = V_Lottable13,
   @dLottable14 = V_Lottable14,
   @dLottable15 = V_Lottable15,
   @nFromScn    = V_FromScn,

   @cInField01   = I_Field01,     @cOutField01  = O_Field01,
   @cInField02   = I_Field02,     @cOutField02  = O_Field02,
   @cInField03   = I_Field03,     @cOutField03  = O_Field03,
   @cInField04   = I_Field04,     @cOutField04  = O_Field04,
   @cInField05   = I_Field05,     @cOutField05  = O_Field05,
   @cInField06   = I_Field06,     @cOutField06  = O_Field06,
   @cInField07   = I_Field07,     @cOutField07  = O_Field07,
   @cInField08   = I_Field08,     @cOutField08  = O_Field08,
   @cInField09   = I_Field09,     @cOutField09  = O_Field09,
   @cInField10   = I_Field10,     @cOutField10  = O_Field10,
   @cInField11   = I_Field11,     @cOutField11  = O_Field11,
   @cInField12   = I_Field12,     @cOutField12  = O_Field12,
   @cInField13   = I_Field13,     @cOutField13  = O_Field13,
   @cInField14   = I_Field14,     @cOutField14  = O_Field14,
   @cInField15   = I_Field15,     @cOutField15  = O_Field15,

   @cFieldAttr01 = FieldAttr01,   @cFieldAttr02 = FieldAttr02,
   @cFieldAttr03 = FieldAttr03,   @cFieldAttr04 = FieldAttr04,
   @cFieldAttr05 = FieldAttr05,   @cFieldAttr06 = FieldAttr06,
   @cFieldAttr07 = FieldAttr07,   @cFieldAttr08 = FieldAttr08,
   @cFieldAttr09 = FieldAttr09,   @cFieldAttr10 = FieldAttr10,
   @cFieldAttr11 = FieldAttr11,   @cFieldAttr12 = FieldAttr12,
   @cFieldAttr13 = FieldAttr13,   @cFieldAttr14 = FieldAttr14,
   @cFieldAttr15 = FieldAttr15
FROM dbo.RDTMobRec WITH (NOLOCK)
WHERE Mobile = @nMobile

-- Redirect to respective screen
IF @nFunc = 1881
BEGIN
   IF @nStep = 0 GOTO Step_0   -- Menu. Init
   IF @nStep = 1 GOTO Step_1   -- Scn = 6930. KIT Ticket #
   IF @nStep = 2 GOTO Step_2   -- Scn = 6931. LOC
   IF @nStep = 3 GOTO Step_3   -- Scn = 6932. PALLET ID
   IF @nStep = 4 GOTO Step_4   -- Scn = 6933. SKU
   IF @nStep = 5 GOTO Step_5   -- Scn = 3990. Lottable
   IF @nStep = 6 GOTO Step_6   -- Scn = 6934. QTY
   IF @nStep = 7 GOTO Step_7   -- Scn = 6935. TO PALLET ID
   IF @nStep = 8 GOTO Step_8   -- Scn = 6936. TO LOC
   IF @nStep = 9 GOTO Step_9   -- Scn = 6937. Success
END

RETURN

/********************************************************************************
Step 0. Called from menu
********************************************************************************/
Step_0:
BEGIN
   EXEC RDT.rdt_STD_EventLog
      @cActionType = '1',
      @cUserID     = @cUserName,
      @nMobileNo   = @nMobile,
      @nFunctionID = @nFunc,
      @cFacility   = @cFacility,
      @cStorerKey  = @cStorerKey,
      @nStep       = @nStep

   SET @nScn  = 6930
   SET @nStep = 1

   SET @cKitTicketNo   = ''
   SET @cLoc           = ''
   SET @cPalletID      = ''
   SET @cOutField01    = ''
   SET @cDispSingleSKU = rdt.RDTGetConfig( @nFunc, 'DISPSINGLESKU', @cStorerKey)
   SET @cDefaultQTY    = rdt.RDTGetConfig( @nFunc, 'DefaultQTY',    @cStorerKey)
   SET @cDefaultKITQty = rdt.RDTGetConfig( @nFunc, 'DefaultKITQty', @cStorerKey)
   SET @cSkipToID      = rdt.RDTGetConfig( @nFunc, 'SKIPTOID',      @cStorerKey)
   SET @cDefaultToLoc  = rdt.RDTGetConfig( @nFunc, 'DEFAULTTOLOC',  @cStorerKey)

   SET @cToPalletID = ''
   SET @cToLoc      = ''
   SET @nFromScn    = 0
   SET @cLottable01 = '' SET @cLottable02 = '' SET @cLottable03 = ''
   SET @dLottable04 = 0  SET @dLottable05 = 0
   SET @cLottable06 = '' SET @cLottable07 = '' SET @cLottable08 = ''
   SET @cLottable09 = '' SET @cLottable10 = ''
   SET @cLottable11 = '' SET @cLottable12 = ''
   SET @dLottable13 = 0  SET @dLottable14 = 0  SET @dLottable15 = 0

   SET @cFieldAttr01 = '' SET @cFieldAttr02 = '' SET @cFieldAttr03 = ''
   SET @cFieldAttr04 = '' SET @cFieldAttr05 = '' SET @cFieldAttr06 = ''
   SET @cFieldAttr07 = '' SET @cFieldAttr08 = '' SET @cFieldAttr09 = ''
   SET @cFieldAttr10 = '' SET @cFieldAttr11 = '' SET @cFieldAttr12 = ''
   SET @cFieldAttr13 = '' SET @cFieldAttr14 = '' SET @cFieldAttr15 = ''

   EXEC rdt.rdtSetFocusField @nMobile, 1
END
GOTO Quit

/********************************************************************************
Step 1. Screen = 6930. KIT Ticket #
   Field01 (input): KIT Ticket #
********************************************************************************/
Step_1:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      SET @cKitTicketNo = @cInField01

      -- Validate mandatory
      IF ISNULL( @cKitTicketNo, '') = ''
      BEGIN
         SET @nErrNo = 274601
         SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- Enter KIT Ticket#
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      -- Validate KIT key exists
      SELECT
         @cKITFacility  = Facility,
         @cKITStorerKey = StorerKey,
         @cKITStatus    = Status
      FROM dbo.KIT WITH (NOLOCK)
      WHERE KITKey = @cKitTicketNo

      IF @@ROWCOUNT = 0
      BEGIN
         SET @nErrNo = 274602
         SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- Invalid KIT Ticket#
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      -- Validate Facility
      IF @cKITFacility <> @cFacility
      BEGIN
         SET @nErrNo = 274603
         SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- Different Facility
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      -- Validate StorerKey
      IF @cKITStorerKey <> @cStorerKey
      BEGIN
         SET @nErrNo = 274604
         SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- Different Storer
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      -- Validate KIT not finalized
      IF @cKITStatus = '9'
      BEGIN
         SET @nErrNo = 274605
         SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- KIT is Finalized
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      SET @cOutField01 = @cKitTicketNo
      SET @cOutField02 = ''
      SET @nScn  = 6931
      SET @nStep = 2
      EXEC rdt.rdtSetFocusField @nMobile, 2
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      EXEC RDT.rdt_STD_EventLog
         @cActionType = '9',
         @cUserID     = @cUserName,
         @nMobileNo   = @nMobile,
         @nFunctionID = @nFunc,
         @cFacility   = @cFacility,
         @cStorerKey  = @cStorerKey,
         @nStep       = @nStep

      SET @nFunc = @nMenu
      SET @nScn  = @nMenu
      SET @nStep = 0
      SET @cOutField01 = ''
   END
   GOTO Quit

   Step_1_Fail:
   BEGIN
      SET @cKitTicketNo = ''
      SET @cOutField01  = ''
   END
END
GOTO Quit

/********************************************************************************
Step 2. Screen = 6931. LOC
   Field01 (display): KIT Ticket #
   Field02 (input):   LOC
********************************************************************************/
Step_2:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      SET @cLoc = @cInField02

      -- Validate mandatory
      IF ISNULL( @cLoc, '') = ''
      BEGIN
         SET @nErrNo = 274606
         SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- Scan LOC
         EXEC rdt.rdtSetFocusField @nMobile, 2
         GOTO Step_2_Fail
      END

      -- Validate LOC is part of KIT
      IF NOT EXISTS
      (
         SELECT 1
         FROM dbo.KITDETAIL WITH (NOLOCK)
         WHERE KITKey = @cKitTicketNo
            AND Type  = 'F'
            AND Loc   = @cLoc
      )
      BEGIN
         SET @nErrNo = 274607
         SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- Not KIT Location
         EXEC rdt.rdtSetFocusField @nMobile, 2
         GOTO Step_2_Fail
      END

      -- Skip PALLET ID screen if LOC is loose or has no pallets
      IF EXISTS     ( SELECT 1 FROM dbo.LOC        WITH (NOLOCK) WHERE LOC = @cLoc AND LoseId = '1')
      OR NOT EXISTS ( SELECT 1 FROM dbo.LOTXLOCXID WITH (NOLOCK) WHERE Loc = @cLoc AND RTRIM( Id) <> '' AND StorerKey = @cStorerKey AND Qty - QtyPicked > 0)
      BEGIN
         -- Auto-fill SKU if config DISPSINGLESKU = 1 and LOC has only 1 SKU
         SET @cAutoSKU = ''
         IF @cDispSingleSKU = '1'
         BEGIN
            SELECT @nSKUCount = COUNT( DISTINCT Sku), @cAutoSKU = MIN( Sku)
            FROM dbo.KITDETAIL WITH (NOLOCK)
            WHERE KITKey = @cKitTicketNo
               AND Type  = 'F'
               AND Loc   = @cLoc
            IF @nSKUCount > 1
               SET @cAutoSKU = ''
         END

         -- Screen 4: Field01=KITTicket, Field02=PalletID(empty), Field03=LOC, Field04=SKU input
         SET @cOutField01 = @cKitTicketNo
         SET @cOutField02 = ''
         SET @cOutField03 = @cLoc
         SET @cOutField04 = @cAutoSKU
         SET @nScn  = 6933
         SET @nStep = 4
      END
      ELSE
      BEGIN
         -- Screen 3: Field01=KITTicket, Field02=LOC, Field03=PalletID input
         SET @cOutField01 = @cKitTicketNo
         SET @cOutField02 = @cLoc
         SET @cOutField03 = ''
         SET @nScn  = 6932
         SET @nStep = 3
      END
      IF @nStep = 4
         EXEC rdt.rdtSetFocusField @nMobile, 4
      ELSE
         EXEC rdt.rdtSetFocusField @nMobile, 3
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      SET @cKitTicketNo  = ''
      SET @cKITFacility  = ''
      SET @cKITStorerKey = ''
      SET @cKITStatus    = ''
      SET @cOutField01   = ''
      SET @nScn  = 6930
      SET @nStep = 1
      EXEC rdt.rdtSetFocusField @nMobile, 1
   END
   GOTO Quit

   Step_2_Fail:
   BEGIN
      SET @cLoc        = ''
      SET @cOutField02 = ''
   END
END
GOTO Quit

/********************************************************************************
Step 3. Screen = 6932. PALLET ID
   Field01 (display): KIT Ticket #
   Field02 (display): LOC
   Field03 (input):   PALLET ID
********************************************************************************/
Step_3:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      SET @cPalletID = @cInField03

      -- Validate mandatory
      IF ISNULL( @cPalletID, '') = ''
      BEGIN
         SET @nErrNo = 274608
         SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- Scan Pallet ID
         EXEC rdt.rdtSetFocusField @nMobile, 3
         GOTO Step_3_Fail
      END

      -- Validate pallet is part of KIT
      SELECT @cKITDetailStatus = Status
      FROM dbo.KITDETAIL WITH (NOLOCK)
      WHERE KITKey = @cKitTicketNo
         AND Type  = 'F'
         AND Loc   = @cLoc
         AND Id    = @cPalletID

      IF @@ROWCOUNT = 0
      BEGIN
         SET @nErrNo = 274609
         SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- Pallet NOT found
         EXEC rdt.rdtSetFocusField @nMobile, 3
         GOTO Step_3_Fail
      END

      -- Validate KITDETAIL status
      IF @cKITDetailStatus = '5'
      BEGIN
         SET @nErrNo = 274610
         SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- Check KITDETAIL status
         EXEC rdt.rdtSetFocusField @nMobile, 3
         GOTO Step_3_Fail
      END

      -- Auto-fill SKU if config DISPSINGLESKU = 1 and pallet has only 1 SKU
      SET @cAutoSKU = ''
      IF @cDispSingleSKU = '1'
      BEGIN
         SELECT @nSKUCount = COUNT( DISTINCT Sku), @cAutoSKU = MIN( Sku)
         FROM dbo.KITDETAIL WITH (NOLOCK)
         WHERE KITKey = @cKitTicketNo
            AND Type  = 'F'
            AND Loc   = @cLoc
            AND Id    = @cPalletID
         IF @nSKUCount > 1
            SET @cAutoSKU = ''
      END

      -- Screen 4: Field01=KITTicket, Field02=PalletID, Field03=LOC, Field04=SKU input
      SET @cOutField01 = @cKitTicketNo
      SET @cOutField02 = @cPalletID
      SET @cOutField03 = @cLoc
      SET @cOutField04 = @cAutoSKU
      SET @nScn  = 6933
      SET @nStep = 4
      EXEC rdt.rdtSetFocusField @nMobile, 4
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      SET @cLoc        = ''
      SET @cOutField01 = @cKitTicketNo
      SET @cOutField02 = ''
      SET @nScn  = 6931
      SET @nStep = 2
      EXEC rdt.rdtSetFocusField @nMobile, 2
   END
   GOTO Quit

   Step_3_Fail:
   BEGIN
      SET @cPalletID   = ''
      SET @cOutField03 = ''
   END
END
GOTO Quit

/********************************************************************************
Step 4. Screen = 6933. SKU
   Field01 (display): KIT Ticket #
   Field02 (display): PALLET ID (empty if skipped)
   Field03 (display): LOC
   Field04 (input):   SKU
********************************************************************************/
Step_4:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      SET @nFromScn = 0
      SET @cSKU = @cInField04

      -- Validate mandatory
      IF ISNULL( @cSKU, '') = ''
      BEGIN
         SET @nErrNo = 274611
         SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- Scan SKU
         EXEC rdt.rdtSetFocusField @nMobile, 4
         GOTO Step_4_Fail
      END

      -- Validate SKU is part of KIT (and pallet if applicable)
      IF NOT EXISTS
      (
         SELECT 1
         FROM dbo.KITDETAIL WITH (NOLOCK)
         WHERE KITKey = @cKitTicketNo
            AND Type  = 'F'
            AND Loc   = @cLoc
            AND ( ISNULL( @cPalletID, '') = '' OR Id = @cPalletID)
            AND Sku   = @cSKU
      )
      BEGIN
         SET @nErrNo = 274612
         SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- SKU NOT on the pallet
         EXEC rdt.rdtSetFocusField @nMobile, 4
         GOTO Step_4_Fail
      END

      -- Get lottable code from SKU
      SELECT @cLottableCode = LottableCode
      FROM dbo.SKU WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND SKU      = @cSKU

      -- Dynamic lottable setup
      EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSKU, @cLottableCode, 'CAPTURE', 'POPULATE', 5, 1,
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
         '',
         @nFunc

      IF @nErrNo <> 0
         GOTO Step_4_Fail

      IF @nMorePage = 1
      BEGIN
         SET @nFromScn = @nScn
         SET @nScn  = 3990
         SET @nStep = 5
      END
      ELSE
      BEGIN
         -- No lottable path: clear @nFromScn so Step 6 knows not to use lottable conditions
         SET @nFromScn = 0

         -- Fetch ExpectedQty for config capping
         SET @nQTY = 0
         SELECT TOP 1 @nQTY = KD.ExpectedQty
         FROM dbo.KITDETAIL KD WITH (NOLOCK)
         WHERE KD.KITKey = @cKitTicketNo
            AND KD.Type  = 'F'
            AND KD.Loc   = @cLoc
            AND ( ISNULL( @cPalletID, '') = '' OR KD.Id = @cPalletID)
            AND KD.Sku   = @cSKU

         -- If KITDETAIL row has lottable values, pre-fill QTY with Qty
         SET @cQTY = ''
         SELECT TOP 1 @cQTY = CAST( KD.Qty AS NVARCHAR( 6))
         FROM dbo.KITDETAIL KD WITH (NOLOCK)
         WHERE KD.KITKey = @cKitTicketNo
            AND KD.Type  = 'F'
            AND KD.Loc   = @cLoc
            AND ( ISNULL( @cPalletID, '') = '' OR KD.Id = @cPalletID)
            AND KD.Sku   = @cSKU
            AND (
               RTRIM( ISNULL( KD.LOTTABLE01, '')) <> '' OR
               RTRIM( ISNULL( KD.LOTTABLE02, '')) <> '' OR
               RTRIM( ISNULL( KD.LOTTABLE03, '')) <> '' OR
               KD.LOTTABLE04 IS NOT NULL OR
               KD.LOTTABLE05 IS NOT NULL OR
               RTRIM( ISNULL( KD.Lottable06, '')) <> '' OR
               RTRIM( ISNULL( KD.Lottable07, '')) <> '' OR
               RTRIM( ISNULL( KD.Lottable08, '')) <> '' OR
               RTRIM( ISNULL( KD.Lottable09, '')) <> '' OR
               RTRIM( ISNULL( KD.Lottable10, '')) <> '' OR
               RTRIM( ISNULL( KD.Lottable11, '')) <> '' OR
               RTRIM( ISNULL( KD.Lottable12, '')) <> ''
            )

         -- Apply DefaultKITQty: default to ExpectedQty and disable field
         SET @cFieldAttr05 = ''
         IF @cDefaultKITQty = '1' AND @nQTY > 0
         BEGIN
            SET @cQTY       = CAST( @nQTY AS NVARCHAR( 6))
            SET @cFieldAttr05 = 'O'
         END
         -- Apply DefaultQTY: default to min(SValue, ExpectedQty)
         ELSE IF ISNULL( @cDefaultQTY, '') <> '' AND RDT.rdtIsValidQTY( @cDefaultQTY, 0) = 1
         BEGIN
            IF @nQTY > 0 AND CAST( @cDefaultQTY AS INT) > @nQTY
               SET @cQTY = CAST( @nQTY AS NVARCHAR( 6))   -- cap at ExpectedQty
            ELSE IF CAST( @cDefaultQTY AS INT) > 0
               SET @cQTY = @cDefaultQTY
         END

         SET @cOutField01  = @cKitTicketNo
         SET @cOutField02  = @cPalletID
         SET @cOutField03  = @cLoc
         SET @cOutField04  = @cSKU
         SET @cOutField05  = @cQTY
         SET @nScn  = 6934
         SET @nStep = 6
         EXEC rdt.rdtSetFocusField @nMobile, 5
      END
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Back to PALLET ID screen if pallet exists, else back to LOC screen
      IF ISNULL( @cPalletID, '') <> ''
      BEGIN
         SET @cOutField01 = @cKitTicketNo
         SET @cOutField02 = @cLoc
         SET @cOutField03 = ''
         SET @nScn  = 6932
         SET @nStep = 3
         EXEC rdt.rdtSetFocusField @nMobile, 3
      END
      ELSE
      BEGIN
         SET @cOutField01 = @cKitTicketNo
         SET @cOutField02 = ''
         SET @nScn  = 6931
         SET @nStep = 2
         EXEC rdt.rdtSetFocusField @nMobile, 2
      END
   END
   GOTO Quit

   Step_4_Fail:
   BEGIN
      SET @cSKU        = ''
      SET @cOutField04 = ''
   END
END
GOTO Quit

/********************************************************************************
Step 5. Screen = 3990. Lottable
********************************************************************************/
Step_5:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      SET @cOutField15Backup = @cOutField15
      SET @ctemp_OutField15  = @cOutField15Backup

      EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSKU, @cLottableCode, 'CAPTURE', 'CHECK', 5, 1,
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
         '',
         @nFunc

      SET @nErrNoBackup  = @nErrNo
      SET @cErrMsgBackup = @cErrMsg

      IF @nErrNo <> 0
         GOTO Step_5_Fail

      IF @nMorePage = 1
      BEGIN
         SET @cOutField15 = @cOutField15Backup
         GOTO Quit
      END

      SET @nErrNo  = @nErrNoBackup
      SET @cErrMsg = @cErrMsgBackup

      -- Validate KITDETAIL matches scanned Loc, Id, Sku and lottable combination
      SELECT TOP 1 @nQTY = KD.ExpectedQty
      FROM dbo.KITDETAIL KD WITH (NOLOCK)
      WHERE KD.KITKey = @cKitTicketNo
         AND KD.Type  = 'F'
         AND KD.Loc   = @cLoc
         AND ( ISNULL( @cPalletID, '') = '' OR KD.Id = @cPalletID)
         AND KD.Sku   = @cSKU
         AND RTRIM( ISNULL( KD.LOTTABLE01, '')) = RTRIM( ISNULL( @cLottable01, ''))
         AND RTRIM( ISNULL( KD.LOTTABLE02, '')) = RTRIM( ISNULL( @cLottable02, ''))
         AND RTRIM( ISNULL( KD.LOTTABLE03, '')) = RTRIM( ISNULL( @cLottable03, ''))
         AND RTRIM( ISNULL( KD.Lottable06, '')) = RTRIM( ISNULL( @cLottable06, ''))
         AND RTRIM( ISNULL( KD.Lottable07, '')) = RTRIM( ISNULL( @cLottable07, ''))
         AND RTRIM( ISNULL( KD.Lottable08, '')) = RTRIM( ISNULL( @cLottable08, ''))
         AND RTRIM( ISNULL( KD.Lottable09, '')) = RTRIM( ISNULL( @cLottable09, ''))
         AND RTRIM( ISNULL( KD.Lottable10, '')) = RTRIM( ISNULL( @cLottable10, ''))
         AND RTRIM( ISNULL( KD.Lottable11, '')) = RTRIM( ISNULL( @cLottable11, ''))
         AND RTRIM( ISNULL( KD.Lottable12, '')) = RTRIM( ISNULL( @cLottable12, ''))
         AND ( @dLottable04 = 0 AND KD.LOTTABLE04 IS NULL OR @dLottable04 <> 0 AND KD.LOTTABLE04 = @dLottable04)
         AND ( @dLottable05 = 0 AND KD.LOTTABLE05 IS NULL OR @dLottable05 <> 0 AND KD.LOTTABLE05 = @dLottable05)
         AND ( @dLottable13 = 0 AND KD.Lottable13 IS NULL OR @dLottable13 <> 0 AND KD.Lottable13 = @dLottable13)
         AND ( @dLottable14 = 0 AND KD.Lottable14 IS NULL OR @dLottable14 <> 0 AND KD.Lottable14 = @dLottable14)
         AND ( @dLottable15 = 0 AND KD.Lottable15 IS NULL OR @dLottable15 <> 0 AND KD.Lottable15 = @dLottable15)

      IF @@ROWCOUNT = 0
      BEGIN
         SET @nErrNo = 274615
         SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- No matching KITDETAIL found
         GOTO Step_5_Fail
      END

      -- KITDETAIL found; apply config and go to QTY screen
      SET @cQTY       = CAST( @nQTY AS NVARCHAR( 6))   -- base: ExpectedQty
      SET @cFieldAttr05 = ''

      IF @cDefaultKITQty = '1'
         SET @cFieldAttr05 = 'O'   -- disable field; QTY already = ExpectedQty
      ELSE IF ISNULL( @cDefaultQTY, '') <> '' AND RDT.rdtIsValidQTY( @cDefaultQTY, 0) = 1
      BEGIN
         IF CAST( @cDefaultQTY AS INT) > 0 AND CAST( @cDefaultQTY AS INT) <= @nQTY
            SET @cQTY = @cDefaultQTY  -- SValue <= ExpectedQty: use SValue
         -- else: SValue > ExpectedQty, keep @cQTY = ExpectedQty (cap already satisfied)
      END

      SET @cOutField01 = @cKitTicketNo
      SET @cOutField02 = @cPalletID
      SET @cOutField03 = @cLoc
      SET @cOutField04 = @cSKU
      SET @cOutField05 = @cQTY
      SET @nScn  = 6934
      SET @nStep = 6
      EXEC rdt.rdtSetFocusField @nMobile, 5
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      SET @cOutField01 = @cKitTicketNo
      SET @cOutField02 = @cPalletID
      SET @cOutField03 = @cLoc
      SET @cOutField04 = @cSKU
      SET @nScn  = @nFromScn
      SET @nStep = 4
      EXEC rdt.rdtSetFocusField @nMobile, 4
   END

   Step_5_Fail:
   BEGIN
      SET @cOutField15 = @cOutField15Backup
   END
END
GOTO Quit

/********************************************************************************
Step 6. Screen = 6934. QTY
   Field01 (display): KIT Ticket #
   Field02 (display): PALLET ID
   Field03 (display): LOC
   Field04 (display): SKU
   Field05 (input):   QTY
********************************************************************************/
Step_6:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      SET @cQTY = @cInField05

      -- Validate mandatory
      IF ISNULL( @cQTY, '') = ''
      BEGIN
         SET @nErrNo = 274613
         SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- Enter QTY
         EXEC rdt.rdtSetFocusField @nMobile, 5
         GOTO Step_6_Fail
      END

      -- Validate QTY is numeric
      IF RDT.rdtIsValidQTY( @cQTY, 0) = 0
      BEGIN
         SET @nErrNo = 274614
         SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- Invalid QTY
         EXEC rdt.rdtSetFocusField @nMobile, 5
         GOTO Step_6_Fail
      END

      SET @nQTY = CAST( @cQTY AS INT)

      -- Validate QTY <= ExpectedQty
      SET @nExpectedQty = 0
      IF ISNULL( @nFromScn, 0) > 0  -- came from lottable screen: match by lottable combination
         SELECT TOP 1 @nExpectedQty = KD.ExpectedQty
         FROM dbo.KITDETAIL KD WITH (NOLOCK)
         WHERE KD.KITKey = @cKitTicketNo
            AND KD.Type  = 'F'
            AND KD.Loc   = @cLoc
            AND ( ISNULL( @cPalletID, '') = '' OR KD.Id = @cPalletID)
            AND KD.Sku   = @cSKU
            AND RTRIM( ISNULL( KD.LOTTABLE01, '')) = RTRIM( ISNULL( @cLottable01, ''))
            AND RTRIM( ISNULL( KD.LOTTABLE02, '')) = RTRIM( ISNULL( @cLottable02, ''))
            AND RTRIM( ISNULL( KD.LOTTABLE03, '')) = RTRIM( ISNULL( @cLottable03, ''))
            AND RTRIM( ISNULL( KD.Lottable06, '')) = RTRIM( ISNULL( @cLottable06, ''))
            AND RTRIM( ISNULL( KD.Lottable07, '')) = RTRIM( ISNULL( @cLottable07, ''))
            AND RTRIM( ISNULL( KD.Lottable08, '')) = RTRIM( ISNULL( @cLottable08, ''))
            AND RTRIM( ISNULL( KD.Lottable09, '')) = RTRIM( ISNULL( @cLottable09, ''))
            AND RTRIM( ISNULL( KD.Lottable10, '')) = RTRIM( ISNULL( @cLottable10, ''))
            AND RTRIM( ISNULL( KD.Lottable11, '')) = RTRIM( ISNULL( @cLottable11, ''))
            AND RTRIM( ISNULL( KD.Lottable12, '')) = RTRIM( ISNULL( @cLottable12, ''))
            AND ( @dLottable04 = 0 AND KD.LOTTABLE04 IS NULL OR @dLottable04 <> 0 AND KD.LOTTABLE04 = @dLottable04)
            AND ( @dLottable05 = 0 AND KD.LOTTABLE05 IS NULL OR @dLottable05 <> 0 AND KD.LOTTABLE05 = @dLottable05)
            AND ( @dLottable13 = 0 AND KD.Lottable13 IS NULL OR @dLottable13 <> 0 AND KD.Lottable13 = @dLottable13)
            AND ( @dLottable14 = 0 AND KD.Lottable14 IS NULL OR @dLottable14 <> 0 AND KD.Lottable14 = @dLottable14)
            AND ( @dLottable15 = 0 AND KD.Lottable15 IS NULL OR @dLottable15 <> 0 AND KD.Lottable15 = @dLottable15)
      ELSE  -- no lottable: match by Loc / Id / Sku only
         SELECT TOP 1 @nExpectedQty = KD.ExpectedQty
         FROM dbo.KITDETAIL KD WITH (NOLOCK)
         WHERE KD.KITKey = @cKitTicketNo
            AND KD.Type  = 'F'
            AND KD.Loc   = @cLoc
            AND ( ISNULL( @cPalletID, '') = '' OR KD.Id = @cPalletID)
            AND KD.Sku   = @cSKU

      IF @nExpectedQty > 0 AND @nQTY > @nExpectedQty
      BEGIN
         SET @nErrNo = 274616
         SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- QTY more than expected
         EXEC rdt.rdtSetFocusField @nMobile, 5
         GOTO Step_6_Fail
      END

      -- Navigate to TO PALLET ID screen (or skip to TO LOC if config)
      IF @cSkipToID = '1'
      BEGIN
         SET @cOutField01 = @cKitTicketNo
         SET @cOutField02 = @cDefaultToLoc
         SET @cOutField05 = @cQTY
         SET @cToLoc = ''
         SET @nScn  = 6936
         SET @nStep = 8
         EXEC rdt.rdtSetFocusField @nMobile, 2
      END
      ELSE
      BEGIN
         SET @cOutField01 = @cKitTicketNo
         SET @cOutField02 = ''
         SET @cOutField05 = @cQTY
         SET @cToPalletID = ''
         SET @nScn  = 6935
         SET @nStep = 7
      END
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Back to lottable screen if lottable was shown, else back to SKU screen
      IF ISNULL( @nFromScn, 0) > 0
      BEGIN
         SET @nScn  = 3990
         SET @nStep = 5
      END
      ELSE
      BEGIN
         SET @cOutField01 = @cKitTicketNo
         SET @cOutField02 = @cPalletID
         SET @cOutField03 = @cLoc
         SET @cOutField04 = @cSKU
         SET @nScn  = 6933
         SET @nStep = 4
         EXEC rdt.rdtSetFocusField @nMobile, 4
      END
   END
   GOTO Quit

   Step_6_Fail:
   BEGIN
      SET @cQTY        = ''
      SET @cOutField05 = ''
   END
END
GOTO Quit

/********************************************************************************
Step 7. Screen = 6935. TO PALLET ID
   Field01 (display): KIT Ticket #
   Field02 (input):   TO PALLET ID (not mandatory)
********************************************************************************/
Step_7:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      SET @cToPalletID = @cInField02

      SET @cOutField01 = @cKitTicketNo
      SET @cOutField02 = @cDefaultToLoc
      SET @cToLoc = ''
      SET @nScn  = 6936
      SET @nStep = 8
      EXEC rdt.rdtSetFocusField @nMobile, 2
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      SET @cOutField01 = @cKitTicketNo
      SET @cOutField02 = @cPalletID
      SET @cOutField03 = @cLoc
      SET @cOutField04 = @cSKU
      -- @cOutField05 retains @cQTY set during Step 6 → Step 7 navigation
      SET @cToPalletID = ''
      SET @nScn  = 6934
      SET @nStep = 6
      EXEC rdt.rdtSetFocusField @nMobile, 5
   END
END
GOTO Quit

/********************************************************************************
Step 8. Screen = 6936. TO LOC
   Field01 (display): KIT Ticket #
   Field02 (input):   TO LOC
********************************************************************************/
Step_8:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      SET @cToLoc = @cInField02

      -- Validate mandatory
      IF ISNULL( @cToLoc, '') = ''
      BEGIN
         SET @nErrNo = 274617
         SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- Enter TO LOC
         EXEC rdt.rdtSetFocusField @nMobile, 2
         GOTO Step_8_Fail
      END

      IF @cSkipToID = '1'
         SET @cToPalletID = ''

      SET @cMoveFromID = NULLIF( RTRIM( ISNULL( @cPalletID,   '')), '')
      SET @cMoveToID   = NULLIF( RTRIM( ISNULL( @cToPalletID, '')), '')

      SET @nTranCount = @@TRANCOUNT
      BEGIN TRAN
      SAVE TRAN KitMovement_Step8

      BEGIN TRY
         EXECUTE rdt.rdt_Move
            @nMobile     = @nMobile,
            @cLangCode   = @cLangCode,
            @nErrNo      = @nErrNo  OUTPUT,
            @cErrMsg     = @cErrMsg OUTPUT,
            @cSourceType = 'rdtfnc_KitMovement',
            @cStorerKey  = @cStorerKey,
            @cFacility   = @cFacility,
            @cFromLOC    = @cLoc,
            @cToLOC      = @cToLoc,
            @cFromID     = @cMoveFromID,
            @cToID       = @cMoveToID,
            @nFunc       = @nFunc
      END TRY
      BEGIN CATCH
         SET @nErrNo = 274618
         SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- Move failed
         GOTO Step_8_RollBack
      END CATCH

      IF @nErrNo <> 0
         GOTO Step_8_RollBack

      IF ISNULL( @nFromScn, 0) > 0  -- came from lottable screen: match by lottable combination
      BEGIN
         BEGIN TRY
            UPDATE dbo.KITDETAIL WITH (ROWLOCK) SET
               Loc    = @cToLoc,
               Id     = ISNULL( RTRIM( @cToPalletID), ''),
               Status = '5'
            WHERE KITKey = @cKitTicketNo
               AND Type  = 'F'
               AND Loc   = @cLoc
               AND ( ISNULL( @cPalletID, '') = '' OR Id = @cPalletID)
               AND Sku   = @cSKU
               AND RTRIM( ISNULL( LOTTABLE01, '')) = RTRIM( ISNULL( @cLottable01, ''))
               AND RTRIM( ISNULL( LOTTABLE02, '')) = RTRIM( ISNULL( @cLottable02, ''))
               AND RTRIM( ISNULL( LOTTABLE03, '')) = RTRIM( ISNULL( @cLottable03, ''))
               AND RTRIM( ISNULL( Lottable06, '')) = RTRIM( ISNULL( @cLottable06, ''))
               AND RTRIM( ISNULL( Lottable07, '')) = RTRIM( ISNULL( @cLottable07, ''))
               AND RTRIM( ISNULL( Lottable08, '')) = RTRIM( ISNULL( @cLottable08, ''))
               AND RTRIM( ISNULL( Lottable09, '')) = RTRIM( ISNULL( @cLottable09, ''))
               AND RTRIM( ISNULL( Lottable10, '')) = RTRIM( ISNULL( @cLottable10, ''))
               AND RTRIM( ISNULL( Lottable11, '')) = RTRIM( ISNULL( @cLottable11, ''))
               AND RTRIM( ISNULL( Lottable12, '')) = RTRIM( ISNULL( @cLottable12, ''))
               AND ( @dLottable04 = 0 AND LOTTABLE04 IS NULL OR @dLottable04 <> 0 AND LOTTABLE04 = @dLottable04)
               AND ( @dLottable05 = 0 AND LOTTABLE05 IS NULL OR @dLottable05 <> 0 AND LOTTABLE05 = @dLottable05)
               AND ( @dLottable13 = 0 AND Lottable13 IS NULL OR @dLottable13 <> 0 AND Lottable13 = @dLottable13)
               AND ( @dLottable14 = 0 AND Lottable14 IS NULL OR @dLottable14 <> 0 AND Lottable14 = @dLottable14)
               AND ( @dLottable15 = 0 AND Lottable15 IS NULL OR @dLottable15 <> 0 AND Lottable15 = @dLottable15)
         END TRY
         BEGIN CATCH
            SET @nErrNo = 274619
            SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- KITDETAIL update failed (lottable)
            GOTO Step_8_RollBack
         END CATCH
      END
      ELSE  -- no lottable: match by Loc / Id / Sku only
      BEGIN
         BEGIN TRY
            UPDATE dbo.KITDETAIL WITH (ROWLOCK) SET
               Loc    = @cToLoc,
               Id     = ISNULL( RTRIM( @cToPalletID), ''),
               Status = '5'
            WHERE KITKey = @cKitTicketNo
               AND Type  = 'F'
               AND Loc   = @cLoc
               AND ( ISNULL( @cPalletID, '') = '' OR Id = @cPalletID)
               AND Sku   = @cSKU
         END TRY
         BEGIN CATCH
            SET @nErrNo = 274620
            SET @cErrMsg = rdt.rdtGetMessageLong( @nErrNo, @cLangCode, 'DSP') -- KITDETAIL update failed (no lottable)
            GOTO Step_8_RollBack
         END CATCH
      END

      WHILE @@TRANCOUNT > @nTranCount
         COMMIT TRAN

      SET @cOutField01 = @cKitTicketNo
      SET @nScn  = 6937
      SET @nStep = 9
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Back to TO PALLET ID screen or QTY screen depending on SKIPTOID config
      IF @cSkipToID = '1'
      BEGIN
         SET @cOutField01 = @cKitTicketNo
         SET @cOutField02 = @cPalletID
         SET @cOutField03 = @cLoc
         SET @cOutField04 = @cSKU
         -- @cOutField05 retains @cQTY (set when navigating to Step 8)
         SET @cToLoc = ''
         SET @nScn  = 6934
         SET @nStep = 6
         EXEC rdt.rdtSetFocusField @nMobile, 5
      END
      ELSE
      BEGIN
         SET @cOutField01 = @cKitTicketNo
         SET @cOutField02 = @cToPalletID
         SET @cToLoc = ''
         SET @nScn  = 6935
         SET @nStep = 7
         EXEC rdt.rdtSetFocusField @nMobile, 2
      END
   END

   GOTO Quit

   Step_8_RollBack:
      ROLLBACK TRAN KitMovement_Step8
      WHILE @@TRANCOUNT > @nTranCount
         COMMIT TRAN
   Step_8_Fail:
   BEGIN
      SET @cToLoc      = ''
      SET @cOutField02 = @cDefaultToLoc
   END
END
GOTO Quit

/********************************************************************************
Step 9. Screen = 6937. Success
   Field01 (display): KIT Ticket #
   Both ENTER and ESC return to LOC screen for next scan
********************************************************************************/
Step_9:
BEGIN
   SET @cLoc        = ''
   SET @cPalletID   = ''
   SET @cSKU        = ''
   SET @cToPalletID = ''
   SET @cToLoc      = ''
   SET @nFromScn    = 0
   SET @cLottable01 = '' SET @cLottable02 = '' SET @cLottable03 = ''
   SET @dLottable04 = 0  SET @dLottable05 = 0
   SET @cLottable06 = '' SET @cLottable07 = '' SET @cLottable08 = ''
   SET @cLottable09 = '' SET @cLottable10 = ''
   SET @cLottable11 = '' SET @cLottable12 = ''
   SET @dLottable13 = 0  SET @dLottable14 = 0  SET @dLottable15 = 0

   SET @cOutField01 = @cKitTicketNo
   SET @cOutField02 = ''
   SET @nScn  = 6931
   SET @nStep = 2
   EXEC rdt.rdtSetFocusField @nMobile, 2
END
GOTO Quit

/********************************************************************************
Quit
********************************************************************************/
Quit:
UPDATE dbo.RDTMobRec WITH (ROWLOCK) SET
   Func         = @nFunc,
   Scn          = @nScn,
   Step         = @nStep,

   V_String1    = @cKitTicketNo,
   V_String2    = @cLoc,
   V_String3    = @cPalletID,
   V_String4    = @cSKU,
   V_String5    = @cDispSingleSKU,
   V_String6    = @cDefaultQTY,
   V_String7    = @cDefaultKITQty,
   V_String8    = @cSkipToID,
   V_String9    = @cToPalletID,
   V_String10   = @cToLoc,
   V_String11   = @cDefaultToLoc,

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
   V_FromScn    = @nFromScn,

   O_Field01    = @cOutField01,   O_Field02    = @cOutField02,
   O_Field03    = @cOutField03,   O_Field04    = @cOutField04,
   O_Field05    = @cOutField05,   O_Field06    = @cOutField06,
   O_Field07    = @cOutField07,   O_Field08    = @cOutField08,
   O_Field09    = @cOutField09,   O_Field10    = @cOutField10,
   O_Field11    = @cOutField11,   O_Field12    = @cOutField12,
   O_Field13    = @cOutField13,   O_Field14    = @cOutField14,
   O_Field15    = @cOutField15,

   FieldAttr01  = @cFieldAttr01,  FieldAttr02  = @cFieldAttr02,
   FieldAttr03  = @cFieldAttr03,  FieldAttr04  = @cFieldAttr04,
   FieldAttr05  = @cFieldAttr05,  FieldAttr06  = @cFieldAttr06,
   FieldAttr07  = @cFieldAttr07,  FieldAttr08  = @cFieldAttr08,
   FieldAttr09  = @cFieldAttr09,  FieldAttr10  = @cFieldAttr10,
   FieldAttr11  = @cFieldAttr11,  FieldAttr12  = @cFieldAttr12,
   FieldAttr13  = @cFieldAttr13,  FieldAttr14  = @cFieldAttr14,
   FieldAttr15  = @cFieldAttr15,

   ErrNo        = @nErrNo,
   ErrMsg       = @cErrMsg
WHERE Mobile = @nMobile
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdtfnc_KitMovement] TO NSQL
GO
