SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_513DecodeSP05                                         */
/* Copyright: Maersk                                                          */
/* Purpose: BAT SA                                                            */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2025-11-04  JackC     1.0   FCR-8677 Created                               */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_513DecodeSP05 (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),  
   @cStorerKey   NVARCHAR( 15), 
   @cBarcode     NVARCHAR( 2000), 
   @cFromLOC     NVARCHAR( 10)  OUTPUT, 
   @cFromID      NVARCHAR( 18)  OUTPUT, 
   @cSKU         NVARCHAR( 20)  OUTPUT, 
   @nQTY         INT            OUTPUT, 
   @cToLOC       NVARCHAR( 10)  OUTPUT, 
   @cToID        NVARCHAR( 18)  OUTPUT, 
   @nErrNo       INT            OUTPUT, 
   @cErrMsg      NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @cBarcode = REPLACE(LTRIM(RTRIM(@cBarcode)), ' ','')
   
   IF @nFunc = 513 -- Move by SKU
   BEGIN
      IF @nStep = 3 -- SKU
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF @cBarcode <> ''
            BEGIN
               IF LEN(@cBarcode) = 17 --label 2
               BEGIN
                  SELECT @cSKU = 
                  CASE 
                     WHEN CHARINDEX('(21)', @cBarcode) > 0 AND CHARINDEX('(241)', @cBarcode) > CHARINDEX('(21)', @cBarcode) THEN
                           SUBSTRING(
                              @cBarcode,
                              CHARINDEX('(21)', @cBarcode) + 4,
                              CHARINDEX('(241)', @cBarcode) - CHARINDEX('(21)', @cBarcode) - 4
                           )
                     ELSE @cBarcode
                  END

                  GOTO Quit
               END --label 2
               ELSE IF LEN(@cBarcode) = 67 --label 5
               BEGIN
                  SELECT  @cSKU = SUBSTRING(@cBarcode, 51, 8)
                  GOTO Quit
               END --label 5
               ELSE
               BEGIN
                  SET @cSKU = @cBarcode
                  GOTO Quit
               END
            END
         END   -- ENTER
      END   -- @nStep = 3
   END

   Quit:

END--sp
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_513DecodeSP05 TO NSQL
GO
