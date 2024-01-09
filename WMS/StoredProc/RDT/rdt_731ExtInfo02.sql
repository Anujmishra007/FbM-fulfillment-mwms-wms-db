

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: rdt_731ExtInfo02                                          */
/* Copyright      : LF Logistics                                              */
/*                                                                            */
/* Purpose: Display ID                                                        */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 2023-12-26   yeekung    1.0   WMS24483. Created                              */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_731ExtInfo02]
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nAfterStep     INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cCCKey         NVARCHAR( 10),
   @cCCSheetNo     NVARCHAR( 10),
   @cCountNo       NVARCHAR( 1),
   @cLOC           NVARCHAR( 10),
   @cSKU           NVARCHAR( 20),
   @nQty           INT,
   @cOption        NVARCHAR( 1),
   @tVar           VariableTable READONLY,
   @cExtendedInfo  NVARCHAR( 20) OUTPUT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   
   DECLARE @cItemClass      NVARCHAR( 20)
   DECLARE @cBUSR4          NVARCHAR( 20)
   DECLARE @cData           NVARCHAR( 20)


   IF @nFunc = 731 -- Simple CC
   BEGIN
      IF @nStep IN ( 4, 9, 10) -- ID
      BEGIN
         IF @nInputKey = 1
         BEGIN
            SELECT @cData = userdefine01 +data 
            FROM SKUConfig (NOLOCK)
            WHERE SKU = @cSKU
               AND Storerkey = @cStorerKey

            SELECT @cItemClass = itemclass,
                   @cBUSR4 = BUSR4
            FROM SKU (NOLOCK)
            WHERE SKU = @cSKU
               AND Storerkey = @cStorerKey
            
            SET @cExtendedInfo = LEFT(@cItemClass,4) +' ' + LEFT(@cData,6) +' '+LEFT(@cBUSR4,7)
         END
      END
   END

   Quit:
END
GO
GRANT EXECUTE ON  [RDT].[rdt_731ExtInfo02] TO [NSQL]
GO
