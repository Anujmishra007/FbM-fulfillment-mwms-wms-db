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
   @cOption          NVARCHAR(1),
   @tExtData         VariableTable,
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
   DECLARE @nFromScn    INT,
   @cHoldID        NVARCHAR( 20),
   @cHoldLoc       NVARCHAR( 20),
   @nRowCount      INT,
   @cUserName      NVARCHAR(18),
   @cSuggToLOC          NVARCHAR(10),
   @c_outstring         NVARCHAR(255),
   @b_success           INT = 1,
   @cListKey            NVARCHAR(10),
   @cAutoGenDROPIDSP    NVARCHAR(20),
   @cExtendedValidateSP NVARCHAR(20),
   @cExtendedUpdateSP   NVARCHAR( 20),
   @nQTY_RPL            INT,
   @cAutoID             NVARCHAR( 18)
   DECLARE @c_InventoryHoldKey NVARCHAR(10)
   DECLARE @nTranCount  INT

   DECLARE @cEquipmentProfileKey NVARCHAR(10) --V1.1.0

   IF @nDebugFlag = 1 --V1.1.0
      SELECT 'Executing rdt_1812ExtScn06'

   -- Get session info  
   SELECT @nMOBRECStep      = [Step]
      ,@nMOBRECScn          = [Scn]
      ,@nFromScn            = [V_FromScn]
      ,@nFromStep           = [V_FromStep]
      ,@cExtendedInfoSP     = [V_String27]
      ,@cSuggSKU            = V_SKU
      ,@nQTY_RPL            =  V_TaskQTY
      ,@nQTY                =  V_QTY
      ,@cTaskDetailKey      = V_TaskDetailKey
      ,@cSuggFromLOC        = V_LOC
      ,@cSuggID             = V_ID
      ,@cDropID             = V_String3
      ,@cPickMethod         = V_String4
      ,@cSuggToloc          = V_String5
      ,@cListKey            = V_String7
      ,@cExtendedUpdateSP  = V_String22
      ,@cExtendedValidateSP= V_String31
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
                        SET @nAfterScn  = CASE WHEN @nFromStep = 1 THEN @nFromScn + 6
                                          WHEN @nFromStep = 2 THEN @nFromScn + 5
                                          WHEN @nFromStep = 8 THEN @nFromScn - 1
                                    END
                        SET @nAfterStep = 7
                     END

                     -- Go to next task screen
                     IF @cPickMethod = 'PP'
                     BEGIN
                        SET @cOption = ''
                        SET @cOutField01 = '' -- Option
                        SET @nAfterScn  = CASE WHEN @nFromStep = 1 THEN @nFromScn + 4
                                          WHEN @nFromStep = 2 THEN @nFromScn + 3
                                          WHEN @nFromStep = 8 THEN @nFromScn - 3
                                    END
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

                  IF NOT EXISTS(SELECT 1 FROM dbo.InventoryHold WITH (NOLOCK) WHERE ID = @cSuggID)
                  BEGIN
                     EXECUTE nspg_getkey
                     'InventoryHoldKey'
                     , 10
                     , @c_InventoryHoldKey OUTPUT
                     , @b_success OUTPUT
                     , @nErrNo OUTPUT
                     , @cErrMsg OUTPUT
                     --Hold ID is generated here
                     INSERT INTO InventoryHold
                     (
                        InventoryHoldKey, Hold, STATUS, StorerKey, SKU,
                        Lottable01, Lottable02, Lottable03, Lottable04,    
                        Lottable05, 
                        Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
                        Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
                        DateOn,    
                        WhoOn,    
                        Remark,ID
                     ) 
                     VALUES
                     (
                        @c_InventoryHoldKey, @cHoldID, @cReasonCode, @cStorerKey, @cSuggSKU,
                        @cLottable01, @cLottable02, @cLottable03, @dLottable04,    
                        @dLottable05,     
                        @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
                        @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
                        GETDATE(), 
                        @cUserName,      
                        '',@cSuggID
                     )
                  END
                  ELSE
                  BEGIN
                     UPDATE dbo.InventoryHold 
                     SET Hold = @cHoldID,STATUS = @cReasonCode, StorerKey = @cStorerKey, SKU = @cSuggSKU,
                        Lottable01 = @cLottable01, Lottable02 = @cLottable02, Lottable03 = @cLottable03,
                        Lottable04 = @dLottable04, Lottable05 = @dLottable05,
                        Lottable06 = @cLottable06, Lottable07 = @cLottable07, Lottable08 = @cLottable08,
                        Lottable09 = @cLottable09, Lottable10 = @cLottable10,
                        Lottable11 = @cLottable11, Lottable12 = @cLottable12, 
                        Lottable13 = @dLottable13, Lottable14 = @dLottable14, Lottable15 = @dLottable15,
                        DateOn = GETDATE(), WhoOn = @cUserName
                     WHERE ID = @cSuggID
                  END
                  IF NOT EXISTS( SELECT 1 FROM dbo.InventoryHold WITH (NOLOCK) WHERE LOC = @cSuggFromLOC)
                  BEGIN
                     EXECUTE nspg_getkey
                     'InventoryHoldKey'
                     , 10
                     , @c_InventoryHoldKey OUTPUT
                     , @b_success OUTPUT
                     , @nErrNo OUTPUT
                     , @cErrMsg OUTPUT
                     --Hold Loc is generated here
                     INSERT INTO InventoryHold
                     (
                        InventoryHoldKey, Hold, STATUS, StorerKey, SKU,
                        Lottable01, Lottable02, Lottable03, Lottable04,    
                        Lottable05, 
                        Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
                        Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
                        DateOn,    
                        WhoOn,    
                        Remark,LOC
                     ) 
                     VALUES
                     (
                        @c_InventoryHoldKey, @cHoldLoc, @cReasonCode, @cStorerKey, @cSuggSKU,
                        @cLottable01, @cLottable02, @cLottable03, @dLottable04,    
                        @dLottable05,     
                        @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
                        @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
                        GETDATE(), 
                        @cUserName,      
                        '',@cSuggFromLOC -- Hold From LOC
                     )
                  END
                  ELSE
                  BEGIN
                     UPDATE dbo.InventoryHold 
                     SET Hold = @cHoldLoc,STATUS = @cReasonCode, StorerKey = @cStorerKey, SKU = @cSuggSKU,
                        Lottable01 = @cLottable01, Lottable02 = @cLottable02, Lottable03 = @cLottable03,
                        Lottable04 = @dLottable04, Lottable05 = @dLottable05,
                        Lottable06 = @cLottable06, Lottable07 = @cLottable07, Lottable08 = @cLottable08,
                        Lottable09 = @cLottable09, Lottable10 = @cLottable10,
                        Lottable11 = @cLottable11, Lottable12 = @cLottable12, 
                        Lottable13 = @dLottable13, Lottable14 = @dLottable14, Lottable15 = @dLottable15,
                        DateOn = GETDATE(), WhoOn = @cUserName
                     WHERE LOC = @cSuggFromLOC
                  END
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
                     SET @cOption = ''
                     SET @cOutField01 = '' -- Option
                     SET @nAfterScn  = CASE WHEN @nFromStep = 1 THEN @nFromScn + 4
                                       WHEN @nFromStep = 2 THEN @nFromScn + 3
                                       WHEN @nFromStep = 8 THEN @nFromScn - 3
                                 END
                     SET @nAfterStep = 5
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
      END  
      IF @nMOBRECStep = 5
      BEGIN
         IF @nInputKey = 0 -- ESC
         BEGIN
            IF NOT EXISTS( SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) WHERE TaskDetailKey = @cTaskdetailKey)
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
