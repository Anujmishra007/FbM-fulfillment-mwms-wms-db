SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1620ExtPrint01                                  */
/* Purpose: Print shipping label and carton label                       */
/*                                                                      */
/* Called from: rdt_Cluster_Pick_PrintLabel                             */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 2023-09-21  1.0  James      WMS-23668. Created                       */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1620ExtPrint01] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cStorerkey       NVARCHAR( 15),
   @cWaveKey         NVARCHAR( 10),
   @cLoadKey         NVARCHAR( 10),
   @cOrderKey        NVARCHAR( 10),
   @cLoc             NVARCHAR( 10),
   @cDropID          NVARCHAR( 20),
   @cSKU             NVARCHAR( 20),
   @nQty             INT,
   @tExtPrint        VARIABLETABLE READONLY,
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
)
AS

	SET NOCOUNT ON
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS OFF
	SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cShipLabel   		      NVARCHAR( 10)
   DECLARE @cShippingContentLabel   NVARCHAR( 10)
   DECLARE @cPickSlipNo             NVARCHAR( 10)
   DECLARE @cPrinter                NVARCHAR( 10)
   DECLARE @cFacility               NVARCHAR( 5)
   DECLARE @nCartonNo               INT
   
   SET @nErrNo = 0

   SELECT 
      @cFacility = Facility,
      @cPrinter = Printer
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SET @cShipLabel = rdt.RDTGetConfig( @nFunc, 'ShipLbl', @cStorerkey)
   IF @cShipLabel = '0'
      SET @cShipLabel = ''

   SET @cShippingContentLabel = rdt.RDTGetConfig( @nFunc, 'ShipCttLbl', @cStorerkey)
   IF @cShippingContentLabel = '0'
      SET @cShippingContentLabel = ''
      
   SELECT @cPickSlipNo = PickHeaderKey 
   FROM dbo.PickHeader WITH (NOLOCK) 
   WHERE OrderKey = @cOrderKey

   -- If still blank picklipno then look for conso pick   
   IF ISNULL(@cPickSlipNo, '') = ''
   BEGIN
      SELECT TOP 1 @cPickSlipNo = PickHeaderKey 
      FROM dbo.PickHeader PIH WITH (NOLOCK)
      JOIN dbo.LoadPlanDetail LPD WITH (NOLOCK) ON (PIH.ExternOrderKey = LPD.LoadKey)
      JOIN dbo.Orders O WITH (NOLOCK) ON (LPD.OrderKey = O.OrderKey)
      WHERE O.OrderKey = @cOrderKey
         AND O.StorerKey = @cStorerKey
   END
   
   SELECT TOP 1 @nCartonNo = CartonNo
   FROM dbo.PackDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerkey
   AND   PickSlipNo = @cPickSlipNo
   AND   LabelNo = @cDropID
   ORDER BY 1

      
   IF @cShipLabel <> ''
	BEGIN
	   DECLARE @tShippingLabels AS VariableTable
	   INSERT INTO @tShippingLabels (Variable, Value) VALUES ( '@cPickSlipNo',    @cPickSlipNo)
	   INSERT INTO @tShippingLabels (Variable, Value) VALUES ( '@cFromCartonNo',  @nCartonNo)
	   INSERT INTO @tShippingLabels (Variable, Value) VALUES ( '@cToCartonNo',    @nCartonNo)

	   -- Print label
	   EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cPrinter, '',
		   @cShipLabel, -- Report type
		   @tShippingLabels, -- Report params
		   'rdt_1620ExtPrint01',
		   @nErrNo  OUTPUT,
		   @cErrMsg OUTPUT

	   IF @nErrNo <> 0
	      GOTO QUIT
	END
    
	--Print Shipping Content label
	IF @cShippingContentLabel <> ''    
	BEGIN    
		DECLARE @tShippingContentLabels AS VariableTable    
		INSERT INTO @tShippingContentLabels (Variable, Value) VALUES ( '@cPickSlipNo',   @cPickSlipNo)    
		INSERT INTO @tShippingContentLabels (Variable, Value) VALUES ( '@cFromCartonNo', @nCartonNo)    
		INSERT INTO @tShippingContentLabels (Variable, Value) VALUES ( '@cToCartonNo',   @nCartonNo)    

		-- Print label    
		EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cPrinter,'',      
		@cShippingContentLabel, -- Report type    
		@tShippingContentLabels, -- Report params    
		'rdt_1620ExtPrint01',     
		@nErrNo  OUTPUT,    
		@cErrMsg OUTPUT     

		IF @nErrNo <> 0    
			GOTO QUIT    
	END     

QUIT:
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1620ExtPrint01 TO NSQL
GO