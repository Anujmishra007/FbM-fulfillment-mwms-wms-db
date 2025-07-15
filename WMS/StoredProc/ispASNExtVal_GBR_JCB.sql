
/****** Object:  StoredProcedure [dbo].[ispASNExtVal_GBR_JCB]    Script Date: 7/10/2025 1:56:46 PM ******/
SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
GO
/**************************************************************************/
/* Store procedure: [ispASNExtVal_GBR_JCB]                                */
/* Copyright: Maersk                                                      */
/*                                                                        */
/* Date         Rev   Author     Purposes                                 */
/* 2024-09-04   1.0   PPA374     SP Created - JCB Finalisation Validation */
/**************************************************************************/
CREATE OR ALTER PROC [dbo].[ispASNExtVal_GBR_JCB]  (
   @c_ReceiptKey NVARCHAR(10), 
   @b_Success Int = 1 OUTPUT, 
   @n_ErrNo Int OUTPUT, 
   @c_ErrMsg NVARCHAR(250) OUTPUT,
   @c_ReceiptLineNumber NVARCHAR(5)
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cShortReceipt AS NVARCHAR(1)

   SELECT TOP 1
      @cShortReceipt = IIF(TRIM(Notes) = '', 'N', 'Y')
   FROM dbo.ReceiptInfo WITH(NOLOCK)
   WHERE ReceiptKey = @c_ReceiptKey

   SET @n_ErrNo = 0
   SET @c_ErrMsg = ''
   SET @b_Success = 1

   IF (
      SELECT ISNULL(SUM(QtyExpected), 0) 
             - ISNULL(SUM(BeforeReceivedQty), 0)
      FROM dbo.RECEIPTDETAIL WITH(NOLOCK)
      WHERE ReceiptKey = @c_ReceiptKey
         AND StorerKey = 'JCB'
   ) <> 0 AND TRIM(@cShortReceipt) = 'N' 
   BEGIN
      SET @n_ErrNo = 1
      SET @c_ErrMsg = 'You are about to receive short, please add the reason into Receipt Info -> ReceiptInfo Notes 1'
      SET @b_Success = 0
      GOTO QUIT
   END

   UPDATE RD
   SET RD.PalletType = P.PalletType
   FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK)
      INNER JOIN dbo.PALLET P WITH(NOLOCK)
         ON RD.ToId = P.PalletKey
   WHERE ReceiptKey = @c_ReceiptKey

   QUIT:
END
