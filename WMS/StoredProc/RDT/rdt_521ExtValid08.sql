

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_521ExtValid08                                   */
/* Purpose: Validate override toLoc for Levis                           */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author    Purposes                                  */
/* 2024-06-07  1.0  Jackc     FCR-264. Created                          */ 
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_521ExtValid08] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cStorerKey      NVARCHAR( 15),
   @cUCCNo          NVARCHAR( 20),
   @cSuggestedLOC   NVARCHAR( 10),
   @cToLOC          NVARCHAR( 10),
   @nErrNo          INT OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  @cFacility           NVARCHAR( 5),  
            @cToLocType          NVARCHAR( 10),
            @cToPutawayZone      NVARCHAR( 20),
            @cToLocAisle         NVARCHAR( 10),
            @nToMaxCarton        INT,
            @nRFToPABookKey      INT,
            @cSuggestPutawayZone NVARCHAR( 20),
            @cSuggestLocAsile    NVARCHAR( 10),
            @nSuggestMaxCarton   INT,
            @cRFSuggtFromLoc     NVARCHAR( 10),
            @nRFSuggtPABookKey   INT,
            @cRFSuggtFromID      NVARCHAR ( 18),
            @cSuggesttLocCat     NVARCHAR ( 10)

   SET @nErrNo = 0
   SET @cErrMSG = ''
   SET @nRFSuggtPABookKey = 0
   SET @nRFToPABookKey = 0

   SELECT @cFacility = Facility FROM rdt.rdtMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile

   IF @nFunc = 521
   BEGIN
      IF @nStep = 2
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @cSuggestedLOC <> @cToLOC
            BEGIN
               --GET toLoc info
               SELECT 
                  @cToLocType = LocationType
                  , @cToPutawayZone = PutawayZone
                  , @cToLocAisle = LocAisle
                  , @nToMaxCarton = IIF(MaxCarton=0, 9999, MaxCarton)
               FROM LOC WITH (NOLOCK)
               WHERE FACILITY = @cFacility
                  AND LOC = @cToLOC
               
               --Get SuggestLoc info
               SELECT 
                  @cSuggestPutawayZone = PutawayZone
                  , @cSuggestLocAsile = LocAisle
                  , @nSuggestMaxCarton = IIF(MaxCarton=0, 9999, MaxCarton)
               FROM LOC WITH (NOLOCK)
               WHERE FACILITY = @cFacility
                  AND LOC = @cSuggestedLOC

               --Validate toLoc
               --To Loc type not valid
               IF @cToLocType <> 'CASE' 
               BEGIN
                  SET @nErrNo = 216151
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Loc Type
                  GOTO Quit
               END

               --To loc putaway zone not valid
               IF @cToPutawayZone <> @cSuggestPutawayZone
               BEGIN
                  SET @nErrNo = 216152
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid putaway zone
                  GOTO Quit
               END

               IF ((SELECT COUNT(1) FROM UCC WITH (NOLOCK) WHERE LOC = @cToLOC GROUP BY LOC) 
                     >= @nToMaxCarton)
               BEGIN
                  SET @nErrNo = 216153
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ToLoc is Full
                  GOTO Quit
               END

               --Get UCC RFPutaway data
               SELECT 
                  @cRFSuggtFromLoc = FromLoc
                  , @cRFSuggtFromID = FromID
                  , @nRFSuggtPABookKey = PABookingKey
                  , @cSuggesttLocCat = LOC.LocationCategory
               FROM RFPUTAWAY rf WITH (NOLOCK)
                  LEFT JOIN LOC WITH (NOLOCK) ON LOC.Facility = @cFacility AND rf.FromLoc = LOC.Loc
               WHERE SuggestedLoc = @cSuggestedLOC
                  AND CaseID = @cUCCNo

               -- Can toLoc can be any loc which capacity is enough to store the UCC
               IF @cToLocAisle = @cSuggestedLOC AND @cSuggesttLocCat  IN ('PND', 'PND_IN', 'PND_OUT')
               BEGIN
                  SELECT 'PND & Same Aisle'
               END
               

               -- 如果 to loc有被book的信息，





            END -- suggtLoc <> toLoc
         END -- inputkey =1
      END -- Step 2
   END -- func 521

   QUIT:

END-- END SP
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_521ExtValid08 TO NSQL
GO
