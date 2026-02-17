SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1819ExtVal25                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Customer: DAIMLER TRUCK AG                                           */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Ver.  Author      Purposes                               */
/* 2026-02-10  1.0   JACKC       FCR-9755. Created                      */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1819ExtVal25]
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cFromID         NVARCHAR( 18),
   @cSuggLOC        NVARCHAR( 10),
   @cPickAndDropLOC NVARCHAR( 10),
   @cToLOC          NVARCHAR( 10),
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   -- Change ID
   IF @nFunc = 1819
   BEGIN
      IF @nStep = 1 
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Validate FromID's Location Type against PAALLZON
            IF NOT EXISTS (
               SELECT 1
               FROM dbo.LOTXLOCXID lli WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK)
                  ON LOC.Loc = lli.Loc
               JOIN dbo.CODELKUP cl WITH (NOLOCK)
                  ON lli.StorerKey = cl.StorerKey
                  AND cl.Code = LOC.LocationType
                  AND cl.ListName = 'PAALLZON'
               WHERE lli.Id = @cFromID
            )
            BEGIN
               SET @nErrNo = 258601
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END

         END--enter
      END --st1
   END

Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_1819ExtVal25] TO [NSQL]
GO
