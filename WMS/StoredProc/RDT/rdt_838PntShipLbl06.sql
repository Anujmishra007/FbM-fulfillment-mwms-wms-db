SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/**********************************************************************************************/
/* Store procedure: rdt_838PntShipLbl06                                                       */
/* Copyright      : Maersk                                                                    */
/* CLIENT         : HILLSAU                                                                   */
/*                                                                                            */
/* Date       Rev   Author     Purposes                                                       */
/* 02-25-2025 1.0   YWA059     FCR-2495 for 838 rdt print SSCC Label                          */
/*                             when ORDERS.billtokey=811110 then Petbarn else Generic format  */
/*            1.0.1 YWA059                                                                    */
/**********************************************************************************************/

CREATE OR ALTER    PROC [RDT].[rdt_838PntShipLbl06] (
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
      --@cRptProcessType        NVARCHAR( 15),
      @cRptPaperType          NVARCHAR( 10),          --'LABEL' / 'PAPER'
      @nRptNoOfCopy           INT,
      --@cRptTargetDB           NVARCHAR( 20),
      @cRptDataWindow         NVARCHAR( 50),
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
      @cWebRequestURL         NVARCHAR( MAX),
      --Print Job
      @cJobStatus    NVARCHAR(1) = '9',
      @nJobID        INT,
      @bDebugFlag    INT = 0           --5 debug for Ship label, 6 debug for pack list
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
   IF @bDebugFlag > 0 
     select  'Enter rdt_838PntShipLbl06' as Title, @nStep as Step,@nInputKey as InputKey, @cOption as [Option]
   IF (@nStep = 99 OR (@nStep = 5 AND @nInputKey = 1 OR @cOption = 1))-- Print Ship label
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
   IF @bDebugFlag = 5 
   SELECT 'Query ExternOrderKey' as Title, @cExternOrderKey as ExternOrderKey,@cOrderKey as OrderKey, @cLabelPrinter as LabelPrinter, @cPaperPrinter as PaperPrinter
   IF ISNULL(@cExternOrderKey, '') = '' 
   BEGIN
   SET @nErrNo = 225859
   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Invalid ExternOrderkey
   GOTO Quit
   END   
   /*
   * Search CODELKUP via @tCodes 
   * 2024-11-18 Requirement change: since the length limition for userdefine02, we have to change the PDF location=codelkup.notes2
   */
   DELETE @tCodes
   INSERT INTO @tCodes(RowId, LabelName, SourceType, Condition, LabelSize, FilePath, FileName, PrinterType)
   SELECT RANK() OVER(ORDER BY code) AS RowId, code, Short, Notes, UDF01, Notes2, UDF03, code2 
   FROM CODELKUP WITH (NOLOCK) 
   WHERE listname = 'PACKPRTCON'
     AND storerkey = @cStorerKey
     AND code2 = 'Label'              --Step 5, Printer Type should be 'label printer', according spec doc, the result should be 5 records, 3 are normal(logi and BTD), 2 are SFTP
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
   IF @bDebugFlag = 5
     SELECT 'Code:', @cLabelName AS LabelName, @cSourceType AS SourceType, @cCondition AS Condition, @cLabelSize AS LabelSize,
              @cFilePath AS FilePath, @cFileName AS FileName, @cPrinterType AS PrinterType
   -----handle condition checking------------
   SET @iRetCount=0
   IF ISNULL(@cCondition,'')='' OR CHARINDEX('all',@cCondition)>0            --for all case, no condition need check
     SET @iRetCount=1
   ELSE
   BEGIN                                                                      --@cCondition, is sql-where-statement for orders
     SET @cSQL = 'SELECT @iRetCount = ' + @cCondition
     SET @cSQLParam = N'@iRetCount INT OUTPUT, @cLabelNo VARCHAR(20)'
     IF @bDebugFlag = 5 
        SELECT  @cSQL AS SQL
     BEGIN TRY
        EXEC sp_ExecuteSQL @cSQL, @cSQLParam, 
           @iRetCount = @iRetCount OUTPUT,
           @cLabelNo = @cLabelNo
     END TRY
     BEGIN CATCH
        DECLARE @cSQLErrorMessage NVARCHAR(max)
        SELECT @cSQLErrorMessage = ERROR_MESSAGE()
        SET @nErrNo = 225856
        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')      -- Invalid Condition
        EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', @cErrMsg, @cLabelName, @cCondition, cSQLErrorMessage
        GOTO Quit
     END CATCH
   END
   ----end of condition checking-------
   IF @iRetCount=0
   BEGIN
     IF @bDebugFlag = 5 
        SELECT 'condition is not matched:' +@cLabelName + ' - ' + @cCondition
   END
   ELSE IF @cSourceType = 'Logi' OR @cSourceType = 'BTD'
   BEGIN
     SELECT @cReportType = @cLabelName, @bPrinting=0
     -- Common params
     DELETE @tReportParams
     INSERT INTO @tReportParams (Variable, Value) VALUES
     ( '@cStorerKey',     @cStorerKey),
     ( '@cPickSlipNo',    @cPickSlipNo),
     ( '@cFromDropID',    @cFromDropID),
     ( '@cPackDtlDropID', @cPackDtlDropID),
     ( '@cLabelNo',       @cLabelNo),
     ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))
     SET @bPrinting = 1
     IF @bDebugFlag = 5 
        SELECT @cReportType AS ReportType, @bPrinting AS Printing
     IF @bPrinting = 1
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
           'rdt_838PntShipLbl06',
           @nErrNo  OUTPUT,
           @cErrMsg OUTPUT
        IF @nErrNo <> 0
           GOTO Quit
     END
   END  --END of BTD or Logi
   END  -- END OF WHILE
END
Quit:
   IF @bDebugFlag >0 
     select  'exit rdt_838PntShipLbl06' as Title
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_838PntShipLbl06] TO NSQL
GO
