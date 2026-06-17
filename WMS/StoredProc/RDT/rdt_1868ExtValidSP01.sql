
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1868ExtValidSP01                                */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date         Rev   Author      Purposes                              */
/* 2026-06-16   1.0   NYE018      FCR-12825 Extended Validation SP      */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_1868ExtValidSP01 (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),
   @cStorerKey   NVARCHAR( 15),
   @cUnPackType  NVARCHAR( 60),
   @nErrNo       INT            OUTPUT,
   @cErrMsg      NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cUNPACK_MODEL  NVARCHAR( 1) = '1'

   SET @nErrNo = 0
   SET @cErrMsg = ''

   IF @nStep = 2
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
      
         IF @cUnPackType = @cUNPACK_MODEL
         BEGIN
            SET @nErrNo = 270401
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  --270401^Unpack not allowed
            GOTO Quit
         END

      END -- Enter
   END -- Step 2

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1868ExtValidSP01 TO NSQL
GO
