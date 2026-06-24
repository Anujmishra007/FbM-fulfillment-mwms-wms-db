SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_839ExtSNVal02                                         */
/* Copyright      : Maersk                                                    */
/* Customer       : PAGEIND                                                   */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2026-06-23  1.0   NYE018     FCR-12865 Validate serial no not already      */
/*                              scanned in the same session                   */
/******************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_839ExtSNVal02
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 3),
   @cStorerKey       NVARCHAR( 15),
   @cSKU             NVARCHAR( 20),
   @nQTY             INT,
   @cSerialNo        NVARCHAR( 30),
   @cType            NVARCHAR( 15),
   @cDocType         NVARCHAR( 10),
   @cDocNo           NVARCHAR( 20),
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 839
   BEGIN
      IF EXISTS(
         SELECT 1
         FROM rdt.rdtReceiveSerialNoLog WITH(NOLOCK)
         WHERE Mobile = @nMobile
            AND Func = @nFunc
            AND SerialNo = @cSerialNo
      )
      BEGIN
         SET @nErrNo = 270951
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 270951 SNOAlreadyScanned
         GOTO Quit
      END
   END -- IF @nFunc = 839

   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_839ExtSNVal02 TO NSQL
GO
