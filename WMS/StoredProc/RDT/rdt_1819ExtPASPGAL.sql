  
/************************************************************************/                
/* Store procedure: rdt_1819ExtPASPGAL                                 */                
/* Copyright      : Maersk                                               */                
/* Modifications log:                                                   */                
/*                                                                      */                
/* Date         Rev  Author   Purposes                                  */                
/* 2025-11-30   1.0  JRA432   Galaxy Specific Putaway logic              */                 
/************************************************************************/                
                
CREATE OR ALTER          PROC [RDT].[rdt_1819ExtPASPGAL] (                
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
	  -- 1st choice: Level 0 (ground) in selected Aisles
      SELECT TOP 1                
            @cSuggLOC =  LOC.LOC                 
      FROM dbo.LOC LOC WITH (NOLOCK)
      WHERE LOC.Facility = @cFacility                       
         AND   LOC.LocationType in ( 'STORAGE')
         AND   LOC.LocationCategory in ( 'STORAGE')           
         AND   LOC.locationFlag = 'NONE'  
		 AND   SUBSTRING(LOC.Loc,1,3) = 'RM4'
		 AND   LOC.LocAisle in ('16','17','18','19')
		 AND   LOC.LocLevel in ('0')
         AND NOT EXISTS   (select  1  from dbo.LOTxLOCxID WITH (NOLOCK) where 
         --storerkey = @cStorerKey and --> WS 20250412  Removed as qwe use same locs for different storers in NLRT1
         QTY <>0 and LOC = loc.loc)  
		 -- Check Location is not already used to for non-finalized ASN PA
		 AND NOT EXISTS(SELECT 1 FROM dbo.ReceiptDetail rd (NOLOCK) 
						JOIN dbo.Receipt r (NOLOCK) ON r.StorerKey = rd.StorerKey AND r.ReceiptKey = rd.ReceiptKey
						WHERE r.Facility = Loc.Facility 
						AND rd.ToLoc = Loc.Loc
						AND r.Status NOT IN ('9','CANC'))	
         GROUP BY LOC.PALogicalLoc, LOC.Loc  
         ORDER BY LOC.PALogicalLoc, LOC.Loc ASC

		 IF ISNULL(@cSuggLOC,'') = ''
			  BEGIN		  
			  -- 2nd choice: Level 1 in selected Aisles			  
			  SELECT TOP 1                
					@cSuggLOC =  LOC.LOC                 
			  FROM dbo.LOC LOC WITH (NOLOCK)
			  WHERE LOC.Facility = @cFacility                       
				 AND   LOC.LocationType in ( 'STORAGE')
				 AND   LOC.LocationCategory in ( 'STORAGE')           
				 AND   LOC.locationFlag = 'NONE'  
				 AND   SUBSTRING(LOC.Loc,1,3) = 'RM4'
				 AND   LOC.LocAisle in ('16','17','18','19')
				 AND   LOC.LocLevel in ('1')
				 AND NOT EXISTS   (select  1  from dbo.LOTxLOCxID WITH (NOLOCK) where 
				 --storerkey = @cStorerKey and --> WS 20250412  Removed as qwe use same locs for different storers in NLRT1
				 QTY <>0 and LOC = loc.loc)   
				-- Ensure Location is not already used to for non-finalized ASN PA
				AND NOT EXISTS(SELECT 1 FROM dbo.ReceiptDetail rd (NOLOCK) 
								JOIN dbo.Receipt r (NOLOCK) ON r.StorerKey = rd.StorerKey AND r.ReceiptKey = rd.ReceiptKey
								WHERE r.Facility = Loc.Facility 
								AND rd.ToLoc = Loc.Loc
								AND r.Status NOT IN ('9','CANC'))					 
				 GROUP BY LOC.PALogicalLoc, LOC.Loc  
				 ORDER BY LOC.PALogicalLoc, LOC.Loc ASC
		 END
   END         
    /*       
   IF ISNULL( @cSuggLOC, '') = ''                
   BEGIN  
		
      SET @nErrNo = 202901              
      SET @cErrMsg = 'No Suitable Location'--rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NOSuiteLoc                
      GOTO Fail                
   END */               
                
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
