SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: WM.lsp_WM_Print_ITFDoc_Wrapper                          */
/* Creation Date: 2023-02-15                                            */
/* Copyright: Mearsk                                                    */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose: NextGen Ecom Packing                                        */
/*        : LFWM-3913-Ship Reference Enhancement-Print Interface Document*/                                                         
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 8.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2023-02-15  Wan      1.0   Created & DevOps Combine Script           */ 
/************************************************************************/
CREATE OR ALTER PROC [WM].[lsp_WM_Print_ITFDoc_Wrapper]
   @n_WMReportRowID      BIGINT 
,  @c_Storerkey          NVARCHAR(15)
,  @c_Facility           NVARCHAR(5)
,  @c_UserName           NVARCHAR(128)               
,  @c_PrinterID          NVARCHAR(30)   = ''
,  @c_IsPaperPrinter     NCHAR(1)       = 'Y'
,  @n_Noofparms          INT            = 0
,  @c_Parm1              NVARCHAR(60)
,  @c_Parm2              NVARCHAR(60)   = ''
,  @c_Parm3              NVARCHAR(60)   = ''
,  @c_Parm4              NVARCHAR(60)   = ''
,  @c_Parm5              NVARCHAR(60)   = ''
,  @c_Parm6              NVARCHAR(60)   = ''
,  @c_Parm7              NVARCHAR(60)   = ''
,  @c_Parm8              NVARCHAR(60)   = ''
,  @c_Parm9              NVARCHAR(60)   = ''
,  @c_Parm10             NVARCHAR(60)   = ''         
,  @c_Parm11             NVARCHAR(60)   = ''
,  @c_Parm12             NVARCHAR(60)   = ''
,  @c_Parm13             NVARCHAR(60)   = ''
,  @c_Parm14             NVARCHAR(60)   = ''
,  @c_Parm15             NVARCHAR(60)   = ''
,  @c_Parm16             NVARCHAR(60)   = ''
,  @c_Parm17             NVARCHAR(60)   = ''
,  @c_Parm18             NVARCHAR(60)   = ''
,  @c_Parm19             NVARCHAR(60)   = ''
,  @c_Parm20             NVARCHAR(60)   = ''
,  @b_Success            INT            = 1  OUTPUT
,  @n_Err                INT            = 0  OUTPUT
,  @c_ErrMsg             NVARCHAR(255)  = '' OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt             INT
         , @n_Continue              INT 
  
         , @b_ContinuePrint         BIT               = 1
         
         , @c_ModuleID              NVARCHAR(30)      = ''
         , @c_SourceType            NVARCHAR(50)      = 'lsp_WM_Print_ITFDoc_Wrapper'
         , @c_ReportID              NVARCHAR(10)      = ''
         , @c_ReportLineNo          NVARCHAR(5)       = ''
         , @c_ReportType            NVARCHAR(30)      = ''
         , @c_PrintType             NVARCHAR(30)      = ''
         , @c_PrintTemplateSP       NVARCHAR(1000)    = ''
      
         , @c_Authority             NVARCHAR(30)      = ''
         , @c_PdfFile               NVARCHAR(100)     = ''
         , @c_ActionType            NVARCHAR(10)      = '3'
         , @c_Printer               NVARCHAR(128)     = ''
         
         , @c_PrintData             NVARCHAR(MAX)     = ''
         , @c_PrintSettings         NVARCHAR(4000)    = ''
         , @c_StorerConfig          NVARCHAR(30)      = ''
         , @c_PrintSettingID        NVARCHAR(10)      = ''

         , @c_SQL                   NVARCHAR(MAX)     = ''
         , @c_SQLParms              NVARCHAR(MAX)     = ''    

   BEGIN TRY
      SELECT @c_ModuleID = @c_ModuleID
            ,@c_ReportID = w.ReportID
            ,@c_ReportType = w2.ReportType
            ,@c_PrintType  = w.Printtype
            ,@c_PrintSettings = w.PrintSettings
            ,@c_ReportLineNo = w.ReportLineNo
            ,@c_PrintTemplateSP = w.PrintTemplateSP
      FROM dbo.WMREPORTDETAIL AS w WITH (NOLOCK)
      JOIN dbo.WMREPORT AS w2 WITH (NOLOCK) ON w2.ReportID = w.ReportID
      WHERE w.RowID = @n_WMReportRowID
    
      SET @c_StorerConfig = ''
      SET @c_StorerConfig = dbo.fnc_GetParamValueFromString( '@c_StorerConfig', @c_PrintSettings, @c_StorerConfig)
         
      IF @c_StorerConfig = ''
      BEGIN
         GOTO EXIT_SP
      END 
            
      SELECT @c_Authority = fgr.Authority FROM dbo.fnc_GetRight2(@c_Facility, @c_Storerkey, '', @c_StorerConfig) AS fgr
      IF @c_Authority = 1 AND @c_StorerConfig IN ('PrintItfReport')
      BEGIN
         EXEC dbo.isp_PrintInterface_Report 
            @c_Parm01   = @c_Parm1
         ,  @c_Parm02   = @c_Parm2
         ,  @c_Parm03   = @c_Parm3
         ,  @c_Parm04   = @c_Parm4
         ,  @c_Parm05   = @c_Parm5
         ,  @b_Success  = @b_Success   OUTPUT
         ,  @n_Err      = @n_Err       OUTPUT       
         ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
         ,  @c_PrinterID= @c_PrinterID     

         IF @b_Success = 0 
         BEGIN
            SET @n_Continue = 3                 
            SET @n_err = 561101
            SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Error Executing isp_PrintInterface_Report. (lsp_WM_Print_ITFDoc_Wrapper)'
                           + '( ' + @c_errmsg + ' )'
            GOTO EXIT_SP
         END  
         SET @b_ContinuePrint = 0
      END
        
      IF @b_ContinuePrint = 1
      BEGIN
         IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(@c_Authority) AND TYPE = 'P')
         BEGIN
            SET @c_PrintTemplateSP = @c_Authority
            SET @c_SQL = N'EXEC ' + @c_PrintTemplateSP  
                        + ' @c_Param01 = @c_Parm1'                           
                        + ',@c_Param02 = @c_Parm2'                           
                        + ',@c_Param03 = @c_Parm3'                           
                        + ',@c_Param04 = @c_Parm4'                           
                        + ',@c_Param05 = @c_Parm5' 
                        + ',@b_Success = @b_Success OUTPUT'             
                        + ',@n_Err     = @n_Err     OUTPUT'                     
                        + ',@c_ErrMsg  = @c_ErrMsg  OUTPUT' 
                          
            SET @c_SQLParms= N'@c_Parm1         NVARCHAR(60)'         
                           + ',@c_Parm2         NVARCHAR(60)'         
                           + ',@c_Parm3         NVARCHAR(60)'         
                           + ',@c_Parm4         NVARCHAR(60)'         
                           + ',@c_Parm5         NVARCHAR(60)' 
                           + ',@b_Success       INT           OUTPUT' 
                           + ',@n_Err           INT           OUTPUT' 
                           + ',@c_ErrMsg        NVARCHAR(255) OUTPUT'                             
            
            EXEC sp_ExecuteSQL @c_SQL
                              ,@c_SQLParms  
                              ,@c_Parm1              
                              ,@c_Parm2              
                              ,@c_Parm3              
                              ,@c_Parm4              
                              ,@c_Parm5              
                              ,@b_Success   OUTPUT
                              ,@n_Err       OUTPUT
                              ,@c_ErrMsg    OUTPUT
                              
            IF @b_Success = 0 
            BEGIN
               SET @n_Continue = 3                 
               SET @n_err = 561102
               SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Error Executing ' + @c_PrintTemplateSP +'. (lsp_WM_Print_ITFDoc_Wrapper)'
                              + '( ' + @c_errmsg + ' ) |' + @c_PrintTemplateSP
               GOTO EXIT_SP
            END                
                              
            SET @b_ContinuePrint = 0           
         END
      END
      
      SET @c_PrintSettingID = ''
      SET @c_PrintSettingID = dbo.fnc_GetParamValueFromString('@c_PrintSettingID', @c_PrintSettings, @c_PrintSettingID)
      
      SET @c_PrinterID = dbo.fnc_GetParamValueFromString('@c_PrinterID', @c_PrintSettings,  @c_PrinterID)

      IF @c_PrintSettingID = ''
      BEGIN
         GOTO EXIT_SP
      END
         
      IF @c_PrinterID = ''
      BEGIN
         GOTO EXIT_SP
      END 

      SELECT @c_Printer = rp.WinPrinter
      FROM RDT.RDTPrinter AS rp WITH (NOLOCK)
      WHERE rp.PrinterID = @c_PrinterID

      IF @b_ContinuePrint = 1 AND @c_Authority = '1'
      BEGIN
         EXEC dbo.isp_GetPrint2PDFConfig
               @c_Storerkey = @c_Storerkey                         
            ,  @c_Facility  = @c_Facility                       
            ,  @c_Configkey = @c_StorerConfig                        
            ,  @c_Param01 = @c_Parm1                           
            ,  @c_Param02 = @c_Parm2                           
            ,  @c_Param03 = @c_Parm3                           
            ,  @c_Param04 = @c_Parm4                           
            ,  @c_Param05 = @c_Parm5                           
            ,  @c_PdfFile = @c_PdfFile OUTPUT            
            ,  @c_Printer = @c_Printer             
            ,  @c_ArchiveFolder = ''
            ,  @c_ActionType    = @c_ActionType    OUTPUT       
            ,  @n_PrintAction   = '' 
            ,  @c_Dimension     = ''         
            ,  @n_NoOfPDFSheet  = 0                        
            ,  @b_Success       = @b_Success OUTPUT             
            ,  @n_Err           = @n_Err     OUTPUT                     
            ,  @c_ErrMsg        = @c_ErrMsg  OUTPUT               
            ,  @c_FromModule    = @c_ModuleID 
                                      
         IF @b_Success = 0 
         BEGIN
            SET @n_Continue = 3                 
            SET @n_err = 561103
            SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Error Executing isp_GetPrint2PDFConfig. (lsp_WM_Print_ITFDoc_Wrapper)'
                           + '( ' + @c_errmsg + ' )'
            GOTO EXIT_SP
         END
        
         --TEsting Data --SET @c_PdfFile = 'INVOICE_LZD, COURIER_LZD_SG236995844466B.pdf'
              
         SET @c_PrintData = '''' + @c_PdfFile + ''' ' 
                          + '''' + @c_PrintSettingID + ''' ' 
                          + '''' + @c_ActionType + ''' ' 
                          + '''' + @c_Printer + ''''  
              
         SET @b_ContinuePrint = 0     
      END

      IF @c_PrintData <> ''
      BEGIN
         EXEC [WM].[lsp_WM_SendPrintJobToProcessApp]  
            @c_ReportID       = @c_ReportID
         ,  @c_ReportLineNo   = @c_ReportLineNo       
         ,  @c_Storerkey      = @c_Storerkey  
         ,  @c_Facility       = @c_Facility         
         ,  @n_Noofparms      = @n_Noofparms  
         ,  @c_Parm1          = @c_Parm1            
         ,  @c_Parm2          = @c_Parm2            
         ,  @c_Parm3          = @c_Parm3            
         ,  @c_Parm4          = @c_Parm4            
         ,  @c_Parm5          = @c_Parm5            
         ,  @c_Parm6          = @c_Parm6            
         ,  @c_Parm7          = @c_Parm7            
         ,  @c_Parm8          = @c_Parm8            
         ,  @c_Parm9          = @c_Parm9            
         ,  @c_Parm10         = @c_Parm10     
         ,  @c_Parm11         = @c_Parm11       
         ,  @c_Parm12         = @c_Parm12       
         ,  @c_Parm13         = @c_Parm13       
         ,  @c_Parm14         = @c_Parm14                            
         ,  @c_Parm15         = @c_Parm15         
         ,  @c_Parm16         = @c_Parm16         
         ,  @c_Parm17         = @c_Parm17         
         ,  @c_Parm18         = @c_Parm18         
         ,  @c_Parm19         = @c_Parm19         
         ,  @c_Parm20         = @c_Parm20                
         ,  @n_Noofcopy       = 1                    --optional
         ,  @c_PrinterID      = @c_PrinterID         --optional
         ,  @c_IsPaperPrinter = @c_IsPaperPrinter    --optional
         ,  @c_ReportTemplate = ''                   --optional
         ,  @c_PrintData      = @c_PrintData         --optional
         ,  @c_PrintType      = @c_PrintType         --ZPL / TCPSPOOLER /  ITFDOC
         ,  @c_UserName       = ''                   --optional  
         ,  @b_SCEPreView     = 0        
         ,  @n_JobID          = 0                      
         ,  @b_success        = @b_success          OUTPUT 
         ,  @n_err            = @n_err              OUTPUT 
         ,  @c_errmsg         = @c_errmsg           OUTPUT
          
         IF @n_err <> 0
         BEGIN 
            SET @n_Continue = 3        
            SET @n_err = 552655
            SET @c_ErrMsg = ERROR_MESSAGE()
            SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Error Executing lsp_SendPrintJobToPrintApp. ([lsp_WM_Print_ITFDoc_Wrapper])'
                           + '( ' + @c_errmsg + ' )'
            GOTO EXIT_SP               
         END 
      END
   END TRY
 
   BEGIN CATCH
      SET @n_Continue = 3
      SET @c_ErrMsg = ERROR_MESSAGE()
      GOTO EXIT_SP
   END CATCH
EXIT_SP:
   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_WM_Print_ITFDoc_Wrapper'
      --RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- procedure
GO
GRANT EXECUTE ON [WM].[lsp_WM_Print_ITFDoc_Wrapper] TO nSQL 
GO
