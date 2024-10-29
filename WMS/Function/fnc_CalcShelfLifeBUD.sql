SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Function       : fnc_CalcShelfLifeBUD                                */
/* Copyright      : Maersk Logistics                                    */
/*                                                                      */
/* Purpose: BUD has Finished Goods (FG). Need to calculate Shelf-Life.  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Rev  Author     Purposes                                */
/* 2024-09-02   1.0  SBA757     Created UWP-23707                       */
/************************************************************************/
CREATE OR ALTER FUNCTION [dbo].[fnc_CalcShelfLifeBUD]   
(
  @cStorerKey NVARCHAR(15),
  @cSKU       NVARCHAR(20),
  @dLottable04 DATETIME,
  @dLottable13 DATETIME
)  
RETURNS NVARCHAR(30)   
AS  
BEGIN  
   DECLARE @cShelfLife  NVARCHAR(30) = ''
   , @cFrozenFood       NVARCHAR(16) = 'FROZEN_FOOD'
   , @cCabinets         NVARCHAR(16) = 'CABINETS'
      
   IF @dLottable04 IS NOT NULL AND @dLottable13 IS NOT NULL
   BEGIN
      SELECT @cShelfLife = 
         CASE
            WHEN CAST(DATEDIFF(dd, GETDATE(), @dLottable04) AS FLOAT) >= CAST(0.6 * DATEDIFF(dd, @dLottable13, @dLottable04) AS FLOAT) THEN 'ML11'
            WHEN SKU.BUSR3 = @cFrozenFood
               AND DATEDIFF(dd, GETDATE(),@dLottable04) > 210
               AND CAST(DATEDIFF(dd, GETDATE(),@dLottable04) AS FLOAT) < CAST(0.6 * DATEDIFF(dd, @dLottable13, @dLottable04) AS FLOAT)
            THEN 'ML19'
            WHEN SKU.BUSR3 = @cCabinets
               AND DATEDIFF(dd, GETDATE(),@dLottable04) > 390
               AND (CAST(DATEDIFF(dd, GETDATE(),@dLottable04) AS FLOAT)) < CAST(0.6 * DATEDIFF(dd, @dLottable13, @dLottable04) AS FLOAT)
            THEN 'ML19'
            WHEN SKU.BUSR3 = @cFrozenFood
               AND DATEDIFF(dd, GETDATE(),@dLottable04) > 60
               AND DATEDIFF(dd, GETDATE(),@dLottable04) < 211
               AND CAST(DATEDIFF(dd,GETDATE(),@dLottable04) AS FLOAT) < CAST(0.6 * DATEDIFF(dd, @dLottable13, @dLottable04) AS FLOAT)
            THEN 'ML18'
            WHEN SKU.BUSR3 = @cCabinets
               AND DATEDIFF(dd, GETDATE(),@dLottable04) > 60
               AND DATEDIFF(dd, GETDATE(),@dLottable04) < 391
               AND CAST(DATEDIFF(dd, GETDATE(),@dLottable04) AS FLOAT) < CAST(0.6 * DATEDIFF(dd, @dLottable13, @dLottable04) AS FLOAT)
            THEN 'ML18'
            WHEN DATEDIFF(dd, GETDATE(),@dLottable04) < 61 THEN 'ML13'
            ELSE 'ML12'
         END
      FROM dbo.SKU SKU WITH (NOLOCK) 
      WHERE SKU.StorerKey = @cStorerKey
      AND SKU.Sku = @cSKU 
   END
   RETURN  @cShelfLife
END
GO
