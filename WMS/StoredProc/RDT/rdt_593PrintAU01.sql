SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/******************************************************************************/
/* Store procedure: rdt_593PrintHK01                                          */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2025-02-26 1.0  YWA059     Create for hills AU                             */
/******************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_593PrintAU01] (
   @nMobile    INT,
   @nFunc      INT,
   @nStep      INT,
   @cLangCode  NVARCHAR( 3),
   @cStorerKey NVARCHAR( 15),
   @cOption    NVARCHAR( 2), --(yeekung01)
   @cParam1    NVARCHAR(60),  --SCTASK0183384
   @cParam2    NVARCHAR(60),  --SCTASK0183384
   @cParam3    NVARCHAR(60),  --SCTASK0183384
   @cParam4    NVARCHAR(60),  --SCTASK0183384
   @cParam5    NVARCHAR(60),  --SCTASK0183384
   @nErrNo     INT           OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   DECLARE 
       @cSQL             NVARCHAR(MAX),
       @cSQLParam        NVARCHAR(MAX),
	   @nInputKey        INT,
	   @cFacility        NVARCHAR( 5),
	   @cPickSlipNo      NVARCHAR( 10),
	   @cFromDropID      NVARCHAR( 20),
	   @nCartonNo        INT,
	   @cLabelNo         NVARCHAR( 20),
	   @cSKU             NVARCHAR( 20),
	   @nQTY             INT,
	   @cUCCNo           NVARCHAR( 20),
	   @cCartonType      NVARCHAR( 10),
	   @cCube            NVARCHAR( 10),
	   @cWeight          NVARCHAR( 10),
	   @cRefNo           NVARCHAR( 20),
	   @cSerialNo        NVARCHAR( 30),
	   @nSerialQTY       INT,
	   @cPackDtlRefNo    NVARCHAR( 20), 
	   @cPackDtlRefNo2   NVARCHAR( 20), 
	   @cPackDtlUPC      NVARCHAR( 30), 
	   @cPackDtlDropID   NVARCHAR( 20), 
	   @cPackData1       NVARCHAR( 30), 
	   @cPackData2       NVARCHAR( 30), 
	   @cPackData3       NVARCHAR( 30)
   SELECT 
       @cFacility = OD.Facility
       ,@cPickSlipNo = PAD.PickSlipNo
   FROM PackDetail PAD (NOLOCK)
   INNER JOIN PackHeader PAH (NOLOCK) ON PAH.PickSlipNo = PAD.PickSlipNo
   INNER JOIN ORDERS OD (NOLOCK) ON PAH.OrderKey = OD.OrderKey
   WHERE PAD.LabelNo = @cParam1
   SET @nInputKey = 1
   SET @cLabelNo = @cParam1
   SET @nStep = 5 --force change to 5, otherwise can not print SSCC label
   --SET @cSKU = ''
   --SET @cFromDropID = ''
   --SET @nCartonNo = ''
   --SET @nQTY = 1
   --SET @cUCCNo = ''
   --SET @cCube = ''
   --SET @cWeight = ''
   --SET @cRefNo = ''
   --SET @cSerialNo = ''
   --SET @nSerialQTY = 0
   --SET @cPackDtlRefNo = ''
   --SET @cPackDtlRefNo2 = ''
   --SET @cPackDtlUPC = ''
   --SET @cPackDtlDropID = ''
   --SET @cPackData1 = ''
   --SET @cPackData2 = ''
   --SET @cPackData3 = ''
   SET @cSQL = 'EXEC rdt.rdt_838PntShipLbl06' +
     ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, ' +
     ' @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption, ' +
     ' @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, @cPackData1, @cPackData2, @cPackData3, ' +
     ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
  SET @cSQLParam =
     '@nMobile         INT,           ' +
     '@nFunc           INT,           ' +
     '@cLangCode       NVARCHAR( 3),  ' +
     '@nStep           INT,           ' +
     '@nInputKey       INT,           ' +
     '@cFacility       NVARCHAR( 5),  ' +
     '@cStorerKey      NVARCHAR( 15), ' +
     '@cPickSlipNo     NVARCHAR( 10), ' +
     '@cFromDropID     NVARCHAR( 20), ' +
     '@nCartonNo       INT,           ' +
     '@cLabelNo        NVARCHAR( 20), ' +
     '@cSKU            NVARCHAR( 20), ' +
     '@nQTY            INT,           ' +
     '@cUCCNo          NVARCHAR( 20), ' +
     '@cCartonType     NVARCHAR( 10), ' +
     '@cCube           NVARCHAR( 10), ' +
     '@cWeight         NVARCHAR( 10), ' +
     '@cRefNo          NVARCHAR( 20), ' +
     '@cSerialNo       NVARCHAR( 30), ' +
     '@nSerialQTY      INT,           ' +
     '@cOption         NVARCHAR( 1),  ' +
     '@cPackDtlRefNo   NVARCHAR( 20), ' +
     '@cPackDtlRefNo2  NVARCHAR( 20), ' +
     '@cPackDtlUPC     NVARCHAR( 30), ' +
     '@cPackDtlDropID  NVARCHAR( 20), ' +
     '@cPackData1      NVARCHAR( 30), ' +
     '@cPackData2      NVARCHAR( 30), ' +
     '@cPackData3      NVARCHAR( 30), ' +
     '@nErrNo          INT            OUTPUT, ' +
     '@cErrMsg         NVARCHAR( 20)  OUTPUT'
  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
     @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID,
     @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption,
     @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, @cPackData1, @cPackData2, @cPackData3,
     @nErrNo OUTPUT, @cErrMsg OUTPUT
GO


SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXECUTE ON RDT.rdt_593PrintAU01 TO NSQL
GO