SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*********************************************************************************/
/* Store procedure: rdtfnc_BuildPalletToKit                                      */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose: Kitting via RDT                                                      */
/*                                                                               */
/* Date        Rev    Author  Purposes                                           */
/* 2025-03-07  1.0.0  JCH507  FCR-2728 created                                   */
/* 2025-08-12  0.0.0  JCH507  !!!Cutover. Use V0 repo for work!!!                */
/*********************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdtfnc_BuildPalletToKit] (
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
   @b_Success      INT,
   @n_Err          INT,
   @c_ErrMsg       NVARCHAR( 250),

   @cChkFacility     NVARCHAR( 5),
   @cChkLOC          NVARCHAR( 10),
   @cPalletTypeInUse NVARCHAR( 1),
   @nMorePage        INT,
   @cOption          NVARCHAR( 1),
   @cSQL             NVARCHAR( MAX),
   @cSQLParam        NVARCHAR( MAX),
   @tPalletLabel     VariableTable,
   @tExtScnData      VariableTable,
   @nLineWithBal     INT

-- Session variable
DECLARE
   @nFunc        INT,
   @nScn         INT,
   @nStep        INT,
   @cLangCode    NVARCHAR( 3),
   @nInputKey    INT,
   @nMenu        INT,
   @nOri_Scn     INT,
   @nOri_Step    INT,
   @cUserName    NVARCHAR( 18),
   @cPrinter     NVARCHAR( 10),
   @cStorerGroup NVARCHAR( 20),
   @cStorerKey   NVARCHAR( 15),
   @cFacility    NVARCHAR( 5),
   @cPalletType  NVARCHAR(10),
   @cPUOM        NVARCHAR(  1),
   @cKitKey      NVARCHAR( 10),
   @cExtKitKey   NVARCHAR( 20),
   @cLOC         NVARCHAR( 20),
   @cID          NVARCHAR( 18),
   @cSKU         NVARCHAR( 20),
   @cSKUDesc     NVARCHAR( 60),
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
   @cMax         NVARCHAR( MAX),
   @nRowCount  INT,
   @cKitStatus NVARCHAR(1),
   @cKitConfirmStatus NVARCHAR(1),


   @cLottableCode       NVARCHAR( 30),
   @cReasonCode         NVARCHAR( 10),
   @cKitDtlLineNumber  NVARCHAR( 5),


   @cPUOM_Desc          NCHAR( 5),
   @cMUOM_Desc          NCHAR( 5),
   @nPUOM_Div           INT,
   @nPQTY               INT,
   @nMQTY               INT,
   @nQTY                INT,
   @nFromScn            INT,
   @nAction     INT,
   @nAfterScn   INT,
   @nAfterStep  INT,
   @cDispStyleColorSize NVARCHAR( 1),
   @cNewPalletPerSKU    NVARCHAR( 20),
   @cDefaultToLOC       NVARCHAR( 20),
   @cCheckIDInKit       NVARCHAR( 20),
   @cCheckIDCrsKit      NVARCHAR( 20),
   @cAutoGenID          NVARCHAR( 20),
   @cAutoID             NVARCHAR( 18),
   @cDecodeSP           NVARCHAR( 20),
   @cVerifySKU          NVARCHAR( 1),
   @cExtendedValidateSP NVARCHAR( 20),
   @cExtendedUpdateSP   NVARCHAR( 20),
   @cConfirmSP    NVARCHAR( 20),
   @cExtendedInfoSP     NVARCHAR( 20),
   @cExtendedInfo       NVARCHAR( 20),
   @cPalletLabel        NVARCHAR( 20),
   @cPrinter_Paper      NVARCHAR( 10),
   @cCheckIDInUse       NVARCHAR( 20),
   @cMultiSKUBarcode    NVARCHAR(1),
   @cDecimalQty         NVARCHAR( 1),
   @cLOCLookupSP        NVARCHAR(20),
   @cUserDefine01       NVARCHAR( 60),
   @cUserDefine02       NVARCHAR( 60),
   @cUserDefine03       NVARCHAR( 60),
   @cUserDefine04       NVARCHAR( 60),
   @cUserDefine05       NVARCHAR( 60),
   @nTempQTY            INT,
   @cScanBarcode        NVARCHAR( 2000),  --(cc01)
   @cDefaultToLocSP     NVARCHAR( 20),
   @tExtData            VariableTable,
   @cDropListSP         NVARCHAR( 20),
   @cCapturePalletType  NVARCHAR( 20),

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
   @nFunc      = Func,
   @nScn       = Scn,
   @nStep      = Step,
   @nInputKey  = InputKey,
   @nMenu      = Menu,
   @cLangCode  = Lang_code,

   @cStorerGroup = StorerGroup,
   @cFacility  = Facility,
   @cPrinter   = Printer,
   @cUserName  = UserName,
   @cPrinter_Paper = Printer_Paper,

   @cStorerKey  = V_StorerKey,
   @cPUOM       = V_UOM,
   @cLOC        = V_Loc,
   @cID         = V_ID,
   @cSKU        = V_SKU,
   @cSKUDesc    = V_SKUDescr,
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
   @cMax        = V_Max,

   @cKitKey             = V_String1,
   @cExtKitKey          = V_String2,
   @cLottableCode       = V_String3,
   @cPalletType         = V_String4,
   @cKitConfirmStatus   = V_String5,
   --@cFinalLOC           = V_String6,
   @cKitDtlLineNumber   = V_String7,
   --@cPalletRecv         = V_String8,
   --@cFlowThruScreen     = V_String9,
   @cMUOM_Desc          = V_String10,
   @cPUOM_Desc          = V_String11,
   @cUserDefine01       = V_String12,

   @nPUOM_Div           = V_PUOM_Div,
   @nPQTY               = V_PQTY,
   @nMQTY               = V_MQTY,
   @nQTY                = V_QTY,
   @nFromScn            = V_FromScn,
   --@nPABookingKey       = V_Integer1,

   @cDispStyleColorSize = V_String20,
   @cCheckIDCrsKit      = V_String21,
   @cDefaultToLOC       = V_String22,
   @cCheckIDInKit         = V_String23,
   @cAutoGenID          = V_String24,
   @cDropListSP         = V_String25,
   @cDecodeSP           = V_String26,
   @cCapturePalletType  = V_String27,
   @cVerifySKU          = V_String28,
   --@cPalletRecvSP       = V_String29,
   @cExtendedValidateSP = V_String30,
   @cExtendedUpdateSP   = V_String31,
   @cConfirmSP    = V_String32,
   @cExtendedInfoSP     = V_String33,
   @cExtendedInfo       = V_String34,
   --@cPutawaySP          = V_String35,
   --@cPutaway            = V_String36,
   @cPalletLabel        = V_String37,
   @cCheckIDInUse       = V_String38,
   @cMultiSKUBarcode    = V_String39,
   @cLOCLookUPSP        = V_String40,
   --@cDocType            = V_String41,
   --@cSerialNoCapture    = V_String42,
   @cScanBarcode        = V_String43, --(cc01)
   --@cClosePallet        = V_String44, --(yeekung06)
   --@cExtScnSP           = V_String45,
   @cDecimalQty         = V_String46,
   --@cBacktoScreen1      = V_String47,  --(Tianlei)

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

SET @nOri_Scn = @nScn
SET @nOri_Step = @nStep

-- Redirect to respective screen
IF @nFunc = 663
BEGIN
   IF @nStep = 0 GOTO Step_0   -- Func = 600. Menu
   IF @nStep = 1 GOTO Step_1   -- Scn = 6570. Kit Key, Ext Kit Key
   IF @nStep = 2 GOTO Step_2   -- Scn = 6571. LOC
   IF @nStep = 3 GOTO Step_3   -- Scn = 6572. ID
   IF @nStep = 4 GOTO Step_4   -- Scn = 6573. SKU
   IF @nStep = 5 GOTO Step_5   -- Scn = 6574. Lottable
   IF @nStep = 6 GOTO Step_6   -- Scn = 6575. QTY
   IF @nStep = 7 GOTO Step_7   -- Scn = 6576. Message. successful received
END
RETURN -- Do nothing if incorrect step


/********************************************************************************
Step 0. func = 663. Menu
   @nStep = 0
********************************************************************************/
Step_0:
BEGIN
   -- Get default UOM
   SELECT @cPUOM = DefaultUOM FROM rdt.rdtUser WITH (NOLOCK) WHERE UserName = @cUserName

   -- EventLog
   EXEC RDT.rdt_STD_EventLog
      @cActionType = '1', -- Sign-in
      @cUserID     = @cUserName,
      @nMobileNo   = @nMobile,
      @nFunctionID = @nFunc,
      @cFacility   = @cFacility,
      @cStorerKey  = @cStorerKey

   -- Init var (due to var pass out by decodeSP, GetReceiveInfoSP is not reset)
   SELECT @cID = '', @cSKU = '', @nQTY = 0,
      @cLottable01 = '', @cLottable02 = '', @cLottable03 = '', @dLottable04 = 0,  @dLottable05 = 0,
      @cLottable06 = '', @cLottable07 = '', @cLottable08 = '', @cLottable09 = '', @cLottable10 = '',
      @cLottable11 = '', @cLottable12 = '', @dLottable13 = 0,  @dLottable14 = 0,  @dLottable15 = 0

   -- Prepare next screen var
   SET @cOutField01 = '' -- Kitkey
   SET @cOutField02 = '' -- External kit key

   -- Set the entry point
   SET @nScn = 6570
   SET @nStep = 1
END
GOTO Quit


/********************************************************************************
Step 1. Scn = 6570. KIT Key, Ext KIT Key
   KitKey      (field01, input)
   Ext KitKey  (field02, input)
********************************************************************************/
Step_1:
BEGIN
   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      DECLARE @cChkStorerKey NVARCHAR( 15)


      -- Screen mapping
      SET @cKitKey      = @cInField01
      SET @cExtKitKey   = @cInField02

      -- Validate at least one field must key-in
      IF (@cKitKey = '' OR @cKitKey IS NULL) AND
         (@cExtKitKey = '' OR @cExtKitKey IS NULL)
      BEGIN
         SET @nErrNo = 234751
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Kit# or ExtKit#
         GOTO Step_1_Fail
      END

      -- Both KitKey & ExtKitKey key-in
      IF NOT (@cKitKey = '' OR @cKitKey IS NULL) AND
         NOT (@cExtKitKey = '' OR @cExtKitKey IS NULL)
      BEGIN
         SET @nErrNo = 234752
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Only Key-in 1 field
         SET @cOutField01 = ''
         SET @cOutField02 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      --Validate Extern kit key
      IF NOT (@cExtKitKey = '' OR @cExtKitKey IS NULL)
      BEGIN
         SELECT @nRowCount = COUNT(DISTINCT KITKey)
         FROM dbo.KIT WITH (NOLOCK)
         WHERE ExternKitKey = @cExtKitKey

         IF @nRowCount = 0
         BEGIN
            SET @nErrNo = 234753
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ExtKit not exist
            SET @cOutField02 = ''
            EXEC rdt.rdtSetFocusField @nMobile, 2
            GOTO Step_1_Fail
         END
         ELSE IF @nRowCount > 1
         BEGIN
            SET @nErrNo = 234754
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MultiKitFound
            SET @cOutField02 = ''
            EXEC rdt.rdtSetFocusField @nMobile, 2
            GOTO Step_1_Fail
         END
         ELSE IF @nRowCount = 1
         BEGIN
            SELECT TOP 1 @cKitKey = KITKey
            FROM dbo.KIT WITH (NOLOCK)
            WHERE ExternKitKey = @cExtKitKey
         END
      END
      
      --Validate Kit key
      IF (@cKitKey <> '' AND @cKitKey IS NOT NULL)
      BEGIN
         SELECT
            @cChkFacility = K.Facility,
            @cChkStorerKey = K.StorerKey,
            @cKitStatus = K.Status,
            @cExtKitKey = ISNULL(K.ExternKitKey, '')
         FROM dbo.KIT K WITH (NOLOCK)
            INNER JOIN dbo.KITDETAIL KD WITH (NOLOCK) ON K.KITKey  = KD.KITKey
         WHERE KD.KITKey = @cKitKey

         SET @nRowCount = @@ROWCOUNT

         -- No row returned, either KIT or KIT detail not exist
         IF @nRowCount = 0
         BEGIN
            SELECT
                  @cChkFacility = Facility,
                  @cChkStorerKey = StorerKey,
                  @cKitStatus = Status,
                  @cExtKitKey = ExternKitKey
            FROM dbo.KIT WITH (NOLOCK)
            WHERE  KITKey = @cKitKey

            SET @nRowCount = @@ROWCOUNT

            -- Check KIT exist
            IF @nRowCount = 0
            BEGIN
               SET @nErrNo = 234755
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --KIT not exist
               SET @cOutField01 = '' -- KitKey
               EXEC rdt.rdtSetFocusField @nMobile, 1
               GOTO Step_1_Fail
            END
            ELSE
            BEGIN
               SET @nErrNo = 234756
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --KITDetail not exist
               SET @cOutField01 = '' -- KitKey
               EXEC rdt.rdtSetFocusField @nMobile, 1
               GOTO Step_1_Fail
            END
         END
      END -- kit key validation
      
      -- Validate KIT in different facility
      IF @cFacility <> @cChkFacility
      BEGIN
         SET @nErrNo = 234757
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff facility
         SET @cOutField01 = '' -- KitKey
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      -- Check storer group
      IF @cStorerGroup <> ''
      BEGIN
         -- Check storer not in storer group
         IF NOT EXISTS (SELECT 1 FROM StorerGroup WITH (NOLOCK) WHERE StorerGroup = @cStorerGroup AND StorerKey = @cChkStorerKey)
         BEGIN
            SET @nErrNo = 234758
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NotInStorerGrp
            SET @cOutField01 = '' -- KitKey
            EXEC rdt.rdtSetFocusField @nMobile, 1
            GOTO Step_1_Fail
         END

         -- Set session storer
         SET @cStorerKey = @cChkStorerKey
      END

      -- Validate Kit belong to the storer
      IF @cStorerKey <> @cChkStorerKey
      BEGIN
         SET @nErrNo = 234759
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff storer
         SET @cOutField01 = '' -- kitkey
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      SET @cKitConfirmStatus = rdt.RDTGetConfig( @nFunc, 'KitConfirmStatus', @cStorerKey)          
      IF @cKitConfirmStatus = '0'          
         SET @cKitConfirmStatus = '9' -- Default to 9

      -- Validate Kit status
      IF @cKitStatus = @cKitConfirmStatus
      BEGIN
         SET @nErrNo = 234760
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Kit is closed
         SET @cOutField01 = '' -- ReceiptKey
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      -- Get storer config
      SET @cAutoGenID = rdt.RDTGetConfig( @nFunc, 'AutoGenID', @cStorerKey)
      SET @cCheckIDInKit = rdt.RDTGetConfig( @nFunc, 'CheckIDInKit', @cStorerKey)
      SET @cCheckIDCrsKit = rdt.RDTGetConfig( @nFunc, 'CheckIDCrsKit', @cStorerKey)
      SET @cDefaultToLOCSP = rdt.RDTGetConfig( @nFunc, 'DefaultToLOCSP', @cStorerKey)
      SET @cDispStyleColorSize = rdt.RDTGetConfig( @nFunc, 'DispStyleColorSize', @cStorerKey)
      SET @cLOCLookUPSP = rdt.rdtGetConfig(@nFunc,'LOCLookupSP',@cStorerKey)
      SET @cCheckIDInUse = rdt.RDTGetConfig( @nFunc, 'CheckIDInUse', @cStorerKey)
      IF @cCheckIDInUse = '0'
         SET @cCheckIDInUse = ''
      SET @cDecodeSP = rdt.RDTGetConfig( @nFunc, 'DecodeSP', @cStorerKey)
      IF @cDecodeSP = '0'
         SET @cDecodeSP = ''
      SET @cDefaultToLOC = rdt.RDTGetConfig( @nFunc, 'KitDefaultToLoc', @cStorerKey)
      IF @cDefaultToLOC = '0'
         SET @cDefaultToLOC = ''
      SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)
      IF @cExtendedValidateSP = '0'
         SET @cExtendedValidateSP = ''
      SET @cExtendedInfoSP = rdt.RDTGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerKey)
      IF @cExtendedInfoSP = '0'
         SET @cExtendedInfoSP = ''
      SET @cExtendedUpdateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)
      IF @cExtendedUpdateSP = '0'
         SET @cExtendedUpdateSP = ''
      SET @cConfirmSP = rdt.RDTGetConfig( @nFunc, 'BuildPalletToKitConfirmSP', @cStorerKey)
      IF @cConfirmSP = '0'
         SET @cConfirmSP = ''
      --SET @cDecimalQty = rdt.RDTGetConfig( @nFunc, 'AcceptDecimal', @cStorerKey)
      SET @cDecimalQty = '' -- Alwasy off Decimal Qty because the KITDetail.Qty is INT type
      IF @cDecimalQty = '0'
         SET @cDecimalQty = ''
      SET @cDropListSP = rdt.RDTGetConfig( @nFunc, 'DropListSP', @cStorerKey)
      IF @cDropListSP = '0'
         SET @cDropListSP = ''
      SET @cCapturePalletType = rdt.RDTGetConfig( @nFunc, 'CapturePalletType', @cStorerKey)
      IF @cCapturePalletType = '0'
         SET @cCapturePalletType = ''

      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + @cExtendedValidateSP +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU, ' +
               ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
               ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
               ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
               ' @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile      INT,           ' +
               '@nFunc        INT,           ' +
               '@cLangCode    NVARCHAR( 3),  ' +
               '@nStep        INT,           ' +
               '@nInputKey    INT,           ' +
               '@cFacility    NVARCHAR( 5),  ' +
               '@cStorerKey   NVARCHAR( 15), ' +
               '@cKitKey      NVARCHAR( 10), ' +
               '@cExtKitKey   NVARCHAR( 20), ' +
               '@cLOC         NVARCHAR( 10), ' +
               '@cID          NVARCHAR( 18), ' +
               '@cSKU         NVARCHAR( 20), ' +
               '@cLottable01  NVARCHAR( 18), ' +
               '@cLottable02  NVARCHAR( 18), ' +
               '@cLottable03  NVARCHAR( 18), ' +
               '@dLottable04  DATETIME,      ' +
               '@dLottable05  DATETIME,      ' +
               '@cLottable06  NVARCHAR( 30), ' +
               '@cLottable07  NVARCHAR( 30), ' +
               '@cLottable08  NVARCHAR( 30), ' +
               '@cLottable09  NVARCHAR( 30), ' +
               '@cLottable10  NVARCHAR( 30), ' +
               '@cLottable11  NVARCHAR( 30), ' +
               '@cLottable12  NVARCHAR( 30), ' +
               '@dLottable13  DATETIME,      ' +
               '@dLottable14  DATETIME,      ' +
               '@dLottable15  DATETIME,      ' +
               '@nQTY         INT,           ' +
               '@cPalletType  NVARCHAR( 10), ' +
               '@cDefaultToLOC   NVARCHAR( 10), ' +
               '@cKitDtlLineNumber NVARCHAR( 5), ' +
               '@nErrNo             INT            OUTPUT, ' +
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU,
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_1_Fail
         END
      END

      IF @cDefaultToLOCSP <> '' AND
         EXISTS( SELECT 1 FROM sys.objects WHERE name = @cDefaultToLOCSP AND type = 'P')
      BEGIN
         BEGIN
            SET @cSQL = 'EXEC rdt.' + @cDefaultToLOCSP +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, ' +
               ' @cDefaultToLOC OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,           ' +
               '@nFunc           INT,           ' +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,           ' +
               '@nInputKey       INT,           ' +
               '@cFacility       NVARCHAR( 5),  ' +
               '@cStorerKey      NVARCHAR( 15), ' +
               '@cKitKey     NVARCHAR( 10), ' +
               '@cExtKitKey          NVARCHAR( 10), ' +
               '@cDefaultToLOC   NVARCHAR( 10)  OUTPUT, ' +
               '@nErrNo          INT            OUTPUT, ' +
               '@cErrMsg         NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, 
               @cDefaultToLOC OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_1_Fail
         END
      END

      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + @cExtendedUpdateSP +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU, ' +
               ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
               ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
               ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
               ' @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile      INT,           ' +
               '@nFunc        INT,           ' +
               '@cLangCode    NVARCHAR( 3),  ' +
               '@nStep        INT,           ' +
               '@nInputKey    INT,           ' +
               '@cFacility    NVARCHAR( 5),  ' +
               '@cStorerKey   NVARCHAR( 15), ' +
               '@cKitKey      NVARCHAR( 10), ' +
               '@cExtKitKey   NVARCHAR( 20), ' +
               '@cLOC         NVARCHAR( 10), ' +
               '@cID          NVARCHAR( 18), ' +
               '@cSKU         NVARCHAR( 20), ' +
               '@cLottable01  NVARCHAR( 18), ' +
               '@cLottable02  NVARCHAR( 18), ' +
               '@cLottable03  NVARCHAR( 18), ' +
               '@dLottable04  DATETIME,      ' +
               '@dLottable05  DATETIME,      ' +
               '@cLottable06  NVARCHAR( 30), ' +
               '@cLottable07  NVARCHAR( 30), ' +
               '@cLottable08  NVARCHAR( 30), ' +
               '@cLottable09  NVARCHAR( 30), ' +
               '@cLottable10  NVARCHAR( 30), ' +
               '@cLottable11  NVARCHAR( 30), ' +
               '@cLottable12  NVARCHAR( 30), ' +
               '@dLottable13  DATETIME,      ' +
               '@dLottable14  DATETIME,      ' +
               '@dLottable15  DATETIME,      ' +
               '@nQTY         INT,           ' +
               '@cPalletType  NVARCHAR( 10), ' +
               '@cDefaultToLOC   NVARCHAR( 10), ' +
               '@cKitDtlLineNumber NVARCHAR( 5), ' +
               '@nErrNo             INT            OUTPUT, ' +
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU,
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber,
               @nErrNo OUTPUT, @cErrMsg OUTPUT
         END

         IF @nErrno<>0
            GOTO Step_1_Fail
      END

      -- EventLog -- (ChewKP01)
      EXEC RDT.rdt_STD_EventLog
         @cUserID     = @cUserName,
         @nMobileNo   = @nMobile,
         @nFunctionID = @nFunc,
         @cFacility   = @cFacility,
         @cStorerKey  = @cStorerKey,
         @nStep       = @nStep,
         @cRefNo1     = @cKitKey

      -- Prepare next screen var
      SET @cOutField01 = @cKitKey
      SET @cOutField02 = @cExtKitKey
      SET @cOutField03 = @cDefaultToLOC

      -- Go to next screen
      SET @nScn = @nScn + 1
      SET @nStep = @nStep + 1
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

   -- Extended info
   IF @cExtendedInfoSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedInfoSP AND type = 'P')
      BEGIN
         SET @cExtendedInfo = ''
         SET @cSQL = 'EXEC rdt.' + @cExtendedInfoSP +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU, ' +
            ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
            ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
            ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
            ' @nQTY, @cPalletType, @cDefaultToLOC,' +
            ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
         SET @cSQLParam =
            '@nMobile       INT,           ' +
            '@nFunc         INT,           ' +
            '@cLangCode     NVARCHAR( 3),  ' +
            '@nStep         INT,           ' +
            '@nAfterStep    INT,           ' +
            '@nInputKey     INT,           ' +
            '@cFacility     NVARCHAR( 5),  ' +
            '@cStorerKey    NVARCHAR( 15), ' +
            '@cKitKey       NVARCHAR( 10), ' +
            '@cExtKitKey    NVARCHAR( 20), ' +
            '@cLOC          NVARCHAR( 10), ' +
            '@cID           NVARCHAR( 18), ' +
            '@cSKU          NVARCHAR( 20), ' +
            '@cLottable01   NVARCHAR( 18), ' +
            '@cLottable02   NVARCHAR( 18), ' +
            '@cLottable03   NVARCHAR( 18), ' +
            '@dLottable04   DATETIME,      ' +
            '@dLottable05   DATETIME,      ' +
            '@cLottable06   NVARCHAR( 30), ' +
            '@cLottable07   NVARCHAR( 30), ' +
            '@cLottable08   NVARCHAR( 30), ' +
            '@cLottable09   NVARCHAR( 30), ' +
            '@cLottable10   NVARCHAR( 30), ' +
            '@cLottable11   NVARCHAR( 30), ' +
            '@cLottable12   NVARCHAR( 30), ' +
            '@dLottable13   DATETIME,      ' +
            '@dLottable14   DATETIME,      ' +
            '@dLottable15   DATETIME,      ' +
            '@nQTY          INT,           ' +
            '@cPalletType   NVARCHAR( 10), ' +
            '@cDefaultToLOC NVARCHAR( 10), ' +
            '@cExtendedInfo NVARCHAR(20)  OUTPUT, ' +
            '@nErrNo        INT           OUTPUT, ' +
            '@cErrMsg       NVARCHAR( 20) OUTPUT'

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, 4, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU,
            @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
            @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
            @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
            @nQTY, @cPalletType, @cDefaultToLOC,
            @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

         IF @nErrNo <> 0
            GOTO Step_1_Fail

         SET @cOutField15 = @cExtendedInfo
      END
   END

   GOTO Quit

   Step_1_Fail:
   BEGIN
      -- Reset this screen var
      SET @cOutField01 = '' -- KitKey
      SET @cOutField02 = '' -- ExtKitKey
      SET @cKitKey = ''
      SET @cExtKitKey = ''
   END
END
GOTO Quit


/********************************************************************************
Step 2. Scn = 6571. Location screen
   Kit      (field01)
   ExtKit   (field02)
   TOLOC    (field03, input)
********************************************************************************/
Step_2:
BEGIN
   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      -- Screen mapping
      SET @cLOC = @cInField03 -- LOC

      -- Validate compulsary field
      IF @cLOC = '' OR @cLOC IS NULL
      BEGIN
         SET @nErrNo = 234761
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need LOC
         GOTO Step_2_Fail
      END

      --Loc Prefix
      IF @cLOCLookupSP = 1
      BEGIN
         EXEC rdt.rdt_LOCLookUp @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFacility,
            @cLOC       OUTPUT,
            @nErrNo     OUTPUT,
            @cErrMsg    OUTPUT
         IF @nErrNo <> 0
            GOTO Step_2_Fail
      END

      -- Get the location
      SET @cChkLOC = ''
      SET @cChkFacility = ''
      SELECT
         @cChkLOC = LOC,
         @cChkFacility = Facility
      FROM dbo.LOC WITH (NOLOCK)
      WHERE LOC = @cLOC

      -- Validate location
      IF @cChkLOC = ''
      BEGIN
         SET @nErrNo = 234762
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid LOC
         GOTO Step_2_Fail
      END

      -- Validate location not in facility
      IF @cChkFacility <> @cFacility
      BEGIN
         SET @nErrNo = 234763
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff facility
         GOTO Step_2_Fail
      END

      --Check pallet type configured
      IF @cCapturePalletType = '1'
      BEGIN
         SET @nRowCount = 0

         SELECT @nRowCount = COUNT(1)
         FROM dbo.PalletTypeMaster WITH (NOLOCK)
         WHERE Facility = @cFacility
            AND Storerkey = @cStorerKey
            AND PalletTypeInUse = 'Y'

         IF @nRowCount = 0
         BEGIN
            SET @nErrNo = 234778
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoPalletType
            GOTO Step_2_Fail
         END
      END

      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + @cExtendedValidateSP +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU, ' +
               ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
               ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
               ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
               ' @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile      INT,           ' +
               '@nFunc        INT,           ' +
               '@cLangCode    NVARCHAR( 3),  ' +
               '@nStep        INT,           ' +
               '@nInputKey    INT,           ' +
               '@cFacility    NVARCHAR( 5),  ' +
               '@cStorerKey   NVARCHAR( 15), ' +
               '@cKitKey      NVARCHAR( 10), ' +
               '@cExtKitKey   NVARCHAR( 20), ' +
               '@cLOC         NVARCHAR( 10), ' +
               '@cID          NVARCHAR( 18), ' +
               '@cSKU         NVARCHAR( 20), ' +
               '@cLottable01  NVARCHAR( 18), ' +
               '@cLottable02  NVARCHAR( 18), ' +
               '@cLottable03  NVARCHAR( 18), ' +
               '@dLottable04  DATETIME,      ' +
               '@dLottable05  DATETIME,      ' +
               '@cLottable06  NVARCHAR( 30), ' +
               '@cLottable07  NVARCHAR( 30), ' +
               '@cLottable08  NVARCHAR( 30), ' +
               '@cLottable09  NVARCHAR( 30), ' +
               '@cLottable10  NVARCHAR( 30), ' +
               '@cLottable11  NVARCHAR( 30), ' +
               '@cLottable12  NVARCHAR( 30), ' +
               '@dLottable13  DATETIME,      ' +
               '@dLottable14  DATETIME,      ' +
               '@dLottable15  DATETIME,      ' +
               '@nQTY         INT,           ' +
               '@cPalletType  NVARCHAR( 10), ' +
               '@cDefaultToLOC   NVARCHAR( 10), ' +
               '@cKitDtlLineNumber NVARCHAR( 5), ' +
               '@nErrNo             INT            OUTPUT, ' +
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU,
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_2_Fail
         END
      END      

      -- Auto generate ID
      SET @cID = ''
      IF @cAutoGenID <> ''
      BEGIN
         EXEC rdt.rdt_AutoGenID @nMobile, @nFunc, @nStep, @cLangCode
            ,@cAutoGenID
            ,@tExtData
            ,@cAutoID  OUTPUT
            ,@nErrNo   OUTPUT
            ,@cErrMsg  OUTPUT
         IF @nErrNo <> 0
            GOTO Step_2_Fail

         SET @cID = @cAutoID
      END

      --Ext Upd
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + @cExtendedUpdateSP +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU, ' +
               ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
               ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
               ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
               ' @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile      INT,           ' +
               '@nFunc        INT,           ' +
               '@cLangCode    NVARCHAR( 3),  ' +
               '@nStep        INT,           ' +
               '@nInputKey    INT,           ' +
               '@cFacility    NVARCHAR( 5),  ' +
               '@cStorerKey   NVARCHAR( 15), ' +
               '@cKitKey      NVARCHAR( 10), ' +
               '@cExtKitKey   NVARCHAR( 20), ' +
               '@cLOC         NVARCHAR( 10), ' +
               '@cID          NVARCHAR( 18), ' +
               '@cSKU         NVARCHAR( 20), ' +
               '@cLottable01  NVARCHAR( 18), ' +
               '@cLottable02  NVARCHAR( 18), ' +
               '@cLottable03  NVARCHAR( 18), ' +
               '@dLottable04  DATETIME,      ' +
               '@dLottable05  DATETIME,      ' +
               '@cLottable06  NVARCHAR( 30), ' +
               '@cLottable07  NVARCHAR( 30), ' +
               '@cLottable08  NVARCHAR( 30), ' +
               '@cLottable09  NVARCHAR( 30), ' +
               '@cLottable10  NVARCHAR( 30), ' +
               '@cLottable11  NVARCHAR( 30), ' +
               '@cLottable12  NVARCHAR( 30), ' +
               '@dLottable13  DATETIME,      ' +
               '@dLottable14  DATETIME,      ' +
               '@dLottable15  DATETIME,      ' +
               '@nQTY         INT,           ' +
               '@cPalletType  NVARCHAR( 10), ' +
               '@cDefaultToLOC   NVARCHAR( 10), ' +
               '@cKitDtlLineNumber NVARCHAR( 5), ' +
               '@nErrNo             INT            OUTPUT, ' +
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU,
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber,
               @nErrNo OUTPUT, @cErrMsg OUTPUT
         END

         IF @nErrno<>0
            GOTO Step_2_Fail
      END

      -- Prepare next screen var
      SET @cOutField01 = @cLOC
      SET @cOutField02 = @cID
      IF @cCapturePalletType = '1'
      BEGIN
         SET @cOutField04 = @cDropListSP
      END
      ELSE
      BEGIN
         SET @cFieldAttr04 = 'O'
         SET @cInField04 = ''
         SET @cOutField04 = ''
      END

      -- Go to next screen
      SET @nScn  = @nScn + 1
      SET @nStep = @nStep + 1
   END

   IF @nInputKey = 0 -- Esc or No
   BEGIN
      -- Prepare prev screen var
      SET @cOutField01 = ''
      SET @cOutField02 = ''

      SET @nScn = @nScn - 1
      SET @nStep = @nStep - 1
   END

   -- Extended info
   IF @cExtendedInfoSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedInfoSP AND type = 'P')
      BEGIN
         SET @cExtendedInfo = ''
         SET @cSQL = 'EXEC rdt.' + @cExtendedInfoSP +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU, ' +
            ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
            ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
            ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
            ' @nQTY, @cPalletType, @cDefaultToLOC,' +
            ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
         SET @cSQLParam =
            '@nMobile       INT,           ' +
            '@nFunc         INT,           ' +
            '@cLangCode     NVARCHAR( 3),  ' +
            '@nStep         INT,           ' +
            '@nAfterStep    INT,           ' +
            '@nInputKey     INT,           ' +
            '@cFacility     NVARCHAR( 5),  ' +
            '@cStorerKey    NVARCHAR( 15), ' +
            '@cKitKey       NVARCHAR( 10), ' +
            '@cExtKitKey    NVARCHAR( 20), ' +
            '@cLOC          NVARCHAR( 10), ' +
            '@cID           NVARCHAR( 18), ' +
            '@cSKU          NVARCHAR( 20), ' +
            '@cLottable01   NVARCHAR( 18), ' +
            '@cLottable02   NVARCHAR( 18), ' +
            '@cLottable03   NVARCHAR( 18), ' +
            '@dLottable04   DATETIME,      ' +
            '@dLottable05   DATETIME,      ' +
            '@cLottable06   NVARCHAR( 30), ' +
            '@cLottable07   NVARCHAR( 30), ' +
            '@cLottable08   NVARCHAR( 30), ' +
            '@cLottable09   NVARCHAR( 30), ' +
            '@cLottable10   NVARCHAR( 30), ' +
            '@cLottable11   NVARCHAR( 30), ' +
            '@cLottable12   NVARCHAR( 30), ' +
            '@dLottable13   DATETIME,      ' +
            '@dLottable14   DATETIME,      ' +
            '@dLottable15   DATETIME,      ' +
            '@nQTY          INT,           ' +
            '@cPalletType   NVARCHAR( 10), ' +
            '@cDefaultToLOC NVARCHAR( 10), ' +
            '@cExtendedInfo NVARCHAR(20)  OUTPUT, ' +
            '@nErrNo        INT           OUTPUT, ' +
            '@cErrMsg       NVARCHAR( 20) OUTPUT'

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, 4, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU,
            @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
            @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
            @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
            @nQTY, @cPalletType, @cDefaultToLOC,
            @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

         IF @nErrNo <> 0
            GOTO Step_2_Fail

         SET @cOutField15 = @cExtendedInfo
      END
   END

   GOTO Quit

   Step_2_Fail:
   BEGIN
      -- Reset this screen var
      SET @cOutField03 = '' -- LOC
      SET @cLOC = ''
   END
END
GOTO Quit

/********************************************************************************
Step 3. Scn = 6572. Pallet ID screen
   TO LOC      (field01)
   TO ID       (field02, input)
   PalletType  (field03, list)
********************************************************************************/
Step_3:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      DECLARE @cIDBarcode NVARCHAR( 60)

      -- Screen mapping
      SET @cID = LEFT( @cInField02, 18) -- ID
      SET @cIDBarcode = @cInField02
      SET @cPalletType = @cInField04 -- PalletType

      IF @cIDBarcode = ''
      BEGIN
         SET @nErrNo = 234779
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need ID
         GOTO Step_3_Fail
      END

      -- Check barcode format
      IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'ID', @cIDBarcode) = 0
      BEGIN
         SET @nErrNo = 234764
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format
         GOTO Step_3_Fail
      END

      SET @cSKU = ''
      -- Decode
      -- Standard decode
      IF @cDecodeSP = '1'
      BEGIN
         EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cIDBarcode,
            @cID           = @cID     OUTPUT,
            @cUserDefine01 = @cUserDefine01 OUTPUT,
            @nErrNo        = @nErrNo  OUTPUT,
            @cErrMsg       = @cErrMsg OUTPUT,
            @cType         = 'ID'

         IF @nErrNo <> 0
            GOTO Step_3_Fail
      END
      ELSE
      BEGIN
         IF @cDecodeSP <> ''
         BEGIN
            IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cDecodeSP AND type = 'P')
            BEGIN
               SELECT @cSKU = '', @nQTY = 0,
                  @cLottable01 = '', @cLottable02 = '', @cLottable03 = '', @dLottable04 = 0,  @dLottable05 = 0,
                  @cLottable06 = '', @cLottable07 = '', @cLottable08 = '', @cLottable09 = '', @cLottable10 = '',
                  @cLottable11 = '', @cLottable12 = '', @dLottable13 = 0,  @dLottable14 = 0,  @dLottable15 = 0

               SET @cSQL = 'EXEC rdt.' + @cDecodeSP +
                  ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cBarcode OUTPUT, @cFieldName, ' +
                  ' @cID         OUTPUT, @cSKU        OUTPUT, @nQTY        OUTPUT, ' +
                  ' @cLottable01 OUTPUT, @cLottable02 OUTPUT, @cLottable03 OUTPUT, @dLottable04 OUTPUT, @dLottable05 OUTPUT, ' +
                  ' @cLottable06 OUTPUT, @cLottable07 OUTPUT, @cLottable08 OUTPUT, @cLottable09 OUTPUT, @cLottable10 OUTPUT, ' +
                  ' @cLottable11 OUTPUT, @cLottable12 OUTPUT, @dLottable13 OUTPUT, @dLottable14 OUTPUT, @dLottable15 OUTPUT, ' +
                  ' @nErrNo      OUTPUT, @cErrMsg     OUTPUT'
               SET @cSQLParam =
                  ' @nMobile      INT,             ' +
                  ' @nFunc        INT,             ' +
                  ' @cLangCode    NVARCHAR( 3),    ' +
                  ' @nStep        INT,             ' +
                  ' @nInputKey    INT,             ' +
                  ' @cStorerKey   NVARCHAR( 15),   ' +
                  ' @cKitKey      NVARCHAR( 10),   ' +
                  ' @cExtKitKey   NVARCHAR( 20),   ' +
                  ' @cLOC         NVARCHAR( 10),   ' +
                  ' @cBarcode     NVARCHAR( 2000) OUTPUT, ' +
                  ' @cFieldName   NVARCHAR( 10),   ' +
                  ' @cID          NVARCHAR( 18)  OUTPUT, ' +
                  ' @cSKU         NVARCHAR( 20)  OUTPUT, ' +
                  ' @nQTY         INT            OUTPUT, ' +
                  ' @cLottable01  NVARCHAR( 18)  OUTPUT, ' +
                  ' @cLottable02  NVARCHAR( 18)  OUTPUT, ' +
                  ' @cLottable03  NVARCHAR( 18)  OUTPUT, ' +
                  ' @dLottable04  DATETIME       OUTPUT, ' +
                  ' @dLottable05  DATETIME       OUTPUT, ' +
                  ' @cLottable06  NVARCHAR( 30)  OUTPUT, ' +
                  ' @cLottable07  NVARCHAR( 30)  OUTPUT, ' +
                  ' @cLottable08  NVARCHAR( 30)  OUTPUT, ' +
                  ' @cLottable09  NVARCHAR( 30)  OUTPUT, ' +
                  ' @cLottable10  NVARCHAR( 30)  OUTPUT, ' +
                  ' @cLottable11  NVARCHAR( 30)  OUTPUT, ' +
                  ' @cLottable12  NVARCHAR( 30)  OUTPUT, ' +
                  ' @dLottable13  DATETIME       OUTPUT, ' +
                  ' @dLottable14  DATETIME       OUTPUT, ' +
                  ' @dLottable15  DATETIME       OUTPUT, ' +
                  ' @nErrNo       INT            OUTPUT, ' +
                  ' @cErrMsg      NVARCHAR( 20)  OUTPUT'

               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                  @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cIDBarcode OUTPUT, 'ID',
                  @cID         OUTPUT, @cSKU        OUTPUT, @nQTY        OUTPUT,
                  @cLottable01 OUTPUT, @cLottable02 OUTPUT, @cLottable03 OUTPUT, @dLottable04 OUTPUT, @dLottable05 OUTPUT,
                  @cLottable06 OUTPUT, @cLottable07 OUTPUT, @cLottable08 OUTPUT, @cLottable09 OUTPUT, @cLottable10 OUTPUT,
                  @cLottable11 OUTPUT, @cLottable12 OUTPUT, @dLottable13 OUTPUT, @dLottable14 OUTPUT, @dLottable15 OUTPUT,
                  @nErrNo      OUTPUT, @cErrMsg     OUTPUT

               IF @nErrNo <> 0
                  GOTO Step_3_Fail
            END
         END
      END

      -- Validate pallet id exist in stock. If config turn on then not allow reuse
      IF @cCheckIDInUse = '1'
      BEGIN
         IF EXISTS( SELECT [ID]
            FROM dbo.LOTxLOCxID LOTxLOCxID WITH (NOLOCK)
            INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON (LOTxLOCxID.LOC = LOC.LOC)
            WHERE [ID] = @cID
            AND   QTY > 0
            AND   StorerKey = @cStorerKey
            AND   LOC.Facility = @cFacility)
         BEGIN
            SET @nErrNo = 234765
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID in Use
            GOTO Step_3_Fail
         END
      END

      -- Check ID used in other KITs
      IF @cCheckIDCrsKit = 1
      BEGIN
         IF EXISTS (SELECT 1 FROM  dbo.KitDetail KD WITH (NOLOCK)
                    JOIN dbo.KIT K WITH (NOLOCK) ON (KD.KITKey = K.KITKey)
                     WHERE K.KITKey <> @cKitKey
                     AND ID = @cID
                     AND K.Facility = @cFacility
                     AND K.StorerKey = @cStorerKey
                     AND K.Status <> '9')
         BEGIN
            SET @nErrNo = 234766
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Occupied ID
            GOTO Step_3_Fail
         END
      END

      -- Check pallet used in current kitting
      IF @cCheckIDInKit = '1'
      BEGIN
         IF EXISTS (SELECT 1 FROM  dbo.KitDetail WITH (NOLOCK)
                    WHERE KITKey = @cKitKey
                    AND StorerKey = @cStorerKey
                    AND ID = @cID
                   )
         BEGIN
            SET @nErrNo = 234777
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Duplicate ID
            GOTO Step_3_Fail
         END
      END

      IF @cCapturePalletType = '1'
      BEGIN
         IF @cPalletType = ''
         BEGIN
            SET @nErrNo = 234767
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Pallet Type
            GOTO Step_3_Fail
         END

         SELECT
            @cPalletTypeInUse = PalletTypeInUse
         FROM dbo.PalletTypeMaster WITH (NOLOCK)
         WHERE PalletType = @cPalletType
            AND StorerKey = @cStorerKey
            AND FACILITY  = @cFacility

         SET @nRowCount = @@ROWCOUNT

         IF @nRowCount = 0
         BEGIN
            SET @nErrNo = 234768
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Pallet Type
            GOTO Step_3_Fail
         END

         --Whether pallettype in use
         IF @cPalletTypeInUse <> 'Y'
         BEGIN
            SET @nErrNo = 234769
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pallet Type Not in Use
            GOTO Step_3_Fail
         END
      END
      ELSE
         SET @cPalletType = ''

      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + @cExtendedValidateSP +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU, ' +
               ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
               ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
               ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
               ' @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile      INT,           ' +
               '@nFunc        INT,           ' +
               '@cLangCode    NVARCHAR( 3),  ' +
               '@nStep        INT,           ' +
               '@nInputKey    INT,           ' +
               '@cFacility    NVARCHAR( 5),  ' +
               '@cStorerKey   NVARCHAR( 15), ' +
               '@cKitKey      NVARCHAR( 10), ' +
               '@cExtKitKey   NVARCHAR( 20), ' +
               '@cLOC         NVARCHAR( 10), ' +
               '@cID          NVARCHAR( 18), ' +
               '@cSKU         NVARCHAR( 20), ' +
               '@cLottable01  NVARCHAR( 18), ' +
               '@cLottable02  NVARCHAR( 18), ' +
               '@cLottable03  NVARCHAR( 18), ' +
               '@dLottable04  DATETIME,      ' +
               '@dLottable05  DATETIME,      ' +
               '@cLottable06  NVARCHAR( 30), ' +
               '@cLottable07  NVARCHAR( 30), ' +
               '@cLottable08  NVARCHAR( 30), ' +
               '@cLottable09  NVARCHAR( 30), ' +
               '@cLottable10  NVARCHAR( 30), ' +
               '@cLottable11  NVARCHAR( 30), ' +
               '@cLottable12  NVARCHAR( 30), ' +
               '@dLottable13  DATETIME,      ' +
               '@dLottable14  DATETIME,      ' +
               '@dLottable15  DATETIME,      ' +
               '@nQTY         INT,           ' +
               '@cPalletType  NVARCHAR( 10), ' +
               '@cDefaultToLOC   NVARCHAR( 10), ' +
               '@cKitDtlLineNumber NVARCHAR( 5), ' +
               '@nErrNo             INT            OUTPUT, ' +
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU,
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_3_Fail
         END
      END

      --Ext Upd
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + @cExtendedUpdateSP +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU, ' +
               ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
               ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
               ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
               ' @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile      INT,           ' +
               '@nFunc        INT,           ' +
               '@cLangCode    NVARCHAR( 3),  ' +
               '@nStep        INT,           ' +
               '@nInputKey    INT,           ' +
               '@cFacility    NVARCHAR( 5),  ' +
               '@cStorerKey   NVARCHAR( 15), ' +
               '@cKitKey      NVARCHAR( 10), ' +
               '@cExtKitKey   NVARCHAR( 20), ' +
               '@cLOC         NVARCHAR( 10), ' +
               '@cID          NVARCHAR( 18), ' +
               '@cSKU         NVARCHAR( 20), ' +
               '@cLottable01  NVARCHAR( 18), ' +
               '@cLottable02  NVARCHAR( 18), ' +
               '@cLottable03  NVARCHAR( 18), ' +
               '@dLottable04  DATETIME,      ' +
               '@dLottable05  DATETIME,      ' +
               '@cLottable06  NVARCHAR( 30), ' +
               '@cLottable07  NVARCHAR( 30), ' +
               '@cLottable08  NVARCHAR( 30), ' +
               '@cLottable09  NVARCHAR( 30), ' +
               '@cLottable10  NVARCHAR( 30), ' +
               '@cLottable11  NVARCHAR( 30), ' +
               '@cLottable12  NVARCHAR( 30), ' +
               '@dLottable13  DATETIME,      ' +
               '@dLottable14  DATETIME,      ' +
               '@dLottable15  DATETIME,      ' +
               '@nQTY         INT,           ' +
               '@cPalletType  NVARCHAR( 10), ' +
               '@cDefaultToLOC   NVARCHAR( 10), ' +
               '@cKitDtlLineNumber NVARCHAR( 5), ' +
               '@nErrNo             INT            OUTPUT, ' +
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU,
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber,
               @nErrNo OUTPUT, @cErrMsg OUTPUT
         END

         IF @nErrno<>0
            GOTO Step_3_Fail
      END

      -- Init next screen var
      SET @cOutField01 = @cID
      SET @cOutField02 = @cPalletType
      SET @cMax = @cSKU -- SKU
      SET @cOutField03 = '' -- SKUDesc1
      SET @cOutField04 = '' -- SKUDesc2

      -- Go to next screen
      SET @nScn  = @nScn + 1
      SET @nStep = @nStep + 1
   END

   IF @nInputKey = 0 -- Esc or No
   BEGIN
      -- Prepare prev screen var
      SET @cOutField01 = @cKitKey
      SET @cOutField02 = @cExtKitKey
      SET @cOutField03 = @cLOC

      SET @nScn = @nScn - 1
      SET @nStep = @nStep - 1

      GOTO Quit
   END

   -- Extended info
   IF @cExtendedInfoSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedInfoSP AND type = 'P')
      BEGIN
         SET @cExtendedInfo = ''
         SET @cSQL = 'EXEC rdt.' + @cExtendedInfoSP +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU, ' +
            ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
            ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
            ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
            ' @nQTY, @cPalletType, @cDefaultToLOC,' +
            ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
         SET @cSQLParam =
            '@nMobile       INT,           ' +
            '@nFunc         INT,           ' +
            '@cLangCode     NVARCHAR( 3),  ' +
            '@nStep         INT,           ' +
            '@nAfterStep    INT,           ' +
            '@nInputKey     INT,           ' +
            '@cFacility     NVARCHAR( 5),  ' +
            '@cStorerKey    NVARCHAR( 15), ' +
            '@cKitKey       NVARCHAR( 10), ' +
            '@cExtKitKey    NVARCHAR( 20), ' +
            '@cLOC          NVARCHAR( 10), ' +
            '@cID           NVARCHAR( 18), ' +
            '@cSKU          NVARCHAR( 20), ' +
            '@cLottable01   NVARCHAR( 18), ' +
            '@cLottable02   NVARCHAR( 18), ' +
            '@cLottable03   NVARCHAR( 18), ' +
            '@dLottable04   DATETIME,      ' +
            '@dLottable05   DATETIME,      ' +
            '@cLottable06   NVARCHAR( 30), ' +
            '@cLottable07   NVARCHAR( 30), ' +
            '@cLottable08   NVARCHAR( 30), ' +
            '@cLottable09   NVARCHAR( 30), ' +
            '@cLottable10   NVARCHAR( 30), ' +
            '@cLottable11   NVARCHAR( 30), ' +
            '@cLottable12   NVARCHAR( 30), ' +
            '@dLottable13   DATETIME,      ' +
            '@dLottable14   DATETIME,      ' +
            '@dLottable15   DATETIME,      ' +
            '@nQTY          INT,           ' +
            '@cPalletType   NVARCHAR( 10), ' +
            '@cDefaultToLOC NVARCHAR( 10), ' +
            '@cExtendedInfo NVARCHAR(20)  OUTPUT, ' +
            '@nErrNo        INT           OUTPUT, ' +
            '@cErrMsg       NVARCHAR( 20) OUTPUT'

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, 4, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU,
            @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
            @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
            @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
            @nQTY, @cPalletType, @cDefaultToLOC,
            @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

         IF @nErrNo <> 0
            GOTO Step_3_Fail

         SET @cOutField15 = @cExtendedInfo
      END
   END

   GOTO Quit

   Step_3_Fail:
   BEGIN
      -- Reset this screen var
      SET @cOutField02 = '' -- ID
      SET @cOutField04 = @cDropListSP -- PalletType
      SET @cID = ''
      SET @cPalletType = ''
   END
END
GOTO Quit

/********************************************************************************
Step 4. Scn = 6573. SKU screen
   TO ID       (field01)
   PalletType  (field02)
   SKU         (v_max, intput)
   SKU desc    (field03)
   SKU desc    (field04)
********************************************************************************/
Step_4:
BEGIN
   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      DECLARE @cSKUBarcode NVARCHAR( 2000)
      DECLARE @cUPC NVARCHAR(30)

      -- Screen mapping
      SET @cUPC = SUBSTRING( @cMax, 1, 30) -- SKU
      SET @cSKUBarcode = SUBSTRING( @cMax, 1, 2000)

      -- Validate compulsary field
      IF @cSKUBarcode = '' OR @cSKUBarcode IS NULL
      BEGIN
         SET @nErrNo = 234780
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU is required
         GOTO Step_4_Fail
      END

      -- Decode
      IF @cDecodeSP <> ''
      BEGIN
         SET @nTempQTY = @nQty
         SET @nQty = 0

         -- Standard decode
         IF @cDecodeSP = '1'
         BEGIN
            EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cSKUBarcode,
               @cID         OUTPUT, @cUPC        OUTPUT, @nQTY        OUTPUT,
               @cLottable01 OUTPUT, @cLottable02 OUTPUT, @cLottable03 OUTPUT, @dLottable04 OUTPUT, @dLottable05 OUTPUT,
               @cLottable06 OUTPUT, @cLottable07 OUTPUT, @cLottable08 OUTPUT, @cLottable09 OUTPUT, @cLottable10 OUTPUT,
               @cLottable11 OUTPUT, @cLottable12 OUTPUT, @dLottable13 OUTPUT, @dLottable14 OUTPUT, @dLottable15 OUTPUT,
               @cUserDefine01 OUTPUT, @cUserDefine02 OUTPUT, @cUserDefine03 OUTPUT, @cUserDefine04 OUTPUT, @cUserDefine05 OUTPUT,
               @cType   = 'UPC'
         END

         -- Customize decode
         ELSE IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cDecodeSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + @cDecodeSP +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cBarcode OUTPUT, @cFieldName, ' +
               ' @cID         OUTPUT, @cSKU        OUTPUT, @nQTY        OUTPUT, ' +
               ' @cLottable01 OUTPUT, @cLottable02 OUTPUT, @cLottable03 OUTPUT, @dLottable04 OUTPUT, @dLottable05 OUTPUT, ' +
               ' @cLottable06 OUTPUT, @cLottable07 OUTPUT, @cLottable08 OUTPUT, @cLottable09 OUTPUT, @cLottable10 OUTPUT, ' +
               ' @cLottable11 OUTPUT, @cLottable12 OUTPUT, @dLottable13 OUTPUT, @dLottable14 OUTPUT, @dLottable15 OUTPUT, ' +
               ' @nErrNo      OUTPUT, @cErrMsg     OUTPUT'
            SET @cSQLParam =
               ' @nMobile      INT,             ' +
               ' @nFunc        INT,             ' +
               ' @cLangCode    NVARCHAR( 3),    ' +
               ' @nStep        INT,             ' +
               ' @nInputKey    INT,             ' +
               ' @cStorerKey   NVARCHAR( 15),   ' +
               ' @cKitKey      NVARCHAR( 10),   ' +
               ' @cExtKitKey   NVARCHAR( 20),   ' +
               ' @cLOC         NVARCHAR( 10),   ' +
               ' @cBarcode     NVARCHAR( 2000) OUTPUT, ' +
               ' @cFieldName   NVARCHAR( 10),   ' +
               ' @cID          NVARCHAR( 18)  OUTPUT, ' +
               ' @cSKU         NVARCHAR( 20)  OUTPUT, ' +
               ' @nQTY         INT            OUTPUT, ' +
               ' @cLottable01  NVARCHAR( 18)  OUTPUT, ' +
               ' @cLottable02  NVARCHAR( 18)  OUTPUT, ' +
               ' @cLottable03  NVARCHAR( 18)  OUTPUT, ' +
               ' @dLottable04  DATETIME       OUTPUT, ' +
               ' @dLottable05  DATETIME       OUTPUT, ' +
               ' @cLottable06  NVARCHAR( 30)  OUTPUT, ' +
               ' @cLottable07  NVARCHAR( 30)  OUTPUT, ' +
               ' @cLottable08  NVARCHAR( 30)  OUTPUT, ' +
               ' @cLottable09  NVARCHAR( 30)  OUTPUT, ' +
               ' @cLottable10  NVARCHAR( 30)  OUTPUT, ' +
               ' @cLottable11  NVARCHAR( 30)  OUTPUT, ' +
               ' @cLottable12  NVARCHAR( 30)  OUTPUT, ' +
               ' @dLottable13  DATETIME       OUTPUT, ' +
               ' @dLottable14  DATETIME       OUTPUT, ' +
               ' @dLottable15  DATETIME       OUTPUT, ' +
               ' @nErrNo       INT            OUTPUT, ' +
               ' @cErrMsg      NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cSKUBarcode OUTPUT, 'SKU',
               @cID         OUTPUT, @cSKU        OUTPUT, @nQTY        OUTPUT,
               @cLottable01 OUTPUT, @cLottable02 OUTPUT, @cLottable03 OUTPUT, @dLottable04 OUTPUT, @dLottable05 OUTPUT,
               @cLottable06 OUTPUT, @cLottable07 OUTPUT, @cLottable08 OUTPUT, @cLottable09 OUTPUT, @cLottable10 OUTPUT,
               @cLottable11 OUTPUT, @cLottable12 OUTPUT, @dLottable13 OUTPUT, @dLottable14 OUTPUT, @dLottable15 OUTPUT,
               @nErrNo      OUTPUT, @cErrMsg     OUTPUT

            IF @nErrNo <> 0
               GOTO Step_4_Fail

            IF @cSKU <> ''
               SET @cUPC = @cSKU
               SET @cScanBarcode = SUBSTRING(@cSKUBarcode,1,60) --(cc01)
         END

         -- Check something returned from decode
         IF ISNULL( @nQty, 0) = 0
            SET @nQty = @nTempQty   -- Assign back the original value if any
      END

      -- Get SKU
      DECLARE @nSKUCnt INT , @bSuccess NVARCHAR(1)
      SET @nSKUCnt = 0

      -- Check SKU

      EXEC RDT.rdt_GetSKUCNT
          @cStorerKey  = @cStorerKey
         ,@cSKU        = @cUPC
         ,@nSKUCnt     = @nSKUCnt   OUTPUT
         ,@bSuccess    = @bSuccess  OUTPUT
         ,@nErr        = @nErrNo    OUTPUT
         ,@cErrMsg     = @cErrMsg   OUTPUT
         ,@cSKUStatus  = 'ACTIVE'

      IF @nSKUCnt = 0
      BEGIN
         SET @nErrNo = 234770
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid SKU
         GOTO Step_4_Fail
      END

      IF @nSKUCnt = 1
      BEGIN
         EXEC [RDT].[rdt_GETSKU]
             @cStorerKey  = @cStorerKey
            ,@cSKU        = @cUPC          OUTPUT
            ,@bSuccess    = @b_Success     OUTPUT
            ,@nErr        = @nErrNo        OUTPUT
            ,@cErrMsg     = @cErrMsg       OUTPUT
            ,@cSKUStatus  = 'ACTIVE' -- (james06)

         SET @cSKU = @cUPC
      END

      -- Check barcode return multi SKU
      IF @nSKUCnt > 1
      BEGIN
         SET @nErrNo = 234771
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MultiSKUBarcod
         GOTO Step_4_Fail
      END

      -- Get SKU info
      SET @cSKUDesc = ''
      SELECT
         @cSKUDesc = DESCR,
         @cLottableCode = LottableCode
      FROM dbo.SKU WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND SKU = @cSKU

      -- Retain value
      SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 1, 20)  -- SKU desc 1
      SET @cOutField04 = rdt.rdtFormatString( @cSKUDesc, 21, 20) -- SKU desc 2

      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + @cExtendedValidateSP +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU, ' +
               ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
               ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
               ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
               ' @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile      INT,           ' +
               '@nFunc        INT,           ' +
               '@cLangCode    NVARCHAR( 3),  ' +
               '@nStep        INT,           ' +
               '@nInputKey    INT,           ' +
               '@cFacility    NVARCHAR( 5),  ' +
               '@cStorerKey   NVARCHAR( 15), ' +
               '@cKitKey      NVARCHAR( 10), ' +
               '@cExtKitKey   NVARCHAR( 20), ' +
               '@cLOC         NVARCHAR( 10), ' +
               '@cID          NVARCHAR( 18), ' +
               '@cSKU         NVARCHAR( 20), ' +
               '@cLottable01  NVARCHAR( 18), ' +
               '@cLottable02  NVARCHAR( 18), ' +
               '@cLottable03  NVARCHAR( 18), ' +
               '@dLottable04  DATETIME,      ' +
               '@dLottable05  DATETIME,      ' +
               '@cLottable06  NVARCHAR( 30), ' +
               '@cLottable07  NVARCHAR( 30), ' +
               '@cLottable08  NVARCHAR( 30), ' +
               '@cLottable09  NVARCHAR( 30), ' +
               '@cLottable10  NVARCHAR( 30), ' +
               '@cLottable11  NVARCHAR( 30), ' +
               '@cLottable12  NVARCHAR( 30), ' +
               '@dLottable13  DATETIME,      ' +
               '@dLottable14  DATETIME,      ' +
               '@dLottable15  DATETIME,      ' +
               '@nQTY         INT,           ' +
               '@cPalletType  NVARCHAR( 10), ' +
               '@cDefaultToLOC   NVARCHAR( 10), ' +
               '@cKitDtlLineNumber NVARCHAR( 5), ' +
               '@nErrNo             INT            OUTPUT, ' +
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU,
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_4_Fail
         END
      END

      -- Dynamic lottable
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
         @cKitKey,
         @nFunc

      IF @nErrNo <> 0
         GOTO Quit

      --Ext Upd
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + @cExtendedUpdateSP +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU, ' +
               ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
               ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
               ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
               ' @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile      INT,           ' +
               '@nFunc        INT,           ' +
               '@cLangCode    NVARCHAR( 3),  ' +
               '@nStep        INT,           ' +
               '@nInputKey    INT,           ' +
               '@cFacility    NVARCHAR( 5),  ' +
               '@cStorerKey   NVARCHAR( 15), ' +
               '@cKitKey      NVARCHAR( 10), ' +
               '@cExtKitKey   NVARCHAR( 20), ' +
               '@cLOC         NVARCHAR( 10), ' +
               '@cID          NVARCHAR( 18), ' +
               '@cSKU         NVARCHAR( 20), ' +
               '@cLottable01  NVARCHAR( 18), ' +
               '@cLottable02  NVARCHAR( 18), ' +
               '@cLottable03  NVARCHAR( 18), ' +
               '@dLottable04  DATETIME,      ' +
               '@dLottable05  DATETIME,      ' +
               '@cLottable06  NVARCHAR( 30), ' +
               '@cLottable07  NVARCHAR( 30), ' +
               '@cLottable08  NVARCHAR( 30), ' +
               '@cLottable09  NVARCHAR( 30), ' +
               '@cLottable10  NVARCHAR( 30), ' +
               '@cLottable11  NVARCHAR( 30), ' +
               '@cLottable12  NVARCHAR( 30), ' +
               '@dLottable13  DATETIME,      ' +
               '@dLottable14  DATETIME,      ' +
               '@dLottable15  DATETIME,      ' +
               '@nQTY         INT,           ' +
               '@cPalletType  NVARCHAR( 10), ' +
               '@cDefaultToLOC   NVARCHAR( 10), ' +
               '@cKitDtlLineNumber NVARCHAR( 5), ' +
               '@nErrNo             INT            OUTPUT, ' +
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU,
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber,
               @nErrNo OUTPUT, @cErrMsg OUTPUT
         END

         IF @nErrno<>0
            GOTO Step_4_Fail
      END
      
      IF @nMorePage = 1 -- Yes
      BEGIN
         -- Go to dynamic lottable screen
         SET @nFromScn = @nScn
         SET @nScn = 3990
         SET @nStep = @nStep + 1
      END
      ELSE
      BEGIN
         -- Get SKU info
         SELECT
            @cSKUDesc = 
               CASE WHEN @cDispStyleColorSize = '0'
                    THEN ISNULL( DescR, '')
                    ELSE CAST( Style AS NCHAR(20)) +
                         CAST( Color AS NCHAR(10)) +
                         CAST( Size  AS NCHAR(10))
               END,
            @cLottableCode = LottableCode,
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
         FROM dbo.SKU SKU WITH (NOLOCK)
            INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)
         WHERE SKU.StorerKey = @cStorerKey
            AND SKU.SKU = @cSKU

         -- Convert to prefer UOM QTY
         IF @cPUOM = '6' OR -- When preferred UOM = master unit
            @nPUOM_Div = 0  -- UOM not setup
         BEGIN
            SET @cPUOM_Desc = ''
            SET @nPQTY = 0
            SET @nMQTY = @nQTY
            SET @cFieldAttr08 = 'O' -- @nPQTY
         END
         ELSE
         BEGIN
            SET @nPQTY = @nQTY / @nPUOM_Div -- Calc QTY in preferred UOM
            SET @nMQTY = @nQTY % @nPUOM_Div -- Calc the remaining in master unit
            SET @cFieldAttr08 = '' -- @nPQTY
         END

         -- Prepare next screen variable
         SET @cOutField01 = @cSKU
         SET @cOutField02 = rdt.rdtFormatString( @cSKUDesc, 1, 20)
         SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 21, 20)
         --SET @cOutField04 = SUBSTRING( @cIVAS, 1, 20)
         SET @cOutField05 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END
         SET @cOutField06 = rdt.rdtRightAlign( @cPUOM_Desc, 5)
         SET @cOutField07 = rdt.rdtRightAlign( @cMUOM_Desc, 5)
         SET @cOutField08 = CASE WHEN @nPQTY = 0 OR @cFieldAttr08 = 'O' THEN '' ELSE CAST( @nPQTY AS NVARCHAR( 7)) END -- PQTY
         SET @cOutField09 = CASE WHEN @nMQTY = 0 THEN '' ELSE CAST( @nMQTY AS NVARCHAR( 7)) END -- MQTY
         --SET @cOutField10 = '' -- Reason
         SET @cOutField15 = '' -- ExtendedInfo

         IF @cFieldAttr08 = ''
            EXEC rdt.rdtSetFocusField @nMobile, 8 -- PQTY

         -- Go to QTY screen
         SET @nScn = @nScn + 2
         SET @nStep = @nStep + 2

         -- Extended info
         IF @cExtendedInfoSP <> ''
         BEGIN
            IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedInfoSP AND type = 'P')
            BEGIN
               SET @cExtendedInfo = ''
               SET @cSQL = 'EXEC rdt.' + @cExtendedInfoSP +
                  ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU, ' +
                  ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
                  ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
                  ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
                  ' @nQTY, @cPalletType, @cDefaultToLOC,' +
                  ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
               SET @cSQLParam =
                  '@nMobile       INT,           ' +
                  '@nFunc         INT,           ' +
                  '@cLangCode     NVARCHAR( 3),  ' +
                  '@nStep         INT,           ' +
                  '@nAfterStep    INT,           ' +
                  '@nInputKey     INT,           ' +
                  '@cFacility     NVARCHAR( 5),  ' +
                  '@cStorerKey    NVARCHAR( 15), ' +
                  '@cKitKey       NVARCHAR( 10), ' +
                  '@cExtKitKey    NVARCHAR( 20), ' +
                  '@cLOC          NVARCHAR( 10), ' +
                  '@cID           NVARCHAR( 18), ' +
                  '@cSKU          NVARCHAR( 20), ' +
                  '@cLottable01   NVARCHAR( 18), ' +
                  '@cLottable02   NVARCHAR( 18), ' +
                  '@cLottable03   NVARCHAR( 18), ' +
                  '@dLottable04   DATETIME,      ' +
                  '@dLottable05   DATETIME,      ' +
                  '@cLottable06   NVARCHAR( 30), ' +
                  '@cLottable07   NVARCHAR( 30), ' +
                  '@cLottable08   NVARCHAR( 30), ' +
                  '@cLottable09   NVARCHAR( 30), ' +
                  '@cLottable10   NVARCHAR( 30), ' +
                  '@cLottable11   NVARCHAR( 30), ' +
                  '@cLottable12   NVARCHAR( 30), ' +
                  '@dLottable13   DATETIME,      ' +
                  '@dLottable14   DATETIME,      ' +
                  '@dLottable15   DATETIME,      ' +
                  '@nQTY          INT,           ' +
                  '@cPalletType   NVARCHAR( 10), ' +
                  '@cDefaultToLOC NVARCHAR( 10), ' +
                  '@cExtendedInfo NVARCHAR(20)  OUTPUT, ' +
                  '@nErrNo        INT           OUTPUT, ' +
                  '@cErrMsg       NVARCHAR( 20) OUTPUT'

               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                  @nMobile, @nFunc, @cLangCode, 4, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU,
                  @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
                  @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
                  @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
                  @nQTY, @cPalletType, @cDefaultToLOC,
                  @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

               IF @nErrNo <> 0
                  GOTO Step_4_Fail

               SET @cOutField15 = @cExtendedInfo
            END
         END
      END
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Prepare next screen var
      SET @cOutField01 = @cLOC
      SET @cOutField02 = '' -- @cID

      IF @cCapturePalletType = '1'
      BEGIN
         SET @cOutField04 = @cDropListSP
      END
      ELSE
      BEGIN
         SET @cFieldAttr04 = 'O'
         SET @cInField04 = ''
         SET @cOutField04 = ''
      END

      -- Go to ID screen
      SET @nScn = @nScn - 1
      SET @nStep = @nStep - 1

      GOTO Quit
   END

   GOTO Quit

   Step_4_Fail:
   BEGIN
      -- Reset this screen var
      SET @cMax = '' -- SKU
      SET @cSKU = ''
   END
END
GOTO Quit

/********************************************************************************
Step 5. Scn = 3990. Dynamic lottables
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
      declare @nErrNoBackup      INT
      declare @cErrMsgBackup     NVARCHAR( 20)
      DECLARE @cOutField15Backup NVARCHAR( 60) = @cOutField15

      -- Dynamic lottable
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
         @cKitKey,
         @nFunc
   
      IF @nErrNo <> 0
         GOTO Quit

      IF @nMorePage = 1 -- Yes
         GOTO Quit

      -- Enable field
      SET @cFieldAttr02 = '' -- Dynamic lottable 1..5
      SET @cFieldAttr04 = ''
      SET @cFieldAttr06 = ''
      SET @cFieldAttr08 = ''
      SET @cFieldAttr10 = ''

      -- Get SKU info
      SELECT
         @cSKUDesc = 
            CASE WHEN @cDispStyleColorSize = '0'
                 THEN ISNULL( DescR, '')
                 ELSE CAST( Style AS NCHAR(20)) +
                      CAST( Color AS NCHAR(10)) +
                      CAST( Size  AS NCHAR(10))
            END,
         --@cIVAS = IsNULL( IVAS, ''),
         @cLottableCode = LottableCode,
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
      FROM dbo.SKU SKU WITH (NOLOCK)
         INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)
      WHERE SKU.StorerKey = @cStorerKey
         AND SKU.SKU = @cSKU

      -- Convert to prefer UOM QTY
      IF @cPUOM = '6' OR -- When preferred UOM = master unit
         @nPUOM_Div = 0  -- UOM not setup
      BEGIN
         SET @cPUOM_Desc = ''
         SET @nPQTY = 0
         SET @nMQTY = @nQTY
         SET @cFieldAttr08 = 'O' -- @nPQTY
      END
      ELSE
      BEGIN
         SET @nPQTY = @nQTY / @nPUOM_Div -- Calc QTY in preferred UOM
         SET @nMQTY = @nQTY % @nPUOM_Div -- Calc the remaining in master unit
         SET @cFieldAttr08 = '' -- @nPQTY
      END

      -- Prepare next screen variable
      SET @cOutField01 = @cSKU
      SET @cOutField02 = rdt.rdtFormatString( @cSKUDesc, 1, 20)
      SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 21, 20)
      --SET @cOutField04 = SUBSTRING( @cIVAS, 1, 20)
      SET @cOutField05 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END
      SET @cOutField06 = rdt.rdtRightAlign( @cPUOM_Desc, 5)
      SET @cOutField07 = rdt.rdtRightAlign( @cMUOM_Desc, 5)
      SET @cOutField08 = CASE WHEN @nPQTY = 0 OR @cFieldAttr08 = 'O' THEN '' ELSE CAST( @nPQTY AS NVARCHAR( 7)) END -- PQTY
      SET @cOutField09 = CASE WHEN @nMQTY = 0 THEN '' ELSE CAST( @nMQTY AS NVARCHAR( 7)) END -- MQTY
      --SET @cOutField10 = '' -- Reason
      SET @cOutField15 = '' -- ExtendedInfo

      IF @cFieldAttr08 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 8 -- PQTY

      -- Go to QTY screen
      SET @nScn  = @nFromScn + 2
      SET @nStep = @nStep + 1

   END

   IF @nInputKey = 0 -- Esc or No
   BEGIN
      -- Dynamic lottable
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
         @cKitKey,
         @nFunc

      IF @nMorePage = 1 -- Yes
         GOTO Quit

      -- Enable field
      SET @cFieldAttr02 = '' -- Dynamic lottable 1..5
      SET @cFieldAttr04 = '' --
      SET @cFieldAttr06 = '' --
      SET @cFieldAttr08 = '' --
      SET @cFieldAttr10 = '' --

      -- Load prev screen var
      SET @cOutField01 = @cID
      SET @cMax = '' -- @cSKU
      SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 1, 20)  -- SKU desc 1
      SET @cOutField04 = rdt.rdtFormatString( @cSKUDesc, 21, 20) -- SKU desc 2
      SET @cOutField05 = ''
      
      -- Go back to prev screen
      SET @nScn = @nFromScn
      SET @nStep = @nStep - 1
   END

   -- Extended info
   IF @cExtendedInfoSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedInfoSP AND type = 'P')
      BEGIN
         SET @cExtendedInfo = ''
         SET @cSQL = 'EXEC rdt.' + @cExtendedInfoSP +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU, ' +
            ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
            ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
            ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
            ' @nQTY, @cPalletType, @cDefaultToLOC,' +
            ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
         SET @cSQLParam =
            '@nMobile       INT,           ' +
            '@nFunc         INT,           ' +
            '@cLangCode     NVARCHAR( 3),  ' +
            '@nStep         INT,           ' +
            '@nAfterStep    INT,           ' +
            '@nInputKey     INT,           ' +
            '@cFacility     NVARCHAR( 5),  ' +
            '@cStorerKey    NVARCHAR( 15), ' +
            '@cKitKey       NVARCHAR( 10), ' +
            '@cExtKitKey    NVARCHAR( 20), ' +
            '@cLOC          NVARCHAR( 10), ' +
            '@cID           NVARCHAR( 18), ' +
            '@cSKU          NVARCHAR( 20), ' +
            '@cLottable01   NVARCHAR( 18), ' +
            '@cLottable02   NVARCHAR( 18), ' +
            '@cLottable03   NVARCHAR( 18), ' +
            '@dLottable04   DATETIME,      ' +
            '@dLottable05   DATETIME,      ' +
            '@cLottable06   NVARCHAR( 30), ' +
            '@cLottable07   NVARCHAR( 30), ' +
            '@cLottable08   NVARCHAR( 30), ' +
            '@cLottable09   NVARCHAR( 30), ' +
            '@cLottable10   NVARCHAR( 30), ' +
            '@cLottable11   NVARCHAR( 30), ' +
            '@cLottable12   NVARCHAR( 30), ' +
            '@dLottable13   DATETIME,      ' +
            '@dLottable14   DATETIME,      ' +
            '@dLottable15   DATETIME,      ' +
            '@nQTY          INT,           ' +
            '@cPalletType   NVARCHAR( 10), ' +
            '@cDefaultToLOC NVARCHAR( 10), ' +
            '@cExtendedInfo NVARCHAR(20)  OUTPUT, ' +
            '@nErrNo        INT           OUTPUT, ' +
            '@cErrMsg       NVARCHAR( 20) OUTPUT'

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, 4, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU,
            @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
            @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
            @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
            @nQTY, @cPalletType, @cDefaultToLOC,
            @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

         IF @nErrNo <> 0
            GOTO Step_5_Fail

         SET @cOutField15 = @cExtendedInfo
      END
   END

   GOTO Quit

   Step_5_Fail:
   -- After captured lottable, screen exit and the hidden field (O_Field15) is clear. 
   -- If any error occur, need to simulate as if still staying in lottable screen, by restoring this hidden field
   SET @cOutField15 = @cOutField15Backup
END
GOTO Quit


/********************************************************************************
Step 6. Scn = 6575. QTY screen
   SKU       (field01)
   SKU desc  (field02)
   SKU desc  (field03)
   UOM ratio (field05)
   PUOM      (field06)
   MUOM   (field07)
   PQTY      (field08, input)
   MQTY      (field09, input)
********************************************************************************/
Step_6:
BEGIN
   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      DECLARE @cPQTY       NVARCHAR( 10)
      DECLARE @cMQTY       NVARCHAR( 10)
      DECLARE @nShelfLife  FLOAT
      DECLARE @cResultCode NVARCHAR( 60)

      -- Screen mapping
      SET @cPQTY = CASE WHEN @cFieldAttr08 = 'O' THEN @cOutField08 ELSE @cInField08 END
      SET @cMQTY = CASE WHEN @cFieldAttr09 = 'O' THEN @cOutField09 ELSE @cInField09 END

      -- Retain value
      SET @cOutField08 = CASE WHEN @cFieldAttr08 = 'O' THEN @cOutField08 ELSE @cInField08 END -- PQTY
      SET @cOutField09 = CASE WHEN @cFieldAttr09 = 'O' THEN @cOutField09 ELSE @cInField09 END -- MQTY

      -- Validate MQTY
      IF @cMQTY <> '' AND RDT.rdtIsValidQTY( @cMQTY, 0) = 0
      BEGIN
         SET @nErrNo = 234772
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid QTY
         EXEC rdt.rdtSetFocusField @nMobile, 9 -- MQTY
         GOTO Step_6_Fail
      END
      SET @nMQTY = CAST( @cMQTY AS INT)

      -- Calc total QTY in master UOM
      IF @cDecimalQty = '1' -- Config not support yet. Alwasy is 0
      BEGIN
         -- Validate PQTY
         IF LEN(STUFF(@cPQTY,1,charindex('.',@cPQTY),'')) > 6
         BEGIN
            SET @nErrNo = 234773
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Decimal Error
            EXEC rdt.rdtSetFocusField @nMobile, 8 -- PQTY
            GOTO Step_6_Fail
         END
         IF @cPQTY <> '' AND RDT.rdtIsValidQTY( @cPQTY, 20) = 0 -- Check for decimal qty
         BEGIN
            SET @nErrNo = 234774
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid QTY
            EXEC rdt.rdtSetFocusField @nMobile, 8 -- PQTY
            GOTO Step_6_Fail
         END
         SET @nQTY = rdt.rdtConvUOMQtyDecimal( @cStorerKey, @cSKU, CAST(@cOutField08 AS FLOAT ), @cPUOM, 6) -- Convert to QTY in master UOM
         IF @nQTY IS NULL
         BEGIN
            SET @nErrNo = 234775
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ConvDecimalErr
            EXEC rdt.rdtSetFocusField @nMobile, 8 -- PQTY
            GOTO Step_6_Fail
         END
         SET @nQTY = @nQTY + @nMQTY
      END --Decimal qty
      ELSE
      BEGIN
         -- Validate PQTY
         IF @cPQTY <> '' AND RDT.rdtIsValidQTY( @cPQTY, 0) = 0
         BEGIN
            SET @nErrNo = 234776
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid QTY
            EXEC rdt.rdtSetFocusField @nMobile, 8 -- PQTY
            GOTO Step_6_Fail
         END
         SET @nPQTY = CAST( @cPQTY AS INT)
         SET @nQTY = rdt.rdtConvUOMQTY( @cStorerKey, @cSKU, @cPQTY, @cPUOM, 6) -- Convert to QTY in master UOM
         SET @nQTY = @nQTY + @nMQTY
      END
      
      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + @cExtendedValidateSP +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU, ' +
               ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
               ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
               ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
               ' @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile      INT,           ' +
               '@nFunc        INT,           ' +
               '@cLangCode    NVARCHAR( 3),  ' +
               '@nStep        INT,           ' +
               '@nInputKey    INT,           ' +
               '@cFacility    NVARCHAR( 5),  ' +
               '@cStorerKey   NVARCHAR( 15), ' +
               '@cKitKey      NVARCHAR( 10), ' +
               '@cExtKitKey   NVARCHAR( 20), ' +
               '@cLOC         NVARCHAR( 10), ' +
               '@cID          NVARCHAR( 18), ' +
               '@cSKU         NVARCHAR( 20), ' +
               '@cLottable01  NVARCHAR( 18), ' +
               '@cLottable02  NVARCHAR( 18), ' +
               '@cLottable03  NVARCHAR( 18), ' +
               '@dLottable04  DATETIME,      ' +
               '@dLottable05  DATETIME,      ' +
               '@cLottable06  NVARCHAR( 30), ' +
               '@cLottable07  NVARCHAR( 30), ' +
               '@cLottable08  NVARCHAR( 30), ' +
               '@cLottable09  NVARCHAR( 30), ' +
               '@cLottable10  NVARCHAR( 30), ' +
               '@cLottable11  NVARCHAR( 30), ' +
               '@cLottable12  NVARCHAR( 30), ' +
               '@dLottable13  DATETIME,      ' +
               '@dLottable14  DATETIME,      ' +
               '@dLottable15  DATETIME,      ' +
               '@nQTY         INT,           ' +
               '@cPalletType  NVARCHAR( 10), ' +
               '@cDefaultToLOC   NVARCHAR( 10), ' +
               '@cKitDtlLineNumber NVARCHAR( 5), ' +
               '@nErrNo             INT            OUTPUT, ' +
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU,
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_6_Fail
         END
      END

      -- Get UOM
      DECLARE @cUOM NVARCHAR(10)
      SELECT @cUOM = PackUOM3
      FROM dbo.SKU WITH (NOLOCK)
         JOIN dbo.Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)
      WHERE StorerKey = @cStorerKey
         AND SKU = @cSKU

      SET @cKitDtlLineNumber=''
      -- Custom Kitting logic
      IF @cConfirmSP <> ''
      BEGIN
         SET @cSQL = 'EXEC rdt.' + @cConfirmSP +
            ' @nFunc, @nMobile, @cLangCode, @cStorerKey, @cFacility, @cKitKey, @cExtKitKey, @cToLOC, @cToID, ' +
            ' @cSKUCode, @cSKUUOM, @nSKUQTY,' +
            ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
            ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
            ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
            ' @nErrNo OUTPUT, @cErrMsg OUTPUT, @cKitDtlLineNumber OUTPUT '

         SET @cSQLParam =
            '@nFunc          INT,            ' +
            '@nMobile        INT,            ' +
            '@cLangCode      NVARCHAR( 3),   ' +
            '@cStorerKey     NVARCHAR( 15),  ' +
            '@cFacility      NVARCHAR( 5),   ' +
            '@cKitKey        NVARCHAR( 10),  ' +
            '@cExtKitKey     NVARCHAR( 20),  ' +
            '@cToLOC         NVARCHAR( 10),  ' +
            '@cToID          NVARCHAR( 18),  ' +
            '@cSKUCode       NVARCHAR( 20),  ' +
            '@cSKUUOM        NVARCHAR( 10),  ' +
            '@nSKUQTY        INT,            ' +
            '@cLottable01    NVARCHAR( 18),  ' +
            '@cLottable02    NVARCHAR( 18),  ' +
            '@cLottable03    NVARCHAR( 18),  ' +
            '@dLottable04    DATETIME,       ' +
            '@dLottable05    DATETIME,       ' +
            '@cLottable06    NVARCHAR( 30),  ' +
            '@cLottable07    NVARCHAR( 30),  ' +
            '@cLottable08    NVARCHAR( 30),  ' +
            '@cLottable09    NVARCHAR( 30),  ' +
            '@cLottable10    NVARCHAR( 30),  ' +
            '@cLottable11    NVARCHAR( 30),  ' +
            '@cLottable12    NVARCHAR( 30),  ' +
            '@dLottable13    DATETIME,       ' +
            '@dLottable14    DATETIME,       ' +
            '@dLottable15    DATETIME,       ' +
            '@nErrNo         INT           OUTPUT, ' +
            '@cErrMsg        NVARCHAR( 20) OUTPUT, ' +
            '@cKitDtlLineNumber NVARCHAR( 5) OUTPUT '

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nFunc, @nMobile, @cLangCode, @cStorerKey, @cFacility, @cKitKey, @cExtKitKey, @cLOC, @cID,
            @cSKU, @cUOM, @nQTY,
            @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
            @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
            @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
            @nErrNo OUTPUT, @cErrMsg OUTPUT,@cKitDtlLineNumber OUTPUT
      END
      ELSE
      BEGIN
         EXEC rdt.rdt_BuildPalletToKit_Confirm
         @nFunc         = @nFunc,  
         @nMobile       = @nMobile,  
         @cLangCode     = @cLangCode,  
         @nErrNo        = @nErrNo     OUTPUT,  
         @cErrMsg       = @cErrMsg    OUTPUT, -- screen limitation, 20 char max  
         @cStorerKey    = @cStorerKey,  
         @cFacility     = @cFacility,  
         @cKitKey       = @cKitKey,  
         @cExtKitKey    = @cExtKitKey,
         @cToLOC        = @cLOC,  
         @cToID         = @cID, -- Blank = to blank ToID 
         @cPalletType   = @cPalletType, 
         @cSKUCode      = @cSKU, -- SKU code. Not SKU barcode  
         @cSKUUOM       = @cUOM, -- SKU UOM
         @nSKUQTY       = @nQTY,       -- In master unit  
         @cLottable01   = @cLottable01,    
         @cLottable02   = @cLottable02,
         @cLottable03   = @cLottable03,     
         @dLottable04   = @dLottable04,
         @dLottable05   = @dLottable05, --@dLottable05,
         @cLottable06   = @cLottable06,  
         @cLottable07   = @cLottable07,
         @cLottable08   = @cLottable08,
         @cLottable09   = @cLottable09,
         @cLottable10   = @cLottable10,
         @cLottable11   = @cLottable11,
         @cLottable12   = @cLottable12,
         @dLottable13   = @dLottable13,
         @dLottable14   = @dLottable14,
         @dLottable15   = @dLottable15,
         @cKitDtlLineNumberOutput = @cKitDtlLineNumber OUTPUT

         IF @nErrNo <> 0
         BEGIN
            GOTO Step_6_Fail
         END
      END

      IF @nErrNo <> 0
         GOTO Quit
      
      --Ext Upd
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + @cExtendedUpdateSP +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU, ' +
               ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
               ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
               ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
               ' @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile      INT,           ' +
               '@nFunc        INT,           ' +
               '@cLangCode    NVARCHAR( 3),  ' +
               '@nStep        INT,           ' +
               '@nInputKey    INT,           ' +
               '@cFacility    NVARCHAR( 5),  ' +
               '@cStorerKey   NVARCHAR( 15), ' +
               '@cKitKey      NVARCHAR( 10), ' +
               '@cExtKitKey   NVARCHAR( 20), ' +
               '@cLOC         NVARCHAR( 10), ' +
               '@cID          NVARCHAR( 18), ' +
               '@cSKU         NVARCHAR( 20), ' +
               '@cLottable01  NVARCHAR( 18), ' +
               '@cLottable02  NVARCHAR( 18), ' +
               '@cLottable03  NVARCHAR( 18), ' +
               '@dLottable04  DATETIME,      ' +
               '@dLottable05  DATETIME,      ' +
               '@cLottable06  NVARCHAR( 30), ' +
               '@cLottable07  NVARCHAR( 30), ' +
               '@cLottable08  NVARCHAR( 30), ' +
               '@cLottable09  NVARCHAR( 30), ' +
               '@cLottable10  NVARCHAR( 30), ' +
               '@cLottable11  NVARCHAR( 30), ' +
               '@cLottable12  NVARCHAR( 30), ' +
               '@dLottable13  DATETIME,      ' +
               '@dLottable14  DATETIME,      ' +
               '@dLottable15  DATETIME,      ' +
               '@nQTY         INT,           ' +
               '@cPalletType  NVARCHAR( 10), ' +
               '@cDefaultToLOC   NVARCHAR( 10), ' +
               '@cKitDtlLineNumber NVARCHAR( 5), ' +
               '@nErrNo             INT            OUTPUT, ' +
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU,
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               @nQTY, @cPalletType, @cDefaultToLOC, @cKitDtlLineNumber,
               @nErrNo OUTPUT, @cErrMsg OUTPUT
         END

         IF @nErrno<>0
            GOTO Step_6_Fail
      END

      -- EventLog
      EXEC RDT.rdt_STD_EventLog
         @cActionType   = '2',
         @cUserID       = @cUserName,
         @nMobileNo     = @nMobile,
         @nFunctionID   = @nFunc,
         @cFacility     = @cFacility,
         @cStorerKey    = @cStorerKey,
         @cLocation     = @cLOC,
         @cID           = @cID,
         @cSKU          = @cSKU,
         @cUOM          = @cUOM,
         @nQTY          = @nQTY,
         @cRefNo1       = @cKitKey,
         @cRefNo2       = @cKitDtlLineNumber,
         @cLottable01   = @cLottable01,
         @cLottable02   = @cLottable02,
         @cLottable03   = @cLottable03,
         @dLottable04   = @dLottable04,
         @dLottable05   = @dLottable05,
         @cLottable06   = @cLottable06,
         @cLottable07   = @cLottable07,
         @cLottable08   = @cLottable08,
         @cLottable09   = @cLottable09,
         @cLottable10   = @cLottable10,
         @cLottable11   = @cLottable11,
         @cLottable12   = @cLottable12,
         @dLottable13   = @dLottable13,
         @dLottable14   = @dLottable14,
         @dLottable15   = @dLottable15


      -- Enable field
      SET @cFieldAttr08 = '' -- @nPQTY

      SET @nScn = @nScn + 1
      SET @nStep = @nStep + 1
   END

   IF @nInputKey = 0 -- Esc or No
   BEGIN
      -- Dynamic lottable
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
         @cKitKey,
         @nFunc

      IF @nErrNo <> 0
         GOTO Quit      

      IF @nMorePage = 1 -- Yes
      BEGIN
         -- Go to dynamic lottable screen
         SET @nScn = 3990
         SET @nStep = @nStep - 1
      END
      ELSE
      BEGIN
         -- Enable field
         SET @cFieldAttr02 = '' -- Dynamic lottable 1..5
         SET @cFieldAttr04 = '' --
         SET @cFieldAttr06 = '' --
         SET @cFieldAttr08 = '' --
         SET @cFieldAttr10 = '' --

         -- Prepare prev screen var
         SET @cOutField01 = @cID
         SET @cOutField02 = @cPalletType
         SET @cMax = '' -- SKU
         SET @cOutField03 ='' --rdt.rdtFormatString( @cSKUDesc, 1, 20)
         SET @cOutField04 ='' --rdt.rdtFormatString( @cSKUDesc, 21, 20)

         -- Go back to SKU screen
         SET @nScn = @nScn - 2
         SET @nStep = @nStep - 2
      END
      GOTO Quit
   END

   -- Extended info
   IF @cExtendedInfoSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedInfoSP AND type = 'P')
      BEGIN
         SET @cExtendedInfo = ''
         SET @cSQL = 'EXEC rdt.' + @cExtendedInfoSP +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU, ' +
            ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
            ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
            ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
            ' @nQTY, @cPalletType, @cDefaultToLOC,' +
            ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
         SET @cSQLParam =
            '@nMobile       INT,           ' +
            '@nFunc         INT,           ' +
            '@cLangCode     NVARCHAR( 3),  ' +
            '@nStep         INT,           ' +
            '@nAfterStep    INT,           ' +
            '@nInputKey     INT,           ' +
            '@cFacility     NVARCHAR( 5),  ' +
            '@cStorerKey    NVARCHAR( 15), ' +
            '@cKitKey       NVARCHAR( 10), ' +
            '@cExtKitKey    NVARCHAR( 20), ' +
            '@cLOC          NVARCHAR( 10), ' +
            '@cID           NVARCHAR( 18), ' +
            '@cSKU          NVARCHAR( 20), ' +
            '@cLottable01   NVARCHAR( 18), ' +
            '@cLottable02   NVARCHAR( 18), ' +
            '@cLottable03   NVARCHAR( 18), ' +
            '@dLottable04   DATETIME,      ' +
            '@dLottable05   DATETIME,      ' +
            '@cLottable06   NVARCHAR( 30), ' +
            '@cLottable07   NVARCHAR( 30), ' +
            '@cLottable08   NVARCHAR( 30), ' +
            '@cLottable09   NVARCHAR( 30), ' +
            '@cLottable10   NVARCHAR( 30), ' +
            '@cLottable11   NVARCHAR( 30), ' +
            '@cLottable12   NVARCHAR( 30), ' +
            '@dLottable13   DATETIME,      ' +
            '@dLottable14   DATETIME,      ' +
            '@dLottable15   DATETIME,      ' +
            '@nQTY          INT,           ' +
            '@cPalletType   NVARCHAR( 10), ' +
            '@cDefaultToLOC NVARCHAR( 10), ' +
            '@cExtendedInfo NVARCHAR(20)  OUTPUT, ' +
            '@nErrNo        INT           OUTPUT, ' +
            '@cErrMsg       NVARCHAR( 20) OUTPUT'

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, 4, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU,
            @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
            @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
            @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
            @nQTY, @cPalletType, @cDefaultToLOC,
            @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

         IF @nErrNo <> 0
            GOTO Step_6_Fail

         SET @cOutField15 = @cExtendedInfo
      END
   END

   GOTO Quit

   Step_6_Fail:

END
GOTO Quit


/********************************************************************************
Step 7. scn = 6576. Message screen
   Successful build
   Press ENTER or ESC
   to continue
********************************************************************************/
Step_7:
BEGIN
   SET @cNewPalletPerSKU = rdt.RDTGetConfig( @nFunc, 'NewPalletPerSKU', @cStorerKey)
   IF @cNewPalletPerSKU = '0'
      SET @cNewPalletPerSKU = ''

   IF @cNewPalletPerSKU = '1'
   BEGIN
      -- AutoGenID
      SET @cID = ''
      IF @cAutoGenID <> ''
      BEGIN
         EXEC rdt.rdt_AutoGenID @nMobile, @nFunc, @nStep, @cLangCode
         ,@cAutoGenID
         ,@tExtData
         ,@cAutoID  OUTPUT
         ,@nErrNo   OUTPUT
         ,@cErrMsg  OUTPUT
         IF @nErrNo <> 0
            GOTO Step_2_Fail

         SET @cID = @cAutoID
      END

      -- Prep next screen var
      SET @cOutField01 = @cLOC
      SET @cOutField02 = @cID
      IF @cCapturePalletType = '1'
      BEGIN
         SET @cOutField03 = 'PALLET TYPE:'
         SET @cOutField04 = @cDropListSP
      END
      ELSE
      BEGIN
         SET @cOutField03 = ''
         SET @cFieldAttr04 = 'O'
         SET @cInField04 = ''
         SET @cOutField04 = ''
      END

      -- Go to ID screen
      SET @nScn = @nScn - 4
      SET @nStep = @nStep - 4
   END
   ELSE
   BEGIN
      -- Prep next screen var
      SET @cOutField01 = @cID
      SET @cOutField02 = @cPalletType
      SET @cMax = '' -- SKU
      SET @cOutField03 = ''  -- SKU desc 1
      SET @cOutField04 = '' -- SKU desc 2

      -- Go to SKU screen
      SET @nScn = @nScn - 3
      SET @nStep = @nStep - 3
   END

   Step_7_Quit:
   -- Extended info
   -- Extended info
   IF @cExtendedInfoSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedInfoSP AND type = 'P')
      BEGIN
         SET @cExtendedInfo = ''
         SET @cSQL = 'EXEC rdt.' + @cExtendedInfoSP +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU, ' +
            ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
            ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
            ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
            ' @nQTY, @cPalletType, @cDefaultToLOC,' +
            ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
         SET @cSQLParam =
            '@nMobile       INT,           ' +
            '@nFunc         INT,           ' +
            '@cLangCode     NVARCHAR( 3),  ' +
            '@nStep         INT,           ' +
            '@nAfterStep    INT,           ' +
            '@nInputKey     INT,           ' +
            '@cFacility     NVARCHAR( 5),  ' +
            '@cStorerKey    NVARCHAR( 15), ' +
            '@cKitKey       NVARCHAR( 10), ' +
            '@cExtKitKey    NVARCHAR( 20), ' +
            '@cLOC          NVARCHAR( 10), ' +
            '@cID           NVARCHAR( 18), ' +
            '@cSKU          NVARCHAR( 20), ' +
            '@cLottable01   NVARCHAR( 18), ' +
            '@cLottable02   NVARCHAR( 18), ' +
            '@cLottable03   NVARCHAR( 18), ' +
            '@dLottable04   DATETIME,      ' +
            '@dLottable05   DATETIME,      ' +
            '@cLottable06   NVARCHAR( 30), ' +
            '@cLottable07   NVARCHAR( 30), ' +
            '@cLottable08   NVARCHAR( 30), ' +
            '@cLottable09   NVARCHAR( 30), ' +
            '@cLottable10   NVARCHAR( 30), ' +
            '@cLottable11   NVARCHAR( 30), ' +
            '@cLottable12   NVARCHAR( 30), ' +
            '@dLottable13   DATETIME,      ' +
            '@dLottable14   DATETIME,      ' +
            '@dLottable15   DATETIME,      ' +
            '@nQTY          INT,           ' +
            '@cPalletType   NVARCHAR( 10), ' +
            '@cDefaultToLOC NVARCHAR( 10), ' +
            '@cExtendedInfo NVARCHAR(20)  OUTPUT, ' +
            '@nErrNo        INT           OUTPUT, ' +
            '@cErrMsg       NVARCHAR( 20) OUTPUT'

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, 4, @nStep, @nInputKey, @cFacility, @cStorerKey, @cKitKey, @cExtKitKey, @cLOC, @cID, @cSKU,
            @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
            @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
            @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
            @nQTY, @cPalletType, @cDefaultToLOC,
            @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

         IF @nErrNo <> 0
            GOTO Step_7_Fail

         SET @cOutField15 = @cExtendedInfo
      END
   END

   -- Reset data
   SELECT @cSKU = '', @nQTY = 0,
      @cLottable01 = '', @cLottable02 = '', @cLottable03 = '',    @dLottable04 = NULL, @dLottable05 = NULL,
      @cLottable06 = '', @cLottable07 = '', @cLottable08 = '',    @cLottable09 = '',   @cLottable10 = '',
      @cLottable11 = '', @cLottable12 = '', @dLottable13 = NULL,  @dLottable14 = NULL, @dLottable15 = NULL
   GOTO Quit
   
   Step_7_Fail:
      GOTO Quit

END
GOTO Quit


/********************************************************************************
Quit. Update back to I/O table, ready to be pick up by JBOSS
********************************************************************************/
Quit:
BEGIN
   UPDATE RDT.RDTMOBREC WITH (ROWLOCK) SET
      EditDate = GETDATE(),
      ErrMsg = @cErrMsg,
      Func   = @nFunc,
      Step   = @nStep,
      Scn    = @nScn,

      Facility     = @cFacility,
      Printer      = @cPrinter,
      -- UserName     = @cUserName,

      V_StorerKey  = @cStorerKey,
      V_UOM        = @cPUOM,
      V_Loc        = @cLOC,
      V_ID         = @cID,
      V_SKU        = @cSKU,
      V_SKUDescr   = @cSKUDesc,
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
      V_Max        = @cMax,

      V_String1    = @cKitKey,
      V_String2    = @cExtKitKey,
      V_String3    = @cLottableCode,
      V_String4    = @cPalletType,
      V_String5    = @cKitConfirmStatus,
      --V_String6    = @cFinalLOC,
      V_String7    = @cKitDtlLineNumber,
      --V_String8    = @cPalletRecv,
      --V_String9    = @cFlowThruScreen,
      V_String10   = @cMUOM_Desc,
      V_String11   = @cPUOM_Desc,
      V_String12   = @cUserDefine01,

      V_PUOM_Div   = @nPUOM_Div ,
      V_PQTY       = @nPQTY,
      V_MQTY       = @nMQTY,
      V_QTY        = @nQTY,
      V_FromScn    = @nFromScn,
      --V_Integer1   = @nPABookingKey,

      V_String20   = @cDispStyleColorSize,
      V_String21   = @cCheckIDCrsKit,
      V_String22   = @cDefaultToLOC,
      V_String23   = @cCheckIDInKit,
      V_String24   = @cAutoGenID,
      V_String25   = @cDropListSP,
      V_String26   = @cDecodeSP,
      V_String27   = @cCapturePalletType,
      V_String28   = @cVerifySKU,
      --V_String29   = @cPalletRecvSP,
      V_String30   = @cExtendedValidateSP,
      V_String31   = @cExtendedUpdateSP,
      V_String32   = @cConfirmSP,
      V_String33   = @cExtendedInfoSP,
      V_String34   = @cExtendedInfo,
      --V_String35   = @cPutawaySP,
      --V_String36   = @cPutaway,
      V_String37   = @cPalletLabel,
      V_String38   = @cCheckIDInUse,
      V_String39   = @cMultiSKUBarcode,
      V_String40   = @cLOCLookupSP,      
      --V_String41   = @cDocType,     --(yeekung02)
      --V_String42   = @cSerialNoCapture,
      V_String43   = @cScanBarcode,   --(cc01)
      --V_String44   = @cClosePallet, --(yeekung06)
      --V_String45   = @cExtScnSP,
      V_String46   = @cDecimalQty,
      --V_String47   = @cBacktoScreen1,  --(Tianlei)

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

GRANT EXEC ON RDT.rdtfnc_BuildPalletToKit TO NSQL
GO
