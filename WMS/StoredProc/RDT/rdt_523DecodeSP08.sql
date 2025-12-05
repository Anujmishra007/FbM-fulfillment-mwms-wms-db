
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************/
/* Store procedure: rdt_523DecodeSP08                                         */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Purpose: Decode For BAT case                                               */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2025-10-27  Deenis    1.0   FCR-8674 Created                               */
/******************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_523DecodeSP08] (
   @nMobile           INT,           
   @nFunc             INT,           
   @cLangCode         NVARCHAR( 3),  
   @nStep             INT,           
   @nInputKey         INT,           
   @cFacility         NVARCHAR( 5),  
   @cStorerKey        NVARCHAR( 15), 
   @cBarcode          NVARCHAR( 60), 
   @cBarcodeUCC       NVARCHAR( 200), 
   @cID               NVARCHAR( 18)  OUTPUT, 
   @cUCC              NVARCHAR( 20)  OUTPUT, 
   @cLOC              NVARCHAR( 10)  OUTPUT, 
   @cSKU              NVARCHAR( 20)  OUTPUT, 
   @nQTY              INT            OUTPUT, 
   @cLottable01       NVARCHAR( 18)  OUTPUT, 
   @cLottable02       NVARCHAR( 18)  OUTPUT, 
   @cLottable03       NVARCHAR( 18)  OUTPUT, 
   @dLottable04       DATETIME       OUTPUT, 
   @nErrNo            INT            OUTPUT, 
   @cErrMsg           NVARCHAR( 120)  OUTPUT    
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cUCCSKU  NVARCHAR (20)
   SET @cBarcodeUCC = replace(TRIM(@cBarcodeUCC),' ','')
   IF @nFunc = 523
   BEGIN
      IF @nStep = 1
      BEGIN
         IF LEN(@cBarcodeUCC) IN (40,44)
         BEGIN
            SELECT 
            @cUCC = CASE 
               WHEN CHARINDEX('(240)', @cBarcodeUCC) > 0 THEN
                     SUBSTRING(
                        @cBarcodeUCC,
                        CHARINDEX('(240)', @cBarcodeUCC) + 5,
                        LEN(@cBarcodeUCC)
                     )
               ELSE NULL
            END
         END
         ELSE IF LEN(@cBarcodeUCC) = 34
         BEGIN
            SELECT 
               @cUCC = RIGHT(@cBarcodeUCC, 20)
         END
         ELSE IF LEN(@cBarcodeUCC) = 67
         BEGIN
            SELECT 
               @cUCC = SUBSTRING(@cBarcodeUCC, 19, 19)
         END

      END
      IF @nStep = 2 -- Sku
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF LEN(@cBarcodeUCC) = 17
            BEGIN
               SELECT @cSKU = 
               CASE 
                  WHEN CHARINDEX('(21)', @cBarcodeUCC) > 0 AND CHARINDEX('(241)', @cBarcodeUCC) > CHARINDEX('(21)', @cBarcodeUCC) THEN
                        SUBSTRING(
                           @cBarcodeUCC,
                           CHARINDEX('(21)', @cBarcodeUCC) + 4,
                           CHARINDEX('(241)', @cBarcodeUCC) - CHARINDEX('(21)', @cBarcodeUCC) - 4
                        )
                  ELSE NULL
               END
               GOTO QUIT
            END
            ELSE
            BEGIN 
               SELECT @cSKU = SKU FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND ALTSKU = @cBarcodeUCC
               IF @@ROWCOUNT = 0
                  SET @cSKU = @cBarcodeUCC
            END
         END
      END
   END

   Quit:
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_523DecodeSP08 TO NSQL
GO

