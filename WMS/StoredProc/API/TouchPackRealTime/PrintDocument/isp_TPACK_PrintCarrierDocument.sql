SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_PrintCarrierDocument                               */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Standard Print Carrier Document thru IML                     */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-02-23   1.0  GCH225     UWP-48263 Created                                */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_PrintCarrierDocument] (
     @cStorerKey  NVARCHAR(15)   = ''
   , @cLabelNo    NVARCHAR(20)   = ''
   , @cOrderKey   NVARCHAR(10)   = ''
   , @bSuccess    INT            = 0   OUTPUT  
   , @nErrNo      INT            = 0   OUTPUT
   , @cErrMsg     NVARCHAR(250)  = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue        INT            = 1  
         , @n_StartCnt        INT            = @@TRANCOUNT

   DECLARE @cModuleID         NVARCHAR(30)
         , @cSQL              NVARCHAR(MAX)
         , @cSQLParam         NVARCHAR(MAX)
         , @cReportID         NVARCHAR(10)
         , @cPrintSource      NVARCHAR(30)
         , @cDefaultPrinterID NVARCHAR(30)
         , @groupByFields     NVARCHAR(MAX)
         , @cPrinterInGroup   NVARCHAR(10)
         , @ctempLabelJobIDs  NVARCHAR(MAX)
         , @cLabelPrinter     NVARCHAR(30)
         , @cUserID           NVARCHAR(256)
         , @cPickSlipNo       NVARCHAR(20)
         , @nCartonNo         INT
         , @cFacility         NVARCHAR(20)
         , @cLangCode         NVARCHAR(10)

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

   SET @bSuccess        = 0  
   SET @nErrNo          = 0  
   SET @cErrMsg         = '' 
   SET @cSQL            = ''
   SET @cSQLParam       = ''
   SET @cFieldName1     = ''
   SET @cFieldName2     = ''
   SET @cFieldName3     = ''
   SET @cFieldName4     = ''
   SET @cParams1        = ''
   SET @cParams2        = ''
   SET @cParams3        = ''
   SET @cParams4        = ''
   SET @IsAggregate1    = 0
   SET @IsAggregate2    = 0
   SET @IsAggregate3    = 0
   SET @IsAggregate4    = 0
   SET @cModuleID       = 'TPPACK'
   SET @cLabelPrinter   = ''
   SET @cLangCode       = 'ENG'

   SELECT @cUserID = EditWho
        , @cPickSlipNo = PickSlipNo
        , @nCartonNo = CartonNo
   FROM PACKDETAIL (NOLOCK)
   WHERE StorerKey = @cStorerKey
   AND LabelNo = @cLabelNo
   
   IF EXISTS(SELECT 1
              FROM PACKHEADER (NOLOCK)
              WHERE PickSlipNo = @cPickSlipNo
              AND OrderKey = @cOrderKey
   )
   BEGIN
      SELECT @cFacility = Facility
      FROM ORDERS (NOLOCK)
      WHERE OrderKey = @cOrderKey
   END
   ELSE
   BEGIN
      SELECT @cFacility = O.Facility
      FROM ORDERS O (NOLOCK)
      WHERE EXISTS (SELECT 1 
                    FROM LOADPLANDETAIL LPD (NOLOCK)
                    WHERE LPD.OrderKey = @cOrderKey
                    AND LPD.LoadKey = O.ExternOrderKey
      )
   END

   SELECT @cLabelPrinter = PrinterID
   FROM API.AppPrinter P (NOLOCK)
   WHERE EXISTS ( SELECT 1 
                  FROM API.AppWorkstation W (NOLOCK) 
                  WHERE W.Workstation = P.Workstation
                  AND EXISTS (SELECT 1 
                              FROM API.AppSection S (NOLOCK) 
                              WHERE S.DeviceID = W.DeviceID
                              AND S.UserID = @cUserID
                              AND S.ScanNo = @cPickSlipNo
                              )
               )
            
   IF NOT EXISTS (SELECT 1
                  FROM WMREPORT WMR (NOLOCK) 
                  JOIN WMREPORTDETAIL WMRD (NOLOCK) 
                  ON WMR.ReportID =WMRD.ReportID
                  WHERE WMRD.StorerKey = @cStorerKey 
                  AND EXISTS(SELECT 1
                             FROM CODELKUP CLK (NOLOCK)
                             WHERE CLK.LISTNAME = 'TPRptType'
                             AND CLK.Code = WMR.ReportType
                             AND CLK.StorerKey = WMRD.StorerKey
                  )
                  AND WMR.ModuleID = @cModuleID
                  AND WMRD.IsPaperPrinter <> 'Y'
                  AND (WMRD.UserName = '' OR WMRD.UserName = @cUserID)
                  AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility) 
   )  
   BEGIN 
      SET @n_Continue = 3
      SET @nErrNo = 11851
      SET @cErrMsg = API.TouchPadGetMessage( @nErrNo, @cLangCode, 'DSP')--'Label: No records found in WMReport.'
      GOTO EXIT_SP
   END

   IF EXISTS ( SELECT  1
               FROM WMREPORT WMR (NOLOCK)
               JOIN WMREPORTDETAIL WMRD (NOLOCK) 
               ON WMR.ReportID = WMRD.ReportID
               WHERE WMRD.StorerKey = @cStorerKey
               AND EXISTS( SELECT 1
                           FROM CODELKUP CLK (NOLOCK)
                           WHERE CLK.LISTNAME = 'TPRptType'
                           AND CLK.Code = WMR.ReportType
                           AND CLK.StorerKey = WMRD.StorerKey
                        )
               AND WMR.ModuleID = @cModuleID
               AND WMRD.IsPaperPrinter <> 'Y'
               AND (WMR.KeyFieldName1 = '' OR WMR.KeyFieldName1 IS NULL)
               AND (WMRD.UserName = '' OR WMRD.UserName = @cUserID)
               AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility) 
   )
   BEGIN
      SET @n_Continue = 3
      SET @nErrNo = 11852
      SET @cErrMsg = API.TouchPadGetMessage( @nErrNo, @cLangCode, 'DSP')--'Label: No value found in table(WMReport); column(keyFieldname1), this column cannot be empty or null.'
      GOTO EXIT_SP
   END

   DECLARE CUR_LBL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT  WMR.ReportID
         , IIF(WMRD.PrintType ='LOGIREPORT', 'JReport', 'WMReport')
         , ISNULL(WMRD.DefaultPrinterID, '')
         , ISNULL(WMR.KeyFieldName1, '')
         , ISNULL(WMR.KeyFieldName2, '')
         , ISNULL(WMR.KeyFieldName3, '')
         , ISNULL(WMR.KeyFieldName4, '')
   FROM WMREPORT WMR (NOLOCK)
   JOIN WMREPORTDETAIL WMRD (NOLOCK) 
   ON WMR.ReportID = WMRD.ReportID
   WHERE WMRD.StorerKey = @cStorerKey
   AND EXISTS( SELECT 1
               FROM CODELKUP CLK (NOLOCK)
               WHERE CLK.LISTNAME = 'TPRptType'
               AND CLK.Code = WMR.ReportType
               AND CLK.StorerKey = WMRD.StorerKey
            )
   AND WMR.ModuleID = @cModuleID
   AND WMRD.IsPaperPrinter <> 'Y'
   AND (WMRD.UserName = '' OR WMRD.UserName = @cUserID)
   AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility) 
   ORDER BY WMR.ReportID        
   OPEN CUR_LBL
   FETCH NEXT FROM CUR_LBL INTO @cReportID
                              , @cPrintSource
                              , @cDefaultPrinterID
                              , @cFieldName1
                              , @cFieldName2
                              , @cFieldName3
                              , @cFieldName4
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

      -- If any valid fields found, append GROUP BY
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
         -- Check if printer is a group  
         IF EXISTS(  SELECT 1 
                     FROM rdt.RDTPRINTERGROUP (NOLOCK) 
                     WHERE PrinterGroup = @cLabelPrinter
         )  
         BEGIN  
            SET @cPrinterInGroup = ''  

            -- Check if report print to a specific printer in group  
            -- UWP-43135 Start
            SELECT TOP 1 @cPrinterInGroup = RTP.PrinterID 
            FROM rdt.RDTREPORTTOPRINTER RTP (NOLOCK) 
            INNER JOIN WMREPORTDETAIL WMRD (NOLOCK)
            ON RTP.ReportType = WMRD.ReportID 
            AND RTP.StorerKey = WMRD.StorerKey 
            AND RTP.ReportLineNo = WMRD.ReportLineNo
            INNER JOIN WMREPORT WMR (NOLOCK)
            ON WMR.ReportID = WMRD.ReportID 
            AND WMR.ModuleID = @cModuleID
            WHERE WMRD.StorerKey = @cStorerKey  
            AND EXISTS( SELECT 1
                        FROM CODELKUP CLK (NOLOCK)
                        WHERE CLK.LISTNAME = 'TPRptType'
                        AND CLK.Code = WMR.ReportType
                        AND CLK.StorerKey = WMRD.StorerKey
                     )
            AND RTP.PrinterGroup = @cLabelPrinter  
            -- UWP-43135 End

            IF @cPrinterInGroup = ''  
            BEGIN  
               -- Get default printer in the group  
               SELECT @cPrinterInGroup = PrinterID  
               FROM rdt.RDTPRINTERGROUP (NOLOCK)  
               WHERE PrinterGroup = @cLabelPrinter  
               AND DefaultPrinter = 1  
            END  

            -- Check no default printer
            IF @cPrinterInGroup = ''  
            BEGIN  
               SET @n_Continue = 3
               SET @nErrNo = 11853    
               SET @cErrMsg = API.TouchPadGetMessage( @nErrNo, @cLangCode, 'DSP')--'Not found PrinterID in PrinterGroup.'  
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
            , @c_UserName     = @cUserID   
            , @c_ComputerName = ''
            , @c_PrinterID    = @cLabelPrinter         
            , @n_NoOfCopy     = '1'     
            , @c_KeyValue1    = @cParams1        
            , @c_KeyValue2    = @cParams2        
            , @c_KeyValue3    = @cParams3     
            , @c_KeyValue4    = @cParams4    
            , @b_Success      = @bSuccess         OUTPUT      
            , @n_Err          = @nErrNo           OUTPUT
            , @c_ErrMsg       = @cErrMsg          OUTPUT
            , @c_PrintSource  = @cPrintSource        
            , @b_SCEPreView   = 0         
            , @c_JobIDs       = @ctempLabelJobIDs OUTPUT    
            , @c_AutoPrint    = 'N'     
            
      IF @nErrNo <> 0   
      BEGIN  
         SET @n_Continue = 3 
         GOTO EXIT_SP  
      END

      FETCH NEXT FROM CUR_LBL INTO @cReportID
                                 , @cPrintSource
                                 , @cDefaultPrinterID
                                 , @cFieldName1
                                 , @cFieldName2
                                 , @cFieldName3
                                 , @cFieldName4
   END
   CLOSE CUR_LBL
   DEALLOCATE CUR_LBL

EXIT_SP:
   IF @n_Continue = 3  -- Error Occured - Process And Return      
   BEGIN      
      SET @bSuccess = 0      
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
      SELECT @bSuccess = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [API].[isp_TPACK_PrintCarrierDocument] TO NSQL
GO