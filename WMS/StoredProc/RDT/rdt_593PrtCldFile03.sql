SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_593PrtCldFile03                                       */
/*                                                                            */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Purpose: PDF Reprint for hillshk                                           */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date       Rev    Author     Purposes                                      */
/* 2024-12-26 1.0.1  BDH028     Print PDF file                                */
/* 2025-04-09 1.1.0  YWA059     Fix issue: endless loop in a scenario         */
/* 2025-05-30 1.1.1  PYU015     FCR-5485 Fix issue:add configkey MaxOrderPrint*/
/* 2025-07-09 1.1.1  PYU015     UWP-37457- Fix issue: fix @cParam2 out of     */
/*                              nvarchar(10) and @cOrderKey is nvarchar(10)   */
/************************** Merged Into V0 ************************************/
/******************************************************************************/
CREATE OR ALTER  PROC [RDT].[rdt_593PrtCldFile03] (
   @nMobile    INT,
   @nFunc      INT,
   @nStep      INT,
   @cLangCode  NVARCHAR( 3),
   @cStorerKey NVARCHAR( 15),
   @cOption    NVARCHAR( 2),
   @cParam1    NVARCHAR(60),
   @cParam2    NVARCHAR(60),
   @cParam3    NVARCHAR(60), 
   @cParam4    NVARCHAR(60), 
   @cParam5    NVARCHAR(60),
   @nErrNo     INT           OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   DECLARE
      @bDebugFlag        BINARY = 0,
      @cOrderKey         NVARCHAR(10),
      @cExternOrderKey   NVARCHAR(50),
      @cLabelName        NVARCHAR(30),
      @cReportType       NVARCHAR(10),
      @cSourceType       NVARCHAR(10), 
      @cCondition        NVARCHAR(4000), 
      @cLabelSize        NVARCHAR(60), 
      @cFilePath         NVARCHAR(250), 
      @cFileName         NVARCHAR(250), 
      @cPrinterType      NVARCHAR(30),
      @nRowCount         INT,
      @cSQL              NVARCHAR(MAX),
      @cSQLParam         NVARCHAR(MAX),
      @cWebRequestURL    NVARCHAR( MAX),
      @cPrintDataFile         NVARCHAR( MAX),
      @cPrintDataFileEncrypt  NVARCHAR( MAX),
      @cPrintDataFileEncode   NVARCHAR( MAX),
      @cPrintDataFileFull     NVARCHAR( MAX),
      @cCloudClientPrinterID  NVARCHAR( 100),
      @cDCropWidth            NVARCHAR( 10)= '' ,
      @cDCropHeight           NVARCHAR( 10)= '',
      @cIsLandScape           NVARCHAR( 1) = '',
      @cIsColor               NVARCHAR( 1) = '',
      @cIsDuplex              NVARCHAR( 1) = '',
      @cIsCollate             NVARCHAR( 1) = '',
      @cPaperSize             NVARCHAR( 20),
      @cPDFPreview            NVARCHAR( 20),
      @cJobStatus             NVARCHAR(1) = '9',
      @nJobID                 INT,
      @cLabelPrinter          NVARCHAR( 10),
      @cPaperPrinter          NVARCHAR( 10),
      @cRptDesc               NVARCHAR( 60),
      @cPrinter               NVARCHAR( 10),
      @cRptPaperType          NVARCHAR( 10),
      @nRptNoOfCopy           INT,
      @cRptDataWindow         NVARCHAR( 50),
      @b_Success              INT,
      @c_VbErrMsg             NVARCHAR( MAX),
      @MbolKey                NVARCHAR(10),
      @loop_OrderKey          NVARCHAR(10),
      @end_loop_flag          INT,
      @nRtnCnt                INT,
      @loop_qty               INT,
      @cMaxOrderPrint         INT

   -- fetch printer
   SELECT @cLabelPrinter = Printer
        , @cPaperPrinter = Printer_Paper
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SET @MbolKey = @cParam1
   SET @loop_OrderKey = ''
   SET @end_loop_flag = 0
   SET @loop_qty = 1

   SELECT @cMaxOrderPrint = CAST(rdt.RDTGetConfig( @nFunc, 'MaxOrderPrint', @cStorerKey) AS INT)
   IF @cMaxOrderPrint = 0
      SET @cMaxOrderPrint = 20

   -- fetch extern order key
   WHILE(@loop_qty < @cMaxOrderPrint)
   BEGIN
     SET @loop_qty = @loop_qty + 1
      IF ISNULL(@cParam2,'') <> ''
      BEGIN
         SET @cOrderKey = @cParam2
          -- UWP-37457 modify  by PYU015 begin --
         IF ISNULL(@cOrderKey, '') = '' OR LEN(@cParam2) != 10
          -- IF ISNULL(@cOrderKey, '') = ''
          -- UWP-37457 modify  by PYU015 end   --
         BEGIN
            SET @nErrno = 236101
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- NeedOrderKey
            GOTO Quit
         END
      END
      ELSE 
      BEGIN
         IF EXISTS (SELECT 1 FROM dbo.MBOLDETAIL WITH(NOLOCK) WHERE MbolKey = @MbolKey)
         BEGIN
               SELECT TOP 1 @loop_OrderKey = OrderKey 
               FROM dbo.MBOLDETAIL WITH(NOLOCK) 
               WHERE MbolKey = @MbolKey
               AND OrderKey > @loop_OrderKey
               ORDER BY OrderKey

               IF @@ROWCOUNT = 0
               BEGIN
                  SET @end_loop_flag = 1
               END

               SET @cOrderKey = @loop_OrderKey
         END
         ELSE
         BEGIN
            SET @nErrNo = 236102
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- InvalidMBOLKEY
            GOTO Quit
         END
      END

      IF (@end_loop_flag = 1)
      BEGIN
         BREAK
      END

      IF (@cOrderKey = @cParam2) 
      BEGIN
         SET @end_loop_flag = 1
      END

      SELECT TOP 1 @cExternOrderKey = ExternOrderKey 
      FROM dbo.ORDERS WITH(NOLOCK) 
      WHERE OrderKey = @cOrderKey
         AND StorerKey = @cStorerKey

      IF ISNULL(@cExternOrderKey, '') = ''
      BEGIN
         SET @nErrNo = 236103
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- NeedExtOrderKey
         GOTO Quit
      END

      -- fetch print code data
      SELECT 
         @cLabelName = c1.Code, 
         @cSourceType = c1.Short, 
         @cCondition = c1.Notes, 
         @cLabelSize = c1.UDF01, 
         @cFilePath = c1.Notes2, 
         @cFileName = c1.UDF03, 
         @cPrinterType = c1.code2
      FROM
         dbo.CODELKUP c1 WITH(NOLOCK)
      INNER JOIN dbo.CODELKUP c2 WITH(NOLOCK)
         ON c1.Code = c2.code2
      WHERE c1.LISTNAME = 'PACKPRTCON'
         AND c1.StorerKey = @cStorerKey
         AND c1.Short = 'SFTP'
         AND c2.LISTNAME = 'RDTLBLRPT' 
         AND c2.StorerKey = @cStorerKey
         AND ISNULL(c2.code2, '') <> ''
         AND c2.Long = 'rdt_593PrtCldFile03'
         AND c2.Code = @cOption

      SELECT @nRowCount = @@ROWCOUNT

      IF @nRowCount = 0
      BEGIN
         SET @nErrNo = 236104
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- FETCH CODE FAILED
         GOTO Quit
      END

      SELECT @cReportType = @cLabelName
      IF ISNULL(@cCondition,'') = '' OR CHARINDEX('all',@cCondition) > 0
      BEGIN
         SET @cCondition = ''
      END

      -- build sql
      SET @cSQL = 'SELECT @nRtnCnt = COUNT(1) FROM dbo.ORDERS orders WITH (NOLOCK) WHERE orders.OrderKey = @cOrderKey '
         + CASE WHEN @cCondition <> '' THEN 'AND ' + @cCondition ELSE '' END
      SET @cSQLParam = '@nRtnCnt INT OUTPUT, @cOrderKey NVARCHAR(10)'

      BEGIN TRY
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam, 
            @nRtnCnt = @nRtnCnt OUTPUT,
            @cOrderKey = @cOrderKey
      END TRY
      BEGIN CATCH
         DECLARE @cSQLErrorMessage NVARCHAR(MAX)
         SELECT @cSQLErrorMessage = ERROR_MESSAGE()
         SET @nErrNo = 236105
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')      -- Invalid Condition
         EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', @cErrMsg, @cLabelName, @cCondition, @cSQLErrorMessage
         GOTO Quit
      END CATCH

      -- check url prefix cfg
      SELECT @cWebRequestURL = WebRequestURL
      FROM dbo.WebServiceCfg WITH (NOLOCK)
      WHERE DataProcess = 'FNGETFILE'
         AND ActiveFlag = 1

      -- URL prifix verify
      IF ISNULL(@cWebRequestURL, '') = ''
      BEGIN
         SET @nErrNo = 236106
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- MissWebSrvc
         GOTO Quit
      END

      -- build file path
      SET @cExternOrderKey = RIGHT(CONCAT('0000000000',@cExternOrderKey),10)
      SELECT @cFilePath = LTRIM(RTRIM(@cFilePath))
      IF RIGHT(@cFilePath,1) IN ('\','/')
      BEGIN
         SELECT @cPrintDataFile = @cFilePath 
            + REPLACE(REPLACE(@cFileName,'<code>',@cLabelName),'<ExternOrderKey>',@cExternOrderKey)
      END
      ELSE BEGIN
         SELECT @cPrintDataFile = @cFilePath 
            + '/' + REPLACE(REPLACE(@cFileName,'<code>',@cLabelName),'<ExternOrderKey>',@cExternOrderKey)
      END

      -- override file path in debug
      IF @bDebugFlag = 1
      BEGIN
         SELECT @cPrintDataFile = 'C:\\targetdir\\filename.PDF'
      END

      -- encrypt file path
      BEGIN TRY
         SELECT @cPrintDataFileEncrypt = MASTER.DBO.fnc_CryptoEncrypt(@cPrintDataFile, '')
      END TRY
      BEGIN CATCH
         SET @nErrNo = 236107
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Failed to encrypt file path
         GOTO Quit
      END CATCH
      IF @nErrNo <> 0
      BEGIN
         GOTO Quit
      END

      -- encode url
      EXEC MASTER.DBO.isp_URLEncode
         @c_InputString = @cPrintDataFileEncrypt,
         @c_OutputString = @cPrintDataFileEncode OUTPUT,
         @c_VbErrMsg = @c_VbErrMsg OUTPUT

      -- build whole uri
      SET @cPrintDataFileFull = @cWebRequestURL + @cPrintDataFileEncode

      SELECT TOP 1
         @cRptDataWindow = DataWindow,                
         @cRptPaperType = PaperType,
         @nRptNoOfCopy = NoOfCopy
      FROM rdt.rdtReport WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND ReportTYpe = @cReportType
         AND (Function_ID = @nFunc OR Function_ID = 0)
      ORDER BY Function_ID DESC

      IF @@ROWCOUNT = 0
      BEGIN
         SET @nErrNo = 236108
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Report Not Exist
         --EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', @cErrMsg, @cReportType
         GOTO Quit
      END

      IF @cRptPaperType = 'LABEL'
         SET @cPrinter = @cLabelPrinter
      ELSE
         SET @cPrinter = @cPaperPrinter

      --Verify printer
      SELECT @cCloudClientPrinterID= CloudPrintClientID
         FROM rdt.rdtprinter WITH (NOLOCK) 
         WHERE PrinterID = @cPrinter
         
      IF @@ROWCOUNT = 0
      BEGIN
         SET @nErrNo = 236109
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- PrinterNotExists
         GOTO Quit
      END

      IF ISNULL(@cCloudClientPrinterID, '') = ''
      BEGIN
         SET @nErrNo = 236110
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- MissCldPrntID
         GOTO Quit
      END

      --Prepare print job data
      SELECT   @cDCropWidth  =  DCropWidth
               ,@cDCropHeight = DCropHeight
               ,@cIsLandScape = IsLandScape
               ,@cIsColor     = IsColor    
               ,@cIsDuplex    = IsDuplex   
               ,@cIsCollate   = IsCollate  
               ,@cPaperSize   = PaperSizeWxH  
      FROM rdt.rdtReportdetail (NOLOCK)
      WHERE reporttype = @cReportType
         AND Storerkey = @cStorerKey
         AND Function_ID = @nFunc

      SET @cDCropWidth    = CASE WHEN ISNULL(@cDCropWidth , '') = '' THEN '' ELSE @cDCropWidth  END
      SET @cDCropHeight   = CASE WHEN ISNULL(@cDCropHeight, '') = '' THEN '' ELSE @cDCropHeight END
      SET @cIsLandScape   = CASE WHEN ISNULL(@cIsLandScape, '') = '' THEN '' ELSE @cIsLandScape END
      SET @cIsColor       = CASE WHEN ISNULL(@cIsColor    , '') = '' THEN '' ELSE @cIsColor     END
      SET @cIsDuplex      = CASE WHEN ISNULL(@cIsDuplex   , '') = '' THEN '' ELSE @cIsDuplex    END
      SET @cIsCollate     = CASE WHEN ISNULL(@cIsCollate  , '') = '' THEN '' ELSE @cIsCollate   END
      SET @cPaperSize     = CASE WHEN ISNULL(@cPaperSize  , '') = '' THEN '' ELSE @cPaperSize   END
      SET @cCloudClientPrinterID = CASE WHEN ISNULL(@cCloudClientPrinterID  , '') = '' THEN '' ELSE @cCloudClientPrinterID   END

      INSERT INTO rdt.rdtPrintJob (
         JobName, ReportID, JobStatus, Datawindow, Parm1, Printer, NoOfCopy, Mobile, TargetDB, PrintData, JobType, StorerKey,
         Function_ID, PaperSizeWxH, DCropWidth, DCropHeight, IsLandScape, IsColor, IsDuplex, IsCollate)
      VALUES(
         'rdt_593PrtCldFile03', @cReportType, @cJobStatus, @cRptDataWindow, @cExternOrderKey, @cPrinter, @nRptNoOfCopy, @nMobile, DB_NAME(), @cPrintDataFileFull, 'LogiReport', @cStorerKey,
         @nFunc, @cPaperSize, @cDCropWidth, @cDCropHeight, @cIsLandScape, @cIsColor, @cIsDuplex, @cIsCollate)

      SELECT @nJobID = SCOPE_IDENTITY(), @nErrNo = @@ERROR
      IF @nErrNo <> 0
      BEGIN
         SET @nErrNo = 236111
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PrnJobFail
         GOTO Quit
      END

      --Submit to cloud print task
      EXEC isp_UpdateRDTPrintJobStatus
            @n_JobID = @nJobID,
            @c_JobStatus = @cJobStatus,  --9
            @c_JobErrMsg = '',
            @b_Success = @b_Success OUTPUT,
            @n_Err  = @nErrNo OUTPUT,
            @c_ErrMsg = @cErrMsg OUTPUT,
            @c_PrintData = @cPrintDataFileFull
      IF @b_Success <> 1
      BEGIN
         SET @nErrNo = 236112
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SubCldPrtFail
         GOTO Quit
      END
   END
   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  [RDT].[rdt_593PrtCldFile03] TO [NSQL]
GO
