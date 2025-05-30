SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_PutawayUCC_Allocated                            */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose: Putaway                                                     */
/*                                                                      */
/*                                                                      */
/* Exceed version: 5.4                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2025-03-14 1.0.0  Dennis   FCR-3449 Created                          */
/* 2025-05-28 1.1.0  Dennis   UWP-35136 Fix Bug                         */
/* 2025-03-14 1.2.0  Dennis   UWP-35136 Fix Bugs (de01)                 */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_PutawayUCC_Allocated (
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
   @nErrNo      INT          OUTPUT,
   @cErrMsg     NVARCHAR( 20) OUTPUT  -- screen limitation, 20 char max
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
   DECLARE @nPA_ALLOC_QTY   INT
   DECLARE @cPackKey  NVARCHAR( 10)
   DECLARE @cPackUOM3 NVARCHAR( 10)
   DECLARE @cOrderKey NVARCHAR( 10)
   DECLARE @nQTY INT
   
   -- Get PackKey, UOM
   SELECT @cPackKey = PackKey FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU
   SELECT @cPackUOM3 = PackUOM3 FROM Pack WITH (NOLOCK) WHERE PackKey = @cPackKey
   SELECT @cOrderKey = OrderKey FROM dbo.UCC WITH (NOLOCK) WHERE UCCNo=@cUCC AND StorerKey = @cStorerKey AND SKU = @cSKU

   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_PutawayUCC_Allocated -- For rollback or commit only our own transaction

   DECLARE @curPutaway CURSOR 
   SET @curPutaway = CURSOR FOR
      SELECT 
         StorerKey, SKU, LOT, 
         (QTY - QTYPicked - (CASE WHEN QTYReplen < 0 THEN 0 ELSE QTYReplen END)),
         QTYAllocated
      FROM dbo.LOTxLOCxID WITH (NOLOCK)
      WHERE StorerKey = CASE WHEN @cStorerKey = '' THEN StorerKey ELSE @cStorerKey END
         AND SKU = CASE WHEN @cSKU = '' THEN SKU ELSE @cSKU END
         AND LOT = CASE WHEN @cLOT = '' THEN LOT ELSE @cLOT END
         AND LOC = @cLOC
         AND ID  = @cID
         AND (QTY - QTYPicked - (CASE WHEN QTYReplen < 0 THEN 0 ELSE QTYReplen END)) > 0
      ORDER BY LOT

   OPEN @curPutaway
   FETCH NEXT FROM @curPutaway INTO @cPA_StorerKey, @cPA_SKU, @cPA_LOT, @nPA_QTY,@nPA_ALLOC_QTY

   SET @nQTY = @nPutawayQTY
   WHILE @@FETCH_STATUS = 0
   BEGIN
      IF @nQTY < @nPA_QTY
         SET @nPA_QTY = @nQTY

      EXEC rdt.rdt_Move
         @nFunc       = @nFunc,
         @nMobile     = @nMobile,
         @cLangCode   = @cLangCode, 
         @nErrNo      = @nErrNo  OUTPUT,
         @cErrMsg     = @cErrMsg OUTPUT, -- screen limitation, 20 char max
         @cSourceType = 'rdt_PutawayUCC_Allocated', 
         @cStorerKey  = @cStorerKey,
         @cFacility   = @cFacility, 
         @cFromLOC    = @cLOC, 
         @cToLOC      = @cFinalLOC, 
         @cFromID     = @cID,       -- NULL means not filter by ID. Blank is a valid ID
         @cToID       = @cID,       -- NULL means not changing ID. Blank consider a valid ID
         --@cSKU      = @cPA_SKU, --(de01)
         @cUCC        = @cUCC, --(de01)
         @nQTY        = @nPA_QTY, 
         @cFromLOT    = @cPA_LOT,
         @nQTYAlloc   = @nPA_ALLOC_QTY
         --@cOrderKey   = @cOrderKey --(de01)

      IF @nErrNo <> 0
         GOTO RollBackTran

      SET @nQTY = @nQTY - @nPA_QTY
      IF @nQTY = 0
         BREAK
         
      FETCH NEXT FROM @curPutaway INTO @cPA_StorerKey, @cPA_SKU, @cPA_LOT, @nPA_QTY,@nPA_ALLOC_QTY
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
         AND (Status = '1' OR Status = '3')
         
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
            AND (Status = '1' OR Status = '3')
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

         BEGIN
            -- Insert putaway QTY
            INSERT INTO dbo.UCC (
               UCCNo, Storerkey, ExternKey, SKU, Sourcekey, Sourcetype, Userdefined01, Userdefined02, Userdefined03, Lot, Receiptkey, ReceiptLineNumber, Orderkey, OrderLineNumber, WaveKey, PickDetailKey, Userdefined04, Userdefined05, Userdefined06, Userdefined07, Userdefined08, Userdefined09, Userdefined10, 
               ID, LOC, QTY, EditWho, EditDate, Status)
            SELECT 
               UCCNo, Storerkey, ExternKey, SKU, Sourcekey, Sourcetype, Userdefined01, Userdefined02, Userdefined03, Lot, Receiptkey, ReceiptLineNumber, Orderkey, OrderLineNumber, WaveKey, PickDetailKey, Userdefined04, Userdefined05, Userdefined06, Userdefined07, Userdefined08, Userdefined09, Userdefined10, 
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
               AND (Status = '1' OR Status = '3')
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
               AND (Status = '1' OR Status = '3')
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 73904
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD UCC Fail
               GOTO RollBackTran
            END
         END
      END
   END

   COMMIT TRAN rdt_PutawayUCC_Allocated -- Only commit change made here
   
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
   ROLLBACK TRAN rdt_PutawayUCC_Allocated -- Only rollback change made here
Fail:
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_PutawayUCC_Allocated TO NSQL
GO
