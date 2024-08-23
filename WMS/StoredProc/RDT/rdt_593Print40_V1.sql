
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_593Print40_V1                                      */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2024-02-07  1.0  Ung      WMS-24670 split from rdt_593Print39        */
/*                           Add check label type                       */
/************************************************************************/

CREATE OR ALTER  PROC [RDT].[rdt_593Print40_V1] (
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
   DECLARE @dScanInDate    DATETIME
   DECLARE @dScanOutDate   DATETIME

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
      SET @nErrNo = 211001
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Type
      EXEC rdt.rdtSetFocusField @nMobile, 2
      GOTO Quit
   END
   
   -- Check QTY
   IF rdt.rdtIsValidQty( @cCartonPallet, 1) = 0
   BEGIN
      SET @nErrNo = 211002
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
      SET @nErrNo = 211003
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid PS
      EXEC rdt.rdtSetFocusField @nMobile, 6
      GOTO Quit
   END

   -- Get order info
   DECLARE @nContainerQty INT
   DECLARE @nBilledContainerQty INT
   SELECT 
      @nContainerQty = ISNULL( ContainerQty, 0), 
      @nBilledContainerQty = ISNULL( BilledContainerQty, 0)
   FROM dbo.Orders WITH (NOLOCK) 
   WHERE Orderkey = @cOrderKey

   -- Check label
   IF @nContainerQty = 0 AND @nBilledContainerQty = 0
   BEGIN
      SET @nErrNo = 211008
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UseDespatchLBL
      EXEC rdt.rdtSetFocusField @nMobile, 2
      GOTO Quit
   END

   IF @cLabelType = 'C'
   BEGIN
      UPDATE dbo.Orders SET
         ContainerQTY = @cCartonPallet
      WHERE OrderKey = @cOrderKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 211004
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
         SET @nErrNo = 211005
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD Order Fail
         GOTO Quit
      END
   END

   -- Get pickslip info
   SELECT 
      @dScanInDate = ScanInDate,
      @dScanOutDate = ScanOutDate 
   FROM dbo.PickingInfo WITH (NOLOCK) 
   WHERE PickSlipNo = @cPickSlipNo 
   
   -- Check scan-in
   IF @dScanInDate IS NULL
   BEGIN
      SET @nErrNo = 211006
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Not Scan-in
      GOTO Quit
   END
      
   -- Scan out
   IF @dScanOutDate IS NULL
   BEGIN
      SET @nErrNo = 0  
      EXEC isp_ScanOutPickSlip  
         @c_PickSlipNo  = @cPickSlipNo,  
         @n_err         = @nErrNo OUTPUT,  
         @c_errmsg      = @cErrMsg OUTPUT  

      IF @nErrNo <> 0  
      BEGIN  
         SET @nErrNo = 211007  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Scan Out Fail  
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
      'rdt_593Print40_V1',
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

GRANT EXECUTE ON RDT.rdt_593Print40_V1 TO NSQL
GO