SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1841ExtInfo03                                   */
/*                                                                      */
/* Purpose: Display SKU.ABC                                             */
/*                                                                      */
/* Called from: rdt_fncPrePalletizeSort                                 */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 2023-07-18  1.0  James      WMS-22995. Created                       */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1841ExtInfo03] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nAfterStep     INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5), 
   @cStorerKey     NVARCHAR( 15),
   @cReceiptKey    NVARCHAR( 10),
   @cLane          NVARCHAR( 10),
   @cUCC           NVARCHAR( 20),
   @cToID          NVARCHAR( 18),
   @cSKU           NVARCHAR( 20),
   @nQty           INT,
   @cOption        NVARCHAR( 1),               
   @cPosition      NVARCHAR( 20),
   @tExtInfoVar    VariableTable READONLY, 
   @cExtendedInfo        NVARCHAR( 20) OUTPUT

)
AS

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cABC     NVARCHAR( 5) = ''
   DECLARE @cFloor   NVARCHAR( 3) = ''
   
   IF @nStep = 7
   BEGIN
      IF @nInputKey = 1
      BEGIN
         SELECT @cABC = ABC
         FROM dbo.SKU WITH (NOLOCK)
         WHERE Storerkey = @cStorerKey
         AND   SKU = @cSKU

         SELECT TOP 1 @cFloor = LOC.Floor
         FROM LOTxLOCxID LLI WITH (NOLOCK)
         JOIN LOC LOC WITH (NOLOCK) ON ( LLI.Loc = LOC.Loc)
         WHERE LLI.StorerKey = @cStorerKey
         AND   LLI.SKU = @cSKU
         AND ( LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked) > 0 
         AND   LOC.LocationFlag <> 'HOLD' 
         AND   LOC.Facility = @cFacility
         ORDER BY 1

         IF @cABC <> ''
            SET @cExtendedInfo = 'ABC|FLOOR: ' + RTRIM( @cABC) + ' | ' + @cFloor
      END
   END

   Quit:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1841ExtInfo03 TO NSQL
GO