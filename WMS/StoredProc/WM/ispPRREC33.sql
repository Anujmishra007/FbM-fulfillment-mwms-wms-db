SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Trigger:  ispPRREC33                                    */
/* Creation Date: 29-May-2024                                           */
/* Copyright: Maersk                                                       */
/* Written by: Shreekanth                                               */
/*                                                                      */
/* Purpose:  Calculate Shelf life to update Lottable06 & Lottable07     */
/*        for Damaged and Expired                                       */
/*                                                                      */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[ispPRREC33]
(     @c_Receiptkey  NVARCHAR(10)
  ,   @c_ReceiptLineNumber  NVARCHAR(5) = ''
  ,   @b_Success     INT           OUTPUT
  ,   @n_Err         INT           OUTPUT
  ,   @c_ErrMsg      NVARCHAR(255) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

SELECT @c_Lottable12Value = Lottable12, @c_Storerkey = StorerKey, @dt_ExpirationDate = Lottable04
                    FROM RECEIPTDETAIL WITH (NOLOCK)
                    WHERE ReceiptKey = c_Receiptkey AND
                          ReceiptLineNumber = c_Receiptlinenumber

IF EXISTS (SELECT TOP 1 * FROM CODELKUP WITH (NOLOCK) WHERE LISTNAME = 'ASNREASON'
                    AND Code = c_Lottable12Value)
    BEGIN
        SELECT @c_DamagedCode = Code FROM CODELKUP WHERE storerkey = c_Storerkey
                                                            AND UDF01 = 'RMPM_Damaged' AND LISTNAME = 'SLCode';
        UPDATE RECEIPTDETAIL WITH (ROWLOCK) SET [LOTTABLE07] = c_DamagedCode, [LOTTABLE06] = 1,
                                WHERE ReceiptKey = c_Receiptkey AND
                                    StorerKey = c_Storerkey AND
                                    ReceiptLineNumber = c_Receiptlinenumber;
    END

ELSE IF DATEDIFF(DAY, @dt_ExpirationDate, GETDATE()) <= 0
    BEGIN
        SELECT @c_ExpiredCode = Code FROM CODELKUP WHERE storerkey = c_Storerkey
                                                            AND UDF01 = 'RMPM_Expired' AND LISTNAME = 'SLCode';
        UPDATE RECEIPTDETAIL WITH (ROWLOCK) SET [LOTTABLE07] = c_ExpiredCode, [LOTTABLE06] = 1,
                                WHERE ReceiptKey = c_Receiptkey AND
                                    StorerKey = c_Storerkey AND
                                    ReceiptLineNumber = c_Receiptlinenumber;
    END

END -- End Procedure
GO
GRANT EXECUTE ON  ispPRREC33 TO NSQL
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
