SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1819ExtPASP58                                   */
/* Created by : Maersk                                                  */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev      Author   Purposes                               */
/* 2025-05-21  1.0.0    Dennis   FCR-4217 Created                       */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1819ExtPASP58] (
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
   
   DECLARE @nTranCount       INT

   DECLARE 
      @cSKU             NVARCHAR(20),
      @cStyle           NVARCHAR(20),
      @cColor           NVARCHAR(10),
      @nRowCount        INT
   
   DECLARE @cPAStrategyKey    NVARCHAR(10)  
   DECLARE @cParam1           NVARCHAR( 20)
   DECLARE @cParam2           NVARCHAR( 20)
   DECLARE @cParam3           NVARCHAR( 20)
   DECLARE @cParam4           NVARCHAR( 20)
   DECLARE @cParam5           NVARCHAR( 20)
   DECLARE @cSTDPutawayKey    NVARCHAR( 20) = 'VNMBULK'
   DECLARE @cPOSMPutawayKey   NVARCHAR( 20) = 'VNMPOSM'
   DECLARE @cItemClass        NVARCHAR(10)  
   DECLARE @cPalletType       NVARCHAR(30)  
   DECLARE @nStackFactor      INT,
   @nLoopIndex                INT,
   @cCandidateLoc             NVARCHAR(10),
   @nDebugFlag                INT = 0,
   @nCountID                  INT,
   @nLocDeep                  INT

   -- Get putaway strategy  
   SET @cPAStrategyKey = ''  
   
   SET @cSuggLOC = ''
   SET @cPickAndDropLOC = ''
   
   -- Lock suggested location
   IF @cSuggLOC = '' 
   BEGIN    
      -- Find the SKU from PalletID and FromLoc
      SELECT TOP 1
         @cSKU = lli.SKU,
         @cItemClass = sku.ItemClass,
         @cPalletType = sku.BUSR6,
         @nStackFactor = sku.StackFactor
      FROM dbo.LOTxLOCxID lli WITH(NOLOCK)
      INNER JOIN dbo.SKU sku WITH(NOLOCK)
         ON lli.SKU = sku.SKU AND sku.StorerKey = @cStorerKey
      WHERE ID = @cID 
         AND LOC = @cFromLOC
         AND lli.StorerKey = @cStorerKey

      DECLARE @tmpLoc TABLE(
         ID    INT IDENTITY(1,1),
         TempLoc NVARCHAR(10),
         LocDeep INT
      )

      SELECT @cPAStrategyKey = CASE WHEN @cItemClass = 'STD' THEN 'MICVNPA01' ELSE 'MICVNPA02' END
   
      IF @nDebugFlag = 1
         SELECT @cSKU, @cItemClass, @cPalletType, @nStackFactor

      IF @cSKU <>  '' AND @cItemClass = 'STD'
      BEGIN
         INSERT INTO @tmpLoc 
         SELECT loc.Loc, @nStackFactor * MAX(ISNULL(LocLevel,0)) 
         FROM dbo.LOC loc WITH(NOLOCK)
         INNER JOIN dbo.LOTxLOCxID lli WITH(NOLOCK) 
            ON lli.Loc = loc.Loc
            AND lli.StorerKey = @cStorerKey
            AND lli.sku = @cSKU
         WHERE loc.Facility = @cFacility
            AND lli.Qty - lli.QtyPicked > 0 
            AND loc.PutawayZone = @cSTDPutawayKey
            GROUP BY LOC.LOC,LOC.LogicalLocation
         ORDER BY LOC.LogicalLocation

         IF @nDebugFlag = 1
            SELECT * FROM @tmpLoc

         SET @nLoopIndex = -1
         WHILE(1=1)
         BEGIN
            IF @cSuggLOC <> ''
               BREAK
            SELECT TOP 1
               @nLoopIndex = ID,
               @cCandidateLoc = TempLoc,
               @nLocDeep = LocDeep
            FROM @tmpLoc
            WHERE ID > @nLoopIndex
            ORDER BY ID

            IF @@ROWCOUNT = 0
               BREAK

            SELECT @nCountID = COUNT(DISTINCT id) 
            FROM LOTxLOCxID lli (NOLOCK) 
            WHERE loc = @cCandidateLoc and lli.Qty - lli.QtyPicked > 0

            IF dbo.fnc_GetDot_8Week_Mix_Rule(@cID, @cCandidateLoc, @cSKU) = '1' AND @nLocDeep - @nCountID > 0
               SET @cSuggLOC = @cCandidateLoc
         END

         IF @nDebugFlag = 1
            SELECT @cSuggLOC,1

         --look for empty loc
         IF @cSuggLOC = ''
         BEGIN
            SELECT TOP 1 @cSuggLOC = loc.Loc
            FROM dbo.LOC loc WITH(NOLOCK)
            LEFT JOIN dbo.LOTxLOCxID lli WITH(NOLOCK) 
               ON lli.Loc = loc.Loc
               AND lli.StorerKey = @cStorerKey
            WHERE loc.Facility = @cFacility
               AND (lli.Qty - lli.QtyPicked + LLI.PendingMoveIN = 0 OR lli.loc IS NULL)
               AND loc.PutawayZone = @cSTDPutawayKey
            ORDER BY LOC.LogicalLocation
         END
         
         IF @nDebugFlag = 1
            SELECT @cSuggLOC,2
         
         --look for loc level = 1 loc
         IF @cSuggLOC = ''
         BEGIN
            SELECT TOP 1 @cSuggLOC = loc.Loc
            FROM dbo.LOC loc WITH(NOLOCK)
            INNER JOIN dbo.LOTxLOCxID lli WITH(NOLOCK) 
               ON lli.Loc = loc.Loc
               AND lli.StorerKey = @cStorerKey
            INNER JOIN dbo.SKU sku WITH(NOLOCK) 
               ON lli.SKU = sku.SKU 
               AND sku.StackFactor = @nStackFactor 
               AND sku.BUSR6 = @cPalletType
            LEFT JOIN @tmpLoc tmp ON tmp.TempLoc = Loc.Loc
            WHERE loc.Facility = @cFacility
               AND lli.Qty - lli.QtyPicked > 0
               AND LOC.LocLevel = 1
               AND loc.PutawayZone = @cSTDPutawayKey
               AND tmp.ID IS NULL
            GROUP BY LOC.LOC,LOC.LogicalLocation
            HAVING MAX(ISNULL(SKU.StackFactor,0)) - Count(lli.ID) >= 1
            ORDER BY LOC.LogicalLocation
         END

         IF @nDebugFlag = 1
            SELECT @cSuggLOC,3

         IF @cSuggLOC <> ''
            SET @cFitCasesInAisle = 'N'

      END
      ELSE IF @cSKU <>  '' AND @cItemClass = 'POSM'
      BEGIN
         IF @cSuggLOC = ''
         BEGIN
            -- Suggest LOC
            EXEC @nErrNo = [dbo].[nspRDTPASTD]
               @c_userid          = 'RDT'
               , @c_storerkey       = @cStorerKey
               , @c_lot             = ''
               , @c_sku             = ''
               , @c_id              = @cID
               , @c_fromloc         = @cFromLOC
               , @n_qty             = 0
               , @c_uom             = '' -- not used
               , @c_packkey         = '' -- optional, if pass-in SKU
               , @n_putawaycapacity = 0
               , @c_final_toloc     = @cSuggLOC          OUTPUT
               , @c_PickAndDropLoc  = @cPickAndDropLOC   OUTPUT
               , @c_FitCasesInAisle = @cFitCasesInAisle  OUTPUT 
               , @c_Param1          = @cParam1
               , @c_Param2          = @cParam2
               , @c_Param3          = @cParam3
               , @c_Param4          = @cParam4
               , @c_Param5          = @cParam5
               , @c_PAStrategyKey   = @cPAStrategyKey  

               IF @nDebugFlag = 1
                  SELECT @cSuggLOC,4
         END
      END

      DELETE FROM @tmpLoc
      -- Check suggest loc
      IF @cSuggLOC = ''
      BEGIN
         SET @nErrNo = -1
         GOTO Quit
      END

      SET @nPABookingKey = 0
      IF @cFitCasesInAisle <> 'Y'
      BEGIN
         EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK'
            ,@cFromLOC
            ,@cID
            ,@cSuggLOC
            ,@cStorerKey
            ,@nErrNo  OUTPUT
            ,@cErrMsg OUTPUT
            ,@nPABookingKey = @nPABookingKey OUTPUT

         IF @nErrNo <> 0
            GOTO Quit
      END
   END
   
   GOTO Quit
END
Quit:
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1819ExtPASP58] TO NSQL
GO
