
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_521ExtInfo05                                    */
/* Purpose: Display custom info                                         */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2023-07-07   yeekung   1.0   WMS-22985 Created                       */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_521ExtInfo05
   @nMobile         INT,       
   @nFunc           INT,       
   @cLangCode       NVARCHAR( 3),  
   @nStep           INT,       
   @nInputKey       INT,       
   @cStorerKey      NVARCHAR( 15), 
   @cUCCNo          NVARCHAR( 20), 
   @cSuggestedLOC   NVARCHAR( 10), 
   @cToLOC          NVARCHAR( 10), 
   @cExtendedInfo1  NVARCHAR( 20) OUTPUT, 
   @nErrNo          INT OUTPUT,    
   @cErrMsg         NVARCHAR( 20) OUTPUT 
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cFacility   NVARCHAR( 5)
   
   SELECT @cFacility = Facility
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
   
   IF @nInputKey = 1
   BEGIN
      IF @nStep = 1
      BEGIN
         SELECT TOP 1 @cExtendedInfo1 ='ABC:' + SKU.ABC
         FROM dbo.UCC UCC WITH (NOLOCK) 
            JOIN SKU SKU (NOLOCK) ON UCC.SKU = SKU.SKU AND UCC.Storerkey = SKU.StorerKey
         WHERE UCCNO = @cUCCNo
            AND SKU.storerkey = @cStorerKey
      END
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_521ExtInfo05 TO NSQL
GO
