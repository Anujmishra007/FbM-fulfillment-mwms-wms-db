
/************************************************************************/
/* Store procedure: rdt_1812SwapID07                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: FCR-14961 - Swap ID for FP picking at Step_FromID (Scr 3)   */
/*                                                                      */
/* Date        Rev     Author      Purposes                             */
/* 2026-07-31  1.0.0   Jackc       FCR-14961 Created. One ID one lot    */
/************************************************************************/
CREATE OR ALTER PROCEDURE [RDT].[rdt_1812SwapID07]
   @nMobile           INT,
   @nFunc             INT,
   @cLangCode         NVARCHAR( 3),
   @cTaskDetailKey    NVARCHAR( 10),
   @cNewID            NVARCHAR( 18),
   @cNewTaskDetailKey NVARCHAR( 10) OUTPUT,
   @nErrNo            INT           OUTPUT,
   @cErrMsg           NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag     INT = 0

   DECLARE @nRowCount      INT

   DECLARE @cTaskPickDetailKey      NVARCHAR(10)
   DECLARE @cOtherPickDetailKey     NVARCHAR(10)
   DECLARE @cOtherTaskDetailKey     NVARCHAR(10)
   DECLARE @cOtherTaskType          NVARCHAR(10)

   DECLARE @cNewSKU           NVARCHAR( 20)
   DECLARE @cNewLOT           NVARCHAR( 10)
   DECLARE @cNewLOC           NVARCHAR( 10)

   DECLARE @cStorerKey        NVARCHAR( 15)
   DECLARE @cTaskType         NVARCHAR( 10)
   DECLARE @cTaskSKU          NVARCHAR( 20)
   DECLARE @cTaskLOT          NVARCHAR( 10)
   DECLARE @cTaskLoc          NVARCHAR( 10)
   DECLARE @cTaskID           NVARCHAR( 18)
   DECLARE @cTaskPickMethod   NVARCHAR( 10)
   DECLARE @cTaskWaveKey      NVARCHAR( 10)
   DECLARE @cUserName         NVARCHAR( 18)

   DECLARE @nNewIDQty         INT  -- kept for execution section
   DECLARE @nTaskIDQty        INT  -- kept for execution section
   DECLARE @nTaskQTY          INT

   DECLARE @cLoopSKU          NVARCHAR(20)
   DECLARE @nLoopQTY          INT
   DECLARE @nLoopIndex        INT
   DECLARE @nNewIDSKUQty      INT

   DECLARE @tTaskIDSKUList TABLE
   (
      RowNum   INT          IDENTITY(1,1),
      SKU      NVARCHAR(20) NOT NULL,
      TotalQty INT          NOT NULL
   )

   DECLARE @tIDTaskList TABLE
   (
      TaskDetailKey  NVARCHAR(10) NOT NULL,
      TaskType       NVARCHAR(10) NOT NULL
   )

   DECLARE @tNewIDTaskList TABLE
   (
      TaskDetailKey  NVARCHAR(10) NOT NULL,
      TaskType       NVARCHAR(10) NOT NULL
   )

   DECLARE @tPKDCandidates TABLE
   (
      PickDetailKey   NVARCHAR(10)  NOT NULL,
      TaskDetailKey   NVARCHAR(10)  NOT NULL,
      OrderKey        NVARCHAR(10)  NOT NULL,
      OrderLineNumber NVARCHAR(5)   NOT NULL,
      SKU             NVARCHAR(20)  NOT NULL,
      QTY             INT           NOT NULL,
      LOT             NVARCHAR(10)  NOT NULL,
      PackKey         NVARCHAR(10)  NOT NULL,
      WaveKey         NVARCHAR(10)  NULL,
      PickSlipNo      NVARCHAR(10)  NULL,
      Loc             NVARCHAR(10)  NOT NULL,
      ID              NVARCHAR(18)  NOT NULL,
      PickMethod      NVARCHAR(1)   NULL,
      UOM             NVARCHAR(10)  NULL,
      UOMQty          INT           NULL
   )

   DECLARE @tOrdToAllocate TABLE
   (
      OrdRowRef       INT           IDENTITY(1,1) NOT NULL,
      TaskDetailKey   NVARCHAR(10)  NOT NULL,
      OrderKey        NVARCHAR(10)  NOT NULL,
      OrderLineNumber NVARCHAR(5)   NOT NULL,
      SKU             NVARCHAR(20)  NOT NULL,
      QtyToAlloc      INT           NOT NULL,
      PackKey         NVARCHAR(10)  NOT NULL,
      WaveKey         NVARCHAR(10)  NULL,
      PickSlipNo      NVARCHAR(10)  NULL,
      PickMethod      NVARCHAR(1)   NULL,
      UOM             NVARCHAR(10)  NULL,
      UOMQty          INT           NULL
   )

   DECLARE @tAvailableLots TABLE
   (
      Lot          NVARCHAR(10) NOT NULL,
      AvailableQty INT          NOT NULL,
      AllocatedQty INT          NOT NULL
   )

   DECLARE @tAllocation TABLE
   (
      PickDetailKey   NVARCHAR(10)  NOT NULL,
      TaskDetailKey   NVARCHAR(10)  NOT NULL,
      OrderKey        NVARCHAR(10)  NOT NULL,
      OrderLineNumber NVARCHAR(5)   NOT NULL,
      SKU             NVARCHAR(20)  NOT NULL,
      QTY             INT           NOT NULL,
      LOT             NVARCHAR(10)  NOT NULL,
      PackKey         NVARCHAR(10)  NOT NULL,
      WaveKey         NVARCHAR(10)  NULL,
      PickSlipNo      NVARCHAR(10)  NULL,
      Loc             NVARCHAR(10)  NOT NULL,
      ID              NVARCHAR(18)  NOT NULL,
      PickMethod      NVARCHAR(1)   NULL,
      UOM             NVARCHAR(10)  NULL,
      UOMQty          INT           NULL,
      PRIMARY KEY CLUSTERED (PickDetailKey)
   )

   DECLARE @nOrdLoopIndex       INT
   DECLARE @cOrdToAlloc         NVARCHAR(10)
   DECLARE @cOrdLineToAlloc     NVARCHAR(5)
   DECLARE @cSKUToAlloc         NVARCHAR(20)
   DECLARE @cPackKeyToAlloc     NVARCHAR(10)
   DECLARE @cWaveKeyToAlloc     NVARCHAR(10)
   DECLARE @cPSNOToAlloc        NVARCHAR(10)
   DECLARE @cAllocTaskDetailKey NVARCHAR(10)
   DECLARE @cAllocPickMethod    NVARCHAR(1)
   DECLARE @cAllocUOM           NVARCHAR(10)
   DECLARE @nAllocUOMQty        INT
   DECLARE @cNewPickDetailKey   NVARCHAR(18)
   DECLARE @cAllocatedLot       NVARCHAR(10)
   DECLARE @cPKDNotes           NVARCHAR(1024)
   DECLARE @nQtyToAlloc         INT
   DECLARE @nBal_Qty            INT
   DECLARE @nRemainingQty       INT
   DECLARE @bSuccess            BIT


   IF @nDebugFlag = 1
      SELECT 'Executing rdt_1812SwapID07', @cTaskDetailKey AS OrgTaskKey, @cNewID AS NewID

   SELECT @cStorerKey = StorerKey
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   -- Check blank
   IF ISNULL(@cNewID,'') = ''
   BEGIN
      SET @nErrNo = 276101
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NewID is empty
      GOTO Quit
   END

   IF @nDebugFlag = 1
      SELECT 'Original Task Validation'

   -- Get task info
   SET @cNewTaskDetailKey = ''

   SELECT
      @cStorerKey          = TD.StorerKey,
      @cTaskType           = TD.TaskType,
      @cTaskSKU            = TD.SKU,
      @cTaskLOT            = TD.LOT,
      @cTaskLOC            = TD.FromLOC,
      @cTaskID             = TD.FromID,
      @nTaskQTY            = TD.SystemQTY,
      @cTaskPickMethod     = TD.PickMethod,
      @cTaskWaveKey        = TD.WaveKey,
      @cUserName           = TD.USERKEY
   FROM dbo.TaskDetail TD WITH (NOLOCK)
   WHERE TD.StorerKey = @cStorerKey
      AND TD.TaskDetailKey = @cTaskDetailKey

   SET @nRowCount = @@ROWCOUNT

   IF @nRowCount = 0
   BEGIN
      SET @nErrNo = 276102
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Task not found
      GOTO Quit
   END

   -- Check PickMethod - only FP is allowed for swap
   IF @cTaskPickMethod <> 'FP'
   BEGIN
      SET @nErrNo = 276103
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PickMethod is not FP
      GOTO Quit
   END

   -- Get Task PickDetail info
   SET @cTaskPickDetailKey = ''

   SELECT @cTaskPickDetailKey = PickDetailKey
   FROM dbo.PickDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND SKU = @cTaskSKU
      AND ID = @cTaskID
      AND Loc = @cTaskLOC
      AND Status = '0'
      AND QTY > 0

   -- Build per-SKU available QTY list for original task ID
   INSERT INTO @tTaskIDSKUList (SKU, TotalQty)
   SELECT SKU, SUM(QTY - QTYPicked)
   FROM dbo.LOTxLOCxID WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND ID = @cTaskID
      AND QTY - QTYPicked > 0
   GROUP BY SKU

   -- Get ID task list
   INSERT INTO @tIDTaskList (TaskDetailKey, TaskType)
   SELECT TaskDetailKey, TaskType
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND FromID = @cTaskID
      AND FromLoc = @cTaskLOC
      AND ((TaskDetailKey = @cTaskDetailKey) OR (TaskType IN ('FCP', 'FPK') AND Status = '0'))

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Original task info', @cTaskDetailKey AS TaskKey, @cTaskID AS TaskID
      SELECT 'Task ID SKU list'
      SELECT * FROM @tTaskIDSKUList
      SELECT 'Task ID tasks list'
      SELECT * FROM @tIDTaskList
   END

   -- Get new ID LOC (any record to verify inventory exists)
   SELECT TOP 1 @cNewLOC = LLI.LOC
   FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
   WHERE LLI.StorerKey = @cStorerKey
      AND LLI.ID = @cNewID
      AND LLI.QTY - LLI.QTYPicked > 0

   IF @nDebugFlag = 1
      SELECT 'NewID Validation'

   -- Check ID valid
   IF @cNewLOC IS NULL
   BEGIN
      SET @nErrNo = 276104
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid New ID
      GOTO Quit
   END

   -- Check if ID is on HOLD
   IF EXISTS (SELECT 1
               FROM dbo.INVENTORYHOLD WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND ID = @cNewID
                  AND Hold = '1')
   BEGIN
      SET @nErrNo = 276106
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --New ID is on hold
      GOTO Quit
   END

   -- Check LOC match: all new ID records must be in task's FromLoc
   IF EXISTS (SELECT 1
              FROM dbo.LOTxLOCxID WITH (NOLOCK)
              WHERE StorerKey = @cStorerKey
                 AND ID = @cNewID
                 AND QTY - QTYPicked > 0
                 AND LOC <> @cTaskLOC)
   BEGIN
      SET @nErrNo = 276107
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Loc Not Match
      GOTO Quit
   END

   -- Check per-SKU QTY match: new ID must have same total QTY for each SKU as original task ID
   SET @nLoopIndex = 0
   WHILE 1 = 1
   BEGIN
      SET @nLoopIndex += 1

      SELECT
         @cLoopSKU = SKU,
         @nLoopQTY = TotalQty
      FROM @tTaskIDSKUList
      WHERE RowNum = @nLoopIndex

      IF @@ROWCOUNT = 0
         BREAK

      SET @nNewIDSKUQty = 0

      SELECT @nNewIDSKUQty = SUM(QTY - QTYPicked)
      FROM dbo.LOTxLOCxID WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND ID = @cNewID
         AND SKU = @cLoopSKU
         AND QTY - QTYPicked > 0

      IF ISNULL(@nNewIDSKUQty, 0) <> @nLoopQTY
      BEGIN
         SET @nErrNo = 276109
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --QTY Not Match
         GOTO Quit
      END
   END

   -- Check new ID has no extra SKUs not present on original task ID
   IF EXISTS (SELECT 1
              FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
              WHERE LLI.StorerKey = @cStorerKey
                 AND LLI.ID = @cNewID
                 AND LLI.QTY - LLI.QTYPicked > 0
                 AND LLI.SKU NOT IN (SELECT SKU FROM @tTaskIDSKUList))
   BEGIN
      SET @nErrNo = 276127
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --QTY Not Match
      GOTO Quit
   END

   IF @nDebugFlag = 1
      SELECT 'NewID Task & Pickdetail Validation'

   -- Check task taken by other
   IF EXISTS( SELECT TOP 1 1
      FROM dbo.TaskDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND FromID = @cNewID
         AND FromLoc = @cNewLOC
         AND TaskDetailKey <> @cTaskDetailKey
         AND Status IN ('3', '5') )
   BEGIN
      SET @nErrNo = 276110
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Executed task exists on new ID
      GOTO Quit
   END

   -- Check new ID whether has tasks
   SET @cOtherTaskDetailKey = ''

   SELECT
      @cOtherTaskDetailKey = TaskDetailKey,
      @cOtherTaskType = TaskType
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerkey
      AND FromLoc = @cNewLOC
      AND FromID = @cNewID
      AND TaskDetailKey <> @cTaskDetailKey
      AND Status = '0'

   IF ISNULL(@cOtherTaskDetailKey, '') <> ''
   BEGIN
      IF EXISTS (SELECT
                     1
                  FROM dbo.TaskDetail WITH (NOLOCK)
                  WHERE StorerKey = @cStorerkey
                     AND FromID = @cNewID
                     AND TaskType NOT IN ('FPK', 'FCP')
                     AND Status = '0')
      BEGIN
         SET @nErrNo = 276111
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NewID has open tasks
         GOTO Quit
      END
      ELSE
      BEGIN
         -- Build @tNewIDTaskList for Step 1.2
         INSERT INTO @tNewIDTaskList (TaskDetailKey, TaskType)
         SELECT TaskDetailKey, TaskType
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND FromID = @cNewID
            AND FromLoc = @cNewLOC
            AND TaskType IN ('FCP', 'FPK')
            AND Status = '0'
      END
   END

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'new id info', @cNewID AS NewID, @cNewLOC AS NewLOC
      SELECT 'New ID tasks list'
      SELECT * FROM @tNewIDTaskList
   END

   -- Get new ID PickDetail info
   SET @cOtherPickDetailKey = ''

   SELECT TOP 1 @cOtherPickDetailKey = PickDetailKey
   FROM dbo.PickDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND ID = @cNewID
      AND Loc = @cNewLOC
      AND Status = '0'
      AND QTY > 0

   -- Check if new ID is allocated to a different wave (replaces SwapID06 261862)
   IF @cOtherPickDetailKey <> ''
   BEGIN
      IF EXISTS (SELECT 1
                 FROM dbo.PickDetail WITH (NOLOCK)
                 WHERE StorerKey = @cStorerKey
                    AND ID = @cNewID
                    AND Loc = @cNewLOC
                    AND Status = '0'
                    AND QTY > 0
                    AND ISNULL(WaveKey, '') <> ISNULL(@cTaskWaveKey, ''))
      BEGIN
         SET @nErrNo = 276112
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --New ID allocated to different wave
         GOTO Quit
      END
   END

   /*--------------------------------------------------------------------------------------------------
                                                Swap ID
   --------------------------------------------------------------------------------------------------*/
   /*
      Scenario:
      1. Handle task data
         1.1 Handle TaskID task data
         1.2 Handle NewID task data if there is a task
      2. Handle Pickdetail data
         2.1 Unallocate taskID
         2.2 Unallocate NewID if it is allocated
         2.3 Reallocate pickdetail but switch ID and Lot
   */

   IF @nDebugFlag = 1
      SELECT 'Start Swap ID logic'

   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT

   BEGIN TRAN
   SAVE TRAN rdt_1812SwapID07

   -- Shortcut: if NewID already has an open FCP/FP task in the same wave,
   -- swap task assignments only (no PickDetail re-allocation needed)
   SELECT TOP 1 @cNewTaskDetailKey = TaskDetailKey
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE StorerKey  = @cStorerKey
      AND FromID    = @cNewID
      AND TaskType  = 'FCP'
      AND PickMethod = 'FP'
      AND ISNULL(WaveKey, '') = ISNULL(@cTaskWaveKey, '')
      AND Status    = '0'

   IF @cNewTaskDetailKey <> ''
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'task swap', @cTaskDetailKey AS CurrentTask, @cNewTaskDetailKey AS NewTask,
                @cTaskID AS OrigID, @cNewID AS NewID

      -- Release current task back to open status
      BEGIN TRY
         UPDATE dbo.TaskDetail WITH (ROWLOCK)
         SET
            Status     = '0',
            USERKEY    = '',
            TrafficCop = NULL,
            EditDate   = GETDATE(),
            EditWho    = SUSER_SNAME()
         WHERE TaskDetailKey = @cTaskDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 276130
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Reset current task fail
         GOTO RollBackTran
      END CATCH

      -- Assign new ID's task to current operator
      BEGIN TRY
         UPDATE dbo.TaskDetail WITH (ROWLOCK)
         SET
            Status     = '3',
            USERKEY    = @cUserName,
            ListKey    = @cNewTaskDetailKey,
            TrafficCop = NULL,
            EditDate   = GETDATE(),
            EditWho    = SUSER_SNAME()
         WHERE TaskDetailKey = @cNewTaskDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 276131
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Take new task fail
         GOTO RollBackTran
      END CATCH

      GOTO CommitTran
   END

   -- 1. Handle task data

   -- 1.1 Update current task ID's tasks to point to new ID
   IF EXISTS (SELECT 1 FROM @tIDTaskList)
   BEGIN
      IF @nDebugFlag = 1
         SELECT '1.1 Update TaskID tasks > new ID', @cTaskID AS FromID, @cNewID AS ToID,
                (SELECT COUNT(1) FROM @tIDTaskList) AS TaskCount

      BEGIN TRY
         UPDATE TD SET
            FromID  = @cNewID,
            ToID    = CASE WHEN TD.ToID    <> '' THEN @cNewID ELSE TD.ToID    END,
            FinalID = CASE WHEN TD.FinalID <> '' THEN @cNewID ELSE TD.FinalID END,
            EditDate = GETDATE(),
            EditWho  = SUSER_SNAME(),
            TrafficCop = NULL
         FROM dbo.TaskDetail TD WITH (ROWLOCK)
         INNER JOIN @tIDTaskList TL ON TD.TaskDetailKey = TL.TaskDetailKey

         SET @nRowCount = @@ROWCOUNT

         IF @nRowCount = 0
         BEGIN
            SET @nErrNo = 276113
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update task fail
            GOTO RollBackTran
         END
      END TRY
      BEGIN CATCH
         SET @nErrNo = 276114
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update task fail
         GOTO RollBackTran
      END CATCH
   END

   -- 1.2 Update new ID's FPK/FCP tasks to point to original ID (bilateral)
   IF EXISTS (SELECT 1 FROM @tNewIDTaskList)
   BEGIN
      IF @nDebugFlag = 1
         SELECT '1.2 Update NewID tasks > original ID', @cNewID AS FromID, @cTaskID AS ToID,
                (SELECT COUNT(1) FROM @tNewIDTaskList) AS TaskCount

      BEGIN TRY
         UPDATE TD SET
            FromID  = @cTaskID,
            ToID    = CASE WHEN ToID    <> '' THEN @cTaskID ELSE ToID    END,
            FinalID = CASE WHEN FinalID <> '' THEN @cTaskID ELSE FinalID END,
            EditDate = GETDATE(),
            EditWho  = SUSER_SNAME(),
            TrafficCop = NULL
         FROM dbo.TaskDetail TD WITH (ROWLOCK)
         INNER JOIN @tNewIDTaskList TL ON TD.TaskDetailKey = TL.TaskDetailKey

         SET @nRowCount = @@ROWCOUNT

         IF @nRowCount = 0
         BEGIN
            SET @nErrNo = 276115
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update NewID task fail
            GOTO RollBackTran
         END
      END TRY
      BEGIN CATCH
         SET @nErrNo = 276116
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update NewID task fail
         GOTO RollBackTran
      END CATCH
   END

   /*
      Phase A: Collect ALL PKD candidates and build ALL allocation plans — no PickDetail DML yet.
      Phase B: Zero ALL > Delete ALL > Insert ALL (atomically, no double-allocation window).

      LOT availability compensates for "will-be-freed" allocations in @tPKDCandidates so that
      planning on already-allocated LOTs succeeds before the originals are removed.
   */

   -- Phase A.1 — Collect ALL PKD candidates: current task (original ID) + new ID's tasks (bilateral)

   INSERT INTO @tPKDCandidates (PickDetailKey, TaskDetailKey, OrderKey, OrderLineNumber, SKU, QTY, LOT,
                                  PackKey, WaveKey, PickSlipNo, Loc, ID, PickMethod, UOM, UOMQty)
   SELECT PickDetailKey, TaskDetailKey, OrderKey, OrderLineNumber, SKU, QTY, LOT,
          PackKey, WaveKey, PickSlipNo, Loc, ID, PickMethod, UOM, UOMQty
   FROM dbo.PickDetail WITH (NOLOCK)
   WHERE StorerKey      = @cStorerKey
      AND TaskDetailKey = @cTaskDetailKey
      AND ID            = @cTaskID
      AND Status        = '0'
      AND QTY           > 0

   IF EXISTS (SELECT 1 FROM @tNewIDTaskList)
   BEGIN
      INSERT INTO @tPKDCandidates (PickDetailKey, TaskDetailKey, OrderKey, OrderLineNumber, SKU, QTY, LOT,
                                    PackKey, WaveKey, PickSlipNo, Loc, ID, PickMethod, UOM, UOMQty)
      SELECT PD.PickDetailKey, PD.TaskDetailKey, PD.OrderKey, PD.OrderLineNumber, PD.SKU, PD.QTY, PD.LOT,
             PD.PackKey, PD.WaveKey, PD.PickSlipNo, PD.Loc, PD.ID, PD.PickMethod, PD.UOM, PD.UOMQty
      FROM dbo.PickDetail PD WITH (NOLOCK)
      INNER JOIN @tNewIDTaskList TL ON PD.TaskDetailKey = TL.TaskDetailKey
      WHERE PD.StorerKey = @cStorerKey
         AND PD.ID       = @cNewID
         AND PD.Status   = '0'
         AND PD.QTY      > 0
   END

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Phase A.1 All PKD candidates collected',
             (SELECT COUNT(1) FROM @tPKDCandidates WHERE ID = @cTaskID) AS TaskIDPKDs,
             (SELECT COUNT(1) FROM @tPKDCandidates WHERE ID = @cNewID)  AS NewIDPKDs
      SELECT * FROM @tPKDCandidates
   END

   -- Phase A.2 — Plan: current task > new ID's LOTs
   IF EXISTS (SELECT 1 FROM @tPKDCandidates WHERE ID = @cTaskID)
   BEGIN
      INSERT INTO @tOrdToAllocate (TaskDetailKey, OrderKey, OrderLineNumber, SKU, QtyToAlloc,
                                    PackKey, WaveKey, PickSlipNo, PickMethod, UOM, UOMQty)
      SELECT
         MIN(TaskDetailKey), OrderKey, OrderLineNumber, SKU, SUM(QTY) AS QtyToAlloc,
         MIN(PackKey), MIN(WaveKey), MIN(PickSlipNo), MIN(PickMethod), MIN(UOM), MIN(UOMQty)
      FROM @tPKDCandidates
      WHERE ID = @cTaskID
      GROUP BY OrderKey, OrderLineNumber, SKU

      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Phase A.2 Order lines: task > new ID', @cTaskID AS SourceID, @cNewID AS TargetID
         SELECT * FROM @tOrdToAllocate
      END

      IF NOT EXISTS (SELECT 1 FROM @tOrdToAllocate)
      BEGIN
         SET @nErrNo = 276128
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Order list empty for task ID re-alloc
         GOTO RollBackTran
      END

      SET @nOrdLoopIndex = 0  -- cursor-style: tracks last-processed OrdRowRef

      WHILE 1 = 1
      BEGIN
         SELECT TOP 1
            @nOrdLoopIndex       = OrdRowRef,
            @cAllocTaskDetailKey = TaskDetailKey,
            @cOrdToAlloc         = OrderKey,
            @cOrdLineToAlloc     = OrderLineNumber,
            @cSKUToAlloc         = SKU,
            @nQtyToAlloc         = QtyToAlloc,
            @cPackKeyToAlloc     = PackKey,
            @cWaveKeyToAlloc     = WaveKey,
            @cPSNOToAlloc        = PickSlipNo,
            @cAllocPickMethod    = PickMethod,
            @cAllocUOM           = UOM,
            @nAllocUOMQty        = UOMQty
         FROM @tOrdToAllocate
         WHERE OrdRowRef > @nOrdLoopIndex
         ORDER BY OrdRowRef ASC

         IF @@ROWCOUNT = 0
            BREAK

         IF @nDebugFlag = 1
            SELECT 'Phase A.2 Order line', @nOrdLoopIndex AS OrdRowRef,
                   @cOrdToAlloc AS OrderKey, @cOrdLineToAlloc AS Line, @cSKUToAlloc AS SKU, @nQtyToAlloc AS QtyToAlloc

         -- Available on new ID: add back new ID's will-be-freed PKD QTY (in @tPKDCandidates)
         INSERT INTO @tAvailableLots (Lot, AvailableQty, AllocatedQty)
         SELECT
            LLI.Lot,
            SUM(LLI.Qty - LLI.QtyAllocated + ISNULL(freed.FreedQty, 0) - LLI.QtyPicked - LLI.QtyReplen) AS AvailableQty,
            SUM(ISNULL(pre.QTY, 0)) AS AllocatedQty
         FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
         LEFT JOIN (
            SELECT Lot, SUM(QTY) AS QTY FROM @tAllocation
            WHERE ID = @cNewID AND SKU = @cSKUToAlloc GROUP BY Lot
         ) pre ON LLI.Lot = pre.Lot
         LEFT JOIN (
            SELECT LOT, SUM(QTY) AS FreedQty FROM @tPKDCandidates
            WHERE ID = @cNewID AND SKU = @cSKUToAlloc GROUP BY LOT
         ) freed ON LLI.Lot = freed.LOT
         WHERE LLI.StorerKey = @cStorerKey AND LLI.ID = @cNewID
            AND LLI.SKU = @cSKUToAlloc AND LLI.Loc = @cNewLOC
         GROUP BY LLI.Lot
         HAVING SUM(LLI.Qty - LLI.QtyAllocated + ISNULL(freed.FreedQty, 0) - LLI.QtyPicked - LLI.QtyReplen) - SUM(ISNULL(pre.QTY, 0)) > 0
         ORDER BY LLI.Lot DESC

         IF @nDebugFlag = 1
         BEGIN
            SELECT 'Phase A.2 Available lots on new ID', @cSKUToAlloc AS SKU, @cNewID AS ID
            SELECT * FROM @tAvailableLots
         END

         SET @nRemainingQty = @nQtyToAlloc

         WHILE @nRemainingQty > 0
         BEGIN
            SELECT TOP 1 @cAllocatedLot = Lot, @nBal_Qty = AvailableQty - AllocatedQty
            FROM @tAvailableLots WHERE AvailableQty > AllocatedQty ORDER BY AvailableQty DESC

            IF @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 276119
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No lot available on new ID
               GOTO RollBackTran
            END

            EXECUTE dbo.nspg_GetKey 'PICKDETAILKEY', 10,
               @cNewPickDetailKey OUTPUT, @bSuccess OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT
            IF @bSuccess <> 1
            BEGIN
               SET @nErrNo = 276117
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GetKey fail
               GOTO RollBackTran
            END

            IF @nBal_Qty >= @nRemainingQty
            BEGIN
               INSERT INTO @tAllocation (PickDetailKey, TaskDetailKey, OrderKey, OrderLineNumber, SKU, QTY, LOT, PackKey, WaveKey, PickSlipNo, Loc, ID, PickMethod, UOM, UOMQty)
               VALUES (@cNewPickDetailKey, @cAllocTaskDetailKey, @cOrdToAlloc, @cOrdLineToAlloc, @cSKUToAlloc, @nRemainingQty, @cAllocatedLot, @cPackKeyToAlloc, @cWaveKeyToAlloc, @cPSNOToAlloc, @cNewLOC, @cNewID, @cAllocPickMethod, @cAllocUOM, @nAllocUOMQty)
               SET @nRemainingQty = 0
            END
            ELSE
            BEGIN
               INSERT INTO @tAllocation (PickDetailKey, TaskDetailKey, OrderKey, OrderLineNumber, SKU, QTY, LOT, PackKey, WaveKey, PickSlipNo, Loc, ID, PickMethod, UOM, UOMQty)
               VALUES (@cNewPickDetailKey, @cAllocTaskDetailKey, @cOrdToAlloc, @cOrdLineToAlloc, @cSKUToAlloc, @nBal_Qty, @cAllocatedLot, @cPackKeyToAlloc, @cWaveKeyToAlloc, @cPSNOToAlloc, @cNewLOC, @cNewID, @cAllocPickMethod, @cAllocUOM, @nAllocUOMQty)
               SET @nRemainingQty -= @nBal_Qty
               DELETE FROM @tAvailableLots WHERE Lot = @cAllocatedLot
            END
         END -- lot loop

         DELETE FROM @tAvailableLots
      END -- order loop

      DELETE FROM @tOrdToAllocate

      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Phase A.2 Plan complete: task > new ID', (SELECT COUNT(1) FROM @tAllocation WHERE ID = @cNewID) AS AllocRows
         SELECT * FROM @tAllocation WHERE ID = @cNewID
      END
   END -- Phase A.2

   -- Phase A.3 — Plan: new ID's tasks > original ID's LOTs (bilateral)
   IF EXISTS (SELECT 1 FROM @tPKDCandidates WHERE ID = @cNewID)
   BEGIN
      INSERT INTO @tOrdToAllocate (TaskDetailKey, OrderKey, OrderLineNumber, SKU, QtyToAlloc,
                                    PackKey, WaveKey, PickSlipNo, PickMethod, UOM, UOMQty)
      SELECT
         TaskDetailKey, OrderKey, OrderLineNumber, SKU, SUM(QTY) AS QtyToAlloc,
         MIN(PackKey), MIN(WaveKey), MIN(PickSlipNo), MIN(PickMethod), MIN(UOM), MIN(UOMQty)
      FROM @tPKDCandidates
      WHERE ID = @cNewID
      GROUP BY TaskDetailKey, OrderKey, OrderLineNumber, SKU

      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Phase A.3 Order lines: new ID tasks > original ID', @cNewID AS SourceID, @cTaskID AS TargetID
         SELECT * FROM @tOrdToAllocate
      END

      IF NOT EXISTS (SELECT 1 FROM @tOrdToAllocate)
      BEGIN
         SET @nErrNo = 276129
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Order list empty for new ID re-alloc
         GOTO RollBackTran
      END

      SET @nOrdLoopIndex = 0  -- reset for Phase A.3; cursor-style works regardless of IDENTITY gap

      WHILE 1 = 1
      BEGIN
         SELECT TOP 1
            @nOrdLoopIndex       = OrdRowRef,
            @cAllocTaskDetailKey = TaskDetailKey,
            @cOrdToAlloc         = OrderKey,
            @cOrdLineToAlloc     = OrderLineNumber,
            @cSKUToAlloc         = SKU,
            @nQtyToAlloc         = QtyToAlloc,
            @cPackKeyToAlloc     = PackKey,
            @cWaveKeyToAlloc     = WaveKey,
            @cPSNOToAlloc        = PickSlipNo,
            @cAllocPickMethod    = PickMethod,
            @cAllocUOM           = UOM,
            @nAllocUOMQty        = UOMQty
         FROM @tOrdToAllocate
         WHERE OrdRowRef > @nOrdLoopIndex
         ORDER BY OrdRowRef ASC

         IF @@ROWCOUNT = 0
            BREAK

         IF @nDebugFlag = 1
            SELECT 'Phase A.3 Order line', @nOrdLoopIndex AS OrdRowRef,
                   @cOrdToAlloc AS OrderKey, @cOrdLineToAlloc AS Line, @cSKUToAlloc AS SKU, @nQtyToAlloc AS QtyToAlloc

         -- Available on original ID: add back task's will-be-freed PKD QTY (in @tPKDCandidates)
         INSERT INTO @tAvailableLots (Lot, AvailableQty, AllocatedQty)
         SELECT
            LLI.Lot,
            SUM(LLI.Qty - LLI.QtyAllocated + ISNULL(freed.FreedQty, 0) - LLI.QtyPicked - LLI.QtyReplen) AS AvailableQty,
            SUM(ISNULL(pre.QTY, 0)) AS AllocatedQty
         FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
         LEFT JOIN (
            SELECT Lot, SUM(QTY) AS QTY FROM @tAllocation
            WHERE ID = @cTaskID AND SKU = @cSKUToAlloc GROUP BY Lot
         ) pre ON LLI.Lot = pre.Lot
         LEFT JOIN (
            SELECT LOT, SUM(QTY) AS FreedQty FROM @tPKDCandidates
            WHERE ID = @cTaskID AND SKU = @cSKUToAlloc GROUP BY LOT
         ) freed ON LLI.Lot = freed.LOT
         WHERE LLI.StorerKey = @cStorerKey AND LLI.ID = @cTaskID
            AND LLI.SKU = @cSKUToAlloc AND LLI.Loc = @cTaskLOC
         GROUP BY LLI.Lot
         HAVING SUM(LLI.Qty - LLI.QtyAllocated + ISNULL(freed.FreedQty, 0) - LLI.QtyPicked - LLI.QtyReplen) - SUM(ISNULL(pre.QTY, 0)) > 0
         ORDER BY LLI.Lot DESC

         IF @nDebugFlag = 1
         BEGIN
            SELECT 'Phase A.3 Available lots on original ID', @cSKUToAlloc AS SKU, @cTaskID AS ID
            SELECT * FROM @tAvailableLots
         END

         SET @nRemainingQty = @nQtyToAlloc

         WHILE @nRemainingQty > 0
         BEGIN
            SELECT TOP 1 @cAllocatedLot = Lot, @nBal_Qty = AvailableQty - AllocatedQty
            FROM @tAvailableLots WHERE AvailableQty > AllocatedQty ORDER BY AvailableQty DESC

            IF @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 276123
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No lot available on orig ID
               GOTO RollBackTran
            END

            EXECUTE dbo.nspg_GetKey 'PICKDETAILKEY', 10,
               @cNewPickDetailKey OUTPUT, @bSuccess OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT
            IF @bSuccess <> 1
            BEGIN
               SET @nErrNo = 276118
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GetKey fail (bilateral)
               GOTO RollBackTran
            END

            IF @nBal_Qty >= @nRemainingQty
            BEGIN
               INSERT INTO @tAllocation (PickDetailKey, TaskDetailKey, OrderKey, OrderLineNumber, SKU, QTY, LOT, PackKey, WaveKey, PickSlipNo, Loc, ID, PickMethod, UOM, UOMQty)
               VALUES (@cNewPickDetailKey, @cAllocTaskDetailKey, @cOrdToAlloc, @cOrdLineToAlloc, @cSKUToAlloc, @nRemainingQty, @cAllocatedLot, @cPackKeyToAlloc, @cWaveKeyToAlloc, @cPSNOToAlloc, @cTaskLOC, @cTaskID, @cAllocPickMethod, @cAllocUOM, @nAllocUOMQty)
               SET @nRemainingQty = 0
            END
            ELSE
            BEGIN
               INSERT INTO @tAllocation (PickDetailKey, TaskDetailKey, OrderKey, OrderLineNumber, SKU, QTY, LOT, PackKey, WaveKey, PickSlipNo, Loc, ID, PickMethod, UOM, UOMQty)
               VALUES (@cNewPickDetailKey, @cAllocTaskDetailKey, @cOrdToAlloc, @cOrdLineToAlloc, @cSKUToAlloc, @nBal_Qty, @cAllocatedLot, @cPackKeyToAlloc, @cWaveKeyToAlloc, @cPSNOToAlloc, @cTaskLOC, @cTaskID, @cAllocPickMethod, @cAllocUOM, @nAllocUOMQty)
               SET @nRemainingQty -= @nBal_Qty
               DELETE FROM @tAvailableLots WHERE Lot = @cAllocatedLot
            END
         END -- lot loop

         DELETE FROM @tAvailableLots
      END -- order loop

      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Phase A.3 Plan complete: new ID tasks > original ID', (SELECT COUNT(1) FROM @tAllocation WHERE ID = @cTaskID) AS AllocRows
         SELECT * FROM @tAllocation WHERE ID = @cTaskID
      END
   END -- Phase A.3

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Phase A complete. All allocation plans ready.',
             (SELECT COUNT(1) FROM @tPKDCandidates) AS TotalPKDsToDelete,
             (SELECT COUNT(1) FROM @tAllocation)    AS TotalPKDsToInsert
      SELECT 'Full @tAllocation'
      SELECT * FROM @tAllocation
   END

   -- Phase B — Apply all changes atomically: Zero ALL > Delete ALL > Insert ALL
   --           All original PickDetail deleted before any new ones are inserted,
   --           preventing double-allocation on new ID.

   -- Phase B.1: Zero ALL original PickDetail
   IF EXISTS (SELECT 1 FROM @tPKDCandidates)
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Phase B.1 Zero ALL original PickDetail', (SELECT COUNT(1) FROM @tPKDCandidates) AS PKDCount

      BEGIN TRY
         UPDATE dbo.PickDetail WITH (ROWLOCK)
         SET
            QTY           = 0,
            TaskDetailKey = '', --Sever link before DELETE so trigger does not clear TaskDetail
            EditDate      = GETDATE(),
            EditWho       = 'rdt.' + SUSER_SNAME()
         WHERE PickDetailKey IN (SELECT PickDetailKey FROM @tPKDCandidates)
      END TRY
      BEGIN CATCH
         SET @nErrNo = 276120
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Unallocate task PKD fail
         GOTO RollBackTran
      END CATCH

      -- Phase B.2: Delete ALL original PickDetail
      IF @nDebugFlag = 1
         SELECT 'Phase B.2 Delete ALL original PickDetail'

      BEGIN TRY
         DELETE FROM dbo.PickDetail
         WHERE PickDetailKey IN (SELECT PickDetailKey FROM @tPKDCandidates)
      END TRY
      BEGIN CATCH
         SET @nErrNo = 276121
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Delete task PKD fail
         GOTO RollBackTran
      END CATCH
   END

   -- Phase B.3: Insert ALL new PickDetail (after ALL originals deleted — no double-allocation)
   IF EXISTS (SELECT 1 FROM @tAllocation)
   BEGIN
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Phase B.3 Insert ALL new PickDetail', (SELECT COUNT(1) FROM @tAllocation) AS PKDCount
         SELECT * FROM @tAllocation
      END

      BEGIN TRY
         INSERT INTO dbo.PickDetail
            (PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, Qty,
             Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup,
             PickMethod, WaveKey, PickSlipNo, Status, EditDate, EditWho, Notes, TaskDetailKey)
         SELECT
            PickDetailKey, '', '', OrderKey, OrderLineNumber, SKU, QTY,
            LOT, @cStorerKey, UOM, UOMQty, '', Loc, ID, PackKey, '',
            PickMethod, WaveKey, PickSlipNo, '0', GETDATE(), 'rdt.' + SUSER_SNAME(),
            CASE ID WHEN @cNewID THEN 'Swap from ID: ' + @cTaskID ELSE 'Swap from ID: ' + @cNewID END,
            TaskDetailKey
         FROM @tAllocation
      END TRY
      BEGIN CATCH
         SET @nErrNo = 276122
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Create task PKD fail
         GOTO RollBackTran
      END CATCH
   END

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Swap complete. Final PickDetail state'
      SELECT * FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND ID IN (@cTaskID, @cNewID)
   END

   CommitTran:
      COMMIT TRAN rdt_1812SwapID07
      GOTO Quit

   RollBackTran:
      IF @nDebugFlag = 1
         SELECT 'RollbackTran', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
      
      IF XACT_STATE() <> -1
         ROLLBACK TRAN rdt_1812SwapID07
      ELSE
         ROLLBACK TRAN

   Quit:
      IF @nDebugFlag = 1
         SELECT 'Quit', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg

      WHILE @@TRANCOUNT > @nTranCount
         COMMIT TRAN
END--sp
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1812SwapID07 TO NSQL
GO


