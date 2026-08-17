SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_511ExtUpd14                                     */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2026-08-14 1.0    Dennis   UWP-63442 Reset scanned UCC status 5->1  */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_511ExtUpd14] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cFromID        NVARCHAR( 18),
   @cFromLOC       NVARCHAR( 10),
   @cToLOC         NVARCHAR( 10),
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 511
   BEGIN
      IF @nStep = 3
      BEGIN
         IF @nInputKey = 1
         BEGIN
            -- Reset scanned UCCs with status 5 back to 1
            BEGIN TRY
               UPDATE dbo.UCC WITH (ROWLOCK)
               SET    Status   = '1',
                      EditWho  = SUSER_SNAME(),
                      EditDate = GETDATE()
               WHERE  StorerKey = @cStorerKey
                 AND  Status    = '5'
                 AND  LOC       = @cToLOC
                 AND  ID        = @cFromID
            END TRY
            BEGIN CATCH
               SET @nErrNo  = 278351
               SET @cErrMsg = rdt.rdtGetMessage(@nErrNo, @cLangCode, N'DSP')
               GOTO Quit
            END CATCH
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

GRANT EXECUTE ON [RDT].[rdt_511ExtUpd14] TO NSQL
GO
