
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: dbo.isp_UCC_WCS_ONBR                                   */
/* Copyright      : Maersk                                                 */
/*                                                                         */
/* Purpose: UCC Receive for WCS                                            */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date       Rev  Author  Purposes                                        */
/* 2025-08-29 1.0  ELB02   UWP-45373 Created                               */
/***************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_UCC_WCS_ONBR](
   @c_ReceiptKey           NVARCHAR(10),
   @c_ReceiptLineNumber    NVARCHAR(5),   
   @c_ID                   NVARCHAR(20), -- WCS will return ID = UC, but ID has limitation of 18 chars and UCC 20, so ID = ReceiptKey + LineNumber
   @c_SKU                  NVARCHAR(20),
   @n_QTY                  INT,
   @c_UCCno                NVARCHAR(20),
   @c_StorerKey            NVARCHAR(15),
   @n_UCCStatus            INT, 
   @c_Lottable02           NVARCHAR(10),
   @c_ExternKey            NVARCHAR(12),
   @n_Success              INT OUTPUT,
   @n_err                  INT OUTPUT,
   @c_ErrMsg               NVARCHAR(250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_TranCount    INT = @@TRANCOUNT
   DECLARE @n_ErrNo        INT
   DECLARE @n_ValidDet     INT
   DECLARE @c_Lot          NVARCHAR(10)
   DECLARE @n_ValidUCC     INT
   DECLARE @c_ToLoc        NVARCHAR(10) 
   DECLARE @c_DocType      NVARCHAR(1)
   DECLARE @c_FzldFlag     NVARCHAR(1)
   DECLARE @c_ValidUccLot  NVARCHAR(10)

   -- Check DocType
   SELECT TOP 1 @c_DocType = DOCTYPE 
   FROM DBO.RECEIPT 
   WHERE ReceiptKey = @c_ReceiptKey 
   AND StorerKey = @c_StorerKey

   IF ISNULL(@c_DocType, '') <> 'A'
   BEGIN
      RETURN --No need error message, return should not run.
   END

   BEGIN TRY
      IF @n_TranCount = 0
         BEGIN TRAN isp_UCC_WCS_ONBR
      ELSE
         SAVE TRAN isp_UCC_WCS_ONBR

      -- Check UCC
      SELECT @n_ValidUCC = COUNT(*)
      FROM DBO.UCC WITH(NOLOCK)
      WHERE UCCNo = @c_UCCno
         AND SKU = @c_SKU
         AND StorerKey = @c_StorerKey

      IF ISNULL(@n_ValidUCC, 0) > 0
      BEGIN
         SET @n_err  = 60326
         SET @c_ErrMsg = rdt.rdtgetmessage(@n_err, 'ENG', 'DSP') -- UCC Exist
         ;THROW 50000, @c_ErrMsg, 1
      END

      -- Check toLoc
      SELECT TOP 1 @c_ToLoc = ToLoc 
      FROM DBO.RECEIPTDETAIL WITH(NOLOCK)
      WHERE ReceiptKey = @c_ReceiptKey 
         AND ReceiptLineNumber = @c_ReceiptLineNumber
         AND StorerKey = @c_StorerKey

      IF ISNULL(@c_ToLoc, '') = ''
      BEGIN
         SET @n_err  = 50008
         SET @c_ErrMsg = rdt.rdtgetmessage(@n_err, 'ENG', 'DSP') -- Loc Not Found.
         ;THROW 50000, @c_ErrMsg, 1
      END

      -- WCS must return 100% of the qty
      SELECT @n_ValidDet = 1
      FROM DBO.RECEIPTDETAIL AS RCPD WITH (NOLOCK)
      JOIN DBO.RECEIPT AS RCP WITH (NOLOCK)
         ON RCP.ReceiptKey = RCPD.ReceiptKey
         AND RCP.StorerKey = RCPD.StorerKey
      WHERE RCPD.ReceiptKey        = @c_ReceiptKey
         AND RCPD.ReceiptLineNumber = @c_ReceiptLineNumber
         AND RCPD.UserDefine01      = @c_UCCno
         AND RCPD.QtyExpected       = @n_QTY
         AND RCPD.SKU               = @c_SKU
         AND RCPD.FinalizeFlag      = 'N'
         AND RCP.Status             < 9
         AND RCP.ASNStatus          < 9

      IF ISNULL(@n_ValidDet, 0) = 0
      BEGIN
         SET @n_err  = 50852
         SET @c_ErrMsg = rdt.rdtgetmessage(@n_err, 'ENG', 'DSP') -- ASN Not exist or finalized.
         ;THROW 50000, @c_ErrMsg, 1
      END
               --ID has limitation of 18 chars and UCC 20, so ID = ReceiptKey + LineNumber
      SET @c_ID = @c_ReceiptKey + '-' + @c_ReceiptLineNumber

      -- Upd RECEIPTDETAIL
      UPDATE RECEIPTDETAIL WITH(ROWLOCK)
      SET QtyReceived  = @n_QTY,
         FinalizeFlag = 'Y',
         ToId         = @c_ID,
         Lottable02   = @c_Lottable02
      WHERE ReceiptKey        = @c_ReceiptKey
         AND ReceiptLineNumber = @c_ReceiptLineNumber
         AND StorerKey         = @c_StorerKey

      IF @@ERROR <> 0
      BEGIN    
         SET @n_err = 63361  
         SET @c_ErrMsg = rdt.rdtgetmessage(@n_err, 'ENG', 'DSP')  -- Upd Fail  
      END   

      -- Confirm Receiving
      EXEC dbo.ispFinalizeReceipt
            @c_ReceiptKey,
            @n_Success   OUTPUT,
            @n_err       OUTPUT,
            @c_ErrMsg    OUTPUT,
            @c_ReceiptLineNumber

      -- Check Lot
      SELECT @c_Lot = LOT
      FROM dbo.LOTxLOCxID WITH(NOLOCK)
      WHERE LOC = @c_ToLoc
         AND ID  = @c_ID
         AND SKU = @c_SKU
         AND QTY = @n_QTY

      IF ISNULL(@c_Lot, '') = ''
      BEGIN
         SET @n_err  = 68516
         SET @c_ErrMsg = rdt.rdtgetmessage(@n_err, 'ENG', 'DSP') -- Confirm Fail
         ;THROW 50001, @c_ErrMsg, 2
      END

      -- Double check , ispFinalizeReceipt wasnt updating receipt detail and inserting in UCC table.
      SELECT @n_ValidUCC = COUNT(*)
      FROM DBO.UCC WITH(NOLOCK)
      WHERE UCCNo = @c_UCCno
         AND SKU = @c_SKU
         AND StorerKey = @c_StorerKey
         AND ReceiptKey = @c_ReceiptKey
         AND ReceiptLineNumber = @c_ReceiptLineNumber

      IF ISNULL(@n_ValidUCC, 0) = 0
      BEGIN
         INSERT INTO dbo.UCC (UCCNo, StorerKey, LOC, LOT, SKU, ID, QTY, ReceiptKey, ReceiptLineNumber, ExternKey, Status)
         VALUES (@c_UCCno, @c_StorerKey, @c_ToLoc, @c_Lot, @c_SKU, @c_ID, @n_QTY, @c_ReceiptKey, @c_ReceiptLineNumber, @c_ExternKey, @n_UCCStatus)
      END

      -- Check UCC Lot
      SELECT @c_ValidUccLot = LOT
      FROM DBO.UCC WITH(NOLOCK)
      WHERE UCCNo = @c_UCCno
         AND SKU = @c_SKU
         AND StorerKey = @c_StorerKey
         AND ReceiptKey = @c_ReceiptKey
         AND ReceiptLineNumber = @c_ReceiptLineNumber

      IF ISNULL(@c_ValidUccLot, '') = ''
      BEGIN
         UPDATE UCC WITH(ROWLOCK)
            SET LOT = @c_Lot
         WHERE UCCNo = @c_UCCno
            AND SKU = @c_SKU
            AND QTY = @n_QTY
            AND ReceiptKey = @c_ReceiptKey
            AND ReceiptLineNumber = @c_ReceiptLineNumber
      END

      -- Commit da transação se foi iniciada aqui
      IF @n_TranCount = 0
         COMMIT TRAN
   END TRY
   BEGIN CATCH
      IF XACT_STATE() <> 0
      BEGIN
         IF @n_TranCount = 0
            ROLLBACK TRAN
         ELSE
            ROLLBACK TRAN isp_UCC_WCS_ONBR
      END

      SET @n_err    = ERROR_NUMBER()
      SET @c_ErrMsg = ERROR_MESSAGE()
      RETURN
   END CATCH
END
GO
GRANT EXECUTE ON [dbo].[isp_UCC_WCS_ONBR] TO nSQL 
GO