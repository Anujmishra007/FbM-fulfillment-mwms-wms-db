/************************************************************************/              
/* Store procedure: [API].[isp_ECOMP_ValidateAndSetUser]                */              
/* Creation Date: 24-Jul-2025                                           */
/* Copyright: Maersk                                                    */
/* Written by: SeanDeng                                                 */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By: SCEAPI                                                    */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date           Author   Purposes                                     */
/* 24-Jul-2025    Sean     #UWP-38247 - Compatible with User Session    */
/************************************************************************/ 
CREATE OR ALTER PROCEDURE [API].[isp_ECOMP_ValidateAndSetUser]
   @c_UserID        NVARCHAR(256),
   @c_DBUserName    NVARCHAR(100) OUTPUT,
   @b_ExecuteAs     BIT OUTPUT,
   @b_Success       INT OUTPUT,
   @n_ErrNo         INT OUTPUT,
   @c_ErrMsg        NVARCHAR(250) OUTPUT
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE @n_OutputCount INT,
           @n_sp_err INT = 0,
           @c_sp_errmsg NVARCHAR(250) = '';

   SET @c_DBUserName = @c_UserID
   SET @b_ExecuteAs = 0
   SET @b_Success = 0
   SET @n_ErrNo = 0
   SET @c_ErrMsg = ''

   SELECT @n_OutputCount = COUNT(1)
   FROM sys.parameters p WITH (NOLOCK)
   JOIN sys.objects o WITH (NOLOCK) ON p.object_id = o.object_id
   WHERE o.name = 'lsp_SetUser' AND p.is_output = 1;

   IF @n_OutputCount = 4
   BEGIN
      EXEC [WM].[lsp_SetUser] @c_UserName = @c_DBUserName OUTPUT,
                              @n_Err = @n_sp_err OUTPUT,
                              @c_ErrMsg = @c_sp_errmsg OUTPUT,
                              @b_ExecuteAs = @b_ExecuteAs OUTPUT;
   END
   ELSE
   BEGIN
      EXEC [WM].[lsp_SetUser] @c_UserName = @c_DBUserName OUTPUT,
                              @n_Err = @n_sp_err OUTPUT,
                              @c_ErrMsg = @c_sp_errmsg OUTPUT;
   END

   IF @n_sp_err <> 0
   BEGIN
      SET @b_Success = 0
      SET @n_ErrNo = @n_sp_err
      SET @c_ErrMsg = @c_sp_errmsg
      RETURN
   END

   IF @n_OutputCount = 4 AND @b_ExecuteAs = 0
   BEGIN
      IF SESSION_CONTEXT(N'mwms_user_name') IS NULL
      BEGIN
         SET @b_Success = 0
         SET @n_ErrNo = 100807
         SET @c_ErrMsg = 'NSQL100807: No Session context found. (lsp_ValidateAndSetUser)'
         RETURN
      END
   END

   SET @b_Success = 1
END
GO
GRANT EXECUTE ON [API].[isp_ECOMP_ValidateAndSetUser] TO NSQL
GO
