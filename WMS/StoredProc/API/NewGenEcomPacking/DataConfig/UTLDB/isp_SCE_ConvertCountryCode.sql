
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/              
/* Store procedure: isp_SCE_ConvertCountryCode                          */              
/* Creation Date: 13-FEB-2023                                           */
/* Copyright: LFL                                                       */
/* Written by: AlexKeoh                                                 */
/*                                                                      */
/* Purpose: Convert SCE 3 char country code to 2 char                   */
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
/* Date        Author   Purposes														*/
/************************************************************************/    
CREATE OR ALTER PROC [dbo].[isp_SCE_ConvertCountryCode](
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
   
   DECLARE @n_Continue                    INT
         , @n_StartCnt                    INT

         , @c_Request_XMLNodes            NVARCHAR(60)
         , @c_OrderKey                    NVARCHAR(30)
         , @c_2CharCountryCode            NVARCHAR(15)
         , @c_3CharCountryCode            NVARCHAR(15)

         , @n_IsExists                    INT 
         
   SET @n_Continue                        = 1
   SET @n_StartCnt                        = @@TRANCOUNT
   SET @b_Success                         = 0
   SET @n_ErrNo                           = 0
   SET @c_ErrMsg                          = ''
   SET @c_ResponseString                  = ''

   SET @n_IsExists                        = 0
   SELECT @c_3CharCountryCode = ISNULL(RTRIM([CountryCode]), '')
   FROM OPENJSON (@c_RequestString)
   WITH ( [CountryCode]  NVARCHAR(15)   '$.CountryCode' )

   SELECT @n_IsExists = (1)
         ,@c_2CharCountryCode = ISNULL(RTRIM([Short]), '')
   FROM dbo.CODELKUP WITH (NOLOCK) 
   WHERE LISTNAME = 'CTRY_CODE' AND Code = @c_3CharCountryCode

   IF @n_IsExists = 0
   BEGIN
      SET @n_Continue = 3 
      SET @n_ErrNo = 98101
      SET @c_ErrMsg = 'Fail to lookup SCE country code: ' + @c_3CharCountryCode
      GOTO QUIT
   END

   SET @c_ResponseString = ISNULL(( 
      SELECT @c_2CharCountryCode As 'CountryCode'
      FOR JSON PATH, WITHOUT_ARRAY_WRAPPER 
   ), '')


   QUIT:
   IF @n_Continue= 3  -- Error Occured - Process And Return      
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
END -- Procedure  
