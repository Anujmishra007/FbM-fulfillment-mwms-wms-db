
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/    
/* Store procedure: rdt_521ExtPA15                                      */    
/*                                                                      */    
/* Purpose: Get suggested loc                                           */    
/*                                                                      */    
/* Called from: rdt_UCCPutaway_GetSuggestLOC                            */    
/*                                                                      */    
/* Date         Rev  Author   Purposes                                  */    
/* 2023-07-07   yeekung   1.0   WMS-22985 Created                       */
/************************************************************************/    
    
CREATE OR ALTER PROC [rdt].[rdt_521ExtPA15] (    
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
       
   DECLARE @cHostWHCode    NVARCHAR(10)    
   DECLARE @cPutawayZone   NVARCHAR(10)   
   DECLARE @cLocationCategory NVARCHAR(20)
   DECLARE @cLocAisle      NVARCHAR(20)
   DECLARE @nTranCount     INT = 0
   DECLARE @cStyle         NVARCHAR(20)
   DECLARE @cSKUGroup      NVARCHAR(20)


   SELECT @cSKUGroup = skugroup,
         @cStyle =style
   FROM SKU (NOLOCK)
   where sku=@csku
   AND storerkey=@cstorerkey

   --New Empty LOC
   IF @cSuggestedLOC=''
   BEGIN

      SELECT TOP 1 @cSuggestedLOC=LOC.loc
      FROM LOTXLOCXID LLI (NOLOCK) 
      JOIN SKU SKU (NOLOCK) ON LLI.SKU = SKU.SKU AND LLI.storerkey= SKU.Storerkey
      JOIN LOC LOC (nolock) ON LLI.LOC =LOC.LOC
      JOIN CODELKUP cl (nolock) ON LOC.LocationCategory = cl.Short and LOC.floor = cl.Code
      WHERE SKU.Style = @cStyle
         AND LOC.Facility  = @cFacility
         AND CL.Storerkey = @cStorerkey
         AND LOC.LOC <> @cLOC
      GROUP BY LOC.LogicalLocation,LOC.loc
      HAVING SUM(LLI.QTY-LLI.QTYAllocated-LLI.qtypicked)>0
      ORDER BY LOC.LogicalLocation asc

      --New Empty LOC
      IF @cSuggestedLOC=''
      BEGIN
         SELECT TOP 1 @cSuggestedLOC=LOC.loc
         FROM LOTXLOCXID LLI (NOLOCK) 
         LEFT JOIN SKU SKU (NOLOCK) ON LLI.SKU = SKU.SKU AND LLI.storerkey= SKU.Storerkey
         LEFT JOIN LOC LOC (nolock) ON LLI.LOC =LOC.LOC
         LEFT JOIN CODELKUP cl (nolock) ON LOC.LocationCategory = cl.Short and LOC.floor = cl.Code and listname ='SKEFLOOR'
         WHERE  LOC.Facility  = @cFacility
            AND LOC.LOC <> @cLOC
         GROUP BY LOC.LogicalLocation,LOC.loc
         HAVING SUM(ISNULL(LLI.QTY,'0')-ISNULL(LLI.QTYAllocated,'0')-ISNULL(LLI.qtypicked,'0')) =0
         ORDER BY LOC.LogicalLocation asc
      END

                             
   END

   /*-------------------------------------------------------------------------------    
                                 Book suggested location    
   -------------------------------------------------------------------------------*/    
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
         ,@cUCCNo        = @cUCC    
         ,@nPABookingKey = @nPABookingKey OUTPUT    
      IF @nErrNo <> 0    
         GOTO QUIT    
   END    
   GOTO Quit    
     
Quit:    
END

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_521ExtPA15] TO NSQL
GO  