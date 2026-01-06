SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*************************************************************************/  
/* Stored Procedure: lsp_FinalizeChannelTRF_Wrapper                      */  
/* Creation Date: 2021-09-06                                             */  
/* Copyright: LFL                                                        */  
/* Written by: Wan                                                       */  
/*                                                                       */  
/* Purpose: LFWM-3021 - SCE Channel Management modules  Channel          */
/*        : TransferFinalize                                             */  
/*                                                                       */  
/* Called By:                                                            */  
/*                                                                       */  
/*                                                                       */  
/* Version: 1.0                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date        Author   Ver   Purposes                                   */ 
/* 2021-09-06  Wan      1.0   Created.                                   */
/* 2021-09-22  Wan      1.0   DevOps Script Combine                      */
/* 2025-10-06  SSA01    1.1   UWP-42142 -Enhanced session management     */
/*                             and cleanup.                              */
/*************************************************************************/   
CREATE OR ALTER PROCEDURE [WM].[lsp_FinalizeChannelTRF_Wrapper]  
      @c_ChannelTransferKey         NVARCHAR(10)  
   ,  @c_ChannelTransferLineNumber  NVARCHAR(5)  = ''  
   ,  @b_Success                    INT          = 1   OUTPUT   
   ,  @n_Err                        INT          = 0   OUTPUT
   ,  @c_Errmsg                     NVARCHAR(255)= ''  OUTPUT
   ,  @c_UserName                   NVARCHAR(128)= ''
AS  
BEGIN  
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue     INT = 1
         , @n_StartTCnt    INT = @@TRANCOUNT
         , @b_ExecuteAs    BIT = 0    --(SSA01)
                 
         , @n_Count        INT = 0 

   SET @b_Success = 1
   SET @c_ErrMsg = ''

   SET @n_Err = 0 
   -- (SSA01) - START
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
   -- (SSA01) - END
   
   BEGIN TRAN

   BEGIN TRY
      EXEC dbo.isp_FinalizeChannelTransfer
         @c_ChannelTransferKey         = @c_ChannelTransferKey 
      ,  @c_ChannelTransferLineNumber  = @c_ChannelTransferLineNumber
      ,  @b_Success                    = @b_Success   OUTPUT 
      ,  @n_Err                        = @n_Err       OUTPUT
      ,  @c_Errmsg                     = @c_Errmsg    OUTPUT

      IF @b_Success = 0
      BEGIN
      	SET @n_Continue = 3
         SET @n_err = 559701
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_err) 
                        + ': Error Executing isp_FinalizeChannelTransfer. (lsp_FinalizeChannelTRF_Wrapper)'
                        + '( ' + @c_ErrMsg + ' )'
         GOTO EXIT_SP
      END
   END TRY
   
   BEGIN CATCH
      SET @n_Continue = 3
      SET @c_ErrMsg = ERROR_MESSAGE() + '. (lsp_FinalizeChannelTRF_Wrapper)'
      GOTO EXIT_SP
   END CATCH

   EXIT_SP:
   
   IF (XACT_STATE()) = -1  
   BEGIN
   	SET @n_Continue = 3
      ROLLBACK TRAN
   END 
       
   IF @n_Continue = 3   
   BEGIN
      SET @b_Success = 0
      IF @n_StartTCnt = 0 AND @@TRANCOUNT > @n_StartTCnt
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_FinalizeChannelTRF_Wrapper'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
   IF @b_ExecuteAs = 1
   BEGIN
      REVERT
   END

   EXEC [WM].[lsp_ResetUser]
END  
GO
GRANT EXECUTE ON [WM].[lsp_FinalizeChannelTRF_Wrapper] TO nSQL 
GO


