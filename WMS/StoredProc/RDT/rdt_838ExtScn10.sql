
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Store procedure: rdt_838ExtScn10                                        */
/* Copyright      : Maersk                                                 */
/* Customer       : AEOMX                                                  */
/*                                                                         */
/*                                                                         */
/* Date        Rev    Author     Purposes                                  */
/* 2026-06-30  1.0.0  JackC      FCR-12984 Created                         */
/* 2026-07-08  1.1.0  NickT      FCR-14763 Add B2C Single logic            */
/* 2026-07-16  1.2.0  JackC      FCR-12984 Update getting carton type logic*/
/* 2026-07-22  1.2.1  JackC      FCR-12984 Update carton cube logic        */
/* 2026-07-27  1.2.2  JackC      FCR-12984 Get Packed Qty from open PSNO   */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_838ExtScn10] (
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
      @nRowCount      INT = 0, 
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
      @cUPC                   NVARCHAR( 30),
      @cQTY                   NVARCHAR( 5),
      @nDecodeQTY             INT,
      @cPackDtlDropID_Decode  NVARCHAR(20),
      @cSKUDataCapture        NVARCHAR(1),
      @cDataCapture           NVARCHAR(1),
      @cSkipChkPPKQTY         NVARCHAR(1) = '0',

      @cCstLabelSP   NVARCHAR(30),
      @nMobrecStep    INT,
      @nMobrecScn     INT,

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
      @cBarcode         NVARCHAR( 60),
                        
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
      @fTotalCube          FLOAT,
      @cOverWriteCartonType  NVARCHAR( 1),
      @nScan               INT,
      @nTranCount          INT

   --Extscn variable
   DECLARE
      @cWaveKey               NVARCHAR( 10),
      @cWaveType              NVARCHAR( 20),
      @cVirtualCartonID       NVARCHAR( 20),
      @cFromLoc               NVARCHAR( 10),
      @cPackSTGLoc            NVARCHAR( 10),
      @cMarshallingLane       NVARCHAR( 10),
      @cFromID                NVARCHAR( 18),
      @cToID                  NVARCHAR( 18),
      @cMoveToPackSTGFlag     NVARCHAR( 1),
      @cPickStatus            NVARCHAR( 1),
      @cMoveQTYAlloc          NVARCHAR( 1),
      @cMoveQTYPick           NVARCHAR( 1),
      @cDeviceProfileKey      NVARCHAR( 10),
      @nCounter               INT,

      @cSuggestedCartonType   NVARCHAR( 10),
      @cCartonTypeConfirmed   NVARCHAR( 1),
      @cOrderType             NVARCHAR( 10),
      @cB2CSingleFlag         NVARCHAR( 1),
      @cFromDropIDDecode      NVARCHAR( 20),
      @cToDropIDDecode        NVARCHAR( 20),
      @nPackedDetailPackedQty INT,
      @nPackedDetailExpQty    INT,
      @cFetchedOrderKey       NVARCHAR(10),

      --Movement variables
      @cMoveSKU               NVARCHAR( 10),
      @cMoveLot               NVARCHAR( 10),
      @cMoveFromLoc           NVARCHAR( 10),
      @cMoveToLoc             NVARCHAR( 10),
      @cMoveFromID            NVARCHAR( 18),
      @cMoveToID              NVARCHAR( 18),
      @cMoveDropID            NVARCHAR( 20),
      @nQTYAlloc              INT,
      @nQtyPick               INT,
      @nMoveQty               INT,

      @nEcomExpPackQty        INT,
      @nEcomPackQty           INT

   DECLARE @tMoveList TABLE (
      RowNumber   INT IDENTITY(1,1) PRIMARY KEY,
      FromLoc     NVARCHAR( 10) NOT NULL,
      FromID      NVARCHAR( 18) NOT NULL,
      ToLoc       NVARCHAR( 10) NOT NULL,
      ToID        NVARCHAR( 18) NOT NULL,
      SKU         NVARCHAR( 20) NOT NULL,
      Lot         NVARCHAR( 10) NOT NULL,
      Qty         INT           NOT NULL,
      DropID      NVARCHAR( 20) NOT NULL,
      REMARK      NVARCHAR( 100) 
   )

   SET @cUDF01 = ''
   SET @cUDF02 = ''
   SET @nTranCount = @@TRANCOUNT

   SELECT
      @nFunc            = Func,
      --@nInputKey        = InputKey,
      @nMenu            = Menu,
      @cLangCode        = Lang_code,
      @nMobrecStep      = Step,
      @nMobrecScn       = Scn,

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
      --Extscn variable
      @cWaveKey            = C_STRING1,
      @cWaveType           = C_STRING2,
      @cMoveToPackSTGFlag  = C_STRING3,
      @cPackSTGLoc         = C_STRING4,
      @cSuggestedCartonType = C_STRING5,
      @cVirtualCartonID     = C_STRING6,
      @cB2CSingleFlag       = C_STRING7

   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nDebugFlag = 1
      SELECT 'Executing 838ExtScn10', @nStep AS Step, @nScn AS Scn, @nInputKey As InputKey

   SET @cMoveQTYAlloc = rdt.RDTGetConfig( @nFunc, 'MoveQTYAlloc', @cStorerKey)
   SET @cMoveQTYPick = rdt.RDTGetConfig( @nFunc, 'MoveQTYPick', @cStorerKey)
   SET @cPickStatus = rdt.RDTGetConfig( @nFunc, 'PickStatus', @cStorerKey)
   IF @cPickStatus = '0'
      SET @cPickStatus = '5'

   IF @nFunc = 838
   BEGIN
      IF @nMobrecStep = 0 -- step_0, reset all C_STRING variables
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Step_0, Reset C_STRING variables'
         SELECT 
            @cWaveKey= '',
            @cWaveType = '',
            @cMoveToPackSTGFlag = '',
            @cPackSTGLoc = '',
            @cSuggestedCartonType = '',
            @cVirtualCartonID = ''

         GOTO Quit
      END

      IF @nStep = 2 AND @nScn = 4651 AND @nMobrecStep = 1 AND @nMobrecScn = 4650 -- From st1 to st2
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'From St1 to St2, Enter'

            SET @cFromDropID = @cInField02
            SET @cWaveKey = ''
            SET @cVirtualCartonID = ''
            SET @cFromLoc = ''
            SET @cPackSTGLoc = ''
            SET @cFromID = ''
            SET @cToID  = ''
            SET @cWaveType = ''
            SET @cMoveToPackSTGFlag = ''
            SET @cB2CSingleFlag = 'N'
            SET @cOrderType = ''

            BEGIN TRY
               DELETE @tMoveList
            END TRY
            BEGIN CATCH
               SET @nErrNo = 272351
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Delete tMoveList failed
               GOTO Fail_St1toSt2
            END CATCH

            SELECT TOP 1
               @cWaveKey = ISNULL(WaveKey, ''),
               @cVirtualCartonID = ISNULL(CaseID, ''), -- For ECOM, it is label no.
               @cFromLoc = Loc,
               @cFromID = ID
            FROM dbo.PickDetail WITH (NOLOCK)
               WHERE DropID = @cFromDropID
                  AND StorerKey = @cStorerKey
                  AND Status = @cPickStatus
                  AND Qty > 0
                  AND CHARINDEX('[PACKED]', ISNULL(NOTES, '')) = 0

            IF @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo  = 272384
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --NoPKDForPacking
               GOTO Fail_St1toSt2
            END

            SELECT
               @cWaveType = ISNULL(UserDefine03, ''),
               @cOrderType = ISNULL(UserDefine05, '')
            FROM dbo.Wave WITH (NOLOCK)
               WHERE WaveKey = @cWaveKey

            --release locations on PTW
            IF EXISTS (SELECT 1 FROM dbo.CODELKUP WITH (NOLOCK)
                        WHERE  ListName = 'AEO_PTWSTG' AND StorerKey = @cStorerKey AND Code = @cFromLoc)
            BEGIN -- FromLoc is a PTW loc
               SET @cDeviceProfileKey = ''
               
               SELECT @cDeviceProfileKey = DeviceProfileKey FROM dbo.DeviceProfile WITH (NOLOCK) 
               WHERE DeviceID = @cWaveType AND Loc = @cFromLoc

               IF ISNULL(@cDeviceProfileKey, '') <> ''
               BEGIN
                  BEGIN TRY
                     UPDATE dbo.DeviceProfile SET Status = 'IDLE' WHERE DeviceProfileKey = @cDeviceProfileKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 272352
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Upd DeviceProfile failed
                     GOTO Fail_St1toSt2
                  END CATCH

                  SET @cMoveToPackSTGFlag = 'Y' --move FromDropID to pack stg   

                  IF @nDebugFlag = 1
                     SELECT 'From St1 to St2, FromLoc is a PTW loc', @cMoveToPackSTGFlag AS MoveToPackSTGFlag
               END
            END
            ELSE IF EXISTS (SELECT 1 FROM dbo.CODELKUP WITH (NOLOCK)
                        WHERE  ListName = 'AEO_PTWSTG' AND StorerKey = @cStorerKey AND Short = @cFromLoc)
            BEGIN -- FromLoc is a STGPTW Loc: move scanned DropID directly to Pack Staging
               SET @cMoveToPackSTGFlag = 'Y'

               IF @nDebugFlag = 1
                  SELECT 'From St1 to St2, FromLoc is a STGPTW loc', @cMoveToPackSTGFlag AS MoveToPackSTGFlag
            END
            ELSE --Not from PTW
            BEGIN
               SET @cMoveToPackSTGFlag = 'N'

               IF @nDebugFlag = 1
                  SELECT 'From St1 to St2, Not from PTW'
            END

            IF @cMoveToPackSTGFlag = 'Y'
            BEGIN
               SET @cPackSTGLoc = ''

               IF @cWaveType = 'ECOM'
                  SET @cPackSTGLoc = 'AEOMX_PAKE'
               ELSE IF @cWaveType = 'WHSLE'
                  SET @cPackSTGLoc = 'AEOMX_PAKW'
               ELSE IF @cWaveType = 'RTL'
                  SET @cPackSTGLoc = 'AEOMX_PAKR'
               ELSE
               BEGIN
                  SET @cPackSTGLoc = ''
                  SET @nErrNo = 272354
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pack Staging loc not defined
                  GOTO Fail_St1toSt2
               END

               IF @cPackSTGLoc <> '' AND NOT EXISTS (SELECT 1 FROM dbo.LOC WITH (NOLOCK) WHERE Loc = @cPackSTGLoc AND Facility = @cFacility)
               BEGIN
                  SET @cMoveToPackSTGFlag = 'N'
                  SET @nErrNo = 272355
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pack Staging loc not exists
                  GOTO Fail_St1toSt2
               END

               BEGIN TRY
                  INSERT INTO @tMoveList (FromLoc, FromID, ToLoc, ToID, SKU, Lot, Qty, DropID, REMARK)
                  SELECT 
                     Loc, --FromLoc
                     ID, --FromID
                     @cPackSTGLoc, --Toloc
                     ID, --ToID
                     SKU, 
                     LOT, 
                     SUM(QTY),
                     @cFromDropID, --DropID
                     'Move from PTW to PackSTG' --REMARK 
                  FROM dbo.PickDetail WITH (NOLOCK)
                     WHERE StorerKey = @cStorerKey 
                        AND DropID = @cFromDropID
                        AND Status = @cPickStatus
                     GROUP BY Loc, ID, DropID, SKU, LOT
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 272356
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Insert tMoveList failed
                  GOTO Fail_St1toSt2
               END CATCH
            END -- Move 
            
            IF @cMoveToPackSTGFlag <> 'Y' AND @nDebugFlag <> 0
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'From St1 to St2, Not move inventory', @cFromDropID AS FromDropID, @cWaveKey AS WaveKey, @cFromLoc AS FromLoc, 
                     @cPackSTGLoc AS PackStgLoc, @cWaveType AS WaveType

               IF @nDebugFlag = 2
               BEGIN
                  BEGIN TRY
                     INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, Step3, Step4, Step5,
                        Col1, Col2, Col3, Col4, Col5)
                     VALUES ('838ExtScn10', GETDATE(), @cUsername, @cWaveKey, @cFromLoc, @cWaveType, @cFromDropID,
                        '', '', '', '','NotMoveInv')    
                  END TRY
                  BEGIN CATCH
                     SELECT 'TraceInfo Error', ERROR_MESSAGE() AS ErrorMessage
                  END CATCH
               END
            END

            IF EXISTS (SELECT 1 FROM @tMoveList)
            BEGIN
               IF @cMoveQtyAlloc <> '1' AND @cMoveQtyPick <> '1'
               BEGIN
                  SET @nErrNo = 272357
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --IncorrectSetup
                  GOTO Fail_St1toSt2
               END

               -- Check move alloc, but picked
               IF @cMoveQTYAlloc = '1' AND @cPickStatus = '5'
               BEGIN
                  SET @nErrNo = 272358
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --IncorrectSetup
                  GOTO Fail_St1toSt2
               END
                  
               -- Check move picked, but not pick confirm
               IF @cMoveQTYPick = '1' AND @cPickStatus < '5'
               BEGIN
                  SET @nErrNo = 272359
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --IncorrectSetup
                  GOTO Fail_St1toSt2
               END

               IF @nDebugFlag = 1
                  SELECT 'MoveList', * FROM @tMoveList

               BEGIN TRANSACTION
               SET @nCounter = 0

               WHILE 1 = 1
               BEGIN
                  SELECT TOP 1
                     @nCounter = RowNumber,
                     @cMoveFromLoc = FromLoc,
                     @cMoveToLoc = ToLoc,
                     @cMoveFromID = FromID,
                     @cMoveToID = ToID, 
                     @cMoveSKU = SKU, 
                     @cMoveLot = Lot, 
                     @nMoveQty = Qty,
                     @cMoveDropID = DropID
                  FROM @tMoveList
                  WHERE RowNumber > @nCounter
                  ORDER BY RowNumber

                  IF @@ROWCOUNT = 0
                     BREAK

                  IF @nDebugFlag = 1
                     SELECT 'Moving inventory', @nCounter AS RowNumber, @cMoveFromLoc AS FromLoc, @cMoveToLoc AS ToLoc, @cMoveFromID AS FromID,
                        @cMoveToID AS ToID, @cMoveSKU AS SKU, @cMoveLot AS Lot, @nMoveQty AS Qty, @cMoveDropID AS DropID

                  IF @cMoveQTYAlloc = '1'
                  BEGIN
                     SET @nQTYAlloc = @nMoveQty
                     SET @nQTYPick = 0
                  END
                  ELSE
                  BEGIN
                     SET @nQTYAlloc = 0
                     SET @nQTYPick = @nMoveQty
                  END

                  EXECUTE rdt.rdt_Move
                     @nMobile     = @nMobile,
                     @cLangCode   = @cLangCode,
                     @nErrNo      = @nErrNo  OUTPUT,
                     @cErrMsg     = @cErrMsg OUTPUT,
                     @cSourceType = 'rdt_838ExtScn10',
                     @cStorerKey  = @cStorerKey,
                     @cFacility   = @cFacility,
                     @cFromLOC    = @cMoveFromLoc,
                     @cToLoc      = @cMoveToLoc,
                     @cFromID     = @cMoveFromID,
                     @cToID       = @cMoveToID,
                     @cSKU        = @cMoveSKU,
                     @nQTY        = @nMoveQty,
                     @nQTYAlloc   = @nQTYAlloc,
                     @nQTYPick    = @nQTYPick,
                     @cFromLOT    = @cMoveLot,
                     @cDropID     = @cMoveDropID,
                     @nFunc       = @nFunc
                  IF @nErrNo <> 0
                     GOTO ROLLBACKTRAN_St1toSt2

                  -- Eventlog
                  EXEC RDT.rdt_STD_EventLog
                     @cActionType    = '3', -- Pick
                     @cUserID        = @cUserName,
                     @nMobileNo      = @nMobile,
                     @nFunctionID    = @nFunc,
                     @cFacility      = @cFacility,
                     @cStorerKey     = @cStorerKey,
                     @cLocation      = @cFromLOC,
                     @cToLocation    = @cPackSTGLoc,
                     @cID            = @cFromID,
                     @cToID          = @cToID,
                     @cSKU           = @cMoveSKU,
                     @nQTY           = @nMoveQty,
                     @cLOT           = @cMoveLot, 
                     @cDropID        = @cFromDropID
               END -- end loop
               
               COMMIT TRANSACTION
            END -- move inventory

            -- B2C Single Logic
            IF ISNULL(@cWaveType, '') = 'ECOM' AND ISNULL(@cOrderType, '') = 'S'
            BEGIN
               SET @cB2CSingleFlag = 'Y'
               SET @nRemainQTY = 0
               SELECT @nRemainQTY = SUM(PAD.ExpQty - PAD.Qty)
               FROM dbo.PackDetail PAD WITH (NOLOCK)
               INNER JOIN dbo.PICKHEADER PKH WITH (NOLOCK) ON PAD.PickSlipNo = PKH.PickHeaderKey AND PAD.StorerKey = PKH.StorerKey
               INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON PAD.LabelNo = PKD.CaseID AND PAD.SKU = PKD.SKU AND PKH.OrderKey = PKD.OrderKey
               WHERE PKD.DropID = @cFromDropID
                  AND PKD.StorerKey = @cStorerKey
                  AND PAD.Qty = 0
               SET @nRemainQTY = ISNULL(@nRemainQTY, 0)

               SET @cOutField01 = ''
               SET @cOutField02 = ''
               SET @cMobBarcode = '' -- clear V_barcode
               SET @cOutField03 = ''
               SET @cOutField04 = ''
               SET @cOutField05 = ISNULL(TRY_CAST( @nRemainQTY AS NVARCHAR( 8)), '')
               SET @cOutField08 = '1'
               SET @cOutField09 = ''
               SET @cOutField10 = ''
               SET @cOutField11 = ''
               SET @cOutField12 = ''
               SET @cOutField13 = ''
               SET @cOutField14 = ''

                  -- Enable field
               SET @cFieldAttr08 = 'O'
               SET @cFieldAttr14 = 'O'

               EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU field
               SET @nAfterScn = 6919
               SET @nAfterStep = 99
            END
            ELSE
            BEGIN
               SET @cB2CSingleFlag = 'N'
               
               IF @cWaveType = 'ECOM'
                  SET @cOutField09 = '2'
               ELSE
                  SET @cOutField09 = '1'
            END

            GOTO Quit_St1toSt2

            ROLLBACKTRAN_St1toSt2:
               ROLLBACK TRANSACTION

            Fail_St1toSt2:
               SET @nAfterScn = 4650
               SET @nAfterStep = 1
               SET @cOutField01 = ''
               SET @cOutField02 = ''
               SET @cOutField03 = ''

            Quit_St1toSt2:
               GOTO Quit
         END -- Enter
      END -- st1 to st2

      IF @nStep = 3 AND @nScn = 4652 AND @nMobrecStep = 2 AND @nMobrecScn = 4651 -- From st2 to st3
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'From St2 to St3, Enter'

            SELECT TOP 1 
               @cSuggestedCartonType = ISNULL(Cartontype, '') 
            FROM dbo.PickDetail WITH (NOLOCK) 
            WHERE StorerKey = @cStorerKey AND DropID = @cFromDropID

            --show REM to Pack on scn 3
            SET @cPickStatus = rdt.RDTGetConfig( @nFunc, 'PickStatus', @cStorerKey)
            IF @cPickStatus = '0'
               SET @cPickStatus = '5'
            
            DECLARE 
               @nTotalPickQty INT = 0,
               @nTotalPackQty INT = 0,
               @nRemainingPackQty INT = 0
               
            SELECT @nTotalPickQty = SUM(Qty)
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND DropID = @cFromDropID
               AND Status = @cPickStatus

            SELECT @nTotalPackQty = SUM(Qty)
            FROM dbo.PackDetail PD WITH (NOLOCK)
            JOIN dbo.PackHeader PH WITH (NOLOCK) --V1.2.2
               ON (PD.PickSlipNo = PH.PickSlipNo)
               AND PH.Status = '0'
            WHERE PD.StorerKey = @cStorerKey
               AND DropID = @cFromDropID

            SET @nRemainingPackQty = ISNULL(@nTotalPickQty,0) - ISNULL(@nTotalPackQty,0)

            SET @cOutField15 = 'REM to PACK: ' + ISNULL(TRY_CAST(@nRemainingPackQty AS NVARCHAR( 20)), '') 
         END
      END -- st2 to st3

      IF @nStep = 2 AND @nScn = 4651 AND @nMobrecStep = 3 AND @nMobrecScn = 4652 -- From st3 back to st2
      BEGIN
         IF @nInputKey = 0
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'From St3 back to St2, ESC'

            --Set default option on screen 4651
            IF @cWaveType = 'ECOM'
               SET @cOutField09 = '2'
            ELSE
               SET @cOutField09 = '1'
         END
      END -- st3 back to st2

      IF @nMobrecStep = 3 AND @nMobrecScn = 4652 AND @nStep = 4 AND @nScn = 4653 -- From st3 to st4
      BEGIN
         IF @nInputKey = 0
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'From St3 to St4, ESC'

            --For ECOM, must pack all items in one carton
            IF @cWaveType = 'ECOM'
            BEGIN
               SELECT 
                  @nEcomPackQty = ISNULL(SUM(QTY), 0),
                  @nEcomExpPackQty = ISNULL(SUM(ExpQty), 0)
               FROM dbo.PackDetail WITH (NOLOCK) 
               WHERE PickSlipNo = @cPickSlipNo 
                  AND CartonNo = @nCartonNo
                  AND LabelNo = @cLabelNo

               IF @nEcomPackQty <> @nEcomExpPackQty
               BEGIN
                  SET @nErrNo = 272368
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ECOM must pack all items in one carton
                  GOTO Fail_St3toSt4
               END
            END

            --Use base 4653 screen but new logic
            EXEC rdt.rdtSetFocusField @nMobile, 1
            SET @nAfterStep = 99

            GOTO Quit_St3toSt4

            Fail_St3toSt4:
               SET @cOutField01 = RTRIM( @cCustomNo)
               SET @cOutField02 = CAST( CAST( @cLabelLine AS INT) AS NVARCHAR(5)) + '/' + CAST( @nCartonSKU AS NVARCHAR(5))
               SET @cOutField03 = '' -- SKU
               SET @cMobBarcode = '' -- New SKU input V7.9
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
               --SET @cOutField15 = '' -- ExtendedInfo -- keep REM to Pack value

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

               -- Enable field
               SET @cFieldAttr08 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END

               EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU

               SET @nAfterScn = 4652
               SET @nAfterStep = 3
            
            Quit_St3toSt4:
               GOTO Quit
         END
      END -- st3 to st4

      -- Step 5, Scn 4654
      -- for B2C Single, @nInputKey = 1
      -- Option 1: if remain qty > 0, Continue to scan SKU. If remain qty = 0, Go back to first screen

      -- for B2C Single, @nInputKey = 0
      -- PackInfo is setup, then go back to capture PackInfo screen. PackInfo is not steup, go back to sku screen
      IF @nMobrecStep = 5 AND @nMobrecScn = 4654
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'ExtScn10, Step5, Enter'

            SET @cOption = @cInField01

            IF @cOption = '1'
            BEGIN
               -- For B2C single handling, check if there is remaining qty to pack, if yes, go back to scan SKU
               IF @cB2CSingleFlag = 'Y'
               BEGIN
                  IF @nDebugFlag = 1
                     SELECT 'B2C Single, Option1'

                  SET @nRemainQTY = 0
                  SELECT @nRemainQTY = SUM(PAD.ExpQty - PAD.Qty)
                  FROM dbo.PackDetail PAD WITH (NOLOCK)
                  INNER JOIN dbo.PICKHEADER PKH WITH (NOLOCK) ON PAD.PickSlipNo = PKH.PickHeaderKey AND PAD.StorerKey = PKH.StorerKey
                  INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON PAD.LabelNo = PKD.CaseID AND PAD.SKU = PKD.SKU AND PKH.OrderKey = PKD.OrderKey
                  WHERE PKD.DropID = @cFromDropID
                     AND PKD.StorerKey = @cStorerKey
                     AND PAD.Qty = 0
                  SET @nRemainQTY = ISNULL(@nRemainQTY, 0)

                  IF @nRemainQTY > 0
                  BEGIN
                     SET @cOutField01 = ''
                     SET @cOutField02 = ''
                     SET @cMobBarcode = '' -- clear V_barcode
                     SET @cOutField03 = ''
                     SET @cOutField04 = ''
                     SET @cOutField05 = ISNULL(TRY_CAST( @nRemainQTY AS NVARCHAR( 8)), '')
                     SET @cOutField08 = '1'
                     SET @cOutField09 = ''
                     SET @cOutField10 = ''
                     SET @cOutField11 = ''
                     SET @cOutField12 = ''
                     SET @cOutField13 = ''
                     SET @cOutField14 = ''

                        -- Enable field
                     SET @cFieldAttr08 = 'O'
                     SET @cFieldAttr14 = 'O'

                     EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU field
                     SET @nAfterScn = 6919
                     SET @nAfterStep = 99
                  END
                  -- For B2C single handling, check if there is remaining qty to pack, if no, go back to first screen
                  ELSE
                  BEGIN
                     SET @cOutField01 = CASE WHEN @cShowPickSlipNo = '1' THEN @cPickSlipNo ELSE '' END -- PickSlipNo
                     SET @cOutField02 = '' -- FromDropID
                     SET @cOutField03 = '' -- ToDropID

                     SET @cFieldAttr01 = '' -- PickSlipNo
                     SET @cFieldAttr02 = '' -- FromDropID
                     SET @cFieldAttr03 = '' -- ToDropID

                     EXEC rdt.rdtSetFocusField @nMobile, 2  -- FromDropID

                     SET @nAfterScn = 4650
                     SET @nAfterStep = 1
                  END
               END
               ELSE
               BEGIN
                  --Set default option on screen 4651
                  IF @cWaveType = 'ECOM'
                     SET @cOutField09 = '2'
                  ELSE
                     SET @cOutField09 = '1'
               END
            END
         END
         ELSE IF @nInputKey = 0
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'ExtScn10, Step5, ESC'

            IF @cB2CSingleFlag = 'Y'
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'B2C Single, ESC'

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
               -- Go back to SKU screen if no pack info setup
               ELSE
               BEGIN
                  SET @nRemainQTY = 0
                  SELECT @nRemainQTY = SUM(PAD.ExpQty - PAD.Qty)
                  FROM dbo.PackDetail PAD WITH (NOLOCK)
                  INNER JOIN dbo.PICKHEADER PKH WITH (NOLOCK) ON PAD.PickSlipNo = PKH.PickHeaderKey AND PAD.StorerKey = PKH.StorerKey
                  INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON PAD.LabelNo = PKD.CaseID AND PAD.SKU = PKD.SKU AND PKH.OrderKey = PKD.OrderKey
                  WHERE PKD.DropID = @cFromDropID
                     AND PKD.StorerKey = @cStorerKey
                     AND PAD.Qty = 0
                  SET @nRemainQTY = ISNULL(@nRemainQTY, 0)

                  SET @cOutField01 = ''
                  SET @cOutField02 = ''
                  SET @cMobBarcode = '' -- clear V_barcode
                  SET @cOutField03 = ''
                  SET @cOutField04 = ''
                  SET @cOutField05 = ISNULL(TRY_CAST( @nRemainQTY AS NVARCHAR( 8)), '')
                  SET @cOutField08 = '1'
                  SET @cOutField09 = ''
                  SET @cOutField10 = ''
                  SET @cOutField11 = ''
                  SET @cOutField12 = ''
                  SET @cOutField13 = ''
                  SET @cOutField14 = ''

                     -- Enable field
                  SET @cFieldAttr08 = 'O'
                  SET @cFieldAttr14 = 'O'

                  EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU field
                  SET @nAfterScn = 6919
                  SET @nAfterStep = 99
               END
            END
         END
      END -- st3 to st4

      IF @nStep = 99
      BEGIN
         /********************************************************************************
         Scn = 6919. SKU QTY screen
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
         IF @nScn = 6919
         BEGIN
            SET @cUDF01 = 'NO UPD RDTMOBREC'
            IF @nInputKey = 1
            BEGIN
               DECLARE @cUPCBarcode NVARCHAR(2000)
               SET @cUPCBarcode = LEFT(@cMobBarcode, 2000)
               SET @cBarcode = ''
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
                                 GOTO SCN_6919_FAIL
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
                              @nMobile, @nFunc, @cLangCode, 3, @nStep, @nInputKey, @cFacility, @cStorerKey, @tVar,
                              @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                           IF @nErrNo <> 0
                              GOTO Quit

                           IF @nStep = 99 AND @nScn = 6919
                              SET @cOutField15 = @cExtendedInfo
                        END
                     END

                     GOTO SCN_6919_FAIL
                  END
               END

               -- Check SKU blank
               IF @cUPCBarcode = ''
               BEGIN
                  SET @nErrNo = 272369
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Need SKU
                  GOTO SCN_6919_FAIL
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
                        EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cUPCBarcode,
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
                           ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, @cUPCBarcode, @cBarcode, ' +
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
                           ' @cBarcode         NVARCHAR( 60), ' +
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
                           @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, @cUPCBarcode, @cBarcode,
                           @cUPC OUTPUT, @nQTY OUTPUT, @cPackDtlRefNo OUTPUT, @cPackDtlRefNo2 OUTPUT, @cPackDtlUPC OUTPUT, @cPackDtlDropID_Decode OUTPUT, @cSerialNo OUTPUT, 
                           @cFromDropIDDecode OUTPUT, @cToDropIDDecode OUTPUT, @cUCCNo OUTPUT,
                           @nErrNo OUTPUT, @cErrMsg OUTPUT

                        IF @nErrNo <> 0
                           GOTO SCN_6919_FAIL

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
                     SET @nErrNo = 272372
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid SKU
                     GOTO SCN_6919_FAIL
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
                           SET @nAfterStep = 11
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
                        SET @nErrNo = 272373
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Multiple SKU Barcod
                        GOTO SCN_6919_FAIL
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
                  FROM dbo.PackDetail PD WITH (NOLOCK)
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
                              GOTO SCN_6919_FAIL
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
                              GOTO SCN_6919_FAIL
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
                           GOTO SCN_6919_FAIL

                        IF @nStep = 99 AND @nScn = 6919
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
                  SET @nErrNo = 272370
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid QTY
                  EXEC rdt.rdtSetFocusField @nMobile, 8 -- QTY
                  GOTO SCN_6919_FAIL
               END

               -- Validate PQTY
               IF @cPQTY <> '' AND RDT.rdtIsValidQTY( @cPQTY, 1) = 0 --Check zero
               BEGIN
                  SET @nErrNo = 272371
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid QTY
                  EXEC rdt.rdtSetFocusField @nMobile, 14 -- QTY
                  GOTO SCN_6919_FAIL
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

               -- FCR-12984: Check if this is B2C Single flow
               IF @cB2CSingleFlag = 'Y' -- Enter pressed with SKU
               BEGIN
                  SET @cVirtualCartonID = ''
                  -- FCR-12984: Dynamic order fetch - find order containing scanned SKU

                  IF ISNULL(@cLabelNo, '') <> ''
                  BEGIN
                     SELECT @nPackedDetailPackedQty = SUM(Qty),
                        @nPackedDetailExpQty = SUM(ExpQty)
                     FROM dbo.PackDetail WITH(NOLOCK) 
                     WHERE LabelNo = @cLabelNo
                        AND StorerKey = @cStorerKey

                     -- If current label is pack completed, start a new label; otherwise, validate the label is correct
                     IF @nPackedDetailPackedQty = @nPackedDetailExpQty
                     BEGIN
                        IF EXISTS(SELECT 1
                                 FROM dbo.PackHeader PH WITH(NOLOCK)
                                 INNER JOIN dbo.PackDetail PD WITH(NOLOCK) ON PH.StorerKey = PD.StorerKey AND PH.PickSlipNo = PD.PickSlipNo
                                 WHERE PD.LabelNo = @cLabelNo
                                    AND PD.StorerKey = @cStorerKey
                                    AND PH.Status = '9')  -- PackHeader is pack done, get next PickSlipNo
                        BEGIN
                           GOTO START_NEW_LABEL
                        END
                        ELSE
                        BEGIN
                           SET @nErrNo = 272374  --  Label is pack done
                           SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                           EXEC rdt.rdtSetFocusField @nMobile, 3
                           SET @cOutField03 = ''  -- Clear SKU field
                           GOTO SCN_6919_FAIL
                        END
                     END

                     SET @cFetchedOrderKey = ''
                     SET @cPickSlipNo = ''
                     SET @cLabelLine = ''
                     SELECT TOP 1
                        @cFetchedOrderKey = PD.OrderKey,
                        @cPickSlipNo = PH.PickHeaderKey,
                        @cLabelLine = PAD.LabelLine
                     FROM dbo.PICKDETAIL PD WITH (NOLOCK)
                     INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON PH.StorerKey = PD.StorerKey AND PH.OrderKey = PD.OrderKey
                     INNER JOIN dbo.PackDetail PAD WITH(NOLOCK) ON PH.StorerKey = PAD.StorerKey AND PH.PickHeaderKey = PAD.PickSlipNo
                     INNER JOIN dbo.Wave W WITH(NOLOCK) ON W.WaveKey = PD.WaveKey
                     WHERE PD.DropID = @cFromDropID
                        AND PD.StorerKey = @cStorerKey
                        AND PD.SKU = @cSKU
                        AND PD.Status = @cPickStatus
                        AND PD.QTY > 0
                        AND ISNULL(W.UserDefine03, '')  = 'ECOM'
                        AND ISNULL(W.UserDefine05, '')  = 'S'
                        AND PH.Status < '9'
                        AND PAD.Qty < PAD.ExpQty
                        AND PAD.LabelNo = @cLabelNo
                     ORDER BY PD.OrderKey
                     SELECT @nRowCount = @@ROWCOUNT

                     -- Validate order was found
                     IF @nRowCount = 0 OR @cFetchedOrderKey = '' OR @cPickSlipNo = ''
                     BEGIN
                        SET @nErrNo = 272375  -- SKU not found in PickSlipNo
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                        EXEC rdt.rdtSetFocusField @nMobile, 3
                        SET @cOutField03 = ''  -- Clear SKU field
                        GOTO SCN_6919_FAIL
                     END

                     SET @nCartonNo = 0
                     SET @cCartonType = ''
                     SET @cWeight = ''
                     SET @cCube = ''
                     SELECT TOP 1
                        @nCartonNo = CartonNo,
                        @cCartonType = ISNULL(CartonType, ''),
                        @cWeight = rdt.rdtFormatFloat(ISNULL(Weight, 0)),
                        @cCube = rdt.rdtFormatFloat(ISNULL([Cube], 0))
                     FROM dbo.PACKINFO WITH (NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                        AND RefNo IS NOT NULL 
                        AND RefNo = @cLabelNo
                     ORDER BY CartonNo
                     SELECT @nRowCount = @@ROWCOUNT

                     IF @nRowCount = 0 OR @nCartonNo IS NULL OR @nCartonNo = 0
                     BEGIN
                        SET @nErrNo = 272376
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- No PackInfo record found
                        EXEC rdt.rdtSetFocusField @nMobile, 3
                        GOTO SCN_6919_FAIL
                     END

                     IF NOT EXISTS(SELECT 1 FROM dbo.PACKDETAIL WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo AND SKU = @cSKU AND LabelNo = @cLabelNo AND Qty < ExpQty)
                     BEGIN
                        SET @nErrNo = 272377
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --  SKU is packed
                        EXEC rdt.rdtSetFocusField @nMobile, 3
                        GOTO SCN_6919_FAIL
                     END
                  END
                  ELSE
                  BEGIN
                     START_NEW_LABEL:
                     SET @cFetchedOrderKey = ''
                     SET @cPickSlipNo = ''
                     SET @cLabelNo = ''
                     SELECT TOP 1
                        @cFetchedOrderKey = PD.OrderKey,
                        @cPickSlipNo = PH.PickHeaderKey,
                        @cLabelNo = PD.CaseID
                     FROM dbo.PICKDETAIL PD WITH (NOLOCK)
                     INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON PH.StorerKey = PD.StorerKey AND PH.OrderKey = PD.OrderKey
                     INNER JOIN dbo.PackDetail PAD WITH(NOLOCK) ON PH.StorerKey = PAD.StorerKey AND PH.PickHeaderKey = PAD.PickSlipNo
                     INNER JOIN dbo.Wave W WITH(NOLOCK) ON W.WaveKey = PD.WaveKey
                     WHERE PD.DropID = @cFromDropID
                        AND PD.StorerKey = @cStorerKey
                        AND PD.SKU = @cSKU
                        AND PD.Status = @cPickStatus
                        AND PD.QTY > 0
                        AND ISNULL(W.UserDefine03, '')  = 'ECOM'
                        AND ISNULL(W.UserDefine05, '')  = 'S'
                        AND PH.Status < '9'
                        AND PAD.Qty < PAD.ExpQty
                     ORDER BY PD.OrderKey
                     SELECT @nRowCount = @@ROWCOUNT

                     -- Validate order was found
                     IF @nRowCount = 0 OR @cFetchedOrderKey = '' OR @cPickSlipNo = ''
                     BEGIN
                        SET @nErrNo = 272378
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --  SKU not found in PickSlipNo
                        EXEC rdt.rdtSetFocusField @nMobile, 3
                        SET @cOutField03 = ''  -- Clear SKU field
                        GOTO SCN_6919_FAIL
                     END

                     SET @nCartonNo = 0
                     SET @cCartonType = ''
                     SET @cWeight = ''
                     SET @cCube = ''
                     SELECT TOP 1
                        @nCartonNo = CartonNo,
                        @cCartonType = ISNULL(CartonType, ''),
                        @cWeight = rdt.rdtFormatFloat(ISNULL(Weight, 0)),
                        @cCube = rdt.rdtFormatFloat(ISNULL([Cube], 0))
                     FROM dbo.PACKINFO WITH (NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                     ORDER BY CartonNo
                     SELECT @nRowCount = @@ROWCOUNT

                     IF @nRowCount = 0 OR @nCartonNo IS NULL OR @nCartonNo = 0
                     BEGIN
                        SET @nErrNo = 272379
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- No PackInfo record found
                        EXEC rdt.rdtSetFocusField @nMobile, 3
                        GOTO SCN_6919_FAIL
                     END

                     SET @cLabelLine = ''
                     SELECT TOP 1 @cLabelLine = LabelLine
                     FROM dbo.PackDetail WITH (NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                        AND CartonNo = @nCartonNo
                        AND SKU = @cSKU
                        AND LabelNo = @cLabelNo
                        AND Qty < ExpQty
                     ORDER BY PickSlipNo, CartonNo, LabelNo, LabelLine
                     SELECT @nRowCount = @@ROWCOUNT

                     IF @nRowCount = 0 OR ISNULL(@cLabelLine, '') = ''
                     BEGIN
                        SET @nErrNo = 272380
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --  SKU is packed
                        EXEC rdt.rdtSetFocusField @nMobile, 3
                        GOTO SCN_6919_FAIL
                     END
                  END

                  IF @nTranCount = 0
                     BEGIN TRAN
                  ELSE
                     SAVE TRAN TR_838ExtScn10_SKU

                  SET @cVirtualCartonID = @cLabelNo
                  -- Confirm
                  BEGIN TRY
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
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 272382
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --  Execute Confirm SP failed
                     EXEC rdt.rdtSetFocusField @nMobile, 3

                     IF @nTranCount > 0 AND XACT_STATE() <> -1
                        ROLLBACK TRAN TR_838ExtScn10_SKU
                     ELSE
                        ROLLBACK TRAN
                        
                     GOTO SCN_6919_FAIL
                  END CATCH

                  IF @nErrNo <> 0
                  BEGIN
                     EXEC rdt.rdtSetFocusField @nMobile, 3
                     IF @nTranCount > 0 AND XACT_STATE() <> -1
                        ROLLBACK TRAN TR_838ExtScn10_SKU
                     ELSE
                        ROLLBACK TRAN

                     GOTO SCN_6919_FAIL
                  END

                  IF @nTranCount = 0
                     COMMIT TRAN

                  SET @nRemainQTY = 0
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

                  SET @cOutField01 = @cLabelNo
                  SET @cOutField02 = @cSku
                  SET @cMobBarcode = '' -- clear V_barcode
                  SET @cOutField03 = rdt.rdtFormatString( @cSKUDescr, 1, 20)
                  SET @cOutField04 = rdt.rdtFormatString( @cSKUDescr, 21, 20)
                  SET @cOutField05 = ISNULL(TRY_CAST( @nRemainQTY AS NVARCHAR( 8)), '')
                  SET @cOutField08 = '1'
                  SET @cOutField09 = ''
                  SET @cOutField10 = ''
                  SET @cOutField11 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END
                  SET @cOutField12 = rdt.rdtRightAlign( @cPUOM_Desc, 5)
                  SET @cOutField13 = rdt.rdtRightAlign( @cMUOM_Desc, 5)
                  SET @cOutField14 = ''

                   -- Enable field
                  SET @cFieldAttr08 = 'O'
                  SET @cFieldAttr14 = 'O'

                  EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU field
                  --Reset
                  SET @nEnter = 0
               END
               -- End FCR-12984 B2C Single handling
            END
            ELSE IF @nInputKey = 0
            BEGIN
               -- Packed
               IF EXISTS( SELECT 1 FROM dbo.PackDetail WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Qty > 0 AND Qty = ExpQty)
                  AND NOT EXISTS (SELECT 1 FROM dbo.PackDetail WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Qty < ExpQty)
                  AND EXISTS (SELECT 1 FROM dbo.PickDetail PD WITH (NOLOCK)
                              INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON PD.StorerKey = PH.StorerKey AND PD.OrderKey = PH.OrderKey
                              WHERE PH.PickHeaderKey = @cPickSlipNo
                                 AND PD.StorerKey = @cStorerKey
                                 AND PH.Status <> '9')
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
                  SET @cOutField01 = CASE WHEN @cShowPickSlipNo = '1' THEN @cPickSlipNo ELSE '' END -- PickSlipNo
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

                  SET @nAfterScn = 4650
                  SET @nAfterStep = 1
               END
            END
            GOTO Quit

            SCN_6919_FAIL:
            BEGIN
               IF rdt.RDTGetConfig( @nFunc, 'ShowErrMsgInNewScn', @cStorerkey) = '1'
               BEGIN
                  EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg
               END

               SET @nRemainQTY = 0
               SELECT @nRemainQTY = SUM(PAD.ExpQty - PAD.Qty)
               FROM dbo.PackDetail PAD WITH (NOLOCK)
               INNER JOIN dbo.PICKHEADER PKH WITH (NOLOCK) ON PAD.PickSlipNo = PKH.PickHeaderKey AND PAD.StorerKey = PKH.StorerKey
               INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON PAD.LabelNo = PKD.CaseID AND PAD.SKU = PKD.SKU AND PKH.OrderKey = PKD.OrderKey
               WHERE PKD.DropID = @cFromDropID
                  AND PKD.StorerKey = @cStorerKey
                  AND PAD.Qty = 0
               SET @nRemainQTY = ISNULL(@nRemainQTY, 0)

               SET @cOutField01 = @cLabelNo
               SET @cOutField02 = @cSku
               SET @cMobBarcode = '' -- clear V_barcode
               SET @cOutField03 = rdt.rdtFormatString( @cSKUDescr, 1, 20)
               SET @cOutField04 = rdt.rdtFormatString( @cSKUDescr, 21, 20)
               SET @cOutField05 = ISNULL(TRY_CAST( @nRemainQTY AS NVARCHAR( 8)), '')
               SET @cOutField08 = '1'
               SET @cOutField09 = ''
               SET @cOutField10 = ''
               SET @cOutField11 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END
               SET @cOutField12 = rdt.rdtRightAlign( @cPUOM_Desc, 5)
               SET @cOutField13 = rdt.rdtRightAlign( @cMUOM_Desc, 5)
               SET @cOutField14 = ''

                  -- Enable field
               SET @cFieldAttr08 = 'O'
               SET @cFieldAttr14 = 'O'

               EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU field
               --Reset 
               SET @nEnter = 0
               GOTO Quit
            END
         END

         IF @nScn = 4653 -- new step4 logic
         BEGIN
            SET @cUDF01 = 'NO UPD RDTMOBREC'
            NEW_Step4:
            IF @nInputKey = 1 -- ENTER
            BEGIN
               IF @nDebugFlag = 1
               BEGIN
                  IF @cCartonTypeConfirmed = 'Y'
                     SELECT 'Back from CartonType confirm, CartonTypeConfirmed=Y, skip carton type check'
                  ELSE
                     SELECT 'New Step4 logic, Enter'
               END

               DECLARE 
                  @cChkCartonType   NVARCHAR( 10),
                  @fTotalWeight     FLOAT,
                  @fCartonWeight    FLOAT,
                  @fSKUWeight       FLOAT, 
                  @fCartonLength    FLOAT, 
                  @fCartonWidth     FLOAT, 
                  @fCartonHeight    FLOAT,
                  @fCartonCube      FLOAT,
                  @fCartonQty       FLOAT --(cc02)

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
                     SET @nErrNo = 272362
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NeedCartonType
                     EXEC rdt.rdtSetFocusField @nMobile, 1
                     GOTO New_Step4_Fail
                  END

                  --V1.2.0 start
                  -- Get length, width, height from cartonization table
                  SELECT
                     @fCartonCube = ISNULL([Cube], 0),--v1.2.1
                     @fCartonWeight = ISNULL(CartonWeight, 0),
                     @fCartonLength = ISNULL(CartonLength, 0),
                     @fCartonWidth = ISNULL(CartonWidth, 0),
                     @fCartonHeight = ISNULL(CartonHeight, 0)
                  FROM Cartonization WITH (NOLOCK)
                  WHERE CartonizationGroup LIKE 'AEO%'
                     AND CartonType = @cChkCartonType
                  --V1.2.0 end

                  SET @nRowCount = @@ROWCOUNT
                  -- Check if valid
                  IF @nRowCount = 0
                  BEGIN
                     SET @nErrNo = 272363
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Bad CTN TYPE
                     EXEC rdt.rdtSetFocusField @nMobile, 1
                     GOTO New_Step4_Fail
                  END

                  -- Different carton type scanned
                  IF @cChkCartonType <> @cSuggestedCartonType AND ISNULL(@cSuggestedCartonType, '') <> '' AND ISNULL(@cCartonTypeConfirmed, '') <> 'Y'
                  BEGIN
                     --Jump to carton type confirm screen
                     IF @nDebugFlag = 1
                        SELECT 'Different carton type, jump to confirm screen', 
                        @cChkCartonType AS ScannedCartonType, @cSuggestedCartonType AS SuggestedCartonType

                     SET @cOutField01 = @cSuggestedCartonType
                     SET @cOutField02 = @cChkCartonType
                     SET @cFieldAttr03 = ''
                     SET @cOutField03 = ''

                     SET @nAfterScn = 6971
                     SET @nAfterStep = 99

                     GOTO Quit
                  END

                  SET @cCartonType = @cChkCartonType
               END

               -- Default weight
               IF @cDefaultWeight IN ('2', '3')
               BEGIN
                  -- Weight (SKU only)
                  SELECT @fSKUWeight = ISNULL( SUM( SKU.STDGrossWGT * PD.QTY), 0)
                  FROM dbo.PackDetail PD WITH (NOLOCK)
                     JOIN dbo.SKU SKU WITH (NOLOCK) ON (SKU.StorerKey = PD.StorerKey AND SKU.SKU = PD.SKU)
                  WHERE PD.PickSlipNo = @cPickSlipNo
                     AND PD.CartonNo = @nCartonNo

                  IF @cDefaultWeight = '2'
                     SET @fTotalWeight = @fSKUWeight
                  -- Weight (SKU + carton)
                  ELSE IF @cDefaultWeight = '3'
                     SET @fTotalWeight = @fCartonWeight + @fSKUWeight
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
                        GOTO NEW_STEP4_FAIL
                  END
               END

               --SET @fCartonCube = CAST( @cCube AS FLOAT)--v1.2.1
               SELECT @fCartonQty = SUM(qty) FROM packDetail WITH (NOLOCK) WHERE pickslipNo = @cPickSlipNo AND cartonNo = @nCartonNo AND storerKey = @cStorerKey --(cc02)

               IF @nDebugFlag = 1
                  SELECT 'PackInfo Data', @cPickSlipNo AS PickSlipNo, @nCartonNo AS CartonNo, @cLabelNo AS LabelNo, @fCartonQty AS Qty, @fTotalWeight AS Weight, 
                     @fCartonCube AS Cube, @cCartonType AS CartonType, @cRefNo AS RefNo, @fCartonLength AS Length, 
                     @fCartonWidth AS Width, @fCartonHeight AS Height

               -- PackInfo
               IF NOT EXISTS (SELECT 1 FROM dbo.PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo)
               BEGIN
                  BEGIN TRY
                     INSERT INTO dbo.PackInfo (PickslipNo, CartonNo, Qty, Weight, Cube, CartonType, 
                                                RefNo, Length, Width, Height, CartonStatus)
                     VALUES (@cPickSlipNo, @nCartonNo, @fCartonQty, @fTotalWeight, @fCartonCube, @cCartonType, 
                              @cRefNo, @fCartonLength, @fCartonWidth, @fCartonHeight, 'PACKED') 
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 272364
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPackInfFail
                     GOTO NEW_STEP4_FAIL
                  END CATCH
               END
               ELSE
               BEGIN
                  BEGIN TRY
                     UPDATE dbo.PackInfo SET
                        CartonType = @cCartonType,
                        Weight = @fTotalWeight,
                        [Cube] = @fCartonCube,
                        RefNo = @cRefNo,
                        Length = @fCartonLength,   
                        Width = @fCartonWidth,    
                        Height = @fCartonHeight,  
                        Qty = @fCartonQty,
                        CartonStatus = 'PACKED',
                        EditWho = SUSER_SNAME(),
                        EditDate = GETDATE()
                     WHERE PickSlipNo = @cPickSlipNo
                        AND CartonNo = @nCartonNo
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 272365
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDPackInfFail
                     GOTO NEW_STEP4_FAIL
                  END CATCH
               END

               

               -- Begin transaction for inventory move + extended update
               IF @nTranCount = 0
                  BEGIN TRAN
               ELSE
                  SAVE TRAN TR_838ExtScn10_Step4

               -- Move inventory and send IML after packing one LabelNo
               EXEC RDT.rdt_838ExtScn10_LabelNoConfirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
                  ,@cPickSlipNo    = @cPickSlipNo
                  ,@cFromDropID    = @cFromDropID
                  ,@nCartonNo      = @nCartonNo    
                  ,@cLabelNo       = @cLabelNo
                  ,@cWaveKey       = @cWaveKey
                  ,@cWaveType      = @cWaveType
                  ,@nErrNo         = @nErrNo       OUTPUT
                  ,@cErrMsg        = @cErrMsg      OUTPUT
               IF @nErrNo <> 0
                  GOTO NEW_STEP4_ROLLBACK

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
                        GOTO NEW_STEP4_ROLLBACK
                  END
               END

               IF @nTranCount = 0
                  COMMIT TRAN

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
                  -- For B2C single handling, check if there is remaining qty to pack, if yes, go back to scan SKU
                  IF @cB2CSingleFlag = 'Y'
                  BEGIN
                     SET @nRemainQTY = 0
                     SELECT @nRemainQTY = SUM(PAD.ExpQty - PAD.Qty)
                     FROM dbo.PackDetail PAD WITH (NOLOCK)
                     INNER JOIN dbo.PICKHEADER PKH WITH (NOLOCK) ON PAD.PickSlipNo = PKH.PickHeaderKey AND PAD.StorerKey = PKH.StorerKey
                     INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON PAD.LabelNo = PKD.CaseID AND PAD.SKU = PKD.SKU AND PKH.OrderKey = PKD.OrderKey
                     WHERE PKD.DropID = @cFromDropID
                        AND PKD.StorerKey = @cStorerKey
                        AND PAD.Qty = 0
                     SET @nRemainQTY = ISNULL(@nRemainQTY, 0)

                     IF @nRemainQTY > 0
                     BEGIN

                        SET @cOutField01 = ''
                        SET @cOutField02 = ''
                        SET @cMobBarcode = '' -- clear V_barcode
                        SET @cOutField03 = ''
                        SET @cOutField04 = ''
                        SET @cOutField05 = ISNULL(TRY_CAST( @nRemainQTY AS NVARCHAR( 8)), '')
                        SET @cOutField08 = '1'
                        SET @cOutField09 = ''
                        SET @cOutField10 = ''
                        SET @cOutField11 = ''
                        SET @cOutField12 = ''
                        SET @cOutField13 = ''
                        SET @cOutField14 = ''

                           -- Enable field
                        SET @cFieldAttr08 = 'O'
                        SET @cFieldAttr14 = 'O'

                        EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU field
                        SET @nAfterScn = 6919
                        SET @nAfterStep = 99
                     END
                     ELSE
                     BEGIN
                        SET @cOutField01 = CASE WHEN @cShowPickSlipNo = '1' THEN @cPickSlipNo ELSE '' END -- PickSlipNo
                        SET @cOutField02 = '' -- FromDropID
                        SET @cOutField03 = '' -- ToDropID

                        SET @cFieldAttr01 = '' -- PickSlipNo
                        SET @cFieldAttr02 = '' -- FromDropID
                        SET @cFieldAttr03 = '' -- ToDropID

                        EXEC rdt.rdtSetFocusField @nMobile, 2  -- FromDropID

                        SET @nAfterScn = 4650
                        SET @nAfterStep = 1
                     END
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
            END

            IF @nInputKey = 0 -- ESC
            BEGIN
               -- Enable field
               SET @cFieldAttr01 = '' -- CartonType
               SET @cFieldAttr02 = '' -- Weight
               SET @cFieldAttr03 = '' -- Cube
               SET @cFieldAttr04 = '' -- RefNo

               -- Prepare next screen var
               SET @cOutField01 = RTRIM( @cCustomNo)
               SET @cOutField02 = CAST( CAST( @cLabelLine AS INT) AS NVARCHAR(5)) + '/' + CAST( @nCartonSKU AS NVARCHAR(5))
               SET @cOutField03 = '' -- SKU
               SET @cMobBarcode = ''
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

               IF @cB2CSingleFlag = 'Y'
               BEGIN
                  SET @nRemainQTY = 0
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

                  SET @cOutField01 = @cLabelNo
                  SET @cOutField02 = @cSku
                  SET @cMobBarcode = '' -- clear V_barcode
                  SET @cOutField03 = rdt.rdtFormatString( @cSKUDescr, 1, 20)
                  SET @cOutField04 = rdt.rdtFormatString( @cSKUDescr, 21, 20)
                  SET @cOutField05 = ISNULL(TRY_CAST( @nRemainQTY AS NVARCHAR( 8)), '')
                  SET @cOutField08 = '1'
                  SET @cOutField09 = ''
                  SET @cOutField10 = ''
                  SET @cOutField11 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END
                  SET @cOutField12 = rdt.rdtRightAlign( @cPUOM_Desc, 5)
                  SET @cOutField13 = rdt.rdtRightAlign( @cMUOM_Desc, 5)
                  SET @cOutField14 = ''

                   -- Enable field
                  SET @cFieldAttr08 = 'O'
                  SET @cFieldAttr14 = 'O'

                  EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU field
                  --Reset
                  SET @nEnter = 0
                  
                  SET @nAfterScn = 6919
                  SET @nAfterStep = 99
               END
            END

            GOTO Quit

            NEW_STEP4_ROLLBACK:
               IF @nTranCount > 0 AND XACT_STATE() <> -1
                  ROLLBACK TRAN TR_838ExtScn10_Step4
               ELSE
                  ROLLBACK TRAN

            NEW_STEP4_FAIL:
               SET @cOutField01 = '' -- CartonType
               GOTO Quit
         END -- new step4 logic

         /*------------------------------------------------------------------
            Scn 6971: Carton Type Screen (Step 99)
            - Field01: Suggested CartonType (display, from pickdetail)
            - Field02: CartonType
            - Confirm Change?
            - OPTIONS: 1= YES, 9 = GO BACK
         ------------------------------------------------------------------*/
         IF @nScn = 6971
         BEGIN
            SET @cOption = @cInField03

            IF @nInputKey = 1 -- ENTER
            BEGIN
               IF @cOption = ''
               BEGIN
                  SET @nErrNo = 272366
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Option required
                  GOTO Quit
               END

               IF @cOption <> '1' AND @cOption <> '9'
               BEGIN
                  SET @nErrNo = 272367
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid option (1=YES, 9=Go back)
                  GOTO Quit
               END

               IF @cOption = '1' -- YES: accept the scanned carton type
               BEGIN
                  IF @nDebugFlag = 1
                     SELECT 'Carton type confirmed, go back to NEW_Step4'

                  SET @cInField01 = @cOutField02    -- confirmed carton type passed from NEW_Step4
                  SET @cCartonTypeConfirmed = 'Y'   -- flag: skip re-trigger check in NEW_Step4
                  SET @nInputKey = 1
                  GOTO NEW_Step4
               END
               ELSE
               BEGIN -- 9: GO BACK
                  GOTO SCN_6971_ESC
               END
            END --Enter
            
            IF @nInputKey = 0 -- ESC
            BEGIN
               SCN_6971_ESC:

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

               --back to new step4
               SET @nAfterScn  = 4653
               SET @nAfterStep = 99
               GOTO Quit
            END --Esc
         END -- 6971
      END -- st99
   END--838

Quit:
   BEGIN TRY
      UPDATE rdt.RDTMOBREC SET
         C_STRING1 = @cWaveKey,
         C_STRING2 = @cWaveType,
         C_STRING3 = @cMoveToPackSTGFlag,
         C_STRING4 = @cPackSTGLoc,
         C_STRING5 = @cSuggestedCartonType,
         C_STRING6 = @cVirtualCartonID,
         C_STRING7 = @cB2CSingleFlag,

         V_String3      = @cLabelNo,
         V_String4      = @cCartonType,
         V_String5      = @cCube,
         V_String6      = @cWeight,

         V_PickSlipNo   = @cPickSlipNo,
         V_CartonNo     = @nCartonNo,
         V_SKU          = @cSKU,
         V_Barcode      = @cMobBarcode,
         
         EditDate       = GETDATE(),
         ErrMsg         = @cErrMsg,
         Func           = @nFunc,
         Scn            = @nAfterScn,
         Step           = @nAfterStep,

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
   END TRY
   BEGIN CATCH
      SET @nErrNo = 272360
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update RDTMOBREC failed
      RETURN
   END CATCH

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_838ExtScn10] TO NSQL
GO


