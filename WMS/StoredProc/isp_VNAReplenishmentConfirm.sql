IF NOT EXISTS(SELECT 1 FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID = 1202 AND Lang_Code = 'ENG' AND Message_Type = 'FNC')
   INSERT INTO rdt.RDTMsg(Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType, Func, URL, Message_Text_Long)
   VALUES( 1202, 'ENG', 'FNC', 'VNAOUT Replenishment Confirm', 'isp_VNAReplenishmentConfirm', '0', '0', '', '' )
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[isp_VNAReplenishmentConfirm]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [dbo].[isp_VNAReplenishmentConfirm]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: isp_VNAReplenishmentConfirm                         */
/* Copyright      : Maersk WMS                                          */
/*                                                                      */
/* Date        Rev  Author    Purposes                                  */
/* 2024-03-08  1.0  NLT013    UWP-16452 Created                         */
/* 2024-04-30  2.0  NLT013    UWP-16455 Cannot find the sencond task    */
/************************************************************************/

CREATE PROC [dbo].[isp_VNAReplenishmentConfirm] (
   @cTaskDetailKey                  NVARCHAR( 10),
   @nErrNo                          INT            OUTPUT,
   @cErrMsg                         NVARCHAR( 255) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @nMobile                      INT,
      @cLangCode                    NVARCHAR(3),
      @nFunc                        INT,
      @nInternalErrNo               INT,

      @cSQL                         NVARCHAR(MAX),
      @cSQLParam                    NVARCHAR(MAX),
      @cConfirmSP                   NVARCHAR( 20),
      @cPickConfirmStatus           NVARCHAR( 1),
      @bSuccess                     INT,
      @cFacility                    NVARCHAR( 5),
      @cStorerKey                   NVARCHAR( 15),

      @nQty                         INT,
      @nQTY_Bal                     INT,
      @nQTY_PD                      INT,
      @nQTY_Move                    INT,
      @cUOM                         NVARCHAR( 5),
      @nUOMQty                      INT,

      @cPickDetailKey               NVARCHAR( 10),
      @cTaskType                    NVARCHAR( 10),
      @cStatus                      NVARCHAR( 10),
      @cTaskCode                    NVARCHAR( 10),
      @cLOT                         NVARCHAR( 10),
      @cPickMethod                  NVARCHAR( 10),
      @cSourceType                  NVARCHAR( 30),
      @cFromLoc                     NVARCHAR( 10),
      @cFromID                      NVARCHAR( 18),
      @cSku                         NVARCHAR( 20),
      @cListKey                     NVARCHAR( 10),

      @cTaskUserKey                 NVARCHAR( 18),
      @cTaskFromLoc                 NVARCHAR( 10),
      @cTaskToLoc                   NVARCHAR( 10),
      @cTaskFinalLoc                NVARCHAR( 10),
      @cID                          NVARCHAR( 18),
      @cTaskStatus                  NVARCHAR( 10),
      @cLoadKey                     NVARCHAR( 10),

      @cVNAOUT                      NVARCHAR( 10) = 'VNAOUT',
      @cRPF                         NVARCHAR( 10) = 'RPF',
      @cRP1                         NVARCHAR( 10) = 'RP1',
      @cUserName                    NVARCHAR( 18),
      @cNewTaskDetailKey            NVARCHAR( 10)


   -- Init var
   SET @nFunc              = 1202
   SET @nMobile            = -1
   SET @cLangCode          = 'ENG'
   SET @nQTY_Move          = 0
   SET @nErrNo             = 0
   SET @cErrMsg            = ''
   SET @nInternalErrNo     = 0
   SET @cSourceType        = 'isp_VNAReplenishmentConfirm'
   SET @cPickConfirmStatus = '9'
   SET @cUserName          = SYSTEM_USER

   -- Get task info
   SELECT
      @cTaskType        = td.TaskType,
      @cTaskCode        = ISNULL(td.Message03, ''),
      @cFacility        = ISNULL(loc.Facility, ''),
      @cStorerKey       = td.StorerKey,
      @cTaskFromLoc     = td.FromLoc,
      @cTaskToLoc       = ToLoc,
      @cID              = ToID,
      @nQTY             = td.Qty,
      @cTaskUserKey     = td.UserKey,
      @cTaskStatus      = td.Status,
      @cListKey         = td.ListKey,
      @cStatus          = td.Status,
      @cTaskFinalLoc    = td.FinalLOC,
      @cLoadKey         = td.LoadKey,
      @cLot             = td.Lot,
      @cUOM             = td.UOM,
      @nUOMQty          = td.UOMQty
   FROM dbo.TaskDetail td WITH(NOLOCK)
   INNER JOIN dbo.Loc loc WITH(NOLOCK)
      ON td.FromLoc = loc.Loc
   INNER JOIN dbo.Loc loc1 WITH(NOLOCK)
      ON td.ToLoc = loc1.Loc
      AND loc.Facility = loc1.Facility
   WHERE TaskDetailKey = @cTaskDetailKey

   -- Check task already SKIP/CANCEL
   IF @cStatus <> '3'
   BEGIN
      SET @nErrNo = 212536
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Task Status
      RETURN
   END

   IF @cTaskType <> @cVNAOUT OR  @cTaskCode <> @cRPF
   BEGIN
      SET @nErrNo = 212537
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Not VNAOUTRPF Task
      RETURN
   END

   IF @cTaskFinalLoc IS NULL OR TRIM(@cTaskFinalLoc) = ''
   BEGIN
      SET @nErrNo = 212546
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Final Loc is missing
      RETURN
   END

   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN isp_VNAReplenishmentConfirm -- For rollback or commit only our own transaction

   -- Unlock  suggested location
   EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
      ,@cTaskFromLoc             --@cFromLOC
      ,@cID                      --@cFromID
      ,@cTaskToLoc               --@cSuggestedLOC
      ,''                        --@cStorerKey
      ,@nErrNo  OUTPUT
      ,@cErrMsg OUTPUT

   IF @nErrNo <> 0  
   BEGIN
      SET @nInternalErrNo = 212550
      SET @cErrMsg = CONCAT_WS(',', rdt.rdtgetmessage( @nInternalErrNo, @cLangCode, 'DSP'),  @nErrNo, @cErrMsg ) -- Unlock Loc Fail, details:
      GOTO RollBackTran
   END

   -- Lock orders to prevent deadlock
   UPDATE ord SET
      EditDate = GETDATE(),
      EditWho = SUSER_SNAME(),
      TrafficCop = NULL
   FROM Orders ord WITH(ROWLOCK)
   INNER JOIN PickDetail pkd WITH (NOLOCK)
      ON ord.StorerKey = pkd.StorerKey
      AND ord.OrderKey = pkd.OrderKey
   WHERE pkd.TaskDetailKey = @cTaskDetailKey

   IF @@ERROR <> 0
   BEGIN
      SET @nErrNo = 212533
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Lock Order Fail
      GOTO RollBackTran
   END

   -- Move inventory
   EXECUTE rdt.rdt_Move
      @nMobile     = @nMobile,
      @cLangCode   = @cLangCode,
      @nErrNo      = @nErrNo  OUTPUT,
      @cErrMsg     = @cErrMsg OUTPUT,
      @cSourceType = @cSourceType,
      @cStorerKey  = @cStorerKey,
      @cFacility   = @cFacility,
      @cFromLOC    = @cTaskFromLoc,
      @cToLOC      = @cTaskToLoc,
      @cFromID     = @cID,
      @cToID       = @cID,
      @nFunc       = @nFunc,
      @nQTYReplen  = @nQTY

   IF @nErrNo <> 0
   BEGIN
      SET @nInternalErrNo = 212541
      SET @cErrMsg = CONCAT_WS(',', rdt.rdtgetmessage( @nInternalErrNo, @cLangCode, 'DSP'),  @nErrNo, @cErrMsg )--Move Inentory Fail, details:
      GOTO RollBackTran
   END

   -- Reduce QTYReplen
   UPDATE dbo.LOTxLOCxID WITH (ROWLOCK) SET
      QTYReplen = 0
   WHERE LOC = @cTaskFromLoc
      AND ID = @cID

   IF @@ERROR <> 0
   BEGIN
      SET @nErrNo = 212534
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update LOTxLOCxID Fail
      GOTO RollBackTran
   END

   -- Unlock  suggested location
   EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
      ,''            --@cFromLOC
      ,@cID           --@cFromID
      ,@cTaskFinalLoc   --@cSuggestedLOC
      ,''            --@cStorerKey
      ,@nErrNo  OUTPUT
      ,@cErrMsg OUTPUT

   IF @nErrNo <> 0  
   BEGIN
      SET @nInternalErrNo = 212544
      SET @cErrMsg = CONCAT_WS(',', rdt.rdtgetmessage( @nInternalErrNo, @cLangCode, 'DSP'),  @nErrNo, @cErrMsg ) -- Unlock Loc Fail, details:
      GOTO RollBackTran
   END

   -- Update Task
   UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
      Status      = @cPickConfirmStatus, -- Closed
      EndTime     = GETDATE(),
      EditDate    = GETDATE(),
      EditWho     = @cUserName,
      Trafficcop  = NULL,
      StatusMsg   = ''
   WHERE TaskDetailKey = @cTaskDetailKey
   IF @@ERROR <> 0
   BEGIN
      SET @nErrNo = 212535
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update Pick Detail Fail
      GOTO RollBackTran
   END

   -- Create next task
   EXEC rdt.rdt_TM_Replen_CreateNextTask @nMobile, @nFunc, @cLangCode,
      @cUserName,
      @cListKey,
      @nErrNo  OUTPUT,
      @cErrMsg OUTPUT
   IF @nErrNo <> 0
   BEGIN
      SET @nInternalErrNo = 212543
      SET @cErrMsg = CONCAT_WS(',', rdt.rdtgetmessage( @nInternalErrNo, @cLangCode, 'DSP'),  @nErrNo, @cErrMsg )--Create 2nd task Fail, details:
      GOTO RollBackTran
   END

   SELECT @cNewTaskDetailKey = TaskDetailKey
   FROM dbo.TaskDetail td WITH(NOLOCK)
   WHERE StorerKey         = @cStorerKey
      AND TaskType         = @cRP1
      AND FromID           = @cID
      AND Status           = '0'
      AND FromLoc          = @cTaskToLoc
      AND ListKey          = @cListKey
      --AND ToLoc            = @cTaskFinalLoc

   IF @cNewTaskDetailKey IS NULL OR TRIM(@cNewTaskDetailKey) = ''
   BEGIN
      SET @nErrNo = 212538
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No new task
      GOTO RollBackTran
   END

   UPDATE dbo.TaskDetail WITH (ROWLOCK) SET 
      RefTaskKey        = @cTaskDetailKey,
      TransitCount      = 1
   WHERE TaskDetailKey = @cNewTaskDetailKey

   IF @@ERROR <> 0
   BEGIN
      SET @nErrNo = 212545
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update new task fail
      GOTO RollBackTran
   END

   -- Loc PF location
   EXEC rdt.rdt_Putaway_PendingMoveIn 
      @cUserName              = ''
      ,@cType                 = 'LOCK'
      ,@cFromLOC              = @cTaskToLoc            --@cFromLOC
      ,@cFromID               = @cID           --@cFromID
      ,@cSuggestedLOC         = @cTaskFinalLoc   --@cSuggestedLOC
      ,@cStorerKey            = ''            --@cStorerKey
      ,@cTaskDetailKey        = @cNewTaskDetailKey
      ,@nErrNo                = @nErrNo  OUTPUT
      ,@cErrMsg               = @cErrMsg OUTPUT

   IF @nErrNo <> 0  
   BEGIN
      SET @nInternalErrNo = 212549
      SET @cErrMsg = CONCAT_WS(',', rdt.rdtgetmessage( @nInternalErrNo, @cLangCode, 'DSP'),  @nErrNo, @cErrMsg ) -- Loc PF Loc Fail, details:
      GOTO RollBackTran
   END

   -- Reduce QTYReplen
   UPDATE dbo.LOTxLOCxID WITH (ROWLOCK) SET
      QTYReplen = 0
   WHERE LOC = @cTaskFromLoc
      AND ID = @cID

   IF @@ERROR <> 0
   BEGIN
      SET @nErrNo = 212534
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update LOTxLOCxID Fail
      GOTO RollBackTran
   END

   -- Add back QTYReplen
   UPDATE dbo.LOTxLOCxID WITH (ROWLOCK) SET
      QTYReplen = @nQTY
   WHERE LOC = @cTaskToLoc
      AND ID = @cID

   IF @@ERROR <> 0
   BEGIN
      SET @nErrNo = 212534
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update LOTxLOCxID Fail
      GOTO RollBackTran
   END

   COMMIT TRAN isp_VNAReplenishmentConfirm -- Only commit change made here
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN isp_VNAReplenishmentConfirm -- Only rollback change made here

Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [dbo].[isp_VNAReplenishmentConfirm] TO NSQL
GO
