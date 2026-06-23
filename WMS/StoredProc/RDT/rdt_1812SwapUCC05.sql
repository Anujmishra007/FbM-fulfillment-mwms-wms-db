SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_1812SwapUCC05                                         */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: Swap ucc for American Eagle Mexico                                */
/*                                                                            */
/* Date        Rev    Author      Purposes                                    */
/* 2026-06-16  1.0    Jackc       FCR-12989 Created                            */
/*                                                                            */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1812SwapUCC05]
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

   DECLARE @cActUCCNo      NVARCHAR( 20)
   DECLARE @cActUCCSKU     NVARCHAR( 20)
   DECLARE @cActUCCLOT     NVARCHAR( 10)
   DECLARE @cActUCCLOC     NVARCHAR( 10)
   DECLARE @cActUCCID         NVARCHAR( 18)
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
      SELECT 'Executing 1812SwapUCC05', @cTaskDetailKey AS Task, @cBarcode AS LabelNo

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
      SET @nErrNo = 269951
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
      SET @nErrNo = 269952
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC scanned
      GOTO Fail
   END

   SELECT @nRowCount = COUNT( 1)
   FROM dbo.UCC WITH (NOLOCK)
   WHERE UCCNo = @cActUCCNo
      AND StorerKey = @cStorerkey

   IF @nRowCount = 0
   BEGIN
      SET @nErrNo = 269953
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Not an UCC
      GOTO Fail
   END

   IF @nRowCount > 1
   BEGIN
      SET @nErrNo = 269954
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Multi SKU UCC
      GOTO Fail
   END

   SELECT
      @cActUCCSKU = SKU,
      @nActUCCQTY = QTY,
      @cActUCCLOT = LOT,
      @cActUCCLOC = LOC,
      @cActUCCID  = ID,
      @cActUCCStatus = Status
   FROM dbo.UCC WITH (NOLOCK)
   WHERE UCCNo = @cActUCCNo
      AND StorerKey = @cStorerkey

   IF @cActUCCStatus NOT IN ('1', '3')
   BEGIN
      SET @nErrNo = 269955
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC cant pick
      GOTO Fail
   END

   IF @cTaskSKU <> @cActUCCSKU
   BEGIN
      SET @nErrNo = 269956
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU mismatch
      GOTO Fail
   END

   IF @cTaskLOC <> @cActUCCLOC
   BEGIN
      SET @nErrNo = 269957
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LOC mismatch
      GOTO Fail
   END

   IF @nTaskQTY <> @nActUCCQTY
   BEGIN
      SET @nErrNo = 269958
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --QTY mismatch
      GOTO Fail
   END

   IF @cTaskLOT <> @cActUCCLOT
   BEGIN
      SET @nErrNo = 269959
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LOT mismatch
      GOTO Fail
   END

   IF ISNULL(@cTaskID, '') <> ISNULL(@cActUCCID, '')
   BEGIN
      SET @nErrNo = 269974
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID mismatch
      GOTO Fail
   END


   IF EXISTS(  SELECT 1 
               FROM dbo.TaskDetail WITH (NOLOCK) 
               WHERE StorerKey = @cStorerKey
                  AND Caseid = @cActUCCNo 
                  AND Status <> '0' )
   BEGIN
      SET @nErrNo = 269960
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC is taken
      GOTO Fail
   END

   IF EXISTS( SELECT 1 
               FROM dbo.PickDetail WITH (NOLOCK) 
               WHERE StorerKey = @cStorerKey
                  AND DropID = @cActUCCNo
                  AND Qty > 0 
                  AND Status NOT IN ('0','9'))
   BEGIN
      SET @nErrNo = 269961
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC is picked
      GOTO Fail
   END

   SET @cActTaskDetailKey = ''
   SET @cActSourceKey = ''
   SET @cActTaskType = ''
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

   IF @cActTaskType NOT IN ('FCP', 'RPF') AND @cActTaskType <> ''
   BEGIN
      SET @nErrNo = 269962
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Fail
   END

   IF @cActUCCStatus = '3'
   BEGIN
      IF @cActTaskDetailKey = ''
      BEGIN
         SET @nErrNo = 269963
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Task not found
         GOTO Fail
      END
   END

   INSERT INTO @tTaskPD (PickDetailKey)
   SELECT PickDetailKey 
   FROM dbo.PickDetail WITH (NOLOCK) 
   WHERE StorerKey = @cStorerKey
      AND TaskDetailKey = @cTaskDetailKey
      AND Qty > 0
      AND Status = '0'

   IF @cActTaskType = 'FCP'
      INSERT INTO @tActPD (PickDetailKey)
      SELECT PickDetailKey
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND TaskDetailKey = @cActTaskDetailKey
         AND Qty > 0
         AND Status = '0'
   ELSE IF @cActTaskType = 'RPF'
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
   SAVE TRAN rdt_1812SwapUCC05

   --always update original task and pkd
   -- Update TaskDetail with new UCC
   BEGIN TRY
      UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
         LOT = @cActUCCLOT,
         CaseID = @cActUCCNo,
         --FromID = CASE WHEN ISNULL(FromID, '') = '' THEN FromID ELSE @cActUCCID END,
         TrafficCop = NULL,
         EditDate = GETDATE(),
         EditWho = SUSER_SNAME()
      WHERE TaskDetailKey = @cTaskDetailKey
   END TRY
   BEGIN CATCH
      SET @nErrNo = 269964
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD TskDtl Fail
      GOTO RollBackTran
   END CATCH

   IF EXISTS (SELECT 1 FROM @tTaskPD)
   BEGIN
      BEGIN TRY
         UPDATE PKD WITH (ROWLOCK) SET
            LOT = @cActUCCLOT,
            DropID = @cActUCCNo,
            --ID = CASE WHEN ISNULL(ID, '') = '' THEN ID ELSE @cActUCCID END,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME(),
            TrafficCop = NULL
         FROM dbo.PickDetail PKD
         JOIN @tTaskPD t
            ON PKD.PickDetailKey = t.PickDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 269965
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
         SET @nErrNo = 269966
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
         SET @nErrNo = 269967
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD UCC Fail
         GOTO RollBackTran
      END CATCH
   END --UCC status = 1
   --Status = 3 Swap Logic - FCP Task Type
   ELSE IF @cActUCCStatus = '3' AND @cActTaskType = 'FCP'
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Swap UCC with FCP task'

      -- Update act ucc TaskDetail
      BEGIN TRY
         UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
            LOT = @cTaskLOT,
            CaseID = @cTaskUCCNo,
            --FromID = CASE WHEN ISNULL(FromID, '') = '' THEN FromID ELSE @cTaskID END,
            TrafficCop = NULL,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         WHERE TaskDetailKey = @cActTaskDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 269968
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
               --ID = CASE WHEN ISNULL(ID, '') = '' THEN ID ELSE @cActUCCID END,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME(),
               TrafficCop = NULL
            FROM dbo.PickDetail PKD
            JOIN @tActPD t
               ON PKD.PickDetailKey = t.PickDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 269969
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
            GOTO RollBackTran
         END CATCH
      END
   END -- ActUCC has pickdetail (FCP)
   /*================================================================================
   Status = 3 Swap Logic - RPF Task Type
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
            --FromID = CASE WHEN ISNULL(FromID, '') = '' THEN FromID ELSE @cTaskID END,
            TrafficCop = NULL,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         WHERE TaskDetailKey = @cActTaskDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 269970
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD TskDtl Fail
         GOTO RollBackTran
      END CATCH

      IF EXISTS (SELECT 1 FROM @tActPD)
      BEGIN
         BEGIN TRY
            UPDATE PKD WITH (ROWLOCK) SET
               LOT = @cTaskLOT,
               DropID = @cTaskUCCNo,
               --ID = CASE WHEN ISNULL(ID, '') = '' THEN ID ELSE @cActUCCID END,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME(),
               TrafficCop = NULL
            FROM dbo.PickDetail PKD
            JOIN @tActPD t
               ON PKD.PickDetailKey = t.PickDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 269969
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
            GOTO RollBackTran
         END CATCH
      END
 
      -- Update REPLENISHMENT.RefNo for RPF task
      IF EXISTS (SELECT 1 FROM dbo.REPLENISHMENT WITH (NOLOCK)
                  WHERE ReplenNo = @cActTaskDetailKey
                  AND ReplenishmentKey = @cActSourceKey
                  AND RefNo = @cActUCCNo)
      BEGIN
         BEGIN TRY
            UPDATE dbo.REPLENISHMENT WITH (ROWLOCK) SET
               RefNo = @cTaskUCCNo,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME()
            WHERE ReplenNo = @cActTaskDetailKey
               AND ReplenishmentKey = @cActSourceKey
               AND RefNo = @cActUCCNo
         END TRY
         BEGIN CATCH
            SET @nErrNo = 269971
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD REPLEN Fail
            GOTO RollBackTran
         END CATCH
      END

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
               @cActUCCID,  --FromID
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
      SET @nErrNo = 269972
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
         SET @cMsg1 = TRY_CAST(269973 AS NVARCHAR(6))
         SET @cMsg2 = rdt.rdtgetmessage( 269973, @cLangCode, 'DSP') --Ins swap ucc fail

         EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cMsg1, @cMsg2
      END CATCH
   END

   SET @cSKU = @cActUCCSKU
   SET @nUCCQTY = @nActUCCQTY
   SET @cUCC = @cActUCCNo

   COMMIT TRAN rdt_1812SwapUCC05 
   GOTO Quit

RollBackTran:
   IF @nTranCount > 0 AND XACT_STATE() = 1
      ROLLBACK TRAN rdt_1812SwapUCC05
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

GRANT EXECUTE ON [RDT].[rdt_1812SwapUCC05] TO [NSQL]
GO