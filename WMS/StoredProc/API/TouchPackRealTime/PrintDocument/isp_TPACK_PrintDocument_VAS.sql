SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_PrintDocument_VAS                                  */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Specific reports printing function by VAS Code               */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-12-24   1.0  YLI237     UWP-43509                                        */
/* 2026-02-25   2.0  GCH225     UWP-49257 Enhancement.                           */
/* 2026-03-05   3.0  GCH225     UWP-50005 Fix Continue Print Logic               */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_PrintDocument_VAS] (
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
   , @bPrintLabelFlag      BIT               = 0   OUTPUT
   , @bPrintPaperFlag      BIT               = 0   OUTPUT
   , @cLabelPrinter        NVARCHAR(30)      = ''
   , @cPaperPrinter        NVARCHAR(30)      = ''
   , @bIsAutoPrint         BIT               = 0
   , @nCopy                INT               = 0
   , @cSKU                 NVARCHAR(20)      = ''
   , @cReportType          NVARCHAR(30)      = ''
   , @cPrintLabelJobIDs    NVARCHAR(MAX)     = ''  OUTPUT
   , @cPrintPaperJobIDs    NVARCHAR(MAX)     = ''  OUTPUT
   , @nContinuePrint       INT               = 0   OUTPUT
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
         , @cSQL                 NVARCHAR(MAX)
         , @cSQLParam            NVARCHAR(MAX)
         , @cReportID            NVARCHAR(10)
         , @cPrintSource         NVARCHAR(30)
         , @cDefaultPrinterID    NVARCHAR(30)
         , @groupByFields        NVARCHAR(MAX)
         , @cPrinterInGroup      NVARCHAR(10)
         , @cReportLine          NVARCHAR(5)
         , @cWODSKU              NVARCHAR(20)
         , @cWODType             NVARCHAR(12)
         , @cWorkOrderKey        NVARCHAR(10)
         , @cWorkOrderLineNumber NVARCHAR(5)
         , @cIsPaperPrinter      CHAR(1)
         , @cPrinterID           NVARCHAR(30)
         , @cJobIDs              NVARCHAR(MAX)
         , @cFinalSKU            NVARCHAR(20)
         , @cUDF01_WK            NVARCHAR(60)
         , @cUDF04_WK            NVARCHAR(60)

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
   -- DECLARE @cTypeFromWOD      NVARCHAR(30)
   --       , @cUDF01Value       NVARCHAR(MAX)

   
   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = '' 
   SET @cSQL               = ''
   SET @cSQLParam          = ''
   SET @cFieldName1        = ''
   SET @cFieldName2        = ''
   SET @cFieldName3        = ''
   SET @cFieldName4        = ''
   SET @cParams1           = ''
   SET @cParams2           = ''
   SET @cParams3           = ''
   SET @cParams4           = ''
   SET @IsAggregate1       = 0
   SET @IsAggregate2       = 0
   SET @IsAggregate3       = 0
   SET @IsAggregate4       = 0
   SET @cModuleID          = 'TPPACK'
   SET @cWODSKU            = ''
   SET @cWODType           = ''
   SET @cJobIDs            = ''
   SET @cIsPaperPrinter    = '0'
   SET @cPrinterID         = ''
   SET @cFinalSKU          = ''
   SET @cUDF01_WK          = ''
   SET @cUDF04_WK          = ''
   SET @nContinuePrint     = 0

   DECLARE @VASReports TABLE (
      ReportID         NVARCHAR(10)
    , ReportLineNo     NVARCHAR(5)
    , PrintSource      NVARCHAR(30)
    , DefaultPrinterID NVARCHAR(30)
    , IsPaperPrinter   CHAR(1)
    , KeyFieldName1    NVARCHAR(MAX)
    , KeyFieldName2    NVARCHAR(MAX)
    , KeyFieldName3    NVARCHAR(MAX)
    , KeyFieldName4    NVARCHAR(MAX)
    , ReportType       NVARCHAR(30)
   )
   
   --if is SKU level and SKU is provided, print specific SKU label or
   --if is Carton level and SKU is not provided, print SKU label for all SKUs under the carton; 
   --otherwise, skip the condition.
   IF @cSKU <> ''
   BEGIN
      DECLARE sku_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT  ISNULL(WOD.SKU, '')
            , ISNULL(WOD.[Type], '')
            , ISNULL(CLK.UDF01,'')
            , ISNULL(CLK.UDF04,'')
      FROM WORKORDERDETAIL WOD (NOLOCK)
      INNER JOIN CODELKUP CLK (NOLOCK)
      ON CLK.Code = WOD.[Type]
      AND CLK.StorerKey = @cStorerKey
      WHERE EXISTS ( SELECT 1
                     FROM WORKORDER WO (NOLOCK)
                     WHERE WO.ExternWorkOrderKey = @cOrderKey
                     AND WO.StorerKey = @cStorerKey
                     AND WO.Facility = @cFacility
                     AND WO.[Type] IN('PACK', 'VAS')
                     AND WO.WorkOrderKey = WOD.WorkOrderKey
                     )
      AND (WOD.SKU = @cSKU OR WOD.SKU = '')
      AND CLK.UDF04 IN ('PRICELB', 'SKULB')
      AND CLK.LISTName = 'WKORDTYPE'
   END
   ELSE
   BEGIN
      DECLARE sku_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT  ISNULL(WOD.SKU, '')
            , ISNULL(WOD.[Type], '')
            , ISNULL(CLK.UDF01,'')
            , ISNULL(CLK.UDF04,'')
      FROM WORKORDERDETAIL WOD (NOLOCK)
      INNER JOIN CODELKUP CLK (NOLOCK)
      ON CLK.Code = WOD.[Type]
      AND CLK.StorerKey = @cStorerKey
      WHERE EXISTS ( SELECT 1
                     FROM WORKORDER WO (NOLOCK)
                     WHERE WO.ExternWorkOrderKey = @cOrderKey
                     AND WO.StorerKey = @cStorerKey
                     AND WO.Facility = @cFacility
                     AND WO.[Type] IN('PACK', 'VAS')
                     AND WO.WorkOrderKey = WOD.WorkOrderKey
                     )
      AND EXISTS ( SELECT 1
                     FROM PACKDETAIL PD (NOLOCK)
                     WHERE 
                     --PD.SKU = WOD.SKU
                     PD.PickSlipNo = @cPickSlipNo
                     AND PD.CartonNo = @nCartonNo
                  )
      AND CLK.UDF04 NOT IN('PRICELB', 'SKULB')
      AND CLK.LISTName = 'WKORDTYPE'
   END

   OPEN sku_cursor
   FETCH NEXT FROM sku_cursor INTO @cWODSKU
                                 , @cWODType
                                 , @cUDF01_WK
                                 , @cUDF04_WK
   WHILE @@FETCH_STATUS = 0
   BEGIN
      INSERT INTO @VASReports ( ReportID
                              , ReportLineNo
                              , PrintSource
                              , DefaultPrinterID
                              , IsPaperPrinter
                              , KeyFieldName1
                              , KeyFieldName2
                              , KeyFieldName3
                              , KeyFieldName4
                              , ReportType)
      EXEC [API].[isp_TPACK_PrintDocument_VAS_BySKU]
         @cWODType          = @cWODType
         , @cStorerKey      = @cStorerKey
         , @cFacility       = @cFacility
         , @cOrderKey       = @cOrderKey
         , @cPickSlipNo     = @cPickSlipNo
         , @nCartonNo       = @nCartonNo
         , @cSKU            = @cWODSKU
         , @cUDF01_WK       = @cUDF01_WK
         , @cUDF04_WK       = @cUDF04_WK
         , @bPrintLabelFlag = @bPrintLabelFlag
         , @bPrintPaperFlag = @bPrintPaperFlag
         , @cLangCode       = @cLangCode
         , @b_Success       = @b_Success       OUTPUT
         , @n_ErrNo         = @n_ErrNo         OUTPUT
         , @c_ErrMsg        = @c_ErrMsg        OUTPUT

      IF @b_Success = 0 
      BEGIN
         SET @n_Continue = 3 
         GOTO EXIT_SP  
      END
      FETCH NEXT FROM sku_cursor INTO @cWODSKU
                                    , @cWODType
                                    , @cUDF01_WK
                                    , @cUDF04_WK
   END
   CLOSE sku_cursor
   DEALLOCATE sku_cursor

   IF @cReportType = '' AND 
   EXISTS ( SELECT 1 
            FROM @VASReports
            WHERE ReportType = 'TPVASCarton'
   )
   BEGIN
      -- If TPVASCarton exists, then no need to continue print the standard or custom carton label.
      SET @bPrintLabelFlag = 0
   END
   
   DECLARE CUR_VASALL CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
   SELECT  ReportID
         , ReportLineNo
         , PrintSource
         , DefaultPrinterID
         , KeyFieldName1
         , KeyFieldName2
         , KeyFieldName3
         , KeyFieldName4
         , IsPaperPrinter
         , ReportType
   FROM @VASReports
   WHERE (@cReportType = '' OR ReportType = @cReportType)
   ORDER BY ReportID

   OPEN CUR_VASALL
   FETCH NEXT FROM CUR_VASALL INTO @cReportID
                                 , @cReportLine
                                 , @cPrintSource
                                 , @cDefaultPrinterID
                                 , @cFieldName1
                                 , @cFieldName2
                                 , @cFieldName3
                                 , @cFieldName4
                                 , @cIsPaperPrinter
                                 , @cReportType
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

      IF @cParams1 = '' 
      AND @cParams2 = '' 
      AND @cParams3 = '' 
      AND @nCartonNo = 0
      AND @cSKU <> ''
      BEGIN
         SET @cParams1 = @cStorerKey
         SET @cParams2 = @cPickSlipNo
         SET @cParams3 = CAST(@nCartonNo AS NVARCHAR(10))
      END
      
      IF @cDefaultPrinterID = ''
      BEGIN
         IF EXISTS(  SELECT 1 
                     FROM rdt.RDTPRINTERGROUP (NOLOCK) 
                     WHERE PrinterGroup = IIF(@cIsPaperPrinter = '1', @cPaperPrinter, @cLabelPrinter)
         )
         BEGIN  
            SET @cPrinterInGroup = ''  
            SELECT TOP 1 @cPrinterInGroup = RTP.PrinterID 
            FROM rdt.RdtReportToPrinter RTP (NOLOCK) 
            INNER JOIN WMReportDetail WMRD (NOLOCK)
            ON RTP.ReportType = WMRD.ReportID 
            AND RTP.StorerKey = WMRD.StorerKey 
            AND RTP.ReportLineNo = WMRD.ReportLineNo
            INNER JOIN WMReport WMR (NOLOCK) 
            ON WMR.ReportID = WMRD.ReportID 
            AND WMR.ModuleID = @cModuleID 
            WHERE WMRD.StorerKey = @cStorerKey  
            AND RTP.PrinterGroup = IIF(@cIsPaperPrinter = '1', @cPaperPrinter, @cLabelPrinter)
            AND WMRD.ReportID = @cReportID
            AND WMRD.ReportLineNo = @cReportLine

            IF @@ROWCOUNT = 0
            BEGIN
               SELECT TOP 1 @cPrinterInGroup = RTP.PrinterID 
               FROM rdt.RdtReportToPrinter RTP (NOLOCK) 
               INNER JOIN WMReportDetail WMRD (NOLOCK)
               ON RTP.ReportType = WMRD.ReportID 
               AND RTP.StorerKey = WMRD.StorerKey 
               AND RTP.ReportLineNo = WMRD.ReportLineNo
               INNER JOIN WMReport WMR (NOLOCK) 
               ON WMR.ReportID = WMRD.ReportID 
               AND WMR.ModuleID = @cModuleID 
               WHERE WMRD.StorerKey = @cStorerKey  
               AND RTP.PrinterGroup = IIF(@cIsPaperPrinter = '1', @cPaperPrinter, @cLabelPrinter)
            END
            IF @cPrinterInGroup = ''  
            BEGIN  
               SELECT @cPrinterInGroup = PrinterID  
               FROM rdt.RDTPRINTERGROUP (NOLOCK)  
               WHERE PrinterGroup = IIF(@cIsPaperPrinter = '1', @cPaperPrinter, @cLabelPrinter)  
               AND DefaultPrinter = 1  
            END  
            IF @cPrinterInGroup = ''  
            BEGIN  
               SET @n_Continue = 3
               SET @n_ErrNo = 14251    
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')
               GOTO EXIT_SP  
            END
            SET @cPrinterID = @cPrinterInGroup
         END
         ELSE
         BEGIN
            SET @cPrinterID = IIF(@cIsPaperPrinter = '1', @cPaperPrinter, @cLabelPrinter)
         END
      END
      ELSE
      BEGIN
         SET @cPrinterID = @cDefaultPrinterID
      END

      SET @nCopy = IIF(@cSKU <> '', @nCopy, 1) 
      
      EXEC  [WM].[lsp_WM_Print_Report]
               @c_ModuleID     = @cModuleID           
            , @c_ReportID     = @cReportID         
            , @c_Storerkey    = @cStorerKey         
            , @c_Facility     = @cFacility        
            , @c_UserName     = @c_UserID   
            , @c_ComputerName = ''
            , @c_PrinterID    = @cPrinterID         
            , @n_NoOfCopy     = @nCopy   
            , @c_KeyValue1    = @cParams1        
            , @c_KeyValue2    = @cParams2        
            , @c_KeyValue3    = @cParams3     
            , @c_KeyValue4    = @cParams4  
            , @c_KeyValue5    = @cReportLine
            , @b_Success      = @b_Success      OUTPUT      
            , @n_Err          = @n_ErrNo        OUTPUT
            , @c_ErrMsg       = @c_ErrMsg       OUTPUT
            , @c_PrintSource  = @cPrintSource        
            , @b_SCEPreView   = 0         
            , @c_JobIDs       = @cJobIDs        OUTPUT    
            , @c_AutoPrint    = 'N'     
            
      IF @b_Success = 0 
      BEGIN  
         SET @n_Continue = 3 
         GOTO EXIT_SP  
      END   

      IF @cIsPaperPrinter = '1'
         SET @cPrintPaperJobIDs = IIF(@cPrintPaperJobIDs <> '', @cPrintPaperJobIDs + '|' + @cJobIDs, @cJobIDs)
      ELSE
         SET @cPrintLabelJobIDs = IIF(@cPrintLabelJobIDs <> '', @cPrintLabelJobIDs + '|' + @cJobIDs, @cJobIDs)

      FETCH NEXT FROM CUR_VASALL INTO @cReportID
                                    , @cReportLine
                                    , @cPrintSource
                                    , @cDefaultPrinterID
                                    , @cFieldName1
                                    , @cFieldName2
                                    , @cFieldName3
                                    , @cFieldName4
                                    , @cIsPaperPrinter
                                    , @cReportType
   END
   CLOSE CUR_VASALL
   DEALLOCATE CUR_VASALL

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
