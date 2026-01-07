
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*******************************************************************************/
/* Store procedure: rdt_1764ClosePlt04                                         */
/* Copyright      : Maersk WMS                                                 */
/* Customer       : USA                                                        */
/*                                                                             */
/* Purpose: Confirm replenish.                                                 */
/*                                                                             */
/* Called from:                                                                */
/*                                                                             */
/* Modifications log:                                                          */
/*                                                                             */
/* Date        Rev      Author    Purposes                                     */
/* 2025-10-02  1.0.0    NLT013    FCR-7730 Created                             */
/* 2025-11-08  1.1.0    NLT013    UWP-43838 Mark TaskDetail as MoveInProgress  */
/* 2025-11-08  1.2.0    NLT013    UWP-44117 Update TaskDetail by Primary Key   */
/* 2025-11-04  1.3.0    NLT013    UWP-43847 Mark Pickdetail as 3, print ZPL    */
/* 2025-11-10  1.4.0    Cuize     UWP-43757 Performance Issue Fix              */
/* 2025-11-20  1.5.0    NLT013    UWP-44502 Do not send WSCTOTALLOCLOG for SHORT*/
/* 2025-12-09  1.6.0    NLT013    UWP-45319 No need to update Message03 if short*/
/* 2025-12-31  1.7.0    NLT013    FCR-7928 Trigger WSSOAlloUpd for real short  */
/* 2026-01-07  1.8.0    NLT013    UWP-46553 Update Task failed if last task is short*/
/*******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1764ClosePlt04] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR(3),
   @cUserName      NVARCHAR(18),
   @cListKey       NVARCHAR(10),
   @nErrNo         INT         OUTPUT,
   @cErrMsg        NVARCHAR(20) OUTPUT,  -- screen limitation, 20 char max
   @cScannedToLoc       NVARCHAR( 10) = ''  -- New param for FCR-7730
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cTaskDetailKey NVARCHAR( 10)
   DECLARE @cPickMethod    NVARCHAR( 10)
   DECLARE @cStorerKey     NVARCHAR( 15)
   DECLARE @cFacility      NVARCHAR( 5)
   DECLARE @cOrderKey      NVARCHAR( 10)
   DECLARE @cWaveKey       NVARCHAR( 10)
   DECLARE @cFromLOC       NVARCHAR( 10)
   DECLARE @cFromID        NVARCHAR( 18)
   DECLARE @cToLoc         NVARCHAR( 10)
   DECLARE @cToID          NVARCHAR( 18)
   DECLARE @cSKU           NVARCHAR( 20)
   DECLARE @cLOT           NVARCHAR( 10)
   DECLARE @cUCCNo         NVARCHAR( 20)
   DECLARE @nQTY           INT
   DECLARE @nSystemQTY     INT
   DECLARE @nQTYAlloc      INT
   DECLARE @nQTYReplen     INT
   DECLARE @nUCCQTY        INT
   DECLARE @cMoveQTYAlloc  NVARCHAR( 1)
   DECLARE @cMoveQTYReplen NVARCHAR( 1)
   DECLARE @cToLocType     NVARCHAR( 10)
   DECLARE @cLoseUCC       NVARCHAR( 1)
   DECLARE @cLoseID        NVARCHAR( 1)
   DECLARE @cClosePalletSP NVARCHAR( 20)
   DECLARE @cSQL           NVARCHAR( MAX)
   DECLARE @cSQLParam      NVARCHAR( MAX)
   DECLARE @cCurrentTaskDetailKey NVARCHAR(10)
   DECLARE @cReasonKey     NVARCHAR( 10)

   DECLARE @tTaskDetail TABLE
   (
      TaskDetailKey NVARCHAR(10) PRIMARY KEY
   )

   DECLARE @trRDTRPFLog TABLE
   (
      RowRef INT PRIMARY KEY
   )

   -- Init var
   SET @nErrNo = 0
   SET @cErrMsg = ''

   SELECT @cStorerKey = StorerKey,
      @cCurrentTaskDetailKey = V_TaskDetailKey
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   INSERT INTO @tTaskDetail ( TaskDetailKey )
   SELECT TaskDetailKey
   FROM dbo.TaskDetail WITH(NOLOCK)
   WHERE ListKey = @cListKey
      AND UserKey = @cUserName
      AND Status = '5'
      AND TaskType = 'RPF'
      AND StorerKey = @cStorerKey
      AND ReasonKey = ''

   IF EXISTS (SELECT 1 FROM @tTaskDetail)
   BEGIN
      UPDATE TD
      SET Message03 = 'MoveInProgress',
         EditDate = GETDATE(),
         EditWho  = SUSER_SNAME(),
         TrafficCop = NULL
      FROM dbo.TaskDetail TD WITH(ROWLOCK)
      INNER JOIN @tTaskDetail TTD ON TD.TaskDetailKey = TTD.TaskDetailKey
   END

   /***********************************************************************************************
                                     Standard Close Pallet
   ***********************************************************************************************/

   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_1764ClosePlt04 -- For rollback or commit only our own transaction

   IF EXISTS(SELECT 1 FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cScannedToLoc AND LocationType = 'PND' )
   BEGIN
      DECLARE 
         @nCurrentStep        INT

      SELECT 
         @nCurrentStep = Step
      FROM rdt.RDTMOBREC WITH (NOLOCK)
      WHERE Mobile = @nMobile

      IF @nCurrentStep = 6
      BEGIN
         DELETE FROM @tTaskDetail
         INSERT INTO @tTaskDetail ( TaskDetailKey )
         SELECT DISTINCT TD.TaskDetailKey
         FROM dbo.TaskDetail TD WITH(NOLOCK)
         INNER JOIN dbo.SKUInfo SI WITH(NOLOCK) ON (TD.StorerKey = SI.StorerKey AND TD.SKU = SI.SKU)
         WHERE TD.StorerKey = @cStorerKey
            AND TD.ListKey = @cListKey
            AND TD.Status = '5'
            AND TD.TaskType = 'RPF'
            AND TD.Qty > 0
            AND TD.UserKey = SUSER_SNAME()
            AND TD.ToLOC <> @cScannedToLoc
            AND ISNULL(SI.ExtendedField06, '') = 'SORTABLE' 
            AND ISNULL(SI.ExtendedField07, '') = 'CONVEYABLE'

         IF @@ROWCOUNT > 0
         BEGIN
            BEGIN TRY
               UPDATE TD
               SET ToLOC = @cScannedToLoc,
                  EditDate = GETDATE(),
                  EditWho  = SUSER_SNAME(),
                  TrafficCop = NULL
               FROM dbo.TaskDetail TD WITH(ROWLOCK)
               INNER JOIN @tTaskDetail TTD ON TD.TaskDetailKey = TTD.TaskDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 248401
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update TaskDetail ToLoc Fail
               GOTO RollBackTran
            END CATCH
         END
      END
   END

   -- Lock orders to prevent deadlock
   DECLARE @curPD CURSOR
   SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT OrderKey
      FROM PickDetail WITH (NOLOCK)
      WHERE TaskDetailKey IN (
         SELECT TaskDetailKey
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE ListKey = @cListKey
            AND UserKey = @cUserName
            AND Status = '5') -- 3=Fetch, 5=Picked, 9=Complete
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
         SET @nErrNo = 78506
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- LockOrderFail
         GOTO RollBackTran
      END
      FETCH NEXT FROM @curPD INTO @cOrderKey
   END

   -- Loop tasks
   DECLARE @curRPTask CURSOR
   SET @curRPTask = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
      SELECT TaskDetailKey, PickMethod, StorerKey, FromLOC, FromID, ToLOC, ToID, SKU, LOT, QTY, SystemQTY, WaveKey
      FROM dbo.TaskDetail WITH (NOLOCK)
      WHERE ListKey = @cListKey
         AND UserKey = @cUserName
         AND Status = '5' -- 3=Fetch, 5=Picked, 9=Complete
      ORDER BY TaskDetailKey
   OPEN @curRPTask
   FETCH NEXT FROM @curRPTask INTO @cTaskDetailKey, @cPickMethod, @cStorerKey, @cFromLOC, @cFromID, @cToLoc, @cToID, @cSKU, @cLOT, @nQTY, @nSystemQTY, @cWaveKey
   WHILE @@FETCH_STATUS = 0
   BEGIN
      SELECT @cFacility = Facility FROM LOC WITH (NOLOCK) WHERE LOC = @cFromLOC

      -- Full pallet replenish
      IF @cPickMethod = 'FP'
      BEGIN
         -- Reduce QTYReplen
         UPDATE dbo.LOTxLOCxID WITH (ROWLOCK) SET
            QTYReplen = 0
         WHERE LOC = @cFromLOC
            AND ID = @cFromID
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 78501
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdTaskdetFail
            GOTO RollBackTran
         END

         -- Move inventory
         EXECUTE rdt.rdt_Move
            @nMobile     = @nMobile,
            @cLangCode   = @cLangCode,
            @nErrNo      = @nErrNo  OUTPUT,
            @cErrMsg     = @cErrMsg OUTPUT,
            @cSourceType = 'rdt_1764ClosePlt04',
            @cStorerKey  = @cStorerKey,
            @cFacility   = @cFacility,
            @cFromLOC    = @cFromLOC,
            @cToLoc      = @cToLoc,
            @cFromID     = @cFromID,
            @cToID       = @cFromID,
            @nFunc       = @nFunc
         IF @nErrNo <> 0
            GOTO RollBackTran

         EXEC RDT.rdt_STD_EventLog
            @cActionType    = '5', -- Replenish
            @cUserID        = @cUserName,
            @nMobileNo      = @nMobile,
            @nFunctionID    = @nFunc,
            @cFacility      = @cFacility,
            @cStorerKey     = @cStorerKey,
            @cLocation      = @cFromLOC,
            @cToLocation    = @cToLoc,
            @cID            = @cFromID,
            @cToID          = @cToID,
            @cRefNo5        = @cListKey,
            @cTaskDetailKey = @cTaskDetailKey,
            @cSKU           = @cSKU,
            @nQTY           = @nQTY
      END

      -- Partial pallet replenish
      IF @cPickMethod = 'PP'
      BEGIN
         -- Move inventory
         IF EXISTS( SELECT 1 FROM rdt.rdtRPFLog WITH (NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey)
         BEGIN
            SET @cMoveQTYAlloc = rdt.RDTGetConfig( @nFunc, 'MoveQTYAlloc', @cStorerKey)
            SET @cMoveQTYReplen = rdt.RDTGetConfig( @nFunc, 'MoveQTYReplen', @cStorerKey)

            DECLARE @curUCC CURSOR
            SET @curUCC = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
               SELECT UCCNo, QTY
               FROM rdt.rdtRPFLog WITH (NOLOCK)
               WHERE TaskDetailKey = @cTaskDetailKey
            OPEN @curUCC
            FETCH NEXT FROM @curUCC INTO @cUCCNo, @nUCCQTY
            WHILE @@FETCH_STATUS = 0
            BEGIN
               -- Single sku ucc
               IF EXISTS ( SELECT 1 FROM dbo.UCC WITH (NOLOCK)
                           WHERE Storerkey = @cStorerKey
                           AND   UCCNo = @cUCCNo
                           GROUP BY UCCNo
                           HAVING COUNT( DISTINCT SKU) = 1)
               BEGIN
                  -- Calc QTYAlloc
                  IF @cMoveQTYAlloc = '1'
                  BEGIN
                     IF @nUCCQTY < @nSystemQTY -- Short replen
                        SET @nQTYAlloc = @nUCCQTY
                     ELSE
                        SET @nQTYAlloc = @nSystemQTY

                     SET @nSystemQTY = @nSystemQTY - @nQTYAlloc
                  END
                  ELSE
                     SET @nQTYAlloc = 0

                  -- Calc QTYReplen
                  IF @cMoveQTYReplen = '1'
                  BEGIN
                     IF @cMoveQTYAlloc = '1'
                        SET @nQTYReplen = @nUCCQTY - @nQTYAlloc
                     ELSE
                        SET @nQTYReplen = @nUCCQTY
                  END
                  ELSE
                     SET @nQTYReplen = 0

                  -- Move by UCC
                  EXECUTE rdt.rdt_Move
                     @nMobile     = @nMobile,
                     @cLangCode   = @cLangCode,
                     @nErrNo      = @nErrNo  OUTPUT,
                     @cErrMsg     = @cErrMsg OUTPUT,
                     @cSourceType = 'rdt_1764ClosePlt04',
                     @cStorerKey  = @cStorerKey,
                     @cFacility   = @cFacility,
                     @cFromLOC    = @cFromLOC,
                     @cToLoc      = @cToLoc,
                     @cFromID     = @cFromID,
                     @cToID       = @cToID,
                     @cUCC        = @cUCCNo,
                     @nQTYAlloc   = @nQTYAlloc,
                     @nQTYReplen  = @nQTYReplen,
                     @nFunc       = @nFunc,
                     @cDropID     = @cUCCNo
                  IF @nErrNo <> 0
                     GOTO RollBackTran

                  EXEC RDT.rdt_STD_EventLog
                     @cActionType    = '5', -- Replenish
                     @cUserID        = @cUserName,
                     @nMobileNo      = @nMobile,
                     @nFunctionID    = @nFunc,
                     @cFacility      = @cFacility,
                     @cStorerKey     = @cStorerKey,
                     @cLocation      = @cFromLOC,
                     @cToLocation    = @cToLoc,
                     @cID            = @cFromID,
                     @cToID          = @cToID,
                     @cRefNo1        = @cUCCNo,
                     @cRefNo5        = @cListKey,
                     @cTaskDetailKey = @cTaskDetailKey
               END
               ELSE  -- Multi sku ucc
               BEGIN
                  DECLARE @nPD_Qty     INT = 0
                  SELECT @nPD_Qty = ISNULL( SUM( Qty), 0)
                  FROM dbo.PICKDETAIL WITH (NOLOCK)
                  WHERE TaskDetailKey = @cTaskDetailKey

                  DECLARE @cUCC_SKU    NVARCHAR (20)
                  DECLARE @curMultiSKUUCC CURSOR
                  SET @curMultiSKUUCC = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
                  SELECT SKU, Lot, SUM( Qty)
                  FROM dbo.UCC WITH (NOLOCK)
                  WHERE Storerkey = @cStorerKey
                  AND   UCCNo = @cUCCNo
                  GROUP BY SKU, Lot
                  OPEN @curMultiSKUUCC
                  FETCH NEXT FROM @curMultiSKUUCC INTO @cUCC_SKU, @cLOT, @nUCCQTY
                  WHILE @@FETCH_STATUS = 0
                  BEGIN
                     -- Calc QTYAlloc
                     SET @cMoveQTYAlloc = rdt.RDTGetConfig( @nFunc, 'MoveQTYAlloc', @cStorerKey)
                     IF @cMoveQTYAlloc = '1'
                     BEGIN
                        IF @nUCCQTY < @nSystemQTY -- Short replen
                        BEGIN
                           SET @nQTYAlloc = @nUCCQTY

                           IF @nPD_Qty > 0
                           BEGIN
                              IF @nPD_Qty < @nQTYAlloc
                              BEGIN
                                 SET @nQTYAlloc = @nPD_Qty
                                 SET @nPD_Qty = 0
                              END
                              ELSE
                                 SET @nPD_Qty = @nPD_Qty - @nQTYAlloc
                           END
                           ELSE
                              SET @nQTYAlloc = 0
                        END
                        ELSE
                           SET @nQTYAlloc = @nSystemQTY
                     END
                     ELSE
                        SET @nQTYAlloc = 0

                     -- Calc QTYReplen
                     SET @cMoveQTYReplen = rdt.RDTGetConfig( @nFunc, 'MoveQTYReplen', @cStorerKey)
                     IF @cMoveQTYReplen = '1'
                     BEGIN
                        IF @cMoveQTYAlloc = '1'
                           SET @nQTYReplen = @nUCCQTY - @nQTYAlloc
                        ELSE
                           SET @nQTYReplen = @nUCCQTY
                     END
                     ELSE
                        SET @nQTYReplen = 0

                     -- move ucc with multi sku (rdt_move not support yet)
                     EXECUTE rdt.rdt_Move
                        @nMobile     = @nMobile,
                        @cLangCode   = @cLangCode,
                        @nErrNo      = @nErrNo  OUTPUT,
                        @cErrMsg     = @cErrMsg OUTPUT,
                        @cSourceType = 'rdt_1764ClosePlt04',
                        @cStorerKey  = @cStorerKey,
                        @cFacility   = @cFacility,
                        @cFromLOC    = @cFromLOC,
                        @cToLoc      = @cToLoc,
                        @cFromID     = @cFromID,
                        @cToID       = @cToID,
                        @cSKU        = @cUCC_SKU,
                        @nQTY        = @nUCCQTY,
                        @nQTYAlloc   = @nQTYAlloc,
                        @nQTYReplen  = @nQTYReplen,
                        @cFromLOT    = @cLOT,
                        @nFunc       = @nFunc,
                        @cTaskDetailKey = @cTaskDetailKey

                     IF @nErrNo <> 0
                        GOTO RollBackTran

                     -- Get LocationType
                     SELECT @cToLocType = SL.LocationType
                     FROM dbo.SKUxLOC SL (NOLOCK)
                     WHERE SL.StorerKey = @cStorerKey
                     AND   SL.SKU = @cUCC_SKU
                     AND   SL.LOC = @cToLoc

                     SET @cLoseUCC = ''
                     SET @cLoseID = ''
                     SELECT
                        @cLoseID = LoseID,
                        @cLoseUCC = LoseUCC
                     FROM dbo.LOC (NOLOCK)
                     WHERE LOC = @cToLoc

                     -- Update UCC (rdt_move not support move ucc with multisku ucc)
                     UPDATE dbo.UCC WITH (ROWLOCK) SET
                        LOC = @cToLoc,
                        ID = CASE
                              WHEN @cLoseID = '1' THEN '' -- Lose ID
                              WHEN @cToID IS NULL THEN ID -- ID not change
                              ELSE @cToID
                              END,
                        -- Lose UCC. Status 5=Picked/Repl
                        Status = CASE WHEN (@cToLocType = 'PICK' OR @cToLocType = 'CASE')  THEN '5'
                                      WHEN @cLoseUCC = '1' THEN '6'
                                      ELSE Status
                                 END,
                        EditWho = SUSER_SNAME(),
                        EditDate = GETDATE(),
                        TrafficCop = NULL
                     WHERE StorerKey = @cStorerKey
                     AND   LOT = @cLOT
                     AND   LOC = @cFromLOC
                     AND   ID  = @cFromID
                     AND   UCCNo = @cUCCNo
                     AND   SKU = @cUCC_SKU
                     AND   Status IN ('1', '3') -- Received, , Allocated
                     AND   Status <> ''

                     IF @@ERROR <> 0
                     BEGIN
                        SET @nErrNo = 78508
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD UCC Fail
                        GOTO RollBackTran
                     END

                     EXEC RDT.rdt_STD_EventLog
                        @cActionType    = '5', -- Replenish
                        @cUserID        = @cUserName,
                        @nMobileNo      = @nMobile,
                        @nFunctionID    = @nFunc,
                        @cFacility      = @cFacility,
                        @cStorerKey     = @cStorerKey,
                        @cLocation      = @cFromLOC,
                        @cToLocation    = @cToLoc,
                        @cID            = @cFromID,
                        @cToID          = @cToID,
                        @cSKU           = @cSKU,
                        @nQTY           = @nQTY,
                        @cLOT           = @cLOT,
                        @cRefNo5        = @cListKey,
                        @cTaskDetailKey = @cTaskDetailKey

                     FETCH NEXT FROM @curMultiSKUUCC INTO @cUCC_SKU, @cLOT, @nUCCQTY
                  END
               END

               -- Clear rdtRPFLog
               DELETE FROM @trRDTRPFLog

               INSERT INTO @trRDTRPFLog ( RowRef )
               SELECT RowRef
               FROM rdt.rdtRPFLog WITH (NOLOCK)
               WHERE TaskDetailKey = @cTaskDetailKey
                  AND UCCNo = @cUCCNo

               DELETE RR
               FROM rdt.rdtRPFLog RR WITH(ROWLOCK)
               INNER JOIN @trRDTRPFLog TRR ON RR.RowRef = TRR.RowRef

               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 78505
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- DelRPFLogFail
                  GOTO RollBackTran
               END

               FETCH NEXT FROM @curUCC INTO @cUCCNo, @nUCCQTY
            END
         END
         ELSE
         BEGIN
            -- Calc QTYAlloc
            SET @cMoveQTYAlloc = rdt.RDTGetConfig( @nFunc, 'MoveQTYAlloc', @cStorerKey)
            IF @cMoveQTYAlloc = '1'
            BEGIN
               IF @nQTY < @nSystemQTY -- Short replen
                  SET @nQTYAlloc = @nQTY
               ELSE
                  SET @nQTYAlloc = @nSystemQTY
            END
            ELSE
               SET @nQTYAlloc = 0

            -- Calc QTYReplen
            SET @cMoveQTYReplen = rdt.RDTGetConfig( @nFunc, 'MoveQTYReplen', @cStorerKey)
            IF @cMoveQTYReplen = '1'
            BEGIN
               IF @cMoveQTYAlloc = '1'
                  SET @nQTYReplen = @nQTY - @nQTYAlloc
               ELSE
                  SET @nQTYReplen = @nQTY
            END
            ELSE
               SET @nQTYReplen = 0

            -- Move by SKU
            IF @nQTY > 0
            BEGIN
               EXECUTE rdt.rdt_Move
                  @nMobile     = @nMobile,
                  @cLangCode   = @cLangCode,
                  @nErrNo      = @nErrNo  OUTPUT,
                  @cErrMsg     = @cErrMsg OUTPUT,
                  @cSourceType = 'rdt_1764ClosePlt04',
                  @cStorerKey  = @cStorerKey,
                  @cFacility   = @cFacility,
                  @cFromLOC    = @cFromLOC,
                  @cToLoc      = @cToLoc,
                  @cFromID     = @cFromID,
                  @cToID       = @cToID,
                  @cSKU        = @cSKU,
                  @nQTY        = @nQTY,
                  @nQTYAlloc   = @nQTYAlloc,
                  @nQTYReplen  = @nQTYReplen,
                  @cFromLOT    = @cLOT,
                  @nFunc       = @nFunc,
                  @cTaskDetailKey = @cTaskDetailKey
                  --@cWaveKey    = @cWaveKey
               IF @nErrNo <> 0
                  GOTO RollBackTran

               EXEC RDT.rdt_STD_EventLog
                  @cActionType    = '5', -- Replenish
                  @cUserID        = @cUserName,
                  @nMobileNo      = @nMobile,
                  @nFunctionID    = @nFunc,
                  @cFacility      = @cFacility,
                  @cStorerKey     = @cStorerKey,
                  @cLocation      = @cFromLOC,
                  @cToLocation    = @cToLoc,
                  @cID            = @cFromID,
                  @cToID          = @cToID,
                  @cSKU           = @cSKU,
                  @nQTY           = @nQTY,
                  @cLOT           = @cLOT,
                  @cRefNo5        = @cListKey,
                  @cTaskDetailKey = @cTaskDetailKey
            END
         END
      END

      -- Commented by (james04)
      --IF EXISTS ( SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey AND ISNULL( TransitLOC, '') <> '')
      --BEGIN
      -- Unlock  suggested location
      EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
         ,''      --@cFromLOC
         ,@cFromID--@cFromID
         ,@cToLoc --@cSuggestedLOC
         ,''      --@cStorerKey
         ,@nErrNo  OUTPUT
         ,@cErrMsg OUTPUT
      IF @nErrNo <> 0
         GOTO Quit
      --END

      -- Update Task
      UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
         Status = '9', -- Closed
         -- UserPosition = @cUserPosition,
         Message03 = IIF(ReasonKey = '', 'MoveCompleted', Message03),
         EndTime = GETDATE(),
         EditDate = GETDATE(),
         EditWho  = @cUserName,
         Trafficcop = NULL
      WHERE TaskDetailKey = @cTaskDetailKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 78504
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdTaskdetFail
         GOTO RollBackTran
      END
      FETCH NEXT FROM @curRPTask INTO @cTaskDetailKey, @cPickMethod, @cStorerKey, @cFromLOC, @cFromID, @cToLoc, @cToID, @cSKU, @cLOT, @nQTY, @nSystemQTY, @cWaveKey
   END

   -- 1. Update PickDetail as 3
   -- 2. Print ZPL label

   -- Update PickDetail as 3
   DECLARE
      @cLocationType             NVARCHAR(10),
      @cLocationCategory         NVARCHAR(10),
      @cCaseID                   NVARCHAR(20),
      @cTaskStatus               NVARCHAR(10),
      @cWSCTOTALLOCLOG           NVARCHAR(10),
      @nLoopIndex                INT,
      @nRowCount                 INT,
      @bSuccess                  INT

   SELECT
      @cLocationType = LocationType,
      @cLocationCategory = LocationCategory,
      @cToLoc = Loc
   FROM dbo.LOC WITH(NOLOCK)
   WHERE LOC = IIF(@cScannedToLoc <> '', @cScannedToLoc, @cToLoc)

   IF @cLocationType = 'PND'
   BEGIN
      DECLARE @tPickDetail TABLE
      (
         PickDetailKey  NVARCHAR(18) PRIMARY KEY
      )
      DECLARE @tCases TABLE
      (
         ID    INT IDENTITY(1,1),
         CaseID NVARCHAR(20),
         SKU    NVARCHAR(20)
      )

      DELETE FROM @tPickDetail

      INSERT INTO @tPickDetail( PickDetailKey )
      SELECT DISTINCT PD.PickDetailKey
      FROM dbo.PickDetail PD WITH (NOLOCK)
      INNER JOIN dbo.TaskDetail TD WITH(NOLOCK) ON PD.StorerKey = TD.StorerKey AND PD.TaskDetailKey = TD.TaskDetailKey AND PD.SKU = TD.SKU
      INNER JOIN dbo.SKUInfo SI WITH(NOLOCK) ON TD.StorerKey = SI.StorerKey AND TD.SKU = SI.SKU
      WHERE PD.StorerKey = @cStorerKey
         AND TD.ListKey = @cListKey
         AND PD.Status = '0'
         AND TD.Status = '9'
         AND TD.TaskType = 'RPF'
         AND ISNULL(SI.ExtendedField06, '') = 'SORTABLE'
         AND ISNULL(SI.ExtendedField07, '') = 'CONVEYABLE'

      IF @@ROWCOUNT > 0
      BEGIN
         BEGIN TRY
            UPDATE PD
            SET Status = '3',
               Loc = @cToLoc,
               EditDate = GETDATE(),
               EditWho  = SUSER_SNAME()
            FROM dbo.PickDetail PD WITH (ROWLOCK)
            INNER JOIN @tPickDetail TPD ON PD.PickDetailKey = TPD.PickDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 248402
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update PickDetail Failed
            GOTO RollBackTran
         END CATCH
      END

      -- Print ZPL
      DECLARE @cRefTaskKey       NVARCHAR(10) = ''
      DELETE FROM @tCases

      INSERT INTO @tCases(CaseID, SKU)
      SELECT DISTINCT CaseID, SKU
      FROM dbo.TaskDetail WITH (NOLOCK)
      WHERE ListKey = @cListKey
         AND Status = '9'
         AND TaskType = 'RPF'
         AND Qty > 0

      SET @nLoopIndex = -1
      WHILE 1 = 1
      BEGIN
         SELECT TOP 1
            @cCaseID = CASEID,
            @cSKU = SKU,
            @nLoopIndex = id
         FROM @tCases
         WHERE id > @nLoopIndex
         ORDER BY id

         IF @@ROWCOUNT = 0
            BREAK

         IF EXISTS(SELECT 1
                  FROM dbo.SkuInfo WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND SKU = @cSKU
                     AND ISNULL(ExtendedField06, '') = 'SORTABLE'
                     AND ISNULL(ExtendedField07, '') = 'CONVEYABLE')
         BEGIN
            DECLARE @nCaseCount INT = 0

            SELECT @nCaseCount = COUNT(DISTINCT CASEID)
            FROM dbo.PICKDETAIL PD WITH(NOLOCK)
            WHERE PD.StorerKey= @cStorerKey
               AND PD.DropID = @cCaseID

            DECLARE @nVASCount INT = 0
            DECLARE @cPrePackIndicator NVARCHAR(30) = ''

            SELECT @cPrePackIndicator = ISNULL(SKU.PrePackIndicator, '')
            FROM dbo.SKU WITH(NOLOCK)
            WHERE StorerKey= @cStorerKey
               AND SKU = @cSKU

            SELECT @nVASCount = COUNT(*)
            FROM dbo.PickDetail PD WITH(NOLOCK)
            INNER JOIN dbo.WorkOrderDetail WOD WITH(NOLOCK)
               ON WOD.ExternWorkOrderKey IS NOT NULL
               AND WOD.ExternLineNo IS NOT NULL
               AND WOD.ExternWorkOrderKey = PD.OrderKey
               AND WOD.ExternLineNo = PD.OrderLineNumber
            INNER JOIN dbo.CODELKUP CL WITH(NOLOCK)
               ON CL.StorerKey = PD.StorerKey
               AND ISNULL(WOD.Type, '') = CL.short
            WHERE PD.StorerKey = @cStorerKey
               AND PD.DropID = @cCaseID
               AND PD.UOM = '2'
               AND CL.LISTNAME = 'WCSVAS'

            IF @nCaseCount = 1 AND (@nVASCount = 0 OR @cPrePackIndicator = 'Y')
               AND EXISTS (SELECT 1 FROM dbo.UCC WITH(NOLOCK) WHERE UCCNo = @cCaseID AND StorerKey = @cStorerKey)
               AND NOT EXISTS (SELECT 1
                           FROM dbo.ORDERS ORM WITH(NOLOCK)
                           INNER JOIN dbo.PICKDETAIL PD WITH(NOLOCK)
                              ON PD.StorerKey = ORM.StorerKey
                              AND PD.OrderKey = ORM.OrderKey
                           INNER JOIN dbo.CODELKUP CL WITH(NOLOCK)
                              ON CL.StorerKey = ORM.StorerKey
                              AND CL.LISTNAME = 'WSCourier'
                              AND CL.Code = 'ECL-1'
                              AND ORM.ShipperKey = CL.short
                           WHERE PD.StorerKey = @cStorerKey
                              AND PD.DropID = @cCaseID
                              AND PD.UOM = '2')
            BEGIN
               DECLARE @cACTCaseID NVARCHAR(20)
               SELECT @cACTCaseID = CASEID FROM dbo.PICKDETAIL WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND DropID = @cCaseID
               -- Login user's printer must = 'PANDA', then goes to ZPL print
               BEGIN TRY
                  EXEC rdt.rdt_LevisPrintCartonLabel
                     @nMobile       = @nMobile
                     ,@nFunc        = @nFunc
                     ,@cLangCode    = @cLangCode
                     ,@cStorerKey   = @cStorerKey
                     ,@nStep        = 6
                     ,@nInputKey    = 1
                     ,@cDropID      = @cACTCaseID
                     ,@cPrintType   = 'ZPL'
                     ,@nErrNo       = @nErrNo      OUTPUT
                     ,@cErrMsg      = @cErrMsg     OUTPUT
                     ,@cSourceName  = 'rdt_1764ClosePlt04'
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 248403
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Print ZPL Failed
                  GOTO RollBackTran
               END CATCH

               IF @nErrNo <> 0
               BEGIN
                  GOTO RollBackTran
               END
            END
         END
      END
   END

   -- Generate TransmitLog for WSCTOTALLOCLOG if needed
   DECLARE @cMessage02        NVARCHAR(50) = ''
   DECLARE @cTryQty           NVARCHAR(5) = ''
   DECLARE @cRealloNumberofRetry      NVARCHAR(5) = ''

   SET @cTaskDetailKey = @cCurrentTaskDetailKey
   SELECT
      @cSKU = SKU,
      @cWaveKey = WaveKey,
      @cCaseID = CaseID,
      @cTaskStatus = Status,
      @nQty = Qty,
      @cReasonKey = ReasonKey,
      @cMessage02 = Message02
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND TaskdetailKey = @cTaskDetailKey
      AND TaskType = 'RPF'

   SET @cRealloNumberofRetry = rdt.RDTGetConfig( @nFunc, 'RealloNumberofRetry', @cStorerKey)
   IF @cRealloNumberofRetry = '0'
      SET @cRealloNumberofRetry = '99'
   
   IF LEFT(@cMessage02, 4) = 'SKIP' AND LEN(@cMessage02) > 4
      SET @cTryQty = RIGHT(@cMessage02, LEN(@cMessage02) - 4)

   IF @cTaskStatus IN ( '5', '9' ) -- RPF task is completed
   BEGIN
      IF @nQty > 0 AND @cReasonKey <> 'SHORT'
      BEGIN
         SELECT @nRowCount = COUNT(*)
         FROM dbo.SkuInfo WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND SKU = @cSKU
            AND ISNULL(ExtendedField06, '') = 'SORTABLE'
            AND ISNULL(ExtendedField07, '') = 'CONVEYABLE'

         SET @cWSCTOTALLOCLOG = rdt.RDTGetConfig( @nFunc, 'WSCTOTALLOCLOG', @cStorerKey)

         IF @nRowCount > 0 AND @cWSCTOTALLOCLOG = '1'
         BEGIN
            SELECT @nRowCount = COUNT(*)
            FROM dbo.Transmitlog2 WITH (NOLOCK)
            WHERE TableName = 'WSCTOTALLOCLOG'
               AND Key1 = @cWaveKey
               AND Key2 = @cCaseID
               AND Key3 = @cStorerKey

            IF @nRowCount = 0 -- No record exist, then generate TransmitLog
            BEGIN
               BEGIN TRY
                  EXEC ispGenTransmitLog2
                     @c_TableName        = 'WSCTOTALLOCLOG'
                     ,@c_Key1             = @cWaveKey
                     ,@c_Key2             = @cCaseID
                     ,@c_Key3             = @cStorerKey
                     ,@c_TransmitBatch    = ''
                     ,@b_Success          = @bSuccess   OUTPUT
                     ,@n_err              = @nErrNo     OUTPUT
                     ,@c_errmsg           = @cErrMsg    OUTPUT
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 233652
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Generate TransmitLog Failed
                  GOTO RollBackTran
               END CATCH

               IF @bSuccess <> 1
               BEGIN
                  GOTO RollBackTran
               END
            END
         END
      END
      ELSE
      BEGIN
         -- 1. Tried qty reached to config value, then generate TransmitLog for each PickDetail
         -- 2. Tried qty not reached, but no UCC is available for re-allocation, then also generate TransmitLog for each PickDetail
         IF @cReasonKey = 'SHORT' AND 
            (@cRealloNumberofRetry = @cTryQty OR ( TRY_CAST(@cTryQty AS INT) IS NOT NULL AND @cTryQty < @cRealloNumberofRetry AND @cMessage02 = '') )
         BEGIN
            DECLARE @curPKD            CURSOR
            DECLARE @cPickDetailKey    NVARCHAR(10)
            DECLARE @nQTY_PD           INT

            SET @curPKD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT PD.PickDetailKey, PD.QTY, PD.OrderKey
               FROM dbo.PickDetail PD WITH (NOLOCK)
               WHERE PD.TaskDetailKey = @cTaskDetailKey
                  AND PD.Status = '4'
               Order by PD.OrderKey, PD.OrderLineNumber, PD.PickDetailKey
         
            OPEN @curPKD
            FETCH NEXT FROM @curPKD INTO @cPickDetailKey, @nQTY_PD, @cOrderKey
            WHILE @@FETCH_STATUS = 0
            BEGIN
               IF NOT EXISTS(SELECT 1 FROM dbo.Transmitlog2 WITH (NOLOCK)
                           WHERE TableName = 'WSSOAlloUpd'
                              AND Key1 = @cOrderKey
                              AND Key2 = @cPickDetailKey
                              AND Key3 = @cStorerkey)
               BEGIN
                  EXEC ispGenTransmitLog2
                     @c_TableName        = 'WSSOAlloUpd'
                     ,@c_Key1             = @cOrderKey
                     ,@c_Key2             = @cPickDetailKey
                     ,@c_Key3             = @cStorerkey
                     ,@c_TransmitBatch    = ''
                     ,@b_Success          = @bSuccess   OUTPUT
                     ,@n_err              = @nErrNo     OUTPUT
                     ,@c_errmsg           = @cErrMsg    OUTPUT

                  IF @bSuccess <> 1
                  BEGIN
                     SET @nErrNo = 248404
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Generate transmitlog2 failed 
                     CLOSE @curPKD
                     DEALLOCATE @curPKD
                     GOTO RollBackTran
                  END
               END

               FETCH NEXT FROM @curPKD INTO @cPickDetailKey, @nQTY_PD, @cOrderKey
            END -- cursor end
            CLOSE @curPKD
            DEALLOCATE @curPKD
         END
      END
   END

   -- Create next task
   EXEC rdt.rdt_TM_Replen_CreateNextTask @nMobile, @nFunc, @cLangCode,
      @cUserName,
      @cListKey,
      @nErrNo  OUTPUT,
      @cErrMsg OUTPUT
   IF @nErrNo <> 0
      GOTO RollBackTran


   COMMIT TRAN rdt_1764ClosePlt04 -- Only commit change made here
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1764ClosePlt04 -- Only rollback change made here
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

GRANT EXECUTE ON [rdt].[rdt_1764ClosePlt04] TO NSQL
GO
