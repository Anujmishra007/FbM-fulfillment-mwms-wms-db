
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Store procedure: rdt_838ExtScn05                                        */
/* Copyright      : Maersk                                                 */
/* Customer       : MATTELCL                                               */
/*                                                                         */
/*                                                                         */
/* Date        Rev    Author     Purposes                                  */
/* 2025-07-10  1.0.0  NickT      FCR-4325 Create                           */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_838ExtScn05] (
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

   SELECT 
      @nCurrentStep = Step,
      @nCurrentScn  = Scn,
      @cUserName = UserName,

      @cPickSlipNo      = V_PickSlipNo,
      @cSKU             = V_SKU,
      @nQTY             = V_QTY,
      @cSKUDescr        = V_SKUDescr,
      @nFromScn         = V_FromScn,
      @nFromStep        = V_FromStep,
      @cPUOM            = V_UOM,

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
      @cDefaultCursor      = V_String51 --(v7.5)
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 838
   BEGIN
      -- If next step is 3, need jump to new SKU screen
      IF @nStep = 3 AND @nScn = 4652
      BEGIN
         SET @nAfterStep = 99
         SET @nAfterScn = 6624
         RETURN
      END

      IF @nCurrentStep = 99
      BEGIN
         IF @nCurrentScn = 6624
         BEGIN
            IF @nInputKey = 1
            BEGIN
               IF @cDisableQTYFieldSP = '1'
               BEGIN
                  SET @nErrNo = 241551
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- DisableQTYField cannot be 1
                  GOTO Step_99_6624_Fail
               END

               -- Screen mapping
               SET @cBarcode = @cInField03 -- SKU
               SET @cBarcode2 = ''
               SET @cUPC = LEFT( @cInField03, 30) -- SKU

               SET @cMQTY = CASE WHEN @cFieldAttr08 = 'O' THEN '' ELSE @cInField08 END
               SET @cPQTY = CASE WHEN @cFieldAttr14 = 'O' THEN '' ELSE @cInField14 END

               -- Retain value
               SET @cOutField08 = CASE WHEN @cFieldAttr08 = 'O' THEN @cOutField08 ELSE @cInField08 END -- PQTY
               SET @cOutField14 = CASE WHEN @cFieldAttr14 = 'O' THEN @cOutField14 ELSE @cInField14 END -- MQTY

               -- Loop SKU
               IF @cBarcode = '' AND @cMQTY = '' AND @cPQTY = ''
               BEGIN
                  IF @nCartonQTY > 0
                  BEGIN
                     -- Get carton info
                     SELECT TOP 1
                        @cSKU = SKU,
                        @cLabelLine = LabelLine
                     FROM dbo.PackDetail WITH (NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                        AND CartonNo = @nCartonNo
                        AND LabelNo = @cLabelNo
                        AND LabelLine > @cLabelLine
                     ORDER BY LabelLine

                     IF @@ROWCOUNT = 0
                        SELECT TOP 1
                           @cSKU = SKU,
                           @cLabelLine = LabelLine
                        FROM dbo.PackDetail WITH (NOLOCK)
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
                                 @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID,
                                 @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption,
                                 @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, @cPackData1, @cPackData2, @cPackData3,
                                 @tVarDisableQTYField, @cDisableQTYField OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                              IF @nErrNo <> 0
                                 GOTO Quit
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
                              @nMobile, @nFunc, @cLangCode, 3, @nStep, @nInputKey, @cFacility, @cStorerKey, @tVar,
                              @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                           IF @nErrNo <> 0
                              GOTO Quit

                           SET @cOutField15 = @cExtendedInfo
                        END
                     END

                     GOTO Quit
                  END
               END

               -- Check SKU blank
               IF @cBarcode = ''
               BEGIN
                  SET @nErrNo = 241552
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Need SKU
                  GOTO Step_99_6624_Fail
               END

               -- Validate SKU
               IF @cBarcode <> ''
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
                        EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,
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
                           GOTO Step_99_6624_Fail

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
                     SET @nErrNo = 241553
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid SKU
                     GOTO Step_99_6624_Fail
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
                           SET @nFromScn = @nCurrentScn
                           SET @nFromStep = @nCurrentStep
                           SET @nScn = 3570
                           SET @nStep = 11
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
                        SET @nErrNo = 241554
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Multiple SKU Barcod
                        GOTO Step_99_6624_Fail
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

                  -- Check SKU in PickSlipNo
                  EXEC rdt.rdt_Pack_Validate @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'SKU'
                     ,@cPickSlipNo
                     ,@cFromDropID
                     ,@cPackDtlDropID
                     ,@cSKU
                     ,0 --@nQTY
                     ,0 --@nCartonNo
                     ,@nErrNo  OUTPUT
                     ,@cErrMsg OUTPUT
                  IF @nErrNo <> 0
                     GOTO Step_99_6624_Fail

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
                              @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID,
                              @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption,
                              @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, @cPackData1, @cPackData2, @cPackData3,
                              @tVarDisableQTYField, @cDisableQTYField OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                           IF @nErrNo <> 0
                              GOTO Quit
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
                              @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID,
                              @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption,
                              @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, @cPackData1, @cPackData2, @cPackData3,
                              @tVarDisableQTYField, @cSkipChkPPKQTY OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                           IF @nErrNo <> 0
                              GOTO Quit
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
                           @nMobile, @nFunc, @cLangCode, 3, @nStep, @nInputKey, @cFacility, @cStorerKey, @tVar,
                           @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                        IF @nErrNo <> 0
                           GOTO Quit

                        IF @nStep = 99 AND @nScn = 6624
                           SET @cOutField15 = @cExtendedInfo
                     END
                  END

                  SET @cOutField03 = '' --CASE WHEN @cDisableQTYField = '1' THEN '' ELSE @cSKU END
                  SET @cOutField04 = @cSKU
                  SET @cOutField05 = rdt.rdtFormatString( @cSKUDescr, 1, 20)
                  SET @cOutField06 = rdt.rdtFormatString( @cSKUDescr, 21, 20)
                  SET @cOutField07 = CAST( @nPackedQTY AS NVARCHAR( 8))    -- ZG02
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

                  SET @nStep = 99
                  SET @nScn = 6625
                  IF @cDefaultCursor <> ''
                     EXEC rdt.rdtSetFocusField @nMobile, @cDefaultCursor
                  ELSE
                  BEGIN
                     IF @cFieldAttr14 = 'O'
                        EXEC rdt.rdtSetFocusField @nMobile,  8
                     ELSE 
                        EXEC rdt.rdtSetFocusField @nMobile, 14
                  END
                  GOTO Quit
               END
            END
            ELSE IF @nInputkey = 0
            BEGIN
               -- Repack without add SKU QTY
               IF @nCartonNo > 0 AND @nCartonQTY = 0
               BEGIN
                  -- Handling transaction
                  DECLARE @nTranCount INT
                  SET @nTranCount = @@TRANCOUNT
                  BEGIN TRAN  -- Begin our own transaction
                  SAVE TRAN rdtfnc_Pack -- For rollback or commit only our own transaction

                  -- PackInfo
                  IF EXISTS( SELECT 1 FROM PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo)
                  BEGIN
                     DELETE PackInfo WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo
                     IF @@ERROR <> 0
                     BEGIN
                        ROLLBACK TRAN rdtfnc_Pack
                        WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                           COMMIT TRAN
                        SET @nErrNo = 241557
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Delete PackInfo fail
                        GOTO Step_99_6625_Fail
                     END
                  END

                  -- PackDetail (delete the booking record, 1 line with blank SKU)
                  IF EXISTS( SELECT 1 FROM PackDetail WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo)
                  BEGIN
                     DELETE PackDetail WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo
                     IF @@ERROR <> 0
                     BEGIN
                        ROLLBACK TRAN rdtfnc_Pack
                        WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                           COMMIT TRAN
                        SET @nErrNo = 241558
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DEL PAKDtlFail
                        GOTO Step_99_6625_Fail
                     END
                  END

                  COMMIT TRAN rdtfnc_Pack
                  WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                     COMMIT TRAN
               END

               -- Packed
               IF @nCartonQTY > 0
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
                     SET @cOutField01 = CASE WHEN ISNULL(@cCartonType ,'') ='' AND ISNULL(@cDefaultcartontype,'')<>''  THEN @cDefaultcartontype ELSE @cCartonType end
                     SET @cOutField02 = @cWeight           --WinSern
                     SET @cOutField03 = @cCube             --WinSern
                     SET @cOutField04 = @cRefNo
                     SET @cOutField05 = @cLength
                     SET @cOutField06 = @cWidth
                     SET @cOutField07 = @cHeight

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
                     SET @nEnter = 0 --(JHU151)  

                     -- Go to next screen
                     SET @nScn = 4653
                     SET @nStep = 4

                     IF EXISTS( SELECT 1 FROM STRING_SPLIT( @cFlowThruScreen, ',') WHERE TRIM( value) = '4') -- PackInfo screen
                     BEGIN
                        SET @cInField01 = CASE WHEN ISNULL(@cCartonType ,'') ='' AND ISNULL(@cDefaultcartontype,'')<>''  THEN @cDefaultcartontype ELSE @cCartonType end
                        SET @nInputKey='1'
                        SET @cUDF01 = 'JumpTo_Step_4'
                        --GOTO Step_4
                     END

                     GOTO Quit
                  END

                  -- Print label
                  IF @cShipLabel <> '' OR @cCartonManifest <> ''
                  BEGIN
                     -- Prepare next screen var
                     SET @cOutField01 = @cDefaultPrintLabelOption --Option

                     -- Enable field
                     SET @cFieldAttr08 = '' -- QTY
                     
                     --Reset 
                     SET @nEnter = 0 --(JHU151) 

                     -- Go to next screen
                     SET @nScn = 5
                     SET @nStep = 4654

                     -- Flow thru
                     IF EXISTS( SELECT 1 FROM STRING_SPLIT( @cFlowThruScreen, ',') WHERE TRIM( value) = '5') -- Print label screen
                     BEGIN
                        SET @cInField01 = @cDefaultPrintLabelOption --Option
                        SET @nInputKey = 1 -- ENTER
                        SET @cUDF01 = 'JumpTo_Step_5'
                        --GOTO Step_5
                     END
                     ELSE
                     GOTO Quit
                  END
               END

               IF @nCartonNo = 0 OR @nCartonQTY = 0
                  SET @cType = 'NEXT'
               ELSE
                  SET @cType = 'CURRENT'

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
                  GOTO Step_99_6625_Fail

               -- Prepare next screen var
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
               SET @cFieldAttr08 = '' -- QTY

               SET @cOutField15 = ''

               --Reset 
               SET @nEnter = 0 --(JHU151)

               SET @nStep = 2
               SET @nScn = 4651
               GOTO Quit
            END

            Step_99_6624_Fail:
               IF rdt.RDTGetConfig( @nFunc, 'ShowErrMsgInNewScn', @cStorerkey) = '1'
               BEGIN
                  EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg
               END

               SET @cOutField03 = '' -- SKU
               EXEC rdt.rdtSetFocusField @nMobile, 3 -- SKU
               SET @cOutField08  =  @cDefaultQTY
         END
         ELSE IF @nCurrentScn = 6625
         BEGIN
            IF @nInputKey = 1
            BEGIN
               SET @cMQTY = CASE WHEN @cFieldAttr08 = 'O' THEN '' ELSE @cInField08 END
               SET @cPQTY = CASE WHEN @cFieldAttr14 = 'O' THEN '' ELSE @cInField14 END
               
               --(cc01)  
               IF @cDefaultQTY >0 AND @nEnter = 0  
               BEGIN
                  SET @nEnter = 1  
                  EXEC rdt.rdtSetFocusField @nMobile, 8
                  GOTO Quit
               END

               -- Validate MQTY
               IF @cMQTY <> '' AND RDT.rdtIsValidQTY( @cMQTY, 1) = 0 --Check zero
               BEGIN
                  SET @nErrNo = 241555
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid QTY
                  EXEC rdt.rdtSetFocusField @nMobile, 8 -- QTY
                  GOTO Step_99_6625_Fail
               END

               -- Validate PQTY
               IF @cPQTY <> '' AND RDT.rdtIsValidQTY( @cPQTY, 1) = 0 --Check zero
               BEGIN
                  SET @nErrNo = 241556
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid QTY
                  EXEC rdt.rdtSetFocusField @nMobile, 14 -- QTY
                  GOTO Step_99_6625_Fail
               END

               -- Get QTY
               IF @nDecodeQTY > 0
               BEGIN
                  SET @cQTY = CAST( @nDecodeQTY AS NVARCHAR(8))  -- ZG02
                  SET @nQTY = @nDecodeQTY
               END
               ELSE
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

               -- Retain QTY
               SET @cOutField08 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE @cMQTY END --(cc03)
               SET @cOutField14 = CASE WHEN @cPUOM_Desc <> '' THEN @cPQTY ELSE '' END

               -- Check over pack
               EXEC rdt.rdt_Pack_Validate @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'QTY'
                  ,@cPickSlipNo
                  ,@cFromDropID
                  ,@cPackDtlDropID
                  ,@cSKU
                  ,@nQTY
                  ,@nCartonNo
                  ,@nErrNo  OUTPUT
                  ,@cErrMsg OUTPUT
               IF @nErrNo <> 0
               BEGIN
                  GOTO Step_99_6625_Fail
               END

               -- Check blank QTY
               IF @cQTY = '' AND @nQTY = 0
               BEGIN
                  SET @nErrNo = 100204
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Need QTY
                  GOTO Step_99_6625_Fail
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
                        '@nSerialQTY      INT,    ' +
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
                        GOTO Step_99_6625_Fail
                  END
               END

               -- Custom data capture setup
               SET @cDataCapture = ''
               IF @cDataCaptureSP = ''
               BEGIN
                  SET @cPackData1 = ''
                  SET @cPackData2 = ''
                  SET @cPackData3 = ''
               END
               ELSE
               BEGIN
                  -- Get default data capture labels
                  SET @cPackLabel1 = ''
                  SET @cPackLabel2 = ''
                  SET @cPackLabel3 = ''
                  SELECT
                     @cPackLabel1 = UDF01,
                     @cPackLabel2 = UDF02,
                     @cPackLabel3 = UDF03
                  FROM dbo.CodeLKUP WITH (NOLOCK)
                  WHERE ListName = 'RDTDATALBL'
                     AND Storerkey = @cStorerKey
                     AND Code2 = @nFunc

                  SET @cPackAttr1 = CASE WHEN @cPackLabel1 = '' THEN'O' ELSE '' END
                  SET @cPackAttr2 = CASE WHEN @cPackLabel2 = '' THEN'O' ELSE '' END
                  SET @cPackAttr3 = CASE WHEN @cPackLabel3 = '' THEN'O' ELSE '' END

                  -- Custom SP to get data capture setup
                  IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cDataCaptureSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cDataCaptureSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, ' +
                        ' @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption, ' +
                        ' @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, ' +
                        ' @cPackData1   OUTPUT, @cPackData2  OUTPUT, @cPackData3  OUTPUT, ' +
                        ' @cPackLabel1  OUTPUT, @cPackLabel2 OUTPUT, @cPackLabel3 OUTPUT, ' +
                        ' @cPackAttr1   OUTPUT, @cPackAttr2  OUTPUT, @cPackAttr3  OUTPUT, ' +
                        ' @cDataCapture OUTPUT, @nErrNo      OUTPUT, @cErrMsg     OUTPUT  ' 
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
                        '@cPackData1      NVARCHAR( 30)  OUTPUT, ' +
                        '@cPackData2      NVARCHAR( 30)  OUTPUT, ' +
                        '@cPackData3      NVARCHAR( 30)  OUTPUT, ' +
                        '@cPackLabel1     NVARCHAR( 20)  OUTPUT, ' +
                        '@cPackLabel2     NVARCHAR( 20)  OUTPUT, ' +
                        '@cPackLabel3     NVARCHAR( 20)  OUTPUT, ' +
                        '@cPackAttr1      NVARCHAR( 1)   OUTPUT, ' +
                        '@cPackAttr2      NVARCHAR( 1)   OUTPUT, ' +
                        '@cPackAttr3      NVARCHAR( 1)   OUTPUT, ' +
                        '@cDataCapture    NVARCHAR( 1)   OUTPUT, ' +
                        '@nErrNo          INT            OUTPUT, ' +
                        '@cErrMsg         NVARCHAR( 20)  OUTPUT  '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID,
                        @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption,
                        @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID,
                        @cPackData1   OUTPUT, @cPackData2  OUTPUT, @cPackData3  OUTPUT,
                        @cPackLabel1  OUTPUT, @cPackLabel2 OUTPUT, @cPackLabel3 OUTPUT,
                        @cPackAttr1   OUTPUT, @cPackAttr2  OUTPUT, @cPackAttr3  OUTPUT,
                        @cDataCapture OUTPUT, @nErrNo      OUTPUT, @cErrMsg     OUTPUT

                     IF @nErrNo <> 0
                        GOTO Step_99_6625_Fail
                  END
                  ELSE
                  BEGIN
                     -- Setup is non SP
                     SET @cDataCapture = @cDataCaptureSP
                     SET @cPackData1 = ''
                     SET @cPackData2 = ''
                     SET @cPackData3 = ''

                     EXEC rdt.rdtSetFocusField @nMobile, 1 -- PackData1
                  END

                  -- Capture data
                  IF @cDataCapture = '1'
                  BEGIN
                     -- SKU need data capture
                     IF @cSKUDataCapture IN ('1', '3') -- 1=Inbound and outbound, 3=outbound only
                     BEGIN
                        -- Prepare next screen var
                        SET @cOutField01 = @cPackLabel1
                        SET @cOutField02 = @cPackData1
                        SET @cOutField03 = @cPackLabel2
                        SET @cOutField04 = @cPackData2
                        SET @cOutField05 = @cPackLabel3
                        SET @cOutField06 = @cPackData3

                        --(yeekung01)
                        SET @cFieldAttr02 = @cPackAttr1
                        SET @cFieldAttr04 = @cPackAttr2
                        SET @cFieldAttr06 = @cPackAttr3

                        -- Go to capture data screen
                        SET @nFromScn = @nScn
                        SET @nFromStep = @nStep

                        SET @nScn = 4659
                        SET @nStep = 10

                        GOTO Quit
                     END
                  END
               END

               -- Serial No
               IF @cSerialNoCapture IN ('1', '3')  -- 1 = INBOUND & OUTBOUND; 2 = INBOUND ONLY; 3 = OUTBOUND ONLY
               BEGIN
                  SET @nScan = 0

                  EXEC rdt.rdt_SerialNo @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cSKU, @cSKUDescr, @nQTY, 'CHECK', 'PICKSLIP', @cPickSlipNo,
                     @cInField01 OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,
                     @cInField02 OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,
                     @cInField03 OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,
                     @cInField04 OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,
                     @cInField05 OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,
                     @cInField06 OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,
                     @cInField07 OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,
                     @cInField08 OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,
                     @cInField09 OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,
                     @cInField10 OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,
                     @cInField11 OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,
                     @cInField12 OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,
                     @cInField13 OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,
                     @cInField14 OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,
                     @cInField15 OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,
                     @nMoreSNO   OUTPUT,  @cSerialNo   OUTPUT,  @nSerialQTY   OUTPUT,
                     @nErrNo     OUTPUT,  @cErrMsg     OUTPUT,  @nScn = 0,
                     @nBulkSNO = 0,       @nBulkSNOQTY = 0,     @cSerialCaptureType = '3',
                     @nScan = @nScan OUTPUT

                  IF @nErrNo <> 0
                     GOTO Step_99_6625_Fail

                  IF @nMoreSNO = 1
                  BEGIN
                     -- Go to Serial No screen
                     SET @nScn = 4831
                     SET @nStep = 9

                     -- Flow thru
                     IF @cSerialNo <> ''
                     BEGIN
                        IF EXISTS( SELECT 1 FROM STRING_SPLIT( @cFlowThruScreen, ',') WHERE TRIM( value) = '9') -- Serial no screen
                        BEGIN
                           -- rdt_SerialNo will read from rdtMboRec directly
                           UPDATE rdt.rdtMobRec SET 
                              V_Max = @cSerialNo, 
                              EditDate = GETDATE()
                           WHERE Mobile = @nMobile
                           
                           SET @nInputKey='1'
                           SET @cUDF01 = 'JumpTo_Step_9'
                           --GOTO Step_9
                        END
                     END

                     GOTO Quit
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
                  GOTO Step_99_6625_Fail

               -- Calc carton info
               SELECT
                  @nCartonSKU = COUNT( 1), --DISTINCT PD.SKU
                  @nCartonQTY = ISNULL( SUM( PD.QTY), 0)
               FROM dbo.PackDetail PD WITH (NOLOCK)
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND CartonNo = @nCartonNo
                  AND LabelNo = @cLabelNo

               -- Get carton info
               DECLARE @cPD_DropID NVARCHAR(20)
               DECLARE @cPD_RefNo  NVARCHAR(20)
               DECLARE @cPD_RefNo2 NVARCHAR(30)
               SELECT
                  @cLabelLine = PD.LabelLine,
                  @nPackedQTY = PD.QTY,
                  @cPD_DropID = PD.DropID,
                  @cPD_RefNo = PD.RefNo,
                  @cPD_RefNo2 = PD.RefNo2
               FROM dbo.PackDetail PD WITH (NOLOCK)
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND CartonNo = @nCartonNo
                  AND LabelNo = @cLabelNo
                  AND SKU = @cSKU

               -- Get custom carton no
               SELECT
                  @cCustomNo =
                     CASE @cCustomCartonNo
                        WHEN '1' THEN LEFT( @cPD_DropID, 5)
                        WHEN '2' THEN LEFT( @cPD_RefNo, 5)
                        WHEN '3' THEN LEFT( @cPD_RefNo2, 5)
                        ELSE CAST( @nCartonNo AS NVARCHAR(5))
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
                        @nMobile, @nFunc, @cLangCode, 3, @nStep, @nInputKey, @cFacility, @cStorerKey, @tVar,
                        @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                        GOTO Step_99_6625_Fail

                     SET @cOutField15 = @cExtendedInfo
                  END
               END

               -- Prepare next screen var
               SET @cOutField01 = RTRIM( @cCustomNo)
               SET @cOutField02 = CAST( CAST( @cLabelLine AS INT) AS NVARCHAR(5)) + '/' + CAST( @nCartonSKU AS NVARCHAR(5))
               SET @cOutField03 = '' -- SKU
               SET @cOutField04 = @cSKU
               SET @cOutField05 = rdt.rdtFormatString( @cSKUDescr, 1, 20)
               SET @cOutField06 = rdt.rdtFormatString( @cSKUDescr, 21, 20)
               SET @cOutField07 = CAST( @nPackedQTY AS NVARCHAR( 8))    -- ZG02
               SET @cOutField08 = CASE WHEN @cDisableQTYField = '1' THEN @cQTY ELSE @cDefaultQTY END --(cc01)
               SET @cOutField09 = CAST( @nCartonQTY AS NVARCHAR( 5))
               SET @cOutField10 = CASE WHEN @cPrePackIndicator = '2' THEN @cPackQtyIndicator ELSE '' END
               SET @cOutField11 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END
               SET @cOutField12 = rdt.rdtRightAlign( @cPUOM_Desc, 5)
               SET @cOutField13 = rdt.rdtRightAlign( @cMUOM_Desc, 5)
               SET @cOutField14 = '' -- PQTY
               SET @nEnter = 0      --(cc01)  

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

               IF @cDefaultCursor <> ''
                  EXEC rdt.rdtSetFocusField @nMobile, @cDefaultCursor
               ELSE
               BEGIN
                  IF @cFieldAttr14 = 'O'
                     EXEC rdt.rdtSetFocusField @nMobile,  8
                  ELSE 
                     EXEC rdt.rdtSetFocusField @nMobile, 14
               END
            END
            ELSE IF @nInputKey = 0
            BEGIN
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

                     IF @nErrNo <> 0 -- V6.4 By JCH507
                     BEGIN
                        GOTO Step_99_6625_Fail
                     END
                  END
               END

               SET @cOutField01 = RTRIM( @cCustomNo)
               SET @cOutField02 = CAST( CAST( @cLabelLine AS INT) AS NVARCHAR(5)) + '/' + CAST( @nCartonSKU AS NVARCHAR(5))
               SET @cOutField03 = '' -- SKU
               SET @cOutField04 = ''
               SET @cOutField05 = ''
               SET @cOutField06 = ''
               SET @cOutField07 = CAST( @nPackedQTY AS NVARCHAR( 8))    -- ZG02
               SET @cOutField08 = CASE WHEN @cDisableQTYField = '1' THEN @cQTY ELSE @cDefaultQTY END --(cc01)
               SET @cOutField09 = CAST( @nCartonQTY AS NVARCHAR( 5))
               SET @cOutField10 = CASE WHEN @cPrePackIndicator = '2' THEN @cPackQtyIndicator ELSE '' END
               SET @cOutField11 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END
               SET @cOutField12 = rdt.rdtRightAlign( @cPUOM_Desc, 5)
               SET @cOutField13 = rdt.rdtRightAlign( @cMUOM_Desc, 5)
               SET @cOutField14 = '' -- PQTY
               --SET @cOutField15 = '' -- ExtendedInfo
               SET @nEnter = 0      --(cc01)  

               SET @nScn = 6624
               SET @nStep = 99
               GOTO Quit
            END

            Step_99_6625_Fail:
               IF rdt.RDTGetConfig( @nFunc, 'ShowErrMsgInNewScn', @cStorerkey) = '1'
               BEGIN
                  EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg
               END

               SET @cOutField08 = CASE WHEN @cFieldAttr08 = 'O' THEN @cOutField08 ELSE '' END -- PQTY
               SET @cOutField14 = CASE WHEN @cFieldAttr14 = 'O' THEN @cOutField14 ELSE '' END -- MQTY
               IF @cDefaultCursor <> ''
                  EXEC rdt.rdtSetFocusField @nMobile, @cDefaultCursor
               ELSE
               BEGIN
                  IF @cFieldAttr14 = 'O'
                     EXEC rdt.rdtSetFocusField @nMobile,  8
                  ELSE 
                     EXEC rdt.rdtSetFocusField @nMobile, 14
               END
         END
         GOTO Quit
      END
   END

   GOTO Quit

Quit:
   UPDATE rdt.RDTMOBREC WITH (ROWLOCK) SET
      EditDate = GETDATE(),
      ErrMsg = @cErrMsg,
      Func   = @nFunc,
      Step   = @nStep,
      Scn    = @nScn,

      StorerKey      = @cStorerKey,
      Facility       = @cFacility,
      -- UserName       = @cUserName,
      Printer_Paper  = @cPaperPrinter,
      Printer        = @cLabelPrinter,

      V_PickSlipNo   = @cPickSlipNo,
      V_SKU          = @cSKU,
      V_QTY          = @nQTY,
      -- V_CaseID       = @cCustomID,
      V_SKUDescr     = @cSKUDescr,
      V_FromScn      = @nFromScn,
      V_FromStep     = @nFromStep,
      V_UOM          = @cPUOM,

      V_String1      = @cPackDtlRefNo,
      V_String2      = @cPackDtlRefNo2,
      V_String3      = @cLabelNo,
      V_String4      = @cCartonType,
      V_String5      = @cCube,
      V_String6      = @cWeight,
      V_String7      = @cRefNo,
      V_String8      = @cLabelLine,
      V_String9      = @cPackDtlDropID,
      V_String10     = @cUCCCounter,
      V_String11     = @cMUOM_Desc,
      V_String12     = @cPUOM_Desc,
      V_String13     = @cDisableQTYFieldSP,
      V_String14     = @cFlowThruScreen, 

      V_CartonNo     = @nCartonNo,
      V_Integer1     = @nCartonSKU,
      V_Integer2     = @nCartonQTY,
      V_Integer3     = @nTotalCarton,
      V_Integer4     = @nTotalPick,
      V_Integer5     = @nTotalPack,
      V_Integer6     = @nTotalShort,
      V_Integer7     = @nPackedQTY,
      V_Integer8     = @nPUOM_Div,
      V_Integer9     = @nPQTY,
      V_Integer10    = @nMQTY,
      V_Integer11    = @nEnter,     --(cc01)  
      V_Integer12    = @nScan,

      V_String15     = @cShowPickSlipNo,
      V_String16     = @cDefaultPrintLabelOption,
      V_String17     = @cDefaultPrintPackListOption,
      V_String18     = @cDefaultWeight,
      V_String19     = @cUCCNo,
      V_String20     = @cFromDropID,
      V_String21     = @cExtendedValidateSP,
      V_String22     = @cExtendedUpdateSP,
      V_String23     = @cExtendedInfoSP,
      V_String24     = @cExtendedInfo,
      V_String25     = @cDecodeSP,
      V_String26     = @cDisableQTYField,
      V_String27     = @cCapturePackInfoSP,
      V_String28     = @cPackInfo,
      V_String29     = @cAllowWeightZero,
      V_String30     = @cAllowCubeZero,
      V_String31     = @cAutoScanIn,
      V_String32     = @cDefaultOption,
      V_String33     = @cDisableOption,
      V_String34     = @cSerialNoCapture,
      V_String35     = @cPackList,
      V_String36     = @cShipLabel,
      V_String37     = @cCartonManifest,
      V_String38     = @cCustomCartonNo,
      V_String39     = @cCustomNo,
      V_String40     = @cDataCaptureSP,
      V_String41     = @cPackDtlUPC,
      V_String42     = @cPrePackIndicator,
      V_String43     = @cPackQtyIndicator,
      V_String44     = @cPackData1,
      V_String45     = @cPackData2,
      V_String46     = @cPackData3,
      V_String47     = @cMultiSKUBarcode,
      V_String48     = @cDefaultQTY, --(cc01)
      V_String49     = @cDefaultcartontype,
      V_String50     = @cPackByFromDropID,
      V_String51     = @cDefaultCursor, --(v7.5)

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

GRANT EXECUTE ON [RDT].[rdt_838ExtScn05] TO NSQL
GO


