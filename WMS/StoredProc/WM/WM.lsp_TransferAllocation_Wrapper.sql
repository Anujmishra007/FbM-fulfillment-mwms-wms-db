IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_TransferAllocation_Wrapper]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_TransferAllocation_Wrapper]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*************************************************************************/  
/* Stored Procedure: lsp_TransferAllocation_Wrapper                      */  
/* Creation Date: 29-OCT-2018                                            */  
/* Copyright: LFL                                                        */  
/* Written by: Wan                                                       */  
/*                                                                       */  
/* Purpose: LFWM-307 - Inventory - Transfer Ticket Clarifications        */
/*                                                                       */  
/* Called By:                                                            */  
/*                                                                       */  
/*                                                                       */  
/* Version: 1.0                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date         Author   Ver  Purposes                                   */ 
/*************************************************************************/   
CREATE PROCEDURE [WM].[lsp_TransferAllocation_Wrapper]  
   @c_FromStorerkey  NVARCHAR(15) = ''
,  @c_TransferKey    NVARCHAR(10) 
,  @b_Success        INT          = 1   OUTPUT   
,  @n_Err            INT          = 0   OUTPUT
,  @c_Errmsg         NVARCHAR(255)= ''  OUTPUT
,  @c_UserName       NVARCHAR(128)= ''
AS  
BEGIN  
   SET ANSI_NULLS ON
   SET ANSI_PADDING ON
   SET ANSI_WARNINGS ON
   SET QUOTED_IDENTIFIER ON
   SET CONCAT_NULL_YIELDS_NULL ON
   SET ARITHABORT ON

   DECLARE @n_Continue        INT = 1
         , @n_StartTCnt       INT = @@TRANCOUNT

         , @n_Count           INT = 0 

   SET @b_Success = 1
   SET @c_ErrMsg = ''

   SET @n_Err = 0 
   EXEC [WM].[lsp_SetUser] 
            @c_UserName = @c_UserName  OUTPUT
         ,  @n_Err      = @n_Err       OUTPUT
         ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
                
   EXECUTE AS LOGIN = @c_UserName
   
   IF @n_Err <> 0 
   BEGIN
      GOTO EXIT_SP
   END

   BEGIN TRY   

      WHILE  @@TRANCOUNT > 0
      BEGIN
         COMMIT TRAN
      END

      SET @b_Success = 1
       
      EXEC ispTransferAllocation
         @c_FromStorerkey  = @c_FromStorerkey
      ,  @c_TransferKey    = @c_TransferKey
      ,  @b_Success        = @b_Success   OUTPUT
      ,  @n_Err            = @n_Err       OUTPUT  
      ,  @c_ErrMsg         = @c_ErrMsg    OUTPUT   
      ,  @c_Code           = ''        

   END TRY

   BEGIN CATCH
      SET @n_err = 554301
      SET @c_ErrMsg = ERROR_MESSAGE()
      SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Executing ispTransferAllocation. (lsp_TransferAllocation_Wrapper)'
                     + '( ' + @c_errmsg + ' )'



      GOTO EXIT_SP
   END CATCH    
   
   IF @n_err <> 0 
   BEGIN
      SET @n_Continue = 3
      GOTO EXIT_SP
   END
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_TransferAllocation_Wrapper'
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

   REVERT      
END  
GO
GRANT EXECUTE ON [WM].[lsp_TransferAllocation_Wrapper] TO nSQL 
GO


