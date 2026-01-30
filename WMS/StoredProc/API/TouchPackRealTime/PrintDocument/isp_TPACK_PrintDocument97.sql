SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_PrintDocument97                                    */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Custom Print Label and Paper Function  (Replaced with Std)   */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-10-14   1.0  GCH225     Cloned from isp_TPS_ExtPrint03 (TPS-690)         */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_PrintDocument97] (
     @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @nCartonNo            INT               = 0
   , @c_UserID             NVARCHAR(256)     = ''  
   , @cLangCode            NVARCHAR(3)       = ''
   , @bIsLastCarton        BIT               = 0
   , @bPrintLabelFlag      BIT               = 0
   , @bPrintPaperFlag      BIT               = 0
   , @cLabelPrinter        NVARCHAR(30)      = ''
   , @cPaperPrinter        NVARCHAR(30)      = ''
   , @cPrintLabelJobIDs    NVARCHAR(MAX)     = 0   OUTPUT
   , @cPrintPaperJobIDs    NVARCHAR(MAX)     = 0   OUTPUT
   , @b_Success            INT               = 0   OUTPUT  
   , @n_ErrNo              INT               = 0   OUTPUT
   , @c_ErrMsg             NVARCHAR(250)     = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue           INT            = 1  
         , @n_StartCnt           INT            = @@TRANCOUNT  
         , @b_sp_Success         INT  
         , @n_sp_err             INT  
         , @c_sp_errmsg          NVARCHAR(250)  = ''
         , @DBUserName           NVARCHAR(100)
         , @b_sp_ExecuteAs       BIT  

   DECLARE @cModuleID            NVARCHAR(30)
         , @cReportType          NVARCHAR(30)
         , @cSQL                 NVARCHAR(MAX)
         , @cSQLParam            NVARCHAR(MAX)
         , @cReportID            NVARCHAR(10)
         , @cPrintSource         NVARCHAR(30)
         , @cDefaultPrinterID    NVARCHAR(30)
         , @groupByFields        NVARCHAR(MAX)
         , @cPrinterInGroup      NVARCHAR(10)
         , @cCustomLabelSP       NVARCHAR(30)
         , @cTPCtnLabelJobIDs    NVARCHAR(400)
   
   DECLARE @cFieldName1       NVARCHAR(MAX)
         , @cFieldName2       NVARCHAR(MAX)
         , @cFieldName3       NVARCHAR(MAX)
         , @cFieldName4       NVARCHAR(MAX)
         , @cParams1          NVARCHAR(MAX)
         , @cParams2          NVARCHAR(MAX)
         , @cParams3          NVARCHAR(MAX)
         , @cParams4          NVARCHAR(MAX)
         , @IsAggregate1      BIT = 0
         , @IsAggregate2      BIT = 0
         , @IsAggregate3      BIT = 0
         , @IsAggregate4      BIT = 0

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = '' 
   SET @cSQL               = ''
   SET @cSQLParam          = ''
   SET @cModuleID          = 'TPPACK'
   SET @cCustomLabelSP     = ''


   --DECLARE @cCurLabel CURSOR
   --      SET @cCurLabel = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
   --      SELECT reporttype
   --      FROM WMReport WMR WITH (NOLOCK)
   --         JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid = WMRD.reportid
   --      WHERE  Storerkey = @cStorerkey
   --            AND ispaperprinter <> 'Y'
   --            AND WMR.moduleid = @c_ModuleID
   --            AND (ISNULL(ComputerName,'') = '' OR ComputerName = @cWorkstation)
   --            AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)  
   --            AND Autoprint = 'Y'
   --      ORDER BY WMR.reportid
   --      OPEN @cCurLabel
   --      FETCH NEXT FROM @cCurLabel INTO @cReportType
   --      WHILE @@FETCH_STATUS = 0
   --      BEGIN

   --         SELECT   @c_ReportID = WMR.reportid,
   --                  @c_PrintSource = CASE WHEN printtype='LOGIREPORT' THEN 'JReport' ELSE 'WMReport' END,
   --                  @cNewLabelPrinter = Defaultprinterid,
   --                  @cFieldName1  = keyFieldname1,
   --                  @cFieldName2  = keyFieldname2,
   --                  @cFieldName3  = keyFieldname3,
   --                  @cFieldName4  = keyFieldname4
   --         FROM WMReport WMR (NOLOCK)
   --         JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid = WMRD.reportid
   --         WHERE Storerkey = @cStorerkey
   --            AND reporttype = @cReportType
   --            AND ModuleID ='TPPack'
   --            AND ispaperprinter <> 'Y'
   --            and (WMRD.username = '' OR WMRD.username = @cUsername)
   --            AND (ISNULL(ComputerName,'') ='' OR ComputerName = @cWorkstation)
   --            AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)  

   --         IF @@ROWCOUNT = 0
   --         BEGIN
   --            SET @b_Success = 0
   --            SET @n_Err = 1002351
   --            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No records found in WMReport. Function : isp_TPS_ExtPrint03'
   --            GOTO Quit
   --         END

   --         IF ISNULL(@cFieldName1,'') = ''
   --         BEGIN
   --            SET @b_Success = 0
   --            SET @n_Err = 1002352
   --            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No value found in table(WMReport); column(keyFieldname1), this column cannot be empty or null. Function : isp_TPS_ExtPrint03'
   --            GOTO Quit
   --         END

   --         SET @IsAggregate1 = CASE WHEN ISNULL(@cFieldName1,'') <> '' AND (
   --                              UPPER(@cFieldName1) LIKE '%SUM(%' OR 
   --                              UPPER(@cFieldName1) LIKE '%AVG(%' OR
   --                              UPPER(@cFieldName1) LIKE '%COUNT(%' OR
   --                              UPPER(@cFieldName1) LIKE '%MIN(%' OR
   --                              UPPER(@cFieldName1) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
   --                           ) THEN 1 ELSE 0 END

   --         SET @IsAggregate2 = CASE WHEN ISNULL(@cFieldName2,'') <> '' AND (
   --                              UPPER(@cFieldName2) LIKE '%SUM(%' OR 
   --                              UPPER(@cFieldName2) LIKE '%AVG(%' OR
   --                              UPPER(@cFieldName2) LIKE '%COUNT(%' OR
   --                              UPPER(@cFieldName2) LIKE '%MIN(%' OR
   --                              UPPER(@cFieldName2) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
   --                           ) THEN 1 ELSE 0 END

   --         SET @IsAggregate3 = CASE WHEN ISNULL(@cFieldName3,'') <> '' AND (
   --                              UPPER(@cFieldName3) LIKE '%SUM(%' OR 
   --                              UPPER(@cFieldName3) LIKE '%AVG(%' OR
   --                              UPPER(@cFieldName3) LIKE '%COUNT(%' OR
   --                              UPPER(@cFieldName3) LIKE '%MIN(%' OR
   --                              UPPER(@cFieldName3) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
   --                           ) THEN 1 ELSE 0 END

   --         SET @IsAggregate4 = CASE WHEN ISNULL(@cFieldName4,'') <> '' AND (
   --                              UPPER(@cFieldName4) LIKE '%SUM(%' OR 
   --                              UPPER(@cFieldName4) LIKE '%AVG(%' OR
   --                              UPPER(@cFieldName4) LIKE '%COUNT(%' OR
   --                              UPPER(@cFieldName4) LIKE '%MIN(%' OR
   --                              UPPER(@cFieldName4) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
   --                           ) THEN 1 ELSE 0 END

   --         SET  @cSQL =
   --         'SELECT  @cParams1='+ @cFieldName1  
   --               SELECT @cSQL = CASE WHEN ISNULL(@cFieldName2,'') <> ''THEN @cSQL +',@cParams2 = '  + @cFieldName2  ELSE  @cSQL END 
   --               SELECT @cSQL = CASE WHEN ISNULL(@cFieldName3,'') <> ''THEN @cSQL +',@cParams3 = '  + @cFieldName3  ELSE  @cSQL END
   --               SELECT @cSQL = CASE WHEN ISNULL(@cFieldName4,'') <> ''THEN @cSQL +',@cParams4 = '  + @cFieldName4  ELSE  @cSQL END
   --         SET @cSQL = @cSQL +' FROM Packdetail (NOLOCK)
   --            WHERE Storerkey = @cstorerkey
   --               AND Pickslipno = @cPickslipno
   --               AND CartonNO = @nCartonno '

   --         SET @groupByFields = ''

   --         IF ISNULL(@cFieldName1, '') <> '' AND @IsAggregate1 = 0 AND ISNUMERIC(@cFieldName1) = 0
   --            SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName1

   --         IF ISNULL(@cFieldName2, '') <> '' AND @IsAggregate2 = 0 AND ISNUMERIC(@cFieldName2) = 0
   --            SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName2

   --         IF ISNULL(@cFieldName3, '') <> '' AND @IsAggregate3 = 0 AND ISNUMERIC(@cFieldName3) = 0
   --               SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName3

   --         IF ISNULL(@cFieldName4, '') <> '' AND @IsAggregate4 = 0 AND ISNUMERIC(@cFieldName4) = 0
   --               SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName4

   --         -- If any valid fields found, append GROUP BY
   --         IF LEN(@groupByFields) > 0
   --               SET @cSQL = @cSQL + ' GROUP BY ' + @groupByFields

   --         SET @cSQLParam = 
   --         ' @cFieldName1 NVARCHAR(max),
   --         @cFieldName2 NVARCHAR(max),
   --         @cFieldName3 NVARCHAR(max),
   --         @cFieldName4 NVARCHAR(max),
   --         @cParams1    NVARCHAR(max) OUTPUT,
   --         @cParams2    NVARCHAR(max) OUTPUT,
   --         @cParams3    NVARCHAR(max) OUTPUT,
   --         @cParams4    NVARCHAR(max) OUTPUT,
   --         @cstorerkey  NVARCHAR(20),
   --         @cPickslipno NVARCHAR(20),
   --         @nCartonno   INT'

   --         EXEC sp_ExecuteSQL @cSQL,@cSQLParam,@cFieldName1,@cFieldName2,@cFieldName3,@cFieldName4,
   --                           @cParams1 OUTPUT,@cParams2 OUTPUT,@cParams3 OUTPUT,@cParams4 OUTPUT,@cstorerkey,@cPickslipno,@nCartonno 

   --         IF ISNULL(@cNewLabelPrinter,'')= ''
   --         BEGIN
   --            SET @cNewLabelPrinter = @cLabelPrinter
   --            -- Check if printer is a group  
   --            IF EXISTS( SELECT TOP 1 1 FROM rdt.rdtPrinterGroup WITH (NOLOCK) WHERE PrinterGroup = @cLabelPrinter)  
   --            BEGIN  
   --               SET @cPrinterInGroup = ''  
  
   --               -- Check if report print to a specific printer in group  
   --               SELECT @cPrinterInGroup = PrinterID  
   --               FROM rdt.rdtReportToPrinter WITH (NOLOCK)  
   --               WHERE Function_ID = @nFunc  
   --                  AND StorerKey = @cStorerKey  
   --                  AND ReportType = @cReportType  
   --                  AND PrinterGroup = @cLabelPrinter  
  
   --               IF @cPrinterInGroup = ''  
   --               BEGIN  
   --                  -- Get default printer in the group  
   --                  SELECT @cPrinterInGroup = PrinterID  
   --                  FROM rdt.rdtPrinterGroup WITH (NOLOCK)  
   --                  WHERE PrinterGroup = @cLabelPrinter  
   --                     AND DefaultPrinter = 1  
  
   --                  -- Check no default printer  
   --                  IF @cPrinterInGroup = ''  
   --                  BEGIN  
   --                     SET @n_Err = 1002353  
   --                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') --Label Printer setup not done. Please setup the Label Printer. Function : isp_TPS_ExtPrint03  
   --                     GOTO Quit  
   --                  END  
   --               END  
   --               SET @cNewLabelPrinter = @cPrinterInGroup
   --            END
   --         END          

   --         EXEC  [WM].[lsp_WM_Print_Report]
   --         @c_ModuleID = @c_ModuleID           
   --         , @c_ReportID = @c_ReportID         
   --         , @c_Storerkey = @cStorerkey         
   --         , @c_Facility  = @cFacility        
   --         , @c_UserName  = @cUsername   
   --         , @c_ComputerName = @cWorkstation
   --         , @c_PrinterID = @cNewLabelPrinter         
   --         , @n_NoOfCopy  = '1'     
   --         , @c_KeyValue1 = @cParams1        
   --         , @c_KeyValue2 = @cParams2        
   --         , @c_KeyValue3 = @cParams3     
   --         , @c_KeyValue4 = @cParams4       
   --         , @b_Success   = @b_Success         OUTPUT      
   --         , @n_Err       = @n_Err             OUTPUT
   --         , @c_ErrMsg    = @c_ErrMsg          OUTPUT
   --         , @c_PrintSource  = @c_PrintSource        
   --         , @b_SCEPreView   = 0         
   --         , @c_JobIDs      = @nJobID         OUTPUT    
   --         , @c_AutoPrint  = 'N' 
            
   --         --To avoid the label print in sequence
   --         --EG: Labelno should print out first by use tcp method and UCC is bartender method
   --         --    but UCC print out first, 

   --         WAITFOR DELAY '00:00:02'


   --         SET @cLabelJobID = @nJobID

   --         FETCH NEXT FROM @cCurLabel INTO @cReportType

   --      END

   --      DECLARE @cCurPaper CURSOR
   --      SET @cCurPaper = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
   --      SELECT reporttype
   --      FROM WMReport WMR WITH (NOLOCK)
   --         JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid = WMRD.reportid
   --      WHERE  Storerkey = @cStorerkey
   --            AND ispaperprinter = 'Y'
   --            AND WMR.moduleid = @c_ModuleID
   --            AND (ISNULL(ComputerName,'') ='' OR ComputerName = @cWorkstation)
   --            AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)  
   --            AND Autoprint = 'Y'
   --      OPEN @cCurPaper
   --      FETCH NEXT FROM @cCurPaper INTO @cReportType
   --      WHILE @@FETCH_STATUS = 0
   --      BEGIN
   --         SELECT   @c_ReportID = WMR.reportid,
   --                  @c_PrintSource = CASE WHEN printtype = 'LOGIREPORT' THEN 'JReport' ELSE 'WMReport' END,
   --                  @cNewPaperPrinter = Defaultprinterid,
   --                  @cFieldName1  = keyFieldname1,
   --                  @cFieldName2  = keyFieldname2,
   --                  @cFieldName3  = keyFieldname3,
   --                  @cFieldName4  = keyFieldname4
   --         FROM WMReport WMR (NOLOCK)
   --         JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid
   --         WHERE Storerkey = @cStorerkey
   --            AND reporttype = @cReportType --(yeekung05)
   --            AND ModuleID ='TPPack'
   --            AND ispaperprinter = 'Y'
   --            and (WMRD.username = '' OR WMRD.username = @cUsername)
   --            AND (ISNULL(ComputerName,'') ='' OR ComputerName = @cWorkstation)
   --            AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)  

   --         IF @@ROWCOUNT = 0
   --         BEGIN
   --            SET @b_Success = 0
   --            SET @n_Err = 1002354
   --            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No records found in WMReport. Function : isp_TPS_ExtPrint03'
   --            GOTO Quit
   --         END

   --         IF ISNULL(@cFieldName1,'') = ''
   --         BEGIN
   --            SET @b_Success = 0
   --            SET @n_Err = 1002355
   --            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No value found in table(WMReport); column(keyFieldname1), this column cannot be empty or null. Function : isp_TPS_ExtPrint03'
   --            GOTO Quit
   --         END

   --         SET @IsAggregate1 = CASE WHEN ISNULL(@cFieldName1,'') <> '' AND (
   --                              UPPER(@cFieldName1) LIKE '%SUM(%' OR 
   --                              UPPER(@cFieldName1) LIKE '%AVG(%' OR
   --                              UPPER(@cFieldName1) LIKE '%COUNT(%' OR
   --                              UPPER(@cFieldName1) LIKE '%MIN(%' OR
   --                              UPPER(@cFieldName1) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
   --                           ) THEN 1 ELSE 0 END

   --         SET @IsAggregate2 = CASE WHEN ISNULL(@cFieldName2,'') <> '' AND (
   --                              UPPER(@cFieldName2) LIKE '%SUM(%' OR 
   --                              UPPER(@cFieldName2) LIKE '%AVG(%' OR
   --                              UPPER(@cFieldName2) LIKE '%COUNT(%' OR
   --                              UPPER(@cFieldName2) LIKE '%MIN(%' OR
   --                              UPPER(@cFieldName2) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
   --                           ) THEN 1 ELSE 0 END

   --         SET @IsAggregate3 = CASE WHEN ISNULL(@cFieldName3,'') <> '' AND (
   --                              UPPER(@cFieldName3) LIKE '%SUM(%' OR 
   --                              UPPER(@cFieldName3) LIKE '%AVG(%' OR
   --                              UPPER(@cFieldName3) LIKE '%COUNT(%' OR
   --                              UPPER(@cFieldName3) LIKE '%MIN(%' OR
   --                              UPPER(@cFieldName3) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
   --                           ) THEN 1 ELSE 0 END

   --         SET @IsAggregate4 = CASE WHEN ISNULL(@cFieldName4,'') <> '' AND (
   --                              UPPER(@cFieldName4) LIKE '%SUM(%' OR 
   --                              UPPER(@cFieldName4) LIKE '%AVG(%' OR
   --                              UPPER(@cFieldName4) LIKE '%COUNT(%' OR
   --                              UPPER(@cFieldName4) LIKE '%MIN(%' OR
   --                              UPPER(@cFieldName4) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
   --                           ) THEN 1 ELSE 0 END

   --         SET @cSQL = ''
   --         SET @cSQLParam = ''

   --         SET  @cSQL =
   --         'SELECT  @cParams1='+ @cFieldName1  
   --                  SELECT @cSQL = CASE WHEN ISNULL(@cFieldName2,'') <> ''THEN @cSQL +',@cParams2 = '  + @cFieldName2  ELSE  @cSQL END 
   --                  SELECT @cSQL = CASE WHEN ISNULL(@cFieldName3,'') <> ''THEN @cSQL +',@cParams3 = '  + @cFieldName3  ELSE  @cSQL END
   --                  SELECT @cSQL = CASE WHEN ISNULL(@cFieldName4,'') <> ''THEN @cSQL +',@cParams4 = '  + @cFieldName4  ELSE  @cSQL END
   --         SET @cSQL = @cSQL +' FROM Packdetail (NOLOCK)
   --            WHERE Storerkey = @cstorerkey
   --               AND Pickslipno = @cPickslipno
   --               AND CartonNo = @nCartonno '

   --         SET @groupByFields = ''

   --         IF ISNULL(@cFieldName1, '') <> '' AND @IsAggregate1 = 0 AND ISNUMERIC(@cFieldName1) = 0
   --            SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName1

   --         IF ISNULL(@cFieldName2, '') <> '' AND @IsAggregate2 = 0 AND ISNUMERIC(@cFieldName2) = 0
   --            SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName2

   --         IF ISNULL(@cFieldName3, '') <> '' AND @IsAggregate3 = 0 AND ISNUMERIC(@cFieldName3) = 0
   --               SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName3

   --         IF ISNULL(@cFieldName4, '') <> '' AND @IsAggregate4 = 0 AND ISNUMERIC(@cFieldName4) = 0
   --               SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName4

   --         -- If any valid fields found, append GROUP BY
   --         IF LEN(@groupByFields) > 0
   --               SET @cSQL = @cSQL + ' GROUP BY ' + @groupByFields

   --         SET @cSQLParam = 
   --         ' @cFieldName1 NVARCHAR(max),
   --            @cFieldName2 NVARCHAR(max),
   --            @cFieldName3 NVARCHAR(max),
   --            @cFieldName4 NVARCHAR(max),
   --            @cParams1    NVARCHAR(max) OUTPUT,
   --            @cParams2    NVARCHAR(max) OUTPUT,
   --            @cParams3    NVARCHAR(max) OUTPUT,
   --            @cParams4    NVARCHAR(max) OUTPUT,
   --            @cstorerkey  NVARCHAR(20),
   --            @cPickslipno NVARCHAR(20),
   --            @nCartonno   INT'

   --         EXEC sp_ExecuteSQL @cSQL,@cSQLParam,@cFieldName1,@cFieldName2,@cFieldName3,@cFieldName4,
   --                              @cParams1 OUTPUT,@cParams2 OUTPUT,@cParams3 OUTPUT,@cParams4 OUTPUT,@cstorerkey,@cPickslipno,@nCartonno 
               
   --         IF ISNULL(@cNewPaperPrinter,'')= ''
   --         BEGIN
   --            SET @cNewPaperPrinter = @cPaperPrinter
   --            -- Check if printer is a group  
   --            IF EXISTS( SELECT TOP 1 1 FROM rdt.rdtPrinterGroup WITH (NOLOCK) WHERE PrinterGroup = @cPaperPrinter)  
   --            BEGIN  
   --               SET @cPrinterInGroup = ''  
  
   --               -- Check if report print to a specific printer in group  
   --               SELECT @cPrinterInGroup = PrinterID  
   --               FROM rdt.rdtReportToPrinter WITH (NOLOCK)  
   --               WHERE Function_ID = @nFunc  
   --                  AND StorerKey = @cStorerKey  
   --                  AND ReportType = @cReportType  
   --                  AND PrinterGroup = @cPaperPrinter  
  
   --               IF @cPrinterInGroup = ''  
   --               BEGIN  
   --                  -- Get default printer in the group  
   --                  SELECT @cPrinterInGroup = PrinterID  
   --                  FROM rdt.rdtPrinterGroup WITH (NOLOCK)  
   --                  WHERE PrinterGroup = @cPaperPrinter  
   --                     AND DefaultPrinter = 1  
  
   --                  -- Check no default printer  
   --                  IF @cPrinterInGroup = ''  
   --                  BEGIN  
   --                     SET @n_Err = 1002356  
   --                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') --Paper Printer setup not done. Please setup the Paper Printer. Function : isp_TPS_ExtPrint03  
   --                     GOTO Quit  
   --                  END  
   --               END  
   --               SET @cNewPaperPrinter = @cPrinterInGroup
   --            END
   --         END           

   --         EXEC  [WM].[lsp_WM_Print_Report]
   --            @c_ModuleID    = @c_ModuleID           
   --         , @c_ReportID     = @c_ReportID         
   --         , @c_Storerkey    = @cStorerkey         
   --         , @c_Facility     = @cFacility        
   --         , @c_UserName     = @cUsername     
   --         , @c_ComputerName = @cWorkstation
   --         , @c_PrinterID    = @cNewPaperPrinter         
   --         , @n_NoOfCopy     = '1'     
   --         , @c_KeyValue1    = @cParams1        
   --         , @c_KeyValue2    = @cParams2     
   --         , @c_KeyValue3    = @cParams3 
   --         , @c_KeyValue4    = @cParams4
   --         , @b_Success      = @b_Success         OUTPUT      
   --         , @n_Err          = @n_Err             OUTPUT
   --         , @c_ErrMsg       = @c_ErrMsg          OUTPUT
   --         , @c_PrintSource  = @c_PrintSource        
   --         , @b_SCEPreView   = 0         
   --         , @c_JobIDs       = @nJobID         OUTPUT    
   --         , @c_AutoPrint    = 'N'   
                     
   --         SET @cPackingJobID = @nJobID 

   --         FETCH NEXT FROM @cCurPaper INTO @cReportType
   --      END




   --IF @bPrintLabelFlag = 1
   --BEGIN
   --   SELECT @cCustomLabelSP = sValue
   --   FROM  STORERCONFIG (NOLOCK)
   --   WHERE StorerKey = @cStorerKey
   --   AND ConfigKey = 'TPS-labelSP'
      
   --   IF @@ROWCOUNT = 0
   --   BEGIN
   --      SET @cReportType = 'TPSHIPPLBL'
   --      IF NOT EXISTS ( SELECT 1
   --                  FROM WMREPORT WMR (NOLOCK) 
   --                  JOIN WMREPORTDETAIL WMRD (NOLOCK) 
   --                  ON WMR.ReportID =WMRD.ReportID
   --                  WHERE WMRD.StorerKey  = @cStorerKey 
   --                  AND WMR.ReportType = @cReportType
   --                  AND WMR.ModuleID = @cModuleID
   --                  AND WMRD.IsPaperPrinter <> 'Y'
   --                  AND (WMRD.UserName = '' OR WMRD.UserName = @c_UserID)
   --                  AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility) 
   --      )  
   --      BEGIN 
   --         SET @n_Continue = 3
   --         SET @n_ErrNo = 11851
   --         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Label: No records found in WMReport.'
   --         GOTO EXIT_SP
   --      END

   --      SELECT  @cReportID         = WMR.ReportID
   --            , @cPrintSource      = IIF(WMRD.PrintType ='LOGIREPORT', 'JReport', 'WMReport')
   --            , @cDefaultPrinterID = ISNULL(WMRD.DefaultPrinterID, '')
   --            , @cFieldName1       = ISNULL(WMR.KeyFieldName1, '')
   --            , @cFieldName2       = ISNULL(WMR.KeyFieldName2, '')
   --            , @cFieldName3       = ISNULL(WMR.KeyFieldName3, '')
   --            , @cFieldName4       = ISNULL(WMR.KeyFieldName4, '')
   --      FROM WMREPORT WMR (NOLOCK)
   --      JOIN WMREPORTDETAIL WMRD (NOLOCK) 
   --      ON WMR.ReportID = WMRD.ReportID
   --      WHERE WMRD.Storerkey = @cStorerKeyx
   --      AND WMR.ReportType = @cReportType
   --      AND WMR.ModuleID = @cModuleID
   --      AND WMRD.IsPaperPrinter <> 'Y'
   --      AND (WMRD.UserName = '' OR WMRD.UserName = @c_UserID)
   --      AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility) 

   --      IF @cFieldName1 = ''
   --      BEGIN
   --         SET @n_Continue = 3
   --         SET @n_ErrNo = 11852
   --         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Label: No value found in table(WMReport); column(keyFieldname1), this column cannot be empty or null.'
   --         GOTO EXIT_SP
   --      END       
         
   --      SET @IsAggregate1 = CASE WHEN @cFieldName1 <> '' AND (
   --                           UPPER(@cFieldName1) LIKE '%SUM(%' OR 
   --                           UPPER(@cFieldName1) LIKE '%AVG(%' OR
   --                           UPPER(@cFieldName1) LIKE '%COUNT(%' OR
   --                           UPPER(@cFieldName1) LIKE '%MIN(%' OR
   --                           UPPER(@cFieldName1) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
   --                        ) THEN 1 ELSE 0 END

   --      SET @IsAggregate2 = CASE WHEN @cFieldName2 <> '' AND (
   --                           UPPER(@cFieldName2) LIKE '%SUM(%' OR 
   --                           UPPER(@cFieldName2) LIKE '%AVG(%' OR
   --                           UPPER(@cFieldName2) LIKE '%COUNT(%' OR
   --                           UPPER(@cFieldName2) LIKE '%MIN(%' OR
   --                           UPPER(@cFieldName2) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
   --                        ) THEN 1 ELSE 0 END

   --      SET @IsAggregate3 = CASE WHEN @cFieldName3 <> '' AND (
   --                           UPPER(@cFieldName3) LIKE '%SUM(%' OR 
   --                           UPPER(@cFieldName3) LIKE '%AVG(%' OR
   --                           UPPER(@cFieldName3) LIKE '%COUNT(%' OR
   --                           UPPER(@cFieldName3) LIKE '%MIN(%' OR
   --                           UPPER(@cFieldName3) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
   --                        ) THEN 1 ELSE 0 END

   --      SET @IsAggregate4 = CASE WHEN @cFieldName4 <> '' AND (
   --                           UPPER(@cFieldName4) LIKE '%SUM(%' OR 
   --                           UPPER(@cFieldName4) LIKE '%AVG(%' OR
   --                           UPPER(@cFieldName4) LIKE '%COUNT(%' OR
   --                           UPPER(@cFieldName4) LIKE '%MIN(%' OR
   --                           UPPER(@cFieldName4) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
   --                        ) THEN 1 ELSE 0 END

   --      IF EXISTS(SELECT 1
   --                FROM STORERCONFIG (NOLOCK)
   --                WHERE StorerKey = @cStorerKey
   --                AND ConfigKey = 'TPS-PrintAfterPacked'
   --                AND sValue = '1'
   --      )  
   --      BEGIN 
   --         SET  @cSQL = ' SELECT  @cParams1 = '+ @cFieldName1  
   --                  SELECT @cSQL = IIF(@cFieldName2 <> '', @cSQL + ',@cParams2=' + @cFieldName2, @cSQL) 
   --                  SELECT @cSQL = IIF(@cFieldName3 <> '', @cSQL + ',@cParams3=' + @cFieldName3, @cSQL)
   --                  SELECT @cSQL = IIF(@cFieldName4 <> '', @cSQL + ',@cParams4=' + @cFieldName4, @cSQL)
   --         SET @cSQL = @cSQL 
   --                   + ' FROM PACKDETAIL (NOLOCK) '
   --                   + ' WHERE StorerKey = @cStorerKey '
   --                   + ' AND PickSlipNo = @cPickSlipNo '
   --      END
   --      ELSE
   --      BEGIN 
   --         SET  @cSQL = ' SELECT  @cParams1 = '+ @cFieldName1  
   --                  SELECT @cSQL = IIF(@cFieldName2 <> '', @cSQL + ',@cParams2=' + @cFieldName2, @cSQL) 
   --                  SELECT @cSQL = IIF(@cFieldName3 <> '', @cSQL + ',@cParams3=' + @cFieldName3, @cSQL)
   --                  SELECT @cSQL = IIF(@cFieldName4 <> '', @cSQL + ',@cParams4=' + @cFieldName4, @cSQL)
   --         SET @cSQL = @cSQL 
   --                   + ' FROM PACKDETAIL (NOLOCK) '
   --                   + ' WHERE StorerKey = @cStorerKey '
   --                   + ' AND PickSlipNo = @cPickSlipNo '
   --                   + ' AND CartonNo = @nCartonNo '
   --      END

   --      SET @groupByFields = ''

   --      IF @cFieldName1 <> '' AND @IsAggregate1 = 0 AND ISNUMERIC(@cFieldName1) = 0
   --         SET @groupByFields = @groupByFields + IIF(LEN(@groupByFields) > 0, ', ', '') + @cFieldName1

   --      IF @cFieldName2 <> '' AND @IsAggregate2 = 0 AND ISNUMERIC(@cFieldName2) = 0
   --         SET @groupByFields = @groupByFields + IIF(LEN(@groupByFields) > 0, ', ', '') + @cFieldName2

   --      IF @cFieldName3 <> '' AND @IsAggregate3 = 0 AND ISNUMERIC(@cFieldName3) = 0
   --            SET @groupByFields = @groupByFields + IIF(LEN(@groupByFields) > 0, ', ', '') + @cFieldName3

   --      IF @cFieldName4 <> '' AND @IsAggregate4 = 0 AND ISNUMERIC(@cFieldName4) = 0
   --            SET @groupByFields = @groupByFields + IIF(LEN(@groupByFields) > 0, ', ', '') + @cFieldName4

   --      -- If any valid fields found, append GROUP BY
   --      IF LEN(@groupByFields) > 0
   --            SET @cSQL = @cSQL + ' GROUP BY ' + @groupByFields

   --      SET @cSQLParam = '  @cFieldName1 NVARCHAR(MAX) '
   --                     + ', @cFieldName2 NVARCHAR(MAX) '
   --                     + ', @cFieldName3 NVARCHAR(MAX) '
   --                     + ', @cFieldName4 NVARCHAR(MAX) '
   --                     + ', @cParams1    NVARCHAR(MAX) OUTPUT '
   --                     + ', @cParams2    NVARCHAR(MAX) OUTPUT '
   --                     + ', @cParams3    NVARCHAR(MAX) OUTPUT '
   --                     + ', @cParams4    NVARCHAR(MAX) OUTPUT '
   --                     + ', @cStorerKey  NVARCHAR(20) '
   --                     + ', @cPickSlipNo NVARCHAR(20) '
   --                     + ', @nCartonNo   INT '

   --      EXEC sp_ExecuteSQL  @cSQL
   --                        , @cSQLParam
   --                        , @cFieldName1
   --                        , @cFieldName2
   --                        , @cFieldName3
   --                        , @cFieldName4
   --                        , @cParams1     OUTPUT
   --                        , @cParams2     OUTPUT
   --                        , @cParams3     OUTPUT
   --                        , @cParams4     OUTPUT
   --                        , @cStorerKey
   --                        , @cPickSlipNo
   --                        , @nCartonNo 

   --      IF @cDefaultPrinterID = ''
   --      BEGIN
   --         -- Check if printer is a group  
   --         IF EXISTS(  SELECT 1 
   --                     FROM rdt.RDTPRINTERGROUP (NOLOCK) 
   --                     WHERE PrinterGroup = @cLabelPrinter
   --         )  
   --         BEGIN  
   --            SET @cPrinterInGroup = ''  

   --            -- Check if report print to a specific printer in group  
   --            SELECT @cPrinterInGroup = PrinterID  
   --            FROM rdt.RDTREPORTTOPRINTER (NOLOCK)  
   --            WHERE Function_ID = '838'  
   --            AND StorerKey = @cStorerKey  
   --            AND ReportType = @cReportType
   --            AND PrinterGroup = @cLabelPrinter  

   --            IF @cPrinterInGroup = ''  
   --            BEGIN  
   --               -- Get default printer in the group  
   --               SELECT @cPrinterInGroup = PrinterID  
   --               FROM rdt.RDTPRINTERGROUP (NOLOCK)  
   --               WHERE PrinterGroup = @cLabelPrinter  
   --               AND DefaultPrinter = 1  
   --            END  

   --            -- Check no default printer
   --            IF @cPrinterInGroup = ''  
   --            BEGIN  
   --               SET @n_Continue = 3
   --               SET @n_ErrNo = 11853    
   --               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Not found PrinterID in PrinterGroup.'  
   --               GOTO EXIT_SP  
   --            END

   --            SET @cLabelPrinter = @cPrinterInGroup
   --         END
   --      END
   --      ELSE
   --      BEGIN
   --         SET @cLabelPrinter = @cDefaultPrinterID
   --      END

   --      EXEC  [WM].[lsp_WM_Print_Report]
   --              @c_ModuleID     = @cModuleID           
   --            , @c_ReportID     = @cReportID         
   --            , @c_Storerkey    = @cStorerKey         
   --            , @c_Facility     = @cFacility        
   --            , @c_UserName     = @c_UserID   
   --            , @c_ComputerName = ''
   --            , @c_PrinterID    = @cLabelPrinter         
   --            , @n_NoOfCopy     = '1'     
   --            , @c_KeyValue1    = @cParams1        
   --            , @c_KeyValue2    = @cParams2        
   --            , @c_KeyValue3    = @cParams3     
   --            , @c_KeyValue4    = @cParams4    
   --            , @b_Success      = @b_Success            OUTPUT      
   --            , @n_Err          = @n_ErrNo              OUTPUT
   --            , @c_ErrMsg       = @c_ErrMsg             OUTPUT
   --            , @c_PrintSource  = @cPrintSource        
   --            , @b_SCEPreView   = 0         
   --            , @c_JobIDs       = @cPrintLabelJobIDs    OUTPUT    
   --            , @c_AutoPrint    = 'N'     
            
   --      IF @n_ErrNo <> 0   
   --      BEGIN  
   --         SET @n_Continue = 3
   --         SET @n_ErrNo = @n_ErrNo  
   --         SET @c_ErrMsg = @c_ErrMsg  
   --         GOTO EXIT_SP  
   --      END
      
   --      --IF @cPrintLabelJobIDs <> ''
   --      --BEGIN
   --      --   SET @cPrintLabelJobIDs = ISNULL ((JSON_QUERY((SELECT [value]
   --      --                            FROM STRING_SPLIT(@cPrintLabelJobIDs, '|')
   --      --                            FOR JSON PATH ))
   --      --                            ),'')
   --      --END
   --   END
   --   ELSE
   --   BEGIN
   --      IF NOT EXISTS (SELECT 1 
   --                     FROM dbo.sysobjects 
   --                     WHERE [name] = @cCustomLabelSP 
   --                     AND [type] = 'P'
   --      )
   --      BEGIN
   --         SET @n_Continue = 3
   --         SET @n_ErrNo = 11857
   --         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Invalid Custom Label SP Name in StorerConfig.'
   --         GOTO EXIT_SP
   --      END

   --      SET @cSQL = 'EXEC ' + RTRIM( @cCustomLabelSP)   
   --                + '  @cStorerKey    = @cStorerKey      ' + CHAR(13)
   --                + ', @cFacility     = @cFacility       ' + CHAR(13)
   --                + ', @cUserName     = @c_UserID        ' + CHAR(13)
   --                + ', @cPickSlipNo   = @cPickSlipNo     ' + CHAR(13)
   --                + ', @cLabelPrinter = @cLabelPrinter   ' + CHAR(13)
   --                + ', @cPaperPrinter = @cPaperPrinter   ' + CHAR(13)
   --                + ', @nErrNo        = @n_ErrNo  OUTPUT ' + CHAR(13)
   --                + ', @cErrMsg       = @c_ErrMsg OUTPUT ' + CHAR(13)   

   --      SET @cSQLParam = '  @cStorerKey      NVARCHAR(15)         ' + CHAR(13)   
   --                     + ', @cFacility       NVARCHAR(5)          ' + CHAR(13) 
   --                     + ', @c_UserID        NVARCHAR(256)        ' + CHAR(13)     
   --                     + ', @cPickSlipNo     NVARCHAR(30)         ' + CHAR(13)   
   --                     + ', @cLabelPrinter   NVARCHAR(30)         ' + CHAR(13)   
   --                     + ', @cPaperPrinter   NVARCHAR(30)         ' + CHAR(13)   
   --                     + ', @n_ErrNo         INT           OUTPUT ' + CHAR(13)   
   --                     + ', @c_ErrMsg        NVARCHAR(250) OUTPUT ' + CHAR(13)    
    
   --      EXEC sp_ExecuteSQL  @cSQL
   --                        , @cSQLParam    
   --                        , @cStorerKey
   --                        , @cFacility
   --                        , @c_UserID
   --                        , @cPickSlipNo
   --                        , @cLabelPrinter
   --                        , @cPaperPrinter
   --                        , @n_ErrNo        OUTPUT
   --                        , @c_ErrMsg       OUTPUT  
                             
   --      IF @n_ErrNo <> 0   
   --      BEGIN  
   --         SET @n_Continue = 3
   --         SET @n_ErrNo = @n_ErrNo  
   --         SET @c_ErrMsg = @c_ErrMsg  
   --         GOTO EXIT_SP  
   --      END 
   --   END

   --   IF EXISTS ( SELECT  1 
   --               FROM WMREPORT WMR (NOLOCK) 
   --               JOIN WMREPORTDETAIL WMRD (NOLOCK) 
   --               ON WMR.ReportID =WMRD.ReportID
   --               WHERE WMRD.StorerKey = @cStorerKey
   --               AND WMR.ReportType = 'TPCtnLbl'
   --               AND WMR.ModuleID = @cModuleID
   --               AND WMRD.IsPaperPrinter <> 'Y'
   --               AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility) 
   --   )   
   --   BEGIN  
   --      SELECT @cReportID = WMR.ReportID
   --           , @cPrintSource = IIF(WMRD.PrintType ='LOGIREPORT', 'JReport', 'WMReport')
   --           , @cDefaultPrinterID = ISNULL(WMRD.DefaultPrinterID, @cLabelPrinter)
   --      FROM WMREPORT WMR (NOLOCK)
   --      JOIN WMREPORTDETAIL WMRD (NOLOCK) 
   --      ON WMR.ReportID =WMRD.ReportID
   --      WHERE WMRD.StorerKey = @cStorerKey
   --      AND WMR.ReportType = 'TPCtnLbl'
   --      AND WMR.ModuleID = @cModuleID
   --      AND WMRD.IsPaperPrinter <> 'Y'
   --      AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility) 

   --      EXEC  [WM].[lsp_WM_Print_Report]
   --         @c_ModuleID       = @cModuleID           
   --         , @c_ReportID     = @cReportID         
   --         , @c_Storerkey    = @cStorerKey         
   --         , @c_Facility     = @cFacility        
   --         , @c_UserName     = @c_UserID          
   --         , @c_ComputerName = ''
   --         , @c_PrinterID    = @cDefaultPrinterID         
   --         , @n_NoOfCopy     = '1'     
   --         , @c_KeyValue1    = @cPickSlipNo        
   --         , @c_KeyValue2    = ''     
   --         , @c_KeyValue3    = ''     
   --         , @c_KeyValue4    = ''     
   --         , @b_Success      = @b_Success         OUTPUT      
   --         , @n_Err          = @n_ErrNo           OUTPUT
   --         , @c_ErrMsg       = @c_ErrMsg          OUTPUT
   --         , @c_PrintSource  = @cPrintSource        
   --         , @b_SCEPreView   = 0         
   --         , @c_JobIDs       = @cTPCtnLabelJobIDs OUTPUT    
   --         , @c_AutoPrint    = 'N'    
  
   --      IF @n_ErrNo <> 0   
   --      BEGIN  
   --         SET @n_Continue = 3
   --         SET @n_ErrNo = @n_ErrNo  
   --         SET @c_ErrMsg = @c_ErrMsg  
   --         GOTO EXIT_SP  
   --      END
   --      SET @cPrintLabelJobIDs = IIF(@cPrintLabelJobIDs <> '', @cPrintLabelJobIDs + '|' + @cTPCtnLabelJobIDs, @cTPCtnLabelJobIDs)
   --   END
   --END

   --SET @cSQL = ''
   --SET @cSQLParam = ''

   --IF @bPrintPaperFlag = 1
   --BEGIN
   --   SET @cReportType = 'TPPACKLIST'
   --   IF NOT EXISTS ( SELECT 1 
   --               FROM WMREPORT WMR (NOLOCK) 
   --               JOIN WMREPORTDETAIL WMRD (NOLOCK)  
   --               ON WMR.ReportID =WMRD.ReportID
   --               WHERE WMRD.StorerKey  = @cStorerKey 
   --               AND WMR.ReportType = @cReportType
   --               AND WMR.ModuleID = @cModuleID
   --               AND WMRD.IsPaperPrinter = 'Y'
   --               AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility) 
   --   )  
   --   BEGIN
   --      SET @n_Continue = 3
   --      SET @n_ErrNo = 11854
   --      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Paper: No records found in WMReport.'
   --      GOTO EXIT_SP
   --   END

   --   SELECT  @cReportID         = WMR.ReportID
   --         , @cPrintSource      = IIF(WMRD.PrintType ='LOGIREPORT', 'JReport', 'WMReport')
   --         , @cDefaultPrinterID = ISNULL(WMRD.DefaultPrinterID, '')
   --         , @cFieldName1       = ISNULL(WMR.KeyFieldName1, '')
   --         , @cFieldName2       = ISNULL(WMR.KeyFieldName2, '')
   --         , @cFieldName3       = ISNULL(WMR.KeyFieldName3, '')
   --         , @cFieldName4       = ISNULL(WMR.KeyFieldName4, '')
   --   FROM WMREPORT WMR (NOLOCK)
   --   JOIN WMREPORTDETAIL WMRD (NOLOCK) 
   --   ON WMR.ReportID = WMRD.ReportID
   --   WHERE WMRD.Storerkey = @cStorerKey
   --   AND WMR.ReportType = @cReportType
   --   AND WMR.ModuleID = @cModuleID
   --   AND WMRD.IsPaperPrinter = 'Y'
   --   AND (WMRD.UserName = '' OR WMRD.UserName = @c_UserID)
   --   AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility) 

   --   IF @cFieldName1 = ''
   --   BEGIN
   --      SET @n_Continue = 3
   --      SET @n_ErrNo = 11855
   --      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Paper: No value found in table(WMReport); column(keyFieldname1), this column cannot be empty or null.'
   --      GOTO EXIT_SP
   --   END       

   --   SET @IsAggregate1 = CASE WHEN @cFieldName1 <> '' AND (
   --                        UPPER(@cFieldName1) LIKE '%SUM(%' OR 
   --                        UPPER(@cFieldName1) LIKE '%AVG(%' OR
   --                        UPPER(@cFieldName1) LIKE '%COUNT(%' OR
   --                        UPPER(@cFieldName1) LIKE '%MIN(%' OR
   --                        UPPER(@cFieldName1) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
   --                     ) THEN 1 ELSE 0 END

   --   SET @IsAggregate2 = CASE WHEN @cFieldName2 <> '' AND (
   --                        UPPER(@cFieldName2) LIKE '%SUM(%' OR 
   --                        UPPER(@cFieldName2) LIKE '%AVG(%' OR
   --                        UPPER(@cFieldName2) LIKE '%COUNT(%' OR
   --                        UPPER(@cFieldName2) LIKE '%MIN(%' OR
   --                        UPPER(@cFieldName2) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
   --                     ) THEN 1 ELSE 0 END

   --   SET @IsAggregate3 = CASE WHEN @cFieldName3 <> '' AND (
   --                        UPPER(@cFieldName3) LIKE '%SUM(%' OR 
   --                        UPPER(@cFieldName3) LIKE '%AVG(%' OR
   --                        UPPER(@cFieldName3) LIKE '%COUNT(%' OR
   --                        UPPER(@cFieldName3) LIKE '%MIN(%' OR
   --                        UPPER(@cFieldName3) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
   --                     ) THEN 1 ELSE 0 END

   --   SET @IsAggregate4 = CASE WHEN @cFieldName4 <> '' AND (
   --                        UPPER(@cFieldName4) LIKE '%SUM(%' OR 
   --                        UPPER(@cFieldName4) LIKE '%AVG(%' OR
   --                        UPPER(@cFieldName4) LIKE '%COUNT(%' OR
   --                        UPPER(@cFieldName4) LIKE '%MIN(%' OR
   --                        UPPER(@cFieldName4) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
   --                     ) THEN 1 ELSE 0 END

   --   SET  @cSQL = ' SELECT  @cParams1 = '+ @cFieldName1  
   --               SELECT @cSQL = IIF(@cFieldName2 <> '', @cSQL + ',@cParams2=' + @cFieldName2, @cSQL) 
   --               SELECT @cSQL = IIF(@cFieldName3 <> '', @cSQL + ',@cParams3=' + @cFieldName3, @cSQL)
   --               SELECT @cSQL = IIF(@cFieldName4 <> '', @cSQL + ',@cParams4=' + @cFieldName4, @cSQL)
   --   SET @cSQL = @cSQL 
   --             + ' FROM PACKDETAIL (NOLOCK) '
   --             + ' WHERE StorerKey = @cStorerKey '
   --             + ' AND PickSlipNo = @cPickSlipNo '
   --             + ' AND CartonNo = @nCartonNo '

   --   SET @groupByFields = ''

   --   IF @cFieldName1 <> '' AND @IsAggregate1 = 0 AND ISNUMERIC(@cFieldName1) = 0
   --      SET @groupByFields = @groupByFields + IIF(LEN(@groupByFields) > 0, ', ', '') + @cFieldName1

   --   IF @cFieldName2 <> '' AND @IsAggregate2 = 0 AND ISNUMERIC(@cFieldName2) = 0
   --      SET @groupByFields = @groupByFields + IIF(LEN(@groupByFields) > 0, ', ', '') + @cFieldName2

   --   IF @cFieldName3 <> '' AND @IsAggregate3 = 0 AND ISNUMERIC(@cFieldName3) = 0
   --         SET @groupByFields = @groupByFields + IIF(LEN(@groupByFields) > 0, ', ', '') + @cFieldName3

   --   IF @cFieldName4 <> '' AND @IsAggregate4 = 0 AND ISNUMERIC(@cFieldName4) = 0
   --         SET @groupByFields = @groupByFields + IIF(LEN(@groupByFields) > 0, ', ', '') + @cFieldName4

   --   -- If any valid fields found, append GROUP BY
   --   IF LEN(@groupByFields) > 0
   --         SET @cSQL = @cSQL + ' GROUP BY ' + @groupByFields

   --   SET @cSQLParam = '  @cFieldName1 NVARCHAR(MAX) '
   --                  + ', @cFieldName2 NVARCHAR(MAX) '
   --                  + ', @cFieldName3 NVARCHAR(MAX) '
   --                  + ', @cFieldName4 NVARCHAR(MAX) '
   --                  + ', @cParams1    NVARCHAR(MAX) OUTPUT '
   --                  + ', @cParams2    NVARCHAR(MAX) OUTPUT '
   --                  + ', @cParams3    NVARCHAR(MAX) OUTPUT '
   --                  + ', @cParams4    NVARCHAR(MAX) OUTPUT '
   --                  + ', @cStorerKey  NVARCHAR(20) '
   --                  + ', @cPickSlipNo NVARCHAR(20) '
   --                  + ', @nCartonNo   INT '

   --   EXEC sp_ExecuteSQL  @cSQL
   --                     , @cSQLParam
   --                     , @cFieldName1
   --                     , @cFieldName2
   --                     , @cFieldName3
   --                     , @cFieldName4
   --                     , @cParams1     OUTPUT
   --                     , @cParams2     OUTPUT
   --                     , @cParams3     OUTPUT
   --                     , @cParams4     OUTPUT
   --                     , @cStorerKey
   --                     , @cPickSlipNo
   --                     , @nCartonNo 

   --   IF @cDefaultPrinterID = ''
   --   BEGIN
   --      -- Check if printer is a group  
   --      IF EXISTS(  SELECT 1 
   --                  FROM rdt.RDTPRINTERGROUP (NOLOCK) 
   --                  WHERE PrinterGroup = @cPaperPrinter
   --      )  
   --      BEGIN  
   --         SET @cPrinterInGroup = ''  

   --         -- Check if report print to a specific printer in group  
   --         SELECT @cPrinterInGroup = PrinterID  
   --         FROM rdt.RDTREPORTTOPRINTER (NOLOCK)  
   --         WHERE Function_ID = '838'  
   --         AND StorerKey = @cStorerKey  
   --         AND ReportType = @cReportType
   --         AND PrinterGroup = @cPaperPrinter  

   --         IF @cPrinterInGroup = ''  
   --         BEGIN  
   --            -- Get default printer in the group  
   --            SELECT @cPrinterInGroup = PrinterID  
   --            FROM rdt.RDTPRINTERGROUP (NOLOCK)  
   --            WHERE PrinterGroup = @cPaperPrinter  
   --            AND DefaultPrinter = 1  
   --         END  

   --         -- Check no default printer
   --         IF @cPrinterInGroup = ''  
   --         BEGIN  
   --            SET @n_Continue = 3
   --            SET @n_ErrNo = 11856    
   --            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Paper: Not found PrinterID in PrinterGroup.'  
   --            GOTO EXIT_SP  
   --         END

   --         SET @cPaperPrinter = @cPrinterInGroup
   --      END
   --   END
   --   ELSE
   --   BEGIN
   --      SET @cPaperPrinter = @cDefaultPrinterID
   --   END

   --   EXEC  [WM].[lsp_WM_Print_Report]
   --           @c_ModuleID     = @cModuleID           
   --         , @c_ReportID     = @cReportID         
   --         , @c_Storerkey    = @cStorerKey         
   --         , @c_Facility     = @cFacility        
   --         , @c_UserName     = @c_UserID   
   --         , @c_ComputerName = ''
   --         , @c_PrinterID    = @cPaperPrinter         
   --         , @n_NoOfCopy     = '1'     
   --         , @c_KeyValue1    = @cParams1        
   --         , @c_KeyValue2    = @cParams2        
   --         , @c_KeyValue3    = @cParams3     
   --         , @c_KeyValue4    = @cParams4    
   --         , @b_Success      = @b_Success            OUTPUT      
   --         , @n_Err          = @n_ErrNo              OUTPUT
   --         , @c_ErrMsg       = @c_ErrMsg             OUTPUT
   --         , @c_PrintSource  = @cPrintSource        
   --         , @b_SCEPreView   = 0         
   --         , @c_JobIDs       = @cPrintPaperJobIDs    OUTPUT    
   --         , @c_AutoPrint    = 'N'     
      
   --   IF @n_ErrNo <> 0   
   --   BEGIN  
   --      SET @n_Continue = 3
   --      SET @n_ErrNo = @n_ErrNo  
   --      SET @c_ErrMsg = @c_ErrMsg  
   --      GOTO EXIT_SP  
   --   END   
      
   --   --IF @cPrintPaperJobIDs <> ''
   --   --BEGIN
   --   --   SET @cPrintPaperJobIDs = ISNULL ((JSON_QUERY((SELECT value
   --   --                            FROM STRING_SPLIT(@cPrintPaperJobIDs, '|')
   --   --                            FOR JSON PATH ))
   --   --                            ),'')
   --   --END
   --END

EXIT_SP:
   IF @n_Continue = 3  -- Error Occured - Process And Return      
   BEGIN      
      SET @b_Success = 0      
      IF @@TRANCOUNT > @n_StartCnt AND @@TRANCOUNT = 1 
      BEGIN               
         ROLLBACK TRAN      
      END      
      ELSE      
      BEGIN      
         WHILE @@TRANCOUNT > @n_StartCnt      
         BEGIN      
            COMMIT TRAN      
         END      
      END   
      RETURN      
   END      
   ELSE      
   BEGIN      
      SELECT @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END