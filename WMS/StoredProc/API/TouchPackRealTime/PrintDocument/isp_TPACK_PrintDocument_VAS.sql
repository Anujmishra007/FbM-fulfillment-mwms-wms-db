SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_PrintDocument_Std                                  */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Specific reports printing function by VAS Code               */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-11-14   1.0  YLI237     UWP-43135                                        */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_PrintDocument_VAS] (
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
   , @cSku                 NVARCHAR(50)      = ''
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
         , @ctempLabelJobIDs     NVARCHAR(MAX)
         , @cUDF04Value          NVARCHAR(MAX)
         , @cCode2               NVARCHAR(50)
         , @cConsigneeKey        NVARCHAR(50)
         , @cMarkForKey          NVARCHAR(50)
         , @cBillToKey           NVARCHAR(50)
         , @cFinalUDF01          NVARCHAR(MAX)
         , @cVASPrintUDF01       NVARCHAR(MAX)
   
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

   -- Variables for workflow implementation
   DECLARE @cTypeFromWOD      NVARCHAR(30)
         , @cUDF01Value       NVARCHAR(MAX)
         , @cParsedReportID   NVARCHAR(10)
         , @cParsedReportLineNo NVARCHAR(10)
   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = '' 
   SET @cSQL               = ''
   SET @cSQLParam          = ''
   SET @cModuleID          = 'TPPACK'
   SET @cCustomLabelSP     = ''

   SELECT @cConsigneeKey = ConsigneeKey, @cMarkForKey = MarkForKey, @cBillToKey = BillToKey
   FROM Orders (NOLOCK)
   WHERE OrderKey = @cOrderKey
     AND StorerKey = @cStorerKey

   DECLARE @VASReports TABLE (
      ReportID         NVARCHAR(10),
      ReportLineNo     INT,
      PrintSource      NVARCHAR(30),
      DefaultPrinterID NVARCHAR(30),
      IsPaperPrinter   CHAR(1),
      KeyFieldName1    NVARCHAR(MAX),
      KeyFieldName2    NVARCHAR(MAX),
      KeyFieldName3    NVARCHAR(MAX),
      KeyFieldName4    NVARCHAR(MAX)
   )

   -- Group WorkOrderDetails by Type
   -- Process each type group through the workflow
   DECLARE type_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT DISTINCT Type
   FROM WorkOrderDetail (NOLOCK)
   WHERE ExternWorkOrderKey = @cOrderKey
     AND StorerKey = @cStorerKey
     AND (@cSku = '' OR SKU = @cSku)

   OPEN type_cursor
   FETCH NEXT FROM type_cursor INTO @cTypeFromWOD

   WHILE @@FETCH_STATUS = 0
   BEGIN
      -- Initialize variables
      SET @cUDF01Value = ''
      SET @cUDF04Value = ''
      SET @cFinalUDF01 = ''

      -- Query CodeLookup table for the current type
      SELECT @cUDF01Value = CL.UDF01
           , @cUDF04Value = CL.UDF04
      FROM CodeLkup CL (NOLOCK)
      WHERE CL.Listname = 'WKOrdType'
        AND CL.Code = @cTypeFromWOD
        AND (CL.StorerKey = '' OR CL.StorerKey = @cStorerKey)
      
      -- Check if we got a UDF01 value
      IF @cUDF01Value IS NOT NULL AND @cUDF01Value <> ''
      BEGIN
         SET @cFinalUDF01 = @cUDF01Value

         -- Logic for UDF04 check
         IF @cUDF04Value <> 'pricelb'
         BEGIN
            SET @cVASPrintUDF01 = ''
            SET @cCode2 = ''

            SELECT @cVASPrintUDF01 = UDF01, @cCode2 = Code2
            FROM CodeLkup (NOLOCK)
            WHERE Listname = 'VASPrintCP'
              AND Long = @cTypeFromWOD
              AND Short = @cUDF04Value
              AND StorerKey = @cStorerKey

            IF @@ROWCOUNT > 0
            BEGIN
               IF @cCode2 = @cConsigneeKey OR @cCode2 = @cMarkForKey OR @cCode2 = @cBillToKey
               BEGIN
                  SET @cFinalUDF01 = @cVASPrintUDF01
               END
            END
         END

         -- Parse UDF01 value to extract ReportID and ReportLineNo
         -- Format: WMReportDetail.ReportID/WMReportDetail.ReportLineNo
         
         -- Check if the format is valid (contains '/')
         IF CHARINDEX('/', @cFinalUDF01) = 0
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 14251
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Invalid UDF01 format in CodeLkup. Expected format: ReportID/ReportLineNo'
            GOTO EXIT_SP
         END
         
         -- Check if there's content before and after the '/'
         IF CHARINDEX('/', @cFinalUDF01) = 1 OR CHARINDEX('/', @cFinalUDF01) = LEN(@cFinalUDF01)
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 14251
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Invalid UDF01 format in CodeLkup. Expected format: ReportID/ReportLineNo'
            GOTO EXIT_SP
         END
         
         SET @cParsedReportID = LEFT(@cFinalUDF01, CHARINDEX('/', @cFinalUDF01) - 1)
         SET @cParsedReportLineNo = SUBSTRING(@cFinalUDF01, CHARINDEX('/', @cFinalUDF01) + 1, LEN(@cFinalUDF01))
         
         -- Check if ReportLineNo is not empty
         IF @cParsedReportLineNo = ''
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 14251
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Invalid ReportLineNo format in CodeLkup. Expected non-empty value'
            GOTO EXIT_SP
         END

         -- Retrieve Report Details
         INSERT INTO @VASReports (ReportID, ReportLineNo, PrintSource, DefaultPrinterID, IsPaperPrinter, KeyFieldName1, KeyFieldName2, KeyFieldName3, KeyFieldName4)
         SELECT WMR.ReportID,
                WMRD.ReportLineNo,
                IIF(WMRD.PrintType = 'LOGIREPORT', 'JReport', 'WMReport'),
                ISNULL(WMRD.DefaultPrinterID, ''),
                WMRD.IsPaperPrinter,
                ISNULL(WMR.KeyFieldName1, ''),
                ISNULL(WMR.KeyFieldName2, ''),
                ISNULL(WMR.KeyFieldName3, ''),
                ISNULL(WMR.KeyFieldName4, '')
         FROM WMReportDetail WMRD (NOLOCK)
         JOIN WMReport WMR (NOLOCK) ON WMR.ReportID = WMRD.ReportID AND WMR.ModuleID = @cModuleID
         WHERE WMRD.ReportID = @cParsedReportID
           AND WMRD.ReportLineNo = @cParsedReportLineNo
           AND WMRD.StorerKey = @cStorerKey
           AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)
      END

      FETCH NEXT FROM type_cursor INTO @cTypeFromWOD
   END

   CLOSE type_cursor
   DEALLOCATE type_cursor

   -- Check if any VAS reports were found
   IF NOT EXISTS (SELECT 1 FROM @VASReports)
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 14252
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No VAS reports found for the given work order and storer'
      GOTO EXIT_SP
   END

   -- Continue with the rest of the existing logic for actual printing
   IF @bPrintLabelFlag = 1
   BEGIN
      -- Check for custom label SP configuration
      SELECT @cCustomLabelSP = sValue
      FROM STORERCONFIG (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND ConfigKey = 'TPS-labelSP'
      
      -- If no custom label SP is configured, proceed with standard VAS reports
      IF @@ROWCOUNT = 0
      BEGIN
         IF EXISTS (SELECT 1 FROM @VASReports WHERE IsPaperPrinter <> 'Y')
         BEGIN
            DECLARE CUR_VASLBL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT ReportID, PrintSource, DefaultPrinterID, KeyFieldName1, KeyFieldName2, KeyFieldName3, KeyFieldName4
            FROM @VASReports
            WHERE IsPaperPrinter <> 'Y'
            ORDER BY ReportID
            OPEN CUR_VASLBL
            FETCH NEXT FROM CUR_VASLBL INTO @cReportID, @cPrintSource, @cDefaultPrinterID, @cFieldName1, @cFieldName2, @cFieldName3, @cFieldName4
            WHILE @@FETCH_STATUS = 0
            BEGIN
               SET @IsAggregate1 = CASE WHEN @cFieldName1 <> '' AND (
                                    UPPER(@cFieldName1) LIKE '%SUM(%' OR 
                                    UPPER(@cFieldName1) LIKE '%AVG(%' OR
                                    UPPER(@cFieldName1) LIKE '%COUNT(%' OR
                                    UPPER(@cFieldName1) LIKE '%MIN(%' OR
                                    UPPER(@cFieldName1) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                                 ) THEN 1 ELSE 0 END

               SET @IsAggregate2 = CASE WHEN @cFieldName2 <> '' AND (
                                    UPPER(@cFieldName2) LIKE '%SUM(%' OR 
                                    UPPER(@cFieldName2) LIKE '%AVG(%' OR
                                    UPPER(@cFieldName2) LIKE '%COUNT(%' OR
                                    UPPER(@cFieldName2) LIKE '%MIN(%' OR
                                    UPPER(@cFieldName2) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                                 ) THEN 1 ELSE 0 END

               SET @IsAggregate3 = CASE WHEN @cFieldName3 <> '' AND (
                                    UPPER(@cFieldName3) LIKE '%SUM(%' OR 
                                    UPPER(@cFieldName3) LIKE '%AVG(%' OR
                                    UPPER(@cFieldName3) LIKE '%COUNT(%' OR
                                    UPPER(@cFieldName3) LIKE '%MIN(%' OR
                                    UPPER(@cFieldName3) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                                 ) THEN 1 ELSE 0 END

               SET @IsAggregate4 = CASE WHEN @cFieldName4 <> '' AND (
                                    UPPER(@cFieldName4) LIKE '%SUM(%' OR 
                                    UPPER(@cFieldName4) LIKE '%AVG(%' OR
                                    UPPER(@cFieldName4) LIKE '%COUNT(%' OR
                                    UPPER(@cFieldName4) LIKE '%MIN(%' OR
                                    UPPER(@cFieldName4) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                                 ) THEN 1 ELSE 0 END

               IF EXISTS(SELECT 1
                         FROM STORERCONFIG (NOLOCK)
                         WHERE StorerKey = @cStorerKey
                         AND ConfigKey = 'TPS-PrintAfterPacked'
                         AND sValue = '1'
               ) AND @bIsLastCarton = 1 
               BEGIN 
                  SET  @cSQL = ' SELECT  @cParams1 = '+ @cFieldName1  
                           SELECT @cSQL = IIF(@cFieldName2 <> '', @cSQL + ',@cParams2=' + @cFieldName2, @cSQL) 
                           SELECT @cSQL = IIF(@cFieldName3 <> '', @cSQL + ',@cParams3=' + @cFieldName3, @cSQL)
                           SELECT @cSQL = IIF(@cFieldName4 <> '', @cSQL + ',@cParams4=' + @cFieldName4, @cSQL)
                  SET @cSQL = @cSQL 
                            + ' FROM PACKDETAIL (NOLOCK) '
                            + ' WHERE StorerKey = @cStorerKey '
                            + ' AND PickSlipNo = @cPickSlipNo '
               END
               ELSE
               BEGIN 
                  SET  @cSQL = ' SELECT  @cParams1 = '+ @cFieldName1  
                           SELECT @cSQL = IIF(@cFieldName2 <> '', @cSQL + ',@cParams2=' + @cFieldName2, @cSQL) 
                           SELECT @cSQL = IIF(@cFieldName3 <> '', @cSQL + ',@cParams3=' + @cFieldName3, @cSQL)
                           SELECT @cSQL = IIF(@cFieldName4 <> '', @cSQL + ',@cParams4=' + @cFieldName4, @cSQL)
                  SET @cSQL = @cSQL 
                            + ' FROM PACKDETAIL (NOLOCK) '
                            + ' WHERE StorerKey = @cStorerKey '
                            + ' AND PickSlipNo = @cPickSlipNo '
                            + ' AND CartonNo = @nCartonNo '
               END

               SET @groupByFields = ''

               IF @cFieldName1 <> '' AND @IsAggregate1 = 0 AND ISNUMERIC(@cFieldName1) = 0
                  SET @groupByFields = @groupByFields + IIF(LEN(@groupByFields) > 0, ', ', '') + @cFieldName1

               IF @cFieldName2 <> '' AND @IsAggregate2 = 0 AND ISNUMERIC(@cFieldName2) = 0
                  SET @groupByFields = @groupByFields + IIF(LEN(@groupByFields) > 0, ', ', '') + @cFieldName2

               IF @cFieldName3 <> '' AND @IsAggregate3 = 0 AND ISNUMERIC(@cFieldName3) = 0
                     SET @groupByFields = @groupByFields + IIF(LEN(@groupByFields) > 0, ', ', '') + @cFieldName3

               IF @cFieldName4 <> '' AND @IsAggregate4 = 0 AND ISNUMERIC(@cFieldName4) = 0
                     SET @groupByFields = @groupByFields + IIF(LEN(@groupByFields) > 0, ', ', '') + @cFieldName4

               IF LEN(@groupByFields) > 0
                     SET @cSQL = @cSQL + ' GROUP BY ' + @groupByFields

               SET @cSQLParam = '  @cFieldName1 NVARCHAR(MAX) '
                              + ', @cFieldName2 NVARCHAR(MAX) '
                              + ', @cFieldName3 NVARCHAR(MAX) '
                              + ', @cFieldName4 NVARCHAR(MAX) '
                              + ', @cParams1    NVARCHAR(MAX) OUTPUT '
                              + ', @cParams2    NVARCHAR(MAX) OUTPUT '
                              + ', @cParams3    NVARCHAR(MAX) OUTPUT '
                              + ', @cParams4    NVARCHAR(MAX) OUTPUT '
                              + ', @cStorerKey  NVARCHAR(20) '
                              + ', @cPickSlipNo NVARCHAR(20) '
                              + ', @nCartonNo   INT '

               EXEC sp_ExecuteSQL  @cSQL
                                 , @cSQLParam
                                 , @cFieldName1
                                 , @cFieldName2
                                 , @cFieldName3
                                 , @cFieldName4
                                 , @cParams1     OUTPUT
                                 , @cParams2     OUTPUT
                                 , @cParams3     OUTPUT
                                 , @cParams4     OUTPUT
                                 , @cStorerKey
                                 , @cPickSlipNo
                                 , @nCartonNo 

               IF @cDefaultPrinterID = ''
               BEGIN
                  IF EXISTS(  SELECT 1 
                              FROM rdt.RDTPRINTERGROUP (NOLOCK) 
                              WHERE PrinterGroup = @cLabelPrinter)
                  BEGIN  
                     SET @cPrinterInGroup = ''  
                     SELECT Top 1 @cPrinterInGroup = RTP.PrinterID FROM rdt.RdtReportToPrinter RTP (NOLOCK) 
                     INNER JOIN WMReportDetail WMRD ON RTP.reportType = WMRD.ReportID AND RTP.storerkey = WMRD.storerkey AND RTP.ReportLineNo = WMRD.ReportLineNo
                     INNER Join WMReport WMR ON WMR.reportID = WMRD.reportID AND WMR.ModuleID = @cModuleID 
                     WHERE WMRD.StorerKey = @cStorerKey  
                     AND RTP.PrinterGroup = @cLabelPrinter  
                     IF @cPrinterInGroup = ''  
                     BEGIN  
                        SELECT @cPrinterInGroup = PrinterID  
                        FROM rdt.RDTPRINTERGROUP (NOLOCK)  
                        WHERE PrinterGroup = @cLabelPrinter  
                        AND DefaultPrinter = 1  
                     END  
                     IF @cPrinterInGroup = ''  
                     BEGIN  
                        SET @n_Continue = 3
                        SET @n_ErrNo = 14253    
                        SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')
                        GOTO EXIT_SP  
                     END
                     SET @cLabelPrinter = @cPrinterInGroup
                  END
               END
               ELSE
               BEGIN
                  SET @cLabelPrinter = @cDefaultPrinterID
               END

               EXEC  [WM].[lsp_WM_Print_Report]
                       @c_ModuleID     = @cModuleID           
                     , @c_ReportID     = @cReportID         
                     , @c_Storerkey    = @cStorerKey         
                     , @c_Facility     = @cFacility        
                     , @c_UserName     = @c_UserID   
                     , @c_ComputerName = ''
                     , @c_PrinterID    = @cLabelPrinter         
                     , @n_NoOfCopy     = '1'     
                     , @c_KeyValue1    = @cParams1        
                     , @c_KeyValue2    = @cParams2        
                     , @c_KeyValue3    = @cParams3     
                     , @c_KeyValue4    = @cParams4    
                     , @b_Success      = @b_Success         OUTPUT      
                     , @n_Err          = @n_ErrNo           OUTPUT
                     , @c_ErrMsg       = @c_ErrMsg          OUTPUT
                     , @c_PrintSource  = @cPrintSource        
                     , @b_SCEPreView   = 0         
                     , @c_JobIDs       = @ctempLabelJobIDs  OUTPUT    
                     , @c_AutoPrint    = 'N'     
               IF @n_ErrNo <> 0   
               BEGIN  
                  SET @n_Continue = 3 
                  GOTO EXIT_SP  
               END
               SET @cPrintLabelJobIDs = IIF(@cPrintLabelJobIDs <> '', @cPrintLabelJobIDs + '|' + @ctempLabelJobIDs, @ctempLabelJobIDs)
               FETCH NEXT FROM CUR_VASLBL INTO @cReportID, @cPrintSource, @cDefaultPrinterID, @cFieldName1, @cFieldName2, @cFieldName3, @cFieldName4
            END
            CLOSE CUR_VASLBL
            DEALLOCATE CUR_VASLBL
         END
      END
      -- Custom label SP is configured, execute it instead
      ELSE
      BEGIN
         IF NOT EXISTS (SELECT 1 
                        FROM dbo.sysobjects 
                        WHERE [name] = @cCustomLabelSP 
                        AND [type] = 'P'
         )
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 14257
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Invalid Custom Label SP Name in StorerConfig.'
            GOTO EXIT_SP
         END

         SET @cSQL = 'EXEC ' + RTRIM( @cCustomLabelSP)   
                   + '  @cStorerKey    = @cStorerKey      ' + CHAR(13)
                   + ', @cFacility     = @cFacility       ' + CHAR(13)
                   + ', @cUserName     = @c_UserID        ' + CHAR(13)
                   + ', @cPickSlipNo   = @cPickSlipNo     ' + CHAR(13)
                   + ', @cLabelPrinter = @cLabelPrinter   ' + CHAR(13)
                   + ', @cPaperPrinter = @cPaperPrinter   ' + CHAR(13)
                   + ', @nErrNo        = @n_ErrNo  OUTPUT ' + CHAR(13)
                   + ', @cErrMsg       = @c_ErrMsg OUTPUT ' + CHAR(13)   

         SET @cSQLParam = '  @cStorerKey      NVARCHAR(15)         ' + CHAR(13)   
                        + ', @cFacility       NVARCHAR(5)          ' + CHAR(13) 
                        + ', @c_UserID        NVARCHAR(256)        ' + CHAR(13)     
                        + ', @cPickSlipNo     NVARCHAR(30)         ' + CHAR(13)   
                        + ', @cLabelPrinter   NVARCHAR(30)         ' + CHAR(13)   
                        + ', @cPaperPrinter   NVARCHAR(30)         ' + CHAR(13)   
                        + ', @n_ErrNo         INT           OUTPUT ' + CHAR(13)   
                        + ', @c_ErrMsg        NVARCHAR(250) OUTPUT ' + CHAR(13)    
    
         EXEC sp_ExecuteSQL  @cSQL
                           , @cSQLParam    
                           , @cStorerKey
                           , @cFacility
                           , @c_UserID
                           , @cPickSlipNo
                           , @cLabelPrinter
                           , @cPaperPrinter
                           , @n_ErrNo        OUTPUT
                           , @c_ErrMsg       OUTPUT  
                             
         IF @n_ErrNo <> 0   
         BEGIN  
            SET @n_Continue = 3
            GOTO EXIT_SP  
         END 
      END
      
   END

   SET @cSQL = ''
   SET @cSQLParam = ''

   IF @bPrintPaperFlag = 1
   BEGIN
      IF EXISTS (SELECT 1 FROM @VASReports WHERE IsPaperPrinter = 'Y')
      BEGIN
         DECLARE CUR_VASPAPER CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
         SELECT ReportID, PrintSource, DefaultPrinterID, KeyFieldName1, KeyFieldName2, KeyFieldName3, KeyFieldName4
         FROM @VASReports
         WHERE IsPaperPrinter = 'Y'
         ORDER BY ReportID
         OPEN CUR_VASPAPER
         FETCH NEXT FROM CUR_VASPAPER INTO  @cReportID, @cPrintSource, @cDefaultPrinterID, @cFieldName1, @cFieldName2, @cFieldName3, @cFieldName4
         WHILE @@FETCH_STATUS = 0
         BEGIN
            SET @IsAggregate1 = CASE WHEN @cFieldName1 <> '' AND (
                              UPPER(@cFieldName1) LIKE '%SUM(%' OR 
                              UPPER(@cFieldName1) LIKE '%AVG(%' OR
                              UPPER(@cFieldName1) LIKE '%COUNT(%' OR
                              UPPER(@cFieldName1) LIKE '%MIN(%' OR
                              UPPER(@cFieldName1) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                           ) THEN 1 ELSE 0 END
            SET @IsAggregate2 = CASE WHEN @cFieldName2 <> '' AND (
                              UPPER(@cFieldName2) LIKE '%SUM(%' OR 
                              UPPER(@cFieldName2) LIKE '%AVG(%' OR
                              UPPER(@cFieldName2) LIKE '%COUNT(%' OR
                              UPPER(@cFieldName2) LIKE '%MIN(%' OR
                              UPPER(@cFieldName2) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                           ) THEN 1 ELSE 0 END
            SET @IsAggregate3 = CASE WHEN @cFieldName3 <> '' AND (
                              UPPER(@cFieldName3) LIKE '%SUM(%' OR 
                              UPPER(@cFieldName3) LIKE '%AVG(%' OR
                              UPPER(@cFieldName3) LIKE '%COUNT(%' OR
                              UPPER(@cFieldName3) LIKE '%MIN(%' OR
                              UPPER(@cFieldName3) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                           ) THEN 1 ELSE 0 END
            SET @IsAggregate4 = CASE WHEN @cFieldName4 <> '' AND (
                              UPPER(@cFieldName4) LIKE '%SUM(%' OR 
                              UPPER(@cFieldName4) LIKE '%AVG(%' OR
                              UPPER(@cFieldName4) LIKE '%COUNT(%' OR
                              UPPER(@cFieldName4) LIKE '%MIN(%' OR
                              UPPER(@cFieldName4) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                           ) THEN 1 ELSE 0 END
            SET  @cSQL = ' SELECT  @cParams1 = '+ @cFieldName1  
                        SELECT @cSQL = IIF(@cFieldName2 <> '', @cSQL + ',@cParams2=' + @cFieldName2, @cSQL) 
                        SELECT @cSQL = IIF(@cFieldName3 <> '', @cSQL + ',@cParams3=' + @cFieldName3, @cSQL)
                        SELECT @cSQL = IIF(@cFieldName4 <> '', @cSQL + ',@cParams4=' + @cFieldName4, @cSQL)
            SET @cSQL = @cSQL 
                      + ' FROM PACKDETAIL (NOLOCK) '
                      + ' WHERE StorerKey = @cStorerKey '
                      + ' AND PickSlipNo = @cPickSlipNo '
                      + ' AND CartonNo = @nCartonNo '
            SET @groupByFields = ''
            IF @cFieldName1 <> '' AND @IsAggregate1 = 0 AND ISNUMERIC(@cFieldName1) = 0
               SET @groupByFields = @groupByFields + IIF(LEN(@groupByFields) > 0, ', ', '') + @cFieldName1
            IF @cFieldName2 <> '' AND @IsAggregate2 = 0 AND ISNUMERIC(@cFieldName2) = 0
               SET @groupByFields = @groupByFields + IIF(LEN(@groupByFields) > 0, ', ', '') + @cFieldName2
            IF @cFieldName3 <> '' AND @IsAggregate3 = 0 AND ISNUMERIC(@cFieldName3) = 0
                  SET @groupByFields = @groupByFields + IIF(LEN(@groupByFields) > 0, ', ', '') + @cFieldName3
            IF @cFieldName4 <> '' AND @IsAggregate4 = 0 AND ISNUMERIC(@cFieldName4) = 0
                  SET @groupByFields = @groupByFields + IIF(LEN(@groupByFields) > 0, ', ', '') + @cFieldName4
            IF LEN(@groupByFields) > 0
                  SET @cSQL = @cSQL + ' GROUP BY ' + @groupByFields
            SET @cSQLParam = '  @cFieldName1 NVARCHAR(MAX) '
                        + ', @cFieldName2 NVARCHAR(MAX) '
                        + ', @cFieldName3 NVARCHAR(MAX) '
                        + ', @cFieldName4 NVARCHAR(MAX) '
                        + ', @cParams1    NVARCHAR(MAX) OUTPUT '
                        + ', @cParams2    NVARCHAR(MAX) OUTPUT '
                        + ', @cParams3    NVARCHAR(MAX) OUTPUT '
                        + ', @cParams4    NVARCHAR(MAX) OUTPUT '
                        + ', @cStorerKey  NVARCHAR(20) '
                        + ', @cPickSlipNo NVARCHAR(20) '
                        + ', @nCartonNo   INT '
            EXEC sp_ExecuteSQL  @cSQL
                           , @cSQLParam
                           , @cFieldName1
                           , @cFieldName2
                           , @cFieldName3
                           , @cFieldName4
                           , @cParams1     OUTPUT
                           , @cParams2     OUTPUT
                           , @cParams3     OUTPUT
                           , @cParams4     OUTPUT
                           , @cStorerKey
                           , @cPickSlipNo
                           , @nCartonNo 
            IF @cDefaultPrinterID = ''
            BEGIN
               IF EXISTS(  SELECT 1 
                           FROM rdt.RDTPRINTERGROUP (NOLOCK) 
                           WHERE PrinterGroup = @cPaperPrinter)
               BEGIN  
                  SET @cPrinterInGroup = ''  
                  SELECT Top 1 @cPrinterInGroup = RTP.PrinterID FROM rdt.RdtReportToPrinter RTP (NOLOCK) 
                  INNER JOIN WMReportDetail WMRD ON RTP.reportType = WMRD.ReportID AND RTP.storerkey = WMRD.storerkey AND RTP.ReportLineNo = WMRD.ReportLineNo
                  INNER JOIN WMReport WMR ON WMR.reportID = WMRD.reportID AND WMR.ModuleID = @cModuleID 
                  WHERE WMRD.StorerKey = @cStorerKey  
                  AND RTP.PrinterGroup = @cPaperPrinter  
                  IF @cPrinterInGroup = ''  
                  BEGIN  
                     SELECT @cPrinterInGroup = PrinterID  
                     FROM rdt.RDTPRINTERGROUP (NOLOCK)  
                     WHERE PrinterGroup = @cPaperPrinter  
                     AND DefaultPrinter = 1  
                  END  
                  IF @cPrinterInGroup = ''  
                  BEGIN  
                     SET @n_Continue = 3
                     SET @n_ErrNo = 14256    
                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')
                     GOTO EXIT_SP  
                  END
                  SET @cPaperPrinter = @cPrinterInGroup
               END
            END
            ELSE
            BEGIN
               SET @cPaperPrinter = @cDefaultPrinterID
            END
            EXEC  [WM].[lsp_WM_Print_Report]
                    @c_ModuleID     = @cModuleID           
                  , @c_ReportID     = @cReportID         
                  , @c_Storerkey    = @cStorerKey         
                  , @c_Facility     = @cFacility        
                  , @c_UserName     = @c_UserID   
                  , @c_ComputerName = ''
                  , @c_PrinterID    = @cPaperPrinter         
                  , @n_NoOfCopy     = '1'     
                  , @c_KeyValue1    = @cParams1        
                  , @c_KeyValue2    = @cParams2        
                  , @c_KeyValue3    = @cParams3     
                  , @c_KeyValue4    = @cParams4    
                  , @b_Success      = @b_Success            OUTPUT      
                  , @n_Err          = @n_ErrNo              OUTPUT
                  , @c_ErrMsg       = @c_ErrMsg             OUTPUT
                  , @c_PrintSource  = @cPrintSource        
                  , @b_SCEPreView   = 0         
                  , @c_JobIDs       = @cPrintPaperJobIDs    OUTPUT    
                  , @c_AutoPrint    = 'N'     
            IF @n_ErrNo <> 0   
            BEGIN  
               SET @n_Continue = 3 
               GOTO EXIT_SP  
            END   
            FETCH NEXT FROM CUR_VASPAPER INTO  @cReportID, @cPrintSource, @cDefaultPrinterID, @cFieldName1, @cFieldName2, @cFieldName3, @cFieldName4
         END
         CLOSE CUR_VASPAPER
         DEALLOCATE CUR_VASPAPER
      END
   END

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