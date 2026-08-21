SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Function       : fnc_CalcShelfLifeBUL                                */
/* Copyright      : Maersk Logistics                                    */
/*                                                                      */
/* Purpose: BUL has Finished Goods (FG) and Raw Material and Packaging  */
/*          Material (RMP). Need to calculate for 5 Shelf-Life rules.   */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Rev  Author     Purposes                                */
/* 2012-04-13   1.0  Shong      Created UWP-22021						*/
/*2025-08-28    2.0  VBH079		UPDATED									*/
/* 2026-08-24   3.0  VNI01   FCR-14631:remove hardcoded shelf-life codes*/
/************************************************************************/
CREATE OR ALTER FUNCTION [dbo].[fnc_CalcShelfLifeBUL]   
(  
  @cStorerKey NVARCHAR(15),
  @cSKU       NVARCHAR(20),
  @dLottable04 DATETIME,
  @dLottable07 NVARCHAR(10)
)
RETURNS NVARCHAR(30)
AS
BEGIN
   DECLARE @cShelfLife  NVARCHAR(30)
   --VBH079 START
   DECLARE @ML1 NVARCHAR(5)
   DECLARE @ML2 NVARCHAR(5)
   DECLARE @ML3 NVARCHAR(5)
   DECLARE @ML4 NVARCHAR(5)
   DECLARE @ML5 NVARCHAR(5)
   DECLARE @Code NVARCHAR(5)  --VNI01
   --VBH079 END
   --VNI01(START)
    SELECT @Code= Max(code2) FROM CODELKUP WITH (NOLOCK)
    WHERE LISTNAME = 'SLCODE'
      AND Storerkey=@cStorerKey and code2=SUBSTRING(isnull(@dLottable07,''), 1, 2)

    /*
       IF @cStorerKey = 'SABULKSA'
       BEGIN
       SET @ML1 = 'ML11'
       SET @ML2 = 'ML18'
       SET @ML3 = 'ML13'
       SET @ML4 = 'ML50'
       SET @ML5 = 'ML51'
       END

       IF @cStorerKey = 'SABULFG'
       BEGIN
       SET @ML1 = 'ML47'
       SET @ML2 = 'ML48'
       SET @ML3 = 'ML49'
       SET @ML4 = 'ML50'
       SET @ML5 = 'ML51'
       END

       IF @cStorerKey = 'SABULRPM'
       BEGIN
       SET @ML1 = 'ML47'
       SET @ML2 = 'ML48'
       SET @ML3 = 'ML49'
       SET @ML4 = 'ML50'
       SET @ML5 = 'ML51'
       END

       */
    IF ISNULL(@Code, '') <> ''
    BEGIN
        SELECT TOP (1) @ML1 = Code FROM dbo.CODELKUP WITH (NOLOCK) WHERE LISTNAME = 'SLCode' AND short='FGAV' AND StorerKey = @cStorerKey AND code2=@code   --VNI01
        SELECT TOP (1) @ML2 = Code FROM dbo.CODELKUP WITH (NOLOCK) WHERE LISTNAME = 'SLCode' AND short='FGNE' AND StorerKey = @cStorerKey AND code2=@code    --VNI01
        SELECT TOP (1) @ML3 = Code FROM dbo.CODELKUP WITH (NOLOCK) WHERE LISTNAME = 'SLCode' AND short='FGEX' AND StorerKey = @cStorerKey  AND code2=@code    --VNI01
        SELECT TOP (1) @ML4 = Code FROM dbo.CODELKUP WITH (NOLOCK) WHERE LISTNAME = 'SLCode' AND short='RPAV' AND StorerKey = @cStorerKey AND code2=@code    --VNI01
        SELECT TOP (1) @ML5 = Code FROM dbo.CODELKUP WITH (NOLOCK) WHERE LISTNAME = 'SLCode' AND short='RPEX' AND StorerKey = @cStorerKey AND code2=@code    --VNI01
    END
    ELSE
    BEGIN
        SELECT TOP (1) @ML1 = Code FROM dbo.CODELKUP WITH (NOLOCK) WHERE LISTNAME = 'SLCode' AND short='FGAV' AND StorerKey = @cStorerKey AND code2='ML'   --VNI01
        SELECT TOP (1) @ML2 = Code FROM dbo.CODELKUP WITH (NOLOCK) WHERE LISTNAME = 'SLCode' AND short='FGNE' AND StorerKey = @cStorerKey AND code2='ML'    --VNI01
        SELECT TOP (1) @ML3 = Code FROM dbo.CODELKUP WITH (NOLOCK) WHERE LISTNAME = 'SLCode' AND short='FGEX' AND StorerKey = @cStorerKey  AND code2='ML'    --VNI01
        SELECT TOP (1) @ML4 = Code FROM dbo.CODELKUP WITH (NOLOCK) WHERE LISTNAME = 'SLCode' AND short='RPAV' AND StorerKey = @cStorerKey AND code2='ML'    --VNI01
        SELECT TOP (1) @ML5 = Code FROM dbo.CODELKUP WITH (NOLOCK) WHERE LISTNAME = 'SLCode' AND short='RPEX' AND StorerKey = @cStorerKey AND code2='ML'   --VNI01
    END
   --VNI01(END)
    IF @cStorerKey = 'SABULKSA'
    BEGIN
        SELECT @cShelfLife =
               CASE
                   WHEN SKU.SKUGROUP = 'FG' AND DATEDIFF (dd, GETDATE(),@dLottable04) > 210 THEN @ML1
                   WHEN SKU.SKUGROUP = 'FG' AND DATEDIFF (dd, GETDATE(),@dLottable04)  <= 210 AND DATEDIFF (dd, GETDATE(), @dLottable04) > 0 THEN @ML3
                   --WHEN SKU.SKUGROUP = 'FG' AND DATEDIFF(dd, GETDATE(),@dLottable04)  <= 0 THEN @ML3
                   --WHEN SKU.SKUGROUP IN ('RM', 'PC') AND DATEDIFF(dd, GETDATE(),@dLottable04) > 0 THEN @ML4
                   --WHEN SKU.SKUGROUP IN ('RM', 'PC') AND DATEDIFF(dd, GETDATE(),@dLottable04) <= 0 THEN @ML5
                   ELSE ''
               END
        FROM dbo.SKU SKU WITH (NOLOCK)
        WHERE SKU.StorerKey = @cStorerKey
          AND SKU.Sku = @cSKU
    END
    ELSE
    BEGIN
        SELECT @cShelfLife =
               CASE
                   WHEN SKU.SKUGROUP = 'FG' AND DATEDIFF (dd, GETDATE(),@dLottable04) > 180 THEN @ML1
                   WHEN SKU.SKUGROUP = 'FG' AND DATEDIFF (dd, GETDATE(),@dLottable04)  <= 180 AND DATEDIFF (dd, GETDATE(), @dLottable04) > 0 THEN @ML2
                   WHEN SKU.SKUGROUP = 'FG' AND DATEDIFF(dd, GETDATE(),@dLottable04)  <= 0 THEN @ML3
                   WHEN SKU.SKUGROUP IN ('RM', 'PC') AND DATEDIFF(dd, GETDATE(),@dLottable04) > 0 THEN @ML4
                   WHEN SKU.SKUGROUP IN ('RM', 'PC') AND DATEDIFF(dd, GETDATE(),@dLottable04) <= 0 THEN @ML5
                   ELSE ''
                   END
        FROM dbo.SKU SKU WITH (NOLOCK)
        WHERE SKU.StorerKey = @cStorerKey
          AND SKU.Sku = @cSKU
    END

   RETURN  @cShelfLife
END
GO