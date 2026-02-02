SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Procedure: lsp_WOMJobUnHoldTasks_Wrapper                       */
/* Creation Date: 25-JUN-2018                                            */
/* Copyright: LFL                                                        */
/* Written by: Wan                                                       */
/*                                                                       */
/* Purpose: LFWMS-466 - Inventory Work Order Management                  */
/*          Work Order Execution  Job Maintenance                        */
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
/* 2021-02-10   mingle01 1.1  Add Big Outer Begin try/Catch              */
/*                            Execute Login if @c_UserName<>SUSER_SNAME()*/
/* 2025-09-02   SWT01    1.2   Enhanced session management pattern       */
/* 2025-10-10   SPC040    1.3   Replace SUSER_SNAME with fnc_GetUserName */
/*************************************************************************/
CREATE OR ALTER PROCEDURE [WM].[lsp_WOMJobUnHoldTasks_Wrapper]
  @c_JobKey    NVARCHAR(10)
, @b_Success   INT           OUTPUT
, @n_Err       INT           OUTPUT
, @c_ErrMsg    NVARCHAR(250) OUTPUT
, @c_UserName  NVARCHAR(128) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue        INT = 1
         , @n_StartTCnt       INT = @@TRANCOUNT

   SET @b_Success = 1
   SET @c_ErrMsg = ''

   -- Start enhanced session management (SWT01)
	 SET @n_Err = 0
	 DECLARE @b_ExecuteAs        BIT = 0
	 IF SUSER_SNAME() <> @c_UserName AND @c_UserName <> ''        
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
	 -- End enhanced session management (SWT01)

   --(mingle01) - START
   BEGIN TRY
      BEGIN TRY
         UPDATE WORKORDERJOBDETAIL WITH (ROWLOCK)
         SET JobStatus = '4'
         ,  EditWho    = @c_UserName
         ,  EditDate = dbo.fnc_GetDate()
         ,  Trafficcop = NULL
         WHERE @c_JobKey = @c_JobKey
      END TRY

      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_err = 553751
         SET @c_ErrMsg = ERROR_MESSAGE()
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_err)
                       + ': Update WORKORDERJOBDETAIL Table Fail. (lsp_WOMJobUnHoldTasks_Wrapper)'
                       + '( ' + @c_errmsg + ' )'
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_WOMJobUnHoldTasks_Wrapper'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END

   IF @b_ExecuteAs = 1 REVERT -- (SWT01)
   EXEC [WM].[lsp_ResetUser]  -- (SWT01)
END
GO
GRANT EXECUTE ON [WM].[lsp_WOMJobUnHoldTasks_Wrapper] TO nSQL 
GO
