
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_523ExtInfo07                                    */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2022-09-01 1.0  yeekung   WMS-20683. Created                         */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_523ExtInfo07]
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nAfterStep      INT,
   @nInputKey       INT,
   @cStorerKey      NVARCHAR( 15),
   @cFacility       NVARCHAR( 5),
   @cLOC            NVARCHAR( 10),
   @cID             NVARCHAR( 18),
   @cSKU            NVARCHAR( 20),
   @nQTY            INT,
   @cSuggestedLOC   NVARCHAR( 10),
   @cFinalLOC       NVARCHAR( 10),
   @cOption         NVARCHAR( 1),
   @cExtendedInfo1  NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cUserdefine01 NVARCHAR(20)
   DECLARE @cData NVARCHAR(20)

   IF @nFunc = 523 -- Putaway by SKU
   BEGIN
      IF @nAfterStep = 3  -- QTY PWY, QTY ACT
      BEGIN
         SELECT @cUserdefine01=userdefine01,
                @cData = data
         FROM SKUconfig (NOLOCK)
         WHERE SKU=@cSKU
            AND  storerkey=@cStorerKey

         SET @cExtendedInfo1 = @cUserdefine01 + ' '+  @cData
      END
   END

Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_523ExtInfo07] TO [NSQL]
GO
