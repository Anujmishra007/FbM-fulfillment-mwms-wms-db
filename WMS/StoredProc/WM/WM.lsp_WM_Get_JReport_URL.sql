IF OBJECT_ID('WM.lsp_WM_Get_JReport_URL','P') IS NOT NULL
   DROP PROC  WM.lsp_WM_Get_JReport_URL;
GO
SET QUOTED_IDENTIFIER OFF;  -- to avoid re-compile on runtime
GO
SET ANSI_NULLS OFF;
GO
/************************************************************************/
/* Stored Proc: lsp_WM_Get_JReport_URL                                  */
/* Creation Date: 2020-05-08                                            */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose: Return URL Link for JReport                                 */
/*                                                                      */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 8.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
-- 2020-05-08  KHLim    1.1  Include get session & view report URL
-- 2020-06-05  KHLim    1.2  ReturnURLStorer
/************************************************************************/
CREATE  PROC  WM.lsp_WM_Get_JReport_URL
     @c_CountryName        NVARCHAR(50)  =''
   , @c_Storerkey          NVARCHAR(15)
   , @c_Application        NVARCHAR(15)
   , @c_UserName           NVARCHAR(128) =''   
   , @b_Success            INT = 1              OUTPUT  
   , @n_err                INT = 0              OUTPUT                                                                                                             
   , @c_ErrMsg             NVARCHAR(255) = ''   OUTPUT
   , @c_ReturnURL          NVARCHAR(1000)= ''   OUTPUT  
   , @c_ReturnURLStorer    NVARCHAR(1000)= ''   OUTPUT  
   , @b_Debug              INT = 0
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt          INT            = @@TRANCOUNT
         , @n_Continue           INT            = 1

   DECLARE @c_URLTemplate        NVARCHAR(100)  = ''
         , @c_FolderPath         NVARCHAR(128)  = ''
         --, @c_JReportURL         NVARCHAR(1000) = ''
         , @c_SecondLvl          NVARCHAR(15)   = ''

   SET @n_err      = 0
   SET @c_errmsg   = ''

   SET @n_Err = 0 
   EXEC [WM].[lsp_SetUser] @c_UserName = @c_UserName, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT
   
   IF @b_Debug <> 0
   BEGIN
      SELECT @n_Err, @c_ErrMsg
   END

   IF @n_Err <> 0 
   BEGIN
      GOTO EXIT_SP
   END

   SELECT TOP 1 @c_URLTemplate = n.NSQLDescrip + ISNULL(s.Option5,'')
   FROM NSQLCONFIG AS n WITH (NOLOCK)
   LEFT JOIN StorerConfig AS s WITH (NOLOCK) ON s.ConfigKey='GetJReportURL' AND s.Facility='' AND s.StorerKey='ALL' AND s.SValue='1'
   WHERE n.ConfigKey='JReportURL'
   
   IF @c_URLTemplate = ''
   BEGIN
      SET @n_Continue = 3
      SET @n_Err = 557851
      SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(6), @n_err) + ': JReport URL Link Not Setup.'
                    + '(lsp_WM_Get_JReport_URL)'
   	GOTO EXIT_SP
   END 
   
   IF ISNULL(@c_CountryName,'') <> 'Regional'
   BEGIN
      SELECT TOP 1 @c_CountryName = n.NSQLDescrip
      FROM NSQLCONFIG AS n WITH (NOLOCK)
      WHERE n.ConfigKey='JReportCountry'
    
      IF @c_CountryName = ''
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 557852
         SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(6), @n_err) + ': JReport Country Not Setup.'
                       + '(lsp_WM_Get_JReport_URL)'
   	   GOTO EXIT_SP
      END
   END

   IF @b_Debug <> 0
   BEGIN
      SELECT TOP 1 *
      FROM JREPORTFOLDER WITH (NOLOCK)
      WHERE Storerkey = @c_Storerkey
   END

   SELECT TOP 1 @c_FolderPath = FolderPath
               ,@c_SecondLvl  = SecondLvl
   FROM JREPORTFOLDER WITH (NOLOCK)
   WHERE Storerkey = @c_Storerkey
   --AND   SecondLvl = @c_Application

   SET @c_ReturnURL = ''
   --BEGIN
   --   SET @c_ReturnURL = @c_URLTemplate + '/' + @c_CountryName + '/' + @c_Application + '/' + @c_Storerkey  -- default to this format if no JReportFolder config
   --END
   --ELSE
   IF ISNULL(@c_FolderPath,'') <> ''
   BEGIN
      SET @c_ReturnURL = @c_URLTemplate + '/' + @c_CountryName + '/' + @c_SecondLvl   + '/' + @c_FolderPath -- follow JReportFolder format if config found
   END 

   SET @c_ReturnURLStorer=@c_URLTemplate+ '/' + @c_CountryName + '/' + @c_Application + '/' + @c_Storerkey  -- default to this format if no JReportFolder config

   EXIT_SP:
   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_WM_Get_JReport_URL'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
   REVERT
END -- procedure
GO

