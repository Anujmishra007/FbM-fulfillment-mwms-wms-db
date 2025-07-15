SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: rdt_732ExtInfo04                                          */
/* Copyright      : MAERSK                                                    */
/*                                                                            */
/* Purpose: Show how many ID scanned by this user                             */
/*                                                                            */
/* Date        Author     Ver.  Purposes                                      */
/* 2025-03-07  James      1.0   FCR-2054 Created                              */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_732ExtInfo04]
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

   DECLARE @nScan  INT = 0
   DECLARE @nTotal INT = 0
   DECLARE @cMsg   NVARCHAR( 20)

   IF @nFunc = 732 -- Simple CC
   BEGIN
      IF @nStep = 9 OR @nAfterStep = 9 -- ID
      BEGIN
         SELECT 
             @nTotal = COUNT(DISTINCT ID),
             @nScan = COUNT(DISTINCT CASE 
                      WHEN @cCountNo = 1 AND Counted_Cnt1 = 1 THEN CAST(ID AS NVARCHAR(18))
                      WHEN @cCountNo = 2 AND Counted_Cnt2 = 1 THEN CAST(ID AS NVARCHAR(18))
                      WHEN @cCountNo = 3 AND Counted_Cnt3 = 1 THEN CAST(ID AS NVARCHAR(18))
                      ELSE NULL END)
         FROM dbo.CCDetail WITH (NOLOCK)
         WHERE Storerkey = @cStorerkey
         AND   CCKey = @cCCKey
         AND   CCSheetNo = CASE WHEN @cCCSheetNo <> '' THEN @cCCSheetNo ELSE CCSheetNo END
         AND   Loc = @cLoc
         
         SET @cExtendedInfo = 'SCAN/TOTAL: ' + 
            CAST( @nScan AS NVARCHAR(4)) + '/' +
            CAST( @nTotal AS NVARCHAR(4))
      END
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON  [RDT].[rdt_732ExtInfo04] TO [NSQL]
GO
