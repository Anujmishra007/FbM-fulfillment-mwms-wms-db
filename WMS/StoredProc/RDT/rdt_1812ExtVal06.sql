SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1812ExtVal06                                    */
/* Purpose: Validate DropID in orher User is in use in the fn1812       */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2026-02-26   ELB012    1.0   UWP-49560 RITM8670783 - Created         */
/************************************************************************/

CREATE OR ALTER   PROCEDURE [RDT].[rdt_1812ExtVal06]
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

   -- TM Pick
   IF @nFunc = 1812
   BEGIN
      IF @nStep = 1 -- DropID
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF EXISTS(SELECT 1 FROM RDT.RDTMOBREC WITH (NOLOCK) WHERE Mobile <> @nMobile AND O_Field02 = @cDropID AND Func = @nFunc)
            BEGIN
               SET @nErrNo = 260301
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Tote in Use
               GOTO Quit
            END
            -- Get storer
            DECLARE @cStorerKey NVARCHAR(15)
            SELECT @cStorerKey = StorerKey FROM dbo.TaskDetail WITH (NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey

            -- Check duplicate
            IF EXISTS( SELECT 1 FROM dbo.PickDetail WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND DropID = @cDropID AND Status <= '5')
            BEGIN
               SET @nErrNo = 260302
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

GRANT EXECUTE ON [RDT].[rdt_1812ExtVal06] TO [NSQL]
GO