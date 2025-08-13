SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_605RcvCfm02                                     */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2025-06-18 1.0  Cuize      FCR-4200 Created                          */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_605RcvCfm02] (
   @nFunc        INT,            
   @nMobile      INT,            
   @cLangCode    NVARCHAR( 3),   
   @cStorerKey   NVARCHAR( 15),  
   @cFacility    NVARCHAR( 5),   
   @cReceiptKey  NVARCHAR( 10),  
   @cToID        NVARCHAR( 18),
   @cToLOC       NVARCHAR( 10),
   @nErrNo       INT           OUTPUT,
   @cErrMsg      NVARCHAR( 20) OUTPUT  
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cSKU         NVARCHAR( 20)
   DECLARE @cUOM         NVARCHAR( 10)  
   DECLARE @cUCCNo       NVARCHAR( 20)
   DECLARE @nQTY         INT
   DECLARE @cLottable01  NVARCHAR( 18)  
   DECLARE @cLottable02  NVARCHAR( 18)  
   DECLARE @cLottable03  NVARCHAR( 18)  
   DECLARE @dLottable04  DATETIME  
   DECLARE @dLottable05  DATETIME  
   DECLARE @cLottable06  NVARCHAR( 30)  
   DECLARE @cLottable07  NVARCHAR( 30)  
   DECLARE @cLottable08  NVARCHAR( 30)  
   DECLARE @cLottable09  NVARCHAR( 30)  
   DECLARE @cLottable10  NVARCHAR( 30)  
   DECLARE @cLottable11  NVARCHAR( 30)  
   DECLARE @cLottable12  NVARCHAR( 30)  
   DECLARE @dLottable13  DATETIME  
   DECLARE @dLottable14  DATETIME  
   DECLARE @dLottable15  DATETIME  
   DECLARE @cReceiptLineNumberOutput NVARCHAR( 5)

    -- Handling transaction  
   DECLARE @nTranCount INT  
   SET @nTranCount = @@TRANCOUNT  
   BEGIN TRAN  -- Begin our own transaction  
   SAVE TRAN rdt_605RcvCfm02 -- For rollback or commit only our own transaction
     
   DECLARE @curUCC CURSOR
   SET @curUCC = CURSOR FOR
      SELECT
         U.UCCNo, U.qty, U.SKU,
         MAX(PD.Lottable01), MAX(PD.Lottable02), MAX(PD.Lottable03), MAX(PD.Lottable04), MAX(PD.Lottable05),
         MAX(PD.Lottable06), MAX(PD.Lottable07), MAX(PD.Lottable08), MAX(PD.Lottable09), MAX(PD.Lottable10),
         MAX(PD.Lottable11), MAX(PD.Lottable12), MAX(PD.Lottable13), MAX(PD.Lottable14), MAX(PD.Lottable15)
      FROM dbo.UCC U WITH (NOLOCK)
         JOIN RECEIPTDETAIL PD WITH (NOLOCK) ON
            (PD.externreceiptkey = U.externkey AND PD.SKU = U.SKU)
      WHERE PD.ReceiptKey = @cReceiptKey
         AND U.ID = @cToID
         AND U.storerKey = @cStorerKey
         AND U.Status = 0
      GROUP BY U.UCCNo, U.qty, U.SKU
   OPEN @curUCC
   FETCH NEXT FROM @curUCC INTO @cUCCNo, @nQTY, @cSKU,
      @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
      @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
      @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15

   WHILE @@FETCH_STATUS = 0
   BEGIN
      -- Get SKU info
      SELECT @cUOM = Pack.PackUOM3
      FROM SKU WITH (NOLOCK)
              JOIN Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)
      WHERE StorerKey = @cStorerKey
        AND SKU = @cSKU

      EXEC rdt.rdt_Receive_V7 --UCC Receive
         @nFunc         = @nFunc,
         @nMobile       = @nMobile,
         @cLangCode     = @cLangCode,
         @nErrNo        = @nErrNo OUTPUT,
         @cErrMsg       = @cErrMsg OUTPUT,
         @cStorerKey    = @cStorerKey,
         @cFacility     = @cFacility,
         @cReceiptKey   = @cReceiptKey,
         @cPOKey        = 'NOPO',
         @cToLOC        = @cToLOC,
         @cToID         = @cToID,
         @cSKUCode      = '',
         @cSKUUOM       = @cUOM,
         @nSKUQTY       = @nQTY,
         @cUCC          = @cUccNo,
         @cUCCSKU       = @cSKU,
         @nUCCQTY       = @nQTY,
         @cCreateUCC    = '',
         @cLottable01   = @cLottable01,
         @cLottable02   = @cLottable02,
         @cLottable03   = @cLottable03,
         @dLottable04   = @dLottable04,
         @dLottable05   = @dLottable05,
         @cLottable06   = @cLottable06,
         @cLottable07   = @cLottable07,
         @cLottable08   = @cLottable08,
         @cLottable09   = @cLottable09,
         @cLottable10   = @cLottable10,
         @cLottable11   = @cLottable11,
         @cLottable12   = @cLottable12,
         @dLottable13   = @dLottable13,
         @dLottable14   = @dLottable14,
         @dLottable15   = @dLottable15,
         @nNOPOFlag     = 1,
         @cConditionCode = 'OK',
         @cSubreasonCode = '',
         @cReceiptLineNumberOutput = @cReceiptLineNumberOutput OUTPUT

      IF @nErrNo <> 0  
         GOTO RollBackTran
              
      FETCH NEXT FROM @curUCC INTO @cUCCNo, @nQTY, @cSKU,
         @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
         @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
         @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15
   END  

   GOTO Quit  
END
  
RollBackTran:    
   ROLLBACK TRAN rdt_605RcvCfm02
Fail:    
Quit:    
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started    
      COMMIT TRAN  
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_605RcvCfm02 to nSQL
GO
