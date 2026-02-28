SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/************************************************************************/  
/* Store procedure: rdt_1812ExtScn08                                    */  
/* Copyright      : MAERSK                                              */  
/*                                                                      */  
/* Purpose:                                                             */  
/*                                                                      */  
/* Date       Rev     Author   Purposes                                 */  
/* 2026-01-20 1.0.0   Dennis   FCR-9664                                 */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1812ExtScn08] (  
   @nMobile          INT,           
   @nFunc            INT,           
   @cLangCode        NVARCHAR( 3),  
   @nStep            INT,           
   @nScn             INT,           
   @nInputKey        INT,           
   @cFacility        NVARCHAR( 5),  
   @cStorerKey       NVARCHAR( 15), 
   @tExtScnData      VariableTable READONLY,
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
   @nAction          INT, --0 Jump Screen, 1 Prepare output fields .....
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
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT, 
   @cUDF30 NVARCHAR( MAX)  OUTPUT   --to support max length parameter output
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @nDebugFlag  INT = 0 --V1.1.0

   DECLARE
   @nMOBRECStep      INT,
   @nMOBRECScn       INT,
   @cTaskdetailKey   NVARCHAR( 10), 
   @cDropID          NVARCHAR( 20),
   @cQTY             NVARCHAR( 20),
   @nQTY             INT, 
   @cToLOC           NVARCHAR( 10),
   @cSQL             NVARCHAR(MAX),
   @cTTMStrategykey  NVARCHAR(10),
   @cSQLParam        NVARCHAR(MAX),
   @cExtendedInfo1   NVARCHAR(20),
   @cExtendedInfoSP  NVARCHAR(20),
   @cSuggSKU         NVARCHAR(20),
   @cFromID          NVARCHAR(18),
   @cOption          NVARCHAR(1),
   @tExtData         VariableTable,
   @cTaskDetailPUOM  NVARCHAR(20),
   @cReasonCode      NVARCHAR(10),

   @TypeOrder INT,
   @cPickMethodAUX  NVARCHAR( 10);

   -- Screen constant  
   DECLARE @nScn_ToLane    INT = 6520  
   DECLARE @nScn_ReasonCode INT = 6620  
   DECLARE @nScn_Message   INT = 4026  
   DECLARE @nStep_Message  INT = 7  

   -- Session var  
   DECLARE @cContinueProcess         NVARCHAR(10)
   DECLARE @cRemoveTaskFromUserQueue NVARCHAR(10)
   DECLARE @cTaskStatus              NVARCHAR(10)
   DECLARE @cToLane        NVARCHAR( 20)
   DECLARE @cSuggToLane    NVARCHAR( 20)
   DECLARE @cExtMbolKey    NVARCHAR( 15)
   DECLARE @cMbolKey       NVARCHAR( 10)
   DECLARE @cPickMethod    NVARCHAR( 10)
   DECLARE @cSuggFromLOC   NVARCHAR( 10)
   DECLARE @cSuggID        NVARCHAR( 18)
   DECLARE @cWaveKey       NVARCHAR( 10)
   DECLARE @cOrderKey      NVARCHAR( 10)
   DECLARE @cOrderLineNum  NVARCHAR( 10)
   DECLARE @nShipperCnt INT = 0
   DECLARE @nFromStep   INT
   DECLARE @nCartonQTY INT
   DECLARE @nFromScn    INT,
   @tPalletLabel   VariableTable,
   @cBarcode            NVARCHAR( MAX),
   @cHoldID        NVARCHAR( 20),
   @cSKU                NVARCHAR(20),
   @cSKUValidated  NVARCHAR( 2),
   @cHoldLoc       NVARCHAR( 20),
   @cMoveQTYAlloc  NVARCHAR( 1),
   @cAreaKey       NVARCHAR(10),
   @nRowCount      INT,
   @cTaskDetailUOM      NVARCHAR( 5),
   @cTTMTaskType        NVARCHAR(10),
   @cUserName      NVARCHAR(18),
   @cSuggToLOC          NVARCHAR(10),
   @c_outstring         NVARCHAR(255),
   @b_success           INT = 1,
   @cSuggLOT            NVARCHAR(10),
   @nPQTY_RPL           INT,
   @nMQTY_RPL           INT,
   @cListKey            NVARCHAR(10),
   @cAutoGenDROPIDSP    NVARCHAR(20),
   @cExtendedValidateSP NVARCHAR(20),
   @cExtendedUpdateSP   NVARCHAR( 20),
   @cDefaultFromID      NVARCHAR( 1),
   @cSwapTaskSP         NVARCHAR(20),
   @cLottableCode       NVARCHAR( 20),
   @cPUOM               NVARCHAR( 1),
   @cDefaultToLOC       NVARCHAR( 10),
   @cDispStyleColorSize NVARCHAR( 1),
   @cSKUDesc            NVARCHAR(60),
   @cDisableQTYField    NVARCHAR(1),
   @nPUOM_Div           INT,
   @cPUOM_Desc          NCHAR( 5),
   @cMUOM_Desc          NCHAR( 5),
   @cPalletLabel        NVARCHAR( 20),
   @cPrinter_Paper      NVARCHAR( 10),
   @cPrinter            NVARCHAR( 10),
   @nQTY_RPL            INT,
   @nPQTY               INT,
   @nMQTY               INT,
   @nMorePage           INT,
   @cNewTaskDetailKey   NVARCHAR( 10),
   @cAutoID             NVARCHAR( 18)
   DECLARE @c_InventoryHoldKey NVARCHAR(10)
   DECLARE @nTranCount  INT
   DECLARE @cAutoGenDropID NVARCHAR( 1)

   DECLARE @cEquipmentProfileKey NVARCHAR(10) --V1.1.0
   DECLARE @bSuccess INT

   DECLARE @tOptions TABLE
   (
      count     INT IDENTITY(1,1),
      LOC       NVARCHAR(10),
      ID        NVARCHAR(18),
      SKU       NVARCHAR(20),
      QTY       INT
   )
   DECLARE @tInventory TABLE
   (
      count     INT IDENTITY(1,1),
      LOC       NVARCHAR(10),
      ID        NVARCHAR(18),
      SKU       NVARCHAR(20),
      QTY       INT
   )
   IF @nDebugFlag = 1 --V1.1.0
      SELECT 'Executing rdt_1812ExtScn08'

   -- Get session info  
   SELECT @nMOBRECStep      = [Step]
      ,@nMOBRECScn          = [Scn]
      ,@cPrinter            = Printer
      ,@cPrinter_Paper      = Printer_Paper
      ,@nFromScn            = [V_FromScn]
      ,@nFromStep           = [V_FromStep]
      ,@cExtendedInfoSP     = [V_String27]
      ,@cSuggSKU            = V_SKU
      ,@cPUOM               = V_UOM
      ,@cSuggLOT            = V_LOT
      ,@nQTY_RPL            =  V_TaskQTY
      ,@nQTY                =  V_QTY
      ,@cTaskDetailKey      = V_TaskDetailKey
      ,@cSuggFromLOC        = V_LOC
      ,@cSuggID             = V_ID
      ,@nPQTY               = V_PQTY
      ,@nMQTY               = V_MQTY
      ,@cAreaKey           = V_String1
      ,@cDropID             = V_String3
      ,@cPickMethod         = V_String4
      ,@cSuggToloc          = V_String5
      ,@cReasonCode         = V_String6
      ,@cListKey            = V_String7
      ,@cDisableQTYField   = V_String8
      ,@cSwapTaskSP        = V_String9
      ,@cLottableCode      = V_String13
      ,@cTaskDetailUOM     = V_String14
      ,@cTaskDetailPUOM    = V_String15
      ,@cDispStyleColorSize= V_String17
      ,@cExtendedUpdateSP  = V_String22
      ,@cDefaultToLOC      = V_String23
      ,@cMoveQTYAlloc      = V_String24
      ,@cSKUValidated      = V_String25
      ,@cDefaultFromID     = V_String26
      ,@cExtendedValidateSP = V_String31
      ,@cTTMStrategykey    = V_String33
      ,@cTTMTaskType        = V_String34
      ,@cAutoGenDROPIDSP    = V_String43
      ,@cToLOC              = V_String44
      ,@cUserName           = UserName
   FROM rdt.rdtMobRec WITH (NOLOCK)  
   WHERE Mobile = @nMobile  

   SET @cAutoGenDropID = rdt.RDTGetConfig( @nFunc, 'AutoGenDropID', @cStorerKey)
   SET @cPalletLabel = rdt.RDTGetConfig( @nFunc, 'DropIDLabel', @cStorerKey)
   IF @cPalletLabel = '0'
      SET @cPalletLabel = ''
   SET @nTranCount = @@TRANCOUNT

   SELECT TOP 1 @cOrderKey = OrderKey, @cOrderLineNum = OrderLineNumber FROM dbo.PICKDETAIL WITH(NOLOCK) WHERE TaskDetailKey = @cTaskdetailKey AND Storerkey = @cStorerKey

   IF @nFunc = 1812 -- TM Case Pick  
   BEGIN
      IF @nMOBRECStep <> @nStep
      BEGIN
         IF @nStep = 1 SET @nScn = 4020   -- Scn = 4020 DropID
         IF @nStep = 2 SET @nScn = 4021   -- Scn = 4021 FromLOC
         IF @nStep = 3 SET @nScn = 4022   -- Scn = 4022 FromID
         IF @nStep = 4 SET @nScn = 4023   -- Scn = 4023 SKU, QTY
         IF @nStep = 5 SET @nScn = 4024   -- Scn = 4024 Cont next replen task / Close pallet
         IF @nStep = 6 SET @nScn = 4025  -- Scn = 4025 To LOC
         IF @nStep = 7 SET @nScn = 4026   -- Scn = 4026 Pallet is close. Next task / Exit
         IF @nStep = 8 SET @nScn = 4027   -- Scn = 4027 Short pick / Close pallet
         IF @nStep = 9 SET @nScn = 2109   -- Scn = 2100 Reason code
      END
      SET @nAfterScn = @nScn
      IF @nScn = 4020 -- DropID Scan Screen
      BEGIN
         SET @nAfterScn = 6771
         GOTO QUIT
      END
      ELSE IF @nScn = 4027 -- Short pick
      BEGIN
         SET @nAfterScn = 6811
         GOTO QUIT
      END
      ELSE IF @nScn = 4024 -- Close pallet
      BEGIN
         SET @nAfterScn = 6810
         GOTO QUIT
      END
      ELSE IF @nScn = 4026 -- EXIT TM
      BEGIN
         SET @nAfterScn = 6812
         GOTO QUIT
      END
      ELSE IF (@nMOBRECStep = 5 OR @nMOBRECStep = 8) AND @nScn = 4025 -- To LOC
      BEGIN
         SET @nAfterStep = 99
         SET @nAfterScn = 6813
         SET @cOutField01 = ''
         GOTO QUIT
      END
      ELSE IF @nMOBRECStep = 99 
      BEGIN
         IF @nMOBRECScn = 6813
         BEGIN
            IF @nInputKey = 1
            BEGIN
               SET @cOption = @cInField01
               IF @cOption = '1' -- Next Task
               BEGIN
                  -- Confirm (TaskDetail to status 5, PickDetail to status 5)
                  EXEC rdt.rdt_TM_CasePick_Confirm @nMobile, @nFunc, @cLangCode, @cUserName, @cFacility, @cStorerKey,
                     @cTaskDetailKey,
                     @cDropID,
                     @nQTY,
                     @cToLoc,
                     @cReasonCode,
                     @cListKey,
                     @nErrNo  OUTPUT,
                     @cErrMsg OUTPUT
                  IF @nErrNo <> 0
                     GOTO Quit

                  SELECT @cNewTaskDetailKey = TD.TaskDetailKey 
                  FROM TASKDETAIL TD WITH (NOLOCK) 
                  WHERE Status = '0' AND StorerKey = @cStorerKey  
                  AND TaskType = 'FCP' 
                  AND EXISTS (SELECT 1 FROM TASKDETAIL TD1 WHERE TD1.TaskDetailKey = @cTaskDetailKey AND TD1.WAVEKEY = TD.WAVEKEY AND TD1.ToLOC = TD.ToLOC)

                  IF ISNULL(@cNewTaskDetailKey, '') = ''
                  BEGIN
                     SET @nErrNo = 180012
                     SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') -- No more open tasks for this wave and location
                     GOTO QUIT
                  END
                  ELSE
                  BEGIN
                     UPDATE TASKDETAIL SET Status = '3',UserKey = @cUserName,ListKey = @cListKey WHERE TaskDetailKey = @cNewTaskDetailKey
                     SET @cUDF01 = @cNewTaskDetailKey
                     SET @nAfterStep = 0
                     SET @cOutField06 = @cNewTaskDetailKey
                     SET @cOutField07 = @cAreaKey
                     SET @cOutField08 = @cTTMStrategykey
                     SET @cOutField09 = ''
                     SET @nFromStep = '0'
                  END
               END
               ELSE IF @cOption = '9' -- Drop to Staging
               BEGIN
                  SET @cOutField01 = @cSuggFromLOC
                  SET @cOutField02 = @cSuggToLOC
                  SET @cOutField03 = CASE WHEN @cDefaultToLOC = '1' THEN @cSuggToLOC ELSE '' END

                  SET @nAfterScn = 4025
                  SET @nAfterStep = 6
                  GOTO QUIT
               END
               ELSE 
               BEGIN
                  SET @nErrNo = 180011
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InvalidInput
                  GOTO QUIT
               END
            END
            ELSE 
            BEGIN
               SET @nErrNo = 180011
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InvalidInput
               GOTO QUIT
            END
         END
      END
   END --1812

   --V1.1.0 end
   GOTO QUIT
Quit:

END    
GO
  
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON rdt.rdt_1812ExtScn08 TO NSQL 
GO  
