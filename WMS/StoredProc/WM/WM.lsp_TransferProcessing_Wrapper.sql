SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: lsp_TransferProcessing_Wrapper                     */
/* Creation Date: 06-Sept-2018                                          */
/* Copyright: LFLogistics                                               */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: Tranfer processing                                          */
/*                                                                      */
/* Called By: Transfer                                                  */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 8.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/* 2021-02-10   mingle01 1.1  Add Big Outer Begin try/Catch              */
/*                            Execute Login if @c_UserName<>SUSER_SNAME()*/
/* 2025-09-02  SWT01    1.1   Enhanced session management pattern       */
/************************************************************************/

CREATE OR ALTER PROCEDURE [WM].[lsp_TransferProcessing_Wrapper]
      @c_TransferKey NVARCHAR(10)
    , @b_Success INT=1 OUTPUT
    , @n_Err INT=0 OUTPUT
    , @c_ErrMsg NVARCHAR(250)='' OUTPUT
    , @n_WarningNo INT = 0       OUTPUT
    , @c_ProceedWithWarning CHAR(1) = 'N'
    , @c_UserName NVARCHAR(128)=''
    , @n_ErrGroupKey INT = 0 OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue         INT,
           @n_starttcnt        INT,
           @c_TableName        NVARCHAR(50),
           @c_SourceType       NVARCHAR(30)

   SELECT @n_starttcnt=@@TRANCOUNT, @n_err=0, @b_success=1, @c_errmsg='', @n_continue=1

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
      IF @n_continue IN(1,2)
      BEGIN
           IF EXISTS(SELECT 1
                     FROM TRANSFER (NOLOCK)
                     WHERE Transferkey = @c_Transferkey
                     AND STATUS = '9')
           BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 554551
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(6),@n_err)+': Transfer has been finalized. Not allowed to allocate. (lsp_TransferProcessing_Wrapper)'
           END
      END

      IF @n_continue IN(1,2)
      BEGIN
           IF EXISTS(SELECT 1
                     FROM TRANSFER (NOLOCK)
                     WHERE Transferkey = @c_Transferkey
                     AND STATUS = 'CANC')
           BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 554552
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(6),@n_err)+': Transfer has been Cancelled. Not allowed to allocate. (lsp_TransferProcessing_Wrapper)'
           END
      END

      IF @n_continue IN(1,2)
      BEGIN
         BEGIN TRY
            EXEC isp_TransferProcessing
                 @c_Transferkey  = @c_TransferKey,
                 @b_Success = @b_Success OUTPUT,
                 @n_err     = @n_err     OUTPUT,
                @c_ErrMsg  = @c_ErrMsg  OUTPUT
         END TRY
         BEGIN CATCH
            IF @n_err = 0
            BEGIN
               SET @n_continue = 3
               SELECT @n_err = ERROR_NUMBER(),
                      @c_ErrMsg = ERROR_MESSAGE()
            END
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
   IF @n_continue = 3
      SET @b_Success = 0

   IF @b_ExecuteAs = 1 REVERT -- (SWT01)
   EXEC [WM].[lsp_ResetUser]  -- (SWT01)
END -- End Procedure
GO
GRANT EXECUTE ON [WM].[lsp_TransferProcessing_Wrapper] TO nSQL 
GO
