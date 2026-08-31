
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Store procedure: rdt_922ExtScn01                                        */
/* Copyright      : Maersk                                                 */
/* Customer       : Columbia SW MY                                         */
/*                                                                         */
/*                                                                         */
/* Date        Rev    Author     Purposes                                  */
/* 2026-04-21  1.0.0  Jackc      FCR-11588 created                         */
/* 2026-05-09  1.0.1  Jackc      FCR-11588 V1.3 FBR                        */
/* 2026-05-27  1.0.2  Jackc      FCR-11588 V1.5 FBR                        */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_922ExtScn01] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nScn         INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),
   @cStorerKey   NVARCHAR( 15),

   @tExtScnData   VariableTable READONLY,

   @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,  @cLottable01 NVARCHAR( 18) OUTPUT,
   @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,  @cLottable02 NVARCHAR( 18) OUTPUT,
   @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,  @cLottable03 NVARCHAR( 18) OUTPUT,
   @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,  @dLottable04 DATETIME      OUTPUT,
   @cInField05       NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,  @dLottable05 DATETIME      OUTPUT,
   @cInField06       NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,  @cLottable06 NVARCHAR( 30) OUTPUT,
   @cInField07       NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,  @cLottable07 NVARCHAR( 30) OUTPUT,
   @cInField08       NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,  @cLottable08 NVARCHAR( 30) OUTPUT,
   @cInField09       NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,  @cLottable09 NVARCHAR( 30) OUTPUT,
   @cInField10       NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,  @cLottable10 NVARCHAR( 30) OUTPUT,
   @cInField11       NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,  @cLottable11 NVARCHAR( 30) OUTPUT,
   @cInField12       NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,  @cLottable12 NVARCHAR( 30) OUTPUT,
   @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,  @dLottable13 DATETIME      OUTPUT,
   @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,  @dLottable14 DATETIME      OUTPUT,
   @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,  @dLottable15 DATETIME      OUTPUT,
   @nAction          INT,
   @nAfterScn        INT OUTPUT, @nAfterStep    INT OUTPUT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT,
   @cUDF01  NVARCHAR( 250) OUTPUT, @cUDF02 NVARCHAR( 250) OUTPUT, @cUDF03 NVARCHAR( 250) OUTPUT,
   @cUDF04  NVARCHAR( 250) OUTPUT, @cUDF05 NVARCHAR( 250) OUTPUT, @cUDF06 NVARCHAR( 250) OUTPUT,
   @cUDF07  NVARCHAR( 250) OUTPUT, @cUDF08 NVARCHAR( 250) OUTPUT, @cUDF09 NVARCHAR( 250) OUTPUT,
   @cUDF10  NVARCHAR( 250) OUTPUT, @cUDF11 NVARCHAR( 250) OUTPUT, @cUDF12 NVARCHAR( 250) OUTPUT,
   @cUDF13  NVARCHAR( 250) OUTPUT, @cUDF14 NVARCHAR( 250) OUTPUT, @cUDF15 NVARCHAR( 250) OUTPUT,
   @cUDF16  NVARCHAR( 250) OUTPUT, @cUDF17 NVARCHAR( 250) OUTPUT, @cUDF18 NVARCHAR( 250) OUTPUT,
   @cUDF19  NVARCHAR( 250) OUTPUT, @cUDF20 NVARCHAR( 250) OUTPUT, @cUDF21 NVARCHAR( 250) OUTPUT,
   @cUDF22  NVARCHAR( 250) OUTPUT, @cUDF23 NVARCHAR( 250) OUTPUT, @cUDF24 NVARCHAR( 250) OUTPUT,
   @cUDF25  NVARCHAR( 250) OUTPUT, @cUDF26 NVARCHAR( 250) OUTPUT, @cUDF27 NVARCHAR( 250) OUTPUT,
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT, @cUDF30 NVARCHAR( 250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag  INT = 0

   DECLARE
      @nMobrecScn       INT,
      @nMobrecStep      INT,   

      @nMenu            INT,
      @cUserName        NVARCHAR( 18),  
      @cSKU             NVARCHAR( 20),
      @nQTY             INT,
      @cSKUDescr        NVARCHAR( 60),
      @nFromScn         INT,
      @nFromStep        INT,

      @nTotalCarton     INT,

      @cFromDropID         NVARCHAR( 20),
      @cExtendedValidateSP NVARCHAR( 20),
      @cExtendedUpdateSP   NVARCHAR( 20),
      @cExtendedInfoSP     NVARCHAR( 20),
      @cExtendedInfo       NVARCHAR( 20),
      @cDecodeSP           NVARCHAR( 20),
      @cAutoScanIn         NVARCHAR( 1),
      @cDefaultOption      NVARCHAR( 1),
      @cDisableOption      NVARCHAR( 10),    -- ZG01
      @cSerialNoCapture    NVARCHAR( 1),
      @cPackList           NVARCHAR( 10),
      @cShipLabel          NVARCHAR( 10),

      @cMultiSKUBarcode    NVARCHAR( 1),
      @cPQTY               NVARCHAR( 5),
      @cMQTY               NVARCHAR( 5),
      @cPUOM               NVARCHAR( 1),
      @cMUOM               NVARCHAR( 1),
      @cPUOM_Desc          NCHAR( 5),
      @cMUOM_Desc          NCHAR( 5),
      @nPUOM_Div           INT,
      @nPQTY               INT,
      @nMQTY               INT,

      --Mobrec parameter
      @cPaperPrinter            NVARCHAR( 10),
      @cLabelPrinter            NVARCHAR( 10),
      @cLoadKey                 NVARCHAR( 10),
      @cOrderKey                NVARCHAR( 10),
      @cLabelNo                 NVARCHAR( 20),
      @cPickSlipNo              NVARCHAR( 10),
      @nCartonNo                INT,
      @cMobBarcode              NVARCHAR( MAX),
   
      @cMBOLKey                 NVARCHAR( 10),
      @cType                    NVARCHAR( 1),
      @cCheckPackDetailDropID   NVARCHAR( 1),
      @cCheckPickDetailDropID   NVARCHAR( 1),
      @cBypassMBOLShippedCheck  NVARCHAR( 1),
      @cBypassPackConfirmCheck  NVARCHAR( 1),
      @cCapturePackInfoSP       NVARCHAR( 20),
      @cPackInfo                NVARCHAR( 3),
      @cWeight                  NVARCHAR( 10),
      @cCube                    NVARCHAR( 10),
      @cCartonType              NVARCHAR( 10),
      @cRefNum                  NVARCHAR( 20),
      @cByPassCheckIDinMBOL     NVARCHAR( 1),
      @cAutoScanOutPS           NVARCHAR( 1),
      @cCaptureRefInfo          NVARCHAR( 1),
      @cDoor                    NVARCHAR( 10),
      @cRefNo                   NVARCHAR( 40),
      @cOTMITF                  NVARCHAR( 1),
      @cManifestReport          NVARCHAR( 20),
      @cCloseMBOL               NVARCHAR( 20),
      @cConfirmStatus           NVARCHAR( 20),
      @cExtScnSP                NVARCHAR( 20),

      @cID                      NVARCHAR( 18),
      @cSQL                     NVARCHAR( MAX),
      @cSQLParam                NVARCHAR( MAX),
      @nScanCarton              INT,
      @nQtyPacked               INT,
      @nQtyPicked               INT,
      @b_success                INT

   --6866
   DECLARE
      @cUCCNo              NVARCHAR(20),
      @cUCCStatus          NVARCHAR( 1),
      @cOrderLineNumber    NVARCHAR( 5),
      @cMBOLLineNumber     NVARCHAR( 5),
      @cPickDetailOrderKey NVARCHAR(10),
      @cPickDetailKey      NVARCHAR(10),
      @cSOStatus           NVARCHAR(10),
      @fOrdTotalCube       FLOAT,
      @fOrdTotalWeight     FLOAT,
      @fOrdTotalQty        FLOAT,
      @nTranCount          INT,
      @nRowCount           INT,
      @nRowRef             INT, 
      @nScanUCC            INT,
      @nTotalUCC           INT,

   --6868
      @cOption             NVARCHAR( 1)   

   -- Load RDT.RDTMobRec
   SELECT
      @nMobrecScn  = Scn,
      @nMobrecStep = Step,


      @cUserName   = UserName,
      @cPaperPrinter = Printer_Paper,
      @cLabelPrinter = Printer,

      @cLoadKey    = V_LoadKey,
      @cOrderKey   = V_OrderKey,
      @cLabelNo    = V_CaseID,
      @cPickSlipNo = V_PickSlipNo,
      @nCartonNo   = V_Cartonno,
      @cMobBarcode = V_Barcode,

      @cMBOLKey    = V_String1,
      @cType       = V_String2,
      @cCheckPackDetailDropID  = V_String3,
      @cCheckPickDetailDropID  = V_String4,
      @cExtendedUpdateSP       = V_String5,
      @cExtendedValidateSP     = V_String6,
      @cBypassMBOLShippedCheck = V_String7,
      @cBypassPackConfirmCheck = V_String8,
      @cCapturePackInfoSP      = V_String9,
      @cPackInfo               = V_String10,
      @cWeight                 = V_String11,
      @cCube                   = V_String12,
      @cCartonType             = V_String13,
      @cRefNum                 = V_String14,
      @cByPassCheckIDinMBOL    = V_String15,
      @cAutoScanOutPS          = V_String16,
      @cCaptureRefInfo         = V_String17,
      @cDoor                   = V_String18,
      @cRefNo                  = V_String19,
      @cOTMITF                 = V_String20,
      @cExtendedInfo           = V_String22,
      @cExtendedInfoSP         = V_String23,
      @cDecodeSP               = V_String24,
      @cManifestReport         = V_String25,
      @cCloseMBOL              = V_String26,
      @cConfirmStatus          = V_String27,
      @cExtScnSP               = V_String28

   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SET @cUDF01 = ''

   IF @nFunc = 922
   BEGIN
      -- V1.0.1 populate Vessel and Vehicle_Type from MBOL
      IF @nScn = 3433 AND @nStep = 4
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Populate Vessel/Vehicle_Type from MBOL for Step 4'

         -- Get Vessel and Vehicle_Type from MBOL if available
         SET @cOutField01 = ''
         SET @cOutField02 = ''
         SELECT
            @cOutField01 = CASE WHEN ISNULL(RTRIM(Vessel), '') <> '' THEN RTRIM(Vessel) ELSE @cOutField01 END,
            @cOutField02 = CASE WHEN ISNULL(RTRIM(Vehicle_Type), '') <> '' THEN RTRIM(Vehicle_Type) ELSE @cOutField02 END
         FROM dbo.MBOL WITH (NOLOCK)
         WHERE MBOLKey = @cMBOLKey

         GOTO Quit
      END

      IF @nMobrecScn = 3433 AND @nMobrecStep = 4 AND @nInputKey = 1 -- V1.0.1 Enter on Step_4
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Main step4, enter'

         IF ISNULL(@cInField01,'') = '' OR ISNULL(@cInField02,'') = ''
         BEGIN
            SET @nErrNo = 264581
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need input
            GOTO Scn_3433_Fail
         END

         BEGIN TRY
            UPDATE dbo.MBOL WITH (ROWLOCK)
            SET Vessel = LEFT(@cInField01, 30),
               Vehicle_Type = LEFT(@cInField02, 20)
            WHERE MBOLKey = @cMBOLKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 264582
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update MBOL Failed
            GOTO Scn_3433_Fail
         END CATCH

         SET @nAfterStep = 99
         SET @nAfterScn = 6869

         GOTO Quit

         Scn_3433_Fail:
            SET @nAfterScn = 3433
            SET @nAfterStep = 4
            GOTO Quit
      END

      -- redirect to new carton id logic
      IF @nScn = 3431 AND @nStep = 2
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Redirect to new carton ID logic scn6869, st99'

         SET @nAfterStep = 99
         SET @nAfterScn = 6869
         GOTO Quit
      END-- redirct to new cart id logic

      IF @nStep = 99
      BEGIN
         /********************************************************************************
         Screen 6869
            MBOLKey         (Field01)
            --LoadKey         (Field02)
            OrderKey        (Field03)
            RefNo           (Field08)
            LabelNo/DropID  (Field04, input)
            Last scanned    (Field05)
            Total carton    (Field06)
            Scan carton     (Field07)
            ExtendInfo      (Field15)
         ********************************************************************************/
         IF @nScn = 6869
         BEGIN
            SET @cUDF01 = 'NO UPD RDTMOBREC'

            IF @nInputKey = 1 -- ENTER
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'St99, Scn 6869, Enter'

               -- Screen mapping
               DECLARE @cLabelNoBarcode NVARCHAR(MAX)

               SET @cLabelNo = LEFT(@cMobBarcode, 20) 
               SET @cLabelNoBarcode = LEFT(@cMobBarcode, 2000)

               -- Check label
               IF @cLabelNo = ''
               BEGIN
                  SET @nErrNo = 264552
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Label No
                  GOTO Scn_6869_Fail
               END

               -- Decode
               -- Standard decode
               IF @cDecodeSP = '1'
               BEGIN
                  EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cLabelNoBarcode,
                     @cID     = @cLabelNo    OUTPUT,
                     @nErrNo  = @nErrNo      OUTPUT,
                     @cErrMsg = @cErrMsg     OUTPUT,
                     @cType   = 'ID'

                  IF @nErrNo <> 0
                     GOTO Scn_6869_Fail
               END
               ELSE
               BEGIN
                  IF @cDecodeSP <> ''
                  BEGIN
                     IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cDecodeSP AND type = 'P')
                     BEGIN
                        SELECT @cID = '',  @cLabelNo = ''

                        SET @cSQL = 'EXEC rdt.' + RTRIM( @cDecodeSP) +
                           ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNoBarcode OUTPUT, @cFieldName, ' +
                           ' @cLabelNo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
                        SET @cSQLParam =
                           ' @nMobile      INT,             ' +
                           ' @nFunc        INT,             ' +
                           ' @cLangCode    NVARCHAR( 3),    ' +
                           ' @nStep        INT,             ' +
                           ' @nInputKey    INT,             ' +
                           ' @cStorerKey   NVARCHAR( 15),   ' +
                           ' @cMBOLKey     NVARCHAR( 10),   ' +
                           ' @cLoadKey     NVARCHAR( 10),   ' +
                           ' @cOrderKey    NVARCHAR( 10),   ' +
                           ' @cLabelNoBarcode     NVARCHAR( MAX) OUTPUT, ' +
                           ' @cFieldName   NVARCHAR( 10),   ' +
                           ' @cLabelNo     NVARCHAR( 20)  OUTPUT, ' +
                           ' @nErrNo       INT            OUTPUT, ' +
                           ' @cErrMsg      NVARCHAR( 20)  OUTPUT'

                        EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                           @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNoBarcode OUTPUT, 'ID',
                           @cLabelNo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                        IF @nErrNo <> 0
                           GOTO Scn_6869_Fail
                     END
                  END
               END

               -- Check double scan
               DECLARE @cDoubleScan NVARCHAR(1)

               SET @cDoubleScan = ''
               IF @cType IN ('M', 'R')
                  IF EXISTS( SELECT 1 FROM RDT.RDTScanToTruck WITH (NOLOCK) WHERE RefNo = @cLabelNo AND MBOLKey = @cMBOLKey AND Status = '9')
                     SET @cDoubleScan = 'Y'
               IF @cType = 'L'
                  IF EXISTS( SELECT 1 FROM RDT.RDTScanToTruck WITH (NOLOCK) WHERE RefNo = @cLabelNo AND LoadKey = @cLoadKey AND Status = '9')
                     SET @cDoubleScan = 'Y'
               IF @cType = 'O'
                  IF EXISTS( SELECT 1 FROM RDT.RDTScanToTruck WITH (NOLOCK) WHERE RefNo = @cLabelNo AND OrderKey = @cOrderKey AND Status = '9')
                     SET @cDoubleScan = 'Y'

               IF @cDoubleScan = 'Y'
               BEGIN
                  SET @nErrNo = 264553
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Label Scanned
                  GOTO Scn_6869_Fail
               END

               DECLARE @cPackHeaderOrderKey NVARCHAR(10)
               DECLARE @cPackHeaderLoadKey  NVARCHAR(10)
               DECLARE @cStatus   NVARCHAR(10)

               SET @cPickDetailOrderKey = ''
               SET @cPackHeaderOrderKey = ''
               SET @cPackHeaderLoadKey = ''
               SET @cPickSlipNo = ''
               SET @nCartonNo = 0
               SET @cStatus = ''

               -- PickDetail
               IF @cCheckPickDetailDropID = '1'
               BEGIN
                  -- Get PickDetail info
                  SELECT
                     @cStatus = Status,
                     @cPickDetailOrderKey = OrderKey
                  FROM dbo.PickDetail WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cLabelNo

                  -- Check ID valid
                  IF @cStatus = ''
                  BEGIN
                     SET @nErrNo = 264554
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --BAD LBNo/DrpID
                     GOTO Scn_6869_Fail
                  END

                  -- Check pick confirm
                  IF @cStatus < '5'
                  BEGIN
                     SET @nErrNo = 264555
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NotPickConfirm
                     GOTO Scn_6869_Fail
                  END
               END
               ELSE
               BEGIN
                  -- Get PackHeaderInfo
                  IF @cCheckPackDetailDropID = '1'
                     SELECT TOP 1
                        @cPickSlipNo = PH.PickSlipNo,
                        @cPackHeaderOrderKey = PH.OrderKey,
                        @cPackHeaderLoadKey = PH.LoadKey,
                        @nCartonNo = PD.CartonNo
                     FROM dbo.PackHeader PH WITH (NOLOCK)
                        JOIN dbo.PackDetail PD WITH (NOLOCK) ON (PH.PickSlipNo = PD.PickSlipNo)
                     WHERE PD.StorerKey = @cStorerKey
                        AND PD.DropID = @cLabelNo
                     ORDER BY PH.PickslipNo Desc -- (ChewKP04)
                  ELSE
                     SELECT TOP 1
                        @cPickSlipNo = PH.PickSlipNo,
                        @cPackHeaderOrderKey = PH.OrderKey,
                        @cPackHeaderLoadKey = PH.LoadKey,
                        @nCartonNo = PD.CartonNo
                     FROM dbo.PackHeader PH WITH (NOLOCK)
                        JOIN dbo.PackDetail PD WITH (NOLOCK) ON (PH.PickSlipNo = PD.PickSlipNo)
                     WHERE PD.StorerKey = @cStorerKey
                        AND PD.LabelNo = @cLabelNo
                     ORDER BY PH.PickslipNo Desc -- (ChewKP04)

                  -- Check ID valid
                  IF @cPickSlipNo = ''
                  BEGIN
                     SET @nErrNo = 264556
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --BAD LBNo/DrpID
                     GOTO Scn_6869_Fail
                  END

                  -- Check pack confirm
                  IF @cBypassPackConfirmCheck <> '1'
                  BEGIN
                     -- (Shong01)
                     IF @cAutoScanOutPS = '1'
                     BEGIN
                        IF EXISTS (SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Status < '5')
                        BEGIN

                           -- If Exist PickDetail.Status = 0 do not allow auto PackConfirm (ChewKP03)
                           IF NOT EXISTS ( SELECT 1 FROM dbo.PickDetail WITH (NOLOCK)
                                          WHERE StorerKey = @cStorerKey
                                          AND PickSlipNo = @cPickSlipNo
                                          AND Status <> '5' )
                           BEGIN

                              SET @nQtyPacked = 0

                              SELECT @nQtyPacked = SUM(Qty)
                              FROM   dbo.PackDetail pd WITH (NOLOCK)
                              WHERE  pd.PickSlipNo = @cPickSlipNo

                              SET @nQtyPicked = 0
                              SELECT @nQtyPicked = SUM(Qty)
                              FROM   dbo.PICKDETAIL p WITH (NOLOCK)
                              WHERE  p.PickSlipNo = @cPickSlipNo
                              AND    p.[Status] = '5'


                              IF @nQtyPacked = @nQtyPicked
                              BEGIN
                                 BEGIN TRY
                                    UPDATE dbo.PackHeader WITH (ROWLOCK)
                                       SET [Status] ='9'
                                    WHERE PickSlipNo = @cPickSlipNo
                                    AND   STATUS <> '9'
                                 END TRY
                                 BEGIN CATCH
                                    SET @nErrNo = 264585
                                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                                    GOTO Scn_6869_Fail
                                 END CATCH
                              END

                           END
                        END
                     END

                     IF EXISTS (SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Status < '5') -- (ChewKP02)
                     BEGIN
                        SET @nErrNo = 264557
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NotPackConfirm
                        GOTO Scn_6869_Fail
                     END
                  END
               END

               -- Check order cancel
               IF @cPickDetailOrderKey <> '' OR
                  @cPackHeaderOrderKey <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.Orders WITH (NOLOCK) WHERE OrderKey IN (@cPickDetailOrderKey, @cPackHeaderOrderKey) AND SOStatus = 'CANC')
                  BEGIN
                     SET @nErrNo = 264569
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Order CANCEL
                     GOTO Scn_6869_Fail
                  END
               END

               -- MBOL
               IF @cType IN ('M', 'R') AND @cByPassCheckIDinMBOL <> '1'
               BEGIN
                  -- PickDetail
                  IF @cCheckPickDetailDropID = '1'
                  BEGIN
                     -- Check ID in MBOL
                     IF NOT EXISTS( SELECT 1
                        FROM dbo.MBOLDetail MD WITH (NOLOCK)
                        WHERE MD.MbolKey = @cMBOLKey
                           AND EXISTS( SELECT 1 FROM dbo.PickDetail PD WITH (NOLOCK) 
                                       WHERE PD.OrderKey = MD.OrderKey AND PD.DropID = @cLabelNo AND Status = '5'))
                     BEGIN
                        SET @nErrNo = 264558
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID NotInMBOL
                        GOTO Scn_6869_Fail
                     END
                  END
                  ELSE
                  BEGIN
                     -- PackDetail
                     IF @cPackHeaderOrderKey <> ''
                     BEGIN
                        IF NOT EXISTS( SELECT 1 FROM dbo.MBOLDetail WITH (NOLOCK) WHERE MbolKey = @cMBOLKey AND OrderKey = @cPackHeaderOrderKey)
                        BEGIN
                        SET @nErrNo = 264559
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID NotInMBOL
                           GOTO Scn_6869_Fail
                        END
                     END
                     ELSE IF @cPackHeaderLoadKey <> ''
                     BEGIN
                        IF NOT EXISTS( SELECT 1
                           FROM dbo.MBOLDetail MD WITH (NOLOCK)
                           WHERE MD.MbolKey = @cMBOLKey
                              AND EXISTS( SELECT 1
                                 FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                                 WHERE LPD.LoadKey = @cPackHeaderLoadKey
                                    AND MD.OrderKey = LPD.OrderKey))
                        BEGIN
                           SET @nErrNo = 264560
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID NotInMBOL
                           GOTO Scn_6869_Fail
                        END
                     END
                  END
               END

               -- Load
               IF @cType = 'L'
               BEGIN
                  -- PickDetail
                  IF @cCheckPickDetailDropID = '1'
                  BEGIN
                     -- Check ID in Load
                     IF NOT EXISTS( SELECT 1
                        FROM dbo.ORDERS O WITH (NOLOCK)
                           JOIN dbo.PickDetail PD WITH (NOLOCK) ON (O.OrderKey = PD.OrderKey)
                        WHERE O.LoadKey = @cLoadKey
                           AND PD.DropID = @cLabelNo
                           AND PD.Status = '5')
                     BEGIN
                        SET @nErrNo = 264561
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID NotInLoad
                        GOTO Scn_6869_Fail
                     END
                  END
                  ELSE
                  BEGIN
                     -- PackDetail
                     IF @cPackHeaderOrderKey <> ''
                     BEGIN
                        IF NOT EXISTS( SELECT 1 FROM dbo.LoadPlanDetail WITH (NOLOCK) WHERE LoadKey = @cLoadKey AND OrderKey = @cPackHeaderOrderKey)
                        BEGIN
                           SET @nErrNo = 264562
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID NotInLoad
                           GOTO Scn_6869_Fail
                        END
                     END
                     ELSE IF @cPackHeaderLoadKey <> ''
                     BEGIN
                        IF @cPackHeaderLoadKey <> @cLoadKey
                        BEGIN
                           SET @nErrNo = 264563
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID NotInLoad
                           GOTO Scn_6869_Fail
                        END
                     END
                  END

                  -- Check MBOL created (except conso packing, where ID could belong to multiple orders, populate to different mbol)
                  IF @cPickDetailOrderKey <> '' OR
                     @cPackHeaderOrderKey <> ''
                  BEGIN
                     -- Get MBOL info
                     SET @cMBOLKey = ''
                     SELECT @cMBOLKey = MBOLKey FROM dbo.MBOLDetail WITH (NOLOCK) WHERE OrderKey IN (@cPickDetailOrderKey, @cPackHeaderOrderKey)

                     -- Check populated to MBOL
                     IF @cMBOLKey = ''
                     BEGIN
                        SET @nErrNo = 264551
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Load Not MBOL
                        GOTO Scn_6869_Fail
                     END
                  END
               END

               -- Order
               IF @cType = 'O'
               BEGIN
                  -- PickDetail
                  IF @cCheckPickDetailDropID = '1'
                  BEGIN
                     -- Check ID in Order
                     IF NOT EXISTS( SELECT 1 FROM dbo.PickDetail WITH (NOLOCK) WHERE OrderKey = @cOrderKey AND DropID = @cLabelNo AND Status = '5')
                     BEGIN
                        SET @nErrNo = 264564
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID NotInOrder
                        GOTO Scn_6869_Fail
                     END
                  END
                  ELSE
                  BEGIN
                     -- PackDetail
                     IF @cPackHeaderOrderKey <> ''
                     BEGIN
                        IF @cPackHeaderOrderKey <> @cOrderKey
                        BEGIN
                           SET @nErrNo = 264565
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID NotInOrder
                           GOTO Scn_6869_Fail
                        END
                     END
                     ELSE IF @cPackHeaderLoadKey <> ''
                     BEGIN
                        IF NOT EXISTS( SELECT 1
                           FROM dbo.LoadPlanDetail WITH (NOLOCK)
                           WHERE LoadKey = @cPackHeaderLoadKey
                              AND OrderKey = @cOrderKey)
                        BEGIN
                           SET @nErrNo = 264566
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID NotInOrder
                           GOTO Scn_6869_Fail
                        END
                     END
                  END
               END

               -- Extended validate
               IF @cExtendedValidateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cType, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo, ' +
                        ' @cPackInfo, @cWeight, @cCube, @cCartonType, @cDoor, @cRefNo, @nErrNo OUTPUT, @cErrMsg OUTPUT '
                     SET @cSQLParam =
                        '@nMobile     INT,           ' +
                        '@nFunc       INT,           ' +
                        '@cLangCode   NVARCHAR( 3),  ' +
                        '@nStep       INT,           ' +
                        '@nInputKey   INT,           ' +
                        '@cStorerKey  NVARCHAR( 15), ' +
                        '@cType       NVARCHAR( 1),  ' +
                        '@cMBOLKey    NVARCHAR( 10), ' +
                        '@cLoadKey    NVARCHAR( 10), ' +
                        '@cOrderKey   NVARCHAR( 10), ' +
                        '@cLabelNo    NVARCHAR( 20), ' +
                        '@cPackInfo   NVARCHAR( 3),  ' +
                        '@cWeight     NVARCHAR( 10), ' +
                        '@cCube       NVARCHAR( 10), ' +
                        '@cCartonType NVARCHAR( 10), ' +
                        '@cDoor       NVARCHAR( 10), ' +
                        '@cRefNo      NVARCHAR( 40), ' +
                        '@nErrNo      INT           OUTPUT, ' +
                        '@cErrMsg     NVARCHAR( 20) OUTPUT  '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cType, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo,
                        @cPackInfo, @cWeight, @cCube, @cCartonType, @cDoor, @cRefNo, @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                        GOTO Quit
                  END
               END

               -- Extended update
               IF @cExtendedUpdateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cType, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo, ' +
                        ' @cPackInfo, @cWeight, @cCube, @cCartonType, @cDoor, @cRefNo, @nErrNo OUTPUT, @cErrMsg OUTPUT '
                     SET @cSQLParam =
                        '@nMobile     INT,           ' +
                        '@nFunc       INT,           ' +
                        '@cLangCode   NVARCHAR( 3),  ' +
                        '@nStep       INT,           ' +
                        '@nInputKey   INT,           ' +
                        '@cStorerKey  NVARCHAR( 15), ' +
                        '@cType       NVARCHAR( 1),  ' +
                        '@cMBOLKey    NVARCHAR( 10), ' +
                        '@cLoadKey    NVARCHAR( 10), ' +
                        '@cOrderKey   NVARCHAR( 10), ' +
                        '@cLabelNo    NVARCHAR( 20), ' +
                        '@cPackInfo   NVARCHAR( 3),  ' +
                        '@cWeight     NVARCHAR( 10), ' +
                        '@cCube       NVARCHAR( 10), ' +
                        '@cCartonType NVARCHAR( 10), ' +
                        '@cDoor       NVARCHAR( 10), ' +
                        '@cRefNo      NVARCHAR( 40), ' +
                        '@nErrNo      INT           OUTPUT, ' +
                        '@cErrMsg     NVARCHAR( 20) OUTPUT  '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cType, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo,
                        @cPackInfo, @cWeight, @cCube, @cCartonType, @cDoor, @cRefNo, @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                        GOTO Quit
                  END
               END

               IF @cExtendedInfoSP <> ''  
               BEGIN  
                  IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedInfoSP AND type = 'P')  
                  BEGIN
                     SET @cExtendedInfo = ''
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +  
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cType, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo, ' +  
                        ' @cPackInfo, @cWeight, @cCube, @cCartonType, @cDoor, @cRefNo, ' + 
                        ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '  
                     SET @cSQLParam =  
                        '@nMobile         INT,           ' +  
                        '@nFunc           INT,           ' +  
                        '@cLangCode       NVARCHAR( 3),  ' +  
                        '@nStep           INT,           ' +  
                        '@nAfterStep      INT,           ' +  
                        '@nInputKey       INT,           ' +  
                        '@cFacility       NVARCHAR( 5),  ' +  
                        '@cStorerKey      NVARCHAR( 15), ' +  
                        '@cType           NVARCHAR( 1),  ' +  
                        '@cMBOLKey        NVARCHAR( 10), ' +  
                        '@cLoadKey        NVARCHAR( 10), ' +  
                        '@cOrderKey       NVARCHAR( 10), ' +  
                        '@cLabelNo        NVARCHAR( 20), ' +  
                        '@cPackInfo       NVARCHAR( 3),  ' +  
                        '@cWeight         NVARCHAR( 10), ' +  
                        '@cCube           NVARCHAR( 10), ' +  
                        '@cCartonType     NVARCHAR( 10), ' +  
                        '@cDoor           NVARCHAR( 10), ' +  
                        '@cRefNo          NVARCHAR( 40), ' +  
                        '@cExtendedInfo   NVARCHAR( 20) OUTPUT, ' +  
                        '@nErrNo          INT           OUTPUT, ' +  
                        '@cErrMsg         NVARCHAR( 20) OUTPUT  '  

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
                        @nMobile, @nFunc, @cLangCode, 1, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType, @cMBOLKey, @cLoadKey, @cOrderKey, @cLabelNo,  
                        @cPackInfo, @cWeight, @cCube, @cCartonType, @cDoor, @cRefNo, 
                        @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT  

                     SET @cOutField15 = @cExtendedInfo
                  END  
               END  

               EXEC rdt.rdt_922ExtScn01_UCC_GetStat @nMobile, @nFunc, @cLangCode, @cStorerKey,
                  @cType, 
                  @cMBOLKey, 
                  @cLoadKey, 
                  @cOrderKey, 
                  @cLabelNo,
                  @nScanUCC OUTPUT, 
                  @nTotalUCC OUTPUT, 
                  @nErrNo OUTPUT, 
                  @cErrMsg OUTPUT

               -- Prepare current screen var
               SET @cOutField01 = CASE WHEN @cType IN ('M', 'R') THEN @cMBOLKey  ELSE '' END
               SET @cOutField02 = CASE WHEN @cType = 'L' THEN @cLoadKey  ELSE '' END
               SET @cOutField03 = CASE WHEN @cType = 'O' THEN @cOrderKey ELSE '' END
               SET @cOutField04 = @cLabelNo
               SET @cMobBarcode = '' -- ID barcode
               SET @cOutField05 = ''
               SET @cOutField06 = TRY_CAST(ISNULL(@nScanUCC, 0) AS NVARCHAR(10))
               SET @cOutField07 = TRY_CAST(ISNULL(@nTotalUCC,0) AS NVARCHAR(10))
               
               SET @nAfterStep = 99 --UCC screen
               SET @nAfterScn = 6866
            END

            IF @nInputKey = 0 -- ESC
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'St99, Scn 6869, Esc'

               -- Get statistic
               EXEC rdt.rdt_ScanToTruck_ByLabelNo_GetStat @nMobile, @nFunc, @cLangCode, @cStorerKey
                  ,@cType
                  ,@cMBOLKey
                  ,@cLoadKey
                  ,@cOrderKey
                  ,@cDoor
                  ,@cRefNo
                  ,@cCheckPackDetailDropID
                  ,@cCheckPickDetailDropID
                  ,@nTotalCarton OUTPUT
                  ,@nScanCarton  OUTPUT
                  ,@nErrNo       OUTPUT
                  ,@cErrMsg      OUTPUT

               -- Print manifest
               /*
               IF @nTotalCarton = @nScanCarton AND @cManifestReport <> ''
               BEGIN
                  -- Go to print manifest screen
                  SET @cOutField01 = '' -- Option

                  SET @nScn  = @nScn + 3
                  SET @nStep = @nStep + 3

                  GOTO Quit
               END*/

               IF @nTotalCarton <> @nScanCarton
               BEGIN
                  SET @nErrNo = 264568
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NotAllScanned
                  EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg
                  SET @nErrNo = 0
                  SET @cErrMsg = ''
               END

               -- Prepare prev screen var
               SET @cOutField01 = ''
               SET @cOutField02 = ''
               SET @cOutField03 = ''
               SET @cOutField04 = ''

               IF @cType = 'M' EXEC rdt.rdtSetFocusField @nMobile, 1
               IF @cType = 'L' EXEC rdt.rdtSetFocusField @nMobile, 2
               IF @cType = 'O' EXEC rdt.rdtSetFocusField @nMobile, 3
               IF @cType = 'R' EXEC rdt.rdtSetFocusField @nMobile, 4

               SET @nAfterScn = 3430
               SET @nAfterStep = 1
            END
            GOTO Quit

            Scn_6869_Fail:
            BEGIN
               SET @cLabelNo = ''
               SET @cOutField04 = ''
               SET @cMobBarcode = ''

               GOTO Quit
            END
         END -- 6869

         /********************************************************************************
         Screen 6866
            MBOLKey         (Field01)
            LoadKey         (Field02)
            OrderKey        (Field03)
            DropID          (Field04)
            UCC             (Field05, input)
            SCANNED         (Field06)
            TOTAL           (Field07)
         ********************************************************************************/
         IF @nScn = 6866
         BEGIN
            IF @nInputKey = 1
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'St99, Scn6866, Enter'

               SET @cUCCNo = ISNULL(@cInField05,'')
               SET @cOrderLineNumber = ''
               SET @nRowCount = 0
               SET @nScanUCC = 0
               SET @nTotalUCC = 0
               
               IF @cUCCNo = ''
               BEGIN
                  SET @nErrNo = 264570
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC Required
                  GOTO Scn_6866_Fail
               END

               SELECT @cUCCStatus = Status
               FROM dbo.UCC WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND UCCNo = @cUCCNo
                  AND ID = @cLabelNo
               
               SET @nRowCount = @@ROWCOUNT

               IF @nRowCount = 0
               BEGIN
                  SET @nErrNo = 264571
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid UCC
                  GOTO Scn_6866_Fail
               END

               IF @cUCCStatus = '5'
               BEGIN
                  SET @nErrNo = 264572
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --already scanned
                  GOTO Scn_6866_Fail
               END

               IF @cUCCStatus <> '1'
               BEGIN
                  SET @nErrNo = 264573
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid UCC Status
                  GOTO Scn_6866_Fail
               END

               EXEC rdt.rdt_922ExtScn01_UCC_GetStat @nMobile, @nFunc, @cLangCode, @cStorerKey,
                  @cType, 
                  @cMBOLKey, 
                  @cLoadKey, 
                  @cOrderKey, 
                  @cLabelNo,
                  @nScanUCC   OUTPUT, 
                  @nTotalUCC  OUTPUT, 
                  @nErrNo     OUTPUT, 
                  @cErrMsg    OUTPUT

               IF @nScanUCC + 1 > @nTotalUCC
               BEGIN
                  SET @nErrNo = 264576
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Exceed qty
                  GOTO Scn_6866_Fail
               END

               SELECT TOP 1 
                  @cOrderLineNumber = PD.OrderLineNumber,
                  @cPickDetailKey = PD.PickDetailKey
               FROM dbo.UCC WITH (NOLOCK)
               JOIN dbo.PICKDETAIL PD WITH (NOLOCK, INDEX(IDX_PICKDETAIL_DropID))
                  ON PD.Storerkey = UCC.Storerkey
                     AND PD.DropID = UCC.Id
                     AND PD.Lot = UCC.Lot
               WHERE UCC.UCCNo = @cUCCNo
                  AND UCC.StorerKey = @cStorerKey
                  AND PD.OrderKey = @cOrderKey
                  AND PD.DropID = @cLabelNo

               IF @nDebugFlag = 1
                  SELECT 'Handling scanned UCC', @cUCCNo AS UCC, @nScanUCC+1 AS ScanedUCC, @nTotalUCC AS TotalUCC

               SET @nTranCount = @@TRANCOUNT
               BEGIN TRAN
               SAVE TRAN rdt_922ExtScn01_6866

               BEGIN TRY
                  UPDATE dbo.UCC WITH(ROWLOCK) SET
                     Status = '5',
                     OrderKey = ISNULL(@cOrderKey, ''),
                     OrderLineNumber = ISNULL(@cOrderLineNumber, ''),
                     PickDetailKey = ISNULL(@cPickDetailKey, '')
                     --UserDefined02 = ISNULL(@cDoor, '') --V1.0.2
                  WHERE StorerKey = @cStorerKey
                     AND UCCNo = @cUCCNo
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 264574
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd UCC Fail
                  GOTO Scn_6866_Rollback
               END CATCH

               --V1.0.1 insert ScanToTruck when 1st UCC scanned. Set status to 9 when last UCC scanned
               IF @nDebugFlag = 1
                     SELECT 'Handling scanned dropID', @cUCCNo AS UCC, @nScanUCC AS ScannedUCC, @nTotalUCC AS TotalUCC

               SET @nRowRef = 0

               SELECT @nRowRef = RowRef
               FROM rdt.rdtScanToTruck WITH (NOLOCK)
               WHERE MBOLKey = @cMBOLKey
                  AND OrderKey = @cOrderKey
                  AND RefNo = @cLabelNo

               IF @nScanUCC = 0 -- 1st UCC scanned
               BEGIN
                  IF @nDebugFlag = 1
                     SELECT '1st scanned dropID', @cUCCNo AS UCC

                  IF @nRowRef = 0
                  BEGIN
                     BEGIN TRY
                        INSERT INTO rdt.rdtScanToTruck
                           (MBOLKey, LoadKey, OrderKey, URNNo, Door, RefNo, Status, CartonType, AddWho, AddDate, EditWho, EditDate)
                        VALUES
                           (@cMBOLKey, @cLoadKey, @cOrderKey, '', '', @cLabelNo, '0', '', SUSER_NAME(), GETDATE(), SUSER_NAME(), GETDATE())

                        SET @nRowRef = SCOPE_IDENTITY()
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 264567
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --INS Truck Fail
                        GOTO Scn_6866_Rollback
                     END CATCH
                  END
                  ELSE
                  BEGIN
                     BEGIN TRY
                        UPDATE rdt.rdtScanToTruck WITH (ROWLOCK) SET
                           Status = '0',
                           --Door = @cDoor, --V1.0.2
                           RefNo = @cLabelNo,
                           --CartonType = @cRefNo, --V1.0.2
                           EditWho = SUSER_NAME(),
                           EditDate = GETDATE()
                        WHERE RowRef = @nRowRef
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 264584
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --UPD Truck Fail
                        GOTO Scn_6866_Rollback
                     END CATCH
                  END
               END

               IF ISNULL(@nScanUCC,0) + 1 = ISNULL(@nTotalUCC,0) 
               BEGIN
                  SET @nROWCOUNT = 0
                  BEGIN TRY
                     UPDATE rdt.rdtScanToTruck WITH (ROWLOCK) SET
                        Status = '9',
                        --Door = @cDoor, --V1.0.2
                        --CartonType = @cRefNo, --V1.0.2
                        EditWho = @cUserName,
                        EditDate = GETDATE()
                     WHERE RowRef = @nRowRef

                     SET @nROWCOUNT = @@ROWCOUNT
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 264575
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --UPD Truck Fail
                     GOTO Scn_6866_Rollback
                  END CATCH

                  IF @nROWCOUNT = 0
                  BEGIN
                     SET @nErrNo = 264583
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Failed to close the pallet
                     GOTO Scn_6866_Rollback
                  END
                  --ToDo still other requirements to do   
               END -- all ucc scanned

               -- EventLog
               EXEC RDT.rdt_STD_EventLog
                  @cActionType = '4', -- Move
                  @cUserID     = @cUserName,
                  @nMobileNo   = @nMobile,
                  @nFunctionID = @nFunc,
                  @cFacility   = @cFacility,
                  @cStorerKey  = @cStorerkey,
                  @cDropID     = @cLabelNo,
                  @cLoadKey    = @cLoadKey,
                  @cOrderKey   = @cOrderKey,
                  @cRefNo1     = @cMBOLKey

               EXEC rdt.rdt_ScanToTruck_ByLabelNo_GetStat @nMobile, @nFunc, @cLangCode, @cStorerKey
                  ,@cType
                  ,@cMBOLKey
                  ,@cLoadKey
                  ,@cOrderKey
                  ,@cDoor
                  ,@cRefNo
                  ,@cCheckPackDetailDropID
                  ,@cCheckPickDetailDropID
                  ,@nTotalCarton OUTPUT
                  ,@nScanCarton  OUTPUT
                  ,@nErrNo       OUTPUT
                  ,@cErrMsg      OUTPUT

               IF @nTotalCarton = @nScanCarton
               BEGIN
                  IF @nDebugFlag = 1
                     SELECT 'Last pallet in order', @nTotalCarton AS TotalCarton, @nScanCarton AS nScanCarton

                  --SELECT @cSOStatus = SOStatus FROM dbo.Orders WITH (NOLOCK) WHERE OrderKey = @cOrderKey

                  SELECT @cMBOLLineNumber = MBOLLineNumber
                  FROM dbo.MbolDetail WITH (NOLOCK)
                  WHERE MbolKey = @cMbolKey
                     AND OrderKey = @cOrderKey

                  SET @fOrdTotalCube = 0
                  SET @fOrdTotalWeight = 0
                  SET @fOrdTotalQty = 0

                  SELECT 
                     @fOrdTotalCube    = SUM(ISNULL(TRY_CAST(la.lottable01 AS FLOAT),0) * pd.QTY),
                     @fOrdTotalWeight = SUM(ISNULL(TRY_CAST(la.lottable02 AS FLOAT),0) * pd.QTY),
                     @fOrdTotalQty     = SUM(pd.qty)
                  FROM dbo.PICKDETAIL pd WITH (NOLOCK)
                  LEFT JOIN dbo.LOTATTRIBUTE la WITH (NOLOCK)
                     ON pd.lot=la.lot
                  WHERE pd.StorerKey= @cStorerKey 
                     AND pd.OrderKey = @cOrderKey

                  /* --No need V1.0.1
                  IF @cSOStatus = 'UNLOAD'
                  BEGIN
                     BEGIN TRY
                        UPDATE dbo.ORDERS WITH (ROWLOCK) SET
                           SOStatus = '0'
                        WHERE OrderKey = @cOrderKey
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 264577
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd Order Fail
                        GOTO Scn_6866_Rollback
                     END CATCH
                  END*/

                  BEGIN TRY
                     UPDATE dbo.MBOLDetail WITH (ROWLOCK) SET
                        WEIGHT = @fOrdTotalWeight,
                        Cube = @fOrdTotalCube,
                        TotalCartons = @fordTotalQty
                     WHERE MbolKey = @cMBOLKey
                        AND MbolLineNumber = @cMBOLLineNumber
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 264578
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd MbolDetail Fail
                     GOTO Scn_6866_Rollback
                  END CATCH
               END

               COMMIT TRAN

               --Go to next screen
               IF ISNULL(@nScanUCC,0) + 1 = ISNULL(@nTotalUCC,0)
               BEGIN -- last pallet scanned
                  IF @nScanCarton = @nTotalCarton
                  BEGIN
                     -- back to st1
                     SET @cOutField01 = ''
                     SET @cOutField02 = ''
                     SET @cOutField03 = ''
                     SET @cOutField04 = ''

                     IF @cType = 'M' EXEC rdt.rdtSetFocusField @nMobile, 1
                     IF @cType = 'L' EXEC rdt.rdtSetFocusField @nMobile, 2
                     IF @cType = 'O' EXEC rdt.rdtSetFocusField @nMobile, 3
                     IF @cType = 'R' EXEC rdt.rdtSetFocusField @nMobile, 4

                     SET @nAfterScn = 3430
                     SET @nAfterStep = 1
                  END
                  ELSE -- not last pallet
                  BEGIN
                     -- Scan next drop id
                     SET @cOutField01 = CASE WHEN @cType IN ('M', 'R') THEN @cMBOLKey  ELSE '' END
                     SET @cOutField02 = CASE WHEN @cType = 'L' THEN @cLoadKey  ELSE '' END
                     SET @cOutField03 = CASE WHEN @cType = 'O' THEN @cOrderKey ELSE '' END
                     SET @cOutField04 = '' -- ID
                     SET @cMobBarcode = '' -- ID barcode
                     SET @cOutField05 = '' -- Last ID
                     SET @cOutField06 = TRY_CAST( @nScanCarton AS NVARCHAR( 10))
                     SET @cOutField07 = TRY_CAST( @nTotalCarton AS NVARCHAR( 10))
                     SET @cOutField08 = CASE WHEN @cType = 'R' THEN @cRefNum ELSE '' END

                     -- Go to next screen
                     SET @nAfterScn  = 6869
                     SET @nAfterStep = 99
                  END
               END
               ELSE
               BEGIN
                  -- stay at current ucc scan screen
                  SET @cOutField01 = CASE WHEN @cType IN ('M', 'R') THEN @cMBOLKey  ELSE '' END
                  SET @cOutField02 = CASE WHEN @cType = 'L' THEN @cLoadKey  ELSE '' END
                  SET @cOutField03 = CASE WHEN @cType = 'O' THEN @cOrderKey ELSE '' END
                  SET @cOutField04 = @cLabelNo
                  SET @cMobBarcode = '' -- UCC barcode
                  SET @cOutField05 = ''
                  SET @cOutField06 = TRY_CAST(ISNULL(@nScanUCC + 1, 0) AS NVARCHAR(10))
                  SET @cOutField07 = TRY_CAST(ISNULL(@nTotalUCC,0) AS NVARCHAR(10))
               END

            END --Enter

            IF @nInputKey = 0 -- ESC
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'St99, Scn 6866, Esc'

               EXEC rdt.rdt_922ExtScn01_UCC_GetStat @nMobile, @nFunc, @cLangCode, @cStorerKey,
                  @cType, 
                  @cMBOLKey, 
                  @cLoadKey, 
                  @cOrderKey, 
                  @cLabelNo,
                  @nScanUCC OUTPUT, 
                  @nTotalUCC OUTPUT, 
                  @nErrNo OUTPUT, 
                  @cErrMsg OUTPUT

               IF ISNULL(@nScanUCC,0) = ISNULL(@nTotalUCC,0)
               BEGIN
                  -- Get statistic
                  EXEC rdt.rdt_ScanToTruck_ByLabelNo_GetStat @nMobile, @nFunc, @cLangCode, @cStorerKey
                     ,@cType
                     ,@cMBOLKey
                     ,@cLoadKey
                     ,@cOrderKey
                     ,@cDoor
                     ,@cRefNo
                     ,@cCheckPackDetailDropID
                     ,@cCheckPickDetailDropID
                     ,@nTotalCarton OUTPUT
                     ,@nScanCarton  OUTPUT
                     ,@nErrNo       OUTPUT
                     ,@cErrMsg      OUTPUT
   
                  -- Prep next screen var
                  SET @cOutField01 = CASE WHEN @cType IN ('M', 'R') THEN @cMBOLKey  ELSE '' END
                  SET @cOutField02 = CASE WHEN @cType = 'L' THEN @cLoadKey  ELSE '' END
                  SET @cOutField03 = CASE WHEN @cType = 'O' THEN @cOrderKey ELSE '' END
                  SET @cOutField04 = '' -- ID
                  SET @cMobBarcode = '' -- ID barcode
                  SET @cOutField05 = '' -- Last ID
                  SET @cOutField06 = CAST( @nScanCarton AS NVARCHAR( 10))
                  SET @cOutField07 = CAST( @nTotalCarton AS NVARCHAR( 10))
                  SET @cOutField08 = CASE WHEN @cType = 'R' THEN @cRefNum ELSE '' END

                  -- Go to pallet screen
                  SET @nAfterScn  = 6869
                  SET @nAfterStep = 99
               END
               ELSE
               BEGIN
                  SET @cOutField01 = @cLabelNo
                  SET @cOutField02 = TRY_CAST(ISNULL(@nScanUCC, 0) AS NVARCHAR(10))
                  SET @cOutField03 = TRY_CAST(ISNULL(@nTotalUCC, 0) AS NVARCHAR(10))
                  SET @cOutField04 = ''

                  --Continue scan UCC scn
                  SET @nAfterScn = 6868
                  SET @nAfterStep = 99
               END
            END-- ESC
            GOTO Quit

            Scn_6866_Rollback:
            BEGIN
               IF XACT_STATE() = -1
                  ROLLBACK TRAN 
               ELSE IF @nTranCount > 0
                  ROLLBACK TRAN rdt_922ExtScn01_6866
               ELSE
                  ROLLBACK TRAN

               GOTO Scn_6866_Fail
            END

            Scn_6866_Fail:
               SET @cOutField05 = ''
               SET @cUCCNo = ''
               GOTO Quit
         END--6866 scan ucc

         /********************************************************************************
         Screen 6868
            Mismatch messsage
            ID               (Field01)
            Scanned Qty      (Field02)
            Total Qty        (Field03)
            1= Yes, 9= No    (Field04, input)
         ********************************************************************************/
         IF @nScn = 6868
         BEGIN
            IF @nInputKey = 1
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'St99, Scn6868, Enter'

               SET @cOption = @cInField04

               IF ISNULL(@cOption, '') = ''
               BEGIN
                  SET @nErrNo = 264579
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Option Required
                  GOTO Quit
               END

               IF ISNULL(@cOption, '') NOT IN ('1', '9')
               BEGIN
                  SET @nErrNo = 264580
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option
                  GOTO Quit
               END

               IF @cOption = '1' -- continue to scan ucc
               BEGIN
                  EXEC rdt.rdt_922ExtScn01_UCC_GetStat @nMobile, @nFunc, @cLangCode, @cStorerKey,
                     @cType, 
                     @cMBOLKey, 
                     @cLoadKey, 
                     @cOrderKey, 
                     @cLabelNo,
                     @nScanUCC OUTPUT, 
                     @nTotalUCC OUTPUT, 
                     @nErrNo OUTPUT, 
                     @cErrMsg OUTPUT

                  -- stay at current ucc scan screen
                  SET @cOutField01 = CASE WHEN @cType IN ('M', 'R') THEN @cMBOLKey  ELSE '' END
                  SET @cOutField02 = CASE WHEN @cType = 'L' THEN @cLoadKey  ELSE '' END
                  SET @cOutField03 = CASE WHEN @cType = 'O' THEN @cOrderKey ELSE '' END
                  SET @cOutField04 = @cLabelNo
                  SET @cMobBarcode = '' -- ID barcode
                  SET @cOutField05 = ''
                  SET @cOutField06 = TRY_CAST(ISNULL(@nScanUCC, 0) AS NVARCHAR(10))
                  SET @cOutField07 = TRY_CAST(ISNULL(@nTotalUCC,0) AS NVARCHAR(10))

                  SET @nAfterStep = 99
                  SET @nAfterScn = 6866
               END -- yes
               ELSE IF @cOPtion = '9' --back to scan pallet screen
               BEGIN
                  --Go to scan pallet screen
                  EXEC rdt.rdt_ScanToTruck_ByLabelNo_GetStat @nMobile, @nFunc, @cLangCode, @cStorerKey
                     ,@cType
                     ,@cMBOLKey
                     ,@cLoadKey
                     ,@cOrderKey
                     ,@cDoor
                     ,@cRefNo
                     ,@cCheckPackDetailDropID
                     ,@cCheckPickDetailDropID
                     ,@nTotalCarton OUTPUT
                     ,@nScanCarton  OUTPUT
                     ,@nErrNo       OUTPUT
                     ,@cErrMsg      OUTPUT

                  SET @cOutField01 = CASE WHEN @cType IN ('M', 'R') THEN @cMBOLKey  ELSE '' END
                  SET @cOutField02 = CASE WHEN @cType = 'L' THEN @cLoadKey  ELSE '' END
                  SET @cOutField03 = CASE WHEN @cType = 'O' THEN @cOrderKey ELSE '' END
                  SET @cOutField04 = '' -- ID
                  SET @cMobBarcode = '' -- ID barcode
                  SET @cOutField05 = '' -- Last ID
                  SET @cOutField06 = TRY_CAST( @nScanCarton AS NVARCHAR( 10))
                  SET @cOutField07 = TRY_CAST( @nTotalCarton AS NVARCHAR( 10))
                  SET @cOutField08 = CASE WHEN @cType = 'R' THEN @cRefNum ELSE '' END

                  -- Go to next screen
                  SET @nAfterScn  = 6869
                  SET @nAfterStep = 99
               END
            END -- Enter

            IF @nInputKey = 0
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'St99, Scn6868, Esc'

               EXEC rdt.rdt_922ExtScn01_UCC_GetStat @nMobile, @nFunc, @cLangCode, @cStorerKey,
                  @cType, 
                  @cMBOLKey, 
                  @cLoadKey, 
                  @cOrderKey, 
                  @cLabelNo,
                  @nScanUCC OUTPUT, 
                  @nTotalUCC OUTPUT, 
                  @nErrNo OUTPUT, 
                  @cErrMsg OUTPUT

               -- stay at current ucc scan screen
               SET @cOutField01 = CASE WHEN @cType IN ('M', 'R') THEN @cMBOLKey  ELSE '' END
               SET @cOutField02 = CASE WHEN @cType = 'L' THEN @cLoadKey  ELSE '' END
               SET @cOutField03 = CASE WHEN @cType = 'O' THEN @cOrderKey ELSE '' END
               SET @cOutField04 = @cLabelNo
               SET @cMobBarcode = '' -- ID barcode
               SET @cOutField05 = ''
               SET @cOutField06 = TRY_CAST(ISNULL(@nScanUCC, 0) AS NVARCHAR(10))
               SET @cOutField07 = TRY_CAST(ISNULL(@nTotalUCC,0) AS NVARCHAR(10))

               SET @nAfterStep = 99
               SET @nAfterScn = 6866
            END -- ESC
            GOTO Quit
         END -- 6868 ucc mismatch
      END --st 99
   END --922

   Quit:
   IF @nDebugFlag = 1
      SELECT 'Exit 922ExtScn01', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
      
   -- Only UPDATE C_StringXXX, because C_StringXXX is used for ExtScnSP
   /*
   UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
   SET
      C_String1 = @cIsB2CSingle,
      C_String2 = @cB2BUoM6Flag
   WHERE Mobile = @nMobile
   */

   -- No need to update RDTMOBREC in base SP if @cUDF01 = 'NO UPD RDTMOBREC'
   IF @cUDF01 = 'NO UPD RDTMOBREC'
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Update RDTMOBREC'

      UPDATE rdt.rdtMobRec WITH (ROWLOCK) SET
         EditDate = GETDATE(),
         ErrMsg = @cErrMsg,
         Func   = @nFunc,
         Step   = @nAfterStep,
         Scn    = @nAfterScn,

         V_CaseID   = @cLabelNo,
         V_PickSlipNo = @cPickSlipNo,
         V_Cartonno = @nCartonNo,
         V_Barcode  = @cMobBarcode,

         V_String1  = @cMBOLKey,
         V_String10 = @cPackInfo,
         V_String11 = @cWeight,
         V_String12 = @cCube,
         V_String13 = @cCartonType,
         V_String22 = @cExtendedInfo,

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
   END -- update MOBREC

END -- SP
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_922ExtScn01] TO NSQL
GO


