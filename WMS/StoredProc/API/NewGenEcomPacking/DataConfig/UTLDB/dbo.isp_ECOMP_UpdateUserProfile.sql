SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/              
/* Store procedure: [dbo].[isp_ECOMP_UpdateUserProfile]                 */              
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
/* 30-Apr-2025 Alex01   Deadlock fixes                                  */
/************************************************************************/    
CREATE OR ALTER PROC [dbo].[isp_ECOMP_UpdateUserProfile](
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

         , @c_StorerKey                   NVARCHAR(15)       = ''
         , @c_Facility                    NVARCHAR(15)       = ''
         , @c_Version                     NVARCHAR(10)       = ''

         , @n_IsExists                    INT 
         , @b_RespSuccess                 BIT                = 0
         
         , @n_RowRefNo                    INT                = 0

   SET @n_Continue                        = 1
   SET @n_StartCnt                        = @@TRANCOUNT

   SET @b_Success                         = 0
   SET @n_ErrNo                           = 0
   SET @c_ErrMsg                          = ''
   SET @c_ResponseString                  = ''

   SET @n_IsExists                        = 0
   SET @b_RespSuccess                     = 0

   SELECT @c_UserName      = ISNULL(RTRIM([UserName]), '')
         ,@c_Region        = ISNULL(RTRIM([Region]), '')
         ,@c_Machine       = ISNULL(RTRIM([Machine]), '')
         ,@c_StorerKey     = ISNULL(RTRIM([DEF_StorerKey]), '')
         ,@c_Facility      = ISNULL(RTRIM([DEF_Facility]), '')
         ,@c_Version       = ISNULL(RTRIM([Version]), '')
   FROM OPENJSON (@c_RequestString)
   WITH ( 
      [UserName]        NVARCHAR(125)        '$.UserName',
      [Region]          NVARCHAR(100)        '$.Region',
      [Machine]         NVARCHAR(100)        '$.Machine',
      [DEF_StorerKey]   NVARCHAR(15)         '$.StorerKey',
      [DEF_Facility]    NVARCHAR(15)         '$.Facility',
      [Version]         NVARCHAR(10)         '$.Version'
   )

   IF @c_UserName <> '' AND @c_Region <> ''
   BEGIN
      --Alex01 S
      SELECT TOP 1
         @n_RowRefNo = RowRefNo
      FROM [dbo].[ECOMP_UserProfile] WITH (NOLOCK) 
      WHERE UserName = @c_UserName 
      AND Region = @c_Region
      --Alex01 E

      IF @@ROWCOUNT = 0
      BEGIN
         INSERT INTO [dbo].[ECOMP_UserProfile] ( UserName, Region, DEF_StorerKey, DEF_Facility, Machine, [Version], [LastLoginDate] )
         VALUES (@c_UserName, @c_Region, @c_StorerKey, @c_Facility, @c_Machine, @c_Version, GETDATE())
      END
      ELSE
      BEGIN
         UPDATE [dbo].[ECOMP_UserProfile] WITH (ROWLOCK)
         SET [DEF_StorerKey]  = @c_StorerKey
            ,[DEF_Facility]   = @c_Facility
            ,[Machine]        = @c_Machine
            ,[Version]        = @c_Version
            ,[LastLoginDate]  = GETDATE()
         WHERE RowRefNo = @n_RowRefNo  --Alex01
      END

      SET @b_RespSuccess = 1
   END
   
   SET @c_ResponseString = ISNULL(( 
      SELECT @b_RespSuccess As 'success'
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
