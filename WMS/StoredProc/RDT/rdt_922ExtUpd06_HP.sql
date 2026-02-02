SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/*******************************************************************************************************************************/
/* Store procedure: rdt_922ExtUpd06_HP                                                                                         */
/* Copyright      : Maersk                                                                                                     */
/* Customer       :                                                                                                            */
/*                                                                                                                             */
/* Purpose: Scanned carton split to different order, to enable partial ship feature                                            */
/*                                                                                                                             */
/* Date       Rev    Author     Purposes                                                                                       */
/* 2024-10-18 1.0    VJI011     none packing process enhancement for ACT                                                       */
/* 2024-10-18 1.1.0  NLT013     UWP-27868 Open qty is wrong                                                                    */
/* 2025-02-05 2.0    AGA399     Copy SP version for Amazon rdt_922ExtUpd06_AMZ to All customer of NLRT with same config        */
/*******************************************************************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_922ExtUpd06_HP] (
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
begin
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount        INT
      
 

   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN
   SAVE TRAN rdt_1650ExtUpd02


 IF @nFunc = 922 -- Scan to truck (by label no)
  
   BEGIN
      IF @nStep = 2 
      BEGIN
       IF @nInputKey = 1
		begin
         IF  NOT EXISTS ( SELECT 1
						  FROM dbo.PickDetail PD WITH (NOLOCK)
                         JOIN dbo.MBOLDetail MD WITH (NOLOCK) ON ( PD.OrderKey = MD.OrderKey)
                         WHERE PD.StorerKey = @cStorerKey
                         AND   ISNULL( PD.ID, '') <> ''
                         AND   MD.MBOLKey = @cMBOLKey
                         AND   NOT EXISTS ( SELECT 1 FROM rdt.rdtScanToTruck ST WITH (NOLOCK)
                                            WHERE MD.MBOLKey = ST.MBOLKey
                                            AND   PD.ID = ST.URNNo
											AND ST.Status='9'
                                          --  AND   ST.CartonType = 'SCNPT2DOOR'
										  ))  
         
		 
		 BEGIN
        
            UPDATE Orders
            SET status = 8
            WHERE MBolKey = @cMBOLKey 
         END
	end
  end
  end

   COMMIT TRAN rdt_1650ExtUpd02

   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1650ExtUpd02 -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN

end
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [RDT].[rdt_922ExtUpd06_HP] TO NSQL
GO
