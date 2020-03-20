IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[ispASNFZ02]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[ispASNFZ02]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***************************************************************************/
/* Stored Procedure: ispASNFZ02                                            */
/* Creation Date: 27-JUN-2014                                              */
/* Copyright: IDS                                                          */
/* Written by:                                                             */
/*                                                                         */
/* Purpose: SOS#314477-Stamp Receiptdetail.Userefine02 to UCC.Userdefined02*/
/*                                                                         */
/* Called By:                                                              */
/*                                                                         */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/***************************************************************************/

CREATE PROC [dbo].[ispASNFZ02]
(     @c_Receiptkey  NVARCHAR(10)
  ,   @b_Success     INT           OUTPUT
  ,   @n_Err         INT           OUTPUT
  ,   @c_ErrMsg      NVARCHAR(255) OUTPUT
  ,   @c_ReceiptLineNumber NVARCHAR(5)=''
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue INT,
           @n_StartTranCount INT,
           @n_LineNo INT

   SELECT @b_Success=1, @n_Err=0, @c_ErrMsg='', @n_Continue = 1, @n_StartTranCount=@@TRANCOUNT

   SELECT DISTINCT ISNULL(UCC.UCCNo, UCCPO.UCCNo) AS UCCNO,
          CASE WHEN ISNULL(UCC.UCCNo,'') <> '' THEN 'ASN' ELSE 'PO' END AS SourceType,
          CASE WHEN ISNULL(UCC.UCCNo,'') <> '' THEN RECEIPTDETAIL.ReceiptKey+RECEIPTDETAIL.ReceiptLineNumber ELSE
               PODETAIL.POKey + PODETAIL.PoLinenUmber END AS Sourcekey,
          RECEIPTDETAIL.Storerkey,
          RECEIPTDETAIL.Sku,
          RECEIPTDETAIL.Userdefine02
   INTO #TMP_UCC
   FROM RECEIPT WITH (NOLOCK)
   JOIN RECEIPTDETAIL WITH (NOLOCK) ON ( RECEIPT.ReceiptKey = RECEIPTDETAIL.ReceiptKey )
   LEFT JOIN UCC      WITH (NOLOCK) ON ( RECEIPTDETAIL.ReceiptKey = SUBSTRING(UCC.SourceKey,1,10) AND UCC.Sourcetype = 'ASN' )
                                                               AND( RECEIPTDETAIL.ReceiptLineNumber = SUBSTRING(UCC.SourceKey,11,5))
   LEFT JOIN PODETAIL WITH (NOLOCK) ON ( RECEIPTDETAIL.POKEy = PODETAIL.POKey )
                                    AND( RECEIPTDETAIL.ExternLineNo = PODETAIL.PoLinenUmber)
   LEFT JOIN UCC  UCCPO WITH (NOLOCK) ON ( PODETAIL.ExternPOKEy = UCCPO.ExternKey )
                                    AND( UCCPO.Sourcekey = PODETAIL.POKey + PODETAIL.PoLinenUmber)
                                    AND( UCCPO.Sourcetype = 'PO')
   WHERE RECEIPT.Receiptkey = @c_Receiptkey
   AND RECEIPTDETAIL.ReceiptLineNumber = CASE WHEN ISNULL(@c_ReceiptLineNumber,'') <> '' THEN @c_ReceiptLineNumber ELSE RECEIPTDETAIL.ReceiptLineNumber END

   UPDATE UCC WITH (ROWLOCK)
   SET UCC.Userdefined02 = T.Userdefine02
   FROM UCC
   JOIN #TMP_UCC T ON UCC.UCCNo = T.UCCNo AND UCC.Sourcetype = T.SourceType AND UCC.SourceKey = T.Sourcekey
                      AND UCC.Storerkey = T.Storerkey AND UCC.Sku = T.Sku
   AND ISNULL(T.UCCNo,'') <> ''

   SELECT @n_err = @@ERROR
   IF  @n_err <> 0
   BEGIN
      SELECT @n_continue = 3
      SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 63504
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update UCC Failed! (ispASNFZ02)' + ' ( '
                             + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
      GOTO QUIT_SP
   END

   QUIT_SP:
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTranCount
      BEGIN
         ROLLBACK TRAN
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ispASNFZ02'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTranCount
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO
GRANT EXECUTE ON [dbo].[ispASNFZ02] TO nSQL 
GO
