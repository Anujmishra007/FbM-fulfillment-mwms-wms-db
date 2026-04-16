
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
/* 2026-03-27  1.1.0  NLT013     FCR-11343 B2C Single Flex Pack            */
/* 2026-04-13  1.2.0  Jackc      FCR-12450 New step1 for B2B order         */
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

   DECLARE @nDebugFlag  INT = 0

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
      @nRemainQTY       INT,
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
      @nScan               INT,

      -- B2C Single Flex Pack variables (FCR-11343)
      @cIsB2CSingle        NVARCHAR(1) = '0',
      @cB2CSingleFlexPack  NVARCHAR(5) = '0',
      @cFetchedOrderKey    NVARCHAR(10) = '',
      @cExistingLockUser   NVARCHAR(18) = '',
      @cPickStatus  NVARCHAR(10),
      @nPackedDetailPackedQty    INT,
      @nPackedDetailExpQty       INT,
      @nPackedInfoQty            INT,
      @nPickedDetaildQty         INT

   --V1.2.0
   DECLARE 
      @cB2BUoM6Flag     NVARCHAR(1),
      @cPackByToDropID  NVARCHAR(1),
      @fCartonQty       FLOAT

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
   @cDefaultCursor      = V_String51,
   @cPackByToDropID     = V_String52,
   @cIsB2CSingle        = C_String1,
   @cB2BUoM6Flag        = C_String2

   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile
  
   -- Get storer configure  
   SET @cPickStatus = rdt.RDTGetConfig( @nFunc, 'PickStatus', @cStorerKey)
   IF @cPickStatus = '0'
      SET @cPickStatus = '5'

   SET @cUDF01 = ''

   IF @nFunc = 838
   BEGIN
      IF @nScn = 4652 -- New carton type screen
      BEGIN
         SELECT TOP 1 @cOutField03 = CONCAT('CartonType:',CartonType) FROM PackInfo (NOLOCK) WHERE PICKSLIPNO = @cPickSlipNo
         GOTO QUIT
      END
      
      -- V1.2.0 start
      --Generic ESC handling
      -- redirect to 1st new screen
      IF @nScn = 4650 AND @nStep = 1
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Redirect to new step1 scn6865'

         SET @cOutField01 = ''
         SET @cOutField02 = ''
         SET @cOutField03 = ''
         SET @cB2BUoM6Flag = ''

         SET @nAfterScn = 6865
         SET @nAfterStep = 99 
         GOTO Quit
      END-- generic esc handling

      --V1.2.0 
      --Replace @nCurrentStep = 1 with new step1 screen 6865

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
         -- Existing Screen 3 handling continues below...
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
      IF @nCurrentStep = 5
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF @cIsB2CSingle = '1'
            BEGIN
               SELECT @nRemainQTY = SUM(PAD.ExpQty - PAD.Qty)
               FROM dbo.PackDetail PAD WITH (NOLOCK)
               INNER JOIN dbo.PICKHEADER PKH WITH (NOLOCK) ON PAD.PickSlipNo = PKH.PickHeaderKey AND PAD.StorerKey = PKH.StorerKey
               INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON PAD.LabelNo = PKD.CaseID AND PAD.SKU = PKD.SKU AND PKH.OrderKey = PKD.OrderKey
               WHERE PKD.DropID = @cFromDropID
                  AND PKD.StorerKey = @cStorerKey
                  AND PAD.Qty = 0

               SET @nRemainQTY = ISNULL(@nRemainQTY, 0)

               SELECT
                  @cSKUDescr = Descr,
                  @cSKUDataCapture = DataCapture,
                  @cPrePackIndicator = ISNULL( PrePackIndicator, ''),
                  @cPackQtyIndicator = LEFT( ISNULL( PackQtyIndicator, '0'), 3),
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

               IF @nRemainQTY > 0
               BEGIN
                  SET @cOutField01 = ''
                  SET @cOutField02 = ''
                  SET @cMobBarcode = '' -- clear V_barcode
                  SET @cOutField03 = ''
                  SET @cOutField04 = ''
                  SET @cOutField05 = ISNULL(TRY_CAST( @nRemainQTY AS NVARCHAR( 8)), '')
                  SET @cOutField08 = CASE WHEN @cDisableQTYField = '1' THEN @cQTY ELSE @cDefaultQTY END
                  SET @cOutField09 = ''
                  SET @cOutField10 = ''
                  SET @cOutField11 = ''
                  SET @cOutField12 = ''
                  SET @cOutField13 = ''
                  SET @cOutField14 = ''

                  -- Enable field
                  SET @cFieldAttr08 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END

                  EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU field

                  SET @nAfterScn = 6862
                  SET @nAfterStep = 99
               END
               ELSE
               BEGIN
                  SET @cOutField01 = CASE WHEN @cShowPickSlipNo = '1' THEN @cPickSlipNo ELSE '' END -- PickSlipNo (james17)
                  SET @cOutField02 = '' -- FromDropID
                  SET @cOutField03 = '' -- ToDropID

                  --(v7.5) start
                  IF @cFromDropID <> ''
                     EXEC rdt.rdtSetFocusField @nMobile, 2  -- FromDropID
                  ELSE
                  BEGIN
                     IF @cPackDtlDropID <> ''
                        EXEC rdt.rdtSetFocusField @nMobile, 3 -- ToDropID
                     ELSE
                        EXEC rdt.rdtSetFocusField @nMobile, 1  -- PickSlipNo
                  END
                  
                  --SET @nAfterScn = 4650
                  --SET @nAfterStep = 1
                  --V1.2
                  SET @nAfterScn = 6865
                  SET @nAfterStep = 99
               END
               GOTO Quit
            END
         END
      END

      IF @nCurrentStep = 99
      BEGIN
         IF @nCurrentScn = 4653 -- New carton type screen
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
               --DECLARE @fCartonQty FLOAT --(cc02) --V1.2 Move to top.
               SET @fCartonQty = 0
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
                     CartonStatus = 'PACKED',
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

               IF @cIsB2CSingle = '1'
               BEGIN
                  SELECT @nPickedDetaildQty = SUM(Qty)
                  FROM dbo.PickDetail WITH(NOLOCK) 
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cFromDropID

                  SELECT @nPackedDetailPackedQty = SUM(Qty),
                     @nPackedDetailExpQty = SUM(ExpQty)
                  FROM dbo.PackDetail WITH(NOLOCK) 
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cFromDropID
                  
                  SET @nPickedDetaildQty = ISNULL(@nPickedDetaildQty, -1)
                  SET @nPackedDetailPackedQty = ISNULL(@nPackedDetailPackedQty, -2)
                  SET @nPackedDetailExpQty = ISNULL(@nPackedDetailExpQty, -3)
                  -- If current label is pack completed, start a new label; otherwise, validate the label is correct
                  IF @nPackedDetailPackedQty = @nPackedDetailExpQty AND @nPickedDetaildQty = @nPackedDetailPackedQty
                  BEGIN
                     IF EXISTS (SELECT TOP 1 1 FROM dbo.PackHeader PH WITH(NOLOCK) 
                                 JOIN dbo.PackDetail PD WITH(NOLOCK) ON PH.StorerKey = PD.StorerKey AND PH.PickSlipNo = PD.PickSlipNo
                                 WHERE PH.StorerKey = @cStorerKey 
                                    AND PD.DropID = @cFromDropID 
                                    AND PH.Status = '9' )
                     BEGIN
                        SET @nErrNo = 253223
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Pack header is 9
                        GOTO Quit
                     END

                     -- Pack confirm
                     SET @cPrintPackList = ''
                     EXEC rdt.rdt_Pack_PackConfirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
                        ,@cPickSlipNo
                        ,@cFromDropID
                        ,@cPackDtlDropID
                        ,@cPrintPackList OUTPUT
                        ,@nErrNo         OUTPUT
                        ,@cErrMsg        OUTPUT
                     
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
                     IF @cIsB2CSingle = '1'
                     BEGIN
                        SELECT @nRemainQTY = SUM(PAD.ExpQty - PAD.Qty)
                        FROM dbo.PackDetail PAD WITH (NOLOCK)
                        INNER JOIN dbo.PICKHEADER PKH WITH (NOLOCK) ON PAD.PickSlipNo = PKH.PickHeaderKey AND PAD.StorerKey = PKH.StorerKey
                        INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON PAD.LabelNo = PKD.CaseID AND PAD.SKU = PKD.SKU AND PKH.OrderKey = PKD.OrderKey
                        WHERE PKD.DropID = @cFromDropID
                           AND PKD.StorerKey = @cStorerKey
                           AND PAD.Qty = 0

                        SET @nRemainQTY = ISNULL(@nRemainQTY, 0)

                        SELECT
                           @cSKUDescr = Descr,
                           @cSKUDataCapture = DataCapture,
                           @cPrePackIndicator = ISNULL( PrePackIndicator, ''),
                           @cPackQtyIndicator = LEFT( ISNULL( PackQtyIndicator, '0'), 3),
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

                        IF @nRemainQTY > 0
                        BEGIN
                           SET @cOutField01 = ''
                           SET @cOutField02 = ''
                           SET @cMobBarcode = '' -- clear V_barcode
                           SET @cOutField03 = ''
                           SET @cOutField04 = ''
                           SET @cOutField05 = ISNULL(TRY_CAST( @nRemainQTY AS NVARCHAR( 8)), '')
                           SET @cOutField08 = CASE WHEN @cDisableQTYField = '1' THEN @cQTY ELSE @cDefaultQTY END
                           SET @cOutField09 = ''
                           SET @cOutField10 = ''
                           SET @cOutField11 = ''
                           SET @cOutField12 = ''
                           SET @cOutField13 = ''
                           SET @cOutField14 = ''

                           -- Enable field
                           SET @cFieldAttr08 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END

                           EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU field

                           SET @nAfterScn = 6862
                           SET @nAfterStep = 99
                        END
                        ELSE
                        BEGIN
                           SET @cOutField01 = CASE WHEN @cShowPickSlipNo = '1' THEN @cPickSlipNo ELSE '' END -- PickSlipNo (james17)
                           SET @cOutField02 = '' -- FromDropID
                           SET @cOutField03 = '' -- ToDropID

                           --(v7.5) start
                           IF @cFromDropID <> ''
                              EXEC rdt.rdtSetFocusField @nMobile, 2  -- FromDropID
                           ELSE
                           BEGIN
                              IF @cPackDtlDropID <> ''
                                 EXEC rdt.rdtSetFocusField @nMobile, 3 -- ToDropID
                              ELSE
                                 EXEC rdt.rdtSetFocusField @nMobile, 1  -- PickSlipNo
                           END
                           
                           --SET @nAfterScn = 4650
                           --SET @nAfterStep = 1

                           --V1.2
                           SET @nAfterScn = 6865
                           SET @nAfterStep = 99
                        END
                        GOTO Quit
                     END

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

               -- FCR-11343: If B2C Single, skip Screen 2 and go to Screen 3
               IF @cIsB2CSingle = '1'
               BEGIN
                  SELECT @nRemainQTY = SUM(PAD.ExpQty - PAD.Qty)
                  FROM dbo.PackDetail PAD WITH (NOLOCK)
                  INNER JOIN dbo.PICKHEADER PKH WITH (NOLOCK) ON PAD.PickSlipNo = PKH.PickHeaderKey AND PAD.StorerKey = PKH.StorerKey
                  INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON PAD.LabelNo = PKD.CaseID AND PAD.SKU = PKD.SKU AND PKH.OrderKey = PKD.OrderKey
                  WHERE PKD.DropID = @cFromDropID
                     AND PKD.StorerKey = @cStorerKey
                     AND PAD.Qty = 0

                  SELECT
                     @cSKUDescr = Descr,
                     @cSKUDataCapture = DataCapture,
                     @cPrePackIndicator = ISNULL( PrePackIndicator, ''),
                     @cPackQtyIndicator = LEFT( ISNULL( PackQtyIndicator, '0'), 3),
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

                  SET @nRemainQTY = ISNULL(@nRemainQTY, 0)

                  SET @cOutField01 = @cLabelNo
                  SET @cOutField02 = @cSku
                  SET @cMobBarcode = '' -- clear V_barcode
                  SET @cOutField03 = rdt.rdtFormatString( @cSKUDescr, 1, 20)
                  SET @cOutField04 = rdt.rdtFormatString( @cSKUDescr, 21, 20)
                  SET @cOutField05 = ISNULL(TRY_CAST( @nRemainQTY AS NVARCHAR( 8)), '')
                  SET @cOutField08 = CASE WHEN @cDisableQTYField = '1' THEN @cQTY ELSE @cDefaultQTY END
                  SET @cOutField09 = ''
                  SET @cOutField10 = ''
                  SET @cOutField11 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END
                  SET @cOutField12 = rdt.rdtRightAlign( @cPUOM_Desc, 5)
                  SET @cOutField13 = rdt.rdtRightAlign( @cMUOM_Desc, 5)
                  SET @cOutField14 = ''

                   -- Enable field
                  SET @cFieldAttr08 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END

                  EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU field
                  --Reset 
                  SET @nEnter = 0

                  SET @nAfterScn = 6862   -- New SKU scan screen
                  SET @nAfterStep = 99
                  GOTO QUIT
               END

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
         ELSE IF @nCurrentScn = 6708 -- B2C single carton type screen
         BEGIN
            IF @nInputKey = 0
            BEGIN
               IF @cIsB2CSingle = '1'
               BEGIN
                  SELECT @nRemainQTY = SUM(PAD.ExpQty - PAD.Qty)
                  FROM dbo.PackDetail PAD WITH (NOLOCK)
                  INNER JOIN dbo.PICKHEADER PKH WITH (NOLOCK) ON PAD.PickSlipNo = PKH.PickHeaderKey AND PAD.StorerKey = PKH.StorerKey
                  INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON PAD.LabelNo = PKD.CaseID AND PAD.SKU = PKD.SKU AND PKH.OrderKey = PKD.OrderKey
                  WHERE PKD.DropID = @cFromDropID
                     AND PKD.StorerKey = @cStorerKey
                     AND PAD.Qty = 0

                  SET @nRemainQTY = ISNULL(@nRemainQTY, 0)

                  SELECT
                     @cSKUDescr = Descr,
                     @cSKUDataCapture = DataCapture,
                     @cPrePackIndicator = ISNULL( PrePackIndicator, ''),
                     @cPackQtyIndicator = LEFT( ISNULL( PackQtyIndicator, '0'), 3),
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

                  IF @nRemainQTY > 0
                  BEGIN
                     SET @cOutField01 = ''
                     SET @cOutField02 = ''
                     SET @cMobBarcode = '' -- clear V_barcode
                     SET @cOutField03 = ''
                     SET @cOutField04 = ''
                     SET @cOutField05 = ISNULL(TRY_CAST( @nRemainQTY AS NVARCHAR( 8)), '')
                     SET @cOutField08 = CASE WHEN @cDisableQTYField = '1' THEN @cQTY ELSE @cDefaultQTY END
                     SET @cOutField09 = ''
                     SET @cOutField10 = ''
                     SET @cOutField11 = ''
                     SET @cOutField12 = ''
                     SET @cOutField13 = ''
                     SET @cOutField14 = ''

                     -- Enable field
                     SET @cFieldAttr08 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END

                     EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU field

                     SET @nAfterScn = 6862
                     SET @nAfterStep = 99
                  END
                  ELSE
                  BEGIN
                     SET @cOutField01 = CASE WHEN @cShowPickSlipNo = '1' THEN @cPickSlipNo ELSE '' END -- PickSlipNo (james17)
                     SET @cOutField02 = '' -- FromDropID
                     SET @cOutField03 = '' -- ToDropID

                     --(v7.5) start
                     IF @cFromDropID <> ''
                        EXEC rdt.rdtSetFocusField @nMobile, 2  -- FromDropID
                     ELSE
                     BEGIN
                        IF @cPackDtlDropID <> ''
                           EXEC rdt.rdtSetFocusField @nMobile, 3 -- ToDropID
                        ELSE
                           EXEC rdt.rdtSetFocusField @nMobile, 1  -- PickSlipNo
                     END
                     
                     --SET @nAfterScn = 4650
                     --SET @nAfterStep = 1

                     --V1.2
                     SET @nAfterScn = 6865
                     SET @nAfterStep = 99
                  END
                  GOTO Quit
               END
            END

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

               --V1.2 Fix Packinfo qty not updated when confirm carton type change
               SET @fCartonQty = 0
               SELECT @fCartonQty = SUM(qty) FROM packDetail WITH (NOLOCK) WHERE pickslipNo = @cPickSlipNo AND cartonNo = @nCartonNo AND storerKey = @cStorerKey --(cc02)

               BEGIN TRY
                  UPDATE dbo.PackInfo SET
                     CartonType = @cCartonType,
                     Weight = @fWeight,
                     Length = @cLength,
                     Width  = @cWidth,
                     Height = @cHeight,
                     Qty    = @fCartonQty,
                     CartonStatus = 'PACKED',
                     EditDate = GETDATE(),
                     EditWho = @cUserName
                  WHERE PickSlipNo = @cPickSlipNo
                     AND CartonNo = @nCartonNo
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 253222
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PackInfo Failed
                  SET @cOutField03 = ''
                  GOTO Quit
               END CATCH

               IF @cIsB2CSingle = '1'
               BEGIN
                  SELECT @nPickedDetaildQty = SUM(Qty)
                  FROM dbo.PickDetail WITH(NOLOCK) 
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cFromDropID

                  SELECT @nPackedDetailPackedQty = SUM(Qty),
                     @nPackedDetailExpQty = SUM(ExpQty)
                  FROM dbo.PackDetail WITH(NOLOCK) 
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cFromDropID
                  
                  SET @nPickedDetaildQty = ISNULL(@nPickedDetaildQty, -1)
                  SET @nPackedDetailPackedQty = ISNULL(@nPackedDetailPackedQty, -2)
                  SET @nPackedDetailExpQty = ISNULL(@nPackedDetailExpQty, -3)
                  -- If current label is pack completed, start a new label; otherwise, validate the label is correct
                  IF @nPackedDetailPackedQty = @nPackedDetailExpQty AND @nPickedDetaildQty = @nPackedDetailPackedQty
                  BEGIN
                     -- Pack confirm
                     SET @cPrintPackList = ''
                     EXEC rdt.rdt_Pack_PackConfirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
                        ,@cPickSlipNo
                        ,@cFromDropID
                        ,@cPackDtlDropID
                        ,@cPrintPackList OUTPUT
                        ,@nErrNo         OUTPUT
                        ,@cErrMsg        OUTPUT
                     
                     IF @nErrNo <> 0
                        GOTO Quit
                  END
               END
               
               
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
         /********************************************************************************
         Scn = 6862. SKU QTY screen
            CARTON NO   (field01)
            SKUCount    (field02)
            CartonSKU   (field02)
            SKU/UPC     (field03, input)
            SKU         (field04)
            DESCR1      (field05)
            DESCR2      (field06)
            PACKED      (field07)
            QTY         (field08, input)
            CARTON QTY  (field09)
         ********************************************************************************/
         ELSE IF @nCurrentScn = 6862
         BEGIN
            SET @cUDF01 = 'NO UPD RDTMOBREC'
            IF @nInputKey = 1
            BEGIN
               DECLARE @cUPCBarcode NVARCHAR(2000)
               SET @cUPCBarcode = LEFT(@cMobBarcode, 2000)
               SET @cBarcode2 = ''
               SET @cUPC = LEFT( @cMobBarcode, 30) -- SKU
               SET @cMQTY = CASE WHEN @cFieldAttr08 = 'O' THEN '' ELSE @cInField08 END
               SET @cPQTY = CASE WHEN @cFieldAttr14 = 'O' THEN '' ELSE @cInField14 END

               -- Retain value
               SET @cOutField08 = CASE WHEN @cFieldAttr08 = 'O' THEN @cOutField08 ELSE @cInField08 END -- PQTY
               SET @cOutField14 = CASE WHEN @cFieldAttr14 = 'O' THEN @cOutField14 ELSE @cInField14 END -- MQTY

               -- Loop SKU
               IF @cUPCBarcode = '' AND @cMQTY = '' AND @cPQTY = ''
               BEGIN
                  IF @nCartonQTY > 0
                  BEGIN
                     -- Get carton info
                     SELECT TOP 1
                        @cSKU = SKU,
                        @cLabelLine = LabelLine
                     FROM PackDetail WITH (NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                        AND CartonNo = @nCartonNo
                        AND LabelNo = @cLabelNo
                        AND LabelLine > @cLabelLine
                     ORDER BY LabelLine

                     IF @@ROWCOUNT = 0
                        SELECT TOP 1
                           @cSKU = SKU,
                           @cLabelLine = LabelLine
                        FROM PackDetail WITH (NOLOCK)
                        WHERE PickSlipNo = @cPickSlipNo
                           AND CartonNo = @nCartonNo
                           AND LabelNo = @cLabelNo
                        ORDER BY LabelLine

                     -- Get SKU info
                     SELECT
                        @cSKUDescr = Descr,
                        @cPrePackIndicator = ISNULL( PrePackIndicator, ''),
                        @cPackQtyIndicator = LEFT( ISNULL( PackQtyIndicator, '0'), 3),
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

                     -- Disable QTY field (cc03)
                     IF @cDisableQTYFieldSP <> ''
                     BEGIN
                        IF @cDisableQTYFieldSP = '1'
                        BEGIN
                           SET @cDisableQTYField = @cDisableQTYFieldSP
                        END
                        ELSE
                        BEGIN
                           IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cDisableQTYFieldSP AND type = 'P')
                           BEGIN
                              SET @cSQL = 'EXEC rdt.' + RTRIM( @cDisableQTYFieldSP) +
                              ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, ' +
                              ' @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption, ' +
                              ' @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, @cPackData1, @cPackData2, @cPackData3, ' +
                              ' @tVarDisableQTYField, @cDisableQTYField OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '
                              SET @cSQLParam =
                              '@nMobile            INT,           ' +
                              '@nFunc              INT,           ' +
                              '@cLangCode          NVARCHAR( 3),  ' +
                              '@nStep              INT,           ' +
                              '@nInputKey          INT,           ' +
                              '@cFacility          NVARCHAR( 5),  ' +
                              '@cStorerKey         NVARCHAR( 15), ' +
                              '@cPickSlipNo        NVARCHAR( 10), ' +
                              '@cFromDropID        NVARCHAR( 20), ' +
                              '@nCartonNo          INT,           ' +
                              '@cLabelNo           NVARCHAR( 20), ' +
                              '@cSKU               NVARCHAR( 20), ' +
                              '@nQTY               INT,           ' +
                              '@cUCCNo             NVARCHAR( 20), ' +
                              '@cCartonType        NVARCHAR( 10), ' +
                              '@cCube              NVARCHAR( 10), ' +
                              '@cWeight            NVARCHAR( 10), ' +
                              '@cRefNo             NVARCHAR( 20), ' +
                              '@cSerialNo          NVARCHAR( 30), ' +
                              '@nSerialQTY         INT,           ' +
                              '@cOption            NVARCHAR( 1),  ' +
                              '@cPackDtlRefNo      NVARCHAR( 20), ' +
                              '@cPackDtlRefNo2     NVARCHAR( 20), ' +
                              '@cPackDtlUPC        NVARCHAR( 30), ' +
                              '@cPackDtlDropID     NVARCHAR( 20), ' +
                              '@cPackData1         NVARCHAR( 30), ' +
                              '@cPackData2         NVARCHAR( 30), ' +
                              '@cPackData3         NVARCHAR( 30), ' +
                              '@tVarDisableQTYField VariableTable READONLY, ' +
                              '@cDisableQTYField   NVARCHAR( 1)   OUTPUT, ' +
                              '@nErrNo             INT            OUTPUT, ' +
                              '@cErrMsg            NVARCHAR( 20)  OUTPUT'

                              EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                                 @nMobile, @nFunc, @cLangCode, @nCurrentStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID,
                                 @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption,
                                 @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, @cPackData1, @cPackData2, @cPackData3,
                                 @tVarDisableQTYField, @cDisableQTYField OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                              IF @nErrNo <> 0
                                 GOTO SCN_6862_FAIL
                           END
                        END
                     END

                     -- Get PackDetail info
                     SELECT @nPackedQTY = PD.QTY
                     FROM dbo.PackDetail PD WITH (NOLOCK)
                     WHERE PD.PickSlipNo = @cPickSlipNo
                        AND CartonNo = @nCartonNo
                        AND LabelNo = @cLabelNo
                        AND LabelLine = @cLabelLine

                     -- Prepare next screen var
                     SET @cOutField01 = RTRIM( @cCustomNo)
                     SET @cOutField02 = CAST( CAST( @cLabelLine AS INT) AS NVARCHAR(5)) + '/' + CAST( @nCartonSKU AS NVARCHAR(5))
                     SET @cOutField03 = '' -- SKU
                     SET @cMobBarcode = '' --Clear v_barcode
                     SET @cOutField04 = @cSKU
                     SET @cOutField05 = rdt.rdtFormatString( @cSKUDescr, 1, 20)
                     SET @cOutField06 = rdt.rdtFormatString( @cSKUDescr, 21, 20)
                     SET @cOutField07 = CAST( @nPackedQTY AS NVARCHAR( 8))    -- ZG02
                     SET @cOutField08 = @cDefaultQTY -- QTY --(cc01)
                     SET @cOutField09 = CAST( @nCartonQTY AS NVARCHAR( 5))
                     SET @cOutField10 = CASE WHEN @cPrePackIndicator = '2' THEN @cPackQtyIndicator ELSE '' END
                     SET @cOutField11 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END
                     SET @cOutField12 = rdt.rdtRightAlign( @cPUOM_Desc, 5)
                     SET @cOutField13 = rdt.rdtRightAlign( @cMUOM_Desc, 5)
                     SET @cOutField14 = '' -- PQTY

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

                     -- Extended info
                     IF @cExtendedInfoSP <> ''
                     BEGIN
                        IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedInfoSP AND type = 'P')
                        BEGIN
                           INSERT INTO @tVar (Variable, Value) VALUES
                              ('@cPickSlipNo',     @cPickSlipNo),
                              ('@cFromDropID',     @cFromDropID),
                              ('@nCartonNo',       CAST( @nCartonNo AS NVARCHAR( 10))),
                              ('@cLabelNo',        @cLabelNo),
                              ('@cSKU',            @cSKU),
                              ('@nQTY',            CAST( @nQTY AS NVARCHAR( 10))),
                              ('@cUCCNo',          @cUCCNo),
                              ('@cCartonType',     @cCartonType),
                              ('@cCube',           @cCube),
                              ('@cWeight',         @cWeight),
                              ('@cRefNo',          @cRefNo),
                              ('@cSerialNo',       @cSerialNo),
                              ('@nSerialQTY',      CAST( @nSerialQTY AS NVARCHAR( 10))),
                              ('@cOption',         @cOption),
                              ('@cPackDtlRefNo',   @cPackDtlRefNo),
                              ('@cPackDtlRefNo2',  @cPackDtlRefNo2),
                              ('@cPackDtlUPC',     @cPackDtlUPC),
                              ('@cPackDtlDropID',  @cPackDtlDropID),
                              ('@cPackData1',      @cPackData1),
                              ('@cPackData2',      @cPackData2),
                              ('@cPackData3',      @cPackData3)

                           SET @cExtendedInfo = ''
                           SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
                              ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @tVar, ' +
                              ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '
                           SET @cSQLParam =
                              ' @nMobile        INT,           ' +
                              ' @nFunc          INT,           ' +
                              ' @cLangCode      NVARCHAR( 3),  ' +
                              ' @nStep          INT,           ' +
                              ' @nAfterStep     INT,           ' +
                              ' @nInputKey      INT,           ' +
                              ' @cFacility      NVARCHAR( 5),  ' +
                              ' @cStorerKey     NVARCHAR( 15), ' +
                              ' @tVar           VariableTable READONLY, ' +
                              ' @cExtendedInfo  NVARCHAR( 20) OUTPUT,   ' +
                              ' @nErrNo         INT           OUTPUT,   ' +
                              ' @cErrMsg        NVARCHAR( 20) OUTPUT    '

                           EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                              @nMobile, @nFunc, @cLangCode, 3, @nCurrentStep, @nInputKey, @cFacility, @cStorerKey, @tVar,
                              @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                           IF @nErrNo <> 0
                              GOTO Quit

                           IF @nCurrentStep = 99 AND @nCurrentScn = 6862
                              SET @cOutField15 = @cExtendedInfo
                        END
                     END

                     GOTO SCN_6862_FAIL
                  END
               END

               -- Check SKU blank
               IF @cUPCBarcode = ''
               BEGIN
                  SET @nErrNo = 100206
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Need SKU
                  GOTO SCN_6862_FAIL
               END

               -- Validate SKU
               IF @cUPCBarcode <> ''
               BEGIN
                  -- Decode
                  IF @cDecodeSP <> ''
                  BEGIN
                     SET @cPackDtlRefNo  = ''
                     SET @cPackDtlRefNo2 = ''
                     SET @cPackDtlUPC    = ''
                     SET @cPackDtlDropID_Decode = ''

                     -- Standard decode
                     IF @cDecodeSP = '1'
                     BEGIN
                        EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nCurrentStep, @nInputKey, @cStorerKey, @cFacility, @cUPCBarcode,
                           @cUPC          = @cUPC           OUTPUT,
                           @nQTY          = @nDecodeQTY     OUTPUT,
                           @cUserDefine01 = @cPackDtlRefNo  OUTPUT,
                           @cUserDefine02 = @cPackDtlRefNo2 OUTPUT,
                           @cUserDefine03 = @cPackDtlUPC    OUTPUT,
                           @cUserDefine04 = @cPackDtlDropID_Decode OUTPUT,
                           @cSerialNo     = @cSerialNo      OUTPUT,
                           @nErrNo        = 0, --@nErrNo     OUTPUT,
                           @cErrMsg       = '' --@cErrMsg    OUTPUT
                     END

                     -- Customize decode
                     ELSE IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cDecodeSP AND type = 'P')
                     BEGIN
                        SET @cSQL = 'EXEC rdt.' + RTRIM( @cDecodeSP) +
                           ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, @cUPCBarcode, @cBarcode2, ' +
                           ' @cSKU OUTPUT, @nQTY OUTPUT, @cPackDtlRefNo OUTPUT, @cPackDtlRefNo2 OUTPUT, @cPackDtlUPC OUTPUT, @cPackDtlDropID OUTPUT, @cSerialNo OUTPUT, ' +
                           ' @cFromDropIDDecode OUTPUT, @cToDropIDDecode OUTPUT, @cUCCNo OUTPUT, ' +
                           ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
                        SET @cSQLParam =
                           ' @nMobile           INT,           ' +
                           ' @nFunc             INT,           ' +
                           ' @cLangCode         NVARCHAR( 3),  ' +
                           ' @nStep             INT,           ' +
                           ' @nInputKey         INT,           ' +
                           ' @cFacility         NVARCHAR( 5),  ' +
                           ' @cStorerKey        NVARCHAR( 15), ' +
                           ' @cPickSlipNo       NVARCHAR( 10), ' +
                           ' @cFromDropID       NVARCHAR( 20), ' +
                           ' @cUPCBarcode       NVARCHAR( 2000), ' +
                           ' @cBarcode2         NVARCHAR( 60), ' +
                           ' @cSKU              NVARCHAR( 30)  OUTPUT, ' +
                           ' @nQTY              INT            OUTPUT, ' +
                           ' @cPackDtlRefNo     NVARCHAR( 20)  OUTPUT, ' +
                           ' @cPackDtlRefNo2    NVARCHAR( 20)  OUTPUT, ' +
                           ' @cPackDtlUPC       NVARCHAR( 30)  OUTPUT, ' +
                           ' @cPackDtlDropID    NVARCHAR( 20)  OUTPUT, ' +
                           ' @cSerialNo         NVARCHAR( 30)  OUTPUT, ' +
                           ' @cFromDropIDDecode NVARCHAR( 30)  OUTPUT, ' +
                           ' @cToDropIDDecode   NVARCHAR( 30)  OUTPUT, ' +
                           ' @cUCCNo            NVARCHAR( 30)  OUTPUT, ' +
                           ' @nErrNo            INT            OUTPUT, ' +
                           ' @cErrMsg           NVARCHAR( 20)  OUTPUT'

                        EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                           @nMobile, @nFunc, @cLangCode, @nCurrentStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, @cUPCBarcode, @cBarcode2,
                           @cUPC OUTPUT, @nQTY OUTPUT, @cPackDtlRefNo OUTPUT, @cPackDtlRefNo2 OUTPUT, @cPackDtlUPC OUTPUT, @cPackDtlDropID_Decode OUTPUT, @cSerialNo OUTPUT, 
                           @cFromDropIDDecode OUTPUT, @cToDropIDDecode OUTPUT, @cUCCNo OUTPUT,
                           @nErrNo OUTPUT, @cErrMsg OUTPUT

                        IF @nErrNo <> 0
                           GOTO SCN_6862_FAIL

                        IF ISNULL( @nQTY, 0) > 0
                           SET @nDecodeQTY = @nQTY
                     END

                     IF @cPackDtlDropID_Decode <> ''
                        SET @cPackDtlDropID = @cPackDtlDropID_Decode
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

                  -- Check SKU valid
                  IF @nSKUCnt = 0
                  BEGIN
                     SET @nErrNo = 100207
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid SKU
                     GOTO SCN_6862_FAIL
                  END

                  -- Check barcode return multi SKU
                  IF @nSKUCnt > 1
                  BEGIN
                     IF @cMultiSKUBarcode IN ('1', '2')
                     BEGIN
                        EXEC rdt.rdt_MultiSKUBarcode @nMobile, @nFunc, @cLangCode,
                           @cInField01 OUTPUT,  @cOutField01 OUTPUT,
                           @cInField02 OUTPUT,  @cOutField02 OUTPUT,
                           @cInField03 OUTPUT,  @cOutField03 OUTPUT,
                           @cInField04 OUTPUT,  @cOutField04 OUTPUT,
                           @cInField05 OUTPUT,  @cOutField05 OUTPUT,
                           @cInField06 OUTPUT,  @cOutField06 OUTPUT,
                           @cInField07 OUTPUT,  @cOutField07 OUTPUT,
                           @cInField08 OUTPUT,  @cOutField08 OUTPUT,
                           @cInField09 OUTPUT,  @cOutField09 OUTPUT,
                           @cInField10 OUTPUT,  @cOutField10 OUTPUT,
                           @cInField11 OUTPUT,  @cOutField11 OUTPUT,
                           @cInField12 OUTPUT,  @cOutField12 OUTPUT,
                           @cInField13 OUTPUT,  @cOutField13 OUTPUT,
                           @cInField14 OUTPUT,  @cOutField14 OUTPUT,
                           @cInField15 OUTPUT,  @cOutField15 OUTPUT,
                           'POPULATE',
                           @cMultiSKUBarcode,
                           @cStorerKey,
                           @cUPC     OUTPUT,
                           @nErrNo   OUTPUT,
                           @cErrMsg  OUTPUT,
                           'PICKSLIPNO',    -- DocType
                           @cPickSlipNo

                        IF @nErrNo = 0 -- Populate multi SKU screen
                        BEGIN
                           -- Go to Multi SKU screen
                           SET @cMobBarcode = '' -- clear v_barcode
                           SET @nFromScn = @nScn
                           SET @nAfterScn = 3570
                           SET @nAfterStep = @nStep + 8
                           GOTO Quit
                        END
                        IF @nErrNo = -1 -- Found in Doc, skip multi SKU screen
                        BEGIN
                           SET @nErrNo = 0
                           SET @cSKU = @cUPC
                        END
                     END
                     ELSE
                     BEGIN
                        SET @nErrNo = 100208
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MultiSKUBarcod
                        GOTO SCN_6862_FAIL
                     END
                  END

                  IF @nSKUCnt = 1
                     EXEC rdt.rdt_GetSKU
                        @cStorerKey  = @cStorerKey
                        ,@cSKU        = @cUPC      OUTPUT
                        ,@bSuccess    = @bSuccess  OUTPUT
                        ,@nErr        = @nErrNo    OUTPUT
                        ,@cErrMsg     = @cErrMsg   OUTPUT

                  SET @cSKU = @cUPC

                  -- Get SKU info
                  SELECT
                     @cSKUDescr = Descr,
                     @cSKUDataCapture = DataCapture,
                     @cPrePackIndicator = ISNULL( PrePackIndicator, ''),
                     @cPackQtyIndicator = LEFT( ISNULL( PackQtyIndicator, '0'), 3),
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

                  -- Get PackDetail info
                  SET @nPackedQTY = 0
                  SELECT @nPackedQTY = QTY
                  FROM PackDetail PD WITH (NOLOCK)
                  WHERE PD.PickSlipNo = @cPickSlipNo
                     AND PD.CartonNo = @nCartonNo -- Could be 0, no record
                     AND PD.SKU = @cSKU

                  -- Disable QTY field (cc03)
                  IF @cDisableQTYFieldSP <> ''
                  BEGIN
                     IF @cDisableQTYFieldSP = '1'
                     BEGIN
                        SET @cDisableQTYField = @cDisableQTYFieldSP
                     END
                     ELSE
                     BEGIN
                        IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cDisableQTYFieldSP AND type = 'P')
                        BEGIN
                           SET @cSQL = 'EXEC rdt.' + RTRIM( @cDisableQTYFieldSP) +
                           ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, ' +
                           ' @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption, ' +
                           ' @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, @cPackData1, @cPackData2, @cPackData3, ' +
                           ' @tVarDisableQTYField, @cDisableQTYField OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '
                           SET @cSQLParam =
                           '@nMobile            INT,           ' +
                           '@nFunc              INT,           ' +
                           '@cLangCode          NVARCHAR( 3),  ' +
                           '@nStep              INT,           ' +
                           '@nInputKey          INT,           ' +
                           '@cFacility          NVARCHAR( 5),  ' +
                           '@cStorerKey         NVARCHAR( 15), ' +
                           '@cPickSlipNo        NVARCHAR( 10), ' +
                           '@cFromDropID        NVARCHAR( 20), ' +
                           '@nCartonNo          INT,           ' +
                           '@cLabelNo           NVARCHAR( 20), ' +
                           '@cSKU               NVARCHAR( 20), ' +
                           '@nQTY               INT,           ' +
                           '@cUCCNo             NVARCHAR( 20), ' +
                           '@cCartonType        NVARCHAR( 10), ' +
                           '@cCube              NVARCHAR( 10), ' +
                           '@cWeight            NVARCHAR( 10), ' +
                           '@cRefNo             NVARCHAR( 20), ' +
                           '@cSerialNo          NVARCHAR( 30), ' +
                           '@nSerialQTY         INT,           ' +
                           '@cOption            NVARCHAR( 1),  ' +
                           '@cPackDtlRefNo      NVARCHAR( 20), ' +
                           '@cPackDtlRefNo2     NVARCHAR( 20), ' +
                           '@cPackDtlUPC        NVARCHAR( 30), ' +
                           '@cPackDtlDropID     NVARCHAR( 20), ' +
                           '@cPackData1         NVARCHAR( 30), ' +
                           '@cPackData2         NVARCHAR( 30), ' +
                           '@cPackData3         NVARCHAR( 30), ' +
                           '@tVarDisableQTYField VariableTable READONLY, ' +
                           '@cDisableQTYField   NVARCHAR( 1)   OUTPUT, ' +
                           '@nErrNo             INT            OUTPUT, ' +
                           '@cErrMsg            NVARCHAR( 20)  OUTPUT'

                           EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                              @nMobile, @nFunc, @cLangCode, @nCurrentStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID,
                              @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption,
                              @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, @cPackData1, @cPackData2, @cPackData3,
                              @tVarDisableQTYField, @cDisableQTYField OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                           IF @nErrNo <> 0
                              GOTO SCN_6862_FAIL
                        END
                     END
                  END
                  --(V7.5) start
                  IF @cPrePackIndicator = '2'
                  BEGIN
                     DECLARE @cSkipChkPPKQTYSP NVARCHAR( 20) = 0
                     SET @cSkipChkPPKQTYSP = rdt.RDTGetConfig( @nFunc, 'SkipChkPPKQTYSP', @cStorerKey)
                     IF @cSkipChkPPKQTYSP = '0'
                        SET @cSkipChkPPKQTYSP = ''

                     IF @cSkipChkPPKQTYSP <> ''
                     BEGIN
                        IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cSkipChkPPKQTYSP AND type = 'P')
                        BEGIN
                           SET @cSQL = 'EXEC rdt.' + RTRIM( @cSkipChkPPKQTYSP) +
                           ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, ' +
                           ' @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption, ' +
                           ' @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, @cPackData1, @cPackData2, @cPackData3, ' +
                           ' @tVarDisableQTYField, @cSkipChkPPKQTY OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '
                           SET @cSQLParam =
                           '@nMobile            INT,           ' +
                           '@nFunc              INT,           ' +
                           '@cLangCode          NVARCHAR( 3),  ' +
                           '@nStep              INT,           ' +
                           '@nInputKey          INT,           ' +
                           '@cFacility          NVARCHAR( 5),  ' +
                           '@cStorerKey         NVARCHAR( 15), ' +
                           '@cPickSlipNo        NVARCHAR( 10), ' +
                           '@cFromDropID        NVARCHAR( 20), ' +
                           '@nCartonNo          INT,           ' +
                           '@cLabelNo           NVARCHAR( 20), ' +
                           '@cSKU               NVARCHAR( 20), ' +
                           '@nQTY               INT,           ' +
                           '@cUCCNo             NVARCHAR( 20), ' +
                           '@cCartonType        NVARCHAR( 10), ' +
                           '@cCube              NVARCHAR( 10), ' +
                           '@cWeight            NVARCHAR( 10), ' +
                           '@cRefNo             NVARCHAR( 20), ' +
                           '@cSerialNo          NVARCHAR( 30), ' +
                           '@nSerialQTY         INT,           ' +
                           '@cOption            NVARCHAR( 1),  ' +
                           '@cPackDtlRefNo      NVARCHAR( 20), ' +
                           '@cPackDtlRefNo2     NVARCHAR( 20), ' +
                           '@cPackDtlUPC        NVARCHAR( 30), ' +
                           '@cPackDtlDropID     NVARCHAR( 20), ' +
                           '@cPackData1         NVARCHAR( 30), ' +
                           '@cPackData2         NVARCHAR( 30), ' +
                           '@cPackData3         NVARCHAR( 30), ' +
                           '@tVarDisableQTYField VariableTable READONLY, ' +
                           '@cSkipChkPPKQTY     NVARCHAR( 1)   OUTPUT, ' +
                           '@nErrNo             INT            OUTPUT, ' +
                           '@cErrMsg            NVARCHAR( 20)  OUTPUT'

                           EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                              @nMobile, @nFunc, @cLangCode, @nCurrentStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID,
                              @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption,
                              @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, @cPackData1, @cPackData2, @cPackData3,
                              @tVarDisableQTYField, @cSkipChkPPKQTY OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                           IF @nErrNo <> 0
                              GOTO SCN_6862_FAIL
                        END
                     END
                  END
                  --(V7.5) end

                  -- (james01)
                  -- Extended info
                  IF @cExtendedInfoSP <> ''
                  BEGIN
                     IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedInfoSP AND type = 'P')
                     BEGIN
                        INSERT INTO @tVar (Variable, Value) VALUES
                           ('@cPickSlipNo',     @cPickSlipNo),
                           ('@cFromDropID',     @cFromDropID),
                           ('@nCartonNo',       CAST( @nCartonNo AS NVARCHAR( 10))),
                           ('@cLabelNo',        @cLabelNo),
                           ('@cSKU',            @cSKU),
                           ('@nQTY',            CAST( @nQTY AS NVARCHAR( 10))),
                           ('@cUCCNo',          @cUCCNo),
                           ('@cCartonType',     @cCartonType),
                           ('@cCube',           @cCube),
                           ('@cWeight',         @cWeight),
                           ('@cRefNo',          @cRefNo),
                           ('@cSerialNo',       @cSerialNo),
                           ('@nSerialQTY',      CAST( @nSerialQTY AS NVARCHAR( 10))),
                           ('@cOption',         @cOption),
                           ('@cPackDtlRefNo',   @cPackDtlRefNo),
                           ('@cPackDtlRefNo2',  @cPackDtlRefNo2),
                           ('@cPackDtlUPC',     @cPackDtlUPC),
                           ('@cPackDtlDropID',  @cPackDtlDropID),
                           ('@cPackData1',      @cPackData1),
                           ('@cPackData2',      @cPackData2),
                           ('@cPackData3',      @cPackData3)

                        SET @cExtendedInfo = ''
                        SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
                           ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @tVar, ' +
                           ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '
                        SET @cSQLParam =
                           ' @nMobile        INT,           ' +
                           ' @nFunc          INT,           ' +
                           ' @cLangCode      NVARCHAR( 3),  ' +
                           ' @nStep          INT,           ' +
                           ' @nAfterStep     INT,           ' +
                           ' @nInputKey      INT,           ' +
                           ' @cFacility      NVARCHAR( 5),  ' +
                           ' @cStorerKey     NVARCHAR( 15), ' +
                           ' @tVar           VariableTable READONLY, ' +
                           ' @cExtendedInfo  NVARCHAR( 20) OUTPUT,   ' +
                           ' @nErrNo         INT           OUTPUT,   ' +
                           ' @cErrMsg        NVARCHAR( 20) OUTPUT    '

                        EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                           @nMobile, @nFunc, @cLangCode, 3, @nCurrentStep, @nInputKey, @cFacility, @cStorerKey, @tVar,
                           @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                        IF @nErrNo <> 0
                           GOTO SCN_6862_FAIL

                        IF @nCurrentStep = 99 AND @nCurrentScn = 6862
                           SET @cOutField15 = @cExtendedInfo
                     END
                  END

                  SET @cOutField03 = CASE WHEN @cDisableQTYField = '1' THEN '' ELSE @cSKU END
                  SET @cOutField04 = @cSKU
                  SET @cOutField05 = rdt.rdtFormatString( @cSKUDescr, 1, 20)
                  SET @cOutField06 = rdt.rdtFormatString( @cSKUDescr, 21, 20)
                  SET @cOutField07 = CAST( @nPackedQTY AS NVARCHAR( 8))    -- ZG02
                  SET @cOutField10 = CASE WHEN @cPrePackIndicator = '2' THEN @cPackQtyIndicator ELSE '' END
                  SET @cOutField11 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END
                  SET @cOutField12 = rdt.rdtRightAlign( @cPUOM_Desc, 5)
                  SET @cOutField13 = rdt.rdtRightAlign( @cMUOM_Desc, 5)
                  SET @cOutField14 = '' -- PQTY
                  --SET @cMobBarcode = '' --fcr8765 hotfix, donot clear barcode value. It is used when input sku only

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

                  EXEC rdt.rdtSetFocusField @nMobile, 8
               END

               -- Validate MQTY
               IF @cMQTY <> '' AND RDT.rdtIsValidQTY( @cMQTY, 1) = 0 --Check zero
               BEGIN
                  SET @nErrNo = 100209
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid QTY
                  EXEC rdt.rdtSetFocusField @nMobile, 8 -- QTY
                  GOTO SCN_6862_FAIL
               END

               -- Validate PQTY
               IF @cPQTY <> '' AND RDT.rdtIsValidQTY( @cPQTY, 1) = 0 --Check zero
               BEGIN
                  SET @nErrNo = 100238
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid QTY
                  EXEC rdt.rdtSetFocusField @nMobile, 14 -- QTY
                  GOTO SCN_6862_FAIL
               END

               -- Get QTY
               IF @nDecodeQTY > 0
               BEGIN
                  SET @cQTY = CAST( @nDecodeQTY AS NVARCHAR(8))  -- ZG02
                  SET @nQTY = @nDecodeQTY
               END
               ELSE
               BEGIN
                  IF @cSKU <> '' AND @cDisableQTYField = '1' 
                  BEGIN
                     IF @cPrePackIndicator = '2' AND @cSkipChkPPKQTY = '0'--(v7.5)
                     BEGIN
                        SET @cQTY = @cPackQtyIndicator
                        SET @nQTY = CAST( @cPackQtyIndicator AS INT)
                     END
                     ELSE
                     BEGIN
                        SET @cQTY = '1'
                        SET @nQTY = 1
                     END
                  END
                  ELSE
                  BEGIN
                     -- Calc total QTY in master UOM
                     SET @nQTY = rdt.rdtConvUOMQTY( @cStorerKey, @cSKU, @cPQTY, @cPUOM, 6) -- Convert to QTY in master UOM
                     SET @nQTY = @nQTY + CAST( @cMQTY AS INT)

                     IF @cPrePackIndicator = '2' AND @cSkipChkPPKQTY = '0'--(v7.5)
                     BEGIN
                        SET @nQTY = @nQTY * CAST( @cPackQtyIndicator AS INT)
                        SET @cQTY = CAST( @nQTY AS NVARCHAR(8))  -- ZG02
                     END
                  END
               END

               -- FCR-11343: Check if this is B2C Single flow
               IF @cIsB2CSingle = '1' -- Enter pressed with SKU
               BEGIN
                  -- FCR-11343: Dynamic order fetch - find order containing scanned SKU
                  SET @cFetchedOrderKey = ''

                  IF ISNULL(@cLabelNo, '') <> ''
                  BEGIN
                     SELECT @nPackedDetailPackedQty = SUM(Qty),
                        @nPackedDetailExpQty = SUM(ExpQty)
                     FROM dbo.PackDetail WITH(NOLOCK) 
                     WHERE PickSlipNo = @cPickSlipNo
                        AND LabelNo IS NOT NULL 
                        AND LabelNo = @cLabelNo 

                     -- If current label is pack completed, start a new label; otherwise, validate the label is correct
                     IF @nPackedDetailPackedQty = @nPackedDetailExpQty
                     BEGIN
                        IF EXISTS(SELECT 1 
                              FROM dbo.PackInfo WITH(NOLOCK) 
                              WHERE PickSlipNo = @cPickSlipNo 
                                 AND RefNo IS NOT NULL 
                                 AND RefNo = @cLabelNo
                                 AND CartonStatus = 'PACKED')
                        BEGIN
                           GOTO START_NEW_LABEL
                        END
                        ELSE
                        BEGIN
                           SET @nErrNo = 253221  --  Label is pack done
                           SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                           EXEC rdt.rdtSetFocusField @nMobile, 3
                           SET @cOutField03 = ''  -- Clear SKU field
                           GOTO SCN_6862_FAIL
                        
                        END
                     END

                     IF NOT EXISTS (
                        SELECT 1
                        FROM dbo.PICKDETAIL PD WITH (NOLOCK)
                        INNER JOIN ORDERS O WITH (NOLOCK) ON PD.StorerKey = O.StorerKey AND PD.OrderKey = O.OrderKey
                        INNER JOIN PickHeader PH WITH(NOLOCK) ON PH.StorerKey = PD.StorerKey AND PH.OrderKey = PD.OrderKey
                        INNER JOIN PackDetail PAD WITH (NOLOCK) ON PAD.PickSlipNo = PH.PickHeaderKey AND PAD.LabelNo = PD.CaseID AND PAD.SKU = PD.SKU
                        WHERE PD.CaseID = @cLabelNo
                           AND PD.StorerKey = @cStorerKey
                           AND PD.DropID = @cFromDropID
                           AND PD.SKU = @cSKU
                           AND PD.Status <= @cPickStatus
                           AND PD.QTY > 0
                           AND PAD.Qty < PAD.ExpQty
                           AND O.DocType = 'E'
                           AND O.ECOM_SINGLE_Flag = 'S'
                     )
                     BEGIN
                        SET @nErrNo = 253208  -- SKU is packed or SKU is in different Carton
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                        EXEC rdt.rdtSetFocusField @nMobile, 3
                        SET @cOutField03 = ''  -- Clear SKU field
                        GOTO SCN_6862_FAIL
                     END

                     SELECT TOP 1
                        @cFetchedOrderKey = PD.OrderKey,
                        @cPickSlipNo = PH.PickHeaderKey
                     FROM PICKDETAIL PD WITH (NOLOCK)
                     INNER JOIN ORDERS O WITH (NOLOCK) ON PD.StorerKey = O.StorerKey AND PD.OrderKey = O.OrderKey
                     INNER JOIN PickHeader PH WITH(NOLOCK) ON PH.StorerKey = PD.StorerKey AND PH.OrderKey = PD.OrderKey
                     WHERE PD.DropID = @cFromDropID
                        AND PD.StorerKey = @cStorerKey
                        AND PD.SKU = @cSKU
                        AND PD.Status <= @cPickStatus
                        AND PD.CaseID = @cLabelNo
                        AND PD.QTY > 0
                        AND O.DocType = 'E'
                        AND O.ECOM_SINGLE_Flag = 'S'
                        AND PD.CaseID <> ''
                        AND PD.CaseID IS NOT NULL
                        AND PD.CaseID <> PD.DropID
                     ORDER BY PD.OrderKey

                     -- Validate order was found
                     IF @cFetchedOrderKey = '' OR @cPickSlipNo = ''
                     BEGIN
                        SET @nErrNo = 253209  -- SKU not found in DropID
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                        EXEC rdt.rdtSetFocusField @nMobile, 3
                        SET @cOutField03 = ''  -- Clear SKU field
                        GOTO SCN_6862_FAIL
                     END

                     SELECT TOP 1
                        @nCartonNo = CartonNo,
                        @cCartonType = ISNULL(CartonType, ''),
                        @cWeight = rdt.rdtFormatFloat(ISNULL(Weight, 0)),
                        @cCube = rdt.rdtFormatFloat(ISNULL([Cube], 0))
                     FROM dbo.PACKINFO WITH (NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                        AND RefNo IS NOT NULL 
                        AND RefNo = @cLabelNo

                     IF @nCartonNo IS NULL OR @nCartonNo = 0
                     BEGIN
                        SET @nErrNo = 253210  -- PackInfo not found
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                        EXEC rdt.rdtSetFocusField @nMobile, 3
                        GOTO SCN_6862_FAIL
                     END

                     IF NOT EXISTS(SELECT 1 FROM dbo.PACKDETAIL WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo AND SKU = @cSKU AND LabelNo = @cLabelNo AND Qty < ExpQty)
                     BEGIN
                        SET @nErrNo = 253211
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --  SKU is packed
                        EXEC rdt.rdtSetFocusField @nMobile, 3
                        GOTO SCN_6862_FAIL
                     END
                  END
                  ELSE
                  BEGIN
                     START_NEW_LABEL:
                     SELECT TOP 1
                        @cFetchedOrderKey = PD.OrderKey,
                        @cPickSlipNo = PH.PickHeaderKey,
                        @cLabelNo = PD.CaseID
                     FROM PICKDETAIL PD WITH (NOLOCK)
                     INNER JOIN dbo.ORDERS O WITH (NOLOCK) ON PD.StorerKey = O.StorerKey AND PD.OrderKey = O.OrderKey
                     INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON PH.StorerKey = PD.StorerKey AND PH.OrderKey = PD.OrderKey
                     INNER JOIN dbo.PackDetail PAD WITH(NOLOCK) ON PH.StorerKey = PAD.StorerKey AND PH.PickHeaderKey = PAD.PickSLipNo
                     WHERE PD.DropID = @cFromDropID
                        AND PD.StorerKey = @cStorerKey
                        AND PD.SKU = @cSKU
                        AND PD.Status <= @cPickStatus
                        AND PD.QTY > 0
                        AND O.DocType = 'E'
                        AND O.ECOM_SINGLE_Flag = 'S'
                        AND PD.CaseID <> ''
                        AND PD.CaseID IS NOT NULL
                        AND PD.CaseID <> PD.DropID
                        AND PAD.Qty < PAD.ExpQty
                     ORDER BY PD.OrderKey

                     -- Validate order was found
                     IF @cFetchedOrderKey = '' OR @cPickSlipNo = ''
                     BEGIN
                        SET @nErrNo = 253203  -- SKU not found in DropID
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                        EXEC rdt.rdtSetFocusField @nMobile, 3
                        SET @cOutField03 = ''  -- Clear SKU field
                        GOTO SCN_6862_FAIL
                     END

                     -- FCR-11343: Fetch PACKINFO (precartonized)
                     SELECT TOP 1
                        @nCartonNo = CartonNo,
                        @cCartonType = ISNULL(CartonType, ''),
                        @cWeight = rdt.rdtFormatFloat(ISNULL(Weight, 0)),
                        @cCube = rdt.rdtFormatFloat(ISNULL([Cube], 0))
                     FROM dbo.PACKINFO WITH (NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                        AND RefNo IS NOT NULL 
                        AND RefNo = @cLabelNo

                     IF @nCartonNo IS NULL OR @nCartonNo = 0
                     BEGIN
                        SET @nErrNo = 253206  -- PackInfo not found
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                        EXEC rdt.rdtSetFocusField @nMobile, 3
                        GOTO SCN_6862_FAIL
                     END

                     IF NOT EXISTS(SELECT 1 FROM dbo.PACKDETAIL WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo AND SKU = @cSKU AND LabelNo = @cLabelNo AND Qty < ExpQty)
                     BEGIN
                        SET @nErrNo = 253207
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --  SKU is packed
                        EXEC rdt.rdtSetFocusField @nMobile, 3
                        GOTO SCN_6862_FAIL
                     END
                  END

                  -- Confirm
                  EXEC RDT.rdt_Pack_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
                     ,@cPickSlipNo    = @cPickSlipNo
                     ,@cFromDropID    = @cFromDropID
                     ,@cSKU           = @cSKU
                     ,@nQTY           = @nQTY
                     ,@cUCCNo         = '' -- @cUCCNo
                     ,@cSerialNo      = '' -- @cSerialNo
                     ,@nSerialQTY     = 0  -- @nSerialQTY
                     ,@cPackDtlRefNo  = @cPackDtlRefNo
                     ,@cPackDtlRefNo2 = @cPackDtlRefNo2
                     ,@cPackDtlUPC    = @cPackDtlUPC
                     ,@cPackDtlDropID = @cPackDtlDropID
                     ,@nCartonNo      = @nCartonNo    OUTPUT
                     ,@cLabelNo       = @cLabelNo     OUTPUT
                     ,@nErrNo         = @nErrNo       OUTPUT
                     ,@cErrMsg        = @cErrMsg      OUTPUT
                     ,@nBulkSNO       = 0
                     ,@nBulkSNOQTY    = 0
                     ,@cPackData1     = @cPackData1
                     ,@cPackData2     = @cPackData2
                     ,@cPackData3     = @cPackData3
                  IF @nErrNo <> 0
                     GOTO SCN_6862_FAIL

                  SELECT @nRemainQTY = SUM(PAD.ExpQty - PAD.Qty)
                  FROM dbo.PackDetail PAD WITH (NOLOCK)
                  INNER JOIN dbo.PICKHEADER PKH WITH (NOLOCK) ON PAD.PickSlipNo = PKH.PickHeaderKey AND PAD.StorerKey = PKH.StorerKey
                  INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON PAD.LabelNo = PKD.CaseID AND PAD.SKU = PKD.SKU AND PKH.OrderKey = PKD.OrderKey
                  WHERE PKD.DropID = @cFromDropID
                     AND PKD.StorerKey = @cStorerKey
                     AND PAD.Qty = 0

                  SELECT
                     @cSKUDescr = Descr,
                     @cSKUDataCapture = DataCapture,
                     @cPrePackIndicator = ISNULL( PrePackIndicator, ''),
                     @cPackQtyIndicator = LEFT( ISNULL( PackQtyIndicator, '0'), 3),
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

                  SET @nRemainQTY = ISNULL(@nRemainQTY, 0)

                  SET @cOutField01 = @cLabelNo
                  SET @cOutField02 = @cSku
                  SET @cMobBarcode = '' -- clear V_barcode
                  SET @cOutField03 = rdt.rdtFormatString( @cSKUDescr, 1, 20)
                  SET @cOutField04 = rdt.rdtFormatString( @cSKUDescr, 21, 20)
                  SET @cOutField05 = ISNULL(TRY_CAST( @nRemainQTY AS NVARCHAR( 8)), '')
                  SET @cOutField08 = CASE WHEN @cDisableQTYField = '1' THEN @cQTY ELSE @cDefaultQTY END
                  SET @cOutField09 = ''
                  SET @cOutField10 = ''
                  SET @cOutField11 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END
                  SET @cOutField12 = rdt.rdtRightAlign( @cPUOM_Desc, 5)
                  SET @cOutField13 = rdt.rdtRightAlign( @cMUOM_Desc, 5)
                  SET @cOutField14 = ''

                   -- Enable field
                  SET @cFieldAttr08 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END

                  EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU field
                  --Reset 
                  SET @nEnter = 0
               END
               -- End FCR-11343 B2C Single handling
            END
            ELSE IF @nInputKey = 0
            BEGIN
               -- Packed
               IF EXISTS( SELECT 1 FROM dbo.PackDetail WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND LabelNo = @cLabelNo AND Qty > 0)
                  AND NOT EXISTS (SELECT 1 FROM dbo.PackDetail WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND LabelNo = @cLabelNo AND Qty = 0)
                  AND EXISTS (SELECT 1 FROM dbo.PickDetail PD WITH (NOLOCK)
                              INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON PD.StorerKey = PH.StorerKey AND PD.OrderKey = PH.OrderKey
                              WHERE PH.PickHeaderKey = @cPickSlipNo 
                                 AND PD.CaseID = @cLabelNo
                                 AND PD.StorerKey = @cStorerKey
                                 AND PD.CaseID <> PD.DropID)
               BEGIN
                  -- Custom PackInfo field setup
                  SET @cPackInfo = ''
                  IF @cCapturePackInfoSP <> ''
                  BEGIN
                     -- Custom SP to get PackInfo setup
                     IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cCapturePackInfoSP AND type = 'P')
                     BEGIN
                        SET @cSQL = 'EXEC rdt.' + RTRIM( @cCapturePackInfoSP) +
                           ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, @nCartonNo, @cLabelNo, ' +
                           ' @nErrNo      OUTPUT, ' +
                           ' @cErrMsg     OUTPUT, ' +
                           ' @cPackInfo   OUTPUT, ' +
                           ' @cWeight     OUTPUT, ' +
                           ' @cCube       OUTPUT, ' +
                           ' @cRefNo      OUTPUT, ' +
                           ' @cCartonType OUTPUT'
                        SET @cSQLParam =
                           '@nMobile     INT,           ' +
                           '@nFunc       INT,           ' +
                           '@cLangCode   NVARCHAR( 3),  ' +
                           '@nStep       INT,           ' +
                           '@nInputKey   INT,           ' +
                           '@cFacility   NVARCHAR( 5),  ' +
                           '@cStorerKey  NVARCHAR( 15), ' +
                           '@cPickSlipNo NVARCHAR( 10), ' +
                           '@cFromDropID NVARCHAR( 20), ' +
                           '@nCartonNo   INT,           ' +
                           '@cLabelNo    NVARCHAR( 20), ' +
                           '@nErrNo      INT           OUTPUT, ' +
                           '@cErrMsg     NVARCHAR( 20) OUTPUT, ' +
                           '@cPackInfo   NVARCHAR( 3)  OUTPUT, ' +
                           '@cWeight     NVARCHAR( 10) OUTPUT, ' +
                           '@cCube       NVARCHAR( 10) OUTPUT, ' +
                           '@cRefNo      NVARCHAR( 20) OUTPUT, ' +
                           '@cCartonType NVARCHAR( 10) OUTPUT  '

                        EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                           @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, @nCartonNo, @cLabelNo,
                           @nErrNo      OUTPUT,
                           @cErrMsg     OUTPUT,
                           @cPackInfo   OUTPUT,
                           @cWeight     OUTPUT,
                           @cCube       OUTPUT,
                           @cRefNo      OUTPUT,
                           @cCartonType OUTPUT
                     END
                     ELSE
                        -- Setup is non SP
                        SET @cPackInfo = @cCapturePackInfoSP
                  END

                  -- Capture pack info
                  IF @cPackInfo <> ''
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
                     SET @cOutField01 = CASE WHEN ISNULL(TRIM(@cCartonType) ,'') ='' AND ISNULL(@cDefaultcartontype,'')<>''  THEN @cDefaultcartontype ELSE @cCartonType end
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

                     --Reset 
                     SET @nEnter = 0

                     -- Go to next screen
                     SET @nAfterScn = 4653
                     SET @nAfterStep = 99
                  END
               END
               ELSE
               BEGIN
                  SET @cOutField01 = CASE WHEN @cShowPickSlipNo = '1' THEN @cPickSlipNo ELSE '' END -- PickSlipNo (james17)
                  SET @cOutField02 = '' -- FromDropID
                  SET @cOutField03 = '' -- ToDropID

                  --(v7.5) start
                  IF @cFromDropID <> ''
                     EXEC rdt.rdtSetFocusField @nMobile, 2  -- FromDropID
                  ELSE
                  BEGIN
                     IF @cPackDtlDropID <> ''
                        EXEC rdt.rdtSetFocusField @nMobile, 3 -- ToDropID
                     ELSE
                        EXEC rdt.rdtSetFocusField @nMobile, 1  -- PickSlipNo
                  END
                  
                  --SET @nAfterScn = 4650
                  --SET @nAfterStep = 1
                  --V1.2
                  SET @nAfterScn = 6865
                  SET @nAfterStep = 99
               END
            END
            GOTO Quit

            SCN_6862_FAIL:
            BEGIN
               IF rdt.RDTGetConfig( @nFunc, 'ShowErrMsgInNewScn', @cStorerkey) = '1'
               BEGIN
                  EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg
               END

               SET @cOutField01 = @cLabelNo
               SET @cOutField02 = @cSku
               SET @cMobBarcode = '' -- clear V_barcode
               SET @cOutField03 = rdt.rdtFormatString( @cSKUDescr, 1, 20)
               SET @cOutField04 = rdt.rdtFormatString( @cSKUDescr, 21, 20)
               SET @cOutField05 = ISNULL(TRY_CAST( @nRemainQTY AS NVARCHAR( 8)), '')
               SET @cOutField08 = CASE WHEN @cDisableQTYField = '1' THEN @cQTY ELSE @cDefaultQTY END
               SET @cOutField09 = ''
               SET @cOutField10 = ''
               SET @cOutField11 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END
               SET @cOutField12 = rdt.rdtRightAlign( @cPUOM_Desc, 5)
               SET @cOutField13 = rdt.rdtRightAlign( @cMUOM_Desc, 5)
               SET @cOutField14 = ''

                  -- Enable field
               SET @cFieldAttr08 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END

               EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU field
               --Reset 
               SET @nEnter = 0
               GOTO Quit
            END
         END
         /************************************************************************************
         Scn = 6865. PickSlipNo screen
            PSNO        (field01, input)
            FROMDROPID  (field02, input)
            TODROPID    (field03, input)
         ************************************************************************************/
         ELSE IF @nCurrentScn = 6865 --New St1 screen V1.2.0 start
         BEGIN
            IF @nInputKey = 0
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'St99, Scn6865, ESC'

               --Back to Menu
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
               SET @cOutField01 = ''
               SET @cOutField02 = ''
               SET @cOutField03 = ''
               SET @cB2BUoM6Flag = ''

               SET @nAfterScn  = @nMenu
               SET @nAfterStep = 0
               SET @nFunc = @nMenu
               SET @cUDF01 = 'NO UPD RDTMOBREC'
            END -- ESC

            IF @nInputKey = 1
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'St99, Scn6865, Enter'

               -- Screen mapping
               SET @cPickSlipNo = @cInField01
               SET @cFromDropID = @cInField02
               SET @cPackDtlDropID = @cInField03
               SET @cBarcode = @cInField02
               SET @cBarcode2 = @cInField03
               SET @cFromDropIDDecode = ''
               SET @cToDropIDDecode = ''
               SET @cB2BUoM6Flag = ''

               IF ISNULL(@cPackDtlDropID, '') <> ''
               BEGIN
                  SET @nErrNo = 253215
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ToDropID not support
                  GOTO Quit
               END

               IF @cPackByFromDropID <> '1'
               BEGIN
                  SET @nErrNo = 253219
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Enable PackByFromDropID
                  GOTO Quit
               END 

               -- Check blank
               IF @cPickSlipNo = '' AND @cFromDropID = ''
               BEGIN
                  SET @nErrNo = 253212
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need PS/DropID
                  GOTO Quit
               END

               IF @cPickSlipNo <> '' AND @cFromDropID <> ''
               BEGIN
                  SET @nErrNo = 253213
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need PS/DropID
                  GOTO Quit
               END

               --FCR-12450 logic
               IF ISNULL(@cPickSlipNo, '') <> ''
               BEGIN
                  IF EXISTS (SELECT 1 FROM dbo.PickHeader WITH (NOLOCK) WHERE PickHeaderKey = @cPickSlipNo)
                  BEGIN
                     IF NOT EXISTS (SELECT 1 
                                    FROM dbo.Orders ORM WITH (NOLOCK)
                                    JOIN dbo.PickHeader PH WITH (NOLOCK)
                                       ON ORM.StorerKey = PH.StorerKey
                                       AND ORM.OrderKey = PH.OrderKey
                                    WHERE PH.StorerKey = @cStorerKey
                                       AND PickHeaderKey = @cPickSlipNo
                                       AND doctype = 'N')
                     BEGIN
                        SET @nErrNo = 253214
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Not B2B
                        GOTO Quit
                     END -- not b2b order
                  END

                  IF @nDebugFlag = 1
                     SELECT 'Merge pickdetail to one drop id' 

                  DECLARE @tPD TABLE
                  (
                     PickDetailKey     NVARCHAR(18),
                     OrderKey          NVARCHAR(10),
                     OrderLineNumber   NVARCHAR(5),
                     Lot               NVARCHAR(10),
                     SKU               NVARCHAR(20),
                     DropID            NVARCHAR(20),
                     Loc               NVARCHAR(10),
                     ID                NVARCHAR(18),
                     Qty               INT,
                     PRIMARY KEY CLUSTERED (PickDetailKey)
                  )

                  -- FCR-12450: Insert PickDetail records where UOM = '6'
                  INSERT INTO @tPD (PickDetailKey, OrderKey, OrderLineNumber, Lot, SKU, DropID, Loc, ID, Qty)
                  SELECT PD.PickDetailKey, PD.OrderKey, PD.OrderLineNumber, PD.Lot, PD.SKU, PD.DropID, PD.Loc, PD.ID, PD.Qty
                  FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.PickHeader PH WITH (NOLOCK) 
                     ON PD.StorerKey = PH.StorerKey AND PD.OrderKey = PH.OrderKey
                  WHERE PH.PickHeaderKey = @cPickSlipNo
                    AND PD.UOM = '6'
                    AND PD.Status = @cPickStatus

                  IF @@ROWCOUNT > 0
                  BEGIN
                     -- Get OrderKey from PickHeader
                     DECLARE @cMergeOrderKey NVARCHAR(10)
                     SELECT @cMergeOrderKey = OrderKey
                     FROM dbo.PickHeader WITH (NOLOCK)
                     WHERE PickHeaderKey = @cPickSlipNo

                     -- Update DropID to OrderKey in temp table
                     UPDATE @tPD SET DropID = @cMergeOrderKey

                     -- Create merged result table
                     DECLARE @tMerged TABLE
                     (
                        KeepPickDetailKey NVARCHAR(18),
                        OrderLineNumber   NVARCHAR(5),
                        Lot               NVARCHAR(10),
                        Loc               NVARCHAR(10),
                        ID                NVARCHAR(18),
                        MergedQty         INT,
                        RecordCount       INT
                     )

                     -- Calculate merged records (GROUP BY OrderLineNumber, Lot, Loc, ID)
                     INSERT INTO @tMerged (KeepPickDetailKey, OrderLineNumber, Lot, Loc, ID, MergedQty, RecordCount)
                     SELECT MIN(PickDetailKey), OrderLineNumber, Lot, Loc, ID, SUM(Qty), COUNT(*)
                     FROM @tPD
                     GROUP BY OrderKey, OrderLineNumber, Lot, Loc, ID

                     IF @nDebugFlag = 1
                     BEGIN
                        SELECT 'FCR-12450: @tPD records' AS DebugInfo, * FROM @tPD
                        SELECT 'FCR-12450: @tMerged records' AS DebugInfo, * FROM @tMerged
                     END

                     -- Handling transaction
                     DECLARE @nTranCount  INT
                     SET @nTranCount = @@TRANCOUNT
                     BEGIN TRAN  -- Begin our own transaction
                     SAVE TRAN rdt_838ExtScn06_6865 -- For rollback or commit only our own transaction

                     -- Delete records that are merged (not the kept one)
                     BEGIN TRY
                        DELETE PD
                        FROM dbo.PickDetail PD WITH (ROWLOCK)
                        WHERE PD.PickDetailKey IN (SELECT PickDetailKey FROM @tPD)
                          AND PD.PickDetailKey NOT IN (SELECT KeepPickDetailKey FROM @tMerged)
                     END TRY
                     BEGIN CATCH
                        IF XACT_STATE() <> -1
                           ROLLBACK TRAN rdt_838ExtScn06_6865
                        ELSE
                           ROLLBACK TRAN
                        SET @nErrNo = 253217
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                        GOTO Quit
                     END CATCH

                     -- Update PickDetail: set DropID and merged Qty for kept records
                     BEGIN TRY
                        UPDATE PD WITH (ROWLOCK) SET 
                           PD.DropID = @cMergeOrderKey,
                           PD.Qty = M.MergedQty,
                           PD.EditDate = GETDATE(),
                           PD.EditWho = SUSER_SNAME()
                        FROM dbo.PickDetail PD WITH (ROWLOCK)
                        INNER JOIN @tMerged M ON PD.PickDetailKey = M.KeepPickDetailKey
                     END TRY
                     BEGIN CATCH
                        IF XACT_STATE() <> -1
                           ROLLBACK TRAN rdt_838ExtScn06_6865
                        ELSE
                           ROLLBACK TRAN
                        SET @nErrNo = 253216
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                        GOTO Quit
                     END CATCH

                     COMMIT TRAN

                     SET @cB2BUoM6Flag = '1'
                     SET @cFromDropID = @cMergeOrderKey
                  END
                  ELSE
                  BEGIN
                     IF @nDebugFlag = 1
                        SELECT 'No records with UOM=6, no need to merge'
                     
                     SET @nErrNo = 253218
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Not B2B
                     GOTO Quit
                  END
               END
               --FCR-12450 logic end

               -- Decode
               IF @cDecodeSP <> ''
               BEGIN
                  -- Customize decode
                  IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cDecodeSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cDecodeSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, @cBarcode, @cBarcode2, ' +
                        ' @cSKU OUTPUT, @nQTY OUTPUT, @cPackDtlRefNo OUTPUT, @cPackDtlRefNo2 OUTPUT, @cPackDtlUPC OUTPUT, @cPackDtlDropID OUTPUT, @cSerialNo OUTPUT, ' +
                        ' @cFromDropIDDecode OUTPUT, @cToDropIDDecode OUTPUT, @cUCCNo OUTPUT, ' +
                        ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
                     SET @cSQLParam =
                        ' @nMobile           INT,           ' +
                        ' @nFunc             INT,           ' +
                        ' @cLangCode         NVARCHAR( 3),  ' +
                        ' @nStep             INT,           ' +
                        ' @nInputKey         INT,           ' +
                        ' @cFacility         NVARCHAR( 5),  ' +
                        ' @cStorerKey        NVARCHAR( 15), ' +
                        ' @cPickSlipNo       NVARCHAR( 10), ' +
                        ' @cFromDropID       NVARCHAR( 20), ' +
                        ' @cBarcode          NVARCHAR( 60), ' +
                        ' @cBarcode2         NVARCHAR( 60), ' +
                        ' @cSKU              NVARCHAR( 20)  OUTPUT, ' +
                        ' @nQTY              INT            OUTPUT, ' +
                        ' @cPackDtlRefNo     NVARCHAR( 20)  OUTPUT, ' +
                        ' @cPackDtlRefNo2    NVARCHAR( 20)  OUTPUT, ' +
                        ' @cPackDtlUPC       NVARCHAR( 30)  OUTPUT, ' +
                        ' @cPackDtlDropID    NVARCHAR( 20)  OUTPUT, ' +
                        ' @cSerialNo         NVARCHAR( 30)  OUTPUT, ' +
                        ' @cFromDropIDDecode NVARCHAR( 30)  OUTPUT, ' +
                        ' @cToDropIDDecode   NVARCHAR( 30)  OUTPUT, ' +
                        ' @cUCCNo            NVARCHAR( 30)  OUTPUT, ' +
                        ' @nErrNo            INT            OUTPUT, ' +
                        ' @cErrMsg           NVARCHAR( 20)  OUTPUT'

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, @cBarcode, @cBarcode2,
                        @cUPC OUTPUT, @nQTY OUTPUT, @cPackDtlRefNo OUTPUT, @cPackDtlRefNo2 OUTPUT, @cPackDtlUPC OUTPUT, @cPackDtlDropID_Decode OUTPUT, @cSerialNo OUTPUT,
                        @cFromDropIDDecode OUTPUT, @cToDropIDDecode OUTPUT, @cUCCNo OUTPUT,
                        @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                        GOTO Quit
                  END

                  IF @cFromDropIDDecode <> ''
                     SET @cFromDropID = @cFromDropIDDecode

                  IF @cToDropIDDecode <> ''
                     SET @cPackDtlDropID = @cToDropIDDecode

               END

               IF @cFromDropID <> ''
               BEGIN
                  -- Check FromDropID format
                  IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'FROMDROPID', @cFromDropID) = 0
                  BEGIN
                     SET @nErrNo = 100233
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format
                     EXEC rdt.rdtSetFocusField @nMobile, 2  -- FromDropID
                     SET @cOutField02 = ''
                     GOTO Quit
                  END

                  -- Get DropID info
                  --DECLARE @cOrderKey NVARCHAR( 10)
                  SET @cOrderKey = ''
                  SELECT TOP 1
                     @cOrderKey = OrderKey
                  FROM PickDetail WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cFromDropID
                     AND Status <= '5'

                  -- Check DropID valid
                  IF @@ROWCOUNT = 0
                  BEGIN
                     SET @nErrNo = 100234
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid DropID
                     EXEC rdt.rdtSetFocusField @nMobile, 2  -- FromDropID
                     SET @cOutField02 = ''
                     GOTO Quit
                  END

                  -- Auto retrieve PickSlipNo
                  IF @cPickSlipNo = ''
                  BEGIN
                     -- Get discrete pick slip
                     SELECT @cPickSlipNo = PickHeaderKey
                     FROM PickHeader WITH (NOLOCK)
                     WHERE OrderKey = @cOrderKey

                     -- Get conso pick slip
                     IF @cPickSlipNo = ''
                     BEGIN
                        DECLARE @cLoadKey NVARCHAR( 10)
                        SET @cLoadKey = ''
                        SELECT @cLoadKey = LoadKey FROM LoadPlanDetail WITH (NOLOCK) WHERE OrderKey = @cOrderKey

                        IF @cLoadKey <> ''
                           SELECT @cPickSlipNo = PickHeaderKey
                           FROM PickHeader WITH (NOLOCK)
                           WHERE ExternOrderKey = @cLoadKey
                              AND OrderKey = ''
                     END

                     -- Check PickHeader
                     IF @cPickSlipNo = ''
                     BEGIN
                        SET @nErrNo = 100235
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need PickHdr
                        EXEC rdt.rdtSetFocusField @nMobile, 2  -- ToDropID
                        SET @cOutField02 = ''
                        GOTO Quit
                     END

                     SET @cOutField01 = @cPickSlipNo
                     SET @cOutField02 = @cFromDropID
                  END
               END

               -- Check blank
               IF @cPickSlipNo = ''
               BEGIN
                  SET @nErrNo = 100201
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- PSNO required
                  EXEC rdt.rdtSetFocusField @nMobile, 1  -- PickSlipNo
                  GOTO Quit
               END

               -- Check blank
               IF @cFromDropID = '' AND @cPackByFromDropID = '1'
               BEGIN
                  SET @nErrNo = 100247
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NeedFromDropID
                  EXEC rdt.rdtSetFocusField @nMobile, 2  -- FromDropID
                  GOTO Quit
               END

               -- Check blank
               IF @cPackDtlDropID = '' AND @cPackByToDropID = '1'
               BEGIN
                  SET @nErrNo = 100251
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need ToDropID
                  EXEC rdt.rdtSetFocusField @nMobile, 3  -- ToDropID
                  GOTO Quit
               END

               -- Check PickSlipNo
               EXEC rdt.rdt_Pack_Validate @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'PICKSLIPNO'
                  ,@cPickSlipNo
                  ,'' --@cFromDropID
                  ,'' --@cPackDtlDropID
                  ,'' --@cSKU
                  ,0  --@nQTY
                  ,0  --@nCartonNo
                  ,@nErrNo  OUTPUT
                  ,@cErrMsg OUTPUT
               IF @nErrNo <> 0
               BEGIN
                  EXEC rdt.rdtSetFocusField @nMobile, 1  -- PickSlipNo
                  SET @cOutField01 = ''
                  GOTO Quit
               END
               SET @cOutField01 = @cPickSlipNo

               -- Check ToDropID format
               IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'TODROPID', @cPackDtlDropID) = 0
               BEGIN
                  SET @nErrNo = 100202
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format
                  EXEC rdt.rdtSetFocusField @nMobile, 3  -- ToDropID
                  SET @cOutField03 = ''
                  GOTO Quit
               END
               SET @cOutField03 = @cPackDtlDropID

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

               -- Get PickingInfo info
               DECLARE @dScanInDate DATETIME
               SELECT @dScanInDate = ScanInDate FROM PickingInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo

               -- Check scan-in
               IF @dScanInDate IS NULL
               BEGIN
                  -- Auto scan-in
                  IF @cAutoScanIn = '1'
                  BEGIN
                     IF NOT EXISTS( SELECT 1 FROM PickingInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo)
                     BEGIN
                        INSERT INTO dbo.PickingInfo (PickSlipNo, ScanInDate, PickerID)
                        VALUES (@cPickSlipNo, GETDATE(), @cUserName)
                        IF @@ERROR <> 0
                        BEGIN
                           SET @nErrNo = 100227
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Scan-In Fail
                           GOTO Quit
                        END
                     END
                     ELSE
                     BEGIN
                        UPDATE dbo.PickingInfo SET
                           ScanInDate = GETDATE(),
                           PickerID = SUSER_SNAME(),
                           EditWho = SUSER_SNAME()
                        WHERE PickSlipNo = @cPickSlipNo
                        IF @@ERROR <> 0
                        BEGIN
                           SET @nErrNo = 100237
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Scan-In Fail
                           GOTO Quit
                        END
                     END
                  END
                  ELSE
                  BEGIN
                     SET @nErrNo = 100228
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Not Scan-In
                     GOTO Quit
                  END
               END

               SET @nCartonNo    = 0
               SET @cLabelNo     = ''
               SET @cCustomNo    = ''
               SET @cCustomID    = ''
               SET @nCartonSKU   = 0
               SET @nCartonQTY   = 0
               SET @nTotalCarton = 0
               SET @nTotalPick   = 0
               SET @nTotalPack   = 0
               SET @nTotalShort  = 0
               SET @cType        = 'NEXT'
               
               -- Lookup carton, if provided
               IF @cPackByToDropID = '1' 
               BEGIN
                  IF @cPackDtlDropID IN ('', 'NEW')
                     SET @cType = 'CURRENT'
                  ELSE
                  BEGIN 
                     -- Get carton info
                     SELECT TOP 1 
                        @nCartonNo = CartonNo, 
                        @cLabelNo = LabelNo
                     FROM dbo.PackDetail WITH (NOLOCK) 
                     WHERE PickSlipNo = @cPickSlipNo 
                        AND LabelNo = @cPackDtlDropID

                     IF @nCartonNo > 0
                        SET @cType = 'CURRENT'
                     ELSE
                     BEGIN
                        SET @nErrNo = 100252
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Bad ToDropID
                        EXEC rdt.rdtSetFocusField @nMobile, 3  -- ToDropID
                        SET @cOutField03 = ''
                        GOTO Quit
                     END
                  END
               END

               -- Get task
               EXEC rdt.rdt_Pack_GetStat @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType
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

               -- Extended info
               IF @cExtendedInfoSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedInfoSP AND type = 'P')
                  BEGIN
                     INSERT INTO @tVar (Variable, Value) VALUES
                        ('@cPickSlipNo',     @cPickSlipNo),
                        ('@cFromDropID',     @cFromDropID),
                        ('@nCartonNo',       CAST( @nCartonNo AS NVARCHAR( 10))),
                        ('@cLabelNo',        @cLabelNo),
                        ('@cSKU',            @cSKU),
                        ('@nQTY',            CAST( @nQTY AS NVARCHAR( 10))),
                        ('@cUCCNo',          @cUCCNo),
                        ('@cCartonType',     @cCartonType),
                        ('@cCube',           @cCube),
                        ('@cWeight',         @cWeight),
                        ('@cRefNo',          @cRefNo),
                        ('@cSerialNo',       @cSerialNo),
                        ('@nSerialQTY',      CAST( @nSerialQTY AS NVARCHAR( 10))),
                        ('@cOption',         @cOption),
                        ('@cPackDtlRefNo',   @cPackDtlRefNo),
                        ('@cPackDtlRefNo2',  @cPackDtlRefNo2),
                        ('@cPackDtlUPC',     @cPackDtlUPC),
                        ('@cPackDtlDropID',  @cPackDtlDropID),
                        ('@cPackData1',      @cPackData1),
                        ('@cPackData2',      @cPackData2),
                        ('@cPackData3',      @cPackData3)

                     SET @cExtendedInfo = ''
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @tVar, ' +
                        ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '
                     SET @cSQLParam =
                        ' @nMobile        INT,           ' +
                        ' @nFunc          INT,           ' +
                        ' @cLangCode      NVARCHAR( 3),  ' +
                        ' @nStep          INT,           ' +
                        ' @nAfterStep     INT,           ' +
                        ' @nInputKey      INT,           ' +
                        ' @cFacility      NVARCHAR( 5),  ' +
                        ' @cStorerKey     NVARCHAR( 15), ' +
                        ' @tVar           VariableTable READONLY, ' +
                        ' @cExtendedInfo  NVARCHAR( 20) OUTPUT,   ' +
                        ' @nErrNo         INT           OUTPUT,   ' +
                        ' @cErrMsg        NVARCHAR( 20) OUTPUT    '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, 1, @nStep, @nInputKey, @cFacility, @cStorerKey, @tVar,
                        @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                        GOTO Quit

                        SET @cOutField15 = @cExtendedInfo
                  END
               END

               -- FCR-11343: B2C Single Flex Pack Detection
               SET @cB2CSingleFlexPack = rdt.rdtGetConfig(@nFunc, 'B2CSingleFlexPack', @cStorerKey)

               SET @cIsB2CSingle = '0'
               IF @cB2CSingleFlexPack = '1'
               BEGIN
                  -- Check if ALL orders in DropID are B2C Single
                  IF NOT EXISTS(
                     SELECT 1
                     FROM dbo.PICKDETAIL PD WITH (NOLOCK)
                     INNER JOIN dbo.ORDERS O WITH (NOLOCK) ON PD.StorerKey = O.StorerKey AND PD.OrderKey = O.OrderKey
                     WHERE PD.DropID = @cFromDropID
                        AND PD.StorerKey = @cStorerKey
                        AND PD.Status <= @cPickStatus
                        AND (O.DocType <> 'E' OR ISNULL(O.ECOM_SINGLE_Flag, '') <> 'S')
                  )
                  AND EXISTS(
                     SELECT 1 FROM dbo.PICKDETAIL WITH (NOLOCK)
                     WHERE DropID = @cFromDropID
                        AND StorerKey = @cStorerKey
                        AND Status <= @cPickStatus
                  )
                  BEGIN
                     IF @nDebugFlag = 1
                        SELECT 'IsB2CSingle On'

                     SET @cIsB2CSingle = '1'
                  END
               END

               IF @cIsB2CSingle <> '1'
               BEGIN
                  -- Prepare next screen var
                  SET @cOutField01 = @cPickSlipNo
                  SET @cOutField02 = CAST( @nTotalPick AS NVARCHAR(8))  -- ZG02
                  SET @cOutField03 = CAST( @nTotalPack AS NVARCHAR(8))  -- ZG02
                  SET @cOutField04 = CAST( @nTotalShort AS NVARCHAR(8))  -- ZG02
                  SET @cOutField05 = RTRIM( @cCustomNo) + '/' + CAST( @nTotalCarton AS NVARCHAR(5))
                  SET @cOutField06 = @cCustomID
                  SET @cOutField07 = CAST( @nCartonSKU AS NVARCHAR(5))
                  SET @cOutField08 = CAST( @nCartonQTY AS NVARCHAR(5))

                  -- FCR-8931 Original step1 ext scn logic start
                  SELECT TOP 1 
                     @cMUOM = Uom,
                     @cOrderKey = Orderkey
                  FROM dbo.PickDetail (NOLOCK)
                  WHERE DropID = @cFromDropID
                  AND StorerKey = @cStorerKey
                  AND Status <= @cPickStatus

                  IF @cMUOM = '2'
                  BEGIN
                     SELECT @cOutField09 = CASE WHEN DocType='N' THEN '4' WHEN DocType='E' THEN '1' END FROM ORDERS (NOLOCK) WHERE OrderKey = @cOrderKey
                  END
                  ELSE IF @cMUOM = '6'
                  BEGIN
                     SELECT @cOutField09 = CASE WHEN DocType='N' THEN '1' WHEN DocType='E' THEN '2' END FROM ORDERS (NOLOCK) WHERE OrderKey = @cOrderKey
                  END
                  --FCR-8931 Original step1 ext scn logic

                  SET @cUDF06 = @cCustomNo
                  SET @cUDF01 = 'NO UPD RDTMOBREC'

                  -- Go to statistic screen
                  SET @nAfterScn = 4651
                  SET @nAfterStep =2
               END
               ELSE
               BEGIN
                  IF EXISTS (SELECT  1 FROM dbo.PickHeader PH WITH (NOLOCK) 
                                 JOIN dbo.PickDetail PD WITH (NOLOCK) 
                                    ON PH.StorerKey = PD.StorerKey AND PH.OrderKey = PD.OrderKey
                                 JOIN dbo.PackHeader PAH WITH (NOLOCK)
                                    ON PH.PickHeaderKey = PAH.PickSlipNo
                                 WHERE PH.StorerKey = @cStorerKey 
                                    AND PD.DropID = @cFromDropID 
                                    AND PAH.Status = '9' )
                  BEGIN
                     SET @nErrNo = 253220
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Pack header is 9
                     GOTO Scn_6865_Fail
                  END

                   -- Get PackDetail info
                  SELECT @nRemainQTY = SUM(PAD.ExpQty - PAD.Qty)
                  FROM dbo.PackDetail PAD WITH (NOLOCK)
                  INNER JOIN dbo.PICKHEADER PKH WITH (NOLOCK) ON PAD.PickSlipNo = PKH.PickHeaderKey AND PAD.StorerKey = PKH.StorerKey
                  INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON PAD.LabelNo = PKD.CaseID AND PAD.SKU = PKD.SKU AND PKH.OrderKey = PKD.OrderKey
                  WHERE PKD.DropID = @cFromDropID
                     AND PKD.StorerKey = @cStorerKey
                     AND PAD.Qty = 0

                  SET @nRemainQTY = ISNULL(@nRemainQTY, 0)

                  -- Prepare Screen 3 variables for flexible SKU scan
                  SET @cOutField01 = ''
                  SET @cOutField02 = ''
                  SET @cMobBarcode = '' -- clear V_barcode
                  SET @cOutField03 = ''
                  SET @cOutField04 = ''
                  SET @cOutField05 = ISNULL(TRY_CAST( @nRemainQTY AS NVARCHAR( 8)), '')
                  SET @cOutField08 = CASE WHEN @cDisableQTYField = '1' THEN @cQTY ELSE @cDefaultQTY END
                  SET @cOutField09 = ''
                  SET @cOutField10 = ''
                  SET @cOutField11 = ''
                  SET @cOutField12 = ''
                  SET @cOutField13 = ''
                  SET @cOutField14 = ''

                  SET @nEnter = 0 
                  SET @cLabelNo = ''
                  SET @cUDF01 = 'NO UPD RDTMOBREC'

                  -- Enable field
                  SET @cFieldAttr14 = 'O'
                  SET @cFieldAttr08 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END

                  EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU field

                  SET @nAfterScn = 6862   -- New SKU scan screen
                  SET @nAfterStep = 99
               END
            END
            GOTO Quit

            Scn_6865_Fail:
            BEGIN
               SET @cOutField01 = ''
               SET @cOutField02 = ''
               SET @cOutField03 = ''

               EXEC rdt.rdtSetFocusField @nMobile, 2  -- FromDropID

               GOTO Quit
            END
         END -- 6865 --V1.2.0 end
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

Quit:

-- Only UPDATE C_StringXXX, because C_StringXXX is used for ExtScnSP
UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
SET
   C_String1 = @cIsB2CSingle,
   C_String2 = @cB2BUoM6Flag
WHERE Mobile = @nMobile

-- No need to update RDTMOBREC in base SP if @cUDF01 = 'NO UPD RDTMOBREC'
IF @cUDF01 = 'NO UPD RDTMOBREC'
BEGIN
   -- FCR-11343: Store fetched values in RDTMOBREC
   UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
   SET
      V_PickSlipNo   = @cPickSlipNo,
      V_CartonNo     = @nCartonNo,
      V_SKU          = @cSKU,
      V_String3      = @cLabelNo,
      V_String4      = @cCartonType,
      V_String5      = @cCube,
      V_String6      = @cWeight,
      V_String20     = @cFromDropID,
      V_String39     = @cCustomNo,
      V_Barcode      = @cMobBarcode,

      V_Integer1     = @nCartonSKU,
      V_Integer2     = @nCartonQTY,
      V_Integer3     = @nTotalCarton,
      V_Integer4     = @nTotalPick,
      V_Integer5     = @nTotalPack,
      V_Integer6     = @nTotalShort,

      EditDate = GETDATE(),
      ErrMsg = @cErrMsg,
      Func   = @nFunc,
      Scn = @nAfterScn,
      Step = @nAfterStep,

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

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_838ExtScn06] TO NSQL
GO


