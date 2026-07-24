
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdtfnc_ScanToTruck_ByCBOL                          */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Scan LabelNo/DropID to truck at CBOL level (Daimler)        */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2026-07-16 1.0  YNE018   FCR-14913 Created                          */
/************************************************************************/
CREATE OR ALTER PROC [RDT].[rdtfnc_ScanToTruck_ByCBOL] (
   @nMobile    INT,
   @nErrNo     INT  OUTPUT,
   @cErrMsg    NVARCHAR(1024) OUTPUT
) AS

SET NOCOUNT ON
SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
SET CONCAT_NULL_YIELDS_NULL OFF

-- Misc variable
DECLARE
   @nTotalCarton     INT,
   @nScanCarton      INT,
   @cSQL             NVARCHAR(MAX),
   @cSQLParam        NVARCHAR(MAX)

-- RDT.RDTMobRec variable
DECLARE
   @nFunc       INT,
   @nScn        INT,
   @nStep       INT,
   @cLangCode   NVARCHAR( 3),
   @nInputKey   INT,
   @nMenu       INT,

   @cStorerKey    NVARCHAR(15),
   @cFacility     NVARCHAR(5),
   @cUserName     NVARCHAR(18),
   @cPaperPrinter NVARCHAR(10),
   @cLabelPrinter NVARCHAR(10),
   @cOption       NVARCHAR( 2),

   @cCBOLKey               NVARCHAR( 10),
   @cMBOLKey               NVARCHAR( 10),
   @cLoadKey               NVARCHAR( 10),
   @cOrderKey              NVARCHAR( 10),
   @cLabelNo               NVARCHAR( 20),
   @cPickSlipNo            NVARCHAR( 10),
   @nCartonNo              INT,
   @cMobBarcode            NVARCHAR( MAX),

   @cCheckPackDetailDropID  NVARCHAR(1),
   @cCheckPickDetailDropID  NVARCHAR(1),
   @cExtendedUpdateSP       NVARCHAR(20),
   @cExtendedValidateSP     NVARCHAR(20),
   @cBypassPackConfirmCheck NVARCHAR(1),
   @cCapturePackInfoSP      NVARCHAR(20),
   @cPackInfo               NVARCHAR(3),
   @cWeight                 NVARCHAR(10),
   @cCube                   NVARCHAR(10),
   @cCartonType             NVARCHAR(10),
   @cByPassCheckIDinCBOL    NVARCHAR(1),
   @cCloseMBOL              NVARCHAR(20),
   @cConfirmStatus          NVARCHAR(20),
   @cDecodeSP               NVARCHAR(20),
   @cExtendedInfo           NVARCHAR(20),
   @cExtendedInfoSP         NVARCHAR(20),
   @cExtScnSP               NVARCHAR(20),

   @tExtScnData             VariableTable,
   @nAction                 INT,

   @cInField01 NVARCHAR( 60),   @cOutField01 NVARCHAR( 60),   @cFieldAttr01 NVARCHAR( 1),   @cLottable01 NVARCHAR( 18),
   @cInField02 NVARCHAR( 60),   @cOutField02 NVARCHAR( 60),   @cFieldAttr02 NVARCHAR( 1),   @cLottable02 NVARCHAR( 18),
   @cInField03 NVARCHAR( 60),   @cOutField03 NVARCHAR( 60),   @cFieldAttr03 NVARCHAR( 1),   @cLottable03 NVARCHAR( 18),
   @cInField04 NVARCHAR( 60),   @cOutField04 NVARCHAR( 60),   @cFieldAttr04 NVARCHAR( 1),   @dLottable04 DATETIME,
   @cInField05 NVARCHAR( 60),   @cOutField05 NVARCHAR( 60),   @cFieldAttr05 NVARCHAR( 1),   @dLottable05 DATETIME,
   @cInField06 NVARCHAR( 60),   @cOutField06 NVARCHAR( 60),   @cFieldAttr06 NVARCHAR( 1),   @cLottable06 NVARCHAR( 30),
   @cInField07 NVARCHAR( 60),   @cOutField07 NVARCHAR( 60),   @cFieldAttr07 NVARCHAR( 1),   @cLottable07 NVARCHAR( 30),
   @cInField08 NVARCHAR( 60),   @cOutField08 NVARCHAR( 60),   @cFieldAttr08 NVARCHAR( 1),   @cLottable08 NVARCHAR( 30),
   @cInField09 NVARCHAR( 60),   @cOutField09 NVARCHAR( 60),   @cFieldAttr09 NVARCHAR( 1),   @cLottable09 NVARCHAR( 30),
   @cInField10 NVARCHAR( 60),   @cOutField10 NVARCHAR( 60),   @cFieldAttr10 NVARCHAR( 1),   @cLottable10 NVARCHAR( 30),
   @cInField11 NVARCHAR( 60),   @cOutField11 NVARCHAR( 60),   @cFieldAttr11 NVARCHAR( 1),   @cLottable11 NVARCHAR( 30),
   @cInField12 NVARCHAR( 60),   @cOutField12 NVARCHAR( 60),   @cFieldAttr12 NVARCHAR( 1),   @cLottable12 NVARCHAR( 30),
   @cInField13 NVARCHAR( 60),   @cOutField13 NVARCHAR( 60),   @cFieldAttr13 NVARCHAR( 1),   @dLottable13 DATETIME,
   @cInField14 NVARCHAR( 60),   @cOutField14 NVARCHAR( 60),   @cFieldAttr14 NVARCHAR( 1),   @dLottable14 DATETIME,
   @cInField15 NVARCHAR( 60),   @cOutField15 NVARCHAR( 60),   @cFieldAttr15 NVARCHAR( 1),   @dLottable15 DATETIME,

   @cUDF01  NVARCHAR( 250), @cUDF02 NVARCHAR( 250), @cUDF03 NVARCHAR( 250),
   @cUDF04  NVARCHAR( 250), @cUDF05 NVARCHAR( 250), @cUDF06 NVARCHAR( 250),
   @cUDF07  NVARCHAR( 250), @cUDF08 NVARCHAR( 250), @cUDF09 NVARCHAR( 250),
   @cUDF10  NVARCHAR( 250), @cUDF11 NVARCHAR( 250), @cUDF12 NVARCHAR( 250),
   @cUDF13  NVARCHAR( 250), @cUDF14 NVARCHAR( 250), @cUDF15 NVARCHAR( 250),
   @cUDF16  NVARCHAR( 250), @cUDF17 NVARCHAR( 250), @cUDF18 NVARCHAR( 250),
   @cUDF19  NVARCHAR( 250), @cUDF20 NVARCHAR( 250), @cUDF21 NVARCHAR( 250),
   @cUDF22  NVARCHAR( 250), @cUDF23 NVARCHAR( 250), @cUDF24 NVARCHAR( 250),
   @cUDF25  NVARCHAR( 250), @cUDF26 NVARCHAR( 250), @cUDF27 NVARCHAR( 250),
   @cUDF28  NVARCHAR( 250), @cUDF29 NVARCHAR( 250), @cUDF30 NVARCHAR( 250)

-- Load RDT.RDTMobRec
SELECT
   @nFunc         = Func,
   @nScn          = Scn,
   @nStep         = Step,
   @nInputKey     = InputKey,
   @nMenu         = Menu,
   @cLangCode     = Lang_code,

   @cStorerKey    = StorerKey,
   @cFacility     = Facility,
   @cUserName     = UserName,
   @cPaperPrinter = Printer_Paper,
   @cLabelPrinter = Printer,

   @cLabelNo      = V_CaseID,
   @cLoadKey      = V_LoadKey,
   @cOrderKey     = V_OrderKey,
   @cPickSlipNo   = V_PickSlipNo,
   @nCartonNo     = V_Cartonno,
   @cMobBarcode   = V_Barcode,

   @cCBOLKey               = V_String1,
   @cMBOLKey               = V_String2,
   @cCheckPackDetailDropID = V_String3,
   @cCheckPickDetailDropID = V_String4,
   @cExtendedUpdateSP      = V_String5,
   @cExtendedValidateSP    = V_String6,
   @cBypassPackConfirmCheck = V_String7,
   @cCapturePackInfoSP     = V_String8,
   @cPackInfo              = V_String9,
   @cWeight                = V_String10,
   @cCube                  = V_String11,
   @cCartonType            = V_String12,
   @cByPassCheckIDinCBOL   = V_String13,
   @cCloseMBOL             = V_String14,
   @cConfirmStatus         = V_String15,
   @cExtendedInfo          = V_String22,
   @cExtendedInfoSP        = V_String23,
   @cDecodeSP              = V_String24,
   @cExtScnSP              = V_String28,

   @cInField01 = I_Field01,   @cOutField01 = O_Field01,   @cFieldAttr01 = FieldAttr01,
   @cInField02 = I_Field02,   @cOutField02 = O_Field02,   @cFieldAttr02 = FieldAttr02,
   @cInField03 = I_Field03,   @cOutField03 = O_Field03,   @cFieldAttr03 = FieldAttr03,
   @cInField04 = I_Field04,   @cOutField04 = O_Field04,   @cFieldAttr04 = FieldAttr04,
   @cInField05 = I_Field05,   @cOutField05 = O_Field05,   @cFieldAttr05 = FieldAttr05,
   @cInField06 = I_Field06,   @cOutField06 = O_Field06,   @cFieldAttr06 = FieldAttr06,
   @cInField07 = I_Field07,   @cOutField07 = O_Field07,   @cFieldAttr07 = FieldAttr07,
   @cInField08 = I_Field08,   @cOutField08 = O_Field08,   @cFieldAttr08 = FieldAttr08,
   @cInField09 = I_Field09,   @cOutField09 = O_Field09,   @cFieldAttr09 = FieldAttr09,
   @cInField10 = I_Field10,   @cOutField10 = O_Field10,   @cFieldAttr10 = FieldAttr10,
   @cInField11 = I_Field11,   @cOutField11 = O_Field11,   @cFieldAttr11 = FieldAttr11,
   @cInField12 = I_Field12,   @cOutField12 = O_Field12,   @cFieldAttr12 = FieldAttr12,
   @cInField13 = I_Field13,   @cOutField13 = O_Field13,   @cFieldAttr13 = FieldAttr13,
   @cInField14 = I_Field14,   @cOutField14 = O_Field14,   @cFieldAttr14 = FieldAttr14,
   @cInField15 = I_Field15,   @cOutField15 = O_Field15,   @cFieldAttr15 = FieldAttr15

FROM rdt.rdtMobRec WITH (NOLOCK)
WHERE Mobile = @nMobile

-- Redirect to respective screen
IF @nFunc = 928
BEGIN
   IF @nStep = 0  GOTO Step_0   -- Menu. Func = 928
   IF @nStep = 1  GOTO Step_1   -- Scn = 6940. CBOLKey
   IF @nStep = 2  GOTO Step_2   -- Scn = 6941. LabelNo/DropID
   IF @nStep = 3  GOTO Step_3   -- Scn = 6942. Weight, Cube, CartonType
   IF @nStep = 4  GOTO Step_4   -- Scn = 6943. Close MBOLs
   IF @nStep = 5  GOTO Step_5   -- Scn = 6944. Not all scanned
   IF @nStep = 99 GOTO Step_99  -- ExtScn
END
RETURN


/********************************************************************************
Step 0. Called from menu
********************************************************************************/
Step_0:
BEGIN
   -- Set the entry point
   SET @nScn  = 6940
   SET @nStep = 1

   -- Get storer config
   SET @cCheckPackDetailDropID  = rdt.RDTGetConfig( @nFunc, 'CheckPackDetailDropID',  @cStorerKey)
   SET @cCheckPickDetailDropID  = rdt.RDTGetConfig( @nFunc, 'CheckPickDetailDropID',  @cStorerKey)
   SET @cBypassPackConfirmCheck = rdt.RDTGetConfig( @nFunc, 'BypassPackConfirmCheck', @cStorerKey)
   SET @cCloseMBOL              = rdt.RDTGetConfig( @nFunc, 'CloseMBOL',              @cStorerKey)
   SET @cConfirmStatus          = rdt.RDTGetConfig( @nFunc, 'ConfirmStatus',          @cStorerKey)

   SET @cByPassCheckIDinCBOL = rdt.RDTGetConfig( @nFunc, 'ByPassCheckIDinCBOL', @cStorerKey)
   IF @cByPassCheckIDinCBOL = '0'
      SET @cByPassCheckIDinCBOL = ''

   SET @cCapturePackInfoSP = rdt.RDTGetConfig( @nFunc, 'CapturePackInfoSP', @cStorerKey)
   IF @cCapturePackInfoSP = '0'
      SET @cCapturePackInfoSP = ''

   SET @cDecodeSP = rdt.RDTGetConfig( @nFunc, 'DecodeSP', @cStorerKey)
   IF @cDecodeSP = '0'
      SET @cDecodeSP = ''

   SET @cExtendedInfoSP = rdt.RDTGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerKey)
   IF @cExtendedInfoSP = '0'
      SET @cExtendedInfoSP = ''

   SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)
   IF @cExtendedValidateSP = '0'
      SET @cExtendedValidateSP = ''

   SET @cExtendedUpdateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)
   IF @cExtendedUpdateSP = '0'
      SET @cExtendedUpdateSP = ''

   SET @cExtScnSP = rdt.RDTGetConfig( @nFunc, 'ExtScnSP', @cStorerKey)
   IF @cExtScnSP = '0'
      SET @cExtScnSP = ''

   -- Logging
   EXEC RDT.rdt_STD_EventLog
      @cActionType = '1',
      @cUserID     = @cUserName,
      @nMobileNo   = @nMobile,
      @nFunctionID = @nFunc,
      @cFacility   = @cFacility,
      @cStorerKey  = @cStorerkey

   -- Prep next screen var
   SET @cOutField01 = '' -- CBOLKey input
END
GOTO Quit


/********************************************************************************
Step 1. Screen = 6940
   CBOLKey  (Field01, input)
********************************************************************************/
Step_1:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cCBOLKey = @cInField01

      -- Validate not empty
      IF @cCBOLKey = ''
      BEGIN
         SET @nErrNo = 274851
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Enter CBOL
         GOTO Step_1_Fail
      END

      -- Check CBOL shipped
      IF EXISTS( SELECT 1 FROM dbo.CBOL WITH (NOLOCK) WHERE CBOLKey = @cCBOLKey AND Status = '9')
      BEGIN
         SET @nErrNo = 274852
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- CBOL Shipped
         GOTO Step_1_Fail
      END

      -- Check MBOLs exist for CBOL
      IF NOT EXISTS( SELECT 1 FROM dbo.MBOL WITH (NOLOCK) WHERE CBOLKey = @cCBOLKey)
      BEGIN
         SET @nErrNo = 274853
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No MBOLs for CBOL
         GOTO Step_1_Fail
      END

      -- Check no MBOL already shipped
      IF EXISTS( SELECT 1 FROM dbo.MBOL WITH (NOLOCK) WHERE CBOLKey = @cCBOLKey AND Status = '9')
      BEGIN
         SET @nErrNo = 274854
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- MBOLs Shipped
         GOTO Step_1_Fail
      END

      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo, ' +
               ' @cPackInfo, @cWeight, @cCube, @cCartonType, @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile     INT,           ' +
               '@nFunc       INT,           ' +
               '@cLangCode   NVARCHAR( 3),  ' +
               '@nStep       INT,           ' +
               '@nInputKey   INT,           ' +
               '@cStorerKey  NVARCHAR( 15), ' +
               '@cCBOLKey    NVARCHAR( 10), ' +
               '@cMBOLKey    NVARCHAR( 10), ' +
               '@cLoadKey    NVARCHAR( 10), ' +
               '@cOrderKey   NVARCHAR( 10), ' +
               '@cLabelNo    NVARCHAR( 20), ' +
               '@cPackInfo   NVARCHAR( 3),  ' +
               '@cWeight     NVARCHAR( 10), ' +
               '@cCube       NVARCHAR( 10), ' +
               '@cCartonType NVARCHAR( 10), ' +
               '@nErrNo      INT           OUTPUT, ' +
               '@cErrMsg     NVARCHAR( 20) OUTPUT  '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo,
               @cPackInfo, @cWeight, @cCube, @cCartonType, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Quit
         END
      END

      -- Get stats
      SELECT @nScanCarton = COUNT(URNNo)
      FROM RDT.RDTSCANTOTRUCK WITH (NOLOCK)
      WHERE RefNo = @cCBOLKey

      IF @cCheckPickDetailDropID = '1'
         SELECT @nTotalCarton = COUNT(DISTINCT PD.DropID)
         FROM dbo.MBOLDETAIL MD WITH (NOLOCK)
         JOIN dbo.PICKDETAIL PD WITH (NOLOCK) ON MD.OrderKey = PD.OrderKey
         JOIN dbo.MBOL M WITH (NOLOCK) ON MD.MBOLKey = M.MBOLKey
         WHERE M.CBOLKey = @cCBOLKey
      ELSE IF @cCheckPackDetailDropID = '1'
         SELECT @nTotalCarton = COUNT(DISTINCT PD.DropID)
         FROM dbo.MBOLDETAIL MD WITH (NOLOCK)
         JOIN dbo.PACKHEADER PH WITH (NOLOCK) ON MD.OrderKey = PH.OrderKey
         JOIN dbo.PACKDETAIL PD WITH (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
         JOIN dbo.MBOL M WITH (NOLOCK) ON MD.MBOLKey = M.MBOLKey
         WHERE M.CBOLKey = @cCBOLKey
      ELSE
         SELECT @nTotalCarton = COUNT(DISTINCT PD.LabelNo)
         FROM dbo.MBOLDETAIL MD WITH (NOLOCK)
         JOIN dbo.PACKHEADER PH WITH (NOLOCK) ON MD.OrderKey = PH.OrderKey
         JOIN dbo.PACKDETAIL PD WITH (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
         JOIN dbo.MBOL M WITH (NOLOCK) ON MD.MBOLKey = M.MBOLKey
         WHERE M.CBOLKey = @cCBOLKey

      -- Prep next screen var
      SET @cOutField01 = @cCBOLKey  -- CBOL display
      SET @cOutField02 = ''          -- LabelNo/DropID input
      SET @cMobBarcode = ''
      SET @cOutField03 = ''          -- Last scanned
      SET @cOutField04 = CAST( @nScanCarton  AS NVARCHAR( 10))
      SET @cOutField05 = CAST( @nTotalCarton AS NVARCHAR( 10))

      -- Extended info
      IF @cExtendedInfoSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedInfoSP AND type = 'P')
         BEGIN
            SET @cExtendedInfo = ''
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo, ' +
               ' @cPackInfo, @cWeight, @cCube, @cCartonType, ' +
               ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile       INT,           ' +
               '@nFunc         INT,           ' +
               '@cLangCode     NVARCHAR( 3),  ' +
               '@nStep         INT,           ' +
               '@nAfterStep    INT,           ' +
               '@nInputKey     INT,           ' +
               '@cFacility     NVARCHAR( 5),  ' +
               '@cStorerKey    NVARCHAR( 15), ' +
               '@cCBOLKey      NVARCHAR( 10), ' +
               '@cMBOLKey      NVARCHAR( 10), ' +
               '@cLoadKey      NVARCHAR( 10), ' +
               '@cOrderKey     NVARCHAR( 10), ' +
               '@cLabelNo      NVARCHAR( 20), ' +
               '@cPackInfo     NVARCHAR( 3),  ' +
               '@cWeight       NVARCHAR( 10), ' +
               '@cCube         NVARCHAR( 10), ' +
               '@cCartonType   NVARCHAR( 10), ' +
               '@cExtendedInfo NVARCHAR( 20) OUTPUT, ' +
               '@nErrNo        INT           OUTPUT, ' +
               '@cErrMsg       NVARCHAR( 20) OUTPUT  '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, 1, @nStep, @nInputKey, @cFacility, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo,
               @cPackInfo, @cWeight, @cCube, @cCartonType,
               @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

            SET @cOutField15 = @cExtendedInfo
         END
      END

      -- Go to LabelNo screen
      SET @nScn  = @nScn + 1
      SET @nStep = @nStep + 1

      IF @cExtScnSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtScnSP AND type = 'P')
            GOTO Step_99
      END

      GOTO Quit

      Step_1_Fail:
      BEGIN
         SET @cCBOLKey    = ''
         SET @cOutField01 = ''
      END
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Logging
      EXEC RDT.rdt_STD_EventLog
         @cActionType = '9',
         @cUserID     = @cUserName,
         @nMobileNo   = @nMobile,
         @nFunctionID = @nFunc,
         @cFacility   = @cFacility,
         @cStorerKey  = @cStorerkey

      -- Back to menu
      SET @nFunc = @nMenu
      SET @nScn  = @nMenu
      SET @nStep = 0
      SET @cOutField01 = ''
   END
END
GOTO Quit


/********************************************************************************
Step 2. Screen = 6941
   CBOLKey         (Field01, display)
   LabelNo/DropID  (Field02, input)
   Last scanned    (Field03, display)
   SCANNED count   (Field04, display)
   TOTAL count     (Field05, display)
   ExtendedInfo    (Field15, display)
********************************************************************************/
Step_2:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      DECLARE @cLabelNoBarcode NVARCHAR(MAX)

      SET @cLabelNo        = @cInField02
      SET @cLabelNoBarcode = @cInField02

      -- Validate not empty
      IF @cLabelNo = ''
      BEGIN
         SET @nErrNo = 274855
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Need LabelNo
         GOTO Step_2_Fail
      END

      -- Decode
      IF @cDecodeSP = '1'
      BEGIN
         EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cLabelNoBarcode,
            @cID     = @cLabelNo    OUTPUT,
            @nErrNo  = @nErrNo      OUTPUT,
            @cErrMsg = @cErrMsg     OUTPUT,
            @cType   = 'ID'

         IF @nErrNo <> 0
            GOTO Step_2_Fail
      END
      ELSE IF @cDecodeSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cDecodeSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cDecodeSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNoBarcode OUTPUT, @cFieldName, ' +
               ' @cLabelNo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               ' @nMobile         INT,             ' +
               ' @nFunc           INT,             ' +
               ' @cLangCode       NVARCHAR( 3),    ' +
               ' @nStep           INT,             ' +
               ' @nInputKey       INT,             ' +
               ' @cStorerKey      NVARCHAR( 15),   ' +
               ' @cCBOLKey        NVARCHAR( 10),   ' +
               ' @cMBOLKey        NVARCHAR( 10),   ' +
               ' @cLoadKey        NVARCHAR( 10),   ' +
               ' @cOrderKey       NVARCHAR( 10),   ' +
               ' @cLabelNoBarcode NVARCHAR( MAX) OUTPUT, ' +
               ' @cFieldName      NVARCHAR( 10),   ' +
               ' @cLabelNo        NVARCHAR( 20)  OUTPUT, ' +
               ' @nErrNo          INT            OUTPUT, ' +
               ' @cErrMsg         NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNoBarcode OUTPUT, 'ID',
               @cLabelNo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_2_Fail
         END
      END

      -- Check double scan
      IF EXISTS( SELECT 1 FROM RDT.RDTSCANTOTRUCK WITH (NOLOCK) WHERE URNNo = @cLabelNo AND RefNo = @cCBOLKey)
      BEGIN
         SET @nErrNo = 274856
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Label already scanned
         GOTO Step_2_Fail
      END

      DECLARE @cPickDetailOrderKey NVARCHAR(10)
      DECLARE @cPackHeaderOrderKey NVARCHAR(10)
      DECLARE @cPackHeaderLoadKey  NVARCHAR(10)
      DECLARE @cStatus             NVARCHAR(10)

      SET @cPickDetailOrderKey = ''
      SET @cPackHeaderOrderKey = ''
      SET @cPackHeaderLoadKey  = ''
      SET @cPickSlipNo = ''
      SET @nCartonNo   = 0
      SET @cStatus     = ''

      -- Validate LabelNo/DropID based on storer config
      IF @cCheckPickDetailDropID = '1'
      BEGIN
         SELECT
            @cStatus             = Status,
            @cPickDetailOrderKey = OrderKey
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
           AND DropID    = @cLabelNo

         IF @cStatus = ''
         BEGIN
            SET @nErrNo = 274857
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- BAD LBL/DrpID
            GOTO Step_2_Fail
         END

         IF @cStatus < '5'
         BEGIN
            SET @nErrNo = 274858
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Picking not confirm
            GOTO Step_2_Fail
         END
      END
      ELSE IF @cCheckPackDetailDropID = '1'
      BEGIN
         SELECT TOP 1
            @cPickSlipNo         = PH.PickSlipNo,
            @cPackHeaderOrderKey = PH.OrderKey,
            @cPackHeaderLoadKey  = PH.LoadKey,
            @nCartonNo           = PD.CartonNo
         FROM dbo.PackHeader PH WITH (NOLOCK)
         JOIN dbo.PackDetail PD WITH (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
         WHERE PD.StorerKey = @cStorerKey
           AND PD.DropID    = @cLabelNo
         ORDER BY PH.PickSlipNo DESC

         IF @cPickSlipNo = ''
         BEGIN
            SET @nErrNo = 274859
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- BAD LBL/DrpID
            GOTO Step_2_Fail
         END

         IF @cBypassPackConfirmCheck <> '1'
         BEGIN
            IF EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Status < '5')
            BEGIN
               SET @nErrNo = 274860
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Packing not confirm
               GOTO Step_2_Fail
            END
         END
      END
      ELSE
      BEGIN
         -- Default: PackDetail.LabelNo
         SELECT TOP 1
            @cPickSlipNo         = PH.PickSlipNo,
            @cPackHeaderOrderKey = PH.OrderKey,
            @cPackHeaderLoadKey  = PH.LoadKey,
            @nCartonNo           = PD.CartonNo
         FROM dbo.PackHeader PH WITH (NOLOCK)
         JOIN dbo.PackDetail PD WITH (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
         WHERE PD.StorerKey = @cStorerKey
           AND PD.LabelNo   = @cLabelNo
         ORDER BY PH.PickSlipNo DESC

         IF @cPickSlipNo = ''
         BEGIN
            SET @nErrNo = 274861
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- BAD LBL/DrpID
            GOTO Step_2_Fail
         END

         IF @cBypassPackConfirmCheck <> '1'
         BEGIN
            IF EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Status < '5')
            BEGIN
               SET @nErrNo = 274860
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Packing not confirm
               GOTO Step_2_Fail
            END
         END
      END

      -- Resolve OrderKey
      IF @cCheckPickDetailDropID = '1'
         SET @cOrderKey = @cPickDetailOrderKey
      ELSE
         SET @cOrderKey = @cPackHeaderOrderKey

      -- Check ID in CBOL
      IF @cByPassCheckIDinCBOL <> '1'
      BEGIN
         IF @cCheckPickDetailDropID = '1'
         BEGIN
            IF NOT EXISTS(
               SELECT 1
               FROM dbo.MBOLDetail MD WITH (NOLOCK)
               JOIN dbo.MBOL M WITH (NOLOCK) ON MD.MBOLKey = M.MBOLKey
               WHERE MD.OrderKey = @cOrderKey
                 AND M.CBOLKey   = @cCBOLKey)
            BEGIN
               SET @nErrNo = 274862
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ID Not in CBOL
               GOTO Step_2_Fail
            END
         END
         ELSE
         BEGIN
            IF NOT EXISTS(
               SELECT 1
               FROM dbo.MBOLDetail MD WITH (NOLOCK)
               JOIN dbo.MBOL M WITH (NOLOCK) ON MD.MBOLKey = M.MBOLKey
               WHERE MD.OrderKey = @cOrderKey
                 AND M.CBOLKey   = @cCBOLKey)
            BEGIN
               SET @nErrNo = 274862
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ID Not in CBOL
               GOTO Step_2_Fail
            END
         END
      END

      -- Resolve MBOLKey and LoadKey for insert
      SET @cMBOLKey = ''
      IF @cByPassCheckIDinCBOL <> '1'
         SELECT TOP 1 @cMBOLKey = MD.MBOLKey
         FROM dbo.MBOLDetail MD WITH (NOLOCK)
         JOIN dbo.MBOL M WITH (NOLOCK) ON MD.MBOLKey = M.MBOLKey
         WHERE MD.OrderKey = @cOrderKey
           AND M.CBOLKey   = @cCBOLKey
      ELSE
         SELECT TOP 1 @cMBOLKey = MBOLKey
         FROM dbo.MBOLDetail WITH (NOLOCK)
         WHERE OrderKey = @cOrderKey

      IF @cCheckPickDetailDropID = '1'
      BEGIN
         SET @cLoadKey = ''
         SELECT TOP 1 @cLoadKey = LoadKey
         FROM dbo.LoadPlanDetail WITH (NOLOCK)
         WHERE OrderKey = @cOrderKey
      END
      ELSE
         SET @cLoadKey = @cPackHeaderLoadKey

      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo, ' +
               ' @cPackInfo, @cWeight, @cCube, @cCartonType, @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile     INT,           ' +
               '@nFunc       INT,           ' +
               '@cLangCode   NVARCHAR( 3),  ' +
               '@nStep       INT,           ' +
               '@nInputKey   INT,           ' +
               '@cStorerKey  NVARCHAR( 15), ' +
               '@cCBOLKey    NVARCHAR( 10), ' +
               '@cMBOLKey    NVARCHAR( 10), ' +
               '@cLoadKey    NVARCHAR( 10), ' +
               '@cOrderKey   NVARCHAR( 10), ' +
               '@cLabelNo    NVARCHAR( 20), ' +
               '@cPackInfo   NVARCHAR( 3),  ' +
               '@cWeight     NVARCHAR( 10), ' +
               '@cCube       NVARCHAR( 10), ' +
               '@cCartonType NVARCHAR( 10), ' +
               '@nErrNo      INT           OUTPUT, ' +
               '@cErrMsg     NVARCHAR( 20) OUTPUT  '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo,
               @cPackInfo, @cWeight, @cCube, @cCartonType, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Quit
         END
      END

      -- Insert RDTSCANTOTRUCK
      BEGIN TRY
         INSERT INTO rdt.rdtScanToTruck
            (MBOLKey, LoadKey, OrderKey, URNNo, Status, RefNo, AddWho, AddDate, EditWho, EditDate)
         VALUES
            (@cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo, '9', @cCBOLKey, @cUserName, GETDATE(), @cUserName, GETDATE())
      END TRY
      BEGIN CATCH
         SET @nErrNo = 274863
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- INS Truck Fail
         GOTO Step_2_Fail
      END CATCH

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo, ' +
               ' @cPackInfo, @cWeight, @cCube, @cCartonType, @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile     INT,           ' +
               '@nFunc       INT,           ' +
               '@cLangCode   NVARCHAR( 3),  ' +
               '@nStep       INT,           ' +
               '@nInputKey   INT,           ' +
               '@cStorerKey  NVARCHAR( 15), ' +
               '@cCBOLKey    NVARCHAR( 10), ' +
               '@cMBOLKey    NVARCHAR( 10), ' +
               '@cLoadKey    NVARCHAR( 10), ' +
               '@cOrderKey   NVARCHAR( 10), ' +
               '@cLabelNo    NVARCHAR( 20), ' +
               '@cPackInfo   NVARCHAR( 3),  ' +
               '@cWeight     NVARCHAR( 10), ' +
               '@cCube       NVARCHAR( 10), ' +
               '@cCartonType NVARCHAR( 10), ' +
               '@nErrNo      INT           OUTPUT, ' +
               '@cErrMsg     NVARCHAR( 20) OUTPUT  '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo,
               @cPackInfo, @cWeight, @cCube, @cCartonType, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Quit
         END
      END

      -- EventLog
      EXEC RDT.rdt_STD_EventLog
         @cActionType = '4',
         @cUserID     = @cUserName,
         @nMobileNo   = @nMobile,
         @nFunctionID = @nFunc,
         @cFacility   = @cFacility,
         @cStorerKey  = @cStorerkey,
         @cDropID     = @cLabelNo,
         @cLoadKey    = @cLoadKey,
         @cOrderKey   = @cOrderKey,
         @cRefNo1     = @cCBOLKey

      -- Recalc stats
      SELECT @nScanCarton = COUNT(URNNo)
      FROM RDT.RDTSCANTOTRUCK WITH (NOLOCK)
      WHERE RefNo = @cCBOLKey

      IF @cCheckPickDetailDropID = '1'
         SELECT @nTotalCarton = COUNT(DISTINCT PD.DropID)
         FROM dbo.MBOLDETAIL MD WITH (NOLOCK)
         JOIN dbo.PICKDETAIL PD WITH (NOLOCK) ON MD.OrderKey = PD.OrderKey
         JOIN dbo.MBOL M WITH (NOLOCK) ON MD.MBOLKey = M.MBOLKey
         WHERE M.CBOLKey = @cCBOLKey
      ELSE IF @cCheckPackDetailDropID = '1'
         SELECT @nTotalCarton = COUNT(DISTINCT PD.DropID)
         FROM dbo.MBOLDETAIL MD WITH (NOLOCK)
         JOIN dbo.PACKHEADER PH WITH (NOLOCK) ON MD.OrderKey = PH.OrderKey
         JOIN dbo.PACKDETAIL PD WITH (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
         JOIN dbo.MBOL M WITH (NOLOCK) ON MD.MBOLKey = M.MBOLKey
         WHERE M.CBOLKey = @cCBOLKey
      ELSE
         SELECT @nTotalCarton = COUNT(DISTINCT PD.LabelNo)
         FROM dbo.MBOLDETAIL MD WITH (NOLOCK)
         JOIN dbo.PACKHEADER PH WITH (NOLOCK) ON MD.OrderKey = PH.OrderKey
         JOIN dbo.PACKDETAIL PD WITH (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
         JOIN dbo.MBOL M WITH (NOLOCK) ON MD.MBOLKey = M.MBOLKey
         WHERE M.CBOLKey = @cCBOLKey

      -- Capture pack info
      IF @cCapturePackInfoSP <> '' AND @cCheckPickDetailDropID <> '1' AND @cPickSlipNo <> ''
      BEGIN
         SET @cPackInfo   = @cCapturePackInfoSP
         SET @cWeight     = ''
         SET @cCube       = ''
         SET @cCartonType = ''

         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cCapturePackInfoSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cCapturePackInfoSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo, @nErrNo OUTPUT, @cErrMsg OUTPUT, ' +
               ' @cPackInfo OUTPUT, @cWeight OUTPUT, @cCube OUTPUT, @cCartonType OUTPUT'
            SET @cSQLParam =
               '@nMobile     INT,           ' +
               '@nFunc       INT,           ' +
               '@cLangCode   NVARCHAR( 3),  ' +
               '@nStep       INT,           ' +
               '@cStorerKey  NVARCHAR( 15), ' +
               '@cCBOLKey    NVARCHAR( 10), ' +
               '@cMBOLKey    NVARCHAR( 10), ' +
               '@cLoadKey    NVARCHAR( 10), ' +
               '@cOrderKey   NVARCHAR( 10), ' +
               '@cLabelNo    NVARCHAR( 20), ' +
               '@nErrNo      INT           OUTPUT, ' +
               '@cErrMsg     NVARCHAR( 20) OUTPUT, ' +
               '@cPackInfo   NVARCHAR( 3)  OUTPUT, ' +
               '@cWeight     NVARCHAR( 10) OUTPUT, ' +
               '@cCube       NVARCHAR( 10) OUTPUT, ' +
               '@cCartonType NVARCHAR( 10) OUTPUT  '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo, @nErrNo OUTPUT, @cErrMsg OUTPUT,
               @cPackInfo OUTPUT, @cWeight OUTPUT, @cCube OUTPUT, @cCartonType OUTPUT
         END

         IF CHARINDEX( 'W', @cPackInfo) <> 0 OR
            CHARINDEX( 'C', @cPackInfo) <> 0 OR
            CHARINDEX( 'T', @cPackInfo) <> 0
         BEGIN
            SET @cOutField01 = @cCBOLKey   -- CBOL display
            SET @cOutField02 = @cLabelNo   -- LabelNo display
            SET @cOutField03 = @cWeight
            SET @cOutField04 = @cCube
            SET @cOutField05 = @cCartonType

            SET @cFieldAttr03 = CASE WHEN CHARINDEX( 'W', @cPackInfo) = 0 THEN 'O' ELSE '' END
            SET @cFieldAttr04 = CASE WHEN CHARINDEX( 'C', @cPackInfo) = 0 THEN 'O' ELSE '' END
            SET @cFieldAttr05 = CASE WHEN CHARINDEX( 'T', @cPackInfo) = 0 THEN 'O' ELSE '' END

            EXEC rdt.rdtSetFocusField @nMobile, 3 -- Weight

            -- Go to pack info screen
            SET @nScn  = @nScn + 1
            SET @nStep = @nStep + 1
            GOTO Quit
         END
      END

      -- Extended info
      IF @cExtendedInfoSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedInfoSP AND type = 'P')
         BEGIN
            SET @cExtendedInfo = ''
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo, ' +
               ' @cPackInfo, @cWeight, @cCube, @cCartonType, ' +
               ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile       INT,           ' +
               '@nFunc         INT,           ' +
               '@cLangCode     NVARCHAR( 3),  ' +
               '@nStep         INT,           ' +
               '@nAfterStep    INT,           ' +
               '@nInputKey     INT,           ' +
               '@cFacility     NVARCHAR( 5),  ' +
               '@cStorerKey    NVARCHAR( 15), ' +
               '@cCBOLKey      NVARCHAR( 10), ' +
               '@cMBOLKey      NVARCHAR( 10), ' +
               '@cLoadKey      NVARCHAR( 10), ' +
               '@cOrderKey     NVARCHAR( 10), ' +
               '@cLabelNo      NVARCHAR( 20), ' +
               '@cPackInfo     NVARCHAR( 3),  ' +
               '@cWeight       NVARCHAR( 10), ' +
               '@cCube         NVARCHAR( 10), ' +
               '@cCartonType   NVARCHAR( 10), ' +
               '@cExtendedInfo NVARCHAR( 20) OUTPUT, ' +
               '@nErrNo        INT           OUTPUT, ' +
               '@cErrMsg       NVARCHAR( 20) OUTPUT  '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, 2, @nStep, @nInputKey, @cFacility, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo,
               @cPackInfo, @cWeight, @cCube, @cCartonType,
               @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

            SET @cOutField15 = @cExtendedInfo
         END
      END

      -- Navigate when all scanned
      IF @nTotalCarton = @nScanCarton
      BEGIN
         IF @cCloseMBOL = '1'
         BEGIN
            -- All scanned + CloseMBOL active: go to close screen
            SET @cOutField01 = @cCBOLKey
            SET @cOutField02 = ''
            SET @nScn  = @nScn + 2
            SET @nStep = @nStep + 2
            GOTO Quit
         END
         ELSE
         BEGIN
            -- All scanned + CloseMBOL NOT active: back to CBOL screen
            SET @cCBOLKey    = ''
            SET @cOutField01 = ''
            SET @nScn  = @nScn - 1
            SET @nStep = @nStep - 1
            GOTO Quit
         END
      END

      -- SCANNED <> TOTAL: stay on current screen for next scan
      SET @cOutField01 = @cCBOLKey  -- CBOL display
      SET @cOutField02 = ''          -- clear input
      SET @cMobBarcode = ''
      SET @cOutField03 = @cLabelNo  -- last scanned
      SET @cOutField04 = CAST( @nScanCarton  AS NVARCHAR( 10))
      SET @cOutField05 = CAST( @nTotalCarton AS NVARCHAR( 10))
      GOTO Quit

      Step_2_Fail:
      BEGIN
         SET @cLabelNo    = ''
         SET @cOutField02 = ''
         SET @cMobBarcode = ''
      END
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Recalc stats
      SELECT @nScanCarton = COUNT(URNNo)
      FROM RDT.RDTSCANTOTRUCK WITH (NOLOCK)
      WHERE RefNo = @cCBOLKey

      IF @cCheckPickDetailDropID = '1'
         SELECT @nTotalCarton = COUNT(DISTINCT PD.DropID)
         FROM dbo.MBOLDETAIL MD WITH (NOLOCK)
         JOIN dbo.PICKDETAIL PD WITH (NOLOCK) ON MD.OrderKey = PD.OrderKey
         JOIN dbo.MBOL M WITH (NOLOCK) ON MD.MBOLKey = M.MBOLKey
         WHERE M.CBOLKey = @cCBOLKey
      ELSE IF @cCheckPackDetailDropID = '1'
         SELECT @nTotalCarton = COUNT(DISTINCT PD.DropID)
         FROM dbo.MBOLDETAIL MD WITH (NOLOCK)
         JOIN dbo.PACKHEADER PH WITH (NOLOCK) ON MD.OrderKey = PH.OrderKey
         JOIN dbo.PACKDETAIL PD WITH (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
         JOIN dbo.MBOL M WITH (NOLOCK) ON MD.MBOLKey = M.MBOLKey
         WHERE M.CBOLKey = @cCBOLKey
      ELSE
         SELECT @nTotalCarton = COUNT(DISTINCT PD.LabelNo)
         FROM dbo.MBOLDETAIL MD WITH (NOLOCK)
         JOIN dbo.PACKHEADER PH WITH (NOLOCK) ON MD.OrderKey = PH.OrderKey
         JOIN dbo.PACKDETAIL PD WITH (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
         JOIN dbo.MBOL M WITH (NOLOCK) ON MD.MBOLKey = M.MBOLKey
         WHERE M.CBOLKey = @cCBOLKey

      IF @nTotalCarton = @nScanCarton
      BEGIN
         -- All scanned, go back to CBOL screen
         SET @cOutField01 = ''
         SET @nScn  = @nScn - 1
         SET @nStep = @nStep - 1
      END
      ELSE
      BEGIN
         -- Not all scanned: go to message screen (Step_5)
         SET @cOutField01 = @cCBOLKey
         SET @nScn  = @nScn + 3
         SET @nStep = @nStep + 3
      END
   END
END
GOTO Quit


/********************************************************************************
Step 3. Screen = 6942
   CBOLKey        (Field01, display)
   LabelNo        (Field02, display)
   Weight         (Field03, input)
   Cube           (Field04, input)
   CartonType     (Field05, input)
********************************************************************************/
Step_3:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cWeight     = LTRIM( ISNULL( @cInField03, ''))
      SET @cCube       = @cInField04
      SET @cCartonType = @cInField05

      -- Retain key-in value
      SET @cOutField03 = CASE WHEN @cFieldAttr03 = 'O' THEN '' ELSE @cInField03 END
      SET @cOutField04 = CASE WHEN @cFieldAttr04 = 'O' THEN '' ELSE @cInField04 END
      SET @cOutField05 = CASE WHEN @cFieldAttr05 = 'O' THEN '' ELSE @cInField05 END

      -- Validate weight
      IF CHARINDEX( 'W', @cPackInfo) <> 0
      BEGIN
         IF rdt.rdtIsValidQty( @cWeight, 21) = 0 OR LEN( @cWeight) > 6 OR CAST( @cWeight AS FLOAT) NOT BETWEEN 0 AND 99999
         BEGIN
            SET @nErrNo = 274864
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Bad Weight
            EXEC rdt.rdtSetFocusField @nMobile, 3
            GOTO Step_3_Fail
         END
      END

      -- Validate cube
      IF CHARINDEX( 'C', @cPackInfo) <> 0 AND rdt.rdtIsValidQty( @cCube, 21) = 0
      BEGIN
         SET @nErrNo = 274865
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Bad Cube
         EXEC rdt.rdtSetFocusField @nMobile, 4
         GOTO Step_3_Fail
      END

      -- Validate carton type
      IF CHARINDEX( 'T', @cPackInfo) <> 0
      BEGIN
         IF NOT EXISTS(
            SELECT 1
            FROM Cartonization WITH (NOLOCK)
            INNER JOIN Storer WITH (NOLOCK) ON Storer.CartonGroup = Cartonization.CartonizationGroup
            WHERE Storer.StorerKey     = @cStorerKey
              AND Cartonization.CartonType = @cCartonType)
         BEGIN
            SET @nErrNo = 274866
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Bad CartonType
            EXEC rdt.rdtSetFocusField @nMobile, 5
            GOTO Step_3_Fail
         END
      END

      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo, ' +
               ' @cPackInfo, @cWeight, @cCube, @cCartonType, @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile     INT,           ' +
               '@nFunc       INT,           ' +
               '@cLangCode   NVARCHAR( 3),  ' +
               '@nStep       INT,           ' +
               '@nInputKey   INT,           ' +
               '@cStorerKey  NVARCHAR( 15), ' +
               '@cCBOLKey    NVARCHAR( 10), ' +
               '@cMBOLKey    NVARCHAR( 10), ' +
               '@cLoadKey    NVARCHAR( 10), ' +
               '@cOrderKey   NVARCHAR( 10), ' +
               '@cLabelNo    NVARCHAR( 20), ' +
               '@cPackInfo   NVARCHAR( 3),  ' +
               '@cWeight     NVARCHAR( 10), ' +
               '@cCube       NVARCHAR( 10), ' +
               '@cCartonType NVARCHAR( 10), ' +
               '@nErrNo      INT           OUTPUT, ' +
               '@cErrMsg     NVARCHAR( 20) OUTPUT  '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo,
               @cPackInfo, @cWeight, @cCube, @cCartonType, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Quit
         END
      END

      -- Update/insert PackInfo
      IF EXISTS( SELECT 1 FROM PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo)
      BEGIN
         BEGIN TRY
            UPDATE PackInfo SET
               Weight     = CASE WHEN CHARINDEX( 'W', @cPackInfo) = 0 THEN Weight     ELSE @cWeight     END,
               Cube       = CASE WHEN CHARINDEX( 'C', @cPackInfo) = 0 THEN Cube       ELSE @cCube       END,
               CartonType = CASE WHEN CHARINDEX( 'T', @cPackInfo) = 0 THEN CartonType ELSE @cCartonType END
            WHERE PickSlipNo = @cPickSlipNo
              AND CartonNo   = @nCartonNo
         END TRY
         BEGIN CATCH
            SET @nErrNo = 274867
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PackInfo Fail
            GOTO Step_3_Fail
         END CATCH
      END
      ELSE
      BEGIN
         BEGIN TRY
            INSERT INTO PackInfo (PickSlipNo, CartonNo, Weight, Cube, CartonType)
            VALUES (@cPickSlipNo, @nCartonNo, @cWeight, @cCube, @cCartonType)
         END TRY
         BEGIN CATCH
            SET @nErrNo = 274868
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- INS PackInfo Fail
            GOTO Step_3_Fail
         END CATCH
      END

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo, ' +
               ' @cPackInfo, @cWeight, @cCube, @cCartonType, @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile     INT,           ' +
               '@nFunc       INT,           ' +
               '@cLangCode   NVARCHAR( 3),  ' +
               '@nStep       INT,           ' +
               '@nInputKey   INT,           ' +
               '@cStorerKey  NVARCHAR( 15), ' +
               '@cCBOLKey    NVARCHAR( 10), ' +
               '@cMBOLKey    NVARCHAR( 10), ' +
               '@cLoadKey    NVARCHAR( 10), ' +
               '@cOrderKey   NVARCHAR( 10), ' +
               '@cLabelNo    NVARCHAR( 20), ' +
               '@cPackInfo   NVARCHAR( 3),  ' +
               '@cWeight     NVARCHAR( 10), ' +
               '@cCube       NVARCHAR( 10), ' +
               '@cCartonType NVARCHAR( 10), ' +
               '@nErrNo      INT           OUTPUT, ' +
               '@cErrMsg     NVARCHAR( 20) OUTPUT  '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo,
               @cPackInfo, @cWeight, @cCube, @cCartonType, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Quit
         END
      END

      -- EventLog
      EXEC RDT.rdt_STD_EventLog
         @cActionType = '4',
         @cUserID     = @cUserName,
         @nMobileNo   = @nMobile,
         @nFunctionID = @nFunc,
         @cFacility   = @cFacility,
         @cStorerKey  = @cStorerkey,
         @cDropID     = @cLabelNo,
         @cLoadKey    = @cLoadKey,
         @cOrderKey   = @cOrderKey,
         @cRefNo1     = @cCBOLKey

      -- Recalc stats
      SELECT @nScanCarton = COUNT(URNNo)
      FROM RDT.RDTSCANTOTRUCK WITH (NOLOCK)
      WHERE RefNo = @cCBOLKey

      IF @cCheckPickDetailDropID = '1'
         SELECT @nTotalCarton = COUNT(DISTINCT PD.DropID)
         FROM dbo.MBOLDETAIL MD WITH (NOLOCK)
         JOIN dbo.PICKDETAIL PD WITH (NOLOCK) ON MD.OrderKey = PD.OrderKey
         JOIN dbo.MBOL M WITH (NOLOCK) ON MD.MBOLKey = M.MBOLKey
         WHERE M.CBOLKey = @cCBOLKey
      ELSE IF @cCheckPackDetailDropID = '1'
         SELECT @nTotalCarton = COUNT(DISTINCT PD.DropID)
         FROM dbo.MBOLDETAIL MD WITH (NOLOCK)
         JOIN dbo.PACKHEADER PH WITH (NOLOCK) ON MD.OrderKey = PH.OrderKey
         JOIN dbo.PACKDETAIL PD WITH (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
         JOIN dbo.MBOL M WITH (NOLOCK) ON MD.MBOLKey = M.MBOLKey
         WHERE M.CBOLKey = @cCBOLKey
      ELSE
         SELECT @nTotalCarton = COUNT(DISTINCT PD.LabelNo)
         FROM dbo.MBOLDETAIL MD WITH (NOLOCK)
         JOIN dbo.PACKHEADER PH WITH (NOLOCK) ON MD.OrderKey = PH.OrderKey
         JOIN dbo.PACKDETAIL PD WITH (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
         JOIN dbo.MBOL M WITH (NOLOCK) ON MD.MBOLKey = M.MBOLKey
         WHERE M.CBOLKey = @cCBOLKey

      -- Reset field attr
      SET @cFieldAttr03 = ''
      SET @cFieldAttr04 = ''
      SET @cFieldAttr05 = ''

      -- Navigate based on scan vs total
      IF @nTotalCarton = @nScanCarton
      BEGIN
         IF @cCloseMBOL = '1'
         BEGIN
            SET @cOutField01 = @cCBOLKey
            SET @cOutField02 = ''
            SET @nScn  = @nScn + 1
            SET @nStep = @nStep + 1
         END
         ELSE
         BEGIN
            -- All scanned, no CloseMBOL: back to CBOL screen
            SET @cOutField01 = ''
            SET @nScn  = @nScn - 2
            SET @nStep = @nStep - 2
         END
         GOTO Quit
      END

      -- Not all scanned: back to LabelNo screen
      SET @cOutField01 = @cCBOLKey
      SET @cOutField02 = ''
      SET @cMobBarcode = ''
      SET @cOutField03 = @cLabelNo
      SET @cOutField04 = CAST( @nScanCarton  AS NVARCHAR( 10))
      SET @cOutField05 = CAST( @nTotalCarton AS NVARCHAR( 10))
      SET @nScn  = @nScn - 1
      SET @nStep = @nStep - 1
      GOTO Quit

      Step_3_Fail:
   END
END
GOTO Quit


/********************************************************************************
Step 4. Screen = 6943
   CBOLKey  (Field01, display)
   Option   (Field02, input)  1 = YES, 2 = NO
********************************************************************************/
Step_4:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cOption = @cInField02

      -- Validate not empty
      IF @cOption = ''
      BEGIN
         SET @nErrNo = 274869
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Need Option
         GOTO Quit
      END

      -- Validate option value
      IF @cOption NOT IN ('1', '2')
      BEGIN
         SET @nErrNo = 274870
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Option
         GOTO Quit
      END

      IF @cOption = '1' -- YES - Close all MBOLs in CBOL
      BEGIN
         -- Validate confirm status maintained
         IF @cConfirmStatus = '' OR @cConfirmStatus = '0'
         BEGIN
            SET @nErrNo = 274872
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Confirm status not maintained
            GOTO Quit
         END

         -- Update all MBOLs in CBOL via cursor (primary key update, full rollback on any failure)
         DECLARE @cCurMBOLKey NVARCHAR(10)
         DECLARE cur_MBOL CURSOR LOCAL FAST_FORWARD FOR
            SELECT MBOLKey
            FROM dbo.MBOL WITH (NOLOCK)
            WHERE CBOLKey = @cCBOLKey

         BEGIN TRANSACTION

         OPEN cur_MBOL
         FETCH NEXT FROM cur_MBOL INTO @cCurMBOLKey

         WHILE @@FETCH_STATUS = 0
         BEGIN
            BEGIN TRY
               UPDATE dbo.MBOL WITH (ROWLOCK) SET
                  Status   = @cConfirmStatus,
                  EditWho  = @cUserName,
                  EditDate = GETDATE()
               WHERE MBOLKey = @cCurMBOLKey
            END TRY
            BEGIN CATCH
               CLOSE cur_MBOL
               DEALLOCATE cur_MBOL
               ROLLBACK TRANSACTION
               SET @nErrNo = 274871
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Close MBOL Err
               GOTO Quit
            END CATCH

            FETCH NEXT FROM cur_MBOL INTO @cCurMBOLKey
         END

         CLOSE cur_MBOL
         DEALLOCATE cur_MBOL

         COMMIT TRANSACTION

         -- Extended update
         IF @cExtendedUpdateSP <> ''
         BEGIN
            IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')
            BEGIN
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                  ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo, ' +
                  ' @cPackInfo, @cWeight, @cCube, @cCartonType, @nErrNo OUTPUT, @cErrMsg OUTPUT '
               SET @cSQLParam =
                  '@nMobile     INT,           ' +
                  '@nFunc       INT,           ' +
                  '@cLangCode   NVARCHAR( 3),  ' +
                  '@nStep       INT,           ' +
                  '@nInputKey   INT,           ' +
                  '@cStorerKey  NVARCHAR( 15), ' +
                  '@cCBOLKey    NVARCHAR( 10), ' +
                  '@cMBOLKey    NVARCHAR( 10), ' +
                  '@cLoadKey    NVARCHAR( 10), ' +
                  '@cOrderKey   NVARCHAR( 10), ' +
                  '@cLabelNo    NVARCHAR( 20), ' +
                  '@cPackInfo   NVARCHAR( 3),  ' +
                  '@cWeight     NVARCHAR( 10), ' +
                  '@cCube       NVARCHAR( 10), ' +
                  '@cCartonType NVARCHAR( 10), ' +
                  '@nErrNo      INT           OUTPUT, ' +
                  '@cErrMsg     NVARCHAR( 20) OUTPUT  '

               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                  @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cCBOLKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo,
                  @cPackInfo, @cWeight, @cCube, @cCartonType, @nErrNo OUTPUT, @cErrMsg OUTPUT

               IF @nErrNo <> 0
                  GOTO Quit
            END
         END
      END

      -- Back to CBOL screen (option 1 or 2)
      SET @cCBOLKey    = ''
      SET @cOutField01 = ''
      SET @nScn  = @nScn - 3
      SET @nStep = @nStep - 3
   END

   IF @nInputKey = 0 -- ESC: force user to choose, stay on same screen
   BEGIN
      SET @nErrNo = 274873
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Choose 1 or 2
   END

   IF @cExtScnSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtScnSP AND type = 'P')
         GOTO Step_99
   END
END
GOTO Quit


/********************************************************************************
Step 5. Screen = 6944
   "Not all LABEL/DROPID SCANNED for CBOL"
   CBOLKey  (Field01, display)
********************************************************************************/
Step_5:
BEGIN
   IF @nInputKey = 1 -- ENTER: acknowledge, back to CBOL screen
   BEGIN
      SET @cCBOLKey    = ''
      SET @cOutField01 = ''
      SET @nScn  = @nScn - 4
      SET @nStep = @nStep - 4
   END

   IF @nInputKey = 0 -- ESC: dismiss message, back to LabelNo scan screen
   BEGIN
      -- Recalc stats for correct display on Screen 2
      SELECT @nScanCarton = COUNT(URNNo)
      FROM RDT.RDTSCANTOTRUCK WITH (NOLOCK)
      WHERE RefNo = @cCBOLKey

      IF @cCheckPickDetailDropID = '1'
         SELECT @nTotalCarton = COUNT(DISTINCT PD.DropID)
         FROM dbo.MBOLDETAIL MD WITH (NOLOCK)
         JOIN dbo.PICKDETAIL PD WITH (NOLOCK) ON MD.OrderKey = PD.OrderKey
         JOIN dbo.MBOL M WITH (NOLOCK) ON MD.MBOLKey = M.MBOLKey
         WHERE M.CBOLKey = @cCBOLKey
      ELSE IF @cCheckPackDetailDropID = '1'
         SELECT @nTotalCarton = COUNT(DISTINCT PD.DropID)
         FROM dbo.MBOLDETAIL MD WITH (NOLOCK)
         JOIN dbo.PACKHEADER PH WITH (NOLOCK) ON MD.OrderKey = PH.OrderKey
         JOIN dbo.PACKDETAIL PD WITH (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
         JOIN dbo.MBOL M WITH (NOLOCK) ON MD.MBOLKey = M.MBOLKey
         WHERE M.CBOLKey = @cCBOLKey
      ELSE
         SELECT @nTotalCarton = COUNT(DISTINCT PD.LabelNo)
         FROM dbo.MBOLDETAIL MD WITH (NOLOCK)
         JOIN dbo.PACKHEADER PH WITH (NOLOCK) ON MD.OrderKey = PH.OrderKey
         JOIN dbo.PACKDETAIL PD WITH (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
         JOIN dbo.MBOL M WITH (NOLOCK) ON MD.MBOLKey = M.MBOLKey
         WHERE M.CBOLKey = @cCBOLKey

      SET @cOutField01 = @cCBOLKey
      SET @cOutField02 = ''
      SET @cMobBarcode = ''
      SET @cOutField03 = @cLabelNo  -- last scanned
      SET @cOutField04 = CAST( @nScanCarton  AS NVARCHAR( 10))
      SET @cOutField05 = CAST( @nTotalCarton AS NVARCHAR( 10))
      SET @nScn  = @nScn - 3
      SET @nStep = @nStep - 3
   END
END
GOTO Quit


/********************************************************************************
Step 99. Extended screen
********************************************************************************/
Step_99:
BEGIN
   IF @cExtScnSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtScnSP AND type = 'P')
      BEGIN
         DELETE FROM @tExtScnData

         DECLARE @nPreSCn      INT,
                 @nPreStep     INT,
                 @nPreInputKey INT

         SET @nPreSCn      = @nScn
         SET @nPreStep     = @nStep
         SET @nPreInputKey = @nInputKey

         EXECUTE [RDT].[rdt_ExtScnEntry]
            @cExtScnSP,
            @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @nInputKey, @cFacility, @cStorerKey, @tExtScnData,
            @cInField01 OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT, @cLottable01 OUTPUT,
            @cInField02 OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT, @cLottable02 OUTPUT,
            @cInField03 OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT, @cLottable03 OUTPUT,
            @cInField04 OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT, @dLottable04 OUTPUT,
            @cInField05 OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT, @dLottable05 OUTPUT,
            @cInField06 OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT, @cLottable06 OUTPUT,
            @cInField07 OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT, @cLottable07 OUTPUT,
            @cInField08 OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT, @cLottable08 OUTPUT,
            @cInField09 OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT, @cLottable09 OUTPUT,
            @cInField10 OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT, @cLottable10 OUTPUT,
            @cInField11 OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT, @cLottable11 OUTPUT,
            @cInField12 OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT, @cLottable12 OUTPUT,
            @cInField13 OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT, @dLottable13 OUTPUT,
            @cInField14 OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT, @dLottable14 OUTPUT,
            @cInField15 OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT, @dLottable15 OUTPUT,
            @nAction,
            @nScn OUTPUT, @nStep OUTPUT,
            @nErrNo  OUTPUT,
            @cErrMsg OUTPUT,
            @cUDF01 OUTPUT, @cUDF02 OUTPUT, @cUDF03 OUTPUT,
            @cUDF04 OUTPUT, @cUDF05 OUTPUT, @cUDF06 OUTPUT,
            @cUDF07 OUTPUT, @cUDF08 OUTPUT, @cUDF09 OUTPUT,
            @cUDF10 OUTPUT, @cUDF11 OUTPUT, @cUDF12 OUTPUT,
            @cUDF13 OUTPUT, @cUDF14 OUTPUT, @cUDF15 OUTPUT,
            @cUDF16 OUTPUT, @cUDF17 OUTPUT, @cUDF18 OUTPUT,
            @cUDF19 OUTPUT, @cUDF20 OUTPUT, @cUDF21 OUTPUT,
            @cUDF22 OUTPUT, @cUDF23 OUTPUT, @cUDF24 OUTPUT,
            @cUDF25 OUTPUT, @cUDF26 OUTPUT, @cUDF27 OUTPUT,
            @cUDF28 OUTPUT, @cUDF29 OUTPUT, @cUDF30 OUTPUT

         IF @nErrNo <> 0
            GOTO Step_99_Fail

         GOTO Quit
      END
   END

   Step_99_Fail:
      GOTO Quit
END


/********************************************************************************
Quit. Update back to I/O table
********************************************************************************/
Quit:
BEGIN
   UPDATE rdt.rdtMobRec WITH (ROWLOCK) SET
      EditDate     = GETDATE(),
      ErrMsg       = @cErrMsg,
      Func         = @nFunc,
      Step         = @nStep,
      Scn          = @nScn,

      StorerKey    = @cStorerKey,
      Facility     = @cFacility,

      V_CaseID     = @cLabelNo,
      V_LoadKey    = @cLoadKey,
      V_OrderKey   = @cOrderKey,
      V_PickSlipNo = @cPickSlipNo,
      V_Cartonno   = @nCartonNo,
      V_Barcode    = @cMobBarcode,

      V_String1    = @cCBOLKey,
      V_String2    = @cMBOLKey,
      V_String3    = @cCheckPackDetailDropID,
      V_String4    = @cCheckPickDetailDropID,
      V_String5    = @cExtendedUpdateSP,
      V_String6    = @cExtendedValidateSP,
      V_String7    = @cBypassPackConfirmCheck,
      V_String8    = @cCapturePackInfoSP,
      V_String9    = @cPackInfo,
      V_String10   = @cWeight,
      V_String11   = @cCube,
      V_String12   = @cCartonType,
      V_String13   = @cByPassCheckIDinCBOL,
      V_String14   = @cCloseMBOL,
      V_String15   = @cConfirmStatus,
      V_String22   = @cExtendedInfo,
      V_String23   = @cExtendedInfoSP,
      V_String24   = @cDecodeSP,
      V_String28   = @cExtScnSP,

      I_Field01 = @cInField01,  O_Field01 = @cOutField01,  FieldAttr01 = @cFieldAttr01,
      I_Field02 = @cInField02,  O_Field02 = @cOutField02,  FieldAttr02 = @cFieldAttr02,
      I_Field03 = @cInField03,  O_Field03 = @cOutField03,  FieldAttr03 = @cFieldAttr03,
      I_Field04 = @cInField04,  O_Field04 = @cOutField04,  FieldAttr04 = @cFieldAttr04,
      I_Field05 = @cInField05,  O_Field05 = @cOutField05,  FieldAttr05 = @cFieldAttr05,
      I_Field06 = @cInField06,  O_Field06 = @cOutField06,  FieldAttr06 = @cFieldAttr06,
      I_Field07 = @cInField07,  O_Field07 = @cOutField07,  FieldAttr07 = @cFieldAttr07,
      I_Field08 = @cInField08,  O_Field08 = @cOutField08,  FieldAttr08 = @cFieldAttr08,
      I_Field09 = @cInField09,  O_Field09 = @cOutField09,  FieldAttr09 = @cFieldAttr09,
      I_Field10 = @cInField10,  O_Field10 = @cOutField10,  FieldAttr10 = @cFieldAttr10,
      I_Field11 = @cInField11,  O_Field11 = @cOutField11,  FieldAttr11 = @cFieldAttr11,
      I_Field12 = @cInField12,  O_Field12 = @cOutField12,  FieldAttr12 = @cFieldAttr12,
      I_Field13 = @cInField13,  O_Field13 = @cOutField13,  FieldAttr13 = @cFieldAttr13,
      I_Field14 = @cInField14,  O_Field14 = @cOutField14,  FieldAttr14 = @cFieldAttr14,
      I_Field15 = @cInField15,  O_Field15 = @cOutField15,  FieldAttr15 = @cFieldAttr15

   WHERE Mobile = @nMobile
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdtfnc_ScanToTruck_ByCBOL] TO nSQL
GO
