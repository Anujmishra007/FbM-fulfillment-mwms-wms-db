
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_Putaway                                         */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose: Putaway                                                     */
/*                                                                      */
/* Called from: 3                                                       */
/*    1. From PowerBuilder                                              */
/*    2. From scheduler                                                 */
/*    3. From others stored procedures or triggers                      */
/*    4. From interface program. DX, DTS                                */
/*                                                                      */
/* Exceed version: 5.4                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2011-09-06 1.0  Ung      Created                                     */
/* 2012-11-21 1.1  Ung      SOS257047 Add Multi SKU UCC and LOC.LoseUCC */
/* 2014-02-10 1.2  Ung      Fix split UCC multiple times                */
/* 2019-10-08 1.3  Chermain WMS-10753 Change Eventlog Col from          */
/*                          @cRefNo3 to @cucc (cc01)                    */
/* 2023-11-20 1.4  Ung      WMS-23730 Add Final ID                      */
/* 2025-11-23 1.5  Ung      FCR-8111 Add serial no                      */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_Putaway (
   @nMobile     INT,
   @nFunc       INT, 
   @cLangCode   NVARCHAR( 3), 
   @cUserName   NVARCHAR( 10), 
   @cFacility   NVARCHAR( 5), 
   @cLOT        NVARCHAR( 10), -- optional
   @cLOC        NVARCHAR( 10), 
   @cID         NVARCHAR( 18), 
   @cStorerKey  NVARCHAR( 15), -- optional
   @cSKU        NVARCHAR( 20), -- optional
   @nPutawayQTY INT, 
   @cFinalLOC   NVARCHAR( 10), 
   @cLabelType  NVARCHAR( 20) = '', 
   @cUCC		    NVARCHAR( 20) = '',
   @nErrNo      INT           OUTPUT,
   @cErrMsg     NVARCHAR( 20) OUTPUT,
   @cFinalID    NVARCHAR( 18) = NULL, 
   @cSerialNo   NVARCHAR( 30) = '',   -- For move with SerialNoUpdateLotLocID
   @nSerialQTY  INT = 0,              -- Same as above
   @nBulkSNO    INT = 0,              -- Same as above. Use rdt.rdtMoveSerialNoLog table
   @nBulkSNOQTY INT = 0               -- Same as above
) AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Success INT
   DECLARE @c_outstring NVARCHAR( 255)

   DECLARE @cPA_StorerKey NVARCHAR( 15)
   DECLARE @cPA_SKU   NVARCHAR( 20)
   DECLARE @cPA_LOT   NVARCHAR( 10)
   DECLARE @nPA_QTY   INT
   DECLARE @cPackKey  NVARCHAR( 10)
   DECLARE @cPackUOM3 NVARCHAR( 10)
   DECLARE @nQTY INT
   
   -- Get PackKey, UOM
   SELECT @cPackKey = PackKey FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU
   SELECT @cPackUOM3 = PackUOM3 FROM Pack WITH (NOLOCK) WHERE PackKey = @cPackKey
   
   -- TO ID
   IF @cFinalID IS NULL
      SET @cFinalID = @cID
   
   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_Putaway -- For rollback or commit only our own transaction

   DECLARE @curPutaway CURSOR 
   SET @curPutaway = CURSOR FOR
      SELECT 
         StorerKey, SKU, LOT, 
         (QTY - QTYAllocated - QTYPicked - (CASE WHEN QTYReplen < 0 THEN 0 ELSE QTYReplen END))
      FROM dbo.LOTxLOCxID WITH (NOLOCK)
      WHERE StorerKey = CASE WHEN @cStorerKey = '' THEN StorerKey ELSE @cStorerKey END
         AND SKU = CASE WHEN @cSKU = '' THEN SKU ELSE @cSKU END
         AND LOT = CASE WHEN @cLOT = '' THEN LOT ELSE @cLOT END
         AND LOC = @cLOC
         AND ID  = @cID
         AND (QTY - QTYAllocated - QTYPicked - (CASE WHEN QTYReplen < 0 THEN 0 ELSE QTYReplen END)) > 0
      ORDER BY LOT

   OPEN @curPutaway
   FETCH NEXT FROM @curPutaway INTO @cPA_StorerKey, @cPA_SKU, @cPA_LOT, @nPA_QTY

   SET @nQTY = @nPutawayQTY
   WHILE @@FETCH_STATUS = 0
   BEGIN
      IF @nQTY < @nPA_QTY
         SET @nPA_QTY = @nQTY
      
      EXEC rdt.rdt_Move
         @nMobile     = @nMobile,
         @cLangCode   = @cLangCode, 
         @nErrNo      = @nErrNo  OUTPUT,
         @cErrMsg     = @cErrMsg OUTPUT, -- screen limitation, 20 char max
         @cSourceType = 'rdt_Putaway', 
         @cStorerKey  = @cStorerKey,
         @cFacility   = @cFacility, 
         @cFromLOC    = @cLOC, 
         @cToLOC      = @cFinalLOC, 
         @cFromID     = @cID,       -- NULL means not filter by ID. Blank is a valid ID
         @cToID       = @cFinalID,  -- NULL means not changing ID. Blank consider a valid ID
         @cSKU        = @cPA_SKU, 
         @nQTY        = @nPA_QTY, 
         @cFromLOT    = @cPA_LOT, 
         @nFunc       = @nFunc, 
         @cSerialNo   = @cSerialNo, 
         @nSerialQTY  = @nSerialQTY, 
         @nBulkSNO    = @nBulkSNO, 
         @nBulkSNOQTY = @nBulkSNOQTY

      IF @nErrNo <> 0
         GOTO RollBackTran

      SET @nQTY = @nQTY - @nPA_QTY
      IF @nQTY = 0
         BREAK
         
      FETCH NEXT FROM @curPutaway INTO @cPA_StorerKey, @cPA_SKU, @cPA_LOT, @nPA_QTY
   END
   CLOSE @curPutaway
   DEALLOCATE @curPutaway

   -- Update UCC
   IF @cLabelType = 'UCC' OR @cUCC <> ''
   BEGIN
      DECLARE @cLoseID NVARCHAR( 1)
      DECLARE @cLoseUCC NVARCHAR( 1)
      DECLARE @nUCCQTY INT
      
      -- Get LOC info
      SELECT 
         @cLoseID = LoseID, 
         @cLoseUCC = LoseUCC
      FROM LOC WITH (NOLOCK) 
      WHERE LOC = @cFinalLOC

      -- Get UCC info
      SELECT @nUCCQTY = QTY
      FROM dbo.UCC WITH (NOLOCK)
      WHERE UCCNo = @cUCC 
         AND StorerKey = @cStorerKey
         AND SKU = @cSKU
         AND Status = '1'
         
      -- Update UCC 
      IF @nPutawayQTY = @nUCCQTY
      BEGIN
         UPDATE UCC WITH (ROWLOCK) SET 
            ID = CASE WHEN @cLoseID = '1' THEN '' ELSE ID END, 
            LOC = @cFinalLOC, 
            EditWho  = sUser_sName(),  
            EditDate = GETDATE(), 
            Status = CASE WHEN @cLoseUCC = '1' THEN '6' ELSE Status END
         WHERE UCCNo = @cUCC 
            AND StorerKey = @cStorerKey
            AND SKU = @cSKU
            AND Status = '1'
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 73901
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD UCC Fail
            GOTO RollBackTran
         END
      END
      ELSE
      -- Split UCC record
      BEGIN
/*         
         IF EXISTS( SELECT 1 
            FROM dbo.UCC WITH (NOLOCK) 
            WHERE UCCNo = @cUCC
               AND StorerKey = @cStorerKey
               AND SKU = @cSKU
               AND Status = '6')
         BEGIN
            UPDATE dbo.UCC SET
               QTY = QTY + @nPutawayQTY
            WHERE UCCNo = @cUCC
               AND StorerKey = @cStorerKey
               AND SKU = @cSKU
               AND Status = '6'
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 73902
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD UCC Fail
               GOTO RollBackTran
            END
         END
         ELSE
*/
         BEGIN
            -- Insert putaway QTY
            INSERT INTO dbo.UCC (
               UCCNo, Storerkey, ExternKey, SKU, Sourcekey, Sourcetype, Userdefined01, Userdefined02, Userdefined03, Lot, Receiptkey, ReceiptLineNumber, Orderkey, OrderLineNumber, WaveKey, PickDetailKey, 
               Userdefined04, Userdefined05, Userdefined06, Userdefined07, Userdefined08, Userdefined09, Userdefined10, 
               ID, LOC, QTY, EditWho, EditDate, Status)
            SELECT 
               UCCNo, Storerkey, ExternKey, SKU, Sourcekey, Sourcetype, Userdefined01, Userdefined02, Userdefined03, Lot, Receiptkey, ReceiptLineNumber, Orderkey, OrderLineNumber, WaveKey, PickDetailKey, 
               Userdefined04, Userdefined05, Userdefined06, Userdefined07, Userdefined08, Userdefined09, Userdefined10, 
               CASE WHEN @cLoseID = '1' THEN '' ELSE ID END, --ID
               @cFinalLOC,    --LOC
               @nPutawayQTY,  --QTY 
               sUser_sName(), --EditWho
               GETDATE(),     --EditDate
               '6'            --Status
            FROM dbo.UCC WITH (NOLOCK)
            WHERE UCCNo = @cUCC
               AND StorerKey = @cStorerKey
               AND SKU = @cSKU
               AND Status = '1'
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 73903
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- INS UCC Fail
               GOTO RollBackTran
            END

            -- Update remaining QTY
            UPDATE UCC WITH (ROWLOCK) SET 
               QTY = @nUCCQTY - @nPutawayQTY, 
               EditWho  = sUser_sName(),  
               EditDate = GETDATE()
            WHERE UCCNo = @cUCC 
               AND StorerKey = @cStorerKey
               AND SKU = @cSKU
               AND Status = '1'
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 73904
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD UCC Fail
               GOTO RollBackTran
            END
         END
      END
   END

   COMMIT TRAN rdt_Putaway -- Only commit change made here
   
   EXEC RDT.rdt_STD_EventLog
      @cActionType   = '4', -- Putaway
      @cUserID       = @cUserName,
      @nMobileNo     = @nMobile,
      @nFunctionID   = @nFunc,
      @cFacility     = @cFacility,
      @cStorerKey    = @cStorerKey,
      @cLocation     = @cLOC,
      @cToLocation   = @cFinalLOC,
      @cID           = @cID,
      @cToID         = @cID,
      @cSKU          = @cSKU,
      @cUOM          = @cPackUOM3,
      @nQTY          = @nPutawayQTY,
      @cLOT          = @cLOT, 
      @cUCC          = @cUCC     --(cc01)
      
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_Putaway -- Only rollback change made here
Fail:
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_Putaway TO NSQL
GO
