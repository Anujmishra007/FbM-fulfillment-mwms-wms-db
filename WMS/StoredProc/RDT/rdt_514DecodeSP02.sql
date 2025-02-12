
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_514DecodeSP02                                         */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: Decode For PMI case                                               */
/*                                                                            */
/* Date          Rev       Author   Purposes                                  */
/* 2024-10-22    ShaoAn    1.0      FCR-759-1001 ID and UCC Length Issue      */
/* 2024-12-21    Dennis    1.1      No need to decode on step 3               */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_514DecodeSP02 (
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

   SET @cBarcode = LTRIM(RTRIM(@cBarcode))
   IF @nFunc = 514
   BEGIN
      IF @nStep = 1 
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            If @cBarcode <> ''  -- UCC  Decode
            BEGIN
               If @cBarcode <> ''
               BEGIN
                  IF LEN(@cBarcode) = 20
                  BEGIN
                     SET @cUCC = @cBarcode
                     GOTO Quit
                  END

                  IF LEN(@cBarcode) <> 40
                  BEGIN
                     SET @nErrNo = 227152
                     SET @cErrMsg = [rdt].[rdtgetmessage]( @nErrNo, @cLangCode, N'DSP') -- Invalid UCC(40 digit)
                     GOTO Quit
                  END
                  SET @cUCC = RIGHT(@cBarcode, 20)
                  GOTO Quit
               END
            END
         END
      END

      -- IF @nStep = 3
      -- BEGIN
      --    IF @nInputKey = 1 -- ENTER
      --       If @cBarcode <> ''  -- ID  Decode
      --       BEGIN
      --          IF LEN(@cBarcode) = 18
      --          BEGIN
      --             SET @cSKU = @cBarcode
      --             GOTO Quit
      --          END

      --          IF LEN(@cBarcode) <> 25
      --          BEGIN
      --                SET @nErrNo = 227151
      --                SET @cErrMsg = [rdt].[rdtgetmessage]( @nErrNo, @cLangCode, N'DSP') -- Invalid ID(25 digit)
      --                GOTO Quit
      --          END
      --          SET @cSKU = RIGHT(@cBarcode, 18)
      --          END
      --       END
      --    END
      -- END
   END

   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXEC ON RDT.rdt_514DecodeSP02 TO NSQL
GO

