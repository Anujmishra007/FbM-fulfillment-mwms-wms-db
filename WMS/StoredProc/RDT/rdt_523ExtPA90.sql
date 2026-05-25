SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_523ExtPA90                                            */
/* Copyright: Maersk                                                          */
/* Customer : AMERICAN EAGLE                                                  */
/*                                                                            */
/* Customer: DAIMLER TRUCK AG                                                 */
/*                                                                            */
/* Date        Rev    Author    Purposes                                      */
/* 2026-05-21  1.0.0  NickT     FCR-12892. Created                            */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_523ExtPA90] (
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

   DECLARE
      @nRowCount                 INT,
      @nTranCount                INT,
      @cLottable02               NVARCHAR( 18),
      @cDamagePutawayZone        NVARCHAR( 10) = 'AEOMX_DAM',
      @cDYNPPICK                 NVARCHAR( 10) = 'DYNPPICK',
      @cAEOMX_MEZ                NVARCHAR( 10) = 'AEOMX_MEZ',
      @fSKUCube                  FLOAT

   SET @cSuggestedLOC = ''
   SET @nPABookingKey = 0
   SET @nErrNo = 0
   SET @cErrMsg = ''

   IF OBJECT_ID('tempdb..#TempLocCube') IS NOT NULL
      DROP TABLE #TempLocCube

   CREATE TABLE #TempLocCube (
      RowRefID                INT IDENTITY(1,1) PRIMARY KEY,
      LOC                     NVARCHAR(10),
      LogicalLocation         NVARCHAR(18),
      LocCube                 FLOAT
   )

   CREATE NONCLUSTERED INDEX IX_TempLocCube_LOC
   ON #TempLocCube( LOC )

   IF OBJECT_ID('tempdb..#TempLocOccupiedCube') IS NOT NULL
      DROP TABLE #TempLocOccupiedCube
   CREATE TABLE #TempLocOccupiedCube (
      RowRefID                INT IDENTITY(1,1),
      LOC                     NVARCHAR(10),
      LogicalLocation         NVARCHAR(18),
      LocOccupiedCube         FLOAT
   )

   CREATE NONCLUSTERED INDEX IX_TempLocOccupiedCube_LOC
   ON #TempLocOccupiedCube( LOC )
   
   SELECT TOP 1 @cLottable02 = Lottable02
   FROM dbo.LOTATTRIBUTE WITH(NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND Sku = @cSKU
      AND Lot = @cLOT

   SET @cLottable02 = UPPER(ISNULL(@cLottable02, ''))

   -- If the SKU is damaged, 
   -- 1. find an empty location with putawayzone = 'AEOMX_DAM' first
   -- 2. if not found, find an location with putawayzone = 'AEOMX_DAM' and with available capacity
   IF @cLottable02 = 'DAM'
   BEGIN
      -- 1. Find an empty location in damage area to put the UCC
      SET @cSuggestedLOC = ''
      SELECT TOP 1 @cSuggestedLOC = LOC.Loc
      FROM dbo.LOC WITH(NOLOCK)
      WHERE LOC.Facility = @cFacility
         AND LOC.PutawayZone = @cDamagePutawayZone
         AND LOC.Loc <> @cLOC
         AND NOT EXISTS (SELECT 1 FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
                        INNER JOIN dbo.LOC LOC1 WITH(NOLOCK) ON LLI.Loc = LOC1.Loc AND LOC1.PutawayZone = @cDamagePutawayZone
                        WHERE LLI.StorerKey = @cStorerKey 
                           AND (LLI.Qty - LLI.QtyPicked - LLI.QTYPickInProcess > 0 OR LLI.PendingMoveIN > 0 OR LLI.QTYExpected > 0)
                           AND LOC.Loc = LOC1.Loc)
      ORDER BY LOC.LogicalLocation, LOC.Loc
      SELECT @nRowCount = @@ROWCOUNT

      -- 2. Find the top 1 location in damage area, do not consider the available capacity here
      IF @nRowCount = 0 OR ISNULL(@cSuggestedLOC, '') = ''
      BEGIN
         SET @cSuggestedLOC = ''
         SELECT TOP 1 @cSuggestedLOC = Loc
         FROM dbo.LOC WITH(NOLOCK)
         WHERE LOC.Facility = @cFacility
            AND LOC.Loc <> @cLOC
            AND LOC.PutawayZone = @cDamagePutawayZone
            AND NOT EXISTS(SELECT 1 FROM dbo.LOC LOC1 WITH(NOLOCK)
                        INNER JOIN dbo.LOTxLOCxID LLI1 WITH(NOLOCK) ON LLI1.Loc = LOC1.Loc AND LLI1.StorerKey = @cStorerKey
                        WHERE LOC1.Facility = @cFacility
                           AND LOC1.PutawayZone = @cDamagePutawayZone
                           AND LOC1.CommingleSku IN ( '0', 'N' )
                           AND LLI1.SKU <> @cSKU
                           AND (LLI1.Qty - LLI1.QtyPicked - LLI1.QtyPickInProcess > 0 OR LLI1.PendingMoveIN + LLI1.QtyExpected > 0)
                           AND LOC.Loc = LOC1.Loc
                        )
         AND NOT EXISTS(SELECT 1 FROM dbo.LOC LOC2 WITH(NOLOCK)
                        INNER JOIN dbo.LOTxLOCxID LLI2 WITH(NOLOCK) ON LLI2.Loc = LOC2.Loc AND LLI2.StorerKey = @cStorerKey
                        INNER JOIN LOTATTRIBUTE LA WITH(NOLOCK) ON LLI2.Lot = LA.Lot AND LLI2.StorerKey = LA.StorerKey
                        WHERE LOC2.Facility = @cFacility
                           AND LOC2.PutawayZone = @cDamagePutawayZone
                           AND LOC2.NoMixLottable02 IN ( '1', 'Y' )
                           AND LA.Lottable02 <> @cLottable02
                           AND (LLI2.Qty - LLI2.QtyPicked - LLI2.QtyPickInProcess > 0 OR LLI2.PendingMoveIN + LLI2.QtyExpected > 0)
                           AND LOC.Loc = LOC2.Loc
                        )
         ORDER BY LogicalLocation, Loc
         SELECT @nRowCount = @@ROWCOUNT
      END
   END
   -- 1. Home location (PICKFACE)
   -- 2. Dynamic location with inventory
   -- 3. Empty dynamic location
   ELSE IF @cLottable02 = 'GOO'
   BEGIN
      -- Get the cubic capacity of the putaway inventory
      SELECT @fSKUCube = ISNULL(Pack.CubeUOM3, 0) * @nQTY
      FROM dbo.SKU WITH(NOLOCK)
      INNER JOIN dbo.Pack WITH(NOLOCK)
         ON Pack.PackKey = SKU.PackKey
      WHERE SKU.StorerKey = @cStorerKey
         AND SKU.SKU = @cSKU
      -- 1. Find the home location (PICKFACE) first, the home location has available capacity

      -- Get the cubic capacity of all home locations
      DELETE FROM #TempLocCube

      INSERT INTO #TempLocCube (LOC, LogicalLocation, LocCube)
      SELECT DISTINCT LOC.Loc, LOC.LogicalLocation, LOC.CubicCapacity
      FROM dbo.LOC WITH(NOLOCK)
      INNER JOIN dbo.SKUxLOC SL WITH(NOLOCK) 
         ON SL.StorerKey = @cStorerKey 
         AND SL.SKU = @cSKU
         AND SL.LocationType = @cDYNPPICK
         AND SL.Loc = LOC.Loc
      WHERE LOC.Facility = @cFacility
         AND LOC.Loc <> @cLOC
         AND LOC.LocationCategory = @cAEOMX_MEZ
         AND NOT EXISTS(SELECT 1 FROM dbo.LOC LOC1 WITH(NOLOCK)
                        INNER JOIN dbo.LOTxLOCxID LLI1 WITH(NOLOCK) ON LLI1.Loc = LOC1.Loc AND LLI1.StorerKey = @cStorerKey
                        WHERE LOC1.Facility = @cFacility
                           AND LOC1.LocationCategory = @cAEOMX_MEZ
                           AND LOC1.CommingleSku IN ( '0', 'N' )
                           AND LLI1.SKU <> @cSKU
                           AND (LLI1.Qty - LLI1.QtyPicked - LLI1.QtyPickInProcess > 0 OR LLI1.PendingMoveIN + LLI1.QtyExpected > 0)
                           AND LOC.Loc = LOC1.Loc
                        )
         AND NOT EXISTS(SELECT 1 FROM dbo.LOC LOC2 WITH(NOLOCK)
                        INNER JOIN dbo.LOTxLOCxID LLI2 WITH(NOLOCK) ON LLI2.Loc = LOC2.Loc AND LLI2.StorerKey = @cStorerKey
                        INNER JOIN LOTATTRIBUTE LA WITH(NOLOCK) ON LLI2.Lot = LA.Lot AND LLI2.StorerKey = LA.StorerKey
                        WHERE LOC2.Facility = @cFacility
                           AND LOC2.LocationCategory = @cAEOMX_MEZ
                           AND LOC2.NoMixLottable02 IN ( '1', 'Y' )
                           AND LA.Lottable02 <> @cLottable02
                           AND (LLI2.Qty - LLI2.QtyPicked - LLI2.QtyPickInProcess > 0 OR LLI2.PendingMoveIN + LLI2.QtyExpected > 0)
                           AND LOC.Loc = LOC2.Loc
                        )
      ORDER BY LOC.LogicalLocation, LOC.Loc

      -- Get the occupied cubic capacity of all home locations
      DELETE FROM #TempLocOccupiedCube

      INSERT INTO #TempLocOccupiedCube (LOC, LogicalLocation, LocOccupiedCube)
      SELECT LOC.Loc, LOC.LogicalLocation, SUM( Pack.CubeUOM3 * ISNULL((LLI.Qty - LLI.QtyPicked - LLI.QTYPickInProcess + LLI.PendingMoveIN + LLI.QTYExpected), 0) )
      FROM dbo.LOC WITH(NOLOCK)
      INNER JOIN dbo.SKUxLOC SL WITH(NOLOCK) 
         ON SL.StorerKey = @cStorerKey 
         AND SL.SKU = @cSKU
         AND SL.LocationType = @cDYNPPICK
         AND SL.Loc = LOC.Loc
      INNER JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK)
         ON LLI.Loc = LOC.Loc
         AND LLI.StorerKey = @cStorerKey
      INNER JOIN dbo.SKU WITH(NOLOCK)
         ON SKU.StorerKey = LLI.StorerKey
         AND SKU.SKU = LLI.SKU
      INNER JOIN dbo.Pack WITH(NOLOCK)
         ON Pack.PackKey = SKU.PackKey
      WHERE LOC.Facility = @cFacility
         AND LOC.Loc <> @cLOC
         AND SKU.StorerKey = @cStorerKey
         AND ( LLI.Qty - LLI.QtyPicked - LLI.QTYPickInProcess > 0 OR LLI.PendingMoveIN + LLI.QTYExpected > 0 )
         AND LOC.LocationCategory = @cAEOMX_MEZ
      GROUP BY LOC.Loc, LOC.LogicalLocation
      ORDER BY LOC.LogicalLocation, LOC.Loc

      SET @cSuggestedLOC = ''
      SELECT TOP 1 @cSuggestedLOC = TLC.LOC
      FROM #TempLocCube TLC
      LEFT JOIN #TempLocOccupiedCube TLOC
         ON TLOC.LOC = TLC.LOC
      WHERE TLC.LocCube >= ISNULL(TLOC.LocOccupiedCube, 0) + @fSKUCube
      ORDER BY TLC.RowRefID

      SELECT @nRowCount = @@ROWCOUNT

      -- 2. Dynamic location with same SKU
      -- If no home location found, find the dynamic location with same SKU, and the available capacity should considered here
      IF @nRowCount = 0 OR @cSuggestedLOC = ''
      BEGIN
         DELETE FROM #TempLocCube

         INSERT INTO #TempLocCube (LOC, LogicalLocation, LocCube)
         SELECT DISTINCT LOC.Loc, LOC.LogicalLocation, LOC.CubicCapacity
         FROM dbo.LOC WITH(NOLOCK)
         INNER JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK)
            ON LLI.Loc = LOC.Loc
            AND LLI.StorerKey = @cStorerKey
         INNER JOIN dbo.SKU WITH(NOLOCK)
            ON SKU.StorerKey = LLI.StorerKey
            AND SKU.SKU = LLI.SKU
         INNER JOIN dbo.Pack WITH(NOLOCK)
            ON Pack.PackKey = SKU.PackKey
         WHERE LOC.Facility = @cFacility
            AND SKU.StorerKey = @cStorerKey
            AND SKU.SKU = @cSKU
            AND LOC.Loc <> @cLOC
            AND LOC.LocationCategory = @cAEOMX_MEZ
            AND (LLI.Qty - LLI.QtyPicked - LLI.QTYPickInProcess > 0 OR LLI.PendingMoveIN + LLI.QTYExpected > 0)
            AND NOT EXISTS(SELECT 1 FROM dbo.LOC LOC1 WITH(NOLOCK)
                        INNER JOIN dbo.LOTxLOCxID LLI1 WITH(NOLOCK) ON LLI1.Loc = LOC1.Loc AND LLI1.StorerKey = @cStorerKey
                        WHERE LOC1.Facility = @cFacility
                           AND LOC1.LocationCategory = @cAEOMX_MEZ
                           AND LOC1.CommingleSku IN ( '0', 'N' )
                           AND LLI1.SKU <> @cSKU
                           AND (LLI1.Qty - LLI1.QtyPicked - LLI1.QtyPickInProcess > 0 OR LLI1.PendingMoveIN + LLI1.QtyExpected > 0)
                           AND LOC.Loc = LOC1.Loc
                        )
            AND NOT EXISTS(SELECT 1 FROM dbo.LOC LOC2 WITH(NOLOCK)
                        INNER JOIN dbo.LOTxLOCxID LLI2 WITH(NOLOCK) ON LLI2.Loc = LOC2.Loc AND LLI2.StorerKey = @cStorerKey
                        INNER JOIN LOTATTRIBUTE LA WITH(NOLOCK) ON LLI2.Lot = LA.Lot AND LLI2.StorerKey = LA.StorerKey
                        WHERE LOC2.Facility = @cFacility
                           AND LOC2.LocationCategory = @cAEOMX_MEZ
                           AND LOC2.NoMixLottable02 IN ( '1', 'Y' )
                           AND LA.Lottable02 <> @cLottable02
                           AND (LLI2.Qty - LLI2.QtyPicked - LLI2.QtyPickInProcess > 0 OR LLI2.PendingMoveIN + LLI2.QtyExpected > 0)
                           AND LOC.Loc = LOC2.Loc
                        )
         ORDER BY LOC.LogicalLocation, LOC.Loc

         -- Get the occupied cubic capacity of all dynamic locations with same SKU
         DELETE FROM #TempLocOccupiedCube

         INSERT INTO #TempLocOccupiedCube (LOC, LogicalLocation, LocOccupiedCube)
         SELECT LOC.Loc, LOC.LogicalLocation, SUM( Pack.CubeUOM3 * ISNULL((LLI.Qty - LLI.QtyPicked - LLI.QTYPickInProcess + LLI.PendingMoveIN + LLI.QTYExpected), 0) )
         FROM dbo.LOC WITH(NOLOCK)
         INNER JOIN #TempLocCube AS TLC
            ON TLC.LOC = LOC.Loc
         INNER JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK)
            ON LLI.Loc = LOC.Loc
            AND LLI.StorerKey = @cStorerKey
            AND ( LLI.Qty - LLI.QtyPicked - LLI.QTYPickInProcess > 0 OR LLI.PendingMoveIN + LLI.QTYExpected > 0 )
         INNER JOIN dbo.SKU WITH(NOLOCK)
            ON SKU.StorerKey = LLI.StorerKey
            AND SKU.SKU = LLI.SKU
         INNER JOIN dbo.Pack WITH(NOLOCK)
            ON Pack.PackKey = SKU.PackKey
         GROUP BY LOC.Loc, LOC.LogicalLocation
         ORDER BY LOC.LogicalLocation, LOC.Loc

         SET @cSuggestedLOC = ''
         SELECT TOP 1 @cSuggestedLOC = TLC.LOC
         FROM #TempLocCube TLC
         LEFT JOIN #TempLocOccupiedCube TLOC
            ON TLOC.LOC = TLC.LOC
         WHERE TLC.LocCube >= ISNULL(TLOC.LocOccupiedCube, 0) + @fSKUCube
         ORDER BY TLC.RowRefID

         SELECT @nRowCount = @@ROWCOUNT
      END

      -- 3. Empty dynamic location
      -- If no dynamic location with inventory found, find the empty dynamic location(may exist coming putaway inventory), and should consider the available capacity here
      IF @nRowCount = 0 OR @cSuggestedLOC = ''
      BEGIN
         DECLARE @cBUSR2 NVARCHAR(30)
         SELECT @cBUSR2 = BUSR2
         FROM dbo.SKU WITH(NOLOCK)
         WHERE SKU.StorerKey = @cStorerKey
            AND SKU.SKU = @cSKU

         -- Get the cubic capacity of all Empty dynamic locations
         DELETE FROM #TempLocCube

         INSERT INTO #TempLocCube (LOC, LogicalLocation, LocCube)
         SELECT DISTINCT LOC.Loc, LOC.LogicalLocation, LOC.CubicCapacity
         FROM dbo.LOC WITH(NOLOCK)
         WHERE LOC.Facility = @cFacility
            AND LOC.Loc <> @cLOC
            AND LOC.LocationCategory = @cAEOMX_MEZ
            AND LOC.SectionKey = ISNULL(@cBUSR2, '')
            AND NOT EXISTS(SELECT 1 FROM dbo.LOC LOC1 WITH(NOLOCK)
                        INNER JOIN dbo.LOTxLOCxID LLI1 WITH(NOLOCK) ON LLI1.Loc = LOC1.Loc AND LLI1.StorerKey = @cStorerKey
                        WHERE LOC1.Facility = @cFacility
                           AND LOC1.LocationCategory = @cAEOMX_MEZ
                           AND LOC1.CommingleSku IN ( '0', 'N' )
                           AND LLI1.SKU <> @cSKU
                           AND (LLI1.Qty - LLI1.QtyPicked - LLI1.QtyPickInProcess > 0 OR LLI1.PendingMoveIN + LLI1.QtyExpected > 0)
                           AND LOC.Loc = LOC1.Loc
                        )
            AND NOT EXISTS(SELECT 1 FROM dbo.LOC LOC2 WITH(NOLOCK)
                        INNER JOIN dbo.LOTxLOCxID LLI2 WITH(NOLOCK) ON LLI2.Loc = LOC2.Loc AND LLI2.StorerKey = @cStorerKey
                        INNER JOIN LOTATTRIBUTE LA WITH(NOLOCK) ON LLI2.Lot = LA.Lot AND LLI2.StorerKey = LA.StorerKey
                        WHERE LOC2.Facility = @cFacility
                           AND LOC2.LocationCategory = @cAEOMX_MEZ
                           AND LOC2.NoMixLottable02 IN ( '1', 'Y' ) 
                           AND LA.Lottable02 <> @cLottable02
                           AND (LLI2.Qty - LLI2.QtyPicked - LLI2.QtyPickInProcess > 0 OR LLI2.PendingMoveIN + LLI2.QtyExpected > 0)
                           AND LOC.Loc = LOC2.Loc
                        )
            AND NOT EXISTS(SELECT 1 FROM dbo.LOC LOC3 WITH(NOLOCK)
                        INNER JOIN dbo.LOTxLOCxID LLI3 WITH(NOLOCK) ON LLI3.Loc = LOC3.Loc AND LLI3.StorerKey = @cStorerKey
                        WHERE LOC3.Facility = @cFacility
                           AND LOC3.LocationCategory = @cAEOMX_MEZ
                           AND (LLI3.Qty - LLI3.QtyPicked - LLI3.QtyPickInProcess > 0)
                           AND LOC.Loc = LOC3.Loc
                        )
         ORDER BY LOC.LogicalLocation, LOC.Loc

         -- Get the occupied cubic capacity of all Empty dynamic locations
         DELETE FROM #TempLocOccupiedCube

         INSERT INTO #TempLocOccupiedCube (LOC, LogicalLocation, LocOccupiedCube)
         SELECT LOC.Loc, LOC.LogicalLocation, SUM( Pack.CubeUOM3 * ISNULL((LLI.PendingMoveIN + LLI.QTYExpected), 0) )
         FROM dbo.LOC WITH(NOLOCK)
         INNER JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK)
            ON LLI.Loc = LOC.Loc
            AND LLI.StorerKey = @cStorerKey
         INNER JOIN dbo.SKU WITH(NOLOCK)
            ON SKU.StorerKey = LLI.StorerKey
            AND SKU.SKU = LLI.SKU
         INNER JOIN dbo.Pack WITH(NOLOCK)
            ON Pack.PackKey = SKU.PackKey
         WHERE LOC.Facility = @cFacility
            AND LLI.Qty - LLI.QtyPicked - LLI.QTYPickInProcess = 0
            AND LLI.PendingMoveIN + LLI.QTYExpected > 0
            AND SKU.StorerKey = @cStorerKey
            AND LOC.Loc <> @cLOC
            AND LOC.LocationCategory = @cAEOMX_MEZ
            AND LOC.SectionKey = ISNULL(@cBUSR2, '')
         GROUP BY LOC.Loc, LOC.LogicalLocation
         ORDER BY LOC.LogicalLocation, LOC.Loc

         SET @cSuggestedLOC = ''
         SELECT TOP 1 @cSuggestedLOC = TLC.LOC
         FROM #TempLocCube TLC
         LEFT JOIN #TempLocOccupiedCube TLOC
            ON TLOC.LOC = TLC.LOC
         WHERE TLC.LocCube >= ISNULL(TLOC.LocOccupiedCube, 0) + @fSKUCube
         ORDER BY TLC.RowRefID

         SELECT @nRowCount = @@ROWCOUNT
      END
   END
   -- ELSE
   -- BEGIN
   --    -- Suggest LOC
   --    EXEC @nErrNo = [dbo].[nspRDTPASTD]
   --         @c_userid          = 'RDT'
   --       , @c_storerkey       = @cStorerKey
   --       , @c_lot             = @cLOT
   --       , @c_sku             = @cSKU
   --       , @c_id              = @cID
   --       , @c_fromloc         = @cLOC
   --       , @n_qty             = @nQTY
   --       , @c_uom             = '' -- not used
   --       , @c_packkey         = '' -- optional, if pass-in SKU
   --       , @n_putawaycapacity = 0
   --       , @c_final_toloc     = @cSuggestedLOC OUTPUT
   -- END

   /*-------------------------------------------------------------------------------
                                 Book suggested location
   -------------------------------------------------------------------------------*/
   BOOK_LOC:
   SET @nTranCount = @@TRANCOUNT
   IF ISNULL( @cSuggestedLOC, '') = ''
   BEGIN
      SET @cSuggestedLOC = ''
      SET @nErrNo = -1
   END
   ELSE
   BEGIN
      -- Handling transaction
      BEGIN TRAN  -- Begin our own transaction
      SAVE TRAN rdt_523ExtPA90 -- For rollback or commit only our own transaction

      IF ISNULL(@cSuggestedLOC,'') <> ''
      BEGIN
         EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK'
            ,@cLOC
            ,@cID
            ,@cSuggestedLOC
            ,@cStorerKey
            ,@nErrNo  OUTPUT
            ,@cErrMsg OUTPUT
            ,@cSKU          = @cSKU
            ,@nPutawayQTY   = @nQTY
            ,@nPABookingKey = @nPABookingKey OUTPUT

         IF @nErrNo <> 0
            GOTO RollBackTran
      END
      COMMIT TRAN rdt_523ExtPA90 -- Only commit change made here
   END
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_523ExtPA90 -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  [RDT].[rdt_523ExtPA90] TO [NSQL]
GO
