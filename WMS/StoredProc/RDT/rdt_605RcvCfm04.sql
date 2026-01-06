SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_605RcvCfm04                                     */
/*                                                                      */
/* Customer:   Indonesia-MICHELIN                                       */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2026-01-04  1.0  Jackc       FCR-9251 Created                        */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_605RcvCfm04] (
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

   DECLARE @nDebugFlag   INT = 0

   DECLARE @cSKU         NVARCHAR( 20)
   DECLARE @cUOM         NVARCHAR( 10)
   DECLARE @nQTY         INT           -- In mast
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
   DECLARE @cReceiptLineNumber   NVARCHAR(5)
   DECLARE @cReceiptLineNumberOutput NVARCHAR( 5)
   DECLARE @cExternReceiptKey NVARCHAR(20)
   DECLARE @cDefaultToLoc  NVARCHAR( 10)
   DECLARE @nRowCount      INT
   DECLARE @nBulkSNO       INT = 0  
   DECLARE @nBulkSNOQTY    INT = 0

   SET @cDefaultToLoc = rdt.RDTGetConfig( @nFunc, 'DefaultToLoc', @cStorerKey)
   IF @cDefaultToLoc = '0'
      SET @cDefaultToLoc = ''

   IF @nDebugFlag = 1
      SELECT 'Executing 605RcvCfm04', @cReceiptKey AS ASN, @cToID AS ID

   IF NOT EXISTS (SELECT 1 FROM dbo.ReceiptDetail WITH (NOLOCK)
                  WHERE ReceiptKey = @cReceiptKey
                        AND ToID = @cToID
                        AND BeforeReceivedQTY = 0)
   BEGIN
      SET @nErrNo = 255353
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF EXISTS (SELECT 1 FROM dbo.ReceiptDetail WITH (NOLOCK)
                  WHERE ReceiptKey = @cReceiptKey
                        AND ToID = @cToID
                        AND FinalizeFlag = 'Y')
   BEGIN
      SET @nErrNo = 255354
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   --clear existing data
   DELETE rdt.rdtReceiveSerialNoLog WHERE Mobile = @nMobile AND Func = @nFunc AND StorerKey = @cStorerKey 

   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_605RcvCfm04 -- For rollback or commit only our own transaction

   DECLARE @curReceipt CURSOR
   SET @curReceipt = CURSOR FOR
      SELECT
         ReceiptLineNumber, ToLOC, SKU, QTYExpected,
         Lottable01, Lottable02, Lottable03, Lottable04, Lottable05,
         Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
         Lottable11, Lottable12, Lottable13, Lottable14, Lottable15
      FROM dbo.ReceiptDetail WITH (NOLOCK)
      WHERE ReceiptKey = @cReceiptKey
         AND ToID = @cToID
         AND BeforeReceivedQTY = 0
      ORDER BY ReceiptLineNumber
   OPEN @curReceipt
   FETCH NEXT FROM @curReceipt INTO @cReceiptLineNumber, @cToLOC, @cSKU, @nQTY,
      @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
      @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
      @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15

   WHILE @@FETCH_STATUS = 0
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Handling RcptDetail', @cToLOC AS ToLoc, @cSKU AS SKU, @nQTY AS Qty, @cLottable02 AS Lot02

      IF @cDefaultToLoc <> '' 
         SET @cToLOC = @cDefaultToLoc

      IF ISNULL(@cToLOC,'') = ''
      BEGIN
         SET @nErrNo = 255355
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
         GOTO Quit
      END

      --prepare serialNo log
      BEGIN TRY
         INSERT INTO rdt.rdtReceiveSerialNoLog (Mobile, Func, StorerKey, SKU, SerialNo, Qty)
         SELECT
            @nMobile,
            @nFunc,
            @cStorerKey,
            @cSKU,
            SerialNo,
            1
         FROM dbo.SerialNo SN WITH (NOLOCK)
         INNER JOIN dbo.ReceiptDetail RD WITH (NOLOCK)
            ON SN.StorerKey = RD.StorerKey
            AND SN.SKU = RD.SKU
            AND SN.UserDefine01 = RD.Lottable01
            AND SN.UserDefine02 = RD.ExternLineNo
         WHERE RD.ReceiptKey = @cReceiptKey
            AND RD.Storerkey = @cStorerKey
            AND RD.ReceiptLineNumber = @cReceiptLineNumber
            AND SN.Status = '0'

         SET @nROWCOUNT = @@ROWCOUNT
      END TRY
      BEGIN CATCH
         SET @nErrNo = 255351
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
         GOTO RollBackTran
      END CATCH

      IF @nRowCount = 0
      BEGIN
         SET @nErrNo = 255352
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
         GOTO RollBackTran
      END
      ELSE
      BEGIN
         SET @nBulkSNO = 1
         SET @nBulkSNOQTY = @nQTY
      END
   	
      -- Get SKU info
      SELECT @cUOM = Pack.PackUOM3
      FROM SKU WITH (NOLOCK)
         JOIN Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)
      WHERE StorerKey = @cStorerKey
         AND SKU = @cSKU

      EXEC rdt.rdt_Receive_V7
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
      @cSKUCode      = @cSKU,
      @cSKUUOM       = @cUOM,
      @nSKUQTY       = @nQTY,
      @cUCC          = '',
      @cUCCSKU       = '',
      @nUCCQTY       = '',
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
      @cReceiptLineNumberOutput = @cReceiptLineNumberOutput OUTPUT,
      @nBulkSNO       = @nBulkSNO,     
      @nBulkSNOQTY    = @nBulkSNOQTY

      IF @nErrNo <> 0
         GOTO RollBackTran

      IF @nDebugFlag = 1
         SELECT 'After confirm receiving', @cReceiptLineNumberOutput AS RctpLineNoOutput

      --delete sn log
      DELETE rdt.rdtReceiveSerialNoLog WHERE Mobile = @nMobile AND Func = @nFunc AND StorerKey = @cStorerKey

      FETCH NEXT FROM @curReceipt INTO @cReceiptLineNumber, @cToLOC, @cSKU, @nQTY,
         @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
         @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
         @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15
   END

   GOTO Quit
END

RollBackTran:
   ROLLBACK TRAN rdt_605RcvCfm04
Fail:
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
GO
GRANT EXECUTE ON  [RDT].[rdt_605RcvCfm04] TO [NSQL]
GO
