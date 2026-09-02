SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_API_ValidateAction                                 */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Validate Action                                              */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-07-31   1.0  JWF011     FCR-13553: Created                               */
/* 2026-08-13   2.0  GCH225     UWP-27783: Restructure to let dynamic json to    */
/*                                         be passed to custom SP                */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_API_ValidateAction] (
     @b_Debug           INT            = 0  
   , @c_Format          VARCHAR(10)    = ''  
   , @c_UserID          NVARCHAR(256)  = ''  
   , @c_OperationType   NVARCHAR(60)   = ''  
   , @c_RequestString   NVARCHAR(MAX)  = ''  
   , @b_Success         INT            = 0   OUTPUT  
   , @n_ErrNo           INT            = 0   OUTPUT  
   , @c_ErrMsg          NVARCHAR(250)  = ''  OUTPUT  
   , @c_ResponseString  NVARCHAR(MAX)  = ''  OUTPUT  
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF 

   DECLARE @n_Continue     INT            = 1  
         , @n_StartCnt     INT            = @@TRANCOUNT  
         , @b_sp_Success   INT  
         , @n_sp_err       INT  
         , @c_sp_errmsg    NVARCHAR(250)  = ''
         , @DBUserName     NVARCHAR(100)
         , @b_sp_ExecuteAs BIT
   
   DECLARE @cAction        NVARCHAR(200)
         , @objData        NVARCHAR(MAX)
         , @cCustomSP      NVARCHAR(256)
         , @cSQL           NVARCHAR(MAX)
         , @cSQLParam      NVARCHAR(3000)
         , @cStorerKey     NVARCHAR( 15)
         , @cFacility      NVARCHAR( 5)
   SET @b_Success = 0  
   SET @n_ErrNo   = 0  
   SET @c_ErrMsg  = '' 

   SET @cAction   = ''
   SET @objData   = ''

   EXEC [API].[isp_ECOMP_ValidateAndSetUser]
        @c_UserID      = @c_UserID
      , @c_DBUserName  = @DBUserName      OUTPUT
      , @b_ExecuteAs   = @b_sp_ExecuteAs  OUTPUT
      , @b_Success     = @b_sp_Success    OUTPUT
      , @n_ErrNo       = @n_sp_err        OUTPUT
      , @c_ErrMsg      = @c_sp_errmsg     OUTPUT

   IF @b_sp_Success = 0
   BEGIN    
      SET @n_Continue = 3
      SET @n_ErrNo = @n_sp_err      
      SET @c_ErrMsg = @c_sp_errmsg     
      GOTO EXIT_SP
   END

   IF @b_sp_ExecuteAs = 1
   BEGIN
      EXECUTE AS LOGIN = @DBUserName
      SET @c_UserID = @DBUserName
   END

   SELECT  @cAction                = cAction
         , @objData                = objData
   FROM OPENJSON(@c_RequestString)
   WITH (
         cAction                NVARCHAR(200)
      ,  objData                NVARCHAR(MAX) AS JSON
   )

   SELECT  @cStorerKey = cStorerKey
         , @cFacility  = cFacility
   FROM OPENJSON(@objData)
   WITH (
         cStorerKey  NVARCHAR(15)
      ,  cFacility   NVARCHAR(5)
   )
   EXEC nspGetRight    
         @c_Facility  = @cFacility    
      ,  @c_StorerKey = @cStorerKey   
      ,  @c_sku       = ''    
      ,  @c_ConfigKey = 'TPS-ValidateAction'
      ,  @c_authority = @cCustomSP OUTPUT    
      ,  @b_Success   = @b_Success OUTPUT
      ,  @n_err       = @n_ErrNo   OUTPUT
      ,  @c_errmsg    = @c_ErrMsg  OUTPUT

   IF @b_Success = 0
   BEGIN
      SET @n_Continue  = 3    
      GOTO EXIT_SP
   END

   IF EXISTS(  SELECT 1 
               FROM sys.objects 
               WHERE [name] = @cCustomSP 
               AND [type] = 'P'
   )
   BEGIN
      SET @cSQL   = 'EXEC [API].[' + RTRIM(@cCustomSP) + ']' + CHAR(13)
                  + '  @cAction                 ' + CHAR(13)
                  + ', @objData                 ' + CHAR(13)
                  + ', @c_UserID                ' + CHAR(13)
                  + ', @b_Success        OUTPUT ' + CHAR(13)
                  + ', @n_ErrNo          OUTPUT ' + CHAR(13)
                  + ', @c_ErrMsg         OUTPUT ' + CHAR(13)
                  + ', @c_ResponseString OUTPUT ' + CHAR(13)

      SET @cSQLParam = '  @cAction           NVARCHAR(200)        ' + CHAR(13)
                     + ', @objData           NVARCHAR(MAX)        ' + CHAR(13)
                     + ', @c_UserID          NVARCHAR(256)        ' + CHAR(13)
                     + ', @b_Success         INT           OUTPUT ' + CHAR(13)
                     + ', @n_ErrNo           INT           OUTPUT ' + CHAR(13)
                     + ', @c_ErrMsg          NVARCHAR(250) OUTPUT ' + CHAR(13)
                     + ', @c_ResponseString  NVARCHAR(MAX) OUTPUT ' + CHAR(13)

      EXEC sp_ExecuteSQL  @cSQL
                        , @cSQLParam
                        , @cAction
                        , @objData
                        , @c_UserID
                        , @b_Success         OUTPUT
                        , @n_ErrNo           OUTPUT
                        , @c_ErrMsg          OUTPUT
                        , @c_ResponseString  OUTPUT

      IF @b_Success = 0
      BEGIN
         SET @n_Continue = 3
         GOTO EXIT_SP
      END
   END

EXIT_SP:
   IF @b_sp_ExecuteAs = 1 REVERT
   EXEC [WM].[lsp_ResetUser]

   IF @n_Continue = 3  -- Error Occurred - Process And Return      
   BEGIN      
      SET @b_Success = 0      
      IF @@TRANCOUNT > @n_StartCnt AND @@TRANCOUNT = 1 
      BEGIN               
         ROLLBACK TRAN      
      END      
      ELSE      
      BEGIN      
         WHILE @@TRANCOUNT > @n_StartCnt      
         BEGIN      
         COMMIT TRAN      
         END      
      END   
      RETURN      
   END      
   ELSE      
   BEGIN      
      SELECT @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [API].[isp_TPACK_API_ValidateAction] TO NSQL
GO