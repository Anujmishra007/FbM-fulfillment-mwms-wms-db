SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: lsp_SetUser                                         */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Dynamic lottable                                            */
/*                                                                      */
/* Date        Author   Rev   Purposes                                  */
/* 12-11-2014  Shong    1.0   Created                                   */
/* 05-12-2017  KHLim    1.1   Extend length same as SUSER_SNAME (KH01)  */
/* 04-04-2018  Shong    1.2   Fixing Bugs                               */
/* 2021-02-25  Wan01    1.1   Add Big Outer Try/Catch                   */
/* 2025-05-23  SWT01    1.3   Setting Session Context for user name     */
/* 2025-09-04  SWT02    1.4   Set user name to suser_sname if not exists*/
/************************************************************************/
CREATE OR ALTER   PROCEDURE [WM].[lsp_SetUser]
   @c_UserName     NVARCHAR(128) OUTPUT,
   @n_Err          INT ='' OUTPUT,
   @c_ErrMsg       NVARCHAR(125) = '' OUTPUT, 
   @b_ExecuteAs    BIT = 0 OUTPUT 
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cExternalUserID  NVARCHAR(100) = '',
           @c_LDAP_DOMAIN    NVARCHAR(50) = '',
           @c_UserType       INT = 0

   -- Doesn't matter whether this user id exists in security login, we still set the session context to user name.
   EXEC sp_set_session_context @key = 'mwms_user_name', @value = @c_UserName;
   
   --(Wan01) - START
   BEGIN TRY
      SELECT @c_UserType = USER_TYPE
      FROM WM.WMS_USER_CREATION_STATUS WITH (NOLOCK)
      WHERE USER_NAME = @c_UserName

      -- External User
      IF @c_UserName LIKE '%_@_%_.__%' OR @c_UserType = 1
      BEGIN
         SET @cExternalUserID = ''

         SELECT @cExternalUserID  = WMS_USER_NAME
         FROM WM.WMS_USER_CREATION_STATUS WITH (NOLOCK)
         WHERE USER_NAME = @c_UserName
         AND   WMS_LOGIN_SYNC = 1

         IF @cExternalUserID <> ''
            SET @c_UserName = @cExternalUserID
      END
      ELSE
      BEGIN
         SET @c_LDAP_DOMAIN = ''
         SELECT @c_LDAP_DOMAIN = LDAP_DOMAIN
         FROM WM.WMS_USER_CREATION_STATUS WITH (NOLOCK)
         WHERE USER_NAME = @c_UserName
         IF @c_LDAP_DOMAIN <> ''
         BEGIN
            SET @c_UserName = @c_LDAP_DOMAIN + '\' + @c_UserName
         END
      END

      -- If this user id NOT FOUND in Security Login, then do not run "Execute As"
      -- This will make the RDT and other application still working if they not ready to change.
      IF NOT EXISTS(
         SELECT 1
         FROM sys.database_principals DBUser
         INNER JOIN sys.database_role_members DBM ON DBM.member_principal_id = DBUser.principal_id
         INNER JOIN sys.database_principals DBRole ON DBRole.principal_id = DBM.role_principal_id
         WHERE DBRole.name = 'NSQL' AND DBUser.name = @c_UserName)
      BEGIN
         SET @b_ExecuteAs = 0 
         SET @c_UserName = SUSER_SNAME() -- (SWT02)
         GOTO EXIT_SP
      END
      ELSE
      BEGIN
         SET @b_ExecuteAs = 1
      END 
   END TRY
   BEGIN CATCH
      SET @n_Err    = @@ERROR
      SET @c_ErrMsg = ERROR_MESSAGE()
      GOTO EXIT_SP
   END CATCH
   --(Wan01) - END

   EXIT_SP:


   --(Wan01) - START
   IF @n_Err <> 0 AND @c_ErrMsg <> ''
   BEGIN
      Execute nsp_logerror @n_err, @c_errmsg, 'lsp_SetUser'
   END
   --(Wan01) - END

END -- End Procedure
GO
GRANT EXECUTE ON [WM].[lsp_SetUser] TO nSQL 
GO

