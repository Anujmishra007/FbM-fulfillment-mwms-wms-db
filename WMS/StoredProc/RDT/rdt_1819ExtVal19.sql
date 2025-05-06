SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_1819ExtVal19                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Check ID go to different SKU zone                           */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2025-02-12   Ung       1.0   FCR-3457 Created                        */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1819ExtVal19]
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
            DECLARE @cStorerKey NVARCHAR( 15)
            DECLARE @cFacility  NVARCHAR( 5)
            SELECT 
               @cStorerKey = StorerKey, 
               @cFacility = Facility
            FROM rdt.rdtMobRec WITH (NOLOCK)
            WHERE Mobile = @nMobile
   
            -- Get ID info
            DECLARE @cSKU NVARCHAR( 20)
            SELECT TOP 1
               @cSKU = LLI.SKU
            FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LLI.LOC = LOC.LOC)
            WHERE LOC.Facility = @cFacility
               AND LLI.ID = @cFromID
               AND LLI.QTY - LLI.QTYAllocated - LLI.QTYPicked > 0
               
            -- SKU info
            DECLARE @cSKUPutawayZone NVARCHAR( 10)
            SELECT @cSKUPutawayZone = ISNULL( PutawayZone, '') FROM dbo.SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU
            
            -- SKU zone is setup
            IF @cSKUPutawayZone <> ''
            BEGIN
               -- Get LOC info
               DECLARE @cToLOCPutawayZone NVARCHAR( 10)
               SELECT @cToLOCPutawayZone = PutawayZone FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cToLOC
            
               -- Check pallet go into different zone
               IF @cSKUPutawayZone <> @cToLOCPutawayZone
               BEGIN
                  SET @nErrNo = 233001
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff SKU zone
                  GOTO Quit
               END
            END
         END
      END
   END

Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_1819ExtVal19] TO [NSQL]
GO
