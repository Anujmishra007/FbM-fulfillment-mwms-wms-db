SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_1819ExtVal20                                    */
/* Copyright      : Maersk WMS                                          */
/* Customer       : LEVIS UAE                                           */
/*                                                                      */
/* Purpose: Location Type must be CASE                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2025-07-25   NickT     1.0.0 FCR-6088 Created                        */
/* 2025-07-28   NickT     1.0.1 FCR-6088 Fixed an issue                 */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1819ExtVal20]
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

   IF @nFunc = 1819 -- Putaway by ID
   BEGIN
      IF @nStep = 2 -- To LOC
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Get session info
            DECLARE 
               @cStorerKey       NVARCHAR( 15),
               @cFacility        NVARCHAR( 5),
               @cLottable03      NVARCHAR( 18),
               @cLocationType    NVARCHAR( 10),
               @cPutawayZone     NVARCHAR( 10),
               @nRowCount        INT

            SELECT 
               @cStorerKey = StorerKey, 
               @cFacility = Facility
            FROM rdt.rdtMobRec WITH (NOLOCK)
            WHERE Mobile = @nMobile

            SELECT TOP 1 @cLottable03 = LA.Lottable03 
            FROM dbo.LOTXLOCXID LLI WITH (NOLOCK)
            INNER JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK) ON LLI.StorerKey = LA.StorerKey AND LLI.Lot = LA.Lot
            WHERE LLI.StorerKey = @cStorerKey
               AND LLI.ID = @cFromID

            IF ISNULL(@cLottable03, '') = ''
            BEGIN
               SELECT @cLocationType = LocationType
               FROM dbo.LOC WITH (NOLOCK)
               WHERE Facility = @cFacility
                  AND LOC = @cToLOC

               IF @cLocationType <> 'CASE'
               BEGIN
                  SET @nErrNo = 242751
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Location type is not CASE
                  GOTO Quit
               END
            END
            ELSE
            BEGIN
               SELECT @cPutawayZone = PutawayZone
               FROM dbo.LOC WITH (NOLOCK)
               WHERE Facility = @cFacility
                  AND LOC = @cToLoC

               SELECT @nRowCount = COUNT(1)
               FROM dbo.CODELKUP WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND LISTNAME = 'LVSCTZONE'
                  AND ISNULL(Long, '') = @cLottable03
                  AND Code = @cPutawayZone

               IF @nRowCount = 0
               BEGIN
                  SET @nErrNo = 242752
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Location Putaway Zone is not in LVSCTZONE
                  GOTO Quit
               END
            END
         END
      END
   END

Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_1819ExtVal20] TO [NSQL]
GO
