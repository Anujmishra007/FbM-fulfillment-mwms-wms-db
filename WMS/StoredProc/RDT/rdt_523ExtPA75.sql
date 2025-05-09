SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: rdt_523ExtPA75                                            */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Date        Rev  Author    Purposes                                        */
/* 2025-03-11  1.0  yeekung   FCR-3456. Created                               */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_523ExtPA75] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @cUserName        NVARCHAR( 18),
   @cStorerKey       NVARCHAR( 15),
   @cFacility        NVARCHAR( 5),
   @cLOC             NVARCHAR( 10),
   @cID              NVARCHAR( 18),
   @cLOT             NVARCHAR( 10),
   @cUCC             NVARCHAR( 20),
   @cSKU             NVARCHAR( 20),
   @nQTY             INT,
   @cSuggestedLOC    NVARCHAR( 10)  OUTPUT,
   @nPABookingKey    INT            OUTPUT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount     INT
   DECLARE @cSuggToLOC     NVARCHAR( 10) = ''
   DECLARE @cStyle         NVARCHAR( 20)
   DECLARE @cPutawayZone   NVARCHAR(10) 
   DECLARE @cSkuGroup      NVARCHAR(20)
   DECLARE @cLogicalLoc    NVARCHAR(20)
   DECLARE @cSKUPutawayZone   NVARCHAR(10)   


   SET @nTranCount = @@TRANCOUNT

   SELECT  TOP 1  @cSKUPutawayZone = SKU.PutawayZone
   FROM SKU SKU (NOLOCK)  
   WHERE SKU.SKU = @cSKU
      AND SKU.Storerkey = @cStorerKey  

      -- Find a friend
   SELECT TOP 1
      @cSuggestedLOC = LOC.LOC
   FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
   JOIN dbo.LOC LOC WITH (NOLOCK) ON ( LLI.LOC = LOC.LOC)
   JOIN dbo.LOTAttribute LA WITH (NOLOCK) ON ( LLI.LOT = LA.LOT)
   JOIN SKU SKU (NOLOCK) ON SKU.SKU = LLI.SKU AND SKU.Storerkey = LLI.Storerkey
   WHERE LOC.Facility = @cFacility
      AND   LOC.LOC <> @cLOC
      AND   LLI.StorerKey = @cStorerKey
      AND   SKU.SKU = @cSKU
      AND   SKU.PutawayZone = @cSKUPutawayZone
   GROUP BY LOC.Loc
   HAVING SUM( lli.Qty - lli.QtyAllocated - lli.QtyPicked - LLI.QtyReplen) > 0
   ORDER BY SUM( lli.Qty - lli.QtyAllocated - lli.QtyPicked - LLI.QtyReplen)

   IF ISNULL(@cSuggestedLOC,'') = ''
   BEGIN
      SELECT TOP 1
         @cSuggestedLOC = LOC.LOC
      FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
      JOIN dbo.LOC LOC WITH (NOLOCK) ON ( LLI.LOC = LOC.LOC)
      JOIN dbo.LOTAttribute LA WITH (NOLOCK) ON ( LLI.LOT = LA.LOT)
      JOIN SKU SKU (NOLOCK) ON SKU.SKU = LLI.SKU AND SKU.Storerkey = LLI.Storerkey
      WHERE LOC.Facility = @cFacility
         AND   LOC.LOC <> @cLOC
         AND   LLI.StorerKey = @cStorerKey
         AND   SKU.SKU = @cSKU
         AND   SKU.PutawayZone = @cSKUPutawayZone
      GROUP BY LOC.Loc
      HAVING SUM( lli.Qty - lli.QtyAllocated - lli.QtyPicked - LLI.QtyReplen) = 0
      ORDER BY SUM( lli.Qty - lli.QtyAllocated - lli.QtyPicked - LLI.QtyReplen) 
   END

   /*-------------------------------------------------------------------------------
                                 Book suggested location
   -------------------------------------------------------------------------------*/
   -- Handling transaction
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_523ExtPA75 -- For rollback or commit only our own transaction

   IF @cSuggToLOC <> ''
   BEGIN
      SET @nErrNo = 0
      EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK'
         ,@cLOC
         ,@cID
         ,@cSuggToLOC
         ,@cStorerKey
         ,@nErrNo  OUTPUT
         ,@cErrMsg OUTPUT
         ,@cSKU          = @cSKU
         ,@nPutawayQTY   = @nQTY
         ,@nPABookingKey = @nPABookingKey OUTPUT
      IF @nErrNo <> 0
         GOTO RollBackTran

      SET @cSuggestedLOC = @cSuggToLOC

      COMMIT TRAN rdt_523ExtPA75 -- Only commit change made here
   END
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_523ExtPA75 -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO
GRANT EXECUTE ON  [RDT].[rdt_523ExtPA75] TO [NSQL]
GO
