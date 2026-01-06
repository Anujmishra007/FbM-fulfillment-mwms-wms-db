
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_514DecodeSP03                                         */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: Decode For PAGEIND case                                           */
/*                                                                            */
/* Date          Rev       Author   Purposes                                  */
/* 2025-10-22    Ung       1.0      FCR-8308 Created                          */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_514DecodeSP03 (
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

   IF @nFunc = 514 -- Move by UCC
   BEGIN
      IF @nStep = 5 -- 2D barcode
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Composite barcode
            IF CHARINDEX( '&', @cBarcode) > 0
            BEGIN
               DECLARE @nRowCount INT
               DECLARE @cStyle NVARCHAR( 30)
               DECLARE @cSize  NVARCHAR( 30)
               DECLARE @cL01P1 NVARCHAR( 18)
               DECLARE @cL01P2 NVARCHAR( 18)
               DECLARE @cSNOP1 NVARCHAR( 10)
               DECLARE @cSNOP2 NVARCHAR( 10)
               DECLARE @cSNOP3 NVARCHAR( 10)
               
               DECLARE @tValue TABLE
               (
                  value       NVARCHAR( 100), 
                  RowNumber   INT
               )
               
               INSERT INTO @tValue (value, RowNumber)
               SELECT value, ROW_NUMBER() OVER ( ORDER BY (SELECT 1)) RowNumber 
               FROM STRING_SPLIT( @cBarcode, '&')
               
               SELECT 
                  @cStyle = CASE WHEN RowNumber = 2 THEN value ELSE @cStyle END, 
                  @cSize  = CASE WHEN RowNumber = 3 THEN value ELSE @cSize  END, 
                  @cSNOP1 = CASE WHEN RowNumber = 4 THEN value ELSE @cSNOP1 END, 
                  @cSNOP2 = CASE WHEN RowNumber = 5 THEN value ELSE @cSNOP2 END, 
                  @cL01P1 = CASE WHEN RowNumber = 6 THEN value ELSE @cL01P1 END, 
                  @cSNOP3 = CASE WHEN RowNumber = 7 THEN value ELSE @cSNOP3 END, 
                  @cL01P2 = CASE WHEN RowNumber = 8 THEN value ELSE @cL01P2 END
               FROM @tValue
               
               -- Invalid barcode
               IF @@ROWCOUNT <> 9
               BEGIN
                  SET @nErrNo = 248201
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid barcode
                  GOTO Quit
               END

               SET @cUCC = @cSNOP1 + @cSNOP2 + @cSNOP3
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

GRANT EXEC ON RDT.rdt_514DecodeSP03 TO NSQL
GO

