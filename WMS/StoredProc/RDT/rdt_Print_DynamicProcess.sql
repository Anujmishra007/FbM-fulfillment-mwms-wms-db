if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_Print_DynamicProcess]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [RDT].[rdt_Print_DynamicProcess]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
  
/******************************************************************************/  
/* Store procedure: rdt_Print_DynamicProcess                                  */  
/* Copyright      : LF Logistics                                              */  
/*                                                                            */  
/* Date       Rev  Author      Purposes                                       */  
/* 15-08-2021 1.0  YeeKung     WMS-17055 Created                              */  
/******************************************************************************/  
  
CREATE PROC rdt.rdt_Print_DynamicProcess (  
   @nMobile       INT,             
   @nFunc         INT,             
   @cLangCode     NVARCHAR( 3),    
   @nStep         INT,             
   @nInputKey     INT,             
   @cFacility     NVARCHAR( 5),    
   @cStorerKey    NVARCHAR( 15),   
   @cLabelPrinter NVARCHAR( 10),   
   @cPaperPrinter NVARCHAR( 10),   
   @cReportType   NVARCHAR( 10),   
   @tReportParam  VariableTable READONLY,  
   @cValue01      NVARCHAR( 20) OUTPUT,    
   @cValue02      NVARCHAR( 20) OUTPUT,    
   @cValue03      NVARCHAR( 20) OUTPUT,    
   @cValue04      NVARCHAR( 20) OUTPUT,    
   @cValue05      NVARCHAR( 20) OUTPUT,    
   @cValue06      NVARCHAR( 20) OUTPUT,    
   @cValue07      NVARCHAR( 20) OUTPUT,      
   @cValue08      NVARCHAR( 20) OUTPUT,     
   @cValue09      NVARCHAR( 20) OUTPUT,     
   @cValue10      NVARCHAR( 20) OUTPUT,     
   @cPrinter      NVARCHAR( 10) OUTPUT,     
   @cSpoolerGroup NVARCHAR( 20) OUTPUT,     
   @nNoOfCopy     INT           OUTPUT,     
   @nErrNo        INT           OUTPUT,    
   @cErrMsg       NVARCHAR( 20) OUTPUT,   
   @cDataWindow   NVARCHAR( 50) OUTPUT,  
   @cprintcommand NVARCHAR(MAX) OUTPUT,  
   @cProcessType  NVARCHAR(20)  OUTPUT   
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @cParam       NVARCHAR( 30)    
   DECLARE @cParam01     NVARCHAR( 30)    
   DECLARE @cParam02     NVARCHAR( 30)    
   DECLARE @cParam03     NVARCHAR( 30)    
   DECLARE @cParam04     NVARCHAR( 30)    
   DECLARE @cParam05     NVARCHAR( 30)    
   DECLARE @cParam06     NVARCHAR( 30)    
   DECLARE @cParam07     NVARCHAR( 30)    
   DECLARE @cParam08     NVARCHAR( 30)    
   DECLARE @cParam09     NVARCHAR( 30)    
   DECLARE @cParam10     NVARCHAR( 30)   
   DECLARE @i            INT  
   DECLARE @cValue       NVARCHAR( 30)   
   DECLARE @cPrinterGroup  NVARCHAR(20)  
  
   DECLARE @cPlatform NVARCHAR(20),  
           @cPrintTemplateSP NVARCHAR(20),  
           @cOrderkey  NVARCHAR(20),  
           @cTrackingno NVARCHAR(20),  
           @cPrintData NVARCHAR(20),  
           @nRowcount  INT =0  
  
   SELECT @cOrderkey = Value FROM @tReportParam WHERE Variable = '@cOrderkey'   
  
   SELECT @cTrackingno = Value FROM @tReportParam WHERE Variable = '@cTrackingNo'   
  
   SELECT @cPrintData=PrintData  
   FROM dbo.CartonTrack  
   WHERE TrackingNo=@cTrackingno  
  
   SELECT @cPlatform=ECOM_Platform  
   FROM orders(NOLOCK)  
   WHERE orderkey=@cOrderkey  
  
   IF @cPrintData<>''  
   BEGIN  
     -- Get report info    
      SELECT TOP 1       
         @cParam01 = ISNULL( Parm1_Label, ''),     
         @cParam02 = ISNULL( Parm2_Label, ''),     
         @cParam03 = ISNULL( Parm3_Label, ''),     
         @cParam04 = ISNULL( Parm4_Label, ''),     
         @cParam05 = ISNULL( Parm5_Label, ''),     
         @cParam06 = ISNULL( Parm6_Label, ''),     
         @cParam07 = ISNULL( Parm7_Label, ''),     
         @cParam08 = ISNULL( Parm8_Label, ''),     
         @cParam09 = ISNULL( Parm9_Label, ''),     
         @cParam10 = ISNULL( Parm10_Label, ''),  
         @cPrintTemplateSP=printtemplatesp    
      FROM rdt.rdtReportdetail WITH (NOLOCK)    
      WHERE StorerKey = @cStorerKey    
         AND ReportTYpe = @cReportType    
         AND (Function_ID = @nFunc OR Function_ID = 0)  
         AND SUBPlatform=@cPlatform  
         AND (facility=@cFacility OR facility='')   
      ORDER BY Function_ID,facility DESC   
  
      SET @nRowcount=@@ROWCOUNT  
   END  
     
   IF @nRowcount=0  
   BEGIN  
      -- Get report info    
      SELECT TOP 1       
         @cParam01 = ISNULL( Parm1_Label, ''),     
         @cParam02 = ISNULL( Parm2_Label, ''),     
         @cParam03 = ISNULL( Parm3_Label, ''),     
         @cParam04 = ISNULL( Parm4_Label, ''),     
         @cParam05 = ISNULL( Parm5_Label, ''),     
         @cParam06 = ISNULL( Parm6_Label, ''),     
         @cParam07 = ISNULL( Parm7_Label, ''),     
         @cParam08 = ISNULL( Parm8_Label, ''),     
         @cParam09 = ISNULL( Parm9_Label, ''),     
         @cParam10 = ISNULL( Parm10_Label, ''),  
         @cProcessType=SUBPlatform    
      FROM rdt.rdtReportdetail WITH (NOLOCK)    
      WHERE StorerKey = @cStorerKey    
         AND ReportTYpe = @cReportType    
         AND (Function_ID = @nFunc OR Function_ID = 0)  
         AND printtemplate='' AND printtemplatesp=''  
         AND (facility=@cFacility OR facility='')   
      ORDER BY Function_ID,facility DESC   
   END   
  
   SET @i = 1    
   WHILE @i <= 10    
   BEGIN    
      -- Get param    
      IF @i = 1  SET @cParam = @cParam01 ELSE    
      IF @i = 2  SET @cParam = @cParam02 ELSE    
      IF @i = 3  SET @cParam = @cParam03 ELSE    
      IF @i = 4  SET @cParam = @cParam04 ELSE    
      IF @i = 5  SET @cParam = @cParam05 ELSE    
      IF @i = 6  SET @cParam = @cParam06 ELSE    
      IF @i = 7  SET @cParam = @cParam07 ELSE    
      IF @i = 8  SET @cParam = @cParam08 ELSE    
      IF @i = 9  SET @cParam = @cParam09 ELSE    
      IF @i = 10 SET @cParam = @cParam10    
    
      -- Param is setup     
      IF @cParam <> ''    
      BEGIN    
         -- Param is variable    
         IF LEFT( @cParam, 1) = '@'    
         BEGIN    
            -- Get param value    
            SELECT @cValue = Value FROM @tReportParam WHERE Variable = @cParam    
            IF @@ROWCOUNT <> 1    
            BEGIN    
               SET @nErrNo = 110704    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ParamNotMatch    
               GOTO Quit    
            END    
         END    
                
         -- Param is constant    
         ELSE    
            SET @cValue = @cParam    
                   
         -- Set value    
         IF @i = 1  SET @cValue01 = @cValue ELSE    
         IF @i = 2  SET @cValue02 = @cValue ELSE    
         IF @i = 3  SET @cValue03 = @cValue ELSE    
         IF @i = 4  SET @cValue04 = @cValue ELSE    
         IF @i = 5  SET @cValue05 = @cValue ELSE    
         IF @i = 6  SET @cValue06 = @cValue ELSE    
         IF @i = 7  SET @cValue07 = @cValue ELSE    
         IF @i = 8  SET @cValue08 = @cValue ELSE    
         IF @i = 9  SET @cValue09 = @cValue ELSE    
         IF @i = 10 SET @cValue10 = @cValue             
      END    
    
      SET @i = @i + 1    
   END    
  
  
   IF @cPlatform='PDD'  
   BEGIN  
      SET @cProcessType='TPPrint'  
  
      SELECT @cPrinterGroup = PG.PrinterGroup    
      FROM rdt.rdtPrinterGroup PG WITH (NOLOCK)   
      WHERE Printerid = @cPrinter    
  
      SELECT @cPrinter=PrinterID  
      FROM rdt.rdtPrinterGroup (NOLOCK)  
      WHERE printergroup=@cPrinterGroup  
      AND DefaultPrinter='2'  
  
      SET @cPrintCommand= N'EXEC rdt.'+@cPrintTemplateSP          
         + N''''+RTRIM(ISNULL(@nFunc,'')) +''''           
         + N',''' + RTRIM(ISNULL(@cReportType,'')) +''''              
         + N',''' + RTRIM(ISNULL(@cStorerkey,'')) +''''       
         + N',''' + RTRIM(ISNULL(@cPrinter,'')) +''''                           
         + N',''' + RTRIM(ISNULL(@cValue01,'')) +''''  
         + N',''' + RTRIM(ISNULL(@cValue02,'')) +''''  
         + N',''' + RTRIM(ISNULL(@cValue03,'')) +''''      
         + N',''' + RTRIM(ISNULL(@cValue04,'')) +''''         
         + N',''' + RTRIM(ISNULL(@cValue05,'')) +''''        
         + N',''' + RTRIM(ISNULL(@cValue06,'')) +''''        
         + N',''' + RTRIM(ISNULL(@cValue07,'')) +''''         
         + N',''' + RTRIM(ISNULL(@cValue08,'')) +''''        
         + N',''' + RTRIM(ISNULL(@cValue09,'')) +''''        
         + N',''' + RTRIM(ISNULL(@cValue10,'')) +''''  
         + N', @cJOBID'  
         + N',1'  
         + N','''''            
         + N','''''  
   END  
     
Quit:  
  
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_Print_DynamicProcess TO NSQL
GO
