
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_838PntShipLbl05                                       */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 09-10-2024 1.0  YYS027     FCR-861-Maersk_V2 Huda_RDT Print labels after   */
/*                            pack based for B2B and Inflencer orders         */
/*                            ShipLabel=CstLabelSP; CstLabelSP=this sp;       */
/*                            Do Not use the config CartonManifest            */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838PntShipLbl05 (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 5),
   @cStorerKey       NVARCHAR( 15),
   @cPickSlipNo      NVARCHAR( 10),
   @cFromDropID      NVARCHAR( 20),
   @nCartonNo        INT,
   @cLabelNo         NVARCHAR( 20),
   @cSKU             NVARCHAR( 20),
   @nQTY             INT,
   @cUCCNo           NVARCHAR( 20),
   @cCartonType      NVARCHAR( 10),
   @cCube            NVARCHAR( 10),
   @cWeight          NVARCHAR( 10),
   @cRefNo           NVARCHAR( 20),
   @cSerialNo        NVARCHAR( 30),
   @nSerialQTY       INT,
   @cOption          NVARCHAR( 1),
   @cPackDtlRefNo    NVARCHAR( 20), 
   @cPackDtlRefNo2   NVARCHAR( 20), 
   @cPackDtlUPC      NVARCHAR( 30), 
   @cPackDtlDropID   NVARCHAR( 20), 
   @cPackData1       NVARCHAR( 30), 
   @cPackData2       NVARCHAR( 30), 
   @cPackData3       NVARCHAR( 30), 
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   DECLARE @cLabelName NVARCHAR(30)
   DECLARE @cSourceType NVARCHAR(10)
   DECLARE @cCondition NVARCHAR(4000)
   DECLARE @cLabelSize NVARCHAR(60)
   DECLARE @cFilePath NVARCHAR(250)
   DECLARE @cFileName NVARCHAR(250)
   DECLARE @cPrinterType NVARCHAR(30)
   
   --printing variable  
   DECLARE
      @cPrinter               NVARCHAR( 10),
      @b_Success              INT,
      @n_Err                  INT,
      @c_ErrMsg               NVARCHAR( 250),
      @cLabelPrinter          NVARCHAR( 10),
      @cPaperPrinter          NVARCHAR( 10),
      @cReportType            NVARCHAR( 10),
      @cRptDesc               NVARCHAR( 60),
      @cRptProcessType        NVARCHAR( 15),
      --@cRptPaperType          NVARCHAR( 10),
      @nRptNoOfCopy           INT,
      @cTargetDB              NVARCHAR( 20),
      @cDataWindow            NVARCHAR( 50),
      @cPrintDataFile         NVARCHAR( MAX),
      @cPrintDataFileEncode   NVARCHAR( MAX),
      @cCloudClientPrinterID  NVARCHAR( 100),
      @cDCropWidth            NVARCHAR( 10)= '' ,
      @cDCropHeight           NVARCHAR( 10)= '',
      @cIsLandScape           NVARCHAR( 1) = '',
      @cIsColor               NVARCHAR( 1) = '',
      @cIsDuplex              NVARCHAR( 1) = '',
      @cIsCollate             NVARCHAR( 1) = '',
      @cPaperSize             NVARCHAR( 20),
      @cPDFPreview            NVARCHAR( 20),

      --Print Job
      @cJobStatus    NVARCHAR(1) = '9',
      @nJobID        INT,
      @bDebugFlag    BINARY = 0

   DECLARE @cOrderKey         NVARCHAR( 20)
   DECLARE @cConsigneyKey     NVARCHAR( 20)
   DECLARE @cExternOrderKey   NVARCHAR( 50)
   DECLARE @tReportParams AS VariableTable

   DECLARE @tCodes TABLE(
      RowId       INT,
      LabelName   NVARCHAR(30), 
      SourceType  NVARCHAR(10), 
      Condition   NVARCHAR(4000), 
      LabelSize   NVARCHAR(60), 
      FilePath    NVARCHAR(250), 
      FileName    NVARCHAR(250), 
      PrinterType NVARCHAR(30)
   )
   DECLARE @nRowID      INT
   DECLARE @nRowCount   INT
   DECLARE @cSQL        NVARCHAR( MAX)
   DECLARE @cSQLParam   NVARCHAR( MAX)
   DECLARE @iRetCount   INT 
   DECLARE @bPrinting   BIT
   DECLARE @c_VbErrMsg  NVARCHAR( MAX)
   
   IF @nStep = 5 -- Print Ship label
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         IF @cOption = 1 -- Yes
         BEGIN
            -- Get session info
            SELECT 
               @cLabelPrinter = Printer, 
               @cPaperPrinter = Printer_Paper
            FROM rdt.rdtMobRec WITH (NOLOCK)
            WHERE Mobile = @nMobile 
            
            /*Recovery Order*/
            SELECT top 1 @cOrderKey = ph.OrderKey 
               FROM PackHeader ph WITH (NOLOCK) 
               JOIN PackDetail pd WITH (NOLOCK)
               ON ph.StorerKey = pd.StorerKey
               AND pd.PickSlipNo = ph.PickSlipNo
            WHERE ph.StorerKey = @cStorerKey
               AND pd.LabelNo = @cLabelNo
            /*   
            Recovery consigney Key from order
            */
            SELECT TOP 1 @cConsigneyKey = ConsigneeKey, @cExternOrderKey = ExternOrderKey
            FROM ORDERS WITH(NOLOCK) 
            WHERE Orders.orderKey = @cOrderKey
            /*
            * Search CODELKUP via @tCodes
            */
            DELETE @tCodes
            INSERT INTO @tCodes(RowId, LabelName, SourceType, Condition, LabelSize, FilePath, FileName, PrinterType)
               SELECT RANK() OVER(ORDER BY code) as RowId, code, Short, Notes, UDF01, UDF02, UDF03, code2 
               FROM CODELKUP WITH (NOLOCK) 
               WHERE listname = 'PACKPRTCON'
                  AND storerkey = @cStorerKey
                  AND code2 = 'Label printer'              --Step 5, output label, so Printer Type should be 'label printer', according spec doc, the result should have 5 records, 3 are normal(logi and BTD), 2 are SFTP
            SELECT @nRowCount = COUNT(1) FROM @tCodes
            SELECT @nRowCount = ISNULL(@nRowCount,0), @nRowID=0

            WHILE @nRowID < @nRowCount
            BEGIN
               SELECT @nRowID = @nRowID + 1
               SELECT 
                  @cLabelName    = LabelName, 
                  @cSourceType   = ISNULL(SourceType,''), 
                  @cCondition    = ISNULL(Condition,''), 
                  @cLabelSize    = ISNULL(LabelSize,''), 
                  @cFilePath     = ISNULL(FilePath,''), 
                  @cFileName     = ISNULL(FileName,''), 
                  @cPrinterType  = PrinterType
               FROM @tCodes WHERE RowId=@nRowID
               
               IF @bDebugFlag = 1
                  SELECT 'Code:', @cLabelName AS LabelName, @cSourceType AS SourceType, @cCondition AS Condition, @cLabelSize AS LabelSize,
                           @cFilePath AS FilePath, @cFileName AS FileName, @cPrinterType AS PrinterType
               -----handle condition checking------------
               SET @iRetCount=0
               IF ISNULL(@cCondition,'')='' OR CHARINDEX('all',@cCondition)>0            --for all case, no condition need check
                  SET @iRetCount=1
               ELSE
               BEGIN                                                                      --@cCondition, is sql-where-statement for orders
                  SET @cSQL = 'SELECT @iRetCount=count(1) FROM orders WHERE orders.OrderKey = @cOrderKey AND ' + @cCondition
                  SET @cSQLParam = N'@iRetCount INT OUTPUT, @cOrderKey VARCHAR(20)'
                  IF @bDebugFlag = 1 
                     select  @cSQL as SQL
                  BEGIN TRY
                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam, 
                        @iRetCount = @iRetCount output,
                        @cOrderKey = @cOrderKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 225856
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')      -- Invalid Condition
                     EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', @cErrMsg, @cLabelName, @cCondition
                     GOTO Quit
                  END CATCH
               END
               ----end of condition checking-------
               --for ship label(Step 5), normal
               --ShipConsignee	Shipper Consignee Label 	BTD                        SHP         ***
               --UAEBox	UAE Box Label for IRF Orders 	      BTD                        SHP         ***
               --RawBox	Raw Box Label for IRF Orders 	      BTD                        SHP         ***
               IF @iRetCount=0
               BEGIN
                  PRINT 'condition is not matched'
               END
               ELSE IF @cSourceType = 'Logi' OR @cSourceType = 'BTD'
               BEGIN
                  SELECT @cReportType = @cLabelName, @bPrinting=0
                  -- Common params
                  DELETE @tReportParams
                  IF @cReportType='ShipConsignee'
                  BEGIN
                     INSERT INTO @tReportParams (Variable, Value) VALUES
                        ( '@cStorerKey',     @cStorerKey),
                        ( '@cPickSlipNo',    @cPickSlipNo),
                        ( '@cFromDropID',    @cFromDropID), -->
                        ( '@cPackDtlDropID', @cPackDtlDropID),
                        ( '@cLabelNo',       @cLabelNo),
                        ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))
                     SET @bPrinting = 1
                  END
                  else if @cReportType='UAEBox'
                  BEGIN
                     INSERT INTO @tReportParams (Variable, Value) VALUES
                        ( '@cStorerKey',     @cStorerKey),
                        ( '@cPickSlipNo',    @cPickSlipNo),
                        ( '@cFromDropID',    @cFromDropID), -->
                        ( '@cPackDtlDropID', @cPackDtlDropID),
                        ( '@cLabelNo',       @cLabelNo),
                        ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))
                     SET @bPrinting = 1
                  END
                  else if @cReportType='RawBox'
                  BEGIN
                     INSERT INTO @tReportParams (Variable, Value) VALUES
                        ( '@cStorerKey',     @cStorerKey),
                        ( '@cPickSlipNo',    @cPickSlipNo),
                        ( '@cFromDropID',    @cFromDropID), -->
                        ( '@cPackDtlDropID', @cPackDtlDropID),
                        ( '@cLabelNo',       @cLabelNo),
                        ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))
                     SET @bPrinting = 1
                  END
                  if @bPrinting = 1
                  BEGIN
                     -- Print label
                     EXEC RDT.rdt_Print 
                        @nMobile, 
                        @nFunc, 
                        @cLangCode, 
                        @nStep, 
                        @nInputKey, 
                        @cFacility, 
                        @cStorerKey, 
                        @cLabelPrinter, 
                        @cPaperPrinter,
                        @cReportType, -- Report type
                        @tReportParams, -- Report params
                        'rdt_838PntShipLbl05',
                        @nErrNo  OUTPUT,
                        @cErrMsg OUTPUT
                     IF @nErrNo <> 0
                        GOTO Quit
                  END
               END  --END of BTD or Logi
               ELSE IF @cSourceType='SFTP'
               BEGIN
                  --for ship label printing(Step 5), via SFTP
                  --AWB		                                    SFTP                       SHP
                  --Manifest		                              SFTP                       SHP
                  IF ISNULL(@cFilePath, '') = '' or ISNULL(@cFileName, '') = ''
                  BEGIN
                     SET @nErrNo = 225851
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- GetFilePathFail
                     GOTO Quit
                  END
                  SELECT @cReportType = @cLabelName
                  --IF NOT @cReportType IN ('AWB','Manifest')                  --for SFTP, do NOT check the reportType
                  --BEGIN
                  --   SET @nErrNo = 225855
                  --   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Invalid Label Name
                  --   GOTO Quit
                  --END

                  --file name(need to replace <code> as actual code value, replace <ExterOrderkey> as actual externorderkey
                  SELECT @cFilePath=ltrim(rtrim(@cFilePath))
                  IF RIGHT(@cFilePath,1) IN ('\','/')
                     SELECT @cPrintDataFile = @cFilePath + REPLACE(REPLACE(@cFileName,'<code>',@cLabelName),'<ExternOrderKey>',@cExternOrderKey)
                  ELSE
                     SELECT @cPrintDataFile = @cFilePath + '/' + REPLACE(REPLACE(@cFileName,'<code>',@cLabelName),'<ExternOrderKey>',@cExternOrderKey)


                  EXEC MASTER.DBO.isp_URLEncode
                     @c_InputString = @cPrintDataFile,
                     @c_OutputString = @cPrintDataFileEncode OUTPUT,
                     @c_VbErrMsg = @c_VbErrMsg OUTPUT

                  IF ISNULL(@c_VbErrMsg,'') <> ''
                  BEGIN
                     SET @nErrNo = 225857
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- URLEncode Failure
                     BREAK
                  END
                  IF @bDebugFlag = 1
                     SELECT 'Print Data File', @cPrintDataFile as DataFile, @cPrintDataFileEncode as DataFileEncode
                  -----BEGIN of cloud print---------------
                  SET @cPrinter = @cLabelPrinter            --for Screen 5(Ship Label), the printer Type should be label
                  --Verify printer
                  SELECT @cCloudClientPrinterID= CloudPrintClientID
                  FROM rdt.rdtprinter WITH (NOLOCK) 
                  WHERE PrinterID = @cPrinter

                  IF @@ROWCOUNT = 0
                  BEGIN
                     SET @nErrNo = 225853
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- PrinterNotExists
                     GOTO Quit
                  END

                  IF ISNULL(@cCloudClientPrinterID, '') = ''
                  BEGIN
                     SET @nErrNo = 225854
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
                  Where reporttype = @cReportType
                     AND Storerkey = @cStorerKey
                     AND Function_ID = @nFunc

                  SET   @cDCropWidth    = CASE WHEN ISNULL(@cDCropWidth , '') = '' THEN '' ELSE @cDCropWidth  END
                  SET   @cDCropHeight   = CASE WHEN ISNULL(@cDCropHeight, '') = '' THEN '' ELSE @cDCropHeight END
                  SET   @cIsLandScape   = CASE WHEN ISNULL(@cIsLandScape, '') = '' THEN '' ELSE @cIsLandScape END
                  SET   @cIsColor       = CASE WHEN ISNULL(@cIsColor    , '') = '' THEN '' ELSE @cIsColor     END
                  SET   @cIsDuplex      = CASE WHEN ISNULL(@cIsDuplex   , '') = '' THEN '' ELSE @cIsDuplex    END
                  SET   @cIsCollate     = CASE WHEN ISNULL(@cIsCollate  , '') = '' THEN '' ELSE @cIsCollate   END
                  SET   @cPaperSize     = CASE WHEN ISNULL(@cPaperSize  , '') = '' THEN '' ELSE @cPaperSize   END
                  SET   @cCloudClientPrinterID = CASE WHEN ISNULL(@cCloudClientPrinterID  , '') = '' THEN '' ELSE @cCloudClientPrinterID   END

                  -- Insert print job
                  IF @bDebugFlag = 1
                     SELECT 'Create Print Job', @cReportType AS RptType, @cPrinter AS Printer, @nRptNoOfCopy AS NoOfCopy, @cPrintDataFileEncode AS PrintData,
                              @cDCropHeight AS width, @cDCropHeight AS height, @cIsLandScape AS IsLandScape, @cIsDuplex AS IsDuplex, @cIsColor AS IsColor,
                              @cIsCollate AS IsCollate, @cPaperSize AS PaperSize, @cCloudClientPrinterID AS CloudClientID

                  INSERT INTO rdt.rdtPrintJob (
                     JobName, ReportID, JobStatus, Datawindow, Parm1, Printer, NoOfCopy, Mobile, TargetDB, PrintData, JobType, StorerKey,
                     Function_ID, PaperSizeWxH, DCropWidth, DCropHeight, IsLandScape, IsColor, IsDuplex, IsCollate)
                  VALUES(
                     'rdt_838PntShipLbl05', @cReportType, @cJobStatus, @cDataWindow, @cOrderKey, @cPrinter, @nRptNoOfCopy, @nMobile, DB_NAME(), @cPrintDataFileEncode, 'LogiReport', @cStorerKey,
                     @nFunc, @cPaperSize, @cDCropWidth, @cDCropHeight, @cIsLandScape, @cIsColor, @cIsDuplex, @cIsCollate)

                  SELECT @nJobID = SCOPE_IDENTITY(), @nErrNo = @@ERROR

                  IF @nErrNo <> 0
                  BEGIN
                     SET @nErrNo = 225858
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PrnJobFail
                     GOTO Quit
                  END

                  --Submit to cloud print task
                  EXEC isp_UpdateRDTPrintJobStatus
                        @n_JobID = @nJobID,
                        @c_JobStatus = @cJobStatus,      --9
                        @c_JobErrMsg = '',
                        @b_Success = @b_Success OUTPUT,
                        @n_Err  = @nErrNo OUTPUT,
                        @c_ErrMsg = @cErrMsg OUTPUT,
                        @c_PrintData = @cPrintDataFileEncode

                  IF @bDebugFlag = 1
                     SELECT 'Submit to cloud print', @nJobID AS JobID, @cJobStatus AS JobStatus, @b_Success AS bSuccess, @nErrNo AS ErrNo, @cErrMsg AS ErrMsg

                  IF @b_Success <> 1
                  BEGIN
                     SET @nErrNo = 225852
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SubCldPrtFail
                     GOTO Quit
                  END
                  -----END OF CLOUD PRINT----------------
               END  --END of SFTP
            END  -- END OF WHILE
         END   --IF @cOption = 1 -- Yes
      END
   END      --end of step 5
   else IF @nStep = 6 -- Print Pack List
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         IF @cOption = 1 -- Yes
         BEGIN
            -- Get session info
            SELECT 
               @cLabelPrinter = Printer, 
               @cPaperPrinter = Printer_Paper
            FROM rdt.rdtMobRec WITH (NOLOCK)
            WHERE Mobile = @nMobile 
            
            /*Recovery Order*/
            SELECT top 1 @cOrderKey = ph.OrderKey 
               FROM PackHeader ph WITH (NOLOCK) 
               JOIN PackDetail pd WITH (NOLOCK)
               ON ph.StorerKey = pd.StorerKey
               AND pd.PickSlipNo = ph.PickSlipNo
            WHERE ph.StorerKey = @cStorerKey
               AND pd.LabelNo = @cLabelNo
            /*   
            Recovery consigney Key from order
            */
            SELECT TOP 1 @cConsigneyKey = ConsigneeKey, @cExternOrderKey = ExternOrderKey
            FROM ORDERS WITH(NOLOCK) 
            WHERE Orders.orderKey = @cOrderKey
            /*
            * Search CODELKUP via @tCodes
            */
            DELETE @tCodes
            INSERT INTO @tCodes(RowId, LabelName, SourceType, Condition, LabelSize, FilePath, FileName, PrinterType)
               SELECT RANK() OVER(ORDER BY code) as RowId, code, Short, Notes, UDF01, UDF02, UDF03, code2 
               FROM CODELKUP WITH (NOLOCK) 
               WHERE listname = 'PACKPRTCON'
                  AND storerkey = @cStorerKey
                  AND code2 = 'Paper Printer'      --Step 6, output Pack list, so Printer Type should be 'paper printer', according spec doc, the result should have 3 records, 2 are normal(logi), 1 are SFTP
            SELECT @nRowCount = COUNT(1) FROM @tCodes
            SELECT @nRowCount = ISNULL(@nRowCount,0), @nRowID=0

            WHILE @nRowID < @nRowCount
            BEGIN
               SELECT @nRowID = @nRowID + 1
               SELECT 
                  @cLabelName    = LabelName, 
                  @cSourceType   = ISNULL(SourceType,''), 
                  @cCondition    = ISNULL(Condition,''), 
                  @cLabelSize    = ISNULL(LabelSize,''), 
                  @cFilePath     = ISNULL(FilePath,''), 
                  @cFileName     = ISNULL(FileName,''), 
                  @cPrinterType  = PrinterType
               FROM @tCodes WHERE RowId=@nRowID
               
               IF @bDebugFlag = 1
                  SELECT 'Code:', @cLabelName AS LabelName, @cSourceType AS SourceType, @cCondition AS Condition, @cLabelSize AS LabelSize,
                           @cFilePath AS FilePath, @cFileName AS FileName, @cPrinterType AS PrinterType
               -----handle condition checking------------
               SET @iRetCount=0
               IF ISNULL(@cCondition,'')='' OR CHARINDEX('all',@cCondition)>0            --for all case, no condition need check
                  SET @iRetCount=1
               ELSE
               BEGIN                                                                      --@cCondition, is sql where statement for orders
                  SET @cSQL = 'SELECT @iRetCount=count(1) FROM orders WHERE orders.OrderKey = @cOrderKey AND ' + @cCondition
                  SET @cSQLParam = N'@iRetCount INT OUTPUT, @cOrderKey VARCHAR(20)'
                  IF @bDebugFlag = 1 
                     select  @cSQL as SQL
                  BEGIN TRY
                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam, 
                        @iRetCount = @iRetCount output,
                        @cOrderKey = @cOrderKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 225856
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')      -- Invalid Condition
                     EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', @cErrMsg, @cLabelName, @cCondition
                     GOTO Quit
                  END CATCH
               END
               ----end of condition checking-------
               SET @bPrinting = 0
               IF @iRetCount=0
               BEGIN
                  PRINT 'Condition is not matched'
               END
               ELSE IF @cSourceType='Logi' OR @cSourceType='BTD'
               BEGIN
                  --for Pack List(Step 6)  normal printing
                  --DGD	DGD (A4 paper ) Color Print	         Logi report (RDT)          PACKLIST     ***
                  --Packinglist	Packing List	               Logi report (RDT)          PACKLIST     ***
                  SELECT @cReportType = @cLabelName, @bPrinting=0
                  -- Common params
                  DELETE @tReportParams
                  if @cReportType='DGD'
                  BEGIN
                     INSERT INTO @tReportParams (Variable, Value) VALUES
                        ( '@cStorerKey',     @cStorerKey),
                        ( '@cPickSlipNo',    @cPickSlipNo),
                        ( '@cFromDropID',    @cFromDropID), -->
                        ( '@cPackDtlDropID', @cPackDtlDropID),
                        ( '@cLabelNo',       @cLabelNo),
                        ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))
                     SET @bPrinting = 1
                  END
                  else if @cReportType='Packinglist'
                  BEGIN
                     INSERT INTO @tReportParams (Variable, Value) VALUES
                        ( '@cStorerKey',     @cStorerKey),
                        ( '@cPickSlipNo',    @cPickSlipNo),
                        ( '@cFromDropID',    @cFromDropID), -->
                        ( '@cPackDtlDropID', @cPackDtlDropID),
                        ( '@cLabelNo',       @cLabelNo),
                        ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))
                     SET @bPrinting = 1
                  END
                  if @bPrinting = 1
                  BEGIN
                     -- Print label
                     EXEC RDT.rdt_Print 
                        @nMobile, 
                        @nFunc, 
                        @cLangCode, 
                        @nStep, 
                        @nInputKey, 
                        @cFacility, 
                        @cStorerKey, 
                        @cLabelPrinter, 
                        @cPaperPrinter,
                        @cReportType, -- Report type
                        @tReportParams, -- Report params
                        'rdtfnc_Pack',
                        @nErrNo  OUTPUT,
                        @cErrMsg OUTPUT
                     IF @nErrNo <> 0
                        GOTO Quit
                  END
               END  --END of BTD or Logi
               ELSE IF CHARINDEX('SFTP',@cSourceType)>0
               BEGIN
                  --for Packlist print(Step 6) via SFTP
                  --CommercialInvoice	Commercial Invoice	   SFTP PDF from customer     PACKLIST
                  --file name(need to replace <code> as actual code value, replace <ExterOderkey> as actual exterorderkey
                  IF ISNULL(@cFilePath, '') = '' or ISNULL(@cFileName, '') = ''
                  BEGIN
                     SET @nErrNo = 225851
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- GetFilePathFail
                     GOTO Quit
                  END
                  SELECT @cReportType = @cLabelName
                  IF NOT @cReportType IN ('CommercialInvoice')
                  BEGIN
                     SET @nErrNo = 225855
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Invalid Label Name
                     GOTO Quit
                  END
                  SELECT @cFilePath=ltrim(rtrim(@cFilePath))
                  IF RIGHT(@cFilePath,1) IN ('\','/')
                     SELECT @cPrintDataFile = @cFilePath +REPLACE( REPLACE(REPLACE(@cFileName,'<code>',@cLabelName),'<ExterOderkey>',@cOrderKey),'<ExternOderkey>',@cOrderKey)
                  ELSE
                     SELECT @cPrintDataFile = @cFilePath + '/' +REPLACE( REPLACE(REPLACE(@cFileName,'<code>',@cLabelName),'<ExterOderkey>',@cOrderKey),'<ExternOderkey>',@cOrderKey)
                  EXEC MASTER.DBO.isp_URLEncode
                     @c_InputString = @cPrintDataFile,
                     @c_OutputString = @cPrintDataFileEncode OUTPUT,
                     @c_VbErrMsg = @c_VbErrMsg OUTPUT

                  IF ISNULL(@c_VbErrMsg,'') <> ''
                  BEGIN
                     SET @nErrNo = 225857
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- URLEncode Failure
                     BREAK
                  END
                  IF @bDebugFlag = 1
                     SELECT 'Print Data File', @cPrintDataFile as DataFile, @cPrintDataFileEncode as DataFileEncode
                  -----BEGIN of cloud print---------------

                  IF CHARINDEX('Label',@cPrinterType)>0
                     SET @cPrinter = @cLabelPrinter
                  ELSE
                     SET @cPrinter = @cPaperPrinter
                  --Verify printer
                  SELECT @cCloudClientPrinterID= CloudPrintClientID
                  FROM rdt.rdtprinter WITH (NOLOCK) 
                  WHERE PrinterID = @cPrinter

                  IF @@ROWCOUNT = 0
                  BEGIN
                     SET @nErrNo = 225853
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- PrinterNotExists
                     GOTO Quit
                  END

                  IF ISNULL(@cCloudClientPrinterID, '') = ''
                  BEGIN
                     SET @nErrNo = 225854
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
                  Where reporttype = @cReportType
                     AND Storerkey = @cStorerKey
                     AND Function_ID = @nFunc

                  SET   @cDCropWidth    = CASE WHEN ISNULL(@cDCropWidth , '') = '' THEN '' ELSE @cDCropWidth  END
                  SET   @cDCropHeight   = CASE WHEN ISNULL(@cDCropHeight, '') = '' THEN '' ELSE @cDCropHeight END
                  SET   @cIsLandScape   = CASE WHEN ISNULL(@cIsLandScape, '') = '' THEN '' ELSE @cIsLandScape END
                  SET   @cIsColor       = CASE WHEN ISNULL(@cIsColor    , '') = '' THEN '' ELSE @cIsColor     END
                  SET   @cIsDuplex      = CASE WHEN ISNULL(@cIsDuplex   , '') = '' THEN '' ELSE @cIsDuplex    END
                  SET   @cIsCollate     = CASE WHEN ISNULL(@cIsCollate  , '') = '' THEN '' ELSE @cIsCollate   END
                  SET   @cPaperSize     = CASE WHEN ISNULL(@cPaperSize  , '') = '' THEN '' ELSE @cPaperSize   END
                  SET   @cCloudClientPrinterID = CASE WHEN ISNULL(@cCloudClientPrinterID  , '') = '' THEN '' ELSE @cCloudClientPrinterID   END

                  -- Insert print job
                  IF @bDebugFlag = 1
                     SELECT 'Create Print Job', @cReportType AS RptType, @cPrinter AS Printer, @nRptNoOfCopy AS NoOfCopy, @cPrintDataFileEncode AS PrintData,
                              @cDCropHeight AS width, @cDCropHeight AS height, @cIsLandScape AS IsLandScape, @cIsDuplex AS IsDuplex, @cIsColor AS IsColor,
                              @cIsCollate AS IsCollate, @cPaperSize AS PaperSize, @cCloudClientPrinterID AS CloudClientID

                  INSERT INTO rdt.rdtPrintJob (
                     JobName, ReportID, JobStatus, Datawindow, Parm1, Printer, NoOfCopy, Mobile, TargetDB, PrintData, JobType, StorerKey,
                     Function_ID, PaperSizeWxH, DCropWidth, DCropHeight, IsLandScape, IsColor, IsDuplex, IsCollate)
                  VALUES(
                     'rdt_838PntShipLbl05', @cReportType, @cJobStatus, @cDataWindow, @cOrderKey, @cPrinter, @nRptNoOfCopy, @nMobile, DB_NAME(), @cPrintDataFileEncode, 'LogiReport', @cStorerKey,
                     @nFunc, @cPaperSize, @cDCropWidth, @cDCropHeight, @cIsLandScape, @cIsColor, @cIsDuplex, @cIsCollate)

                  SELECT @nJobID = SCOPE_IDENTITY(), @nErrNo = @@ERROR

                  IF @nErrNo <> 0
                  BEGIN
                     SET @nErrNo = 225858
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PrnJobFail
                     GOTO Quit
                  END

                  --Submit to cloud print task
                  EXEC isp_UpdateRDTPrintJobStatus
                        @n_JobID = @nJobID,
                        @c_JobStatus = @cJobStatus,      --9
                        @c_JobErrMsg = '',
                        @b_Success = @b_Success OUTPUT,
                        @n_Err  = @nErrNo OUTPUT,
                        @c_ErrMsg = @cErrMsg OUTPUT,
                        @c_PrintData = @cPrintDataFileEncode

                  IF @bDebugFlag = 1
                     SELECT 'Submit to cloud print', @nJobID AS JobID, @cJobStatus AS JobStatus, @b_Success AS bSuccess, @nErrNo AS ErrNo, @cErrMsg AS ErrMsg

                  IF @b_Success <> 1
                  BEGIN
                     SET @nErrNo = 225852
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SubCldPrtFail
                     GOTO Quit
                  END
                  -----END OF CLOUD PRINT----------------
               END  --END of SFTP
            END  -- END OF WHILE         
         END
      END
   END  --end of step 6

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838PntShipLbl05 TO NSQL
GO
