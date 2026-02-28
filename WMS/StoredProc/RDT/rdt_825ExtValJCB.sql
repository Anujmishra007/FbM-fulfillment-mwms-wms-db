
/****** Object:  StoredProcedure [RDT].[rdt_825ExtValJCB]    Script Date: 7/15/2025 5:20:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************/
/* Store procedure: [rdt_825ExtValJCB]                                                              */
/* Copyright: Maersk                                                                                */
/*                                                                                                  */
/* Date         Rev   Author   Purposes                                                             */
/* 31/03/2025   1.0   PPA374   Created                                      	                    */
/* 31/03/2025   1.0   PPA374   Checks that fields are blank                                         */
/****************************************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_825ExtValJCB] (
   @nMobile        INT,            
   @nFunc          INT,            
   @cLangCode      NVARCHAR( 3),   
   @nStep          INT,            
   @nInputKey      INT,            
   @cStorerKey     NVARCHAR( 15),  
   @cFacility      NVARCHAR( 5),   
   @cPalletKey     NVARCHAR( 30),  
   @cLength        NVARCHAR( 10),  
   @cWidth         NVARCHAR( 10),  
   @cHeight        NVARCHAR( 10),  
   @cWeight        NVARCHAR( 10),  
   @nErrNo         INT           OUTPUT,  
   @cErrMsg        NVARCHAR( 20) OUTPUT
) AS

BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nStep = 1 
      AND @nInputKey = 1
   BEGIN

      IF @cLength <> '' 
	     OR @cHeight <> '' 
		 OR @cWidth <> ''
	  BEGIN
	     SET @nErrNo = 218229
		 SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')--'Keep fields blank'
	  END
   END
END

GO
GRANT EXECUTE ON [RDT].[rdt_825ExtValJCB] TO [NSQL]
GO
