SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_513Confirm02                                          */
/* Copyright      : LF Logistics                                              */
/*                                                                            */
/* Purpose: Move QTY, base on booking LOT                                     */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 2018-12-18   Ung       1.0   WMS-6467 Created                              */
/* 2019-07-31   Ung       1.1   WMS-9941 Add QTYPrinted                       */
/* 2021-06-01   James     1.2   WMS-17130 Ignore filter from id if it is not  */
/*                              key in. Deduct QTYPrinted (james01)           */
/*                              Add deduct pendingmovein                      */
/******************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_513Confirm02
    @nMobile         INT 
   ,@nFunc           INT 
   ,@cLangCode       NVARCHAR( 3) 
   ,@nStep           INT 
   ,@nInputKey       INT
   ,@cStorerKey      NVARCHAR( 15)
   ,@cFacility       NVARCHAR(  5)
   ,@cFromLOC        NVARCHAR( 10)
   ,@cFromID         NVARCHAR( 18)
   ,@cSKU            NVARCHAR( 20)
   ,@nQTY            INT
   ,@cToID           NVARCHAR( 18)
   ,@cToLOC          NVARCHAR( 10)
   ,@nErrNo          INT           OUTPUT 
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cPrePackIndicator NVARCHAR( 30)
   DECLARE @nPackQtyIndicator INT
   
   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT

   -- Move by SKU
   IF @nFunc = 513
   BEGIN
      IF @nStep = 6 -- ToLOC
      BEGIN
         IF @nInputKey = 1 -- Enter
         BEGIN
            DECLARE @cLOCCat NVARCHAR(10)
            SELECT @cLOCCat = LocationCategory FROM LOC WITH (NOLOCK) WHERE LOC = @cFromLOC

            SELECT 
               @cPrePackIndicator = PrePackIndicator,
               @nPackQtyIndicator = PackQtyIndicator 
            FROM dbo.SKU WITH (NOLOCK) 
            WHERE StorerKey = @cStorerKey 
            AND   SKU = @cSKU
            
            -- Receiving stage
            IF @cLOCCat = 'STAGING'
            BEGIN
            
               DECLARE @nQTY_Bal    INT
               DECLARE @nQTY_RF     INT
               DECLARE @nQTY_Move   INT
               DECLARE @cLOT        NVARCHAR(10)
               DECLARE @nRowRef     INT
               DECLARE @nRF_Qty     INT
               
               SET @nQTY_Bal = @nQTY

               BEGIN TRAN 
               SAVE TRAN rdt_513Confirm02

               -- Loop RFPutaway
               DECLARE @curRF CURSOR
               SET @curRF = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
                  SELECT RowRef, LOT, QTY
                  FROM dbo.RFPutaway WITH (NOLOCK)
                  WHERE FromLOC = @cFromLOC
                     AND (( ISNULL( @cFromID, '') = '') OR ( FromID = @cFromID))
                     AND StorerKey = @cStorerKey
                     AND SKU = @cSKU
                     AND SuggestedLOC = @cToLOC
                     AND QTYPrinted > 0
                     AND qty <> 0
                  ORDER BY RowRef
               OPEN @curRF
               FETCH NEXT FROM @curRF INTO @nRowRef, @cLOT, @nQTY_RF
               WHILE @@FETCH_STATUS = 0
               BEGIN
                  -- Calc QTY to move
                  IF @nQTY_RF >= @nQTY_Bal
                     SET @nQTY_Move = @nQTY_Bal
                  ELSE
                     SET @nQTY_Move = @nQTY_RF
               
                  EXECUTE rdt.rdt_Move
                     @nMobile     = @nMobile,
                     @cLangCode   = @cLangCode,
                     @nErrNo      = @nErrNo  OUTPUT,
                     @cErrMsg     = @cErrMsg OUTPUT, -- screen limitation, 20 NVARCHAR max
                     @cSourceType = 'rdt_513Confirm02',
                     @cStorerKey  = @cStorerKey,
                     @cFacility   = @cFacility,
                     @cFromLOC    = @cFromLOC,
                     @cToLOC      = @cToLOC,
                     @cFromID     = @cFromID,     -- NULL means not filter by ID. Blank is a valid ID
                     @cToID       = @cToID,       -- NULL means not changing ID. Blank consider a valid ID
                     @cSKU        = @cSKU,
                     @nQTY        = @nQTY_Move,
                     @cFromLOT    = @cLOT 
                  IF @nErrNo <> 0
                  BEGIN
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO RollBackTran
                  END

                  -- Deduct RFPutaway
                  IF @nQTY_Move = @nQTY_RF
                  BEGIN
                     DELETE dbo.RFPutaway WITH (ROWLOCK)
                     WHERE  RowRef = @nRowRef
                     IF @@ERROR <> 0
                        GOTO RollBackTran
                  END
                  ELSE
                  BEGIN
                  	/*Tracing purpose*/
                  	DECLARE @nOri_Qty INT, @nOri_QtyPrinted INT, @nAf_Qty INT, @nAf_QtyPrinted INT
                  	SELECT @nOri_Qty = Qty, @nOri_QtyPrinted = QTYPrinted
                  	FROM dbo.RFPUTAWAY WITH (NOLOCK)
                  	WHERE RowRef = @nRowRef
                  	
                     UPDATE dbo.RFPutaway SET 
                        QTY = QTY - @nQTY,
                        QTYPrinted = QTYPrinted - @nQTY
                     WHERE RowRef = @nRowRef

                     IF @@ERROR <> 0
                        GOTO RollBackTran

                     SELECT @nAf_Qty = Qty, @nAf_QtyPrinted = QTYPrinted
                  	FROM dbo.RFPUTAWAY WITH (NOLOCK)
                  	WHERE RowRef = @nRowRef
                  END

                  -- Reduce QTY
                  SET @nQTY_Bal = @nQTY_Bal - @nQTY_Move

                  -- Check exit point
                  IF @nQTY_Bal = 0
                     BREAK

                  FETCH NEXT FROM @curRF INTO @nRowRef, @cLOT, @nQTY_RF
               END
               
               -- Check fully offset
               IF @nQTY_Bal <> 0
               BEGIN
                  SET @nErrNo = 133251
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoBookingQTY
                  GOTO RollBackTran
               END

               -- Booking (RFPutaway) qty empty only need clear 
               IF EXISTS ( SELECT 1
                           FROM dbo.RFPutaway WITH (NOLOCK)
                           WHERE FromLOC = @cFromLOC
                           AND  (( ISNULL( @cFromID, '') = '') OR ( FromID = @cFromID))
                           AND   StorerKey = @cStorerKey
                           AND   SKU = @cSKU
                           AND   SuggestedLOC = @cToLOC)
               BEGIN
                  SELECT @nRF_Qty = ISNULL( SUM( QTY), 0)
                  FROM dbo.RFPutaway WITH (NOLOCK)
                  WHERE FromLOC = @cFromLOC
                  AND  (( ISNULL( @cFromID, '') = '') OR ( FromID = @cFromID))
                  AND   StorerKey = @cStorerKey
                  AND   SKU = @cSKU
                  AND   SuggestedLOC = @cToLOC

                  IF @nRF_Qty = 0
                  BEGIN
                     -- Unlock  suggested location
                     EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
                        ,@cFromLOC      --@cFromLOC
                        ,@cFromID--@cFromID
                        ,@cToLOC --@cSuggestedLOC
                        ,''      --@cStorerKey
                        ,@nErrNo  OUTPUT
                        ,@cErrMsg OUTPUT
                     IF @nErrNo <> 0
                     BEGIN
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                        GOTO RollBackTran
                     END
                  END
               END
               
               COMMIT TRAN rdt_513Confirm02
            END
            
            ELSE
            BEGIN
               BEGIN TRAN 
               SAVE TRAN rdt_513Confirm02

               EXECUTE rdt.rdt_Move
                  @nMobile     = @nMobile,
                  @cLangCode   = @cLangCode,
                  @nErrNo      = @nErrNo  OUTPUT,
                  @cErrMsg     = @cErrMsg OUTPUT, -- screen limitation, 20 NVARCHAR max
                  @cSourceType = 'rdt_513Confirm02',
                  @cStorerKey  = @cStorerKey,
                  @cFacility   = @cFacility,
                  @cFromLOC    = @cFromLOC,
                  @cToLOC      = @cToLOC,
                  @cFromID     = @cFromID,     -- NULL means not filter by ID. Blank is a valid ID
                  @cToID       = @cToID,       -- NULL means not changing ID. Blank consider a valid ID
                  @cSKU        = @cSKU,
                  @nQTY        = @nQTY
               IF @nErrNo <> 0
               BEGIN
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran
               END

               -- Unlock  suggested location
               EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
                  ,@cFromLOC      --@cFromLOC
                  ,@cFromID--@cFromID
                  ,@cToLOC --@cSuggestedLOC
                  ,''      --@cStorerKey
                  ,@nErrNo  OUTPUT
                  ,@cErrMsg OUTPUT
               IF @nErrNo <> 0
               BEGIN
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran
               END
            
               COMMIT TRAN rdt_513Confirm02
            END
         END
      END
   END
   
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_513Confirm02 -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_513Confirm02 TO NSQL
GO
