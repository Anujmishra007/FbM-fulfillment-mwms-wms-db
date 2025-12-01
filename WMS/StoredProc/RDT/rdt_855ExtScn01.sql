SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************************/
/* Store procedure: rdt_855ExtScn01                                                    */
/*                                                                                     */
/* Modifications log:                                                                  */
/* Customer: Granite                                                                   */
/*                                                                                     */
/* Date       Rev  Author     Purposes                                                 */
/* 2024-06-13 1.0  NLT013     FCR-386. Created                                         */
/* 2024-11-15 1.1.0 LJQ006    FCR-1109. Updated                                        */
/* 2025-01-04 1.1.1 Dennis    FCR-1109. Updated                                        */
/* 2025-02-05 1.2.0 CYU027    FCR-2630 Add Option=5 in step 5                          */
/* 2025-02-05 1.3.0 Dennis    Add Step_4                                               */
/* 2025-04-05 1.4.0 JackC     FCR-4159 Support single unit orders                      */
/* 2025-08-27 1.5.0 JackC     FCR-7348 New single unit order identifer                 */
/* 2025-08-27 1.5.1 JackC     FCR-7348 Remov MPOC condition from Single                */
/*                                unit order judgement                                 */
/* 2025-09-20 1.5.2 JackC     FCR-7348 If PPK order not set single unit                */
/*                               order flag                                            */
/* 2025-09-24 1.6.0 NickT     UWP-41178 Stay in PrintPackingList scn                   */
/*                            if input invalid option                                  */
/* 2025-09-25 1.7.0 JackC     FCR-7348 Support UPC at SKU screen when Single unit order*/
/* 2025-10-15 1.8.0 CYU027    FCR-6657 validation to AVOID SHORT                       */
/* 2025-12-01 1.9.0 NickT     UWP-44802 Correct parameter text string                  */
/***************************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_855ExtScn01] (
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
      -- FCR-1109 start
      @cPPACtnIDByPDDropIDnPDLblNo NVARCHAR(1),
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
      @b_Success              INT
   --V1.4.0 end

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

   SET @cPPACtnIDByPDDropIDnPDLblNo = rdt.rdtGetConfig( @nFunc, 'PPACtnIDByPDDropIDnPDLblNo', @cStorerkey)
   IF @cPPACtnIDByPDDropIDnPDLblNo = '0'
      SET @cPPACtnIDByPDDropIDnPDLblNo = ''

   --V1.4.0 Start
   -- No need to get config from rdt config. Because both of configs are calcuated not from config table.
   -- And the calculated values are updated to rdtmobrec
   /*
   SET @cPPACartonIDByPackDetailLabelNo = rdt.rdtGetConfig( @nFunc, 'PPACartonIDByPackDetailLabelNo', @cStorerkey)
   IF @cPPACartonIDByPackDetailLabelNo = '0'
      SET @cPPACartonIDByPackDetailLabelNo = ''

   SET @cPPACartonIDByPickDetailCaseID = rdt.rdtGetConfig( @nFunc, 'PPACartonIDByPickDetailCaseID', @cStorerkey)
   IF @cPPACartonIDByPickDetailCaseID = '0'
      SET @cPPACartonIDByPickDetailCaseID = ''
   */
   --V1.4.0 end

   SET @cPPAPrintPackListSP = rdt.rdtGetConfig( @nFunc, 'PPAPrintPackListSP', @cStorerKey)
   IF @cPPAPrintPackListSP = '0'
      SET @cPPAPrintPackListSP = ''

   SELECT @nStep = Step,
      @cPPAPromptDiscrepancy = V_String21,
      @cDisableQTYField    = V_String23,
      @cPPADefaultQTY      = V_String14,
      @cTaskQty            = V_String6,
      @cTaskDefaultQty     = V_String7,
      @cDropIDFlag         = C_STRING1,
      @cSingleUnitOrdFlag  = C_STRING2, --V1.4.0
      @cToteID             = C_STRING3, --V1.4.0
      @cDSPOrderKey        = C_String4, --V1.5.0
      @cCaptureReasonCode  = V_String46,
      @nMenu               = Menu
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 855
   BEGIN
      IF @nStep = 3
      BEGIN
         IF @nAction = 0
         BEGIN
            IF @nInputKey = 1 --Enter
            BEGIN
               SELECT @nTotalPQty = SUM(PQty), @nTotalCQty = SUM(CQty), @cPPAStatus = Status
               FROM RDT.RDTPPA WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND DropID = @cDropID
                  AND Sku = @cSKU
               GROUP BY Status

               IF @nTotalPQty = @nTotalCQty AND @cPPAStatus IN ('2', '5')  ---- Aduit finished or not need QC
               BEGIN
                  SET @cOutField01 = '' --@cSKU
                  SET @cOutField02 = '' --@cSKU
                  SET @cOutField03 = '' --SUBSTRING( @cSKUDesc, 1, 20)
                  SET @cOutField04 = '' --SUBSTRING( @cSKUDesc, 21, 40)
                  SET @cOutField05 = '' --@cStyle
                  SET @cOutField06 = '' --@cColor
                  SET @cOutField07 = '' --@cSize
                  SET @cOutField08 = '' --@nPUOM_Div, @cPUOM_Desc, @cMUOM_Desc
                  SET @cOutField09 = CASE WHEN @cPPADefaultPQTY <> '' THEN @cPPADefaultPQTY ELSE '' END --@nPUOM
                  SET @cOutField10 = CASE WHEN @cTaskDefaultQty = '1' THEN @cTaskQty ELSE @cPPADefaultQTY END --@nMUOM
                  SET @cOutField11 = '' --@nPQTY_CHK
                  SET @cOutField12 = '' --@nMQTY_CHK
                  SET @cOutField13 = '' --@nPQTY_PPA
                  SET @cOutField14 = '' --@nMQTY_PPA
                  SET @cOutField15 = '' --@cExtendedInfo
                  --SET @cOutField16 = '' --@cPackQTYIndicator
                  EXEC rdt.rdtSetFocusField @nMobile, 1 --SKU
                  GOTO Quit
               END
            END
            ELSE IF @nInputKey = 0 --ESC
            BEGIN
               SELECT @cPreviousSKU = O_Field02
               FROM RDT.RDTMOBREC WITH(NOLOCK)
               WHERE Mobile = @nMobile
                  AND ISNULL(V_String2, '') = @cDropID

               IF @cPreviousSKU IS NOT NULL AND TRIM(@cPreviousSKU) <> ''
               BEGIN
                  SELECT @nTotalPQty = SUM(PQty), @nTotalCQty = SUM(CQty), @cPPAStatus = Status
                  FROM RDT.RDTPPA WITH(NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cDropID
                     AND Sku = @cPreviousSKU
                  GROUP BY Status

                  IF @nTotalPQty <> @nTotalCQty AND @cPPAStatus = '0'  ---- If previous SKU is not finished, Confirm Short screen displays
                  BEGIN
                     SET @nAfterScn = 6384
                     SET @nAfterStep = 99

                     GOTO Quit
                  END
               END
               ELSE --go to ste2 scn815
               BEGIN
                  --V1.5.0
                  --Make orderkey display at step2 when exit from step3
                  SET @cOutField04 = @cDSPOrderKey
               END
            END
         END
      END
      IF @nStep = 2
      BEGIN
         --FCR-6657 new Discrepancy logic
         IF @nInputKey = '1'
            AND EXISTS(
               SELECT 1 FROM dbo.WorkOrderDetail WOD WITH(NOLOCK)
               INNER JOIN dbo.PickDetail PKD WITH(NOLOCK)
               ON WOD.StorerKey = PKD.StorerKey
                  AND WOD.ExternWorkOrderKey = PKD.OrderKey
                  AND WOD.WkOrdUdef1 = PKD.SKU
               WHERE PKD.StorerKey = @cStorerkey
                 AND ( PKD.CaseID = @cDropID or PKD.DropID = @cDropID)
                 AND WOD.type = 'S02'
                 AND TRY_CAST(NULLIF(WOD.WkOrdUdef3, '') AS INT) > 0)
         BEGIN

            DECLARE @wSKU NVARCHAR(20)
            DECLARE @wQty INT = 0

            IF EXISTS ( SELECT 1
                 FROM dbo.ORDERS ord WITH (NOLOCK)
                         INNER JOIN dbo.PickDetail pd WITH (NOLOCK) ON ord.OrderKey = pd.OrderKey
                         INNER JOIN dbo.Wave w WITH (NOLOCK) ON ord.UserDefine09 = w.WaveKey
                 WHERE ord.StorerKey = @cStorerkey
                   AND pd.StorerKey = @cStorerkey
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
                                        ON (ph.StorerKey = pd.StorerKey AND ph.PickSlipNo = pd.PickSlipNo AND WOD.WkOrdUdef1 = Pd.SKU)
                     WHERE pd.StorerKey = @cStorerkey
                       AND ( pd.LabelNo = @cDropID or pd.dropID = @cDropID)
                       AND WOD.type = 'S02'
                     GROUP BY pd.SKU
                     HAVING SUM(TRY_CAST(NULLIF(WOD.WkOrdUdef3, '') AS INT)) > 0
                  ) as W
               WHERE W.WorkOrderQty <> W.PickQty
            END
            ELSE
            BEGIN -- Manuel
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
                             INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON
                        WOD.StorerKey = PKD.StorerKey
                           AND WOD.ExternWorkOrderKey = PKD.OrderKey
                           AND WOD.WkOrdUdef1 = PKD.SKU
                     WHERE PKD.StorerKey = @cStorerkey
                       AND (PKD.CaseID = @cDropID OR PKD.DROPID = @cDropID)
                       AND WOD.type = 'S02'
                     GROUP BY PKD.SKU
                     HAVING SUM(TRY_CAST(NULLIF(WOD.WkOrdUdef3, '') AS INT)) > 0
                  ) as W
               WHERE W.WorkOrderQty <> W.PickQty
            END


            IF (ISNULL(@wSKU,'')<>'')
            BEGIN

               --Message Queue
               DECLARE
                  @cMsg01                 NVARCHAR(20) = '',
                  @cMsg02                 NVARCHAR(20) = '',
                  @cMsg03                 NVARCHAR(20) = '',
                  @cMsg04                 NVARCHAR(20) = '',
                  @cMsg05                 NVARCHAR(20) = '',
                  @cMsg06                 NVARCHAR(20) = '',
                  @cMsg07                 NVARCHAR(20) = '',
                  @cMsg08                 NVARCHAR(20) = '',
                  @cMsg09                 NVARCHAR(20) = ''

               SET @cMsg01 = 'Error.See Supervisor'
               SET @cMsg02 = 'Qty does not match . '
               SET @cMsg03 = 'Expected value :' + CAST(@wQty AS NVARCHAR(10))
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


               -- Go to discrepency screen
               SET @cOutField01 = '' -- Option
               SET @cFieldAttr02 = CASE WHEN @cCaptureReasonCode ='1' THEN '' ELSE 'o' END
               SET @cOutField02 = ''
               SET @cInField02 = ''

               SET @nAfterScn = 817
               SET @nAfterStep = 4

               GOTO Quit
            END

         END


         IF @nScn = 818
         BEGIN
            IF @nInputKey = 0
            BEGIN
               IF @cPPAPromptDiscrepancy = '1'
               BEGIN
                  SELECT @nVariance = 0
                  EXECUTE rdt.rdt_PostPickAudit_GetStat @nMobile, @nFunc, @cRefNo, @cPickSlipNo, @cLoadKey,
                     @cOrderKey, @cDropID, @cID, @cTaskDetailKey, cStorerKey, @cFacility, @cPUOM,
                     @nVariance = @nVariance OUTPUT

                  -- Discrepancy found
                  IF @nVariance = 1
                  BEGIN
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
                              '@cTaskDetailKey  NVARCHAR( 10), ' +
                              '@cReasonCode     NVARCHAR( 20)  OUTPUT'

                           EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                              @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, cStorerKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, @cSKU, @nQty, '',
                              @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey,@cReasonCode OUTPUT

                           IF @nErrNo <> 0
                              GOTO Quit
                        END
                     END

                     -- Go to discrepency screen
                     SET @cOutField01 = '' -- Option
                     SET @cFieldAttr02 = CASE WHEN @cCaptureReasonCode ='1' THEN '' ELSE 'o' END
                     SET @cOutField02 = @cReasonCode
                     SET @cInField02 = ''

                     SET @nAfterScn = 817 --V1.4.0 Fix an existing issue
                     SET @nAfterStep = 4

                     GOTO Quit
                  END
               END
            END
            --Go to new print pack list screen
            SET @nAfterScn = 6464
            SET @nAfterStep = 99
            GOTO Quit
         END
         ELSE IF @nScn = 816 --V1.4.0 Fill in SKU automatically when single unit order
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'ExtScn01, Step2, Scn816'
            IF @nInputKey = 1
            BEGIN
               --The base step2 always set SKU back to '', so get sku from rdtmobrec again
               IF @cSingleUnitOrdFlag = 'Y' --V1.5.0 only set default value if single unit order
               BEGIN
                  SELECT @cUPC = V_String35 FROM rdt.rdtmobrec WITH (NOLOCK) WHERE Mobile = @nMobile
                  SET @cOutField01 = ISNULL(@cUPC,'') --V1.7.0
               END
               GOTO Quit
            END
         END
         --V1.4.0 Fill in SKU automatically when single unit order end
         ELSE IF @nScn = 817 --V1.4.0 Press ESC on step2 in single unit order, redirect to single unit order screen
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'ExtScn01, Step2, Scn817'
            IF @nInputKey = 0 --ESC
            BEGIN
               IF @cSingleUnitOrdFlag = 'Y'
               BEGIN
                --Set return value
                  SET @cUDF01 = @cToteID
                  SET @cUDF02 = @cPPACartonIDByPackDetailLabelNo
                  SET @cUDF03 = @cPPACartonIDByPickDetailCaseID
                  SET @cUDF04 = @cSingleUnitOrdFlag

                  SET @cOutField01 = '' -- SKU 
                  SET @cFieldAttr01 = ''

                  SET @nAfterScn = 6468
                  SET @nAfterStep = 99
                  GOTO Quit
               END
               ELSE
               BEGIN -- keep original logic
                  SET @cOutField01 = '' -- Option    
                  SET @cFieldAttr02 = CASE WHEN @cCaptureReasonCode ='1' THEN '' ELSE 'o' END        
                  SET @cOutField02 = @cReasonCode       
                  SET @cInField02 = ''   
            
                  SET @nScn = @nScn + 2
                  SET @nStep = @nStep + 2
               END
            END
            --V1.4.0 end
         END
      END
      ELSE IF @nStep = 4
      BEGIN
         IF @nInputKey = 0 --ESC
         BEGIN
            IF @cSingleUnitOrdFlag = 'Y' --V1.4.0
            BEGIN
               SET @cOutField01 = '' -- SKU

               SET @cUDF01 = @cToteID
               SET @cUDF02 = @cPPACartonIDByPackDetailLabelNo
               SET @cUDF03 = @cPPACartonIDByPickDetailCaseID
               SET @cUDF04 = @cSingleUnitOrdFlag -- Single unit order flag

               SET @nAfterStep = 99 
               SET @nAfterScn = 6468 -- Single unit order scan sku screen
            END
            ELSE
            BEGIN
               IF rdt.rdtGetConfig (@nFunc, 'PPAShowSummary', @cStorerKey) = '1'
               BEGIN
                  SELECT @nCSKU = 0, @nCQTY = 0, @nPSKU = 0, @nPQTY = 0
                  EXECUTE rdt.rdt_PostPickAudit_GetStat @nMobile, @nFunc, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, @cID, @cTaskDetailKey, @cStorerKey, @cFacility, @cPUOM,
                     @nCSKU = @nCSKU OUTPUT,
                     @nCQTY = @nCQTY OUTPUT,
                     @nPSKU = @nPSKU OUTPUT,
                     @nPQTY = @nPQTY OUTPUT

                  SET @cSKUStat = CAST( @nCSKU AS NVARCHAR( 10)) + '/' + CAST( @nPSKU AS NVARCHAR( 10))
                  SET @cQTYStat = CAST( @nCQTY AS NVARCHAR( 10)) + '/' + CAST( @nPQTY AS NVARCHAR( 10))
               END
               ELSE
               BEGIN
                  SET @cSKUStat = ''
                  SET @cQTYStat = ''
               END

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
               SET @cOutField10 = @cTaskDetailKey

               -- Enable all fields
               SET @cFieldAttr01 = ''
               SET @cFieldAttr02 = ''
               SET @cFieldAttr03 = ''
               SET @cFieldAttr04 = ''
               SET @cFieldAttr05 = ''
               -- Go to next screen
               SET @nAfterScn = 815
               SET @nAfterStep = 2
            END

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
                     @nMobile, @nFunc, @cLangCode, 4, @nStep, @nInputKey, @cFacility, @cStorerKey, @tExtInfo,
                     @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                  SET @cOutField08 = @cExtendedInfo
               END
            END
            GOTO QUIT
         END
      END
      ELSE IF @nStep = 99
      BEGIN
         IF @nScn = 6384
         BEGIN
            IF @nInputKey = 0
            BEGIN
               SET @cOutField01 = ''
               IF @cDisableQTYField = '1'
               BEGIN
                  SET @cFieldAttr09 = 'O' -- PQTY
                  SET @cFieldAttr10 = 'O' -- MQTY
               END

               SET @cOutField10 = CASE WHEN @cTaskDefaultQty = '1' THEN @cTaskQty ELSE @cPPADefaultQTY END --@nMUOM
               SET @cOutField02 = @cSKU

               SET @nAfterScn = 816
               SET @nAfterStep = 3
            END
            ELSE IF @nInputKey = 1
            BEGIN
               SET @cOption = @cInField01

               IF @cOption NOT IN ('1', '9') --1. Short Pick  9. Not Short Pick
               BEGIN
                  SET @nErrNo = 217351
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidOption
                  GOTO Quit
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
                        '@cTaskDetailKey  NVARCHAR( 10), ' +
                        '@cReasonCode     NVARCHAR( 20)  OUTPUT '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, @cSKU, @nQty, @cOption,
                        @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey, @cReasonCode OUTPUT

                     IF @nErrNo <> 0
                        GOTO Quit
                  END
               END

               SET @cOutField01 = ''
               IF @cDisableQTYField = '1'
               BEGIN
                  SET @cFieldAttr09 = 'O' -- PQTY
                  SET @cFieldAttr10 = 'O' -- MQTY
               END

               IF @cOption = '1'
               BEGIN
                  SET @cOutField01 = '' --@cSKU
                  SET @cOutField02 = '' --@cSKU
                  SET @cOutField03 = '' --SUBSTRING( @cSKUDesc, 1, 20)
                  SET @cOutField04 = '' --SUBSTRING( @cSKUDesc, 21, 40)
                  SET @cOutField05 = '' --@cStyle
                  SET @cOutField06 = '' --@cColor
                  SET @cOutField07 = '' --@cSize
                  SET @cOutField08 = '' --@nPUOM_Div, @cPUOM_Desc, @cMUOM_Desc
                  SET @cOutField09 = CASE WHEN @cPPADefaultPQTY <> '' THEN @cPPADefaultPQTY ELSE '' END --@nPUOM
                  SET @cOutField10 = CASE WHEN @cTaskDefaultQty = '1' THEN @cTaskQty ELSE @cPPADefaultQTY END --@nMUOM
                  SET @cOutField11 = '' --@nPQTY_CHK
                  SET @cOutField12 = '' --@nMQTY_CHK
                  SET @cOutField13 = '' --@nPQTY_PPA
                  SET @cOutField14 = '' --@nMQTY_PPA
                  SET @cOutField15 = '' --@cExtendedInfo
                  --SET @cOutField16 = '' --@cPackQTYIndicator
                  EXEC rdt.rdtSetFocusField @nMobile, 1 --SKU
               END
               ELSE IF @cOption = '9'
               BEGIN
                  SET @cOutField02 = @cSKU
                  SET @cOutField10 = CASE WHEN @cTaskDefaultQty = '1' THEN @cTaskQty ELSE @cPPADefaultQTY END --@nMUOM
               END

               SET @nAfterScn = 816
               SET @nAfterStep = 3
            END
         END--6384
         IF @nScn = 814
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
                        -- V1.5.1 No need to check LISTNAME = 'MPOCPERMIT' for single unit order
                        -- IF NOT EXISTS (SELECT 1
                        --             FROM dbo.PICKDETAIL PD WITH (NOLOCK)
                        --             JOIN dbo.ORDERS AS O WITH (NOLOCK)
                        --                ON O.orderkey = PD.orderkey
                        --             JOIN dbo.CODELKUP AS C WITH (NOLOCK)
                        --                ON LISTNAME = 'MPOCPERMIT'
                        --                AND ( C.Code = O.BillToKey OR C.Code = O.ConsigneeKey )
                        --                AND C.Storerkey = O.StorerKey
                        --             WHERE  PD.StorerKey = @cStorerkey
                        --                AND PD.DropID = @cDropID)
                        --V1.5.2 Any SKU which UOM=2, then it is PPK order not single unit order.
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
                              SET @cToteID = @cDropID -- in single unit order, the scanned dropid is the toteid
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
                  END --ToteID scanned
                  --V1.4.0 end

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

                     -- Show the statistic
                     IF rdt.rdtGetConfig (@nFunc, 'PPAShowSummary', @cStorerKey) = '1'
                     BEGIN
                        SELECT @nCSKU = 0, @nCQTY = 0, @nPSKU = 0, @nPQTY = 0
                        EXECUTE rdt.rdt_PostPickAudit_GetStat @nMobile, @nFunc, @cRefNo, @cPickSlipNo, @cLoadKey,
                        @cOrderKey, @cDropID, @cID, @cTaskDetailKey, @cStorerKey, @cFacility, @cPUOM,
                           @nCSKU = @nCSKU OUTPUT,
                           @nCQTY = @nCQTY OUTPUT,
                           @nPSKU = @nPSKU OUTPUT,
                           @nPQTY = @nPQTY OUTPUT
                        SET @cSKUStat = CAST( @nCSKU AS NVARCHAR( 10)) + '/' + CAST( @nPSKU AS NVARCHAR( 10))
                        SET @cQTYStat = CAST( @nCQty AS NVARCHAR( 10)) + '/' + CAST( @nPQty AS NVARCHAR( 10))
                     END
                     ELSE
                     BEGIN
                        SET @cSKUStat = ''
                        SET @cQTYStat = ''
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
                     -- Enable all fields
                     SET @cFieldAttr01 = ''
                     SET @cFieldAttr02 = ''
                     SET @cFieldAttr03 = ''
                     SET @cFieldAttr04 = ''
                     SET @cFieldAttr05 = ''
                     -- Go to next screen
                     SET @nAfterScn = 815
                     SET @nAfterStep = 2

                     -- update variables
                     SET @cUDF01 = @cDropID
                     SET @cUDF02 = CAST(@nCSKU AS NVARCHAR(10))
                     SET @cUDF03 = CAST(@nPSKU AS NVARCHAR(10))
                     SET @cUDF04 = CAST(@nPQTY AS NVARCHAR(10))
                     SET @cUDF05 = CAST(@nCQTY AS NVARCHAR(10))
                     SET @cUDF06 = @cSKUStat
                     SET @cUDF07 = @cQTYStat
                     SET @cUDF08 = @cExtendedInfo
                     SET @cUDF09 = @cPPACartonIDByPackDetailLabelNo
                     SET @cUDF10 = @cPPACartonIDByPickDetailCaseID
                     --SET @cUDF11 = @cSKU Do not use UDF11.
                     SET @cUDF12 = @cOrderKey --V1.5.0
                  END --Original logc single order flag <> 'Y'
                  ELSE --Single unit orders logic
                  BEGIN
                     --Single unit orders validation
                     --PackDetail should be ready before packing
                     IF NOT EXISTS (SELECT 1 FROM dbo.PackDetail WITH(NOLOCK)
                                    WHERE StorerKey = @cStorerkey
                                       AND DropID = @cDropID --ToteID
                                   )
                     BEGIN
                        SET @nErrNo = 217354
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- PackDetail not ready
                        GOTO Step_1_99_Fail
                     END

                     --Keep the logic consistent with the original. Since single unit orders have packdetail data
                     --Set the configs accordingly
                     SET @cPPACartonIDByPackDetailLabelNo = '1'
                     SET @cPPACartonIDByPickDetailCaseID = ''

                     --Set return value
                     SET @cUDF01 = @cToteID
                     SET @cUDF02 = @cPPACartonIDByPackDetailLabelNo
                     SET @cUDF03 = @cPPACartonIDByPickDetailCaseID
                     SET @cUDF04 = @cSingleUnitOrdFlag 
                     SET @cFieldAttr01 = ''

                     SET @nAfterScn = 6468
                     SET @nAfterStep = 99
                  END -- Single orders logic
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

                        SET @cOutField08 = @cExtendedInfo
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

         IF @nScn = 6464
         BEGIN
            /********************************************************************************
               Scn = 6464. PRINT PACKING LIST?
               1 = YES
               5 = Automation label and doc'
               9 = NO
               OPTION: %01i01'
            ********************************************************************************/
            IF @nInputKey = 1 -- Yes OR Send
            BEGIN
               -- Screen mapping
               SET @cOption = @cInField01 -- Option

               -- Check option blank
               IF @cOption = ''
               BEGIN
                  SET @nErrNo = 60883
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- OptionRequired
                  GOTO Quit
               END

               -- Check option valid
               IF @cOption NOT IN ('1','5','9')
               BEGIN
                  SET @nErrNo = 60884
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Invalid Option
                  GOTO Quit
               END

               -- Prompt print packing list
               IF @cPPAPrintPackListSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cPPAPrintPackListSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cPPAPrintPackListSP) +
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
                             '@cTaskDetailKey        NVARCHAR( 10)  '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                          @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, @cSKU, @nQTY, @cOption, 'PRINT',
                          @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey

                     IF @nErrNo <> 0
                        GOTO Quit
                  END
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
                             '@cTaskDetailKey  NVARCHAR( 10), ' +
                             '@cReasonCode     NVARCHAR( 20)  OUTPUT'

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                          @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, @cSKU, @nQty, @cOption,
                          @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey,@cReasonCode OUTPUT

                     IF @nErrNo <> 0
                        GOTO Quit
                  END
               END

               -- Reset prev screen var
               SET @cRefNo = ''
               SET @cPickSlipNo = ''
               SET @cLoadKey = ''
               SET @cOrderKey = ''
               SET @cDropID = ''
               SET @cID = ''
               SET @cTaskDetailKey = ''

               --v1.4.0 START
               IF @cSingleUnitOrdFlag = 'Y'
                  AND EXISTS (SELECT  1
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
                                 AND ISNULL(PI.CartonStatus,'') <> 'PACKED') -- There is unpakced SKU in the tote
               BEGIN
                  SET @cOutField01 = '' -- SKU

                  SET @cUDF01 = @cToteID
                  SET @cUDF02 = @cPPACartonIDByPackDetailLabelNo
                  SET @cUDF03 = @cPPACartonIDByPickDetailCaseID
                  SET @cUDF04 = @cSingleUnitOrdFlag -- Single unit order flag

                  SET @nAfterScn = 6468
                  SET @nAfterStep = 99
                  GOTO Quit
               END
               ELSE
               BEGIN
                  SET @cOutField01 = @cRefNo
                  SET @cOutField02 = @cPickSlipNo
                  SET @cOutField03 = @cLoadKey
                  SET @cOutField04 = @cOrderKey
                  SET @cOutField05 = @cDropID
                  SET @cOutField06 = @cID
                  SET @cOutField07 = @cTaskDetailKey

                  -- Enable disable field
                  SET @cFieldAttr01 = 'O' --RefNo
                  SET @cFieldAttr02 = 'O' --PickSlipNo
                  SET @cFieldAttr03 = 'O' --LoadKey
                  SET @cFieldAttr04 = 'O' --OrderKey
                  SET @cFieldAttr05 = ''
                  SET @cFieldAttr06 = 'O' --ID
                  SET @cFieldAttr07 = 'O' --TaskDetailKey

                  -- Go to first screen
                  SET @nAction = 0 --Is required to jump into st99 scn814 backend logic

                  SET @cUDF09 = CAST(@nAction AS NVARCHAR(1))
                  SET @nAfterScn = 814
                  SET @nAfterStep = 99
               END -- @cSingleUnitOrdFlag <> 'Y'

            END

            IF @nInputKey = 0 -- Esc OR No
            BEGIN

               IF rdt.rdtGetConfig (@nFunc, 'PPAShowSummary', @cStorerKey) = '1'
               BEGIN
                  SELECT @nCSKU = 0, @nCQTY = 0, @nPSKU = 0, @nPQTY = 0
                  EXECUTE rdt.rdt_PostPickAudit_GetStat @nMobile, @nFunc, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, @cID, @cTaskDetailKey, @cStorerKey, @cFacility, @cPUOM,
                          @nCSKU = @nCSKU OUTPUT,
                          @nCQTY = @nCQTY OUTPUT,
                          @nPSKU = @nPSKU OUTPUT,
                          @nPQTY = @nPQTY OUTPUT

                  SET @cSKUStat = CAST( @nCSKU AS NVARCHAR( 10)) + '/' + CAST( @nPSKU AS NVARCHAR( 10))
                  SET @cQTYStat = CAST( @nCQTY AS NVARCHAR( 10)) + '/' + CAST( @nPQTY AS NVARCHAR( 10))
               END
               ELSE
               BEGIN
                  SET @cSKUStat = ''
                  SET @cQTYStat = ''
               END

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
               SET @cOutField10 = @cTaskDetailKey

               -- Go to prev screen
               SET @nAfterScn = 815
               SET @nAfterStep = 2

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
                          @nMobile, @nFunc, @cLangCode, 5, @nStep, @nInputKey, @cFacility, @cStorerKey, @tExtInfo,
                          @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                     SET @cOutField08 = @cExtendedInfo
                  END
               END
            END
         END --6464

         --V1.4.0 START
         IF @nScn = 6468
         /********************************************************************************
         Step 99. Scn = 6468. SKU screen
            SKU            (field01, input)
         ********************************************************************************/
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'Executing St99, Scn6468'

            IF @nInputKey = 1
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Inputkey = 1', @cInfield01 AS InputField01

               SET @cUPC = @cInField01 -- SKU

               IF ISNULL(@cUPC, '') = ''
               BEGIN
                  SET @nErrNo = 217355
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --SKU needed
                  GOTO Scn_6468_Fail
               END

               --Verify SKU is valid
               SET @nSKUCnt = 0

               EXEC [RDT].[rdt_GETSKUCNT]
                  @cStorerKey  = @cStorerKey,
                  @cSKU        = @cUPC,
                  @nSKUCnt     = @nSKUCnt       OUTPUT,
                  @bSuccess    = @b_Success     OUTPUT,
                  @nErr        = @nErrNo        OUTPUT,
                  @cErrMsg     = @cErrMsg       OUTPUT

               IF @nSKUCnt = 0
               BEGIN
                  SET @nErrNo = 217356
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid SKU
                  GOTO Scn_6468_Fail
               END

               IF @nSKUCnt > 1
               BEGIN
                  SET @nErrNo = 217357
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Multi SKU barcode
                  GOTO Scn_6468_Fail
               END

               --V1.7.0 Get real SKU value
               EXEC [RDT].[rdt_GETSKU]
                  @cStorerKey  = @cStorerKey
                  ,@cSKU        = @cUPC          OUTPUT
                  ,@bSuccess    = @b_Success     OUTPUT
                  ,@nErr        = @nErrNo        OUTPUT
                  ,@cErrMsg     = @cErrMsg       OUTPUT
                  ,@cSKUStatus  = 'ACTIVE'
               IF @nErrNo <> 0
               BEGIN
                  SET @nErrNo = 217361
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid SKU
                  EXEC rdt.rdtSetFocusField @nMobile, 1
                  SET @cOutField01 = ''
                  GOTO Scn_6468_Fail
               END

               SET @cSKU = @cUPC
               SET @cUPC = @cInfield01 --V1.7.0 get scanned value back

               --Verify SKU in the scanned ToteID (DropID)
               IF NOT EXISTS ( SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cToteID --ToteID
                     AND SKU = @cSKU)
               BEGIN
                  SET @nErrNo = 217358
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU not in tote
                  GOTO Scn_6468_Fail
               END -- SKU in the toteID

               --Get 1st not packed carton and order
               SET @cOrderKey = ''
               SET @cPickSlipNo = ''
               SET @cLabelNo = ''

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

               IF @@ROWCOUNT = 0
               BEGIN
                  SET @nErrNo = 217359
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --All packed
                  GOTO Scn_6468_Fail
               END

               --Since DropID = LabelNo = CaseId in existing LVSUSA 855
               --So, set labelNo back to dropID. In the following process the value of dropid is caseid/labelno
               SET @cDropID = @cLabelNo

                -- Show the statistic
               IF rdt.rdtGetConfig (@nFunc, 'PPAShowSummary', @cStorerKey) = '1'
               BEGIN
                  SELECT @nCSKU = 0, @nCQTY = 0, @nPSKU = 0, @nPQTY = 0
                  EXECUTE rdt.rdt_PostPickAudit_GetStat @nMobile, @nFunc, @cRefNo, @cPickSlipNo, @cLoadKey,
                  @cOrderKey, @cDropID, @cID, @cTaskDetailKey, @cStorerKey, @cFacility, @cPUOM,
                     @nCSKU = @nCSKU OUTPUT,
                     @nCQTY = @nCQTY OUTPUT,
                     @nPSKU = @nPSKU OUTPUT,
                     @nPQTY = @nPQTY OUTPUT
                  SET @cSKUStat = CAST( @nCSKU AS NVARCHAR( 10)) + '/' + CAST( @nPSKU AS NVARCHAR( 10))
                  SET @cQTYStat = CAST( @nCQty AS NVARCHAR( 10)) + '/' + CAST( @nPQty AS NVARCHAR( 10))
               END
               ELSE
               BEGIN
                  SET @cSKUStat = ''
                  SET @cQTYStat = ''
               END

               -- Prepare next screen var
               SET @cOutField01 = @cRefNo
               SET @cOutField02 = '' --@cPickSlipNo
               SET @cOutField03 = @cLoadKey
               SET @cOutField04 = @cOrderKey
               SET @cOutField05 = @cDropID
               SET @cOutField06 = @cSKUStat
               SET @cOutField07 = @cQTYStat
               SET @cOutField08 = '' -- @cExtendedInfo
               SET @cOutField09 = @cID
               SET @cOutField10 = @cTaskDetailKey		--INC1045866
               -- Enable all fields
               SET @cFieldAttr01 = ''
               SET @cFieldAttr02 = ''
               SET @cFieldAttr03 = ''
               SET @cFieldAttr04 = ''
               SET @cFieldAttr05 = ''

               -- Go to next screen
               SET @nAfterScn = 815
               SET @nAfterStep = 2

               -- update variables
               SET @cUDF01 = @cDropID
               SET @cUDF02 = CAST(@nCSKU AS NVARCHAR(10))
               SET @cUDF03 = CAST(@nPSKU AS NVARCHAR(10))
               SET @cUDF04 = CAST(@nPQTY AS NVARCHAR(10))
               SET @cUDF05 = CAST(@nCQTY AS NVARCHAR(10))
               SET @cUDF06 = @cSKUStat
               SET @cUDF07 = @cQTYStat
               --SET @cUDF08 = @cExtendedInfo
               SET @cUDF09 = @cPPACartonIDByPackDetailLabelNo
               SET @cUDF10 = @cPPACartonIDByPickDetailCaseID
               SET @cUDF11 = @cSKU --Save to mobrec V_SKU to populate on SKU QTY screen
               SET @cUDF12 = @cOrderKey --V1.5.0 Save orderkey to mobrec
               SET @cUDF13 = @cUPC --V1.7.0 save to mobrec

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

                     SET @cOutField08 = @cExtendedInfo
                  END
               END

            END -- inputkey = 1

            IF @nInputKey = 0
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Inputkey = 0'

               --V1.4.0 start
               --If there is single unit order not packed, go to discrepency screen
               IF EXISTS ( SELECT 1 
                           FROM dbo.PackInfo PI WITH (NOLOCK)
                           JOIN dbo.PackDetail PD WITH (NOLOCK)
                              ON PI.PickSlipNo = PD.PickSlipNo
                              AND PI.CartonNo = PD.CartonNo
                           WHERE PD.StorerKey = @cStorerKey
                              AND PD.DropID = @cToteID --ToteID
                              AND ISNULL(PI.CartonStatus,'') <> 'PACKED')
                           AND -- If 1st time to scan SKU, then allow to back to step1 directly (No RDTPPA data)
                           (( SELECT COUNT(1) 
                              FROM rdt.RDTPPA PPA WITH (NOLOCK)
                              JOIN dbo.PackDetail PD WITH (NOLOCK)
                                 ON PPA.StorerKey = PD.StorerKey
                                 AND PPA.DropID = PD.LabelNo
                              WHERE PPA.StorerKey = @cStorerKey 
                              AND PD.DropID = @cToteID) <> 0)
                        
               BEGIN
                  -- Go to discrepency screen      
                  SET @cOutField01 = '' -- Option    
                  SET @cFieldAttr02 = CASE WHEN @cCaptureReasonCode ='1' THEN '' ELSE 'o' END        
                  SET @cOutField02 = @cReasonCode       
                  SET @cInField02 = ''   
                  
                  SET @nAfterScn = 817
                  SET @nAfterStep = 4
               END--V1.4.0 end
               ELSE
               BEGIN
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
                  SET @cFieldAttr01 = 'O' --Disable Refno
                  SET @nAction = 0
                  SET @cUDF09 = CAST(@nAction AS NVARCHAR(1))
                  
               END
               GOTO Quit
            END -- inputkey = 0

            Scn_6468_Fail:
               SET @cOutField01 = '' --clear the input when error
            
            GOTO Quit

         END--6468 --single unit order sku screen
         --V1.4.0 END

      END -- step99

      -- fcr 1109
      IF @nStep IN (0, 2, 4, 5, 8)
            OR (@nStep = 99 AND @nScn = 6464 ) -- Print Scn
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @nStep IN (0, 4, 5, 8, 99)
            BEGIN
               -- if config is set, go to new logic
               IF @cPPACtnIDByPDDropIDnPDLblNo <> ''
               BEGIN
                  SET @nAfterScn = 814
                  SET @nAfterStep = 99
                  SET @nAction = 0
                  SET @cUDF09 = CAST(@nAction AS NVARCHAR(1))
                  GOTO Quit
               END
            END
         END
         IF @nInputKey = 0
         BEGIN
            IF @nStep = 2
            BEGIN
               -- if config is set, go to new logic
               IF @cPPACtnIDByPDDropIDnPDLblNo <> ''
               BEGIN
                  SET @nAfterScn = 814
                  SET @nAfterStep = 99
                  SET @nAction = 0
                  SET @cUDF09 = CAST(@nAction AS NVARCHAR(1))
                  GOTO Quit
               END
            END
         END
      END
   END

   GOTO Quit

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_855ExtScn01 to nSQL
GO
