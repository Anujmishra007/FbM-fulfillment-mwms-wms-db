SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/              
/* Store procedure: [dbo].[isp_ECOMP_GetUserProfile]                    */              
/* Creation Date: 13-FEB-2023                                           */
/* Copyright: LFL                                                       */
/* Written by: AlexKeoh                                                 */
/*                                                                      */
/* Purpose: Get New GEN ECOMPacking User Profile by region              */
/*                                                                      */
/* Called By: New GEN ECOMPacking                                       */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Purposes														*/
/************************************************************************/    
CREATE OR ALTER PROC [dbo].[isp_ECOMP_GetUserProfile](
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

         , @c_UserName                    NVARCHAR(125)      = ''
         , @c_Region                      NVARCHAR(100)      = ''
         , @c_Machine                     NVARCHAR(100)      = ''

         , @c_DEF_StorerKey               NVARCHAR(15)       = ''
         , @c_DEF_Facility                NVARCHAR(10)       = ''

         , @n_IsExists                    INT 
         
   SET @n_Continue                        = 1
   SET @n_StartCnt                        = @@TRANCOUNT

   SET @b_Success                         = 0
   SET @n_ErrNo                           = 0
   SET @c_ErrMsg                          = ''
   SET @c_ResponseString                  = ''

   SET @n_IsExists                        = 0

   SELECT * FROM [dbo].[ECOMP_UserProfile] WITH (NOLOCK) 

   SELECT @c_UserName      = ISNULL(RTRIM([UserName]), '')
         ,@c_Region        = ISNULL(RTRIM([Region]), '')
         ,@c_Machine       = ISNULL(RTRIM([Machine]), '')
   FROM OPENJSON (@c_RequestString)
   WITH ( 
      [UserName]        NVARCHAR(125)        '$.UserName',
      [Region]          NVARCHAR(100)        '$.Region',
      [Machine]         NVARCHAR(100)        '$.Machine'
   )

   SELECT @c_DEF_StorerKey = ISNULL(RTRIM(DEF_StorerKey), '') 
         ,@c_DEF_Facility  = ISNULL(RTRIM(DEF_Facility), '')
   FROM [dbo].[ECOMP_UserProfile] WITH (NOLOCK) 
   WHERE UserName = @c_UserName
   AND Region = @c_Region

   SET @c_ResponseString = ISNULL(( 
      SELECT @c_DEF_StorerKey As 'DefaultStorerKey'
            ,@c_DEF_Facility As 'DefaultFacility'
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
