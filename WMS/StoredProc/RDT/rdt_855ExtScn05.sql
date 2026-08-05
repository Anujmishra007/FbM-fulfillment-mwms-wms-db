SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_855ExtScn05                                     */
/* Copyright      : Maersk                                              */
/* Customer       : Levis US (LVSUSA)                                   */
/*                                                                      */
/* Purpose: FCR-13167 PPA Packing - No Pre-Sort Flow                    */
/*          - Eliminate pre-sorting, allow any-order SKU scanning       */
/*          - Skip step 2 (Statistics), go directly to step 99/scn 6911 */
/*          - Flow: Scn814(Carton) -> Scn6911(SKU) -> standard PPA flow */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2026-06-01  1.0  Cuize    FCR-13167 Created from rdt_855ExtScn01     */
/* 2026-07-07  1.1  Cuize    FCR-13139 PPA Packing flow enhancements    */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_855ExtScn05] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep INT,
   @nScn  INT,
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
   @nAction      INT, --0 Jump Screen, 2. Prepare output fields, Step = 99 is a new screen
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

   DECLARE @nDebugFlag           INT  = 0
   DECLARE
      @cExtendedUpdateSP         NVARCHAR( 20),
      @cExtendedValidateSP       NVARCHAR( 20),
      @cExtendedInfoSP           NVARCHAR( 20),
      @cSingleUnitOrdConfig      NVARCHAR( 1),
      @tExtInfo                  VariableTable,

      @cDropID                   NVARCHAR( 20),
      @cRefNo                    NVARCHAR( 20),
      @cExtendedInfo             NVARCHAR( 20),
      @cPickSlipNo               NVARCHAR( 10),
      @cLoadKey                  NVARCHAR( 10),
      @cOrderKey                 NVARCHAR( 10),
      @cDSPOrderKey              NVARCHAR( 10), --V1.5.0
      @cID                       NVARCHAR( 18),
      @cOption                   NVARCHAR( 1),
      @cSKU                      NVARCHAR( 20),
      @cTaskDetailKey            NVARCHAR( 20),
      @cPreviousSKU              NVARCHAR( 20),
      @cPPAStatus                NVARCHAR( 1),
      @cReasonCode               NVARCHAR( 20),
      @cDisableQTYField          NVARCHAR( 1),
      @cPPADefaultQTY            NVARCHAR( 1),
      @cTaskDefaultQty           NVARCHAR( 1),
      @cTaskQty                  NVARCHAR( 5),
      @cPUOM                     NVARCHAR( 10),
      @cStatus                   NVARCHAR( 1),
      @cPPADefaultPQTY           NVARCHAR( 1),
      @cPPAPrintPackListSP       NVARCHAR( 20),
      @cSKUStat                  NVARCHAR( 12),
      @cQTYStat                  NVARCHAR( 12),
      @cSQL                      NVARCHAR( MAX),
      @cSQLParam                 NVARCHAR( MAX),
      @nQTY                      INT,
      @nTotalCQty                INT,
      @nTotalPQty                INT,
      @nVariance                 INT

   DECLARE

      @tExtValidate              VariableTable,
      @nQTY_PPA                  INT,
      @nQTY_CHK                  INT,
      @cUserName                 NVARCHAR(18),
      @nCSKU                     INT,
      @nPSKU                     INT,
      @nPQTY                     INT,
      @nCQTY                     INT,
      @nMenu                     INT,
      @cMultiColScan             NVARCHAR(20),
      @nRowRef                   INT,
      @cPPACartonIDByPackDetailLabelNo NVARCHAR(1),
      @cPPACartonIDByPickDetailCaseID NVARCHAR(1),
      @cDropIDFlag               NVARCHAR(1),
      @cCaptureReasonCode        NVARCHAR(1),
      @cPPAPromptDiscrepancy     NVARCHAR( 1)
      -- FCR-1109 end

   --V1.4.0
   DECLARE
      @cSingleUnitOrdFlag     NVARCHAR( 1),
      @cToteID                NVARCHAR(20),
      @cLabelNo               NVARCHAR(20),
      @cUPC                   NVARCHAR(30),--1.7.0 SKU.RetailSKU
      @nSKUCnt                INT,
      @b_Success              INT,
      @cShipperKey            NVARCHAR(15), -- FCR-13167: For WSSOECL trigger check
      -- FCR-13167: Variables for ReferenceID generation (V1.17 from ExtUpd13/24)
      @cONRIOrderKey          NVARCHAR(10),
      @cONRIConsigneeKey      NVARCHAR(10),
      @cONRIWaveKey           NVARCHAR(10),
      @cReferenceID           NVARCHAR(50),
      @cOtherParams           NVARCHAR(250),
      @bSuccess               INT,
      @nLoopIndex             INT,
      @nRowCount              INT
   --V1.4.0 end

   -- FCR-13167: Table variable for orders without ReferenceID
   DECLARE @tOrderNoRefID TABLE (
      RowNumber INT IDENTITY(1,1),
      OrderKey NVARCHAR(10),
      ConsigneeKey NVARCHAR(10),
      WaveKey NVARCHAR(10)
   )

   --FCR-13167 VAS variables (4 VAS codes)
   DECLARE
      @cVASCode1              NVARCHAR(20),
      @cVASDesc1              NVARCHAR(50),
      @cVASCode2              NVARCHAR(20),
      @cVASDesc2              NVARCHAR(50),
      @cVASCode3              NVARCHAR(20),
      @cVASDesc3              NVARCHAR(50),
      @cVASCode4              NVARCHAR(20),
      @cVASDesc4              NVARCHAR(50),
      @cVASCode5              NVARCHAR(20),
      @cVASDesc5              NVARCHAR(50),
      @cVASDisplay1           NVARCHAR(60),
      @cVASDisplay2           NVARCHAR(60),
      @cVASDisplay3           NVARCHAR(60),
      @cVASDisplay4           NVARCHAR(60),
      @cVASDisplay5           NVARCHAR(60),
      @nCtnSKUCounted         INT,           -- Unique SKUs scanned in carton
      @nCtnSKUTotal           INT,           -- Total unique SKUs in carton
      @nSKUCounted            INT,           -- Current SKU scanned count
      @nSKUTotal              INT,           -- Current SKU expected count
      @nTotalQtyCKD           INT,           -- Total units scanned in carton
      @nTotalQtyExpected      INT,           -- Total expected units in carton
      @cCartonType            NVARCHAR(20),
      @cSKUDescr1             NVARCHAR(60),
      @cSKUDescr2             NVARCHAR(60),
      @cUOMQty                NVARCHAR(30),
      -- Wave and Print control
      -- @cWaveKey and @cWaveType removed - not used in business logic
      -- C_String16 and C_String17 now used for VAS5
      @cPrintControl          NVARCHAR(1),   -- '1'=Auto print bypass
      @cFirstSKUScan          NVARCHAR(1),   -- 'Y'=First SKU scan done
      @cPPACtnIDConfig        NVARCHAR(1),   -- PPACtnIDByPDDropIDnPDLblNo config
      -- Note: @cDisableQTYField and @cPPADefaultQTY already declared above (lines 92-93)
      -- Temp variables for RDTMOBREC parsing
      @cTemp                  NVARCHAR(250),
      @cTemp2                 NVARCHAR(250),
      @cTemp3                 NVARCHAR(250),
      @nTemp1                 INT,
      @nTemp2                 INT,
      @cSavedSKU              NVARCHAR(50),   -- Saved SKU from C_String10
      -- TRANSMITLOG2 variables
      @c_QCmdClass            NVARCHAR(10) = '',
      @cTransmitLogKey        NVARCHAR(10),
      -- Print variables
      @cLabelPrinterGroup     NVARCHAR(10),
      @cPaperPrinter          NVARCHAR(10),
      @cLabelName             NVARCHAR(30),
      -- Pagination variable
      @nDiscOffset            INT = 0,       -- Discrepancy screen pagination offset
      -- FCR-6657: Flag to indicate jump from 814 to 6915 (only option 1 allowed)
      @cFrom814Flag           NVARCHAR(1) = 'N'  -- C_String27
   --FCR-13167 end

   SET @nErrNo = 0
   SET @cErrMsg = ''
   SET @cTaskDetailKey = ''

   SELECT @cDropID = Value FROM @tExtScnData WHERE Variable = '@cDropID'
   SELECT @cRefNo = Value FROM @tExtScnData WHERE Variable = '@cRefNo'
   SELECT @cPickSlipNo = Value FROM @tExtScnData WHERE Variable = '@cPickSlipNo'
   SELECT @cLoadKey = Value FROM @tExtScnData WHERE Variable = '@cLoadKey'
   SELECT @cOrderKey = Value FROM @tExtScnData WHERE Variable = '@cOrderKey'
   SELECT @cID = Value FROM @tExtScnData WHERE Variable = '@cID'
   SELECT @cSKU = Value FROM @tExtScnData WHERE Variable = '@cSKU'
   SELECT @cPUOM = Value FROM @tExtScnData WHERE Variable = '@cPUOM'
   SELECT @nQTY = CAST(Value AS INT) FROM @tExtScnData WHERE Variable = '@nQTY'
   SELECT @nScn = CAST(Value AS INT) FROM @tExtScnData WHERE Variable = '@nScn'

   --FCR-13167: Read persisted data from RDTMOBREC C_String5-27 (one value per column)
   -- C_String5  = OrderKey        C_String6  = PickSlipNo      C_String7  = LabelNo
   -- C_String8  = VASCode1        C_String9  = VASDesc1        C_String10 = VASCode2
   -- C_String11 = VASDesc2        C_String12 = VASCode3        C_String13 = VASDesc3
   -- C_String14 = VASCode4        C_String15 = VASDesc4        C_String16 = VASCode5
   -- C_String17 = VASDesc5        C_String18 = PrintControl    C_String19 = FirstSKUScan
   -- C_String20 = CtnSKUTotal     C_String21 = TotalQtyExpected
   -- C_String22 = DisableQTYField C_String23 = PPADefaultQTY
   -- C_String24 = SavedSKU        C_String25 = SavedSKUTotal
   -- C_String26 = DiscOffset      C_String27 = From814Flag
   -- Note: @cLabelNo already declared above (line 134)

   SELECT
      @nStep               = Step,
      @nMenu               = Menu,
      @cLabelPrinterGroup  = Printer,
      @cPaperPrinter       = Printer_Paper,
      -- V_String fields
      @cTaskQty            = V_String6,
      @cTaskDefaultQty     = V_String7,
      @cPPAPromptDiscrepancy = V_String21,
      @cDisableQTYField    = V_String23,
      @cCaptureReasonCode  = V_String46,
      -- C_String fields
      @cDropIDFlag         = C_STRING1,
      @cSingleUnitOrdFlag  = C_STRING2,
      @cToteID             = C_STRING3,
      @cDSPOrderKey        = C_String4,
      @cOrderKey           = CASE WHEN ISNULL(@cOrderKey,'') = '' THEN ISNULL(C_String5,'') ELSE @cOrderKey END,
      @cPickSlipNo         = CASE WHEN ISNULL(@cPickSlipNo,'') = '' THEN ISNULL(C_String6,'') ELSE @cPickSlipNo END,
      @cLabelNo            = ISNULL(C_String7,''),
      @cVASCode1           = ISNULL(C_String8,''),
      @cVASDesc1           = ISNULL(C_String9,''),
      @cVASCode2           = ISNULL(C_String10,''),
      @cVASDesc2           = ISNULL(C_String11,''),
      @cVASCode3           = ISNULL(C_String12,''),
      @cVASDesc3           = ISNULL(C_String13,''),
      @cVASCode4           = ISNULL(C_String14,''),
      @cVASDesc4           = ISNULL(C_String15,''),
      @cVASCode5           = ISNULL(C_String16,''),
      @cVASDesc5           = ISNULL(C_String17,''),
      @cFirstSKUScan       = ISNULL(C_String19,'N'),
      @nCtnSKUTotal        = ISNULL(TRY_CAST(C_String20 AS INT), 0),
      @nTotalQtyExpected   = ISNULL(TRY_CAST(C_String21 AS INT), 0),
      @cPPADefaultQTY      = CASE WHEN ISNULL(V_String14,'') = '' THEN ISNULL(C_String23,'1') ELSE V_String14 END,
      @cSavedSKU           = ISNULL(C_String24,''),
      @nSKUTotal           = ISNULL(TRY_CAST(C_String25 AS INT), 0),
      @nDiscOffset         = ISNULL(TRY_CAST(C_String26 AS INT), 0),
      @cFrom814Flag        = ISNULL(C_String27,'N')
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   SET @cExtendedUpdateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerkey)
   IF @cExtendedUpdateSP = '0'
      SET @cExtendedUpdateSP = ''
   SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerkey)
   IF @cExtendedValidateSP = '0'
      SET @cExtendedValidateSP = ''
   SET @cExtendedInfoSP = rdt.RDTGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerkey)
   IF @cExtendedInfoSP = '0'
      SET @cExtendedInfoSP = ''

   SET @cPPADefaultPQTY = rdt.rdtGetConfig( @nFunc, 'PPADefaultPQTY', @cStorerkey)
   IF @cPPADefaultPQTY = '0'
      SET @cPPADefaultPQTY = ''

   -- FCR-13167: Get PrintControl config
   SET @cPrintControl = rdt.RDTGetConfig(@nFunc, 'PrintControl', @cStorerKey)
   IF @cPrintControl = '0'
      SET @cPrintControl = ''


   SET @cPPAPrintPackListSP = rdt.rdtGetConfig( @nFunc, 'PPAPrintPackListSP', @cStorerKey)
   IF @cPPAPrintPackListSP = '0'
      SET @cPPAPrintPackListSP = ''



   IF @nFunc = 855
   BEGIN

      IF @nStep = 99
      BEGIN
         IF @nScn = 814  --FIRST SCREEN
         BEGIN
            IF @nAction = 0
            BEGIN
               IF @nInputKey = 1
               BEGIN
                  IF @nFunc = 855 SET @cDropID = ISNULL( @cInField05, '') -- DropID

                  IF @nFunc = 855 AND @cDropID = ''
                  BEGIN
                     SET @nErrNo = 217352
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- DROP/CASE ID req
                     GOTO Step_1_99_Fail
                  END

                  -- FCR-6657: Check WorkOrderDetail qty discrepancy before packing
                  IF EXISTS(
                     SELECT 1 FROM dbo.WorkOrderDetail WOD WITH(NOLOCK)
                     INNER JOIN dbo.PickDetail PKD WITH(NOLOCK)
                     ON WOD.StorerKey = PKD.StorerKey
                        AND WOD.ExternWorkOrderKey = PKD.OrderKey
                        AND WOD.WkOrdUdef1 = PKD.SKU
                     WHERE PKD.StorerKey = @cStorerKey
                       AND (PKD.CaseID = @cDropID OR PKD.DropID = @cDropID)
                       AND WOD.type = 'S02'
                       AND TRY_CAST(NULLIF(WOD.WkOrdUdef3, '') AS INT) > 0)
                  BEGIN
                     DECLARE @wSKU NVARCHAR(20)
                     DECLARE @wQty INT = 0

                     DECLARE @tPKD TABLE
                     (
                        StorerKey         NVARCHAR(15),
                        OrderKey          NVARCHAR(10),
                        SKU               NVARCHAR(20),
                        Qty               INT
                     )

                     IF EXISTS (SELECT 1
                           FROM dbo.ORDERS ord WITH (NOLOCK)
                           INNER JOIN dbo.PickDetail pd WITH (NOLOCK) ON ord.OrderKey = pd.OrderKey
                           INNER JOIN dbo.Wave w WITH (NOLOCK) ON ord.UserDefine09 = w.WaveKey
                           WHERE ord.StorerKey = @cStorerKey
                              AND pd.StorerKey = @cStorerKey
                              AND (pd.CaseID = @cDropID OR pd.DropId = @cDropID)
                              AND w.UserDefine09 = 'Y')
                     BEGIN -- Automation
                        SELECT TOP 1
                           @wSKU = W.SKU,
                           @wQty = W.WorkOrderQty
                        FROM
                           (
                              SELECT
                                 pd.SKU,
                                 SUM(TRY_CAST(NULLIF(WOD.WkOrdUdef3, '') AS INT)) AS WorkOrderQty,
                                 SUM(pd.Qty) AS PickQty
                              FROM dbo.WorkOrderDetail WOD WITH(NOLOCK)
                              INNER JOIN dbo.PackHeader ph WITH(NOLOCK)
                                 ON (WOD.StorerKey = ph.StorerKey AND WOD.ExternWorkOrderKey = ph.OrderKey)
                              INNER JOIN dbo.PackDetail pd WITH(NOLOCK)
                                 ON (ph.StorerKey = pd.StorerKey AND ph.PickSlipNo = pd.PickSlipNo AND WOD.WkOrdUdef1 = pd.SKU)
                              WHERE pd.StorerKey = @cStorerKey
                                 AND (pd.LabelNo = @cDropID OR pd.DropID = @cDropID)
                                 AND WOD.type = 'S02'
                              GROUP BY pd.SKU
                              HAVING SUM(TRY_CAST(NULLIF(WOD.WkOrdUdef3, '') AS INT)) > 0
                           ) AS W
                        WHERE W.WorkOrderQty <> W.PickQty
                     END
                     ELSE
                     BEGIN -- Manual
                        DELETE FROM @tPKD

                        INSERT INTO @tPKD (StorerKey, OrderKey, SKU, Qty)
                        SELECT StorerKey, OrderKey, SKU, SUM(Qty)
                        FROM dbo.PickDetail WITH(NOLOCK)
                        WHERE StorerKey = @cStorerKey
                           AND (CaseID = @cDropID OR DropID = @cDropID)
                        GROUP BY StorerKey, OrderKey, SKU

                        SELECT TOP 1
                           @wSKU = W.SKU,
                           @wQty = W.WorkOrderQty
                        FROM
                           (
                              SELECT
                                 PKD.SKU,
                                 SUM(TRY_CAST(NULLIF(WOD.WkOrdUdef3, '') AS INT)) AS WorkOrderQty,
                                 SUM(PKD.Qty) AS PickQty
                              FROM dbo.WorkOrderDetail WOD WITH(NOLOCK)
                              INNER JOIN @tPKD PKD
                                 ON WOD.StorerKey = PKD.StorerKey
                                 AND WOD.ExternWorkOrderKey = PKD.OrderKey
                                 AND WOD.WkOrdUdef1 = PKD.SKU
                              WHERE WOD.type = 'S02'
                              GROUP BY PKD.SKU
                              HAVING SUM(TRY_CAST(NULLIF(WOD.WkOrdUdef3, '') AS INT)) > 0
                           ) AS W
                        WHERE W.WorkOrderQty <> W.PickQty
                     END

                     IF (ISNULL(@wSKU, '') <> '')
                     BEGIN
                        -- Message Queue
                        DECLARE
                           @cMsg01 NVARCHAR(20) = '',
                           @cMsg02 NVARCHAR(20) = '',
                           @cMsg03 NVARCHAR(20) = '',
                           @cMsg04 NVARCHAR(20) = '',
                           @cMsg05 NVARCHAR(20) = '',
                           @cMsg06 NVARCHAR(20) = '',
                           @cMsg07 NVARCHAR(20) = '',
                           @cMsg08 NVARCHAR(20) = '',
                           @cMsg09 NVARCHAR(20) = ''

                        SET @cMsg01 = 'Error.See Supervisor'
                        SET @cMsg02 = 'Qty does not match.'
                        SET @cMsg03 = 'Expected:' + CAST(@wQty AS NVARCHAR(10))
                        SET @cMsg04 = 'On ' + @wSKU
                        EXEC rdt.rdtInsertMsgQueue @nMobile = @nMobile,
                             @nErrNo = @nErrNo,
                             @cErrMsg = @cErrMsg,
                             @cLine01 = @cMsg01,
                             @cLine02 = @cMsg02,
                             @cLine03 = @cMsg03,
                             @cLine04 = @cMsg04,
                             @cLine05 = @cMsg05,
                             @cLine06 = @cMsg06,
                             @cLine07 = @cMsg07,
                             @cLine08 = @cMsg08,
                             @cLine09 = @cMsg09,
                             @nDisplayMsg = 0

                        -- Go to discrepancy options screen (6915)
                        SET @cOutField01 = @cDropID -- CARTON ID
                        SET @cOutField02 = '' -- Option input
                        SET @cFrom814Flag = 'Y' -- FCR-6657: Mark as from 814, only option 1 allowed

                        SELECT
                           @cFieldAttr01  =  '',
                           @cFieldAttr02  =  '',
                           @cFieldAttr03  =  '',
                           @cFieldAttr04  =  '',
                           @cFieldAttr05  =  '',
                           @cFieldAttr06  =  '',
                           @cFieldAttr07  =  '',
                           @cFieldAttr08  =  '',
                           @cFieldAttr09  =  '',
                           @cFieldAttr10  =  ''

                        SET @nAfterScn = 6915
                        SET @nAfterStep = 99
                        GOTO Quit
                     END
                  END -- FCR-6657 discrepancy check

                  SET @cSingleUnitOrdFlag = 'N' --V1.4.0

                  SET @cDropIDFlag=''
                  -- if scanned CartonID is dropid(toteid), replace it with caseid
                  IF EXISTS (
                     SELECT 1 FROM dbo.PickDetail WITH(NOLOCK)
                     WHERE DropId = @cDropID
                        AND StorerKey = @cStorerKey
                        AND ShipFlag <> 'Y')
                  BEGIN
                     IF LEN(@cDropID) = 10
                        SET @cDropIDFlag = 'Y'

                     --V1.4.0 start
                     --V1.5.0 Replace the old flag set logic
                     --V1.5.1 Only check PickDetail
                     IF NOT EXISTS (
                        SELECT 1
                        FROM dbo.PickDetail WITH (NOLOCK)
                        WHERE StorerKey = @cStorerKey
                              AND DropID = @cDropID
                              AND ShipFlag <> 'Y'
                        GROUP BY OrderKey
                        HAVING COUNT(DISTINCT OrderLineNumber) <> 1
                           OR COUNT(DISTINCT SKU) <> 1
                           OR SUM(Qty) <> 1
                     )
                     AND NOT EXISTS (
                        SELECT 1
                        FROM dbo.PickDetail WITH (NOLOCK)
                        WHERE StorerKey = @cStorerKey
                              AND DropID = @cDropID
                              AND ShipFlag <> 'Y'
                        GROUP BY CaseID
                        HAVING COUNT(PickDetailKey) <> 1
                     )
                     BEGIN

                        IF NOT EXISTS (
                           SELECT 1
                           FROM dbo.PickDetail PKD WITH (NOLOCK)
                           WHERE PKD.StorerKey = @cStorerKey
                                 AND DropID = @cDropID
                                 AND ShipFlag <> 'Y'
                                 AND UOM = '2'
                        ) -- V1.5.2 end
                        BEGIN
                           SET @cSingleUnitOrdConfig = rdt.rdtGetConfig( @nFunc, 'SingleUnitOrderConfig', @cStorerkey)
                           IF @cSingleUnitOrdConfig = '0'
                              SET @cSingleUnitOrdConfig = ''

                           IF @cSingleUnitOrdConfig = '1'
                           BEGIN
                              SET @cSingleUnitOrdFlag = 'Y'
                              -- Only set ToteID if not already set (avoid overwrite on subsequent scans)
                              IF ISNULL(@cToteID, '') = ''
                                 SET @cToteID = @cDropID
                           END
                        END
                     END

                     UPDATE RDT.RDTMOBREC WITH(ROWLOCK) SET
                        C_STRING1 = @cDropIDFlag,
                        C_STRING2 = @cSingleUnitOrdFlag --v1.4.0
                     WHERE Mobile = @nMobile

                     -- Migrated from step1 in PPA func, only 855 logic incouded
                     IF @cExtendedValidateSP <> ''
                     BEGIN
                        IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
                        BEGIN
                           INSERT INTO @tExtValidate (Variable, Value) VALUES
                              ('@cSKU',         @cSKU),
                              ('@nQTY',         CAST( @nQTY AS NVARCHAR( 10))),
                              ('@nQTY_PPA',     CAST( @nQTY_PPA AS NVARCHAR( 10))),
                              ('@nQTY_CHK',     CAST( @nQTY_CHK AS NVARCHAR( 10))),
                              ('@nRowRef',      CAST( @nRowRef AS NVARCHAR( 10))),
                              ('@nInputKey',    CAST( @nInputKey AS NVARCHAR( 1))),
                              ('@cUserName',    @cUserName)

                           SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedValidateSP) +
                              ' @nMobile, @nFunc, @cLangCode, @nStep, @cStorer, @cFacility, @cRefNo, @cOrderKey, @cDropID, @cLoadKey, @cPickSlipNo, ' +
                              ' @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey, @tExtValidate '
                           SET @cSQLParam =
                              '@nMobile        INT, ' +
                              '@nFunc          INT, ' +
                              '@cLangCode      NVARCHAR( 3),  ' +
                              '@nStep          INT,           ' +
                              '@cStorer        NVARCHAR( 15), ' +
                              '@cFacility      NVARCHAR( 5),  ' +
                              '@cRefNo         NVARCHAR( 20), ' +
                              '@cOrderKey      NVARCHAR( 10), ' +
                              '@cDropID        NVARCHAR( 20), ' +
                              '@cLoadKey       NVARCHAR( 10), ' +
                              '@cPickSlipNo    NVARCHAR( 10), ' +
                              '@nErrNo         INT           OUTPUT, ' +
                              '@cErrMsg        NVARCHAR( 20) OUTPUT, ' +
                              '@cID            NVARCHAR( 18), ' +
                              '@cTaskDetailKey NVARCHAR( 10), ' +
                              '@tExtValidate   VARIABLETABLE READONLY'

                           EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                              @nMobile, @nFunc, @cLangCode, @nStep, @cStorerKey, @cFacility, @cRefNo, @cOrderKey, @cDropID, @cLoadKey, @cPickSlipNo,
                              @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey, @tExtValidate

                           IF @nErrNo <> 0
                           BEGIN
                              SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                              GOTO Step_1_99_Fail
                           END
                        END
                     END


                     --If not single unit order, then 1 toteID (dropID) link to 1 CaseID (LabelNo)
                     --But if Single unit order, one toteID contains mulitple CaseID
                     IF @cSingleUnitOrdFlag <> 'Y'
                        SELECT @cDropID = CaseID
                        FROM dbo.PickDetail WITH(NOLOCK)
                        WHERE DropID = @cDropID
                           AND StorerKey = @cStorerKey
                           AND ShipFlag <> 'Y'

                     --SAVE DROPID INTO TOTEID
                     IF @cSingleUnitOrdFlag = 'Y'
                     BEGIN

                        --Single Unit order: 1 order, 1 PSNO, 1 sku, 1 qty
                        --One tote ID includes multiple single unit orders
                        SELECT TOP 1
                           @cOrderKey = PH.OrderKey,
                           @cPickSlipNo = PD.PickSlipNo,
                           @cLabelNo = PD.LabelNo
                        FROM PackInfo PI WITH (NOLOCK)
                           INNER JOIN PackDetail PD WITH (NOLOCK)
                           ON PI.PickSlipNo = PD.PickSlipNo
                        AND PI.CartonNo = PD.CartonNo
                           INNER JOIN PickHeader PH WITH (NOLOCK)
                           ON PD.PickSlipNo = PH.PickHeaderKey
                        AND PD.StorerKey = PH.StorerKey
                        WHERE
                           PD.StorerKey = @cStorerKey
                          AND PD.DropID = @cToteID --ToteID
                          AND PD.SKU = @cSKU
                          AND ISNULL(PI.CartonStatus,'') <> 'PACKED'

                        SET @cDropID = @cLabelNo

                     END
                  END --ToteID scanned
                  --V1.4.0 end

                  -- FCR-13139: C_STRING1, C_STRING2 will be saved to RDTMOBREC at Quit

                  --v1.4.0 start
                  --Original logc single unit order flag <> 'Y'
                  IF @cSingleUnitOrdFlag <> 'Y'
                  BEGIN
                     -- DropID Validation
                     -- DropID is CaseID, or changed to CaseID, so only validate CaseID
                     IF NOT EXISTS( SELECT 1
                        FROM dbo.PickDetail WITH (NOLOCK)
                        WHERE CaseID = @cDropID
                           AND StorerKey = @cStorerKey
                           AND ShipFlag <> 'Y')
                     BEGIN
                        SET @nErrNo = 217353
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Inv CaseID
                        GOTO Step_1_99_Fail
                     END

                     IF NOT EXISTS(SELECT 1
                        FROM dbo.PackHeader PH WITH (NOLOCK)
                        INNER JOIN dbo.PackDetail PD WITH (NOLOCK) ON (PH.PickSlipNo = PD.PickSlipNo)
                        WHERE PD.LabelNo = @cDropID
                        AND PH.StorerKey = @cStorerKey)
                     BEGIN
                        SET @cPPACartonIDByPackDetailLabelNo = ''
                        SET @cPPACartonIDByPickDetailCaseID = '1'
                     END
                     ELSE
                     BEGIN
                        SET @cPPACartonIDByPackDetailLabelNo = '1'
                        SET @cPPACartonIDByPickDetailCaseID = ''
                     END

                     -- Extended update
                     IF @cExtendedUpdateSP <> ''
                     BEGIN
                        IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
                        BEGIN
                           SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                              ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, ' +
                              ' @cSKU, @nQty, @cOption, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey,@cReasonCode OUTPUT'
                           SET @cSQLParam =
                              '@nMobile         INT,       ' +
                              '@nFunc           INT,       ' +
                              '@cLangCode       NVARCHAR( 3),  ' +
                              '@nStep           INT,           ' +
                              '@nInputKey       INT,           ' +
                              '@cStorerKey      NVARCHAR( 15), ' +
                              '@cRefNo          NVARCHAR( 10), ' +
                              '@cPickSlipNo     NVARCHAR( 10), ' +
                              '@cLoadKey        NVARCHAR( 10), ' +
                              '@cOrderKey       NVARCHAR( 10), ' +
                              '@cDropID         NVARCHAR( 20), ' +
                              '@cSKU            NVARCHAR( 20), ' +
                              '@nQty            INT,           ' +
                              '@cOption         NVARCHAR( 1),  ' +
                              '@nErrNo          INT           OUTPUT, ' +
                              '@cErrMsg         NVARCHAR( 20) OUTPUT, ' +
                              '@cID             NVARCHAR( 18), ' +
                              '@cTaskDetailKey  NVARCHAR( 10),  ' +
                              '@cReasonCode     NVARCHAR( 20)  OUTPUT '
                           EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                              @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, @cSKU, @nQty, '',
                              @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey,@cReasonCode OUTPUT
                           IF @nErrNo <> 0
                              GOTO Quit
                        END
                     END


                     -- V1.4.0 Set OrderKey when not single unit orders start
                     IF EXISTS (SELECT 1
                                 FROM dbo.ORDERS O WITH (NOLOCK)
                                 JOIN dbo.PICKDETAIL PD WITH (NOLOCK)
                                    ON O.orderkey = PD.OrderKey
                                    AND O.StorerKey = PD.StorerKey
                                 WHERE PD.StorerKey = @cStorerKey
                                    AND PD.CaseID = @cDropID -- DropID value value is caseID when not SingleUnitOrder
                                    AND PD.ShipFlag <> 'Y'
                                 GROUP BY PD.CaseID
                                    HAVING COUNT(DISTINCT O.OrderKey) = 1)
                     BEGIN -- 1 dropid 1 corder
                        SELECT TOP 1
                           @cOrderKey = OrderKey
                        FROM dbo.PickDetail PD WITH (NOLOCK)
                        WHERE PD.StorerKey = @cStorerKey
                           AND CaseID = @cDropID -- DropID value is caseID when not SingleUnitOrder
                           AND PD.ShipFlag <> 'Y'

                        --IF the consigneeKey exists in MPOCPERMIT, then even only 1 order in dropid
                        --it is still a MPOC order
                        IF EXISTS(SELECT 1
                                    FROM dbo.PICKDETAIL PD WITH (NOLOCK)
                                    JOIN dbo.ORDERS AS O WITH (NOLOCK)
                                       ON O.orderkey = PD.orderkey
                                    JOIN dbo.CODELKUP AS C WITH (NOLOCK)
                                       ON LISTNAME = 'MPOCPERMIT'
                                       AND ( C.Code = O.BillToKey OR C.Code = O.ConsigneeKey )
                                       AND C.Storerkey = O.StorerKey
                                    WHERE  PD.OrderKey = @cOrderKey)
                        BEGIN
                           SET @cOrderKey = 'MPOC'
                        END
                     END -- DropID contians 1 order
                     ELSE -- 1 dropid mulitple orders
                     BEGIN
                        --WCS will make sure all orders in one tote has same ORDERS.ConsigneeKey (ShipTo)
                        --Check whether the ShipTo is allowed to MPOC
                        IF EXISTS(SELECT 1
                                    FROM dbo.PICKDETAIL PD WITH (NOLOCK)
                                    JOIN dbo.ORDERS AS O WITH (NOLOCK)
                                       ON O.orderkey = PD.orderkey
                                    JOIN dbo.CODELKUP AS C WITH (NOLOCK)
                                       ON LISTNAME = 'MPOCPERMIT'
                                       AND ( C.Code = O.BillToKey OR C.Code = O.ConsigneeKey )
                                       AND C.Storerkey = O.StorerKey
                                    WHERE  PD.CaseID = @cDropID) -- DropID value is caseID when not SingleUnitOrder
                        BEGIN
                           SET @cOrderKey = 'MPOC'
                        END
                        ELSE -- Not allow to MPOC
                        BEGIN
                           SET @nErrNo = 217360
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- MPOC not allowed
                           GOTO Step_1_99_Fail
                        END
                     END--one dropid multiple orders
                     -- V1.4.0 Set OrderKey when not single unit orders END
                  END --Original logc single order flag <> 'Y'
                  ELSE --Single unit orders logic
                  BEGIN
                     --Single unit orders validation
                     --PackDetail should be ready before packing
                     IF NOT EXISTS (SELECT 1 FROM dbo.PackDetail WITH(NOLOCK)
                                    WHERE StorerKey = @cStorerkey
                                       AND DropID = @cToteID --ToteID
                     )
                     BEGIN
                        SET @nErrNo = 217354
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- PackDetail not ready
                        GOTO Step_1_99_Fail
                     END
                  END -- Single unit orders validation

                  -- FCR-13167: Common logic for both SUO and Normal Order - go to scn 6911
                  SET @cSKU = ''

                  -- FCR-13167: Get statistics for scn 6911 display
                  -- Get carton-level totals from PackDetail
                  IF @cSingleUnitOrdFlag = 'Y'
                     SELECT @nCtnSKUTotal = COUNT(DISTINCT SKU),
                            @nTotalQtyExpected = ISNULL(SUM(QTY), 0)
                     FROM dbo.PackDetail WITH (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND DropID = @cToteID
                  ELSE
                     SELECT @nCtnSKUTotal = COUNT(DISTINCT SKU),
                            @nTotalQtyExpected = ISNULL(SUM(QTY), 0)
                     FROM dbo.PackDetail WITH (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND LabelNo = @cDropID

                  -- Get current counters from RDTPPA
                  IF @cSingleUnitOrdFlag = 'Y'
                     SELECT @nCtnSKUCounted = COUNT(DISTINCT PPA.SKU),
                            @nTotalQtyCKD = ISNULL(SUM(PPA.CQty), 0)
                     FROM dbo.PackDetail PD WITH (NOLOCK)
                     INNER JOIN rdt.RDTPPA PPA WITH (NOLOCK)
                        ON PD.StorerKey = PPA.StorerKey
                        AND PD.LabelNo = PPA.DropID
                        AND PD.SKU = PPA.SKU
                     WHERE PD.StorerKey = @cStorerKey
                        AND PD.DropID = @cToteID
                        AND PPA.CQty > 0
                  ELSE
                     SELECT @nCtnSKUCounted = COUNT(DISTINCT SKU),
                            @nTotalQtyCKD = ISNULL(SUM(CQty), 0)
                     FROM rdt.RDTPPA WITH (NOLOCK)
                     WHERE StorerKey = @cStorerKey AND DropID = @cDropID AND CQty > 0


                  -- FCR-13167: scn 6911 screen layout - OutField01=SKU, OutField02=QTY
                  SET @cOutField01 = '' -- SKU input (empty for first scan)
                  SET @cOutField02 = @cPPADefaultQTY -- QTY input (default value)
                  SET @cOutField03 = '' -- Scanned SKU display
                  SET @cOutField04 = '' -- Style/Color/Size
                  SET @cOutField05 = '' -- SKU Description
                  SET @cOutField06 = '0' -- SKU Counted (empty, no SKU scanned yet)
                  SET @cOutField07 = CAST(ISNULL(@nCtnSKUCounted, 0) AS NVARCHAR(5)) + '/' + CAST(ISNULL(@nCtnSKUTotal, 0) AS NVARCHAR(5)) -- CTN SKU CKD/Total
                  SET @cOutField08 = '0' -- SKU TOTAL (empty, no SKU scanned yet)
                  SET @cOutField09 = CAST(ISNULL(@nTotalQtyCKD, 0) AS NVARCHAR(5)) + '/' + CAST(ISNULL(@nTotalQtyExpected, 0) AS NVARCHAR(5)) -- QTY CKD/Total
                  SET @cOutField10 = '' -- VAS1
                  SET @cOutField11 = '' -- VAS2
                  SET @cOutField12 = '' -- VAS3
                  SET @cOutField13 = '' -- VAS4
                  SET @cOutField14 = '' -- VAS5
                  EXEC rdt.rdtSetFocusField @nMobile, 1 --SKU

                  -- Enable all fields
                  SET @cFieldAttr01 = ''
                  SET @cFieldAttr02 = ''
                  SET @cFieldAttr03 = ''
                  SET @cFieldAttr04 = ''
                  SET @cFieldAttr05 = ''

                  -- FCR-13167: Disable QTY field if configured (scn 6911 uses @cFieldAttr02)
                  IF @cDisableQTYField = '1'
                     SET @cFieldAttr02 = 'O'

                  -- Go to next screen - FCR-13167: directly to scn 6911 (skip step 3)
                  SET @nAfterScn = 6911
                  SET @nAfterStep = 99
                  --V1.4.0 end

                  -- Extended info
                  IF @cExtendedInfoSP <> ''
                  BEGIN
                     IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
                     BEGIN
                        INSERT INTO @tExtInfo (Variable, Value) VALUES
                           ('@cRefNo',       @cRefNo),
                           ('@cPickSlipNo',  @cPickSlipNo),
                           ('@cLoadKey',     @cLoadKey),
                           ('@cOrderKey',    @cOrderKey),
                           ('@cDropID',      @cDropID),
                           ('@cID',          @cID),
                           ('@cTaskDetailKey',  @cTaskDetailKey),
                           ('@cSKU',         @cSKU),
                           ('@nQTY',         CAST( @nQTY AS NVARCHAR( 10))),
                           ('@nCSKU',        CAST( @nCSKU AS NVARCHAR( 10))),
                           ('@nCQTY',        CAST( @nCQTY AS NVARCHAR( 10))),
                           ('@nPSKU',        CAST( @nPSKU AS NVARCHAR( 10))),
                           ('@nPQTY',        CAST( @nPQTY AS NVARCHAR( 10))),
                           ('@cOption',      @cOption)

                        SET @cExtendedInfo = ''
                        SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
                           ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @tExtInfo, ' +
                           ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
                        SET @cSQLParam =
                           ' @nMobile        INT,           ' +
                           ' @nFunc          INT,           ' +
                           ' @cLangCode      NVARCHAR( 3),  ' +
                           ' @nStep          INT,           ' +
                           ' @nAfterStep     INT,           ' +
                           ' @nInputKey      INT,           ' +
                           ' @cFacility      NVARCHAR( 5),  ' +
                           ' @cStorerKey     NVARCHAR( 15), ' +
                           ' @tExtInfo       VariableTable READONLY, ' +
                           ' @cExtendedInfo  NVARCHAR( 20) OUTPUT, ' +
                           ' @nErrNo         INT           OUTPUT, ' +
                           ' @cErrMsg        NVARCHAR( 20) OUTPUT  '
                        EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                           @nMobile, @nFunc, @cLangCode, 1, @nStep, @nInputKey, @cFacility, @cStorerKey, @tExtInfo,
                           @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                        SET @cOutField14 = @cExtendedInfo
                     END
                  END
               END ---- End of @nInputKey = 1
               IF @nInputKey = 0
               BEGIN
                  -- (ChewKP02)
                  EXEC RDT.rdt_STD_EventLog
                    @cActionType = '9', -- Sign in function
                    @cUserID     = @cUserName,
                    @nMobileNo   = @nMobile,
                    @nFunctionID = @nFunc,
                    @cFacility   = @cFacility,
                    @cStorerKey  = @cStorerKey
                  -- Back to menu scn
                  SET @nAfterScn  = @nMenu
                  SET @nAfterStep = 0
                  SET @cOutField01 = ''

                  -- Enable all fields
                  SET @cFieldAttr01 = ''
                  SET @cFieldAttr02 = ''
                  SET @cFieldAttr03 = ''
                  SET @cFieldAttr04 = ''
                  SET @cFieldAttr05 = ''

                  SELECT
                     @cFieldAttr01  =  '',
                     @cFieldAttr02  =  '',
                     @cFieldAttr03  =  '',
                     @cFieldAttr04  =  '',
                     @cFieldAttr05  =  '',
                     @cFieldAttr06  =  '',
                     @cFieldAttr07  =  '',
                     @cFieldAttr08  =  '',
                     @cFieldAttr09  =  '',
                     @cFieldAttr10  =  ''
               END
               GOTO Quit

               Step_1_99_Fail:
               BEGIN
                  IF ISNULL(@cMultiColScan,'')=''
                  BEGIN
                     -- Reset this screen var
                     SET @cRefNo = ''
                     SET @cPickSlipNo = ''
                     SET @cLoadKey = ''
                     SET @cOrderKey = ''
                     SET @cDropID = ''
                     SET @cID = ''
                     SET @cTaskDetailKey = ''
                  END
                  ELSE
                  BEGIN
                     -- Prepare next screen var
                     SET @cOutField01 = @cRefNo
                     SET @cOutField02 = @cPickSlipNo
                     SET @cOutField03 = @cLoadKey
                     SET @cOutField04 = @cOrderKey
                     SET @cOutField05 = @cDropID
                     SET @cOutField06 = @cSKUStat
                     SET @cOutField07 = @cQTYStat
                     SET @cOutField08 = '' -- @cExtendedInfo
                     SET @cOutField09 = @cID
                     SET @cOutField10 = @cTaskDetailKey		--INC1045866
                  END
               END
            END -- end of @nAction = 0
         END -- end of 814

         --V1.4.0 END

         /********************************************************************************
         Step 99. Scn = 6911. SC2: SKU Scan with VAS display
         d01=SKU display, i02=QTY input, d03=Scanned SKU, d04=Style/Size/Color, d05=Descr
         d06/d07=SKU Ctd/Total, d08/d09=CTN SKU Ctd/Total, d10=Total, d11=QTY CKD
         d12-d15=VAS1-4

         Flow:
         - Enter with SKU only: validate SKU, display info, wait for QTY
         - ESC: complete packing or show discrepancy
         ********************************************************************************/
         ELSE IF @nScn = 6911
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'Executing St99, Scn6911 - SC2 SKU Scan'

            -- FCR-13167: First entry to scn 6911 - execute WSSOECL and load VAS codes
            -- Check if this is first SKU scan (no RDTPPA records exist for this DropID/ToteID)
            -- Get carton-level totals if not already loaded from RDTMOBREC
            IF ISNULL(@nCtnSKUTotal, 0) = 0
            BEGIN
               IF @cSingleUnitOrdFlag = 'Y'
                  SELECT @nCtnSKUTotal = COUNT(DISTINCT SKU),
                         @nTotalQtyExpected = ISNULL(SUM(QTY), 0)
                  FROM dbo.PackDetail WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cToteID
               ELSE
                  SELECT @nCtnSKUTotal = COUNT(DISTINCT SKU),
                         @nTotalQtyExpected = ISNULL(SUM(QTY), 0)
                  FROM dbo.PackDetail WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND LabelNo = @cDropID
            END

            -- FCR-13167: Disable QTY field if configured
            IF @cDisableQTYField = '1'
               SET @cFieldAttr02 = 'O'

            SET @cOption = ''

            IF @nInputKey = 1 -- Enter
            BEGIN
               SET @cUPC = @cInField01 -- SKU/UPC scanned

               -- Get QTY config from RDTMOBREC (already loaded above)
               -- DisableQTYField and PPADefaultQTY from original MOBREC read
               IF @cDisableQTYField = '' SET @cDisableQTYField = '0'
               IF @cPPADefaultQTY = '' SET @cPPADefaultQTY = '1'

               -- Get QTY: if DisableQTYField='1', use default; otherwise use input or default
               IF @cDisableQTYField = '1'
                  SET @nQTY = ISNULL(TRY_CAST(@cPPADefaultQTY AS INT), 1)
               ELSE
               BEGIN
                  SET @nQTY = ISNULL(TRY_CAST(@cInField02 AS INT), 0)
                  IF @nQTY = 0
                     SET @nQTY = ISNULL(TRY_CAST(@cPPADefaultQTY AS INT), 1)
               END

               -- If SKU empty (just Enter pressed), check completion status
               IF ISNULL(@cUPC, '') = ''
               BEGIN
                  -- FCR-13167: Check if packing complete when blank SKU entered
                  -- Both SUO and Normal Order check if all SKUs are complete
                  DECLARE @bPackingComplete BIT = 0

                  IF @cSingleUnitOrdFlag = 'Y'
                  BEGIN
                     -- SUO: Check if all SKUs in ToteID are complete
                     IF NOT EXISTS (
                        SELECT 1 FROM dbo.PackDetail PD WITH (NOLOCK)
                        LEFT JOIN rdt.RDTPPA PPA WITH (NOLOCK)
                           ON PD.StorerKey = PPA.StorerKey
                           AND PD.LabelNo = PPA.DropID
                           AND PD.SKU = PPA.SKU
                        WHERE PD.StorerKey = @cStorerKey
                           AND PD.DropID = @cToteID
                           AND (PPA.CQty IS NULL OR PPA.CQty < PD.Qty)
                     )
                        SET @bPackingComplete = 1
                  END
                  ELSE
                  BEGIN
                     -- Normal Order: Check if all SKUs in LabelNo are complete
                     IF NOT EXISTS (
                        SELECT 1 FROM dbo.PackDetail PD WITH (NOLOCK)
                        LEFT JOIN rdt.RDTPPA PPA WITH (NOLOCK)
                           ON PD.StorerKey = PPA.StorerKey
                           AND PD.LabelNo = PPA.DropID
                           AND PD.SKU = PPA.SKU
                        WHERE PD.StorerKey = @cStorerKey
                           AND PD.LabelNo = @cDropID
                           AND (PPA.CQty IS NULL OR PPA.CQty < PD.Qty)
                     )
                        SET @bPackingComplete = 1
                  END

                  IF @bPackingComplete = 1
                  BEGIN
                     -- FCR-13139: All complete + empty SKU + Enter
                     IF @cPrintControl = '1'
                     BEGIN
                        -- Already auto-printed on last SKU scan, return to 814
                        SET @cDropID = ''
                        SET @cOrderKey = ''
                        SET @cPickSlipNo = ''
                        SET @cOutField01 = ''
                        SET @cOutField02 = ''
                        SET @cOutField03 = ''
                        SET @cOutField04 = ''
                        SET @cOutField05 = ''
                        SET @cOutField06 = ''
                        SET @cOutField07 = ''

                        -- Enable disable field
                        SET @cFieldAttr01 = 'O' --RefNo
                        SET @cFieldAttr02 = 'O' --PickSlipNo
                        SET @cFieldAttr03 = 'O' --LoadKey
                        SET @cFieldAttr04 = 'O' --OrderKey
                        SET @cFieldAttr05 = ''
                        SET @cFieldAttr06 = 'O' --ID
                        SET @cFieldAttr07 = 'O' --TaskDetailKey

                        SET @nAfterScn = 814
                        SET @nAfterStep = 99
                     END
                     ELSE
                     BEGIN
                        -- Manual print: go to print screen (6464)
                        SET @nAfterScn = 6464
                        SET @nAfterStep = 99
                     END
                     GOTO Quit
                  END
                  ELSE
                  BEGIN
                     -- Not complete - reload display and stay on screen
                     -- Build VAS display strings (VAS codes already loaded from RDTMOBREC)
                     SET @cVASDisplay1 = ISNULL(@cVASCode1, '') + CASE WHEN ISNULL(@cVASCode1, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc1, ''), 40) ELSE '' END
                     SET @cVASDisplay2 = ISNULL(@cVASCode2, '') + CASE WHEN ISNULL(@cVASCode2, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc2, ''), 40) ELSE '' END
                     SET @cVASDisplay3 = ISNULL(@cVASCode3, '') + CASE WHEN ISNULL(@cVASCode3, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc3, ''), 40) ELSE '' END
                     SET @cVASDisplay4 = ISNULL(@cVASCode4, '') + CASE WHEN ISNULL(@cVASCode4, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc4, ''), 40) ELSE '' END
                     SET @cVASDisplay5 = ISNULL(@cVASCode5, '') + CASE WHEN ISNULL(@cVASCode5, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc5, ''), 40) ELSE '' END

                     -- Reload counters
                     IF @cSingleUnitOrdFlag = 'Y'
                        SELECT @nCtnSKUCounted = COUNT(DISTINCT PPA.SKU)
                        FROM dbo.PackDetail PD WITH (NOLOCK)
                        INNER JOIN rdt.RDTPPA PPA WITH (NOLOCK)
                           ON PD.StorerKey = PPA.StorerKey
                           AND PD.LabelNo = PPA.DropID
                           AND PD.SKU = PPA.SKU
                        WHERE PD.StorerKey = @cStorerKey
                           AND PD.DropID = @cToteID
                           AND PPA.CQty > 0
                     ELSE
                        SELECT @nCtnSKUCounted = COUNT(DISTINCT SKU)
                        FROM rdt.RDTPPA WITH (NOLOCK)
                        WHERE StorerKey = @cStorerKey AND DropID = @cDropID AND CQty > 0

                     SET @cOutField01 = ''
                     SET @cOutField02 = @cPPADefaultQTY -- Reset QTY to default
                     SET @cOutField07 = CAST(ISNULL(@nCtnSKUCounted, 0) AS NVARCHAR(5)) + '/' + CAST(ISNULL(@nCtnSKUTotal, 0) AS NVARCHAR(5)) -- CTN/SKU (X/Y)
                     SET @cOutField10 = @cVASDisplay1
                     SET @cOutField11 = @cVASDisplay2
                     SET @cOutField12 = @cVASDisplay3
                     SET @cOutField13 = @cVASDisplay4
                     SET @cOutField14 = @cVASDisplay5

                     -- If DisableQTYField='1', set QTY field to output only
                     IF @cDisableQTYField = '1'
                        SET @cFieldAttr02 = 'O'

                     SET @nAfterScn = 6911
                     SET @nAfterStep = 99
                     GOTO Quit
                  END
               END

               -- If SKU is new (different from saved or first scan), validate it
               -- @cSavedSKU already loaded from RDTMOBREC C_String10
               IF ISNULL(@cUPC, '') <> '' AND @cUPC <> ISNULL(@cSavedSKU, '')
               BEGIN
                  -- Verify SKU is valid
                  SET @nSKUCnt = 0
                  EXEC [RDT].[rdt_GETSKUCNT]
                     @cStorerKey  = @cStorerKey,
                     @cSKU        = @cUPC,
                     @nSKUCnt     = @nSKUCnt OUTPUT,
                     @bSuccess    = @b_Success OUTPUT,
                     @nErr        = @nErrNo OUTPUT,
                     @cErrMsg     = @cErrMsg OUTPUT

                  IF @nSKUCnt = 0
                  BEGIN
                     SET @nErrNo = 268653
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Invalid SKU
                     GOTO Scn_6911_Fail
                  END

                  -- Get real SKU value
                  EXEC [RDT].[rdt_GETSKU]
                     @cStorerKey  = @cStorerKey,
                     @cSKU        = @cUPC OUTPUT,
                     @bSuccess    = @b_Success OUTPUT,
                     @nErr        = @nErrNo OUTPUT,
                     @cErrMsg     = @cErrMsg OUTPUT,
                     @cSKUStatus  = 'ACTIVE'

                  IF @nErrNo <> 0
                  BEGIN
                     SET @nErrNo = 268654
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Invalid SKU
                     GOTO Scn_6911_Fail
                  END

                  SET @cSKU = @cUPC

                  -- Verify SKU belongs to this carton
                  -- FCR-13167: SUO uses ToteID (PackDetail.DropID), Normal uses LabelNo
                  IF @cSingleUnitOrdFlag = 'Y'
                  BEGIN
                     -- First check: SKU exists in ToteID
                     IF NOT EXISTS (SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)
                        WHERE StorerKey = @cStorerKey
                        AND DropID = @cToteID
                        AND SKU = @cSKU)
                     BEGIN
                        SET @nErrNo = 268655
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --SKU not in carton
                        GOTO Scn_6911_Fail
                     END

                     -- FCR-13167: Second check for SUO - SKU must have uncompleted CaseID
                     -- All CaseIDs for this SKU may already be scanned
                     IF NOT EXISTS (
                        SELECT 1
                        FROM dbo.PackInfo PI WITH (NOLOCK)
                        INNER JOIN dbo.PackDetail PD WITH (NOLOCK)
                           ON PI.PickSlipNo = PD.PickSlipNo
                           AND PI.CartonNo = PD.CartonNo
                        LEFT JOIN rdt.RDTPPA PPA WITH (NOLOCK)
                           ON PD.StorerKey = PPA.StorerKey
                           AND PD.LabelNo = PPA.DropID
                           AND PD.SKU = PPA.SKU
                        WHERE PD.StorerKey = @cStorerKey
                           AND PD.DropID = @cToteID
                           AND PD.SKU = @cSKU
                           AND ISNULL(PI.CartonStatus,'') <> 'PACKED'
                           AND (PPA.RowRef IS NULL OR ISNULL(PPA.CQty, 0) < PD.Qty)
                     )
                     BEGIN
                        SET @nErrNo = 268668
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --SKU already scanned
                        GOTO Scn_6911_Fail
                     END
                  END
                  ELSE
                  BEGIN
                     -- Normal Order: Check PackDetail.LabelNo or PickDetail.CaseID
                     IF NOT EXISTS (SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)
                        WHERE StorerKey = @cStorerKey
                        AND LabelNo = @cDropID
                        AND SKU = @cSKU)
                     BEGIN
                        -- Fallback: check PickDetail.CaseID
                        IF NOT EXISTS (SELECT 1 FROM dbo.PickDetail WITH (NOLOCK)
                           WHERE StorerKey = @cStorerKey
                           AND CaseID = @cDropID
                           AND SKU = @cSKU)
                        BEGIN
                           SET @nErrNo = 268655
                           SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --SKU not in carton
                           GOTO Scn_6911_Fail
                        END
                     END
                  END

                  -- FCR-13139: Call ExtendedValidateSP for SKU validation
                  IF @cExtendedValidateSP <> ''
                  BEGIN
                     IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
                     BEGIN
                        DELETE FROM @tExtValidate
                        INSERT INTO @tExtValidate (Variable, Value) VALUES
                           ('@cSKU',         @cSKU),
                           ('@nQTY',         CAST( @nQTY AS NVARCHAR( 10))),
                           ('@nInputKey',    CAST( @nInputKey AS NVARCHAR( 1)))

                        SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedValidateSP) +
                           ' @nMobile, @nFunc, @cLangCode, @nStep, @cStorer, @cFacility, @cRefNo, @cOrderKey, @cDropID, @cLoadKey, @cPickSlipNo, ' +
                           ' @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey, @tExtValidate '
                        SET @cSQLParam =
                           '@nMobile        INT, ' +
                           '@nFunc          INT, ' +
                           '@cLangCode      NVARCHAR( 3),  ' +
                           '@nStep          INT,           ' +
                           '@cStorer        NVARCHAR( 15), ' +
                           '@cFacility      NVARCHAR( 5),  ' +
                           '@cRefNo         NVARCHAR( 20), ' +
                           '@cOrderKey      NVARCHAR( 10), ' +
                           '@cDropID        NVARCHAR( 20), ' +
                           '@cLoadKey       NVARCHAR( 10), ' +
                           '@cPickSlipNo    NVARCHAR( 10), ' +
                           '@nErrNo         INT           OUTPUT, ' +
                           '@cErrMsg        NVARCHAR( 20) OUTPUT, ' +
                           '@cID            NVARCHAR( 18), ' +
                           '@cTaskDetailKey NVARCHAR( 10), ' +
                           '@tExtValidate   VARIABLETABLE READONLY'

                        EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                           @nMobile, @nFunc, @cLangCode, @nStep, @cStorerKey, @cFacility, @cRefNo, @cOrderKey, @cDropID, @cLoadKey, @cPickSlipNo,
                           @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey, @tExtValidate

                        IF @nErrNo <> 0
                        BEGIN
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                           GOTO Scn_6911_Fail
                        END
                     END
                  END

                  -- FCR-13167: WSSOECL TRANSMITLOG2 is now inserted in step 3 Enter (before jumping to scn 6911)

                  -- FCR-13167: For SUO, get LabelNo for current SKU (for RDTPPA write)
                  -- Must exclude CaseIDs that already have RDTPPA records with CQty >= expected Qty
                  IF @cSingleUnitOrdFlag = 'Y'
                  BEGIN
                     SELECT TOP 1
                        @cOrderKey = ISNULL(PH.OrderKey, @cOrderKey),
                        @cPickSlipNo = ISNULL(PD.PickSlipNo, @cPickSlipNo),
                        @cLabelNo = PD.LabelNo
                     FROM dbo.PackInfo PI WITH (NOLOCK)
                     INNER JOIN dbo.PackDetail PD WITH (NOLOCK)
                        ON PI.PickSlipNo = PD.PickSlipNo
                        AND PI.CartonNo = PD.CartonNo
                     INNER JOIN dbo.PickHeader PH WITH (NOLOCK)
                        ON PD.PickSlipNo = PH.PickHeaderKey
                        AND PD.StorerKey = PH.StorerKey
                     LEFT JOIN rdt.RDTPPA PPA WITH (NOLOCK)
                        ON PD.StorerKey = PPA.StorerKey
                        AND PD.LabelNo = PPA.DropID
                        AND PD.SKU = PPA.SKU
                     WHERE
                        PD.StorerKey = @cStorerKey
                        AND PD.DropID = @cToteID
                        AND PD.SKU = @cSKU
                        AND ISNULL(PI.CartonStatus,'') <> 'PACKED'
                        AND (PPA.RowRef IS NULL OR ISNULL(PPA.CQty, 0) < PD.Qty) -- Exclude completed CaseIDs

                     -- Convert DropID to LabelNo for RDTPPA write
                     IF ISNULL(@cLabelNo, '') <> ''
                        SET @cDropID = @cLabelNo
                  END

                  -- FCR-13167: Load VAS codes for current CaseID
                  -- First: VAS Header (VASORD, ExternLineNo='0H') - max 2 lines
                  -- Then: VAS Line (WKORDTYPE, SKU level) - remaining lines
                  DECLARE @nVASHeaderCount INT = 0

                  -- Load VAS Header first (max 2)
                  ;WITH VAS_HEADER_RAW AS (
                     SELECT DISTINCT
                        CLK.Code AS VASCode,
                        CLK.Description AS VASDescription
                     FROM dbo.WorkOrderDetail WOD WITH (NOLOCK)
                     INNER JOIN dbo.PickDetail PKD WITH (NOLOCK)
                        ON WOD.StorerKey = PKD.StorerKey
                        AND WOD.ExternWorkOrderKey = PKD.OrderKey
                     INNER JOIN dbo.CODELKUP CLK WITH (NOLOCK)
                        ON PKD.StorerKey = CLK.StorerKey
                        AND CLK.LISTNAME = 'VASORD'
                        AND WOD.Type = CLK.Code
                     WHERE PKD.StorerKey = @cStorerKey
                        AND PKD.CaseID = @cDropID
                        AND WOD.ExternLineNo = '0H'
                  ),
                  VAS_HEADER_CTE AS (
                     SELECT VASCode, VASDescription, ROW_NUMBER() OVER (ORDER BY VASCode) AS RowNum
                     FROM VAS_HEADER_RAW
                  )
                  SELECT
                     @cVASCode1 = MAX(CASE WHEN RowNum = 1 THEN VASCode END),
                     @cVASDesc1 = MAX(CASE WHEN RowNum = 1 THEN VASDescription END),
                     @cVASCode2 = MAX(CASE WHEN RowNum = 2 THEN VASCode END),
                     @cVASDesc2 = MAX(CASE WHEN RowNum = 2 THEN VASDescription END),
                     @nVASHeaderCount = COUNT(*)
                  FROM VAS_HEADER_CTE
                  WHERE RowNum <= 2

                  -- Load VAS Line (WKORDTYPE) into remaining slots
                  ;WITH VAS_LINE_RAW AS (
                     SELECT DISTINCT
                        lk.Code AS VASCode,
                        lk.Description AS VASDescription
                     FROM dbo.WorkOrderDetail wod WITH (NOLOCK)
                     INNER JOIN dbo.WorkOrder wo WITH (NOLOCK)
                        ON wo.WorkOrderKey = wod.WorkOrderKey
                     INNER JOIN dbo.CODELKUP lk WITH (NOLOCK)
                        ON wo.StorerKey = lk.StorerKey
                        AND wod.Type = lk.Code
                        AND ISNULL(lk.Short, '') <> 'Y'
                        AND lk.LISTNAME = 'WKORDTYPE'
                     INNER JOIN dbo.PickDetail pkd WITH (NOLOCK)
                        ON wo.StorerKey = pkd.StorerKey
                        AND wod.ExternWorkOrderKey = pkd.OrderKey
                        AND pkd.OrderLinenumber = wod.ExternLineNo
                     WHERE wo.StorerKey = @cStorerKey
                        AND pkd.CaseID = @cDropID
                        AND wod.ExternWorkOrderKey IS NOT NULL
                        AND wod.ExternWorkOrderKey <> ''
                  ),
                  VAS_LINE_CTE AS (
                     SELECT VASCode, VASDescription, ROW_NUMBER() OVER (ORDER BY VASCode) AS RowNum
                     FROM VAS_LINE_RAW
                  )
                  SELECT
                     -- Fill slots after VAS Header (based on header count)
                     @cVASCode3 = CASE WHEN @nVASHeaderCount >= 2 THEN MAX(CASE WHEN RowNum = 1 THEN VASCode END) ELSE @cVASCode3 END,
                     @cVASDesc3 = CASE WHEN @nVASHeaderCount >= 2 THEN MAX(CASE WHEN RowNum = 1 THEN VASDescription END) ELSE @cVASDesc3 END,
                     @cVASCode4 = CASE WHEN @nVASHeaderCount >= 2 THEN MAX(CASE WHEN RowNum = 2 THEN VASCode END) ELSE @cVASCode4 END,
                     @cVASDesc4 = CASE WHEN @nVASHeaderCount >= 2 THEN MAX(CASE WHEN RowNum = 2 THEN VASDescription END) ELSE @cVASDesc4 END,
                     @cVASCode5 = CASE WHEN @nVASHeaderCount >= 2 THEN MAX(CASE WHEN RowNum = 3 THEN VASCode END) ELSE @cVASCode5 END,
                     @cVASDesc5 = CASE WHEN @nVASHeaderCount >= 2 THEN MAX(CASE WHEN RowNum = 3 THEN VASDescription END) ELSE @cVASDesc5 END
                  FROM VAS_LINE_CTE
                  WHERE RowNum <= 3

                  -- If VAS Header has 0 or 1 entry, fill remaining slots with VAS Line
                  IF @nVASHeaderCount = 0
                  BEGIN
                     ;WITH VAS_LINE_RAW AS (
                        SELECT DISTINCT lk.Code AS VASCode, lk.Description AS VASDescription
                        FROM dbo.WorkOrderDetail wod WITH (NOLOCK)
                        INNER JOIN dbo.WorkOrder wo WITH (NOLOCK) ON wo.WorkOrderKey = wod.WorkOrderKey
                        INNER JOIN dbo.CODELKUP lk WITH (NOLOCK) ON wo.StorerKey = lk.StorerKey AND wod.Type = lk.Code AND ISNULL(lk.Short, '') <> 'Y' AND lk.LISTNAME = 'WKORDTYPE'
                        INNER JOIN dbo.PickDetail pkd WITH (NOLOCK) ON wo.StorerKey = pkd.StorerKey AND wod.ExternWorkOrderKey = pkd.OrderKey AND pkd.OrderLinenumber = wod.ExternLineNo
                        WHERE wo.StorerKey = @cStorerKey AND pkd.CaseID = @cDropID AND wod.ExternWorkOrderKey IS NOT NULL AND wod.ExternWorkOrderKey <> ''
                     ),
                     VAS_LINE_CTE AS (
                        SELECT VASCode, VASDescription, ROW_NUMBER() OVER (ORDER BY VASCode) AS RowNum FROM VAS_LINE_RAW
                     )
                     SELECT
                        @cVASCode1 = MAX(CASE WHEN RowNum = 1 THEN VASCode END),
                        @cVASDesc1 = MAX(CASE WHEN RowNum = 1 THEN VASDescription END),
                        @cVASCode2 = MAX(CASE WHEN RowNum = 2 THEN VASCode END),
                        @cVASDesc2 = MAX(CASE WHEN RowNum = 2 THEN VASDescription END),
                        @cVASCode3 = MAX(CASE WHEN RowNum = 3 THEN VASCode END),
                        @cVASDesc3 = MAX(CASE WHEN RowNum = 3 THEN VASDescription END),
                        @cVASCode4 = MAX(CASE WHEN RowNum = 4 THEN VASCode END),
                        @cVASDesc4 = MAX(CASE WHEN RowNum = 4 THEN VASDescription END),
                        @cVASCode5 = MAX(CASE WHEN RowNum = 5 THEN VASCode END),
                        @cVASDesc5 = MAX(CASE WHEN RowNum = 5 THEN VASDescription END)
                     FROM VAS_LINE_CTE
                     WHERE RowNum <= 5
                  END
                  ELSE IF @nVASHeaderCount = 1
                  BEGIN
                     ;WITH VAS_LINE_RAW AS (
                        SELECT DISTINCT lk.Code AS VASCode, lk.Description AS VASDescription
                        FROM dbo.WorkOrderDetail wod WITH (NOLOCK)
                        INNER JOIN dbo.WorkOrder wo WITH (NOLOCK) ON wo.WorkOrderKey = wod.WorkOrderKey
                        INNER JOIN dbo.CODELKUP lk WITH (NOLOCK) ON wo.StorerKey = lk.StorerKey AND wod.Type = lk.Code AND ISNULL(lk.Short, '') <> 'Y' AND lk.LISTNAME = 'WKORDTYPE'
                        INNER JOIN dbo.PickDetail pkd WITH (NOLOCK) ON wo.StorerKey = pkd.StorerKey AND wod.ExternWorkOrderKey = pkd.OrderKey AND pkd.OrderLinenumber = wod.ExternLineNo
                        WHERE wo.StorerKey = @cStorerKey AND pkd.CaseID = @cDropID AND wod.ExternWorkOrderKey IS NOT NULL AND wod.ExternWorkOrderKey <> ''
                     ),
                     VAS_LINE_CTE AS (
                        SELECT VASCode, VASDescription, ROW_NUMBER() OVER (ORDER BY VASCode) AS RowNum FROM VAS_LINE_RAW
                     )
                     SELECT
                        @cVASCode2 = MAX(CASE WHEN RowNum = 1 THEN VASCode END),
                        @cVASDesc2 = MAX(CASE WHEN RowNum = 1 THEN VASDescription END),
                        @cVASCode3 = MAX(CASE WHEN RowNum = 2 THEN VASCode END),
                        @cVASDesc3 = MAX(CASE WHEN RowNum = 2 THEN VASDescription END),
                        @cVASCode4 = MAX(CASE WHEN RowNum = 3 THEN VASCode END),
                        @cVASDesc4 = MAX(CASE WHEN RowNum = 3 THEN VASDescription END),
                        @cVASCode5 = MAX(CASE WHEN RowNum = 4 THEN VASCode END),
                        @cVASDesc5 = MAX(CASE WHEN RowNum = 4 THEN VASDescription END)
                     FROM VAS_LINE_CTE
                     WHERE RowNum <= 4
                  END

                  -- Get SKU details for display
                  SELECT
                     @cSKUDescr1 = ISNULL(S.Style, '') + '/' + ISNULL(S.Color, '') + '/' + ISNULL(S.Size, ''),
                     @cSKUDescr2 = ISNULL(S.DESCR, '')
                     FROM dbo.SKU S WITH (NOLOCK)
                  WHERE S.StorerKey = @cStorerKey
                     AND S.SKU = @cSKU

                  -- Get expected QTY for this SKU
                  -- FCR-13167: SUO uses ToteID for PackDetail, Normal uses LabelNo
                  IF @cSingleUnitOrdFlag = 'Y'
                     SELECT @nSKUTotal = ISNULL(SUM(QTY), 0)
                     FROM dbo.PackDetail WITH (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND DropID = @cToteID
                        AND SKU = @cSKU
                  ELSE
                     SELECT @nSKUTotal = ISNULL(SUM(QTY), 0)
                     FROM dbo.PackDetail WITH (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND LabelNo = @cDropID
                        AND SKU = @cSKU

                  -- Get already counted QTY from RDTPPA
                  -- FCR-13167: RDTPPA.DropID = LabelNo (after conversion for SUO)
                  SELECT @nSKUCounted = ISNULL(SUM(CQty), 0)
                  FROM rdt.RDTPPA WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cDropID
                     AND SKU = @cSKU

                  IF @cSingleUnitOrdFlag = 'Y'
                     SELECT @nCtnSKUCounted = COUNT(DISTINCT PPA.SKU)
                        FROM PACKDETAIL PD WITH (NOLOCK)
                        INNER JOIN rdt.RDTPPA PPA WITH (NOLOCK)
                        ON PD.StorerKey = PPA.StorerKey
                           AND PD.LabelNo = PPA.DropID
                           AND PD.SKU = PPA.SKU
                     WHERE PD.StorerKey = @cStorerKey
                        AND PD.DropID = @cToteID
                  ELSE
                     -- Get carton-level SKU counted
                     SELECT @nCtnSKUCounted = COUNT(DISTINCT SKU)
                     FROM rdt.RDTPPA WITH (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND DropID = @cDropID
                        AND CQty > 0

                  -- @cPUOM already retrieved from @tExtScnData at SP start (line 194)

                  -- Save current SKU for flow-through (will be saved to RDTMOBREC at Quit)
                  SET @cSavedSKU = @cSKU
               END
               ELSE
               BEGIN
                  -- Use saved SKU (already loaded from RDTMOBREC C_String10)
                  SET @cSKU = @cSavedSKU
                  -- @nSKUTotal already loaded from RDTMOBREC
               END

               -- Build VAS display strings (VAS codes already loaded from RDTMOBREC)
               SET @cVASDisplay1 = ISNULL(@cVASCode1, '') + CASE WHEN ISNULL(@cVASCode1, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc1, ''), 40) ELSE '' END
               SET @cVASDisplay2 = ISNULL(@cVASCode2, '') + CASE WHEN ISNULL(@cVASCode2, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc2, ''), 40) ELSE '' END
               SET @cVASDisplay3 = ISNULL(@cVASCode3, '') + CASE WHEN ISNULL(@cVASCode3, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc3, ''), 40) ELSE '' END
               SET @cVASDisplay4 = ISNULL(@cVASCode4, '') + CASE WHEN ISNULL(@cVASCode4, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc4, ''), 40) ELSE '' END
               SET @cVASDisplay5 = ISNULL(@cVASCode5, '') + CASE WHEN ISNULL(@cVASCode5, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc5, ''), 40) ELSE '' END

               DECLARE @nTranCount INT
               SET @nTranCount = @@TRANCOUNT

               IF @nTranCount = 0
                  BEGIN TRAN Scn_6911_Tran
               ELSE
                  SAVE TRAN Scn_6911_Tran

               -- FCR-13167: Record the count (auto-increment by 1 on each scan)
               IF ISNULL(@cSKU, '') <> ''
               BEGIN

                  -- FCR-13167: Validate packed qty cannot exceed required qty
                  DECLARE @nCurrentCQty INT = 0
                  SELECT @nCurrentCQty = ISNULL(CQty, 0)
                  FROM rdt.RDTPPA WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey AND DropID = @cDropID AND SKU = @cSKU

                  IF (@nCurrentCQty + @nQTY) > @nSKUTotal
                  BEGIN
                     SET @nErrNo = 268657
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- QTY exceeds expected
                     GOTO Scn_6911_Rollback
                  END

                  -- Insert/Update RDTPPA record
                  IF EXISTS (SELECT 1 FROM rdt.RDTPPA WITH (NOLOCK)
                     WHERE StorerKey = @cStorerKey AND DropID = @cDropID AND SKU = @cSKU)
                  BEGIN
                     BEGIN TRY
                        UPDATE rdt.RDTPPA
                        SET CQty = CQty + @nQTY,
                            EditDate = GETDATE(),
                            EditWho = SUSER_SNAME()
                        WHERE StorerKey = @cStorerKey
                           AND DropID = @cDropID
                           AND SKU = @cSKU
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 268664
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- RDTPPA Update Failed
                        GOTO Scn_6911_Rollback
                     END CATCH
                  END
                  ELSE
                  BEGIN
                     -- Check if this is the first SKU scan for this DropID (before INSERT)
                     DECLARE @bIsFirstSKUScan BIT = 0
                     IF NOT EXISTS (SELECT 1 FROM rdt.RDTPPA WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND DropID = @cDropID)
                        SET @bIsFirstSKUScan = 1

                     BEGIN TRY
                        INSERT INTO rdt.rdtPPA WITH (ROWLOCK) (Refkey, PickSlipno, LoadKey, Store, StorerKey, Sku, Descr, PQTY, CQTY, Status, UserName, AddDate, NoOfCheck, UOMQty, OrderKey, DropID)
                        VALUES ('', @cPickSlipNo, '', '', @cStorerKey, @cSKU, @cSKUDescr2, @nSKUTotal, @nQTY, '0', SUSER_SNAME(), GETDATE(), 0, 1, @cOrderKey, @cDropID)
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 268665
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- RDTPPA Insert Failed
                        GOTO Scn_6911_Rollback
                     END CATCH

                     -- FCR-13167: WSSOECL logic on first SKU scan (moved from ExtUpd13/24)
                     -- Only trigger if ShipperKey is in WSCourier list
                     IF @bIsFirstSKUScan = 1
                     BEGIN
                        -- Get ShipperKey from Orders
                        SELECT TOP 1 @cShipperKey = ISNULL(O.ShipperKey, '')
                        FROM dbo.PickDetail PD WITH (NOLOCK)
                        INNER JOIN dbo.Orders O WITH (NOLOCK)
                           ON PD.OrderKey = O.OrderKey
                        WHERE PD.StorerKey = @cStorerKey
                           AND PD.CaseID = @cDropID

                        -- Check if ShipperKey is in WSCourier list
                        IF TRIM(@cShipperKey) <> ''
                           AND EXISTS(SELECT 1 FROM dbo.CODELKUP WITH (NOLOCK)
                                      WHERE StorerKey = @cStorerKey
                                        AND LISTNAME = 'WSCourier'
                                        AND @cShipperKey = ISNULL(notes, '-1'))
                        BEGIN
                           -- V1.17: Generate ReferenceID for orders without one
                           DELETE FROM @tOrderNoRefID
                           INSERT INTO @tOrderNoRefID (OrderKey, ConsigneeKey, WaveKey)
                              SELECT DISTINCT ORM.OrderKey, ORM.ConsigneeKey, ORM.UserDefine09
                              FROM dbo.PICKDETAIL PD WITH (NOLOCK)
                              JOIN dbo.ORDERS ORM WITH (NOLOCK) ON PD.OrderKey = ORM.OrderKey
                              JOIN dbo.OrderInfo OI WITH (NOLOCK) ON ORM.OrderKey = OI.OrderKey
                              WHERE PD.CaseID = @cDropID
                                 AND PD.CaseID <> ''
                                 AND PD.StorerKey = @cStorerKey
                                 AND PD.Status NOT IN ('4', '9')
                                 AND (OI.ReferenceId IS NULL OR OI.ReferenceId = '')

                           IF EXISTS (SELECT 1 FROM @tOrderNoRefID)
                           BEGIN
                              SET @nLoopIndex = -1
                              WHILE 1 = 1
                              BEGIN
                                 SELECT TOP 1
                                    @cONRIOrderKey = OrderKey,
                                    @cONRIConsigneeKey = ConsigneeKey,
                                    @cONRIWaveKey = WaveKey,
                                    @nLoopIndex = RowNumber
                                 FROM @tOrderNoRefID
                                 WHERE RowNumber > @nLoopIndex
                                 ORDER BY RowNumber

                                 SET @nRowCount = @@ROWCOUNT

                                 IF @nRowCount = 0
                                    BREAK

                                 SET @cReferenceID = ''

                                 -- Call BOL running number generator
                                 EXEC [dbo].[msp_GetBOLbyConsigneeKey]
                                    @c_Wavekey  = @cONRIWaveKey,
                                    @c_Orderkey = @cONRIOrderKey,
                                    @c_Consigneekey = @cONRIConsigneeKey,
                                    @c_BOLByConsigneekey = @cReferenceID OUTPUT,
                                    @c_OtherParams = @cOtherParams OUTPUT,
                                    @b_Success = @bSuccess OUTPUT,
                                    @n_Err = @nErrNo OUTPUT,
                                    @c_ErrMsg = @cErrMsg OUTPUT

                                 IF @bSuccess <> 1 OR @nErrNo <> 0
                                 BEGIN
                                    SET @nErrNo = 268669
                                    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --GenReferenceIDFail
                                    GOTO Scn_6911_Fail
                                 END

                                 BEGIN TRY
                                    UPDATE dbo.OrderInfo WITH (ROWLOCK)
                                    SET ReferenceId = @cReferenceID
                                    WHERE OrderKey = @cONRIOrderKey
                                 END TRY
                                 BEGIN CATCH
                                    SET @nErrNo = 268670
                                    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Update OrderInfo fail
                                    GOTO Scn_6911_Fail
                                 END CATCH
                              END -- loop generating reference id end
                           END -- OrderNoRefID exists end

                           -- Insert WSSOECL TRANSMITLOG2
                           DECLARE @cTruncatedDropID_6911 NVARCHAR(10) = LEFT(@cDropID, 10)

                           EXECUTE ispGenTransmitLog2
                              @c_TableName      = 'WSSOECL',
                              @c_Key1           = @cTruncatedDropID_6911,
                              @c_Key2           = @cDropID,
                              @c_Key3           = @cStorerKey,
                              @c_TransmitBatch  = '',
                              @b_Success        = @b_Success   OUTPUT,
                              @n_err            = @nErrNo      OUTPUT,
                              @c_errmsg         = @cErrMsg     OUTPUT

                           IF @b_Success <> 1
                           BEGIN
                              SET @nErrNo = 268661
                              SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --GenTranLogFail
                              GOTO Scn_6911_Fail
                           END

                           -- Insert QCmd alert
                           DECLARE @cTransmitLogKey_6911 NVARCHAR(50)
                           SELECT @cTransmitLogKey_6911 = transmitlogkey
                           FROM dbo.TRANSMITLOG2 WITH (NOLOCK)
                           WHERE tablename = 'WSSOECL'
                              AND key1 = @cTruncatedDropID_6911
                              AND key2 = @cDropID
                              AND key3 = @cStorerKey

                           EXEC dbo.isp_QCmd_WSTransmitLogInsertAlert
                              @c_QCmdClass         = @c_QCmdClass,
                              @c_FrmTransmitlogKey = @cTransmitLogKey_6911,
                              @c_ToTransmitlogKey  = @cTransmitLogKey_6911,
                              @b_Debug             = 0,
                              @b_Success           = @b_Success    OUTPUT,
                              @n_Err               = @nErrNo       OUTPUT,
                              @c_ErrMsg            = @cErrMsg      OUTPUT

                           IF @b_Success <> 1
                           BEGIN
                              SET @nErrNo = 268662
                              SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --QCmdFail
                              GOTO Scn_6911_Fail
                           END
                        END
                     END
                  END

                  -- Recalculate counters after update
                  -- FCR-13167: RDTPPA.DropID = LabelNo (after conversion for SUO)
                  SELECT @nSKUCounted = ISNULL(SUM(CQty), 0)
                  FROM rdt.RDTPPA WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cDropID
                     AND SKU = @cSKU

                  -- FCR-13167: @nCtnSKUCounted needs JOIN for SUO to count all SKUs in ToteID
                  IF @cSingleUnitOrdFlag = 'Y'
                     SELECT @nCtnSKUCounted = COUNT(DISTINCT PPA.SKU)
                     FROM dbo.PackDetail PD WITH (NOLOCK)
                     INNER JOIN rdt.RDTPPA PPA WITH (NOLOCK)
                        ON PD.StorerKey = PPA.StorerKey
                        AND PD.LabelNo = PPA.DropID
                        AND PD.SKU = PPA.SKU
                     WHERE PD.StorerKey = @cStorerKey
                        AND PD.DropID = @cToteID
                        AND PPA.CQty > 0
                  ELSE
                     SELECT @nCtnSKUCounted = COUNT(DISTINCT SKU)
                     FROM rdt.RDTPPA WITH (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND DropID = @cDropID
                        AND CQty > 0

                  -- Clear saved SKU for next scan (will be saved to RDTMOBREC at Quit)
                  SET @cSavedSKU = ''
                  -- Note: Keep @nSKUTotal for display, it will be saved to RDTMOBREC at Quit

                  -- Display scanned SKU info and prepare for next scan
                  SET @cOutField01 = '' -- Clear SKU for next scan
                  SET @cOutField02 = @cPPADefaultQTY -- Reset QTY to default
                  SET @cOutField03 = @cSKU -- Scanned SKU
                  SET @cOutField04 = LEFT(ISNULL(@cSKUDescr1, ''), 20) -- Style/Color/Size
                  SET @cOutField05 = LEFT(ISNULL(@cSKUDescr2, ''), 20) -- Description

                  -- If DisableQTYField='1', set QTY field to output only
                  IF @cDisableQTYField = '1'
                     SET @cFieldAttr02 = 'O'
               END

               -- FCR-13167: Call ExtendedUpdateSP for VAS label printing after SKU scan
               -- Pass @cOption = '' to indicate SKU scan (vs 'M'/'A' for print)
               IF @cExtendedUpdateSP <> ''
               BEGIN
                  IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedUpdateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, ' +
                        ' @cSKU, @nQty, @cOption, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey, @cReasonCode OUTPUT'
                     SET @cSQLParam =
                        '@nMobile         INT,           ' +
                        '@nFunc           INT,           ' +
                        '@cLangCode       NVARCHAR(3),   ' +
                        '@nStep           INT,           ' +
                        '@nInputKey       INT,           ' +
                        '@cStorerKey      NVARCHAR(15),  ' +
                        '@cRefNo          NVARCHAR(10),  ' +
                        '@cPickSlipNo     NVARCHAR(10),  ' +
                        '@cLoadKey        NVARCHAR(10),  ' +
                        '@cOrderKey       NVARCHAR(10),  ' +
                        '@cDropID         NVARCHAR(20),  ' +
                        '@cSKU            NVARCHAR(20),  ' +
                        '@nQty            INT,           ' +
                        '@cOption         NVARCHAR(1),   ' +
                        '@nErrNo          INT OUTPUT,    ' +
                        '@cErrMsg         NVARCHAR(20) OUTPUT, ' +
                        '@cID             NVARCHAR(18),  ' +
                        '@cTaskDetailKey  NVARCHAR(10),  ' +
                        '@cReasonCode     NVARCHAR(20) OUTPUT '
                     -- @cOption = '' indicates SKU scan for VAS printing
                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, @cSKU, @nQty, @cOption,
                        @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey, @cReasonCode OUTPUT
                     IF @nErrNo <> 0
                        GOTO Scn_6911_Rollback -- FCR-13167: Rollback RDTPPA if VAS print fails
                  END
               END

               -- FCR-13167: Commit SKU scan transaction (RDTPPA + VAS print succeeded)
               -- Only commit if this SP started the transaction
               WHILE @@TRANCOUNT>@nTranCount
                  COMMIT TRAN Scn_6911_Tran


               -- Get CTN SKU Total from PackDetail (per requirement) - FCR-13167 uses UDF27
               -- @nCtnSKUTotal already loaded from RDTMOBREC C_String9ji
               IF @nCtnSKUTotal = 0
               BEGIN
                  -- FCR-13167: SUO uses ToteID, Normal uses LabelNo
                  IF @cSingleUnitOrdFlag = 'Y'
                     SELECT @nCtnSKUTotal = COUNT(DISTINCT SKU)
                     FROM dbo.PackDetail WITH (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND DropID = @cToteID
                  ELSE
                     SELECT @nCtnSKUTotal = COUNT(DISTINCT SKU)
                     FROM dbo.PackDetail WITH (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND LabelNo = @cDropID
               END

               -- @nTotalQtyExpected already loaded from RDTMOBREC C_String9
               -- FCR-13167: @nTotalQtyCKD needs JOIN for SUO
               IF @cSingleUnitOrdFlag = 'Y'
                  SELECT @nTotalQtyCKD = ISNULL(SUM(PPA.CQty), 0)
                  FROM dbo.PackDetail PD WITH (NOLOCK)
                  INNER JOIN rdt.RDTPPA PPA WITH (NOLOCK)
                     ON PD.StorerKey = PPA.StorerKey
                     AND PD.LabelNo = PPA.DropID
                     AND PD.SKU = PPA.SKU
                  WHERE PD.StorerKey = @cStorerKey
                     AND PD.DropID = @cToteID
               ELSE
                  SELECT @nTotalQtyCKD = ISNULL(SUM(CQty), 0)
                  FROM rdt.RDTPPA WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey AND DropID = @cDropID

               -- Update output fields
               -- d06=SKU Ctd, d07=CTN/SKU, d08=TOTAL, d09=QTY CKD, d10-d14=VAS1-5
               SET @cOutField06 = CAST(ISNULL(@nSKUCounted, 0) AS NVARCHAR(5)) -- SKU Counted
               SET @cOutField07 = CAST(ISNULL(@nCtnSKUCounted, 0) AS NVARCHAR(5)) + '/' + CAST(ISNULL(@nCtnSKUTotal, 0) AS NVARCHAR(5)) -- CTN/SKU (X/Y)
               SET @cOutField08 = CAST(ISNULL(@nSKUTotal, 0) AS NVARCHAR(5)) -- TOTAL (SKU Total for current SKU)
               SET @cOutField09 = CAST(ISNULL(@nTotalQtyCKD, 0) AS NVARCHAR(5)) + '/' + CAST(ISNULL(@nTotalQtyExpected, 0) AS NVARCHAR(5)) -- QTY CKD (X/Y)
               SET @cOutField10 = @cVASDisplay1 -- VAS1
               SET @cOutField11 = @cVASDisplay2 -- VAS2
               SET @cOutField12 = @cVASDisplay3 -- VAS3
               SET @cOutField13 = @cVASDisplay4 -- VAS4
               SET @cOutField14 = @cVASDisplay5 -- VAS5

               -- FCR-13167: SUO vs Normal Order completion logic
               -- @cDropID is already converted to LabelNo for SUO at function entry
               -- SUO: Each scan = different CaseID (LabelNo), trigger print per CaseID completion
               -- Normal Order: All scans = same CaseID, trigger print when all SKUs complete

               IF @cSingleUnitOrdFlag = 'Y'
               BEGIN
                  -- SUO: Each SKU scan = 1 CaseID complete (1 order = 1 SKU = 1 qty)
                  -- Show Packing Complete message for this CaseID
                  SET @nErrNo = 268663
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Packing Complete
                  SET @nErrNo = 0

                  -- FCR-13167: Print control
                  IF @cPrintControl = '1'
                  BEGIN
                     -- Auto print: skip screen, execute print logic directly
                     -- Determine print option: automation order (Wave.UserDefine09='Y') = 'A', else = 'M'
                     -- @cDropID is now LabelNo = CaseID for SUO
                     IF EXISTS (
                        SELECT 1
                        FROM dbo.ORDERS ord WITH (NOLOCK)
                        INNER JOIN dbo.PickDetail pd WITH (NOLOCK) ON ord.OrderKey = pd.OrderKey
                        INNER JOIN dbo.Wave w WITH (NOLOCK) ON ord.UserDefine09 = w.WaveKey
                        WHERE ord.StorerKey = @cStorerKey
                           AND pd.StorerKey = @cStorerKey
                           AND pd.CaseID = @cDropID
                           AND w.UserDefine09 = 'Y'
                     )
                        SET @cOption = 'A' -- Automation
                     ELSE
                        SET @cOption = 'M' -- Manual

                     GOTO PRINT_LABEL
                  END

                  -- FCR-13139: Show Packing Complete message and stay on scn 6911
                  SET @nErrNo = 268663
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Packing Complete
                  SET @nErrNo = 0
                  SET @cOutField01 = '' -- Clear SKU for next scan
                  SET @nAfterScn = 6911
                  SET @nAfterStep = 99
               END
               ELSE
               BEGIN
                  -- Normal Order: All scans = same CaseID
                  -- Check if all SKUs in carton are fully counted
                  -- @cDropID = LabelNo for both SUO and Normal
                  IF NOT EXISTS (
                     SELECT 1 FROM dbo.PackDetail PD WITH (NOLOCK)
                     LEFT JOIN rdt.RDTPPA PPA WITH (NOLOCK)
                        ON PD.StorerKey = PPA.StorerKey
                        AND PD.LabelNo = PPA.DropID
                        AND PD.SKU = PPA.SKU
                     WHERE PD.StorerKey = @cStorerKey
                        AND PD.LabelNo = @cDropID
                        AND (PPA.CQty IS NULL OR PPA.CQty < PD.Qty)
                  )
                  BEGIN
                     -- All SKUs complete - trigger completion
                     SET @nErrNo = 268663
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Packing Complete
                     SET @nErrNo = 0

                     -- FCR-13167: Print control
                     IF @cPrintControl = '1'
                     BEGIN
                        -- Auto print: skip screen, execute print logic directly
                        -- Determine print option: automation order (Wave.UserDefine09='Y') = 'A', else = 'M'
                        IF EXISTS (
                           SELECT 1
                           FROM dbo.ORDERS ord WITH (NOLOCK)
                           INNER JOIN dbo.PickDetail pd WITH (NOLOCK) ON ord.OrderKey = pd.OrderKey
                           INNER JOIN dbo.Wave w WITH (NOLOCK) ON ord.UserDefine09 = w.WaveKey
                           WHERE ord.StorerKey = @cStorerKey
                              AND pd.StorerKey = @cStorerKey
                              AND pd.CaseID = @cDropID
                              AND w.UserDefine09 = 'Y'
                        )
                           SET @cOption = 'A' -- Automation
                        ELSE
                           SET @cOption = 'M' -- Manual

                        GOTO PRINT_LABEL
                     END
                     ELSE
                     BEGIN
                        -- FCR-13139: PrintControl ≠ '1' - stay on 6911, user must ESC or Empty Enter to print
                        SET @nAfterScn = 6911
                        SET @nAfterStep = 99
                     END
                  END
                  ELSE
                  BEGIN
                     -- Not complete - stay on scn 6911
                     SET @nAfterScn = 6911
                     SET @nAfterStep = 99
                  END
               END

            END

            IF @nInputKey = 0 -- ESC - Show discrepancy screen
            BEGIN
               -- FCR-13167: Check for discrepancies and show discrepancy screen
               -- @cPickSlipNo already loaded from RDTMOBREC C_String5

               -- Get discrepancies sorted by highest discrepancy first
               DECLARE @tDiscrepancy TABLE (
                  RowNum INT,
                  SKU NVARCHAR(20),
                  Counted INT,
                  Expected INT,
                  Discrepancy INT
               )

               -- FCR-13167: SUO uses ToteID (PackDetail.DropID), Normal uses LabelNo
               -- RDTPPA.DropID = LabelNo for both
               INSERT INTO @tDiscrepancy (RowNum, SKU, Counted, Expected, Discrepancy)
               SELECT
                  ROW_NUMBER() OVER (ORDER BY (PD.Qty - ISNULL(PPA.CQty, 0)) DESC) AS RowNum,
                  PD.SKU,
                  ISNULL(PPA.CQty, 0) AS Counted,
                  PD.Qty AS Expected,
                  (PD.Qty - ISNULL(PPA.CQty, 0)) AS Discrepancy
               FROM dbo.PackDetail PD WITH (NOLOCK)
               LEFT JOIN rdt.RDTPPA PPA WITH (NOLOCK)
                  ON PD.StorerKey = PPA.StorerKey
                  AND PD.LabelNo = PPA.DropID
                  AND PD.SKU = PPA.SKU
               WHERE PD.StorerKey = @cStorerKey
                  AND ((@cSingleUnitOrdFlag = 'Y' AND PD.DropID = @cToteID) OR (@cSingleUnitOrdFlag <> 'Y' AND PD.LabelNo = @cDropID))
                  AND (PPA.CQty IS NULL OR PPA.CQty < PD.Qty)

               DECLARE @nDiscTotal INT = 0
               SELECT @nDiscTotal = COUNT(*) FROM @tDiscrepancy

               IF @nDiscTotal > 0
               BEGIN
                  -- Populate discrepancy screen fields (5 SKUs per page, starting from row 1)
                  SET @nDiscOffset = 0 -- First page starts at 0
                  DECLARE @cDiscSKU1 NVARCHAR(20), @nDiscCounted1 INT, @nDiscExpected1 INT
                  DECLARE @cDiscSKU2 NVARCHAR(20), @nDiscCounted2 INT, @nDiscExpected2 INT
                  DECLARE @cDiscSKU3 NVARCHAR(20), @nDiscCounted3 INT, @nDiscExpected3 INT
                  DECLARE @cDiscSKU4 NVARCHAR(20), @nDiscCounted4 INT, @nDiscExpected4 INT
                  DECLARE @cDiscSKU5 NVARCHAR(20), @nDiscCounted5 INT, @nDiscExpected5 INT

                  SELECT @cDiscSKU1 = SKU, @nDiscCounted1 = Counted, @nDiscExpected1 = Expected
                  FROM @tDiscrepancy WHERE RowNum = 1
                  SELECT @cDiscSKU2 = SKU, @nDiscCounted2 = Counted, @nDiscExpected2 = Expected
                  FROM @tDiscrepancy WHERE RowNum = 2
                  SELECT @cDiscSKU3 = SKU, @nDiscCounted3 = Counted, @nDiscExpected3 = Expected
                  FROM @tDiscrepancy WHERE RowNum = 3
                  SELECT @cDiscSKU4 = SKU, @nDiscCounted4 = Counted, @nDiscExpected4 = Expected
                  FROM @tDiscrepancy WHERE RowNum = 4
                  SELECT @cDiscSKU5 = SKU, @nDiscCounted5 = Counted, @nDiscExpected5 = Expected
                  FROM @tDiscrepancy WHERE RowNum = 5

                  -- Set output fields for scn 6914 (5 SKUs per page, combined Counted/Expected)
                  SET @cOutField01 = @cDropID -- CARTON ID
                  SET @cOutField02 = ISNULL(@cDiscSKU1, '') -- SKU 1
                  SET @cOutField03 = CASE WHEN @cDiscSKU1 IS NOT NULL THEN CAST(@nDiscCounted1 AS NVARCHAR(5)) + '/' + CAST(@nDiscExpected1 AS NVARCHAR(5)) ELSE '' END
                  SET @cOutField04 = ISNULL(@cDiscSKU2, '') -- SKU 2
                  SET @cOutField05 = CASE WHEN @cDiscSKU2 IS NOT NULL THEN CAST(@nDiscCounted2 AS NVARCHAR(5)) + '/' + CAST(@nDiscExpected2 AS NVARCHAR(5)) ELSE '' END
                  SET @cOutField06 = ISNULL(@cDiscSKU3, '') -- SKU 3
                  SET @cOutField07 = CASE WHEN @cDiscSKU3 IS NOT NULL THEN CAST(@nDiscCounted3 AS NVARCHAR(5)) + '/' + CAST(@nDiscExpected3 AS NVARCHAR(5)) ELSE '' END
                  SET @cOutField08 = ISNULL(@cDiscSKU4, '') -- SKU 4
                  SET @cOutField09 = CASE WHEN @cDiscSKU4 IS NOT NULL THEN CAST(@nDiscCounted4 AS NVARCHAR(5)) + '/' + CAST(@nDiscExpected4 AS NVARCHAR(5)) ELSE '' END
                  SET @cOutField10 = ISNULL(@cDiscSKU5, '') -- SKU 5
                  SET @cOutField11 = CASE WHEN @cDiscSKU5 IS NOT NULL THEN CAST(@nDiscCounted5 AS NVARCHAR(5)) + '/' + CAST(@nDiscExpected5 AS NVARCHAR(5)) ELSE '' END
                  -- d12 = 'ENTER=MORE' if more pages, empty if only one page
                  SET @cOutField12 = CASE WHEN @nDiscTotal > 5 THEN 'ENTER=MORE' ELSE '' END

                  -- @nDiscOffset already set to 0 above, will be saved to RDTMOBREC at Quit

                  -- Go to Discrepancy screen (6914)
                  SET @nAfterScn = 6914
                  SET @nAfterStep = 99
               END
               ELSE
               BEGIN
                  -- FCR-13139: No discrepancy - all complete, already printed when last SKU scanned
                  -- Return to scn 814 (same as completing the carton)
                  SET @cOutField01 = ''
                  SET @cOutField02 = ''
                  SET @cOutField03 = ''
                  SET @cOutField04 = ''
                  SET @cOutField05 = ''
                  SET @cOutField06 = ''
                  SET @cOutField07 = ''

                  -- Enable disable field
                  SET @cFieldAttr01 = 'O' --RefNo
                  SET @cFieldAttr02 = 'O' --PickSlipNo
                  SET @cFieldAttr03 = 'O' --LoadKey
                  SET @cFieldAttr04 = 'O' --OrderKey
                  SET @cFieldAttr05 = ''
                  SET @cFieldAttr06 = 'O' --ID
                  SET @cFieldAttr07 = 'O' --TaskDetailKey

                  SET @nAfterScn = 814
                  SET @nAfterStep = 99
               END
               GOTO Quit
            END

            GOTO Quit

            Scn_6911_Rollback:
            ROLLBACK TRAN Scn_6911_Tran

            Scn_6911_Fail:
               SET @cOutField01 = '' -- Clear SKU display on error
               -- Keep VAS display (VAS codes already loaded from RDTMOBREC)
               SET @cVASDisplay1 = ISNULL(@cVASCode1, '') + CASE WHEN ISNULL(@cVASCode1, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc1, ''), 40) ELSE '' END
               SET @cVASDisplay2 = ISNULL(@cVASCode2, '') + CASE WHEN ISNULL(@cVASCode2, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc2, ''), 40) ELSE '' END
               SET @cVASDisplay3 = ISNULL(@cVASCode3, '') + CASE WHEN ISNULL(@cVASCode3, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc3, ''), 40) ELSE '' END
               SET @cVASDisplay4 = ISNULL(@cVASCode4, '') + CASE WHEN ISNULL(@cVASCode4, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc4, ''), 40) ELSE '' END
               SET @cVASDisplay5 = ISNULL(@cVASCode5, '') + CASE WHEN ISNULL(@cVASCode5, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc5, ''), 40) ELSE '' END
               SET @cOutField10 = @cVASDisplay1
               SET @cOutField11 = @cVASDisplay2
               SET @cOutField12 = @cVASDisplay3
               SET @cOutField13 = @cVASDisplay4
               SET @cOutField14 = @cVASDisplay5
               -- FCR-13167: Must set @nAfterScn/@nAfterStep to stay on screen 6911 on error
               SET @nAfterScn = 6911
               SET @nAfterStep = 99
               GOTO Quit
         END -- Scn 6911


      ELSE IF @nScn = 6914
      /********************************************************************************
      Step 99. Scn = 6914. SC5: Discrepancy display screen (FCR-13167)
         Display up to 5 SKUs per page, sorted by highest discrepancy first
         Enter = next page (if more), ESC = options screen (6914)
      ********************************************************************************/
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Executing St99, Scn6914 - SC5 Discrepancy (FCR-13167)'

         IF @nInputKey = 1 -- Enter - Next page (if more discrepancies)
         BEGIN
            -- @nDiscOffset already loaded from RDTMOBREC at start

            -- Query discrepancies to get total count and data
            -- FCR-13167: SUO uses ToteID (PackDetail.DropID), Normal uses LabelNo
            DECLARE @tDisc6915 TABLE (RowNum INT, SKU NVARCHAR(20), Counted INT, Expected INT)
            INSERT INTO @tDisc6915 (RowNum, SKU, Counted, Expected)
            SELECT
               ROW_NUMBER() OVER (ORDER BY (PD.Qty - ISNULL(PPA.CQty, 0)) DESC) AS RowNum,
               PD.SKU,
               ISNULL(PPA.CQty, 0) AS Counted,
               PD.Qty AS Expected
            FROM dbo.PackDetail PD WITH (NOLOCK)
            LEFT JOIN rdt.RDTPPA PPA WITH (NOLOCK)
               ON PD.StorerKey = PPA.StorerKey
               AND PD.LabelNo = PPA.DropID
               AND PD.SKU = PPA.SKU
            WHERE PD.StorerKey = @cStorerKey
               AND ((@cSingleUnitOrdFlag = 'Y' AND PD.DropID = @cToteID) OR (@cSingleUnitOrdFlag <> 'Y' AND PD.LabelNo = @cDropID))
               AND (PPA.CQty IS NULL OR PPA.CQty < PD.Qty)

            DECLARE @nDiscTotal_6915 INT
            SELECT @nDiscTotal_6915 = COUNT(*) FROM @tDisc6915

            -- If only one page, Enter does nothing (stay on current screen)
            IF @nDiscTotal_6915 <= 5
            BEGIN
               -- Only one page - stay on current screen, d12 remains empty
               SET @nAfterScn = 6914
               SET @nAfterStep = 99
               GOTO Quit
            END

            -- Check if more pages exist
            IF @nDiscOffset + 5 < @nDiscTotal_6915
            BEGIN
               -- Move to next page
               SET @nDiscOffset = @nDiscOffset + 5

               -- Get 5 SKUs for this page
               DECLARE @cDS1 NVARCHAR(20), @nDC1 INT, @nDE1 INT
               DECLARE @cDS2 NVARCHAR(20), @nDC2 INT, @nDE2 INT
               DECLARE @cDS3 NVARCHAR(20), @nDC3 INT, @nDE3 INT
               DECLARE @cDS4 NVARCHAR(20), @nDC4 INT, @nDE4 INT
               DECLARE @cDS5 NVARCHAR(20), @nDC5 INT, @nDE5 INT

               SELECT @cDS1 = SKU, @nDC1 = Counted, @nDE1 = Expected FROM @tDisc6915 WHERE RowNum = @nDiscOffset + 1
               SELECT @cDS2 = SKU, @nDC2 = Counted, @nDE2 = Expected FROM @tDisc6915 WHERE RowNum = @nDiscOffset + 2
               SELECT @cDS3 = SKU, @nDC3 = Counted, @nDE3 = Expected FROM @tDisc6915 WHERE RowNum = @nDiscOffset + 3
               SELECT @cDS4 = SKU, @nDC4 = Counted, @nDE4 = Expected FROM @tDisc6915 WHERE RowNum = @nDiscOffset + 4
               SELECT @cDS5 = SKU, @nDC5 = Counted, @nDE5 = Expected FROM @tDisc6915 WHERE RowNum = @nDiscOffset + 5

               -- Set output fields (combined Counted/Expected)
               SET @cOutField01 = @cDropID
               SET @cOutField02 = ISNULL(@cDS1, '')
               SET @cOutField03 = CASE WHEN @cDS1 IS NOT NULL THEN CAST(@nDC1 AS NVARCHAR(5)) + '/' + CAST(@nDE1 AS NVARCHAR(5)) ELSE '' END
               SET @cOutField04 = ISNULL(@cDS2, '')
               SET @cOutField05 = CASE WHEN @cDS2 IS NOT NULL THEN CAST(@nDC2 AS NVARCHAR(5)) + '/' + CAST(@nDE2 AS NVARCHAR(5)) ELSE '' END
               SET @cOutField06 = ISNULL(@cDS3, '')
               SET @cOutField07 = CASE WHEN @cDS3 IS NOT NULL THEN CAST(@nDC3 AS NVARCHAR(5)) + '/' + CAST(@nDE3 AS NVARCHAR(5)) ELSE '' END
               SET @cOutField08 = ISNULL(@cDS4, '')
               SET @cOutField09 = CASE WHEN @cDS4 IS NOT NULL THEN CAST(@nDC4 AS NVARCHAR(5)) + '/' + CAST(@nDE4 AS NVARCHAR(5)) ELSE '' END
               SET @cOutField10 = ISNULL(@cDS5, '')
               SET @cOutField11 = CASE WHEN @cDS5 IS NOT NULL THEN CAST(@nDC5 AS NVARCHAR(5)) + '/' + CAST(@nDE5 AS NVARCHAR(5)) ELSE '' END
               -- d12 = 'ENTER=MORE' if more pages, 'ENTER=BACK' if last page (but more than 1 page total)
               SET @cOutField12 = CASE WHEN @nDiscOffset + 5 < @nDiscTotal_6915 THEN 'ENTER=MORE' ELSE 'ENTER=BACK' END

               -- @nDiscOffset will be saved to RDTMOBREC at Quit

               SET @nAfterScn = 6914
               SET @nAfterStep = 99
               GOTO Quit
            END
            ELSE
            BEGIN
               -- Last page reached, wrap around to first page
               SET @nDiscOffset = 0

               -- Get 5 SKUs for first page
               DECLARE @cDS1_W NVARCHAR(20), @nDC1_W INT, @nDE1_W INT
               DECLARE @cDS2_W NVARCHAR(20), @nDC2_W INT, @nDE2_W INT
               DECLARE @cDS3_W NVARCHAR(20), @nDC3_W INT, @nDE3_W INT
               DECLARE @cDS4_W NVARCHAR(20), @nDC4_W INT, @nDE4_W INT
               DECLARE @cDS5_W NVARCHAR(20), @nDC5_W INT, @nDE5_W INT

               SELECT @cDS1_W = SKU, @nDC1_W = Counted, @nDE1_W = Expected FROM @tDisc6915 WHERE RowNum = 1
               SELECT @cDS2_W = SKU, @nDC2_W = Counted, @nDE2_W = Expected FROM @tDisc6915 WHERE RowNum = 2
               SELECT @cDS3_W = SKU, @nDC3_W = Counted, @nDE3_W = Expected FROM @tDisc6915 WHERE RowNum = 3
               SELECT @cDS4_W = SKU, @nDC4_W = Counted, @nDE4_W = Expected FROM @tDisc6915 WHERE RowNum = 4
               SELECT @cDS5_W = SKU, @nDC5_W = Counted, @nDE5_W = Expected FROM @tDisc6915 WHERE RowNum = 5

               -- Set output fields (combined Counted/Expected)
               SET @cOutField01 = @cDropID
               SET @cOutField02 = ISNULL(@cDS1_W, '')
               SET @cOutField03 = CASE WHEN @cDS1_W IS NOT NULL THEN CAST(@nDC1_W AS NVARCHAR(5)) + '/' + CAST(@nDE1_W AS NVARCHAR(5)) ELSE '' END
               SET @cOutField04 = ISNULL(@cDS2_W, '')
               SET @cOutField05 = CASE WHEN @cDS2_W IS NOT NULL THEN CAST(@nDC2_W AS NVARCHAR(5)) + '/' + CAST(@nDE2_W AS NVARCHAR(5)) ELSE '' END
               SET @cOutField06 = ISNULL(@cDS3_W, '')
               SET @cOutField07 = CASE WHEN @cDS3_W IS NOT NULL THEN CAST(@nDC3_W AS NVARCHAR(5)) + '/' + CAST(@nDE3_W AS NVARCHAR(5)) ELSE '' END
               SET @cOutField08 = ISNULL(@cDS4_W, '')
               SET @cOutField09 = CASE WHEN @cDS4_W IS NOT NULL THEN CAST(@nDC4_W AS NVARCHAR(5)) + '/' + CAST(@nDE4_W AS NVARCHAR(5)) ELSE '' END
               SET @cOutField10 = ISNULL(@cDS5_W, '')
               SET @cOutField11 = CASE WHEN @cDS5_W IS NOT NULL THEN CAST(@nDC5_W AS NVARCHAR(5)) + '/' + CAST(@nDE5_W AS NVARCHAR(5)) ELSE '' END
               -- d12 = 'ENTER=MORE' when wrapped back to first page (multiple pages exist)
               SET @cOutField12 = 'ENTER=MORE'

               -- @nDiscOffset (=0) will be saved to RDTMOBREC at Quit

               SET @nAfterScn = 6914
               SET @nAfterStep = 99
               GOTO Quit
            END
         END

         IF @nInputKey = 0 -- ESC - Go to options screen (6915 - Discrepancy Options)
         BEGIN
            -- Set output fields for scn 6915
            SET @cOutField01 = @cDropID -- CARTON ID
            SET @cOutField02 = '' -- Option input


            SELECT
               @cFieldAttr01  =  '',
               @cFieldAttr02  =  '',
               @cFieldAttr03  =  '',
               @cFieldAttr04  =  '',
               @cFieldAttr05  =  '',
               @cFieldAttr06  =  '',
               @cFieldAttr07  =  '',
               @cFieldAttr08  =  '',
               @cFieldAttr09  =  '',
               @cFieldAttr10  =  ''

            SET @nAfterScn = 6915
            SET @nAfterStep = 99
            GOTO Quit
         END
      END -- Scn 6914


      ELSE IF @nScn = 6915
      /********************************************************************************
      Step 99. Scn = 6915. SC6: Discrepancy Options screen (FCR-13167)
         Options: 1 = SEND TO QC PRINT LBL, 3 = CONTINUE PACKING
      ********************************************************************************/
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Executing St99, Scn6915 - SC6 Discrepancy Options (FCR-13167)'

         IF @nInputKey = 1 -- Enter
         BEGIN
            SET @cOption = @cInField02

            -- FCR-6657: If from 814 (WorkOrder qty mismatch), only option 1 is allowed
            IF @cFrom814Flag = 'Y' AND @cOption <> '1'
            BEGIN
               SET @nErrNo = 273309
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Only option 1 allowed
               SET @nAfterScn = 6915
               SET @nAfterStep = 99
               GOTO Quit
            END

            IF @cOption = '1' -- Send to QC and Print Label
            BEGIN
               -- FCR-13167: Print QC Label
               SELECT @cLabelName = RDT.RDTGetConfig(@nFunc, 'LVSQALABEL', @cStorerKey)
               IF @cLabelName = '0'
                  SET @cLabelName = ''

               IF @cLabelName <> ''
               BEGIN
                  DECLARE @tQCLabelList VariableTable
                  INSERT INTO @tQCLabelList (Variable, Value)
                  VALUES ('@cLabelNo', @cDropID)

                  -- Print QC label
                  EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinterGroup, @cPaperPrinter,
                     @cLabelName, -- Report type
                     @tQCLabelList, -- Report params
                     'rdt_855ExtScn05',
                     @nErrNo  OUTPUT,
                     @cErrMsg OUTPUT

                  IF @nErrNo <> 0
                     GOTO Quit
               END

               -- Go back to SC1 for next carton
               SET @cDropID = ''
               SET @cOrderKey = ''
               SET @cPickSlipNo = ''
               SET @cOutField01 = ''
               SET @cOutField02 = ''
               SET @cOutField03 = ''
               SET @cOutField04 = ''
               SET @cOutField05 = ''
               SET @cOutField06 = ''
               SET @cOutField07 = ''

               -- Enable disable field
               SET @cFieldAttr01 = 'O' --RefNo
               SET @cFieldAttr02 = 'O' --PickSlipNo
               SET @cFieldAttr03 = 'O' --LoadKey
               SET @cFieldAttr04 = 'O' --OrderKey
               SET @cFieldAttr05 = ''
               SET @cFieldAttr06 = 'O' --ID
               SET @cFieldAttr07 = 'O' --TaskDetailKey

               -- FCR-6657: Clear flag when returning to 814
               SET @cFrom814Flag = 'N'

               SET @nAfterScn = 814
               SET @nAfterStep = 99
               GOTO Quit
            END

            IF @cOption = '3' -- Continue Packing
            BEGIN
               -- Go back to SC2 (6911) with current carton count status
               -- Reload counters from RDTPPA
               DECLARE @nCtnSKUCounted_Cont INT, @nCtnSKUTotal_Cont INT
               DECLARE @nTotalQtyCKD_Cont INT, @nTotalQtyExpected_Cont INT

               -- Get CTN SKU Total from PackDetail
               -- FCR-13167: SUO uses ToteID, Normal uses LabelNo
               IF @cSingleUnitOrdFlag = 'Y'
                  SELECT @nCtnSKUTotal_Cont = COUNT(DISTINCT SKU)
                  FROM dbo.PackDetail WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cToteID
               ELSE
                  SELECT @nCtnSKUTotal_Cont = COUNT(DISTINCT SKU)
                  FROM dbo.PackDetail WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND LabelNo = @cDropID

               -- Get counted values from RDTPPA
               -- FCR-13167: RDTPPA.DropID = LabelNo, need JOIN for SUO
               IF @cSingleUnitOrdFlag = 'Y'
                  SELECT @nCtnSKUCounted_Cont = COUNT(DISTINCT PPA.SKU),
                         @nTotalQtyCKD_Cont = ISNULL(SUM(PPA.CQty), 0)
                  FROM dbo.PackDetail PD WITH (NOLOCK)
                  INNER JOIN rdt.RDTPPA PPA WITH (NOLOCK)
                     ON PD.StorerKey = PPA.StorerKey
                     AND PD.LabelNo = PPA.DropID
                     AND PD.SKU = PPA.SKU
                  WHERE PD.StorerKey = @cStorerKey
                     AND PD.DropID = @cToteID
                     AND PPA.CQty > 0
               ELSE
                  SELECT @nCtnSKUCounted_Cont = COUNT(DISTINCT SKU),
                         @nTotalQtyCKD_Cont = ISNULL(SUM(CQty), 0)
                  FROM rdt.RDTPPA WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey AND DropID = @cDropID AND CQty > 0

               -- Get Total QTY Expected from PackDetail
               -- FCR-13167: SUO uses ToteID, Normal uses LabelNo
               IF @cSingleUnitOrdFlag = 'Y'
                  SELECT @nTotalQtyExpected_Cont = ISNULL(SUM(Qty), 0)
                  FROM dbo.PackDetail WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cToteID
               ELSE
                  SELECT @nTotalQtyExpected_Cont = ISNULL(SUM(Qty), 0)
                  FROM dbo.PackDetail WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND LabelNo = @cDropID

               -- Build VAS display strings (VAS codes stored in RDTMOBREC)
               DECLARE @cVASCode1_Cont NVARCHAR(10), @cVASDesc1_Cont NVARCHAR(50)
               DECLARE @cVASCode2_Cont NVARCHAR(10), @cVASDesc2_Cont NVARCHAR(50)
               DECLARE @cVASCode3_Cont NVARCHAR(10), @cVASDesc3_Cont NVARCHAR(50)
               DECLARE @cVASCode4_Cont NVARCHAR(10), @cVASDesc4_Cont NVARCHAR(50)
               DECLARE @cVASCode5_Cont NVARCHAR(10), @cVASDesc5_Cont NVARCHAR(50)
               DECLARE @cDisableQTYField_Cont NVARCHAR(1), @cPPADefaultQTY_Cont NVARCHAR(5)

               SELECT @cVASCode1_Cont = C_String8, @cVASDesc1_Cont = C_String9,
                      @cVASCode2_Cont = C_String10, @cVASDesc2_Cont = C_String11,
                      @cVASCode3_Cont = C_String12, @cVASDesc3_Cont = C_String13,
                      @cVASCode4_Cont = C_String14, @cVASDesc4_Cont = C_String15,
                      @cVASCode5_Cont = C_String16, @cVASDesc5_Cont = C_String17,
                      @cDisableQTYField_Cont = ISNULL(C_String22, '0'),
                      @cPPADefaultQTY_Cont = ISNULL(C_String23, '1')
               FROM RDT.RDTMOBREC WITH(NOLOCK) WHERE Mobile = @nMobile

               DECLARE @cVASDisplay1_Cont NVARCHAR(60), @cVASDisplay2_Cont NVARCHAR(60)
               DECLARE @cVASDisplay3_Cont NVARCHAR(60), @cVASDisplay4_Cont NVARCHAR(60)
               DECLARE @cVASDisplay5_Cont NVARCHAR(60)
               SET @cVASDisplay1_Cont = ISNULL(@cVASCode1_Cont, '') + CASE WHEN ISNULL(@cVASCode1_Cont, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc1_Cont, ''), 40) ELSE '' END
               SET @cVASDisplay2_Cont = ISNULL(@cVASCode2_Cont, '') + CASE WHEN ISNULL(@cVASCode2_Cont, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc2_Cont, ''), 40) ELSE '' END
               SET @cVASDisplay3_Cont = ISNULL(@cVASCode3_Cont, '') + CASE WHEN ISNULL(@cVASCode3_Cont, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc3_Cont, ''), 40) ELSE '' END
               SET @cVASDisplay4_Cont = ISNULL(@cVASCode4_Cont, '') + CASE WHEN ISNULL(@cVASCode4_Cont, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc4_Cont, ''), 40) ELSE '' END
               SET @cVASDisplay5_Cont = ISNULL(@cVASCode5_Cont, '') + CASE WHEN ISNULL(@cVASCode5_Cont, '') <> '' THEN ': ' + LEFT(ISNULL(@cVASDesc5_Cont, ''), 40) ELSE '' END

               -- Set output fields for scn 6911
               SET @cOutField01 = '' -- SKU input
               SET @cOutField02 = @cPPADefaultQTY_Cont -- QTY input
               SET @cOutField03 = '' -- Scanned SKU
               SET @cOutField04 = '' -- Style/Color/Size
               SET @cOutField05 = '' -- SKU Description
               SET @cOutField06 = '0' -- SKU Counted (no SKU selected)
               SET @cOutField07 = CAST(ISNULL(@nCtnSKUCounted_Cont, 0) AS NVARCHAR(5)) + '/' + CAST(ISNULL(@nCtnSKUTotal_Cont, 0) AS NVARCHAR(5)) -- CTN/SKU (X/Y)
               SET @cOutField08 = '0' -- TOTAL (no SKU selected)
               SET @cOutField09 = CAST(ISNULL(@nTotalQtyCKD_Cont, 0) AS NVARCHAR(5)) + '/' + CAST(ISNULL(@nTotalQtyExpected_Cont, 0) AS NVARCHAR(5)) -- QTY CKD (X/Y)
               SET @cOutField10 = @cVASDisplay1_Cont -- VAS1
               SET @cOutField11 = @cVASDisplay2_Cont -- VAS2
               SET @cOutField12 = @cVASDisplay3_Cont -- VAS3
               SET @cOutField13 = @cVASDisplay4_Cont -- VAS4
               SET @cOutField14 = @cVASDisplay5_Cont -- VAS5

               -- Disable QTY field if configured
               IF @cDisableQTYField_Cont = '1'
                  SET @cFieldAttr02 = 'O'

               SET @nAfterScn = 6911
               SET @nAfterStep = 99
               GOTO Quit
            END

            -- Invalid option
            SET @nErrNo = 268656
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Invalid option
            GOTO Quit
         END

         IF @nInputKey = 0 -- ESC - Go back to discrepancy screen with data reloaded
         BEGIN
            -- FCR-6657: If from 814 (WorkOrder qty mismatch), ESC is not allowed
            IF @cFrom814Flag = 'Y'
            BEGIN
               SET @nErrNo = 273309
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Only option 1 allowed
               SET @nAfterScn = 6915
               SET @nAfterStep = 99
               GOTO Quit
            END

            -- @nDiscOffset already loaded from RDTMOBREC at start

            -- Re-query discrepancies
            -- FCR-13167: SUO uses ToteID (PackDetail.DropID), Normal uses LabelNo
            DECLARE @tDiscESC TABLE (RowNum INT, SKU NVARCHAR(20), Counted INT, Expected INT)
            INSERT INTO @tDiscESC (RowNum, SKU, Counted, Expected)
            SELECT
               ROW_NUMBER() OVER (ORDER BY (PD.Qty - ISNULL(PPA.CQty, 0)) DESC) AS RowNum,
               PD.SKU,
               ISNULL(PPA.CQty, 0) AS Counted,
               PD.Qty AS Expected
            FROM dbo.PackDetail PD WITH (NOLOCK)
            LEFT JOIN rdt.RDTPPA PPA WITH (NOLOCK)
               ON PD.StorerKey = PPA.StorerKey
               AND PD.LabelNo = PPA.DropID
               AND PD.SKU = PPA.SKU
            WHERE PD.StorerKey = @cStorerKey
               AND ((@cSingleUnitOrdFlag = 'Y' AND PD.DropID = @cToteID) OR (@cSingleUnitOrdFlag <> 'Y' AND PD.LabelNo = @cDropID))
               AND (PPA.CQty IS NULL OR PPA.CQty < PD.Qty)

            DECLARE @nDiscTotal_ESC INT
            SELECT @nDiscTotal_ESC = COUNT(*) FROM @tDiscESC

            -- Get 5 SKUs for current page
            DECLARE @cDSE1 NVARCHAR(20), @nDCE1 INT, @nDEE1 INT
            DECLARE @cDSE2 NVARCHAR(20), @nDCE2 INT, @nDEE2 INT
            DECLARE @cDSE3 NVARCHAR(20), @nDCE3 INT, @nDEE3 INT
            DECLARE @cDSE4 NVARCHAR(20), @nDCE4 INT, @nDEE4 INT
            DECLARE @cDSE5 NVARCHAR(20), @nDCE5 INT, @nDEE5 INT

            SELECT @cDSE1 = SKU, @nDCE1 = Counted, @nDEE1 = Expected FROM @tDiscESC WHERE RowNum = @nDiscOffset + 1
            SELECT @cDSE2 = SKU, @nDCE2 = Counted, @nDEE2 = Expected FROM @tDiscESC WHERE RowNum = @nDiscOffset + 2
            SELECT @cDSE3 = SKU, @nDCE3 = Counted, @nDEE3 = Expected FROM @tDiscESC WHERE RowNum = @nDiscOffset + 3
            SELECT @cDSE4 = SKU, @nDCE4 = Counted, @nDEE4 = Expected FROM @tDiscESC WHERE RowNum = @nDiscOffset + 4
            SELECT @cDSE5 = SKU, @nDCE5 = Counted, @nDEE5 = Expected FROM @tDiscESC WHERE RowNum = @nDiscOffset + 5

            -- Populate output fields (combined Counted/Expected)
            SET @cOutField01 = @cDropID
            SET @cOutField02 = ISNULL(@cDSE1, '')
            SET @cOutField03 = CASE WHEN @cDSE1 IS NOT NULL THEN CAST(@nDCE1 AS NVARCHAR(5)) + '/' + CAST(@nDEE1 AS NVARCHAR(5)) ELSE '' END
            SET @cOutField04 = ISNULL(@cDSE2, '')
            SET @cOutField05 = CASE WHEN @cDSE2 IS NOT NULL THEN CAST(@nDCE2 AS NVARCHAR(5)) + '/' + CAST(@nDEE2 AS NVARCHAR(5)) ELSE '' END
            SET @cOutField06 = ISNULL(@cDSE3, '')
            SET @cOutField07 = CASE WHEN @cDSE3 IS NOT NULL THEN CAST(@nDCE3 AS NVARCHAR(5)) + '/' + CAST(@nDEE3 AS NVARCHAR(5)) ELSE '' END
            SET @cOutField08 = ISNULL(@cDSE4, '')
            SET @cOutField09 = CASE WHEN @cDSE4 IS NOT NULL THEN CAST(@nDCE4 AS NVARCHAR(5)) + '/' + CAST(@nDEE4 AS NVARCHAR(5)) ELSE '' END
            SET @cOutField10 = ISNULL(@cDSE5, '')
            SET @cOutField11 = CASE WHEN @cDSE5 IS NOT NULL THEN CAST(@nDCE5 AS NVARCHAR(5)) + '/' + CAST(@nDEE5 AS NVARCHAR(5)) ELSE '' END
            SET @cOutField12 = CASE WHEN @nDiscOffset + 5 < @nDiscTotal_ESC THEN '...' ELSE '' END

            SET @nAfterScn = 6914
            SET @nAfterStep = 99
            GOTO Quit
         END
      END -- Scn 6915

      ELSE IF @nScn = 6464
      /********************************************************************************
      Step 99. Scn = 6464. PRINT PACKING LIST? (FCR-13167)
         1 = YES (Print carton label)
         5 = Automation label and doc
         9 = NO
         OPTION: %01i01

         PRINT_LABEL is a GOTO target for auto-print (@cPrintControl='1')
         When called via GOTO, @cOption is already set by caller
      ********************************************************************************/
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Executing St99, Scn6464 - Print Pack List (FCR-13167)'

         -- Manual mode (screen refresh): validate option from screen input
         IF @nInputKey = 1
         BEGIN
            -- Screen mapping
            SET @cOption = @cInField01 -- Option

            -- Check option blank
            IF ISNULL(@cOption, '') = ''
            BEGIN
               SET @nErrNo = 60883
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- OptionRequired
               GOTO Quit
            END

            -- Check option valid
            IF @cOption NOT IN ('1', '5', '9')
            BEGIN
               SET @nErrNo = 60884
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Invalid Option
               GOTO Quit
            END
         END


         PRINT_LABEL:
         BEGIN
            -- FCR-13167: Save Packing Complete message before calling SPs (they use @cErrMsg as OUTPUT)
            DECLARE @cSavedErrMsg NVARCHAR(200) = @cErrMsg

            -- Call PPAPrintPackListSP if configured
            IF @cPPAPrintPackListSP <> ''
            BEGIN
               IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = @cPPAPrintPackListSP AND type = 'P')
               BEGIN
                  SET @cSQL = 'EXEC rdt.' + RTRIM(@cPPAPrintPackListSP) +
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, @cSKU, @nQTY, @cOption, @cType, ' +
                     ' @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey '
                  SET @cSQLParam =
                     '@nMobile         INT,           ' +
                     '@nFunc           INT,           ' +
                     '@cLangCode       NVARCHAR( 3),  ' +
                     '@nStep           INT,           ' +
                     '@nInputKey       INT,           ' +
                     '@cRefNo          NVARCHAR( 10), ' +
                     '@cPickSlipNo     NVARCHAR( 10), ' +
                     '@cLoadKey        NVARCHAR( 10), ' +
                     '@cOrderKey       NVARCHAR( 10), ' +
                     '@cDropID         NVARCHAR( 20), ' +
                     '@cSKU            NVARCHAR( 20), ' +
                     '@nQTY            INT,           ' +
                     '@cOption         NVARCHAR( 1),  ' +
                     '@cType           NVARCHAR( 10), ' +
                     '@nErrNo          INT           OUTPUT, ' +
                     '@cErrMsg         NVARCHAR( 20) OUTPUT, ' +
                     '@cID             NVARCHAR( 18), ' +
                     '@cTaskDetailKey  NVARCHAR( 10)  '

                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                     @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, @cSKU, @nQTY, @cOption, 'PRINT',
                     @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey

                  -- FCR-13167: If auto print fails, go to manual print screen
                  IF @nErrNo <> 0
                  BEGIN
                     SET @nAfterScn = 6464
                     GOTO Quit
                  END
               END
            END

            -- Call ExtendedUpdateSP for printing and transmitlog2
            IF @cExtendedUpdateSP <> ''
            BEGIN
               IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
               BEGIN
                  SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedUpdateSP) +
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, ' +
                     ' @cSKU, @nQty, @cOption, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey, @cReasonCode OUTPUT'
                  SET @cSQLParam =
                     '@nMobile         INT,       ' +
                     '@nFunc           INT,       ' +
                     '@cLangCode       NVARCHAR( 3),  ' +
                     '@nStep           INT,           ' +
                     '@nInputKey       INT,           ' +
                     '@cStorerKey      NVARCHAR( 15), ' +
                     '@cRefNo          NVARCHAR( 10), ' +
                     '@cPickSlipNo     NVARCHAR( 10), ' +
                     '@cLoadKey        NVARCHAR( 10), ' +
                     '@cOrderKey       NVARCHAR( 10), ' +
                     '@cDropID         NVARCHAR( 20), ' +
                     '@cSKU            NVARCHAR( 20), ' +
                     '@nQty            INT,           ' +
                     '@cOption         NVARCHAR( 1),  ' +
                     '@nErrNo          INT           OUTPUT, ' +
                     '@cErrMsg         NVARCHAR( 20) OUTPUT, ' +
                     '@cID             NVARCHAR( 18), ' +
                     '@cTaskDetailKey  NVARCHAR( 10), ' +
                     '@cReasonCode     NVARCHAR( 20)  OUTPUT'

                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                     @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, @cSKU, @nQty, @cOption,
                     @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey, @cReasonCode OUTPUT

                  -- FCR-13167: If auto print fails, go to manual print screen
                  IF @nErrNo <> 0
                  BEGIN
                     SET @nAfterScn = 6464
                     GOTO Quit
                  END
               END
            END

            -- FCR-13167: Restore Packing Complete message after SP calls
            IF ISNULL(@cSavedErrMsg, '') <> ''
               SET @cErrMsg = @cSavedErrMsg

            -- FCR-13139: Determine next screen based on option source
            -- @cOption in ('M', 'A') = auto print from code (GOTO PRINT_LABEL), stay on 6911
            -- @cOption in ('1', '5', '9') = manual print from scn 6464, go back to 814
            IF @cOption IN ('M', 'A')
            BEGIN
               -- Auto print from code - stay on scn 6911
               IF @cSingleUnitOrdFlag = 'Y'
               BEGIN
                  -- SUO: Check if there are more unpacked CaseIDs in the ToteID
                  IF EXISTS (
                     SELECT 1
                     FROM dbo.PackInfo PI WITH (NOLOCK)
                     INNER JOIN dbo.PackDetail PD WITH (NOLOCK)
                        ON PI.PickSlipNo = PD.PickSlipNo AND PI.CartonNo = PD.CartonNo
                     WHERE PD.StorerKey = @cStorerKey
                        AND PD.DropID = @cToteID
                        AND ISNULL(PI.CartonStatus, '') <> 'PACKED'
                  )
                  BEGIN
                     -- More CaseIDs to pack - go back to scn 6911 with full screen info
                     SELECT @nCtnSKUCounted = COUNT(DISTINCT PPA.SKU)
                     FROM dbo.PackDetail PD WITH (NOLOCK)
                     INNER JOIN rdt.RDTPPA PPA WITH (NOLOCK)
                        ON PD.StorerKey = PPA.StorerKey
                        AND PD.LabelNo = PPA.DropID
                        AND PD.SKU = PPA.SKU
                     WHERE PD.StorerKey = @cStorerKey
                        AND PD.DropID = @cToteID
                        AND PPA.CQty > 0

                     SELECT @nTotalQtyCKD = ISNULL(SUM(PPA.CQty), 0)
                     FROM dbo.PackDetail PD WITH (NOLOCK)
                     INNER JOIN rdt.RDTPPA PPA WITH (NOLOCK)
                        ON PD.StorerKey = PPA.StorerKey
                        AND PD.LabelNo = PPA.DropID
                        AND PD.SKU = PPA.SKU
                     WHERE PD.StorerKey = @cStorerKey
                        AND PD.DropID = @cToteID

                     -- Set output fields with last scanned SKU info
                     SET @cOutField01 = '' -- Clear SKU for next scan
                     SET @cOutField02 = @cPPADefaultQTY
                     SET @cOutField03 = @cSKU -- Last scanned SKU
                     SET @cOutField04 = LEFT(ISNULL(@cSKUDescr1, ''), 20) -- Style/Color/Size
                     SET @cOutField05 = LEFT(ISNULL(@cSKUDescr2, ''), 20) -- Description
                     SET @cOutField06 = CAST(ISNULL(@nSKUCounted, 0) AS NVARCHAR(5)) -- SKU Counted
                     SET @cOutField07 = CAST(ISNULL(@nCtnSKUCounted, 0) AS NVARCHAR(5)) + '/' + CAST(ISNULL(@nCtnSKUTotal, 0) AS NVARCHAR(5)) -- CTN/SKU (X/Y)
                     SET @cOutField08 = CAST(ISNULL(@nSKUTotal, 0) AS NVARCHAR(5)) -- TOTAL
                     SET @cOutField09 = CAST(ISNULL(@nTotalQtyCKD, 0) AS NVARCHAR(5)) + '/' + CAST(ISNULL(@nTotalQtyExpected, 0) AS NVARCHAR(5)) -- QTY CKD (X/Y)
                     SET @cOutField10 = @cVASDisplay1 -- VAS1
                     SET @cOutField11 = @cVASDisplay2 -- VAS2
                     SET @cOutField12 = @cVASDisplay3 -- VAS3
                     SET @cOutField13 = @cVASDisplay4 -- VAS4
                     SET @cOutField14 = @cVASDisplay5 -- VAS5

                     SET @nAfterScn = 6911
                     SET @nAfterStep = 99
                  END
                  ELSE
                  BEGIN
                     -- All CaseIDs packed (last scan) - stay on scn 6911 with Packing Complete message
                     SET @nErrNo = 268663
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Packing Complete
                     SET @nErrNo = 0
                     SET @cOutField01 = '' -- Clear SKU for next scan
                     SET @nAfterScn = 6911
                     SET @nAfterStep = 99
                  END
               END
               ELSE
               BEGIN
                  -- Normal Order - last scan, stay on scn 6911 with Packing Complete message
                  SET @nErrNo = 268663
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Packing Complete
                  SET @nErrNo = 0
                  SET @cOutField01 = '' -- Clear SKU for next scan
                  SET @nAfterScn = 6911
                  SET @nAfterStep = 99
               END
            END
            ELSE
            BEGIN
               -- Manual print from scn 6464 (option 1, 5, 9) - go back to scn 814
               SET @cDropID = ''
               SET @cOrderKey = ''
               SET @cPickSlipNo = ''
               SET @cOutField01 = ''
               SET @cOutField02 = ''
               SET @cOutField03 = ''
               SET @cOutField04 = ''
               SET @cOutField05 = ''
               SET @cOutField06 = ''
               SET @cOutField07 = ''

               -- Enable disable field
               SET @cFieldAttr01 = 'O' --RefNo
               SET @cFieldAttr02 = 'O' --PickSlipNo
               SET @cFieldAttr03 = 'O' --LoadKey
               SET @cFieldAttr04 = 'O' --OrderKey
               SET @cFieldAttr05 = ''
               SET @cFieldAttr06 = 'O' --ID
               SET @cFieldAttr07 = 'O' --TaskDetailKey

               SET @nAfterScn = 814
               SET @nAfterStep = 99
            END

            GOTO Quit
         END

         -- FCR-13167: No ESC handling - user must select an option on scn 6464
      END -- Scn 6464

      END -- step99

      -- fcr 1109: Entry point - redirect to FCR-13167 flow when config is set
      IF @nStep IN (0, 2, 4, 5, 8)
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @nStep IN (0, 4, 5, 8)
            BEGIN
               -- if config is set, go to new logic
               SET @nAfterScn = 814
               SET @nAfterStep = 99
               GOTO Quit
            END
         END
         IF @nInputKey = 0
         BEGIN
            IF @nStep IN (0, 2)  -- FCR-13167: Include step 0 for initial screen load
            BEGIN
               -- if config is set, go to new logic
               SET @nAfterScn = 814
               SET @nAfterStep = 99
               GOTO Quit
            END
         END
      END

   END -- IF @nFunc = 855

   GOTO Quit

Quit:
   -- FCR-13167: If returning to first screen (814), reset all UDFs
   IF @nAfterScn = 814 AND @nAfterStep = 99
   BEGIN
      SET @cUDF01 = ''
      SET @cUDF04 = ''
      SET @cUDF08 = ''
      SET @cUDF09 = ''
      SET @cUDF10 = ''
      SET @cUDF12 = ''
      SET @cUDF13 = ''
   END
   ELSE
   BEGIN
      -- FCR-13167: Pass values back to main function via @cUDFxx
      -- UDF01=DropID, UDF04=SingleUnitOrdFlag, UDF08=ExtendedInfo
      -- UDF09=PPACartonIDByPackDetailLabelNo, UDF10=PPACartonIDByPickDetailCaseID
      -- UDF12=OrderKey, UDF13=ToteID (matches rdtfnc_PostPickAudit expectation)
      SET @cUDF01 = @cDropID
      SET @cUDF04 = @cSingleUnitOrdFlag
      SET @cUDF08 = @cExtendedInfo
      SET @cUDF09 = @cPPACartonIDByPackDetailLabelNo
      SET @cUDF10 = @cPPACartonIDByPickDetailCaseID
      SET @cUDF12 = @cOrderKey
      SET @cUDF13 = @cToteID
   END

   

   -- FCR-13167: Save all state to RDTMOBREC (unified at Quit)
   -- V_String2, V_OrderKey, V_PickSlipNo for main function to read
   -- C_STRING1-3 for flags, C_String5-25 for session state, C_String26 for pagination

   UPDATE RDT.RDTMOBREC SET
      V_String2   = ISNULL(@cDropID,''),        -- DropID for main function
      V_OrderKey  = ISNULL(@cOrderKey,''),      -- OrderKey for main function
      V_PickSlipNo= ISNULL(@cPickSlipNo,''),    -- PickSlipNo for main function
      C_STRING1  = ISNULL(@cDropIDFlag,''),     -- DropIDFlag
      C_STRING2  = ISNULL(@cSingleUnitOrdFlag,'N'), -- SingleUnitOrdFlag
      C_STRING3  = ISNULL(@cToteID,''),         -- ToteID
      C_String5  = ISNULL(@cOrderKey,''),
      C_String6  = ISNULL(@cPickSlipNo,''),
      C_String7  = ISNULL(@cLabelNo,''),
      C_String8  = ISNULL(@cVASCode1,''),
      C_String9  = ISNULL(@cVASDesc1,''),
      C_String10 = ISNULL(@cVASCode2,''),
      C_String11 = ISNULL(@cVASDesc2,''),
      C_String12 = ISNULL(@cVASCode3,''),
      C_String13 = ISNULL(@cVASDesc3,''),
      C_String14 = ISNULL(@cVASCode4,''),
      C_String15 = ISNULL(@cVASDesc4,''),
      C_String16 = ISNULL(@cVASCode5,''),
      C_String17 = ISNULL(@cVASDesc5,''),
      C_String19 = ISNULL(@cFirstSKUScan,'N'),
      C_String20 = CAST(ISNULL(@nCtnSKUTotal,0) AS NVARCHAR(10)),
      C_String21 = CAST(ISNULL(@nTotalQtyExpected,0) AS NVARCHAR(10)),
      C_String22 = ISNULL(@cDisableQTYField,'0'),
      C_String23 = ISNULL(@cPPADefaultQTY,'1'),
      C_String24 = ISNULL(@cSavedSKU,''),
      C_String25 = CAST(ISNULL(@nSKUTotal,0) AS NVARCHAR(10)),
      C_String26 = CAST(ISNULL(@nDiscOffset,0) AS NVARCHAR(10)), -- DiscOffset for pagination
      C_String27 = ISNULL(@cFrom814Flag,'N') -- FCR-6657: From 814 to 6915 flag
   WHERE Mobile = @nMobile
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_855ExtScn05 to nSQL
GO
