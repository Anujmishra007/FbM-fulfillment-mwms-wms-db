
/***************************************************************************/
/* Store procedure: rdt_1764CreateTask16                                   */
/* Copyright      : Maersk                                                 */
/*                                                                         */
/* Purpose: Cajamar                                                        */
/*                                                                         */
/* Called from:                                                            */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date        Rev    Author    Purposes                                   */
/* 2025/11/27  1.0.0  Jackc     FCR-8535 Created                           */
/* 2025/12/18  1.0.1  Jackc     FCR-8535 Skip create task if all full short*/
/* 2026/02/02  1.1.0  NickT     FCR-10467 Update ToLoc for second task     */
/****************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_1764CreateTask16] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @cUserName      NVARCHAR( 15), 
   @cListKey       NVARCHAR( 10),
   @nErrNo         INT          OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag  INT = 0

   DECLARE @nTranCount  INT
   DECLARE @nSuccess    INT
   DECLARE @cTaskDetailKey    NVARCHAR( 10)
   DECLARE @cNewTaskDetailKey NVARCHAR( 10)
   DECLARE @cStatus     NVARCHAR( 10)
   DECLARE @cWaveKey    NVARCHAR( 10)
   DECLARE @cStorerKey  NVARCHAR( 15)
   DECLARE @cSKU        NVARCHAR( 20)
   DECLARE @cLOT        NVARCHAR( 10)
   DECLARE @nQTY        INT
   DECLARE @cToLOC      NVARCHAR( 10)
   DECLARE @cToID       NVARCHAR( 18)
   DECLARE @cCaseID     NVARCHAR( 20)
   DECLARE @cFinalLOC   NVARCHAR( 10)
   DECLARE @cFinalID    NVARCHAR( 18)
   DECLARE @cTransitLOC NVARCHAR( 10)
   DECLARE @nTransitCount   INT
   DECLARE @cPriority       NVARCHAR( 10)
   DECLARE @cSourcePriority NVARCHAR( 10)
   DECLARE @cSourceType     NVARCHAR( 30)
   DECLARE @cOrgTaskKey     NVARCHAR( 30)
          ,@cReplenByRPT    NVARCHAR(1) 
          ,@nUOMQty         INT
          ,@cCreateNextTaskSP NVARCHAR(30)
          ,@cSQL              NVARCHAR(1000)
          ,@cSQLParam         NVARCHAR(1000)
          ,@cUOM              NVARCHAR(5)
          ,@cPickMethod       NVARCHAR(10)
   
   -- Init var
   SET @nErrNo = 0
   SET @cErrMsg = ''

   -- Get ToLOC from latest transit task
   SELECT TOP 1 
      @cWaveKey        = WaveKey, 
      @cStorerKey      = StorerKey, 
      @cStatus         = Status, 
      @cToLOC          = ToLOC, 
      @cToID           = ToID, 
      @nQTY            = QTY, 
      @cFinalLOC       = FinalLoc,
      @nTransitCount   = TransitCount, 
      @cPriority       = Priority, 
      @cSourcePriority = SourcePriority, 
      @cSourceType     = 'rdt_1764CreateTask16'
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE ListKey = @cListKey
   ORDER BY 
      TransitCount DESC, -- Get initial task
      CASE WHEN Status = '9' THEN 1 ELSE 2 END -- RefTask that fetch to perform together, still Status=3

   -- Task not completed/SKIP/CANCEL
   IF @cStatus <> '9'
      RETURN
   
   /***********************************************************************************************
                                             Stardard Create Task 
   ***********************************************************************************************/
   DECLARE @tTask TABLE
   (
      TaskDetailKey NVARCHAR(10), 
      StorerKey     NVARCHAR(15),
      SKU           NVARCHAR(20),
      QTY           INT, 
      ToLOC         NVARCHAR(10),
      ToID          NVARCHAR(18),
      FinalLOC      NVARCHAR(10),
      FinalID       NVARCHAR(18),
      TransitLOC    NVARCHAR(10)
   )

   -- Get initial task info
   INSERT INTO @tTask (TaskDetailKey, StorerKey, SKU, QTY, ToLOC, ToID, FinalLOC, FinalID)
   SELECT TaskDetailKey, StorerKey, SKU, QTY, @cToLOC, @cToID, FinalLOC, FinalID --NOTE: ToLOC, ToID are from lastest task
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE ListKey = @cListKey
      AND TransitCount = 0
      AND Status = '9'
      AND (
         (PickMethod = 'PP' AND Qty <> 0 AND ISNULL(ReasonKey,'') = '') --Skip full short PP task
         OR (PickMethod = 'FP')
      )

   IF NOT EXISTS (SELECT 1 FROM @tTask) --1.0.1
      RETURN

   -- Not generate next task if: 
   -- 1) Already reach final location or 
   -- 2) There is no transit task involved or
   -- 3) Reach conveyor location
   IF EXISTS( SELECT 1 FROM @tTask WHERE ToLOC = FinalLOC)
      RETURN
   
   IF EXISTS( SELECT 1 FROM @tTask WHERE FinalLOC = '')
      RETURN
   
   IF EXISTS( SELECT 1 FROM @tTask Task JOIN dbo.LOC WITH (NOLOCK) ON (Task.ToLOC = LOC.LOC) WHERE LOC.LocationCategory = 'INDUCTION')
      RETURN
   
   -- Get TransitLOC for tasks
   DECLARE @curTask CURSOR
   SET @curTask = CURSOR FOR 
      SELECT TaskDetailKey, StorerKey, SKU, QTY, ToLOC, ToID, FinalLOC, FinalID 
      FROM @tTask t
         JOIN dbo.LOC WITH (NOLOCK) ON (t.FinalLOC = LOC.LOC)
      ORDER BY CASE WHEN LOC.LocationCategory = 'INDUCTION' THEN 2 ELSE 1 END -- Induction LOC come last, so @cFinalLOC variable in next task goes to induction LOC 
   OPEN @curTask
   FETCH NEXT FROM @curTask INTO @cTaskDetailKey, @cStorerKey, @cSKU, @nQTY, @cToLOC, @cToID, @cFinalLOC, @cFinalID
   WHILE @@FETCH_STATUS = 0
   BEGIN
      -- Get next transit LOC
      EXECUTE rdt.rdt_GetTransitLOC
         @cUserName, 
         @cStorerKey, 
         @cSKU, 
         @nQTY, 
         @cToLOC,      -- FromLOC
         @cToID,       -- FromID
         @cFinalLOC,   -- ToLOC
         0,            -- Lock PND transit LOC. 1=Yes, 0=No
         @cTransitLOC OUTPUT,
         @nErrNo      OUTPUT,
         @cErrMsg     OUTPUT  -- screen limitation, 20 char max
      IF @nErrNo <> 0 
         GOTO Fail

      UPDATE @tTask SET 
         TransitLOC = @cTransitLOC 
      WHERE TaskDetailKey = @cTaskDetailKey
      
      FETCH NEXT FROM @curTask INTO @cTaskDetailKey, @cStorerKey, @cSKU, @nQTY, @cToLOC, @cToID, @cFinalLOC, @cFinalID
   END
         
   -- Get new TaskDetailKeys
   SET @nSuccess = 1
   EXECUTE dbo.nspg_getkey
      'TASKDETAILKEY'
      , 10
      , @cNewTaskDetailKey OUTPUT
      , @nSuccess          OUTPUT
      , @nErrNo            OUTPUT
      , @cErrMsg           OUTPUT
   IF @nSuccess <> 1
   BEGIN
      SET @nErrNo = 252301
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
      GOTO Fail
   END
   
   -- Get LOC info
   DECLARE @cToLOCPAZone NVARCHAR(10)
   DECLARE @cToLOCAreaKey NVARCHAR(10)
   SET @cToLOCPAZone = ''
   SET @cToLOCAreaKey = ''
   SELECT @cToLOCPAZone = PutawayZone FROM LOC WITH (NOLOCK) WHERE LOC = @cToLOC
   SELECT @cToLOCAreaKey = AreaKey FROM AreaDetail WITH (NOLOCK) WHERE PutawayZone = @cToLOCPAZone 
   
   -- Handling transaction
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_1764CreateTask16 -- For rollback or commit only our own transaction

   SET @nTransitCount = @nTransitCount + 1

   -- Generate task
   IF EXISTS( SELECT 1 FROM @tTask WHERE TransitLOC = FinalLOC)
   BEGIN
      -- Loop original task
      DECLARE @curRPLog CURSOR
      SET @curRPLog = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
         SELECT StorerKey, SKU, LOT, QTY, FinalLOC, FinalID, CaseID, TaskDetailKey, UOM, UOMQty, PickMethod
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE ListKey = @cListKey
            AND TransitCount = 0 -- Original task
      OPEN @curRPLog
      FETCH NEXT FROM @curRPLog INTO @cStorerKey, @cSKU, @cLOT, @nQTY, @cFinalLOC, @cFinalID, @cCaseID, @cOrgTaskKey, @cUOM, @nUOMQty, @cPickMethod
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- Get new TaskDetailKeys
         IF @cNewTaskDetailKey = ''
         BEGIN
            SET @nSuccess = 1
            EXECUTE dbo.nspg_getkey
               'TASKDETAILKEY'
               , 10
               , @cNewTaskDetailKey OUTPUT
               , @nSuccess          OUTPUT
               , @nErrNo            OUTPUT
               , @cErrMsg           OUTPUT
            IF @nSuccess <> 1
            BEGIN
               SET @nErrNo = 252302
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
               GOTO RollBackTran
            END
         END

         IF @cPickMethod = 'PP'
         BEGIN
            -- Insert final task
            BEGIN TRY
               INSERT INTO TaskDetail (
                  TaskDetailKey, TaskType, Status, UserKey, FromLOC, FromID, ToLOC, ToID, QTY, CaseID, AreaKey, UOM, UOMQty, FinalLoc, 
                  PickMethod, StorerKey, SKU, LOT, ListKey, TransitCount, SourceType, SourceKey, WaveKey, Priority, SourcePriority, TrafficCop)
               VALUES (
                  @cNewTaskDetailKey, 'ASTRPT', '0', '', @cToLOC, @cToID, @cFinalLOC, @cFinalID, @nQTY, @cCaseID, @cToLOCAreaKey, @cUOM, @nUOMQty, @cFinalLOC,
                  'PP', @cStorerKey, @cSKU, @cLOT, '', @nTransitCount, @cSourceType, @cOrgTaskKey, @cWaveKey, @cPriority, @cSourcePriority, NULL)
            END TRY
            BEGIN CATCH
               SET @nErrNo = 252303
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InsTaskDetFail
               GOTO RollBackTran
            END CATCH
         END --PP

         IF @cPickMethod = 'FP'
         BEGIN
            -- Insert final task
            BEGIN TRY
               INSERT INTO TaskDetail (
                  TaskDetailKey, TaskType, Status, UserKey, FromLOC, FromID, ToLOC, ToID, QTY, AreaKey, FinalLoc, 
                  PickMethod, StorerKey, SKU, LOT, ListKey, TransitCount, SourceType, SourceKey, WaveKey, Priority, SourcePriority, TrafficCop)
               VALUES (
                  @cNewTaskDetailKey, 'RP1', '0', '', @cToLOC, @cToID, @cFinalLOC, @cToID, 0, @cToLOCAreaKey, @cFinalLOC,
                  'FP', @cStorerKey, '', '', '', @nTransitCount, @cSourceType, @cOrgTaskKey, @cWaveKey, @cPriority, @cSourcePriority, NULL)
            END TRY
            BEGIN CATCH
               SET @nErrNo = 252304
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InsTaskDetFail
               GOTO RollBackTran
            END CATCH
         END --FP
         
         SET @cNewTaskDetailKey = ''
         FETCH NEXT FROM @curRPLog INTO @cStorerKey, @cSKU, @cLOT, @nQTY, @cFinalLOC, @cFinalID, @cCaseID, @cOrgTaskKey, @cUOM, @nUOMQty, @cPickMethod
      END
   END
   ELSE
   BEGIN
      BEGIN TRY 
         -- Insert transit task
         INSERT INTO TaskDetail (
            TaskDetailKey, TaskType, Status, UserKey, FromLOC, FromID, ToLOC, ToID, QTY, AreaKey, FinalLoc, 
            PickMethod, Storerkey, SKU, LOT, ListKey, TransitCount, SourceType, WaveKey, Priority, SourcePriority, TrafficCop)
         VALUES (
            @cNewTaskDetailKey, 'RP1', '0', '', @cToLOC, @cToID, @cTransitLOC, @cToID, 0, @cToLOCAreaKey, @cFinalLOC,
            'FP', @cStorerkey, '', '', @cListKey, @nTransitCount, @cSourceType, @cWaveKey, @cPriority, @cSourcePriority, NULL)
      END TRY
      BEGIN CATCH
         SET @nErrNo = 252305
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InsTaskDetFail
         GOTO RollBackTran
      END CATCH
   END

   COMMIT TRAN rdt_1764CreateTask16 -- Only commit change made here
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1764CreateTask16 -- Only rollback change made here
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

GRANT EXECUTE ON [rdt].[rdt_1764CreateTask16] TO NSQL
GO
