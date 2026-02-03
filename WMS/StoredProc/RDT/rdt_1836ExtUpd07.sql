/*****************************************************************************/
/* Store procedure: rdt_1836ExtUpd07                                         */
/* Copyright      : Maersk                                                   */
/* Client         : ONBR                                                     */
/*                                                                           */
/* Modifications log:                                                        */
/*                                                                           */
/* Date         Author    Ver.    Purposes                                   */
/* 2025-12-10   Jackc     1.0.0   FCR-8535 set UCC status to 6               */
/* 2026-01-29   NickT     1.1.0   FCR-10467 release pick task and unlock loc */
/*****************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1836ExtUpd07]
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cTaskdetailKey  NVARCHAR( 10),
   @cFinalLOC       NVARCHAR( 10),
   @nErrNo          INT             OUTPUT,
   @cErrMsg         NVARCHAR( 20)   OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cCaseID           NVARCHAR( 20)
   DECLARE @nUCC_RowRef       INT
   DECLARE @cErrMsg1          NVARCHAR( 125)
   DECLARE @cErrMsg2          NVARCHAR( 125)
   DECLARE @cErrMsg3          NVARCHAR( 125)
   DECLARE @cStorerKey        NVARCHAR( 15)

   DECLARE @cTaskKey          NVARCHAR( 10)
   DECLARE @cTaskType         NVARCHAR( 10)

   DECLARE @cPickDetailKey    NVARCHAR( 15)
   DECLARE @cWaveKey          NVARCHAR( 10)
   DECLARE @cFacility         NVARCHAR( 5)
   DECLARE @cLot              NVARCHAR( 10)
   DECLARE @cLoc              NVARCHAR( 10)
   DECLARE @cSKU              NVARCHAR( 20)
   DECLARE @nQty              INT
   DECLARE @cAreakey          NVARCHAR(20)
   DECLARE @cFromLOC          NVARCHAR( 10)
   DECLARE @cSuggToLOC        NVARCHAR( 10)
   DECLARE @cSuggFinalLoc     NVARCHAR( 10)
   DECLARE @cRefTaskKey       NVARCHAR( 10)
   DECLARE @cTaskDetaiKey     NVARCHAR( 10)
   DECLARE @nLoopIndex        INT
   DECLARE @nTranCount        INT
   DECLARE @nRowRef           INT
   DECLARE @cSourceKey        NVARCHAR( 30)
   DECLARE @cUserName         NVARCHAR( 128)

   DECLARE @tTaskDetail TABLE
   (
      RowRef INT IDENTITY(1,1),
      TaskDetailKey        NVARCHAR(10) PRIMARY KEY
   )

   SELECT 
      @cFacility = FACILITY,
      @cStorerKey = Storerkey
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SET @nTranCount = @@TRANCOUNT

   -- TM Replen From
   IF @nFunc = 1836
   BEGIN
      IF @nStep = 1 -- Final Loc
      BEGIN
         IF @nInputKey = '1'
         BEGIN
            -- 1. Mark UCC as 6
            SELECT 
               @cCaseID = CaseID,
               @cLot = LOT,
               @cSKU = SKU,
               @cSourceKey = ISNULL(SourceKey, ''),
               @nQty = Qty
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE TaskDetailKey = @cTaskDetailKey

            SELECT @nUCC_RowRef = UCC_RowRef 
            FROM dbo.UCC WITH(NOLOCK) 
            WHERE StorerKey = @cStorerKey
               AND UCCNo = @cCaseID

            BEGIN TRAN
            SAVE TRAN rdt_1836ExtUpd07

            IF ISNULL(@nUCC_RowRef, 0) <> 0
            BEGIN
               BEGIN TRY
                  UPDATE dbo.UCC WITH (ROWLOCK)
                  SET Status = '6'
                  WHERE UCC_RowRef = @nUCC_RowRef
               END TRY
               BEGIN CATCH
                  SET @cErrMsg1 = '253301'
                  SET @cErrMsg2 = 'Update UCC failed'
                  SET @cErrMsg3 = 'UCC: ' + @cCaseID
                  EXEC rdt.rdtInsertMsgQueue @nMobile = @nMobile,
                     @nErrNo = @nErrNo,
                     @cErrMsg = @cErrMsg,
                     @cLine01 = @cErrMsg1,
                     @cLine02 = @cErrMsg2,
                     @cLine03 = @cErrMsg3,
                     @nDisplayMsg = 0

                  GOTO RollBackTran
               END CATCH
            END

            -- 2. Release pick task which is ON HOLD
            DELETE FROM @tTaskDetail
            INSERT INTO @tTaskDetail (TaskDetailKey)
            SELECT TaskDetailKey
            FROM dbo.TaskDetail WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND TaskType IN ('FCP','ASTCPK')
               AND Status = 'H'
               AND FromLoc = @cFinalLOC
               AND LOT = @cLot
               AND SKU = @cSKU
            ORDER BY OrderKey, OrderLineNumber, TaskDetailKey

            IF @@ROWCOUNT > 0
            BEGIN
               SET @nLoopIndex = -1
               WHILE 1 = 1
               BEGIN
                  SELECT TOP 1
                     @cTaskDetaiKey = TaskDetailKey,
                     @nLoopIndex = RowRef
                  FROM @tTaskDetail
                  WHERE RowRef > @nLoopIndex
                  ORDER BY RowRef

                  IF @@ROWCOUNT = 0
                     BREAK

                  BEGIN TRY
                     UPDATE dbo.TaskDetail WITH(ROWLOCK)
                     SET Status = '0',
                        UserKey = '',
                        EditWho = @cUserName,
                        EditDate = GETDATE(),
                        TrafficCop = NULL
                     WHERE TaskDetailKey = @cTaskDetaiKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 253302
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Update TaskDetail failed
                     GOTO RollBackTran
                  END CATCH
               END
            END

            -- 3. Unbook final Loc
            SELECT TOP 1 @nRowRef = RowRef 
            FROM dbo.RFPutaway WITH(NOLOCK) 
            WHERE ISNULL(TaskDetailKey, '') <> '' 
               AND TaskDetailKey IN (@cTaskDetaiKey, @cSourceKey)
               AND SuggestedLOC = @cFinalLOC
               AND SKU = @cSKU
               AND Qty = @nQty

            IF @@ROWCOUNT > 0 AND @nRowRef > 0
            BEGIN
               BEGIN TRY
                  EXEC rdt.rdt_Putaway_PendingMoveIn 
                     @cUserName     = '',
                     @cType         = 'UNLOCK',      -- LOCK / UNLOCK
                     @cFromLOC      = '',
                     @cFromID       = '',
                     @cSuggestedLOC = '',
                     @cStorerKey    = '',
                     @nErrNo        = @nErrNo    OUTPUT,
                     @cErrMsg       = @cErrMsg   OUTPUT, 
                     @cSKU          = '',
                     @nPutawayQTY   = 0,
                     @nRowRef       = @nRowRef,
                     @cUCCNo        = '', 
                     @cFromLOT      = '', 
                     @cToID         = '', 
                     @cTaskDetailKey= '', 
                     @nFunc         = @nFunc, 
                     @cMoveQTYAlloc = '',
                     @cMoveQTYPick  = ''
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 253303
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Exec rdt_Putaway_PendingMoveIn failed
                  GOTO RollBackTran
               END CATCH

               IF @nErrNo <> 0
               BEGIN
                  GOTO RollBackTran
               END
            END
            ELSE
            BEGIN
               BEGIN TRY
                  EXEC rdt.rdt_Putaway_PendingMoveIn 
                     @cUserName     = '',
                     @cType         = 'UNLOCK',      -- LOCK / UNLOCK
                     @cFromLOC      = '',
                     @cFromID       = '',
                     @cSuggestedLOC = @cFinalLOC,
                     @cStorerKey    = '',
                     @nErrNo        = @nErrNo    OUTPUT,
                     @cErrMsg       = @cErrMsg   OUTPUT, 
                     @cSKU          = @cSKU,
                     @nPutawayQTY   = @nQTY,
                     @nRowRef       = 0,
                     @cUCCNo        = '', 
                     @cFromLOT      = '', 
                     @cToID         = '', 
                     @cTaskDetailKey= '', 
                     @nFunc         = @nFunc, 
                     @cMoveQTYAlloc = '',
                     @cMoveQTYPick  = ''
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 253304
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Exec rdt_Putaway_PendingMoveIn failed
                  GOTO RollBackTran
               END CATCH

               IF @nErrNo <> 0
               BEGIN
                  GOTO RollBackTran
               END
            END

            COMMIT TRAN rdt_1836ExtUpd07
         END --enter
      END --st1
   END --1836

   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1836ExtUpd07 -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1836ExtUpd07 TO NSQL
GO
