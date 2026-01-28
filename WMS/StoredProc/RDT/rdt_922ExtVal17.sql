SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************/
/* Store procedure: rdt_922ExtVal17                                     */
/* Copyright      : Maersk                                              */
/* Customer       :                                                     */
/*                                                                      */
/* Date       Rev    Author     Purposes                                */
/* 2025-01-28 1.0.0  Dennis     FCR-10164 Created                       */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_922ExtVal17] (
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
   IF @nStep = 2
   BEGIN
      IF @nInputKey = 1
      BEGIN
         IF EXISTS ( 
            SELECT 1
            FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN ORDERS O (NOLOCK) ON PD.StorerKey = O.StorerKey AND PD.OrderKey = O.OrderKey AND O.UserDefine03 <> '001'
            JOIN PACKHEADER PH WITH (NOLOCK) ON PD.StorerKey = PH.StorerKey AND PD.OrderKey = PH.OrderKey
            WHERE PD.StorerKey = @cStorerKey
               AND PD.DropID = @cLabelNo
               AND PH.ManifestPrinted = '0'
         )
         BEGIN
            SET @nErrNo = 180021
            SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') -- Please Print PackSlip (Manifest) report to continue
            GOTO Quit
         END
      END
   END
END

Quit:
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_922ExtVal17 TO NSQL
GO

