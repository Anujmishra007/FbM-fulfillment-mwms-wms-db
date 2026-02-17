
/************************************************************************/
/* Store procedure: rdt_664ExtInfo01_GAL                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author  Purposes                                     */
/* 2026-01-26 1.0  JRA432  Created                                      */
/************************************************************************/

CREATE OR ALTER     PROC [RDT].[rdt_664ExtInfo01_GAL]
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cStorerKey      NVARCHAR( 15),
   @cID             NVARCHAR( 18),              
   @cFromLOC        NVARCHAR( 10),              
   @cToLOC          NVARCHAR( 10),              
   @cSKU            NVARCHAR( 20),              
   @cReceiptKey     NVARCHAR( 10),              
   @cReceiptLineNumber NVARCHAR( 10),        
   @cOutText1       NVARCHAR( 20) OUTPUT,     
   @cOutText2       NVARCHAR( 20) OUTPUT,     
   @cOutText3       NVARCHAR( 20) OUTPUT,
   @nErrNo          INT OUTPUT,              
   @cErrMsg         NVARCHAR( 20) OUTPUT      
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cExtendedField01  NVARCHAR( 30) = '' 
          ,@cSuggLOC         NVARCHAR( 10)
		  ,@cLocLevel		 INT


   IF @nFunc = 664 -- Putaway by SKU
      BEGIN
      IF @nStep = 3 --Toloc
         IF EXISTS ( SELECT 1 FROM dbo.ReceiptDetail WITH (NOLOCK)         
				   WHERE StorerKey = @cStorerKey        
				   AND ToId = @cID 
				   HAVING Count(Distinct SKU) = 1 )     
         BEGIN  
	     -- 1st choice: Level 0 (ground) in selected Aisles
		  SELECT TOP 1                
				@cSuggLOC =  LOC.LOC    
				,@cLocLevel = LOC.LocLevel
		  FROM dbo.LOC LOC WITH (NOLOCK)
		  WHERE LOC.Facility = 'NLRT1' -- @cFacility                  
			 AND   LOC.LocationType in ( 'STORAGE')
			 AND   LOC.LocationCategory in ( 'STORAGE')           
			 AND   LOC.locationFlag = 'NONE'  
			 AND   SUBSTRING(LOC.Loc,1,3) = 'RM4'
			 AND   LOC.LocAisle in ('16','17','18','19')
			 AND   LOC.LocLevel in ('0')
			 AND NOT EXISTS   (select  1  from dbo.LOTxLOCxID WITH (NOLOCK) where 
			 --storerkey = @cStorerKey and --> WS 20250412  Removed as we use same locs for different storers in NLRT1
			 QTY <>0 and LOC = loc.loc)   
			 -- Ensure Location is not already used to for non-finailsed PA
			 AND NOT EXISTS(SELECT 1 FROM dbo.ReceiptDetail rd (NOLOCK) 
							JOIN dbo.Receipt r (NOLOCK) ON r.StorerKey = rd.StorerKey AND r.ReceiptKey = rd.ReceiptKey
							WHERE r.Facility = Loc.Facility 
							AND rd.ToLoc = Loc.Loc
							AND r.Status NOT IN ('9','CANC'))	
			 GROUP BY LOC.PALogicalLoc, LOC.Loc, LOC.LocLevel  
			 ORDER BY LOC.PALogicalLoc, LOC.Loc ASC

			 IF ISNULL(@cSuggLOC,'') = ''
				  BEGIN		  
				  -- 2nd choice: Level 1 in selected Aisles			  
				  SELECT TOP 1                
						@cSuggLOC =  LOC.LOC  
						,@cLocLevel = LOC.LocLevel
				  FROM dbo.LOC LOC WITH (NOLOCK)
				  WHERE LOC.Facility = 'NLRT1' --@cFacility                       
					 AND   LOC.LocationType in ( 'STORAGE')
					 AND   LOC.LocationCategory in ( 'STORAGE')           
					 AND   LOC.locationFlag = 'NONE'  
					 AND   SUBSTRING(LOC.Loc,1,3) = 'RM4'
					 AND   LOC.LocAisle in ('16','17','18','19')
					 AND   LOC.LocLevel in ('1')
					 AND NOT EXISTS   (select  1  from dbo.LOTxLOCxID WITH (NOLOCK) where 
					 --storerkey = @cStorerKey and --> WS 20250412  Removed as we use same locs for different storers in NLRT1
					 QTY <>0 and LOC = loc.loc) 
					 -- Ensure Location is not already used to for non-finailsed PA
					 AND NOT EXISTS(SELECT 1 FROM dbo.ReceiptDetail rd (NOLOCK) 
									JOIN dbo.Receipt r (NOLOCK) ON r.StorerKey = rd.StorerKey AND r.ReceiptKey = rd.ReceiptKey
									WHERE r.Facility = Loc.Facility 
									AND rd.ToLoc = Loc.Loc
									AND r.Status NOT IN ('9','CANC'))	
					 GROUP BY LOC.PALogicalLoc, LOC.Loc, LOC.LocLevel  
					 ORDER BY LOC.PALogicalLoc, LOC.Loc ASC
				END
		END
		SET @cOutText1 = CASE WHEN ISNULL(@cSuggLoc,'') = '' THEN 'No Location Found!' 
							  ELSE CONCAT('SuggLoc: ',@cSuggLoc) END 
		SET @cErrMsg = CASE WHEN ISNULL(@cSuggLoc,'') = '' THEN 'No Location Found!' 
							  WHEN ISNULL(@cSuggLoc,'') <> '' AND @cLocLevel > 0 THEN 'Slave Pallet Req!'
							  ELSE '' END 
		
	END
END