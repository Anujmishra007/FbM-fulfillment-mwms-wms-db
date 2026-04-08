
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Store procedure: rdt_838ExtScn07                                        */
/* Copyright      : Maersk                                                 */
/* Customer       :                                                        */
/*                                                                         */
/*                                                                         */
/* Date        Rev    Author     Purposes                                  */
/* 2026-01-07  1.0.0  Dennis     FCR-7820 Created                          */
/* 2026-03-26  1.1.0  Dennis     FCR-7820 Step1 loop scan DropID to        */
/*                               RDT.rdtPickLog                            */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_838ExtScn07] (
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
      @cScannedPickSlipNo NVARCHAR( 10),
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
      @fTotalCube          FLOAT,
      @cOverWriteCartonType  NVARCHAR( 1),
      @nScan               INT

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
      IF @nCurrentStep = 2
            UPDATE rdt.RDTMOBREC SET C_STRING1 = @cInField09 WHERE Mobile = @nMobile
      IF @nScn = 4650
      BEGIN
         -- Clear pick log
         DELETE FROM RDT.rdtPickLog
         WHERE StorerKey = @cStorerKey
            AND Mobile = @nMobile
            AND Status = '0'

         EXEC rdt.rdtSetFocusField @nMobile, 2
         -- Jump to DropID scan screen
         SET @cOutField01 = ''  -- DropID input
         SET @cOutField02 = ''
         SET @cOutField03 = ''
         SET @nAfterStep = 99
         SET @nAfterScn = 6861
         GOTO QUIT
      END

      IF @nScn = 6861
      BEGIN
         DECLARE @cScannedDropID NVARCHAR(20)

         IF @nInputKey = 1 -- ENTER
         BEGIN
            SET @cScannedPickSlipNo = ISNULL(@cInField01,'')
            SET @cScannedDropID = ISNULL(RTRIM(LTRIM(@cInField02)),'')
            SET @cPackDtlDropID = ISNULL(@cInField03,'')

            IF NOT EXISTS (SELECT 1 FROM RDT.rdtPickLog WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND Mobile = @nMobile
               AND Status = '0')
               SET @cPickSlipNo = ''

            IF @cPackDtlDropID <> '' AND 
            EXISTS (SELECT 1 FROM RDT.rdtPickLog WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND Mobile = @nMobile
               AND Status = '0'
               GROUP BY Mobile
               HAVING COUNT(DropID)>1
            )
            BEGIN
               SET @nErrNo = 180064
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               EXEC rdt.rdtSetFocusField @nMobile, 2
               GOTO Quit
            END

            -- Check blank
            IF @cScannedDropID = '' AND NOT EXISTS (
               SELECT 1 FROM RDT.rdtPickLog WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND Mobile = @nMobile
                  AND Status = '0'
            ) AND @cScannedPickSlipNo = ''
            BEGIN
               SET @nErrNo = 100247
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Need DropID
               EXEC rdt.rdtSetFocusField @nMobile, 2
               GOTO Quit
            END

            IF (@cScannedDropID = '' AND EXISTS (
               SELECT 1 FROM RDT.rdtPickLog WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND Mobile = @nMobile
                  AND Status = '0'
            )) OR @cScannedPickSlipNo <> ''
            BEGIN
               IF @cScannedPickSlipNo <> ''
                  SET @cPickSlipNo = @cScannedPickSlipNo

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

               -- (james17)
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

               -- Prepare next screen var
               SET @cOutField01 = @cPickSlipNo
               SET @cOutField02 = CAST( @nTotalPick AS NVARCHAR(8))  -- ZG02
               SET @cOutField03 = CAST( @nTotalPack AS NVARCHAR(8))  -- ZG02
               SET @cOutField04 = CAST( @nTotalShort AS NVARCHAR(8))  -- ZG02
               SET @cOutField05 = RTRIM( @cCustomNo) + '/' + CAST( @nTotalCarton AS NVARCHAR(5))
               SET @cOutField06 = @cCustomID
               SET @cOutField07 = CAST( @nCartonSKU AS NVARCHAR(5))
               SET @cOutField08 = CAST( @nCartonQTY AS NVARCHAR(5))
               SET @cOutField09 = @cDefaultOption

               -- Pass values to rdtfnc_Pack via UDF parameters
               SET @cUDF01 = @cPickSlipNo
               SET @cUDF02 = CAST( @nCartonNo AS NVARCHAR(10))
               SET @cUDF03 = @cLabelNo
               SET @cUDF04 = @cCustomNo
               SET @cUDF05 = @cCustomID
               SET @cUDF06 = CAST( @nCartonSKU AS NVARCHAR(10))
               SET @cUDF07 = CAST( @nCartonQTY AS NVARCHAR(10))
               SET @cUDF08 = CAST( @nTotalCarton AS NVARCHAR(10))
               SET @cUDF09 = CAST( @nTotalPick AS NVARCHAR(10))
               SET @cUDF10 = CAST( @nTotalPack AS NVARCHAR(10))
               SET @cUDF11 = CAST( @nTotalShort AS NVARCHAR(10))
               SET @cUDF12 = @cPackDtlDropID

               SET @nAfterStep = 2
               SET @nAfterScn = 4651
               GOTO QUIT
            END

            -- Check DropID format
            IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'FROMDROPID', @cScannedDropID) = 0
            BEGIN
               SET @nErrNo = 100233
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Format
               EXEC rdt.rdtSetFocusField @nMobile, 2
               SET @cOutField01 = ''
               GOTO Quit
            END

            -- Check DropID exists in PickDetail
            IF NOT EXISTS (
               SELECT 1 FROM PickDetail WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND DropID = @cScannedDropID
                  AND Status <= '5'
            )
            BEGIN
               SET @nErrNo = 100234
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid DropID
               EXEC rdt.rdtSetFocusField @nMobile, 2
               SET @cOutField01 = ''
               GOTO Quit
            END

            -- Check if already scanned (exists in rdtPickLog for this session)
            IF EXISTS (
               SELECT 1 FROM RDT.rdtPickLog WITH (NOLOCK)
               WHERE DropID = @cScannedDropID
                  AND StorerKey = @cStorerKey
                  AND Mobile = @nMobile
                  AND Status = '0'
            )
            BEGIN
               SET @nErrNo = 180062
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Already Scanned
               EXEC rdt.rdtSetFocusField @nMobile, 2
               SET @cOutField02 = ''
               GOTO Quit
            END

            -- Get DropID info
            SET @cOrderKey = ''
            SELECT TOP 1
               @cOrderKey = OrderKey
            FROM PickDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND DropID = @cScannedDropID
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

            -- Get discrete pick slip
            SELECT @cPickSlipNo = PickHeaderKey
            FROM PickHeader WITH (NOLOCK)
            WHERE OrderKey = @cOrderKey

            -- Get conso pick slip by WaveKey (Orders.UserDefine09)
            IF ISNULL(@cPickSlipNo,'') = ''
            BEGIN
               DECLARE @cWaveKey NVARCHAR(10)
               SET @cWaveKey = ''

               -- Get WaveKey from Orders.UserDefine09
               SELECT @cWaveKey = UserDefine09
               FROM Orders WITH (NOLOCK)
               WHERE OrderKey = @cOrderKey

               -- Check if PickHeader exists with this WaveKey
               IF @cWaveKey <> ''
               BEGIN
                  SELECT @cPickSlipNo = PickHeaderKey
                  FROM PickHeader WITH (NOLOCK)
                  WHERE WaveKey = @cWaveKey

                  -- If PickHeader exists but not for this order, create new PickSlipNo
                  IF @cPickSlipNo <> '' AND NOT EXISTS (
                     SELECT 1 FROM PickHeader WITH (NOLOCK)
                     WHERE OrderKey = @cOrderKey
                  )
                  BEGIN
                     DECLARE @cNewPickSlipNo NVARCHAR(10)

                     EXECUTE nspg_GetKey 'PICKSLIP', 9, @cNewPickSlipNo OUTPUT, @bSuccess OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT
                     IF @bSuccess <> 1
                     BEGIN
                        SET @nErrNo = 180066
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- GenPickSlipFail
                        GOTO Quit
                     END

                     SET @cNewPickSlipNo = 'P' + @cNewPickSlipNo

                     BEGIN TRY
                        INSERT INTO PickHeader (PickHeaderKey, ExternOrderKey, OrderKey, PickType, Zone, StorerKey, WaveKey)
                        VALUES (@cNewPickSlipNo, '', @cOrderKey, '0', '', @cStorerKey, @cWaveKey)
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 180067
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- InsPickHdrFail
                        GOTO Quit
                     END CATCH

                     SET @cPickSlipNo = @cNewPickSlipNo
                  END
               END
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

            -- Check if scanned DropID belongs to same PickSlipNo as previously scanned
            DECLARE @cExistingPickSlipNo NVARCHAR(10)
            SELECT TOP 1 @cExistingPickSlipNo = PickSlipNo
            FROM RDT.rdtPickLog WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND Mobile = @nMobile
               AND Status = '0'

            IF @cExistingPickSlipNo IS NOT NULL AND @cExistingPickSlipNo <> @cPickSlipNo
            BEGIN
               SET @nErrNo = 180065
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- DiffPickSlipNo
               EXEC rdt.rdtSetFocusField @nMobile, 2
               SET @cOutField02 = ''
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

            -- Insert PickDetail records into RDT.rdtPickLog
            BEGIN TRY
               INSERT INTO RDT.rdtPickLog (
                  WaveKey, OrderKey, OrderLineNumber, PickDetailKey,
                  StorerKey, Sku, Descr, Loc, Lot, Id,
                  ActQty, PickQty, UOM, PackKey,
                  Lottable01, Lottable02, Lottable03, Lottable04, Lottable05,
                  PickSlipNo, Status, AddWho, AddDate, DropID, Mobile
               )
               SELECT
                  PD.WaveKey,
                  PD.OrderKey,
                  PD.OrderLineNumber,
                  PD.PickDetailKey,
                  PD.StorerKey,
                  PD.Sku,
                  S.Descr,
                  PD.Loc,
                  PD.Lot,
                  PD.ID,
                  PD.Qty,
                  PD.Qty,
                  PD.UOM,
                  PD.PackKey,
                  '',
                  '',
                  '',
                  NULL,
                  NULL,
                  @cPickslipNo,
                  '0',  -- Status: 0=Pending
                  @cUserName,
                  GETDATE(),
                  PD.DropID,
                  @nMobile
               FROM PickDetail PD WITH (NOLOCK)
               JOIN SKU S WITH (NOLOCK) ON S.StorerKey = PD.StorerKey AND S.SKU = PD.SKU
               LEFT JOIN LOTxLOCxID LLI WITH (NOLOCK) ON LLI.StorerKey = PD.StorerKey
                  AND LLI.SKU = PD.SKU AND LLI.Loc = PD.Loc AND LLI.Lot = PD.Lot AND LLI.ID = PD.ID
               WHERE PD.StorerKey = @cStorerKey
                  AND PD.DropID = @cScannedDropID
                  AND PD.Status <= '5'
                  AND NOT EXISTS (
                     SELECT 1 FROM RDT.rdtPickLog PL WITH (NOLOCK)
                     WHERE PL.PickDetailKey = PD.PickDetailKey
                        AND PL.Mobile = @nMobile
                        AND PL.Status = '0'
                  )
            END TRY
            BEGIN CATCH
               SET @nErrNo = 180063
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Insert Failed
               GOTO Quit
            END CATCH

            IF @cPackDtlDropID <> ''
            BEGIN
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

               -- (james17)
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

               -- Prepare next screen var
               SET @cOutField01 = @cPickSlipNo
               SET @cOutField02 = CAST( @nTotalPick AS NVARCHAR(8))  -- ZG02
               SET @cOutField03 = CAST( @nTotalPack AS NVARCHAR(8))  -- ZG02
               SET @cOutField04 = CAST( @nTotalShort AS NVARCHAR(8))  -- ZG02
               SET @cOutField05 = RTRIM( @cCustomNo) + '/' + CAST( @nTotalCarton AS NVARCHAR(5))
               SET @cOutField06 = @cCustomID
               SET @cOutField07 = CAST( @nCartonSKU AS NVARCHAR(5))
               SET @cOutField08 = CAST( @nCartonQTY AS NVARCHAR(5))
               SET @cOutField09 = @cDefaultOption

               -- Pass values to rdtfnc_Pack via UDF parameters
               SET @cUDF01 = @cPickSlipNo
               SET @cUDF02 = CAST( @nCartonNo AS NVARCHAR(10))
               SET @cUDF03 = @cLabelNo
               SET @cUDF04 = @cCustomNo
               SET @cUDF05 = @cCustomID
               SET @cUDF06 = CAST( @nCartonSKU AS NVARCHAR(10))
               SET @cUDF07 = CAST( @nCartonQTY AS NVARCHAR(10))
               SET @cUDF08 = CAST( @nTotalCarton AS NVARCHAR(10))
               SET @cUDF09 = CAST( @nTotalPick AS NVARCHAR(10))
               SET @cUDF10 = CAST( @nTotalPack AS NVARCHAR(10))
               SET @cUDF11 = CAST( @nTotalShort AS NVARCHAR(10))
               SET @cUDF12 = @cPackDtlDropID

               SET @nAfterStep = 2
               SET @nAfterScn = 4651
               GOTO QUIT
            END

            EXEC rdt.rdtSetFocusField @nMobile, 2
            -- Loop back to scan next DropID
            SET @cUDF01 = @cPickSlipNo
            SET @cUDF12 = @cPackDtlDropID
            SET @cOutField01 = ''
            SET @cOutField02 = ''  -- Clear for next scan
            SET @cOutField03 = ''
            SET @nAfterStep = 99
            SET @nAfterScn = 6861
            GOTO QUIT
         END
         IF @nInputKey = 0
         BEGIN
            -- Clear pick log
            DELETE FROM RDT.rdtPickLog
            WHERE StorerKey = @cStorerKey
               AND Mobile = @nMobile
               AND Status = '0'
         END
      END

      IF (@nCurrentStep = 2 AND @nAfterStep = 3)
      OR (@nCurrentStep = 7 AND @nAfterStep = 3)
      BEGIN
         SET @cOutField01 = ''
         -- Check if any DropID scanned in rdtPickLog
         DECLARE @nDropIDCount INT = 0
         SELECT @nDropIDCount = COUNT(DISTINCT DropID)
         FROM RDT.rdtPickLog WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND Mobile = @nMobile
            AND Status = '0'

         -- Check WTW order type (from scanned DropIDs or PickSlipNo)
         IF @nDropIDCount > 0
         BEGIN
            -- Use scanned DropIDs from rdtPickLog
            IF EXISTS (
               SELECT 1 FROM ORDERS O (NOLOCK)
               JOIN RDT.rdtPickLog PL (NOLOCK) ON O.OrderKey = PL.OrderKey AND O.StorerKey = PL.StorerKey
               JOIN CodeLKUP CL (NOLOCK) ON O.STORERKEY = CL.STORERKEY AND CL.ListName = 'ORDERTYPE' AND CL.Code = O.Type
               WHERE CL.UDF02 = 'WTW'
                  AND PL.StorerKey = @cStorerKey
                  AND PL.Mobile = @nMobile
                  AND PL.Status = '0'
            )
            BEGIN
               SELECT TOP 1 @cOutField01 = Code
               FROM CodeLKUP CL (NOLOCK)
               JOIN Cartonization CZ WITH (NOLOCK) ON CL.Code = CZ.CartonType
               JOIN Storer S WITH (NOLOCK) ON (S.CartonGroup = CZ.CartonizationGroup AND S.StorerKey = CL.StorerKey)
               WHERE CL.ListName = 'PAGECARTON'
               AND S.StorerKey = @cStorerKey
               AND CL.UDF01 = 'Y'
               AND CL.UDF02 = 'WTW'
            END
            ELSE
            BEGIN
               -- Calculate total cube from all scanned DropIDs in rdtPickLog
               SELECT @fTotalCube = SUM(SKU.STDCUBE * PL.ActQty)
               FROM RDT.rdtPickLog PL (NOLOCK)
               JOIN SKU SKU (NOLOCK) ON PL.STORERKEY = SKU.STORERKEY AND PL.SKU = SKU.SKU
               WHERE PL.STORERKEY = @cStorerKey
                  AND PL.Mobile = @nMobile
                  AND PL.Status = '0'

               SELECT TOP 1 @cOutField01 = Code
               FROM CodeLKUP CL (NOLOCK)
               JOIN Cartonization CZ WITH (NOLOCK) ON CL.Code = CZ.CartonType
               JOIN Storer S WITH (NOLOCK) ON (S.CartonGroup = CZ.CartonizationGroup AND S.StorerKey = CL.StorerKey)
               --JOIN LOTxLOCxID LLI WITH (NOLOCK) ON LLI.StorerKey = S.StorerKey AND LLI.SKU = CL.CODE AND (QTY-QtyPicked-QTYAllocated) > 0
               --JOIN SKU SKU WITH (NOLOCK) ON SKU.StorerKey = S.StorerKey AND SKU.SKU = CL.CODE --AND BUSR8 = CZ.CartonType
               WHERE CL.ListName = 'PAGECARTON'
               AND S.StorerKey = @cStorerKey
               AND CL.UDF01 = 'Y'
               AND CAST(CZ.Cube AS FLOAT) >= @fTotalCube
               ORDER BY CAST(CZ.Cube AS FLOAT) ASC
            END
         END

         SET @cOutField02 = ''
         SET @nAfterStep = 99
         SET @nAfterScn = 6827
         GOTO QUIT
      END
      IF @nScn = 6827
      BEGIN
         IF @nInputKey = 1
         BEGIN
            SET @cCartonType  =  @cInField02

            -- Check blank
            IF @cCartonType = ''
            BEGIN
               SET @nErrNo = 100210
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NeedCartonType
               EXEC rdt.rdtSetFocusField @nMobile, 2
               GOTO Quit 
            END

            SET @cOverWriteCartonType = RDT.RDTGetConfig( @nFunc, 'OverWriteCartonType', @cStorerKey)

            IF @cOverWriteCartonType <> '1' AND @cCartonType <> @cOutField01
            BEGIN
               SET @nErrNo = 255758
               SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') --Cannot Overwrite Carton Type
               EXEC rdt.rdtSetFocusField @nMobile, 2
               GOTO Quit 
            END

            IF @cOverWriteCartonType = '1' AND @cCartonType <> @cOutField01
            AND NOT EXISTS (SELECT 1
            FROM CodeLKUP CL (NOLOCK)
            JOIN Cartonization CZ WITH (NOLOCK) ON CL.Code = CZ.CartonType
            JOIN Storer S WITH (NOLOCK) ON (S.CartonGroup = CZ.CartonizationGroup AND S.StorerKey = CL.StorerKey)
            --JOIN LOTxLOCxID LLI WITH (NOLOCK) ON LLI.StorerKey = S.StorerKey AND LLI.SKU = CL.CODE AND (QTY-QtyPicked-QTYAllocated) > 0
            --JOIN SKU SKU WITH (NOLOCK) ON SKU.StorerKey = S.StorerKey AND SKU.SKU = CL.CODE --AND BUSR8 = CZ.CartonType
            WHERE CL.ListName = 'PAGECARTON'
            AND S.StorerKey = @cStorerKey
            AND CL.Code = @cCartonType
            AND CL.UDF01 = 'Y')
            BEGIN
               SET @nErrNo = 180061
               SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') --Invalid Carton Type
               EXEC rdt.rdtSetFocusField @nMobile, 2
               GOTO Quit
            END

            -- Get default cube
            DECLARE @nDefaultCube FLOAT
            SELECT @nDefaultCube = [Cube]
            FROM Cartonization WITH (NOLOCK)
               INNER JOIN Storer WITH (NOLOCK) ON (Storer.CartonGroup = Cartonization.CartonizationGroup)
            WHERE Storer.StorerKey = @cStorerKey
               AND Cartonization.CartonType = @cCartonType

            --(v7.5) start
            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount = 0
            BEGIN
               SELECT
                  @cCartonType = CartonType,
                  @nDefaultCube = [Cube]
               FROM Cartonization WITH (NOLOCK)
                  INNER JOIN Storer WITH (NOLOCK) ON (Storer.CartonGroup = Cartonization.CartonizationGroup)
               WHERE Storer.StorerKey = @cStorerKey
                  AND Cartonization.Barcode = @cCartonType

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
            SET @cUDF01 = @cCartonType
            UPDATE RDT.RDTMOBREC SET C_STRING2 = @cCartonType WHERE Mobile = @nMobile

            -- Get Option from C_STRING1
            SELECT @cOption = C_STRING1 FROM RDT.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile

            -- Option 1: New carton
            IF @cOption = '1'
            BEGIN
               SET @nCartonNo = 0
               SET @cLabelNo = ''
               SET @cSKU = ''
               SET @nPackedQTY = 0
               SET @nCartonSKU = 0
               SET @nCartonQTY = 0

               -- Prepare next screen var
               SET @cOutField01 = 'NEW'
               SET @cOutField02 = '0/0'
               SET @cOutField03 = ''  -- SKU
               SET @cOutField04 = ''  -- SKU
               SET @cOutField05 = ''  -- Desc 1
               SET @cOutField06 = ''  -- Desc 2
               SET @cOutField07 = '0' -- Packed
               SET @cOutField08 = @cDefaultQTY  -- QTY
               SET @cOutField09 = '0' -- CartonQTY
               SET @cOutField11 = '' -- UOM
               SET @cOutField12 = '' -- PUOM
               SET @cOutField13 = '' -- MUOM
               SET @cOutField14 = '' -- PQTY
               SET @cOutField15 = '' -- ExtendedInfo

               -- Enable field
               SET @cFieldAttr08 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END
               SET @cFieldAttr14 = 'O'

               -- Pass values via UDF
               SET @cUDF02 = CAST(@nCartonNo AS NVARCHAR(10))
               SET @cUDF03 = @cLabelNo
               SET @cUDF04 = @cSKU
               SET @cUDF05 = CAST(@nPackedQTY AS NVARCHAR(10))
               SET @cUDF06 = CAST(@nCartonSKU AS NVARCHAR(10))
               SET @cUDF07 = CAST(@nCartonQTY AS NVARCHAR(10))

               EXEC rdt.rdtSetFocusField @nMobile, 6  -- SKU
            END

            -- Option 2: Edit carton
            ELSE IF @cOption = '2'
            BEGIN
               -- Check UCC
               IF EXISTS( SELECT 1 FROM PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo AND UCCNo <> '')
               BEGIN
                  SET @nErrNo = 100229
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Cannot EditUCC
                  GOTO Quit
               END

               -- Get carton info
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

               -- Get PackDetail info
               SELECT @nPackedQTY = PD.QTY
               FROM dbo.PackDetail PD WITH (NOLOCK)
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND CartonNo = @nCartonNo
                  AND LabelNo = @cLabelNo
                  AND LabelLine = @cLabelLine

               -- Convert to prefer UOM QTY
               IF @cPUOM = '6' OR @nPUOM_Div = 0
               BEGIN
                  SET @cPUOM_Desc = ''
                  SET @nPQTY = 0
                  SET @cFieldAttr14 = 'O' -- @nPQTY
               END
               ELSE
               BEGIN
                  SET @cFieldAttr14 = '' -- @nPQTY
               END

               -- Prepare next screen var
               SET @cOutField01 = RTRIM( @cCustomNo)
               SET @cOutField02 = CAST( CAST( @cLabelLine AS INT) AS NVARCHAR(5)) + '/' + CAST( @nCartonSKU AS NVARCHAR(5))
               SET @cOutField03 = '' -- SKU
               SET @cOutField04 = @cSKU
               SET @cOutField05 = rdt.rdtFormatString( @cSKUDescr, 1, 20)
               SET @cOutField06 = rdt.rdtFormatString( @cSKUDescr, 21, 20)
               SET @cOutField07 = CAST( @nPackedQTY AS NVARCHAR( 8))
               SET @cOutField08 = '' -- QTY
               SET @cOutField09 = CAST( @nCartonQTY AS NVARCHAR( 5))
               SET @cOutField10 = CASE WHEN @cPrePackIndicator = '2' THEN @cPackQtyIndicator ELSE '' END
               SET @cOutField11 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END
               SET @cOutField12 = rdt.rdtRightAlign( @cPUOM_Desc, 5)
               SET @cOutField13 = rdt.rdtRightAlign( @cMUOM_Desc, 5)
               SET @cOutField14 = '' -- PQTY
               SET @cOutField15 = '' -- ExtendedInfo

               -- Enable field
               SET @cFieldAttr08 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END

               -- Pass values via UDF
               SET @cUDF02 = CAST(@nCartonNo AS NVARCHAR(10))
               SET @cUDF03 = @cLabelNo
               SET @cUDF04 = @cSKU
               SET @cUDF05 = CAST(@nPackedQTY AS NVARCHAR(10))
               SET @cUDF06 = CAST(@nCartonSKU AS NVARCHAR(10))
               SET @cUDF07 = CAST(@nCartonQTY AS NVARCHAR(10))
               SET @cUDF08 = @cLabelLine
               SET @cUDF09 = @cSKUDescr
               SET @cUDF10 = @cPrePackIndicator
               SET @cUDF11 = @cPackQtyIndicator
               SET @cUDF12 = @cMUOM_Desc
               SET @cUDF13 = @cPUOM_Desc
               SET @cUDF14 = CAST(@nPUOM_Div AS NVARCHAR(10))
               SET @cUDF15 = CAST(@nPQTY AS NVARCHAR(10))

               EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU
            END

            -- Option 3: Repack carton
            ELSE IF @cOption = '3'
            BEGIN
               SET @cSKU = ''
               SET @nPackedQTY = 0
               SET @nCartonSKU = 0
               SET @nCartonQTY = 0

               -- Prepare next screen var
               SET @cOutField01 = RTRIM( @cCustomNo)
               SET @cOutField02 = '0/0'
               SET @cOutField03 = ''  -- SKU
               SET @cOutField04 = ''  -- SKU
               SET @cOutField05 = ''  -- Desc 1
               SET @cOutField06 = ''  -- Desc 2
               SET @cOutField07 = '0' -- Packed
               SET @cOutField08 = ''  -- QTY
               SET @cOutField09 = '0' -- CartonQTY
               SET @cOutField15 = ''  -- ExtendedInfo

               -- Enable field
               SET @cFieldAttr08 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END

               -- Pass values via UDF
               SET @cUDF02 = CAST(@nCartonNo AS NVARCHAR(10))
               SET @cUDF03 = @cLabelNo
               SET @cUDF04 = @cSKU
               SET @cUDF05 = CAST(@nPackedQTY AS NVARCHAR(10))
               SET @cUDF06 = CAST(@nCartonSKU AS NVARCHAR(10))
               SET @cUDF07 = CAST(@nCartonQTY AS NVARCHAR(10))

               EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU
            END

            -- Option 4: UCC
            ELSE IF @cOption = '4'
            BEGIN
               -- Get total UCC
               SELECT @nTotalUCC = COUNT(1) FROM PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND UCCNo <> ''

               -- Prepare next screen var
               SET @cOutField01 = '' -- UCC
               SET @cOutField02 = '' -- Scan
               SET @cOutField03 = CAST( @nTotalUCC AS NVARCHAR( 5))

               -- Pass values via UDF
               SET @cUDF02 = CAST(@nTotalUCC AS NVARCHAR(10))

               -- Go to UCC screen
               SET @nAfterScn = 4657
               SET @nAfterStep = 8
               GOTO Quit
            END

            SET @nAfterStep = 3
            SET @nAfterScn = 4652
         END
         ELSE IF @nInputKey = 0
         BEGIN

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
               GOTO Quit

            SET @cUDF01 = CAST( @nCartonNo AS NVARCHAR(5))
            SET @cUDF02 = @cLabelNo
            SET @cUDF03 = @cCustomNo
            SET @cUDF04 = @cCustomID
            SET @cUDF05 = CAST( @nCartonSKU AS NVARCHAR(5))
            SET @cUDF06 = CAST( @nCartonQTY AS NVARCHAR(5))
            SET @cUDF07 = CAST( @nTotalCarton AS NVARCHAR(5))
            SET @cUDF08 = CAST( @nTotalPick AS NVARCHAR(8))
            SET @cUDF09 = CAST( @nTotalPack AS NVARCHAR(8))
            SET @cUDF10 = CAST( @nTotalShort AS NVARCHAR(8))

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
            SET @nAfterStep = 2
            SET @nAfterScn = 4651
            GOTO QUIT
         END
      END
      IF @nCurrentStep = 3 AND @nInputKey = 0
      BEGIN
         IF @nStep = 4
         BEGIN
            SELECT @cOutField01 = C_STRING2 FROM RDT.RDTMOBREC WHERE Mobile = @nMobile
            GOTO QUIT
         END
         SET @cOutField01 = ''
         -- Check if any DropID scanned in rdtPickLog
         SET @nDropIDCount = 0
         SELECT @nDropIDCount = COUNT(DISTINCT DropID)
         FROM RDT.rdtPickLog WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND Mobile = @nMobile
            AND Status = '0'

         -- Check WTW order type (from scanned DropIDs or PickSlipNo)
         IF @nDropIDCount > 0
         BEGIN
            -- Use scanned DropIDs from rdtPickLog
            IF EXISTS (
               SELECT 1 FROM ORDERS O (NOLOCK)
               JOIN RDT.rdtPickLog PL (NOLOCK) ON O.OrderKey = PL.OrderKey AND O.StorerKey = PL.StorerKey
               JOIN CodeLKUP CL (NOLOCK) ON O.STORERKEY = CL.STORERKEY AND CL.ListName = 'ORDERTYPE' AND CL.Code = O.Type
               WHERE CL.UDF02 = 'WTW'
                  AND PL.StorerKey = @cStorerKey
                  AND PL.Mobile = @nMobile
                  AND PL.Status = '0'
            )
            BEGIN
               SELECT TOP 1 @cOutField01 = Code
               FROM CodeLKUP CL (NOLOCK)
               JOIN Cartonization CZ WITH (NOLOCK) ON CL.Code = CZ.CartonType
               JOIN Storer S WITH (NOLOCK) ON (S.CartonGroup = CZ.CartonizationGroup AND S.StorerKey = CL.StorerKey)
               WHERE CL.ListName = 'PAGECARTON'
               AND S.StorerKey = @cStorerKey
               AND CL.UDF01 = 'Y'
               AND CL.UDF02 = 'WTW'
            END
            ELSE
            BEGIN
               -- Calculate total cube from all scanned DropIDs in rdtPickLog
               SELECT @fTotalCube = SUM(SKU.STDCUBE * PL.ActQty)
               FROM RDT.rdtPickLog PL (NOLOCK)
               JOIN SKU SKU (NOLOCK) ON PL.STORERKEY = SKU.STORERKEY AND PL.SKU = SKU.SKU
               WHERE PL.STORERKEY = @cStorerKey
                  AND PL.Mobile = @nMobile
                  AND PL.Status = '0'

               SELECT TOP 1 @cOutField01 = Code
               FROM CodeLKUP CL (NOLOCK)
               JOIN Cartonization CZ WITH (NOLOCK) ON CL.Code = CZ.CartonType
               JOIN Storer S WITH (NOLOCK) ON (S.CartonGroup = CZ.CartonizationGroup AND S.StorerKey = CL.StorerKey)
               --JOIN LOTxLOCxID LLI WITH (NOLOCK) ON LLI.StorerKey = S.StorerKey AND LLI.SKU = CL.CODE AND (QTY-QtyPicked-QTYAllocated) > 0
               --JOIN SKU SKU WITH (NOLOCK) ON SKU.StorerKey = S.StorerKey AND SKU.SKU = CL.CODE --AND BUSR8 = CZ.CartonType
               WHERE CL.ListName = 'PAGECARTON'
               AND S.StorerKey = @cStorerKey
               AND CL.UDF01 = 'Y'
               AND CAST(CZ.Cube AS FLOAT) >= @fTotalCube
               ORDER BY CAST(CZ.Cube AS FLOAT) ASC
            END
         END

         SET @cOutField02 = ''
         SET @nAfterStep = 99
         SET @nAfterScn = 6827
         GOTO QUIT
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

GRANT EXECUTE ON [RDT].[rdt_838ExtScn07] TO NSQL
GO


