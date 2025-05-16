
/************************************************************************/              
/* Store procedure: [API].[isp_ECOMP_API_UpdateTestData]                */              
/* Creation Date: 13-FEB-2023                                           */
/* Copyright: Maersk                                                    */
/* Written by: AlexKeoh                                                 */
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
/* 16-June-2023    Alex     Initial                                     */
/************************************************************************/    
CREATE OR ALTER PROC [API].[isp_ECOMP_API_UpdateTestData](
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
   
   DECLARE @n_Continue                    INT            = 1
         , @n_StartCnt                    INT            = @@TRANCOUNT

         , @c_ComputerName                NVARCHAR(30)   = ''
         , @n_RowRef                      BIGINT         = 0

   SET @b_Success                         = 0
   SET @n_ErrNo                           = 0
   SET @c_ErrMsg                          = ''
   SET @c_ResponseString                  = ''

   SELECT @n_RowRef  = ISNULL(RTRIM(RowRef), 0)
   FROM OPENJSON (@c_RequestString)
   WITH ( 
      RowRef BIGINT '$.RowRef'  
   )

   UPDATE [dbo].[EPACKPFTDATA]
   SET [Status] = '9'
   WHERE RowRef = @n_RowRef

   SET @c_ResponseString = '{"Success": true}'

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
