
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Store procedure: rdt_922ExtVal18                                        */
/* Copyright      : Maersk                                                 */
/* Customer       : Columbia SW MY                                         */
/*                                                                         */
/*                                                                         */
/* Date        Rev    Author     Purposes                                  */
/* 2026-05-12  1.0.0  Jackc      FCR-11588 created                         */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_922ExtVal18] (
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
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @nErrNo = 0
   SET @cErrMsg = ''

   IF @nFunc = 922
   BEGIN
      IF @nStep = 1
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Validate Type must be 'O' (Order)
            IF @cType <> 'O'
            BEGIN
               SET @nErrNo = 266201
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END
            ELSE
            BEGIN
               IF EXISTS (SELECT 1 FROM dbo.PickDetail WITH (NOLOCK) WHERE OrderKey = @cOrderKey AND Status IN ('0','3'))
               BEGIN
                  SET @nErrNo = 266202
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- picking not finished
                  GOTO Quit 
               END

               IF EXISTS (SELECT 1 FROM dbo.PickDetail WITH (NOLOCK) WHERE OrderKey = @cOrderKey AND Status ='9')
               BEGIN
                  SET @nErrNo = 266203
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- order shipped
                  GOTO Quit
               END
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

GRANT EXECUTE ON [RDT].[rdt_922ExtVal18] TO NSQL
GO

