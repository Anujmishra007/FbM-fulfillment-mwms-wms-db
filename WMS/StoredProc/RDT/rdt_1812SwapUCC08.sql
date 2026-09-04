SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_1812SwapUCC08                                         */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: Swap UCC for BNT SA - FCR-15553 UCC Enable                        */
/*                                                                            */
/* Date        Rev    Author     Purposes                                     */
/* 2026-09-03  1.0    JCH507     FCR-15553 Created                            */
/*                                                                            */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1812SwapUCC08]
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

   DECLARE @nDebugFlag     INT = 0

   DECLARE @nTranCount     INT
   DECLARE @nRowCount      INT

   DECLARE @cStorerKey     NVARCHAR( 15)
   DECLARE @cTaskSKU       NVARCHAR( 20)
   DECLARE @cTaskCaseID    NVARCHAR( 20)
   DECLARE @cTaskUOM       NVARCHAR(  5)
   DECLARE @cTaskFromLOC   NVARCHAR( 10)
   DECLARE @cTaskFromID    NVARCHAR( 18)
   DECLARE @nTaskQTY       INT

   DECLARE @cScannedUCC       NVARCHAR( 20)
   DECLARE @cScannedSKU       NVARCHAR( 20)
   DECLARE @cScannedLot       NVARCHAR( 10)
   DECLARE @cScannedLoc       NVARCHAR( 10)
   DECLARE @cScannedId        NVARCHAR( 18)
   DECLARE @cScannedStatus    NVARCHAR(  1)
   DECLARE @nScannedQTY       INT

   DECLARE @cTaskCaseIDStatus NVARCHAR(  1)
   DECLARE @cMsg1             NVARCHAR( 60)
   DECLARE @cMsg2             NVARCHAR( 60)

   DECLARE @tTaskPD TABLE
   (
      PickDetailKey NVARCHAR( 10) NOT NULL,
      PRIMARY KEY CLUSTERED (PickDetailKey)
   )

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_1812SwapUCC08', @cTaskdetailKey AS Task, @cBarcode AS Barcode

   SET @nTranCount = @@TRANCOUNT

   -- Step 1: Read task detail
   SELECT
      @cStorerKey   = StorerKey,
      @cTaskSKU     = Sku,
      @cTaskCaseID  = Caseid,
      @cTaskUOM     = UOM,
      @cTaskFromLOC = FromLoc,
      @cTaskFromID  = FromID,
      @nTaskQTY     = Qty
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE TaskDetailKey = @cTaskdetailKey

   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo  = 279951
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --BadTaskDtlKey
      GOTO Fail
   END

   -- Step 2: Activation guard — only process when CaseID set and UOM = '2'
   IF ISNULL(@cTaskCaseID, '') = '' OR ISNULL(@cTaskUOM, '') <> '2'
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Not UCC picking mode, return'

      SET @nUCCQTY = 0
      SET @cUCC    = ''
      GOTO Quit
   END

   SET @cScannedUCC = LEFT(@cBarcode, 20)

   -- Step 3: Same UCC scanned — no swap needed
   IF @cScannedUCC = @cTaskCaseID
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Same as task UCC, no swapping required'

      SET @cSKU    = @cTaskSKU
      SET @cUCC    = @cScannedUCC
      SET @nUCCQTY = @nTaskQTY
      GOTO Quit
   END

   IF @nDebugFlag = 1
      SELECT 'Validating scanned UCC', @cScannedUCC

   -- Step 4: Look up scanned barcode in dbo.UCC
   SELECT @nRowCount = COUNT(1)
   FROM dbo.UCC WITH (NOLOCK)
   WHERE UCCNo = @cScannedUCC
      AND StorerKey = @cStorerKey

   IF @nRowCount = 0
   BEGIN
      SET @nErrNo  = 279952
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --InvalidUCC
      GOTO Fail
   END

   SELECT @cTaskCaseIDStatus = Status
   FROM dbo.UCC WITH (NOLOCK)
   WHERE UCCNo      = @cTaskCaseID
      AND StorerKey = @cStorerKey

   SET @nRowCount = @@ROWCOUNT

   IF @nRowCount = 0
   BEGIN
      SET @nErrNo  = 279964
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --TaskUCC not found
      GOTO Fail
   END

   IF ISNULL(@cTaskCaseIDStatus, '') = ''
   BEGIN
      SET @nErrNo  = 279965
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --InvalidUCCStatus
      GOTO Fail
   END

   SELECT
      @cScannedStatus = Status,
      @cScannedSKU    = SKU,
      @cScannedLot    = Lot,
      @nScannedQTY    = qty,
      @cScannedLoc    = Loc,
      @cScannedId     = Id
   FROM dbo.UCC WITH (NOLOCK)
   WHERE UCCNo = @cScannedUCC
      AND StorerKey = @cStorerKey

   -- Step 5: Swap validation
   IF @cScannedStatus <> '1'
   BEGIN
      SET @nErrNo  = 279953
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --CannotSwapUCC
      GOTO Fail
   END

   IF @cScannedSKU <> @cTaskSKU
   BEGIN
      SET @nErrNo  = 279954
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --SKUMismatch
      GOTO Fail
   END

   IF @nScannedQTY <> @nTaskQTY
   BEGIN
      SET @nErrNo  = 279955
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --QTYMismatch
      GOTO Fail
   END

   IF @cScannedLoc <> @cTaskFromLOC
   BEGIN
      SET @nErrNo  = 279956
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --LOCMismatch
      GOTO Fail
   END

   IF ISNULL(@cScannedId, '') <> ISNULL(@cTaskFromID, '')
   BEGIN
      SET @nErrNo  = 279957
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --IDMismatch
      GOTO Fail
   END

   -- Step 6: Collect all PickDetail rows for this task
   BEGIN TRY
      INSERT INTO @tTaskPD (PickDetailKey)
      SELECT PickDetailKey
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND TaskDetailKey = @cTaskdetailKey
         AND Qty > 0
         AND Status = '0'
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 279963
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --CollectTaskPD Fail
      GOTO Fail
   END CATCH

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Task PickDetail rows collected'
      SELECT * FROM @tTaskPD
   END

   /*------------------------------------------------------------------------
                              Swap UCC Logic
   ------------------------------------------------------------------------*/
   IF @nDebugFlag = 1
      SELECT 'Start swap UCC', @cTaskCaseID AS TaskUCC, @cScannedUCC AS NewUCC

   BEGIN TRAN
   SAVE TRAN rdt_1812SwapUCC08

   -- DML 1: Restore original UCC status to Available ('1')
   BEGIN TRY
      UPDATE dbo.UCC WITH (ROWLOCK) SET
         Status   = '1',
         EditDate = GETDATE(),
         EditWho  = SUSER_SNAME()
      WHERE UCCNo     = @cTaskCaseID
         AND StorerKey = @cStorerKey
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 279958
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --UpdOrigUCC Fail
      GOTO RollBackTran
   END CATCH

   -- DML 2: Mark scanned UCC as Allocated ('3')
   BEGIN TRY
      UPDATE dbo.UCC WITH (ROWLOCK) SET
         Status   = '3',
         EditDate = GETDATE(),
         EditWho  = SUSER_SNAME()
      WHERE UCCNo      = @cScannedUCC
         AND StorerKey = @cStorerKey
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 279959
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --UpdNewUCC Fail
      GOTO RollBackTran
   END CATCH

   -- DML 3: Update TaskDetail — new CaseID + conditional LOT replacement
   BEGIN TRY
      UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
         Caseid   = @cScannedUCC,
         Lot      = @cScannedLot,
         TrafficCop = NULL,
         EditDate = GETDATE(),
         EditWho  = SUSER_SNAME()
      WHERE TaskDetailKey = @cTaskdetailKey
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 279960
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --UpdTaskDtl Fail
      GOTO RollBackTran
   END CATCH

   -- DML 4: Update all PickDetail rows — new CaseID + LOT (via table variable JOIN)
   IF EXISTS (SELECT 1 FROM @tTaskPD)
   BEGIN
      BEGIN TRY
         UPDATE PKD WITH (ROWLOCK) SET
            DropID   = @cScannedUCC,
            Lot      = @cScannedLot,
            EditDate = GETDATE(),
            EditWho  = SUSER_SNAME()
         FROM dbo.PickDetail PKD
         JOIN @tTaskPD t ON PKD.PickDetailKey = t.PickDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo  = 279961
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --UpdPickDtl Fail
         GOTO RollBackTran
      END CATCH
   END

   -- Audit: record swap in rdt.SwapUCC (non-fatal on failure)
   -- @cTaskCaseIDStatus was captured before DML1 — reflects pre-swap status
   IF @cScannedUCC <> @cTaskCaseID
   BEGIN
      BEGIN TRY
         INSERT INTO rdt.SwapUCC (Func, UCC, NewUCC, ReplenGroup, UCCStatus, NewUCCStatus)
         VALUES (1812, @cTaskCaseID, @cScannedUCC, @cTaskdetailKey, @cTaskCaseIDStatus, @cScannedStatus)
      END TRY
      BEGIN CATCH
         SET @cMsg1 = TRY_CAST(279962 AS NVARCHAR(6))
         SET @cMsg2 = rdt.rdtgetmessage(279962, @cLangCode, 'DSP')
         EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cMsg1, @cMsg2
      END CATCH
   END

   SET @cSKU    = @cTaskSKU
   SET @cUCC    = @cScannedUCC
   SET @nUCCQTY = @nScannedQTY

   COMMIT TRAN rdt_1812SwapUCC08
   GOTO Quit

RollBackTran:
   IF @nTranCount > 0 AND XACT_STATE() = 1
      ROLLBACK TRAN rdt_1812SwapUCC08
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

GRANT EXECUTE ON [RDT].[rdt_1812SwapUCC08] TO [NSQL]
GO
