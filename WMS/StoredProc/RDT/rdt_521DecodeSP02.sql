
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
   @cBarcode          NVARCHAR( MAX), 
   @cUCCNo            NVARCHAR( 20)  OUTPUT, 
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
   SET @cBarcode = replace(TRIM(@cBarcode),' ','')
   IF @nFunc = 521
   BEGIN
      IF @nStep = 1
      BEGIN
         IF LEN(@cBarcode) IN (40,44)
         BEGIN
            SELECT 
            @cUCCNo = CASE 
               WHEN CHARINDEX('(240)', @cBarcode) > 0 THEN
                     SUBSTRING(
                        @cBarcode,
                        CHARINDEX('(240)', @cBarcode) + 5,
                        LEN(@cBarcode)
                     )
               ELSE NULL
            END
         END
         ELSE IF LEN(@cBarcode) = 34
         BEGIN
            SELECT 
               @cUCCNo = RIGHT(@cBarcode, 20)
         END
         ELSE IF LEN(@cBarcode) = 67
         BEGIN
            SELECT 
               @cUCCNo = SUBSTRING(@cBarcode, 19, 19)
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

