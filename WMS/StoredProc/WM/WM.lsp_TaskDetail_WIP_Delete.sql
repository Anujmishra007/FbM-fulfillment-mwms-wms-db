SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Procedure: lsp_TaskDetail_WIP_Delete                           */
/* Creation Date: 20-SEP-2018                                            */
/* Copyright: LFL                                                        */
/* Written by: Wan                                                       */
/*                                                                       */
/* Purpose: LFWM-1273 - Stored Procedures for Feature - Release Cycle    */
/*          Count                                                        */
/* Called By:                                                            */
/*                                                                       */
/*                                                                       */
/* Version: 1.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date         Author   Ver  Purposes                                   */
/* 2021-02-09   mingle01 1.1  Add Big Outer Begin try/Catch              */
/*                            Execute Login if @c_UserName<>SUSER_SNAME()*/
/* 2025-09-02   SWT01    1.2  Enhanced session management pattern        */
/* 2025-12-02   Michael  1.3  UWP-44616 Fix Gateway Timeout error (ML01) */
/*************************************************************************/
CREATE OR ALTER PROCEDURE [WM].[lsp_TaskDetail_WIP_Delete]
   @c_BatchNo              NVARCHAR(10)
,  @b_Success              INT          = 1   OUTPUT
,  @n_Err                  INT          = 0   OUTPUT
,  @c_Errmsg               NVARCHAR(255)= ''  OUTPUT
,  @c_UserName             NVARCHAR(128)= ''

AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue        INT = 1
         , @n_StartTCnt       INT = @@TRANCOUNT

         , @n_RowId           BIGINT = 0
         , @n_LogKey          BIGINT = 0

         , @CUR_DEL           CURSOR

   SET @b_Success = 1
   SET @c_ErrMsg = ''
   SET @n_Err = 0

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
/* ML01-S
      SET @CUR_DEL = CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT RowID
      FROM TASKDETAIL_WIP WITH (NOLOCK)
      WHERE TaskWIPBatchNo = @c_BatchNo

      OPEN @CUR_DEL

      FETCH NEXT FROM @CUR_DEL INTO @n_RowID
      WHILE @@FETCH_STATUS <> -1
      BEGIN
         BEGIN TRY
            DELETE TASKDETAIL_WIP
            WHERE RowID = @n_RowID
         END TRY

         BEGIN CATCH
            SET @n_Continue = 3
            SET @n_err = 554751
            SET @c_ErrMsg = ERROR_MESSAGE()
            SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Delete from TASKDETAIL_WIP Fail. (lsp_TaskDetail_WIP_Delete)'
                           + '( ' + @c_errmsg + ' )'

            GOTO EXIT_SP
         END CATCH
         FETCH NEXT FROM @CUR_DEL INTO @n_RowID
      END
      CLOSE @CUR_DEL
      DEALLOCATE @CUR_DEL
 ML01-E */

      --ML01-S
      WHILE EXISTS(SELECT TOP 1 1 FROM TASKDETAIL_WIP WITH (NOLOCK) WHERE TaskWIPBatchNo = @c_BatchNo)
      BEGIN
         DELETE TOP (10000) TASKDETAIL_WIP WITH(ROWLOCK)
         WHERE TaskWIPBatchNo = @c_BatchNo
      END
      --ML01-E

      SELECT @n_LogKey = LogKey
      FROM IDS_GENERALLOG WITH (NOLOCK)
      WHERE udf01 = 'SKURELOPTION'
      AND   udf02 = @c_BatchNo

      IF @n_LogKey > 0
      BEGIN
         BEGIN TRY
            DELETE IDS_GENERALLOG WHERE LogKey = @n_LogKey
         END TRY

         BEGIN CATCH
            SET @n_Continue = 3
            SET @n_err = 554752
            SET @c_ErrMsg = ERROR_MESSAGE()
            SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Delete From IDS_GeneralLog Fail. (lsp_TaskDetail_WIP_Delete)'
                           + '( ' + @c_errmsg + ' )'

            GOTO EXIT_SP
         END CATCH
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_TaskDetail_WIP_Delete'
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
GRANT EXECUTE ON  [WM].[lsp_TaskDetail_WIP_Delete] TO [NSQL]
GO
