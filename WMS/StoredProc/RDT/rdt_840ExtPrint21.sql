SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO    

/************************************************************************/  
/* Store procedure: rdt_840ExtPrint21                                   */  
/* Purpose: Print carton label                                          */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2022-03-18 1.0  James      WMS-19123. Created                        */  
/************************************************************************/  
  
CREATE OR ALTER PROC [RDT].[rdt_840ExtPrint21] (  
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
           @cShipLabel        NVARCHAR( 10),  
           @cPackList         NVARCHAR( 10)
             
  
   DECLARE @tShipLabel     VariableTable  
   DECLARE @tPackList      VariableTable  
     
   SELECT @cLabelPrinter = Printer,  
          @cPaperPrinter = Printer_Paper
   FROM RDT.RDTMOBREC WITH (NOLOCK)  
   WHERE Mobile = @nMobile  
  
   IF @nInputKey = 1  
   BEGIN  
      IF @nStep = 4  
      BEGIN  
         SET @cShipLabel = rdt.RDTGetConfig( @nFunc, 'SHIPLABEL', @cStorerkey)    
         IF @cShipLabel = '0'    
            SET @cShipLabel = ''    
  
         IF @cShipLabel <> ''  
         BEGIN  
            INSERT INTO @tShipLabel (Variable, Value) VALUES ( '@cPickSlipNo',    @cPickSlipNo)    
            INSERT INTO @tShipLabel (Variable, Value) VALUES ( '@nCartonNoFrom',  @nCartonNo)  
            INSERT INTO @tShipLabel (Variable, Value) VALUES ( '@nCartonNoTo',    @nCartonNo)  
             
            -- Print label    
            EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 0, 1, '', @cStorerKey, @cLabelPrinter, '',     
               @cShipLabel, -- Report type    
               @tShipLabel, -- Report params    
               'rdt_840ExtPrint21',     
               @nErrNo  OUTPUT,    
               @cErrMsg OUTPUT    
         END  

         SET @cPackList = rdt.RDTGetConfig( @nFunc, 'PACKLIST', @cStorerkey)    
         IF @cPackList = '0'    
            SET @cPackList = ''    
  
         IF @cPackList <> ''  
         BEGIN  
            INSERT INTO @tPackList (Variable, Value) VALUES ( '@cPickSlipNo',  @cPickSlipNo)  
             
            -- Print label    
            EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 0, 1, '', @cStorerKey, '', @cPaperPrinter,     
               @cPackList, -- Report type    
               @tPackList, -- Report params    
               'rdt_840ExtPrint21',     
               @nErrNo  OUTPUT,    
               @cErrMsg OUTPUT    
         END  
      END   -- IF @nStep = 4  
   END   -- @nInputKey = 1  
  
Quit:  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_840ExtPrint21 to nSQL
GO