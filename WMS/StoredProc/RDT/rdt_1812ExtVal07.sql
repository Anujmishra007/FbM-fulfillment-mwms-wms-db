SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1812ExtVal07                                    */
/* Copyright      : Maersk                                              */
/* Purpose        : JCB UC                                              */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2026-08-04   JCH507    1.0   FCR-14961 - Created                    */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1812ExtVal07]
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

   IF @nFunc = 1812
   BEGIN
      IF @nStep = 6 -- To LOC
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            DECLARE @cSuggToLoc  NVARCHAR(10)
            SELECT @cSuggToLoc = ToLOC FROM dbo.TaskDetail WITH (NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey

            IF @cSuggToLoc IS NULL
            BEGIN
               SET @nErrNo = 276652
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END

            IF @cToLOC <> @cSuggToLoc
            BEGIN
               DECLARE @cToLocCategory   NVARCHAR(10)
               DECLARE @cSuggLocCategory NVARCHAR(10)

               SELECT @cToLocCategory   = LocationCategory FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cToLOC
               SELECT @cSuggLocCategory = LocationCategory FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cSuggToLoc

               IF ISNULL(@cToLocCategory, '') <> ISNULL(@cSuggLocCategory, '')
               BEGIN
                  SET @nErrNo = 276651
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  EXEC rdt.rdtSetFocusField @nMobile, 3 -- ToLoc field
                  GOTO Quit
               END
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

GRANT EXECUTE ON [RDT].[rdt_1812ExtVal07] TO [NSQL]
GO
