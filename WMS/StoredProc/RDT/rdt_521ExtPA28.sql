SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_521ExtPA28                                      */
/*                                                                      */
/* Purpose: Get suggested loc                                           */
/*                                                                      */
/* Chile - Maersk WMS v2 - PUMA - Directed Putaway                      */
/*                                                                      */
/* Called from: rdt_UCCPutaway_GetSuggestLOC                            */
/*                                                                      */
/* Date         Rev  Author   Purposes                                  */
/* 28-May-2026  1.0  ELB012   UWP-57058                                 */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_521ExtPA28] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR(3),
   @cUserName        NVARCHAR(18),
   @cStorerKey       NVARCHAR(15),
   @cFacility        NVARCHAR(5),
   @cLOC             NVARCHAR(10),
   @cID              NVARCHAR(18),
   @cLOT             NVARCHAR(10),
   @cUCC             NVARCHAR(20),
   @cSKU             NVARCHAR(20),
   @nQty             INT,
   @cSuggestedLOC    NVARCHAR(10) OUTPUT,
   @cPickAndDropLoc  NVARCHAR(10) OUTPUT,
   @nPABookingKey    INT          OUTPUT,
   @nErrNo           INT          OUTPUT,
   @cErrMsg          NVARCHAR(20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET XACT_ABORT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cPAZone           NVARCHAR(10),
      @cStgPAZone        NVARCHAR(10),
      @cBuffPAZone       NVARCHAR(10),
      @cMZ1PALocCfg      NVARCHAR(10),
      @cMZ2PALocCfg      NVARCHAR(10),
      @cMZ3PALocCfg      NVARCHAR(10),
      @cMZ4PALocCfg      NVARCHAR(10),
      @cRackPALocCfg     NVARCHAR(10),
      @cLocTypeCfgZone   NVARCHAR(20),
      @cLocPaZone        NVARCHAR(20),
      @cSKUPaZone        NVARCHAR(20),
      @cInvStatus        NVARCHAR(10),
      @cRespectiveBuffer NVARCHAR(10),
      @cLocBufferSugg    NVARCHAR(10),
      @cLocHSSugg        NVARCHAR(10),
      @cLocMezSugg       NVARCHAR(10),
      @cLocRackSugg      NVARCHAR(10),
      @cLocDinSugg       NVARCHAR(10),
      @nMaxHsperFloor    INT,
      @nLocMezFloor      INT,
      @cIsUCCFullPack    INT,
      @nCountEAinHL      INT,
      @nCountUCCinHS     INT,
      @nCartonAvlinHS    INT,
      @nCartonAvlinDin   INT,
      @nCountUCCinBuffer INT,
      @nSumEAinBuffer    INT,
      @nSumAvlEaInHL     INT,
      @nSumAvlPackHL     INT,
      @nCountUCCinRack   INT,
      @nPackCaseCnt      INT,
      @nRackCapacity     INT,
      @nDinCapacity      INT,
      @nIsRepleLoc       INT,
      @nIsStage          INT,
      @nIsBuffer         INT,
      @nIsHS             INT,
      @nTranCount        INT,
      @StartedTran       BIT = 0

   SET @cSuggestedLOC = ''
   SET @cPAZone = ''
   SET @cPickAndDropLoc = ''
   SET @nPABookingKey = 0
   SET @nTranCount = @@TRANCOUNT

   -- ===============================================================================
   -- UCC single or multi SKU - only allowed single sku
   -- ===============================================================================

   IF NOT EXISTS (
      SELECT 1
      FROM dbo.UCC WITH(NOLOCK)
      WHERE UCCNO = @cUCC
        AND STATUS IN ('1', '3')
        AND Storerkey = @cStorerKey
      GROUP BY UCCNO
   )
   BEGIN
      SET @cSuggestedLOC = ''
      SET @nErrNo = 253568
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --253568^ucc not found
      GOTO Quit
   END

   IF EXISTS (
      SELECT 1
      FROM dbo.UCC WITH(NOLOCK)
      WHERE UCCNO = @cUCC
        AND STATUS IN ('1', '3')
        AND Storerkey = @cStorerKey
      GROUP BY UCCNO
      HAVING COUNT(DISTINCT SKU) > 1
   )
   BEGIN
      SET @cSuggestedLOC = ''
      SET @nErrNo = 253569
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --253569^N Mix SKU UCC
      GOTO Quit
   END

   -- ===============================================================================
   -- From Loc Info
   -- ===============================================================================

   SELECT TOP 1 @cLocPaZone = ISNULL(PutawayZone, '')
   FROM dbo.LOC AS LOC WITH(NOLOCK)
   WHERE LOC.LOC = @cLOC
     AND LOC.FACILITY = @cFacility
     AND LOC.LOC NOT LIKE '%OUT%'
     AND LOC.LOC NOT LIKE '%VAS%'

   -- ===============================================================================
   -- SKU: Pack information, Putawayzone and FULLPack
   -- ===============================================================================

   ;WITH CTE_SKU_LOC AS (
      SELECT
         SL.StorerKey,
         SL.SKU,
         LOC.PutawayZone,
         LOC.Floor,
         rn = ROW_NUMBER() OVER (PARTITION BY SL.StorerKey, SL.SKU ORDER BY LOC.PutawayZone)
      FROM dbo.SKUxLOC SL WITH(NOLOCK)
      JOIN dbo.LOC LOC WITH(NOLOCK)
        ON LOC.LOC = SL.LOC
       AND LOC.Status = 'OK'
       AND LOC.LocationFlag = 'NONE'
      WHERE SL.SKU = @cSKU
        AND SL.STORERKEY = @cStorerKey
        AND SL.QtyLocationLimit > 0
        AND SL.LocationType = 'PICK'
   )
   SELECT
      @nPackCaseCnt = PACK.CaseCnt,
      @cSKUPaZone   = CTE.PutawayZone,
      @nLocMezFloor = CTE.Floor
   FROM dbo.SKU SKU WITH(NOLOCK)
   JOIN dbo.PACK PACK WITH(NOLOCK)
     ON PACK.PackKey = SKU.PACKKEY
   LEFT JOIN CTE_SKU_LOC CTE
     ON CTE.StorerKey = SKU.StorerKey
    AND CTE.SKU = SKU.SKU
    AND CTE.rn = 1
   WHERE SKU.SKU = @cSKU
     AND SKU.STORERKEY = @cStorerKey

   IF @nPackCaseCnt IS NULL OR @nPackCaseCnt = '' OR @nPackCaseCnt = 0
   BEGIN
      SET @cSuggestedLOC = ''
      SET @nErrNo = 253570
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --253570^No Pack SKU Cfg
      GOTO Quit
   END

   IF @cSKUPaZone IS NULL OR @cSKUPaZone = ''
   BEGIN
      SET @cSuggestedLOC = ''
      SET @nErrNo = 253571
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --253571^Sku HL Not Found
      GOTO Quit
   END

   IF @nQty = @nPackCaseCnt
      SET @cIsUCCFullPack = 1
   ELSE
      SET @cIsUCCFullPack = 0

   -- ===============================================================================
   -- INV_STATUS: Lottatribute
   -- UR0001 = OK
   -- UR0003 = SCRAP
   -- UR0004 = SCRAP
   -- UR0008 = Return
   -- ===============================================================================

   SELECT TOP 1 @cInvStatus = LT.Lottable01
   FROM dbo.UCC AS UCC WITH(NOLOCK)
   JOIN dbo.LOTATTRIBUTE AS LT WITH(NOLOCK)
     ON UCC.Lot = LT.Lot
    AND UCC.SKU = LT.Sku
    AND LT.StorerKey = UCC.Storerkey
   WHERE UCC.Storerkey = @cStorerKey
     AND UCCNo = @cUCC
     AND UCC.SKU = @cSKU

   -- ===============================================================================
   -- Load Configs Once
   -- ===============================================================================

   DECLARE @CFG TABLE (
      LISTNAME   VARCHAR(50),
      CODE       VARCHAR(50),
      SHORT      VARCHAR(50),
      STORERKEY  VARCHAR(50),
      UDF01      VARCHAR(255),
      UDF02      VARCHAR(255),
      UDF03      VARCHAR(255),
      UDF04      VARCHAR(255),
      UDF05      VARCHAR(255),
      LONGVALUE  VARCHAR(255)
   )

   INSERT INTO @CFG (LISTNAME, CODE, SHORT, STORERKEY, UDF01, UDF02, UDF03, UDF04, UDF05, LONGVALUE)
   SELECT CD.LISTNAME, CD.CODE, CD.SHORT, CD.STORERKEY, CD.UDF01, CD.UDF02, CD.UDF03, CD.UDF04, CD.UDF05, CD.LONG
   FROM dbo.CODELKUP CD WITH(NOLOCK)
   WHERE CD.LISTNAME = 'PUMA_PACFG'
     AND CD.STORERKEY = @cStorerKey

   -- ===============================================================================
   -- Capacity in Rack Area / Loc
   -- ===============================================================================

   SELECT TOP 1 @nRackCapacity = SHORT
   FROM @CFG
   WHERE CODE = 'RACKCAP'

   IF ISNULL(@nRackCapacity, '') = ''
   BEGIN
      SET @cSuggestedLOC = ''
      SET @nErrNo = 253572
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --253572^RackCap Not Setup
      GOTO Quit
   END

   -- ===============================================================================
   -- Standard configs
   -- ===============================================================================

   SELECT TOP 1
      @cMZ1PALocCfg  = UDF01,
      @cMZ2PALocCfg  = UDF02,
      @cMZ3PALocCfg  = UDF03,
      @cMZ4PALocCfg  = UDF04,
      @cRackPALocCfg = UDF05
   FROM @CFG
   WHERE CODE = 'BUFFERS'

   IF ISNULL(@cMZ1PALocCfg, '') = ''
      OR ISNULL(@cMZ2PALocCfg, '') = ''
      OR ISNULL(@cMZ3PALocCfg, '') = ''
      OR ISNULL(@cMZ4PALocCfg, '') = ''
      OR ISNULL(@cRackPALocCfg, '') = ''
   BEGIN
      SET @cSuggestedLOC = ''
      SET @nErrNo = 253573
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --253573^Buffer Not Setup
      GOTO Quit
   END

   -- ===============================================================================
   -- Stage Config
   -- ===============================================================================

   SELECT TOP 1
      @cStgPAZone      = UDF01,
      @cLocTypeCfgZone = LONGVALUE
   FROM @CFG
   WHERE SHORT = 'STAGE'

   IF ISNULL(@cStgPAZone, '') = ''
      OR ISNULL(@cLocTypeCfgZone, '') = ''
   BEGIN
      SET @cSuggestedLOC = ''
      SET @nErrNo = 253574
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --253574^Stg Not Setup
      GOTO Quit
   END

   -- ===============================================================================
   -- Buffer Config by SKU PA Zone
   -- ===============================================================================

   SELECT TOP 1
      @cRespectiveBuffer = UDF01,
      @nMaxHsperFloor    = UDF05
   FROM @CFG
   WHERE SHORT = 'BUFFER'
     AND UDF02 = LEFT(@cSKUPaZone, 1)
     AND TRY_CONVERT(INT, SUBSTRING(@cSKUPaZone, 2, 2))
         BETWEEN TRY_CONVERT(INT, UDF03) AND TRY_CONVERT(INT, UDF04)

   IF ISNULL(@nMaxHsperFloor, '') = ''
      OR ISNULL(@cRespectiveBuffer, '') = ''
   BEGIN
      SET @cSuggestedLOC = ''
      SET @nErrNo = 253575
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --253575^No SKU PAzone
      GOTO Quit
   END

   -- ===============================================================================
   -- Flags
   -- ===============================================================================

   SET @nIsStage = CASE WHEN @cLocPaZone = @cStgPAZone THEN 1 ELSE 0 END

   IF @cLOC = @cRespectiveBuffer OR @cLOC = @cRackPALocCfg
   BEGIN
      SET @nIsBuffer = 1
      SET @nIsStage = 0
   END
   ELSE
   BEGIN
      SET @nIsBuffer = 0
   END

   -- ===============================================================================
   -- HS Location
   -- ===============================================================================

   SET @nIsHS = 0

   IF EXISTS (
      SELECT 1
      FROM dbo.LOC LOC WITH(NOLOCK)
      WHERE LOC.Loc = @cLOC
        AND LOC.LocationHandling = '2'
        AND LOC.Facility = @cFacility
        AND LOC.Floor = @nLocMezFloor
   )
   BEGIN
      SET @nIsHS = 1
   END

   -- ===============================================================================
   -- Replenishment Location
   -- ===============================================================================

   SET @nIsRepleLoc = 0

   IF EXISTS (
      SELECT 1
      FROM @CFG
      WHERE CODE = @cLOC
        AND SHORT = 'REPLE'
   )
   BEGIN
      SET @nIsRepleLoc = 1
   END

   -- ===============================================================================
   -- Checking Available Locs / Sumarizing Qty's
   -- Validating EA's And UCC's in Buffer To Calculate if Can PA to HS/Rack
   -- ===============================================================================

   SET @nCountUCCinBuffer = 0
   SET @nSumEAinBuffer = 0

   SELECT
      @nCountUCCinBuffer = ISNULL(COUNT(DISTINCT CASE WHEN UCC.QTY = @nPackCaseCnt THEN UCC.UCCNO END), 0),
      @nSumEAinBuffer = ISNULL(SUM(UCC.QTY), 0)
   FROM dbo.UCC AS UCC WITH(NOLOCK)
   WHERE UCC.Loc = @cRespectiveBuffer
     AND UCC.Storerkey = @cStorerKey
     AND UCC.SKU = @cSKU

   -- ===============================================================================
   -- Mezzanine: HomeLocation
   -- ===============================================================================

   ;WITH LLI_SKULOC AS (
      SELECT
         Loc,
         StorerKey,
         Sku,
         SUM(QTY + PendingMoveIN + QtyAllocated - QtyPicked) AS TotalQty
      FROM dbo.LOTXLOCXID WITH(NOLOCK)
      WHERE Sku = @cSKU
        AND StorerKey = @cStorerKey
      GROUP BY Loc, StorerKey, Sku
   )
   SELECT
      @nSumAvlEaInHL = ISNULL(SUM(SL.QtyLocationLimit), 0) - ISNULL(SUM(SL.QTY), 0),
      @nSumAvlPackHL = ISNULL(CEILING((SUM(SL.QtyLocationLimit) - SUM(SL.QTY)) * 1.0 / @nPackCaseCnt), 0)
   FROM dbo.SKUxLOC SL WITH(NOLOCK)
   JOIN dbo.LOC LOC WITH(NOLOCK)
     ON SL.Loc = LOC.Loc
    AND LOC.Facility = @cFacility
    AND LOC.Status = 'OK'
    AND LOC.LocationFlag = 'NONE'
   LEFT JOIN LLI_SKULOC X
     ON X.Loc = SL.Loc
    AND X.StorerKey = SL.StorerKey
    AND X.Sku = SL.Sku
   WHERE SL.Sku = @cSKU
     AND SL.StorerKey = @cStorerKey
     AND SL.LocationType = 'PICK'
     AND SL.QtyLocationLimit > 0
     AND SL.QtyLocationLimit >= ISNULL(X.TotalQty, 0) + @nQty

   -- ===============================================================================
   -- Handstack COUNT UCC IN AND AVAILABLE
   -- ===============================================================================

   SELECT @nCountUCCinHS = ISNULL(COUNT(DISTINCT UCCNo), 0)
   FROM dbo.UCC AS UCC WITH(NOLOCK)
   JOIN dbo.LOC AS LOC WITH(NOLOCK)
     ON LOC.LOC = UCC.LOC
    AND LOC.Facility = @cFacility
    AND LOC.Status = 'OK'
    AND LOC.LocationFlag = 'NONE'
    AND LOC.LocationHandling = '2'
    AND LOC.Floor = @nLocMezFloor
   WHERE UCC.Storerkey = @cStorerKey
     AND UCC.SKU = @cSKU
     AND UCC.Status IN ('1', '3')

   SELECT @nCartonAvlinHS = ISNULL(SUM(LOC.MAXCARTON), 0)
   FROM dbo.LOC LOC WITH(NOLOCK)
   WHERE LOC.Facility = @cFacility
     AND LOC.Status = 'OK'
     AND LOC.LocationFlag = 'NONE'
     AND LOC.LocationHandling = '2'
     AND LOC.Floor = @nLocMezFloor
     AND NOT EXISTS (
        SELECT 1
        FROM dbo.LOTXLOCXID LLI WITH(NOLOCK)
        WHERE LLI.Loc = LOC.LOC
          AND LLI.StorerKey = @cStorerKey
          AND (LLI.QTY + LLI.PendingMoveIN + LLI.QtyAllocated - LLI.QtyPicked) > 0
     )

   -- ===============================================================================
   -- AVAILABLE LOC IN HANDSTACK, LOC.HANDLING = 2 (CASE ONLY)
   -- ===============================================================================

   SELECT TOP 1 @cLocHSSugg = L.LOC
   FROM (
      SELECT UCC.LOC, COUNT(DISTINCT UCC.UCCNo) AS QTD
      FROM dbo.UCC UCC
      WHERE UCC.SKU = @cSKU
        AND UCC.STATUS IN ('1', '3')
        AND UCC.STORERKEY = @cStorerKey
      GROUP BY UCC.LOC
   ) U
   JOIN dbo.LOC L ON L.LOC = U.LOC
   WHERE L.Facility = @cFacility
     AND L.LocationHandling = '2'
     AND L.Status = 'OK'
     AND L.LocationFlag = 'NONE'
     AND L.Floor = @nLocMezFloor
     AND L.LOC NOT IN (@cRespectiveBuffer, @cLOC)
     AND U.QTD < L.MaxCarton
   ORDER BY L.PALogicalLoc, L.LOC
   OPTION (FAST 1)

   -- ===============================================================================
   -- FALLBACK: EMPTY LOC HANDSTACK
   -- ===============================================================================

   IF @cLocHSSugg IS NULL OR @cLocHSSugg = ''
   BEGIN
      SELECT TOP 1 @cLocHSSugg = LOC.LOC
      FROM dbo.LOC LOC WITH(NOLOCK)
      WHERE LOC.Facility = @cFacility
        AND LOC.LocationHandling = '2'
        AND LOC.Status = 'OK'
        AND LOC.LocationFlag = 'NONE'
        AND LOC.Floor = @nLocMezFloor
        AND NOT EXISTS (
           SELECT 1
           FROM dbo.LOTXLOCXID LLI WITH(NOLOCK)
           WHERE LLI.Loc = LOC.LOC
             AND LLI.StorerKey = @cStorerKey
             AND (LLI.QTY + LLI.PendingMoveIN + LLI.QtyAllocated - LLI.QtyPicked) > 0
        )
      ORDER BY LOC.PALogicalLoc, LOC.Loc
      OPTION (FAST 1)
   END

   -- ===============================================================================
   -- AVAILABLE LOC IN HOMELOCATION THAT FIT UCC QTY
   -- ===============================================================================

   ;WITH LLI_AGG AS (
      SELECT
         Loc,
         StorerKey,
         Sku,
         SUM(QTY + PendingMoveIN + QtyAllocated - QtyPicked) AS TotalQty
      FROM dbo.LOTXLOCXID WITH(NOLOCK)
      WHERE Sku = @cSKU
        AND StorerKey = @cStorerKey
      GROUP BY Loc, StorerKey, Sku
   )
   SELECT TOP 1 @cLocMezSugg = ISNULL(SL.Loc, '')
   FROM dbo.SKUxLOC SL WITH(NOLOCK)
   JOIN dbo.LOC LOC WITH(NOLOCK)
     ON SL.Loc = LOC.Loc
    AND LOC.Facility = @cFacility
    AND LOC.Status = 'OK'
    AND LOC.LocationFlag = 'NONE'
    AND LOC.PutawayZone = @cSKUPAZone
   LEFT JOIN LLI_AGG X
     ON X.Loc = SL.Loc
    AND X.StorerKey = SL.StorerKey
    AND X.Sku = SL.Sku
   WHERE SL.Sku = @cSKU
     AND SL.StorerKey = @cStorerKey
     AND SL.LocationType = 'PICK'
     AND SL.QtyLocationLimit >= ISNULL(X.TotalQty, 0) + @nQty
   ORDER BY LOC.PALogicalLoc, LOC.Loc
   OPTION (FAST 1)

   -- ===============================================================================
   -- IF IS A REPLENISHMENT LOC CHECK HL AVAILABLE FIRST THEN DIN LOCS
   -- ===============================================================================

   IF @nIsRepleLoc = 1
   BEGIN
      IF ISNULL(@cLocMezSugg, '') <> '' AND @nSumAvlEaInHL + @nQty >= 0
      BEGIN
         IF @@TRANCOUNT = 0
         BEGIN
            BEGIN TRAN
            SET @StartedTran = 1
         END
         ELSE
         BEGIN
            SAVE TRAN rdt_521ExtPA28
         END

         EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK',
            @cLOC, @cID, @cLocMezSugg, @cStorerKey,
            @nErrNo OUTPUT, @cErrMsg OUTPUT,
            @cSKU, @nQty, @cUCC, @cLOT,
            @nPABookingKey = @nPABookingKey OUTPUT

         IF @nErrNo <> 0
            GOTO RollBackTran

         SET @cSuggestedLOC = @cLocMezSugg
         GOTO CommitTran
      END
      ELSE
      BEGIN
         -- IF NO CAPACITY IN HL THEN TRY DIN LOCS
         SELECT TOP 1 @cLocDinSugg = LOC.Loc
         FROM dbo.LOC AS LOC WITH(NOLOCK)
         LEFT JOIN dbo.UCC AS UCC WITH(NOLOCK)
           ON UCC.Loc = LOC.Loc
          AND UCC.Status IN ('1', '3')
          AND UCC.StorerKey = @cStorerKey
         WHERE LOC.Facility = @cFacility
           AND LOC.Floor = @nLocMezFloor
           AND TRIM(LOC.LocationRoom) = 'DIN'
         GROUP BY LOC.Loc, LOC.MaxCarton, LOC.PALogicalLoc
         HAVING COUNT(DISTINCT UCC.UCCNO) < LOC.MaxCarton
         ORDER BY LOC.PALogicalLoc

         IF @cLocDinSugg <> ''
         BEGIN
            IF @@TRANCOUNT = 0
            BEGIN
               BEGIN TRAN
               SET @StartedTran = 1
            END
            ELSE
            BEGIN
               SAVE TRAN rdt_521ExtPA28
            END

            EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK',
               @cLOC, @cID, @cLocDinSugg, @cStorerKey,
               @nErrNo OUTPUT, @cErrMsg OUTPUT,
               @cSKU, @nQty, @cUCC, @cLOT,
               @nPABookingKey = @nPABookingKey OUTPUT

            IF @nErrNo <> 0
               GOTO RollBackTran

            SET @cSuggestedLOC = @cLocDinSugg
            GOTO CommitTran
         END
      END
   END

   -- ===============================================================================
   -- IF ITS FROM HS THEN ONLY GO TO HOMELOCATION/PICKFACE
   -- ===============================================================================

   IF @nIsHS = 1
   BEGIN
      IF @nSumAvlEaInHL + @nQty >= 0 AND ISNULL(@cLocMezSugg, '') <> ''
      BEGIN
         IF @@TRANCOUNT = 0
         BEGIN
            BEGIN TRAN
            SET @StartedTran = 1
         END
         ELSE
         BEGIN
            SAVE TRAN rdt_521ExtPA28
         END

         EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK',
            @cLOC, @cID, @cLocMezSugg, @cStorerKey,
            @nErrNo OUTPUT, @cErrMsg OUTPUT,
            @cSKU, @nQty, @cUCC, @cLOT

         IF @nErrNo <> 0
            GOTO RollBackTran

         SET @cSuggestedLOC = @cLocMezSugg
         GOTO CommitTran
      END
   END

   -- ===============================================================================
   -- First Step: Putaway from stage to corresponding Buffer
   -- ===============================================================================

   IF @nIsStage = 1
   BEGIN
      -- LESS THAN 1 PACK.CASECNT GO TO MEZ
      IF @cIsUCCFullPack = 0
      BEGIN
         SET @cSuggestedLOC = @cRespectiveBuffer
         GOTO Quit
      END

      -- PACK.CASECNT FULL
      -- 1. IF FIT IN HOMELOCATION
      -- 2. IF FIT IN HANDSTACK
      -- 3. GO TO RACK
      IF @cIsUCCFullPack = 1
      BEGIN
         IF @nSumEAinBuffer + @nQty <= @nSumAvlEaInHL
         BEGIN
            SET @cSuggestedLOC = @cRespectiveBuffer
            GOTO Quit
         END

         IF @nCountUCCinHS + @nCountUCCinBuffer < @nMaxHsperFloor + @nSumAvlPackHL
         BEGIN
            IF @nCountUCCinHS + @nCountUCCinBuffer < @nCartonAvlinHS
            BEGIN
               SET @cSuggestedLOC = @cRespectiveBuffer
               GOTO Quit
            END
         END
         ELSE
         BEGIN
            SET @cSuggestedLOC = @cRackPALocCfg
            GOTO Quit
         END
      END
   END

   -- ===============================================================================
   -- Second Step: Putaway from Buffer to Final Loc
   -- ===============================================================================

   IF @nIsBuffer = 1
   BEGIN
      IF @cLOC IN (@cMZ1PALocCfg, @cMZ2PALocCfg, @cMZ3PALocCfg, @cMZ4PALocCfg)
      BEGIN
         IF @cIsUCCFullPack = 0
         BEGIN
            IF ISNULL(@cLocMezSugg, '') <> ''
            BEGIN
               IF @@TRANCOUNT = 0
               BEGIN
                  BEGIN TRAN
                  SET @StartedTran = 1
               END
               ELSE
               BEGIN
                  SAVE TRAN rdt_521ExtPA28
               END

               EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK',
                  @cLOC, @cID, @cLocMezSugg, @cStorerKey,
                  @nErrNo OUTPUT, @cErrMsg OUTPUT,
                  @cSKU, @nQty, @cUCC, @cLOT,
                  @nPABookingKey = @nPABookingKey OUTPUT

               IF @nErrNo <> 0
                  GOTO RollBackTran

               SET @cSuggestedLOC = @cLocMezSugg
               GOTO CommitTran
            END
            ELSE
            BEGIN
               -- No Loc Avl in Mezz For Partial Pack
               SET @cSuggestedLOC = ''
               SET @nErrNo = 253576
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --253576^No Loc in Mezz
               GOTO Quit
            END
         END
         ELSE
         BEGIN
            -- IS PACK FULL
            IF ISNULL(@cLocMezSugg, '') <> ''
            BEGIN
               IF @@TRANCOUNT = 0
               BEGIN
                  BEGIN TRAN
                  SET @StartedTran = 1
               END
               ELSE
               BEGIN
                  SAVE TRAN rdt_521ExtPA28
               END

               EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK',
                  @cLOC, @cID, @cLocMezSugg, @cStorerKey,
                  @nErrNo OUTPUT, @cErrMsg OUTPUT,
                  @cSKU, @nQty, @cUCC, @cLOT,
                  @nPABookingKey = @nPABookingKey OUTPUT

               IF @nErrNo <> 0
                  GOTO RollBackTran

               SET @cSuggestedLOC = @cLocMezSugg
               GOTO CommitTran
            END

            IF ISNULL(@cLocHSSugg, '') <> ''
            BEGIN
               IF @@TRANCOUNT = 0
               BEGIN
                  BEGIN TRAN
                  SET @StartedTran = 1
               END
               ELSE
               BEGIN
                  SAVE TRAN rdt_521ExtPA28
               END

               EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK',
                  @cLOC, @cID, @cLocHSSugg, @cStorerKey,
                  @nErrNo OUTPUT, @cErrMsg OUTPUT,
                  @cSKU, @nQty, @cUCC, @cLOT,
                  @nPABookingKey = @nPABookingKey OUTPUT

               IF @nErrNo <> 0
                  GOTO RollBackTran

               SET @cSuggestedLOC = @cLocHSSugg
               GOTO CommitTran
            END
            ELSE
            BEGIN
               SET @cSuggestedLOC = ''
               SET @nErrNo = 253577
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --253577^No Loc Found
               GOTO Quit
            END
         END
      END

      -- ===============================================================================
      -- AVAILABLES LOCS IN RACK ACCORDING TO MAXCARTON, IF = 0 THEN @nRackCapacity
      -- ===============================================================================

      IF @cLOC = @cRackPALocCfg
      BEGIN
         SELECT TOP 1 @cLocRackSugg = LOC.Loc
         FROM dbo.UCC AS UCC WITH(NOLOCK)
         JOIN dbo.LOC AS LOC WITH(NOLOCK)
           ON LOC.LOC = UCC.LOC
          AND LOC.LocationRoom = 'RACK'
          AND LOC.HOSTWHCODE = @cInvStatus
          AND LOC.Status = 'OK'
          AND LOC.LocationFlag = 'NONE'
          AND LOC.LOC <> @cRackPALocCfg
         JOIN dbo.LOTATTRIBUTE AS LT WITH(NOLOCK)
           ON UCC.LOT = LT.LOT
          AND UCC.SKU = LT.SKU
          AND LT.Lottable01 = LOC.HOSTWHCODE
         WHERE UCC.STATUS IN ('1', '3')
           AND UCC.STORERKEY = @cStorerkey
           AND UCC.SKU = @cSKU
         GROUP BY LOC.LOC, LOC.PALogicalLoc, LOC.MaxCarton
         HAVING COUNT(DISTINCT UCC.UCCNo) < CASE WHEN LOC.MaxCarton > 0 THEN LOC.MaxCarton ELSE @nRackCapacity END
         ORDER BY LOC.PALogicalLoc, LOC.Loc

         -- FALLBACK: EMPTY LOC RACK
         IF @cLocRackSugg IS NULL OR @cLocRackSugg = ''
         BEGIN
            SELECT TOP 1 @cLocRackSugg = LOC.LOC
            FROM dbo.LOC LOC WITH(NOLOCK)
            WHERE LOC.LocationRoom = 'RACK'
              AND LOC.HOSTWHCODE = @cInvStatus
              AND LOC.Facility = @cFacility
              AND LOC.Status = 'OK'
              AND LOC.LocationFlag = 'NONE'
              AND LOC.Loc <> @cRackPALocCfg
              AND NOT EXISTS (
                 SELECT 1
                 FROM dbo.LOTXLOCXID LLI WITH(NOLOCK)
                 WHERE LLI.Loc = LOC.LOC
                   AND LLI.StorerKey = @cStorerkey
                   AND (LLI.QTY + LLI.PendingMoveIN + LLI.QtyAllocated - LLI.QtyPicked) > 0
              )
            ORDER BY LOC.PALogicalLoc, LOC.Loc
            OPTION (FAST 1)
         END

         IF ISNULL(@cLocRackSugg, '') <> ''
         BEGIN
            IF @@TRANCOUNT = 0
            BEGIN
               BEGIN TRAN
               SET @StartedTran = 1
            END

            EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK',
               @cLOC, @cID, @cLocRackSugg, @cStorerKey,
               @nErrNo OUTPUT, @cErrMsg OUTPUT,
               @cSKU, @nQty, @cUCC, @cLOT,
               @nPABookingKey = @nPABookingKey OUTPUT

            IF @nErrNo <> 0
               GOTO RollBackTran

            SET @cSuggestedLOC = @cLocRackSugg
            GOTO CommitTran
         END
         ELSE
         BEGIN
            SET @cSuggestedLOC = ''
            SET @nErrNo = 253578
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --253578^No Loc Found
            GOTO Quit
         END
      END
   END

   RollBackTran:
   IF XACT_STATE() <> 0
   BEGIN
      IF @StartedTran = 1
         ROLLBACK TRAN
      ELSE IF @@TRANCOUNT > 0
         ROLLBACK TRAN rdt_521ExtPA28
   END
   GOTO Quit

   CommitTran:
   IF @StartedTran = 1
      COMMIT TRAN
   GOTO Quit

   Quit:
END
GO
GRANT EXECUTE ON [RDT].[rdt_521ExtPA28] TO NSQL
GO
