IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[RDT].[rdt_839ExtValidSP04]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_839ExtValidSP04]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  

/************************************************************************/  
/* Store procedure: rdt_839ExtValidSP04                                 */  
/* Purpose:                                                             */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2021-03-29 1.0  James      WMS-16553. Created                        */  
/************************************************************************/  
CREATE PROC rdt.rdt_839ExtValidSP04 (  
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,           
   @nInputKey    INT,           
   @cFacility    NVARCHAR( 5) , 
   @cStorerKey   NVARCHAR( 15), 
   @cType        NVARCHAR( 10), 
   @cPickSlipNo  NVARCHAR( 10), 
   @cPickZone    NVARCHAR( 1),  
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
   DECLARE @cUserName      NVARCHAR( 18)
  
   SET @nErrNo          = 0
   SET @cErrMSG         = ''

   SELECT @cUserName = UserName
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
   
   IF @nStep = 1
   BEGIN
      IF @nInputKey = 1
      BEGIN
         IF EXISTS ( SELECT 1 FROM dbo.PickingInfo WITH (NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                     AND   ISNULL( ScanInDate, '') <> ''
                     AND   PickerID = 'VOICEPICKING') 
         BEGIN
            SET @nErrNo = 165351
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'VP Picked'
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

GRANT EXEC ON RDT.rdt_839ExtValidSP04 TO NSQL
GO
  
 