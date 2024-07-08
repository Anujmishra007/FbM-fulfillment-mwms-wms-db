SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_838DropIDVLT                                    */
/*                                                                      */
/*                                                                      */
/* Date         Author   Purposes                                       */
/* 5/17/2024    PPA374   Inserts DROPID in the DropID table             */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_838DropIDVLT] (
   @nMobile         INT,            
   @nFunc           INT,            
   @cLangCode       NVARCHAR( 3),   
   @nStep           INT,            
   @nInputKey       INT,            
   @cFacility       NVARCHAR( 5),   
   @cStorerKey      NVARCHAR( 15),  
   @cPickSlipNo     NVARCHAR( 10),  
   @cFromDropID     NVARCHAR( 20),  
   @nCartonNo       INT,            
   @cLabelNo        NVARCHAR( 20),  
   @cSKU            NVARCHAR( 20),  
   @nQTY            INT,            
   @cUCCNo          NVARCHAR( 20),  
   @cCartonType     NVARCHAR( 10),  
   @cCube           NVARCHAR( 10),  
   @cWeight         NVARCHAR( 10),  
   @cRefNo          NVARCHAR( 20),  
   @cSerialNo       NVARCHAR( 30),  
   @nSerialQTY      INT,            
   @cOption         NVARCHAR( 1),   
   @cPackDtlRefNo   NVARCHAR( 20),  
   @cPackDtlRefNo2  NVARCHAR( 20),  
   @cPackDtlUPC     NVARCHAR( 30),  
   @cPackDtlDropID  NVARCHAR( 20),  
   @cPackData1      NVARCHAR( 30),  
   @cPackData2      NVARCHAR( 30),  
   @cPackData3      NVARCHAR( 30),  
   @nErrNo          INT            OUTPUT,  
   @cErrMsg         NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
   @LOADKEY nvarchar(20),
   @PICKSLIP nvarchar(20)

   SELECT @LOADKEY = LoadKey FROM ORDERS (NOLOCK) WHERE orderkey = (SELECT TOP 1 OrderKey FROM PICKDETAIL (NOLOCK) WHERE DropID = @cFromDropID)
   SELECT @PICKSLIP = PickHeaderKey FROM PICKHEADER (NOLOCK) WHERE orderkey = (SELECT TOP 1 OrderKey FROM PICKDETAIL (NOLOCK) WHERE DropID = @cFromDropID)
   
   IF @nFunc = 838
   BEGIN
      IF @nStep = 5 and @cOption = 2 and not exists (SELECT 1 FROM dropid WHERE dropid = @cPackDtlDropID)
      BEGIN
         INSERT INTO Dropid(Dropid,Droploc,AdditionalLoc,DropIDType,LabelPrinted,ManifestPrinted,Status,AddDate,AddWho,EditDate,EditWho,TrafficCop,ArchiveCop,Loadkey,PickSlipNo,UDF01,UDF02,UDF03,UDF04,UDF05)
         VALUES(@cPackDtlDropID,'','',0,'N',0,5,GETDATE(),SUSER_NAME(),GETDATE(),SUSER_NAME(),null,null,@LOADKEY,@PICKSLIP,'','','','','')
      END
      ELSE IF @nStep = 5 and @cOption = 1 and not exists (SELECT 1 FROM dropid WHERE dropid = @cPackDtlDropID)
      BEGIN
         INSERT INTO Dropid(Dropid,Droploc,AdditionalLoc,DropIDType,LabelPrinted,ManifestPrinted,Status,AddDate,AddWho,EditDate,EditWho,TrafficCop,ArchiveCop,Loadkey,PickSlipNo,UDF01,UDF02,UDF03,UDF04,UDF05)
         VALUES(@cPackDtlDropID,'','',0,'Y',0,5,GETDATE(),SUSER_NAME(),GETDATE(),SUSER_NAME(),null,null,@LOADKEY,@PICKSLIP,'','','','','')
      END
      ELSE IF @nStep = 5 and @cOption = 1 and exists (SELECT 1 FROM dropid WHERE dropid = @cPackDtlDropID and LabelPrinted = 'N')
      BEGIN
         UPDATE dropid
         SET LabelPrinted = 'Y'
         WHERE dropid = @cPackDtlDropID
      END
      IF @nStep = 3 and not exists (SELECT 1 FROM dropid WHERE dropid = @cPackDtlDropID)
      BEGIN
         INSERT INTO Dropid(Dropid,Droploc,AdditionalLoc,DropIDType,LabelPrinted,ManifestPrinted,Status,AddDate,AddWho,EditDate,EditWho,TrafficCop,ArchiveCop,Loadkey,PickSlipNo,UDF01,UDF02,UDF03,UDF04,UDF05)
         VALUES(@cPackDtlDropID,'','',0,'N',0,5,GETDATE(),SUSER_NAME(),GETDATE(),SUSER_NAME(),null,null,@LOADKEY,@PICKSLIP,'','','','','')
      END
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_838DropIDVLT] TO NSQL
GO  

