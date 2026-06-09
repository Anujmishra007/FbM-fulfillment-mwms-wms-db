SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1819ExtPASP64                                   */
/* Created by : Maersk                                                  */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev      Author   Purposes                               */
/* 2026-06-02  1.0.0    NickT    FCR-12893 Created                      */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1819ExtPASP64] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @cUserName        NVARCHAR( 18),
   @cStorerKey       NVARCHAR( 15), 
   @cFacility        NVARCHAR( 5), 
   @cFromLOC         NVARCHAR( 10),
   @cID              NVARCHAR( 18),
   @cSuggLOC         NVARCHAR( 10)  OUTPUT,
   @cPickAndDropLOC  NVARCHAR( 10)  OUTPUT,
   @cFitCasesInAisle NVARCHAR( 1)   OUTPUT,
   @nPABookingKey    INT            OUTPUT, 
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @nTranCount             INT,
      @nRowCount              INT,
      @nUCCQty                INT,
      @nRowRefID              INT,
      @cUCCNo                 NVARCHAR( 20),
      @cTempLoc               NVARCHAR( 10) = '',
      @cTempLogicalLocation   NVARCHAR( 18),
      @cSKU                   NVARCHAR( 20),
      @cPutawayZone           NVARCHAR( 10),
      @cConditionCode         NVARCHAR(10),
      @cVAS                   NVARCHAR(3) = 'VAS',
      @cDAM                   NVARCHAR(3) = 'DAM',
      @cGOO                   NVARCHAR(3) = 'GOO',
      @cPND                   NVARCHAR(3) = 'PND',
      @cPNDMEZZA              NVARCHAR(10) = 'PND-MEZZA',
      @cLottable02            NVARCHAR( 18)

   CREATE TABLE #TempLocUCCQty (
      RowRefID                INT IDENTITY(1,1),
      LOC                     NVARCHAR(10),
      LogicalLocation         NVARCHAR(18),
      MaxCarton               INT,
      PendingMoveInUCCQty     INT,
      UCCQty                  INT
   )

   SET @cSuggLOC = ''
   SET @cPickAndDropLOC = ''
   SET @nPABookingKey = 0
   SET @cFitCasesInAisle = '0'
   SET @nErrNo = 0
   SET @nRowCount = 0
   SET @cErrMsg = ''

   SELECT @cConditionCode = ConditionCode
   FROM dbo.RECEIPTDETAIL WITH(NOLOCK)
   WHERE ToID = @cID
      AND StorerKey = @cStorerKey
  
   -- 1. For DAM inventory, only suggest VAS location
   IF ISNULL(@cConditionCode, '') = @cDAM
   BEGIN
      SET @cSuggLOC = ''
      SELECT TOP 1 @cSuggLOC = LOC.Loc
      FROM dbo.LOC WITH(NOLOCK)
      WHERE LOC.Facility = @cFacility
         AND LocationType = @cVAS
         AND LOC.Loc <> @cFromLOC
      ORDER BY LogicalLocation, Loc

      SET @nRowCount = @@ROWCOUNT
   END
   ELSE
   BEGIN
      -- Get first UCC
      SELECT TOP 1 
         @cLottable02 = LA.Lottable02,
         @cUCCNo = UCC.UCCNo
      FROM dbo.LOTATTRIBUTE LA WITH(NOLOCK)
      INNER JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK) 
         ON LA.Lot = LLI.Lot
         AND LA.StorerKey = LLI.StorerKey
         AND LA.Sku = LLI.Sku
         AND LLI.Qty - LLI.QtyPicked - LLI.QtyPickInProcess > 0
      LEFT JOIN dbo.UCC WITH(NOLOCK) 
         ON LLI.Sku = UCC.SKU
         AND LLI.Lot = UCC.Lot
         AND LLI.StorerKey = UCC.StorerKey
         AND LLI.Loc = UCC.Loc
         AND LLI.ID = UCC.ID
          AND UCC.Status IN ('1', '3') -- Available or Reserved
      WHERE LLI.StorerKey = @cStorerKey
         AND LLI.ID = @cID
      ORDER BY UCC.UCCNo, LLI.Sku, LLI.Lot

      SET @cLottable02 = ISNULL(@cLottable02, '')
      SET @cUCCNo = ISNULL(@cUCCNo, '')

      IF @cLottable02 = @cGOO
      BEGIN
         SELECT @nUCCQty = COUNT(DISTINCT UCCNo)
         FROM dbo.UCC WITH(NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND ID = @cID
            AND Status IN( '1', '3' ) -- Available or Reserved

         -- 2. check If the first UCC is mono-SKU 
         IF @cUCCNo <> ''
            AND EXISTS(SELECT 1 
                  FROM dbo.UCC WITH(NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND ID = @cID
                     AND UCCNo = @cUCCNo
                  HAVING (COUNT (DISTINCT SKU)) = 1)
         BEGIN
            SELECT TOP 1 @cSKU = SKU
            FROM dbo.UCC WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND ID = @cID
               AND UCCNo = @cUCCNo
            ORDER BY UCCNo
            
            SELECT @cPutawayZone = PutawayZone
            FROM dbo.SKU WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND SKU = @cSKU

            IF ISNULL(@cPutawayZone, '') = ''
            BEGIN
               SET @nErrNo = 268401
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Missing SKU Putaway Zone
               RETURN
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
            LEFT JOIN dbo.UCC UCC2 WITH(NOLOCK) ON RFP.StorerKey = UCC2.StorerKey AND RFP.FromLOC = UCC2.Loc AND RFP.CaseID IS NOT NULL AND RFP.CaseID = UCC2.UCCNo AND RFP.SKU = UCC2.SKU
            WHERE LOC.Facility = @cFacility
               AND LOC.Loc <> @cFromLOC
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
                              INNER JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK) ON LLI2.Lot = LA.Lot AND LLI2.StorerKey = LA.StorerKey AND LLI2.SKU = LA.SKU
                              WHERE LOC2.Facility = @cFacility
                                 AND LOC2.PutawayZone = @cPutawayZone
                                 AND LOC2.NoMixLottable02 IN ('1', 'Y')
                                 AND LA.Lottable02 <> @cLottable02
                                 AND (LLI2.Qty - LLI2.QtyPicked - LLI2.QtyPickInProcess > 0 OR LLI2.PendingMoveIN + LLI2.QtyExpected > 0)
                                 AND LOC.Loc = LOC2.Loc
                              )
            GROUP BY LOC.Loc, LOC.LogicalLocation, LOC.MaxCarton
            ORDER BY LOC.LogicalLocation, LOC.Loc

            SET @cSuggLOC = ''
            SELECT TOP 1 @cSuggLOC = TU.Loc
            FROM #TempLocUCCQty TU
            INNER JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK) ON TU.Loc = LLI.Loc AND LLI.StorerKey = @cStorerKey AND LLI.SKU = @cSKU
            WHERE IIF(MaxCarton = 0, 99999, MaxCarton) >= ISNULL(UCCQty, 0) + ISNULL(PendingMoveInUCCQty, 0) -- + @nUCCQty
            ORDER BY RowRefID

            SELECT @nRowCount = @@ROWCOUNT

            -- 2. Step 2 - Nearby Location of the Location with same SKU
            IF @nRowCount = 0 OR ISNULL(@cSuggLOC, '')  = ''
            BEGIN
               SET @cSuggLOC = ''

               -- find the loc where holds the SKU
               SELECT TOP 1
                  @nRowRefID = RowRefID,
                  @cSuggLOC = TU.Loc,
                  @cTempLogicalLocation = TU.LogicalLocation
               FROM #TempLocUCCQty TU
               INNER JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK) ON TU.Loc = LLI.Loc AND LLI.StorerKey = @cStorerKey AND LLI.SKU = @cSKU
               ORDER BY RowRefID DESC

               SELECT @nRowCount = @@ROWCOUNT

               -- Find nearby forward location which has space to put the UCC, and the location should be in the same putaway zone
               -- the location has different SKU
               IF @nRowCount > 0 AND ISNULL(@cSuggLOC, '') <> ''
               BEGIN
                  SET @cTempLoc = @cSuggLOC
                  SET @cSuggLOC = ''

                  SELECT TOP 1 @cSuggLOC = TU.Loc
                  FROM #TempLocUCCQty TU
                  INNER JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK) ON TU.Loc = LLI.Loc AND LLI.StorerKey = @cStorerKey AND LLI.SKU <> @cSKU
                  WHERE IIF(MaxCarton = 0, 99999, MaxCarton) >= ISNULL(UCCQty, 0) + ISNULL(PendingMoveInUCCQty, 0) -- + @nUCCQty
                     AND RowRefID > @nRowRefID
                     AND TU.Loc <> @cTempLoc
                  ORDER BY RowRefID

                  SELECT @nRowCount = @@ROWCOUNT
               END
            END

            -- Step 3 - First empty location
            IF @nRowCount = 0 OR ISNULL(@cSuggLOC, '')  = ''
            BEGIN
               SET @cSuggLOC = ''
               SELECT TOP 1 @cSuggLOC = LOC.Loc
               FROM dbo.LOC WITH(NOLOCK)
               WHERE LOC.Facility = @cFacility
                  AND LOC.PutawayZone = @cPutawayZone
                  --AND LOC.MaxCarton >= @nUCCQty
                  AND LOC.Loc <> @cFromLOC
                  AND NOT EXISTS (SELECT 1 FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
                                 INNER JOIN dbo.LOC LOC1 WITH(NOLOCK) ON LLI.Loc = LOC1.Loc AND LOC1.PutawayZone = @cPutawayZone
                                 WHERE LLI.StorerKey = @cStorerKey 
                                    AND (LLI.Qty - LLI.QtyPicked - LLI.QtyPickInProcess > 0 OR LLI.PendingMoveIN + LLI.QtyExpected > 0)
                                    AND LOC.Loc = LOC1.Loc)
               ORDER BY LOC.LogicalLocation, LOC.Loc

               SELECT @nRowCount = @@ROWCOUNT
            END

            -- Step 4 - Pick and Drop location which has the same aisle with the location found in step 1 or step 2, step 3
            IF @nRowCount > 0 AND ISNULL(@cSuggLOC, '') <> ''
            BEGIN
               SET @cPickAndDropLOC = ''
               SELECT TOP 1 @cPickAndDropLOC = LOC.Loc
               FROM dbo.LOC WITH(NOLOCK)
               INNER JOIN dbo.LOC LOC1 WITH(NOLOCK) ON LOC.Facility = LOC1.Facility AND ISNULL(LOC.LocAisle, '') = ISNULL(LOC1.LocAisle, '') AND LOC1.Loc = @cSuggLOC
               WHERE LOC.Facility = @cFacility
                  AND LOC.LocationType = @cPND
               ORDER BY LOC.LogicalLocation, LOC.Loc

               SELECT @nRowCount = @@ROWCOUNT
            END
         END
         
         -- 3. for the remaining scenarios (the pallet has multi-SKU UCCs or loose units (no UCC). ), 
         -- suggest the PND-MEZZA location as fallback if there is no suggested location from above logic
         IF @nRowCount = 0 OR ISNULL(@cSuggLOC, '') = ''
         BEGIN
            SELECT TOP 1 @cLottable02 = LA.Lottable02
            FROM dbo.LOTATTRIBUTE LA WITH(NOLOCK)
            INNER JOIN dbo.UCC WITH(NOLOCK) 
               ON LA.Lot = UCC.Lot
               AND LA.StorerKey = UCC.StorerKey
               AND LA.Sku = UCC.SKU
            WHERE UCC.StorerKey = @cStorerKey
               AND UCC.ID = @cID
               AND UCC.Status IN ('1', '3', '4')
            ORDER BY UCC.UCCNo, UCC.SKU, UCC.Lot

            SET @cLottable02 = ISNULL(@cLottable02, '')

            -- Only GOO pallet
            IF @cLottable02 = @cGOO
               AND NOT EXISTS (SELECT 1
                              FROM dbo.LOTATTRIBUTE LA WITH(NOLOCK)
                              INNER JOIN dbo.UCC WITH(NOLOCK) 
                                 ON LA.Lot = UCC.Lot
                                 AND LA.StorerKey = UCC.StorerKey
                              WHERE UCC.StorerKey = @cStorerKey
                                 AND UCC.ID = @cID
                                 AND ISNULL(LA.LOTTABLE02, '') <> @cGOO
                              )
            BEGIN
               DECLARE
                  @nMultiSKU_UCCQty          INT, 
                  @nLooseInvSKUQty           INT

               SELECT @nMultiSKU_UCCQty = COUNT(DISTINCT UCCNo)
               FROM (
                  SELECT UCCNo
                  FROM dbo.UCC WITH(NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND ID = @cID
                  GROUP BY UCCNo
                  HAVING COUNT(DISTINCT SKU) > 1
               ) AS MultiSKU

               SET @nMultiSKU_UCCQty = ISNULL(@nMultiSKU_UCCQty, 0)

               SELECT @nLooseInvSKUQty = COUNT(DISTINCT LLI.SKU)
               FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
               WHERE LLI.StorerKey = @cStorerKey
               AND LLI.ID = @cID
               AND (LLI.Qty - LLI.QtyPicked - LLI.QtyPickInProcess > 0)
               AND NOT EXISTS (
                     SELECT 1 FROM dbo.UCC WITH(NOLOCK)
                     WHERE UCC.StorerKey = LLI.StorerKey
                        AND UCC.SKU = LLI.SKU
                        AND UCC.Lot = LLI.Lot
                        AND UCC.Loc = LLI.Loc
                        AND UCC.ID = LLI.ID
               )

               SET @nLooseInvSKUQty = ISNULL(@nLooseInvSKUQty, 0)

               -- Multiple SKU UCC
               IF @nMultiSKU_UCCQty > 0
               BEGIN
                  DELETE FROM #TempLocUCCQty
                  IF EXISTS(SELECT 1 FROM dbo.LOC LOC2 WITH(NOLOCK)
                           INNER JOIN dbo.LOTxLOCxID LLI2 WITH(NOLOCK) ON LLI2.Loc = LOC2.Loc AND LLI2.StorerKey = @cStorerKey
                           INNER JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK) ON LLI2.Lot = LA.Lot AND LLI2.StorerKey = LA.StorerKey AND LLI2.SKU = LA.SKU
                           WHERE LOC2.Facility = @cFacility
                              AND LOC2.Loc = @cPNDMEZZA
                              AND LOC2.NoMixLottable02 IN ('1', 'Y')
                              AND LA.Lottable02 <> @cLottable02
                              AND (LLI2.Qty - LLI2.QtyPicked - LLI2.QtyPickInProcess > 0 OR LLI2.PendingMoveIN + LLI2.QtyExpected > 0)
                           )
                  BEGIN
                     SET @nRowCount = 0
                     SET @cSuggLOC = ''
                  END
                  ELSE
                  BEGIN
                     INSERT INTO #TempLocUCCQty (LOC, LogicalLocation, MaxCarton, PendingMoveInUCCQty, UCCQty)
                     SELECT LOC.Loc, LOC.LogicalLocation, LOC.MaxCarton, COUNT(DISTINCT UCC2.UCCNo), COUNT(DISTINCT UCC.UCCNo)
                     FROM dbo.LOC WITH(NOLOCK)
                     LEFT JOIN LOTxLOCxID LLI WITH(NOLOCK) ON LLI.StorerKey = @cStorerKey AND LOC.Loc = LLI.Loc AND (LLI.Qty - LLI.QtyPicked > 0 OR LLI.PendingMoveIN > 0)
                     LEFT JOIN dbo.UCC WITH(NOLOCK) ON LOC.Loc = UCC.Loc AND UCC.StorerKey = @cStorerKey AND UCC.Status IN ('1', '3', '4')
                     LEFT JOIN dbo.RFPutaway RFP WITH(NOLOCK) ON LLI.StorerKey = RFP.StorerKey AND LLI.Loc = RFP.SuggestedLOC
                     LEFT JOIN dbo.UCC UCC2 WITH(NOLOCK) ON RFP.StorerKey = UCC2.StorerKey AND RFP.FromLOC = UCC2.Loc AND RFP.CaseID IS NOT NULL AND RFP.CaseID = UCC2.UCCNo AND RFP.SKU = UCC2.SKU
                     WHERE LOC.Facility = @cFacility
                        AND LOC.Loc = @cPNDMEZZA
                        AND LOC.Loc <> @cFromLOC
                        AND LOC.CommingleSku IN ('1', 'Y')
                     GROUP BY LOC.Loc, LOC.LogicalLocation, LOC.MaxCarton
                     ORDER BY LOC.LogicalLocation, LOC.Loc
                  END

                  SELECT TOP 1 @cSuggLOC = LOC.Loc
                  FROM dbo.LOC LOC WITH(NOLOCK)
                  INNER JOIN #TempLocUCCQty TU ON LOC.Loc = TU.Loc
                  WHERE LOC.Facility = @cFacility
                     AND IIF(LOC.MaxCarton = 0, 99999, LOC.MaxCarton) >= ISNULL(TU.UCCQty, 0) + ISNULL(TU.PendingMoveInUCCQty, 0) + @nUCCQty
                  ORDER BY LOC.LogicalLocation, LOC.Loc

                  SET @nRowCount = @@ROWCOUNT
               END

               -- Loose inventory
               IF @nLooseInvSKUQty > 0
               BEGIN
                  -- Single SKU
                  IF @nLooseInvSKUQty = 1
                  BEGIN
                     SELECT TOP 1 @cSKU = Sku
                     FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
                     WHERE LLI.StorerKey = @cStorerKey
                        AND LLI.ID = @cID
                        AND (LLI.Qty - LLI.QtyPicked - LLI.QtyPickInProcess > 0)
                     ORDER BY LLI.SKU, LLI.LOT

                     SELECT TOP 1 @cSuggLOC = LOC.Loc
                     FROM dbo.LOC WITH(NOLOCK)
                     WHERE LOC.Facility = @cFacility
                        AND LOC.Loc = @cPNDMEZZA
                        AND LOC.Loc <> @cFromLOC
                        -- Respect CommingleSKU rule
                        AND NOT EXISTS(
                              SELECT 1 FROM dbo.LOC LOC1 WITH(NOLOCK)
                              INNER JOIN dbo.LOTxLOCxID LLI1 WITH(NOLOCK) ON LLI1.Loc = LOC1.Loc AND LLI1.StorerKey = @cStorerKey
                              WHERE LOC1.Facility = @cFacility
                              AND LOC1.Loc = @cPNDMEZZA
                              AND LOC1.CommingleSku IN ('0', 'N')
                              AND LLI1.SKU <> @cSKU
                              AND (LLI1.Qty - LLI1.QtyPicked - LLI1.QtyPickInProcess > 0 OR LLI1.PendingMoveIN + LLI1.QtyExpected > 0)
                              AND LOC.Loc = LOC1.Loc
                        )
                        -- Respect NoMixLottable02 rule
                        AND NOT EXISTS(
                              SELECT 1 FROM dbo.LOC LOC2 WITH(NOLOCK)
                              INNER JOIN dbo.LOTxLOCxID LLI2 WITH(NOLOCK) ON LLI2.Loc = LOC2.Loc AND LLI2.StorerKey = @cStorerKey
                              INNER JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK) ON LLI2.Lot = LA.Lot AND LLI2.StorerKey = LA.StorerKey AND LLI2.SKU = LA.SKU
                              WHERE LOC2.Facility = @cFacility
                              AND LOC2.Loc = @cPNDMEZZA
                              AND LOC2.NoMixLottable02 IN ('1', 'Y')
                              AND LA.Lottable02 <> @cLottable02
                              AND (LLI2.Qty - LLI2.QtyPicked - LLI2.QtyPickInProcess > 0 OR LLI2.PendingMoveIN + LLI2.QtyExpected > 0)
                              AND LOC.Loc = LOC2.Loc
                        )
                     ORDER BY LOC.LogicalLocation, LOC.Loc

                     SET @nRowCount = @@ROWCOUNT
                  END
                  ELSE
                  BEGIN
                     SELECT TOP 1 @cSuggLOC = LOC.Loc
                     FROM dbo.LOC WITH(NOLOCK)
                     WHERE LOC.Facility = @cFacility
                        AND LOC.Loc = @cPNDMEZZA
                        AND LOC.Loc <> @cFromLOC
                        AND LOC.CommingleSku IN ('1', 'Y')
                        -- Respect NoMixLottable02 rule
                        AND NOT EXISTS(
                              SELECT 1 FROM dbo.LOC LOC2 WITH(NOLOCK)
                              INNER JOIN dbo.LOTxLOCxID LLI2 WITH(NOLOCK) ON LLI2.Loc = LOC2.Loc AND LLI2.StorerKey = @cStorerKey
                              INNER JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK) ON LLI2.Lot = LA.Lot AND LLI2.StorerKey = LA.StorerKey AND LLI2.SKU = LA.SKU
                              WHERE LOC2.Facility = @cFacility
                              AND LOC2.Loc = @cPNDMEZZA
                              AND LOC2.NoMixLottable02 IN ('1', 'Y')
                              AND LA.Lottable02 <> @cLottable02
                              AND (LLI2.Qty - LLI2.QtyPicked - LLI2.QtyPickInProcess > 0 OR LLI2.PendingMoveIN + LLI2.QtyExpected > 0)
                              AND LOC.Loc = LOC2.Loc
                        )
                     ORDER BY LOC.LogicalLocation, LOC.Loc

                     SET @nRowCount = @@ROWCOUNT
                  END
               END
            END
         END
      END
   END

   LOCK_LOC:
   IF ISNULL( @cSuggLOC, '') <> '' OR ISNULL(@cPickAndDropLOC, '') <> ''
   BEGIN
      DECLARE @cToLoc      NVARCHAR(10)
      SET @cToLoc = IIF(ISNULL(@cPickAndDropLOC, '') <> '', @cPickAndDropLOC, @cSuggLOC)
   
      -- Handling transaction
      SET @nTranCount = @@TRANCOUNT
      BEGIN TRAN  -- Begin our own transaction
      SAVE TRAN rdt_1819ExtPASP64 -- For rollback or commit only our own transaction
      
      EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK',
         @cFromLOC,
         @cID,
         @cToLoc,
         @cStorerKey,
         @nErrNo  OUTPUT,
         @cErrMsg OUTPUT,
         @nPABookingKey = @nPABookingKey OUTPUT

      IF @nErrNo <> 0
         GOTO RollBackTran
         
      COMMIT TRAN rdt_1819ExtPASP64
      
      GOTO Quit

      RollBackTran:
         ROLLBACK TRAN rdt_1819ExtPASP64 -- Only rollback change made here      
      Quit:
         WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started      
            COMMIT TRAN
   END
   ELSE
   BEGIN
      SET @nErrNo = -1
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1819ExtPASP64] TO NSQL
GO
