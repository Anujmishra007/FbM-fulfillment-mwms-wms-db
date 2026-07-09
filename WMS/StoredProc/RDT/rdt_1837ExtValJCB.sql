SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Store procedure: rdt_1837ExtInfo1_JCB                                */  
/*                                                                      */  
/* Purpose:       Not merging non-completed task IDs                    */  
/*                                                                      */  
/* Date         Rev   Author   Purposes                                 */  
/* 2026-07-09   1.0   PPA374   Created                                  */  
/************************************************************************/ 
CREATE OR ALTER PROC PROC [RDT].[rdt_1837ExtValJCB] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cCartonID      NVARCHAR( 20), 
   @cPalletID      NVARCHAR( 20), 
   @cLoadKey       NVARCHAR( 10), 
   @cLoc           NVARCHAR( 10), 
   @cOption        NVARCHAR( 1), 
   @tExtValidate   VariableTable READONLY,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nStep = 1
   AND EXISTS 
   (
      SELECT 1 
      FROM TaskDetail WITH(NOLOCK)
      WHERE Status NOT IN ('x','9')
	     AND FromID = @cCartonID
		 AND Storerkey = @cStorerKey
   )
   BEGIN
      SET @nErrNo = 218154
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --LPN task is open
   END
END
GO
GRANT EXECUTE ON rdt_1837ExtValJCB TO NSQL
GO
