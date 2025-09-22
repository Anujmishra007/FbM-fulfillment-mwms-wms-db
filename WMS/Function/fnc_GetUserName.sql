SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: fnc_GetUserName                                    */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 23-May-2025  Shong         Replacing sUser_sName()                   */
/************************************************************************/
CREATE OR ALTER FUNCTION dbo.fnc_GetUserName ()
RETURNS NVARCHAR(128) AS
BEGIN
   DECLARE @c_UserName NVARCHAR(128) = N''

   SELECT @c_UserName = CONVERT(NVARCHAR(128), SESSION_CONTEXT(N'mwms_user_name'))   

   -- When this session context not set for other appliaction, it will default to SUSER_SNAME()
   -- For example, IML user, other other application not calling lsp_SetUser, this function is still working
   IF ISNULL(@c_UserName, '') = ''
      SET  @c_UserName = SUSER_SNAME()
   
   RETURN @c_UserName  
END 
GO
GRANT EXECUTE ON  [dbo].[fnc_GetUserName] TO [NSQL]
GO



