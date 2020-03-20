IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_SetUser]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_SetUser]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store procedure: lsp_SetUser                                         */
/* Copyright      : LFLogistics                                         */
/*                                                                      */
/* Purpose: Dynamic lottable                                            */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 12-11-2014  1.0  Shong       Created                                 */
/* 05-12-2017  1.1  KHLim       Extend length same as SUSER_SNAME (KH01)*/
/* 04-04-2018  1.2  Shong       Fixing Bugs                             */ 
/************************************************************************/

CREATE PROCEDURE [WM].[lsp_SetUser]
   @c_UserName     NVARCHAR(128) OUTPUT,  
   @n_Err          INT ='' OUTPUT,  
   @c_ErrMsg       NVARCHAR(125) = '' OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cExternalUserID  NVARCHAR(100) = '',
           @c_LDAP_DOMAIN    NVARCHAR(50) = '',
           @c_UserType       INT = 0 
   
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
   
   IF NOT EXISTS(
      SELECT 1
      FROM sys.database_principals DBUser
      INNER JOIN sys.database_role_members DBM ON DBM.member_principal_id = DBUser.principal_id
      INNER JOIN sys.database_principals DBRole ON DBRole.principal_id = DBM.role_principal_id
      WHERE DBRole.name = 'NSQL' AND DBUser.name = @c_UserName)
   BEGIN
      SET @c_UserName = SUSER_SNAME()
      GOTO EXIT_SP
   END 
   
   --EXECUTE AS LOGIN = @c_UserName 
   
   EXIT_SP:
   
END -- End Procedure
GO
GRANT EXECUTE ON [WM].[lsp_SetUser] TO nSQL 
GO
