SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Store procedure: rdt_523ExtValidSP99                                 */  
/* Purpose: Validate DefaultQty X nQty                                  */  
/*                                                                      */
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author    Purposes                                   */  
/* 2025-12-08 1.0  ELB012    Project - RITM8172881                      */  
/************************************************************************/  
  
CREATE OR ALTER PROC [RDT].[rdt_523ExtValidSP99] (  
   @nMobile         INT, 
   @nFunc           INT, 
   @cLangCode       NVARCHAR( 3),  
   @nStep           INT, 
   @nInputKey       INT, 
   @cStorerKey      NVARCHAR( 15), 
   @cFacility       NVARCHAR( 5),  
   @cFromLOC        NVARCHAR( 10), 
   @cFromID         NVARCHAR( 18), 
   @cSKU            NVARCHAR( 20), 
   @nQty            INT,  
   @cSuggestedLOC   NVARCHAR( 10), 
   @cFinalLOC       NVARCHAR( 10), 
   @cOption         NVARCHAR( 1),  
   @nErrNo          INT           OUTPUT,  
   @cErrMsg         NVARCHAR( 20) OUTPUT
)  
AS  
BEGIN
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF     

   DECLARE @cDefaultQty VARCHAR(1)
   SET @cDefaultQTY = rdt.RDTGetConfig( @nFunc, 'DefaultQTY', @cStorerKey)

   IF @nStep = 3
   BEGIN
      IF @cDefaultQTY = '1' 
      BEGIN
         IF @nInputKey = 1  
         BEGIN  
            IF @nQty <> '1'
            BEGIN
               SET @nErrNo = 73032
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 73032^QTY>Suggest
               GOTO Quit 
            END
         END
      END
   END
    
QUIT:

END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON  [RDT].[rdt_523ExtValidSP99] TO [NSQL]
GO
