
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_523ExtValidSP15                                 */
/*                                                                      */
/* Purpose: Validate pallet id before putaway                           */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author    Purposes                                   */
/* 2025-03-11 1.0  yeekung   FCR-3456. Created                          */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_523ExtValidSP15] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cStorerKey      NVARCHAR( 15),
   @cFacility       NVARCHAR( 5),
   @cFromLOC        NVARCHAR( 10),
   @cFromID         NVARCHAR( 18),
   @cSKU            NVARCHAR( 20),
   @nQty            INT,
   @cSuggestedLOC   NVARCHAR( 10),
   @cFinalLOC       NVARCHAR( 10),
   @cOption         NVARCHAR( 1),
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @cPutawayzone NVARCHAR(20)

   IF @nInputKey = 1 
   BEGIN
      IF @nStep = 4
      BEGIN
         SELECT @cPutawayzone = Putawayzone 
         FROM SKU (NOLOCK)
         WHERE SKU = @cSKU 
            AND Storerkey = @cStorerKey

         IF @cFinalLOC  <> @cSuggestedLOC 
         BEGIN
            IF  EXISTS (   SELECT 1
                           FROM loc (Nolock)
                           WHERE LOC.Loc = @cFinalLOC
                              AND Facility = @cFacility
                              AND Putawayzone <> @cPutawayzone)
            BEGIN
               SET @nErrNo = 237801
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ZoneNotMatch
               GOTO Quit
            END
         END

      END
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_523ExtValidSP15 TO NSQL
GO