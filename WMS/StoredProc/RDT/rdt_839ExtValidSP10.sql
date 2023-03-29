SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  

/************************************************************************/  
/* Store procedure: rdt_839ExtValidSP10                                 */  
/* Purpose: Validate option                                             */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2021-12-20 1.0  James      WMS-18004. Created                        */  
/************************************************************************/  
CREATE OR ALTER PROC rdt.rdt_839ExtValidSP10 (  
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,           
   @nInputKey    INT,           
   @cFacility    NVARCHAR( 5) , 
   @cStorerKey   NVARCHAR( 15), 
   @cType        NVARCHAR( 10), 
   @cPickSlipNo  NVARCHAR( 10), 
   @cPickZone    NVARCHAR( 10),  
   @cDropID      NVARCHAR( 20), 
   @cLOC         NVARCHAR( 10), 
   @cSKU         NVARCHAR( 20), 
   @nQTY         INT,           
   @nErrNo       INT           OUTPUT, 
   @cErrMsg      NVARCHAR(250) OUTPUT  
)  
AS  

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF
  
IF @nFunc = 839  
BEGIN  
   DECLARE @cOption           NVARCHAR( 1)
          
   SET @nErrNo          = 0
   SET @cErrMSG         = ''

   IF @nStep = 5 
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         SELECT @cOption = I_Field01 
         FROM rdt.RDTMOBREC WITH (NOLOCK)
         WHERE Mobile = @nMobile 
         
         IF @cOption = '1'   
         BEGIN  
            SET @nErrNo = 180201
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Cannot ShtPick'
            GOTO QUIT  
         END  

         IF @cOption = '4'   
         BEGIN  
            SET @nErrNo = 180202
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Cannot SkipLoc'
            GOTO QUIT  
         END  
      END
   END
END  
  
QUIT:  

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXEC ON RDT.rdt_839ExtValidSP10 TO NSQL
GO
  
 