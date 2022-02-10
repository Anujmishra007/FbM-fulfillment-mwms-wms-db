IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[rdt].[rdt_523ExtPA43]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [rdt].[rdt_523ExtPA43]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
   
/************************************************************************/    
/* Store procedure: rdt_523ExtPA43                                      */    
/*                                                                      */    
/* Purpose: Use RDT config to get suggested loc else return blank loc   */    
/*                                                                      */    
/* Called from: rdt_PutawayBySKU_GetSuggestLOC                          */    
/*                                                                      */    
/* Date         Rev  Author      Purposes                               */    
/* 2021-10-28   1.0  Chermaine   WMS-18161. Created                     */    
/************************************************************************/    
    
CREATE PROC [rdt].[rdt_523ExtPA43] (    
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
   @cSuggestedLOC    NVARCHAR( 10) = ''   OUTPUT,    
   @nPABookingKey    INT                  OUTPUT,    
   @nErrNo           INT                  OUTPUT,    
   @cErrMsg          NVARCHAR( 20)        OUTPUT    
) AS    
BEGIN    
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
       
   DECLARE @cHostWHCode    NVARCHAR(10)    
   DECLARE @cPutawayZone   NVARCHAR(10)    
       
       
   SELECT @cHostWHCode = HostWHCode FROM Loc WITH (NOLOCK) WHERE facility = @cFacility AND loc = @cLOC    
   SELECT @cPutawayZone = PutawayZone FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND sku = @cSKU    
       
   IF EXISTS (SELECT 1     
              FROM codelkup WITH (NOLOCK)     
              WHERE storerKey = @cStorerKey    
              AND listname = 'ADSTKSTS'    
              AND Code = @cHostWHCode    
              AND Long = 'B' )    
   BEGIN    
    --Look for latest Lottable05 with same HostWHCode of the SKU    
      SELECT TOP 1       
         @cSuggestedLOC = LOC.LOC      
      FROM LOTxLOCxID LLI WITH (NOLOCK)      
      JOIN LOC LOC WITH (NOLOCK) ON (LLI.LOC = LOC.LOC)      
      JOIN LOTAttribute LA WITH (NOLOCK) ON (LLI.LOT = LA.LOT)      
      WHERE LOC.Facility = @cFacility      
      AND   LOC.HOSTWHCODE = @cHostWHCode      
      AND   LLI.StorerKey = @cStorerKey      
      AND   LLI.SKU = @cSKU      
      AND (( Qty - QtyPicked > 0) OR ( PendingMoveIn > 0))      
      AND LOC.Loc <> @cLOC    
      ORDER BY LA.Lottable05 DESC      
  
      IF @cSuggestedLOC = ''    
      BEGIN    
         ----empty Loc with the same Loc.HostWHCode    
         SELECT TOP 1 
            @cSuggestedLOC = LOC.Loc      
         FROM dbo.LOC LOC WITH (NOLOCK)      
         LEFT OUTER JOIN dbo.LOTxLOCxID LLI WITH (NOLOCK) ON ( LOC.loc = LLI.LOC )       
         WHERE LOC.Facility = @cFacility      
         AND   LOC.HOSTWHCODE = @cHostWHCode    
         AND LOC.Loc <> @cLOC    
         GROUP BY Loc.LogicalLocation, LOC.LOC      
         HAVING ISNULL( SUM( LLI.QTY + LLI.QTYPicked + LLI.QTYAllocated + LLI.PendingMoveIn +       
            (CASE WHEN LLI.QtyReplen < 0 THEN 0 ELSE LLI.QtyReplen END)), 0) = 0      
         ORDER BY LOC.LogicalLocation, LOC.LOC        
      END    
   END    
   ELSE IF EXISTS (SELECT 1     
            FROM codelkup WITH (NOLOCK)     
            WHERE storerKey = @cStorerKey    
            AND listname = 'ADSTKSTS'    
            AND Code = @cHostWHCode    
            AND Long = 'I' )    
   BEGIN    
    --HomeLOC    
      SELECT TOP 1          
         @cSuggestedLOC = SL.LOC        
      FROM dbo.SKUxLOC SL WITH (NOLOCK)  
      JOIN dbo.LOC LOC WITH (NOLOCK) ON (LOC.LOC = SL.LOC AND LOC.Facility = @cFacility)       
      WHERE SL.StorerKey = @cStorerKey  
      AND SL.SKU = @cSKU        
      AND SL.LocationType = 'PICK'        
   END    
   ELSE IF EXISTS (SELECT 1     
            FROM codelkup WITH (NOLOCK)     
            WHERE storerKey = @cStorerKey    
            AND listname = 'ADSTKSTS'    
            AND Code = @cHostWHCode    
            AND Long = 'U' )    
   BEGIN    
    --HomeLOC    
      SELECT TOP 1          
            @cSuggestedLOC = SL.LOC        
      FROM dbo.SKUxLOC SL WITH (NOLOCK)  
      JOIN dbo.LOC LOC WITH (NOLOCK) ON (LOC.LOC = SL.LOC AND LOC.Facility = @cFacility)       
      WHERE SL.StorerKey = @cStorerKey  
      AND SL.SKU = @cSKU        
      AND SL.LocationType = 'PICK'        
  
      IF @cSuggestedLOC = ''    
      BEGIN    
       --No HomeLoc Setup, Suggest location as the Sku PutawayZone    
        SET @cSuggestedLOC = @cPutawayZone      
      END    
   END    
   ELSE    
   BEGIN    
      SET @nErrNo = 177901    
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- HostWHCodeErr    
      GOTO Quit    
   END    
       
   /*-------------------------------------------------------------------------------    
                                 Book suggested location    
   -------------------------------------------------------------------------------*/    
   IF ISNULL( @cSuggestedLOC, '') <> '' AND ISNULL( @cSuggestedLOC, '') <> @cPutawayZone  
   --IF ISNULL( @cSuggestedLOC, '') <> ''    
   BEGIN    
      SET @nErrNo = 0    
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
         GOTO Quit    
   END    
       
   Quit:    
    
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_523ExtPA43] TO NSQL
GO