
/************************************************************************/
/* Store procedure: rdt_1812SwapID06                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: SABRF                                                       */
/*                                                                      */
/* Date        Rev     Author      Purposes                             */
/* 2026-03-19  1.0.0   Jackc       FCR-11292 Created                    */
/************************************************************************/
CREATE OR ALTER PROCEDURE [RDT].[rdt_1812SwapID06]
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

   DECLARE @nNewIDQty         INT
   DECLARE @nTaskIDQty        INT
   DECLARE @nTaskQTY          INT

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

   DECLARE @tPD TABLE
   (
      PickdetailKey  NVARCHAR(10) NOT NULL, 
      TaskDetailKey  NVARCHAR(10) NOT NULL, 
      QTY            INT          NOT NULL DEFAULT 0,
      LOT            NVARCHAR(10) NOT NULL,
      ID             NVARCHAR(18) NOT NULL,
      Remark         NVARCHAR(100)  
   )


   IF @nDebugFlag = 1
      SELECT 'Executing rdt_1812SwapID06', @cTaskDetailKey AS OrgTaskKey, @cNewID AS NewID

   SELECT @cStorerKey = StorerKey
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   -- Check blank
   IF ISNULL(@cNewID,'') = ''
   BEGIN
      SET @nErrNo = 261851
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need ID
      GOTO Quit
   END

   IF @nDebugFlag = 1
      SELECT 'Original Task Validation'

   -- Get task info
   SELECT
      @cStorerKey          = TD.StorerKey, 
      @cTaskType           = TD.TaskType, 
      @cTaskSKU            = TD.SKU, 
      @cTaskLOT            = TD.LOT,
      @cTaskLOC            = TD.FromLOC,
      @cTaskID             = TD.FromID,
      @nTaskQTY            = TD.SystemQTY
   FROM dbo.TaskDetail TD WITH (NOLOCK)
   WHERE TD.StorerKey = @cStorerKey
      AND TD.TaskDetailKey = @cTaskDetailKey

   SET @nRowCount = @@ROWCOUNT 

   IF @nRowCount = 0
   BEGIN
      SET @nErrNo = 261852
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --BadTaskDtlKey
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

   -- Get task ID Qty
   SELECT
      @nTaskIDQty = QTY - QTYPicked
   FROM dbo.LOTxLOCxID WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND ID = @cTaskID
      AND QTY - QTYPicked > 0

   --Get ID task list
   INSERT INTO @tIDTaskList (TaskDetailKey, TaskType)
   SELECT TaskDetailKey, TaskType
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND FromID = @cTaskID
      AND FromLoc = @cTaskLOC
      AND ((TaskDetailKey = @cTaskDetailKey) OR (TaskType IN ('FCP', 'FPK') AND Status = '0'))

   IF NOT EXISTS (SELECT 1 FROM @tIDTaskList)
   BEGIN
      SET @nErrNo = 261859
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --BadTaskDtlKey
      GOTO Quit
   END

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Original task info', @cTaskDetailKey AS TaskKey, @cTaskID AS TaskID, @nTaskIDQty AS TaskIDQty
      SELECT 'Task ID tasks list'
      SELECT * FROM @tIDTaskList
   END

   -- Get new ID info
   SELECT
      @cNewSKU = LLI.SKU,
      @nNewIDQTY = LLI.QTY - LLI.QTYPicked,
      @cNewLOT = LLI.LOT,
      @cNewLOC = LLI.LOC
   FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
   WHERE LLI.StorerKey = @cStorerKey
      AND LLI.ID = @cNewID
      AND LLI.QTY - LLI.QTYPicked > 0

   SET @nRowCount = @@ROWCOUNT 

   IF @nDebugFlag = 1
      SELECT 'NewID Validation'

   -- Check ID valid
   IF @nRowCount = 0
   BEGIN
      SET @nErrNo = 261853
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid ID
      GOTO Quit
   END

   -- Check ID multi LOC/LOT/SKU
   IF @nRowCount > 1
   BEGIN
      SET @nErrNo = 261854
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID multi rec
      GOTO Quit
   END

   -- Check if ID is on HOLD
   IF EXISTS (SELECT 1 
               FROM dbo.INVENTORYHOLD WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND ID = @cNewID
                  AND Hold = '1')
   BEGIN
      SET @nErrNo = 261855
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --IDIsOnHold
      GOTO Quit
   END

   -- Check LOC match
   IF @cNewLOC <> @cTaskLOC
   BEGIN
      SET @nErrNo = 261856
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LOC not match
      GOTO Quit
   END

   -- Check SKU match
   IF @cNewSKU <> @cTaskSKU
   BEGIN
      SET @nErrNo = 261857
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU not match
      GOTO Quit
   END

   -- Check QTY match
   IF @nNewIDQTY <> @nTaskIDQTY
   BEGIN
      SET @nErrNo = 261858
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --QTY not match
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
      SET @nErrNo = 261860
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID task taken
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
         SET @nErrNo = 261861
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Swap ID cannot has other open tasks
         GOTO Quit
      END
      ELSE
      BEGIN
         --Get ID task list
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
      SELECT 'new id info', @cNewID AS NewID, @nNewIDQty AS NewIDQty
      SELECT 'New ID tasks list'
      SELECT * FROM @tNewIDTaskList
   END

   -- Get other PickDetail info
   SET @cOtherPickDetailKey = ''

   SELECT @cOtherPickDetailKey = PickDetailKey
   FROM dbo.PickDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND SKU = @cNewSKU
      AND ID = @cNewID
      AND Loc = @cNewLOC
      AND Status = '0'
      AND QTY > 0

   -- Check pallet allocated but not yet release task
   IF @cOtherTaskDetailKey = '' AND ISNULL(@cOtherPickDetailKey, '') <> ''
   BEGIN
      SET @nErrNo = 261862
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID locked
      GOTO Quit
   END

   IF @nDebugFlag = 1
      SELECT 'Get taskID and newID RPF info'

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
   SAVE TRAN rdt_1812SwapID06

   --1. Handle task data
   IF @nDebugFlag = 1
   BEGIN
      SELECT '1. Handle task data'
      SELECT '1.1 Handle TaskID task data', @cTaskDetailKey AS TaskKey, @cTaskID AS TaskID
   END

   -- 1.1 Handle TaskID task data
   -- 1.1.1 Update current ID task
   IF EXISTS (SELECT 1 FROM @tIDTaskList)
   BEGIN
      BEGIN TRY
         UPDATE TD SET
            LOT = CASE WHEN TD.LOT <> '' THEN @cNewLOT ELSE TD.LOT END, 
            FromID = @cNewID, 
            ToID = CASE WHEN TD.ToID <> '' THEN @cNewID ELSE TD.ToID END, 
            FinalID = CASE WHEN TD.FinalID <> '' THEN @cNewID ELSE TD.FinalID END, 
            EditDate = GETDATE(), 
            EditWho = SUSER_SNAME(), 
            TrafficCop = NULL
         FROM dbo.TaskDetail TD WITH (ROWLOCK)
         INNER JOIN @tIDTaskList TL ON TD.TaskDetailKey = TL.TaskDetailKey

         SET @nRowCount = @@ROWCOUNT

         IF @nRowCount = 0
         BEGIN
            SET @nErrNo = 261863
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD Task Fail
            GOTO RollBackTran
         END
      END TRY
      BEGIN CATCH
         SET @nErrNo = 261864
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD Task Fail
         GOTO RollBackTran
      END CATCH
   END

   --1.2 Handle NewID task data if there is a task. NewID might have multiple tasks (FPK or FCPs)
   IF EXISTS (SELECT 1 FROM @tNewIDTaskList)
   BEGIN
      IF @nDebugFlag = 1
      BEGIN
         SELECT '1.2 Handle NewID task data if there is a task', @cOtherTaskDetailKey AS OtherTaskKey, @cNewID AS NewID
         SELECT '1.2.1 Handle NewID FPK or FCP task'
      END
      
      BEGIN TRY
         UPDATE TD SET
            LOT = CASE WHEN LOT <> '' THEN @cTaskLOT ELSE LOT END, 
            FromID = @cTaskID,
            ToID = CASE WHEN ToID <> '' THEN @cTaskID ELSE ToID END,
            FinalID = CASE WHEN FinalID <> '' THEN @cTaskID ELSE FinalID END, 
            EditDate = GETDATE(), 
            EditWho = SUSER_SNAME(), 
            TrafficCop = NULL
         FROM dbo.TaskDetail TD WITH (ROWLOCK)
         INNER JOIN  @tNewIDTaskList TL ON TD.TaskDetailKey = TL.TaskDetailKey

         SET @nRowCount = @@ROWCOUNT

         IF @nRowCount = 0
         BEGIN
            SET @nErrNo = 261865
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD Task Fail
            GOTO RollBackTran
         END
      END TRY
      BEGIN CATCH
         SET @nErrNo = 261866
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD Task Fail
         GOTO RollBackTran
      END CATCH--1.2.1
   END --1.2

   -- 2.1 Unallocate taskID
   IF @nDebugFlag = 1
      SELECT '2 Handle pickdetail data'
      
   IF @cTaskPickDetailKey <> ''
   BEGIN
      IF @nDebugFlag = 1
         SELECT '2.1 Unallocate task ID', @cTaskID AS Task_ID

      --Save the task pickdetail and replace lot and ID with new values
      INSERT INTO @tPD (PickDetailKey, TaskDetailKey, Qty, LOT, ID,Remark)
      SELECT
         PickDetailKey, TaskDetailKey, QTY, @cNewLot, @cNewID, 'TaskPKD'
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND ID = @cTaskID
         AND LOC = @cTaskLoc
         AND Status = '0'
         AND Qty > 0

      BEGIN TRY
         UPDATE dbo.PickDetail WITH (ROWLOCK)
         SET
            QTY = 0, 
            EditDate = GETDATE(), 
            EditWho = 'rdt.' + SUSER_SNAME()
         WHERE StorerKey = @cStorerKey
            AND ID = @cTaskID
            AND LOC = @cTaskLoc
            AND Status = '0'
            AND Qty > 0
      END TRY
      BEGIN CATCH
         SET @nErrNo = 261867
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKD Fail
         GOTO RollBackTran
      END CATCH
   END -- unallocate taskID

   --2.2 Unallocate NewID if it is allocated
   IF @cOtherPickDetailKey <> ''
   BEGIN
      IF @nDebugFlag = 1
         SELECT '2.2 Unallocate NewID'

      --Save the NewID pickdetail and replace lot and ID with task values
      INSERT INTO @tPD (PickDetailKey, TaskDetailKey, Qty, LOT, ID,Remark)
      SELECT
         PickDetailKey, TaskDetailKey, QTY, @cTaskLot, @cTaskID, 'NewIDPKD'
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND ID = @cNewID
         AND Loc = @cNewLOC
         AND Status = '0'
         AND Qty > 0

      BEGIN TRY
         UPDATE dbo.PickDetail WITH (ROWLOCK)
         SET
            QTY = 0, 
            EditDate = GETDATE(), 
            EditWho = 'rdt.' + SUSER_SNAME()
         WHERE StorerKey = @cStorerKey
            AND ID = @cNewID
            AND Loc = @cNewLOC
            AND Status = '0'
            AND Qty > 0
      END TRY
      BEGIN CATCH
         SET @nErrNo = 261868
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKD Fail
         GOTO RollBackTran
      END CATCH
   END -- unallocate NewID

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Unallocation finished. Data in @tPD'
      SELECT * FROM @tPD
   END

   --2.3 Reallocate pickdetail
   IF EXISTS ( SELECT 1 FROM @tPD)
   BEGIN
      IF @nDebugFlag = 1
         SELECT '2.3 Reallocate pickdetail'

      BEGIN TRY
         MERGE INTO dbo.PickDetail AS PKD
         USING @tPD AS PD
            ON PKD.PickDetailKey = PD.PickDetailKey
         WHEN MATCHED THEN
            UPDATE SET
               QTY = PD.QTY, 
               LOT = PD.LOT, 
               ID = PD.ID, 
               EditDate = GETDATE(), 
               EditWho = 'rdt.' + SUSER_SNAME();
      END TRY
      BEGIN CATCH
         SET @nErrNo = 261869
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKD Fail
         GOTO RollBackTran
      END CATCH
   END

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Check PickDetail'
      SELECT * FROM PickDetail WITH (NOLOCK)
      WHERE Storerkey = @cStorerKey
         AND ID IN (@cTaskID, @cNewID)
   END

   CommitTran:
      COMMIT TRAN rdt_1812SwapID06
      GOTO Quit

   RollBackTran:
      IF @nDebugFlag = 1
         SELECT 'RollbackTran', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg

      ROLLBACK TRAN rdt_1812SwapID06

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

GRANT EXECUTE ON rdt.rdt_1812SwapID06 TO NSQL
GO


