SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_855ExtScn02                                     */
/*                                                                      */
/* Modifications log:                                                   */
/* Customer: Mattel                                                     */
/*                                                                      */
/* Date       Rev    Author     Purposes                                */
/* 2025-07-21 1.0.0  Jackc      FCR-5413. Created                       */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_855ExtScn02] (
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

   DECLARE @nMOBRECStep          INT,
           @nMOBRECScn           INT,
           @nFromStep            INT,
           @nFromScn             INT

   DECLARE
      @cExtendedUpdateSP         NVARCHAR( 20),
      @cExtendedValidateSP       NVARCHAR( 20),
      @cExtendedInfoSP           NVARCHAR( 20),
      @tExtInfo                  VariableTable,

      @cDropID                   NVARCHAR( 20),
      @cRefNo                    NVARCHAR( 20),
      @cExtendedInfo             NVARCHAR( 20),
      @cPickSlipNo               NVARCHAR( 10),
      @cLoadKey                  NVARCHAR( 10),
      @cOrderKey                 NVARCHAR( 10),
      @cID                       NVARCHAR( 18),
      @cOption                   NVARCHAR( 1),
      @cSKU                      NVARCHAR( 20),
      @cTaskDetailKey            NVARCHAR( 20),
      @cPreviousSKU              NVARCHAR( 20),
      @cPPAStatus                NVARCHAR( 1),
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
      @nQTY_PPA                  INT,
      @nQTY_CHK                  INT,
      @cUserName                 NVARCHAR(18),
      @nCSKU                     INT=0,
      @nPSKU                     INT=0,
      @nPQTY                     INT=0,
      @nCQTY                     INT=0,
      @nMenu                     INT,
      @cMultiColScan             NVARCHAR(20),
      @nRowRef                   INT

   DECLARE 
      @cPickConfirmStatus        NVARCHAR( 1),
      @cSkipChkPSlipMustScanIn   NVARCHAR( 1),
      @cSkipChkPSlipMustScanOut  NVARCHAR( 1),
      @cConvertQTYSP             NVARCHAR(20),
      @cCaptureReasonCode        NVARCHAR( 1),
      @cPPAPromptDiscrepancy     NVARCHAR( 1),
      @cCapturePackInfo          NVARCHAR(20),
      @cCaptureData              NVARCHAR( 1),
      @cPrintPackList            NVARCHAR( 1),

      @cReasonCode               NVARCHAR(20),
      @cCartonType               NVARCHAR(10),    
      @cCube                     NVARCHAR(10),    
      @cWeight                   NVARCHAR(10),
      @cCaptureDataInput         NVARCHAR(60),
      @tDataCapture              VariableTable,
      @tExtValidate              VariableTable

   SET @nErrNo = 0
   SET @cErrMsg = ''
   SET @cUDF30 = '' --reset skip update indicator

   /*SELECT @cDropID = Value FROM @tExtScnData WHERE Variable = '@cDropID'
   SELECT @cRefNo = Value FROM @tExtScnData WHERE Variable = '@cRefNo'
   SELECT @cPickSlipNo = Value FROM @tExtScnData WHERE Variable = '@cPickSlipNo'
   SELECT @cLoadKey = Value FROM @tExtScnData WHERE Variable = '@cLoadKey'
   SELECT @cOrderKey = Value FROM @tExtScnData WHERE Variable = '@cOrderKey'
   SELECT @cID = Value FROM @tExtScnData WHERE Variable = '@cID'
   SELECT @cSKU = Value FROM @tExtScnData WHERE Variable = '@cSKU'
   SELECT @cPUOM = Value FROM @tExtScnData WHERE Variable = '@cPUOM'
   SELECT @nQTY = CAST(Value AS INT) FROM @tExtScnData WHERE Variable = '@nQTY'
   SELECT @nScn = CAST(Value AS INT) FROM @tExtScnData WHERE Variable = '@nScn'*/

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

   SET @cPPAPrintPackListSP = rdt.rdtGetConfig( @nFunc, 'PPAPrintPackListSP', @cStorerKey)
   IF @cPPAPrintPackListSP = '0'
      SET @cPPAPrintPackListSP = ''

   SET @cPickConfirmStatus = rdt.rdtGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
      IF @cPickConfirmStatus = '0'
         SET @cPickConfirmStatus = '5'

   SELECT 
      @nMOBRECStep               = Step,
      @nMOBRECScn                = Scn,
      @cPUOM                     = V_UOM,
      @cLoadKey                  = V_LoadKey,
      @cSKU                      = V_SKU,
      @cDropID                   = V_String2,
      @cSkipChkPSlipMustScanIn   = V_String15,
      @cConvertQTYSP             = V_String17,
      @cPPAPromptDiscrepancy     = V_String21,
      @cDisableQTYField          = V_String23,
      @cSkipChkPSlipMustScanOut  = V_String24,
      @cCapturePackInfo          = V_String39,
      @cReasonCode               = V_String45,
      @cCaptureReasonCode        = V_String46,
      @nMenu                     = Menu
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_855ExtScn02', @nScn AS Scn, @nStep AS Step

   IF @nFunc = 855
   BEGIN
      IF @nStep = 1 AND @nScn = 814 -- redirect to new 1st scn
      BEGIN

         IF @nDebugFlag = 1
            SELECT 'Step1, Scn 814, redirect to new 1st screen'
         
         SET @cOutField01 = ''
         SET @cOutField02 = ''
         SET @cFieldAttr01 = ''
         SET @cFieldAttr02 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 1
         SET @nAfterScn = 6628
         SET @nAfterStep = 99

         SET @cUDF01 = '' --loadkey
         SET @cUDF02 = '' --dropid

         GOTO Quit

      END --step1, scn
      IF @nStep = 2 AND @nScn = 815 --Statictic screen
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Step2, Scn 815, redirect to new 2nd screen'

         --prepare the common output fields
         SET @cOutField01 = @cLoadKey -- Loadkey

         SELECT @cOutField02 = CAST(COUNT(DISTINCT PD.DropID) AS NVARCHAR(5)) --Pallets Picked
         FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
         JOIN dbo.PickDetail PD WITH (NOLOCK) 
            ON LPD.OrderKey = PD.OrderKey
         WHERE LPD.LoadKey = @cLoadKey    
            AND PD.StorerKey = @cStorerKey
            AND PD.ShipFlag <> 'Y'
            AND PD.Status = @cPickConfirmStatus  

         SELECT @cOutField03 = CAST(COUNT(DISTINCT DropID) AS NVARCHAR(5)) --Pallets Audited
         FROM rdt.RDTPPA WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND LoadKey = @cLoadKey

         SELECT @cOutField04 = CAST(COUNT(PD.PickDetailKey) AS NVARCHAR(5)) --Pending Picks
         FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
         JOIN dbo.PickDetail PD WITH (NOLOCK) 
            ON LPD.OrderKey = PD.OrderKey
         WHERE LPD.LoadKey = @cLoadKey    
            AND PD.StorerKey = @cStorerKey
            AND PD.ShipFlag <> 'Y'
            AND PD.Status IN ('0','3')

         SELECT @cOutField05 = CAST(COUNT(PD.PickDetailKey) AS NVARCHAR(5)) --Short Picks
         FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
         JOIN dbo.PickDetail PD WITH (NOLOCK) 
            ON LPD.OrderKey = PD.OrderKey
         WHERE LPD.LoadKey = @cLoadKey    
            AND PD.StorerKey = @cStorerKey
            AND PD.ShipFlag <> 'Y'
            AND PD.Status = '4'


         SET @cOutField06 = @cDropID -- DropID

         IF rdt.rdtGetConfig (@nFunc, 'PPAShowSummary', @cStorerKey) = '1'
         BEGIN
            SELECT @nCSKU = 0, @nCQTY = 0, @nPSKU = 0, @nPQTY = 0
            EXECUTE rdt.rdt_PostPickAudit_GetStat @nMobile, @nFunc, 
               '',--@cRefNo, 
               '',--@cPickSlipNo, 
               '',--@cLoadKey, 
               '',--@cOrderKey, 
               @cDropID, 
               '',--@cID, 
               '',--@cTaskDetailKey, 
               @cStorerKey, 
               @cFacility, 
               @cPUOM,
               @nCSKU = @nCSKU OUTPUT,
               @nCQTY = @nCQTY OUTPUT,
               @nPSKU = @nPSKU OUTPUT,
               @nPQTY = @nPQTY OUTPUT

            SET @cSKUStat = CAST( @nCSKU AS NVARCHAR( 10)) + '/' + CAST( @nPSKU AS NVARCHAR( 10))
            SET @cQTYStat = CAST( @nCQty AS NVARCHAR( 10)) + '/' + CAST( @nPQty AS NVARCHAR( 10))

            SET @cOutField07 = @cSKUStat
            SET @cOutField08 = @cQTYStat

            SET @nAfterScn = 6670 -- Load Statistic screen with drop id
            SET @nAfterStep = 99
         END
         ELSE
         BEGIN
            SET @nAfterScn = 6629 --Load Statictic screen
            SET @nAfterStep = 99
         END
      END --step2, scn
      ELSE IF @nStep = 99
      BEGIN
         IF @nScn = 6628
         /************************************************************************************
         Scn = 6628. Load, Dropid screen
            LoadKey    (field01, input)
            DropID     (field02, input)
         ************************************************************************************/
         BEGIN
            IF @nInputKey = 0
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'St99, Scn 6628, Inputkey = 0'
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
               SET @nAfterScn  = @nMenu
               SET @nAfterStep = 0
               SET @cOutField01 = '' -- LoadKey
               SET @cOutField02 = '' -- Drop id
               SET @cLoadKey = ''
               SET @cDropID = ''
            END
            ELSE IF @nInputKey = 1
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'St99, Scn 6628, Inputkey = 1'

               SET @cLoadKey = @cInField01
               SET @cDropID = @cInField02

               IF @cInField01 = ''
               BEGIN
                  SET @nErrNo = 242301
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Load required
                  EXEC rdt.rdtSetFocusField @nMobile, 1
                  GOTO Scn_6628_Fail
               END

               IF NOT EXISTS (SELECT 1 FROM dbo.LoadPlanDetail WITH(NOLOCK) WHERE LoadKey = @cLoadKey)
               BEGIN
                  SET @nErrNo = 242302
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Invalid loadkey
                  EXEC rdt.rdtSetFocusField @nMobile, 1
                  GOTO Scn_6628_Fail
               END

               IF NOT EXISTS (SELECT 1 FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                              JOIN dbo.PickDetail PD WITH (NOLOCK) 
                                 ON LPD.OrderKey = PD.OrderKey
                              WHERE LPD.LoadKey = @cLoadKey    
                                 AND PD.StorerKey = @cStorerKey
                                 AND PD.ShipFlag <> 'Y'
                                 AND PD.Status NOT IN ('4','9'))
               BEGIN
                  SET @nErrNo = 242303
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- No pickdetail
                  EXEC rdt.rdtSetFocusField @nMobile, 1
                  GOTO Scn_6628_Fail
               END

               IF @cSkipChkPSlipMustScanIn <> '1'
               BEGIN
                  -- Validate all pickslip already scan in
                  IF EXISTS( SELECT 1
                     FROM dbo.LoadPlan LP WITH (NOLOCK)
                        INNER JOIN dbo.PickHeader PH WITH (NOLOCK) ON PH.ExternOrderKey = LP.LoadKey
                        LEFT OUTER JOIN dbo.PickingInfo [PI] WITH (NOLOCK) ON [PI].PickSlipNo = PH.PickHeaderKey
                     WHERE LP.LoadKey = @cLoadKey
                        AND [PI].ScanInDate IS NULL)
                  BEGIN
                     SET @nErrNo = 242305
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Not Scan-in
                     EXEC rdt.rdtSetFocusField @nMobile, 1
                     GOTO Scn_6628_Fail
                  END
               END

               -- (james05)
               IF @cSkipChkPSlipMustScanOut <> '1'
               BEGIN
                  -- Validate all pickslip already scan out
                  IF EXISTS( SELECT 1
                     FROM dbo.LoadPlan LP WITH (NOLOCK)
                        INNER JOIN dbo.PickHeader PH WITH (NOLOCK) ON PH.ExternOrderKey = LP.LoadKey
                        LEFT OUTER JOIN dbo.PickingInfo [PI] WITH (NOLOCK) ON [PI].PickSlipNo = PH.PickHeaderKey
                     WHERE LP.LoadKey = @cLoadKey
                        AND [PI].ScanOutDate IS NULL)
                  BEGIN
                     SET @nErrNo = 242306
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --Not Scan-out
                     EXEC rdt.rdtSetFocusField @nMobile, 1
                     GOTO Scn_6628_Fail
                  END
               END

               --Validate drop id
               IF @cDropID <> ''
               BEGIN
                  IF NOT EXISTS (SELECT 1 FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                              JOIN dbo.PickDetail PD WITH (NOLOCK) 
                                 ON LPD.OrderKey = PD.OrderKey
                              WHERE LPD.LoadKey = @cLoadKey    
                                 AND PD.StorerKey = @cStorerKey
                                 AND PD.DropID = @cDropID
                                 AND PD.ShipFlag <> 'Y'
                                 AND PD.Status = @cPickConfirmStatus)
                  BEGIN
                     SET @nErrNo = 242304
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Invalid drop id
                     EXEC rdt.rdtSetFocusField @nMobile, 1
                     GOTO Scn_6628_Fail
                  END
               END

               --prepare the common output fields
               SET @cOutField01 = @cLoadKey -- Loadkey

               SELECT @cOutField02 = CAST(COUNT(DISTINCT PD.DropID) AS NVARCHAR(5)) --Pallets Picked
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) 
                  ON LPD.OrderKey = PD.OrderKey
               WHERE LPD.LoadKey = @cLoadKey    
                  AND PD.StorerKey = @cStorerKey
                  AND PD.ShipFlag <> 'Y'
                  AND PD.Status = @cPickConfirmStatus  

               SELECT @cOutField03 = CAST(COUNT(DISTINCT DropID) AS NVARCHAR(5)) --Pallets Audited
               FROM rdt.RDTPPA WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND LoadKey = @cLoadKey

               SELECT @cOutField04 = CAST(COUNT(PD.PickDetailKey) AS NVARCHAR(5)) --Pending Picks
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) 
                  ON LPD.OrderKey = PD.OrderKey
               WHERE LPD.LoadKey = @cLoadKey    
                  AND PD.StorerKey = @cStorerKey
                  AND PD.ShipFlag <> 'Y'
                  AND PD.Status IN ('0','3')

               SELECT @cOutField05 = CAST(COUNT(PD.PickDetailKey) AS NVARCHAR(5)) --Short Picks
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) 
                  ON LPD.OrderKey = PD.OrderKey
               WHERE LPD.LoadKey = @cLoadKey    
                  AND PD.StorerKey = @cStorerKey
                  AND PD.ShipFlag <> 'Y'
                  AND PD.Status = '4'

               IF @cDropID <> ''
               BEGIN
                  SET @cOutField06 = @cDropID -- DropID

                  IF rdt.rdtGetConfig (@nFunc, 'PPAShowSummary', @cStorerKey) = '1'
                  BEGIN
                     SELECT @nCSKU = 0, @nCQTY = 0, @nPSKU = 0, @nPQTY = 0
                     EXECUTE rdt.rdt_PostPickAudit_GetStat @nMobile, @nFunc, 
                        '',--@cRefNo, 
                        '',--@cPickSlipNo, 
                        '', --@cLoadKey, 
                        '',--@cOrderKey, 
                        @cDropID, 
                        '',--@cID, 
                        '',--@cTaskDetailKey, 
                        @cStorerKey, 
                        @cFacility, 
                        @cPUOM,
                        @nCSKU = @nCSKU OUTPUT,
                        @nCQTY = @nCQTY OUTPUT,
                        @nPSKU = @nPSKU OUTPUT,
                        @nPQTY = @nPQTY OUTPUT

                     SET @cSKUStat = CAST( @nCSKU AS NVARCHAR( 10)) + '/' + CAST( @nPSKU AS NVARCHAR( 10))
                     SET @cQTYStat = CAST( @nCQty AS NVARCHAR( 10)) + '/' + CAST( @nPQty AS NVARCHAR( 10))

                     SET @cOutField07 = @cSKUStat
                     SET @cOutField08 = @cQTYStat
                  END
                  ELSE
                  BEGIN
                     SET @cSKUStat = ''
                     SET @cQTYStat = ''
                  END

                  SET @nAfterScn = 6670 -- Load Statistic screen with drop id
                  SET @nAfterStep = 99
               END
               ELSE
               BEGIN
                  SET @nAfterScn = 6629 --Load Statictic screen
                  SET @nAfterStep = 99
               END

               --Pass the loadkey and dropid to main sp
               SET @cUDF01 = @cLoadKey
               SET @cUDF02 = @cDropID
            END -- inputkey = 1

            GOTO Quit

            Scn_6628_Fail:
               -- Stay at 6628
               SET @cOutField01 = ''
               SET @cOutField02 = ''

               SET @cLoadKey = ''
               SET @cDropID = ''

               GOTO Quit
         END--6628
         IF @nScn = 6629
         /************************************************************************************
         Scn = 6629. Load statictic screen
         ************************************************************************************/
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'st99,6629 screen'
            SET @cOutField01 = @cLoadKey
            SET @cOutField02 = ''
            EXEC rdt.rdtSetFocusField @nMobile, 2

            SET @nAfterScn = 6628
            SET @nAfterStep = 99

            SET @cUDF01 = ''
            SET @cUDF02= ''
         END --6629
         IF @nScn = 6670
         /************************************************************************************
         Scn = 6670. Load statictic with drop id screen
         ************************************************************************************/
         BEGIN
            IF @nInputKey = 1 -- Yes OR Send
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'st99, 6670 screen, Inputkey = 1'
               -- Set next screen var
               SET @cSKU = ''
               --SET @cPackQTYIndicator = ''
               --SET @cPrePackIndicator = ''

               -- Disable QTY field
               IF @cDisableQTYField = '1'
               BEGIN
                  SET @cFieldAttr09 = 'O' -- PQTY
                  SET @cFieldAttr10 = 'O' -- MQTY
               END

               IF @cConvertQTYSP <> '' AND EXISTS( SELECT TOP 1 1 FROM dbo.sysobjects WHERE name = @cConvertQTYSP AND type = 'P')
               BEGIN
                  IF @cPUOM = '6'
                     SET @cFieldAttr09 = 'O' -- @nPQTY
               END
               
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

               /*
               --(cc02)
               INSERT INTO @tDataCapture (Variable, Value) VALUES 
                  ('@cRefNo',       @cRefNo), 
                  ('@cPickSlipNo',  @cPickSlipNo), 
                  ('@cLoadKey',     @cLoadKey), 
                  ('@cOrderKey',    @cOrderKey), 
                  ('@cDropID',      @cDropID), 
                  ('@cID',          @cID), 
                  ('@cTaskDetailKey',  @cTaskDetailKey), 
                  ('@cSKU',         @cSKU), 
                  ('@cBarCode',     ''), 
                  ('@nQTY',         CAST( @nQTY AS NVARCHAR( 10))), 
                  ('@nCSKU',        CAST( @nCSKU AS NVARCHAR( 10))), 
                  ('@nCQTY',        CAST( @nCQTY AS NVARCHAR( 10))), 
                  ('@nPSKU',        CAST( @nPSKU AS NVARCHAR( 10))), 
                  ('@nPQTY',        CAST( @nPQTY AS NVARCHAR( 10))), 
                  ('@cOption',      @cOption)

               SET @cCaptureData = '0'
               SET @cCaptureDataInput = ''
               EXEC rdt.rdt_PPAVerifyDataCapture @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'CHECK', @tDataCapture,
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
                  @cCaptureData OUTPUT,@nErrNo      OUTPUT,  @cErrMsg      OUTPUT

               IF @nErrNo <> 0
                  GOTO Quit

               IF @cCaptureData = '1'
               BEGIN
                  SET @cOutField01 = @cPickSlipNo
                  SET @cOutField02 = ''
                  SET @cOutField03 = ''
                  SET @cOutField04 = @cCaptureDataColName
                  SET @cOutField05 = ''
                  SET @cOutField06 = ''
                  
                  SET @nFromScn = @nScn
                  SET @nFromStep = @nStep
                  
                  -- Go to data capture screen
                  SET @nScn = @nScn + 4
                  SET @nStep = @nStep + 5

                  GOTO Quit
               END*/
               
               --SET @cCaptureDataInput = ''  --(cc02)
               -- Go to next screen  
               SET @nAfterScn = 816 --SKU qty screen
               SET @nAfterStep = 3  
         
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
                        @nMobile, @nFunc, @cLangCode, 2, @nStep, @nInputKey, @cFacility, @cStorerKey, @tExtInfo,   
                        @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT  
                  
                     SET @cOutField15 = @cExtendedInfo  
                  END  
               END  
            END
            
            IF @nInputKey = 0 -- Esc OR No
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'st99, 6670 screen, Inputkey = 0'
               -- Prompt discrepancy
               IF @cPPAPromptDiscrepancy = '1'
               BEGIN
                  SELECT @nVariance = 0
                  EXECUTE rdt.rdt_PostPickAudit_GetStat @nMobile, @nFunc, 
                     '',--@cRefNo, 
                     '',--@cPickSlipNo, 
                     '',--@cLoadKey, 
                     '',--@cOrderKey, 
                     @cDropID, 
                     '',--@cID, 
                     '',--@cTaskDetailKey, 
                     @cStorerKey, 
                     @cFacility, 
                     @cPUOM,
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
                              @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, @cSKU, @nQty, '',         
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
                     
                     SET @nAfterScn = 6671
                     SET @nAfterStep = 99

                     GOTO Quit
                  END -- variance = 1
                  ELSE --(cc02)
                  BEGIN
                     INSERT INTO @tDataCapture (Variable, Value) VALUES 
                        ('@cRefNo',       ''), 
                        ('@cPickSlipNo',  ''), 
                        ('@cLoadKey',     @cLoadKey), 
                        ('@cOrderKey',    ''), 
                        ('@cDropID',      @cDropID), 
                        ('@cID',          ''), 
                        ('@cTaskDetailKey',  ''), 
                        ('@cSKU',         @cSKU), 
                        ('@cBarCode',     ''), 
                        ('@nQTY',         CAST( @nQTY AS NVARCHAR( 10))), 
                        ('@nCSKU',        CAST( @nCSKU AS NVARCHAR( 10))), 
                        ('@nCQTY',        CAST( @nCQTY AS NVARCHAR( 10))), 
                        ('@nPSKU',        CAST( @nPSKU AS NVARCHAR( 10))), 
                        ('@nPQTY',        CAST( @nPQTY AS NVARCHAR( 10))), 
                        ('@cOption',      @cOption)

                     SET @cCaptureData = '0'
                     SET @cCaptureDataInput = ''
                     EXEC rdt.rdt_PPAVerifyDataCapture @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'CHECK', @tDataCapture,
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
                        @cCaptureData OUTPUT,@nErrNo      OUTPUT,  @cErrMsg      OUTPUT

                     IF @nErrNo <> 0
                        GOTO Quit
                  
                     -- No variance and only export order need to capture PackInfo
                     IF @cCapturePackInfo <> '' AND @cCaptureData = '1' 
                     BEGIN
                        -- Get PackInfo    
                        SET @cCartonType = ''    
                        SET @cWeight = ''    
                        SET @cCube = ''    
                        SET @cRefNo = ''   
                        
                        -- Prepare capturePackInfo screen var    
                        SET @cOutField01 = @cCartonType    
                        SET @cOutField02 = @cWeight   
                        SET @cOutField03 = @cCube       
                  
                        -- Enable disable field    
                        SET @cFieldAttr01 = CASE WHEN CHARINDEX( 'T', @cCapturePackInfo) = 0 THEN 'O' ELSE '' END    
                        SET @cFieldAttr02 = CASE WHEN CHARINDEX( 'C', @cCapturePackInfo) = 0 THEN 'O' ELSE '' END    
                        SET @cFieldAttr03 = CASE WHEN CHARINDEX( 'W', @cCapturePackInfo) = 0 THEN 'O' ELSE '' END    
                                 
                        -- Position cursor    
                        IF @cFieldAttr01 = '' AND @cOutField01 = ''  EXEC rdt.rdtSetFocusField @nMobile, 1 ELSE    
                        IF @cFieldAttr02 = '' AND @cOutField02 = '0' EXEC rdt.rdtSetFocusField @nMobile, 2 ELSE    
                        IF @cFieldAttr03 = '' AND @cOutField03 = '0' EXEC rdt.rdtSetFocusField @nMobile, 3     
                                       
                        SET @nFromScn = @nScn
                        SET @nFromStep = @nStep
                  
                        -- Go to capture PackInfo screen    
                        SET @nAfterScn = 5980   
                        SET @nAfterStep = 8    
                        
                        GOTO Quit    
                     END
                  END -- no variance
               END --Show discrepancy

               -- Prompt print packing list
               IF @cPPAPrintPackListSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cPPAPrintPackListSP AND type = 'P')
                  BEGIN
                     SET @cPrintPackList = ''

                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cPPAPrintPackListSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, @cSKU, @nQTY, @cOption, @cType, ' +
                        ' @nErrNo OUTPUT, @cErrMsg OUTPUT, @cPrintPackList OUTPUT, @cID, @cTaskDetailKey '
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
                        '@nErrNo          INT OUTPUT,    ' +
                        '@cErrMsg         NVARCHAR( 20)OUTPUT, ' +
                        '@cPrintPackList  NVARCHAR( 1) OUTPUT, ' + 
                        '@cID             NVARCHAR( 18), ' + 
                        '@cTaskDetailKey  NVARCHAR( 10)  ' 

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, @cSKU, @nQTY, @cOption, 'CHECK',
                        @nErrNo OUTPUT, @cErrMsg OUTPUT, @cPrintPackList OUTPUT, @cID, @cTaskDetailKey

                     IF @cPrintPackList = '1'
                     BEGIN
                        -- Go to print pack list screen
                        SET @cOutField01 = '' -- Option
                        SET @nAfterScn = 818
                        SET @nAfterStep = 5
                        GOTO Quit
                     END
                  END
               END --show print packing list

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
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, @cSKU, @nQty, '',         
                        @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey,@cReasonCode OUTPUT   

                     IF @nErrNo <> 0
                        GOTO Quit
                  END
               END

               SET @cOutField01 = @cLoadKey --loadkey
               SET @cOutField02 = '' --dropid

               -- Enable disable field
               SET @cFieldAttr01 = '' 
               SET @cFieldAttr02 = '' 

               -- Reset prev screen var
               SET @cRefNo = ''
               SET @cPickSlipNo = ''
               SET @cLoadKey = ''
               SET @cOrderKey = ''
               SET @cDropID = ''
               SET @cID = ''
               SET @cTaskDetailKey = ''



               -- Go to prev screen
               SET @nAfterScn = 6628
               SET @nAfterStep = 99

               SET @cUDF01 = @cLoadKey
               SET @cUDF02 = @cDropID

               GOTO Quit
            END -- inputkey = 0
         END --6670
         IF @nScn = 6671
         /************************************************************************************
         Scn = 6671. Discrepancy screen
            DISCREPANCY FOUND
            2=Exit anyway
            9=Recount
            OPTION (field01)
         ************************************************************************************/
         BEGIN
            IF @nInputKey = 1 -- Yes OR Send
            BEGIN
               -- Screen mapping
               SET @cOption = @cInField01 -- Option
               SET @cReasonCode = CASE WHEN @cCaptureReasonCode='1' THEN @cInField02 ELSE '' END    

               -- Check option blank
               IF @cOption = ''
               BEGIN
                  SET @nErrNo = 242307
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- OptionRequired
                  GOTO Scn_6671_Fail
               END

               -- Check option valid
               IF @cOption NOT IN ('2', '9')
               BEGIN
                  SET @nErrNo = 242308
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Invalid Option
                  GOTO Scn_6671_Fail
               END
               
               IF @cCaptureReasonCode='1'        
               BEGIN        
                  IF @cReasonCode = ''        
                  BEGIN        
                     SET @nErrNo = 242309        
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- ReasonCodeRequired        
                     GOTO Scn_6671_Fail        
                  END        
               END 

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
                        ('@cUserName',    @cUserName),
                        ('@cOption',      @cOption)

                     SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedValidateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @cStorerKey, @cFacility, @cRefNo, @cOrderKey, @cDropID, @cLoadKey, @cPickSlipNo, ' + 
                        ' @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey, @tExtValidate '
                     SET @cSQLParam =
                        '@nMobile        INT, ' +
                        '@nFunc          INT, ' +
                        '@cLangCode      NVARCHAR( 3),  ' +
                        '@nStep          INT,           ' +
                        '@cStorerKey        NVARCHAR( 15), ' +
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
                        GOTO Scn_6671_Fail
                     END
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
                        GOTO Scn_6671_Fail  
                  END
               END

               IF @cOption = '2'
               BEGIN
                  SET @cOutField01 = @cLoadKey --loadkey
                  SET @cOutField02 = '' --dropid

                  -- Enable disable field
                  SET @cFieldAttr01 = '' 
                  SET @cFieldAttr02 = '' 
                  SET @cRefNo = ''
                  SET @cPickSlipNo = ''
                  SET @cLoadKey = ''
                  SET @cOrderKey = ''
                  SET @cDropID = ''
                  SET @cID = ''
                  SET @cTaskDetailKey = ''

                  -- Go to 1st  screen
                  SET @nAfterScn = 6628
                  SET @nAfterStep = 99

                  SET @cUDF01 = ''--@cLoadKey
                  SET @cUDF02 = ''--@cDropID
               END --Option=2

               IF @cOption = '9' --recount
               BEGIN
                  DELETE FROM RDT.RDTPPA WHERE StorerKey = @cStorerKey AND DropID = @cDropID

                  -- Set next screen var
                  SET @cSKU = ''
                  --SET @cPackQTYIndicator = ''
                  --SET @cPrePackIndicator = ''

                  -- Disable QTY field
                  IF @cDisableQTYField = '1'
                  BEGIN
                     SET @cFieldAttr09 = 'O' -- PQTY
                     SET @cFieldAttr10 = 'O' -- MQTY
                  END

                  IF @cConvertQTYSP <> '' AND EXISTS( SELECT TOP 1 1 FROM dbo.sysobjects WHERE name = @cConvertQTYSP AND type = 'P')
                  BEGIN
                     IF @cPUOM = '6'
                        SET @cFieldAttr09 = 'O' -- @nPQTY
                  END
                  
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

                  /*
                  --(cc02)
                  INSERT INTO @tDataCapture (Variable, Value) VALUES 
                     ('@cRefNo',       @cRefNo), 
                     ('@cPickSlipNo',  @cPickSlipNo), 
                     ('@cLoadKey',     @cLoadKey), 
                     ('@cOrderKey',    @cOrderKey), 
                     ('@cDropID',      @cDropID), 
                     ('@cID',          @cID), 
                     ('@cTaskDetailKey',  @cTaskDetailKey), 
                     ('@cSKU',         @cSKU), 
                     ('@cBarCode',     ''), 
                     ('@nQTY',         CAST( @nQTY AS NVARCHAR( 10))), 
                     ('@nCSKU',        CAST( @nCSKU AS NVARCHAR( 10))), 
                     ('@nCQTY',        CAST( @nCQTY AS NVARCHAR( 10))), 
                     ('@nPSKU',        CAST( @nPSKU AS NVARCHAR( 10))), 
                     ('@nPQTY',        CAST( @nPQTY AS NVARCHAR( 10))), 
                     ('@cOption',      @cOption)

                  SET @cCaptureData = '0'
                  SET @cCaptureDataInput = ''
                  EXEC rdt.rdt_PPAVerifyDataCapture @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'CHECK', @tDataCapture,
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
                     @cCaptureData OUTPUT,@nErrNo      OUTPUT,  @cErrMsg      OUTPUT

                  IF @nErrNo <> 0
                     GOTO Quit

                  IF @cCaptureData = '1'
                  BEGIN
                     SET @cOutField01 = @cPickSlipNo
                     SET @cOutField02 = ''
                     SET @cOutField03 = ''
                     SET @cOutField04 = @cCaptureDataColName
                     SET @cOutField05 = ''
                     SET @cOutField06 = ''
                     
                     SET @nFromScn = @nScn
                     SET @nFromStep = @nStep
                     
                     -- Go to data capture screen
                     SET @nScn = @nScn + 4
                     SET @nStep = @nStep + 5

                     GOTO Quit
                  END*/
                  
                  --SET @cCaptureDataInput = ''  --(cc02)
                  -- Go to next screen  
                  SET @nAfterScn = 816 --SKU qty screen
                  SET @nAfterStep = 3  
            
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
                           @nMobile, @nFunc, @cLangCode, 2, @nStep, @nInputKey, @cFacility, @cStorerKey, @tExtInfo,   
                           @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT  
                     
                        SET @cOutField15 = @cExtendedInfo  
                     END  
                  END  
               END --Option = 9

            END--inputkey = 1

            IF @nInputKey = 0 -- Esc OR No
            BEGIN
               --prepare the common output fields
               SET @cOutField01 = @cLoadKey -- Loadkey

               SELECT @cOutField02 = CAST(COUNT(DISTINCT PD.DropID) AS NVARCHAR(5)) --Pallets Picked
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) 
                  ON LPD.OrderKey = PD.OrderKey
               WHERE LPD.LoadKey = @cLoadKey    
                  AND PD.StorerKey = @cStorerKey
                  AND PD.ShipFlag <> 'Y'
                  AND PD.Status = @cPickConfirmStatus  

               SELECT @cOutField03 = CAST(COUNT(DISTINCT DropID) AS NVARCHAR(5)) --Pallets Audited
               FROM rdt.RDTPPA WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND LoadKey = @cLoadKey

               SELECT @cOutField04 = CAST(COUNT(PD.PickDetailKey) AS NVARCHAR(5)) --Pending Picks
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) 
                  ON LPD.OrderKey = PD.OrderKey
               WHERE LPD.LoadKey = @cLoadKey    
                  AND PD.StorerKey = @cStorerKey
                  AND PD.ShipFlag <> 'Y'
                  AND PD.Status IN ('0','3')

               SELECT @cOutField05 = CAST(COUNT(PD.PickDetailKey) AS NVARCHAR(5)) --Short Picks
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) 
                  ON LPD.OrderKey = PD.OrderKey
               WHERE LPD.LoadKey = @cLoadKey    
                  AND PD.StorerKey = @cStorerKey
                  AND PD.ShipFlag <> 'Y'
                  AND PD.Status = '4'

               SET @cOutField06 = @cDropID -- DropID

               IF rdt.rdtGetConfig (@nFunc, 'PPAShowSummary', @cStorerKey) = '1'
               BEGIN
                  SELECT @nCSKU = 0, @nCQTY = 0, @nPSKU = 0, @nPQTY = 0
                  EXECUTE rdt.rdt_PostPickAudit_GetStat @nMobile, @nFunc, 
                     '',--@cRefNo, 
                     '',--@cPickSlipNo, 
                     '', --@cLoadKey, 
                     '',--@cOrderKey, 
                     @cDropID, 
                     '',--@cID, 
                     '',--@cTaskDetailKey, 
                     @cStorerKey, 
                     @cFacility, 
                     @cPUOM,
                     @nCSKU = @nCSKU OUTPUT,
                     @nCQTY = @nCQTY OUTPUT,
                     @nPSKU = @nPSKU OUTPUT,
                     @nPQTY = @nPQTY OUTPUT

                  SET @cSKUStat = CAST( @nCSKU AS NVARCHAR( 10)) + '/' + CAST( @nPSKU AS NVARCHAR( 10))
                  SET @cQTYStat = CAST( @nCQty AS NVARCHAR( 10)) + '/' + CAST( @nPQty AS NVARCHAR( 10))

                  SET @cOutField07 = @cSKUStat
                  SET @cOutField08 = @cQTYStat
               END
               ELSE
               BEGIN
                  SET @cSKUStat = ''
                  SET @cQTYStat = ''
               END

               SET @nAfterScn = 6670 -- Load Statistic screen with drop id
               SET @nAfterStep = 99

               --Pass the loadkey and dropid to main sp
               SET @cUDF01 = @cLoadKey
               SET @cUDF02 = @cDropID

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
            END
            GOTO Quit

            Scn_6671_Fail:
               GOTO Quit
         END--6671
      END -- step99
      -- fcr 1109
      /*
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
      */
   END --855

   GOTO Quit

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_855ExtScn02 to nSQL
GO
