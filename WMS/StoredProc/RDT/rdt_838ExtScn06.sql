
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Store procedure: rdt_838ExtScn06                                        */
/* Copyright      : Maersk                                                 */
/* Customer       :                                                        */
/*                                                                         */
/*                                                                         */
/* Date        Rev    Author     Purposes                                  */
/* 2025-12-08  1.0.0  Dennis     FCR-8931 Create                           */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_838ExtScn06] (
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
   @nAction      INT,
   @nAfterScn    INT OUTPUT, @nAfterStep    INT OUTPUT,
   @nErrNo             INT            OUTPUT,
   @cErrMsg            NVARCHAR( 20)  OUTPUT,
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

   DECLARE
      @bSuccess       INT,
      @nRowCount      INT, --v7.5
      @cOption        NVARCHAR( 2),
      @cCurrLOC       NVARCHAR( 10),
      @cSQL           NVARCHAR( MAX),
      @cSQLParam      NVARCHAR( MAX),
      @cUCCNo         NVARCHAR( 20),
      @cType          NVARCHAR( 10),
      @cOrderKey      NVARCHAR( 10),
      @cPrintPackList NVARCHAR( 1),
      @cCustomID      NVARCHAR( 20),
      @nTotalUCC      INT,
      @cSerialNo      NVARCHAR( 30) = '',
      @cIsValSerialNo NVARCHAR( 1) = '0',  --TLE109
      @nSerialQTY     INT,
      @nMoreSNO       INT,
      @nBulkSNO       INT,
      @nBulkSNOQTY    INT,
      @tVar                VariableTable, 
      @tVarDisableQTYField VARIABLETABLE,
      @cBarcode               NVARCHAR( 60),
      @cBarcode2              NVARCHAR( 60),
      @cFromDropIDDecode      NVARCHAR( 20),
      @cToDropIDDecode        NVARCHAR( 20),
      @cUPC                   NVARCHAR( 30),
      @cQTY                   NVARCHAR( 5),
      @nDecodeQTY             INT,
      @cPackDtlDropID_Decode  NVARCHAR(20),
      @cSKUDataCapture        NVARCHAR(1),
      @cDataCapture           NVARCHAR(1),
      @cSkipChkPPKQTY         NVARCHAR(1) = '0',

      @cCstLabelSP NVARCHAR(30),
      @nCurrentStep INT,
      @nCurrentScn  INT,

      @nMenu            INT,
      @cFlowThruScreen  NVARCHAR( 1), 

      @cUserName        NVARCHAR( 18),
      @cPaperPrinter    NVARCHAR( 10),
      @cLabelPrinter    NVARCHAR( 10),
      @cMobBarcode      NVARCHAR( MAX),    
      @cPickSlipNo      NVARCHAR( 10),
      @cSKU             NVARCHAR( 20),
      @nQTY             INT,
      @cSKUDescr        NVARCHAR( 60),
      @nFromScn         INT,
      @nFromStep        INT,

      @cPackDtlRefNo    NVARCHAR( 20),
      @cPackDtlRefNo2   NVARCHAR( 20),
      @cLabelNo         NVARCHAR( 20),
      @cCartonType      NVARCHAR( 10),
      @cCube            NVARCHAR( 10),
      @cWeight          NVARCHAR( 10),
      @cRefNo           NVARCHAR( 20),
      @cLabelLine       NVARCHAR( 5),
      @cPackDtlDropID   NVARCHAR( 20),
      @cUCCCounter      NVARCHAR( 5),
                        
      @nCartonNo        INT,
      @nCartonSKU       INT,
      @nCartonQTY       INT,
      @nTotalCarton     INT,
      @nTotalPick       INT,
      @nTotalPack       INT,
      @nTotalShort      INT,
      @nPackedQTY       INT,
      @nEnter           INT, --(cc01)

      @cDefaultPrintLabelOption     NVARCHAR( 1),
      @cDefaultPrintPackListOption  NVARCHAR( 1),
      @cDefaultWeight      NVARCHAR( 1),
      @cFromDropID         NVARCHAR( 20),
      @cExtendedValidateSP NVARCHAR( 20),
      @cExtendedUpdateSP   NVARCHAR( 20),
      @cExtendedInfoSP     NVARCHAR( 20),
      @cExtendedInfo       NVARCHAR( 20),
      @cDecodeSP           NVARCHAR( 20),
      @cDisableQTYField    NVARCHAR( 1),
      @cCapturePackInfoSP  NVARCHAR( 20),
      @cPackInfo           NVARCHAR( 10),
      @cAllowWeightZero    NVARCHAR( 1),
      @cAllowCubeZero      NVARCHAR( 1),
      @cAutoScanIn         NVARCHAR( 1),
      @cDefaultOption      NVARCHAR( 1),
      @cDisableOption      NVARCHAR( 10),    -- ZG01
      @cSerialNoCapture    NVARCHAR( 1),
      @cPackList           NVARCHAR( 10),
      @cShipLabel          NVARCHAR( 10),
      @cCartonManifest     NVARCHAR( 10),
      @cCustomCartonNo     NVARCHAR( 1),
      @cCustomNo           NVARCHAR( 5),
      @cDataCaptureSP      NVARCHAR( 20),
      @cPackDtlUPC         NVARCHAR( 30),
      @cPrePackIndicator   NVARCHAR( 30),
      @cPackQtyIndicator   NVARCHAR( 3),
      @cPackData1          NVARCHAR( 30),
      @cPackData2          NVARCHAR( 30),
      @cPackData3          NVARCHAR( 30),
      @cPackLabel1         NVARCHAR( 20),
      @cPackLabel2         NVARCHAR( 20),
      @cPackLabel3         NVARCHAR( 20),
      @cPackAttr1          NVARCHAR( 1),
      @cPackAttr2          NVARCHAR( 1),
      @cPackAttr3          NVARCHAR( 1),
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
      @cShowPickSlipNo     NVARCHAR( 1),
      @cDisableQTYFieldSP  NVARCHAR(20),
      @cDefaultQTY         NVARCHAR( 1), --(cc01)
      @cLength             NVARCHAR( 10), -- (james20)
      @cWidth              NVARCHAR( 10), -- (james20)
      @cHeight             NVARCHAR( 10), -- (james20)
      @cAllowLengthZero    NVARCHAR( 1),  -- (james20)
      @cAllowWidthZero     NVARCHAR( 1),  -- (james20)
      @cAllowHeightZero    NVARCHAR( 1),  -- (james20)
      @cDefaultcartontype  NVARCHAR( 20),  --(yeekung01)
      @cExtendedScreenSP   NVARCHAR( 20), --(JHU151)
      @cJumpType           NVARCHAR( 10), --(JHU151) Forward/Back
      @cPackByFromDropID   NVARCHAR( 1),
      @cDefaultCursor      NVARCHAR( 2), --(v7.5)
      @nScan               INT
   DECLARE @nWeight FLOAT
   DECLARE @nCartonWeight FLOAT
   DECLARE @fCube FLOAT

   SELECT 
      @nCurrentStep = Step,
      @nCurrentScn  = Scn,
      @cUserName = UserName
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   SET @cUDF01 = ''
   SET @cUDF02 = ''

   SELECT
   @nFunc            = Func,
   @nInputKey        = InputKey,
   @nMenu            = Menu,
   @cLangCode        = Lang_code,

   @cFacility        = Facility,
   @cStorerKey       = StorerKey,
   @cUserName        = UserName,
   @cPaperPrinter    = Printer_Paper,
   @cLabelPrinter    = Printer,

   @cPickSlipNo      = V_PickSlipNo,
   @cSKU             = V_SKU,
   @nQTY             = V_QTY,
   @cSKUDescr        = V_SKUDescr,
   -- @cCustomID        = V_CaseID,
   @nFromScn         = V_FromScn,
   @nFromStep        = V_FromStep,
   @cPUOM            = V_UOM,
   @cMobBarcode      = V_Barcode,

   @cPackDtlRefNo       = V_String1,
   @cPackDtlRefNo2      = V_String2,
   @cLabelNo            = V_String3,
   @cCartonType         = V_String4,
   @cCube               = V_String5,
   @cWeight             = V_String6,
   @cRefNo              = V_String7,
   @cLabelLine          = V_String8,
   @cPackDtlDropID      = V_String9,
   @cUCCCounter         = V_String10,
   @cMUOM_Desc          = V_String11,
   @cPUOM_Desc          = V_String12,
   @cDisableQTYFieldSP  = V_String13,
   @cFlowThruScreen     = V_String14,

   @nCartonNo           = V_CartonNo,
   @nCartonSKU          = V_Integer1,
   @nCartonQTY          = V_Integer2,
   @nTotalCarton        = V_Integer3,
   @nTotalPick          = V_Integer4,
   @nTotalPack          = V_Integer5,
   @nTotalShort         = V_Integer6,
   @nPackedQTY          = V_Integer7,
   @nPUOM_Div           = V_Integer8,
   @nPQTY               = V_Integer9,
   @nMQTY               = V_Integer10,
   @nEnter              = V_Integer11,  --(cc01)  
   @nScan               = V_Integer12,

   @cShowPickSlipNo     = V_String15,
   @cDefaultPrintLabelOption    = V_String16,
   @cDefaultPrintPackListOption = V_String17,
   @cDefaultWeight      = V_String18,
   @cUCCNo              = V_String19,
   @cFromDropID         = V_String20,
   @cExtendedValidateSP = V_String21,
   @cExtendedUpdateSP   = V_String22,
   @cExtendedInfoSP     = V_String23,
   @cExtendedInfo       = V_String24,
   @cDecodeSP           = V_String25,
   @cDisableQTYField    = V_String26,
   @cCapturePackInfoSP  = V_String27,
   @cPackInfo           = V_String28,
   @cAllowWeightZero    = V_String29,
   @cAllowCubeZero      = V_String30,
   @cAutoScanIn         = V_String31,
   @cDefaultOption      = V_String32,
   @cDisableOption      = V_String33,
   @cSerialNoCapture    = V_String34,
   @cPackList           = V_String35,
   @cShipLabel          = V_String36,
   @cCartonManifest     = V_String37,
   @cCustomCartonNo     = V_String38,
   @cCustomNo           = V_String39,
   @cDataCaptureSP      = V_String40,
   @cPackDtlUPC         = V_String41,
   @cPrePackIndicator   = V_String42,
   @cPackQtyIndicator   = V_String43,
   @cPackData1          = V_String44,
   @cPackData2          = V_String45,
   @cPackData3          = V_String46,
   @cMultiSKUBarcode    = V_String47,
   @cDefaultQTY         = V_String48, --(cc01)
   @cDefaultcartontype  = V_String49,
   @cPackByFromDropID   = V_String50,
   @cDefaultCursor      = V_String51

   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 838
   BEGIN
      IF @nScn = 4652
      BEGIN
         SELECT TOP 1 @cOutField03 = CONCAT('CartonType:',CartonType) FROM PackInfo (NOLOCK) WHERE PICKSLIPNO = @cPickSlipNo
         GOTO QUIT
      END
      IF @nCurrentStep = 1 AND @nInputKey = 1
      BEGIN 
         SET @cPickSlipNo = @cInField01
         SET @cFromDropID = @cInField02

         SELECT TOP 1 @cMUOM = Uom,@cOrderKey = Orderkey
         FROM PickDetail (NOLOCK)
         WHERE DropID = @cFromDropID
         AND StorerKey = @cStorerKey
         AND Status <= '5'

         IF @cMUOM = '2'
         BEGIN
            SELECT @cOutField09 = CASE WHEN DocType='N' THEN '4' WHEN DocType='E' THEN '1' END FROM ORDERS (NOLOCK) WHERE OrderKey = @cOrderKey
         END
         ELSE IF @cMUOM = '6'
         BEGIN
            SELECT @cOutField09 = CASE WHEN DocType='N' THEN '1' WHEN DocType='E' THEN '2' END FROM ORDERS (NOLOCK) WHERE OrderKey = @cOrderKey
         END
      END
      IF @nCurrentStep = 8
      BEGIN
         IF @nStep = 4
         BEGIN
            SELECT @cOutField02 = SUM(PD.QTY * SKU.STDGROSSWGT)
            FROM dbo.PackDetail PD WITH (NOLOCK)
            JOIN dbo.SKU SKU WITH (NOLOCK) ON (SKU.StorerKey = PD.StorerKey AND SKU.SKU = PD.SKU)
            WHERE PickSlipNo = @cPickSlipNo
               AND CartonNo  = @nCartonNo
            GROUP BY PD.PickSlipNo, PD.CartonNo

            SELECT
               @cOutField05 = LengthUOM1,
               @cOutField06 = WidthUOM1,
               @cOutField07 = HeightUOM1
            FROM dbo.PackInfo PI WITH (NOLOCK)
            JOIN dbo.UCC UCC (NOLOCK) ON UCC.UCCNo = PI.UCCNo AND UCC.StorerKey = @cStorerKey
            JOIN dbo.SKU SKU (NOLOCK) ON SKU.SKU = UCC.SKU AND SKU.StorerKey = @cStorerKey
            JOIN dbo.Pack P (NOLOCK) ON P.PackKey = SKU.PackKey
            WHERE PI.PickSlipNo = @cPickSlipNo
               AND PI.CartonNo  = @nCartonNo

            SET @fCube = CAST(ISNULL(@cOutField05,0) as FLOAT) * CAST( ISNULL(@cOutField06,0) as FLOAT) * CAST( ISNULL(@cOutField07,0) as FLOAT)
            SET @cOutField03 = rdt.rdtFormatFloat( @fCube)

            SET @nAfterStep = 99
            GOTO QUIT
         END
      END
      IF @nCurrentStep = 3
      BEGIN
         IF @nStep = 4
         BEGIN
            SELECT @cOutField02 = SUM(PD.QTY * SKU.STDGROSSWGT)
            FROM dbo.PackDetail PD WITH (NOLOCK)
            JOIN dbo.SKU SKU WITH (NOLOCK) ON (SKU.StorerKey = PD.StorerKey AND SKU.SKU = PD.SKU)
            WHERE PickSlipNo = @cPickSlipNo
               AND CartonNo  = @nCartonNo
            GROUP BY PD.PickSlipNo, PD.CartonNo

            SET @nAfterStep = 99
            GOTO QUIT
         END
         ELSE IF @nStep = 2
         BEGIN

            SELECT @cOrderKey = ORDERKEY
            FROM PickHeader (NOLOCK)
            WHERE PickHeaderKey = @cPickSlipNo

            SELECT TOP 1 @cMUOM = Uom
            FROM PickDetail (NOLOCK)
            WHERE DropID = @cFromDropID
            AND StorerKey = @cStorerKey
            AND Status <= '5'

            IF @cMUOM = '2'
            BEGIN
               SELECT @cOutField09 = CASE WHEN DocType='N' THEN '4' WHEN DocType='E' THEN '1' END FROM ORDERS (NOLOCK) WHERE OrderKey = @cOrderKey
            END
            ELSE IF @cMUOM = '6'
            BEGIN
               SELECT @cOutField09 = CASE WHEN DocType='N' THEN '1' WHEN DocType='E' THEN '2' END FROM ORDERS (NOLOCK) WHERE OrderKey = @cOrderKey
            END
         END
      END
      IF @nCurrentStep = 99
      BEGIN
         IF @nCurrentScn = 4653
         BEGIN
            IF @nInputKey = 1 -- ENTER
            BEGIN
               DECLARE @cChkCartonType NVARCHAR( 10)
               DECLARE @cChkCartonTypeBarcode NVARCHAR( 30) --(v7.5)

               -- (james02)
               -- Screen mapping
               SET @cChkCartonTypeBarcode = CASE WHEN @cFieldAttr01 = '' THEN @cInField01 ELSE @cOutField01 END --(v7.5)
               SET @cChkCartonType  = CASE WHEN @cFieldAttr01 = '' THEN @cInField01 ELSE @cOutField01 END
               SET @cWeight         = CASE WHEN @cFieldAttr02 = '' THEN @cInField02 ELSE @cOutField02 END
               SET @cCube           = CASE WHEN @cFieldAttr03 = '' THEN @cInField03 ELSE @cOutField03 END
               SET @cRefNo          = CASE WHEN @cFieldAttr04 = '' THEN @cInField04 ELSE @cOutField04 END
               SET @cLength         = CASE WHEN @cFieldAttr05 = '' THEN @cInField05 ELSE @cOutField05 END
               SET @cWidth          = CASE WHEN @cFieldAttr06 = '' THEN @cInField06 ELSE @cOutField06 END
               SET @cHeight         = CASE WHEN @cFieldAttr07 = '' THEN @cInField07 ELSE @cOutField07 END

               -- Carton type
               IF @cFieldAttr01 = ''
               BEGIN
                  -- Check blank
                  IF @cChkCartonType = ''
                  BEGIN
                     SET @nErrNo = 100210
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NeedCartonType
                     EXEC rdt.rdtSetFocusField @nMobile, 1
                     GOTO Quit 
                  END

                  -- Get default cube
                  DECLARE @nDefaultCube FLOAT
                  SELECT @nDefaultCube = [Cube]
                  FROM Cartonization WITH (NOLOCK)
                     INNER JOIN Storer WITH (NOLOCK) ON (Storer.CartonGroup = Cartonization.CartonizationGroup)
                  WHERE Storer.StorerKey = @cStorerKey
                     AND Cartonization.CartonType = @cChkCartonType

                  --(v7.5) start
                  SET @nRowCount = @@ROWCOUNT

                  IF @nRowCount = 0
                  BEGIN
                     SELECT
                        @cChkCartonType = CartonType,
                        @nDefaultCube = [Cube]
                     FROM Cartonization WITH (NOLOCK)
                        INNER JOIN Storer WITH (NOLOCK) ON (Storer.CartonGroup = Cartonization.CartonizationGroup)
                     WHERE Storer.StorerKey = @cStorerKey
                        AND Cartonization.Barcode = @cChkCartonTypeBarcode

                     SET @nRowCount = @@ROWCOUNT
                  END
                  --(v7.5) end

                  -- Check if valid
                  IF @nRowCount = 0 --(v7.5)
                  BEGIN
                     SET @nErrNo = 100211
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Bad CTN TYPE
                     EXEC rdt.rdtSetFocusField @nMobile, 1
                     GOTO Quit
                  END

                  -- Different carton type scanned
                  IF @cChkCartonType <> @cCartonType
                  BEGIN
                     SET @cCartonType = @cChkCartonType
                     --SET @cCube = rdt.rdtFormatFloat( @nDefaultCube)

                     SET @cOutField01 = @cCartonType
                  END
               END

               -- Weight
               IF @cFieldAttr02 = ''
               BEGIN
                  -- Check blank
                  IF @cWeight = ''
                  BEGIN
                     SET @nErrNo = 100214
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Weight
                     EXEC rdt.rdtSetFocusField @nMobile, 2
                     GOTO Quit
                  END

                  -- Check format    --(cc04)
                  IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'Weight', @cWeight) = 0
                  BEGIN
                     SET @nErrNo = 100246
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format
                     EXEC rdt.rdtSetFocusField @nMobile, 2
                     GOTO Quit
                  END

                  -- Check weight valid
                  IF @cAllowWeightZero = '1'
                     SET @nErrNo = rdt.rdtIsValidQty( @cWeight, 20)
                  ELSE
                     SET @nErrNo = rdt.rdtIsValidQty( @cWeight, 21)

                  IF @nErrNo = 0
                  BEGIN
                     SET @nErrNo = 100215
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid weight
                     EXEC rdt.rdtSetFocusField @nMobile, 2
                     SET @cOutField02 = ''
                     GOTO QUIT
                  END
                  SET @nErrNo = 0
                  SET @cOutField02 = @cWeight
               END

               -- Default weight
               ELSE IF @cDefaultWeight IN ('2', '3')
               BEGIN
                  -- Weight (SKU only)
                  SELECT @nWeight = ISNULL( SUM( SKU.STDGrossWGT * PD.QTY), 0)
                  FROM dbo.PackDetail PD WITH (NOLOCK)
                     JOIN dbo.SKU SKU WITH (NOLOCK) ON (SKU.StorerKey = PD.StorerKey AND SKU.SKU = PD.SKU)
                  WHERE PD.PickSlipNo = @cPickSlipNo
                     AND PD.CartonNo = @nCartonNo

                  -- Weight (SKU + carton)
                  IF @cDefaultWeight = '3'
                  BEGIN
                     -- Get carton type info
                     SELECT @nCartonWeight = CartonWeight
                     FROM Cartonization C WITH (NOLOCK)
                        JOIN Storer S WITH (NOLOCK) ON (C.CartonizationGroup = S.CartonGroup)
                     WHERE S.StorerKey = @cStorerKey
                        AND C.CartonType = @cCartonType

                     SET @nWeight = @nWeight + @nCartonWeight
                  END
                  SET @cWeight = rdt.rdtFormatFloat( @nWeight)
               END

               -- Cube
               IF @cFieldAttr03 = ''
               BEGIN
                  -- Check blank
                  IF @cCube = ''
                  BEGIN
                     SET @nErrNo = 100212
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Cube
                     EXEC rdt.rdtSetFocusField @nMobile, 3
                     GOTO Quit
                  END

                  -- Check cube valid
                  IF @cAllowCubeZero = '1'
                     SET @nErrNo = rdt.rdtIsValidQty( @cCube, 20)
                  ELSE
                     SET @nErrNo = rdt.rdtIsValidQty( @cCube, 21)

                  IF @nErrNo = 0
                  BEGIN
                     SET @nErrNo = 100213
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid cube
                     EXEC rdt.rdtSetFocusField @nMobile, 3
                     SET @cOutField03 =''
                     GOTO QUIT
                  END
                  SET @nErrNo = 0
                  SET @cOutField03 = @cCube
               END

               -- RefNo    --(cc01)
               IF @cFieldAttr04 = ''
               BEGIN
                  -- Check blank
                  IF @cRefNo = ''
                  BEGIN
                     SET @nErrNo = 100239
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need RefNo
                     EXEC rdt.rdtSetFocusField @nMobile, 4
                     GOTO Quit
                  END
                  SET @cOutField04 = @cRefNo
               END

               -- Length
               --IF @cFieldAttr04 = ''
               IF @cFieldAttr05 = ''   -- ZG03
               BEGIN
                  -- Check blank
                  IF @cLength = ''
                  BEGIN
                     SET @nErrNo = 100240
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Length
                     EXEC rdt.rdtSetFocusField @nMobile, 5
                     GOTO Quit
                  END

                  -- Check cube valid
                  IF @cAllowLengthZero = '1'
                     SET @nErrNo = rdt.rdtIsValidQty( @cLength, 20)
                  ELSE
                     SET @nErrNo = rdt.rdtIsValidQty( @cLength, 21)

                  IF @nErrNo = 0
                  BEGIN
                     SET @nErrNo = 100241
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Length
                     EXEC rdt.rdtSetFocusField @nMobile, 5
                     SET @cOutField05 = ''
                     GOTO QUIT
                  END
                  SET @nErrNo = 0
                  SET @cOutField05 = @cLength
               END

               -- Width
               --IF @cFieldAttr05 = ''
               IF @cFieldAttr06 = ''   -- ZG03
               BEGIN
                  -- Check blank
                  IF @cWidth = ''
                  BEGIN
                     SET @nErrNo = 100242
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Width
                     EXEC rdt.rdtSetFocusField @nMobile, 6
                     GOTO Quit
                  END

                  -- Check cube valid
                  IF @cAllowWidthZero = '1'
                     SET @nErrNo = rdt.rdtIsValidQty( @cWidth, 20)
                  ELSE
                     SET @nErrNo = rdt.rdtIsValidQty( @cWidth, 21)

                  IF @nErrNo = 0
                  BEGIN
                     SET @nErrNo = 100243
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Width
                     EXEC rdt.rdtSetFocusField @nMobile, 6
                     SET @cOutField06 = ''
                     GOTO QUIT
                  END
                  SET @nErrNo = 0
                  SET @cOutField06 = @cWidth
               END

               -- Height
               --IF @cFieldAttr06 = ''
               IF @cFieldAttr07 = ''   -- ZG03
               BEGIN
                  -- Check blank
                  IF @cHeight = ''
                  BEGIN
                     SET @nErrNo = 100244
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Height
                     EXEC rdt.rdtSetFocusField @nMobile, 7
                     GOTO Quit
                  END

                  -- Check cube valid
                  IF @cAllowHeightZero = '1'
                     SET @nErrNo = rdt.rdtIsValidQty( @cHeight, 20)
                  ELSE
                     SET @nErrNo = rdt.rdtIsValidQty( @cHeight, 21)

                  IF @nErrNo = 0
                  BEGIN
                     SET @nErrNo = 100245
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Height
                     EXEC rdt.rdtSetFocusField @nMobile, 7
                     SET @cOutField07 = ''
                     GOTO QUIT
                  END
                  SET @nErrNo = 0
                  SET @cOutField07 = @cHeight
               END

               -- Extended validate
               IF @cExtendedValidateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, ' +
                        ' @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption, ' +
                        ' @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, @cPackData1, @cPackData2, @cPackData3, ' +
                        ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
                     SET @cSQLParam =
                        '@nMobile         INT,           ' +
                        '@nFunc           INT,           ' +
                        '@cLangCode       NVARCHAR( 3),  ' +
                        '@nStep           INT,           ' +
                        '@nInputKey       INT,           ' +
                        '@cFacility       NVARCHAR( 5),  ' +
                        '@cStorerKey      NVARCHAR( 15), ' +
                        '@cPickSlipNo     NVARCHAR( 10), ' +
                        '@cFromDropID     NVARCHAR( 20), ' +
                        '@nCartonNo       INT,           ' +
                        '@cLabelNo        NVARCHAR( 20), ' +
                        '@cSKU            NVARCHAR( 20), ' +
                        '@nQTY            INT,           ' +
                        '@cUCCNo          NVARCHAR( 20), ' +
                        '@cCartonType     NVARCHAR( 10), ' +
                        '@cCube           NVARCHAR( 10), ' +
                        '@cWeight         NVARCHAR( 10), ' +
                        '@cRefNo          NVARCHAR( 20), ' +
                        '@cSerialNo       NVARCHAR( 30), ' +
                        '@nSerialQTY      INT,           ' +
                        '@cOption         NVARCHAR( 1),  ' +
                        '@cPackDtlRefNo   NVARCHAR( 20), ' +
                        '@cPackDtlRefNo2  NVARCHAR( 20), ' +
                        '@cPackDtlUPC     NVARCHAR( 30), ' +
                        '@cPackDtlDropID  NVARCHAR( 20), ' +
                        '@cPackData1      NVARCHAR( 30), ' +
                        '@cPackData2      NVARCHAR( 30), ' +
                        '@cPackData3      NVARCHAR( 30), ' +
                        '@nErrNo          INT            OUTPUT, ' +
                        '@cErrMsg         NVARCHAR( 1024)  OUTPUT'

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID,
                        @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption,
                        @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, @cPackData1, @cPackData2, @cPackData3,
                        @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                        GOTO Quit
                  END
               END

               DECLARE @fWeight FLOAT
               DECLARE @fCartonQty FLOAT --(cc02)
               SET @fCube = CAST( @cCube AS FLOAT)
               SET @fWeight = CAST( @cWeight AS FLOAT)

               SELECT @fCartonQty = SUM(qty) FROM packDetail WITH (NOLOCK) WHERE pickslipNo = @cPickSlipNo AND cartonNo = @nCartonNo AND storerKey = @cStorerKey --(cc02)

               SET @cUDF01 = @cCartonType
               SET @cUDF02 = @fCube
               SET @cUDF03 = @cRefNo
               SET @cUDF04 = @cLength

               -- PackInfo
               IF NOT EXISTS (SELECT 1 FROM dbo.PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo)
               BEGIN
                  SELECT @cLength = CartonLength, @cWidth = CartonWidth, @cHeight = CartonHeight
                  FROM Cartonization C WITH (NOLOCK)
                     JOIN Storer S WITH (NOLOCK) ON (C.CartonizationGroup = S.CartonGroup)
                  WHERE S.StorerKey = @cStorerKey
                     AND C.CartonType = @cCartonType

                  SET @fCube = CAST(@cLength as FLOAT) * CAST( @cWidth as FLOAT) * CAST( @cHeight as FLOAT)
                  SET @fCube = @fCube / 1000000

                  INSERT INTO dbo.PackInfo (PickslipNo, CartonNo, Qty, Weight, Cube, CartonType, RefNo, Length, Width, Height)
                  VALUES (@cPickSlipNo, @nCartonNo, @fCartonQty, @fWeight, @fCube, @cCartonType, @cRefNo, @cLength, @cWidth, @cHeight)  --(cc02)/(james20)
                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 100216
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPackInfFail
                     GOTO Quit
                  END
               END
               ELSE
               BEGIN
                  IF NOT EXISTS (SELECT 1 FROM PackInfo (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo AND CartonType = @cCartonType )
                  BEGIN
                     SET @cFieldAttr01 = '' 
                     SET @cFieldAttr02 = ''
                     SET @cFieldAttr03 = ''
                     SET @cFieldAttr04 = ''
                     SELECT @cOutField01 = CartonType FROM PackInfo (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo
                     SET @cOutField02 = @cCartonType
                     SET @cOutField03 = ''
                     SET @nAfterScn = 6708
                     SET @nAfterStep = 99
                     GOTO QUIT
                  END
                  UPDATE dbo.PackInfo SET
                     CartonType = @cCartonType,
                     Weight = @fWeight,
                     [Cube] = @fCube,
                     RefNo = @cRefNo,
                     Length = @cLength,   -- (james20)
                     Width = @cWidth,     -- (james20)
                     Height = @cHeight,    -- (james20)
                     Qty = @fCartonQty,
                     EditWho = SUSER_SNAME(),
                     EditDate = GETDATE()
                  WHERE PickSlipNo = @cPickSlipNo
                     AND CartonNo = @nCartonNo
                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 100217
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDPackInfFail
                     GOTO Quit
                  END
               END
               -- Extended update
               IF @cExtendedUpdateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, ' +
                        ' @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption, ' +
                        ' @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, @cPackData1, @cPackData2, @cPackData3, ' +
                        ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
                     SET @cSQLParam =
                        '@nMobile         INT,           ' +
                        '@nFunc           INT,           ' +
                        '@cLangCode       NVARCHAR( 3),  ' +
                        '@nStep           INT,           ' +
                        '@nInputKey       INT,           ' +
                        '@cFacility       NVARCHAR( 5),  ' +
                        '@cStorerKey      NVARCHAR( 15), ' +
                        '@cPickSlipNo     NVARCHAR( 10), ' +
                        '@cFromDropID     NVARCHAR( 20), ' +
                        '@nCartonNo       INT,           ' +
                        '@cLabelNo        NVARCHAR( 20), ' +
                        '@cSKU            NVARCHAR( 20), ' +
                        '@nQTY            INT,           ' +
                        '@cUCCNo          NVARCHAR( 20), ' +
                        '@cCartonType     NVARCHAR( 10), ' +
                        '@cCube           NVARCHAR( 10), ' +
                        '@cWeight         NVARCHAR( 10), ' +
                        '@cRefNo          NVARCHAR( 20), ' +
                        '@cSerialNo       NVARCHAR( 30), ' +
                        '@nSerialQTY      INT,           ' +
                        '@cOption         NVARCHAR( 1),  ' +
                        '@cPackDtlRefNo   NVARCHAR( 20), ' +
                        '@cPackDtlRefNo2  NVARCHAR( 20), ' +
                        '@cPackDtlUPC     NVARCHAR( 30), ' +
                        '@cPackDtlDropID  NVARCHAR( 20), ' +
                        '@cPackData1      NVARCHAR( 30), ' +
                        '@cPackData2      NVARCHAR( 30), ' +
                        '@cPackData3      NVARCHAR( 30), ' +
                        '@nErrNo          INT            OUTPUT, ' +
                        '@cErrMsg         NVARCHAR( 20)  OUTPUT'

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID,
                        @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption,
                        @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, @cPackData1, @cPackData2, @cPackData3,
                        @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                        GOTO Quit
                  END
               END

               -- Print label
               IF @cShipLabel <> '' OR @cCartonManifest <> ''
               BEGIN
                  -- Prepare next screen var
                  SET @cOutField01 = @cDefaultPrintLabelOption --Option

                  -- Enable field
                  SET @cFieldAttr01 = '' -- CartonType
                  SET @cFieldAttr02 = '' -- Weight
                  SET @cFieldAttr03 = '' -- Cube
                  SET @cFieldAttr04 = '' -- RefNo

                  -- Go to next screen
                  SET @nAfterScn = 4654
                  SET @nAfterStep = 5
               END
               ELSE
               BEGIN
                  IF @cUCCNo = ''
                  BEGIN
                     -- Get statistics
                     EXEC rdt.rdt_Pack_GetStat @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'CURRENT'
                        ,@cPickSlipNo
                        ,@cFromDropID
                        ,@cPackDtlDropID
                        ,@nCartonNo    OUTPUT
                        ,@cLabelNo     OUTPUT
                        ,@cCustomNo    OUTPUT
                        ,@cCustomID    OUTPUT
                        ,@nCartonSKU   OUTPUT
                        ,@nCartonQTY   OUTPUT
                        ,@nTotalCarton OUTPUT
                        ,@nTotalPick   OUTPUT
                        ,@nTotalPack   OUTPUT
                        ,@nTotalShort  OUTPUT
                        ,@nErrNo       OUTPUT
                        ,@cErrMsg      OUTPUT
                     IF @nErrNo <> 0
                        GOTO Quit

                     -- Prepare current screen var
                     SET @cOutField01 = @cPickSlipNo
                     SET @cOutField02 = CAST( @nTotalPick AS NVARCHAR(8))  -- ZG02
                     SET @cOutField03 = CAST( @nTotalPack AS NVARCHAR(8))  -- ZG02
                     SET @cOutField04 = CAST( @nTotalShort AS NVARCHAR(8))  -- ZG02
                     SET @cOutField05 = RTRIM( @cCustomNo) + '/' + CAST( @nTotalCarton AS NVARCHAR(5))
                     SET @cOutField06 = @cCustomID
                     SET @cOutField07 = CAST( @nCartonSKU AS NVARCHAR(5))
                     SET @cOutField08 = CAST( @nCartonQTY AS NVARCHAR(5))
                     SET @cOutField09 = @cDefaultOption -- Option

                     -- Enable field
                     SET @cFieldAttr01 = '' -- CartonType
                     SET @cFieldAttr02 = '' -- Weight
                     SET @cFieldAttr03 = '' -- Cube
                     SET @cFieldAttr04 = '' -- RefNo

                     -- Go to statistic screen
                     SET @nAfterScn = 4651
                     SET @nAfterStep = 2       
                  END
                  ELSE
                  BEGIN
                     -- Get total UCC
                     SELECT @nTotalUCC = COUNT(1) FROM PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND UCCNo <> ''

                     -- Prepare current screen var
                     SET @cOutField01 = '' -- UCCNo
                     SET @cOutField02 = @cUCCCounter
                     SET @cOutField03 = CAST( @nTotalUCC AS NVARCHAR(5))

                     -- Go to UCC screen
                     SET @nAfterScn = 4657
                     SET @nAfterStep = 8
                  END
               END
            END

            IF @nInputKey = 0 -- ESC
            BEGIN
               -- Enable field
               SET @cFieldAttr01 = '' -- CartonType
               SET @cFieldAttr02 = '' -- Weight
               SET @cFieldAttr03 = '' -- Cube
               SET @cFieldAttr04 = '' -- RefNo

               IF @cUCCNo = ''
               BEGIN
                  -- Prepare next screen var
                  SET @cOutField01 = RTRIM( @cCustomNo)
                  SET @cOutField02 = CAST( CAST( @cLabelLine AS INT) AS NVARCHAR(5)) + '/' + CAST( @nCartonSKU AS NVARCHAR(5))
                  SET @cOutField03 = '' -- SKU
                  SET @cOutField04 = @cSKU
                  SET @cOutField05 = rdt.rdtFormatString( @cSKUDescr, 1, 20)
                  SET @cOutField06 = rdt.rdtFormatString( @cSKUDescr, 21, 20)
                  SET @cOutField07 = CAST( @nPackedQTY AS NVARCHAR( 8))    -- ZG02
                  SET @cOutField08 = '' -- QTY
                  SET @cOutField09 = CAST( @nCartonQTY AS NVARCHAR( 5))
                  SET @cOutField10 = CASE WHEN @cPrePackIndicator = '2' THEN @cPackQtyIndicator ELSE '' END
                  SET @cOutField11 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END
                  SET @cOutField12 = rdt.rdtRightAlign( @cPUOM_Desc, 5)
                  SET @cOutField13 = rdt.rdtRightAlign( @cMUOM_Desc, 5)
                  SET @cOutField14 = '' -- PQTY
                  SET @cOutField15 = '' -- ExtendedInfo

                  -- Convert to prefer UOM QTY
                  IF @cPUOM = '6' OR -- When preferred UOM = master unit
                     @nPUOM_Div = 0  -- UOM not setup
                  BEGIN
                     SET @cPUOM_Desc = ''
                     SET @nPQTY = 0
                     SET @cFieldAttr14 = 'O' -- @nPQTY
                  END
                  ELSE
                  BEGIN
                     SET @cFieldAttr14 = '' -- @nPQTY
                  END

                  SET @cFieldAttr08 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END

                  EXEC rdt.rdtSetFocusField @nMobile, 3 -- SKU

                  -- Go to SKU QTY screen
                  SET @nAfterScn = 4652
                  SET @nAfterStep = 3
               END
               ELSE
               BEGIN
                  -- Get total UCC
                  SELECT @nTotalUCC = COUNT(1) FROM PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND UCCNo <> ''

                  -- Prepare current screen var
                  SET @cOutField01 = '' -- UCCNo
                  SET @cOutField02 = @cUCCCounter
                  SET @cOutField03 = CAST( @nTotalUCC AS NVARCHAR(5))

                  -- Go to UCC screen
                  SET @nAfterScn =  4657
                  SET @nAfterStep = 8
               END
            END
            GOTO QUIT
         END
         IF @nCurrentScn = 6708
         BEGIN
            SET @cOption = @cInField03
            IF @cOption NOT IN ('1','9') AND @nInputKey = 1
            BEGIN
               SET @nErrNo = 253202
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --invalidOption
               SET @cOutField03 = ''
               GOTO Quit 
            END
            IF @cOption = '1'
            BEGIN
               SELECT @cLength = CartonLength, @cWidth = CartonWidth, @cHeight = CartonHeight
               FROM Cartonization C WITH (NOLOCK)
                  JOIN Storer S WITH (NOLOCK) ON (C.CartonizationGroup = S.CartonGroup)
               WHERE S.StorerKey = @cStorerKey
                  AND C.CartonType = @cCartonType
               
               IF @cDefaultWeight IN ('2', '3')
               BEGIN
                  -- Weight (SKU only)
                  SELECT @nWeight = ISNULL( SUM( SKU.STDGrossWGT * PD.QTY), 0)
                  FROM dbo.PackDetail PD WITH (NOLOCK)
                     JOIN dbo.SKU SKU WITH (NOLOCK) ON (SKU.StorerKey = PD.StorerKey AND SKU.SKU = PD.SKU)
                  WHERE PD.PickSlipNo = @cPickSlipNo
                     AND PD.CartonNo = @nCartonNo

                  -- Weight (SKU + carton)
                  IF @cDefaultWeight = '3'
                  BEGIN
                     -- Get carton type info
                     SELECT @nCartonWeight = CartonWeight
                     FROM Cartonization C WITH (NOLOCK)
                        JOIN Storer S WITH (NOLOCK) ON (C.CartonizationGroup = S.CartonGroup)
                     WHERE S.StorerKey = @cStorerKey
                        AND C.CartonType = @cCartonType

                     SET @nWeight = @nWeight + @nCartonWeight
                  END
                  SET @cWeight = rdt.rdtFormatFloat( @nWeight)
                  SET @fWeight = CAST( @cWeight AS FLOAT)
               END
               
               UPDATE dbo.PackInfo SET
                  CartonType = @cCartonType,
                  Weight = @fWeight,
                  Length = @cLength,  
                  Width = @cWidth,     
                  Height = @cHeight
               WHERE PickSlipNo = @cPickSlipNo
                  AND CartonNo = @nCartonNo
               
               DECLARE @c_AlertMessage NVARCHAR(MAX)
               SET @c_AlertMessage = CONCAT('PS:',@cPickSlipNo,'/CTNNO:',@nCartonNo,'/ORGCTNTYPE:', @cOutField01,'/NEWCTNTYPE:',@cCartonType)

               -- Generate alert
               EXEC nspLogAlert
                  @c_modulename       = 'PPK'
                  , @c_AlertMessage     = @c_AlertMessage
                  , @n_Severity         = '5'
                  , @b_Success          = @bSuccess      OUTPUT
                  , @n_err              = @nErrNO          OUTPUT
                  , @c_errmsg           = @cErrMSG       OUTPUT
                  , @c_Activity         = 'CTNTYPCHNG'
                  , @c_Storerkey        = @cStorerKey

               SET @cOutField01 = @cDefaultPrintLabelOption
               SET @nAfterStep = 5
               SET @nAfterScn = 4654
               GOTO QUIT
            END
            ELSE
            BEGIN
               -- Get PackInfo
               SET @cCartonType = ''
               SET @cWeight = ''
               SET @cCube = ''
               SET @cRefNo = ''
               SET @cLength = ''
               SET @cWidth = ''
               SET @cHeight = ''

               SELECT
                  @cCartonType = ISNULL( CartonType, ''),
                  @cWeight = rdt.rdtFormatFloat( Weight),
                  @cCube = rdt.rdtFormatFloat( [Cube]),
                  @cRefNo = RefNo,
                  @cLength = rdt.rdtFormatFloat( [Length]),
                  @cWidth = rdt.rdtFormatFloat( [Width]),
                  @cHeight = rdt.rdtFormatFloat( [Height])
               FROM dbo.PackInfo WITH (NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo
                  AND CartonNo  = @nCartonNo

               -- Prepare LOC screen var
               SET @cOutField01 = CASE WHEN ISNULL(@cCartonType ,'') ='' AND ISNULL(@cDefaultcartontype,'')<>''  THEN @cDefaultcartontype ELSE @cCartonType end
               SET @cOutField02 = @cWeight           --WinSern
               SET @cOutField03 = @cCube             --WinSern
               SET @cOutField04 = @cRefNo
               SET @cOutField05 = @cLength
               SET @cOutField06 = @cWidth
               SET @cOutField07 = @cHeight
               SET @cMobBarcode = '' --clear v_barcode

               -- Enable disable field
               SET @cFieldAttr01 = CASE WHEN CHARINDEX( 'T', @cPackInfo) = 0 THEN 'O' ELSE '' END
               SET @cFieldAttr02 = CASE WHEN CHARINDEX( 'C', @cPackInfo) = 0 THEN 'O' ELSE '' END
               SET @cFieldAttr03 = CASE WHEN CHARINDEX( 'W', @cPackInfo) = 0 THEN 'O' ELSE '' END
               SET @cFieldAttr04 = CASE WHEN CHARINDEX( 'R', @cPackInfo) = 0 THEN 'O' ELSE '' END
               SET @cFieldAttr05 = CASE WHEN CHARINDEX( 'L', @cPackInfo) = 0 THEN 'O' ELSE '' END
               SET @cFieldAttr06 = CASE WHEN CHARINDEX( 'D', @cPackInfo) = 0 THEN 'O' ELSE '' END
               SET @cFieldAttr07 = CASE WHEN CHARINDEX( 'H', @cPackInfo) = 0 THEN 'O' ELSE '' END
               SET @cFieldAttr08 = '' -- QTY

               -- Position cursor
               IF @cFieldAttr01 = '' AND @cOutField01 = ''  EXEC rdt.rdtSetFocusField @nMobile, 1 ELSE
               IF @cFieldAttr02 = '' AND @cOutField02 = '0' EXEC rdt.rdtSetFocusField @nMobile, 2 ELSE
               IF @cFieldAttr03 = '' AND @cOutField03 = '0' EXEC rdt.rdtSetFocusField @nMobile, 3 ELSE
               IF @cFieldAttr04 = '' AND @cOutField04 = ''  EXEC rdt.rdtSetFocusField @nMobile, 4 ELSE
               IF @cFieldAttr05 = '' AND @cOutField05 = '0' EXEC rdt.rdtSetFocusField @nMobile, 5 ELSE
               IF @cFieldAttr06 = '' AND @cOutField06 = '0' EXEC rdt.rdtSetFocusField @nMobile, 6 ELSE
               IF @cFieldAttr07 = '' AND @cOutField07 = '0' EXEC rdt.rdtSetFocusField @nMobile, 7 

               SET @nAfterScn = 4653
               SET @nAfterStep = 99
               GOTO QUIT
            END   
         END
      END
      IF @nCurrentStep = 5
      BEGIN
         IF @nStep = 4
         BEGIN
            SET @nAfterStep = 99
            GOTO QUIT
         END
      END
   END

   RETURN

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_838ExtScn06] TO NSQL
GO


