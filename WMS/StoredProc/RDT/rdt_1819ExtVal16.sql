
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_1819ExtVal16                                    */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Date        Rev  Author   Purposes                                   */
/* 04-06-2024  1.0  NLT013   FCR-267. Created                           */
/*                           If any SKU.PrePackIndicator=Y, throw error */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1819ExtVal16] (
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
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nRowCount INT

   IF @nFunc = 1819 -- Putaway by ID
   BEGIN
      IF @nStep = 1 -- From ID
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT @nRowCount = COUNT(1)
            FROM dbo.UCC ucc WITH(NOLOCK)
            INNER JOIN dbo.SKU sku WITH(NOLOCK)
               ON ucc.StorerKey = sku.StorerKey
               AND ucc.Sku = sku.Sku
            WHERE Id = @cFromID
               AND ISNULL(sku.PrePackIndicator, '') = 'Y'

            IF @nRowCount > 0
            BEGIN
               SET @nErrNo = 216001
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- NoPutawayStrategy
               GOTO Quit
            END
         END
      END
   END

Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_1819ExtVal16] TO [NSQL]
GO
