SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Procedure: WM.lsp_KioskASRSCCTaskCfm_Wrapper                   */
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
CREATE OR ALTER PROCEDURE [WM].[lsp_KioskASRSCCTaskCfm_Wrapper]
   @c_Jobkey         NVARCHAR(10)
,  @c_TaskDetailkey  NVARCHAR(10)
,  @c_ID             NVARCHAR(18)
,  @c_CCKey          NVARCHAR(10)
,  @c_CCSheetNo      NVARCHAR(10)
,  @c_CCDetailkey    NVARCHAR(10)
,  @c_Storerkey      NVARCHAR(20)
,  @c_Sku            NVARCHAR(20)
,  @c_Lottable01     NVARCHAR(18)
,  @c_Lottable02     NVARCHAR(18)
,  @c_Lottable03     NVARCHAR(18)
,  @dt_Lottable04    DATETIME
,  @dt_Lottable05    DATETIME
,  @c_Lottable06     NVARCHAR(30)
,  @c_Lottable07     NVARCHAR(30)
,  @c_Lottable08     NVARCHAR(30)
,  @c_Lottable09     NVARCHAR(30)
,  @c_Lottable10     NVARCHAR(30)
,  @c_Lottable11     NVARCHAR(30)
,  @c_Lottable12     NVARCHAR(30)
,  @dt_Lottable13    DATETIME
,  @dt_Lottable14    DATETIME
,  @dt_Lottable15    DATETIME
,  @n_CountedQty     INT
,  @c_taskstatus     NVARCHAR(10) OUTPUT
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
         , @b_ExecuteAs       BIT = 0 -- (SSA01)

   SET @b_Success = 1
   SET @c_ErrMsg = ''

   SET @n_Err = 0

   -- Enhanced session management (SWT01)
   --(mingle01) - START
   -- Enhanced session management (SSA01)
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

       IF @b_ExecuteAs = 1 -- (SWT01)
         EXECUTE AS LOGIN = @c_UserName
   END
   -- End enhanced session management (SSA01)
   --(mingle01) - END
   -- End enhanced session management (SWT01)

   --(mingle01) - START
   BEGIN TRY

      BEGIN TRY
         EXEC isp_KioskASRSCCTaskCfm
            @c_jobkey         = @c_jobkey
         ,  @c_TaskDetailkey  = @c_TaskDetailkey
         ,  @c_id             = @c_id
         ,  @c_CCKey          = @c_CCKey
         ,  @c_CCSheetNo      = @c_CCSheetNo
         ,  @c_CCDetailkey    = @c_CCDetailkey
         ,  @c_Storerkey      = @c_Storerkey
         ,  @c_Sku            = @c_Sku
         ,  @c_Lottable01     = @c_Lottable01
         ,  @c_Lottable02     = @c_Lottable02
         ,  @c_Lottable03     = @c_Lottable03
         ,  @dt_Lottable04    = @dt_Lottable04
         ,  @dt_Lottable05    = @dt_Lottable05
         ,  @c_Lottable06     = @c_Lottable06
         ,  @c_Lottable07     = @c_Lottable07
         ,  @c_Lottable08     = @c_Lottable08
         ,  @c_Lottable09     = @c_Lottable09
         ,  @c_Lottable10     = @c_Lottable10
         ,  @c_Lottable11     = @c_Lottable11
         ,  @c_Lottable12     = @c_Lottable12
         ,  @dt_Lottable13    = @dt_Lottable13
         ,  @dt_Lottable14    = @dt_Lottable14
         ,  @dt_Lottable15    = @dt_Lottable15
         ,  @n_CountedQty     = @n_CountedQty
         ,  @c_taskstatus     = @c_taskstatus   OUTPUT
         ,  @b_Success        = @b_Success      OUTPUT
         ,  @n_Err            = @n_Err          OUTPUT
         ,  @c_Errmsg         = @c_Errmsg       OUTPUT
      END TRY

      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_err = 552851
         SET @c_ErrMsg = ERROR_MESSAGE()
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_err)
                       + ': CC Count Complete Fail. ' +  @c_ErrMsg
      END CATCH

      IF @b_success = 0 OR @n_Err <> 0
      BEGIN
         SET @n_continue = 3
         GOTO EXIT_SP
      END

      SET @c_ErrMsg = 'CC Count Complete Sucessfully.'

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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_KioskASRSCCTaskCfm_Wrapper'
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
GRANT EXECUTE ON  [WM].[lsp_KioskASRSCCTaskCfm_Wrapper] TO [NSQL]
GO
