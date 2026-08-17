SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1721CheckID02                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Called from: rdtfnc_Pallet_Move                                      */
/*                                                                      */
/* Purpose: Check ID (skip shipped status=9 validation)                 */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2026-08-07  1.0  Dennis   UWP-63645 Created                          */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1721CheckID02] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cID            NVARCHAR( 40),
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
) AS
BEGIN

   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cStatus          NVARCHAR( 10)
   DECLARE @cLOC             NVARCHAR( 10)

   -- Check blank ID
   IF @cID = ''
   BEGIN
      SET @nErrNo = 277201
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Need ID
      GOTO Quit
   END

   -- Get ID info
   SET @cStatus = ''
   SET @cLOC = ''
   SELECT @cLOC = DropLOC,
          @cStatus = Status
   FROM dbo.DropID WITH (NOLOCK)
   WHERE DropID = @cID

   -- Check valid ID
   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo = 277202
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid ID
      GOTO Quit
   END


   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [RDT].[rdt_1721CheckID02] TO NSQL
GO
