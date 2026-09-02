SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: msp_BEJ_AsnAutoFinalize                            */
/* Creation Date: 27-Aug-2026                                           */
/* Copyright: Maersk                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: FCR-15217   - Auto ASN Finalize                             */
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
/* Date         Author   Rev   Purposes                                 */
/*2026-08-27    USH022   1.0   Created - FCR-15217 - ASN Auto Finalize  */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[msp_BEJ_AsnAutoFinalize]
     @c_StorerKey   NVARCHAR(15)   = ''
   , @c_Facility    NVARCHAR(5)    = ''
   , @c_OtherConfig NVARCHAR(4000)  = ''
   , @b_debug       INT = 0

AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   DECLARE  @n_Continue         INT
            , @b_Success        INT
            , @n_Err            INT
            , @c_ErrMsg         NVARCHAR(250)
            , @n_StartTCnt      INT -- Holds the current transaction count
            , @c_ReceiptKey         NVARCHAR(10)
            , @n_WarningNo          INT          = 0
            , @c_ProceedWithWarning CHAR(1)      = 'N'
            , @n_SkipGenID          INT          = 0
            , @c_ASNStatusCode      NVARCHAR(10)  = ''
            , @c_ASNStatusShort     NVARCHAR(10)  = ''  -- optional: CODELKUP.Short to resolve into @c_ASNStatusCode
            , @n_ErrNo              INT
            , @c_ErrMsg_TRY         NVARCHAR(4000)
            , @c_OtherFilterCond    NVARCHAR(2000) = ''  -- dynamic condition parsed from @c_OtherConfig
            , @c_ASNStatusCondition NVARCHAR(100)  = ''   -- built only when @c_ASNStatusCode is resolved
            , @c_SQL                NVARCHAR(MAX)  = ''
            , @c_SQLParmDef         NVARCHAR(500)  = ''
            , @c_UserName           NVARCHAR(128)  = SUSER_SNAME()
            , @n_ErrGroupKey_TRY    INT            = 0

   SELECT @n_StartTCnt = @@TRANCOUNT
        , @n_Continue = 1
        , @b_Success = 1
        , @n_Err = 0

   SELECT @c_ErrMsg=''

   IF @b_debug = 1
          BEGIN
            print('@c_StorerKey :'+@c_StorerKey )
            print('@c_Facility:'+@c_Facility)
          END

      SELECT @c_ASNStatusShort = dbo.fnc_GetParamValueFromString('@c_ASNStatusShort', @c_OtherConfig, '')

      IF ISNULL(@c_ASNStatusShort,'') <> ''
      BEGIN
         SELECT @c_ASNStatusCode = ISNULL(LTRIM(RTRIM(C.Code)),'')
         FROM CODELKUP C (NOLOCK)
         WHERE C.LISTNAME = 'ASNStatus'
               AND C.Short = @c_ASNStatusShort

         IF ISNULL(@c_ASNStatusCode,'') <> ''
         BEGIN
            SET @c_ASNStatusCondition = N'AND   R.ASNStatus = @c_ASNStatusCode '
         END
      END

      -- @c_Query defaults to '' - no baked-in filter. Caller must supply its own condition(s) per Storer/Facility.
      SELECT @c_OtherFilterCond = dbo.fnc_GetParamValueFromString('@c_OtherFilterCond', @c_OtherConfig, '')

      IF dbo.fnc_GetParamValueFromString('@b_Debug', @c_OtherConfig, '0') = '1'
      BEGIN
         SET @b_debug = 1
      END

      IF @b_debug = 1
      BEGIN
         PRINT '@c_OtherConfig: ' + ISNULL(@c_OtherConfig,'')
         PRINT '@c_ASNStatusShort: ' + ISNULL(@c_ASNStatusShort,'')
         PRINT '@c_ASNStatusCode: ' + ISNULL(@c_ASNStatusCode,'')
         PRINT '@c_OtherFilterCond: ' + ISNULL(@c_OtherFilterCond,'')
      END

      IF OBJECT_ID('tempdb..#TMP_ASNAUTO_FINALIZE') IS NOT NULL
      BEGIN
         DROP TABLE #TMP_ASNAUTO_FINALIZE
      END

      CREATE TABLE #TMP_ASNAUTO_FINALIZE
      (
         ReceiptKey        NVARCHAR(10)
      )

      SET @c_SQL =
           N'SELECT DISTINCT R.ReceiptKey '
         + N'FROM dbo.RECEIPT R (NOLOCK) '
         + N'WHERE R.StorerKey = @c_StorerKey '
         + N'AND   R.Facility  = @c_Facility '
         + N'AND   R.Status    = ''0'' '
         + N' ' + @c_ASNStatusCondition + N' '
         + N' ' + ISNULL(@c_OtherFilterCond,'') + N' '   -- caller-supplied condition appended after Storer/Facility filter
         + N'ORDER BY R.ReceiptKey'

      SET @c_SQLParmDef = N'@c_StorerKey NVARCHAR(15), @c_Facility NVARCHAR(5), @c_ASNStatusCode NVARCHAR(10)'

      IF @b_debug = 1
      BEGIN
         PRINT '@c_SQL: ' + @c_SQL
      END

      INSERT INTO #TMP_ASNAUTO_FINALIZE (ReceiptKey)
      EXEC sp_executesql
           @c_SQL
         , @c_SQLParmDef
         , @c_StorerKey     = @c_StorerKey
         , @c_Facility      = @c_Facility
         , @c_ASNStatusCode = @c_ASNStatusCode

     DECLARE CUR_ASNAUTO_FINALIZE CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT T.ReceiptKey
         FROM #TMP_ASNAUTO_FINALIZE T

      OPEN CUR_ASNAUTO_FINALIZE

      FETCH NEXT FROM CUR_ASNAUTO_FINALIZE INTO @c_ReceiptKey

       WHILE @@FETCH_STATUS <> -1
       BEGIN
       --Calling finalize wrapper for each receipt line and receipt key
       --to be processed
        BEGIN TRY
        EXEC WM.lsp_FinalizeReceipt_Wrapper
                @c_ReceiptKey           = @c_ReceiptKey
              , @c_ReceiptLineNumber    = ''
              , @b_Success              = @b_Success         OUTPUT
              , @n_Err                  = @n_Err             OUTPUT
              , @c_ErrMsg               = @c_ErrMsg          OUTPUT
              , @n_WarningNo            = @n_WarningNo       OUTPUT
              , @c_ProceedWithWarning   = @c_ProceedWithWarning
              , @c_UserName             = @c_UserName
              , @n_ErrGroupKey          = @n_ErrGroupKey_TRY OUTPUT
              , @n_SkipGenID            = @n_SkipGenID       OUTPUT
        END TRY
        BEGIN CATCH
           SET @n_ErrNo      = ERROR_NUMBER()
           SET @c_ErrMsg_TRY = ERROR_MESSAGE()
           SET @b_Success    = 0
           SET @n_Err        = @n_ErrNo
           SET @c_ErrMsg     = 'NSQL' + CONVERT(NVARCHAR(5), @n_ErrNo)
                             + ': ' + @c_ErrMsg_TRY + ' (lsp_FinalizeReceipt_Wrapper call)'
           EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AsnAutoFinalize'  --logging purpose
           SET @n_Continue = 3
           GOTO QUIT_SP
        END CATCH
       -- end of the call
         FETCH NEXT FROM CUR_ASNAUTO_FINALIZE INTO  @c_ReceiptKey
       END
       CLOSE CUR_ASNAUTO_FINALIZE
       DEALLOCATE CUR_ASNAUTO_FINALIZE

       IF OBJECT_ID('tempdb..#TMP_ASNAUTO_FINALIZE') IS NOT NULL
       BEGIN
          DROP TABLE #TMP_ASNAUTO_FINALIZE
       END

       GOTO EXIT_SP

QUIT_SP:
       IF CURSOR_STATUS('local','CUR_ASNAUTO_FINALIZE') >= 0
       BEGIN
         CLOSE CUR_ASNAUTO_FINALIZE
         DEALLOCATE CUR_ASNAUTO_FINALIZE
       END

       IF OBJECT_ID('tempdb..#TMP_ASNAUTO_FINALIZE') IS NOT NULL
       BEGIN
         DROP TABLE #TMP_ASNAUTO_FINALIZE
       END

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
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AsnAutoFinalize'
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
