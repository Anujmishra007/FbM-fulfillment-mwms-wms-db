SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Procedure: lsp_GetGTMKioskPendingJob_Wrapper                   */
/* Creation Date: 28-FEB-2019                                            */
/* Copyright: LFL                                                        */
/* Written by:                                                           */
/*                                                                       */
/* Purpose:                                                              */
/*                                                                       */
/* Called By:                                                            */
/*                                                                       */
/*                                                                       */
/* Version: 1.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date         Author   Ver  Purposes                                   */
/* 2021-02-05   mingle01 1.1  Add Big Outer Begin try/Catch             */
/*                            Execute Login if @c_UserName<>SUSER_SNAME()*/
/* 2025-01-21   SWT01    1.2  Enhanced session management               */
/* 2025-10-10  AK01     1.3   UWP-41151 - Replace SUSER_SNAME with       */
/*                            fnc_GetUserName & GETDATE() with fnc_GetDate()*/
/*************************************************************************/
CREATE OR ALTER PROCEDURE [WM].[lsp_GetGTMKioskPendingJob_Wrapper]
   @c_GTMWorkStation       NVARCHAR(10)
,  @c_JobKey               NVARCHAR(10)        OUTPUT
,  @b_Success              INT          = 1    OUTPUT
,  @n_Err                  INT          = 0    OUTPUT
,  @c_Errmsg               NVARCHAR(255)= ''   OUTPUT
,  @n_WarningNo            INT          = 0   OUTPUT
,  @c_ProceedWithWarning   CHAR(1)      = 'N'
,  @c_UserName             NVARCHAR(128)= ''
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue     INT = 1
         , @n_StartTCnt    INT = @@TRANCOUNT

         , @n_StartedJob   INT = 0

   SET @b_Success = 1
   SET @c_ErrMsg = ''

   SET @n_Err = 0

   -- (SWT01) - START
   DECLARE @b_ExecuteAs BIT = 0
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
         EXECUTE AS LOGIN = @c_UserName
   END
   -- (SWT01) - END

   --(mingle01) - START
   BEGIN TRY

		IF @c_ProceedWithWarning = 'N' AND @n_WarningNo < 1
		BEGIN
			SET @n_StartedJob = 0
			SELECT TOP 1 @n_StartedJob = 1
						, @c_JobKey = TD.TaskDetailKey
			FROM TASKDETAIL TD WITH (NOLOCK)
			WHERE TD.UserPosition = @c_GTMWorkStation
			AND   TD.TaskType = 'GTMJOB'
			AND   TD.[Status] >= '3' AND TD.[Status] < '9'
			ORDER BY TD.TaskDetailKey

			IF @n_StartedJob = 0 -- GET NewJOB
			BEGIN
				GOTO EXIT_SP
			END

			IF @n_StartedJob > 0 -- GET PendingJOB
			BEGIN
				SET @n_WarningNo = 1
				SET @c_Errmsg = 'Job - ' + RTRIM(@c_JobKey) + ' had started and in progress. Continue to perform this job?'
				GOTO EXIT_SP
			END
		END

		BEGIN TRY
			UPDATE TASKDETAIL WITH (ROWLOCK)
			SET StatusMsg = '0'
				,EditWho   = @c_UserName
				,EditDate  = dbo.fnc_GetDate()
				,Trafficcop= NULL
			WHERE TaskDetailKey = @c_JobKey
			AND   TaskType = 'GTMJOB'
			AND   [Status] >= '3' AND Status < '9'
			AND   StatusMsg = '1'

		END TRY
		BEGIN CATCH
			SET @n_Continue = 3
			SET @n_err = 555451
			SET @c_ErrMsg = ERROR_MESSAGE()
			SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Update TASKDETAIL Table fail. (lsp_GetGTMKioskPendingJob_Wrapper)'
								+ '( ' + @c_errmsg + ' )'
			GOTO EXIT_SP
		END CATCH

   END TRY

	BEGIN CATCH
      SET @n_Continue = 3
      SET @c_ErrMsg = ERROR_MESSAGE()
      GOTO EXIT_SP
	END CATCH
	--(mingle01) - END
EXIT_SP:
   IF @b_ExecuteAs = 1              -- (SWT01)
      REVERT                        

   EXEC [WM].[lsp_ResetUser] -- (SWT01)

   IF @n_Continue = 3
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_GetGTMKioskPendingJob_Wrapper'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END
GO
GRANT EXECUTE ON  [WM].[lsp_GetGTMKioskPendingJob_Wrapper] TO [NSQL]
GO

