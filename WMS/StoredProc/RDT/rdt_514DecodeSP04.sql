
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_514DecodeSP04                                         */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: Decode For BAT SA                                                 */
/*                                                                            */
/* Date          Rev       Author   Purposes                                  */
/* 2025-11-04  JackC     1.0   FCR-8677 Created                               */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_514DecodeSP04 (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cToID          NVARCHAR( 18),
   @cToLoc         NVARCHAR( 10),
   @cFromLoc       NVARCHAR( 10),
   @cFromID        NVARCHAR( 18),
   @cBarcode       NVARCHAR( MAX),
   @cUCC           NVARCHAR( 20) OUTPUT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @cBarcode = REPLACE(LTRIM(RTRIM(@cBarcode)), ' ', '')

   IF @nFunc = 514
   BEGIN
      IF @nStep = 5 --2Dbarcode 
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF @cBarcode <> ''  -- UCC  Decode
            BEGIN
               IF LEN(@cBarcode) = 40 OR LEN(@cBarcode) = 44--label2
               BEGIN
                  SELECT 
                  @cUCC = 
                  CASE 
                     WHEN CHARINDEX('(240)', @cBarcode) > 0 THEN
                           SUBSTRING(
                              @cBarcode,
                              CHARINDEX('(240)', @cBarcode) + 5,
                              LEN(@cBarcode)
                           )
                     ELSE @cBarcode
                  END
                  GOTO Quit
               END--label2 
               ELSE IF LEN(@cBarcode) = 34 --label4
               BEGIN
                  SELECT @cUCC = RIGHT(@cBarcode, 20)
                  GOTO Quit
               END
               ELSE IF LEN(@cBarcode) = 67 --label5
               BEGIN
                  SELECT @cUCC = SUBSTRING(@cBarcode, 19, 19)
                  GOTO Quit
               END
               ELSE
               BEGIN
                  SET @cUCC = @cBarcode
                  GOTO Quit
               END
            END      
         END
      END --st8
   END

   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXEC ON RDT.rdt_514DecodeSP04 TO NSQL
GO

