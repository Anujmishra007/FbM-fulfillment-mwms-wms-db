SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  
    
/************************************************************************/    
/* Store procedure: rdt_1819ExtValCSC                                   */    
/*                                                                      */    
/* Purpose:                                                             */    
/*                                                                      */    
/* Date        Rev  Author   Purposes                                   */    
/* 14-06-2024  1.0  MMA982   Check putaway zone and locationflag        */    
/************************************************************************/    
    
CREATE OR ALTER PROC [RDT].[rdt_1819ExtValCSC] (    
   @nMobile         INT,    
   @nFunc           INT,    
   @cLangCode       NVARCHAR( 3),    
   @nStep           INT,    
   @nInputKey       INT,    
   @cFromID         NVARCHAR( 18),    
   @cSuggLOC        NVARCHAR( 10),    
   @cPickAndDropLOC NVARCHAR( 10),    
   @cToLOC          NVARCHAR( 10),    
   @nErrNo          INT           OUTPUT,    
   @cErrMsg         NVARCHAR( 20) OUTPUT    
) AS    
BEGIN    
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
    
   IF @nFunc = 1819 -- Putaway by ID    
   BEGIN    
      IF @nStep = 2 -- ToLoc    
      BEGIN    
         IF @nInputKey = 1 -- ENTER    
         BEGIN    
             -- Get login info    
            DECLARE @cFacility  NVARCHAR( 5)    
            DECLARE @cStorerKey NVARCHAR( 15)    
                  , @cSuggPAZone NVARCHAR(10)     
                  , @cToLocPAZone NVARCHAR(10)     
                  , @cSKU         NVARCHAR(20)     
                  , @cPAStrategyKey NVARCHAR(10)    
      , @locationFlag  NVARCHAR(10)   
            SELECT     
               @cFacility = Facility,     
               @cStorerKey = StorerKey    
            FROM rdt.rdtMobRec WITH (NOLOCK)     
            WHERE Mobile = @nMobile    
                
            SELECT TOP 1 @cSKU = SKU     
            FROM dbo.LotxLocxID WITH (NOLOCK)     
            WHERE StorerKey = @cStorerKey    
            AND ID = @cFromID    
                
            SELECT @cPAStrategyKey = PutawayStrategyKey     
            FROM dbo.SKU SKU WITH (NOLOCK)     
            INNER JOIN dbo.Strategy S WITH (NOLOCK) ON SKU.StrategyKey = S.StrategyKey    
            WHERE StorerKey = @cStorerKey    
            AND SKU = @cSKU     
                
                
            --SELECT @cSuggPAZone = PutawayZone     
            --FROM dbo.Loc WITH (NOLOCK)     
            --WHERE LOC = @cSuggLOC    
                
            SELECT @cToLocPAZone = PutawayZone ,  
       @locationFlag = LocationFlag  
            FROM dbo.Loc WITH (NOLOCK)     
            WHERE LOC = @cToLOC    
                
            IF NOT EXISTS ( SELECT 1 FROM dbo.PutawayStrategyDetail WITH (NOLOCK)     
                            WHERE PutawayStrategyKey = @cPAStrategyKey    
                            AND Zone = @cToLocPAZone )     
            BEGIN    
               SET @nErrNo = 104451    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DiffPAZone    
               GOTO Quit    
            END    
  
   IF @locationFlag = 'INACTIVE'  
    BEGIN    
               SET @nErrNo = 112802    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Inactive loc    
               GOTO Quit    
            END    
  
         END    
      END    
   END    
    
Quit:    
    
END    
