SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/**************************************************************************/
/* Store procedure: rdt_513ExtVal14                                       */
/* Copyright: Maersk                                                      */
/* Customer : PAGE                                                        */
/*                                                                        */
/* Purpose: Product Division validation for GOO items                     */
/*          Check LOC.SectionKey = SKU.BUSR2 when Lottable02 = 'GOO'     */
/*                                                                        */
/* Date       Rev    Author     Purposes                                  */
/* 2026-06-02 1.0.0  Dennis     Created                                   */
/**************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_513ExtVal14] (
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
      @cSKU_BUSR2          NVARCHAR(30),
      @cToLOC_SectionKey   NVARCHAR(10)

   IF @nFunc = 513 -- Move by SKU
   BEGIN
      IF @nStep = 6 -- TO LOC
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Check if any lot has Lottable02 = 'GOO' (one LOC+ID+SKU may have multiple lots)
            IF EXISTS (
               SELECT 1
               FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
               INNER JOIN dbo.LOC L WITH (NOLOCK)
                  ON LLI.LOC = L.LOC AND L.Facility = @cFacility
               INNER JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK)
                  ON LLI.Lot = LA.Lot AND LLI.StorerKey = LA.StorerKey AND LLI.SKU = LA.SKU
               WHERE LLI.StorerKey = @cStorerKey
                 AND LLI.LOC = @cFromLOC
                 AND LLI.ID = @cFromID
                 AND LLI.SKU = @cSKU
                 AND ISNULL(LA.Lottable02, '') = 'GOO'
            )
            BEGIN
               -- Get SKU.BUSR2 (Product Division)
               SELECT @cSKU_BUSR2 = RTRIM(ISNULL(BUSR2, ''))
               FROM dbo.SKU WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                 AND SKU = @cSKU

               -- Check if SKU.BUSR2 is maintained
               IF ISNULL(@cSKU_BUSR2, '') = ''
               BEGIN
                  SET @nErrNo = 268351
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- SKU ProdDiv Empty
                  GOTO Quit
               END

               -- Get ToLOC SectionKey
               SELECT @cToLOC_SectionKey = RTRIM(ISNULL(SectionKey, ''))
               FROM dbo.LOC WITH (NOLOCK)
               WHERE LOC = @cToLOC
                 AND Facility = @cFacility

               -- Validate Product Division match
               IF @cToLOC_SectionKey <> @cSKU_BUSR2
               BEGIN
                  SET @nErrNo = 268352
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- ProdDiv Mismatch
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

GRANT EXECUTE ON RDT.rdt_513ExtVal14 TO NSQL
GO
