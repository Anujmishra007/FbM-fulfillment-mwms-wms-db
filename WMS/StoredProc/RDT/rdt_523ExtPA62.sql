SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO 
/************************************************************************/  
/* Store procedure: rdt_523ExtPA62                                      */  
/*                                                                      */  
/* Purpose: Get suggested loc                                           */  
/*                                                                      */  
/* Called from: rdtfnc_PutawayBySKU                                     */  
/*                                                                      */  
/* Date         Rev  Author   Purposes                                  */  
/* 2023-10-17   1.0  yeekung  WMS-23857 Created                         */  
/************************************************************************/  
  
CREATE OR ALTER PROC [rdt].[rdt_523ExtPA62] (  
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
   @nPABookingKey    INT           OUTPUT,    
   @nErrNo           INT           OUTPUT,   
   @cErrMsg          NVARCHAR( 20) OUTPUT    
) AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
     
   DECLARE @nTranCount  INT  
   DECLARE @cBUSR4      NVARCHAR( 200)  
   DECLARE @cPAZone     NVARCHAR( 10) = ''  
   DECLARE @cDefaultLOC NVARCHAR( 10) = ''  
       
   -- Get SKU info  
   SELECT @cBUSR4 = ISNULL( BUSR4, '')  
   FROM dbo.SKU WITH (NOLOCK)   
   WHERE StorerKey = @cStorerKey   
      AND SKU = @cSKU  
     
   -- Get product zone and LOC  
   SELECT   
      @cPAZone = ISNULL( Short, ''),   
      @cDefaultLOC = ISNULL( Long, '')  
   FROM dbo.CodeLKUP WITH (NOLOCK)  
   WHERE ListName = 'MHYPAZONE'  
      AND Code = @cBUSR4  
      AND StorerKey = @cStorerKey  
      AND Code2 = @cFacility
     
   SET @cSuggestedLOC = ''  
  
   -- Find Pickloc
   SELECT TOP 1 @cSuggestedLOC = SL.LOC  
   FROM dbo.SKUxLOC SL WITH (NOLOCK)   
   JOIN dbo.LOC LOC WITH (NOLOCK) ON ( SL.LOC = LOC.LOC)  
   WHERE SL.StorerKey = @cStorerKey   
   AND   SL.SKU = @cSKU  
   AND   SL.LocationType = 'PICK'  
   AND   LOC.Facility = @cFacility  
   ORDER BY LOC.LogicalLocation,LOC.Loc  

   -- Find friend loc
   IF @cSuggestedLOC = ''  
   BEGIN 
      SELECT TOP 1 @cSuggestedLOC = LLI.LOC  
      FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)   
      JOIN dbo.LOC LOC WITH (NOLOCK) ON ( LLI.LOC = LOC.LOC)  
      WHERE LLI.StorerKey = @cStorerKey   
      AND   LLI.SKU = @cSKU  
      AND   LLI.QTY-LLI.QTYPicked > 0  
      AND   LOC.LocationType = 'PICK'  
      AND   LOC.Facility = @cFacility  
      AND   LOC.PutawayZone = @cPAZone  
      ORDER BY Loc.LogicalLocation, LOC.LOC
   END
     
   -- Find empty LOC  
   IF @cSuggestedLOC = ''  
   BEGIN  
      SELECT TOP 1 @cSuggestedLOC = LOC.LOC  
      FROM dbo.LOC LOC WITH (NOLOCK)   
      LEFT OUTER JOIN LOTxLOCxID LLI WITH (NOLOCK) ON (LLI.LOC = LOC.LOC)   
      WHERE LOC.Facility = @cFacility  
      AND   LOC.Locationflag <> 'HOLD'  
      AND   LOC.Locationflag <> 'DAMAGE'  
      AND   LOC.Status <> 'HOLD'   
      AND   LOC.LocationType = 'PICK'  
      AND   LOC.PutawayZone = @cPAZone  
      GROUP BY Loc.LogicalLocation, LOC.LOC  
      HAVING ISNULL( SUM(LLI.Qty - LLI.QtyPicked), 0) = 0   
      AND   ISNULL( SUM(LLI.PendingMoveIn), 0) = 0  
      ORDER BY Loc.LogicalLocation, LOC.LOC          
   END  
  
   -- Default LOC  
   IF @cSuggestedLOC = ''  
      SET @cSuggestedLOC = @cDefaultLOC  
  
   /*-------------------------------------------------------------------------------  
                                 Book suggested location  
   -------------------------------------------------------------------------------*/  
   -- Handling transaction  
   BEGIN TRAN  -- Begin our own transaction  
   SAVE TRAN rdt_523ExtPA62 -- For rollback or commit only our own transaction  
  
   IF @cSuggestedLOC <> ''  
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
         ,@cFromLOT      = @cLOT  
         ,@nPABookingKey = @nPABookingKey OUTPUT  
      IF @nErrNo <> 0  
         GOTO RollBackTran  
  
      COMMIT TRAN rdt_523ExtPA62 -- Only commit change made here  
   END  
   GOTO Quit     
  
RollBackTran:  
   ROLLBACK TRAN rdt_523ExtPA62 -- Only rollback change made here  
Quit:  
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
      COMMIT TRAN  
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_523ExtPA62 TO NSQL
GO
