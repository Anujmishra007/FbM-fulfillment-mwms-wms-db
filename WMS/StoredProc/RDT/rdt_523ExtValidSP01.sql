IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[RDT].[rdt_523ExtValidSP01]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_523ExtValidSP01]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  
/************************************************************************/  
/* Store procedure: rdt_523ExtValidSP01                                 */  
/* Purpose: Validate  Location                                          */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2015-05-21 1.0  ChewKP     SOS#340776                                */  
/************************************************************************/  
  
CREATE PROC rdt.rdt_523ExtValidSP01 (  
      @nMobile         INT, 
      @nFunc           INT, 
      @cLangCode       NVARCHAR( 3),  
      @nStep           INT, 
      @cStorerKey      NVARCHAR( 15), 
      @cFacility       NVARCHAR( 5),  
      @cFromLOC        NVARCHAR( 10), 
      @cFromID         NVARCHAR( 18), 
      @cSKU            NVARCHAR( 20), 
      @nQty            INT,  
      @cToLoc          NVARCHAR( 10), 
      @cToID           NVARCHAR( 18), 
      @nErrNo          INT           OUTPUT,  
      @cErrMsg         NVARCHAR( 20) OUTPUT
)  
AS  
  
SET NOCOUNT ON    
SET QUOTED_IDENTIFIER OFF    
SET ANSI_NULLS OFF    
SET CONCAT_NULL_YIELDS_NULL OFF    
  
IF @nFunc = 523  
BEGIN  
   
    
    DECLARE  @cSuggestedLOC       NVARCHAR(10)

    
    SET @nErrNo          = 0
    SET @cErrMSG         = ''
    

       
    IF @nStep = '6'
    BEGIN

       SELECT @cSuggestedLOC = V_String13
       FROM rdt.rdtMobrec WITH (NOLOCK)
       WHERE Mobile = @nMobile
       
       IF RIGHT(@cSuggestedLOC,9 ) <> RIGHT(@cToLoc,9 )
       BEGIN
            SET @nErrNo = 93201
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'InvalidLoc'
            GOTO QUIT
       END
       
       
       
    END
    
    

   
END  
  
QUIT:  

 
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXEC ON RDT.rdt_523ExtValidSP01 TO NSQL
GO
  
 