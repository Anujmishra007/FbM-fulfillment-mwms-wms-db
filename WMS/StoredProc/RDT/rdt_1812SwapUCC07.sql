SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_1812SwapUCC07                                         */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: Swap ucc for JCB US                                               */
/*                                                                            */
/* Date        Rev    Author      Purposes                                    */
/* 2026-08-06  1.0    Jackc       FCR-14961 CaseID is lottable11              */
/*                                                                            */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1812SwapUCC07]
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cTaskdetailKey   NVARCHAR( 10),
   @cBarcode         NVARCHAR( 60), -- scanned value
   @cSKU             NVARCHAR( 20)  OUTPUT,
   @cUCC             NVARCHAR( 20)  OUTPUT, --decoded UCC
   @nUCCQTY          INT            OUTPUT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag     INT = 0

   DECLARE @nRowCount      INT
   DECLARE @nTranCount     INT

   DECLARE @cActCaseID     NVARCHAR( 20)
   DECLARE @cActCaseSKU    NVARCHAR( 20)
   DECLARE @cActCaseLOT    NVARCHAR( 10)
   DECLARE @cActCaseLOC    NVARCHAR( 10)
   DECLARE @cActCaseFromID NVARCHAR( 18)
   DECLARE @cActCaseStatus NVARCHAR( 1)

   DECLARE @cStorerKey     NVARCHAR( 20)
   DECLARE @cTaskType      NVARCHAR( 10)
   DECLARE @cTaskCaseID    NVARCHAR( 20)
   DECLARE @cTaskUOM       NVARCHAR( 5)
   DECLARE @cTaskLOT       NVARCHAR( 10)
   DECLARE @cTaskLOC       NVARCHAR( 10)
   DECLARE @cTaskID        NVARCHAR( 18)
   DECLARE @cTaskSKU       NVARCHAR( 20)
   DECLARE @nTaskQTY       INT
   DECLARE @nTaskUOMQTY    INT

   DECLARE @cActTaskDetailKey NVARCHAR( 10)
   DECLARE @cActSourceKey     NVARCHAR( 10)
   DECLARE @cActTaskType      NVARCHAR( 10)
   DECLARE @cActTaskUOM       NVARCHAR( 5)
   DECLARE @cActTaskStatus    NVARCHAR( 1)
   DECLARE @nActSystemQTY     INT
   DECLARE @nActTaskQty       INT
   DECLARE @nActCaseQty       INT
   DECLARE @nActPendingMoveIn INT

   DECLARE @nSKUCountTaskCaseID  INT = 0
   DECLARE @nSKUCountActCaseID   INT = 0
   DECLARE @nActCaseAllocQty     INT = 0
   DECLARE @nActCasePickQty      INT = 0
   DECLARE @nActCaseAvailableQty INT = 0

   DECLARE @cMsg1             NVARCHAR(60)
   DECLARE @cMsg2             NVARCHAR(60)
   DECLARE @cMsg3             NVARCHAR(60)

   DECLARE @tTaskPD TABLE
   (
      PickDetailKey  NVARCHAR( 10) NOT NULL,
      Qty            INT NOT NULL,
      PRIMARY KEY CLUSTERED (PickDetailKey)
   )

   DECLARE @tActPD TABLE
   (
      PickDetailKey NVARCHAR( 10) NOT NULL,
      Qty           INT NOT NULL,
      PRIMARY KEY CLUSTERED (PickDetailKey)
   )

   IF @nDebugFlag = 1
      SELECT 'Executing 1812SwapUCC07', @cTaskDetailKey AS Task, @cBarcode AS ScannedCase

   SET @nTranCount = @@TRANCOUNT
   SET @cActCaseID = @cBarcode

   SELECT
      @cStorerKey = StorerKey,
      @cTaskType = TaskType,
      @cTaskCaseID = CaseID,
      @cTaskUOM = UOM,
      @nTaskUOMQTY = UOMQTY,
      @cTaskLOT = ISNULL(LOT, ''),
      @cTaskLOC = FromLOC,
      @cTaskID  = ISNULL(FromID, ''),
      @cTaskSKU = ISNULL(SKU, ''),
      @nTaskQTY = QTY
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE TaskDetailKey = @cTaskDetailKey

   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo = 276901
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --BadTaskDtlKey
      GOTO Fail
   END

   IF @cTaskUOM <> '2'
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Not UCC picking, return'
         
      SET @nUCCQTY = 0
      SET @cUCC = ''

      GOTO Quit
   END

   IF @cTaskCaseID = @cActCaseID
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Same as task UCC, No swapping'

      SET @cSKU = @cTaskSKU
      SET @nUCCQty = @nTaskQTY
      SET @cUCC = @cTaskCaseID
      GOTO Quit
   END

   IF @nDebugFlag = 1
      SELECT 'Validating Task CaseID', @cTaskCaseID

   SELECT @nSKUCountTaskCaseID =  COUNT(1) 
   FROM dbo.LotxLocxID LLI WITH (NOLOCK)
   JOIN dbo.LotAttribute LA WITH (NOLOCK)
      ON LLI.StorerKey = LA.StorerKey AND LLI.Lot = LA.Lot      
   WHERE LLI.StorerKey = @cStorerKey 
      AND LLI.Loc = @cTaskLOC
      AND LLI.ID = @cTaskID
      AND LA.Lottable11 = @cTaskCaseID
      AND LLI.Qty > 0
   
   IF @nSKUCountTaskCaseID = 0
   BEGIN
      SET @nErrNo = 276902
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Inventory not found for task case
      GOTO Fail
   END

   IF @nSKUCountTaskCaseID > 1
   BEGIN
      SET @nErrNo = 276903
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Cannot swap case with mix SKU/Lot
      GOTO Fail
   END

   IF @cTaskLOT = '' OR @cTaskSKU = ''
   BEGIN
      SET @nErrNo = 276904
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Task Lot or SKU is empty
      GOTO Fail
   END

   IF @nDebugFlag = 1
      SELECT 'Validating scanned case', @cActCaseID

   SELECT @nSKUCountActCaseID =  COUNT(1) 
   FROM dbo.LotxLocxID LLI WITH (NOLOCK)
   JOIN dbo.LotAttribute LA WITH (NOLOCK)
      ON LLI.StorerKey = LA.StorerKey AND LLI.Lot = LA.Lot      
   WHERE LLI.StorerKey = @cStorerKey 
      AND LLI.Loc = @cTaskLOC
      AND LLI.ID = @cTaskID
      AND LA.Lottable11 = @cActCaseID
      AND LLI.Qty > 0

   IF @nSKUCountActCaseID = 0
   BEGIN
      SET @nErrNo = 276905
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid CaseID
      GOTO Fail
   END

   IF @nSKUCountActCaseID > 1
   BEGIN
      SET @nErrNo = 276906
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Cannot swap case with mix SKU/Lot
      GOTO Fail
   END

   SELECT
      @cActCaseSKU      = LLI.SKU,
      @nActCaseQTY      = LLI.QTY,
      @nActCaseAllocQty = LLI.QtyAllocated,
      @nActCasePickQty  = LLI.QtyPicked,
      @cActCaseLOT      = LLI.LOT,
      @cActCaseLOC      = LLI.LOC,
      @cActCaseFromID   = LLI.ID
   FROM dbo.LotxLocxID LLI WITH (NOLOCK)
   JOIN dbo.LotAttribute LA WITH (NOLOCK)
      ON LLI.StorerKey = LA.StorerKey AND LLI.Lot = LA.Lot      
   WHERE LLI.StorerKey = @cStorerKey 
      AND LLI.Loc = @cTaskLOC
      AND LLI.ID = @cTaskID
      AND LA.Lottable11 = @cActCaseID
      AND LLI.Qty > 0

   IF @nActCasePickQty > 0
   BEGIN
      SET @nErrNo = 276907
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Case is picked
      GOTO Fail
   END

   IF @cTaskSKU <> @cActCaseSKU
   BEGIN
      SET @nErrNo = 276908
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU mismatch
      GOTO Fail
   END

   IF @nActCaseQTY <> @nActCaseAllocQty AND @nActCaseAllocQty > 0
   BEGIN
      SET @nErrNo = 276909
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Case is partially allocated
      GOTO Fail
   END

   IF @nTaskQTY <> @nActCaseQTY
   BEGIN
      SET @nErrNo = 276910
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --QTY mismatch
      GOTO Fail
   END

   IF @cTaskID <> @cActCaseFromID
   BEGIN
      SET @nErrNo = 276924
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --FromID mismatch
      GOTO Fail
   END

   --get act case task
   IF @nActCaseAllocQty > 0
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'ActCase is allocated, get task detail for act case'

      SET @nRowCount = 0

      SELECT
         @cActTaskDetailKey = TaskDetailKey,
         @cActTaskType = TaskType,
         @cActTaskUOM = UOM,
         @nActTaskQty = QTY,
         @cActTaskStatus = Status,
         @cActSourceKey = SourceKey,
         @nActSystemQTY = SystemQTY,
         @nActPendingMoveIn = PendingMoveIn
      FROM dbo.TaskDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND TaskType = 'FCP'
         AND CaseID = @cActCaseID
         AND SKU = @cActCaseSKU
         AND LOT = @cActCaseLOT
         AND FromLoc = @cActCaseLOC
         AND FromID = @cActCaseFromID

      SET @nRowCount = @@ROWCOUNT

      IF @nRowCount = 0
      BEGIN
         SET @nErrNo = 276911
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Act case task not found
         GOTO Fail
      END

      IF @cActTaskStatus IN ('3','5', '9')
      BEGIN
         SET @nErrNo = 276912
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Act case task status invalid
         GOTO Fail
      END

      IF @cActTaskUOM <> '2'
      BEGIN
         SET @nErrNo = 276913
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Act case task is not UOM2
         GOTO Fail
      END

      IF @nActCaseAllocQty <> @nActTaskQty
      BEGIN
         SET @nErrNo = 276914
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Act case task qty mismatch
         GOTO Fail
      END

      IF EXISTS( SELECT 1 
            FROM dbo.PickDetail WITH (NOLOCK) 
            WHERE StorerKey = @cStorerKey
               AND TaskDetailKey = @cActTaskDetailKey
               AND Qty > 0 
               AND Status NOT IN ('0'))
      BEGIN
         SET @nErrNo = 276915
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Act case is picked
         GOTO Fail
      END

      IF @nDebugFlag = 1
         SELECT 'Act case task found', @cActTaskDetailKey AS ActTask
   END --valid act case task  

   INSERT INTO @tTaskPD (PickDetailKey, Qty)
   SELECT PickDetailKey, Qty
   FROM dbo.PickDetail WITH (NOLOCK) 
   WHERE StorerKey = @cStorerKey
      AND TaskDetailKey = @cTaskDetailKey
      AND Qty > 0
      AND Status = '0'

   IF @cActTaskType = 'FCP'
      INSERT INTO @tActPD (PickDetailKey, Qty)
      SELECT PickDetailKey, Qty
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND TaskDetailKey = @cActTaskDetailKey
         AND Qty > 0
         AND Status = '0'

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Get task case pickdetail'
      SELECT * FROM @tTaskPD
      SELECT 'Get act case pickdetail'
      SELECT * FROM @tActPD
   END

   /*--------------------------------------------------------------------------------------------------

                                                   Swap UCC Logic

   --------------------------------------------------------------------------------------------------*/
   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Start to swap case'
      SELECT 'Unallocate task case/act case pkd'
   END

   BEGIN TRAN
   SAVE TRAN rdt_1812SwapUCC07

   IF EXISTS (SELECT 1 FROM @tTaskPD)
   BEGIN
      BEGIN TRY
         UPDATE PKD WITH (ROWLOCK) SET
            Qty = 0,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         FROM dbo.PickDetail PKD
         JOIN @tTaskPD t
            ON PKD.PickDetailKey = t.PickDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 276916
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
         GOTO RollBackTran
      END CATCH
   END

   IF EXISTS (SELECT 1 FROM @tActPD)
   BEGIN
      BEGIN TRY
         UPDATE PKD WITH (ROWLOCK) SET
            Qty = 0,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         FROM dbo.PickDetail PKD
         JOIN @tActPD t
            ON PKD.PickDetailKey = t.PickDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 276917
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
         GOTO RollBackTran
      END CATCH
   END

   IF @nDebugFlag = 1
      SELECT 'reallocate task case/act case pkd'

   IF EXISTS (SELECT 1 FROM @tTaskPD)
   BEGIN
      BEGIN TRY
         UPDATE PKD WITH (ROWLOCK) SET
            LOT = @cActCaseLOT,
            Qty = t.Qty,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         FROM dbo.PickDetail PKD
         JOIN @tTaskPD t
            ON PKD.PickDetailKey = t.PickDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 276918
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
         GOTO RollBackTran
      END CATCH
   END

   IF EXISTS (SELECT 1 FROM @tActPD)
   BEGIN
      BEGIN TRY
         UPDATE PKD WITH (ROWLOCK) SET
            LOT = @cTaskLOT,
            Qty = t.Qty,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         FROM dbo.PickDetail PKD
         JOIN @tActPD t
            ON PKD.PickDetailKey = t.PickDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 276919
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
         GOTO RollBackTran
      END CATCH
   END

   IF @nDebugFlag = 1
      SELECT 'Update task with new case and lot'

   -- Update TaskDetail with new case and lot
   BEGIN TRY
      UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
         LOT = @cActCaseLOT,
         CaseID = @cActCaseID,
         TrafficCop = NULL,
         EditDate = GETDATE(),
         EditWho = SUSER_SNAME()
      WHERE TaskDetailKey = @cTaskDetailKey
   END TRY
   BEGIN CATCH
      SET @nErrNo = 276920
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD TskDtl Fail
      GOTO RollBackTran
   END CATCH

   IF ISNULL(@cActTaskDetailKey, '') <> ''
   BEGIN

      -- Update act ucc TaskDetail
      BEGIN TRY
         UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
            LOT = @cTaskLOT,
            CaseID = @cTaskCaseID,
            TrafficCop = NULL,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         WHERE TaskDetailKey = @cActTaskDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 276921
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD TskDtl Fail
         GOTO RollBackTran
      END CATCH
   END -- ActCase has pickdetail (FCP)

   IF @cTaskCaseID <> @cActCaseID
   BEGIN
      BEGIN TRY
         INSERT INTO rdt.SwapUCC (Func, UCC, NewUCC, ReplenGroup, UCCStatus, NewUCCStatus)
         VALUES (1812, @cTaskCaseID, @cActCaseID, @cTaskDetailKey, '', '')
      END TRY
      BEGIN CATCH
         SET @cMsg1 = TRY_CAST(276923 AS NVARCHAR(6))
         SET @cMsg2 = rdt.rdtgetmessage( 276923, @cLangCode, 'DSP') --Ins swap ucc fail

         EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cMsg1, @cMsg2
      END CATCH
   END

   SET @cSKU = @cActCaseSKU
   SET @nUCCQTY = @nActCaseQTY
   SET @cUCC = @cActCaseID

   COMMIT TRAN rdt_1812SwapUCC07 
   GOTO Quit

RollBackTran:
   IF @nTranCount > 0 AND XACT_STATE() = 1
      ROLLBACK TRAN rdt_1812SwapUCC07
   ELSE IF XACT_STATE() = -1 OR @nTranCount = 0
      ROLLBACK TRAN

Fail:
   SET @nUCCQTY = 0

Quit:
   IF @nDebugFlag = 1
      SELECT 'Quit', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
   
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1812SwapUCC07] TO [NSQL]
GO