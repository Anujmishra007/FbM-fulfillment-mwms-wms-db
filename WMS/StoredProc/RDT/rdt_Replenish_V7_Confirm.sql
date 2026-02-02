SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_Replenish_V7_Confirm                            */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date       Rev    Author     Purposes                                */
/* 25-03-2018 1.0    James      WMS-8254 Created                        */
/* 2022-08-23 1.1    Ung        WMS-20562 Add UCC                       */
/* 2025-03-17 1.2.0  JCH507     FCR-2728 Add customization SP entry     */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_Replenish_V7_Confirm] (
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR( 3)
   ,@nStep           INT
   ,@nInputKey       INT
   ,@cFacility       NVARCHAR( 5)
   ,@cStorerKey      NVARCHAR( 15)
   ,@cReplenBySKUQTY NVARCHAR( 1)
   ,@cMoveQTYAlloc   NVARCHAR( 1)
   ,@cReplenKey      NVARCHAR( 20)
   ,@cFromLOC        NVARCHAR( 20)
   ,@cFromID         NVARCHAR( 20)
   ,@cSKU            NVARCHAR( 20)
   ,@nActQTY         INT
   ,@cUCCNo          NVARCHAR( 20)
   ,@cToLOC          NVARCHAR( 10)
   ,@cToID           NVARCHAR( 18)
   ,@cLottableCode   NVARCHAR( 30) OUTPUT
   ,@cLottable01     NVARCHAR( 18) OUTPUT
   ,@cLottable02     NVARCHAR( 18) OUTPUT
   ,@cLottable03     NVARCHAR( 18) OUTPUT
   ,@dLottable04     DATETIME      OUTPUT
   ,@dLottable05     DATETIME      OUTPUT
   ,@cLottable06     NVARCHAR( 30) OUTPUT
   ,@cLottable07     NVARCHAR( 30) OUTPUT
   ,@cLottable08     NVARCHAR( 30) OUTPUT
   ,@cLottable09     NVARCHAR( 30) OUTPUT
   ,@cLottable10     NVARCHAR( 30) OUTPUT
   ,@cLottable11     NVARCHAR( 30) OUTPUT
   ,@cLottable12     NVARCHAR( 30) OUTPUT
   ,@dLottable13     DATETIME      OUTPUT
   ,@dLottable14     DATETIME      OUTPUT
   ,@dLottable15     DATETIME      OUTPUT
   ,@nErrNo          INT           OUTPUT
   ,@cErrMsg         NVARCHAR(250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cSQL           NVARCHAR(MAX)  
   DECLARE @cSQLParam      NVARCHAR(MAX)  
   DECLARE @cReplConfirmSP NVARCHAR(20)

   --V1.2.0 start
   -- Get storer configure  
   SET @cReplConfirmSP = rdt.RDTGetConfig( @nFunc, 'ReplConfirmSP', @cStorerKey)  
   IF @cReplConfirmSP = '0'  
      SET @cReplConfirmSP = ''  
  
   /***********************************************************************************************  
                                              Custom Replenishment confirm  
   ***********************************************************************************************/  
   -- Custom logic  
   IF @cReplConfirmSP <> ''  
   BEGIN  
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cReplConfirmSP AND type = 'P')  
      BEGIN  
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cReplConfirmSP) +  
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReplenBySKUQTY, @cMoveQTYAlloc, ' + 
            '@cReplenKey, @cFromLOC, @cFromID, @cSKU, @nActQTY, @cUCCNo, @cToLOC, @cToID, @cLottableCode, ' +
            '@cLottable01,   @cLottable02,   @cLottable03,   @dLottable04,   @dLottable05, ' +
            '@cLottable06,   @cLottable07,   @cLottable08,   @cLottable09,   @cLottable10, ' +
            '@cLottable11,   @cLottable12,   @dLottable13,   @dLottable14,   @dLottable15, ' +
            '@nErrNo OUTPUT, @cErrMsg OUTPUT '  
  
         SET @cSQLParam =  
            ' @nMobile           INT,           ' +   
            ' @nFunc             INT,           ' +   
            ' @cLangCode         NVARCHAR( 3),  ' +   
            ' @nStep             INT,           ' +   
            ' @nInputKey         INT,           ' +   
            ' @cFacility         NVARCHAR( 5),  ' +   
            ' @cStorerKey        NVARCHAR( 15), ' +     
            ' @cReplenBySKUQTY   NVARCHAR( 1),  ' +     
            ' @cMoveQtyAlloc     NVARCHAR( 1),  ' +   
            ' @cReplenKey        NVARCHAR( 10), ' +   
            ' @cFromLOC          NVARCHAR( 10), ' +
            ' @cFromID           NVARCHAR( 18), ' +
            ' @cSKU              NVARCHAR( 20), ' +
            ' @nActQTY           INT,           ' +
            ' @cUCCNo            NVARCHAR( 20), ' +
            ' @cToLOC            NVARCHAR( 10), ' +
            ' @cToID             NVARCHAR( 18), ' +
            ' @cLottableCode     NVARCHAR( 18), ' + 
            ' @cLottable01       NVARCHAR( 18), ' +
            ' @cLottable02       NVARCHAR( 18), ' +
            ' @cLottable03       NVARCHAR( 18), ' +
            ' @dLottable04       DATETIME,      ' +
            ' @dLottable05       DATETIME,      ' +
            ' @cLottable06       NVARCHAR( 30), ' +
            ' @cLottable07       NVARCHAR( 30), ' +
            ' @cLottable08       NVARCHAR( 30), ' +
            ' @cLottable09       NVARCHAR( 30), ' +
            ' @cLottable10       NVARCHAR( 30), ' +
            ' @cLottable11       NVARCHAR( 30), ' +
            ' @cLottable12       NVARCHAR( 30), ' +
            ' @dLottable13       DATETIME,      ' +
            ' @dLottable14       DATETIME,      ' +
            ' @dLottable15       DATETIME,      ' +
            ' @nErrNo            INT           OUTPUT, ' +   
            ' @cErrMsg           NVARCHAR(250) OUTPUT  '  
              
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
            @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReplenBySKUQTY, @cMoveQTYAlloc
            ,@cReplenKey, @cFromLOC, @cFromID, @cSKU, @nActQTY, @cUCCNo, @cToLOC, @cToID, @cLottableCode
            ,@cLottable01,   @cLottable02,   @cLottable03,   @dLottable04,   @dLottable05
            ,@cLottable06,   @cLottable07,   @cLottable08,   @cLottable09,   @cLottable10
            ,@cLottable11,   @cLottable12,   @dLottable13,   @dLottable14,   @dLottable15
            ,@nErrNo  OUTPUT
            ,@cErrMsg OUTPUT  
  
         GOTO Quit  
      END  
   END 
   --V1.2.0 end

   /**********************************************************************************  
                           Standard Replenishment confirm  
   ***********************************************************************************/ 

   DECLARE @nTranCount  INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_Replenish_V7_Confirm -- For rollback or commit only our own transaction

   IF @cReplenBySKUQTY = '1'
   BEGIN
      DECLARE @nQTY     INT
      DECLARE @nBal_QTY INT
      DECLARE @nRPL_QTY INT
      DECLARE @nAVL_QTY INT
      DECLARE @cLOT     NVARCHAR( 10)

      SET @nBal_QTY = @nActQTY

      DECLARE @curPD CURSOR
      SET @curPD = CURSOR FOR
         SELECT ReplenishmentKey, LOT, QTY
         FROM dbo.Replenishment WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND FromLOC = @cFromLOC
            AND ID = @cFromID
            AND SKU = @cSKU
            AND Confirmed = 'N'
      OPEN @curPD
      FETCH NEXT FROM @curPD INTO @cReplenKey, @cLOT, @nRPL_QTY
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- Get QTY avail
         SELECT @nAVL_QTY = ISNULL( SUM( QTY
            - CASE WHEN @cMoveQTYAlloc = '1' THEN 0 ELSE QTYAllocated END
            - QTYPicked), 0)
         FROM dbo.LOTxLOCxID WITH (NOLOCK)
         WHERE LOT = @cLOT
            AND LOC = @cFromLOC
            AND ID = @cFromID

         -- Make sure replen QTY not more then avail QTY
         IF @nRPL_QTY > @nAVL_QTY
            SET @nRPL_QTY = @nAVL_QTY

         -- Calc QTY to replen
         IF @nRPL_QTY > @nBal_QTY
            SET @nQTY = @nBal_QTY
         ELSE
            SET @nQTY = @nRPL_QTY

         UPDATE dbo.Replenishment WITH (ROWLOCK) SET
            QTY = @nQTY,
            ToLOC = @cToLOC,
            ToID = CASE WHEN @cToID <> '' THEN @cToID ELSE ToID END,
            Confirmed = 'Y'
         WHERE ReplenishmentKey = @cReplenKey
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 141551
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd RPL Fail
            GOTO RollBackTran
         END

         -- Reduce balance
         SET @nBal_QTY = @nBal_QTY - @nQTY
         IF @nBal_QTY <= 0
            BREAK

         FETCH NEXT FROM @curPD INTO @cReplenKey, @cLOT, @nRPL_QTY
      END

      -- Check offset error
      IF @nBal_QTY <> 0
      BEGIN
         SET @nErrNo = 141552
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Offset Error
         GOTO RollBackTran
      END
   END
   ELSE
   BEGIN
      UPDATE dbo.Replenishment WITH (ROWLOCK) SET
         QTY = @nActQTY,
         ToLOC = @cToLOC,
         ToID = CASE WHEN @cToID <> '' THEN @cToID ELSE ToID END,
         Confirmed = 'Y'
      WHERE ReplenishmentKey = @cReplenKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 141553
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd RPL Fail
         GOTO RollBackTran
      END
      
      IF @cUCCNo <> ''
      BEGIN
         DECLARE @cLoseID NVARCHAR(1)
         SELECT @cLoseID = LoseID FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cToLOC
         
         UPDATE dbo.UCC WITH (ROWLOCK) SET
            Status = '6',
            LOC = @cToLOC, 
            ID = CASE WHEN @cLoseID = '1' THEN '' ELSE @cToID END, 
            EditWho = SUSER_SNAME(),
            EditDate = GETDATE()
         WHERE StorerKey = @cStorerKey
            AND UCCNo = @cUCCNo
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 141554
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd UCC Fail
            GOTO RollBackTran
         END
      END
   END

   COMMIT TRAN rdt_Replenish_V7_Confirm
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_Replenish_V7_Confirm -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO
GRANT EXECUTE ON  [RDT].[rdt_Replenish_V7_Confirm] TO [NSQL]
GO
