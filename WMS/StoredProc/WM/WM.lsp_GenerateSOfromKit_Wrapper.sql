SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/  
/* Stored Procedure: lsp_GenerateSOfromKit_Wrapper                       */  
/* Creation Date: 28-FEB-2018                                            */  
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
/* 2021-02-05   mingle01 1.1  Add Big Outer Begin try/Catch              */
/*                            Execute Login if @c_UserName<>SUSER_SNAME()*/
/* 2025-10-06   SSA01    1.2   UWP-42142 -Enhanced session management    */
/*                             and cleanup.                              */
/*************************************************************************/   
CREATE OR ALTER PROCEDURE [WM].[lsp_GenerateSOfromKit_Wrapper]  (
   @c_StorerKey  NVARCHAR(15), 
   @c_KitKey     NVARCHAR(10),
   @b_Success    int = 1 OUTPUT,
   @n_Err        int = 0 OUTPUT,
   @c_Errmsg     NVARCHAR(250) = '' OUTPUT,
   @c_UserName   NVARCHAR(128) = '' )
AS  
BEGIN  
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue     INT = '1'         
         , @n_Count        INT = 0
         , @b_ExecuteAs    BIT = 0     --(SSA01)

   SET @b_Success = 1
   SET @c_ErrMsg = ''

   SET @n_Err = 0 

   --(mingle01) - START
   --(SSA01) - START
   IF SUSER_SNAME() <> @c_UserName
   BEGIN
      EXEC [WM].[lsp_SetUser] @c_UserName = @c_UserName OUTPUT, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT,  @b_ExecuteAs = @b_ExecuteAs OUTPUT
   
      IF @n_Err <> 0 
      BEGIN
         GOTO EXIT_SP
      END

      IF @b_ExecuteAs = 1
         EXECUTE AS LOGIN = @c_UserName
   END
   --(SSA01) - END
   --(mingle01) - END

   --(mingle01) - START
   BEGIN TRY 
      BEGIN TRY
      EXEC ispGenerateSOfromKit_Wrapper 
           @c_StorerKey = @c_StorerKey 
          ,@c_KitKey    = @c_KitKey  
          ,@b_Success   = @b_Success OUTPUT
          ,@n_Err       = @n_Err     OUTPUT
          ,@c_ErrMsg    = @c_Errmsg  OUTPUT
                 
      END TRY
      BEGIN CATCH
         SET @n_err = 552501
         SET @c_ErrMsg = ERROR_MESSAGE()
         SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Error Executing ispGenerateSOfromKit_Wrapper. (lsp_GenerateSOfromKit_Wrapper)'
                        + '( ' + @c_errmsg + ' )'
      END CATCH      

   END TRY

   BEGIN CATCH
      SET @n_Continue = 3
      SET @c_ErrMsg = ERROR_MESSAGE()
      GOTO EXIT_SP
   END CATCH
   --(mingle01) - END
EXIT_SP: 
   
   IF @n_Continue = 3   
   BEGIN
      SET @b_Success = 0
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_GenerateSOfromKit_Wrapper'  
   END
   ELSE
   BEGIN
      SET @b_Success = 1
   END
  --(SSA01) - Start
   IF @b_ExecuteAs = 1
   BEGIN
      REVERT
   END

   EXEC [WM].[lsp_ResetUser]
   --(SSA01) - END
END  
GO
GRANT EXECUTE ON [WM].[lsp_GenerateSOfromKit_Wrapper] TO nSQL 
GO

