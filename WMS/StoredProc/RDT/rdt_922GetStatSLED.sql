/************************************************************************/
/* Store procedure: rdt_922GetStatSLED                                  */
/* Purpose: Get statistic                                               */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 21-05-2025 1.0  WSE016     SLED Fn922 Project                        */
/************************************************************************/

CREATE OR ALTER   PROC [RDT].[rdt_922GetStatSLED] (
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

   SELECT @nTotalCarton = COUNT( DISTINCT PD.LabelNo)  
   FROM dbo.PackHeader PH WITH (NOLOCK)
      JOIN dbo.PackDetail PD WITH (NOLOCK) ON (PH.PickSlipNo = PD.PickSlipNo)
   WHERE PH.LoadKey = @cLoadKey
      AND PD.RefNo = @cRefNo

   SELECT  @nTotalCarton = COUNT( DISTINCT PD.DropID)  
   FROM dbo.MBOLDetail MD WITH (NOLOCK)  
   JOIN dbo.PackHeader PH WITH (NOLOCK) ON (MD.LoadKey = PH.LoadKey)
      JOIN dbo.PackDetail PD WITH (NOLOCK) ON (PH.PickSlipNo = PD.PickSlipNo)
   WHERE MD.MbolKey = @cMBOLKey 


   SELECT @nScanCarton = COUNT( 1) 
   FROM rdt.rdtScanToTruck WITH (NOLOCK) 
   WHERE MBOLKey =  @cMBOLKey
      AND RefNo = @cRefNo
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_922GetStatSLED] TO NSQL
GO
