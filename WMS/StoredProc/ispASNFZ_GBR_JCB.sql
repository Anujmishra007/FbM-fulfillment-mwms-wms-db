
/****** Object:  StoredProcedure [dbo].[ispASNFZ_GBR_JCB]    Script Date: 7/10/2025 2:28:09 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*************************************************************************************/
/* Store procedure: ispASNFZ_GBR_JCB                                                 */
/* Copyright      : Maersk                                                           */
/* Customer       : JCB                                                              */
/*                                                                                   */
/*                                                                                   */
/* Date         Rev   Author   Purposes                                              */
/* 09/07/2025   1.0   PPA374   Updating pallet ID for the inventory at finalisation  */
/*************************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[ispASNFZ_GBR_JCB]
   @c_ReceiptKey         NVARCHAR(10),
   @c_ReceiptLineNumber  NVARCHAR(10),
   @b_Success            INT OUTPUT,
   @n_Err                INT OUTPUT,
   @c_ErrMsg             NVARCHAR(250) OUTPUT

AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   UPDATE ID
   SET ID.PalletType = RD.PalletType
   FROM dbo.ID WITH(NOLOCK)
      INNER JOIN dbo.RECEIPTDETAIL RD WITH(NOLOCK)
         ON ID.Id = RD.ToId
   WHERE ReceiptKey = @c_ReceiptKey
      AND ToID <> ''
END
