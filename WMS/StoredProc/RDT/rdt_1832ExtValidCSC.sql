SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/            
/* Store procedure: rdt_1832ExtValidCSC                                 */            
/* Purpose: Validate  UCC                                               */            
/*                                                                      */            
/* Modifications log:                                                   */            
/*                                                                      */            
/* Date       Rev  Author     Purposes                                  */            
/* 2026-06-10 1.0  TTW017     Created                                   */            
/************************************************************************/            
            
CREATE OR ALTER PROC [RDT].[rdt_1832ExtValidCSC] (            
     @nMobile         INT,           
     @nFunc           INT,           
     @cLangCode       NVARCHAR(3),           
     @nStep           INT,           
     @cStorerKey      NVARCHAR(15),          
     @cFacility       NVARCHAR(5),           
     @cFromLOC        NVARCHAR(10),          
     @cFromID         NVARCHAR(18),          
     @cSKU            NVARCHAR(20),          
     @nQTY            INT,           
     @cUCC            NVARCHAR(20),          
     @cToID           NVARCHAR(18),          
     @cToLOC          NVARCHAR(10),          
     @nErrNo          INT OUTPUT,           
     @cErrMsg         NVARCHAR(20) OUTPUT          
)            
AS            
            
SET NOCOUNT ON              
SET QUOTED_IDENTIFIER OFF              
SET ANSI_NULLS OFF              
SET CONCAT_NULL_YIELDS_NULL OFF              
            
IF @nFunc = 1832            
BEGIN           
        
   IF @nStep = 5          
   BEGIN          
  
   IF EXISTS (SELECT 1  
              FROM dbo.lotxlocxid WITH (NOLOCK)  
              WHERE StorerKey = @cStorerKey          
                AND ID = @cToID  
                AND Qty != 0)  
  
    BEGIN  
        IF NOT EXISTS (SELECT 1  
                       FROM dbo.lotxlocxid WITH (NOLOCK)  
                       WHERE StorerKey = @cStorerKey          
                         AND ID = @cToID  
                         AND LOC = @cToLOC  
                         AND Qty != 0)  
        BEGIN          
            SET @nErrNo = 270801          
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --'ID not in LOC'  
            GOTO QUIT          
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

GRANT EXECUTE ON RDT.rdt_1832ExtValidCSC TO NSQL
GO