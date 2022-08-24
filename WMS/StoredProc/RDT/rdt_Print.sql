
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  
/******************************************************************************/                
/* Store procedure: rdt_Print                                                 */                
/* Copyright      : LF Logistics                                              */                
/*                                                                            */                
/* Date       Rev  Author      Purposes                                       */                
/* 30-05-2017 1.0  Ung         WMS-1919 Created                               */                
/* 25-10-2017 1.1  SWT01       Include IP when insert into TCP Q Task         */                
/*                             TransmitlogKey = JobID                         */                
/* 08-05-2018 1.2  Ung         WMS-4248 Migrate print command to QCommander   */                
/* 25-04-2018 1.3  Ung         WMS-4675 Use BarTender NoOfCopy                */                
/* 14-08-2018 1.4  Ung         Add TCPSocket_OutLog.MessageNum                */                
/*                             Update TCPSocket_QueueTask.Status = X          */                
/*                             Expand param value to 30 chars                 */                
/* 25-10-2018 1.5  Ung         Call isp_QCmd_UpdateQueueTaskStatus to update  */                
/*                             TCPSocket_QueueTask.Status = X                 */                
/* 30-10-2018 1.6  James       Add function id when insert printjob (james01) */                
/* 05-11-2018 1.7  James       Add to rdtprintjob_log (james02)               */                
/* 07-01-2019 1.8  Ung         Add TCPSpooler                                 */                
/* 11-02-2019 1.9  ChewKP      WMS-4692 Add new ProcessType 'BARTENDERPRTSEQ' */              
/*                             (ChewKP01)                                     */              
/* 19-06-2019 2.0  Ung         WMS-9050 Add data window to custom map         */              
/* 10-08-2021 2.1  YeeKung     WMS-17055 Add printcommand in processtype      */              
/*                             (yeekung01)                                    */          
/* 23-08-2021 2.2  YeeKung     WMS-17797 Modified new feature                 */     
/* 15-11-2021 2.3  YeeKung     WMS-18126 Add UPS support (yeekung03)          */              
/* 12-07-2022 2.4  James       WMS-20111 Add ExportFileName (james03)         */
/******************************************************************************/                
                
CREATE OR ALTER PROC rdt.rdt_Print (                
    @nMobile       INT                
   ,@nFunc         INT                
   ,@cLangCode     NVARCHAR( 3)                
   ,@nStep         INT                
   ,@nInputKey     INT                
   ,@cFacility     NVARCHAR( 5)                
   ,@cStorerKey    NVARCHAR( 15)                
   ,@cLabelPrinter NVARCHAR( 10)                
   ,@cPaperPrinter NVARCHAR( 10)                
   ,@cReportType   NVARCHAR( 10)                
   ,@tReportParam  VariableTable READONLY                
   ,@cSourceType   NVARCHAR( 50)                
   ,@nErrNo        INT           OUTPUT                
   ,@cErrMsg       NVARCHAR(250) OUTPUT                
   ,@nNoOfCopy     INT = NULL                
   ,@cPrintCommand NVARCHAR(MAX) = ''                
   ,@cExportFileName NVARCHAR( 50) = ''
)                
AS                
BEGIN                
   SET NOCOUNT ON                
   SET QUOTED_IDENTIFIER OFF                
   SET ANSI_NULLS OFF                
   SET CONCAT_NULL_YIELDS_NULL OFF                
                
   DECLARE @i              INT                
   DECLARE @nDefNoOfCopy   INT                
   DECLARE @cPrinter       NVARCHAR( 10)                
   DECLARE @cDataWindow    NVARCHAR( 50)                
   DECLARE @cTargetDB      NVARCHAR( 20)                
   DECLARE @cJobType       NVARCHAR( 10)                
   DECLARE @cJobStatus     NVARCHAR( 1)                
   DECLARE @cPaperType     NVARCHAR( 10)                
   DECLARE @cProcessType   NVARCHAR( 15)                
   DECLARE @cProcessSP     NVARCHAR( 50)                
   DECLARE @cTemplate      NVARCHAR( MAX)                
   DECLARE @cTemplateSP    NVARCHAR( 80)                
   DECLARE @cPrintData     NVARCHAR( MAX)                
   DECLARE @cSpoolerGroup  NVARCHAR( 20)                
   DECLARE @cIPAddress     NVARCHAR( 40)                
   DECLARE @cPortNo        NVARCHAR( 5)                
   DECLARE @cDataReceived  NVARCHAR( 4000)                
   DECLARE @cJobID         NVARCHAR( 10)              
   DECLARE @nJobID         INT                
   DECLARE @cIniFilePath    NVARCHAR( 200)                
   DECLARE @bSuccess       INT                
   DECLARE @cUserName NVARCHAR( 18)             
   DECLARE @c_PrintMethod  NVARCHAR( 18)        --(yeekung03)    
                   
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
                                         
   DECLARE @cValue       NVARCHAR( 30)                
   DECLARE @cValue01     NVARCHAR( 30)                
   DECLARE @cValue02     NVARCHAR( 30)                
   DECLARE @cValue03     NVARCHAR( 30)                
   DECLARE @cValue04     NVARCHAR( 30)                
   DECLARE @cValue05     NVARCHAR( 30)                
   DECLARE @cValue06     NVARCHAR( 30)                
   DECLARE @cValue07     NVARCHAR( 30)                
   DECLARE @cValue08     NVARCHAR( 30)                
   DECLARE @cValue09     NVARCHAR( 30)                
   DECLARE @cValue10     NVARCHAR( 30)                
          ,@cStartRec          NVARCHAR(5)                           
          ,@cEndRec            NVARCHAR(5)                           
          ,@cFromSourceModule  NVARCHAR(250)                 
          ,@cQCmdSubmitFlag    CHAR(1)                  
                        
   DECLARE @cDBName         NVARCHAR( 30)                
   DECLARE @cSpoolerCommand NVARCHAR( 1024)                
   DECLARE @cCommand        NVARCHAR( 1024)                
   DECLARE @nQueueID        BIGINT                   
   DECLARE @c_ContinueNextPrint NVARCHAR(1)                
            
   SET @cValue = ''                
   SET @cValue01 = ''                
   SET @cValue02 = ''                
   SET @cValue03 = ''                
   SET @cValue04 = ''                
   SET @cValue05 = ''                
   SET @cValue06 = ''                
   SET @cValue07 = ''                
   SET @cValue08 = ''                
   SET @cValue09 = ''                
   SET @cValue10 = ''                
                   
   SET @nErrNo = 0                
   SET @cJobType = ''                
   SET @cJobStatus = '0'                
   SET @cPrintData = ''                
                   
   -- Get report info                
   SELECT TOP 1                
      @cDataWindow = DataWindow,                 
      @cTargetDB = TargetDB,                 
      @cPaperType = PaperType,                 
      @cProcessType = ProcessType,                 
      @cProcessSP = ProcessSP,                 
      @nDefNoOfCopy = NoOfCopy,                 
      @cTemplate = ISNULL( PrintTemplate, ''),                
      @cTemplateSP = ISNULL( PrintTemplateSP, ''),                 
      @cParam01 = ISNULL( Parm1_Label, ''),                 
      @cParam02 = ISNULL( Parm2_Label, ''),                 
      @cParam03 = ISNULL( Parm3_Label, ''),                 
      @cParam04 = ISNULL( Parm4_Label, ''),                 
      @cParam05 = ISNULL( Parm5_Label, ''),                 
      @cParam06 = ISNULL( Parm6_Label, ''),                 
      @cParam07 = ISNULL( Parm7_Label, ''),                 
      @cParam08 = ISNULL( Parm8_Label, ''),                 
      @cParam09 = ISNULL( Parm9_Label, ''),                 
      @cParam10 = ISNULL( Parm10_Label, '')                
   FROM rdt.rdtReport WITH (NOLOCK)                
   WHERE StorerKey = @cStorerKey                
      AND ReportTYpe = @cReportType                
      AND (Function_ID = @nFunc OR Function_ID = 0)                
   ORDER BY Function_ID DESC                
                
   -- Check report                
   IF @@ROWCOUNT = 0                
   BEGIN                
      SET @nErrNo = 110701                
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ReportNotSetup                
      GOTO Quit                
   END                
                
   IF @nNoOfCopy IS NULL                
      SET @nNoOfCopy = @nDefNoOfCopy                
                
   -- Check login printer                
   IF @cPaperType = 'LABEL'                 
   BEGIN                
      IF @cLabelPrinter = ''                
      BEGIN                
         SET @nErrNo = 110702                
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoLabelPrinter                
         GOTO Quit                
      END                
      SET @cPrinter = @cLabelPrinter                
   END                
   ELSE                
   BEGIN                
      IF @cPaperPrinter = ''                
      BEGIN                
         SET @nErrNo = 110703                
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoPaperPrinter                
         GOTO Quit                
      END                
      SET @cPrinter = @cPaperPrinter                
   END                
                
   -- Check if printer is a group                
   IF EXISTS( SELECT TOP 1 1 FROM rdt.rdtPrinterGroup WITH (NOLOCK) WHERE PrinterGroup = @cPrinter)                
   BEGIN                
      DECLARE @cPrinterInGroup NVARCHAR(10)                
      SET @cPrinterInGroup = ''                
                
      -- Check if report print to a specific printer in group                
      SELECT @cPrinterInGroup = PrinterID                
      FROM rdt.rdtReportToPrinter WITH (NOLOCK)                
      WHERE Function_ID = @nFunc                
         AND StorerKey = @cStorerKey                
         AND ReportType = @cReportType                
         AND PrinterGroup = @cPrinter                
                   
      IF @cPrinterInGroup = ''                
      BEGIN                
         -- Get default printer in the group                
         SELECT @cPrinterInGroup = PrinterID                
         FROM rdt.rdtPrinterGroup WITH (NOLOCK)                
         WHERE PrinterGroup = @cPrinter                
            AND DefaultPrinter = 1                
                
         -- Check no default printer                
         IF @cPrinterInGroup = ''                
         BEGIN                
            SET @nErrNo = 110714                
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoDefPrnInGRP                
            GOTO Quit                
         END                
      END                
                
      SET @cPrinter = @cPrinterInGroup                
   END                
                
   -- Get printer info                
   SELECT                
      @cSpoolerGroup = SpoolerGroup                
   FROM rdt.rdtPrinter WITH (NOLOCK)                
   WHERE PrinterID = @cPrinter                
                
   -- Check printer                
   IF @@ROWCOUNT = 0                
   BEGIN                
      SET @nErrNo = 110706                
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PrinterNoSetup                
      GOTO Quit                
   END                
                
   -- Standard mapping process         
   IF @cProcessSP = ''                
   BEGIN                
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
   END                
                
   -- Custom mapping process                
   ELSE IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cProcessSP AND type = 'P')                
   BEGIN                
      DECLARE @cSQL NVARCHAR(MAX)                
      DECLARE @cSQLParam NVARCHAR(MAX)                
                
      SET @cSQL = 'EXEC rdt.' + RTRIM( @cProcessSP) +                
         ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter, @cReportType, @tReportParam, ' +                 
         ' @cValue01 OUTPUT, @cValue02 OUTPUT, @cValue03 OUTPUT, @cValue04 OUTPUT, @cValue05 OUTPUT, ' +                 
         ' @cValue06 OUTPUT, @cValue07 OUTPUT, @cValue08 OUTPUT, @cValue09 OUTPUT, @cValue10 OUTPUT, ' +                 
         ' @cPrinter OUTPUT, @cSpoolerGroup OUTPUT, @nNoOfCopy OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cDataWindow OUTPUT,' +               
         ' @cPrintCommand OUTPUT,@cProcessType OUTPUT,@c_PrintMethod OUTPUT'              
      SET @cSQLParam =                
         '@nMobile       INT,           ' +                
         '@nFunc         INT,           ' +                
         '@cLangCode     NVARCHAR( 3),  ' +                
         '@nStep         INT,           ' +                
         '@nInputKey     INT,           ' +                
         '@cFacility     NVARCHAR( 5),  ' +                 
         '@cStorerKey    NVARCHAR( 15), ' +                
         '@cLabelPrinter NVARCHAR( 10), ' +                 
         '@cPaperPrinter NVARCHAR( 10), ' +                 
         '@cReportType   NVARCHAR( 10), ' +                 
         '@tReportParam  VariableTable READONLY, ' +                
         '@cValue01      NVARCHAR( 30) OUTPUT,   ' +                
         '@cValue02      NVARCHAR( 30) OUTPUT,   ' +                
         '@cValue03      NVARCHAR( 30) OUTPUT,   ' +                
         '@cValue04      NVARCHAR( 30) OUTPUT,   ' +                
         '@cValue05      NVARCHAR( 30) OUTPUT,   ' +                
         '@cValue06      NVARCHAR( 30) OUTPUT,   ' +                
         '@cValue07      NVARCHAR( 30) OUTPUT,   ' +                  
         '@cValue08      NVARCHAR( 30) OUTPUT,   ' +                 
         '@cValue09      NVARCHAR( 30) OUTPUT,   ' +                 
         '@cValue10      NVARCHAR( 30) OUTPUT,   ' +                 
         '@cPrinter      NVARCHAR( 10) OUTPUT,   ' +                 
         '@cSpoolerGroup NVARCHAR( 20) OUTPUT,   ' +                 
         '@nNoOfCopy     INT           OUTPUT,   ' +                 
         '@nErrNo        INT           OUTPUT,   ' +                
         '@cErrMsg       NVARCHAR( 20) OUTPUT,   ' +               
         '@cDataWindow   NVARCHAR( 50) OUTPUT,   ' +              
         '@cPrintCommand NVARCHAR( MAX) OUTPUT,  ' +              
         '@cProcessType  NVARCHAR( 20) OUTPUT,   '  +         
         '@c_PrintMethod      NVARCHAR( 18) OUTPUT    '       
                
      EXEC sp_ExecuteSQL @cSQL, @cSQLParam,                
         @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter, @cReportType, @tReportParam,                
         @cValue01 OUTPUT, @cValue02  OUTPUT, @cValue03 OUTPUT, @cValue04 OUTPUT, @cValue05 OUTPUT,                 
         @cValue06 OUTPUT, @cValue07  OUTPUT, @cValue08 OUTPUT, @cValue09 OUTPUT, @cValue10 OUTPUT,                  
         @cPrinter OUTPUT, @cSpoolerGroup OUTPUT, @nNoOfCopy OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cDataWindow OUTPUT,           
         @cPrintCommand OUTPUT,@cProcessType OUTPUT, @c_PrintMethod OUTPUT         
              
                         
      IF @nErrNo <> 0                
         GOTO Quit                
   END                
   ELSE                
   BEGIN                
      SET @nErrNo = 110705                
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Bad ProcessSP                
      GOTO Quit                
   END                
                
   -- QCommander                
   IF @cProcessType = 'QCOMMANDER'                
   BEGIN                
                  
      -- Get spooler info                
      SELECT                 
         @cIPAddress = IPAddress,                 
         @cPortNo = PortNo,                 
         @cSpoolerCommand = Command,                 
         @cIniFilePath = IniFilePath           
      FROM rdt.rdtSpooler WITH (NOLOCK)                
      WHERE SpoolerGroup = @cSpoolerGroup                
                      
      -- Check valid                
      IF @@ROWCOUNT = 0 OR @cIPAddress = '' OR @cPortNo = ''                
      BEGIN                
         SET @nErrNo = 110707                
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SpoolNot Setup                
         GOTO Quit                
      END                
                      
      SET @cDBName = DB_NAME()                
      SET @cJobType = 'QCOMMANDER'                
                
      IF @cPrintCommand <> ''                
         SET @cJobStatus = '9'                
                
      SET @i = 0                
      WHILE @i < @nNoOfCopy                
      BEGIN                
         -- Insert print job                
         INSERT INTO rdt.rdtPrintJob (                
            JobName, ReportID, JobStatus, Datawindow, NoOfParms, Printer, NoOfCopy, Mobile, TargetDB, PrintData, JobType, StorerKey,                 
            Parm1, Parm2, Parm3, Parm4, Parm5, Parm6, Parm7, Parm8, Parm9, Parm10, Function_ID, ExportFileName)                
         VALUES(                
            @cSourceType, @cReportType, @cJobStatus, @cDataWindow, 0, @cPrinter, 1, @nMobile, DB_NAME(), @cPrintCommand, @cJobType, @cStorerKey,                 
            @cValue01, @cValue02, @cValue03, @cValue04, @cValue05, @cValue06, @cValue07, @cValue08, @cValue09, @cValue10, @nFunc, @cExportFileName)                
         SELECT @nJobID = SCOPE_IDENTITY(), @nErrNo = @@ERROR                
         IF @nErrNo <> 0                
         BEGIN                
            SET @nErrNo = 110708                
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PrnJobFail                
         END                
                
         SET @cJobID = CAST( @nJobID AS NVARCHAR( 10))                
         IF @cPrintCommand <> ''                
            SET @cCommand = @cPrintCommand                
         ELSE                
            SET @cCommand = @cSpoolerCommand + ' ' + @cJobID                
              
                   
         -- Insert task (SWT01)                   
         INSERT INTO TCPSocket_QueueTask (CmdType, Cmd, StorerKey, Port, TargetDB, IP, TransmitLogKey, DataStream)                           
         VALUES ('CMD', @cCommand, @cStorerKey, @cPortNo, DB_NAME(), @cIPAddress, @cJobID, 'QSPOOLER')                
         SELECT @nQueueID = SCOPE_IDENTITY(), @nErrNo = @@ERROR                
         IF @nErrNo <> 0                
         BEGIN                
            SET @nErrNo = 110709                
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS QTask Fail       
            GOTO Quit                
         END                
                   
         -- <STX>CMD|855377|CNWMS|D:\RDTSpooler\rdtprint.exe 2668351<ETX>                
         SET @cPrintData =                 
            '<STX>' +                 
               'CMD|' +                 
               CAST( @nQueueID AS NVARCHAR( 20)) + '|' +                 
               DB_NAME() + '|' +                 
               @cCommand +                 
            '<ETX>'                
              
         -- Call Qcommander                
         EXEC isp_QCmd_SendTCPSocketMsg                
            @cApplication  = 'QCommander',                
            @cStorerKey    = @cStorerKey,                 
            @cMessageNum   = @cJobID,                
            @cData         = @cPrintData,                
            @cIP           = @cIPAddress,                 
            @cPORT        = @cPortNo,                 
            @cIniFilePath  = @cIniFilePath,                 
            @cDataReceived = @cDataReceived OUTPUT,                
            @bSuccess      = @bSuccess      OUTPUT,                 
            @nErr          = @nErrNo        OUTPUT,                 
            @cErrMsg       = @cErrMsg       OUTPUT                
         IF @nErrNo <> 0                
         BEGIN                
            /*                
            UPDATE TCPSocket_QueueTask SET                
               Status = 'X',                 
               ErrMsg = @cErrMsg,                 
             EditWho = SUSER_SNAME(),                 
               EditDate = GETDATE()                
            WHERE ID = @nQueueID                
            */                
            EXEC dbo.isp_QCmd_UpdateQueueTaskStatus                
               @cTargetDB    = @cDBName,                
               @nQTaskID     = @nQueueID,                 
               @cQStatus     = 'X',                
               @cThreadID    = '',                
               @cMsgRecvDate = '',                
               @cQErrMsg     = ''                
               -- @bSuccess     = @bSuccess OUTPUT,                 
               -- @nErr         = @nErrNo   OUTPUT,                 
               -- @cErrMsg      = @cErrMsg  OUTPUT                
            IF @@ERROR <> 0                
            BEGIN                
               SET @nErrNo = 110716                
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD QTask Fail                
            END                
                            
            UPDATE rdt.rdtPrintJob SET                
               JobStatus = 'E',                 
               EditDate = GETDATE(),                 
               EditWho = SUSER_SNAME()                
            WHERE JobID = @nJobID                
            IF @@ERROR <> 0                
            BEGIN                
               SET @nErrNo = 110717                
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PrnJobFail     
            END                
                            
            GOTO Quit                   
         END                
                      
         SET @i = @i + 1                
      END                
   END                
                
   -- TCPSpooler                
   ELSE IF @cProcessType = 'TCPSPOOLER'                
   BEGIN                
      -- Get spooler info                
      SELECT                 
         @cIPAddress = IPAddress,                 
         @cPortNo = PortNo,                 
         @cIniFilePath = IniFilePath                
      FROM rdt.rdtSpooler WITH (NOLOCK)                
      WHERE SpoolerGroup = @cSpoolerGroup                
                      
      -- Check valid                
      IF @@ROWCOUNT = 0 OR @cIPAddress = '' OR @cPortNo = ''                
      BEGIN                
         SET @nErrNo = 110718                
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SpoolNot Setup                
         GOTO Quit                
      END                
                      
      SET @cJobType = 'TCPSPOOLER'                
                
      SET @i = 0                
      WHILE @i < @nNoOfCopy                
      BEGIN                
         -- Insert print job                
         INSERT INTO rdt.rdtPrintJob (                
            JobName, ReportID, JobStatus, Datawindow, NoOfParms, Printer, NoOfCopy, Mobile, TargetDB, PrintData, JobType, StorerKey,                 
            Parm1, Parm2, Parm3, Parm4, Parm5, Parm6, Parm7, Parm8, Parm9, Parm10, Function_ID, ExportFileName)                
         VALUES(                
            @cSourceType, @cReportType, @cJobStatus, @cDataWindow, 0, @cPrinter, 1, @nMobile, DB_NAME(), @cPrintCommand, @cJobType, @cStorerKey,                 
            @cValue01, @cValue02, @cValue03, @cValue04, @cValue05, @cValue06, @cValue07, @cValue08, @cValue09, @cValue10, @nFunc, @cExportFileName)                
         SELECT @nJobID = SCOPE_IDENTITY(), @nErrNo = @@ERROR                
         IF @nErrNo <> 0                
         BEGIN                
            SET @nErrNo = 110719                
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PrnJobFail                
         END                
                
         SET @cJobID = CAST( @nJobID AS NVARCHAR( 10))                
                   
       -- Send TCP socket message                
         EXEC isp_QCmd_SendTCPSocketMsg                
            @cApplication  = 'TCPSPOOLER',                
            @cStorerKey    = @cStorerKey,                 
            @cMessageNum   = @cJobID,                
            @cData         = @cJobID,                
            @cIP           = @cIPAddress,                 
            @cPORT         = @cPortNo,                 
            @cIniFilePath  = @cIniFilePath,                 
            @cDataReceived = @cDataReceived OUTPUT,                
            @bSuccess      = @bSuccess      OUTPUT,                 
            @nErr          = @nErrNo        OUTPUT,               
            @cErrMsg       = @cErrMsg       OUTPUT                
         IF @nErrNo <> 0                
         BEGIN                
            UPDATE rdt.rdtPrintJob SET                
               JobStatus = 'E',                 
               EditDate = GETDATE(),                 
               EditWho = SUSER_SNAME()                
            WHERE JobID = @nJobID                
            IF @@ERROR <> 0                
            BEGIN                
               SET @nErrNo = 110720                
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PrnJobFail                
            END                
                            
            GOTO Quit                   
         END                
                      
         SET @i = @i + 1                
      END                
   END                
                   
   -- Bartender                
   ELSE IF @cProcessType IN (  'BARTENDER' ,'BARTENDERPRTSEQ' )  -- (ChewKP01)                
   BEGIN                
      SET @cUserName = LEFT( SUSER_SNAME(), 18)                
               
      SET @cStartRec = ''              
      SET @cEndRec = ''                                  
      SET @cFromSourceModule = ''               
                    
      IF @cProcessType = 'BARTENDER'              
         SET @cQCmdSubmitFlag  = '1'               
      ELSE IF @cProcessType = 'BARTENDERPRTSEQ'              
         SET @cQCmdSubmitFlag  = '0'               
                      
      SET @cJobType = 'BARTENDER'                
      SET @cJobStatus = '9'                
                      
      -- Insert print job                
      INSERT INTO rdt.rdtPrintJob (                
         JobName, ReportID, JobStatus, Datawindow, NoOfParms, Printer, NoOfCopy, Mobile, TargetDB, PrintData, JobType, StorerKey,                 
         Parm1, Parm2, Parm3, Parm4, Parm5, Parm6, Parm7, Parm8, Parm9, Parm10, Function_ID, ExportFileName)                
      VALUES(                
         @cSourceType, @cReportType, @cJobStatus, ISNULL( @cDataWindow, ''), 0, @cPrinter, @nNoOfCopy, @nMobile, DB_NAME(), @cPrintData, @cJobType, @cStorerKey,                 
         @cValue01, @cValue02, @cValue03, @cValue04, @cValue05, @cValue06, @cValue07, @cValue08, @cValue09, @cValue10, @nFunc, @cExportFileName)                
                
      SELECT @nJobID = SCOPE_IDENTITY()                
                
      IF @@ERROR <> 0                
      BEGIN                
         SET @nErrNo = 110715                
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PrnJobFail                
      END                
                      
      -- Call bartender                
      EXECUTE dbo.isp_BT_GenBartenderCommand                
         @cPrinter,     -- printer id                
         @cReportType,  -- label type                
         @cUserName,    -- user id                
         @cValue01,     -- parm01                
         @cValue02,     -- parm02                
         @cValue03,     -- parm03                
         @cValue04,     -- parm04                
         @cValue05,     -- parm05                
         @cValue06,     -- parm06                
         @cValue07,     -- parm07                
         @cValue08,     -- parm08                
         @cValue09,     -- parm09                
         @cValue10,     -- parm10                
         @cStorerKey,   -- StorerKey                
         @nNoOfCopy,    -- no of copy                
         0,             -- debug                
         'N',           -- return result                
         @nErrNo        OUTPUT,                
         @cErrMsg       OUTPUT,              
         @cStartRec,                                  
         @cEndRec,                                   
         @cFromSourceModule,                 
         @cQCmdSubmitFlag                
                       
      IF @nErrNo <> 0                
      BEGIN                
         SET @nErrNo = 110710                
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --BarTender Fail                
         GOTO Quit                
      END                
   END                      
              
   ELSE IF @cProcessType = 'TPPrint'  --(yeekung01)              
   BEGIN              
      DECLARE @b_success INT            
            
      SELECT @cUserName=UserName            
      FROM rdt.RDTMOBREC (NOLOCK)            
      WHERE mobile=@nMobile            
            
      EXEC [dbo].[isp_TPP_PrintToTPServer]                   
            @c_Module            = 'RDT', --PACKING, EPACKING                    
            @c_ReportType        = @cReportType, --UCCLABEL,                    
            @c_Storerkey         = @cStorerKey, --Optional, if empty get from pickslip or rdtuser                    
            @c_Facility          = @cFacility,  --Optional, if empty get from pickslip or rdtuser                    
            @c_UserName          = @cUserName, --optional, if empty get from current db user                    
            @c_PrinterID         = @cLabelPrinter, --optional                    
            @c_IsPaperPrinter    = 'N', --optional Y/N                    
            @c_KeyFieldName      = @cValue10,                  
            @c_Parm01            = @cValue01,                  
            @c_Parm02            = @cValue02,  --e.g. from carton no                    
            @c_Parm03            ='',  --e.g. to carton no                    
            @c_Parm04            ='',                    
            @c_Parm05            ='',                    
            @c_Parm06            ='',                    
            @c_Parm07            ='',                    
            @c_Parm08            ='',                    
            @c_Parm09            ='',                    
            @c_Parm10            ='',                    
            @c_SourceType        = @nFunc, --print from which function           
            @c_PrintMethod       = @c_PrintMethod,             
            @c_ContinueNextPrint = @c_ContinueNextPrint OUTPUT, -- Y=Continue next print N=Not continue next print mode like Bartender, Logireport, PDF and Datawindow                    
            @b_success           = @b_success OUTPUT,                    
            @n_err               = @nErrNo OUTPUT,                    
            @c_errmsg            = @cErrMsg OUTPUT               
                        
      GOTO quit             
   END              
   -- Direct print                
   ELSE IF @cTemplate <> '' AND @cTemplateSP <> ''                
   BEGIN                
      -- Execute SP to merge data and template, output print data as ZPL code                
      SET @cSQL = 'EXEC ' + RTRIM( @cTemplateSP) +                
         ' @nMobile, @nFunc, @cLangCode, @cStorerKey, ' +                 
         ' @cValue01, @cValue02, @cValue03, @cValue04, @cValue05, @cValue06, @cValue07, @cValue08, @cValue09, @cValue10, ' +                
         ' @cTemplate, @cPrintData OUTPUT, @nErrNo OUTPUT, @cErrMSG OUTPUT '                
                
      SET @cSQLParam =                
         '@nMobile      INT,            ' +                
         '@nFunc        INT,            ' +                
         '@cLangCode    NVARCHAR( 3),   ' +                
         '@cStorerKey   NVARCHAR( 15),  ' +                
         '@cValue01     NVARCHAR( 20),  ' +                
         '@cValue02     NVARCHAR( 20),  ' +                
         '@cValue03     NVARCHAR( 20),  ' +                
         '@cValue04     NVARCHAR( 20),  ' +                
         '@cValue05     NVARCHAR( 20),  ' +                
         '@cValue06     NVARCHAR( 20),  ' +                
         '@cValue07     NVARCHAR( 20),  ' +                
         '@cValue08     NVARCHAR( 20),  ' +                
         '@cValue09     NVARCHAR( 20),  ' +                
         '@cValue10     NVARCHAR( 20),  ' +          
         '@cTemplate    NVARCHAR( MAX), ' +                
         '@cPrintData   NVARCHAR( MAX) OUTPUT, ' +                
         '@nErrNo       INT            OUTPUT, ' +                
         '@cErrMsg      NVARCHAR( 20)  OUTPUT  '                
                
      EXEC sp_ExecuteSQL @cSQL, @cSQLParam,                
         @nMobile, @nFunc, @cLangCode, @cStorerKey,                
         @cValue01, @cValue02, @cValue03, @cValue04, @cValue05, @cValue06, @cValue07, @cValue08, @cValue09, @cValue10,                
         @cTemplate, @cPrintData OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT                
                
      IF @nErrNo <> 0                
         GOTO Quit                
                
      -- Save print data and trigger remote printing in RDT handle                
      UPDATE rdt.rdtMobrec SET                
         EditDate = GETDATE(),                
         RemotePrint = 1, -- 1=On                
         V_MAX = @cPrintData                
      WHERE Mobile = @nMobile                
      IF @@ERROR <> 0                
      BEGIN                
         SET @nErrNo = 110711                
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DirectPrn Fail                
         GOTO Quit                
      END                
                
      SET @cJobType = 'DIRECTPRN'                
      SET @cJobStatus = '9' -- Not trigger RDTSpooler                
   END                
                
   -- RDT Spooler (command)                
   ELSE IF @cPrintCommand <> ''                
   BEGIN                
      SET @cJobType = 'COMMAND'                
      SET @cPrintData = @cPrintCommand                
   END                
                   
   -- RDT Spooler (DataWindow)                
   ELSE                
   BEGIN                
      -- Check datawindow                
      IF ISNULL( @cDataWindow, '') = ''                
      BEGIN                
         SET @nErrNo = 110712                
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DW not setup                
         GOTO Quit                
      END                
                
      SET @cJobType = 'DATAWINDOW'                
   END                
                
   IF @cProcessType <> 'QCOMMANDER' AND @cProcessType <> 'TCPSPOOLER' AND @cProcessType <> 'BARTENDER'  AND @cProcessType <> 'BARTENDERPRTSEQ'  AND @cProcessType<>'TPPrint'              
   BEGIN                
      SET @i = 0                
      WHILE @i < @nNoOfCopy                
      BEGIN                
         -- Insert print job                
         INSERT INTO rdt.rdtPrintJob (                
            JobName, ReportID, JobStatus, Datawindow, NoOfParms, Printer, NoOfCopy, Mobile, TargetDB, PrintData, JobType, StorerKey,                 
            Parm1, Parm2, Parm3, Parm4, Parm5, Parm6, Parm7, Parm8, Parm9, Parm10, Function_ID, ExportFileName)                
         VALUES(                
            @cSourceType, @cReportType, @cJobStatus, ISNULL( @cDataWindow, ''), 0, @cPrinter, 1, @nMobile, DB_NAME(), @cPrintData, @cJobType, @cStorerKey,                 
            @cValue01, @cValue02, @cValue03, @cValue04, @cValue05, @cValue06, @cValue07, @cValue08, @cValue09, @cValue10, @nFunc, @cExportFileName)                
                
         SELECT @nJobID = SCOPE_IDENTITY()                
                   IF @@ERROR <> 0                
         BEGIN                
            SET @nErrNo = 110713                
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PrnJobFail                
         END                
         SET @i = @i + 1                
      END                
   END                
                
   IF @cProcessType <> 'QCOMMANDER' AND @cProcessType <> 'TCPSPOOLER'                
   BEGIN                
      -- rdtspooler will be phased out so should be only bartender & direct print                
      -- will have jobstatus = 9. Thus deleted by below stored proc              
      IF @cJobStatus = '9'                
      BEGIN                
         EXEC [dbo].[isp_UpdateRDTPrintJobStatus]                
             @n_JobID      = @nJobID                
            ,@c_JobStatus  = @cJobStatus                
            ,@c_JobErrMsg  = ''                
            ,@b_Success    = @bSuccess OUTPUT                
            ,@n_Err        = @nErrNo   OUTPUT                
            ,@c_ErrMsg     = @cErrMsg  OUTPUT                
                
         IF @nErrNo <> 0                
         BEGIN                
            SET @nErrNo = 110718                
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PrnLogFail                
         END                
      END                
   END                
                
Quit:                
                
END       
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_Print TO NSQL
GO