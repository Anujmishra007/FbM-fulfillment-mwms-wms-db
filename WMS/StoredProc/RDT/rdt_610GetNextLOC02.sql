IF EXISTS ( SELECT * FROM sys.sysobjects WHERE  id = OBJECT_ID(N'[RDT].[rdt_610GetNextLOC02]') AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 )
   DROP PROCEDURE [RDT].[rdt_610GetNextLOC02]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: rdt_610GetNextLOC02                                          */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose: Get next location. If @nCCCountNo>1 then only pick discrepancy       */
/*                                                                               */
/* Called from: rdt_CycleCount_GetNextLOC                                        */
/*                                                                               */
/* Modifications log:                                                            */
/*                                                                               */
/* Date        Rev  Author   Purposes                                            */
/* 02-Nov-2025 1.0  Cuize    FCR-8016 Created                                    */
/*********************************************************************************/
    
CREATE PROC [RDT].[rdt_610GetNextLOC02] (
   @nMobile               INT,           
   @nFunc                 INT,           
   @cLangCode             NVARCHAR( 3),  
   @nStep                 INT,           
   @nInputKey             INT,           
   @cFacility             NVARCHAR( 5),  
   @cCCRefNo              NVARCHAR( 10), 
   @cCCSheetNo            NVARCHAR( 10), 
   @cSheetNoFlag          NVARCHAR( 1),  
   @nCCCountNo            INT,           
   @cZone1                NVARCHAR( 10), 
   @cZone2                NVARCHAR( 10), 
   @cZone3                NVARCHAR( 10), 
   @cZone4                NVARCHAR( 10), 
   @cZone5                NVARCHAR( 10), 
   @cAisle                NVARCHAR( 10), 
   @cLevel                NVARCHAR( 10), 
   @cCurrSuggestLogiLOC   NVARCHAR( 10), 
   @cCurrSuggestLOC       NVARCHAR( 10), 
   @cSuggestLogiLOC       NVARCHAR( 10) OUTPUT, 
   @cSuggestLOC           NVARCHAR( 10) OUTPUT 
)    
AS  
BEGIN    
   SET NOCOUNT ON    
   SET ANSI_NULLS OFF    
   SET ANSI_DEFAULTS OFF    
   SET QUOTED_IDENTIFIER OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    

   DECLARE @cUserName      NVARCHAR( 18)
   --DELETE FROM TRACEINFO WHERE TRACENAME = '610'
   --INSERT INTO TRACEINFO (TRACENAME, TIMEIN, COL1, COL2, COL3, COL4, COL5, STEP1, STEP2) VALUES 
   --('610', GETDATE(), @cSheetNoFlag, @cZone1, @cAisle, @cLevel, @cCurrSuggestLogiLOC, @cSuggestLogiLOC, @cSuggestLOC)

   SET @cSuggestLogiLOC = ''
   SET @cSuggestLOC = ''

   SELECT @cUserName = UserName
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE MOBILE = @nMobile


   DECLARE @CCDetail TABLE
   (
      RowID             INT IDENTITY(1,1) PRIMARY KEY,
      [CCDetailKey]     NVARCHAR(10) NOT NULL,

      [SystemQty]       INT NOT NULL,
      [Qty]             INT NOT NULL,
      [Qty_Cnt2]        INT NULL,
      [Qty_Cnt3]        INT NULL,
      [SuggestLogiLOC]  NVARCHAR(10) NULL,
      [SuggestLOC]      NVARCHAR(10) NULL,
      [updatedFlag]     BIT NOT NULL DEFAULT 0
   );

   INSERT INTO @CCDetail (CCDetailKey, SystemQty, Qty, Qty_Cnt2, Qty_Cnt3, SuggestLogiLOC, SuggestLOC)
   SELECT CCD.CCDetailKey,
          CCD.SystemQty,
          CCD.Qty,
          CCD.Qty_Cnt2,
          CCD.Qty_Cnt3,
          LOC.CCLogicalLOC,
          LOC.LOC
   FROM dbo.CCDetail CCD (NOLOCK)
      INNER JOIN dbo.LOC LOC (NOLOCK) ON (CCD.LOC = LOC.LOC)
   WHERE CCD.CCKey = @cCCRefNo
      AND LOC.Facility = @cFacility
      AND (@cSheetNoFlag <> 'Y' OR CCD.CCSheetNo = @cCCSheetNo )
      AND (
        (@cSheetNoFlag = 'Y' AND LOC.CCLogicalLOC >  @cCurrSuggestLogiLOC)
      OR
        (@cSheetNoFlag <> 'Y' AND LOC.CCLogicalLOC >= @cCurrSuggestLogiLOC)
      )
      AND (  @cSheetNoFlag = 'Y' OR @cZone1 = 'ALL'
         OR LOC.PutawayZone IN (@cZone1, @cZone2, @cZone3, @cZone4, @cZone5)
      )

      AND LOC.LocAisle =
      CASE WHEN ISNULL(@cAisle,'') = '' OR RTRIM(@cAisle) = 'ALL' THEN LOC.LocAisle
      ELSE @cAisle END

      AND LOC.LocLevel = CASE WHEN ISNULL(@cLevel,'') = '' OR RTRIM(@cLevel) = 'ALL' THEN LOC.LocLevel
      ELSE @cLevel  END

      AND 1 = CASE
         WHEN @nCCCountNo = 1 AND Counted_Cnt1 = 1 THEN 0
         WHEN @nCCCountNo = 2 AND Counted_Cnt2 = 1 THEN 0
         WHEN @nCCCountNo = 3 AND Counted_Cnt3 = 1 THEN 0
         ELSE 1
      END

      AND NOT EXISTS (
         SELECT 1
         FROM RDT.RDTCCLock CCL WITH (NOLOCK)
         WHERE CCD.CCKey = CCL.CCKEY
            AND CCD.CCSheetNo = CASE
                                  WHEN ISNULL(CCL.SheetNo , '') = '' THEN CCD.CCSheetNo
                                  ELSE CCL.SheetNo
            END
              AND CCD.LOC = CCL.LOC
              AND CCL.ADDWHO <> @cUserName
              AND CCL.Status = '0'
      )

      ORDER BY
      LOC.CCLogicalLOC,
      CASE WHEN @cSheetNoFlag = 'Y' THEN NULL ELSE LOC.LocAisle END,
      CASE WHEN @cSheetNoFlag = 'Y' THEN NULL ELSE LOC.LocLevel END,
      LOC.LOC


   IF @nCCCountNo = 2
   BEGIN
      UPDATE @CCDetail SET updatedFlag = 1 WHERE Qty = SystemQty

      UPDATE CCD SET
         CCD.Qty_Cnt2 = CCD.SystemQty,
         CCD.Lottable01_Cnt2 = CCD.Lottable01,
         CCD.Lottable02_Cnt2 = CCD.Lottable02,
         CCD.Lottable03_Cnt2 = CCD.Lottable03,
         CCD.Lottable04_Cnt2 = CCD.Lottable04,
         CCD.Lottable05_Cnt2 = CCD.Lottable05
      FROM dbo.CCDetail CCD
         INNER JOIN @CCDetail C ON CCD.CCDetailKey = C.CCDetailKey
      WHERE C.Qty = C.SystemQty
   END

   ELSE IF @nCCCountNo = 3
   BEGIN
      UPDATE @CCDetail
      SET updatedFlag = 1
      WHERE Qty_Cnt2 = SystemQty

      UPDATE CCD SET
         CCD.Qty_Cnt3 = CCD.SystemQty,
         CCD.Lottable01_Cnt3 = CCD.Lottable01,
         CCD.Lottable02_Cnt3 = CCD.Lottable02,
         CCD.Lottable03_Cnt3 = CCD.Lottable03,
         CCD.Lottable04_Cnt3 = CCD.Lottable04,
         CCD.Lottable05_Cnt3 = CCD.Lottable05
      FROM dbo.CCDetail CCD
              INNER JOIN @CCDetail C ON CCD.CCDetailKey = C.CCDetailKey
      WHERE C.Qty_Cnt2 = C.SystemQty
   END

   SELECT TOP 1 @cSuggestLogiLOC = SuggestLogiLOC,
          @cSuggestLOC = SuggestLOC
   FROM @CCDetail
   WHERE updatedFlag = 0
   ORDER BY RowID


   IF @@ROWCOUNT = 0
      SET @cSuggestLOC = ''

   Quit:
END  
GO
GRANT EXECUTE ON [RDT].[rdt_610GetNextLOC02] TO nSQL
GO
