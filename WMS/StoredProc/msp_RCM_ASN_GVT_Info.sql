SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: msp_RCM_ASN_GVT_Info                                    */
/* Creation Date: 2026-04-28                                            */
/* Copyright: Maersk Logistics                                          */
/* Written by: Supriya Sangeetham                                       */
/*                                                                      */
/* Purpose: UWP-54447 - MWMS Retrigger RCMConfig SP                     */
/*        :                                                             */
/* Called By:    lsp_RCMConfigSP_ASN_Wrapper                            */
/*          :                                                           */
/*                                                                      */
/* Version: 1.1                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date               Author      Ver   Purposes                        */
/* 2026-04-28         SSA01      1.0   Created.                         */
/* 2026-05-25         Preetham   2.0   inserting directly to GVTLog     */
/************************************************************************/
CREATE OR ALTER   PROC [dbo].[msp_RCM_ASN_GVT_Info]
   @c_Receiptkey  NVARCHAR(10)
,  @b_success  INT          = 1  OUTPUT
,  @n_err      INT          = 0  OUTPUT
,  @c_errmsg   NVARCHAR(225)= '' OUTPUT
,  @c_code     NVARCHAR(30) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
           @n_StartTCnt          INT   = @@TRANCOUNT
         , @n_Continue           INT   = 1

         , @c_ASNStatus          NVARCHAR(10) = ''
         , @c_Status                 NVARCHAR(10) = ''
         , @c_Storerkey           NVARCHAR(15) = ''
         , @c_Tablename         NVARCHAR(30) = 'GVTASNREC'

   SET @b_success = 1
   SET @n_err     = 0
   SET @c_errmsg  = ''

   SELECT @c_Status = rh.Status
         ,@c_ASNStatus = rh.ASNStatus
         ,@c_Storerkey = rh.Storerkey
   FROM RECEIPT rh (NOLOCK)
   WHERE rh.Receiptkey = @c_ReceiptKey

  IF @@TRANCOUNT = 0
        BEGIN TRAN

   IF @c_ASNStatus <> '0'
   BEGIN
      SET @n_Continue = 3
      SET @n_Err = 68010
      SET @c_ErrMsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)
                    + ': ASN_INFO cannot be sent when ASNStatus is not 0. (msp_RCM_ASN_GVT_Info)'
      GOTO QUIT_SP
   END
    IF @n_Continue IN (1,2)
    BEGIN
           IF EXISTS ( SELECT 1 FROM StorerConfig STC WITH (NOLOCK)
                      WHERE STC.StorerKey = @c_Storerkey
                      AND   STC.ConfigKey = 'GVTITF'
                      AND   STC.SValue    = '1' )
          BEGIN
                IF @c_Status = '0'
                BEGIN                                                        --Preetham1(Start)
                    BEGIN TRY
                        INSERT INTO GVTLog (tablename, key1, key2, key3, transmitflag, TransmitBatch)
                        VALUES (@c_Tablename, @c_ReceiptKey, @c_ASNStatus, @c_StorerKey, '0', '')
                    END TRY
                    BEGIN CATCH
                        SET @n_Continue = 3
                        SET @n_Err = 68011
                        SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                                        + ': Exception while inserting ASN_INFO to GVTLog. (msp_RCM_ASN_GVT_Info)'
                                        + ' ERR' + ERROR_MESSAGE()

                            GOTO QUIT_SP
                    END CATCH
                 END                                                        --Preetham1(end)
          END
      END

   QUIT_SP:
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'msp_RCM_ASN_GVT_Info'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- procedure
GO
GRANT EXECUTE ON msp_RCM_ASN_GVT_Info TO nSQL
GO
