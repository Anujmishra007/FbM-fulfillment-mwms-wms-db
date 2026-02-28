SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: isp_TPS_ExtPrint04                                        */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2023-07-27   1.0  yeekung    TPS-759 Created                               */
/* 2023-09-12   1.1  YeeKung    TPS-773/TPS-740 New print (yeekung3)          */
/* 2024-11-06   1.2  YeeKung    TPS-989 Add Facility (yeekung02)              */
/* 2024-12-01   1.3  YeeKung    TPS-954 add customize prinnt (yeekung03)      */
/* 2025-04-22   1.4  YeeKung    TPS-1015 Fix issues    (yeekung04)            */
/* 2025-04-24   2.1  GhChan     UWP-33066 FCR-4039 Fix Group By (Gh01)        */
/* 2025-04-24   2.2  GhChan     FCR-4207 Fix DynamicPrinter (Gh02)            */
/******************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPS_ExtPrint04] (
	@cStorerKey       NVARCHAR( 15),
   @cFacility        NVARCHAR( 5),
   @nFunc            INT,
   @cUserName        NVARCHAR( 128),
   @cLangCode        NVARCHAR( 3),
   @cScanNo          NVARCHAR( 50),
   @cpickslipNo      NVARCHAR( 30),
   @cDropID          NVARCHAR( 50),
   @cOrderKey        NVARCHAR( 10),
   @cLoadKey         NVARCHAR( 10),
   @cZone            NVARCHAR( 18),
   @EcomSingle       NVARCHAR( 1),
   @nCartonNo        INT,
   @cCartonType      NVARCHAR( 10),
   @cType            NVARCHAR( 30),
   @fCartonWeight    FLOAT,
   @fCartonCube      FLOAT,
   @cWorkstation     NVARCHAR( 30),
   @cLabelNo         NVARCHAR( 20),
   @cCloseCartonJson NVARCHAR (MAX),
   @cPrintPackList   NVARCHAR(1),
   @cLabelJobID      NVARCHAR ( 30) OUTPUT,
   @cPackingJobID    NVARCHAR ( 30) OUTPUT,
   @b_Success        INT = 1        OUTPUT,
   @n_Err            INT = 0        OUTPUT,
   @c_ErrMsg         NVARCHAR( 255) = ''  OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE @curAD CURSOR
DECLARE
	@cSKU             NVARCHAR(20),
   @cSkuBarcode      NVARCHAR(60),
   @cOrderLineNumber NVARCHAR(5),
   @cWeight          NVARCHAR(10),
   @cCube            NVARCHAR(10),
   @cLottableVal     NVARCHAR(20),
   @cSerialNoKey     NVARCHAR(60),
   @nQty             INT,
   @bsuccess         INT,
   @nTranCount       INT

DECLARE @CloseCtnList TABLE (
   SKU             NVARCHAR( 20),
   QTY             INT,
   Weight          FLOAT,
   Cube            FLOAT,
   lottableVal     NVARCHAR(60),
   SkuBarcode      NVARCHAR(60),
   ADCode          NVARCHAR(60)
)



DECLARE   @c_ModuleID           NVARCHAR(30) ='TPPack'
      , @c_ReportID           NVARCHAR(10) 
      , @c_PrinterID          NVARCHAR(30)  
      , @c_JobIDs             NVARCHAR(50)   = ''         --(Wan03) -- May return multiple jobs ID.JobID seperate by '|'
      , @c_PrintSource        NVARCHAR(20)
      , @c_AutoPrint          NVARCHAR(1)    = 'N'        --(Wan07)

--INSERT INTO @CloseCtnList (SKU, QTY, WEIGHT, CUBE, lottableVal,SkuBarcode, ADCode)
--SELECT
--Hdr.SKU
--, Hdr.Qty
--, Hdr.Weight
--, Hdr.Cube
--, Hdr.lottableValue
--, Det.barcodeVal
--, Det.AntiDiversionCode
--FROM OPENJSON(@cCloseCartonJson)
--WITH (
--   SKU            NVARCHAR( 20)  '$.SKU',
--   Qty            INT            '$.PackedQty',
--   Weight         FLOAT          '$.WEIGHT',
--   Cube           FLOAT          '$.CUBE',
--   lottableValue  NVARCHAR(60)   '$.Lottable',
--   barcodeObj     NVARCHAR(MAX)  '$.barcodeObj' AS JSON
--) AS Hdr
--CROSS APPLY OPENJSON(barcodeObj)
--WITH (
--   barcodeVal        NVARCHAR(60) '$.barcodeVal',
--   AntiDiversionCode NVARCHAR(60) '$.AntiDiversionCode'
--) AS Det

--SELECT 'aa',* FROM @CloseCtnList

DECLARE  @tUCCLabel AS VariableTable
DECLARE  @tCtnLabel AS VariableTable
DECLARE  @tPackList AS VariableTable
DECLARE  @cConsignee     NVARCHAR(15)
DECLARE  @cReportType    nvarchar(20)
DECLARE  @cLabelPrinter  NVARCHAR ( 30)
DECLARE  @cPaperPrinter  NVARCHAR ( 30)
DECLARE  @nRC            INT
DECLARE  @cSQL           NVARCHAR ( MAX)
DECLARE  @cSQLParam      NVARCHAR ( MAX)
DECLARE  @cColumn        NVARCHAR( 60)
DECLARE  @cValue         NVARCHAR( 60)
DECLARE  @cTemplate      NVARCHAR(50),
         @cTemplateCode  NVARCHAR(60),
         @cCodeTwo       NVARCHAR(20),
         @cField01       NVARCHAR(10),
         @cVASType       NVARCHAR(10),
         @cNewLabelPrinter NVARCHAR(10),
         @cNewPaperPrinter NVARCHAR(10),
         @cPrinterInGroup NVARCHAR(10)

DECLARE @groupByFields NVARCHAR(MAX) = ''
DECLARE @cFieldName1 NVARCHAR(max),
        @cFieldName2 NVARCHAR(max),
        @cFieldName3 NVARCHAR(max),
        @cFieldName4 NVARCHAR(max),
        @cParams1    NVARCHAR(max),
        @cParams2    NVARCHAR(max),
        @cParams3    NVARCHAR(max),
        @cParams4    NVARCHAR(max),
        @IsAggregate1 BIT = 0,
        @IsAggregate2 BIT = 0,
        @IsAggregate3 BIT = 0,
        @IsAggregate4 BIT = 0


DECLARE @tOutBoundList AS VariableTable

set @cLabelJobID = ''
set @cPackingJobID = ''

BEGIN
	IF @cPickSlipNo <> ''
   BEGIN

      SELECT @cPaperPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Paper'
      SELECT @cLabelPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Label'

      IF EXISTS (  SELECT 1
            FROM dbo.DocInfo WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
            AND TableName = 'ORDERDETAIL'
            AND Key1 = @cOrderKey
            AND Rtrim(Substring(Docinfo.Data,31,30)) = 'L01'  )
      BEGIN

         DECLARE CursorLabel CURSOR LOCAL FAST_FORWARD READ_ONLY FOR

         SELECT Rtrim(Substring(Docinfo.Data,31,30))
               ,Rtrim(Substring(Docinfo.Data,61,30))
         FROM dbo.DocInfo WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND TableName = 'ORDERDETAIL'
         AND Key1 = @cOrderKey
         AND Key2 = '00001'
         AND Rtrim(Substring(Docinfo.Data,31,30)) = 'L01'

         OPEN CursorLabel
         FETCH NEXT FROM CursorLabel INTO @cVASType, @cField01
         WHILE @@FETCH_STATUS = 0
         BEGIN

            DECLARE CursorCodeLkup CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT Notes, Code2
            FROM dbo.CodeLkup WITH (NOLOCK)
            WHERE ListName = 'UALabel'
            AND Code  = @cField01
            AND Short = @cVASType
            AND StorerKey = @cStorerKey

            OPEN CursorCodeLkup
            FETCH NEXT FROM CursorCodeLkup INTO @cTemplate, @cCodeTwo
            WHILE @@FETCH_STATUS = 0
            BEGIN

               SET @cTemplateCode = ''
               SET @cTemplateCode = ISNULL(RTRIM(@cField01),'')  

               IF @cTemplate = ''
               BEGIN
                  SET @n_Err = 1002401
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') --UALabel Template Not Found Function : isp_TPS_ExtPrint04
                  GOTO Quit
               END

               --DELETE FROM @tOutBoundList

               --INSERT INTO @tOutBoundList (Variable, Value) VALUES ( '@cPickSlipNo',  @cPickSlipNo)
               --INSERT INTO @tOutBoundList (Variable, Value) VALUES ( '@nCartonStart', @nCartonNo)
               --INSERT INTO @tOutBoundList (Variable, Value) VALUES ( '@nCartonEnd',   @nCartonNo)
               --INSERT INTO @tOutBoundList (Variable, Value) VALUES ( '@cTemplateCode',   @cTemplateCode)

               ---- Print label
               --EXEC API.isp_Print @cLangCode, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
               --   'SHIPLBLUA2', -- Report type
               --   @tOutBoundList, -- Report params
               --   'isp_TPS_ExtPrint04',
               --   @n_Err  OUTPUT,
               --   @c_ErrMsg OUTPUT

               
               SELECT   @c_ReportID = WMR.reportid,
                        @c_PrintSource = CASE WHEN printtype='LOGIREPORT' THEN 'JReport' ELSE 'WMReport' END
               FROM WMReport WMR (NOLOCK)
               JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid
               WHERE Storerkey = @cStorerkey
                  AND reporttype = 'SHIPLBLUA2'
                  AND ModuleID ='TPPack'
                  AND ispaperprinter <> 'Y'
                  AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)  


               EXEC  [WM].[lsp_WM_Print_Report]
                @c_ModuleID = @c_ModuleID           
               , @c_ReportID = @c_ReportID         
               , @c_Storerkey = @cStorerkey         
               , @c_Facility  = @cFacility        
               , @c_UserName  = @cUsername   
               , @c_ComputerName = ''
               , @c_PrinterID = @cLabelPrinter         
               , @n_NoOfCopy  = '1'     
               , @c_KeyValue1 = @cPickSlipNo        
               , @c_KeyValue2 = @nCartonNo        
               , @c_KeyValue3 = @nCartonNo     
               , @c_KeyValue4 = @cTemplateCode       
               , @b_Success   = @b_Success         OUTPUT      
               , @n_Err       = @n_Err             OUTPUT
               , @c_ErrMsg    = @c_ErrMsg          OUTPUT
               , @c_PrintSource  = @c_PrintSource        
               , @b_SCEPreView   = 0         
               , @c_JobIDs      = @cLabelJobID         OUTPUT    
               , @c_AutoPrint  = 'N'     

               IF @n_Err <> 0
                  GOTO QUIT

               FETCH NEXT FROM CursorCodeLkup INTO @cTemplate, @cCodeTwo

            END
            CLOSE CursorCodeLkup
            DEALLOCATE CursorCodeLkup

            FETCH NEXT FROM CursorLabel INTO @cVASType, @cField01
         END
      END
      IF EXISTS (  SELECT 1
                  FROM dbo.DocInfo WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND TableName = 'ORDERDETAIL'
                  AND Key1 = @cOrderKey
                  AND Rtrim(Substring(Docinfo.Data,31,30)) = 'L02'  )
      BEGIN
   
         SELECT @cVASType = Rtrim(Substring(Docinfo.Data,31,30))  
         FROM dbo.DocInfo WITH (NOLOCK)  
         WHERE StorerKey = @cStorerKey  
         AND TableName = 'ORDERDETAIL'  
         AND Key1 = @cOrderKey  
         AND Key2 = '00001'  
         AND Rtrim(Substring(Docinfo.Data,31,30)) = 'L02'  

         SET @cTemplate = ''

         DECLARE CursorCodeLkup CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT Notes, Code2
         FROM dbo.CodeLkup WITH (NOLOCK)
         WHERE ListName = 'UACCLabel'
         AND Code  = @cVASType
         AND StorerKey = @cStorerKey

         OPEN CursorCodeLkup
         FETCH NEXT FROM CursorCodeLkup INTO @cTemplate, @cCodeTwo
         WHILE @@FETCH_STATUS <> -1
         BEGIN

            SET @cTemplateCode = ''
            SET @cTemplateCode = ISNULL(RTRIM(@cVASType),'')  + ISNULL(RTRIM(@cCodeTwo),'')

            IF @cTemplate = ''
            BEGIN
               SET @n_Err = 1002402
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') --UACCLabel Template Not Found Function : isp_TPS_ExtPrint04
               GOTO Quit
            END

               --DELETE FROM @tOutBoundList

               --INSERT INTO @tOutBoundList (Variable, Value) VALUES ( '@cPickSlipNo',  @cPickSlipNo)
               --INSERT INTO @tOutBoundList (Variable, Value) VALUES ( '@nCartonStart', @nCartonNo)
               --INSERT INTO @tOutBoundList (Variable, Value) VALUES ( '@nCartonEnd',   @nCartonNo)
               --INSERT INTO @tOutBoundList (Variable, Value) VALUES ( '@cTemplateCode',   @cTemplateCode)

               ---- Print label
               --EXEC API.isp_Print @cLangCode, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
               --   'SHIPLBLUA2', -- Report type
               --   @tOutBoundList, -- Report params
               --   'rdt_593PrintUA01',
               --   @n_Err  OUTPUT,
               --   @c_ErrMsg OUTPUT

                              
               SELECT   @c_ReportID = WMR.reportid,
                        @c_PrintSource = CASE WHEN printtype='LOGIREPORT' THEN 'JReport' ELSE 'WMReport' END
               FROM WMReport WMR (NOLOCK)
               JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid
               WHERE Storerkey = @cStorerkey
                  AND reporttype = 'SHIPLBLUA2'
                  AND ModuleID ='TPPack'
                  AND ispaperprinter <> 'Y'
                  AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)  

               EXEC  [WM].[lsp_WM_Print_Report]
                @c_ModuleID = @c_ModuleID           
               , @c_ReportID = @c_ReportID         
               , @c_Storerkey = @cStorerkey         
               , @c_Facility  = @cFacility        
               , @c_UserName  = @cUsername   
               , @c_ComputerName = ''
               , @c_PrinterID = @cLabelPrinter         
               , @n_NoOfCopy  = '1'     
               , @c_KeyValue1 = @cPickSlipNo        
               , @c_KeyValue2 = @nCartonNo        
               , @c_KeyValue3 = @nCartonNo     
               , @c_KeyValue4 = @cTemplateCode       
               , @b_Success   = @b_Success         OUTPUT      
               , @n_Err       = @n_Err             OUTPUT
               , @c_ErrMsg    = @c_ErrMsg          OUTPUT
               , @c_PrintSource  = @c_PrintSource        
               , @b_SCEPreView   = 0         
               , @c_JobIDs      = @cLabelJobID         OUTPUT    
               , @c_AutoPrint  = 'N'     

               IF @n_Err <> 0
                  GOTO Quit

            FETCH NEXT FROM CursorCodeLkup INTO @cTemplate, @cCodeTwo

         END
         CLOSE CursorCodeLkup
         DEALLOCATE CursorCodeLkup

      END
      IF EXISTS (select 1 from orders (nolock)
         WHERE orderkey=@cOrderKey
         AND ordergroup ='JIT')
      BEGIN

         SELECT   @c_ReportID = WMR.reportid,
                  @c_PrintSource = CASE WHEN printtype='LOGIREPORT' THEN 'JReport' ELSE 'WMReport' END
         FROM WMReport WMR (NOLOCK)
         JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid
         WHERE Storerkey = @cStorerkey
            AND reporttype = 'CTNLBLUA'
            AND ModuleID ='TPPack'
            AND ispaperprinter <> 'Y'
            AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)  
            
         EXEC  [WM].[lsp_WM_Print_Report]
            @c_ModuleID = @c_ModuleID           
         , @c_ReportID = @c_ReportID         
         , @c_Storerkey = @cStorerkey         
         , @c_Facility  = @cFacility        
         , @c_UserName  = @cUsername   
         , @c_ComputerName = ''
         , @c_PrinterID = @cLabelPrinter         
         , @n_NoOfCopy  = '1'     
         , @c_KeyValue1 = @cLabelNo        
         , @c_KeyValue2 = ''    
         , @c_KeyValue3 = '' 
         , @c_KeyValue4 = ''       
         , @b_Success   = @b_Success         OUTPUT      
         , @n_Err       = @n_Err             OUTPUT
         , @c_ErrMsg    = @c_ErrMsg          OUTPUT
         , @c_PrintSource  = @c_PrintSource        
         , @b_SCEPreView   = 0         
         , @c_JobIDs      = @cLabelJobID         OUTPUT    
         , @c_AutoPrint  = 'N'     

      END

      DECLARE @cCurLabel CURSOR
      SET @cCurLabel = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
      SELECT reporttype
      FROM WMReport WMR WITH (NOLOCK)
         JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid = WMRD.reportid
      WHERE  Storerkey = @cStorerkey
            AND ispaperprinter <> 'Y'
            AND reporttype <> 'SHIPLBLUA2'
            AND WMR.moduleid = @c_ModuleID
            AND (ISNULL(ComputerName,'') = '' OR ComputerName = @cWorkstation)
            AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)  
      ORDER BY WMR.reportid
      OPEN @cCurLabel
      FETCH NEXT FROM @cCurLabel INTO @cReportType
      WHILE @@FETCH_STATUS = 0
      BEGIN

         SELECT   @c_ReportID = WMR.reportid,
                  @c_PrintSource = CASE WHEN printtype='LOGIREPORT' THEN 'JReport' ELSE 'WMReport' END,
                  @cNewLabelPrinter = Defaultprinterid,
                  @cFieldName1  = keyFieldname1,
                  @cFieldName2  = keyFieldname2,
                  @cFieldName3  = keyFieldname3,
                  @cFieldName4  = keyFieldname4
         FROM WMReport WMR (NOLOCK)
         JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid = WMRD.reportid
         WHERE Storerkey = @cStorerkey
            AND reporttype = @cReportType
            AND ModuleID ='TPPack'
            AND ispaperprinter <> 'Y'
            and (WMRD.username = '' OR WMRD.username = @cUsername)
            AND (ISNULL(ComputerName,'') ='' OR ComputerName = @cWorkstation)
            AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)  

         IF @@ROWCOUNT = 0
         BEGIN
            SET @b_Success = 0
            SET @n_Err = 1002403
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No records found in WMReport. Function : isp_TPS_ExtPrint04'
            GOTO Quit
         END

         IF ISNULL(@cFieldName1,'') = ''
         BEGIN
            SET @b_Success = 0
            SET @n_Err = 1002404
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No value found in table(WMReport); column(keyFieldname1), this column cannot be empty or null. Function : isp_TPS_ExtPrint04'
            GOTO Quit
         END
            
         SET @IsAggregate1 = CASE WHEN ISNULL(@cFieldName1,'') <> '' AND (
                              UPPER(@cFieldName1) LIKE '%SUM(%' OR 
                              UPPER(@cFieldName1) LIKE '%AVG(%' OR
                              UPPER(@cFieldName1) LIKE '%COUNT(%' OR
                              UPPER(@cFieldName1) LIKE '%MIN(%' OR
                              UPPER(@cFieldName1) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                           ) THEN 1 ELSE 0 END

         SET @IsAggregate2 = CASE WHEN ISNULL(@cFieldName2,'') <> '' AND (
                              UPPER(@cFieldName2) LIKE '%SUM(%' OR 
                              UPPER(@cFieldName2) LIKE '%AVG(%' OR
                              UPPER(@cFieldName2) LIKE '%COUNT(%' OR
                              UPPER(@cFieldName2) LIKE '%MIN(%' OR
                              UPPER(@cFieldName2) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                           ) THEN 1 ELSE 0 END

         SET @IsAggregate3 = CASE WHEN ISNULL(@cFieldName3,'') <> '' AND (
                              UPPER(@cFieldName3) LIKE '%SUM(%' OR 
                              UPPER(@cFieldName3) LIKE '%AVG(%' OR
                              UPPER(@cFieldName3) LIKE '%COUNT(%' OR
                              UPPER(@cFieldName3) LIKE '%MIN(%' OR
                              UPPER(@cFieldName3) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                           ) THEN 1 ELSE 0 END

         SET @IsAggregate4 = CASE WHEN ISNULL(@cFieldName4,'') <> '' AND (
                              UPPER(@cFieldName4) LIKE '%SUM(%' OR 
                              UPPER(@cFieldName4) LIKE '%AVG(%' OR
                              UPPER(@cFieldName4) LIKE '%COUNT(%' OR
                              UPPER(@cFieldName4) LIKE '%MIN(%' OR
                              UPPER(@cFieldName4) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                           ) THEN 1 ELSE 0 END

         SET  @cSQL =
         ' select  @cParams1='+ @cFieldName1  
                SELECT @cSQL = CASE WHEN ISNULL(@cFieldName2,'') <> ''THEN @cSQL +',@cParams2 = '  + @cFieldName2  ELSE  @cSQL END 
                SELECT @cSQL = CASE WHEN ISNULL(@cFieldName3,'') <> ''THEN @cSQL +',@cParams3 = '  + @cFieldName3  ELSE  @cSQL END
                SELECT @cSQL = CASE WHEN ISNULL(@cFieldName4,'') <> ''THEN @cSQL +',@cParams4 = '  + @cFieldName4  ELSE  @cSQL END
         SET @cSQL = @cSQL +' FROM Packdetail (NOLOCK)
            WHERE Storerkey = @cstorerkey
               AND Pickslipno = @cPickslipno
               AND CartonNO = @nCartonno '
         
         SET @groupByFields = ''

         IF ISNULL(@cFieldName1, '') <> '' AND @IsAggregate1 = 0 AND ISNUMERIC(@cFieldName1) = 0
            SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName1

         IF ISNULL(@cFieldName2, '') <> '' AND @IsAggregate2 = 0 AND ISNUMERIC(@cFieldName2) = 0
            SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName2

         IF ISNULL(@cFieldName3, '') <> '' AND @IsAggregate3 = 0 AND ISNUMERIC(@cFieldName3) = 0
               SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName3

         IF ISNULL(@cFieldName4, '') <> '' AND @IsAggregate4 = 0 AND ISNUMERIC(@cFieldName4) = 0
               SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName4

         -- If any valid fields found, append GROUP BY
         IF LEN(@groupByFields) > 0
               SET @cSQL = @cSQL + ' GROUP BY ' + @groupByFields

         SET @cSQLParam = 
         ' @cFieldName1 NVARCHAR(max),
           @cFieldName2 NVARCHAR(max),
           @cFieldName3 NVARCHAR(max),
           @cFieldName4 NVARCHAR(max),
           @cParams1    NVARCHAR(max) OUTPUT,
           @cParams2    NVARCHAR(max) OUTPUT,
           @cParams3    NVARCHAR(max) OUTPUT,
           @cParams4    NVARCHAR(max) OUTPUT,
           @cstorerkey  NVARCHAR(20),
           @cPickslipno NVARCHAR(20),
           @nCartonno   INT'

         EXEC sp_ExecuteSQL @cSQL,@cSQLParam,@cFieldName1,@cFieldName2,@cFieldName3,@cFieldName4,
                             @cParams1 OUTPUT,@cParams2 OUTPUT,@cParams3 OUTPUT,@cParams4 OUTPUT,@cstorerkey,@cPickslipno,@nCartonno 

         IF ISNULL(@cNewLabelPrinter,'')= ''
         BEGIN
            SET @cNewLabelPrinter = @cLabelPrinter
            -- Check if printer is a group  
            IF EXISTS( SELECT TOP 1 1 FROM rdt.rdtPrinterGroup WITH (NOLOCK) WHERE PrinterGroup = @cLabelPrinter)  
            BEGIN  
               SET @cPrinterInGroup = ''  
  
               -- Check if report print to a specific printer in group  
               SELECT @cPrinterInGroup = PrinterID  
               FROM rdt.rdtReportToPrinter WITH (NOLOCK)  
               WHERE Function_ID = @nFunc  
                  AND StorerKey = @cStorerKey  
                  AND ReportType = @cReportType  
                  AND PrinterGroup = @cLabelPrinter  
  
               IF @cPrinterInGroup = ''  
               BEGIN  
                  -- Get default printer in the group  
                  SELECT @cPrinterInGroup = PrinterID  
                  FROM rdt.rdtPrinterGroup WITH (NOLOCK)  
                  WHERE PrinterGroup = @cLabelPrinter  
                     AND DefaultPrinter = 1  
  
                  -- Check no default printer  
                  IF @cPrinterInGroup = ''  
                  BEGIN  
                     SET @n_Err = 1002405  
                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') --Label Printer setup not done. Please setup the Label Printer. Function : isp_TPS_ExtPrint04  
                     GOTO Quit  
                  END  
               END  
               SET @cNewLabelPrinter = @cPrinterInGroup
            END
         END 

         EXEC  [WM].[lsp_WM_Print_Report]
          @c_ModuleID = @c_ModuleID           
         , @c_ReportID = @c_ReportID         
         , @c_Storerkey = @cStorerkey         
         , @c_Facility  = @cFacility        
         , @c_UserName  = @cUsername   
         , @c_ComputerName = @cWorkstation
         , @c_PrinterID = @cNewLabelPrinter         
         , @n_NoOfCopy  = '1'     
         , @c_KeyValue1 = @cParams1        
         , @c_KeyValue2 = @cParams2        
         , @c_KeyValue3 = @cParams3     
         , @c_KeyValue4 = @cParams4       
         , @b_Success   = @b_Success         OUTPUT      
         , @n_Err       = @n_Err             OUTPUT
         , @c_ErrMsg    = @c_ErrMsg          OUTPUT
         , @c_PrintSource  = @c_PrintSource        
         , @b_SCEPreView   = 0         
         , @c_JobIDs      = @cLabelJobID     OUTPUT    
         , @c_AutoPrint  = 'N' 
         
         --To avoid the label print in sequence
         --EG: Labelno should print out first by use tcp method and UCC is bartender method
         --    but UCC print out first, 

         FETCH NEXT FROM @cCurLabel INTO @cReportType

      END

		IF @cPrintPackList = 'Y'
      BEGIN
         DECLARE @cCurPaper CURSOR
         SET @cCurPaper = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
         SELECT reporttype
         FROM WMReport WMR WITH (NOLOCK)
            JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid = WMRD.reportid
         WHERE  Storerkey = @cStorerkey
               AND ispaperprinter = 'Y'
               AND WMR.moduleid = @c_ModuleID
               AND (ISNULL(ComputerName,'') ='' OR ComputerName = @cWorkstation)
               AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)  
         OPEN @cCurPaper
         FETCH NEXT FROM @cCurPaper INTO @cReportType
         WHILE @@FETCH_STATUS = 0
         BEGIN
            SELECT   @c_ReportID = WMR.reportid,
                     @c_PrintSource = CASE WHEN printtype = 'LOGIREPORT' THEN 'JReport' ELSE 'WMReport' END,
                     @cNewPaperPrinter = Defaultprinterid,
                     @cFieldName1  = keyFieldname1,
                     @cFieldName2  = keyFieldname2,
                     @cFieldName3  = keyFieldname3,
                     @cFieldName4  = keyFieldname4
            FROM WMReport WMR (NOLOCK)
            JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid
            WHERE Storerkey = @cStorerkey
               AND reporttype = @cReportType --(yeekung05)
               AND ModuleID ='TPPack'
               AND ispaperprinter = 'Y'
               and (WMRD.username = '' OR WMRD.username = @cUsername)
               AND (ISNULL(ComputerName,'') ='' OR ComputerName = @cWorkstation)
               AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)  

         IF @@ROWCOUNT = 0
         BEGIN
            SET @b_Success = 0
            SET @n_Err = 1002406
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No records found in WMReport. Function : isp_TPS_ExtPrint04'
            GOTO Quit
         END

         IF ISNULL(@cFieldName1,'') = ''
         BEGIN
            SET @b_Success = 0
            SET @n_Err = 1002407
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No value found in table(WMReport); column(keyFieldname1), this column cannot be empty or null. Function : isp_TPS_ExtPrint04'
            GOTO Quit
         END

         SET @IsAggregate1 = CASE WHEN ISNULL(@cFieldName1,'') <> '' AND (
                              UPPER(@cFieldName1) LIKE '%SUM(%' OR 
                              UPPER(@cFieldName1) LIKE '%AVG(%' OR
                              UPPER(@cFieldName1) LIKE '%COUNT(%' OR
                              UPPER(@cFieldName1) LIKE '%MIN(%' OR
                              UPPER(@cFieldName1) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                           ) THEN 1 ELSE 0 END

         SET @IsAggregate2 = CASE WHEN ISNULL(@cFieldName2,'') <> '' AND (
                              UPPER(@cFieldName2) LIKE '%SUM(%' OR 
                              UPPER(@cFieldName2) LIKE '%AVG(%' OR
                              UPPER(@cFieldName2) LIKE '%COUNT(%' OR
                              UPPER(@cFieldName2) LIKE '%MIN(%' OR
                              UPPER(@cFieldName2) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                           ) THEN 1 ELSE 0 END

         SET @IsAggregate3 = CASE WHEN ISNULL(@cFieldName3,'') <> '' AND (
                              UPPER(@cFieldName3) LIKE '%SUM(%' OR 
                              UPPER(@cFieldName3) LIKE '%AVG(%' OR
                              UPPER(@cFieldName3) LIKE '%COUNT(%' OR
                              UPPER(@cFieldName3) LIKE '%MIN(%' OR
                              UPPER(@cFieldName3) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                           ) THEN 1 ELSE 0 END

         SET @IsAggregate4 = CASE WHEN ISNULL(@cFieldName4,'') <> '' AND (
                              UPPER(@cFieldName4) LIKE '%SUM(%' OR 
                              UPPER(@cFieldName4) LIKE '%AVG(%' OR
                              UPPER(@cFieldName4) LIKE '%COUNT(%' OR
                              UPPER(@cFieldName4) LIKE '%MIN(%' OR
                              UPPER(@cFieldName4) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                           ) THEN 1 ELSE 0 END

            SET @cSQL = ''
            SET @cSQLParam = ''

            SET  @cSQL =
            'SELECT  @cParams1='+ @cFieldName1  
                     SELECT @cSQL = CASE WHEN ISNULL(@cFieldName2,'') <> ''THEN @cSQL +',@cParams2 = '  + @cFieldName2  ELSE  @cSQL END 
                     SELECT @cSQL = CASE WHEN ISNULL(@cFieldName3,'') <> ''THEN @cSQL +',@cParams3 = '  + @cFieldName3  ELSE  @cSQL END
                     SELECT @cSQL = CASE WHEN ISNULL(@cFieldName4,'') <> ''THEN @cSQL +',@cParams4 = '  + @cFieldName4  ELSE  @cSQL END
            SET @cSQL = @cSQL +' FROM Packdetail (NOLOCK)
               WHERE Storerkey = @cstorerkey
                  AND Pickslipno = @cPickslipno
                  AND CartonNO = @nCartonno '

            SET @groupByFields = ''

            IF ISNULL(@cFieldName1, '') <> '' AND @IsAggregate1 = 0 AND ISNUMERIC(@cFieldName1) = 0
               SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName1

            IF ISNULL(@cFieldName2, '') <> '' AND @IsAggregate2 = 0 AND ISNUMERIC(@cFieldName2) = 0
               SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName2

            IF ISNULL(@cFieldName3, '') <> '' AND @IsAggregate3 = 0 AND ISNUMERIC(@cFieldName3) = 0
                  SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName3

            IF ISNULL(@cFieldName4, '') <> '' AND @IsAggregate4 = 0 AND ISNUMERIC(@cFieldName4) = 0
                  SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName4

            -- If any valid fields found, append GROUP BY
            IF LEN(@groupByFields) > 0
                  SET @cSQL = @cSQL + ' GROUP BY ' + @groupByFields

            SET @cSQLParam = 
            ' @cFieldName1 NVARCHAR(max),
               @cFieldName2 NVARCHAR(max),
               @cFieldName3 NVARCHAR(max),
               @cFieldName4 NVARCHAR(max),
               @cParams1    NVARCHAR(max) OUTPUT,
               @cParams2    NVARCHAR(max) OUTPUT,
               @cParams3    NVARCHAR(max) OUTPUT,
               @cParams4    NVARCHAR(max) OUTPUT,
               @cstorerkey  NVARCHAR(20),
               @cPickslipno NVARCHAR(20),
               @nCartonno   INT'

            EXEC sp_ExecuteSQL @cSQL,@cSQLParam,@cFieldName1,@cFieldName2,@cFieldName3,@cFieldName4,
                                 @cParams1 OUTPUT,@cParams2 OUTPUT,@cParams3 OUTPUT,@cParams4 OUTPUT,@cstorerkey,@cPickslipno,@nCartonno 
          
            IF ISNULL(@cNewPaperPrinter,'')= ''
            BEGIN
               SET @cNewPaperPrinter = @cPaperPrinter
               -- Check if printer is a group  
               IF EXISTS( SELECT TOP 1 1 FROM rdt.rdtPrinterGroup WITH (NOLOCK) WHERE PrinterGroup = @cPaperPrinter)  
               BEGIN  
                  SET @cPrinterInGroup = ''  
  
                  -- Check if report print to a specific printer in group  
                  SELECT @cPrinterInGroup = PrinterID  
                  FROM rdt.rdtReportToPrinter WITH (NOLOCK)  
                  WHERE Function_ID = @nFunc  
                     AND StorerKey = @cStorerKey  
                     AND ReportType = @cReportType  
                     AND PrinterGroup = @cPaperPrinter  
  
                  IF @cPrinterInGroup = ''  
                  BEGIN  
                     -- Get default printer in the group  
                     SELECT @cPrinterInGroup = PrinterID  
                     FROM rdt.rdtPrinterGroup WITH (NOLOCK)  
                     WHERE PrinterGroup = @cPaperPrinter  
                        AND DefaultPrinter = 1  
  
                     -- Check no default printer  
                     IF @cPrinterInGroup = ''  
                     BEGIN  
                        SET @n_Err = 1002408  
                        SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') --Paper Printer setup not done. Please setup the Paper Printer. Function : isp_TPS_ExtPrint04  
                        GOTO Quit  
                     END  
                  END  
                  SET @cNewPaperPrinter = @cPrinterInGroup
               END
            END   

            EXEC  [WM].[lsp_WM_Print_Report]
               @c_ModuleID    = @c_ModuleID           
            , @c_ReportID     = @c_ReportID         
            , @c_Storerkey    = @cStorerkey         
            , @c_Facility     = @cFacility        
            , @c_UserName     = @cUsername     
            , @c_ComputerName = @cWorkstation
            , @c_PrinterID    = @cNewPaperPrinter         
            , @n_NoOfCopy     = '1'     
            , @c_KeyValue1    = @cParams1        
            , @c_KeyValue2    = @cParams2     
            , @c_KeyValue3    = @cParams3 
            , @c_KeyValue4    = @cParams4
            , @b_Success      = @b_Success         OUTPUT      
            , @n_Err          = @n_Err             OUTPUT
            , @c_ErrMsg       = @c_ErrMsg          OUTPUT
            , @c_PrintSource  = @c_PrintSource        
            , @b_SCEPreView   = 0         
            , @c_JobIDs       = @cPackingJobID         OUTPUT    
            , @c_AutoPrint    = 'N'   

            FETCH NEXT FROM @cCurPaper INTO @cReportType
         END
      END
   END

Quit:

END
 
GO
GRANT EXECUTE ON api.isp_TPS_ExtPrint04 TO NSQL
GO

