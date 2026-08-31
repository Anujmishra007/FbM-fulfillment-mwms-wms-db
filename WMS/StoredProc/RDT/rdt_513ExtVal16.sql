SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_513ExtVal16                                          */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: VIVOBAREFOOT DE - Prevent moving SKU into a pick location         */
/*          where a different SKU is assigned in SKUxLOC                      */
/*                                                                            */
/* Date        Rev  Author   Purposes                                         */
/* 17-08-2026  1.0  Sreeja   FCR-15090 Created                                */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_513ExtVal16]
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
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @nErrNo = 0
   SET @cErrMsg = ''

   IF @nFunc = 513 -- Move by SKU
   BEGIN
      IF @nStep = 6 -- ToLOC
      BEGIN
         IF @nInputKey = 1 -- Enter
         BEGIN
            -- Block move if ToLOC has a SKUxLOC assignment for a different SKU
            IF EXISTS (SELECT 1 FROM dbo.SKUxLOC WITH(NOLOCK) WHERE Loc = @cToLOC AND StorerKey = @cStorerKey)
            BEGIN
               IF NOT EXISTS (SELECT 1 FROM dbo.SKUxLOC WITH(NOLOCK) WHERE Loc = @cToLOC AND StorerKey = @cStorerKey AND Sku = @cSKU)
               BEGIN
                  SET @nErrNo = 278551
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Wrong SKUxLOC match
                  GOTO Quit
               END
            END
         END --inputkey=1
      END --step6
   END --fnc 513

   Quit:
END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_513ExtVal16] TO NSQL
GO