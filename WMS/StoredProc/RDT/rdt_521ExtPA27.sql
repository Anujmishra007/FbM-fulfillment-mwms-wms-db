SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_521ExtPA27                                      */
/* Copyright      : Maersk                                              */
/* Customer       : AMERICAN EAGLE                                      */
/*                                                                      */
/*                                                                      */
/* Date         Rev  Author   Purposes                                  */
/* 2026-05-19   1.0  NickT    FCR-12181 Create                          */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_521ExtPA27] (
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
   @nQty             INT,
   @cSuggestedLOC    NVARCHAR( 10) OUTPUT,
   @cPickAndDropLoc  NVARCHAR( 10) OUTPUT,
   @nPABookingKey    INT           OUTPUT,
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @nSKUQty                INT,
      @nRowCount              INT,
      @cLottable02            NVARCHAR( 18),
      @cPutawayZone           NVARCHAR( 10),
      @cTempLogicalLocation   NVARCHAR( 18),
      @cTempLoc               NVARCHAR( 10),
      @cAEOMX_DAM             NVARCHAR( 10) = 'AEOMX_DAM',
      @nRowRefID              INT

   SET @nPABookingKey = 0
   SET @cSuggestedLOC = ''
   SET @cPickAndDropLoc = ''
   SET @nErrNo = 0
   SET @cErrMsg = ''

   IF OBJECT_ID('tempdb..#TempLocUCCQty') IS NOT NULL
      DROP TABLE #TempLocUCCQty

   CREATE TABLE #TempLocUCCQty (
      RowRefID                INT IDENTITY(1,1),
      LOC                     NVARCHAR(10),
      LogicalLocation         NVARCHAR(18),
      MaxCarton               INT,
      PendingMoveInUCCQty     INT,
      UCCQty                  INT
   )

   SELECT @nSKUQty = COUNT(DISTINCT SKU)
   FROM dbo.UCC WITH(NOLOCK)
   WHERE UCCNo = @cUCC
      AND StorerKey = @cStorerKey

   SELECT TOP 1 
      @cSKU = SKU,
      @cLOT = Lot
   FROM dbo.UCC WITH(NOLOCK)
   WHERE UCCNo = @cUCC
      AND StorerKey = @cStorerKey
   ORDER BY SKU, Lot

   SELECT @cLottable02 = Lottable02
   FROM dbo.LOTATTRIBUTE WITH(NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND Sku = @cSKU
      AND Lot = @cLOT

   -- For damage UCC, put it to damage location
   -- 1. Find the empty location to put the UCC
   -- 2. if no empty location, find top 1 location which has the space to put the UCC, and the location should be in the damage area
   IF @cLottable02 = 'DAM'
   BEGIN
      -- 1. Find the empty location in damage area to put the UCC
      SET @cSuggestedLOC = ''
      SELECT TOP 1 @cSuggestedLOC = LOC.Loc
      FROM dbo.LOC WITH(NOLOCK)
      WHERE LOC.Facility = @cFacility
         AND LOC.PutawayZone = @cAEOMX_DAM
         AND NOT EXISTS (SELECT 1 FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
                        INNER JOIN dbo.LOC LOC1 WITH(NOLOCK) ON LLI.Loc = LOC1.Loc AND LOC1.PutawayZone = @cAEOMX_DAM
                        WHERE LLI.StorerKey = @cStorerKey 
                           AND (LLI.Qty - LLI.QtyPicked - LLI.QtyPickInProcess > 0 OR LLI.PendingMoveIN + LLI.QtyExpected > 0)
                           AND LOC.Loc = LOC1.Loc)
      ORDER BY LOC.LogicalLocation, LOC.Loc
      
      SELECT @nRowCount = @@ROWCOUNT

      IF @nRowCount > 0 AND ISNULL(@cSuggestedLOC, '') <> ''
         GOTO BOOK_LOC

      -- 2. If no empty location is found, find top 1 location in AEOMX_DAM
      -- should consider CommingleSku and NoMixLottable02 to make sure the suggested location is suitable for the damage UCC which has Lottable02 = 'DAM'
      SET @cSuggestedLOC = ''

      IF @nSKUQty = 1
      BEGIN
         SELECT TOP 1 @cSuggestedLOC = LOC.Loc
         FROM dbo.LOC WITH(NOLOCK)
         WHERE LOC.Facility = @cFacility
            AND LOC.Loc <> @cLoc
            AND LOC.PutawayZone = @cAEOMX_DAM
            AND NOT EXISTS(SELECT 1 FROM dbo.LOC LOC1 WITH(NOLOCK)
                           INNER JOIN dbo.LOTxLOCxID LLI1 WITH(NOLOCK) ON LLI1.Loc = LOC1.Loc AND LLI1.StorerKey = @cStorerKey
                           WHERE LOC1.Facility = @cFacility
                              AND LOC1.PutawayZone = @cAEOMX_DAM
                              AND LOC1.CommingleSku IN( '0', 'N' )
                              AND LLI1.SKU <> @cSKU
                              AND (LLI1.Qty - LLI1.QtyPicked - LLI1.QtyPickInProcess > 0 OR LLI1.PendingMoveIN + LLI1.QtyExpected > 0)
                              AND LOC.Loc = LOC1.Loc
                           )
            AND NOT EXISTS(SELECT 1 FROM dbo.LOC LOC2 WITH(NOLOCK)
                           INNER JOIN dbo.LOTxLOCxID LLI2 WITH(NOLOCK) ON LLI2.Loc = LOC2.Loc AND LLI2.StorerKey = @cStorerKey
                           INNER JOIN LOTATTRIBUTE LA WITH(NOLOCK) ON LLI2.Lot = LA.Lot AND LLI2.StorerKey = LA.StorerKey
                           WHERE LOC2.Facility = @cFacility
                              AND LOC2.PutawayZone = @cAEOMX_DAM
                              AND LOC2.NoMixLottable02 IN ('1', 'Y')
                              AND LA.Lottable02 <> @cLottable02
                              AND (LLI2.Qty - LLI2.QtyPicked - LLI2.QtyPickInProcess > 0 OR LLI2.PendingMoveIN + LLI2.QtyExpected > 0)
                              AND LOC.Loc = LOC2.Loc
                           )

         ORDER BY LOC.LogicalLocation, LOC.Loc
      END
      ELSE IF @nSKUQty > 1
      BEGIN
         SELECT TOP 1 @cSuggestedLOC = LOC.Loc
         FROM dbo.LOC WITH(NOLOCK)
         WHERE LOC.Facility = @cFacility
            AND LOC.Loc <> @cLoc
            AND LOC.PutawayZone = @cAEOMX_DAM
            AND NOT EXISTS(SELECT 1 FROM dbo.LOC LOC1 WITH(NOLOCK)
                           INNER JOIN dbo.LOTxLOCxID LLI1 WITH(NOLOCK) ON LLI1.Loc = LOC1.Loc AND LLI1.StorerKey = @cStorerKey
                           WHERE LOC1.Facility = @cFacility
                              AND LOC1.PutawayZone = @cAEOMX_DAM
                              AND LOC1.CommingleSku IN( '0', 'N' )
                              AND (LLI1.Qty - LLI1.QtyPicked - LLI1.QtyPickInProcess > 0 OR LLI1.PendingMoveIN + LLI1.QtyExpected > 0)
                              AND LOC.Loc = LOC1.Loc
                           )
            AND NOT EXISTS(SELECT 1 FROM dbo.LOC LOC2 WITH(NOLOCK)
                           INNER JOIN dbo.LOTxLOCxID LLI2 WITH(NOLOCK) ON LLI2.Loc = LOC2.Loc AND LLI2.StorerKey = @cStorerKey
                           INNER JOIN LOTATTRIBUTE LA WITH(NOLOCK) ON LLI2.Lot = LA.Lot AND LLI2.StorerKey = LA.StorerKey
                           WHERE LOC2.Facility = @cFacility
                              AND LOC2.PutawayZone = @cAEOMX_DAM
                              AND LOC2.NoMixLottable02 IN ('1', 'Y')
                              AND LA.Lottable02 <> @cLottable02
                              AND (LLI2.Qty - LLI2.QtyPicked - LLI2.QtyPickInProcess > 0 OR LLI2.PendingMoveIN + LLI2.QtyExpected > 0)
                              AND LOC.Loc = LOC2.Loc
                           )

         ORDER BY LOC.LogicalLocation, LOC.Loc
      END
   END
   ELSE IF @cLottable02 = 'GOO'
   BEGIN
      SELECT @cPutawayZone = PutawayZone
      FROM dbo.SKU WITH(NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND SKU = @cSKU

      IF ISNULL(@cPutawayZone, '') = ''
      BEGIN
         SET @nErrNo = 267051
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Missing SKU Putaway Zone
         GOTO QUIT
      END

      -- 1. Step 1 - Location with same SKU, the location has space to put the UCC, and the location should be in the same putaway zone
      DELETE FROM #TempLocUCCQty

      -- Get the LOC data, including MaxCarton, UCCQty and PendingMoveInUCCQty. 
      --The UCCQty and PendingMoveInUCCQty is calculated based on the current location inventory and the suggested putaway move, 
      --not only the inventory with the same SKU, but also the inventory with different SKU as they will also take space of the location.
      INSERT INTO #TempLocUCCQty (LOC, LogicalLocation, MaxCarton, PendingMoveInUCCQty, UCCQty)
      SELECT LOC.Loc, LOC.LogicalLocation, LOC.MaxCarton, COUNT(DISTINCT UCC2.UCCNo), COUNT(DISTINCT UCC.UCCNo)
      FROM dbo.LOC WITH(NOLOCK)
      INNER JOIN LOTxLOCxID LLI WITH(NOLOCK) ON LOC.Loc = LLI.Loc AND (LLI.Qty - LLI.QtyPicked > 0 OR LLI.PendingMoveIN > 0)
      LEFT JOIN dbo.UCC WITH(NOLOCK) ON LOC.Loc = UCC.Loc AND UCC.StorerKey = @cStorerKey AND UCC.Status IN ('1', '3', '4')
      LEFT JOIN dbo.RFPutaway RFP WITH(NOLOCK) ON LLI.StorerKey = RFP.StorerKey AND LLI.Loc = RFP.SuggestedLOC
      LEFT JOIN dbo.UCC UCC2 WITH(NOLOCK) ON ISNULL(RFP.CaseID, '') <> '' AND RFP.StorerKey = UCC2.StorerKey AND RFP.FromLOC = UCC2.Loc AND RFP.CaseID = UCC2.UCCNo AND RFP.SKU = UCC2.SKU
      WHERE LOC.Facility = @cFacility
         AND LOC.Loc <> @cLOC
         AND LOC.PutawayZone = @cPutawayZone
         AND LLI.StorerKey = @cStorerKey
         AND NOT EXISTS(SELECT 1 FROM dbo.LOC LOC1 WITH(NOLOCK)
                        INNER JOIN dbo.LOTxLOCxID LLI1 WITH(NOLOCK) ON LLI1.Loc = LOC1.Loc AND LLI1.StorerKey = @cStorerKey
                        WHERE LOC1.Facility = @cFacility
                           AND LOC1.PutawayZone = @cPutawayZone
                           AND LOC1.CommingleSku IN( '0', 'N' )
                           AND LLI1.SKU <> @cSKU
                           AND (LLI1.Qty - LLI1.QtyPicked - LLI1.QtyPickInProcess > 0 OR LLI1.PendingMoveIN + LLI1.QtyExpected > 0)
                           AND LOC.Loc = LOC1.Loc
                        )
         AND NOT EXISTS(SELECT 1 FROM dbo.LOC LOC2 WITH(NOLOCK)
                        INNER JOIN dbo.LOTxLOCxID LLI2 WITH(NOLOCK) ON LLI2.Loc = LOC2.Loc AND LLI2.StorerKey = @cStorerKey
                        INNER JOIN LOTATTRIBUTE LA WITH(NOLOCK) ON LLI2.Lot = LA.Lot AND LLI2.StorerKey = LA.StorerKey
                        WHERE LOC2.Facility = @cFacility
                           AND LOC2.PutawayZone = @cPutawayZone
                           AND LOC2.NoMixLottable02 IN ('1', 'Y')
                           AND LA.Lottable02 <> @cLottable02
                           AND (LLI2.Qty - LLI2.QtyPicked - LLI2.QtyPickInProcess > 0 OR LLI2.PendingMoveIN + LLI2.QtyExpected > 0)
                           AND LOC.Loc = LOC2.Loc
                        )
      GROUP BY LOC.Loc, LOC.LogicalLocation, LOC.MaxCarton
      ORDER BY LOC.LogicalLocation, LOC.Loc

      SET @cSuggestedLOC = ''
      SELECT TOP 1 @cSuggestedLOC = TU.Loc
      FROM #TempLocUCCQty TU
      INNER JOIN LOTxLOCxID LLI WITH(NOLOCK) ON TU.Loc = LLI.Loc AND LLI.StorerKey = @cStorerKey AND LLI.SKU = @cSKU
      WHERE MaxCarton > ISNULL(UCCQty, 0) + ISNULL(PendingMoveInUCCQty, 0)
      ORDER BY RowRefID

      SELECT @nRowCount = @@ROWCOUNT

      -- 2. Step 2 - Nearby Location of the Location with same SKU
      IF @nRowCount = 0 OR ISNULL(@cSuggestedLOC, '')  = ''
      BEGIN
         SET @cSuggestedLOC = ''

         -- find the loc where holds the SKU
         SELECT TOP 1
            @nRowRefID = RowRefID,
            @cSuggestedLOC = TU.Loc,
            @cTempLogicalLocation = TU.LogicalLocation
         FROM #TempLocUCCQty TU
         INNER JOIN LOTxLOCxID LLI WITH(NOLOCK) ON TU.Loc = LLI.Loc AND LLI.StorerKey = @cStorerKey AND LLI.SKU = @cSKU
         ORDER BY RowRefID DESC

         SELECT @nRowCount = @@ROWCOUNT

         -- Find nearby forward location which has space to put the UCC, and the location should be in the same putaway zone
         -- the location has different SKU
         IF @nRowCount > 0 AND ISNULL(@cSuggestedLOC, '') <> ''
         BEGIN
            SET @cTempLoc = @cSuggestedLOC
            SET @cSuggestedLOC = ''

            SELECT TOP 1 @cSuggestedLOC = TU.Loc
            FROM #TempLocUCCQty TU
            INNER JOIN LOTxLOCxID LLI WITH(NOLOCK) ON TU.Loc = LLI.Loc AND LLI.StorerKey = @cStorerKey AND LLI.SKU <> @cSKU
            WHERE MaxCarton > ISNULL(UCCQty, 0) + ISNULL(PendingMoveInUCCQty, 0)
               AND RowRefID > @nRowRefID
               AND TU.Loc <> @cTempLoc
            ORDER BY RowRefID

            SELECT @nRowCount = @@ROWCOUNT
         END
      END

      -- Step 3 - First empty location
      IF @nRowCount = 0 OR ISNULL(@cSuggestedLOC, '')  = ''
      BEGIN
         SET @cSuggestedLOC = ''
         SELECT TOP 1 @cSuggestedLOC = LOC.Loc
         FROM dbo.LOC WITH(NOLOCK)
         WHERE LOC.Facility = @cFacility
            AND LOC.PutawayZone = @cPutawayZone
            AND NOT EXISTS (SELECT 1 FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
                           INNER JOIN dbo.LOC LOC1 WITH(NOLOCK) ON LLI.Loc = LOC1.Loc AND LOC1.PutawayZone = @cPutawayZone
                           WHERE LLI.StorerKey = @cStorerKey 
                              AND (LLI.Qty - LLI.QtyPicked - LLI.QtyPickInProcess > 0 OR LLI.PendingMoveIN + LLI.QtyExpected > 0)
                              AND LOC.Loc = LOC1.Loc)
         ORDER BY LOC.LogicalLocation, LOC.Loc
      END
   END

   BOOK_LOC:
   IF ISNULL( @cSuggestedLOC, '') = ''
   BEGIN
      SET @cSuggestedLOC = ''
      SET @nErrNo = -1
   END
   ELSE
   BEGIN
      EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK'
         ,@cLOC
         ,@cID
         ,@cSuggestedLOC
         ,@cStorerKey
         ,@nErrNo  OUTPUT
         ,@cErrMsg OUTPUT
         ,@cSKU        = @cSKU
         ,@nPutawayQTY = @nQTY
         ,@cUCCNo      = @cUCC
         ,@cFromLOT    = @cLOT
         ,@nPABookingKey = @nPABookingKey OUTPUT
   END

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  [RDT].[rdt_521ExtPA27] TO [NSQL]
GO