SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_521ExtValid10                                   */
/* Purpose: Validate  SKU Floor                                         */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2025-11-06  1.0  yeekung  FCR-7296. Created                          */  
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_521ExtValid10] (
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

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE   @cPutawayZone    NVARCHAR( 20)
   DECLARE   @cFloor          NVARCHAR( 20)
   DECLARE   @cSKU            NVARCHAR( 20)
   DECLARE   @cSKUGroup       NVARCHAR( 20)
   DECLARE   @cFacility		  NVARCHAR( 5)

   SELECT @cFacility = Facility 
   FROM rdt.rdtMOBREC WITH (NOLOCK) 
   WHERE Mobile = @nMobile

   IF @nStep = 2 -- UCC
   BEGIN
      IF @nInputKey = 1
      BEGIN
         IF @cSuggestedLOC <> @cToLOC
         BEGIN
            
            
            SELECT TOP 1 @cSKU = SKU 
            FROM UCC (NOLOCK) 
            WHERE UCCNO = @cUCCNo
               AND StorerKey = @cStorerKey

            -- Get the Floor of the sku
            SELECT TOP 1
               @cSKUGroup = SKUGroup  --(yeekung01)
            FROM dbo.SKU sku WITH(NOLOCK)
            WHERE sku.SKU = @cSKU
               AND StorerKey = @cStorerKey;

            --Get The Floor
            SELECT @cFloor = Long
            FROM CODELKUP (NOLOCK)
            WHERE LISTNAME =  'SKUGRP_FLR'
               AND StorerKey = @cStorerKey 
               AND Code = @cSKUGroup

            IF EXISTS ( SELECT 1 FROM dbo.LOC WITH (NOlOCK)
                        WHERE LOC = @cToLOC
                           AND Facility = @cFacility
                           AND Floor <> @cFloor)
            BEGIN
               SET @nErrNo = 250851
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- LOCNotSameFloor
               GOTO Quit
            END

            IF EXISTS ( SELECT 1 FROM dbo.LotxLocxID LLI (NOLOCK)
                           JOIN dbo.LOC LOC WITH (NOlOCK) ON LLI.LOC = LOC.LOC
                        WHERE LLI.LOC = @cToLOC
                           AND LOC.Facility = @cFacility
                           AND LLI.StorerKey = @cStorerkey
                        HAVING SUM(ISNULL(LLI.QTY,'0')-ISNULL(LLI.QTYAllocated,'0')-ISNULL(LLI.qtypicked,'0')) > 0 )
            BEGIN
               SET @nErrNo = 250852
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ToLocHadQty
               GOTO Quit
            END
         END

      END
   END

QUIT:
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON  [RDT].[rdt_521ExtValid10] TO [NSQL]
GO
