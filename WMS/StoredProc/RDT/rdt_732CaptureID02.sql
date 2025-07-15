SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: rdt_732CaptureID02                                        */
/* Copyright      : MAERSK                                                    */
/*                                                                            */
/* Purpose: Determine whether need go to id screen based on loc.locationtype  */
/*                                                                            */
/* Date        Author     Ver.  Purposes                                      */
/* 2025-03-07  James      1.0   FCR-2054 Created                              */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_732CaptureID02]
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
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
   @cCaptureID     NVARCHAR( 1)  OUTPUT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 732 -- Simple CC
   BEGIN
      IF EXISTS ( SELECT 1 
                  FROM dbo.CCDetail CCD WITH (NOLOCK) 
                  JOIN dbo.LOC LOC WITH (NOLOCK) ON ( CCD.Loc = LOC.Loc)
                  WHERE CCD.CCKey = @cCCKey    
                  AND   CCD.CCSheetNo = CASE WHEN ISNULL( @cCCSheetNo, '') = '' THEN CCD.CCSheetNo ELSE @cCCSheetNo END
                  AND   CCD.Storerkey = @cStorerKey
                  AND   CCD.Loc = @cLOC
                  AND   CCD.FinalizeFlag = 'N'
                  AND   LOC.LocationType = 'OTHER')     
      BEGIN
         IF EXISTS ( SELECT 1 
                     FROM dbo.CCDetail CCD WITH (NOLOCK) 
                     JOIN dbo.LOC LOC WITH (NOLOCK) ON ( CCD.Loc = LOC.Loc)
                     JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK) ON ( CCD.Lot = LA.Lot)
                     WHERE CCD.CCKey = @cCCKey    
                     AND   CCD.CCSheetNo = CASE WHEN ISNULL( @cCCSheetNo, '') = '' THEN CCD.CCSheetNo ELSE @cCCSheetNo END
                     AND   CCD.Storerkey = @cStorerKey
                     AND   CCD.Loc = @cLOC
                     AND   CCD.FinalizeFlag = 'N'
                     AND   LOC.LocationType = 'OTHER'
                     AND   LA.Lottable06 = 'AV')     
            SET @cCaptureID = '2'   -- step cckey, loc, id (loop id screen)
         ELSE
            SET @cCaptureID = '3'   -- step cckey, loc, id, sku (loop sku screen)
      END
      ELSE
         SET @cCaptureID = '0'
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  [RDT].[rdt_732CaptureID02] TO [NSQL]
GO
