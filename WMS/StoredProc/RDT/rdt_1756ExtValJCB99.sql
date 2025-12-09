
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1756ExtValJCB99                                 */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: For JCB                                                     */
/*                                                                      */
/* Date        Rev     Author      Purposes                             */
/* 2025-11-13  1.0.0   PPA374      Not allow to process without printer */ 
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1756ExtValJCB99]
   @nMobile         INT,                      
   @nFunc           INT,                      
   @cLangCode       NVARCHAR( 3),             
   @nStep           INT,                      
   @nScn            INT,                      
   @cAreaKey        NVARCHAR( 10),            
   @cEquipmentProfileKey NVARCHAR( 10),       
   @cNewEquipmentProfileKey NVARCHAR( 10),    
   @cTaskdetailKey  NVARCHAR( 10),            
   @nErrNo          INT OUTPUT,               
   @cErrMsg         NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @nInputKey INT

   SELECT TOP 1 @nInputKey = InputKey FROM RDT.RDTMOBREC WITH(NOLOCK) WHERE Mobile = @nMobile

   IF @nStep = 99
   BEGIN
      IF @nInputKey = 1
	  BEGIN
	     IF (SELECT TOP 1 ISNULL(Printer,'') FROM RDT.RDTMOBREC WITH(NOLOCK) WHERE Mobile = @nMobile) = ''
		 BEGIN
		    SET @nErrNo = 218250
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- No printer selected
            GOTO Quit
		 END
	  END
   END
Quit:
END
GO
GRANT EXECUTE ON  [RDT].[rdt_1756ExtValJCB99] TO [NSQL]
GO
