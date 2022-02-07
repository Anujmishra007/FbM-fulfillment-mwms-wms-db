if exists (select * from dbo.sysobjects where id = object_id(N'[rdt].[rdt_593Print33]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [rdt].[rdt_593Print33]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_593Print33                                         */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date       Rev  Author   Purposes                                       */
/* 2021-06-02 1.0  James    WMS-17143. Created                             */
/***************************************************************************/

CREATE PROC rdt.rdt_593Print33 (
   @nMobile    INT,
   @nFunc      INT,
   @nStep      INT,
   @cLangCode  NVARCHAR( 3),
   @cStorerKey NVARCHAR( 15),
   @cOption    NVARCHAR( 1),
   @cParam1    NVARCHAR(20),  -- ASN
   @cParam2    NVARCHAR(20),  -- ID
   @cParam3    NVARCHAR(20),  -- SKU/UPC
   @cParam4    NVARCHAR(20),
   @cParam5    NVARCHAR(20),
   @nErrNo     INT OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   DECLARE @cPaperPrinter  NVARCHAR( 10)
          ,@cPH_StorerKey  NVARCHAR( 15)
          ,@cLabelNo       NVARCHAR( 20)
          ,@cPickSlipNo    NVARCHAR( 10)
          ,@cDataWindow    NVARCHAR( 50)  
          ,@cTargetDB      NVARCHAR( 20)   
          ,@cReportType    NVARCHAR( 10) 
          ,@cLoadKey       NVARCHAR( 10) 
          ,@cPickHeaderKey NVARCHAR( 10) 
          ,@nCartonNo      INT
          ,@nTTLCnts       INT
          ,@cOrderKey      NVARCHAR( 10)
          ,@cSalesman      NVARCHAR( 30)
          ,@cUDF01         NVARCHAR( 60)
          ,@cUDF02         NVARCHAR( 60)
          ,@cPaperPrinter1 NVARCHAR( 10)
          ,@cPaperPrinter2 NVARCHAR( 10)
          ,@tCR            VariableTable
          ,@tSI            VariableTable

   DECLARE @cErrMsg01        NVARCHAR( 20),
           @cErrMsg02        NVARCHAR( 20),
           @cErrMsg03        NVARCHAR( 20),
           @cErrMsg04        NVARCHAR( 20),
           @cErrMsg05        NVARCHAR( 20),
           @cErrMsg06        NVARCHAR( 20),
           @cErrMsg07        NVARCHAR( 20),
           @cErrMsg08        NVARCHAR( 20),
           @cErrMsg09        NVARCHAR( 20),
           @cErrMsg10        NVARCHAR( 20),
           @cErrMsg11        NVARCHAR( 20),
           @cErrMsg12        NVARCHAR( 20),
           @cErrMsg13        NVARCHAR( 20),
           @cErrMsg14        NVARCHAR( 20),
           @cErrMsg15        NVARCHAR( 20)

   -- Parameter mapping
   SET @cOrderKey = ''

   -- Check blank
   IF ISNULL( @cParam1, '') = ''
   BEGIN
      SET @nErrNo = 168701
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --Input required
      GOTO Quit
   END

   SET @cOrderKey = @cParam1
   
   SELECT @cPaperPrinter = Printer_Paper
   FROM rdt.rdtMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Check blank
   IF ISNULL( @cPaperPrinter, '') = ''
   BEGIN
      SET @nErrNo = 168702
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --Printer req
      GOTO Quit
   END
   
   IF NOT EXISTS ( SELECT 1 FROM rdt.rdtReportToPrinter WITH (NOLOCK)
                   WHERE Function_ID = @nFunc
                   AND   StorerKey = @cStorerKey
                   AND   PrinterGroup = @cPaperPrinter)
   -- Check blank
   BEGIN
      SET @nErrNo = 168703
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --PrinterGroup req
      GOTO Quit
   END
   
   SELECT @cSalesman = Salesman 
   FROM dbo.ORDERS WITH (NOLOCK)
   WHERE OrderKey = @cOrderKey
   
   SELECT @cUDF01 = UDF01,
          @cUDF02 = UDF02
   FROM dbo.CODELKUP WITH (NOLOCK)
   WHERE LISTNAME = 'PRTVALID'
   AND   Long = @cSalesman
   AND   Storerkey = @cStorerKey

   -- Check blank
   IF ISNULL( @cUDF01, '') = '' AND ISNULL( @cUDF02, '') = ''
   BEGIN
      SET @nErrNo = 168704
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --ReportType req
      GOTO Quit
   END
   
   IF ISNULL( @cUDF01, '') <> ''
   BEGIN
      SELECT @cPaperPrinter1 = PrinterID
      FROM rdt.rdtReportToPrinter WITH (NOLOCK)
      WHERE Function_ID = @nFunc
      AND   StorerKey = @cStorerKey
      AND   PrinterGroup = @cPaperPrinter
      AND   ReportType = @cUDF01
      
      INSERT INTO @tCR (Variable, Value) VALUES ( '@cOrderkey',     @cOrderkey)  
           
      -- Print label  
      EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 0, 1, '', @cStorerKey, '', @cPaperPrinter1,    
         @cUDF01, -- Report type  
         @tCR, -- Report params  
         'rdt_593Print33',   
         @nErrNo  OUTPUT,  
         @cErrMsg OUTPUT   
               
      IF @nErrNo <> 0
         GOTO Quit
   END

   IF ISNULL( @cUDF02, '') <> ''
   BEGIN
      SELECT @cPaperPrinter2 = PrinterID
      FROM rdt.rdtReportToPrinter WITH (NOLOCK)
      WHERE Function_ID = @nFunc
      AND   StorerKey = @cStorerKey
      AND   PrinterGroup = @cPaperPrinter
      AND   ReportType = @cUDF02
      
      INSERT INTO @tSI (Variable, Value) VALUES ( '@cOrderkey',     @cOrderkey)  
           
      -- Print label  
      EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 0, 1, '', @cStorerKey, '', @cPaperPrinter2,    
         @cUDF02, -- Report type  
         @tSI, -- Report params  
         'rdt_593Print33',   
         @nErrNo  OUTPUT,  
         @cErrMsg OUTPUT   
               
      IF @nErrNo <> 0
         GOTO Quit
   END
Quit:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_593Print33 TO NSQL
GO
