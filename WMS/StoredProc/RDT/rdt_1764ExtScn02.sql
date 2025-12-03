
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****************************************************************************/
/* Store procedure: rdt_1764ExtScn02                                        */
/* Copyright      : Maersk                                                  */
/* Customer       : JCB                                                     */
/*                                                                          */
/*                                                                          */
/* Date       Rev      Author   Purposes                                    */
/* 2025-06-11 1.0.0    Dennis   FCR-3959 Created                            */
/* 2025-08-21 1.0.1    Dennis   FCR-3959 Fix Inventory Hold Bug              */
/* 2025-08-20 1.1.0    Dennis   FCR-3959 New Feature                        */
/****************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1764ExtScn02] (
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
   @nAction          INT,
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
   @cUDF30  NVARCHAR( MAX)  OUTPUT   --to support max length parameter output
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   -- Screen constant
   DECLARE
      @nStep_Start      INT, 
      @nStep_DropID     INT,  @nScn_DropID      INT,
      @nStep_FromLOC    INT,  @nScn_FromLOC     INT,
      @nStep_FromID     INT,  @nScn_FromID      INT,
      @nStep_SKU        INT,  @nScn_SKU         INT,
      @nStep_NextTask   INT,  @nScn_NextTask    INT,
      @nStep_ToLOC      INT,  @nScn_ToLOC       INT,
      @nStep_Exit       INT,  @nScn_Exit        INT,
      @nStep_ShortPick  INT,  @nScn_ShortPick   INT,
      @nStep_Reason     INT,  @nScn_Reason      INT

   SELECT
      @nStep_Start      = 0, 
      @nStep_DropID     = 1,  @nScn_DropID      = 2680,
      @nStep_FromLOC    = 2,  @nScn_FromLOC     = 2681,
      @nStep_FromID     = 3,  @nScn_FromID      = 2682,
      @nStep_SKU        = 4,  @nScn_SKU         = 2683,
      @nStep_NextTask   = 5,  @nScn_NextTask    = 2684,
      @nStep_ToLOC      = 6,  @nScn_ToLOC       = 2685,
      @nStep_Exit       = 7,  @nScn_Exit        = 2686,
      @nStep_ShortPick  = 8,  @nScn_ShortPick   = 2687,
      @nStep_Reason     = 9,  @nScn_Reason      = 2109
   DECLARE 
      @nMOBRECStep           INT,
      @nMOBRECScn            INT,
      @cTaskDetailKey         NVARCHAR(10) = '',
      @cPendingTaskDetailKey    NVARCHAR(10) = '',
      @b_success              INT = 1,
      @cTTMTaskType           NVARCHAR(10),
      @cSuggID                NVARCHAR(18),
      @cSuggToLOC             NVARCHAR(10),
      @cSuggSKU               NVARCHAR(20),
      @cSKUDesc               NVARCHAR(60),
      @cSuggLOT               NVARCHAR(10),
      @cSuggFromLOC           NVARCHAR(10),
      @nQTY_RPL               INT,
      @nSystemQTY             NVARCHAR(10),
      @cPickMethod            NVARCHAR(10),
      @nTransit               INT,
      @cDropID                NVARCHAR(20),
      @cListKey               NVARCHAR(10),
      @cUserName              NVARCHAR(18),
      @cReasonCode            NVARCHAR(10),
      @cStatus                NVARCHAR(10),
      @cDefaultToLOC          NVARCHAR(10),
      @cDefaultSuggToLOC      NVARCHAR(10),
      @cLocShowDescr          NVARCHAR(1),  
      @cLocDescr              NVARCHAR(20),
      @cToLOC                 NVARCHAR(10),
      @cFinalLOC              NVARCHAR(10),
      @cTaskStatus            NVARCHAR(10),
      @cToLOCCat              NVARCHAR(10),
      @nRowCount              INT,
      @cTaskUserKey           NVARCHAR(18),
      @cAreaKey               NVARCHAR(10),
      @cHoldID        NVARCHAR( 20),
      @cHoldLoc       NVARCHAR( 20),
      @cOption        NVARCHAR( 20),
      @nFromStep           INT,
      @nFromScn            INT,
      @cExtendedValidateSP NVARCHAR( 20),
      @cExtendedUpdateSP   NVARCHAR( 20),
      @cSQL                NVARCHAR(MAX),
      @cSQLParam           NVARCHAR(MAX),
      @nQTY                INT,
      @c_outstring         NVARCHAR(255),
      @cMessage01              NVARCHAR(125),
      @cMessage02              NVARCHAR(125),
      @cMessage03              NVARCHAR(125),
      @cMessage04              NVARCHAR(125),
      @cMessage05              NVARCHAR(125)
   DECLARE @nScn_ReasonCode INT = 6620  
   DECLARE @c_InventoryHoldKey NVARCHAR(10)
   DECLARE @nTranCount  INT
   SELECT 
      @nMOBRECStep        = Step,
      @nMOBRECScn         = Scn,
      @cUserName           = UserName,
      @cTaskDetailKey  = V_TaskDetailKey,
      @cSuggFromLOC    = V_LOC,
      @cSuggID         = V_ID,
      @cSuggSKU        = V_SKU,
      @nFromScn           = V_FromScn,
      @nFromStep          = V_FromStep,
      @cDropID            = V_String3,
      @cPickMethod        = V_String4,
      @cSuggToloc         = V_String5,
      @cListKey            = V_String7,
      @cLocShowDescr      = V_String14,
      @cExtendedValidateSP = V_String17,
      @cExtendedUpdateSP   = V_String22,
      @nQTY_RPL            = V_Integer1,
      @nQTY                = V_Integer4
   FROM RDT.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN
   SAVE TRAN rdt_1764ExtScn02

   IF @nFunc = 1764 -- TM Replen
   BEGIN
      IF @nMOBRECStep = 0 OR (@nMOBRECStep = 7 AND @nStep <> 7) -- StartTM or ExitTM back to start
      BEGIN
         SET @cTaskDetailKey = @cOutField06

         SELECT
            @cUDF01 = CASE WHEN TD.PickMethod = 'PP' THEN LA.Lottable11 ELSE TD.ToID END,
            @cOutField01 = TD.PickMethod,
            @cOutField03 = TD.FromLOC
         FROM dbo.TaskDetail TD WITH(NOLOCK)
         JOIN LOTAttribute LA WITH(NOLOCK) ON TD.LOT = LA.LOT AND TD.StorerKey = LA.StorerKey
         WHERE TD.TaskDetailKey = @cTaskDetailKey

         SET @cOutField02 = @cUDF01
         SET @cOutField04 = '' -- FromLOC
         SET @cOutField10 = '' -- ExtendedInfo

         SET @nAfterStep = @nStep_FromLOC
         SET @nAfterScn = @nScn_FromLOC
         GOTO QUIT
      END
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
                  GOTO Step_Reason_Fail
               END

			   IF EXISTS (
			      SELECT 1 
				  FROM LOC L WITH(NOLOCK)
				     INNER JOIN CODELKUP C WITH(NOLOCK)
				        ON C.LISTNAME = 'JCBBKRCODE'
						AND C.StorerKey = @cStorerKey
						AND C.Long = L.LocationCategory
			      WHERE LOC = @cSuggFromLOC 
				     AND L.Facility = @cFacility
			   )
			   BEGIN
			      IF @cReasonCode NOT IN (
				     SELECT Short 
					 FROM CODELKUP C WITH(NOLOCK)
					    INNER JOIN LOC L WITH(NOLOCK)
						   ON L.LocationCategory = C.Long
					 WHERE C.LISTNAME = 'JCBBKRCODE' 
					    AND C.StorerKey = @cStorerKey
						AND L.Facility = @cFacility
						AND L.Loc = @cSuggFromLOC
				  )
				  BEGIN
			         SET @nErrNo = 218259
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Step_Reason_Fail
				  END
			   END

               -- Extended validate
               IF @cExtendedValidateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @cToLoc, @nErrNo OUTPUT, @cErrMsg OUTPUT'
                     SET @cSQLParam =
                        '@nMobile         INT,        ' +
                        '@nFunc           INT,        ' +
                        '@cLangCode       NVARCHAR( 3),   ' +
                        '@nStep           INT,        ' +
                        '@cTaskdetailKey  NVARCHAR( 10),  ' +
                        '@cToLoc          NVARCHAR( 10),'+
                        '@nErrNo          INT OUTPUT, ' +
                        '@cErrMsg         NVARCHAR( 20) OUTPUT'

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey,@cSuggToloc, @nErrNo OUTPUT, @cErrMsg OUTPUT

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
                     GOTO Step_Reason_Fail

                  -- Confirm (update TaskDetail to status 5)
                  IF @nFromStep = 8 --Short pick
                  BEGIN
                     EXEC rdt.rdt_TM_Replen_Confirm @nMobile, @nFunc, @cLangCode, @cUserName, @cFacility, @cStorerKey,
                        @cTaskDetailKey,
                        @cDropID,
                        @nQTY,
                        @cReasonCode,
                        @cListKey,
                        @nErrNo  OUTPUT,
                        @cErrMsg OUTPUT
                     IF @nErrNo <> 0
                        GOTO Quit
                  END

                  -- Get task reason info
                  DECLARE @cContinueProcess         NVARCHAR(10)
                  DECLARE @cRemoveTaskFromUserQueue NVARCHAR(10)
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
                        SET @nErrNo = 72293
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsSkipTskFail
                        GOTO Step_Reason_Fail
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
                        SET @nErrNo = 72294
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdTaskdetFail
                           GOTO Step_Reason_Fail
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
                           SET @nErrNo = 72295
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdTaskdetFail
                           GOTO Step_Reason_Fail
                        END
                     END

                     -- Cancel picked UCC
                     IF EXISTS( SELECT 1 FROM rdt.rdtRPFLog WITH (NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey)
                     BEGIN
                        DELETE rdt.rdtRPFLog WHERE TaskDetailKey = @cTaskDetailKey
                        IF @@ERROR <> 0
                        BEGIN
                           SET @nErrNo = 72296
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DelRPFLogFail
                           GOTO Step_Reason_Fail
                        END
                     END
                  END

                  -- Continue process current task
                  IF @cContinueProcess = '1'
                  BEGIN
                     -- Back to DropID screen
                     IF @nFromStep = @nStep_DropID
                     BEGIN
                        SET @cOutField01 = '' -- DropID
                        SET @cOutField10 = '' -- ExtendedInfo
                        
                        SET @nAfterScn = @nScn_DropID
                        SET @nAfterStep = @nStep_DropID
                     END

                     -- Back to FromLOC screen
                     IF @nFromStep = @nStep_FromLOC
                     BEGIN
                        SELECT @cLocDescr = SUBSTRING( Descr, 1, 20) FROM dbo.LOC WITH (NOLOCK) WHERE Facility = @cFacility AND LOC = @cSuggFromLOC
                        IF ISNULL( @cLocDescr, '') = ''
                           SET @cLocDescr = @cSuggFromLOC

                        SET @cOutField01 = @cPickMethod
                        SET @cOutField02 = @cDropID
                        SET @cOutField03 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr ELSE @cSuggFromLOC END
                        SET @cOutField04 = '' -- FromLOC
                        SET @cOutField10 = '' -- ExtendedInfo
                        
                        SET @nAfterScn = @nScn_FromLOC
                        SET @nAfterStep = @nStep_FromLOC
                     END

                     -- Go to next task screen
                     IF @nFromStep = @nStep_ShortPick -- Short pick screen
                     BEGIN
                        SET @cOption = ''
                        SET @cOutField01 = '' -- Option
                        SET @cOutField10 = '' -- ExtendedInfo
                        
                        SET @nAfterScn = @nScn_NextTask
                        SET @nAfterStep = @nStep_NextTask
                     END
                  END
                  ELSE
                  BEGIN
                     -- Setup RDT storer config ContProcNotUpdTaskStatus, to avoid nspRFRSN01 set TaskDetail.Status = '9', when ContinueProcess <> 1

                     -- Go to next task/exit TM screen
                     IF @cPickMethod = 'FP'
                     BEGIN
                        -- Prepare next screen var
                        SET @cOutField01 = @cToLOC
                        SET @cOutField10 = '' -- ExtendedInfo
                        
                        SET @nAfterScn = @nScn_Exit
                        SET @nAfterStep = @nStep_Exit
                     END

                     -- Go to next task screen
                     IF @cPickMethod = 'PP'
                     BEGIN
                        SET @cOption = ''
                        SET @cOutField01 = '' -- Option
                        SET @nAfterScn = @nScn_NextTask
                        SET @nAfterStep = @nStep_NextTask
                     END
                  END
               END
               ELSE -- Customerize process
               BEGIN
                  
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

                  IF @cPickMethod = 'FP'
                  BEGIN
                     -- Prepare next screen var
                     SET @cOutField01 = @cToLOC
                     SET @cOutField10 = '' -- ExtendedInfo
                     
                     SET @nAfterScn = @nScn_Exit
                     SET @nAfterStep = @nStep_Exit
                  END

                  -- Go to next task screen
                  IF @cPickMethod = 'PP'
                  BEGIN
                     SET @cOption = ''
                     SET @cOutField01 = '' -- Option
                     SET @nAfterScn = @nScn_NextTask
                     SET @nAfterStep = @nStep_NextTask
                  END
               END

               IF @cExtendedUpdateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT'
                     SET @cSQLParam =
                        '@nMobile         INT,           ' +
                        '@nFunc           INT,           ' +
                        '@cLangCode       NVARCHAR( 3),  ' +
                        '@nStep           INT,           ' +
                        '@cTaskdetailKey  NVARCHAR( 10), ' +
                        '@nErrNo          INT OUTPUT,    ' +
                        '@cErrMsg         NVARCHAR( 20) OUTPUT '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                     BEGIN
                        GOTO RollBackTran
                     END
                  END
               END
            END
            IF @nInputKey = 0 -- ESC
            BEGIN
               -- Go to DropID screen
               IF @nFromStep = @nStep_DropID
               BEGIN
                  -- Prepare next screen variable
                  SET @cDropID = ''
                  SET @cOutField01 = '' -- DropID
                  SET @cOutField10 = '' -- ExtendedInfo
               END

               -- Go to FromLOC screen
               IF @nFromStep = @nStep_FromLOC
               BEGIN
                  SELECT @cLocDescr = SUBSTRING( Descr, 1, 20) FROM dbo.LOC WITH (NOLOCK) WHERE Facility = @cFacility AND LOC = @cSuggFromLOC
                  IF ISNULL( @cLocDescr, '') = ''
                     SET @cLocDescr = @cSuggFromLOC

                  -- Prepare next screen variable
                  SET @cOutField01 = @cPickMethod
                  SET @cOutField02 = @cDropID
                  SET @cOutField03 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr ELSE @cSuggFromLOC END
                  SET @cOutField04 = '' -- FromLOC
                  SET @cOutField10 = '' -- ExtendedInfo
                  SET @cUDF01 = @cDropID
               END

               -- Go to short pick screen
               IF @nFromStep = @nStep_ShortPick
               BEGIN
                  -- Prepare next screen variable
                  SET @cOption = ''
                  SET @cOutField01 = '' -- Option
               END

               -- Back to prev screen
               SET @nAfterScn = @nFromScn
               SET @nAfterStep = @nFromStep
            END
            
            GOTO Quit

            Step_Reason_Fail:
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
         IF @nInputKey = 1
         BEGIN
            IF @cInField01 = '9' -- Close Pallet
            BEGIN
               IF NOT EXISTS (SELECT 1 FROM TASKDETAIL WITH(NOLOCK) WHERE ListKey = @cListKey AND Status = '5')
               AND EXISTS (SELECT 1 FROM TaskDetail WITH(NOLOCK) WHERE TaskDetailKey = @cTaskdetailKey AND Status = '0')
               BEGIN
                  SET @nAfterStep = 7
                  SET @nAfterScn = 4026
                  SET @cOutField01 = ''
                  GOTO Quit
               END
                       
               IF NOT EXISTS (SELECT 1 FROM TASKDETAIL WITH(NOLOCK) WHERE (ListKey = @cListKey AND Status = '5') OR (TaskDetailKey = @cTaskdetailKey AND Status = '3'))
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
            IF EXISTS( SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) WHERE TaskDetailKey = @cTaskdetailKey AND STATUS = 'S')
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
   END
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1764ExtScn02 -- Only rollback change made here
Fail:
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON rdt.rdt_1764ExtScn02 TO NSQL 
GO  
