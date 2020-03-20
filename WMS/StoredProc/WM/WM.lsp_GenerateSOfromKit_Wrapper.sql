IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_GenerateSOfromKit_Wrapper]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_GenerateSOfromKit_Wrapper]
GO

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
/*************************************************************************/   
CREATE PROCEDURE [WM].[lsp_GenerateSOfromKit_Wrapper]  (
   @c_StorerKey  NVARCHAR(15), 
   @c_KitKey     NVARCHAR(10),
   @b_Success    int = 1 OUTPUT,
   @n_Err        int = 0 OUTPUT,
   @c_Errmsg     NVARCHAR(250) = '' OUTPUT,
   @c_UserName   NVARCHAR(128) = '' )
AS  
BEGIN  
   SET ANSI_NULLS ON
   SET ANSI_PADDING ON
   SET ANSI_WARNINGS ON
   SET QUOTED_IDENTIFIER ON
   SET CONCAT_NULL_YIELDS_NULL ON
   SET ARITHABORT ON

   DECLARE @n_Continue     INT = '1'         
         , @n_Count        INT = 0 

   SET @b_Success = 1
   SET @c_ErrMsg = ''

   SET @n_Err = 0 
   EXEC [WM].[lsp_SetUser] @c_UserName = @c_UserName OUTPUT, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT
   
   EXECUTE AS LOGIN = @c_UserName
      
   IF @n_Err <> 0 
   BEGIN
      GOTO EXIT_SP
   END

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

   EXIT_SP:
   
   IF @n_Continue = 3   
   BEGIN
      SET @b_Success = 0
   END
   ELSE
   BEGIN
      SET @b_Success = 1
   END
   REVERT      
END  
GO
GRANT EXECUTE ON [WM].[lsp_GenerateSOfromKit_Wrapper] TO nSQL 
GO

