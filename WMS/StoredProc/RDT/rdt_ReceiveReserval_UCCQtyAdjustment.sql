if exists (select * from dbo.sysobjects where id = object_id(N'[rdt].[rdt_ReceiveReserval_UCCQtyAdjustment]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [rdt].[rdt_ReceiveReserval_UCCQtyAdjustment]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


/************************************************************************/
/* Store procedure: rdt_ReceiveReserval_UCCQtyAdjustment                */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purposes:                                                            */
/* 1) Update UCC QTY and RECEIPTDETAIL QTY                              */
/*                                                                      */
/* Called from: 3                                                       */
/*    1. From PowerBuilder                                              */
/*    2. From scheduler                                                 */
/*    3. From others stored procedures or triggers                      */
/*    4. From interface program. DX, DTS                                */
/*                                                                      */
/* Exceed version: 5.4                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/************************************************************************/

CREATE PROC rdt.rdt_ReceiveReserval_UCCQtyAdjustment (
   @cReceiptKey    NVARCHAR(10),
   @cLOC           NVARCHAR(10),
   @cID            NVARCHAR(18),
   @cUCC           NVARCHAR(20),
   @cStorerkey     NVARCHAR(15),
   @cQTY           NVARCHAR(4),
   @cNewQty        NVARCHAR(4),
   @cReceiptLineNo NVARCHAR(5),
   @nError         INT      OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_debug          INT   

   
   SET @n_debug = 0
   SET @nError = 0

   BEGIN TRAN

      UPDATE dbo.UCC WITH (ROWLOCK)
         SET QTY = CAST(@cNewQty AS INT)
      WHERE Storerkey = @cStorerkey 
       AND  ReceiptKey = @cReceiptKey 
       AND  ReceiptLineNumber = @cReceiptLineNo 
       AND  UCCNo = @cUCC 
       AND  Status = '1'

   IF @@ERROR = 0 
   BEGIN
      COMMIT TRAN
   END 
   ELSE
   BEGIN
      ROLLBACK TRAN
      SELECT @nError = 1
      GOTO QUIT
   END              

   BEGIN TRAN

      UPDATE dbo.RECEIPTDETAIL WITH (ROWLOCK)
         SET BeforeReceivedQty = (BeforeReceivedQty - CAST(@cQTY AS INT)) + CAST(@cNewQty AS INT),
             Trafficcop = NULL
      WHERE Storerkey = @cStorerkey 
       AND  ReceiptKey = @cReceiptKey 
       AND  ReceiptLineNumber = @cReceiptLineNo 

   IF @@ERROR = 0 
   BEGIN
      COMMIT TRAN
   END 
   ELSE
   BEGIN
      ROLLBACK TRAN
      SELECT @nError = 1

      UPDATE dbo.UCC WITH (ROWLOCK)
         SET QTY = CAST(@cQTY AS INT)
      WHERE Storerkey = @cStorerkey 
       AND  ReceiptKey = @cReceiptKey 
       AND  ReceiptLineNumber = @cReceiptLineNo 
       AND  UCCNo = @cUCC 
       AND  Status = '1'

      GOTO QUIT
   END                     


QUIT:
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

