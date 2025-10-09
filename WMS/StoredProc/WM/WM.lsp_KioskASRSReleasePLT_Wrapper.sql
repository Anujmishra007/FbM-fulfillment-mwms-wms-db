SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Procedure: lsp_KioskASRSReleasePLT_Wrapper                     */
/* Creation Date: 18-JUN-2018                                            */
/* Copyright: LFL                                                        */
/* Written by: Wan                                                       */
/*                                                                       */
/* Purpose: LFWM-572 - Stored Procedures for Release 2 Feature�C GTM Kiosk*/
/*                                                                       */
/* Called By:                                                            */
/*                                                                       */
/*                                                                       */
/* Version: 1.2 (SWT01)                                                 */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date         Author   Ver  Purposes                                   */
/* 2021-02-05   mingle01 1.1  Add Big Outer Begin try/Catch             */
/*                            Execute Login if @c_UserName<>SUSER_SNAME()*/
/* 2025-01-09   SWT01    1.2  Enhanced session management                */
/*************************************************************************/
CREATE OR ALTER PROCEDURE [WM].[lsp_KioskASRSReleasePLT_Wrapper]
   @c_Jobkey         NVARCHAR(10)
,  @c_Releaseid      NVARCHAR(18)
,  @c_Jobstatus      NVARCHAR(10)
,  @b_RejEmptyPLT    INT          = 0
,  @b_Success        INT          = 1  OUTPUT
,  @n_Err            INT          = 0  OUTPUT
,  @c_Errmsg         NVARCHAR(255)= '' OUTPUT
,  @c_UserName       NVARCHAR(128)= ''
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_ExecuteAs       BIT = 0 -- (SWT01)
         , @n_Continue        INT = 1
         , @n_StartTCnt       INT = @@TRANCOUNT

   SET @b_Success = 1
   SET @c_ErrMsg = ''

   SET @n_Err = 0

   -- Enhanced session management (SWT01)
   --(mingle01) - START
   IF SUSER_SNAME() <> @c_UserName
   BEGIN
      EXEC [WM].[lsp_SetUser]
            @c_UserName = @c_UserName  OUTPUT
         ,  @n_Err      = @n_Err       OUTPUT
         ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
         ,  @b_ExecuteAs = @b_ExecuteAs OUTPUT

      IF @n_Err <> 0

      BEGIN
         GOTO EXIT_SP
      END

       IF @b_ExecuteAs = 1
         EXECUTE AS LOGIN =@c_UserName 
   END
   --(mingle01) - END
   -- End enhanced session management (SWT01)

   --(mingle01) - START
   BEGIN TRY

      BEGIN TRY
         EXEC isp_KioskASRSReleasePLT
            @c_jobkey         = @c_jobkey
         ,  @c_releaseid      = @c_releaseid
         ,  @c_jobstatus      = @c_jobstatus
         ,  @b_RejEmptyPLT    = @b_RejEmptyPLT
         ,  @b_Success        = @b_Success   OUTPUT
         ,  @n_Err            = @n_Err       OUTPUT
         ,  @c_Errmsg         = @c_Errmsg    OUTPUT
      END TRY

      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_err = 551651
         SET @c_ErrMsg = ERROR_MESSAGE()
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_err)
                       + ': Release Pallet: ' + @c_releaseid + ' fail. ' +  @c_ErrMsg
      END CATCH

      IF @b_success = 0 OR @n_Err <> 0
      BEGIN
         SET @n_continue = 3
         GOTO EXIT_SP
      END

  END TRY
   BEGIN CATCH
      SET @n_Continue = 3
      SET @c_ErrMsg = ERROR_MESSAGE()
      GOTO EXIT_SP
   END CATCH
   --(mingle01) - END
EXIT_SP:

   IF @b_ExecuteAs = 1 REVERT -- (SWT01)

   EXEC [WM].[lsp_ResetUser] -- (SWT01)

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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_KioskASRSReleasePLT_Wrapper'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
END
GO
GRANT EXECUTE ON  [WM].[lsp_KioskASRSReleasePLT_Wrapper] TO [NSQL]
GO
