SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Stored Procedure: lsp_ASNReleasePATask_Wrapper                       */  
/* Creation Date: 18-Sep-2012                                           */  
/* Copyright: IDS                                                       */  
/* Written by: YTWan                                                    */  
/*                                                                      */  
/* Purpose:                                                             */  
/*                                                                      */
/*                                                                      */
/*                                                                      */  
/* Called By: ASN RCM Release Putaway Tasks                             */  
/*                                                                      */  
/* Version: 1.3                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author   Ver  Purposes                                  */  
/* 28-Dec-2020 SWT01    1.0   Adding Begin Try/Catch                    */
/* 15-JAN-2021 Wan01    1.1   Execute Login if @c_UserName<>SUSER_SNAME()*/
/* 03-JUN-2025 Wan02    1.3   UWP-32707 - FCR-3957 - JCB Putaway Using  */
/*                            TM SCE. Handle Sub SP Uncommit Transaction*/
/* 02-SEP-2025  SWT01    1.1   Setting Session Context for user name     */
/************************************************************************/ 
CREATE OR ALTER PROCEDURE [WM].[lsp_ASNReleasePATask_Wrapper]
   @c_ReceiptKey NVARCHAR(10),    
   @b_Success    INT   OUTPUT,
   @n_Err        INT   OUTPUT, 
   @c_ErrMsg     NVARCHAR(250) OUTPUT, 
   @n_WarningNo  INT = 0        OUTPUT,
   @c_ProceedWithWarning CHAR(1) = 'N',    
   @c_UserName   NVARCHAR(128)=''
AS  
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   SET @n_Err = 0 
   
   -- (SWT01) - START
   DECLARE @b_ExecuteAs BIT = 0
   IF SUSER_SNAME() <> @c_UserName
   BEGIN 

      EXEC [WM].[lsp_SetUser] 
            @c_UserName = @c_UserName  OUTPUT
         ,  @n_Err      = @n_Err       OUTPUT
         ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
         ,  @b_ExecuteAs = @b_ExecuteAs OUTPUT
         
      IF @n_Err <> 0 
      BEGIN
         GOTO EXIT_SP
      END

      IF @b_ExecuteAs = 1                    
         EXECUTE AS LOGIN = @c_UserName
   END
   -- (SWT01) - END                                --(Wan01) - END
   
   BEGIN TRY -- SWT01 - Begin Outer Begin Try                 
      EXEC isp_ASNReleasePATask_Wrapper 
         @c_ReceiptKey = @c_ReceiptKey,
         @b_Success = @b_Success OUTPUT, 
         @n_Err = @n_Err OUTPUT, 
         @c_ErrMsg = @c_ErrMsg OUTPUT
   END TRY  
  
   BEGIN CATCH  
      SET @b_Success= 0       --(Wan01)  
      SET @c_ErrMsg = 'ASN Release Putaway Task Failed. (lsp_ASNReleasePATask_Wrapper) ( SQLSvr MESSAGE=' + ERROR_MESSAGE() + ' ) '    --(Wan01)  
      GOTO EXIT_SP  
   END CATCH -- (SWT01) - End Big Outer Begin try.. end Try Begin Catch.. End Catch 
   EXIT_SP:

   IF (XACT_STATE()) = -1                                                           --(Wan02) - START  
   BEGIN
      ROLLBACK TRAN
   END                                                                              --(Wan02) - END  

   IF @b_ExecuteAs = 1              -- (SWT01)
      REVERT                        

   EXEC [WM].[lsp_ResetUser] -- (SWT01)  
END
GO
GRANT EXECUTE ON [WM].[lsp_ASNReleasePATask_Wrapper] TO nSQL 
GO
