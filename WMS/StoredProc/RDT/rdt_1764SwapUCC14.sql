SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_1764SwapUCC14                                         */
/* Copyright      : Maersk                                                    */
/* Customer       : AMERICAN EAGLE                                            */
/*                                                                            */
/* Date       Rev  Author    Purposes                                         */
/* 2026-06-16 1.0  NickT     FCR-12990 Created                                */
/******************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1764SwapUCC14
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cTaskdetailKey   NVARCHAR( 10),
   @cBarcode         NVARCHAR( 60),
   @cSKU             NVARCHAR( 20)  OUTPUT,
   @cUCC             NVARCHAR( 20)  OUTPUT,
   @nUCCQTY          INT            OUTPUT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cStorerKey                NVARCHAR( 15),
      @cFacility                 NVARCHAR( 5),
      @cUserName                 NVARCHAR( 20),

      @cTaskSuggestedToLOC       NVARCHAR( 10),

      @cOriginalTaskUOM          NVARCHAR( 5),
      @cOriginalTaskUCC          NVARCHAR( 20),
      @cOriginalTaskFromLoc      NVARCHAR( 10),
      @cOriginalTaskFromID       NVARCHAR( 18),
      @cOriginalTaskSKU          NVARCHAR( 20),
      @cOriginalTaskLot          NVARCHAR( 10),
      @nOriginalTaskQTY          INT,

      @cScannedUCC               NVARCHAR( 20),
      @cScannedUCCLoc            NVARCHAR( 10),
      @cScannedUCCID             NVARCHAR( 18),
      @cScannedUCCSKU            NVARCHAR( 20),
      @cScannedUCCLot            NVARCHAR( 10),
      @cScannedUCCStatus         NVARCHAR( 1),
      @cTaskdetailKeyTemp        NVARCHAR( 10),
      @cToLocTemp                NVARCHAR( 10),
      @cMoveQTYAlloc             NVARCHAR(1),
      @nScannedUCCQTY            INT,
      @nRowCount                 INT,
      @nTranCount                INT

   DECLARE @tTaskDetails#1 TABLE 
   (
      RowRef INT IDENTITY(1,1),
      TaskDetailKey NVARCHAR(10) PRIMARY KEY
   )

   DECLARE @tPickDetails#1 TABLE 
   (
      RowRef INT IDENTITY(1,1),
      PickDetailKey NVARCHAR(18) PRIMARY KEY,
      TaskDetailKey NVARCHAR(10) DEFAULT '',
      Qty INT
   )

   DECLARE @tPickDetails#2 TABLE 
   (
      RowRef         INT IDENTITY(1,1),
      PickDetailKey  NVARCHAR(18) PRIMARY KEY,
      TaskDetailKey  NVARCHAR(10) DEFAULT '',
      Qty            INT
   )

    DECLARE @tTaskDetails#2 TABLE 
   (
      RowRef INT IDENTITY(1,1),
      TaskDetailKey NVARCHAR(10) PRIMARY KEY,
      ToLoc NVARCHAR(10) DEFAULT ''
   )

   SELECT @cStorerKey = StorerKey,
      @cFacility = Facility,
      @cUserName = UserName
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SET @cScannedUCC = @cBarcode

   IF EXISTS( SELECT 1 FROM rdt.rdtRPFLog WITH (NOLOCK) WHERE UCCNo = @cScannedUCC)
   BEGIN
      SET @nErrNo = 270451
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC scanned
      GOTO Fail
   END

   SELECT 
      @cOriginalTaskUOM = UOM,
      @cOriginalTaskUCC = CaseID,
      @cOriginalTaskFromLoc = FromLoc,
      @cOriginalTaskFromID = FromID,
      @cOriginalTaskLot = LOT,
      @cOriginalTaskSKU = SKU,
      @nOriginalTaskQTY = QTY,
      @cTaskSuggestedToLOC = ToLoc
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE TaskDetailKey = @cTaskdetailKey
      AND StorerKey = @cStorerKey
      AND TaskType = 'RPF'

   SELECT 
      @cScannedUCCLoc = LOC,
      @cScannedUCCID = ID,
      @cScannedUCCSKU = SKU,
      @cScannedUCCStatus = Status,
      @cScannedUCCLot = LOT,
      @nScannedUCCQTY = QTY
   FROM dbo.UCC WITH (NOLOCK)
   WHERE UCCNo = @cScannedUCC
      AND StorerKey = @cStorerKey
   SELECT @nRowCount = @@ROWCOUNT

   IF @nRowCount = 0
   BEGIN
      SET @nErrNo = 270475
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Scanned UCC does not exist
      GOTO Fail
   END

   -- Check multi SKU UCC
   IF @nRowCount > 1
   BEGIN
      SET @nErrNo = 270476
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Scanned UCC contains multiple SKUs
      GOTO Fail
   END

   IF @cOriginalTaskUCC = @cScannedUCC
   BEGIN
      SET @cSKU = @cScannedUCCSKU
      SET @nUCCQTY = @nScannedUCCQTY
      SET @cUCC = @cScannedUCC
      RETURN
   END

   IF @cScannedUCCStatus NOT IN ('1', '3')
   BEGIN
      SET @nErrNo = 270452
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC status is not valid for swap
      GOTO Fail
   END

   -- Only same Loc, ID, SKU, Qty and Lot are allowed for swap
   IF @cOriginalTaskFromLoc <> @cScannedUCCLoc
   BEGIN
      SET @nErrNo = 270453
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Loc does not match
      GOTO Fail
   END

   IF @cOriginalTaskSKU <> @cScannedUCCSKU
   BEGIN
      SET @nErrNo = 270454
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- SKU does not match
      GOTO Fail
   END

   IF @cOriginalTaskLot <> @cScannedUCCLot
   BEGIN
      SET @nErrNo = 270455
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- LOT does not match
      GOTO Fail
   END

   IF @nOriginalTaskQTY <> @nScannedUCCQTY
   BEGIN
      SET @nErrNo = 270456
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- QTY does not match
      GOTO Fail
   END

   IF EXISTS(SELECT 1 
            FROM dbo.TaskDetail WITH (NOLOCK) 
            WHERE StorerKey = @cStorerKey
               AND TaskType = 'RPF'
               AND Status IN( '3', '5' )
               AND CaseID IS NOT NULL
               AND CaseID = @cScannedUCC 
            )
      OR EXISTS(SELECT 1 
            FROM dbo.TaskDetail WITH (NOLOCK) 
            WHERE StorerKey = @cStorerKey
               AND TaskType = 'FCP'
               AND Status IN ('3', '5')
               AND CaseID IS NOT NULL
               AND CaseID = @cScannedUCC 
            )
      OR EXISTS(SELECT 1
               FROM dbo.PickDetail WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND Status <> '0'
                  AND DropID IS NOT NULL
                  AND DropID = @cScannedUCC)
   BEGIN
      SET @nErrNo = 270457
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UCC is locked by other task
      GOTO Fail
   END

   -- 1. Unlock original task UCC from RPF and Pick Task, 
   -- 2. Unlock scanned UCC from RPF and Pick Task, 
   -- 3. Allocate scanned UCC to current RPF and Pick task,
   -- 4. Update UCC status

   SET @nTranCount = @@TRANCOUNT
   IF @nTranCount = 0
      BEGIN TRAN
   ELSE 
      SAVE TRAN rdt_1764SwapUCC14

   -- 1. #BEGIN Unlock original task UCC from RPF and Pick Task
   BEGIN
      -- 1.1) #BEGIN Unlock original task UCC from RPF
      BEGIN
         BEGIN TRY
            UPDATE dbo.TaskDetail WITH (ROWLOCK)
            SET 
               CaseID = '',
               FromID = '',
               EditDate = GETDATE(),
               EditWho = @cUserName,
               TrafficCop = NULL
            WHERE TaskDetailKey = @cTaskdetailKey
               AND StorerKey = @cStorerKey
               AND TaskType = 'RPF'
               AND CaseID = @cOriginalTaskUCC
         END TRY
         BEGIN CATCH
            SET @nErrNo = 270458
            SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, 'DSP') -- Unlock UCC from RPF task failed
            GOTO ROLLBACK_TRAN
         END CATCH

         -- Unlock original UCC from RFPutaway
         SET @nErrNo = 0
         BEGIN TRY
            EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
                  ,'' --FromLOC
                  ,'' --FromID
                  ,'' --SuggLOC
                  ,'' --Storer
                  ,@nErrNo  OUTPUT
                  ,@cErrMsg OUTPUT
                  ,@cTaskDetailKey = @cTaskDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 270472
            SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, 'DSP') -- Exec rdt_Putaway_PendingMoveIn failed
            GOTO ROLLBACK_TRAN
         END CATCH

         IF @nErrNo <> 0
            GOTO ROLLBACK_TRAN
      END
      -- 1.1) #END Unlock original task UCC from RPF
      
      -- 1.2) #BEGIN Unlock original task UCC from Pick
      BEGIN
         -- Unallocate task UCC from PickDetail
         DELETE FROM @tPickDetails#1
         INSERT INTO @tPickDetails#1 (PickDetailKey, TaskDetailKey, Qty)
         SELECT PickDetailKey, TaskDetailKey, Qty
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND Status = '0'
            AND DropID IS NOT NULL
            AND DropID = @cOriginalTaskUCC

         BEGIN TRY
            UPDATE PD WITH (ROWLOCK)
            SET 
               DropID = '',
               Qty = 0,
               EditDate = GETDATE(),
               EditWho = @cUserName
            FROM dbo.PickDetail PD 
            INNER JOIN @tPickDetails#1 TPD ON PD.PickDetailKey = TPD.PickDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 270459
            SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, 'DSP') -- Unlock UCC from FCP PickDetail failed
            GOTO ROLLBACK_TRAN
         END CATCH

         -- Unallocate task UCC from TaskDetail
         DELETE FROM @tTaskDetails#1
         INSERT INTO @tTaskDetails#1 (TaskDetailKey)
         SELECT TaskDetailKey
         FROM dbo.TaskDetail TD WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
               AND TaskType = 'FCP'
               AND Status IN ( '0', 'H' )
               AND CaseID IS NOT NULL
               AND CaseID = @cOriginalTaskUCC
               AND EXISTS(SELECT 1 FROM @tPickDetails#1 TPD WHERE TPD.TaskDetailKey IS NOT NULL AND TPD.TaskDetailKey = TD.TaskDetailKey)

         BEGIN TRY
            UPDATE TD WITH (ROWLOCK)
            SET
               CaseID = '',
               EditDate = GETDATE(),
               EditWho = @cUserName,
               TrafficCop = NULL
            FROM dbo.TaskDetail TD 
            INNER JOIN @tTaskDetails#1 TTD ON TD.TaskDetailKey = TTD.TaskDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 270460
            SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, 'DSP') -- Unlock UCC from FCP task failed
            GOTO ROLLBACK_TRAN
         END CATCH
      END
      -- 1.2) #END Unlock original task UCC from Pick
   END -- 1. #END Unlock original task UCC from RPF and Pick Task

   -- 2. #BEGIN Unlock scanned UCC from RPF and Pick Task
   BEGIN
      -- 2.1 #BEGIN Unlock scanned UCC from RPF task,
      BEGIN
         DELETE FROM @tTaskDetails#2
         INSERT INTO @tTaskDetails#2 (TaskDetailKey, ToLoc)
         SELECT TaskDetailKey, ToLoc
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND TaskType = 'RPF'
            AND Status = '0'
            AND FromLoc = @cScannedUCCLoc
            AND FromID = @cScannedUCCID
            AND SKU = @cScannedUCCSKU
            AND CaseID IS NOT NULL
            AND CaseID = @cScannedUCC

         -- replace it with original task UCC, if scanned UCC is allocated for RPF task
         IF EXISTS(SELECT 1 FROM @tTaskDetails#2)
         BEGIN
            BEGIN TRY
               UPDATE TD WITH (ROWLOCK)
               SET 
                  CaseID = @cOriginalTaskUCC,
                  FromID = @cOriginalTaskFromID,
                  EditDate = GETDATE(),
                  EditWho = @cUserName,
                  TrafficCop = NULL
               FROM dbo.TaskDetail TD
               INNER JOIN @tTaskDetails#2 TTD ON TD.TaskDetailKey = TTD.TaskDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 270461
               SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, 'DSP') -- Allocate task UCC to other RPF task failed
               GOTO ROLLBACK_TRAN
            END CATCH

            SELECT TOP 1 
               @cTaskdetailKeyTemp = TaskDetailKey, 
               @cToLocTemp = ToLoc 
            FROM @tTaskDetails#2
            ORDER BY RowRef

            -- Unlock scanned UCC from RFPutaway
            SET @nErrNo = 0
            BEGIN TRY
               EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
                     ,'' --FromLOC
                     ,'' --FromID
                     ,'' --SuggLOC
                     ,'' --Storer
                     ,@nErrNo  OUTPUT
                     ,@cErrMsg OUTPUT
                     ,@cTaskDetailKey = @cTaskdetailKeyTemp
            END TRY
            BEGIN CATCH
               SET @nErrNo = 270473
               SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, 'DSP') --  FExec rdt_Putaway_PendingMoveIn failed
               GOTO ROLLBACK_TRAN
            END CATCH

            IF @nErrNo <> 0
               GOTO ROLLBACK_TRAN
         END
      END
      -- 2.1 #END Unlock scanned UCC from RPF task

      -- 2.2 #BEGIN Unlock scanned UCC from Pick task
      -- replace it with original task UCC, if scanned UCC is allocated for Pick task
      BEGIN
         DELETE FROM @tPickDetails#2
         INSERT INTO @tPickDetails#2 (PickDetailKey, TaskDetailKey, Qty)
         SELECT PickDetailKey, PD.TaskDetailKey, PD.Qty
         FROM dbo.PickDetail PD WITH(NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND Status = '0'
            AND TaskDetailKey IS NOT NULL
            AND DropID IS NOT NULL
            AND DropID = @cScannedUCC

         -- Unallocate scanned UCC from PickDetail
         BEGIN TRY
            IF EXISTS(SELECT 1 FROM @tPickDetails#2)
            BEGIN
               UPDATE PD WITH (ROWLOCK)
               SET 
                  Qty = 0,
                  DropID = '',
                  EditDate = GETDATE(),
                  EditWho = @cUserName
               FROM dbo.PickDetail PD
               INNER JOIN @tPickDetails#2 TPD ON PD.PickDetailKey = TPD.PickDetailKey
            END
         END TRY
         BEGIN CATCH
            SET @nErrNo = 270462
            SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, 'DSP') -- Unallocate scanned UCC from PickDetail failed
            GOTO ROLLBACK_TRAN
         END CATCH

         SET @cMoveQTYAlloc = '0'
         -- Allocate original task UCC to scanned UCC's PickDetail
         BEGIN TRY
            IF EXISTS(SELECT 1 FROM @tPickDetails#2)
            BEGIN
               SET @cMoveQTYAlloc = '1'
               UPDATE PD WITH (ROWLOCK)
               SET 
                  Qty = TPD.Qty,
                  DropID = @cOriginalTaskUCC,
                  Loc = @cOriginalTaskFromLoc,
                  ID = @cOriginalTaskFromID,
                  EditDate = GETDATE(),
                  EditWho = @cUserName
               FROM dbo.PickDetail PD
               INNER JOIN @tPickDetails#2 TPD ON PD.PickDetailKey = TPD.PickDetailKey
            END
         END TRY
         BEGIN CATCH
            SET @nErrNo = 270463
            SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, 'DSP') -- Allocate task UCC to other PickDetail failed
            GOTO ROLLBACK_TRAN
         END CATCH

         -- Allocate original task UCC to TaskDetail which is allocated with scanned UCC, in case scanned UCC is allocated for Pick task but not RPF task
         BEGIN TRY
            IF EXISTS(SELECT 1 FROM @tPickDetails#2 WHERE TaskDetailKey IS NOT NULL AND TRIM(TaskDetailKey) <> '')
            BEGIN
               UPDATE TD WITH (ROWLOCK)
               SET
                  CaseID = @cOriginalTaskUCC,
                  FromLoc = @cOriginalTaskFromLoc,
                  FromID = @cOriginalTaskFromID,
                  EditDate = GETDATE(),
                  EditWho = @cUserName,
                  TrafficCop = NULL
               FROM dbo.TaskDetail TD
               INNER JOIN @tPickDetails#2 TPD ON TD.TaskDetailKey = TPD.TaskDetailKey
               WHERE TD.StorerKey = @cStorerKey
                  AND TD.TaskType = 'FCP'
                  AND TD.Status IN ( '0', 'H' )
                  AND TD.CaseID IS NOT NULL
                  AND TD.CaseID = @cScannedUCC
            END
         END TRY
         BEGIN CATCH
            SET @nErrNo = 270471
            SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, 'DSP') -- Allocate task UCC to other FCP TaskDetail failed
            GOTO ROLLBACK_TRAN
         END CATCH 

         -- Lock original UCC to RFPutaway
         SELECT TOP 1 
            @cTaskdetailKeyTemp = TaskDetailKey,
            @cToLocTemp = ToLoc
         FROM @tTaskDetails#2
         ORDER BY RowRef
         SELECT @nRowCount = @@ROWCOUNT
         
         SET @nErrNo = 0
         IF @nRowCount > 0 AND ISNULL(@cTaskdetailKeyTemp, '') <> ''
         BEGIN
            BEGIN TRY
               EXEC rdt.rdt_Putaway_PendingMoveIn '', 'LOCK'
                  ,@cOriginalTaskFromLoc --FromLOC
                  ,@cOriginalTaskFromID  --FromID
                  ,@cToLocTemp --SuggLOC
                  ,@cStorerKey --Storer
                  ,@nErrNo  OUTPUT
                  ,@cErrMsg OUTPUT
                  ,@cSKU = @cOriginalTaskSKU
                  ,@nPutawayQTY = @nOriginalTaskQTY
                  ,@cUCCNo = @cOriginalTaskUCC
                  ,@cFromLOT = @cOriginalTaskLot
                  ,@cTaskDetailKey = @cTaskdetailKeyTemp
                  ,@nFunc = 0
                  ,@cMoveQTYAlloc = @cMoveQTYAlloc
            END TRY
            BEGIN CATCH
               SET @nErrNo = 270473
               SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, 'DSP') --  FExec rdt_Putaway_PendingMoveIn failed
               GOTO ROLLBACK_TRAN
            END CATCH

            IF @nErrNo <> 0
               GOTO ROLLBACK_TRAN
         END
      END-- 2.2 #END Unlock scanned UCC from Pick task
   END-- 2. #END Unlock scanned UCC from RPF and Pick Task

   -- 3. #BEGIN allocate scanned UCC to current RPF and Pick task
   BEGIN
      -- 3.1 #BEGIN allocate scanned UCC to current RPF task
      BEGIN TRY
         UPDATE dbo.TaskDetail WITH (ROWLOCK)
         SET 
            CaseID = @cScannedUCC,
            FromLoc = @cScannedUCCLoc,
            FromID = @cScannedUCCID,
            EditDate = GETDATE(),
            EditWho = @cUserName,
            TrafficCop = NULL
         WHERE TaskDetailKey = @cTaskdetailKey
            AND StorerKey = @cStorerKey
            AND TaskType = 'RPF'
            AND (CaseID IS NULL OR CaseID = '')
      END TRY
      BEGIN CATCH
         SET @nErrNo = 270464
         SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, 'DSP') --  Allocate scanned UCC to RPF task failed
         GOTO ROLLBACK_TRAN
      END CATCH
      -- 3.1 #END allocate scanned UCC to current RPF task

      -- 3.2 #BEGIN allocate scanned UCC to current Pick detail
      SET @cMoveQTYAlloc = '0'
      BEGIN TRY
         IF EXISTS(SELECT 1 FROM @tPickDetails#1)
         BEGIN
            SET @cMoveQTYAlloc = '1'
            UPDATE PD WITH (ROWLOCK)
            SET 
               Qty = TPD.Qty,
               DropID = @cScannedUCC,
               Loc = @cScannedUCCLoc,
               ID = @cScannedUCCID,
               EditDate = GETDATE(),
               EditWho = @cUserName
            FROM dbo.PickDetail PD
            INNER JOIN @tPickDetails#1 TPD ON PD.PickDetailKey = TPD.PickDetailKey
            WHERE StorerKey = @cStorerKey
               AND PD.Status = '0'
               AND PD.Qty = 0
               AND PD.DropID = ''
         END
      END TRY
      BEGIN CATCH
         SET @nErrNo = 270465
         SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, 'DSP') --  Allocate scanned UCC to PickDetail failed
         GOTO ROLLBACK_TRAN
      END CATCH
      -- 3.2 #END allocate scanned UCC to current Pick detail

      -- 3.3 #BEGIN allocate scanned UCC to current Pick task
      BEGIN TRY
         IF EXISTS(SELECT 1 FROM @tTaskDetails#1)
         BEGIN
            UPDATE TD WITH (ROWLOCK)
            SET 
               CaseID = @cScannedUCC,
               FromLoc = @cScannedUCCLoc,
               FromID = @cScannedUCCID,
               EditDate = GETDATE(),
               EditWho = @cUserName,
               TrafficCop = NULL
            FROM dbo.TaskDetail TD
            INNER JOIN @tPickDetails#1 TPD ON TD.TaskDetailKey = TPD.TaskDetailKey
            WHERE StorerKey = @cStorerKey
               AND Status IN ( '0', 'H' )
         END
      END TRY
      BEGIN CATCH
         SET @nErrNo = 270466
         SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, 'DSP') --  Allocate scanned UCC to TaskDetail failed
         GOTO ROLLBACK_TRAN
      END CATCH
      -- 3.3 #END allocate scanned UCC to current Pick task

      -- 3.4 #BEGIN Lock scanned UCC in RFPutaway
      BEGIN TRY
         EXEC rdt.rdt_Putaway_PendingMoveIn '', 'LOCK'
               ,@cScannedUCCLoc --FromLOC
               ,@cScannedUCCID  --FromID
               ,@cTaskSuggestedToLOC --SuggLOC
               ,@cStorerKey --Storer
               ,@nErrNo  OUTPUT
               ,@cErrMsg OUTPUT
               ,@cSKU = @cScannedUCCSKU
               ,@nPutawayQTY = @nScannedUCCQTY
               ,@cUCCNo = @cScannedUCC
               ,@cFromLOT = @cScannedUCCLot
               ,@cTaskDetailKey = @cTaskDetailKey
               ,@nFunc = 0
               ,@cMoveQTYAlloc = @cMoveQTYAlloc
      END TRY
      BEGIN CATCH
         SET @nErrNo = 270467
         SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, 'DSP') --  Fail to lock scanned UCC to RFPutaway
         GOTO ROLLBACK_TRAN
      END CATCH

      IF @nErrNo <> 0
         GOTO ROLLBACK_TRAN
      -- 3.4 #END Lock scanned UCC in RFPutaway

      SET @cUCC = @cScannedUCC
      SET @cSKU = @cScannedUCCSKU
      SET @nUCCQTY = @nScannedUCCQTY
   END -- 3. #END allocate scanned UCC to current RPF and Pick task

   -- 4. #BEGIN Update UCC status
   BEGIN
      --4.1 # BEGIN Update scanned UCC status to '3'
      IF EXISTS(SELECT 1 FROM dbo.PickDetail WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND Status = '0' AND DropID IS NOT NULL AND DropID = @cScannedUCC)
      BEGIN
         BEGIN TRY
            UPDATE dbo.UCC WITH (ROWLOCK)
            SET Status = '3',
               EditDate = GETDATE(),
               EditWho = @cUserName
            WHERE UCCNo = @cScannedUCC
               AND StorerKey = @cStorerKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 270468
            SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, 'DSP') --  Update scanned UCC to 3 failed
            GOTO ROLLBACK_TRAN
         END CATCH
      END
      --4.1 # END Update scanned UCC status to '3'

      --4.2 # BEGIN Update scanned UCC status to '1'
      IF NOT EXISTS(SELECT 1 FROM dbo.PickDetail WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND Status = '0' AND DropID IS NOT NULL AND DropID = @cScannedUCC)
      BEGIN
         BEGIN TRY
            UPDATE dbo.UCC WITH (ROWLOCK)
            SET Status = '1',
               EditDate = GETDATE(),
               EditWho = @cUserName
            WHERE UCCNo = @cScannedUCC
               AND StorerKey = @cStorerKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 270474
            SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, 'DSP') --   Update scanned UCC to 1 failed
            GOTO ROLLBACK_TRAN
         END CATCH
      END
      --4.2 # END Update scanned UCC status to '1'

      -- 4.3 #BEGIN Update original UCC status to '1'
      IF NOT EXISTS(SELECT 1 FROM dbo.PickDetail WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND Status = '0' AND DropID IS NOT NULL AND DropID = @cOriginalTaskUCC)
      BEGIN
         BEGIN TRY
            UPDATE dbo.UCC WITH (ROWLOCK)
            SET Status = '1',
               EditDate = GETDATE(),
               EditWho = @cUserName
            WHERE UCCNo = @cOriginalTaskUCC
               AND StorerKey = @cStorerKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 270469
            SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, 'DSP') --   Update original task UCC to 1 failed
            GOTO ROLLBACK_TRAN
         END CATCH
      END-- 4.3 #END Update original UCC status to '1'

      -- 4.4 #BEGIN If scanned UCC is allocated to other PickDetail, update it to 3 if needed
      IF EXISTS(SELECT 1 FROM dbo.PickDetail WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND Status = '0' AND DropID IS NOT NULL AND DropID = @cOriginalTaskUCC)
      BEGIN
         BEGIN TRY
            UPDATE dbo.UCC WITH (ROWLOCK)
            SET Status = '3',
               EditDate = GETDATE(),
               EditWho = @cUserName
            WHERE UCCNo = @cOriginalTaskUCC
               AND StorerKey = @cStorerKey
               AND Status = '1'
         END TRY
         BEGIN CATCH
            SET @nErrNo = 270470
            SET @cErrMsg = rdt.rdtGetMessage( @nErrNo, @cLangCode, 'DSP') -- Update original task UCC to 3 failed
            GOTO ROLLBACK_TRAN
         END CATCH
      END-- 4.4 #END If scanned UCC is allocated to other PickDetail, update it to 3 if needed
      
   END -- 4. #END Update UCC status

   IF @@TRANCOUNT > @nTranCount
   BEGIN
      IF XACT_STATE() = 1
         COMMIT TRANSACTION
   END
   GOTO QUIT

   Fail:
   ROLLBACK_TRAN:
   IF @@TRANCOUNT > 0
   BEGIN
      IF @nTranCount = 0
      BEGIN
         ROLLBACK TRANSACTION
      END
      ELSE
      BEGIN
         IF XACT_STATE() <> -1
            ROLLBACK TRANSACTION rdt_1764SwapUCC14
         ELSE
            ROLLBACK TRANSACTION 
      END
   END
   QUIT:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1764SwapUCC14 TO NSQL
GO
