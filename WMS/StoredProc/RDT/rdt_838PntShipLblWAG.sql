
/******************************************************************************/
/* Store procedure: rdt_838PntShipLblWAG                                       */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 27-05-2024 1.0  NLT013     FCR-388Merge code to V2 branch,                 */
/*                            original owner is Wojciech                      */
/* 27-05-2024 1.0  JRA432     Copy rdt_838PntShipLbl01 for WAG implementation */
/******************************************************************************/

CREATE OR ALTER     PROC [RDT].[rdt_838PntShipLblWAG] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 5),
   @cStorerKey       NVARCHAR( 15),
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
   @cOption          NVARCHAR( 1),
   @cPackDtlRefNo    NVARCHAR( 20), 
   @cPackDtlRefNo2   NVARCHAR( 20), 
   @cPackDtlUPC      NVARCHAR( 30), 
   @cPackDtlDropID   NVARCHAR( 20), 
   @cPackData1       NVARCHAR( 30), 
   @cPackData2       NVARCHAR( 30), 
   @cPackData3       NVARCHAR( 30), 
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   --SET QUOTED_IDENTIFIER OFF /*Must be off for ZPL decode*/
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  @bDebugFlag    BINARY = 0,
            @cOrderKey     NVARCHAR(10),
			@cDelServiceList NVARCHAR(10) = 'DELSERVICE',
			@cDelService	NVARCHAR(30),
			@cShipLabel        NVARCHAR(10),
			@tReportParam AS VariableTable,
            @cLabelPrinter     NVARCHAR(10),
            @cPaperPrinter     NVARCHAR(10),            
			@nRowCount     INT,
		    @cPrintData  NVARCHAR(MAX),
			@cPrintCommand VARCHAR(MAX)

   IF @nFunc = 838 -- Pack
   BEGIN
      IF @nStep = 5 -- Print label
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF @cOption = '1' -- Yes
            BEGIN
               -- Get session info
			   SELECT 
				   @cLabelPrinter = Printer, 
				   @cPaperPrinter = Printer_Paper
			   FROM rdt.rdtMobRec WITH (NOLOCK)
			   WHERE Mobile = @nMobile 
               DECLARE @bSuccess             INT

               SELECT TOP 1 @cOrderKey = PH.OrderKey,
			   @cDelService = O.UserDefine02
               FROM PickHeader PH WITH (NOLOCK)
			   JOIN dbo.Orders O ON O.StorerKey = PH.StorerKey AND O.OrderKey = PH.OrderKey
               WHERE PH.StorerKey = @cStorerKey
			   AND PH.PickHeaderKey = @cPickSlipNo

               SET @nRowCount = @@ROWCOUNT
			   IF @nRowCount = 0
               BEGIN
                  SET @nErrNo = 250501
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END

               IF @nRowCount <> 0 AND ISNULL(@cOrderKey, '') <> '' AND ISNULL(@cDelService,'') <> ''
               BEGIN --Print Logic					 
				  IF EXISTS(SELECT 1 FROM dbo.Codelkup WITH (NOLOCK)
							WHERE Storerkey = @cStorerKey
							AND ListName = @cDelServiceList
							AND Code = @cDelService 
							AND UDF02 = 'TMS_ENABLED')
				  BEGIN --Decode and print carrier label
					 BEGIN
						IF NOT EXISTS(SELECT 1 FROM dbo.CartonTrack (NOLOCK) 
						              WHERE KeyName = @cStorerKey 
						              AND LabelNo = @cLabelNo 
									  AND ISNULL(PrintData,'') <> '')
                        BEGIN
                           SET @nErrNo = 101902
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No Print Data
                           GOTO Quit
                        END
						ELSE  --Print found Label data
						BEGIN
				           --Get Report Type
					       SELECT 
						      @cShipLabel = Svalue 
					       FROM rdt.StorerConfig  WITH (NOLOCK)
					       WHERE Storerkey = @cStorerKey 
					       AND Function_id = @nFunc
					       AND ConfigKey = 'ShipLabelTMS'
					       
						   --Build Parameters
                           INSERT INTO @tReportParam (Variable, Value) VALUES
					          ( '@cStorerKey',     @cStorerKey),
					          ( '@cPickSlipNo',    @cPickSlipNo),
					          ( '@cFromDropID',    @cFromDropID), -->
					          ( '@cPackDtlDropID', @cPackDtlDropID),
					          ( '@cLabelNo',       @cLabelNo),
					          ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))

					       -- Print label (Label data is retreived by SP configured vs Rdt.RdtReport record)
					       EXEC RDT.rdt_Print 
					          @nMobile, 
					          @nFunc, 
					          @cLangCode, 
					          @nStep, 
					          @nInputKey, 
					          @cFacility, 
					          @cStorerKey, 
					          @cLabelPrinter, 
					          @cPaperPrinter,
					          @cShipLabel, -- Report type
					          @tReportParam, -- Report params
					          'rdtfnc_Pack',
					          @nErrNo  OUTPUT,
					          @cErrMsg OUTPUT,
							  NULL --@nNoOfCopy
							  --@cPrintCommand
                           
						   IF @nErrNo <> 0
                              GOTO Quit
						END
				     END
				  END --Decode and print carrier label
			   ELSE 
			      BEGIN --Print internal label from rdt.rdtreport config
				    --Get Report Type
					SELECT 
					   @cShipLabel = Svalue 
					FROM rdt.StorerConfig  WITH (NOLOCK)
					WHERE Storerkey = @cStorerKey 
					AND Function_id = @nFunc
					AND ConfigKey = 'ShipLabelRpt'
				
					--Build Parameters
                    INSERT INTO @tReportParam (Variable, Value) VALUES
					   ( '@cStorerKey',     @cStorerKey),
					   ( '@cPickSlipNo',    @cPickSlipNo),
					   ( '@cFromDropID',    @cFromDropID), -->
					   ( '@cPackDtlDropID', @cPackDtlDropID),
					   ( '@cLabelNo',       @cLabelNo),
					   ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))

					-- Print label
					EXEC RDT.rdt_Print 
					   @nMobile, 
					   @nFunc, 
					   @cLangCode, 
					   @nStep, 
					   @nInputKey, 
					   @cFacility, 
					   @cStorerKey, 
					   @cLabelPrinter, 
					   @cPaperPrinter,
					   @cShipLabel, -- Report type
					   @tReportParam, -- Report params
					   'rdtfnc_Pack',
					   @nErrNo  OUTPUT,
					   @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                        GOTO Quit
                      
				  END --Print internal label from rdt.rdtreport config
               END --Print Logic
               GOTO Quit
            END -- option=1
         END -- key=1
      END -- step5
   END -- 838

   GOTO Quit

   Quit:  



END--sp

GO
 
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
GRANT EXECUTE ON RDT.rdt_838PntShipLblWAG TO NSQL
GO

