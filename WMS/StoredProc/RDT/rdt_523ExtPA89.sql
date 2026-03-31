SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: rdt_523ExtPA89                                            */
/* Copyright: Maersk                                                          */
/* Customer: PAGE INDUSTRIES LIMITED                                          */
/*                                                                            */
/* Date        Rev    Author    Purposes                                      */
/* 2026-03-26  1.0.0  NickT     FCR-10232. Created                            */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_523ExtPA89] (
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
      @cPutawayStrategy    NVARCHAR(5),
      @cPutawayZone        NVARCHAR(10),
      @fFreeCube           FLOAT,
      @fSKUCube            FLOAT,
      @nFreeQty            INT,
      @nTranCount          INT,
      @nLoopIndex          INT

   SET @nErrNo = 0
   SET @cErrMsg = ''
   SET @cSuggestedLOC = ''

   IF OBJECT_ID('tempdb.dbo.#TEMPLOC_523ExtPA89') IS NOT NULL
      DROP TABLE #TEMPLOC_523ExtPA89

   CREATE TABLE #TEMPLOC_523ExtPA89
   (
      RowRef               INT IDENTITY(1,1),
      LOC                  NVARCHAR(10),
      LogicalLocation      NVARCHAR(18),
      CommingleSku         NVARCHAR(1),
      SKU                  NVARCHAR(20),
      LocCube              FLOAT,
      UsedCube             FLOAT
   )

   SELECT @cPutawayZone = PutawayZone,
      @fSKUCube = IIF(STDCUBE = 0, 1, STDCUBE)
   FROM dbo.SKU WITH(NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND SKU = @cSKU

   IF ISNULL(@cPutawayZone, '') = ''
   BEGIN
      SET @nErrNo = 262351
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No PutawayZone is setup
      GOTO Quit
   END

   SELECT TOP 1 @cPutawayStrategy = code2
   FROM dbo.CODELKUP WITH(NOLOCK)
   WHERE ListName = 'PASTRPRIO'
      AND StorerKey = @cStorerKey
   ORDER BY CODE

   IF @@ROWCOUNT = 0
   BEGIN
      GOTO Quit
   END

   IF ISNULL(@cPutawayStrategy, '') = 'E'
   BEGIN
      SELECT TOP 1 @cSuggestedLOC = Loc, @fFreeCube = LOC.Cube
      FROM dbo.LOC WITH(NOLOCK)
      WHERE LOC.Facility = @cFacility
         AND ((LOC.PutawayZone IS NULL AND @cPutawayZone = '') OR LOC.PutawayZone = @cPutawayZone)
         AND NOT EXISTS(SELECT 1 FROM dbo.LOTXLOCXID LLI WITH(NOLOCK)
                        INNER JOIN dbo.LOC LOC2 WITH(NOLOCK) ON LOC2.Facility = @cFacility AND LLI.Loc = LOC2.Loc
                        WHERE LLI.StorerKey = @cStorerKey
                           AND LOC2.Facility = @cFacility
                           AND ISNULL(LOC2.PutawayZone, '') = @cPutawayZone
                           AND ( LLI.Qty - LLI.QtyPicked > 0 OR LLI.PendingMoveIN > 0)
                           AND LOC.Loc = LOC2.Loc
                        )
      ORDER BY LOC.LogicalLocation, LOC.Loc

      IF @@ROWCOUNT = 0
      BEGIN
         SET @cSuggestedLOC = ''
         SET @fFreeCube = 0
      END

      IF @cSuggestedLOC = ''
      BEGIN
         INSERT INTO #TEMPLOC_523ExtPA89 (LOC, LogicalLocation, CommingleSku, LocCube, SKU, UsedCube )
         SELECT LOC.Loc, LOC.LogicalLocation, LOC.CommingleSku, LOC.[Cube] AS LocCube, SKU.SKU, SKU.STDCUBE * SUM( LLI.QTY - LLI.QTYPicked + LLI.PendingMoveIn) AS UsedCube
         FROM dbo.LOC WITH(NOLOCK)
         INNER JOIN dbo.LOTXLOCXID LLI WITH(NOLOCK) ON LLI.Loc = LOC.Loc
         INNER JOIN dbo.SKU WITH(NOLOCK) ON SKU.StorerKey = LLI.StorerKey AND SKU.SKU = LLI.SKU
         WHERE LOC.Facility = @cFacility
            AND ((LOC.PutawayZone IS NULL AND @cPutawayZone = '') OR LOC.PutawayZone = @cPutawayZone)
            AND ( LLI.Qty - LLI.QtyPicked > 0 OR LLI.PendingMoveIN > 0)
            AND EXISTS(SELECT 1 FROM 
                     dbo.LOTXLOCXID LLI1 WITH(NOLOCK) 
                     INNER JOIN dbo.LOC LOC1 WITH(NOLOCK) ON LLI1.Loc = LOC1.Loc 
                     WHERE LOC1.Facility = @cFacility
                        AND LLI1.StorerKey = @cStorerKey
                        AND LLI1.Sku = @cSKU 
                        AND ( LLI1.Qty - LLI1.QtyPicked > 0 OR LLI1.PendingMoveIN > 0) 
                        AND LOC.Loc = LOC1.Loc
                  )
         GROUP BY LOC.Loc, LOC.LogicalLocation, LOC.CommingleSku,  LOC.[Cube], SKU.SKU, SKU.STDCUBE

         SELECT TOP 1 @cSuggestedLOC = Loc
         FROM #TEMPLOC_523ExtPA89 T1
         WHERE SKU = @cSKU
            AND NOT EXISTS(SELECT 1 FROM #TEMPLOC_523ExtPA89 T2 
                           WHERE T2.CommingleSku = '0'
                              AND T1.Loc = T2.Loc
                           GROUP BY Loc
                           HAVING COUNT(DISTINCT SKU) > 1)
         ORDER BY RowRef

         IF (@cSuggestedLOC IS NOT NULL)
         BEGIN
            SELECT @fFreeCube = LocCube - SUM(UsedCube)
            FROM #TEMPLOC_523ExtPA89
            WHERE Loc = @cSuggestedLOC
            GROUP BY Loc, LocCube

            SET @fFreeCube = IIF(@fFreeCube <0 , 0, @fFreeCube)
         END
      END
   END
   ELSE
   BEGIN
      INSERT INTO #TEMPLOC_523ExtPA89 (LOC, LogicalLocation, CommingleSku, LocCube, SKU, UsedCube )
      SELECT LOC.Loc, LOC.LogicalLocation, LOC.CommingleSku, LOC.[Cube] AS LocCube, SKU.SKU, SKU.STDCUBE * SUM( LLI.QTY - LLI.QTYPicked + LLI.PendingMoveIn) AS UsedCube
      FROM dbo.LOC WITH(NOLOCK)
      INNER JOIN dbo.LOTXLOCXID LLI WITH(NOLOCK) ON LLI.Loc = LOC.Loc
      INNER JOIN dbo.SKU WITH(NOLOCK) ON SKU.StorerKey = LLI.StorerKey AND SKU.SKU = LLI.SKU
      WHERE LOC.Facility = @cFacility
         AND ((LOC.PutawayZone IS NULL AND @cPutawayZone = '') OR LOC.PutawayZone = @cPutawayZone)
         AND ( LLI.Qty - LLI.QtyPicked > 0 OR LLI.PendingMoveIN > 0)
         AND EXISTS(SELECT 1 FROM 
                     dbo.LOTXLOCXID LLI1 WITH(NOLOCK) 
                     INNER JOIN dbo.LOC LOC1 WITH(NOLOCK) ON LLI1.Loc = LOC1.Loc 
                     WHERE LOC1.Facility = @cFacility
                        AND LLI1.StorerKey = @cStorerKey
                        AND LLI1.Sku = @cSKU 
                        AND ( LLI1.Qty - LLI1.QtyPicked > 0 OR LLI1.PendingMoveIN > 0) 
                        AND LOC.Loc = LOC1.Loc
                  )
      GROUP BY LOC.Loc, LOC.LogicalLocation, LOC.CommingleSku,  LOC.[Cube], SKU.SKU, SKU.STDCUBE

      SET @nLoopIndex = -1
      WHILE 1 = 1
      BEGIN
         SELECT TOP 1 
            @cSuggestedLOC = Loc,
            @nLoopIndex = RowRef
         FROM #TEMPLOC_523ExtPA89 T1
         WHERE SKU = @cSKU
            AND RowRef > @nLoopIndex
            AND NOT EXISTS(SELECT 1 FROM #TEMPLOC_523ExtPA89 T2 
                           WHERE T2.CommingleSku = '0'
                              AND T1.Loc = T2.Loc
                           GROUP BY Loc
                           HAVING COUNT(DISTINCT SKU) > 1)
         ORDER BY RowRef

         IF @@ROWCOUNT = 0
            BREAK

         IF ISNULL(@cSuggestedLOC, '') <> ''
         BEGIN
            SELECT @fFreeCube = LocCube - SUM(UsedCube)
            FROM #TEMPLOC_523ExtPA89
            WHERE Loc = @cSuggestedLOC
            GROUP BY Loc, LocCube

            SET @fFreeCube = IIF(@fFreeCube <0 , 0, @fFreeCube)
         END

         IF ISNULL(@cSuggestedLOC, '') <> '' AND @fFreeCube > 0
            BREAK
      END

      IF ISNULL(@cSuggestedLOC, '') = '' OR @fFreeCube = 0
      BEGIN
         SELECT TOP 1 @cSuggestedLOC = Loc, @fFreeCube = LOC.Cube
         FROM dbo.LOC WITH(NOLOCK)
         WHERE LOC.Facility = @cFacility
            AND ((LOC.PutawayZone IS NULL AND @cPutawayZone = '') OR LOC.PutawayZone = @cPutawayZone)
            AND NOT EXISTS(SELECT 1 FROM dbo.LOTXLOCXID LLI WITH(NOLOCK)
                           INNER JOIN dbo.LOC LOC2 WITH(NOLOCK) ON LOC2.Facility = @cFacility AND LLI.Loc = LOC2.Loc
                           WHERE LLI.StorerKey = @cStorerKey
                              AND LOC2.Facility = @cFacility
                              AND ISNULL(LOC2.PutawayZone, '') = @cPutawayZone
                              AND ( LLI.Qty - LLI.QtyPicked > 0 OR LLI.PendingMoveIN > 0)
                              AND LOC.Loc = LOC2.Loc
                           )
         ORDER BY LOC.LogicalLocation, LOC.Loc

         IF @@ROWCOUNT = 0
         BEGIN
            SET @cSuggestedLOC = ''
            SET @fFreeCube = 0
         END
      END
   END

   SET @nFreeQty = ISNULL(TRY_CAST(@fFreeCube / @fSKUCube AS INT), 0)

   IF @nFreeQty = 0
      SET @cSuggestedLOC = ''

   SELECT @nQTY = Qty
   FROM dbo.LOTXLOCXID WITH(NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND SKU = @cSKU
      AND Loc = @cLOC
      AND LOT = @cLOT
      AND ID = @cID
   
   IF ISNULL(@nQTY, 0) = 0
   BEGIN
      SET @nErrNo = 262353
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No quantity to move into suggested location
      GOTO Quit
   END

   /*-------------------------------------------------------------------------------
                                 Book suggested location
   -------------------------------------------------------------------------------*/
   -- Handling transaction
   SET @nTranCount = @@Trancount
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_523ExtPA89 -- For rollback or commit only our own transaction

   IF ISNULL(@cSuggestedLOC,'') <> ''
   BEGIN
      
      SET @nQTY = IIF( @nFreeQty <= @nQTY, @nFreeQty, @nQTY)

      SET @nErrNo = 0
      BEGIN TRY
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
      END TRY
      BEGIN CATCH
         SET @nErrNo = 262352
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Execute rdt_Putaway_PendingMoveIn failed
         GOTO RollBackTran
      END CATCH

      IF @nErrNo <> 0
         GOTO RollBackTran
   END
   COMMIT TRAN rdt_523ExtPA89 -- Only commit change made here
   GOTO Quit

RollBackTran:
   IF XACT_STATE() = -1
      ROLLBACK TRAN -- Full rollback required for doomed transaction
   ELSE IF XACT_STATE() = 1
      ROLLBACK TRAN rdt_523ExtPA89 -- Rollback to savepoint
Quit:
   IF @@TRANCOUNT > @nTranCount
   BEGIN
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
         COMMIT TRAN
   END
   DROP TABLE #TEMPLOC_523ExtPA89
END
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

GRANT EXECUTE ON  [RDT].[rdt_523ExtPA89] TO [NSQL]
GO
