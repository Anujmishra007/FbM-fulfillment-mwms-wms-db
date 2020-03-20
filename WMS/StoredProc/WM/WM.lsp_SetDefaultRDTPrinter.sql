IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_SetDefaultRDTPrinter]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_SetDefaultRDTPrinter]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store procedure: lsp_SetDefaultRDTPrinter                            */
/* Copyright      : LFLogistics                                         */
/*                                                                      */
/* Purpose: Dynamic lottable                                            */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/*22-Feb-2018  1.0  Shong       Created                                 */
/*02-Mar-2018  1.1  NJOW        Support domain checking                 */
/************************************************************************/

CREATE PROCEDURE [WM].[lsp_SetDefaultRDTPrinter]
   @c_UserName        NVARCHAR(128), 
   @c_LabelPrinter    NVARCHAR(10),
   @c_PaperPrinter    NVARCHAR(10),
   @n_Err             INT ='' OUTPUT,  
   @c_ErrMsg          NVARCHAR(125) = '' OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @n_Pos INT,
           @c_Domain NVARCHAR(30),
           @c_NoDomainUserName NVARCHAR(128)

   SELECT @n_Pos = CHARINDEX('\',@c_UserName)
   
   IF @n_Pos > 0 AND @c_UserName NOT LIKE '%_@_%_.__%' 
   BEGIN
        SELECT @c_Domain = LEFT(@c_UserName, @n_Pos - 1)
      SELECT @c_NoDomainUserName = SUBSTRING(@c_UserName, @n_Pos + 1, LEN(@c_Username))
   END
   ELSE 
        SET @c_NoDomainUserName = @c_UserName
      
   IF NOT EXISTS(SELECT 1
                 FROM WM.WMS_USER_CREATION_STATUS WITH (NOLOCK)
                 WHERE USER_NAME = @c_NoDomainUserName
                 AND LDAP_Domain = CASE WHEN ISNULL(@c_domain,'') <> '' THEN @c_Domain ELSE LDAP_Domain END) 
   BEGIN
        SET @n_Err = 553101
        SET @c_ErrMsg = 'Invalid User ID'
        GOTO EXIT_SP
   END   

   --EXECUTE AS LOGIN = @c_UserName
   SET @n_Err = 0 
   EXEC [WM].[lsp_SetUser] @c_UserName = @c_UserName OUTPUT, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT
   
   IF @n_Err <> 0 
   BEGIN
      GOTO EXIT_SP
   END
   
   EXECUTE AS LOGIN = @c_UserName
      
   IF NOT EXISTS(SELECT 1 FROM RDT.RDTUser AS r WITH(NOLOCK)
                 WHERE r.UserName = @c_UserName)
   BEGIN
      INSERT INTO RDT.RdtUser (UserName, [Password], FullName, DefaultStorer,
                  DefaultFacility, DefaultLangCode, DefaultMenu, DefaultUOM,
                  LastLogin, DefaultPrinter, DefaultPrinter_Paper, [Active])
      VALUES (@c_UserName, '', @c_UserName, '', '', 'ENG', 0, '', 
              GETDATE(), @c_LabelPrinter, @c_PaperPrinter, '1')
   END 
   ELSE
   BEGIN
        UPDATE RDT.RdtUser 
           SET DefaultPrinter = CASE WHEN ISNULL(@c_LabelPrinter,'') <> '' THEN @c_LabelPrinter ELSE DefaultPrinter END       
             , DefaultPrinter_Paper = CASE WHEN ISNULL(@c_PaperPrinter,'') <> '' THEN @c_PaperPrinter ELSE DefaultPrinter_Paper END
        WHERE UserName = @c_UserName                   
   END
      
   EXIT_SP:
   REVERT    
END -- End Procedure
GO
GRANT EXECUTE ON [WM].[lsp_SetDefaultRDTPrinter] TO nSQL 
GO
