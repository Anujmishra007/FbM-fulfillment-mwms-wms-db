IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_KioskASRSGetNextPLTItem_Wrapper]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_KioskASRSGetNextPLTItem_Wrapper]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*************************************************************************/  
/* Stored Procedure: lsp_KioskASRSGetNextPLTItem_Wrapper                 */  
/* Creation Date: 28-FEB-2019                                            */  
/* Copyright: LFL                                                        */  
/* Written by:                                                           */  
/*                                                                       */  
/* Purpose:                                                              */  
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
CREATE PROCEDURE [WM].[lsp_KioskASRSGetNextPLTItem_Wrapper]  
   @c_JobKey               NVARCHAR(10)  
,  @b_Success              INT          = 1   OUTPUT   
,  @n_Err                  INT          = 0   OUTPUT
,  @c_Errmsg               NVARCHAR(255)= ''  OUTPUT
,  @c_UserName             NVARCHAR(128) = ''
AS  
BEGIN  
   SET ANSI_NULLS ON
   SET ANSI_PADDING ON
   SET ANSI_WARNINGS ON
   SET QUOTED_IDENTIFIER ON
   SET CONCAT_NULL_YIELDS_NULL ON
   SET ARITHABORT ON

   DECLARE @n_Continue     INT = 1
         , @n_StartTCnt    INT = @@TRANCOUNT 
                 
         , @n_Count        INT = 0 

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
      EXEC dbo.isp_KioskASRSGetNextPLTItem
         @c_JobKey = @c_JobKey   
      ,  @b_Success  = @b_Success   OUTPUT 
      ,  @n_Err      = @n_Err       OUTPUT
      ,  @c_Errmsg   = @c_Errmsg    OUTPUT

   END TRY
   BEGIN CATCH
      SET @n_err = 555351
      SET @c_ErrMsg = ERROR_MESSAGE()
      SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_err) 
                     + ': Error Executing isp_KioskASRSGetNextPLTItem. (lsp_KioskASRSGetNextPLTItem_Wrapper)'
                     + '( ' + @c_ErrMsg + ' )'
   END CATCH

   IF @b_Success = 0 OR @n_Err <> 0 
   BEGIN
      SET @n_continue = 3
      GOTO EXIT_SP 
   END
   
   EXIT_SP:
   
   IF @n_Continue = 3   
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_KioskASRSGetNextPLTItem_Wrapper'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
   REVERT
END  
GO
GRANT EXECUTE ON [WM].[lsp_KioskASRSGetNextPLTItem_Wrapper] TO nSQL 
GO


