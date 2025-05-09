    
/************************************************************************/                
/* Store procedure: rdt_1819ExtPASPSLD2                                 */                
/* Copyright      : Maersk                                                                     */                
/* Modifications log:                                                   */                
/*                                                                      */                
/* Date         Rev  Author   Purposes                                  */                
/* 2025-03-12   1.0  WSE016    WMS-33003 PE review                       */                 
/************************************************************************/                
                
CREATE OR ALTER      PROC [RDT].[rdt_1819ExtPASPSLD2] (                
   @nMobile          INT,                
   @nFunc            INT,                
   @cLangCode        NVARCHAR( 3),                
   @cUserName        NVARCHAR( 18),                
   @cStorerKey       NVARCHAR( 15),                 
   @cFacility        NVARCHAR( 5),                 
   @cFromLOC         NVARCHAR( 10),                
   @cID              NVARCHAR( 18),                
   @cSuggLOC         NVARCHAR( 10) = ''  OUTPUT,                
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
                   
   DECLARE @cSKU           NVARCHAR( 20)                
   DECLARE @cPutawayZone   NVARCHAR(10)                   
   DECLARE @cLottable03    NVARCHAR( 20)                
   DECLARE @nTranCount     INT                
   DECLARE @nPalletTotStdCube FLOAT    
   DECLARE @QtyLocationLimit NVARCHAR( 20)            
   DECLARE @LPN_Qty NVARCHAR( 20)     
                          
   SELECT TOP 1 @cSKU = SKU.SKU,                              
               @cFromLOC = LLI.LOC,                
               @cPutawayZone = SKU.PutawayZone ,
               @cFacility = sku.facility,
               @LPN_Qty = Qty                  
   FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)                        
      JOIN SKU SKU (NOLOCK) ON SKU.SKU = LLI.SKU AND SKU.Storerkey = LLI.Storerkey                
   WHERE ID = @cID                
      AND SKU.Storerkey = @cStorerKey  
      AND LLI.qty >0                 
   ORDER BY LLI.QTY DESC                
      
       
   IF EXISTS ( SELECT 1 FROM dbo.LotxLocxID WITH (NOLOCK)         
               WHERE StorerKey = @cStorerKey        
               AND ID = @cID        
               HAVING Count(Distinct SKU) = 1 )     
   BEGIN    
      SELECT TOP 1                
            @cSuggLOC =  LOC.LOC                 
      FROM dbo.LOC LOC WITH (NOLOCK)
      WHERE LOC.Facility = @cFacility                       
         AND   LOC.LocationType in ( 'STORAGE', 'PICK', 'SHELF')
         AND   LOC.LocationCategory in ( 'STORAGE'  , 'PICK')           
         AND   LOC.locationFlag = 'NONE'  
         AND   LOC.PutawayZone in ('SLED_ST' ,'SLED_PF')      
         AND NOT EXISTS   (select  1  from dbo.LOTxLOCxID WITH (NOLOCK) where 
         --storerkey = @cStorerKey and --> WS 20250412  Removed as qwe use same locs for different storers in NLRT1
         QTY <>0 and LOC = loc.loc)           
         GROUP BY LOC.PALogicalLoc, LOC.Loc  
         ORDER BY LOC.PALogicalLoc, LOC.Loc 
   END         
           
   IF ISNULL( @cSuggLOC, '') = ''                
   BEGIN                
      SET @nErrNo = 202901              
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NOSuiteLoc                
      GOTO Fail                
   END                
                
   IF ISNULL( @cSuggLOC, '') <> ''                
   BEGIN
      --PE review comments: No need transaction. rdt_Putaway_PendingMoveIn has its own transaction     
      /*Handling transaction                
      SET @nTranCount = @@TRANCOUNT                
      BEGIN TRAN  -- Begin our own transaction                
      SAVE TRAN rdt_1819ExtPASPSLD2 -- For rollback or commit only our own transaction*/                
                
      EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK'                
         ,@cFromLOC                
         ,@cID                
         ,@cSuggLOC                
         ,@cStorerKey            
         ,@nErrNo  OUTPUT                
         ,@cErrMsg OUTPUT                
         ,@nPABookingKey = @nPABookingKey OUTPUT                
      IF @nErrNo <> 0
      BEGIN                
         /*GOTO RollBackTraN*/
         SET @nErrNo = 0 -- To Go to ToLoc screen even have error     
         SET @cSuggLOC = '' 
         GOTO Quit
      END                
      
      --PE review comments: Not need transaction.
      /*COMMIT TRAN rdt_1819ExtPASPSLD2 */       
                  
      GOTO Quit                

       --PE review comments: Not need transaction. rdt_Putaway_PendingMoveIn has its own transaction         
      /*RollBackTran:                
         ROLLBACK TRAN rdt_1819ExtPASPSLD2 -- Only rollback change made here            
         SET @nErrNo = 0 -- To Go to ToLoc screen even have error     
         SET @cSuggLOC = '' 
         GOTO Quit  */         
   END

   Quit:
      --PE review comments: Not need transaction. rdt_Putaway_PendingMoveIn has its own transaction                
      /*WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started                
         COMMIT TRAN*/                        
                
   Fail:                
   --SET @nErrNo = 0 -- To Go to ToLoc screen even have error       


END   
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1819ExtPASPSLD2] TO [NSQL]
GO
