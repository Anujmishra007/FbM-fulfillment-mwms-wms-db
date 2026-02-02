SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure:   rdt_896ReplCfmSP01                                */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Puma CHL                                                    */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2025-03-17 1.0.0  JCH507   FCR-3287 Created                          */
/* 2025-08-27 1.1.0  JCH507   UWP-40178 Check replen finalization result*/
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_896ReplCfmSP01] (
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

   DECLARE @bDebugFlag  BINARY = 0
   DECLARE @cLoseID     NVARCHAR( 1)
   DECLARE @curPD       CURSOR
   DECLARE @cPickDetailKey    NVARCHAR( 10)
   DECLARE @nQTY       INT

   DECLARE @tPD TABLE
   (
      PickDetailKey NVARCHAR( 10) NOT NULL,
      LOT           NVARCHAR( 10) NOT NULL,
      QTY           INT           NOT NULL
      PRIMARY KEY CLUSTERED (PickDetailKey)
   )

   IF @bDebugFlag = 1
   SELECT 'Runing rdt_896ReplCfmSP01'

   SELECT @cLoseID = LoseID FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cToLOC

   IF @cLoseID = '1' AND @cToID <> ''
   BEGIN
      SET @nErrNo = 235156
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ToLoc is the loose ID location
      GOTO Quit
   END

   --V1.1
   IF @cLoseID = '0' AND ISNULL(@cToID,'') = ''
   BEGIN
      SET @nErrNo = 235159
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ToID is required
      GOTO Quit
   END 

   IF @cUCCNo = ''
   BEGIN
      SET @nErrNo = 235152
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCCNo is empty
      GOTO RollBackTran
   END

   DECLARE @nTranCount  INT
   SET @nTranCount = @@TRANCOUNT

   IF @nTranCount = 0
      BEGIN TRAN  -- Begin our own transaction
   ELSE
      SAVE TRAN rdt_896ReplCfmSP01 -- For rollback or commit only our own transaction

   IF @cReplenBySKUQTY = '1'
   BEGIN
      --v1.0.0 start
      IF @bDebugFlag = 1
         SELECT 'Replenish by SKU QTY'

      SET @nErrNo = 235151
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Turn off RePlenBYSKUQTY Config
      GOTO RollBackTran 
      --v1.0.0 end  
   END --RplbySKUQTY = 1
   ELSE
   BEGIN
      IF @bDebugFlag = 1
         SELECT 'Replenish by ReplenKey'

      INSERT INTO @tPD (PickDetailKey, LOT, QTY)
      SELECT PD.PickDetailKey, PD.LOT, PD.QTY
      FROM dbo.PickDetail PD WITH (NOLOCK)
         JOIN UCC WITH (NOLOCK) ON (UCC.UCCNo = PD.DropID)
      WHERE UCC.StorerKey = @cStorerkey
         AND PD.StorerKey = @cStorerkey
         AND UCC.UCCNo = @cUCCNo
         AND PD.Status = '0'
         AND PD.QTY > 0
      
      IF @bDebugFlag = 1
      BEGIN
         SELECT 'Create temp pickdetail'
         SELECT * FROM @tPD
      END

      --Unallocate the pickdetail before change the Loc, ID
      -- Unallocate (task)
      SET @curPD = CURSOR FOR
         SELECT PickDetailKey FROM @tPD ORDER BY PickDetailKey
      OPEN @curPD
      FETCH NEXT FROM @curPD INTO @cPickDetailKey
      WHILE @@FETCH_STATUS = 0
      BEGIN
         BEGIN TRY
            UPDATE dbo.PickDetail WITH (ROWLOCK)
            SET
               QTY = 0,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME()
            WHERE PickDetailKey = @cPickDetailKey
         END TRY
         BEGIN CATCH
            IF @bDebugFlag = 1
               SELECT  '235157 Error info', ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage

            SET @nErrNo = 235157
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
            GOTO RollBackTran
         END CATCH

         FETCH NEXT FROM @curPD INTO @cPickDetailKey
      END     

      BEGIN TRY
         UPDATE dbo.Replenishment WITH (ROWLOCK) SET
            QTY = @nActQTY,
            ToLOC = @cToLOC,
            ToID = CASE WHEN @cToID <> '' THEN @cToID ELSE '' END,
            Confirmed = 'Y'
         WHERE ReplenishmentKey = @cReplenKey
      END TRY
      BEGIN CATCH
         IF @bDebugFlag = 1
            SELECT  '235153 Error info', ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage

         SET @nErrNo = 235153
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd RPL Fail
         GOTO RollBackTran
      END CATCH

      --V1.1.0
      IF NOT EXISTS (SELECT 1 FROM dbo.ITRN WITH (NOLOCK) WHERE SourceKey = @cReplenKey)
      BEGIN
         SET @nErrNo = 235158
         SET @cErrMsg = 'Finalize Replen ' + @cReplenKey + ' fails'
         GOTO RollBackTran
      END
      
      IF @cUCCNo <> ''
      BEGIN
         --DECLARE @cLoseID NVARCHAR(1) --V1.0.0
         --SELECT @cLoseID = LoseID FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cToLOC --V1.0.0
         
         BEGIN TRY
            UPDATE dbo.UCC WITH (ROWLOCK) SET
               Status = '3', --v1.0.0
               LOC = @cToLOC, 
               ID = CASE WHEN @cToID <> '' THEN @cToID ELSE '' END,
               EditWho = SUSER_SNAME(),
               EditDate = GETDATE()
            WHERE StorerKey = @cStorerKey
               AND UCCNo = @cUCCNo
         END TRY
         BEGIN CATCH
            IF @bDebugFlag = 1
               SELECT  '235154 Error info', ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage

            SET @nErrNo = 235154
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd UCC Fail
            GOTO RollBackTran
         END CATCH
      END

      --reallocate task after inventory moved
      SET @curPD = CURSOR FOR
      SELECT PickDetailKey, QTY FROM @tPD ORDER BY PickDetailKey
      OPEN @curPD
      FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY
      WHILE @@FETCH_STATUS = 0
      BEGIN
         BEGIN TRY
            UPDATE dbo.PickDetail WITH (ROWLOCK)
            SET
               Loc = @cToLOC,
               ID = CASE WHEN @cToID <> '' THEN @cToID ELSE '' END,
               QTY = @nQTY,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME()
            WHERE PickDetailKey = @cPickDetailKey
         END TRY
         BEGIN CATCH
            IF @bDebugFlag = 1
               SELECT  '235155 Error info', ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage

            SET @nErrNo = 235155
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
            GOTO RollBackTran
         END CATCH
         
         FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY
      END
   END --ReplenBySKUQTY = 0

   IF @nTranCount = 0
      COMMIT TRAN
   ELSE
      COMMIT TRAN rdt_896ReplCfmSP01
      
   GOTO Quit

RollBackTran:
   IF @nTranCount = 0
      ROLLBACK TRAN
   ELSE
      ROLLBACK TRAN rdt_896ReplCfmSP01 -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO
GRANT EXECUTE ON  [RDT].[rdt_896ReplCfmSP01] TO [NSQL]
GO
