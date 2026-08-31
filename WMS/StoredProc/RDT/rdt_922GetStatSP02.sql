
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_922GetStatSP02                                  */
/* Purpose: Get statistic                                               */
/* Customer       : Columbia SW MY                                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-05-12 1.0  Jackc      FCR-11588. Created                        */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_922GetStatSP02] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @cStorerKey   NVARCHAR( 15),
   @cType        NVARCHAR( 1),
   @cMBOLKey     NVARCHAR( 10),
   @cLoadKey     NVARCHAR( 10),
   @cOrderKey    NVARCHAR( 10),
   @cDoor        NVARCHAR( 10),
   @cRefNo       NVARCHAR( 40),
   @cCheckPackDetailDropID INT,
   @cCheckPickDetailDropID INT,
   @nTotalCarton INT OUTPUT,
   @nScanCarton  INT OUTPUT,
   @nErrNo       INT           OUTPUT,
   @cErrMsg      NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @nErrNo = 0
   SET @cErrMsg = ''

   SELECT @nTotalCarton = COUNT( DISTINCT PD.DropID)
   FROM dbo.PickDetail PD WITH (NOLOCK)
   WHERE PD.OrderKey = @cOrderKey AND PD.Status = '5'

   SELECT @nScanCarton = COUNT( 1)
   FROM rdt.rdtScanToTruck WITH (NOLOCK)
   WHERE OrderKey = @cOrderKey AND Status = '9'

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_922GetStatSP02] TO NSQL
GO
