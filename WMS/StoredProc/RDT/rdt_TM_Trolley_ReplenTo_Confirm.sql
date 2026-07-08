SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/******************************************************************************/
/* Store procedure: rdt_TM_Trolley_ReplenTo_Confirm                           */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2026-02-01 1.0  Cuize      FCR-9735. Created                               */
/* 2026-07-08 1.1  NYE018     UWP-60625 Set UCC status=6 for loseUCC loc      */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_TM_Trolley_ReplenTo_Confirm] (
   @nMobile    INT,
   @nFunc      INT, 
   @cLangCode  NVARCHAR( 3), 
   @cFacility  NVARCHAR( 5), 
   @cStorerKey NVARCHAR( 15), 
   @cUserName  NVARCHAR( 18), 
   @cTrolleyNo NVARCHAR( 10), 
   @cUCC       NVARCHAR( 20), 
   @cLOC       NVARCHAR( 10), 
   @nErrNo     INT       OUTPUT, 
   @cErrMsg    NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cFromLOC       NVARCHAR( 10)
   DECLARE @cFromID        NVARCHAR( 18)
   DECLARE @cToLOC         NVARCHAR( 10)
   DECLARE @cWaveKey       NVARCHAR(10)
   DECLARE @cToID          NVARCHAR( 18)
   DECLARE @cOrderKey      NVARCHAR( 10)
   DECLARE @cTaskDetailKey NVARCHAR( 10)
   DECLARE @cDropID        NVARCHAR( 20)
   DECLARE @nTranCount     INT

   SET @nTranCount = @@TRANCOUNT

   -- Get UCC info
   SELECT TOP 1 
      @cFromLOC = LOC, 
      @cFromID = ID
   FROM dbo.UCC WITH (NOLOCK)
   WHERE UCCNo = @cUCC 
      AND StorerKey = @cStorerKey
      AND Status IN ('1', '3')   -- (james01)
   
   -- Get final LOC
   SELECT
      @cTaskDetailKey = TaskDetailKey
   FROM rdt.rdtTrolleyLog WITH (NOLOCK) 
   WHERE TrolleyNo = @cTrolleyNo 
      AND UCCNo = @cUCC
      --AND Status = '1'

   SELECT TOP 1
      @cToLOC           =              Task.ToLoc,
      @cToID            =              Task.ToID,
      @cTaskdetailkey   =              Task.TaskDetailKey,
      @cWaveKey         =              Task.wavekey
   FROM TASKDETAIL TASK WITH (NOLOCK)
      JOIN rdt.rdtTrolleyLog T WITH (NOLOCK) ON (T.TaskDetailKey = Task.TaskDetailKey)
   WHERE T.TrolleyNo = @cTrolleyNo
      AND TASK.[Status] <> 'H'
      AND T.UCCNo = @cUCC

   -- Final LOC
   IF @cLOC <> ''
      SET @cToLOC = @cLOC

   -- To prevent missing TaskDetailKey (just in case) that will lock all orders
   IF @cTaskDetailKey = '' OR @cTaskDetailKey IS NULL
   BEGIN
      SET @nErrNo = 256663
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- UCC no TaskKey
      GOTO Quit
   END

   BEGIN TRAN
   SAVE TRAN rdt_TM_Trolley_ReplenTo_Confirm
   
   -- Lock orders to prevent deadlock
   DECLARE @curPD CURSOR
   SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT OrderKey
      FROM PickDetail WITH (NOLOCK) 
      WHERE TaskDetailKey = @cTaskDetailKey
      ORDER BY OrderKey
   OPEN @curPD
   FETCH NEXT FROM @curPD INTO @cOrderKey
   WHILE @@FETCH_STATUS = 0
   BEGIN
      -- Dummy update to lock order
      UPDATE Orders SET
         EditDate = GETDATE(),
         EditWho = SUSER_SNAME(), 
         TrafficCop = NULL
      WHERE OrderKey = @cOrderKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 256664
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- LockOrderFail
         GOTO RollBackTran
      END
      FETCH NEXT FROM @curPD INTO @cOrderKey
   END

   -- Move by UCC
   EXECUTE rdt.rdt_Move
      @nMobile     = @nMobile,
      @cLangCode   = @cLangCode,
      @nErrNo      = @nErrNo  OUTPUT,
      @cErrMsg     = @cErrMsg OUTPUT,
      @cSourceType = 'rdt_TM_Trolley_ReplenTo_Confirm',
      @cStorerKey  = @cStorerKey,
      @cFacility   = @cFacility,
      @cFromLOC    = @cFromLOC,
      @cToLOC      = @cToLOC,
      @cFromID     = @cFromID,
      @cToID       = @cToID,
      @cUCC        = @cUCC, 
      @nFunc       = @nFunc, 
      @cDropID     = @cUCC
   IF @nErrNo <> 0
      GOTO RollBackTran

   -- UWP-60625: set UCC status=6 for loseUCC loc
   IF EXISTS (SELECT 1 FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cToLOC AND loseUCC = '1' AND Facility = @cFacility)
   BEGIN
      BEGIN TRY
         UPDATE dbo.UCC WITH (ROWLOCK) SET
            Status   = '6',
            EditWho  = SUSER_SNAME(),
            EditDate = GETDATE()
         WHERE StorerKey = @cStorerKey
           AND UCCNo     = @cUCC
           AND Status   <> '6'
      END TRY
      BEGIN CATCH
         SET @nErrNo  = 256672
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Upd UCC lost fail
         GOTO RollBackTran
      END CATCH
   END

   UPDATE dbo.TaskDetail WITH(ROWLOCK)  -- close task
   SET
      FinalLOC = @cToLoc,
      [Status] = '9',
      EditWho = SUSER_SNAME(),
      EditDate = GETDATE()
   WHERE TaskDetailKey = @cTaskDetailKey
   IF @@ERROR <> 0
   BEGIN
      SET @nErrNo = 256668
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- close task fail
      GOTO RollBackTran
   END

   -- Remove Log
   DELETE rdt.rdtTrolleyLog
   WHERE TrolleyNo = @cTrolleyNo 
      AND UCCNo = @cUCC
      --AND Status = '1'
   IF @@ERROR <> 0
   BEGIN
      SET @nErrNo = 256665
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- DEL Log Fail
      GOTO RollBackTran
   END

   -- IF current wave finished, start relase CPK task
   IF ISNULL(@cWaveKey , '') <> ''
      AND NOT EXISTS(
         SELECT 1 FROM TASKDETAIL WITH (NOLOCK)
         WHERE wavekey = @cWaveKey
           AND status <> '9'
           AND TaskType IN ('RPF','ASTTPA')
      )
   BEGIN

      -- UPDATE all the waves with same dropid, need to release task
      DECLARE @waveToUpdate TABLE (
         WaveKey       NVARCHAR(10)
      );
      INSERT INTO @waveToUpdate (wavekey)

      SELECT DISTINCT(Wavekey )
      FROM PICKDETAIL WITH (NOLOCK)
      WHERE Storerkey = @cStorerKey
        AND DropID IN
      (
         SELECT DropID FROM PICKDETAIL WITH (NOLOCK)
         WHERE  WaveKey = @cWaveKey
           AND Storerkey = @cStorerKey
           AND ISNULL(Dropid,'') <> ''
      )

      DECLARE @waveKeyToProcess NVARCHAR(10);


      WHILE EXISTS (SELECT 1 FROM @waveToUpdate)
      BEGIN

         SELECT TOP 1 @waveKeyToProcess = wavekey
         FROM @waveToUpdate;

         --UPDATE PICKTASKS STATUS TO 0
         IF ISNULL(@waveKeyToProcess , '') <> ''
         AND NOT EXISTS(
            SELECT 1 FROM TASKDETAIL WITH (NOLOCK)
            WHERE wavekey = @waveKeyToProcess
              AND status <> '9'
              AND TaskType IN ('RPF','ASTTPA')
         )
         BEGIN
            UPDATE dbo.TaskDetail WITH(ROWLOCK)  -- UNLOCK TASK
            SET
               [Status] = '0',
               UserKey = '',
               EditWho = SUSER_SNAME(),
               EditDate = GETDATE()
            WHERE wavekey = @waveKeyToProcess
              AND TaskType IN ('CPK', 'ASTCPK')
              AND status = 'H'

         END

         DELETE FROM @waveToUpdate
         WHERE wavekey = @waveKeyToProcess;

      END
   END

   -- EventLog
   EXEC RDT.rdt_STD_EventLog
      @cActionType   = '4', -- Move
      @cUserID       = @cUserName,
      @nMobileNo     = @nMobile,
      @nFunctionID   = @nFunc,
      @cFacility     = @cFacility,
      @cStorerKey    = @cStorerkey,
      @cToLocation   = @cToLOC, 
      @cUCC          = @cUCC, --(cc01)
      @cRefNo2       = @cTrolleyNo, 
      @cTaskDetailKey = @cTaskDetailKey

   GOTO Quit

RollBackTran:
      ROLLBACK TRAN rdt_TM_Trolley_ReplenTo_Confirm
Quit:
   IF CURSOR_STATUS('variable', '@curPD') IN (0, 1)
   BEGIN
      IF CURSOR_STATUS('variable', '@curPD') = 1
         CLOSE @curPD;
      DEALLOCATE @curPD;
   END
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN
GO
GRANT EXECUTE ON [RDT].[rdt_TM_Trolley_ReplenTo_Confirm] TO nSQL
GO
