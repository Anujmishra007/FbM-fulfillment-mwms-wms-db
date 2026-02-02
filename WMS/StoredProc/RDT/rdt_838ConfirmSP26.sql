SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_838ConfirmSP26                                        */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date       Rev  Author      Purposes                                       */
/* 2025-11-17 1.0  NickT       UWP-43907 Merge from V0 WMS-25533              */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838ConfirmSP26 (
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR( 3)
   ,@nStep           INT
   ,@nInputKey       INT
   ,@cFacility       NVARCHAR( 5)
   ,@cStorerKey      NVARCHAR( 15)
   ,@cPickSlipNo     NVARCHAR( 10)
   ,@cFromDropID     NVARCHAR( 20)
   ,@cSKU            NVARCHAR( 20)
   ,@nQTY            INT
   ,@cUCCNo          NVARCHAR( 20)
   ,@cSerialNo       NVARCHAR( 30)
   ,@nSerialQTY      INT
   ,@cPackDtlRefNo   NVARCHAR( 20)
   ,@cPackDtlRefNo2  NVARCHAR( 20)
   ,@cPackDtlUPC     NVARCHAR( 30)
   ,@cPackDtlDropID  NVARCHAR( 20)
   ,@nCartonNo       INT           OUTPUT
   ,@cLabelNo        NVARCHAR( 20) OUTPUT
   ,@nErrNo          INT           OUTPUT
   ,@cErrMsg         NVARCHAR(250) OUTPUT
   ,@nBulkSNO        INT
   ,@nBulkSNOQTY     INT
   ,@cPackData1      NVARCHAR( 30)
   ,@cPackData2      NVARCHAR( 30)
   ,@cPackData3      NVARCHAR( 30)
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
            
   -- Standard confirm
   EXEC rdt.rdt_Pack_Confirm
       @nMobile        = @nMobile
      ,@nFunc          = @nFunc
      ,@cLangCode      = @cLangCode
      ,@nStep          = @nStep
      ,@nInputKey      = @nInputKey
      ,@cFacility      = @cFacility
      ,@cStorerKey     = @cStorerKey
      ,@cPickSlipNo    = @cPickSlipNo
      ,@cFromDropID    = @cFromDropID
      ,@cSKU           = @cSKU
      ,@nQTY           = @nQTY
      ,@cUCCNo         = @cUCCNo
      ,@cSerialNo      = @cSerialNo
      ,@nSerialQTY     = @nSerialQTY
      ,@cPackDtlRefNo  = @cPackDtlRefNo
      ,@cPackDtlRefNo2 = @cPackDtlRefNo2
      ,@cPackDtlUPC    = @cPackDtlUPC
      ,@cPackDtlDropID = @cPackDtlDropID
      ,@nCartonNo      = @nCartonNo      OUTPUT
      ,@cLabelNo       = @cLabelNo       OUTPUT
      ,@nErrNo         = @nErrNo         OUTPUT
      ,@cErrMsg        = @cErrMsg        OUTPUT
      ,@nBulkSNO       = @nBulkSNO
      ,@nBulkSNOQTY    = @nBulkSNOQTY
      ,@cPackData1     = @cPackData1
      ,@cPackData2     = @cPackData2
      ,@cPackData3     = @cPackData3
      ,@nUseStandard   = 1 -- Force use back standard logic, otherwise infinite loop
   IF @nErrNo <> 0
      GOTO Quit
   
   DECLARE @tVasLabel AS VariableTable
   DECLARE @cVASLabel      NVARCHAR( 10)
   DECLARE @cLabelPrinter  NVARCHAR( 10) 
   DECLARE @cPaperPrinter  NVARCHAR( 10) 
   DECLARE @cNotes         NVARCHAR( 500)
   DECLARE @cOrderLineNumber  NVARCHAR( 5)

   -- Get session info
   SELECT 
      @cLabelPrinter = Printer, 
      @cPaperPrinter = Printer_Paper
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile
   
   -- Get order info
   DECLARE @cOrderKey NVARCHAR( 10)
   SELECT @cOrderKey = OrderKey FROM dbo.PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo
   
   -- Get OrderDetail info
   SELECT TOP 1 
      @cOrderLineNumber = OrderLineNumber, 
      @cNotes = ISNULL( Notes, '')
   FROM dbo.OrderDetail WITH (NOLOCK) 
   WHERE OrderKey = @cOrderKey 
      AND SKU = @cSKU
   ORDER BY OrderLineNumber
   
   -- VAS label
   IF @cNotes <> ''
   BEGIN
      DECLARE @curVASLabel CURSOR
      SET @curVASLabel = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
         SELECT value
         FROM STRING_SPLIT( @cNotes, '|')
         WHERE TRIM( value) <> ''
      OPEN @curVASLabel 
      FETCH NEXT FROM @curVASLabel INTO @cVASLabel
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- Common params
         DELETE @tVasLabel 
         INSERT INTO @tVasLabel (Variable, Value) VALUES
            ( '@cOrderKey',         @cOrderKey),
            ( '@cOrderLineNumber',  @cOrderLineNumber),
            ( '@cLabelType',        @cVASLabel),
            ( '@cSKU',              @cSKU)

         -- Print label
         EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
            @cVASLabel, -- Report type
            @tVasLabel, -- Report params
            'rdt_838ConfirmSP26',
            0,  --@nErrNo  OUTPUT,
            '' -- @cErrMsg OUTPUT
         IF @nErrNo <> 0
            GOTO Quit
         
         FETCH NEXT FROM @curVASLabel INTO @cVASLabel
      END
   END
   
Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838ConfirmSP26 TO NSQL
GO
