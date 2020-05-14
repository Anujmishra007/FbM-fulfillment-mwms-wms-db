IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_GetPrint2PDFConfig]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[isp_GetPrint2PDFConfig]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/***************************************************************************/  
/* Stored Procedure: isp_GetPrint2PDFConfig                                */  
/* Creation Date: 22-Oct-2019                                              */  
/* Copyright: LFL                                                          */  
/* Written by:                                                             */  
/*                                                                         */  
/* Purpose: Print to PDF  (ispGet<Module>PDFXX)                            */                                 
/*                                                                         */  
/* Called By:                                                              */  
/*                                                                         */  
/*                                                                         */  
/* PVCS Version: 1.0                                                       */  
/*                                                                         */  
/* Version: 7.0                                                            */  
/*                                                                         */  
/* Data Modifications:                                                     */  
/*                                                                         */  
/* Updates:                                                                */  
/* Date           Ver    Author   Purposes                                 */  
/***************************************************************************/    
CREATE PROC [dbo].[isp_GetPrint2PDFConfig]    
(     
      @c_Storerkey     NVARCHAR(15),
      @c_Facility      NVARCHAR(5), 
      @c_Configkey     NVARCHAR(30),
      @c_Param01       NVARCHAR(50),
      @c_Param02       NVARCHAR(50),
      @c_Param03       NVARCHAR(50),
      @c_Param04       NVARCHAR(50),
      @c_Param05       NVARCHAR(50),
      @c_PdfFile       NVARCHAR(500) OUTPUT,
      @c_Printer       NVARCHAR(500) OUTPUT,
      @c_ArchiveFolder NVARCHAR(500) OUTPUT,
      @c_ActionType    NVARCHAR(10)  OUTPUT,  --2 = Print and don't move 3 = Print and move (Default)
      @n_PrintAction   INT           OUTPUT,  --0 = Not print PDF  1=Print PDF   2=Print PDF and continue other printing
      @c_Dimension     NVARCHAR(50)  OUTPUT,  --Dimension in mm x mm, eg. 210x297
      @n_NoOfPDFSheet  INT = 1,               --PDF Sheets number (For 1 ReportType print multiple layout)
      --@c_PostPrinting  NVARCHAR(1)   OUTPUT,  --Y - PostPrinting, N - DirectPrint (Need to wait)
      @b_Success       INT           OUTPUT,  
      @n_Err           INT           OUTPUT, 
      @c_ErrMsg        NVARCHAR(255) OUTPUT     
)    
AS    
BEGIN    
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
    
   DECLARE @n_Continue     INT   
         , @n_StartTCount  INT   
         , @c_SPCode       NVARCHAR(50)
         , @c_SQL          NVARCHAR(MAX)         
         , @c_authority    NVARCHAR(30)
         , @c_option1      NVARCHAR(50)
         , @c_option2      NVARCHAR(50)
         , @c_option3      NVARCHAR(50)
         , @c_option4      NVARCHAR(50)
         , @c_option5      NVARCHAR(4000)
         , @c_PdfFolder    NVARCHAR(500)
         , @dt_timeIn      DATETIME
         , @dt_timeOut     DATETIME

   DECLARE @c_TraceCode   NVARCHAR(20) = 'Print2PDFMainSP'  
         , @c_TraceName   NVARCHAR(80) = 'isp_GetPrint2PDFConfig'   

   SET @b_Success= 1   
   SET @n_Err    = 0    
   SET @c_ErrMsg = ''   
   SET @n_Continue = 1    
   SET @n_StartTCount = @@TRANCOUNT  
   SET @dt_timeIn = GETDATE()

   EXECUTE nspGetRight                                
    @c_Facility  = @c_facility,                     
    @c_StorerKey = @c_StorerKey,                    
    @c_sku       = '',
    @c_ConfigKey =  @c_Configkey,
    @b_Success   = @b_success   OUTPUT,             
    @c_authority = @c_authority OUTPUT,             
    @n_err       = @n_err       OUTPUT,             
    @c_errmsg    = @c_errmsg    OUTPUT,             
    @c_Option1   = @c_option1 OUTPUT,               
    @c_Option2   = @c_option2 OUTPUT,               
    @c_Option3   = @c_option3 OUTPUT,               
    @c_Option4   = @c_option4 OUTPUT,               
    @c_Option5   = @c_option5 OUTPUT   --@c_PdfFolder  @c_ArchiveFolder  @c_Printer @c_PostPrinting @c_Dimension   e.g.  @c_ArchiveFolder=c:\pdf\archive @c_printer=PDF Creator @c_Dimension=210x297
     
   IF ISNULL(@c_authority,'') <> '1'
   BEGIN
   	  SET @n_PrintAction = 0
   	  GOTO QUIT_SP
   END
   
   IF ISNULL(@c_ArchiveFolder,'') = ''
      SELECT @c_ArchiveFolder = dbo.fnc_GetParamValueFromString('@c_ArchiveFolder', @c_Option5, @c_ArchiveFolder)  

   IF ISNULL(@c_Printer,'') = ''
      SELECT @c_Printer = dbo.fnc_GetParamValueFromString('@c_Printer', @c_Option5, @c_Printer) 
      
   IF ISNULL(@c_Dimension,'') = ''
      SELECT @c_Dimension = dbo.fnc_GetParamValueFromString('@c_Dimension', @c_Option5, @c_Dimension)       

   --IF ISNULL(@c_PostPrinting,'') = ''
   --   SELECT @c_PostPrinting = dbo.fnc_GetParamValueFromString('@c_PostPrinting', @c_Option5, @c_PostPrinting)  
      
   --IF ISNULL(@c_PostPrinting,'') = ''
   --   SET @c_PostPrinting = 'Y'     --Default = 'Y'

   SELECT @c_PdfFolder = dbo.fnc_GetParamValueFromString('@c_PdfFolder', @c_Option5, @c_PdfFolder)          
   
   SELECT @c_SPCode = @c_Option1

   --SELECT @c_PdfFolder, @c_ArchiveFolder, @c_Printer, @c_SPCode
   
   IF ISNULL(@c_SPCode,'') = '' AND (ISNULL(@c_PdfFile,'') = '' OR ISNULL(@c_ArchiveFolder,'') = '' OR ISNULL(@c_Printer,'') = '')  
   BEGIN
      SET @n_Continue = 3
      SET @n_err      = 83000   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
      SET @c_ErrMsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)+
      ': Storerconfig' + RTRIM(@c_configkey) + '.Option1 - Stored Proc name is not setup (isp_GetPrint2PDFConfig )'        
      GOTO QUIT_SP     	
   END
   
   IF ISNULL(@c_SPCode,'') <> ''
   BEGIN
      IF NOT EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = RTRIM(@c_SPCode) AND type = 'P')  
      BEGIN  
            SET @n_Continue = 3
            SET @n_err      = 83010   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
            SET @c_ErrMsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)+
            ': Storerconfig' + RTRIM(@c_configkey) + '.Option1 - Stored Proc name is invalid (isp_GetPrint2PDFConfig )'        
            GOTO QUIT_SP  
      END        
    
      SET @c_SQL = 'EXEC ' + @c_SPCode + ' @c_Storerkey=@c_StorerkeyP, @c_Facility=@c_FacilityP, @c_Configkey=@c_ConfigkeyP, 
                   @c_Param01=@c_Param01P, @c_Param02=@c_Param02P, @c_Param03=@c_Param03P,@c_Param04=@c_Param04P, @c_Param05=@c_Param05P, @c_PdfFolder=@c_PdffolderP,
                   @c_PdfFile=@c_PdfFileP OUTPUT, @c_Printer=@c_PrinterP OUTPUT, @c_ArchiveFolder=@c_ArchiveFolderP OUTPUT, @c_ActionType=@c_ActionTypeP OUTPUT, @n_PrintAction=@n_PrintActionP OUTPUT,
                   @c_Dimension=@c_DimensionP OUTPUT, @n_NoOfPDFSheet=@n_NoOfPDFSheetP,
                   @b_Success=@b_SuccessP OUTPUT, @n_Err=@n_ErrP OUTPUT, @c_ErrMsg=@c_ErrMsgP OUTPUT '  

      EXEC sp_executesql @c_SQL   
          ,N'@c_StorerkeyP NVARCHAR(15), @c_FacilityP NVARCHAR(5), @c_ConfigkeyP NVARCHAR(30), 
            @c_Param01P NVARCHAR(50), @c_Param02P NVARCHAR(50), @c_Param03P NVARCHAR(50),@c_Param04P NVARCHAR(50), @c_Param05P NVARCHAR(50), @c_PdfFolderP NVARCHAR(500),
            @c_PdfFileP NVARCHAR(500) OUTPUT, @c_PrinterP NVARCHAR(500) OUTPUT, @c_ArchiveFolderP NVARCHAR(500) OUTPUT, @c_ActionTypeP NVARCHAR(10) OUTPUT, @n_PrintActionP INT OUTPUT,
            @c_DimensionP NVARCHAR(50) OUTPUT, @n_NoOfPDFSheetP INT,
            @b_SuccessP INT OUTPUT, @n_ErrP INT OUTPUT, @c_ErrMsgP NVARCHAR(255) OUTPUT '   
          ,@c_Storerkey
          ,@c_Facility 
          ,@c_Configkey
          ,@c_Param01       
          ,@c_Param02
          ,@c_Param03
          ,@c_Param04
          ,@c_Param05
          ,@c_Pdffolder
          ,@c_PdfFile       OUTPUT
          ,@c_Printer       OUTPUT
          ,@c_ArchiveFolder OUTPUT
          ,@c_ActionType    OUTPUT  --2 = Print and don't move 3 = Print and move (Default)
          ,@n_PrintAction   OUTPUT  --0 =Not print PDF  1=Print PDF   2=Print PDF and continue other printing
          ,@c_Dimension     OUTPUT  --Dimension in mm x mm, eg. 210x297
          ,@n_NoOfPDFSheet          --PDF Sheets number (For 1 ReportType print multiple layout)
          --,@c_PostPrinting  OUTPUT  --Y - PostPrinting, N - DirectPrint (Need to wait)
          ,@b_Success       OUTPUT  
          ,@n_Err           OUTPUT  
          ,@c_ErrMsg        OUTPUT           

      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
      END             
   END      
   ELSE
      SET @n_PrintAction = 1
                 
   QUIT_SP:  
   SET @dt_timeOut = GETDATE()

   EXEC isp_InsertTraceInfo
           @c_TraceCode = @c_TraceCode
         , @c_TraceName = @c_TraceName
         , @c_starttime = @dt_timeIn 
         , @c_endtime   = @dt_timeOut  
         , @c_step1     = 'Param01'    
         , @c_step2     = 'Param02'    
         , @c_step3     = 'Param03'    
         , @c_step4     = 'Param04'    
         , @c_step5     = 'Param05'    
         , @c_col1      = @c_Param01   
         , @c_col2      = @c_Param02   
         , @c_col3      = @c_Param03   
         , @c_col4      = @c_Param04   
         , @c_col5      = @c_Param05 
         , @b_Success   = @b_Success
         , @n_Err       = @n_Err    
         , @c_ErrMsg    = @c_ErrMsg 

   IF @n_continue = 3  -- Error Occured - Process And Return  
   BEGIN  
      SET @b_success = 0  
  
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCount  
      BEGIN  
         ROLLBACK TRAN  
      END  
      ELSE  
      BEGIN  
         WHILE @@TRANCOUNT > @n_StartTCount  
         BEGIN  
            COMMIT TRAN  
         END  
      END  
      Execute nsp_logerror @n_err, @c_errmsg, 'isp_GetPrint2PDFConfig'  
      --RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012  
      RETURN  
   END  
   ELSE  
   BEGIN  
      SET @b_success = 1  
      WHILE @@TRANCOUNT > @n_StartTCount  
      BEGIN  
         COMMIT TRAN  
      END   
  
      RETURN  
   END   
END 
GO

GRANT EXECUTE ON [dbo].[isp_GetPrint2PDFConfig] TO NSQL
GO

