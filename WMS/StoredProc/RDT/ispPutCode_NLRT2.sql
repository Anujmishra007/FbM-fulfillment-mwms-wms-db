SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: ispPutCode_NLRT2                                    */
/* Copyright      : Maersk WMS                                          */
/* Customer       : NLRT2-ColdStore NL                                  */
/*                                                                      */
/* Purpose: Extended putaway strategy for NLRT2 coldstore (Fn 1819).    */
/*   Phase 1 (@c_ToLoc=''): returns SQL fragment to pre-filter          */
/*     candidate locations by per-location weight capacity.             */
/*     In debug mode returns '' so all candidates appear in trace.      */
/*   Phase 2 (@c_ToLoc<>''): validates the suggested location against   */
/*     beam-level weight capacity (CODELKUP BEAMCAP) and beam width.    */
/*     Re-checks per-location weight capacity as a short-circuit guard  */
/*     and to enforce the check when Phase 1 was bypassed (debug mode). */
/*                                                                      */
/* Configured in PUTAWAYSTRATEGYDETAIL.PutCode                          */
/* LocationFlagExclude (INACTIVE/DAMAGE/HOLD) is handled by             */
/* PA_CHECKRESTRICTIONS via CheckRestrictions=Y in strategy config.     */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2026-07-29   NLT013    1.0   FCR-14605 Created                       */
/************************************************************************/

CREATE OR ALTER PROCEDURE dbo.ispPutCode_NLRT2
    @n_PTraceHeadKey             NVARCHAR(10)
   ,@n_PTraceDetailKey           NVARCHAR(10)
   ,@c_PutawayStrategyKey        NVARCHAR(10)
   ,@c_PutawayStrategyLineNumber NVARCHAR(5)
   ,@c_StorerKey NVARCHAR(15)
   ,@c_SKU       NVARCHAR(20)
   ,@c_LOT       NVARCHAR(10)
   ,@c_FromLoc   NVARCHAR(10)
   ,@c_ID        NVARCHAR(18)
   ,@n_Qty       INT
   ,@c_ToLoc     NVARCHAR(10)
   ,@c_Param1    NVARCHAR(20)
   ,@c_Param2    NVARCHAR(20)
   ,@c_Param3    NVARCHAR(20)
   ,@c_Param4    NVARCHAR(20)
   ,@c_Param5    NVARCHAR(20)
   ,@b_debug     INT
   ,@c_SQL       NVARCHAR(1000) OUTPUT
   ,@b_RestrictionsPassed INT   OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @nRowCount         INT           = 0,
      @cReason          NVARCHAR(200) = '',
      @nPalletWgt        FLOAT         = 0,
      @nPalletWidth      FLOAT         = 0,
      @cFacility         NVARCHAR(5)   = '',
      @cLocRoom          NVARCHAR(30)  = '',
      @cLocLevel         INT           = 0,
      @cLocBay           NVARCHAR(10)  = '',
      @cLocAisle         NVARCHAR(10)  = '',
      @nLocWeightCap     FLOAT         = 0,
      @nBeamWeightCap    FLOAT         = 0,
      @nBeamWidth        FLOAT         = 0,
      @nOccupiedWeight   FLOAT         = 0,
      @nOccupiedWidth    FLOAT         = 0,
      @cBEAMCAP          NVARCHAR(10)  = 'BEAMCAP'

   -- Resolve incoming pallet weight and width
   SELECT 
      @nPalletWgt = ISNULL(GrossWgt, 0),
      @nPalletWidth = ISNULL(Width, 0)
   FROM dbo.PALLET WITH (NOLOCK)
   WHERE PalletKey = @c_ID
   SET @nRowCount = @@ROWCOUNT

   SET @nPalletWgt = ISNULL(@nPalletWgt, 0)
   SET @nPalletWidth = ISNULL(@nPalletWidth, 0)

   -- ID does not exist in PALLET table, Quit with @b_RestrictionsPassed = 0 to prevent putaway
   IF @nRowCount = 0
   BEGIN
      SET @c_SQL = 'AND 1 <> 1'  -- always false, so no candidate locations will be returned
      SET @b_RestrictionsPassed = 0
      GOTO Quit
   END

   IF @nPalletWgt = 0
   BEGIN
      SELECT 
         @nPalletWgt = ISNULL(SUM(ISNULL(SKU.STDGrossWgt, 0) * (LLI.Qty - LLI.QtyPicked)), 0)
      FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
      INNER JOIN dbo.SKU WITH (NOLOCK) ON LLI.SKU = SKU.SKU AND LLI.StorerKey = SKU.StorerKey
      WHERE LLI.ID = @c_ID
         AND LLI.StorerKey = @c_StorerKey
         AND LLI.Qty - LLI.QtyPicked > 0

      SET @nPalletWgt = ISNULL(@nPalletWgt, 0)
   END

   -- ---------------------------------------------------------------
   -- Phase 1: Pre-filter (called before location search, @c_ToLoc = '')
   -- ---------------------------------------------------------------
   IF @c_ToLoc = ''
   BEGIN
      IF @b_debug = 1
         -- Trace mode: no pre-filtering so all candidates appear in putaway trace
         SET @c_SQL = ''
      ELSE
         -- Pre-filter locations where per-location weight capacity is insufficient.
         SET @c_SQL = ' AND ISNULL(LOC.WeightCapacity,0) >= ' + CAST(@nPalletWgt AS NVARCHAR(30))
   END

   -- ---------------------------------------------------------------
   -- Phase 2: Beam-level validation (called after a location is suggested, @c_ToLoc <> '')
   -- ---------------------------------------------------------------
   IF @c_ToLoc <> ''
   BEGIN
      SET @b_RestrictionsPassed = 1

      -- Get beam coordinates and per-location weight capacity from suggested location
      SELECT
         @cFacility     = ISNULL(Facility, ''),
         @cLocRoom      = ISNULL(LocationRoom, ''),
         @cLocLevel     = ISNULL(LocLevel, 0),
         @cLocBay       = ISNULL(LocBay, ''),
         @cLocAisle     = ISNULL(LocAisle, ''),
         @nLocWeightCap = ISNULL(WeightCapacity, 0)
      FROM dbo.LOC WITH (NOLOCK)
      WHERE LOC = @c_ToLoc

      -- Check 1: Per-location weight capacity
      IF @nLocWeightCap < @nPalletWgt
      BEGIN
         IF @b_debug = 1
         BEGIN
            SET @cReason = 'FAILED ispPutCode_NLRT2: LocWeightCap=' +
               CAST(@nLocWeightCap AS NVARCHAR(20)) + ' < PalletWgt=' + CAST(@nPalletWgt AS NVARCHAR(20))
            EXEC nspPTD 'nspRDTPASTD', @n_PTraceHeadKey, @c_PutawayStrategyKey,
               @c_PutawayStrategyLineNumber, @n_PTraceDetailKey, @c_ToLoc, @cReason
         END
         SET @b_RestrictionsPassed = 0
      END
      ELSE
      BEGIN
         -- Look up beam weight capacity from CODELKUP: storer-specific first, then generic
         SELECT TOP 1 
            @nBeamWeightCap = ISNULL(TRY_CAST(UDF01 AS FLOAT), 0)
         FROM dbo.CODELKUP WITH (NOLOCK)
         WHERE ListName = @cBEAMCAP
           AND ISNULL(Code2, '') = @cFacility
           AND ISNULL(UDF02, '') = @cLocRoom
           AND ISNULL(UDF03, '') = CAST(@cLocLevel AS NVARCHAR(10))
           AND ISNULL(UDF04, '') = @cLocBay
           AND ISNULL(UDF05, '') = @cLocAisle
           AND StorerKey = @c_StorerKey
         ORDER BY Code
         SET @nRowCount = @@ROWCOUNT

         SET @nBeamWeightCap = ISNULL(@nBeamWeightCap, 0)

         IF @nRowCount = 0 OR @nBeamWeightCap = 0  -- no storer-specific entry, fall back to generic
         BEGIN
            SELECT TOP 1 @nBeamWeightCap = ISNULL(TRY_CAST(UDF01 AS FLOAT), 0)
            FROM dbo.CODELKUP WITH (NOLOCK)
            WHERE ListName = @cBEAMCAP
              AND ISNULL(Code2, '') = @cFacility
              AND ISNULL(UDF02, '') = @cLocRoom
              AND ISNULL(UDF03, '') = CAST(@cLocLevel AS NVARCHAR(10))
              AND ISNULL(UDF04, '') = @cLocBay
              AND ISNULL(UDF05, '') = @cLocAisle
              AND StorerKey = ''
            ORDER BY Code
            SET @nRowCount = @@ROWCOUNT

            SET @nBeamWeightCap = ISNULL(@nBeamWeightCap, 0) 
         END

         -- No BEAMCAP entry found for this beam, or weight capacity is zero, fail the check
         IF @nRowCount = 0 OR @nBeamWeightCap = 0
         BEGIN
            IF @b_debug = 1
            BEGIN
               SET @cReason = 'FAILED ispPutCode_NLRT2: No BEAMCAP entry found for Facility=' + @cFacility +
                  ' LocRoom=' + @cLocRoom + ' LocLevel=' + CAST(@cLocLevel AS NVARCHAR(10))
               EXEC nspPTD 'nspRDTPASTD', @n_PTraceHeadKey, @c_PutawayStrategyKey,
                  @c_PutawayStrategyLineNumber, @n_PTraceDetailKey, @c_ToLoc, @cReason
            END
            SET @b_RestrictionsPassed = 0
            GOTO Quit
         END

         -- Calculate total beam width: SUM(LOC.Width) for all locations on this beam
         SELECT @nBeamWidth = ISNULL(SUM(ISNULL(Width, 0)), 0)
         FROM dbo.LOC WITH (NOLOCK)
         WHERE Facility = @cFacility
           AND ISNULL(LocationRoom, '') = @cLocRoom
           AND ISNULL(LocLevel, 0)     = @cLocLevel
           AND ISNULL(LocBay, '')      = @cLocBay
           AND ISNULL(LocAisle, '')    = @cLocAisle
         SET @nBeamWidth = ISNULL(@nBeamWidth, 0)

         -- Collect distinct pallet IDs on the beam (current qty + pending move-in),
         -- excluding the incoming pallet itself.
         IF OBJECT_ID('tempdb..#tBeamPallets_NLRT2') IS NOT NULL
            DROP TABLE #tBeamPallets_NLRT2

         CREATE TABLE #tBeamPallets_NLRT2 (
            PalletID  NVARCHAR(18) NOT NULL,
            GrossWgt  FLOAT        NOT NULL DEFAULT 0,
            Width     FLOAT        NOT NULL DEFAULT 0
         )

         INSERT INTO #tBeamPallets_NLRT2 (PalletID, GrossWgt, Width)
         SELECT DISTINCT 
            LLI.ID, ISNULL(PL.GrossWgt, 0), ISNULL(PL.Width, 0)
         FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
         INNER JOIN dbo.LOC WITH (NOLOCK) ON LOC.LOC = LLI.LOC
         INNER JOIN dbo.PALLET PL WITH (NOLOCK) ON PL.PalletKey = LLI.ID
         WHERE LOC.Facility = @cFacility
           AND ISNULL(LOC.LocationRoom, '') = @cLocRoom
           AND ISNULL(LOC.LocLevel, 0)     = @cLocLevel
           AND ISNULL(LOC.LocBay, '')      = @cLocBay
           AND ISNULL(LOC.LocAisle, '')    = @cLocAisle
           AND (LLI.Qty - LLI.QtyPicked > 0 OR LLI.PendingMoveIn > 0)
           AND LLI.ID <> @c_ID

         -- For pallets where GrossWgt = 0, calculate weight from inventory
         UPDATE #tBeamPallets_NLRT2
         SET GrossWgt = ISNULL((
            SELECT SUM(ISNULL(SKU.STDGrossWgt, 0) * (LLI.Qty - LLI.QtyPicked))
            FROM LOTxLOCxID LLI WITH (NOLOCK)
            JOIN SKU WITH (NOLOCK) ON LLI.SKU = SKU.SKU AND LLI.StorerKey = SKU.StorerKey
            WHERE LLI.ID = PalletID
               AND LLI.Qty - LLI.QtyPicked > 0
         ), 0)
         WHERE GrossWgt = 0

         SELECT
            @nOccupiedWeight = ISNULL(SUM(GrossWgt), 0),
            @nOccupiedWidth  = ISNULL(SUM(Width), 0)
         FROM #tBeamPallets_NLRT2

         DROP TABLE #tBeamPallets_NLRT2

         -- Check 2: Beam width — only enforce when pallet width is maintained
         IF @nPalletWidth > 0 AND @nBeamWidth > 0 AND (@nBeamWidth - @nOccupiedWidth) < @nPalletWidth
         BEGIN
            IF @b_debug = 1
            BEGIN
               SET @cReason = 'FAILED ispPutCode_NLRT2: BeamWidthResidual=' +
                  CAST((@nBeamWidth - @nOccupiedWidth) AS NVARCHAR(20)) + ' < PalletWidth=' + CAST(@nPalletWidth AS NVARCHAR(20))
               EXEC nspPTD 'nspRDTPASTD', @n_PTraceHeadKey, @c_PutawayStrategyKey,
                  @c_PutawayStrategyLineNumber, @n_PTraceDetailKey, @c_ToLoc, @cReason
            END
            SET @b_RestrictionsPassed = 0
            GOTO Quit
         END

         -- Check 3: Beam weight capacity — only enforce when a BEAMCAP entry was found
         IF @nPalletWgt > 0 AND @nBeamWeightCap > 0 AND (@nBeamWeightCap - @nOccupiedWeight) < @nPalletWgt
         BEGIN
            IF @b_debug = 1
            BEGIN
               SET @cReason = 'FAILED ispPutCode_NLRT2: BeamWgtResidual=' +
                  CAST((@nBeamWeightCap - @nOccupiedWeight) AS NVARCHAR(20)) + ' < PalletWgt=' + CAST(@nPalletWgt AS NVARCHAR(20))
               EXEC nspPTD 'nspRDTPASTD', @n_PTraceHeadKey, @c_PutawayStrategyKey,
                  @c_PutawayStrategyLineNumber, @n_PTraceDetailKey, @c_ToLoc, @cReason
            END
            SET @b_RestrictionsPassed = 0
            GOTO Quit
         END

         IF @b_debug = 1
         BEGIN
            SET @cReason = 'PASSED ispPutCode_NLRT2: BeamWgtResidual=' +
               CAST((@nBeamWeightCap - @nOccupiedWeight) AS NVARCHAR(20)) +
               ' PalletWgt=' + CAST(@nPalletWgt AS NVARCHAR(20)) +
               ' BeamWidthResidual=' + CAST((@nBeamWidth - @nOccupiedWidth) AS NVARCHAR(20)) +
               ' PalletWidth=' + CAST(@nPalletWidth AS NVARCHAR(20))
            EXEC nspPTD 'nspRDTPASTD', @n_PTraceHeadKey, @c_PutawayStrategyKey,
               @c_PutawayStrategyLineNumber, @n_PTraceDetailKey, @c_ToLoc, @cReason
         END
      END -- ELSE Check 1 passed
   END -- IF @c_ToLoc <> ''

   Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON dbo.ispPutCode_NLRT2 TO NSQL
GO
