SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_1812SwapUCC04                                         */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: Swap ucc for ONBR in Columbia                                     */
/*                                                                            */
/* Date        Rev    Author      Purposes                                    */
/* 2026-03-24  1.0    Jackc      FCR-11571 Created                            */
/* 2026-03-27  1.0.1  Jackc      FCR-11571 Handle task is loose item picking  */
/*                                                                            */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1812SwapUCC04]
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
   DECLARE @bSuccess       INT

   DECLARE @cActUCCNo      NVARCHAR( 20)
   DECLARE @cActUCCSKU        NVARCHAR( 20)
   DECLARE @cActUCCLOT        NVARCHAR( 10)
   DECLARE @cActUCCLOC        NVARCHAR( 10)
   DECLARE @cUCCID         NVARCHAR( 18)
   DECLARE @cActUCCStatus     NVARCHAR( 1)

   DECLARE @cStorerKey     NVARCHAR( 20)
   DECLARE @cTaskType      NVARCHAR( 10)
   DECLARE @cTaskUCCNo     NVARCHAR( 20)
   DECLARE @cTaskUOM       NVARCHAR( 5)
   DECLARE @cTaskLOT       NVARCHAR( 10)
   DECLARE @cTaskLOC       NVARCHAR( 10)
   DECLARE @cTaskID        NVARCHAR( 18)
   DECLARE @cTaskSKU       NVARCHAR( 20)
   DECLARE @nTaskQTY       INT
   DECLARE @nTaskUOMQTY    INT

   DECLARE @cPickDetailKey NVARCHAR( 10)
   DECLARE @cNewPickDetailKey NVARCHAR( 10)
   DECLARE @nQTY_Bal       INT
   DECLARE @nQTY_PD        INT
   DECLARE @curPD          CURSOR

   DECLARE @cActTaskDetailKey NVARCHAR( 10)
   DECLARE @cActSourceKey     NVARCHAR( 10)
   DECLARE @cActTaskType      NVARCHAR( 10)
   DECLARE @nActSystemQTY     INT
   DECLARE @nActTaskQty       INT
   DECLARE @nActUCCQty        INT
   DECLARE @nActPendingMoveIn INT

   DECLARE @cMsg1             NVARCHAR(60)
   DECLARE @cMsg2             NVARCHAR(60)
   DECLARE @cMsg3             NVARCHAR(60)

   DECLARE @tTaskPD TABLE
   (
      PickDetailKey NVARCHAR( 10) NOT NULL,
      PRIMARY KEY CLUSTERED (PickDetailKey)
   )

   DECLARE @tActPD TABLE
   (
      PickDetailKey NVARCHAR( 10) NOT NULL,
      PRIMARY KEY CLUSTERED (PickDetailKey)
   )

   IF @nDebugFlag = 1
      SELECT 'Executing 1812SwapUCC04', @cTaskDetailKey AS Task, @cBarcode AS LabelNo

   SET @nTranCount = @@TRANCOUNT
   SET @cActUCCNo = @cBarcode

   SELECT
      @cStorerKey = StorerKey,
      @cTaskType = TaskType,
      @cTaskUCCNo = CaseID,
      @cTaskUOM = UOM,
      @nTaskUOMQTY = UOMQTY,
      @cTaskLOT = LOT,
      @cTaskLOC = FromLOC,
      @cTaskID = FromID,
      @cTaskSKU = SKU,
      @nTaskQTY = QTY
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE TaskDetailKey = @cTaskDetailKey

   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo = 262152
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --BadTaskDtlKey
      GOTO Fail
   END

   --V1.0.1 If it is piece picking, return directly
   IF @cTaskUOM = '6'
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Piece picking, return'
         
      SET @nUCCQTY = 0
      SET @cUCC = ''

      GOTO Quit
   END

   IF @cTaskUCCNo = @cActUCCNo
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Same as task UCC, No swapping'

      SET @cSKU = @cTaskSKU
      SET @nUCCQty = @nTaskQTY
      SET @cUCC = @cTaskUCCNo
      GOTO Quit
   END

   IF @nDebugFlag = 1
      SELECT 'Validating scanned UCC', @cActUCCNo
   
   IF EXISTS( SELECT 1 FROM rdt.rdtRPFLog WITH (NOLOCK) WHERE UCCNo = @cActUCCNo)
   BEGIN
      SET @nErrNo = 262151
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC scanned
      GOTO Fail
   END

   SELECT @nRowCount = COUNT( 1)
   FROM dbo.UCC WITH (NOLOCK)
   WHERE UCCNo = @cActUCCNo
      AND StorerKey = @cStorerkey

   IF @nRowCount = 0
   BEGIN
      SET @nErrNo = 262153
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Not an UCC
      GOTO Fail
   END

   IF @nRowCount > 1
   BEGIN
      SET @nErrNo = 262154
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Multi SKU UCC
      GOTO Fail
   END

   SELECT
      @cActUCCSKU = SKU,
      @nActUCCQTY = QTY,
      @cActUCCLOT = LOT,
      @cActUCCLOC = LOC,
      @cUCCID  = ID,
      @cActUCCStatus = Status
   FROM dbo.UCC WITH (NOLOCK)
   WHERE UCCNo = @cActUCCNo
      AND StorerKey = @cStorerkey

   IF @cActUCCStatus NOT IN ('1', '3')
   BEGIN
      SET @nErrNo = 262159
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC cant pick
      GOTO Fail
   END

   IF @cTaskSKU <> @cActUCCSKU
   BEGIN
      SET @nErrNo = 262155
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU mismatch
      GOTO Fail
   END

   IF @cTaskLOC <> @cActUCCLOC
   BEGIN
      SET @nErrNo = 262156
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LOC mismatch
      GOTO Fail
   END

   IF @nTaskQTY <> @nActUCCQTY
   BEGIN
      SET @nErrNo = 262157
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --QTY mismatch
      GOTO Fail
   END

   IF @cTaskLOT <> @cActUCCLOT
   BEGIN
      SET @nErrNo = 262158
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LOT mismatch
      GOTO Fail
   END

   IF EXISTS(  SELECT 1 
               FROM dbo.TaskDetail WITH (NOLOCK) 
               WHERE StorerKey = @cStorerKey
                  AND Caseid = @cActUCCNo 
                  AND Status <> '0' )
   BEGIN
      SET @nErrNo = 262160
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC is taken
      GOTO Fail
   END

   IF EXISTS( SELECT 1 
               FROM dbo.PickDetail WITH (NOLOCK) 
               WHERE StorerKey = @cStorerKey
                  AND DropID = @cActUCCNo 
                  AND Status > '0')
   BEGIN
      SET @nErrNo = 262161
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC is taken
      GOTO Fail
   END

   SET @cActTaskDetailKey = ''
   SET @cActSourceKey = ''
   SET @nActTaskQty = 0
   SET @nActSystemQTY = 0
   SET @nActPendingMoveIn = 0

   SELECT
      @cActTaskDetailKey = TaskDetailKey,
      @cActTaskType = TaskType,
      @cActSourceKey = SourceKey,
      @nActSystemQTY = SystemQTY,
      @nActPendingMoveIn = PendingMoveIn
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND CaseID = @cActUCCNo
      AND Status = '0'

   IF @nDebugFlag = 1
      SELECT 'Scanned UCC task', @cActTaskDetailKey AS ActTask

   IF @cActUCCStatus = '3'
   BEGIN
      IF @cActTaskDetailKey = ''
      BEGIN
         SET @nErrNo = 262162
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Task not found
         GOTO Fail
      END
   END

   INSERT INTO @tTaskPD (PickDetailKey)
   SELECT PickDetailKey 
   FROM dbo.PickDetail WITH (NOLOCK) 
   WHERE StorerKey = @cStorerKey
      AND DropID = @cTaskUCCNo
      AND Qty > 0
      AND Status = '0'

   INSERT INTO @tActPD (PickDetailKey)
   SELECT PickDetailKey
   FROM dbo.PickDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND DropID = @cActUCCNo
      AND Qty > 0
      AND Status = '0'

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Get task UCC pickdetail'
      SELECT * FROM @tTaskPD
      SELECT 'Get act UCC pickdetail'
      SELECT * FROM @tActPD
   END

   /*--------------------------------------------------------------------------------------------------

                                                   Swap UCC Logic

   --------------------------------------------------------------------------------------------------*/
   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Start to swap UCC'
      SELECT 'Update original task & pkd'
   END

   BEGIN TRAN
   SAVE TRAN rdt_1812SwapUCC04

   --always update original task and pkd
   -- Update TaskDetail with new UCC
   BEGIN TRY
      UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
         LOT = @cActUCCLOT,
         CaseID = @cActUCCNo,
         TrafficCop = NULL,
         EditDate = GETDATE(),
         EditWho = SUSER_SNAME()
      WHERE TaskDetailKey = @cTaskDetailKey
   END TRY
   BEGIN CATCH
      SET @nErrNo = 262163
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD TskDtl Fail
      GOTO RollBackTran
   END CATCH

   IF EXISTS (SELECT 1 FROM @tTaskPD)
   BEGIN
      BEGIN TRY
         UPDATE PKD WITH (ROWLOCK) SET
            LOT = @cActUCCLOT,
            DropID = @cActUCCNo,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME(),
            TrafficCop = NULL
         FROM dbo.PickDetail PKD
         JOIN @tTaskPD t
            ON PKD.PickDetailKey = t.PickDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 262164
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
         GOTO RollBackTran
      END CATCH
   END

   IF @cActUCCStatus = '1'
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Act UCC without tasks'

      -- Update task UCC status to 1 (Received)
      BEGIN TRY
         UPDATE dbo.UCC WITH (ROWLOCK) SET
            Status = '1',
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         WHERE StorerKey = @cStorerkey
            AND UCCNo = @cTaskUCCNo
      END TRY
      BEGIN CATCH
         SET @nErrNo = 262165
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD UCC Fail
         GOTO RollBackTran
      END CATCH

      -- Update new UCC status to 3 (Allocated)
      BEGIN TRY
         UPDATE dbo.UCC WITH (ROWLOCK) SET
            Status = '3',
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         WHERE StorerKey = @cStorerkey
            AND UCCNo = @cActUCCNo
      END TRY
      BEGIN CATCH
         SET @nErrNo = 262166
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD UCC Fail
         GOTO RollBackTran
      END CATCH
   END --UCC status = 1
   --Status = 3 Swap Logic - FCP Task Type
   ELSE IF @cActUCCStatus = '3' AND @cActTaskType = 'FCP'
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Swap UCC with pickdetail'

      -- Update act ucc TaskDetail
      BEGIN TRY
         UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
            LOT = @cTaskLOT,
            CaseID = @cTaskUCCNo,
            TrafficCop = NULL,
            EditDate = GETDATE(),
            EditWho = 'rdt.' + SUSER_SNAME()
         WHERE TaskDetailKey = @cActTaskDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 262167
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD TskDtl Fail
         GOTO RollBackTran
      END CATCH

      -- Update act ucc PickDetail with old UCC
      IF EXISTS (SELECT 1 FROM @tActPD)
      BEGIN
         BEGIN TRY
            UPDATE PKD WITH (ROWLOCK) SET
               LOT = @cTaskLOT,
               DropID = @cTaskUCCNo,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME(),
               TrafficCop = NULL
            FROM dbo.PickDetail PKD
            JOIN @tActPD t
               ON PKD.PickDetailKey = t.PickDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 262168
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
            GOTO RollBackTran
         END CATCH
      END
   END -- ActUCC has pickdetail (FCP)
   /*================================================================================
   14. Status = 3 Swap Logic - RPF Task Type
   =================================================================================*/
   ELSE IF @cActTaskType = 'RPF'
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Swap UCC with RPF task'

      -- Update act ucc TaskDetail
      BEGIN TRY
         UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
            LOT = @cTaskLOT,
            CaseID = @cTaskUCCNo,
            TrafficCop = NULL,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         WHERE TaskDetailKey = @cActTaskDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 262169
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD TskDtl Fail
         GOTO RollBackTran
      END CATCH

      --Update Act UCC, add picking info from Task UCC
      BEGIN TRY
         UPDATE ActUCC WITH (ROWLOCK) SET
            Orderkey = TaskUCC.Orderkey,
            OrderLineNumber = TaskUCC.OrderLineNumber,
            PickDetailKey = TaskUCC.PickDetailKey,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         FROM dbo.UCC ActUCC
         JOIN dbo.UCC TaskUCC ON TaskUCC.UCCNo = @cTaskUCCNo AND TaskUCC.StorerKey = @cStorerkey
         WHERE ActUCC.UCCNo = @cActUCCNo
            AND ActUCC.StorerKey = @cStorerkey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 262175
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD act UCC Fail
         GOTO RollBackTran
      END CATCH

      --Update Task UCC, remove picking info from Task UCC
      BEGIN TRY
         UPDATE dbo.UCC WITH (ROWLOCK) SET
            Orderkey = '',
            OrderLineNumber = '',
            PickDetailKey = '',
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         WHERE UCCNo = @cTaskUCCNo
            AND StorerKey = @cStorerkey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 262176
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD task UCC Fail
         GOTO RollBackTran
      END CATCH
 
      -- Update REPLENISHMENT.RefNo for RPF task
      BEGIN TRY
         UPDATE dbo.REPLENISHMENT WITH (ROWLOCK) SET
            RefNo = @cTaskUCCNo,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         WHERE ReplenNo = @cActTaskDetailKey
            AND ReplenishmentKey = @cActSourceKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 262170
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD REPLEN Fail
         GOTO RollBackTran
      END CATCH

      /* -- lot, qty, from loc is same
      -- Handle Pending Move In for replenishment
      IF @nActPendingMoveIn > 0
      BEGIN
         BEGIN TRY
            EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK',
               '', --FromLOC
               '', --FromID
               '', --SuggLOC
               '', --Storer
               @nErrNo OUTPUT,
               @cErrMsg OUTPUT,
               @cTaskDetailKey = @cActTaskDetailKey

            IF @nErrNo <> 0
               GOTO RollBackTran

            EXEC rdt.rdt_Putaway_PendingMoveIn '', 'LOCK',
               @cActUCCLOC, --FromLOC
               @cUCCID,  --FromID
               @cTaskLOC, --SuggLOC
               @cStorerKey, --Storer
               @nErrNo OUTPUT,
               @cErrMsg OUTPUT,
               @cSKU = @cActUCCSKU,
               @nPutawayQTY = @nActUCCQTY,
               @cFromLOT = @cTaskLOT,
               @cTaskDetailKey = @cActTaskDetailKey,
               @nFunc = 0,
               @cMoveQTYAlloc = '1'

            IF @nErrNo <> 0
               GOTO RollBackTran
         END TRY
         BEGIN CATCH
            SET @nErrNo = 262165
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD REPLEN Fail
            GOTO RollBackTran
         END CATCH
      END*/
   END
   ELSE
   BEGIN
      SET @nErrNo = 262173
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Cannot swap ucc
      GOTO RollBackTran
   END

   IF @cTaskUCCNo <> @cActUCCNo
   BEGIN
      DECLARE @cTaskUCCStatus NVARCHAR(1)
      SELECT @cTaskUCCStatus = Status FROM dbo.UCC WITH (NOLOCK) WHERE UCCNo = @cTaskUCCNo AND StorerKey = @cStorerkey

      BEGIN TRY
         INSERT INTO rdt.SwapUCC (Func, UCC, NewUCC, ReplenGroup, UCCStatus, NewUCCStatus)
         VALUES (1812, @cTaskUCCNo, @cActUCCNo, @cTaskDetailKey, @cTaskUCCStatus, @cActUCCStatus)
      END TRY
      BEGIN CATCH
         SET @cMsg1 = TRY_CAST(262174 AS NVARCHAR(6))
         SET @cMsg2 = rdt.rdtgetmessage( 262174, @cLangCode, 'DSP') --Ins swap ucc fail

         EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cMsg1, @cMsg2
      END CATCH
   END

   SET @cSKU = @cActUCCSKU
   SET @nUCCQTY = @nActUCCQTY
   SET @cUCC = @cActUCCNo

   COMMIT TRAN rdt_1812SwapUCC04
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1812SwapUCC04

Fail:
   SET @nUCCQTY = 0

Quit:
   IF @nDebugFlag = 1
      SELECT 'Quit', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg

   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN
END
GO

GRANT EXECUTE ON [RDT].[rdt_1812SwapUCC04] TO [NSQL]
GO