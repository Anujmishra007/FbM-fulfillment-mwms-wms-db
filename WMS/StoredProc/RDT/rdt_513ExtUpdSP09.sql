
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_513ExtUpdSP09                                         */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: NLTR2                                                             */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 2026-06-03   JackC     1.0   FCR-12576 Created                             */
/******************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_513ExtUpdSP09
    @nMobile         INT 
   ,@nFunc           INT 
   ,@cLangCode       NVARCHAR( 3) 
   ,@nStep           INT 
   ,@nInputKey       INT
   ,@cStorerKey      NVARCHAR( 15)
   ,@cFacility       NVARCHAR(  5)
   ,@cFromLOC        NVARCHAR( 10)
   ,@cFromID         NVARCHAR( 18)
   ,@cSKU            NVARCHAR( 20)
   ,@nQTY            INT
   ,@cToID           NVARCHAR( 18)
   ,@cToLOC          NVARCHAR( 10)
   ,@nErrNo          INT           OUTPUT 
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag    INT = 0

   DECLARE 
      @cPalletType   NVARCHAR(10),
      @cCapturePalletType  NVARCHAR(1),
      @cMsg01             NVARCHAR(125) = '',
      @cMsg02             NVARCHAR(125) = '',
      @cMsg03             NVARCHAR(125) = ''

   -- Move by SKU
   IF @nFunc = 513
   BEGIN
      IF @nStep = 6 -- ToLOC
      BEGIN
         IF @nInputKey = 1 -- Enter
         BEGIN
            SET @cCapturePalletType = rdt.RDTGetConfig( @nFunc, 'CapturePalletType', @cStorerKey)

            IF @cCapturePalletType = '1'
            BEGIN
               SELECT @cPalletType = C_String1
               FROM rdt.RDTMOBREC WITH (NOLOCK)
               WHERE Mobile = @nMobile

               IF EXISTS (SELECT 1 FROM dbo.ID WHERE ID = @cToID) AND ISNULL(@cPalletType, '') <> ''
               BEGIN
                  BEGIN TRY
                     UPDATE dbo.ID WITH (ROWLOCK)
                     SET PalletType = @cPalletType
                     WHERE ID = @cToID
                  END TRY
                  BEGIN CATCH
                     SET @cMsg01 = '268701'
                     SET @cMsg02 = 'Failed to update pallet type'
                     SET @cMsg03 = ''
                     EXEC rdt.rdtInsertMsgQueue @nMobile = @nMobile,
                                    @nErrNo = @nErrNo,
                                    @cErrMsg = @cErrMsg,
                                    @cLine01 = @cMsg01,
                                    @cLine02 = @cMsg02,
                                    @cLine03 = @cMsg03,
                                    @nDisplayMsg = 0
                  END CATCH
               END
            END -- capture pallet type on
         END
      END --st6
   END --513
   GOTO Quit


Quit:
   
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_513ExtUpdSP09 TO NSQL
GO
