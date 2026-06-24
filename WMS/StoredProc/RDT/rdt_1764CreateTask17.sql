SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************************/
/* Store procedure: rdt_1764CreateTask17                                            */
/* Copyright      : Maersk                                                          */
/*                                                                                  */
/* Purpose: UK Columbia                                                             */
/*                                                                                  */
/* Called from:                                                                     */
/*                                                                                  */
/* Modifications log:                                                               */
/*                                                                                  */
/* Date       Rev    Author     Purposes                                            */
/* 2026-01-15 1.0.0  JCH507     FCR-10031 created on base logic                     */
/* 2026-03-04 1.0.1  JCH507     FCR-10031 V1.4,1.5: Logic to create ASTMV           */
/* 2026-06-24 1.0.2  JCH507     UWP-59810 Only create new tasks if task status = 9  */
/************************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1764CreateTask17] (
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
   DECLARE @cStatus           NVARCHAR( 10)
   DECLARE @cWaveKey          NVARCHAR( 10)
   DECLARE @cTaskWaveKey      NVARCHAR( 10)
   DECLARE @cStorerKey        NVARCHAR( 15)
   DECLARE @cSKU              NVARCHAR( 20)
   DECLARE @cLOT              NVARCHAR( 10)
   DECLARE @nQTY              INT
   DECLARE @cToLOC            NVARCHAR( 10)
   DECLARE @cToID             NVARCHAR( 18)
   DECLARE @cCaseID           NVARCHAR( 20)
   DECLARE @cFinalLOC         NVARCHAR( 10)
   DECLARE @cFinalID          NVARCHAR( 18)
   DECLARE @cTransitLOC       NVARCHAR( 10)
   DECLARE @nTransitCount     INT
   DECLARE @cPriority         NVARCHAR( 10)
   DECLARE @cSourcePriority   NVARCHAR( 10)
   DECLARE @cSourceType       NVARCHAR( 30)
   DECLARE @cOrgTaskKey       NVARCHAR( 30)
          ,@cReplenByRPT      NVARCHAR(1) 
          ,@nUOMQty           INT
          ,@cCreateNextTaskSP NVARCHAR(30)
          ,@cSQL              NVARCHAR(1000)
          ,@cSQLParam         NVARCHAR(1000)
   
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
      @nTransitCount   = TransitCount, 
      @cPriority       = Priority, 
      @cSourcePriority = SourcePriority, 
      @cSourceType     = 'rdt_1764CreateTask17'
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE ListKey = @cListKey
      AND TaskType = 'RPF' -- V1.0.1
   ORDER BY 
      TransitCount DESC, -- Get initial task
      CASE WHEN Status = '9' THEN 1 ELSE 2 END -- RefTask that fetch to perform together, still Status=3

   -- Task not completed/SKIP/CANCEL
   IF @cStatus <> '9'
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'There are tasks status <> 9'
      RETURN
   END
   
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
      AND TaskType = 'RPF' -- V1.0.1
      AND TransitCount = 0
      AND Status = '9' -- V1.0.2
      AND Qty > 0
      AND ReasonKey = '' ----V1.0.0 do not include full short task 

   IF @nDebugFlag = 1
      SELECT * FROM @tTask

   -- Not generate next task if: 
   -- 1) Already reach final location or 
   -- 2) There is no transit task involved or
   -- 3) Reach conveyor location
   -- 4) No task in temp task
   IF EXISTS( SELECT 1 FROM @tTask WHERE ToLOC = FinalLOC)
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'ToLoc = FinalLoc, return'
      RETURN
   END
   
   IF EXISTS( SELECT 1 FROM @tTask WHERE FinalLOC = '')
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'FinalLoc is empty, return'
      RETURN
   END
   
   IF EXISTS( SELECT 1 FROM @tTask Task JOIN dbo.LOC WITH (NOLOCK) ON (Task.ToLOC = LOC.LOC) WHERE LOC.LocationCategory = 'INDUCTION')
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'LocCategory=Induction, return'
      RETURN
   END

   IF NOT EXISTS (SELECT 1 FROM @tTask)
   BEGIN
      IF @nDebugFlag = 1
         SELECT '@tTask is empty'
      
      RETURN
   END
   
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

   IF @nDebugFlag = 1
   BEGIN
      SELECT '@tTask after handling transit loc'
      SELECT * FROM @tTask
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
      SET @nErrNo = 256501
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
      GOTO Fail
   END
   
   -- Get LOC info
   DECLARE @cToLOCPAZone NVARCHAR(10)
   DECLARE @cToLOCAreaKey NVARCHAR(10)
   SET @cToLOCPAZone = ''
   SET @cToLOCAreaKey = ''
   SELECT @cToLOCPAZone = PutawayZone FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cToLOC
   SELECT @cToLOCAreaKey = AreaKey FROM dbo.AreaDetail WITH (NOLOCK) WHERE PutawayZone = @cToLOCPAZone 
   
   -- Handling transaction
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_1764CreateTask17 -- For rollback or commit only our own transaction

   SET @nTransitCount = @nTransitCount + 1

   -- Generate task
   IF EXISTS( SELECT 1 FROM @tTask WHERE TransitLOC = FinalLOC)
   BEGIN
      -- generate replen to task if:
      -- 1) Pallet have multi final LOC and
      -- 2) Pallet not contain INDUCTION TransitLOC
      IF (SELECT COUNT( DISTINCT FinalLOC) FROM dbo.TaskDetail WITH (NOLOCK) WHERE ListKey = @cListKey AND Status = '9' AND TransitCount = 0) > 1 
         AND NOT EXISTS( SELECT 1 
            FROM @tTask Task 
               JOIN dbo.LOC WITH (NOLOCK) ON (Task.TransitLOC = LOC.LOC)
            WHERE LOC.LocationCategory = 'INDUCTION')
      BEGIN
         -- Loop original task
         DECLARE @curRPLog CURSOR
         DECLARE @nPickQty INT
         DECLARE @nOrderCnt INT
         DECLARE @bIsASTMV BIT = 0
         DECLARE @cFinalLOCPAZone NVARCHAR(10) = ''

         SET @curRPLog = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
            SELECT StorerKey, SKU, LOT, QTY, FinalLOC, FinalID, CaseID, TaskDetailKey, UOMQty, Wavekey
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE ListKey = @cListKey
               AND TaskType = 'RPF' -- V1.0.1
               AND Status = '9' --V1.0.2
               AND TransitCount = 0 -- Original task
               AND Qty > 0
               AND ReasonKey = '' -- do not include full short task 
         OPEN @curRPLog
         FETCH NEXT FROM @curRPLog INTO @cStorerKey, @cSKU, @cLOT, @nQTY, @cFinalLOC, @cFinalID, @cCaseID, @cOrgTaskKey, @nUOMQty, @cTaskWaveKey
         WHILE @@FETCH_STATUS = 0
         BEGIN
            -- Check if this UCC should generate ASTMV task
            -- Condition:
            -- 1) PickDetail.DropID = TaskDetail.CaseID
            -- 2) Sum(Pick Qty) = UCC Qty
            -- 3) All PickDetail belong to same order
            -- 4) FinalLOC PutawayZone is CSCPACK or CSCCNVYR

            --V1.0.1 start
            --reset value
            SET @nPickQty = 0
            SET @nOrderCnt = 0
            SET @bIsASTMV = 0
            SET @cFinalLOCPAZone = ''

            SELECT @nPickQty = ISNULL(SUM(Qty), 0), @nOrderCnt = ISNULL(COUNT(DISTINCT OrderKey), 0)
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND DropID = @cCaseID

            SELECT @cFinalLOCPAZone = PutawayZone FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cFinalLOC

            IF @nPickQty = @nQTY AND @nOrderCnt = 1 AND @cFinalLOCPAZone IN ('CSCPACK', 'CSCCNVYR')
               SET @bIsASTMV = 1
            --V1.0.1 end

            IF @nDebugFlag = 1
               SELECT 'Final task, multiple final loc', 'CaseID' = @cCaseID, 'PickQty' = @nPickQty, 'TaskQty' = @nQTY, 
                        'WaveCnt' = @nOrderCnt, 'FinalLOCPAZone' = @cFinalLOCPAZone, 'IsASTMV' = @bIsASTMV

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
                  SET @nErrNo = 256502
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
                  GOTO Fail
               END
            END

            -- Insert final task - ASTMV or ASTTPA based on condition
            INSERT INTO dbo.TaskDetail (
               TaskDetailKey, TaskType, Status, UserKey, FromLOC, FromID, ToLOC, ToID, QTY, CaseID, AreaKey, UOMQty,
               PickMethod, StorerKey, SKU, LOT, ListKey, TransitCount, SourceType, SourceKey, WaveKey, Priority, SourcePriority, TrafficCop)
            VALUES (
               @cNewTaskDetailKey, CASE WHEN @bIsASTMV = 1 THEN 'ASTMV' ELSE 'ASTTPA' END, '0', '', @cToLOC, @cToID, @cFinalLOC, @cFinalID, @nQTY, @cCaseID, @cToLOCAreaKey, @nUOMQty,
               'PP', @cStorerKey, @cSKU, @cLOT, @cListKey, @nTransitCount, @cSourceType, @cOrgTaskKey, @cTaskWaveKey, @cPriority, @cSourcePriority, NULL)
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 256503
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InsTaskDetFail
               GOTO RollBackTran
            END

            IF @bIsASTMV = 1
            BEGIN
               BEGIN TRY
                  UPDATE PickDetail WITH (ROWLOCK)
                  SET
                     Status = '5'
                  WHERE Storerkey = @cStorerkey
				         AND DropID = @cCaseID
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 256508
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKD Fail
                  GOTO RollBackTran
               END CATCH
            END

            SET @cNewTaskDetailKey = ''
            FETCH NEXT FROM @curRPLog INTO @cStorerKey, @cSKU, @cLOT, @nQTY, @cFinalLOC, @cFinalID, @cCaseID, @cOrgTaskKey, @nUOMQty, @cTaskWaveKey
         END
      END
      ELSE
      BEGIN
         --Due to pickdetail check, always create 2step task based on UCC level
         --SET @cReplenByRPT = rdt.RDTGetConfig( @nFunc, 'ReplenByRPT', @cStorerKey)
         
         IF @nDebugFlag = 1
            SELECT 'Finaltask, same finalLoc'

         -- Loop original task
         DECLARE @curRPTLog CURSOR
         DECLARE @nPickQty2 INT
         DECLARE @nOrderCnt2 INT
         DECLARE @bIsASTMV2 BIT = 0
         DECLARE @cFinalLOCPAZone2 NVARCHAR(10) = ''

         SET @curRPTLog = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
            SELECT StorerKey, SKU, LOT, QTY, FinalLOC, FinalID, CaseID, TaskDetailKey, UOMQty, WaveKey
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE ListKey = @cListKey
               AND TaskType = 'RPF' -- V1.0.1
               AND Status = '9' -- V1.0.2
               AND TransitCount = 0 -- Original task
               AND Qty > 0
               AND ReasonKey = '' -- do not include full short task 
         OPEN @curRPTLog
         FETCH NEXT FROM @curRPTLog INTO @cStorerKey, @cSKU, @cLOT, @nQTY, @cFinalLOC, @cFinalID, @cCaseID, @cOrgTaskKey, @nUOMQty, @cTaskWaveKey
         WHILE @@FETCH_STATUS = 0
         BEGIN
            -- Check if this UCC should generate ASTMV task
            -- Condition:
            -- 1) PickDetail.DropID = TaskDetail.CaseID
            -- 2) Sum(Pick Qty) = UCC Qty
            -- 3) All PickDetail belong to same order
            -- 4) FinalLOC PutawayZone is CSCPACK or CSCCNVYR

            --V1.0.1 start
            --reset value
            SET @nPickQty2 = 0
            SET @nOrderCnt2 = 0
            SET @bIsASTMV2 = 0
            SET @cFinalLOCPAZone2 = ''

            SELECT @nPickQty2 = ISNULL(SUM(Qty), 0), @nOrderCnt2 = ISNULL(COUNT(DISTINCT OrderKey), 0)
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND DropID = @cCaseID

            SELECT @cFinalLOCPAZone2 = PutawayZone FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cFinalLOC

            IF @nPickQty2 = @nQTY AND @nOrderCnt2 = 1 AND @cFinalLOCPAZone2 IN ('CSCPACK', 'CSCCNVYR')
               SET @bIsASTMV2 = 1
            --V1.0.1 end

            IF @nDebugFlag = 1
               SELECT 'Finaltask, same final loc', 'CaseID' = @cCaseID, 'PickQty' = @nPickQty2, 'TaskQty' = @nQTY, 
                        'WaveCnt' = @nOrderCnt2, 'FinalLOCPAZone' = @cFinalLOCPAZone2, 'IsASTMV' = @bIsASTMV2

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
                  SET @nErrNo = 256506
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
                  GOTO Fail
               END
            END

            -- Insert final task - ASTMV or ASTTPA based on condition
            INSERT INTO dbo.TaskDetail (
               TaskDetailKey, TaskType, Status, UserKey, FromLOC, FromID, ToLOC, ToID, QTY, CaseID, AreaKey, UOMQty,
               PickMethod, StorerKey, SKU, LOT, ListKey, TransitCount, SourceType, SourceKey, WaveKey, Priority, SourcePriority, TrafficCop)
            VALUES (
               @cNewTaskDetailKey, CASE WHEN @bIsASTMV2 = 1 THEN 'ASTMV' ELSE 'ASTTPA' END, '0', '', @cToLOC, @cToID, @cFinalLOC, @cFinalID, @nQTY, @cCaseID, @cToLOCAreaKey, @nUOMQty,
               'PP', @cStorerKey, @cSKU, @cLOT, @cListKey, @nTransitCount, @cSourceType, @cOrgTaskKey, @cTaskWaveKey, @cPriority, @cSourcePriority, NULL)
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 256507
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InsTaskDetFail
               GOTO RollBackTran
            END

            IF @bIsASTMV2 = 1
            BEGIN
               BEGIN TRY
                  UPDATE PickDetail WITH (ROWLOCK)
                  SET
                     Status = '5'
                  WHERE Storerkey = @cStorerkey
				         AND DropID = @cCaseID
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 256509
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKD Fail
                  GOTO RollBackTran
               END CATCH
            END

            SET @cNewTaskDetailKey = ''
            FETCH NEXT FROM @curRPTLog INTO @cStorerKey, @cSKU, @cLOT, @nQTY, @cFinalLOC, @cFinalID, @cCaseID, @cOrgTaskKey, @nUOMQty, @cTaskWaveKey
         END
      END
   END
   ELSE
   BEGIN 
      IF @nDebugFlag = 1
               SELECT 'Transit task'
      -- Insert transit task
      INSERT INTO dbo.TaskDetail (
         TaskDetailKey, TaskType, Status, UserKey, FromLOC, FromID, ToLOC, ToID, QTY, AreaKey, 
         PickMethod, Storerkey, SKU, LOT, ListKey, TransitCount, SourceType, WaveKey, Priority, SourcePriority, TrafficCop)
      VALUES (
         @cNewTaskDetailKey, 'RP1', '0', '', @cToLOC, @cToID, @cTransitLOC, @cToID, 0, @cToLOCAreaKey, 
         'FP', @cStorerkey, '', '', @cListKey, @nTransitCount, @cSourceType, @cWaveKey, @cPriority, @cSourcePriority, NULL)
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 256505
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InsTaskDetFail
         GOTO RollBackTran
      END
   END

   COMMIT TRAN rdt_1764CreateTask17 -- Only commit change made here
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1764CreateTask17 -- Only rollback change made here
Fail:
Quit:
   IF @nDebugFlag = 1
      SELECT 'Quit', @nErrNo AS ErrNo, @cErrMsg AS cErrMsg

   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

GRANT EXECUTE ON  [RDT].[rdt_1764CreateTask17] TO [NSQL]
GO
