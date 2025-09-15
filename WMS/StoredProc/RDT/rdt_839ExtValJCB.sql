
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*************************************************************************************/
/* Store procedure: [rdt_839ExtValJCB]                                               */
/* Copyright: Maersk                                                                 */
/*                                                                                   */
/* Date         Rev   Author   Purposes                                              */
/* 12/09/2025   1.0   PPA374   Only allow PickZones from CODELKUP PickPiece pick     */
/*************************************************************************************/

ALTER   PROC [RDT].[rdt_839ExtValJCB] (
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
   @cPackData1   NVARCHAR( 30),  
   @cPackData2   NVARCHAR( 30),  
   @cPackData3   NVARCHAR( 30),  
   @nErrNo       INT    OUTPUT,  
   @cErrMsg      NVARCHAR(250) OUTPUT  
) AS

BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 839
   BEGIN
	  IF @nStep = 2 
	     AND @nInputKey = 1 --PickZone
	  BEGIN
	     IF NOT EXISTS (
		    SELECT 1 
			FROM dbo.CODELKUP WITH(NOLOCK) 
			WHERE LISTNAME = 'JCBPPPZ' 
			   AND Code = @cPickZone
	     )
		 BEGIN
		    SET @nErrNo = 218238
			SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
			GOTO QUIT
		 END
      END
   END
Quit:
END
GO

GRANT EXECUTE ON rdt_839ExtValJCB TO NSQL
GO
