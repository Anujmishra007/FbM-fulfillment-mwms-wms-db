SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/**************************************************************************/
/* Store procedure: rdt_1764SwapID08                                      */
/* Copyright      : Maersk WMS                                            */
/*                                                                        */
/* Purpose: Swap ID - validates scanned ID is in same LOC, same SKU,      */
/*          same QTY, and not allocated before swapping.                  */
/*                                                                        */
/* Date        Rev      Author      Purposes                              */
/* 2026-08-13  1.0.0    NYE018      FCR-14962 Create                      */
/**************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1764SwapID08
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

   DECLARE @nRowCount     INT
   DECLARE @nTranCount    INT

   DECLARE @cStorerKey    NVARCHAR( 15)

   DECLARE @cTaskSKU      NVARCHAR( 20)
   DECLARE @cTaskLOT      NVARCHAR( 10)
   DECLARE @cTaskLOC      NVARCHAR( 10)
   DECLARE @cTaskID       NVARCHAR( 18)
   DECLARE @nTaskQTY      INT
   DECLARE @nTaskQTYReplen INT

   DECLARE @cNewSKU       NVARCHAR( 20)
   DECLARE @cNewLOT       NVARCHAR( 10)
   DECLARE @cNewLOC       NVARCHAR( 10)
   DECLARE @nNewQTY       INT

   SELECT @nErrNo = 0, @cErrMsg = '', @cNewTaskDetailKey = ''

   -- Validate blank input
   IF ISNULL(@cNewID, '') = ''
   BEGIN
      SET @nErrNo = 277851
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- NeedID
      GOTO Quit
   END

   -- Get session StorerKey
   SELECT @cStorerKey = StorerKey
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Get task info
   SELECT
      @cTaskSKU  = SKU,
      @cTaskLOT  = LOT,
      @cTaskLOC  = FromLOC,
      @cTaskID   = FromID,
      @nTaskQTY  = QTY
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE TaskDetailKey = @cTaskDetailKey
      AND StorerKey = @cStorerKey

   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo = 277852
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- BadTaskDtlKey
      GOTO Quit
   END

   -- Get scanned ID info from inventory
   SELECT
      @cNewSKU = SKU,
      @cNewLOT = LOT,
      @cNewLOC = LOC,
      @nNewQTY = QTY - QTYPicked
   FROM dbo.LOTxLOCxID WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND ID = @cNewID
      AND QTY - QTYPicked > 0

   SET @nRowCount = @@ROWCOUNT

   IF @nRowCount = 0
   BEGIN
      SET @nErrNo = 277853
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InvalidID
      GOTO Quit
   END

   -- Check: same LOC as task FromLOC
   IF @cNewLOC <> @cTaskLOC
   BEGIN
      SET @nErrNo = 277854
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- PalletCannotBePicked
      GOTO Quit
   END

   -- Check: same SKU as task SKU
   IF @cNewSKU <> @cTaskSKU
   BEGIN
      SET @nErrNo = 277858
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- PalletCannotBePicked
      GOTO Quit
   END

   -- Check: same QTY as task QTY
   IF @nNewQTY <> @nTaskQTY
   BEGIN
      SET @nErrNo = 277859
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- PalletCannotBePicked
      GOTO Quit
   END

   -- Check: scanned ID is not allocated to any task (not part of any TaskDetail.FromID)
   IF EXISTS (
      SELECT 1
      FROM dbo.TaskDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND FromID = @cNewID
         AND Status IN ('0', '3', '5', 'Q', 'H')
   )
   BEGIN
      SET @nErrNo = 277860
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- PalletCannotBePicked
      GOTO Quit
   END

   -- Get current QTYReplen on the original task ID (to transfer to the new ID)
   SELECT @nTaskQTYReplen = ISNULL(QTYReplen, 0)
   FROM dbo.LOTxLOCxID WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND LOC = @cTaskLOC
      AND ID = @cTaskID

   SET @nTaskQTYReplen = ISNULL(@nTaskQTYReplen, 0)

   /*--------------------------------------------------------------------
      Swap: update TaskDetail and transfer QTYReplen between IDs
   --------------------------------------------------------------------*/
   SET @nTranCount = @@TRANCOUNT

   IF @nTranCount = 0
      BEGIN TRAN
   ELSE
      SAVE TRAN rdt_1764SwapID08

   -- Update TaskDetail to point at the scanned ID
   BEGIN TRY
      UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
          LOT      = CASE WHEN LOT <> '' THEN @cNewLOT ELSE '' END,
          FromID   = @cNewID,
          ToID     = CASE WHEN ToID   <> '' THEN @cNewID ELSE ToID   END,
          FinalID  = CASE WHEN FinalID <> '' THEN @cNewID ELSE FinalID END,
          EditDate = GETDATE(),
          EditWho  = SUSER_SNAME(),
          TrafficCop = NULL
      WHERE TaskDetailKey = @cTaskDetailKey
   END TRY
   BEGIN CATCH
      SET @nErrNo = 277855
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdTaskFail
      GOTO RollBackTran
   END CATCH

   IF @@ROWCOUNT <> 1
   BEGIN
      SET @nErrNo = 277861
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdTaskFail
      GOTO RollBackTran
   END

   -- Transfer QTYReplen from original ID to the scanned (new) ID
   BEGIN TRY
      UPDATE dbo.LOTxLOCxID WITH (ROWLOCK) SET
          QTYReplen = @nTaskQTYReplen,
          EditDate  = GETDATE(),
          EditWho   = SUSER_SNAME(),
          TrafficCop = NULL
      WHERE StorerKey = @cStorerKey
         AND LOC = @cTaskLOC
         AND ID  = @cNewID
   END TRY
   BEGIN CATCH
      SET @nErrNo = 277856
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdLLIFail
      GOTO RollBackTran
   END CATCH

   -- Clear QTYReplen on the original ID (no longer being replenished)
   BEGIN TRY
      UPDATE dbo.LOTxLOCxID WITH (ROWLOCK) SET
          QTYReplen = 0,
          EditDate  = GETDATE(),
          EditWho   = SUSER_SNAME(),
          TrafficCop = NULL
      WHERE StorerKey = @cStorerKey
         AND LOC = @cTaskLOC
         AND ID  = @cTaskID
   END TRY
   BEGIN CATCH
      SET @nErrNo = 277857
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdLLIFail
      GOTO RollBackTran
   END CATCH

   -- Return same TaskDetailKey (ID swapped on the same task)
   SET @cNewTaskDetailKey = @cTaskDetailKey

   IF @nTranCount = 0
      COMMIT TRAN
   GOTO Quit

RollBackTran:
   IF @nTranCount > 0 AND XACT_STATE() <> -1
      ROLLBACK TRAN rdt_1764SwapID08
   ELSE IF @nTranCount = 0
      ROLLBACK TRAN

Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1764SwapID08 TO NSQL
GO
