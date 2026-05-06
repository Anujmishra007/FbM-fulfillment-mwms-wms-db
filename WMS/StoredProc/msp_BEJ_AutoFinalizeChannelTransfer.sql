SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Stored Procedure: msp_BEJ_AutoFinalizeChannelTransfer                */
/* Creation Date: 25-Mar-2026                                           */
/* Copyright: Maersk                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: FCR-11813   - Auto Finalize Channel Transfer for PAGE       */
/*                                                                      */
/* Called By: Call by SQL Scheduler Job                                 */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Rev   Purposes                                  */
/*2026-03-25    SSA01   1.0   Created - FCR-11813  - Auto Finalize      */
/*                            Channel Transfer for PAGE                 */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[msp_BEJ_AutoFinalizeChannelTransfer]
     @c_StorerKey   NVARCHAR(15)   = ''
   , @c_Facility    NVARCHAR(5)    = ''
   , @c_OtherConfig NVARCHAR(4000)  = ''
   , @b_debug       INT = 0

AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   DECLARE  @n_Continue       INT
            , @b_Success     INT
            , @n_Err         INT
            , @c_ErrMsg      NVARCHAR(250)
            , @n_StartTCnt    INT -- Holds the current transaction count
            , @c_ChannelTransferKey         NVARCHAR(10)

   SELECT @n_StartTCnt=@@TRANCOUNT , @n_Continue=1, @b_Success=1, @n_Err=0

   SELECT @c_ErrMsg=''

   IF @b_debug = 1
          BEGIN
            print('@c_StorerKey :'+@c_StorerKey )
            print('@c_Facility:'+@c_Facility)
          END

      DECLARE CUR_CHANNEL_TRF CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT CT.ChannelTransferKey FROM ChannelTransfer CT
      JOIN Codelkup CL ON CT.FromStorerKey = CL.Storerkey AND CL.Listname = 'CHTRFTYPE'
      AND CL.Code = CT.Type AND CL.UDF01 = 'Y'
      WHERE  CT.Facility = @c_Facility
      AND CT.FromStorerKey = @c_StorerKey
      AND CT.STATUS =  '0'

      OPEN CUR_CHANNEL_TRF

      FETCH NEXT FROM CUR_CHANNEL_TRF INTO @c_ChannelTransferKey

       WHILE @@FETCH_STATUS <> -1
       BEGIN
           BEGIN TRY
            EXEC [WM].[lsp_FinalizeChannelTRF_Wrapper]
              @c_ChannelTransferKey  =  @c_ChannelTransferKey
           ,  @c_ChannelTransferLineNumber = ''
           , @b_Success = 1
           , @n_Err = 0
           , @c_Errmsg = ''
           , @c_UserName = ''
          END TRY
          BEGIN CATCH
              SET @c_ErrMsg = ERROR_MESSAGE()
              SET @n_err = 550156
              SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(6),@n_err)+':'+@c_ChannelTransferKey  + '(' + @c_errmsg + '): Execute lsp_FinalizeChannelTRF_Wrapper Failed. (msp_BEJ_AutoFinalizeChannelTransfer)'
              EXECUTE nsp_logerror @n_err, @c_errmsg, 'msp_BEJ_AutoFinalizeChannelTransfer'
          END CATCH
         FETCH NEXT FROM CUR_CHANNEL_TRF INTO  @c_ChannelTransferKey
       END
       CLOSE CUR_CHANNEL_TRF
       DEALLOCATE CUR_CHANNEL_TRF

EXIT_SP:

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_Success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
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
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoFinalizeChannelTransfer'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END

END -- Procedure
GO
