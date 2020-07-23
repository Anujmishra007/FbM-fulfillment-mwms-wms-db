IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_RCMConfigSP_LOAD_Wrapper]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_RCMConfigSP_LOAD_Wrapper]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*************************************************************************/  
/* Stored Procedure: lsp_RCMConfigSP_LOAD_Wrapper                        */  
/* Creation Date: 2020-06-11                                             */  
/* Copyright: LFL                                                        */  
/* Written by: Wan                                                       */  
/*                                                                       */  
/* Purpose: LFWM-2159 - Dyanamic Menu RCMConfig PO                       */
/*          ReceiptTransferSOAdjustmentWaveLoadPlanMbol                  */
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
CREATE PROCEDURE [WM].[lsp_RCMConfigSP_LOAD_Wrapper]  
   @c_Storerkey   NVARCHAR(15)
,  @c_LoadKey     NVARCHAR(10) 
,  @b_Success     INT          = 1   OUTPUT   
,  @n_Err         INT          = 0   OUTPUT
,  @c_Errmsg      NVARCHAR(255)= ''  OUTPUT
,  @c_UserName    NVARCHAR(128)= ''
,  @c_Code        NVARCHAR(10) = ''
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
         , @c_RCMConfigSP     NVARCHAR(60) = ''

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

   WHILE  @@TRANCOUNT > 0
   BEGIN
      COMMIT TRAN
   END

   BEGIN TRAN

   SELECT @c_RCMConfigSP = RTRIM(CL.Long)
   FROM CODELKUP CL (NOLOCK)
   WHERE CL.ListName = 'RCMConfig'
   AND   CL.Code = @c_Code
   AND   CL.UDF01= 'loadplan'
   AND   CL.Short= 'storedproc'
   AND   CL.Storerkey = @c_Storerkey

   IF @c_RCMConfigSP <> ''
   BEGIN
      IF NOT EXISTS (SELECT 1 FROM sys.objects (NOLOCK) WHERE Object_ID(@c_RCMConfigSP) = object_id AND [Type] = 'P')
      BEGIN
         GOTO EXIT_SP
      END
   END

   BEGIN TRY   
      SET @b_Success = 1
       
      EXEC @c_RCMConfigSP 
         @c_Loadkey        = @c_Loadkey
      ,  @b_Success        = @b_Success   OUTPUT
      ,  @n_Err            = @n_Err       OUTPUT  
      ,  @c_ErrMsg         = @c_ErrMsg    OUTPUT   
      ,  @c_Code           = @c_Code        

   END TRY

   BEGIN CATCH
      SET @n_Continue = 3
      SET @n_err = 558101
      SET @c_ErrMsg = ERROR_MESSAGE()
      SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Error Executing Loadplan''s RCMConfig Custom SP' + @c_RCMConfigSP + '. (lsp_RCMConfigSP_LOAD_Wrapper)'
                     + '( ' + @c_errmsg + ' ) |' + @c_RCMConfigSP
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_RCMConfigSP_LOAD_Wrapper'
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
GRANT EXECUTE ON [WM].[lsp_RCMConfigSP_LOAD_Wrapper] TO nSQL 
GO


