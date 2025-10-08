SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: mspPRREC02                                            */
/* Creation Date: 2025-10-06                                               */
/* Copyright: Maersk Logistics                                             */
/* Written by: Wan                                                         */
/*                                                                         */
/* Purpose: FCR-7996 - PAGE FG ASN FINALIZATION CR                         */
/*                                                                         */
/* Called By: ASN Storerconfig 'PreFinalizeReceiptSP'                      */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: V2                                                             */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date        Author   Ver   Purposes                                     */
/* 2025-10-06  Wan      1.0   Created                                      */
/***************************************************************************/
CREATE OR ALTER PROC [dbo].[mspPRREC02]
   @c_Receiptkey        NVARCHAR(10)
,  @c_ReceiptLineNumber NVARCHAR(5)    = ''
,  @b_Success           INT            = 1   OUTPUT
,  @n_Err               INT            = 0   OUTPUT
,  @c_ErrMsg            NVARCHAR(255)  = ''  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Debug              INT   = 0
         , @n_Cnt                INT   = 0
         , @n_Continue           INT   = 1
         , @n_StartTCnt          INT   = @@TRANCOUNT

   DECLARE @c_Facility           NVARCHAR( 5)   = ''
         , @c_Storerkey          NVARCHAR(15)   = ''
         , @c_ASNStatus          NVARCHAR(10)   = '0'
         , @c_ItemClass          NVARCHAR(10)   = ''

         , @CUR_RD               CURSOR

   SET @b_Success= 1
   SET @n_Err    = 0
   SET @c_ErrMsg = ''

   SELECT @c_Storerkey    = rh.Storerkey 
         ,@c_ASNStatus    = rh.ASNStatus
   FROM Receipt rh(NOLOCK)
   WHERE rh.ReceiptKey = @c_Receiptkey

   IF @c_ASNStatus >= '9'
   BEGIN
      GOTO QUIT_SP
   END

   IF @c_ReceiptLineNumber > ''
   BEGIN
      SET @CUR_RD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT rd.ReceiptKey
            ,rd.ReceiptLineNumber
            ,ItemClass = ISNULL(s.ItemClass,'')
      FROM ReceiptDetail rd (NOLOCK)
      JOIN Sku s (NOLOCK) ON  s.Storerkey = rd.Storerkey
                          AND s.Sku = rd.Sku
      WHERE rd.ReceiptKey = @c_Receiptkey
      AND   rd.ReceiptLineNumber = @c_ReceiptLineNumber
      ORDER BY rd.ReceiptLineNumber
   END
   ELSE
   BEGIN
      SET @CUR_RD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT rd.ReceiptKey
            ,rd.ReceiptLineNumber
            ,ItemClass = ISNULL(s.ItemClass,'')
      FROM ReceiptDetail rd (NOLOCK)
      JOIN Sku s (NOLOCK) ON  s.Storerkey = rd.Storerkey
                          AND s.Sku = rd.Sku
      WHERE rd.ReceiptKey = @c_Receiptkey
      ORDER BY rd.ReceiptLineNumber
   END

   OPEN @CUR_RD

   FETCH NEXT FROM @CUR_RD INTO @c_Receiptkey
                              , @c_ReceiptLineNumber
                              , @c_ItemClass
 
   WHILE @@FETCH_STATUS <> -1 AND @n_Continue IN (1,2)
   BEGIN
      UPDATE rd WITH (ROWLOCK)
         SET Lottable06 = @c_ItemClass
         ,   Trafficcop = NULL
      FROM RECEIPTDETAIL rd
      WHERE rd.Receiptkey = @c_Receiptkey
      AND   rd.ReceiptLineNumber = @c_ReceiptLineNumber

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3
         SET @c_ErrMsg = ERROR_MESSAGE()
      END
    
      FETCH NEXT FROM @CUR_RD INTO @c_Receiptkey
                                 , @c_ReceiptLineNumber
                                 , @c_ItemClass
   END
   CLOSE @CUR_RD
   DEALLOCATE @CUR_RD

   QUIT_SP:
   IF @n_Continue=3  -- Error Occured - Process AND Return
   BEGIN
       SET @b_Success = 0
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
       EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'mspPRREC02'    
       --RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    -- SQL2012
    END
    ELSE
    BEGIN
       SET @b_Success = 1
       WHILE @@TRANCOUNT > @n_StartTCnt
       BEGIN
         COMMIT TRAN
       END
   END  
   RETURN 
END
GO
GRANT EXECUTE ON [dbo].[mspPRREC02] TO nSQL
GO
