SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************************************/
/* Store procedure: rdtfnc_SerialUnpackAndUnpick                                                */
/* Copyright      : Maersk                                                                      */
/*                                                                                              */
/* Date         Rev  Author         Purposes                                                    */
/* 2024-11-05   1.0  TLE109         FCR-917 Serial Unpack and Unpick                            */
/* 2025-01-15   1.1  NYE018         FCR-9889 Added Decode QR logic                              */
/* 2026-02-19   1.2  NYE018         FCR-10102 Added extended screen logic                       */
/************************************************************************************************/

CREATE OR ALTER PROC [RDT].[rdtfnc_SerialUnpackAndUnpick] (
   @nMobile    INT,
   @nErrNo     INT           OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

-- Misc variables
DECLARE
   @bSuccess       INT,
   @nAction        INT, 
   @cOption        NVARCHAR( 2),
   @cSQL           NVARCHAR( MAX),
   @cSQLParam      NVARCHAR( MAX),
   @nTranCount     INT,
   @cUNPACK_MODEL           NVARCHAR( 1) = '1',  -- choose unpack only
   @cUNPACKANDUNPICK_MODEL  NVARCHAR( 1) = '2',  -- choose unpack and unpick
   @cOrderKey      NVARCHAR( 20),
   @cLoadKey       NVARCHAR( 20)
   


   

-- RDT.RDTMobRec variables
DECLARE
   @nFunc            INT,
   @nScn             INT,
   @nStep            INT,
   @cLangCode        NVARCHAR( 3),
   @nInputKey        INT,
   @nMenu            INT,

   @cFacility        NVARCHAR( 5),
   @cStorerKey       NVARCHAR( 15),
   @cUserName        NVARCHAR( 18),
   @nEnter           INT,

   @cPickSlipNo      NVARCHAR( 20),
   @cUnPackType      NVARCHAR( 60),
   @cToLOC           NVARCHAR( 20),
   @nScannedNum      INT,
   
   -- FCR-9889
   @cDecodeSP  NVARCHAR( 20),
   @cBarcode   NVARCHAR( MAX),
   -- FCR-9889

   -- NEW VARIABLES FOR EXTENDED SCREEN - (NYE018 - FCR-10102)
   @cExtScnSP           NVARCHAR( 20),
   @tExtScnData         VariableTable,
   -- END NEW VARIABLES - (NYE018 - FCR-10102)


   @cInField01 NVARCHAR( 60),   @cOutField01 NVARCHAR( 60),   @cFieldAttr01 NVARCHAR( 1), @cLottable01  NVARCHAR( 18),
   @cInField02 NVARCHAR( 60),   @cOutField02 NVARCHAR( 60),   @cFieldAttr02 NVARCHAR( 1), @cLottable02  NVARCHAR( 18),
   @cInField03 NVARCHAR( 60),   @cOutField03 NVARCHAR( 60),   @cFieldAttr03 NVARCHAR( 1), @cLottable03  NVARCHAR( 18),
   @cInField04 NVARCHAR( 60),   @cOutField04 NVARCHAR( 60),   @cFieldAttr04 NVARCHAR( 1), @dLottable04  DATETIME,
   @cInField05 NVARCHAR( 60),   @cOutField05 NVARCHAR( 60),   @cFieldAttr05 NVARCHAR( 1), @dLottable05  DATETIME,
   @cInField06 NVARCHAR( 60),   @cOutField06 NVARCHAR( 60),   @cFieldAttr06 NVARCHAR( 1), @cLottable06  NVARCHAR( 30),
   @cInField07 NVARCHAR( 60),   @cOutField07 NVARCHAR( 60),   @cFieldAttr07 NVARCHAR( 1), @cLottable07  NVARCHAR( 30),
   @cInField08 NVARCHAR( 60),   @cOutField08 NVARCHAR( 60),   @cFieldAttr08 NVARCHAR( 1), @cLottable08  NVARCHAR( 30),
   @cInField09 NVARCHAR( 60),   @cOutField09 NVARCHAR( 60),   @cFieldAttr09 NVARCHAR( 1), @cLottable09  NVARCHAR( 30),
   @cInField10 NVARCHAR( 60),   @cOutField10 NVARCHAR( 60),   @cFieldAttr10 NVARCHAR( 1), @cLottable10  NVARCHAR( 30),
   @cInField11 NVARCHAR( 60),   @cOutField11 NVARCHAR( 60),   @cFieldAttr11 NVARCHAR( 1), @cLottable11  NVARCHAR( 30),
   @cInField12 NVARCHAR( 60),   @cOutField12 NVARCHAR( 60),   @cFieldAttr12 NVARCHAR( 1), @cLottable12  NVARCHAR( 30),
   @cInField13 NVARCHAR( 60),   @cOutField13 NVARCHAR( 60),   @cFieldAttr13 NVARCHAR( 1), @dLottable13  DATETIME,
   @cInField14 NVARCHAR( 60),   @cOutField14 NVARCHAR( 60),   @cFieldAttr14 NVARCHAR( 1), @dLottable14  DATETIME,
   @cInField15 NVARCHAR( 60),   @cOutField15 NVARCHAR( 60),   @cFieldAttr15 NVARCHAR( 1), @dLottable15  DATETIME,

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

-- Getting Mobile information
SELECT
   @nFunc            = Func,
   @nScn             = Scn,
   @nStep            = Step,
   @nInputKey        = InputKey,
   @nMenu            = Menu,
   @cLangCode        = Lang_code,

   @cFacility        = Facility,
   @cStorerKey       = StorerKey,
   @cUserName        = UserName,
   @nEnter           = V_Integer1,

   @cBarcode         = V_Barcode,     -- FCR-9889
   @cDecodeSP        = V_String10,    -- FCR-9889

   @cExtScnSP        = V_String9, -- (NYE018 - FCR-10102)

   @cPickSlipNo      = V_PickSlipNo,
   @cUnPackType      = V_String1,
   @cToLOC           = V_Loc,
   @nScannedNum      = V_Qty,

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

FROM rdt.rdtMobRec WITH (NOLOCK)
WHERE Mobile = @nMobile

IF @nFunc = 1868 -- Serial Unpack and Unpick
BEGIN
   -- Redirect to respective screen
   IF @nStep = 0  GOTO Step_0  -- Menu. Func = 1868
   IF @nStep = 1  GOTO Step_1  -- Scn = 6511. PSNO
   IF @nStep = 2  GOTO Step_2  -- Scn = 6512. Confirm Unpack or Unpack & Unpick
   IF @nStep = 3  GOTO Step_3  -- Scn = 6513. Unpack & Unpick location
   IF @nStep = 4  GOTO Step_4  -- Scn = 6514. Scan serial number
   IF @nStep = 5  GOTO Step_5  -- Scn = 6515. Complete
   IF @nStep = 99 GOTO Step_ExtendedScreen -- Extended Screen Entry - (NYE018 - FCR-10102)
END
RETURN -- Do nothing if incorrect step

Step_0:
BEGIN


     -- EventLog
   EXEC RDT.rdt_STD_EventLog
      @cActionType = '1', -- Sign-in
      @cUserID     = @cUserName,
      @nMobileNo   = @nMobile,
      @nFunctionID = @nFunc,
      @cFacility   = @cFacility,
      @cStorerKey  = @cStorerKey,
      @nStep       = @nStep


   -- Go to PSNO screen
   SET @nScn = 6511
   SET @nStep = 1
   SET @cOutField01 = ''
   SET @nScannedNum = 0

   SET @cDecodeSP = rdt.RDTGetConfig( @nFunc, 'DecodeSP', @cStorerkey)
      IF @cDecodeSP IN ('0', '')
         SET @cDecodeSP = ''
   
   -- START CHANGE: Load ExtScnSP Config - (NYE018 - FCR-10102)
   SET @cExtScnSP = rdt.RDTGetConfig( @nFunc, 'ExtScnSP', @cStorerKey)
   IF @cExtScnSP = '0' SET @cExtScnSP = ''
   -- END CHANGE - (NYE018 - FCR-10102)
   
END
GOTO QUIT


Step_1:
BEGIN
   IF @nInputKey = 1
   BEGIN
      
      IF @cInField01 = '' OR LEN(@cInField01) > 10
      BEGIN
         SET @nErrNo = 228251
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  --228251^PSNO is not valid
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_QUIT
      END

      SET @cPickslipNo = @cInField01

      IF NOT EXISTS( SELECT 1 FROM dbo.PackHeader WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND PickSlipNo = @cPickslipNo)
      BEGIN
         SET @nErrNo = 228251
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  --228251^PSNO is not valid
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_QUIT
      END

      SELECT @cOrderKey = OrderKey, @cLoadKey = LoadKey
      FROM dbo.PackHeader WITH(NOLOCK)
      WHERE StorerKey = @cStorerKey AND PickSlipNo = @cPickslipNo

      IF @cOrderKey IS NOT NULL AND @cOrderKey <> '' 
         AND EXISTS( SELECT 1 FROM dbo.ORDERS WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND OrderKey = @cOrderKey AND [Status] = 9 )
      BEGIN
         SET @nErrNo = 228252
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  --228252^Order Shipped
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_QUIT
      END

      IF @cLoadKey IS NOT NULL AND @cLoadKey <> ''
         AND EXISTS( SELECT 1 FROM dbo.ORDERS WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND LoadKey = @cLoadKey AND [Status] = 9 )
      BEGIN
         SET @nErrNo = 228252
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  --228252^Order Shipped
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_QUIT
      END

      SET @nScn = @nScn + 1
      SET @nStep = @nStep + 1
   END
   ELSE BEGIN
      -- EventLog
      EXEC RDT.rdt_STD_EventLog
         @cActionType = '9', -- Sign-out
         @cUserID     = @cUserName,
         @nMobileNo   = @nMobile,
         @nFunctionID = @nFunc,
         @cFacility   = @cFacility,
         @cStorerKey  = @cStorerKey,
         @nStep       = @nStep

      -- Back to menu
      SET @nFunc = @nMenu
      SET @nScn  = @nMenu
      SET @nStep = 0
   END
END
Step_1_QUIT:
   SET @cOutField01 = ''
   GOTO QUIT


Step_2:
BEGIN
   IF @nInputKey = 1
   BEGIN
      SET @cUnPackType = @cInField01

      IF @cUnPackType NOT IN(@cUNPACK_MODEL, @cUNPACKANDUNPICK_MODEL)
      BEGIN
         SET @nErrNo = 228253
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  --228253^Please enter valid value
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_2_QUIT
      END
      

      IF @cUnPackType = @cUNPACK_MODEL
      BEGIN

         -- FCR-10102
         IF @cExtScnSP <> ''
         BEGIN
            GOTO Step_ExtendedScreen
         END
         -- FCR-10102

         SET @nScn = @nScn + 2
         SET @nStep = @nStep + 2
         SET @cOutField02 = CAST( @nScannedNum AS NVARCHAR(10))
         SET @cOutField03 = 'UnPack'
      END
      ELSE IF @cUnPackType = @cUNPACKANDUNPICK_MODEL
      BEGIN
         SET @nScn = @nScn + 1
         SET @nStep = @nStep + 1
      END
   END
   ELSE 
   BEGIN
      SET @cUnPackType = ''
      SET @nScn = @nScn - 1
      SET @nStep = @nStep - 1
   END
END
Step_2_QUIT:
   SET @cOutField01 = ''
   SET @nScannedNum = 0
   GOTO QUIT


Step_3:
BEGIN
   IF @nInputKey = 1
   BEGIN
      DECLARE @cToInLOC NVARCHAR( 100)
      SET @cToInLOC = @cInField01

      IF @cToInLOC = '' OR NOT EXISTS( SELECT 1 FROM LOC WITH(NOLOCK) WHERE Loc = @cToInLOC AND Facility = @cFacility )
      BEGIN
         SET @nErrNo = 228254
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')   --228254^Location is not valid
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_3_QUIT
      END

      IF NOT EXISTS( SELECT 1 FROM LOC WITH(NOLOCK) WHERE Loc = @cToInLOC AND LocationType IN('STAGE', 'STAGING') AND Facility = @cFacility )
      BEGIN
         SET @nErrNo = 228255
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')   --228255^Location is not Staging
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_3_QUIT
      END

      SET @cToLOC = @cToInLOC

      -- FCR-10102
      IF @cExtScnSP <> ''
      BEGIN
         GOTO Step_ExtendedScreen
      END
      -- FCR-10102

      SET @nScn = @nScn + 1
      SET @nStep = @nStep + 1  

      SET @cOutField02 = CAST( @nScannedNum AS NVARCHAR(10))
      SET @cOutField03 = 'UnPack And UnPick'
   END
   ELSE
   BEGIN
      SET @cToLOC = ''
      SET @nScn = @nScn - 1
      SET @nStep = @nStep - 1    
   END
END
Step_3_QUIT:
   SET @cOutField01 = ''
   GOTO QUIT


Step_4:
BEGIN
   IF @nInputKey = 1 
   BEGIN
      IF @cInField04 = '9'
      BEGIN
         SET @nScn = @nScn + 1
         SET @nStep = @nStep + 1
         GOTO Step_4_QUIT
      END
      ELSE IF @cInField04 IS NOT NULL AND @cInField04 <> ''
      BEGIN
         SET @nErrNo = 228267
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')   --228267^Invalid Option
         EXEC rdt.rdtSetFocusField @nMobile, 4
         GOTO QUIT
      END

      DECLARE @cSerialNo NVARCHAR( 200)
      -- @cBarcode already populated from V_Barcode (FCR-9889)
      SET @cSerialNo = @cBarcode

      IF @cSerialNo = ''
      BEGIN
         SET @nErrNo = 228256
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')   --228256^SerialNo is not valid
         GOTO Step_4_QUIT
      END

      -- FCR-9889 - Decode QR code if decode SP is configured
      IF @cDecodeSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cDecodeSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cDecodeSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cBarcode, ' +
               ' @cSerialNo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               ' @nMobile      INT,           ' +
               ' @nFunc        INT,           ' +
               ' @cLangCode    NVARCHAR( 3),  ' +
               ' @nStep        INT,           ' +
               ' @nInputKey    INT,           ' +
               ' @cFacility    NVARCHAR( 5),  ' +
               ' @cStorerKey   NVARCHAR( 15), ' +
               ' @cBarcode     NVARCHAR( MAX), ' +
               ' @cSerialNo    NVARCHAR( 20)  OUTPUT, ' +
               ' @nErrNo       INT            OUTPUT, ' +
               ' @cErrMsg      NVARCHAR( 1024)  OUTPUT'
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cBarcode,
               @cSerialNo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT
         END
      END

      -- Check for DecodeSP errors immediately
      IF @nErrNo <> 0
      BEGIN
         GOTO Step_4_QUIT
      END
      -- (FCR-9889) Logic for DecodeSP

      IF @cUnPackType = @cUNPACK_MODEL  --only unpack
      BEGIN

         SET @nTranCount = @@TRANCOUNT
         BEGIN TRAN
         SAVE TRAN tran_SerialUnpack

         EXEC rdt.rdt_1868UnpackVal   @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,
            @cSerialNo, @cPickslipNo,
            @nErrNo OUTPUT, @cErrMsg OUTPUT
         IF @nErrNo <> 0
         BEGIN
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
            IF @nTranCount = 0 ROLLBACK TRAN ELSE ROLLBACK TRAN tran_SerialUnpack
            GOTO Step_4_QUIT
         END

         EXEC rdt.rdt_1868UnpackConfirm   @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,
               @cSerialNo, @cPickslipNo,
               @nErrNo OUTPUT, @cErrMsg OUTPUT
         IF @nErrNo <> 0
         BEGIN
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
            IF @nTranCount = 0 ROLLBACK TRAN ELSE ROLLBACK TRAN tran_SerialUnpack
            GOTO Step_4_QUIT
         END
      
         
         SET @nScannedNum = @nScannedNum + 1
         IF @nTranCount = 0 COMMIT TRAN
      END
      ELSE IF @cUnPackType = @cUNPACKANDUNPICK_MODEL  --unpack and unpick
      BEGIN

         SET @nTranCount = @@TRANCOUNT
         BEGIN TRAN
         SAVE TRAN tran_SerialUnpackAndUnpick

         EXEC rdt.rdt_1868UnpackVal   @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,
            @cSerialNo, @cPickslipNo,
            @nErrNo OUTPUT, @cErrMsg OUTPUT
         IF @nErrNo <> 0
         BEGIN
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
            IF @nTranCount = 0 ROLLBACK TRAN ELSE ROLLBACK TRAN tran_SerialUnpackAndUnpick
            GOTO Step_4_QUIT
         END

         DECLARE
            @cPickDetailKey   NVARCHAR( 20),
            @cSKU             NVARCHAR( 40)
         
         SET @cOrderKey = ''
         SET @cPickDetailKey = ''
         SET @cSKU = ''
         SET @cLoadKey = ''
         
         SELECT 
            @cOrderKey = OrderKey,
            @cLoadKey = LoadKey
         FROM dbo.PackHeader WITH(NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
            AND StorerKey=@cStorerKey
            
         IF @cOrderKey = '' AND @cLoadKey = ''
         BEGIN
            SET @nErrNo = 228264
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  --228264^OrderKey Not Exists
            IF @nTranCount = 0 ROLLBACK TRAN ELSE ROLLBACK TRAN tran_SerialUnpackAndUnpick
            GOTO Step_4_QUIT
         END

         SELECT  
            @cPickDetailKey = PickDetailKey, 
            @cSKU           = SKU
         FROM dbo.PackSerialNo WITH(NOLOCK)
         WHERE  SerialNo =@cSerialNo
            AND PickSlipNo =@cPickSlipNo
            AND StorerKey=@cStorerKey

         IF @cPickDetailKey = '' OR @cSKU = ''
         BEGIN
            SET @nErrNo = 228265 
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  --228265^SKU Or PickDetailKey Not Exists
            IF @nTranCount = 0 ROLLBACK TRAN ELSE ROLLBACK TRAN tran_SerialUnpackAndUnpick
            GOTO Step_4_QUIT
         END

         EXEC rdt.rdt_1868UnpackConfirm   @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,
            @cSerialNo, @cPickslipNo,
            @nErrNo OUTPUT, @cErrMsg OUTPUT
         IF @nErrNo <> 0
         BEGIN
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
            IF @nTranCount = 0 ROLLBACK TRAN ELSE ROLLBACK TRAN tran_SerialUnpackAndUnpick
            GOTO Step_4_QUIT
         END

         EXEC rdt.rdt_1868UnpickConfirm  @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,
               @cSerialNo, @cPickslipNo, @cOrderKey, @cPickDetailKey, @cSKU, @cToLOC, @cLoadKey,
               @nErrNo OUTPUT, @cErrMsg OUTPUT
         IF @nErrNo <> 0
         BEGIN
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
            IF @nTranCount = 0 ROLLBACK TRAN ELSE ROLLBACK TRAN tran_SerialUnpackAndUnpick
            GOTO Step_4_QUIT
         END

         SET @nScannedNum = @nScannedNum + 1
         IF @nTranCount = 0 COMMIT TRAN
      END
   END
   ELSE
   BEGIN
      -- FCR-10102 logic: Let Extended Screen handle the Back navigation
      IF @cExtScnSP <> ''
      BEGIN
         GOTO Step_ExtendedScreen
      END
      -- End FCR-10102 logic
      IF @cUnPackType = @cUNPACK_MODEL 
      BEGIN
         SET @nScn = @nScn - 2
         SET @nStep = @nStep - 2
      END
      ELSE IF @cUnPackType = @cUNPACKANDUNPICK_MODEL
      BEGIN
         SET @nScn = @nScn - 1
         SET @nStep = @nStep - 1
      END
      GOTO Step_4_QUIT
   END
END
Step_4_QUIT:

   SET @cBarcode   = ''  --clear barcode (FCR-9889)
   SET @cOutField01 = ''
   SET @cOutFIeld04 = ''
   IF @nStep = 4
   BEGIN
      EXEC rdt.rdtSetFocusField @nMobile, 1
      SET @cOutField02 = CAST(@nScannedNum AS NVARCHAR(10))
   END
   ELSE IF @nStep = 5
   BEGIN 
      IF @cUnPackType = @cUNPACK_MODEL
      BEGIN
         SET @cOutField01 = 'UnPack'
      END
      ELSE IF @cUnPackType = @cUNPACKANDUNPICK_MODEL
      BEGIN
         SET @cOutField01 = 'UnPack And UnPick'
      END
   END
   ELSE
   BEGIN
      SET @cOutField01 = ''
      SET @cOutField02 = ''
      SET @cOutField03 = ''
      SET @cOutField04 = ''
   END
   GOTO QUIT


Step_5:
BEGIN
   SET @nScn = @nScn - 1
   SET @nStep = @nStep - 1
   SET @cOutField01 = ''
   SET @nScannedNum = 0
   SET @cOutField02 = CAST( @nScannedNum AS NVARCHAR(10) )
   SET @cOutField04 = ''
END
GOTO QUIT

-- FCR-10102
Step_ExtendedScreen:
BEGIN
   IF @cExtScnSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtScnSP AND type = 'P')
      BEGIN
         -- Clear output fields to prevent ghost data
         SET @cOutField01 = ''
         SET @cOutField02 = ''
         SET @cOutField03 = ''
         SET @cOutField04 = ''

         DECLARE @nStepBak INT,@nScnBak INT
         SELECT @nStepBak = @nStep, @nScnBak = @nScn

         DELETE FROM @tExtScnData
         INSERT INTO @tExtScnData (Variable, Value) VALUES
         ('@nScnBak', CAST(@nScnBak AS NVARCHAR(20))),
         ('@nStepBak', CAST(@nStepBak AS NVARCHAR(20))),
         ('@cOption',   @cInField01)

         EXECUTE [RDT].[rdt_ExtScnEntry] 
         @cExtScnSP, 
         @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @nInputKey, @cFacility, @cStorerKey, @tExtScnData ,
         @cInField01 OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  @cLottable01 OUTPUT,  
         @cInField02 OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  @cLottable02 OUTPUT,  
         @cInField03 OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  @cLottable03 OUTPUT,  
         @cInField04 OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  @dLottable04 OUTPUT,  
         @cInField05 OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  @dLottable05 OUTPUT,  
         @cInField06 OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  @cLottable06 OUTPUT, 
         @cInField07 OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  @cLottable07 OUTPUT, 
         @cInField08 OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  @cLottable08 OUTPUT, 
         @cInField09 OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  @cLottable09 OUTPUT, 
         @cInField10 OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  @cLottable10 OUTPUT, 
         @cInField11 OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  @cLottable11 OUTPUT,
         @cInField12 OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  @cLottable12 OUTPUT,
         @cInField13 OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  @dLottable13 OUTPUT,
         @cInField14 OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  @dLottable14 OUTPUT,
         @cInField15 OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  @dLottable15 OUTPUT,
         @nAction, 
         @nScn     OUTPUT,  @nStep OUTPUT,
         @nErrNo   OUTPUT, 
         @cErrMsg  OUTPUT,
         @cUDF01   OUTPUT, @cUDF02 OUTPUT, @cUDF03 OUTPUT,
         @cUDF04   OUTPUT, @cUDF05 OUTPUT, @cUDF06 OUTPUT,
         @cUDF07   OUTPUT, @cUDF08 OUTPUT, @cUDF09 OUTPUT,
         @cUDF10   OUTPUT, @cUDF11 OUTPUT, @cUDF12 OUTPUT,
         @cUDF13   OUTPUT, @cUDF14 OUTPUT, @cUDF15 OUTPUT,
         @cUDF16   OUTPUT, @cUDF17 OUTPUT, @cUDF18 OUTPUT,
         @cUDF19   OUTPUT, @cUDF20 OUTPUT, @cUDF21 OUTPUT,
         @cUDF22   OUTPUT, @cUDF23 OUTPUT, @cUDF24 OUTPUT,
         @cUDF25   OUTPUT, @cUDF26 OUTPUT, @cUDF27 OUTPUT,
         @cUDF28   OUTPUT, @cUDF29 OUTPUT, @cUDF30 OUTPUT

         IF @nErrNo <> 0
            GOTO Quit
      END
   END
   GOTO Quit
END
-- FCR-10102

Quit:
BEGIN
   UPDATE rdt.RDTMOBREC WITH (ROWLOCK) SET
      EditDate = GETDATE(),
      ErrMsg = @cErrMsg,
      Func   = @nFunc,
      Step   = @nStep,
      Scn    = @nScn,
      StorerKey      = @cStorerKey,
      Facility       = @cFacility,
      V_Integer1     = @nEnter,
      
      V_Barcode     = @cBarcode,  -- FCR-9889
      V_String10    = @cDecodeSP, -- FCR-9889
      V_String9     = @cExtScnSP, -- (NYE018 - FCR-10102)

      V_PickSlipNo   = @cPickSlipNo,
      V_String1      = @cUnPackType,
      V_Loc          = @cToLoc,
      V_Qty          = @nScannedNum,
      
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

GRANT EXECUTE ON RDT.rdtfnc_SerialUnpackAndUnpick TO NSQL
GO