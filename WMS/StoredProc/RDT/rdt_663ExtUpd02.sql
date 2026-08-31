
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_663ExtUpd02                                           */
/* Copyright    Maersk                                                        */
/*                                                                            */
/* Purpose: NLRT2 HWID - KIT HOLD Status Preservation                         */
/*                                                                            */
/* Date       Ver.   Author   Purposes                                        */
/* 2026-08-31 1.0.0  NickT    FCR-16001 Preserve ExternStatus 7-Hold          */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_663ExtUpd02 (
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR( 3),
   @nStep               INT,
   @nInputKey           INT,
   @cFacility           NVARCHAR( 5),
   @cStorerKey          NVARCHAR( 15),
   @cKitKey             NVARCHAR( 10),
   @cExtKitKey          NVARCHAR( 20),
   @cLOC                NVARCHAR( 10),
   @cID                 NVARCHAR( 18),
   @cSKU                NVARCHAR( 20),
   @cLottable01         NVARCHAR( 18),
   @cLottable02         NVARCHAR( 18),
   @cLottable03         NVARCHAR( 18),
   @dLottable04         DATETIME,
   @dLottable05         DATETIME,
   @cLottable06         NVARCHAR( 30),
   @cLottable07         NVARCHAR( 30),
   @cLottable08         NVARCHAR( 30),
   @cLottable09         NVARCHAR( 30),
   @cLottable10         NVARCHAR( 30),
   @cLottable11         NVARCHAR( 30),
   @cLottable12         NVARCHAR( 30),
   @dLottable13         DATETIME,
   @dLottable14         DATETIME,
   @dLottable15         DATETIME,
   @nQTY                INT,
   @cPalletType         NVARCHAR( 10),
   @cDefaultToLoc       NVARCHAR( 10),
   @cKitDtlLineNumber   NVARCHAR( 10),
   @nErrNo              INT            OUTPUT,
   @cErrMsg             NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @bDebugFlag     BINARY = 0
   DECLARE @dUSRDEF6       DATETIME
   DECLARE @cExternStatus  NVARCHAR( 30)

   IF @nFunc = 663
   BEGIN
      IF @nStep = 3 -- id screen
      BEGIN
         IF @nInputKey = 1
         BEGIN
            SELECT @dUSRDEF6 = USRDEF6,
                   @cExternStatus = ExternStatus
            FROM dbo.KIT WITH(NOLOCK)
            WHERE KITKey = @cKitKey

            IF ISNULL(@cExternStatus,'') NOT IN ('7','3')
            BEGIN
               BEGIN TRY
                  UPDATE dbo.KIT WITH (ROWLOCK)
                  SET ExternStatus = '3'
                  WHERE KITKEY = @cKitKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 279601
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Update Kit failed'
                  GOTO Quit
               END CATCH
            END

            IF ISNULL(@dUSRDEF6, '1900-01-01 00:00:00.000' ) = '1900-01-01 00:00:00.000'
            BEGIN
               BEGIN TRY
                  UPDATE dbo.KIT WITH (ROWLOCK)
                  SET USRDEF6 = GETDATE()
                  WHERE KITKEY = @cKitKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 279602
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Update Kit failed'
                  GOTO Quit
               END CATCH
            END
            ELSE
            BEGIN
               BEGIN TRY
                  UPDATE dbo.KIT WITH (ROWLOCK)
                  SET USRDEF7 = GETDATE()
                  WHERE KITKEY = @cKitKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 279603
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Update Kit failed'
                  GOTO Quit
               END CATCH
            END
         END
      END --inputkey=1
   END--663

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_663ExtUpd02 TO NSQL
GO
