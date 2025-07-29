SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO
/**************************************************************************/
/* Store procedure: rdt_513ExtVal13                                       */
/* Copyright: Maersk                                                      */
/* Customer : Levis UAE                                                   */
/*                                                                        */
/* Date       Rev    Author     Purposes                                  */
/* 2025-07-29 1.0.0  NickT      FCR-6187 Created                          */
/**************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_513ExtVal13] (
   @nMobile         INT,          
   @nFunc           INT,          
   @cLangCode       NVARCHAR( 3), 
   @nStep           INT,          
   @nInputKey       INT,          
   @cStorerKey      NVARCHAR( 15),
   @cFacility       NVARCHAR(  5),
   @cFromLOC        NVARCHAR( 10),
   @cFromID         NVARCHAR( 18),
   @cSKU            NVARCHAR( 20),
   @nQTY            INT,          
   @cToID           NVARCHAR( 18),
   @cToLOC          NVARCHAR( 10),
   @nErrNo          INT           OUTPUT,   
   @cErrMsg         NVARCHAR( 20) OUTPUT
)
AS
BEGIN

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   DECLARE 
      @cFromIDLottable03         NVARCHAR( 18),
      @cToIDLottable03           NVARCHAR( 18),
      @cToLocationType           NVARCHAR( 10),
      @cToLocationPutawayZone    NVARCHAR( 10),
      @nRowCount                 INT

   IF @nFunc = 513 -- Move by SKU
   BEGIN
      IF @nStep = 5 -- TO ID
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT @cFromIDLottable03 = LA.Lottable03
            FROM dbo.LOTXLOCXID LLI WITH (NOLOCK)
            INNER JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK) ON LLI.Lot = LA.Lot
            WHERE LLI.ID = @cFromID
               AND LLI.StorerKey = @cStorerKey

            IF @cToID <> ''
            BEGIN
               SELECT @cToIDLottable03 = LA.Lottable03
               FROM dbo.LOTXLOCXID LLI WITH (NOLOCK)
               INNER JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK) ON LLI.Lot = LA.Lot
               WHERE LLI.ID = @cToID
                  AND LLI.StorerKey = @cStorerKey
                  AND LLI.Qty > 0

               SELECT @nRowCount = @@ROWCOUNT

               IF @nRowCount > 0
               BEGIN
                  IF ISNULL(@cFromIDLottable03, '') <> ISNULL(@cToIDLottable03, '')
                  BEGIN
                     SET @nErrNo = 242851
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lottable03 need to be the same
                     GOTO Quit
                  END
               END
            END
         END
      END

      IF @nStep = 6 -- TO LOC
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT @cFromIDLottable03 = LA.Lottable03
            FROM dbo.LOTXLOCXID LLI WITH (NOLOCK)
            INNER JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK) ON LLI.Lot = LA.Lot
            WHERE LLI.ID = @cFromID
               AND LLI.StorerKey = @cStorerKey

            IF ISNULL(@cFromIDLottable03, '') = ''
            BEGIN
               SELECT @cToLocationType = LocationType
               FROM dbo.LOC WITH (NOLOCK)
               WHERE LOC = @cToLOC
                  AND Facility = @cFacility

               IF @cToLocationType <> 'CASE'
               BEGIN
                  SET @nErrNo = 242852
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Location Type must be CASE
                  GOTO Quit
               END
            END
            ELSE
            BEGIN
               SELECT @cToLocationPutawayZone = PutawayZone
               FROM dbo.LOC WITH (NOLOCK)
               WHERE LOC = @cToLOC
                  AND Facility = @cFacility

               SELECT @nRowCount = COUNT(1)
               FROM dbo.CODELKUP WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND LISTNAME = 'LVSCTZONE'
                  AND ISNULL(Long, '') = @cFromIDLottable03
                  AND Code = @cToLocationPutawayZone

               IF @nRowCount = 0
               BEGIN
                  SET @nErrNo = 242853
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Location Putaway Zone is not in LVSCTZONE
                  GOTO Quit
               END
            END
         END
      END
   END

END

Quit:
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_513ExtVal13 TO NSQL
GO



