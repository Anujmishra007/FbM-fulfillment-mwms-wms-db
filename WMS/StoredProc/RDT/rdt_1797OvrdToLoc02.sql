SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1797OvrdToLoc02                                 */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author   Purposes                                   */
/* 2026-04-01  1.0  Cuize    FCR-11750. Created                         */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_1797OvrdToLoc02] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @cTaskdetailKey   NVARCHAR( 10),
   @cSuggToLOC       NVARCHAR( 10),
   @cToLOC           NVARCHAR( 10),
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF



   --1. ItemClass = 'PVAR', only allowed to an empty location
   DECLARE @cItemClass                NVARCHAR(10)
   DECLARE @cRoomNumber               NVARCHAR(10)
   DECLARE @cLocCategory              NVARCHAR(10)
   DECLARE @cFacility                 NVARCHAR(5)
   DECLARE @nTranCount          INT
   DECLARE @cTTMTaskType        NVARCHAR(10)
   DECLARE @cFromLOC            NVARCHAR(10)
   DECLARE @cFromID             NVARCHAR(18)
   DECLARE @cSKU                NVARCHAR(20)
   DECLARE @nQTY                INT
   DECLARE @nPABookingKey       INT
   DECLARE @cLOT                NVARCHAR( 10)
   DECLARE @cStorerKey          NVARCHAR( 15)
   DECLARE @cUserName           NVARCHAR( 18)
   DECLARE @cSectionKeySuggested NVARCHAR(10)
   DECLARE @cSectionKeyScanned  NVARCHAR(10)
   DECLARE @cFacilityScanned     NVARCHAR(10)


   SELECT    @cFacility        = Facility,
             @cStorerKey      = Storerkey
   FROM   RDTMOBREC (NOLOCK)
   WHERE  Mobile = @nMobile

   -- Check if the SectionKey is same as suggested location
   SELECT @cSectionKeySuggested = SectionKey
   FROM dbo.LOC WITH (NOLOCK) 
   WHERE LOC = @cSuggToLOC
      AND Facility = @cFacility

   SELECT @cSectionKeyScanned = SectionKey,
      @cFacilityScanned = Facility
   FROM dbo.LOC WITH (NOLOCK) 
   WHERE LOC = @cToLoc

   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo = 263659
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Location
      GOTO Quit
   END

   IF @cFacilityScanned <> @cFacility
   BEGIN
      SET @nErrNo = 263657
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Different Facility
      GOTO Quit
   END

   IF ISNULL(@cSectionKeySuggested, '') <> ISNULL(@cSectionKeyScanned, '')
   BEGIN
      SET @nErrNo = 263658
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Different SectionKey(storerkey)
      GOTO Quit
   END

   SELECT @cItemClass = s.itemclass
      FROM Taskdetail TASK WITH (NOLOCK )
      JOIN SKU s WITH (NOLOCK ) ON s.sku = task.sku
                                AND s.storerkey = task.storerkey
   WHERE TaskDetailKey = @cTaskdetailKey

   SELECT top 1 @cRoomNumber = Long,
      @cLocCategory = Short
   FROM dbo.CodeLkup WITH (NOLOCK)
   WHERE ListName = 'BRFLOCOVRD'
     AND StorerKey = @cStorerKey
     AND code = @citemClass

   --Config Exists
   IF @@ROWCOUNT > 0
   BEGIN

      IF (@cToLOC NOT LIKE @cRoomNumber + '%')
      BEGIN
         SET @nErrNo = 263651
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --BadRoomNumber
         GOTO Quit
      END

      IF NOT EXISTS (
         SELECT 1 FROM LOC WITH(NOLOCK)
         WHERE LOC = @cToLOC
           AND LocationCategory = @cLocCategory)
      BEGIN
         SET @nErrNo = 263652
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --BadLocCategory
         GOTO Quit
      END

      IF NOT EXISTS (
         SELECT 1
         FROM LotxLocxID
         WHERE LOC = @cToLOC
         GROUP BY LotxLocxID.LOC
         HAVING SUM( ISNULL(LotxLocxID.Qty,0)) = 0
            AND SUM( ISNULL(LotxLocxID.PendingMoveIn,0)) = 0
      )
      BEGIN
         SET @nErrNo = 263653
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LOC NOT EMPTY
         GOTO Quit
      END

      GOTO OverrideLoc
   END

   DECLARE @nPalletQty     INT
   DECLARE @nActualQty     INT
   DECLARE @cLottable02    NVARCHAR( 18)

   SELECT
      @nPalletQty    = pack.Pallet,
      @cFromID       = Task.FromID,
      @cLottable02   = RD.Lottable02,
      @cSKU          = RD.SKU
   FROM taskdetail TASK WITH(NOLOCK )
   JOIN receiptdetail RD WITH(NOLOCK ) ON (TASK.SourceKey = RD.ReceiptKey AND TASK.sku = RD.Sku AND TASK.ToID = RD.ToId)
   JOIN pack WITH(NOLOCK ) ON (PACK.PackKey = RD.PackKey)
   AND taskdetailkey = @cTaskdetailKey


   SELECT @nActualQty = ISNULL( SUM (QTY),0) FROM LOTxLOCxID where ID = @cFromID



   IF ( @nActualQty < @nPalletQty ) -- Partial Pallet
   BEGIN

      IF NOT EXISTS(
         SELECT 1
         FROM LOC WITH (NOLOCK )
                 LEFT JOIN LOtxLOCxID WITH (NOLOCK ) ON (LOC.loc = LotxLocxID.loc)
         WHERE LOC.LOC = @cToLOC
           AND LOC.LocationCategory = 'SELECTIVE'
         GROUP BY LOC.LOC
         HAVING SUM(ISNULL(LotxLocxID.Qty, 0)) = 0
            AND SUM(ISNULL(LotxLocxID.PendingMoveIn, 0)) = 0
      )
      BEGIN
         SET @nErrNo = 263654
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Loose pallet not allowed
         GOTO Quit
      END
      GOTO OverrideLoc

   END
   ELSE
   BEGIN -- Full Pallet

      IF NOT EXISTS(
      SELECT 1
      FROM dbo.LOC loc WITH (NOLOCK)
      LEFT JOIN dbo.LOTxLOCxID LLI WITH (NOLOCK) ON (loc.LOC = LLI.LOC AND
         (LLI.QTY - LLI.QTYPicked > 0 OR LLI.PendingMoveIn > 0) AND
         LLI.StorerKey = @cStorerKey)
      WHERE loc.loc = @cToLOC
         AND loc.Facility = @cFacility
         AND ISNULL(loc.Status, '') = 'OK'
         AND loc.LocationFlag <> 'DAMAGE'
      GROUP BY loc.Loc, IIF(loc.MaxPallet = 0, 9999, MaxPallet)
      HAVING IIF(loc.MaxPallet = 0, 9999, loc.MaxPallet) - COUNT(DISTINCT LLI.ID) > 0
      )
      BEGIN
         SET @nErrNo = 263655
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Over max pallet capacity
         GOTO Quit
      END

      IF EXISTS(
         SELECT 1 FROM LOTxLOCxID LLI
            JOIN LOTATTRIBUTE LT on (LT.Lot = lli.Lot)
         WHERE LOC = @cToLOC
           AND LLI.StorerKey = @cStorerKey
           AND LLI.qty > 0
           AND ( LLI.SKU <> @cSKU OR LT.Lottable02 <> @cLottable02)
      )
      BEGIN
         SET @nErrNo = 263656
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU + Batch mismatch
         GOTO Quit
      END

      GOTO OverrideLoc

   END

   OverrideLoc:

   SET @nErrNo = 0

   -- Handling transaction
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_1797OvrdToLoc02 -- For rollback or commit only our own transaction

   -- Get task info
   SELECT
      @cTTMTaskType = TaskType,
      @cFromLOC = FromLoc,
      @cFromID = FromID,
      @cStorerKey = Storerkey
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE TaskDetailKey = @cTaskdetailKey

   SET @cUserName = SUSER_SNAME()

   IF @cTTMTaskType = 'PAF'
   BEGIN
      SELECT @cSKU = SKU,
             @nQTY = Qty,
             @cLOT = Lot,
             @nPABookingKey = PABookingKey
      FROM dbo.RFPUTAWAY WITH (NOLOCK)
      WHERE FromLoc = @cFromLOC
      AND   FromID = @cFromID
      AND   SuggestedLoc = @cSuggToLOC
      AND   StorerKey = @cStorerKey

      IF @@ROWCOUNT > 0
      BEGIN
         -- Unlock original suggested loc
         SET @nErrNo = 0
         -- Unlock by RPF task
         EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
            ,''
            ,''
            ,''
            ,''
            ,@nErrNo  OUTPUT
            ,@cErrMsg OUTPUT
            ,''
            ,0
            ,''
            ,''
            ,''
            ,''
            ,0
            ,@nPABookingKey
            ,''
            ,''
         IF @nErrNo <> 0
            GOTO RollBackTran
      END

      UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
         ToLoc = @cToLoc
      WHERE TaskDetailKey = @cTaskDetailKey

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 147201
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --OverWrite Fail
         GOTO RollBackTran
      END

      -- Lock user key in toloc
      SET @nErrNo = 0
      SET @nPABookingKey = 0
      EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK'
         ,@cFromLOC
         ,@cFromID
         ,@cToLoc
         ,@cStorerKey
         ,@nErrNo  OUTPUT
         ,@cErrMsg OUTPUT
         ,@cSKU          = @cSKU
         ,@nPutawayQTY   = @nQTY
         ,@cFromLOT      = @cLOT
         ,@nPABookingKey = @nPABookingKey OUTPUT
      IF @nErrNo <> 0
         GOTO RollBackTran
      SET @nErrNo = -1
   END

   COMMIT TRAN rdt_1797OvrdToLoc02 -- Only commit change made here
   GOTO Quit

   RollBackTran:
      ROLLBACK TRAN rdt_1797OvrdToLoc02 -- Only rollback change made here

Quit:
   WHILE @@TRANCOUNT > @nTranCount  --INC1066142
      COMMIT TRAN                   --INC1066142

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1797OvrdToLoc02] TO NSQL
GO
