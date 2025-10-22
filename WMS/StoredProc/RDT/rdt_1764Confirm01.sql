SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_1764Confirm01                                   */
/* Copyright      :                                                     */
/*                                                                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author    Purposes                                   */
/* 2025-06-18 1.0  Dennis    FCR-3959 Created                           */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1764Confirm01] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @cUserName      NVARCHAR( 18),
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cTaskDetailKey NVARCHAR( 10),
   @cDropID        NVARCHAR( 20),
   @nQTY           INT,
   @cReasonKey     NVARCHAR( 10),
   @cListKey       NVARCHAR( 10),
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT,
   @nDebug         INT = 0
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cNewTaskDetailKey NVARCHAR(10)
   DECLARE @cPickDetailKey NVARCHAR(10)
   DECLARE @cTaskType   NVARCHAR( 10)
   DECLARE @cFromLOC    NVARCHAR( 10)
   DECLARE @cToLOC      NVARCHAR( 10)
   DECLARE @cFromID     NVARCHAR( 18)
   DECLARE @cLOT        NVARCHAR( 10)
   DECLARE @cPickMethod NVARCHAR( 10)
   DECLARE @nSystemQTY  INT
   DECLARE @bSuccess    INT
   DECLARE @cStatus     NVARCHAR( 10)
   DECLARE @cSQL        NVARCHAR(1000)
   DECLARE @cSQLParam   NVARCHAR(1000)
   DECLARE @nQTY_PD     INT
   DECLARE @nPickQTY    INT
   DECLARE @nNewTaskQty INT
   DECLARE @nOrgTaskQty INT
   DECLARE @nShortQTY   INT
   DECLARE @cTask       NVARCHAR(3)
   DECLARE @cLOCType    NVARCHAR(10)
   DECLARE @cPickConfirmStatus NVARCHAR( 1),
   @nTaskQTY            INT,
   @nNewSystemQTY       INT

   -- Init var
   SET @nErrNo = 0
   SET @cErrMsg = ''
   SET @cNewTaskDetailKey = ''
   SET @nNewTaskQTY = 0

   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT

   -- Get task info
   SET @nSystemQTY = 0
   SELECT 
      @cTaskType = TaskType, 
      @cFromLOC = FromLOC, 
      @cFromID = FromID, 
      @cToLOC = ToLOC, 
      @nTaskQTY = QTY, 
      @nSystemQTY = SystemQTY, 
      @cLOT = LOT, 
      @cPickMethod = PickMethod, 
      @cStatus = Status
   FROM dbo.TaskDetail WITH (NOLOCK) 
   WHERE TaskDetailKey = @cTaskDetailKey

   -- Check task already confirm/SKIP/CANCEL/Hold
   IF @cStatus IN ('5', '0', 'X','S')
      RETURN

   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_TM_Replen_Confirm01 -- For rollback or commit only our own transaction

   -- Split task (PP, close pallet with balance)
   IF @nQTY < @nTaskQTY AND   -- not full replen
      @cReasonKey = '' AND    -- not short reason
      @cPickMethod <> 'FP'    -- not full pallet
   BEGIN
      DECLARE @b_success INT

      -- Get new TaskDetailKey
      SET @b_success = 1
      EXECUTE dbo.nspg_getkey
         'TaskDetailKey'
         , 10
         , @cNewTaskDetailKey OUTPUT
         , @b_success OUTPUT
         , @nErrNo    OUTPUT
         , @cErrMsg   OUTPUT
      IF @b_success <> 1
      BEGIN
         SET @nErrNo = 74251
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GetKey Fail
         GOTO RollBackTran
      END
      
      -- Calc SystemQTY
      IF @nQTY <= @nSystemQTY
      BEGIN
         SET @nNewSystemQTY = @nSystemQTY - @nQTY
         SET @nSystemQTY = @nQTY
      END
      ELSE
         SET @nNewSystemQTY = 0
         
      -- Insert TaskDetail
      INSERT INTO TaskDetail (
         TaskDetailKey, RefTaskKey, ListKey, Status, UserKey, ReasonKey, DropID, QTY, SystemQTY, ToLOC, ToID, 
         TaskType, Storerkey, Sku, LOT, UOM, UOMQTY, FromLOC, LogicalFromLOC, FromID, LogicalToLOC, CaseID, PickMethod, StatusMsg, Priority, SourcePriority, HoldKey, UserPosition, UserKeyOverRide, SourceType, SourceKey, PickDetailKey, OrderKey, OrderLineNumber, WaveKey, Message01, Message02, Message03, LoadKey, AreaKey, GroupKey)
      SELECT
         @cNewTaskDetailKey, @cTaskDetailKey, '', '0', '', '', '', (@nTaskQTY - @nQTY), @nNewSystemQTY, 
         ToLOC = CASE WHEN FinalLOC = '' THEN ToLOC ELSE FinalLOC END, 
         ToID  = CASE WHEN FinalID  = '' THEN ToID  ELSE FinalID  END, 
         TaskType, Storerkey, Sku, LOT, UOM, UOMQTY, FromLOC, LogicalFromLOC, FromID, LogicalToLOC, CaseID, PickMethod, StatusMsg, Priority, SourcePriority, HoldKey, UserPosition, UserKeyOverRide, SourceType, SourceKey, PickDetailKey, OrderKey, OrderLineNumber, WaveKey, Message01, Message02, Message03, LoadKey, AreaKey, GroupKey
      FROM TaskDetail WITH (NOLOCK)
      WHERE TaskDetailKey = @cTaskDetailKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 74252
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InsTaskdetFail
         GOTO RollBackTran
      END
   END
   
   -- Update Task
   UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
      Status = '5', -- Picked
      DropID = @cDropID, 
      ToID = CASE WHEN PickMethod = 'PP' THEN @cDropID ELSE ToID END, 
      QTY = @nQTY,
      SystemQTY = @nSystemQTY, 
      ReasonKey = @cReasonKey, 
      EndTime = GETDATE(),
      EditDate = GETDATE(),
      EditWho  = @cUserName, 
      Trafficcop = NULL
   WHERE TaskDetailKey = @cTaskDetailKey
   IF @@ERROR <> 0
   BEGIN
      SET @nErrNo = 74253
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdTaskdetFail
      GOTO RollBackTran
   END
   
   -- Get Confirm Extended config
   DECLARE @cConfirmExtUpdSP NVARCHAR(20)
   SET @cConfirmExtUpdSP = rdt.rdtGetConfig( @nFunc, 'ConfirmExtUpdSP', @cStorerKey)
   IF @cConfirmExtUpdSP = '0'
      SET @cConfirmExtUpdSP = ''
   
   -- Confirm Extended update
   IF @cConfirmExtUpdSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cConfirmExtUpdSP AND type = 'P')
      BEGIN
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cConfirmExtUpdSP) +
            ' @nMobile, @nFunc, @cLangCode, @cTaskdetailKey, @cNewTaskDetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT'
         SET @cSQLParam =
            '@nMobile            INT,           ' +
            '@nFunc              INT,           ' +
            '@cLangCode          NVARCHAR( 3),  ' +
            '@cTaskdetailKey     NVARCHAR( 10), ' +
            '@cNewTaskDetailKey  NVARCHAR( 10), ' +
            '@nErrNo             INT OUTPUT,    ' +
            '@cErrMsg            NVARCHAR( 20) OUTPUT ' 

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, @cTaskdetailKey, @cNewTaskDetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT

         IF @nErrNo <> 0
            GOTO Quit
      END
   END
   
   COMMIT TRAN rdt_TM_Replen_Confirm01 -- Only commit change made here
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_TM_Replen_Confirm01 -- Only rollback change made here
Fail:
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO
GRANT EXECUTE ON  [RDT].[rdt_1764Confirm01] TO [NSQL]
GO
