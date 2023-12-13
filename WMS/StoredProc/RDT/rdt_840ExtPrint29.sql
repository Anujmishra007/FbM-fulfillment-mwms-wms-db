SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/  
/* Store procedure: rdt_840ExtPrint29                                   */  
/* Purpose: Print PDF from MarketPlace                                  */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2023-11-06 1.0  James      WMS-23929. Created                        */  
/************************************************************************/  
  
CREATE OR ALTER PROC [RDT].[rdt_840ExtPrint29] (  
   @nMobile     INT,  
   @nFunc       INT,   
   @cLangCode   NVARCHAR( 3),   
   @nStep       INT,   
   @nInputKey   INT,   
   @cStorerkey  NVARCHAR( 15),   
   @cOrderKey   NVARCHAR( 10),   
   @cPickSlipNo NVARCHAR( 10),   
   @cTrackNo    NVARCHAR( 20),   
   @cSKU        NVARCHAR( 20),   
   @nCartonNo   INT,  
   @nErrNo      INT           OUTPUT,   
   @cErrMsg     NVARCHAR( 20) OUTPUT  
)  
AS  
  
   SET NOCOUNT ON     
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF    
  
   DECLARE @cPaperPrinter     NVARCHAR( 10),  
           @cLabelPrinter     NVARCHAR( 10),  
           @cUserName         NVARCHAR( 18),  
           @cFacility         NVARCHAR( 5),  
           @cShippLabel       NVARCHAR( 10),  
           @cPrtInvoice       NVARCHAR( 10),  
           @nExpectedQty      INT = 0,  
           @nPackedQty        INT = 0,  
           @nNoOfCopy         INT = 0,  
           @cNoOfCopy         NVARCHAR( 2),  
           @cShipperKey       NVARCHAR( 15) 

   DECLARE @cFilePrefix       NVARCHAR( 30)    
   DECLARE @cFilePath         NVARCHAR(100)       
   DECLARE @cPrintFilePath    NVARCHAR(100)   
   DECLARE @cReportType       NVARCHAR( 10)
   DECLARE @cPrintCommand     NVARCHAR(MAX)    
   DECLARE @cExternOrderKey   NVARCHAR(50)
   DECLARE @cFileName         NVARCHAR( 50)  
   DECLARE @cWinPrinterName   NVARCHAR(100)  
   DECLARE @cWinPrinter       NVARCHAR(128)  
   DECLARE @cPrinterName      NVARCHAR(100) 
   DECLARE @cPDFPrinter       NVARCHAR(100)
   DECLARE @cUserDefine05     NVARCHAR( 40)
   DECLARE @cPrinterSettngID  NVARCHAR( 60)
   
   DECLARE @tShippLabel    VariableTable  
   DECLARE @tPrtInvoice    VariableTable  
     
   SELECT @cLabelPrinter = Printer,  
          @cPaperPrinter = Printer_Paper,  
          @cFacility = Facility,  
          @cUserName = UserName  
   FROM RDT.RDTMOBREC WITH (NOLOCK)  
   WHERE Mobile = @nMobile  
  
   IF @nInputKey = 1  
   BEGIN  
      IF @nStep = 3  
      BEGIN  
         SELECT @nExpectedQty = ISNULL(SUM(Qty), 0) FROM PickDetail WITH (NOLOCK)  
         WHERE Orderkey = @cOrderkey  
            AND Storerkey = @cStorerkey  
            AND Status < '9'  
  
         SELECT @nPackedQty = ISNULL(SUM(Qty), 0) FROM dbo.PackDetail WITH (NOLOCK)  
         WHERE PickSlipNo = @cPickSlipNo  
  
         IF @nExpectedQty > @nPackedQty  
            GOTO Quit  
  
         IF EXISTS ( SELECT 1 FROM dbo.Orders O WITH (NOLOCK) 
                     JOIN dbo.OrderInfo OI WITH (NOLOCK) ON ( O.OrderKey = OI.OrderKey)
                     JOIN dbo.Codelkup CL WITH (NOLOCK) ON ( CL.StorerKey = O.StorerKey AND RTRIM(CL.Code) = RTRIM(OI.Platform))   
					      WHERE O.StorerKey = @cStorerKey
                     AND   O.OrderKey = @cOrderKey 
                     AND   CL.ListName = 'PLATFLKUP') 
         BEGIN 
            SELECT 
               @cExternOrderKey = O.ExternOrderKey,          
               @cUserDefine05 = O.TrackingNo,
               @cPrinterSettngID = RTRIM(CL.UDF05)        
            FROM dbo.Orders O WITH (NOLOCK)  
            JOIN dbo.OrderInfo OI WITH (NOLOCK) ON ( O.OrderKey = OI.OrderKey)         
            JOIN dbo.Codelkup CL WITH (NOLOCK) ON ( CL.StorerKey = O.StorerKey AND RTRIM(CL.Code) = RTRIM(OI.Platform))
            WHERE O.StorerKey = @cStorerKey          
            AND   O.OrderKey = @cOrderKey          
            AND   CL.ListName = 'PLATFLKUP'
   
            -- Print PDF Process for Market Place Order
            SELECT @cFilePath = Long, 
                   @cPrintFilePath = Notes, 
                   @cReportType = Code2, 
                   @cFilePrefix = UDF01
            FROM dbo.CODELKUP WITH (NOLOCK)      
            WHERE LISTNAME = 'PrtbyShipK'      
            AND   StorerKey = @cStorerKey
            AND   Code2 = 'PDFSHIPLBL'
            
            --WMSLBL_VN_0000031343_CD_LZ_AVN0000369_ sample file name
            SET @cWinPrinter = ''
            SET @cPrinterName = ''
            SET @cWinPrinterName = ''
            SET @cPDFPrinter = ''
            SET @cPDFPrinter = @cLabelPrinter+'-'
            
            SELECT @cWinPrinter = WinPrinter
            FROM rdt.rdtPrinter WITH (NOLOCK)  
            WHERE PrinterID = @cPDFPrinter
         
            SET @cPrinterName = LEFT( @cWinPrinter , (CHARINDEX(',' , @cWinPrinter) - 1) )    
            SET @cWinPrinterName = @cPrinterName
            
            DECLARE @tRDTPrintJob AS VariableTable
            
            SET @cFilePrefix = @cFilePrefix + CASE WHEN ISNULL( @cFilePrefix, '') <> '' THEN '_' ELSE '' END
            SET @cFileName = @cFilePrefix + RTRIM(@cExternOrderKey) + '_' + @cUserDefine05 + '.pdf'     
            SET @cPrintCommand = '"' + @cPrintFilePath + '" "' + @cFilePath + '\' + @cFileName + '" "' + @cPrinterSettngID + '" "2" "' + @cWinPrinterName + '"'
            --SET @cPrintCommand = '"' + @cPrintFilePath + '" "' + @cFilePath + '\' + @cFileName + '" "50" "3" "' + @cWinPrinterName + '"'                              
            
            EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 0, 1, '', @cStorerKey, @cPDFPrinter, '',
               @cReportType,     -- Report type
               @tRDTPrintJob,    -- Report params
               'rdt_840ExtPrint29', 
               @nErrNo  OUTPUT,
               @cErrMsg OUTPUT,
               1,
               @cPrintCommand
         END
         ELSE
         BEGIN
            SET @cShippLabel = rdt.RDTGetConfig( @nFunc, 'SHIPPLABEL', @cStorerkey)    
            IF @cShippLabel = '0'    
               SET @cShippLabel = ''    
     
            IF @cShippLabel <> ''  
            BEGIN  
               SELECT @cShipperKey = ShipperKey  
               FROM dbo.ORDERS WITH (NOLOCK)  
               WHERE OrderKey = @cOrderKey  
                 
               SELECT @cNoOfCopy = Short  
               FROM dbo.CODELKUP WITH (NOLOCK)  
               WHERE LISTNAME = 'SHIPMETHOD'  
               AND   Code = @cShipperKey  
               AND   Storerkey = @cStorerkey  
                 
               -- If no setup, default print copy to 1 (james01)  
               IF ISNULL( @cNoOfCopy, '') = '' OR @cNoOfCopy = '0' OR rdt.rdtIsValidQTY( @cNoOfCopy, 0) = 0  
                  SET @nNoOfCopy = 1  
               ELSE  
                  SET @nNoOfCopy = CAST( @cNoOfCopy AS INT)  
                    
               INSERT INTO @tShippLabel (Variable, Value) VALUES ( '@cOrderkey',     @cOrderkey)    
                 
               WHILE @nNoOfCopy > 0  
               BEGIN  
                  -- Print label    
                  EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 0, 1, '', @cStorerKey, @cLabelPrinter, '',     
                     @cShippLabel, -- Report type    
                     @tShippLabel, -- Report params    
                     'rdt_840ExtPrint29',     
                     @nErrNo  OUTPUT,    
                     @cErrMsg OUTPUT  
                    
                  SET @nNoOfCopy = @nNoOfCopy - 1  
               END    
            END  
     
            SET @cPrtInvoice = rdt.RDTGetConfig( @nFunc, 'PrtInvoice', @cStorerkey)    
            IF @cPrtInvoice = '0'    
               SET @cPrtInvoice = ''    
     
            IF @cPrtInvoice <> ''  
            BEGIN  
               INSERT INTO @tPrtInvoice (Variable, Value) VALUES ( '@cOrderkey',     @cOrderkey)    
                
               -- Print label    
               EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 0, 1, '', @cStorerKey, '', @cPaperPrinter,    
                  @cPrtInvoice, -- Report type    
                  @tPrtInvoice, -- Report params    
                  'rdt_840ExtPrint29',     
                  @nErrNo  OUTPUT,    
                  @cErrMsg OUTPUT    
            END  
         END
      END   -- IF @nStep = 4  
   END   -- @nInputKey = 1  
  
Quit:  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_840ExtPrint29 TO NSQL
GO