SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************/
/* Store procedure: rdt_1812ExtVal04                                    	  */
/* Purpose: Validate DropID                                             	  */
/*                                                                      	  */
/* Modifications log:                                               	      */
/*                                                                      	  */
/* Date         Author    Ver.  Purposes                               		  */
/* 2014-07-08   Ung       1.0   SOS327467 Created                             */
/* 2025-04-11   PSJ036    1.1   Copy from SP rdt_1812ExtVal01 CR RITM7816261  */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1812ExtVal04]
    @nMobile         INT 
   ,@nFunc           INT 
   ,@cLangCode       NVARCHAR( 3) 
   ,@nStep           INT 
   ,@nInputKey       INT
   ,@cTaskdetailKey  NVARCHAR( 10)
   ,@cDropID         NVARCHAR( 20)
   ,@nQTY            INT
   ,@cToLOC          NVARCHAR( 10)
   ,@nErrNo          INT           OUTPUT 
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   -- TM Pallet Pick
   IF @nFunc = 1812
   BEGIN
      IF @nStep = 1 -- DropID
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Check DropID
            IF @cDropID = ''
            BEGIN
               SET @nErrNo = 239051
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Need DropID
               EXEC rdt.rdtSetFocusField @nMobile, 4 -- DropID
               GOTO Quit
            END
            
            -- Get storer
            DECLARE @cStorerKey NVARCHAR(15)
            SELECT @cStorerKey = StorerKey FROM dbo.TaskDetail WITH (NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey
            
            -- Check duplicate
            IF EXISTS( SELECT 1 FROM dbo.PickDetail WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND DropID = @cDropID ) --PSJ036 Removed Status < 9
            BEGIN
               SET @nErrNo = 239052
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- DropID used
               EXEC rdt.rdtSetFocusField @nMobile, 4 -- DropID
               GOTO Quit
            END
         END
      END
   END
   GOTO Quit

Quit:

END

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1812ExtVal04 TO NSQL
GO
