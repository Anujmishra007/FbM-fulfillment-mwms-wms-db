
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_922ExtVal13                                     */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2023-10-26 1.0  James      WMS-23887 Created                         */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_922ExtVal13 (
   @nMobile     INT,
   @nFunc       INT,
   @cLangCode   NVARCHAR( 3),
   @nStep       INT,
   @nInputKey   INT,
   @cStorerKey  NVARCHAR( 15),
   @cType       NVARCHAR( 1),
   @cMBOLKey    NVARCHAR( 10),
   @cLoadKey    NVARCHAR( 10),
   @cOrderKey   NVARCHAR( 10),
   @cLabelNo    NVARCHAR( 20),
   @cPackInfo   NVARCHAR( 3),
   @cWeight     NVARCHAR( 10),
   @cCube       NVARCHAR( 10),
   @cCartonType NVARCHAR( 10),
   @cDoor       NVARCHAR( 10),
   @cRefNo      NVARCHAR( 40),
   @nErrNo      INT           OUTPUT,
   @cErrMsg     NVARCHAR( 20) OUTPUT
)
AS

SET NOCOUNT ON
SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
SET CONCAT_NULL_YIELDS_NULL OFF

IF @nFunc = 922 -- Scan to truck
BEGIN
   IF @nStep = 2  -- LABEL NO
   BEGIN
      DECLARE @cStatus NVARCHAR(10) = ''
      
      SELECT @cStatus = [Status]
      FROM dbo.ID WITH (NOLOCK)
      WHERE Id = @cLabelNo
      
      IF @cStatus <> 'OK'
      BEGIN
         SET @nErrNo = 207951
         SET @cErrMsg = RTRIM( rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')) --ID STATUS:
                        + @cStatus         
         GOTO Quit
      END
   END
END

Quit:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_922ExtVal13 TO NSQL
GO
