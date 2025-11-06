
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************/
/* Store procedure: rdt_521DecodeSP02                                         */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Purpose: Decode For BAT case                                               */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2025-10-27  Deenis    1.0   FCR-8674 Created                               */
/******************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_521DecodeSP02] (
   @nMobile           INT,           
   @nFunc             INT,           
   @cLangCode         NVARCHAR( 3),  
   @nStep             INT,           
   @nInputKey         INT,           
   @cFacility         NVARCHAR( 5),  
   @cStorerKey        NVARCHAR( 15), 
   @cBarcodeUCC       NVARCHAR( 200), 
   @cUCC              NVARCHAR( 20)  OUTPUT, 
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

   IF @nFunc = 521
   BEGIN
      IF @nStep = 1
      BEGIN
         IF LEN(@cBarcodeUCC) = 40
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
   END

   Quit:
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_521DecodeSP02 TO NSQL
GO

