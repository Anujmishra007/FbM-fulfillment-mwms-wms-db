
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_593Print39                                      */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2023-09-19  1.0  Ung      WMS-23518 Created                          */
/************************************************************************/

CREATE OR ALTER  PROC [RDT].[rdt_593Print39] (
   @nMobile    INT,
   @nFunc      INT,
   @nStep      INT,
   @cLangCode  NVARCHAR( 3),
   @cStorerKey NVARCHAR( 15),
   @cOption    NVARCHAR( 2),
   @cParam1    NVARCHAR(20), 
   @cParam2    NVARCHAR(20),  
   @cParam3    NVARCHAR(20),
   @cParam4    NVARCHAR(20),
   @cParam5    NVARCHAR(20),
   @nErrNo     INT           OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cLabelPrinter  NVARCHAR( 10)
   DECLARE @cPaperPrinter  NVARCHAR( 10)
   DECLARE @cFacility      NVARCHAR( 20)
   DECLARE @nInputKey      INT

   DECLARE @cLabelType     NVARCHAR( 1)
   DECLARE @cCartonPallet  NVARCHAR( 5)
   DECLARE @cPickSlipNo    NVARCHAR( 10)
   DECLARE @cOrderKey      NVARCHAR( 10) = ''

   -- Param mapping
   SET @cLabelType = LEFT( @cParam1, 1)
   SET @cCartonPallet = LEFT( @cParam2, 5)
   SET @cPickSlipNo = LEFT( @cParam3, 10)
   
   -- Get session info
   SELECT 
      @cLabelPrinter = Printer,
      @cPaperPrinter = Printer_Paper,
      @cFacility = Facility,
      @nInputKey = InputKey
   FROM rdt.rdtMobrec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Check type valid
   IF @cLabelType NOT IN ('C', 'P')
   BEGIN
      SET @nErrNo = 206351
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Type
      EXEC rdt.rdtSetFocusField @nMobile, 2
      GOTO Quit
   END
   
   -- Check QTY
   IF rdt.rdtIsValidQty( @cCartonPallet, 1) = 0
   BEGIN
      SET @nErrNo = 206352
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid QTY
      EXEC rdt.rdtSetFocusField @nMobile, 4
      GOTO Quit
   END

   -- Get pickslip info
   SELECT @cOrderKey = OrderKey
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   -- Check PickSlip valid
   IF @cOrderKey = ''
   BEGIN
      SET @nErrNo = 206353
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid PS
      EXEC rdt.rdtSetFocusField @nMobile, 6
      GOTO Quit
   END

   IF @cLabelType = 'C'
   BEGIN
      UPDATE dbo.Orders SET
         ContainerQTY = @cCartonPallet
      WHERE OrderKey = @cOrderKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 206354
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD Order Fail
         GOTO Quit
      END
   END
   ELSE IF @cLabelType = 'P'
   BEGIN
      UPDATE dbo.Orders SET
         BilledContainerQTY = @cCartonPallet
      WHERE OrderKey = @cOrderKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 206355
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD Order Fail
         GOTO Quit
      END
   END
   
   -- Print label
   DECLARE @tReportType AS VariableTable
   INSERT INTO @tReportType (Variable, Value) VALUES 
      ( '@cOrderKey',      @cOrderKey), 
      ( '@cLabelType',     @cLabelType), 
      ( '@cCartonPallet',  @cCartonPallet)

   EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cLabelPrinter, @cPaperPrinter,
      'DESPATCHLB', -- Report type
      @tReportType, -- Report params
      'rdt_593Print39',
      @nErrNo  OUTPUT,
      @cErrMsg OUTPUT

   IF @nErrNo <> 0
      GOTO Quit

Quit:

END

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_593Print39 TO NSQL
GO