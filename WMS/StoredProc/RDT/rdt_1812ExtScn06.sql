SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/************************************************************************/  
/* Store procedure: rdt_1812ExtScn06                                    */  
/* Copyright      : MAERSK                                              */  
/*                                                                      */  
/* Purpose:                                                             */  
/*                                                                      */  
/* Date       Rev     Author   Purposes                                 */  
/* 2025-06-09 1.0.0   Dennis   FCR-3959                                 */
/* 2025-06-10 1.1.0   Jackc    FCR-3959 Jump to 1756 equipment screen   */ 
/* 2025-08-21 1.1.1   Dennis   FCR-3959 Fix Inventory Hold Bug          */
/* 2025-08-25 1.1.2   Dennis   FCR-3959 New Scn                         */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_1812ExtScn06] (  
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
   @cSQLParam        NVARCHAR(MAX),
   @cExtendedInfo1   NVARCHAR(20),
   @cExtendedInfoSP  NVARCHAR(20),
   @cSuggSKU         NVARCHAR(20),
   @cFromID          NVARCHAR(18),
   @cOption          NVARCHAR(1),
   @tExtData         VariableTable,
   @cTaskDetailPUOM  NVARCHAR(20),
   @cReasonCode      NVARCHAR(10)

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
   DECLARE @nShipperCnt INT = 0
   DECLARE @nFromStep   INT
   DECLARE @nCartonQTY INT
   DECLARE @nFromScn    INT,
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
   @nQTY_RPL            INT,
   @nPQTY               INT,
   @nMQTY               INT,
   @nMorePage           INT,
   @cAutoID             NVARCHAR( 18)
   DECLARE @c_InventoryHoldKey NVARCHAR(10)
   DECLARE @nTranCount  INT
   DECLARE @cNewTaskDetailKey NVARCHAR( 10)

   DECLARE @cEquipmentProfileKey NVARCHAR(10) --V1.1.0
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
      SELECT 'Executing rdt_1812ExtScn06'

   -- Get session info  
   SELECT @nMOBRECStep      = [Step]
      ,@nMOBRECScn          = [Scn]
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
      ,@cTTMTaskType        = V_String34
      ,@cAutoGenDROPIDSP    = V_String43
      ,@cToLOC              = V_String44
      ,@cUserName           = UserName
   FROM rdt.rdtMobRec WITH (NOLOCK)  
   WHERE Mobile = @nMobile  

   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN
   SAVE TRAN rdt_1812ExtScn06

   IF @nFunc = 1812 -- TM Case Pick  
   BEGIN  
      IF @nScn = 2109 -- Generic Reason Code screen
      BEGIN
         SET @nAfterStep = 99
         SET @nAfterScn = @nScn_ReasonCode
         GOTO QUIT
      END
      IF @nMOBRECStep = 99 -- Customize screens  
      BEGIN  
         IF @nScn = @nScn_ReasonCode -- Reason Code screen  
         BEGIN  
            IF @nInputKey = 1 -- ENTER
            BEGIN
               -- Screen mapping
               DECLARE @nShortQTY INT
               SET @cReasonCode = @cInField01

               -- Check blank reason
               IF @cReasonCode = ''
               BEGIN
                  SET @nErrNo = 51377
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Reason needed
                  GOTO Step_9_Fail
               END

               IF EXISTS (SELECT 1 FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
                  WHERE LLI.StorerKey = @cStorerKey
                  AND LLI.LOT = @cSuggLOT
                  AND LLI.Loc = @cSuggFromLOC
                  AND LLI.ID = @cSuggID
                  AND QTY - QTYPICKED > 0
                  AND QTYAllocated < @nQTY_RPL
                  AND @cReasonCode IN (
                    SELECT 
                      Short 
                   FROM CODELKUP WITH(NOLOCK)
                        WHERE LISTNAME = 'JCBPREASON'
                 ))
               BEGIN
                  SET @nErrNo = 245404
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Inventory issue
                  GOTO Step_9_Fail
               END

               -- Extended validate
               IF @cExtendedValidateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cDropID, @nQTY, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT'
                     SET @cSQLParam =
                        '@nMobile         INT,           ' +
                        '@nFunc           INT,           ' +
                        '@cLangCode       NVARCHAR( 3),  ' +
                        '@nStep           INT,           ' +
                        '@nInputKey       INT,           ' +
                        '@cTaskdetailKey  NVARCHAR( 10), ' +
                        '@cDropID         NVARCHAR( 20), ' +
                        '@nQTY            INT,           ' +
                        '@cToLOC          NVARCHAR( 10), ' +
                        '@nErrNo          INT OUTPUT,    ' +
                        '@cErrMsg         NVARCHAR( 20) OUTPUT '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cDropID, @nQTY, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                        GOTO Quit
                  END
               END

               SELECT TOP 1 
                  @cHoldID = CASE WHEN UDF01='Y' THEN '1' ELSE '0' END,
                  @cHoldLoc = CASE WHEN UDF02='Y' THEN '1' ELSE '0' END
               FROM CodeLKUP WITH (NOLOCK)
               WHERE ListName = 'JCBPREASON'
                  AND StorerKey = @cStorerKey
                  AND Short = @cReasonCode
               SET @nRowCount = @@ROWCOUNT

               IF @nRowCount = 0
               BEGIN -- Generic process
                  SET @nShortQTY = @nQTY_RPL - @nQTY
                  EXEC dbo.nspRFRSN01
                     @c_sendDelimiter = NULL
                     ,@c_ptcid         = 'RDT'
                     ,@c_userid        = @cUserName
                     ,@c_taskId        = 'RDT'
                     ,@c_databasename  = NULL
                     ,@c_appflag       = NULL
                     ,@c_recordType    = NULL
                     ,@c_server        = NULL
                     ,@c_ttm           = NULL
                     ,@c_TaskDetailKey = @cTaskDetailKey
                     ,@c_fromloc       = @cSuggFromLOC
                     ,@c_fromid        = @cSuggID
                     ,@c_toloc         = @cSuggToloc
                     ,@c_toid          = @cDropID
                     ,@n_qty           = @nShortQTY
                     ,@c_PackKey       = ''
                     ,@c_uom           = ''
                     ,@c_reasoncode    = @cReasonCode
                     ,@c_outstring     = @c_outstring    OUTPUT
                     ,@b_Success       = @b_Success      OUTPUT
                     ,@n_err           = @nErrNo         OUTPUT
                     ,@c_errmsg        = @cErrMsg        OUTPUT
                     ,@c_userposition  = '1' -- 1=at from LOC
                  IF @b_Success = 0 OR @nErrNo <> 0
                     GOTO Step_9_Fail

                  -- Confirm (update TaskDetail to status 5)
                  IF @nFromStep = 8 --Short pick
                  BEGIN
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
                  END

                  -- Get task reason info
                  SELECT
                     @cContinueProcess = ContinueProcessing,
                     @cRemoveTaskFromUserQueue = RemoveTaskFromUserQueue,
                     @cTaskStatus = TaskStatus
                  FROM dbo.TaskManagerReason WITH (NOLOCK)
                  WHERE TaskManagerReasonKey = @cReasonCode

                  IF @cRemoveTaskFromUserQueue = '1'
                  BEGIN
                     INSERT INTO TaskManagerSkipTasks (UserID, TaskDetailKey, TaskType, LOT, FromLOC, ToLOC, FromID, ToID, CaseID)
                     SELECT UserKey, TaskDetailKey, TaskType, LOT, FromLOC, ToLOC, FromID, ToID, CaseID
                     FROM dbo.TaskDetail WITH (NOLOCK)
                     WHERE TaskDetailKey = @cTaskdetailKey
                     IF @@ERROR <> 0
                     BEGIN
                        SET @nErrNo = 51379
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsSkipTskFail
                        GOTO Step_9_Fail
                     END                  
                  END

                  -- Update TaskDetail.Status
                  IF @cTaskStatus <> ''
                  BEGIN
                     -- Skip task
                     IF @cTaskStatus = '0'
                     BEGIN
                        UPDATE dbo.TaskDetail SET
                           UserKey = ''
                           ,ReasonKey = ''
                           ,Status = '0'
                           ,EditDate = GETDATE()
                           ,EditWho  = SUSER_SNAME()
                           ,TrafficCop = NULL
                        WHERE TaskDetailKey = @cTaskDetailKey
                        IF @@ERROR <> 0
                        BEGIN
                           SET @nErrNo = 51380
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdTaskdetFail
                           GOTO Step_9_Fail
                        END
                     END

                     -- Cancel task
                     IF @cTaskStatus = 'X'
                     BEGIN
                        UPDATE dbo.TaskDetail SET
                           Status = 'X'
                           ,EditDate = GETDATE()
                           ,EditWho  = SUSER_SNAME()
                           ,TrafficCop = NULL
                        WHERE TaskDetailKey = @cTaskDetailKey
                        IF @@ERROR <> 0
                        BEGIN
                           SET @nErrNo = 51381
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdTaskdetFail
                           GOTO Step_9_Fail
                        END
                     END

                     -- Cancel picked UCC
                     IF EXISTS( SELECT 1 FROM rdt.rdtFCPLog WITH (NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey)
                     BEGIN
                        DELETE rdt.rdtFCPLog WHERE TaskDetailKey = @cTaskDetailKey
                        IF @@ERROR <> 0
                        BEGIN
                           SET @nErrNo = 51382
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DelRPFLogFail
                           GOTO Step_9_Fail
                        END
                     END
                  END

                  -- Extended update
                  IF @cExtendedUpdateSP <> ''
                  BEGIN
                     IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
                     BEGIN
                        SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                           ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cDropID, @nQTY, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nAfterStep '
                        SET @cSQLParam =
                           '@nMobile         INT,           ' +
                           '@nFunc           INT,           ' +
                           '@cLangCode       NVARCHAR( 3),  ' +
                           '@nStep           INT,           ' +
                           '@nInputKey       INT,           ' +
                           '@cTaskdetailKey  NVARCHAR( 10), ' +
                           '@cDropID         NVARCHAR( 20), ' +
                           '@nQTY            INT,           ' +
                           '@cToLOC          NVARCHAR( 10), ' +
                           '@nErrNo          INT OUTPUT,    ' +
                           '@cErrMsg         NVARCHAR( 20) OUTPUT, ' +
                           '@nAfterStep      INT            '

                        EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                           @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cDropID, @nQTY, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nStep

                        IF @nErrNo <> 0
                           GOTO Quit
                     END
                  END

                  -- Continue process current task
                  IF @cContinueProcess = '1'
                  BEGIN
                     -- Back to DropID screen
                     IF @nFromStep = 1
                     BEGIN
                        SET @cOutField01 = '' -- DropID
                        SET @nAfterScn = @nFromScn
                        SET @nAfterStep = @nFromStep
                     END

                     -- Back to FromLOC screen
                     IF @nFromStep = 2
                     BEGIN
                        SET @cOutField01 = @cPickMethod
                        SET @cOutField02 = @cDropID
                        SET @cOutField03 = '' -- FromLOC
                        SET @nAfterScn = @nFromScn
                        SET @nAfterStep = @nFromStep
                     END

                     -- Go to next task screen
                     IF @nFromStep = 8 -- Short pick screen
                     BEGIN
                        SET @cOption = ''
                        SET @cOutField01 = '' -- Option
                        SET @nAfterScn = @nFromScn - 3
                        SET @nAfterStep = @nFromStep - 3
                     END
                  END
                  ELSE
                  BEGIN
                     -- Setup RDT storer config ContProcNotUpdTaskStatus, to avoid nspRFRSN01 set TaskDetail.Status = '9', when ContinueProcess <> 1

                     -- Go to next task/exit TM screen
                     IF @cPickMethod = 'FP'
                     BEGIN
                        SET @nAfterScn  = 4026
                        SET @nAfterStep = 7
                     END

                     -- Go to next task screen
                     IF @cPickMethod = 'PP'
                     BEGIN
                        SET @cOption = ''
                        SET @cOutField01 = '' -- Option
                        SET @nAfterScn  = 4024
                        SET @nAfterStep = 5
                     END
                  END
               END
               ELSE -- Customerize process
               BEGIN

                  --Deallocate pickdetail
                  UPDATE dbo.PickDetail WITH(ROWLOCK) SET
                     Qty = 0
                  WHERE TaskDetailKey = @cTaskdetailKey
                  AND StorerKey = @cStorerKey

                  --Delete Pickdetail
                  DELETE FROM dbo.PickDetail WITH(ROWLOCK)
                  WHERE TaskDetailKey = @cTaskdetailKey
                  AND StorerKey = @cStorerKey
                  
                  --Hold TaskDetail
                  UPDATE dbo.TaskDetail WITH(ROWLOCK) SET
                     ReasonKey = @cReasonCode
                     ,Status = 'S' -- Hold
                     ,EditDate = GETDATE()
                     ,EditWho  = SUSER_SNAME()
                     ,TrafficCop = NULL
                  WHERE TaskDetailKey = @cTaskdetailKey

                  SELECT @cLottable01 = ISNULL(@cLottable01,''),@cLottable02 = ISNULL(@cLottable02,''),@cLottable03 = ISNULL(@cLottable03,''),
                     @cLottable06 = ISNULL(@cLottable06,''),@cLottable07 = ISNULL(@cLottable07,''),@cLottable08 = ISNULL(@cLottable08,''),
                     @cLottable09 = ISNULL(@cLottable09,''),@cLottable10 = ISNULL(@cLottable10,''),@cLottable11 = ISNULL(@cLottable11,''),
                     @cLottable12 = ISNULL(@cLottable12,'')
                  BEGIN TRY
                     EXEC nspInventoryHoldWrapper
                        '',               -- lot
                        '',               -- loc
                        @cSuggID,               -- id
                        @cStorerKey,     -- storerkey
                        @cSuggSKU,           -- sku
                        '',               -- lottable01
                        '',               -- lottable01
                        '',               -- lottable01
                        NULL,             -- lottable01
                        NULL,             -- lottable01
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        NULL,
                        NULL,
                        NULL,
                        @cReasonCode,      -- status
                        @cHoldID,              -- hold
                        @b_success OUTPUT,
                        @nErrNo OUTPUT,
                        @cErrMsg OUTPUT,
                        ''   -- remark
                     IF @nErrNo <> 0
                     BEGIN
                        SET @nErrNo = 245402
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                        GOTO RollBackTran
                     END

                     UPDATE ID SET STATUS = CASE WHEN @cHoldID = '1' THEN 'HOLD' ELSE STATUS END
                     WHERE ID = @cSuggID

                     EXEC nspInventoryHoldWrapper
                        '',               -- lot
                        @cSuggFromLOC,    -- loc
                        '',               -- id
                        @cStorerKey,     -- storerkey
                        @cSuggSKU,           -- sku
                        '',               -- lottable01
                        '',               -- lottable01
                        '',               -- lottable01
                        NULL,             -- lottable01
                        NULL,             -- lottable01
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        NULL,
                        NULL,
                        NULL,
                        @cReasonCode,      -- status
                        @cHoldLoc,              -- hold
                        @b_success OUTPUT,
                        @nErrNo OUTPUT,
                        @cErrMsg OUTPUT,
                        ''   -- remark
                        IF @nErrNo <> 0
                        BEGIN
                           SET @nErrNo = 245403
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                           GOTO RollBackTran
                        END
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 245401
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'UCC req'
                     GOTO RollBackTran
                  END CATCH
                  -- Go to next task/exit TM screen
                  IF @cPickMethod = 'FP'
                  BEGIN
                     SET @nAfterScn  = CASE WHEN @nFromStep = 1 THEN @nFromScn + 6
                                       WHEN @nFromStep = 2 THEN @nFromScn + 5
                                       WHEN @nFromStep = 8 THEN @nFromScn - 1
                                 END
                     SET @nAfterStep = 7
                  END

                  -- Go to next task screen
                  IF @cPickMethod = 'PP'
                  BEGIN
                     IF NOT EXISTS( SELECT 1
                        FROM dbo.TaskDetail TD WITH (NOLOCK)    
                        JOIN dbo.LOC WITH(NOLOCK) ON LOC.LOC = TD.FromLOC
                        WHERE ListKey <> @cListKey  
                        AND TD.UserKey = @cUserName  
                        AND TD.AreaKey = @cAreaKey
                        AND TD.Status = '3'
                        AND TaskType IN ('FCP','FCP1'))
                     AND NOT EXISTS( SELECT 1    
                        FROM dbo.TaskDetail WITH (NOLOCK)    
                        WHERE ListKey = @cListKey    
                        AND UserKey = @cUserName
                        AND Status = '5')  
                     BEGIN
                        SET @nAfterScn  = 4026
                        SET @nAfterStep = 7
                     END
                     ELSE 
                     BEGIN
                        SET @cOption = ''
                        SET @cOutField01 = '' -- Option
                        SET @nAfterScn  = 4024
                        SET @nAfterStep = 5
                     END

                  END
               END

               UPDATE OD SET
                  Notes = @cReasonCode
               FROM ORDERDETAIL OD 
               JOIN PickDetail PD ON PD.ORDERKEY = OD.ORDERKEY AND PD.OrderLineNumber = OD.OrderLineNumber
               WHERE PD.TaskDetailKey = @cTaskDetailKey

               -- Extended update
               IF @cExtendedUpdateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cDropID, @nQTY, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nAfterStep '
                     SET @cSQLParam =
                        '@nMobile         INT,           ' +
                        '@nFunc           INT,           ' +
                        '@cLangCode       NVARCHAR( 3),  ' +
                        '@nStep           INT,           ' +
                        '@nInputKey       INT,           ' +
                        '@cTaskdetailKey  NVARCHAR( 10), ' +
                        '@cDropID         NVARCHAR( 20), ' +
                        '@nQTY            INT,           ' +
                        '@cToLOC          NVARCHAR( 10), ' +
                        '@nErrNo          INT OUTPUT,    ' +
                        '@cErrMsg         NVARCHAR( 20) OUTPUT, ' +
                        '@nAfterStep      INT            '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cDropID, @nQTY, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nStep

                     IF @nErrNo <> 0
                        GOTO Quit
                  END
               END
            END

            IF @nInputKey = 0 -- ESC
            BEGIN
               -- Go to DropID screen
               IF @nFromStep = 1
               BEGIN
                  -- Prepare next screen variable
                  SET @cDropID = ''
                  SET @cOutField01 = '' -- DropID

                  IF @cAutoGenDROPIDSP <> ''
                  BEGIN
                     -- Auto generate DROPID
                     EXEC rdt.rdt_AutoGenID @nMobile, @nFunc, @nStep, @cLangCode
                        ,@cAutoGenDROPIDSP
                        ,@tExtData
                        ,@cAutoID  OUTPUT
                        ,@nErrNo   OUTPUT
                        ,@cErrMsg  OUTPUT
                     IF @nErrNo <> 0
                        GOTO Quit

                     SET @cOutField01 = @cAutoID
                  END
               END

               -- Go to FromLOC screen
               IF @nFromStep = 2
               BEGIN
                  -- Prepare next screen variable
                  SET @cOutField01 = @cPickMethod
                  SET @cOutField02 = @cDropID
                  SET @cOutField03 = @cSuggFromLOC
                  SET @cOutField04 = '' -- FromLOC
                  SET @cOutField10 = '' -- ExtendedInfo
               END

               -- Go to short pick screen
               IF @nFromStep = 8
               BEGIN
                  -- Prepare next screen variable
                  SET @cOption = ''
                  SET @cOutField01 = '' -- Option
               END

               IF @nFromStep = 99 AND @nFromScn = 6672
               BEGIN
                  SET @cOutField01 = ''
                  SELECT @cOutField01 = Lottable03 FROM LOTAttribute (NOLOCK)
                  WHERE lot = @cSuggLOT AND Storerkey = @cStorerKey AND SKU = @cSuggSKU

                  INSERT INTO @tOptions (LOC,ID)
                  SELECT TOP 3 LLI.LOC,LLI.ID
                  FROM LOTxLOCxID LLI(NOLOCK)
                  JOIN LOTAttribute LA (NOLOCK) ON LLI.LOT = LA.LOT AND LLI.StorerKey = LA.StorerKey AND LLI.SKU = LA.SKU
                  WHERE LLI.QTY - LLI.QTYPICKED > 0
                  AND LLI.StorerKey = @cStorerKey
                  AND LLI.SKU = @cSuggSKU
                  AND LLI.QTY = @nQTY_RPL
                  AND LA.Lottable03 = @cOutField01
                  AND LLI.ID <> @cSuggID
                  ORDER BY CASE WHEN LLI.LOC = @cSuggFromLOC THEN 0 ELSE 1 END, LLI.LOT

                  SELECT
                     @cOutField02 = ISNULL(MAX(CASE WHEN count = 1 THEN LOC ELSE NULL END),''),
                     @cOutField03 = ISNULL(MAX(CASE WHEN count = 1 THEN ID ELSE NULL END),''),
                     @cOutField04 = ISNULL(MAX(CASE WHEN count = 2 THEN LOC ELSE NULL END),''),
                     @cOutField06 = ISNULL(MAX(CASE WHEN count = 2 THEN ID ELSE NULL END),''),
                     @cOutField07 = ISNULL(MAX(CASE WHEN count = 3 THEN LOC ELSE NULL END),''),
                     @cOutField08 = ISNULL(MAX(CASE WHEN count = 3 THEN ID ELSE NULL END),'')
                  FROM @tOptions

                  INSERT INTO @tInventory (SKU,QTY)
                  SELECT TOP 3 LLI.SKU,SUM(LLI.QTY)
                  FROM LOTxLOCxID LLI(NOLOCK)
                  WHERE LLI.QTY - LLI.QTYPICKED > 0
                  AND LLI.StorerKey = @cStorerKey
                  AND LLI.ID = @cSuggID
                  AND LLI.LOC = @cSuggFromLOC
                  GROUP BY LLI.SKU
                  ORDER BY SKU

                  SELECT
                     @cOutField09 = ISNULL(CASE WHEN count = 1 THEN CONCAT(SKU,'   ',QTY) ELSE NULL END,''),
                     @cOutField11 = ISNULL(CASE WHEN count = 2 THEN CONCAT(SKU,'   ',QTY) ELSE NULL END,''),
                     @cOutField12 = ISNULL(CASE WHEN count = 3 THEN CONCAT(SKU,'   ',QTY) ELSE NULL END,'')
                  FROM @tInventory

                  SET @cOutField05 = ''
                  SET @cOutField15 = @cSuggSKU
                  SET @nAfterStep = 99
                  SET @nAfterScn = 6672
                  GOTO QUIT
               END

               -- Back to prev screen
               SET @nAfterScn = @nFromScn
               SET @nAfterStep = @nFromStep

               -- Extended info
               IF @cExtendedInfoSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
                  BEGIN
                     SET @cExtendedInfo1 = ''
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nAfterStep'
                     SET @cSQLParam =
                        '@nMobile         INT,           ' +
                        '@nFunc           INT,           ' +
                        '@cLangCode       NVARCHAR( 3),  ' +
                        '@nStep           INT,           ' +
                        '@cTaskdetailKey  NVARCHAR( 10), ' +
                        '@cExtendedInfo1  NVARCHAR( 20) OUTPUT, ' +
                        '@nErrNo          INT           OUTPUT, ' +
                        '@cErrMsg         NVARCHAR( 20) OUTPUT, ' +
                        '@nAfterStep      INT '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, 9, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nStep

                     SET @cOutField10 = @cExtendedInfo1
                  END
               END
            END
            GOTO Quit

            Step_9_Fail:
            BEGIN
               SET @cReasonCode = ''

               -- Reset this screen var
               SET @cOutField01 = ''
            END
              
            GOTO Quit  
         END  
         IF @nScn = 4022 OR @nScn = 6672 -- FromID Scn
         BEGIN
            IF @nInputKey = 1 -- ENTER
            BEGIN
               -- Screen mapping
               SET @cFromID  = @cInField05

               -- Check FromID match
               IF @cFromID <> @cSuggID
               BEGIN
                  IF @cFromID = '99' AND @nScn = 4022
                  BEGIN
                     SET @cOutField01 = ''
                     SELECT @cOutField01 = Lottable03 FROM LOTAttribute (NOLOCK)
                     WHERE lot = @cSuggLOT AND Storerkey = @cStorerKey AND SKU = @cSuggSKU

                     INSERT INTO @tOptions (LOC,ID)
                     SELECT TOP 3 LLI.LOC,LLI.ID
                     FROM LOTxLOCxID LLI(NOLOCK)
                     JOIN LOTAttribute LA (NOLOCK) ON LLI.LOT = LA.LOT AND LLI.StorerKey = LA.StorerKey AND LLI.SKU = LA.SKU
                     WHERE LLI.QTY > 0
                     AND (LLI.QTYPICKED + LLI.QTYALLOCATED + LLI.QtyReplen) = 0
                     AND LLI.StorerKey = @cStorerKey
                     AND LLI.SKU = @cSuggSKU
                     AND LLI.QTY = @nQTY_RPL
                     AND LA.Lottable03 = @cOutField01
                     AND LLI.ID <> @cSuggID
                     ORDER BY CASE WHEN LLI.LOC = @cSuggFromLOC THEN 0 ELSE 1 END, LLI.LOT

                     SELECT
                        @cOutField02 = ISNULL(MAX(CASE WHEN count = 1 THEN LOC ELSE NULL END),''),
                        @cOutField03 = ISNULL(MAX(CASE WHEN count = 1 THEN ID ELSE NULL END),''),
                        @cOutField04 = ISNULL(MAX(CASE WHEN count = 2 THEN LOC ELSE NULL END),''),
                        @cOutField06 = ISNULL(MAX(CASE WHEN count = 2 THEN ID ELSE NULL END),''),
                        @cOutField07 = ISNULL(MAX(CASE WHEN count = 3 THEN LOC ELSE NULL END),''),
                        @cOutField08 = ISNULL(MAX(CASE WHEN count = 3 THEN ID ELSE NULL END),'')
                     FROM @tOptions

                     INSERT INTO @tInventory (SKU,QTY)
                     SELECT TOP 3 LLI.SKU,SUM(LLI.QTY)
                     FROM LOTxLOCxID LLI(NOLOCK)
                     WHERE LLI.QTY - LLI.QTYPICKED > 0
                     AND LLI.StorerKey = @cStorerKey
                     AND LLI.ID = @cSuggID
                     AND LLI.LOC = @cSuggFromLOC
                     GROUP BY LLI.SKU
                     ORDER BY SKU

                     SELECT
                        @cOutField09 = ISNULL(CASE WHEN count = 1 THEN CONCAT(SKU,'   ',QTY) ELSE NULL END,''),
                        @cOutField11 = ISNULL(CASE WHEN count = 2 THEN CONCAT(SKU,'   ',QTY) ELSE NULL END,''),
                        @cOutField12 = ISNULL(CASE WHEN count = 3 THEN CONCAT(SKU,'   ',QTY) ELSE NULL END,'')
                     FROM @tInventory

                     SET @cUDF01 = @cTTMTaskType
                     SET @cUDF03 = @cSuggID
                     SET @cUDF04 = @cSuggLOT
                     SET @cUDF05 = @cSuggFromLOC
                     SET @cUDF06 = @cSuggToLOC
                     SET @cUDF07 = @cSuggSKU
                     SET @cUDF08 = @nQTY_RPL
                     SET @cUDF09 = @cPickMethod
                     SET @cUDF11 = @cDropID
                     SET @cUDF12 = @cListKey
                     SET @cUDF13 = @cTaskDetailUOM
                     SET @cUDF14 = @nPQTY
                     SET @cUDF15 = @nMQTY
                     SET @cUDF16 = @nPQTY_RPL
                     SET @cUDF17 = @nMQTY_RPL
                     SET @cUDF18 = @nPUOM_Div
                     SET @cUDF19 = @cLottableCode
                     SET @cUDF20 = @cTaskDetailKey
                     SET @cUDF21 = @nMOBRECStep
                     SET @cUDF22 = @nMOBRECScn

                     SET @cOutField05 = ''
                     SET @cOutField15 = @cSuggSKU
                     SET @nAfterStep = 99
                     SET @nAfterScn = 6672
                     GOTO QUIT
                  END
                  IF @cSwapTaskSP = ''
                  BEGIN
                     SET @nErrNo = 51359
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID not match
                     GOTO Step_3_Fail
                  END

                  -- Swap ID
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cSwapTaskSP AND type = 'P')
                  BEGIN
                     SET @cNewTaskDetailKey = ''

                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cSwapTaskSP) +
                        ' @nMobile, @nFunc, @cLangCode, @cTaskdetailKey, @cFromID, @cNewTaskDetailKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
                     SET @cSQLParam =
                        '@nMobile            INT,           ' +
                        '@nFunc              INT,           ' +
                        '@cLangCode          NVARCHAR( 3),  ' +
                        '@cTaskdetailKey     NVARCHAR( 10), ' +
                        '@cFromID            NVARCHAR( 18), ' +
                        '@cNewTaskDetailKey  NVARCHAR( 10)  OUTPUT, ' +
                        '@nErrNo             INT            OUTPUT, ' +
                        '@cErrMsg            NVARCHAR( 20)  OUTPUT'

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @cTaskdetailKey, @cFromID, @cNewTaskDetailKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                        GOTO RollBackTran

                     -- New task
                     IF @cNewTaskDetailKey <> ''
                        SET @cTaskDetailKey = @cNewTaskDetailKey

                     -- Reload task
                     SELECT
                        @cTTMTaskType = TaskType,
                        @cSuggID      = FromID,
                        @cSuggLOT     = LOT,
                        @cSuggFromLOC = FromLOC,
                        @cSuggToLOC   = ToLOC,
                        @cSuggSKU     = SKU,
                        @nQTY_RPL     = QTY,
                        @cPickMethod  = PickMethod,
                        @cDropID      = CASE WHEN ISNULL(DROPID,'')='' THEN @cDropID ELSE DROPID END , --(yeekung02)
                        @cListKey     = ListKey,
                        @cTaskDetailUOM = UOM
                     FROM dbo.TaskDetail WITH (NOLOCK)
                     WHERE TaskDetailKey = @cTaskDetailKey

                     IF @cTaskDetailPUOM = '1'
                     BEGIN
                        -- Task Detail UoM as preferred UOM
                        SET @cPUOM = @cTaskDetailUOM
                     END
                     ELSE
                     BEGIN
                        -- Get preferred UOM
                        SELECT @cPUOM = DefaultUOM FROM rdt.rdtUser WITH (NOLOCK) WHERE UserName = @cUserName
                     END

                  END
               END

               -- Check QTYAlloc, QTYReplen
               IF @cPickMethod = 'FP'
               BEGIN
                  IF EXISTS( SELECT 1
                     FROM dbo.LOTxLOCxID WITH (NOLOCK)
                     WHERE LOC = @cSuggFromLOC
                        AND ID = @cSuggID
                        AND (QTYReplen > 0 OR
                           QTYAllocated > (CASE WHEN @cMoveQTYAlloc = '1' THEN QTYAllocated ELSE 0 END)))
                  BEGIN
                     SET @nErrNo = 51360
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --QTYALC/QTYRPL
                     GOTO Step_3_Fail
                  END
               END

               -- Extended update
               IF @cExtendedUpdateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cDropID, @nQTY, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nAfterStep '
                     SET @cSQLParam =
                        '@nMobile         INT,           ' +
                        '@nFunc           INT,           ' +
                        '@cLangCode       NVARCHAR( 3),  ' +
                        '@nStep           INT,           ' +
                        '@nInputKey       INT,           ' +
                        '@cTaskdetailKey  NVARCHAR( 10), ' +
                        '@cDropID         NVARCHAR( 20), ' +
                        '@nQTY            INT,           ' +
                        '@cToLOC          NVARCHAR( 10), ' +
                        '@nErrNo          INT OUTPUT,    ' +
                        '@cErrMsg         NVARCHAR( 20) OUTPUT, ' +
                        '@nAfterStep      INT            '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cDropID, @nQTY, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nStep

                     IF @nErrNo <> 0
                        GOTO Quit
                  END
               END

               -- Full pallet
               IF @cPickMethod = 'FP'
               BEGIN
                  -- Prepare next screen var
                  SET @cToLOC = ''
                  SET @cOutField01 = @cSuggFromLOC
                  SET @cOutField02 = @cSuggToLOC
                  SET @cOutField03 = CASE WHEN @cDefaultToLOC = '1' THEN @cSuggToLOC ELSE '' END

                  SET @nAfterScn = 4025
                  SET @nAfterStep = 6
               END

               -- Partial pallet
               IF @cPickMethod = 'PP'
               BEGIN
                  -- Get SKU info
                  SELECT
                     @cSKUDesc =
                        CASE WHEN @cDispStyleColorSize = '0'
                           THEN ISNULL( S.Descr, '')
                           ELSE CAST( S.Style AS NCHAR(20)) +
                                 CAST( S.Color AS NCHAR(10)) +
                                 CAST( S.Size  AS NCHAR(10))
                        END,
                     @cLottableCode = S.LottableCode,
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
                     @nPUOM_Div = CAST(
                        CASE @cPUOM
                           WHEN '2' THEN Pack.CaseCNT
                           WHEN '3' THEN Pack.InnerPack
                           WHEN '6' THEN Pack.QTY
                           WHEN '1' THEN Pack.Pallet
                           WHEN '4' THEN Pack.OtherUnit1
                           WHEN '5' THEN Pack.OtherUnit2
                        END AS INT)
                  FROM dbo.SKU S WITH (NOLOCK)
                     INNER JOIN dbo.Pack Pack (nolock) ON (S.PackKey = Pack.PackKey)
                  WHERE StorerKey = @cStorerKey
                     AND SKU = @cSuggSKU

                  SELECT
                     @cLottable01 = '', @cLottable02 = '', @cLottable03 = '',    @dLottable04 = NULL,  @dLottable05 = NULL,
                     @cLottable06 = '', @cLottable07 = '', @cLottable08 = '',    @cLottable09 = '',    @cLottable10 = '',
                     @cLottable11 = '', @cLottable12 = '', @dLottable13 = NULL,  @dLottable14 = NULL,  @dLottable15 = NULL

                  -- Get lottable
                  SELECT
                     @cLottable01 = LA.Lottable01,
                     @cLottable02 = LA.Lottable02,
                     @cLottable03 = LA.Lottable03,
                     @dLottable04 = LA.Lottable04,
                     @dLottable05 = LA.Lottable05,
                     @cLottable06 = LA.Lottable06,
                     @cLottable07 = LA.Lottable07,
                     @cLottable08 = LA.Lottable08,
                     @cLottable09 = LA.Lottable09,
                     @cLottable10 = LA.Lottable10,
                     @cLottable11 = LA.Lottable11,
                     @cLottable12 = LA.Lottable12,
                     @dLottable13 = LA.Lottable13,
                     @dLottable14 = LA.Lottable14,
                     @dLottable15 = LA.Lottable15
                  FROM dbo.LOTAttribute LA WITH (NOLOCK)
                  WHERE LOT = @cSuggLOT

                  -- Dynamic lottable
                  EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSKU, @cLottableCode, 'DISPLAY', 'POPULATE', 4, 4,
                     @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  @cLottable01 OUTPUT,
                     @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  @cLottable02 OUTPUT,
                     @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  @cLottable03 OUTPUT,
                     @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  @dLottable04 OUTPUT,
                     @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  @dLottable05 OUTPUT,
                     @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  @cLottable06 OUTPUT,
                     @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  @cLottable07 OUTPUT,
                     @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  @cLottable08 OUTPUT,
                     @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  @cLottable09 OUTPUT,
                     @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  @cLottable10 OUTPUT,
                     @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  @cLottable11 OUTPUT,
                     @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  @cLottable12 OUTPUT,
                     @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  @dLottable13 OUTPUT,
                     @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  @dLottable14 OUTPUT,
                     @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  @dLottable15 OUTPUT,
                     @nMorePage   OUTPUT,
                     @nErrNo      OUTPUT,
                     @cErrMsg     OUTPUT,
                     '',      -- SourceKey
                     @nFunc   -- SourceType

                  -- Restore scanned carton QTY
                  SELECT @nCartonQTY = ISNULL( SUM( QTY), 0)
                  FROM rdt.rdtFCPLog WITH (NOLOCK)
                  WHERE TaskDetailKey = @cTaskDetailKey

                  IF @nCartonQTY = 0
                     SET @cSKUValidated = '0'
                  ELSE
                     SET @cSKUValidated = '1'

                  -- Disable QTY field
                  SET @cFieldAttr14 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END -- PQTY
                  SET @cFieldAttr15 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END -- MQTY

                  -- Convert to prefer UOM QTY
                  IF @cPUOM = '6' OR -- When preferred UOM = master unit
                     @nPUOM_Div = 0 -- UOM not setup
                  BEGIN
                     SET @cPUOM_Desc = ''
                     SET @nPQTY_RPL = 0
                     SET @nPQTY = 0
                     SET @nMQTY = @nCartonQTY
                     SET @nMQTY_RPL = @nQTY_RPL
                     SET @cFieldAttr14 = 'O' -- @nPQTY_PWY
                  END
                  ELSE
                  BEGIN
                     SET @nPQTY = 0
                     SET @nMQTY = @nCartonQTY

                     SET @nPQTY = @nCartonQTY / @nPUOM_Div -- Calc QTY in preferred UOM
                     SET @nMQTY = @nCartonQTY % @nPUOM_Div -- Calc the remaining in master unit

                     SET @nPQTY_RPL = @nQTY_RPL / @nPUOM_Div -- Calc QTY in preferred UOM
                     SET @nMQTY_RPL = @nQTY_RPL % @nPUOM_Div -- Calc the remaining in master unit
                  END

                  -- Prepare next screen variable
                  SET @cOutField01 = @cSuggSKU
                  SET @cOutField02 = SUBSTRING( @cSKUDesc, 1, 20)
                  SET @cOutField03 = SUBSTRING( @cSKUDesc, 21, 20)
                  SET @cBarcode    = '' -- SKU
                  SET @cOutField09 = ''
                  SET @cOutField10 = ''
                  SET @cOutField11 = '1:' + CAST( @nPUOM_Div AS NCHAR( 6)) + ' ' + @cPUOM_Desc + ' ' + @cMUOM_Desc
                  SET @cOutField12 = CASE WHEN (@cPUOM = '6' OR @nPUOM_Div = 0) THEN '' ELSE CAST( @nPQTY_RPL AS NVARCHAR( 6)) END
                  SET @cOutField13 = CAST( @nMQTY_RPL AS NVARCHAR( 6))
                  SET @cOutField14 = CASE WHEN (@cPUOM = '6' OR @nPUOM_Div = 0) THEN '' ELSE CAST( @nPQTY AS NVARCHAR( 6)) END -- PQTY
                  SET @cOutField15 = CAST( @nMQTY AS NVARCHAR( 6)) -- MQTY
                  EXEC rdt.rdtSetFocusField @nMobile, 'V_Barcode' -- SKU

                  SET @nAfterScn = 4023
                  SET @nAfterStep = 4
               END

               -- Extended info
               IF @cExtendedInfoSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
                  BEGIN
                     SET @cExtendedInfo1 = ''
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nAfterStep'
                     SET @cSQLParam =
                        '@nMobile         INT,           ' +
                        '@nFunc           INT,           ' +
                        '@cLangCode       NVARCHAR( 3),  ' +
                        '@nStep           INT,           ' +
                        '@cTaskdetailKey  NVARCHAR( 10), ' +
                        '@cExtendedInfo1  NVARCHAR( 20) OUTPUT, ' +
                        '@nErrNo          INT           OUTPUT, ' +
                        '@cErrMsg         NVARCHAR( 20) OUTPUT, ' +
                        '@nAfterStep      INT '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, 3, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nStep

                     SET @cOutField10 = @cExtendedInfo1
                  END
               END

               SET @cUDF01 = @cTTMTaskType
               SET @cUDF03 = @cSuggID
               SET @cUDF04 = @cSuggLOT
               SET @cUDF05 = @cSuggFromLOC
               SET @cUDF06 = @cSuggToLOC
               SET @cUDF07 = @cSuggSKU
               SET @cUDF08 = @nQTY_RPL
               SET @cUDF09 = @cPickMethod
               SET @cUDF11 = @cDropID
               SET @cUDF12 = @cListKey
               SET @cUDF13 = @cTaskDetailUOM
               SET @cUDF14 = @nPQTY
               SET @cUDF15 = @nMQTY
               SET @cUDF16 = @nPQTY_RPL
               SET @cUDF17 = @nMQTY_RPL
               SET @cUDF18 = @nPUOM_Div
               SET @cUDF19 = @cLottableCode
               SET @cUDF20 = @cTaskDetailKey
               SET @cUDF21 = @nMOBRECStep
               SET @cUDF22 = @nMOBRECScn
            END
            IF @nInputKey = 0 AND @nScn = 4022
            BEGIN
               SET @nAfterScn = 4021
               SET @nAfterStep = 2

               -- Prepare prev screen var
               SET @cOutField01 = @cPickMethod
               SET @cOutField02 = @cDropID
               SET @cOutField03 = @cSuggFromLOC
               SET @cOutField04 = '' -- FromLOC
               SET @cOutField10 = '' -- ExtendedInfo

               -- Extended info
               IF @cExtendedInfoSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
                  BEGIN
                     SET @cExtendedInfo1 = ''
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nAfterStep'
                     SET @cSQLParam =
                        '@nMobile         INT,           ' +
                        '@nFunc           INT,           ' +
                        '@cLangCode       NVARCHAR( 3),  ' +
                        '@nStep           INT,           ' +
                        '@cTaskdetailKey  NVARCHAR( 10), ' +
                        '@cExtendedInfo1  NVARCHAR( 20) OUTPUT, ' +
                        '@nErrNo          INT           OUTPUT, ' +
                        '@cErrMsg         NVARCHAR( 20) OUTPUT, ' +
                        '@nAfterStep      INT '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, 3, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nAfterStep

                     SET @cOutField10 = @cExtendedInfo1
                  END
               END
            END
            IF @nInputKey = 0 AND @nScn = 6672 --GOTO ReasonCodeScn
            BEGIN
               SET @cOutField01 = ''
               SET @cUDF01 = 99 --FROM STEP
               SET @cUDF02 = 6672 -- FROM SCN
               SET @nAfterStep = 99
               SET @nAfterScn = @nScn_ReasonCode
               GOTO QUIT
            END
            Step_3_Fail:
            BEGIN
               SET @cOutField05 = '' -- FromID
            END
         END
      END
      IF @nMOBRECStep = 5
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @cInField01 = '9' -- Close Pallet
            BEGIN
               IF NOT EXISTS (SELECT 1 FROM TASKDETAIL WHERE (ListKey = @cListKey AND Status = '5')OR (TaskDetailKey = @cTaskDetailKey AND STATUS = '3') )
               BEGIN
                  SET @nErrNo = 239666
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Nothing to close
                  SET @nAfterStep = @nMOBRECStep
                  SET @nAfterScn = @nMOBRECScn
                  SET @cOutField01 = ''
                  GOTO Quit
               END
            END
         END
         IF @nInputKey = 0 -- ESC
         BEGIN
            IF EXISTS( SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) WHERE TaskDetailKey = @cTaskdetailKey AND Status = 'S')
            OR NOT EXISTS ( SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) WHERE TaskDetailKey = @cTaskdetailKey)
            BEGIN
               SET @nErrNo = 239665
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pls choose an option
               SET @nAfterStep = @nMOBRECStep
               SET @nAfterScn = @nMOBRECScn
               SET @cOutField01 = ''
               GOTO Quit
            END
         END
      END
      IF @nMOBRECStep = 2 --FromLoc
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF EXISTS (SELECT 1 FROM LOC LOC WITH (NOLOCK)
               JOIN dbo.CodeLKUP CL WITH (NOLOCK)
                  ON LOC.LocationCategory = CL.LONG
                  AND CL.ListName = 'JCBBKFRMLC'
                  AND CL.StorerKey = @cStorerKey
               WHERE LOC = @cSuggFromLOC AND LOC.Facility = @cFacility)
            BEGIN
               -- Prepare Next Screen
               SET @cOutField01 = @cPickMethod
               SET @cOutField02 = @cDropID
               SET @cOutField03 = @cSuggFromLOC
               SET @cOutField04 = @cSuggID
               SET @cOutField05 = CASE WHEN @cDefaultFromID = '1' THEN @cSuggID ELSE '' END -- FromID
               SET @cOutField10 = '' -- ExtendedInfo

               SET @nAfterScn = 4022
               SET @nAfterStep = 99

               -- Extended info
               IF @cExtendedInfoSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
                  BEGIN
                     SET @cExtendedInfo1 = ''
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nAfterStep'
                     SET @cSQLParam =
                        '@nMobile         INT,           ' +
                        '@nFunc           INT,           ' +
                        '@cLangCode       NVARCHAR( 3),  ' +
                        '@nStep           INT,           ' +
                        '@cTaskdetailKey  NVARCHAR( 10), ' +
                        '@cExtendedInfo1  NVARCHAR( 20) OUTPUT, ' +
                        '@nErrNo          INT           OUTPUT, ' +
                        '@cErrMsg         NVARCHAR( 20) OUTPUT, ' +
                        '@nAfterStep      INT '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, 2, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nAfterStep

                     SET @cOutField10 = @cExtendedInfo1
                  END
               END
            END
         END
      END
      IF @nMOBRECStep = 6
      BEGIN
         IF @nInputKey = 0 -- ESC
         BEGIN
            -- Back to FromID screen (full pallet)
            IF @nFromStep = 99
            BEGIN
               -- Prepare next screen variable
               SET @cFromID = ''
               SET @cOutField01 = @cPickMethod
               SET @cOutField02 = @cDropID
               SET @cOutField03 = @cSuggFromLOC
               SET @cOutField04 = @cSuggID
               SET @cOutField05 = '' -- FromID
            END

            -- Back to close pallet screen
            IF @nFromStep = 5
            BEGIN
               -- Prepare next screen variable
               SET @cOption = ''
               SET @cOutField01 = '' -- Option
            END
            SET @nAfterScn = @nFromScn
            SET @nAfterStep = @nFromStep
            GOTO QUIT
         END
      END
   END --1812

   --V1.1.0 Jump to new equipment scn in TM Main instaed of Area scn
   IF @nFunc = 1756
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Func 1756 branch', @nScn AS Scn, @nStep AS Step
      IF @nScn = 2100 AND @nStep = 1
      BEGIN

         DECLARE @cTMExtScnSP NVARCHAR(20)

         SET @cTMExtScnSP = rdt.RDTGetConfig( 1756, 'ExtScnSP', @cStorerKey)

         IF @cTMExtScnSP = 'rdt_1756ExtScn01' -- If scan equipment scn is set in task main
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'Redirect to TM Main Equipment screen'

            SELECT @cEquipmentProfileKey = EquipmentProfileKey
               FROM dbo.TaskManagerUser WITH (NOLOCK) 
               WHERE UserKey = @cUserName

            SET @nAfterStep = 99
            SET @nAfterScn = 6529

            --Prepare data for the TM equipment screen
            SET @cOutField01 = @cEquipmentProfileKey
            SET @cOutField02 = ''
            SET @cOutField15 = '' 
         END
      END --2100, st1
   END--1756
   --V1.1.0 end
   GOTO QUIT
RollBackTran:
   ROLLBACK TRAN rdt_1812ExtScn06 -- Only rollback change made here
Fail:
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN

END  
  
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON rdt.rdt_1812ExtScn06 TO NSQL 
GO  
