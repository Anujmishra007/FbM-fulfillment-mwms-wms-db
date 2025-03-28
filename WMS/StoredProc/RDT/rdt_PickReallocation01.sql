/****** Object:  StoredProcedure [RDT].[rdt_PickReallocation01]    Script Date: 3/21/2024 10:14:40 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_PickReallocation01                              */
/* Copyright      : Maersk                                              */
/* Customer       : PUMACL                                              */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2025-03-26 1.0.0 NLT013  FCR-2704 Re-allocation if short happens     */
/*                                                                      */
/************************************************************************/

CREATE OR ALTER  PROC [RDT].[rdt_PickReallocation01] (
   @nMobile          INT          
   ,@nFunc           INT          
   ,@cLangCode       NVARCHAR( 3) 
   ,@cFacility       NVARCHAR( 5) 
   ,@cStorerKey      NVARCHAR( 15)
   ,@cPickSlipNo     NVARCHAR( 10)
   ,@tAdditionalData   VariableTable READONLY
   ,@cType           NVARCHAR( 5) --UCC/SKU
   ,@cLOC            NVARCHAR( 10)
   ,@cID             NVARCHAR( 18)
   ,@cSKU            NVARCHAR( 20)
   ,@nQTY            INT
   ,@cLot            NVARCHAR( 10)  OUTPUT
   ,@cPickZone       NVARCHAR( 10)  OUTPUT
   ,@cSuggestLOC     NVARCHAR( 10)  OUTPUT
   ,@cSuggestID      NVARCHAR( 18)  OUTPUT
   ,@nErrNo          INT            OUTPUT
   ,@cErrMsg         NVARCHAR(250)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cPickZone        NVARCHAR(10),
      @nRowCount        INT,
      @nLoopIndex       INT,
      @nPickDetailQty   INT,
      @cPickDetailKey   NVARCHAR(18),
      @cLot             NVARCHAR(10),
      @cUCCNo           NVARCHAR(20)

   DECLARE @tPickDetails TABLE
   (
      id INT IDENTITY(1,1),
      PickDetailKey  NVARCHAR(18),
      Qty      INT
   )

   SELECT @cPickZone = PickZone
   FROM dbo.LOC with(NOLOCK)
   WHERE Facility = @cFacility
      AND LOC = @cLOC

   IF ISNULL(@cPickZone, '') = ''
      GOTO Quit
   
   IF @cType = 'UCC'
   BEGIN
      SELECT TOP 1 
         @cSuggestLOC = UCC.Loc
        ,@cSuggestID = UCC.ID
      FROM dbo.UCC WITH(NOLOCK)
      INNER JOIN dbo.LOC WITH(NOLOCK) ON UCC.LOC = LOC.LOC AND LOC.PickZone = @cPickZone
      INNER JOIN LOTATTRIBUTE LA WITH(NOLOCK) ON UCC.LOT = LA.Lot
      WHERE UCC.StorerKey = @cStorerKey
         AND UCC.SKU = @cSKU
         AND UCC.QTY > 0
         AND UCC.STATUS = '1'
         AND LA.Lottable01 = @cLottable01
         AND UCC.Loc <> @cLOC
      GROUP BY UCC.Loc, UCC.ID
      HAVING SUM(UCC.QTY) >= @nQTY
      ORDER BY UCC.Loc

      SELECT @nRowCount = @@ROWCOUNT

      IF @nRowCount > 0
      BEGIN
         INSERT INTO @tPickDetails (PickDetailKey, Qty)
         SELECT PD.PickDetailKey, Qty
         FROM dbo.PickDetail PD WITH(ROWLOCK)
         INNER JOIN LOTATTRIBUTE LA WITH(NOLOCK) ON PD.LOT = LA.Lot
         WHERE PickSlipNo = @cPickSlipNo
            AND Status = '4'
            AND Loc = @cLoc
            AND ID = @cID
            AND SKU = @cSKU
            AND LA.Lottable01 = @cLottable01

         SET @nTranCount = @@TRANCOUNT

         BEGIN TRAN  -- Begin our own transaction
         SAVE TRAN rdt_PickReallocation01_01 -- For rollback or commit only our own transaction

         SET @nLoopIndex = -1

         WHILE 1 = 1
         BEGIN
            SELECT TOP 1
               @cPickDetailKey = PickDetailKey,
               @nPickDetailQty = Qty,
               @nLoopIndex = id
            FROM @tPickDetails
            WHERE id > @nLoopIndex
            ORDER BY id

            SELECT @nRowCount = @@ROWCOUNT

            IF @nRowCount = 0
               BREAK

            SELECT TOP 1
               @cUCCNo = UCCNo,
               @cLot = Lot
            FROM dbo.UCC WITH(NOLOCK)
            WHERE Loc = @cSuggestLOC
               AND ID = @cSuggestID
               AND SKU = @cSKU
               AND QTY = @nPickDetailQty
               AND STATUS = '1'
               AND LA.Lottable01 = @cLottable01
            ORDER BY UCCNo
            
            -- Create new a PickDetail to hold the balance
            INSERT INTO dbo.PickDetail (
               CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM, 
               UOMQTY, QTYMoved, Status, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType, 
               ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
               EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes, 
               PickDetailKey, 
               QTY, 
               OptimizeCop)
            SELECT 
               CaseID, PickHeaderKey, OrderKey, OrderLineNumber, @cLot, StorerKey, SKU, AltSku, UOM, 
               UOMQTY, QTYMoved, '0', @cUCCNo, LOC, ID, PackKey, UpdateSource, CartonGroup, 
               CartonType, ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
               EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes, 
               @cNewPickDetailKey, 
               Qty,
               '1'
            FROM dbo.PickDetail WITH (NOLOCK) 
            WHERE PickDetailKey = @cPickDetailKey

            DELETE PD
            FROM dbo.PickDetail PD WITH(ROWLOCK)
            WHERE PickSlipNo = @cPickSlipNo
               AND Status = '4'
               AND PickDetailKey = @cPickDetailKey
         END

         RollBackTran_01:
            ROLLBACK TRAN rdt_PickCase_Confirm -- Only rollback change made here
         CommitTran_01:
            WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
               COMMIT TRAN
      END

   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXEC ON [RDT].[rdt_PickReallocation01] TO NSQL
GO


