SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/
/* Store Procedure: lsp_WM_SendPrintJobToProcessApp                     */
/* Creation Date: 2023-02-15                                            */
/* Copyright: Mearsk                                                    */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:  Send Print Job to Print App to Print                       */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* PVCS Version: 1.9                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver. Purposes                                   */
/* 2023-02-15   Wan     1.0  Created & DevOps Combine Script            */  
/************************************************************************/
CREATE OR ALTER PROC [WM].[lsp_WM_SendPrintJobToProcessApp] 
   @c_ReportID       NVARCHAR(10) 
,  @c_ReportLineNo   NVARCHAR(5)    = '' 
,  @c_Storerkey      NVARCHAR(15)
,  @c_Facility       NVARCHAR(5)    = ''      --optional
,  @n_NoOfParms      INT            = 0
,  @c_Parm1          NVARCHAR(30)   = ''        
,  @c_Parm2          NVARCHAR(30)   = ''        
,  @c_Parm3          NVARCHAR(30)   = ''        
,  @c_Parm4          NVARCHAR(30)   = ''        
,  @c_Parm5          NVARCHAR(30)   = ''        
,  @c_Parm6          NVARCHAR(30)   = ''        
,  @c_Parm7          NVARCHAR(30)   = ''        
,  @c_Parm8          NVARCHAR(30)   = ''        
,  @c_Parm9          NVARCHAR(30)   = ''        
,  @c_Parm10         NVARCHAR(30)   = '' 
,  @c_Parm11         NVARCHAR(30)   = ''   
,  @c_Parm12         NVARCHAR(30)   = ''   
,  @c_Parm13         NVARCHAR(30)   = ''   
,  @c_Parm14         NVARCHAR(30)   = ''   
,  @c_Parm15         NVARCHAR(30)   = ''   
,  @c_Parm16         NVARCHAR(30)   = ''   
,  @c_Parm17         NVARCHAR(30)   = ''   
,  @c_Parm18         NVARCHAR(30)   = ''   
,  @c_Parm19         NVARCHAR(30)   = ''   
,  @c_Parm20         NVARCHAR(30)   = ''           
,  @n_Noofcopy       INT            =  1     --optional
,  @c_PrinterID      NVARCHAR(30)   = ''     --optional
,  @c_IsPaperPrinter NVARCHAR(5)    = 'N'    --optional
,  @c_ReportTemplate NVARCHAR(40)   = ''     --optional
,  @c_PrintData      NVARCHAR(MAX)  = ''     --optional
,  @c_PrintType      NVARCHAR(30)   = ''     --ZPL / TCPSPOOLER /  ITFDOC 
,  @c_UserName       NVARCHAR(128)  = ''     --optional  
,  @b_SCEPreView     INT            = 0    
,  @n_JobID          INT            = 0   OUTPUT   
,  @b_success        INT            = 1   OUTPUT 
,  @n_err            INT            = 0   OUTPUT 
,  @c_errmsg         NVARCHAR(255)  = ''  OUTPUT
AS
BEGIN
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF
   SET ANSI_NULLS OFF     

   DECLARE
      @n_starttcnt            INT            = @@TRANCOUNT
   ,  @n_continue             INT            = 1 
   ,  @b_debug                INT            = 0    
   ,  @n_Retry                INT            = 1
   ,  @n_Mobile               INT            = 0
   ,  @n_QueueID              INT            = 0  
   ,  @n_Function_ID          INT            = 999
   
   ,  @b_SkipSend2QCmd        BIT            = 0 
   
   ,  @c_DefaultFacility      NVARCHAR(5)    = ''
   ,  @c_DefaultPrinter       NVARCHAR(10)   = ''
   ,  @c_DefaultPrinter_Paper NVARCHAR(10)   = ''

   ,  @c_ProcessApp           NVARCHAR(50)   = ''
      
   ,  @c_PDFPreview           CHAR(1)        = 'N' 
   ,  @c_CountryPDFFolder     NVARCHAR(30)   = '' 
   ,  @c_PDFPreviewServer     NVARCHAR(30)   = '' 

   ,  @c_WinPrinter           NVARCHAR(128)  = ''
           
   ,  @c_SpoolerGroup         NVARCHAR(20)   = ''        
   ,  @c_IPAddress            NVARCHAR(40)   = ''        
   ,  @c_PortNo               NVARCHAR(5)    = ''
   ,  @c_PrintApp             NVARCHAR(50)   = ''         
   ,  @c_IniFilePath          NVARCHAR(200)  = ''        
   ,  @c_DataReceived         NVARCHAR(4000) = ''        

   ,  @c_SkipQCmdByPrinter    NVARCHAR(50)   = ''    
   ,  @c_SpoolerPrinterID     NVARCHAR(50)   = ''   
   
   ,  @c_TargetDB             NVARCHAR(20)   = DB_NAME()
   ,  @c_JobName              NVARCHAR(50)   = ''
   ,  @c_JobID                NVARCHAR(20)   = ''
   ,  @c_JobStatus            NVARCHAR(10)   = '0'

   ,  @c_QPrintCmd            NVARCHAR(1024) = '' 
   ,  @c_SendSocketData       NVARCHAR(4000) = ''
      
   SET @b_success    = 0
   SET @n_err        = 0
   SET @c_errmsg     = ''   
   SET @c_SpoolerGroup = ''                                          

   IF @c_PrintType NOT IN ( 'QCOMMANDER', 'TCPSPOOLER', 'ZPL', 'ITFDOC' )
   BEGIN
      GOTO EXIT_SP
   END
         
   IF @c_UserName = '' SET @c_UserName = SUSER_SNAME()
   
   SELECT @c_ProcessApp = ISNULL(c.Long,'')
   FROM dbo.CODELKUP AS c (NOLOCK)
   WHERE c.LISTNAME = 'WMPrintTyp'
   AND c.Code = @c_PrintType
   
   IF @c_PrinterID = '' AND @b_SCEPreView = 0
   BEGIN
      SELECT TOP 1 
               @c_DefaultFacility = ISNULL(DefaultFacility,'')
            ,  @c_DefaultPrinter  = ISNULL(ru.DefaultPrinter,'')
            ,  @c_DefaultPrinter_Paper = ISNULL(ru.DefaultPrinter_Paper,'')
      FROM RDT.RDTUser AS ru (NOLOCK)
      WHERE ru.UserName = @c_UserName
      
      IF @c_Facility = '' SET @c_Facility = @c_DefaultFacility
      
      SET @c_PrinterID = IIF (@c_IsPaperPrinter = 'Y', @c_DefaultPrinter_Paper, @c_DefaultPrinter)
 
      IF @c_PrinterID = '' 
      BEGIN
         SET @n_Continue = 3    
         SET @n_Err = 561251    
         SET @c_ErrMsg='NSQL'+CONVERT(CHAR(6),@n_Err)+ ': Default Printer Not Setup For User: ' 
                         + @c_UserName + ' (lsp_WM_SendPrintJobToProcessApp) |' + @c_UserName
         GOTO EXIT_SP
      END
   END 
   
   IF @b_SCEPreView = 1 
   BEGIN 
      SET @c_PDFPreview = 'Y'
      SELECT TOP 1
            @c_PDFPreviewServer  = sc.SValue
         ,  @c_CountryPDFFolder  = ISNULL(sc.Option1,'')          
      FROM dbo.StorerConfig AS sc (NOLOCK)  
      WHERE sc.ConfigKey='PDFPreviewServer' 
      AND sc.Storerkey IN (@c_Storerkey, 'ALL') 
      ORDER BY  CASE WHEN sc.Storerkey  = @c_Storerkey THEN 1
                     WHEN sc.Storerkey  = 'ALL'        THEN 2
                     ELSE 9
                     END
               
      IF @c_PDFPreviewServer = ''
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 561252
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6),@n_Err) + ': PDFPreviewServer Not Setup.'
                       + ' (lsp_WM_SendPrintJobToProcessApp)'
         GOTO EXIT_SP
      END
        
      IF @c_CountryPDFFolder = ''
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 561253
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6),@n_Err) + ': Country PDF Folder for Preview not Setup.'
                       + ' (lsp_WM_SendPrintJobToProcessApp)'
         GOTO EXIT_SP
      END
     
      SELECT TOP 1
            @c_SpoolerGroup = rs.SpoolerGroup
      FROM RDT.rdtSpooler AS rs WITH (NOLOCK)
      WHERE rs.IPAddress = @c_PDFPreviewServer
      
      SELECT TOP 1 @c_PrinterID = rp.PrinterID     
      FROM rdt.RDTPrinter AS rp WITH (NOLOCK)  
      LEFT JOIN rdt.RDTPrintJob AS rpj WITH (NOLOCK) ON rp.PrinterID = rpj.Printer  
      WHERE rp.SpoolerGroup = @c_SpoolerGroup  
      GROUP BY rp.PrinterID  
      ORDER BY COUNT(rpj.Printer)   
               ,  rp.PrinterID
   END 
   ELSE IF @c_PrinterID <> '' 
   BEGIN
      SELECT @c_SpoolerGroup = ISNULL(RTRIM(P.SpoolerGroup),'')
      FROM rdt.rdtPrinter P WITH (NOLOCK)
      WHERE P.PrinterID = @c_PrinterID
   END

   IF @c_SpoolerGroup = '' 
   BEGIN
      SET @n_Continue = 3    
      SET @n_Err = 561254   
      SET @c_ErrMsg='NSQL'+CONVERT(CHAR(6),@n_Err)+': Spooler Group Not Setup for printerid: ' 
                   + RTRIM(@c_PrinterID) + ' (lsp_WM_SendPrintJobToProcessApp) |' + RTRIM(@c_PrinterID)
      GOTO EXIT_SP    
   END

   -- Get spooler info
   SET @c_IPAddress = ''
   SET @c_PortNo    = ''
   SET @c_QPrintCmd   = ''
   SET @c_IniFilePath = ''

   SELECT 
         @c_IPAddress = IPAddress 
      ,  @c_PortNo    = PortNo
      ,  @c_PrintApp  = Command
      ,  @c_IniFilePath = IniFilePath
   FROM rdt.rdtSpooler WITH (NOLOCK)
   WHERE SpoolerGroup = @c_SpoolerGroup

   IF @@ROWCOUNT = 0 OR @c_IPAddress = '' OR @c_PortNo = '' OR @c_PrintApp = '' OR @c_IniFilePath = ''
   BEGIN
      SET @n_Continue = 3    
      SET @n_Err = 561255   
      SET @c_ErrMsg='NSQL'+CONVERT(CHAR(6),@n_Err)+': Spooler Group Not Setup. (lsp_WM_SendPrintJobToProcessApp)'
      GOTO EXIT_SP   
   END  
   SET @c_JobName = 'PRINT_' + @c_ReportID
  
   BEGIN TRAN

   IF NOT EXISTS (SELECT 1 FROM RDT.RDTMOBREC (NOLOCK) WHERE UserName = @c_UserName)  
   BEGIN
      SET @n_Retry = 1

      WHILE @n_Retry <= 3 
      BEGIN
         SELECT @n_Mobile = ISNULL(MAX(Mobile),0) + 1
         FROM RDT.RDTMOBREC (NOLOCK)
          
         BEGIN TRY     
            INSERT INTO RDT.RDTMOBREC (Mobile, UserName, Storerkey, Facility, Printer, ErrMsg, Inputkey)
            VALUES (@n_Mobile, @c_UserName, @c_Storerkey, ISNULL(@c_Facility,''), ISNULL(@c_PrinterID,''),'WMS',0)
         END TRY

         BEGIN CATCH
            SET @n_Err = @@ERROR
         END CATCH

         IF @n_Err = 0
         BEGIN 
            BREAK
         END

         SET @n_Retry = @n_Retry + 1
      END

      IF @n_Err <> 0   
      BEGIN  
         SELECT @n_Continue = 3    
         SELECT @n_Err = 561256    
         SELECT @c_ErrMsg='NSQL'+CONVERT(CHAR(6),@n_Err)+': Insert Error On Table RDT.RDTMOBREC. (lsp_WM_SendPrintJobToProcessApp)'
         GOTO EXIT_SP                          
      END  
   END
   ELSE
   BEGIN
      SELECT TOP 1 @n_Mobile = Mobile
      FROM RDT.RDTMOBREC (NOLOCK) 
      WHERE UserName = @c_UserName
        
      UPDATE RDT.RDTMOBREC WITH (ROWLOCK)
      SET Storerkey = @c_Storerkey
         ,Facility = ISNULL(@c_Facility,'')
         ,Printer  = ISNULL(@c_PrinterID,'')
      WHERE Mobile = @n_Mobile

      IF @@ERROR <> 0 
      BEGIN  
         SELECT @n_Continue = 3    
         SELECT @n_Err = 561257    
         SELECT @c_ErrMsg='NSQL'+CONVERT(CHAR(6),@n_Err)+': Update Error On Table RDT.RDTMOBREC. (lsp_WM_SendPrintJobToProcessApp)'
         GOTO EXIT_SP                          
      END  
   END

   SET @b_Success = 1
   SET @c_SkipQCmdByPrinter = ''
   EXEC nspGetRight      
         @c_Facility  = @c_Facility     
      ,  @c_StorerKey = @c_StorerKey      
      ,  @c_sku       = NULL      
      ,  @c_ConfigKey = 'SkipQCmdByPrinter'      
      ,  @b_Success   = @b_Success              OUTPUT      
      ,  @c_authority = @c_SkipQCmdByPrinter    OUTPUT      
      ,  @n_err       = @n_err                  OUTPUT      
      ,  @c_errmsg    = @c_errmsg               OUTPUT
      ,  @c_Option1   = @c_SpoolerPrinterID     OUTPUT

   IF @b_Success <> 1
   BEGIN
      SET @n_Continue = 3
      SET @n_Err = 561258
      SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err)  
                  + ': Error Executing nspGetRight - SkipQCmdByPrinter. (lsp_WM_SendPrintJobToProcessApp)'  
      GOTO EXIT_SP
   END

   IF @c_SkipQCmdByPrinter = '1' AND @c_PrinterID IN (SELECT Value FROM STRING_SPLIT(@c_SpoolerPrinterID,','))  
   BEGIN
      SET @c_JobStatus = '9'
      SET @b_SkipSend2QCmd = 1
   END
   
   IF @c_PrintType = 'ZPL'
   BEGIN
      SET @c_JobStatus = '9'
      --SET @c_QPrintCmd = @c_PrintApp + ' ' + @c_JobID
   END 

   IF @c_PrintType = 'ITFDOC'
   BEGIN
      SET @c_JobStatus = '9'
      SET @c_PrintData = @c_PrintApp + ' ' + @c_PrintData
   END
   
   INSERT INTO RDT.RDTPrintJob(JobName, ReportID, JobStatus, Datawindow, NoOfParms
                              ,Parm1, Parm2, Parm3, Parm4, Parm5, Parm6, Parm7, Parm8, Parm9, Parm10
                              ,Parm11, Parm12, Parm13, Parm14, Parm15, Parm16, Parm17, Parm18, Parm19, Parm20                      --(Wan06)
                              ,ReportLineNo                                                                                        --(Wan06)
                              ,Printer, NoOfCopy, Mobile, TargetDB, PrintData, JobType, Storerkey, Function_ID
                              ,PDFPreview                                                                                          --(Wan09)
                              )
   VALUES(@c_JobName, @c_ReportID, @c_JobStatus, @c_ReportTemplate, @n_NoOfParms
         ,@c_Parm1, @c_Parm2, @c_Parm3, @c_Parm4, @c_Parm5, @c_Parm6, @c_Parm7, @c_Parm8, @c_Parm9, @c_Parm10
         ,@c_Parm11, @c_Parm12, @c_Parm13, @c_Parm14, @c_Parm15, @c_Parm16, @c_Parm17, @c_Parm18, @c_Parm19, @c_Parm20    --(Wan06)
         ,@c_ReportLineNo                                                                                                           --(Wan06)
         ,@c_PrinterId, @n_Noofcopy, @n_Mobile, @c_TargetDB
         ,@c_PrintData, @c_PrintType, @c_Storerkey, @n_Function_ID
         ,@c_PDFPreview                                                                                                             --(Wan09)         
         )

   SET @n_JobID = SCOPE_IDENTITY() 
  
   IF @@ERROR <> 0 
   BEGIN  
      SELECT @n_Continue = 3    
      SELECT @n_Err = 561259    
      SELECT @c_ErrMsg='NSQL'+CONVERT(CHAR(6),@n_Err)+': Insert Error On Table RDT.RDTPrintJob. (lsp_WM_SendPrintJobToProcessApp)'
      GOTO EXIT_SP                          
   END  

   IF @b_SkipSend2QCmd = 1
   BEGIN
      GOTO MOVE_RDTPRNJOB2LOG   
   END
   
   SET @c_JobID       = CAST( @n_JobID AS NVARCHAR( 10))
      
   IF @c_PrintType = 'QCOMMANDER'
   BEGIN
      SET @c_QPrintCmd = @c_PrintApp + ' ' + @c_JobID
   END
      
   IF @c_PrintType = 'ZPL'
   BEGIN
      SET @c_QPrintCmd = @c_PrintApp + ' ' + @c_JobID 
   END  
         
   IF @c_PrintType = 'ITFDOC'
   BEGIN
      SET @c_QPrintCmd = @c_PrintData
   END

   IF @c_ProcessApp IN ('TCPSpooler')
   BEGIN
      SET @c_SendSocketData = @c_JobID
   END
   ELSE IF @c_ProcessApp IN ('QCommander')
   BEGIN
      -- Insert task 
      INSERT INTO TCPSocket_QueueTask (CmdType, Cmd, StorerKey, Port, TargetDB, IP, TransmitLogKey, DataStream) 
      VALUES ('CMD', @c_QPrintCmd, @c_StorerKey, @c_PortNo, DB_NAME(), @c_IPAddress, @c_JobID, @c_PrintType )  

      SET @n_QueueID = SCOPE_IDENTITY()

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3    
         SET @n_Err = 561260   
         SET @c_ErrMsg='NSQL'+CONVERT(CHAR(6),@n_Err)+': Insert Error QCommander Task. (lsp_WM_SendPrintJobToProcessApp)'
         GOTO EXIT_SP    
      END
   
      -- For Eg <STX>CMD|855377|CNWMS|D:\RDTSpooler\rdtprint.exe 2668351<ETX>
      SET @c_SendSocketData = 
         '<STX>' + 
            'CMD|' + 
            CAST( @n_QueueID AS NVARCHAR( 20)) + '|' + 
            DB_NAME() + '|' + 
            @c_QPrintCmd + 
         '<ETX>'
   END
   
   IF @c_SendSocketData <> ''
   BEGIN
      BEGIN TRY
         EXEC isp_QCmd_SendTCPSocketMsg
               @cApplication  = @c_ProcessApp
            ,  @cStorerKey    = @c_StorerKey 
            ,  @cMessageNum   = @c_JobID
            ,  @cData         = @c_SendSocketData
            ,  @cIP           = @c_IPAddress 
            ,  @cPORT         = @c_PortNo 
            ,  @cIniFilePath  = @c_IniFilePath 
            ,  @cDataReceived = @c_DataReceived OUTPUT
            ,  @bSuccess      = @b_Success      OUTPUT 
            ,  @nErr          = @n_err          OUTPUT 
            ,  @cErrMsg       = @c_ErrMsg       OUTPUT 

      END TRY
      BEGIN CATCH
         SET @n_Err = @@ERROR
         SET @c_ErrMsg = ERROR_MESSAGE()
      END  CATCH 
  
      IF @n_err <> 0
      BEGIN
         SET @n_continue = 3
         IF @n_QueueID > 0 
         BEGIN
            EXEC dbo.isp_QCmd_UpdateQueueTaskStatus                
                  @cTargetDB    = @c_TargetDB              
               ,  @nQTaskID     = @n_QueueID                 
               ,  @cQStatus     = 'X'                
               ,  @cThreadID    = ''                
               ,  @cMsgRecvDate = ''                
               ,  @cQErrMsg     = ''  
         END
      
         IF @n_JobID > 0
         BEGIN 
            SET @c_JobStatus = '5'
         END                   
      END
   END  
   
   MOVE_RDTPRNJOB2LOG: 
   IF @n_JobID > 0 AND @c_JobStatus IN ('5','9')
   BEGIN
      EXEC [dbo].[isp_UpdateRDTPrintJobStatus]                
                @n_JobID      = @n_JobID                
               ,@c_JobStatus  = @c_JobStatus                
               ,@c_JobErrMsg  = @c_ErrMsg                
               ,@b_Success    = @b_Success OUTPUT                
               ,@n_Err        = @n_Err   OUTPUT                
               ,@c_ErrMsg     = @c_ErrMsg  OUTPUT
   END 
   
   WHILE @@TRANCOUNT > 0
   BEGIN
      COMMIT TRAN
   END 

   EXIT_SP:

   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_success = 0     
      IF @@TRANCOUNT > @n_starttcnt 
      BEGIN
         ROLLBACK TRAN
      END
      ELSE 
      BEGIN
         WHILE @@TRANCOUNT > @n_starttcnt 
         BEGIN
            COMMIT TRAN
         END          
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, "lsp_WM_SendPrintJobToProcessApp"
   END
   ELSE 
   BEGIN
      SELECT @b_success = 1
      
      WHILE @@TRANCOUNT > @n_starttcnt 
      BEGIN
         COMMIT TRAN
      END
   END
   
   WHILE @@TRANCOUNT < @n_starttcnt
   BEGIN
      BEGIN TRAN
   END
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON [WM].[lsp_WM_SendPrintJobToProcessApp] TO NSQL
GO
