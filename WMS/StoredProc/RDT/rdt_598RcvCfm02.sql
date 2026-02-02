SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_598RcvCfm02                                           */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: Receive across multiple ASN                                       */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2021-06-24 1.0  Chermaine  WMS-17244 Created                               */
/* 2022-07-19 1.1  Ung        WMS-20246 Change V_String40 to 41               */
/* 2023-09-22 1.2  Ung        WMS-23533 Add SKU                               */
/* 2025-07-14 1.3  YeeKung    FCR-5719  Add new params                        */
/******************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_598RcvCfm02 (
   @nFunc          INT,
   @nMobile        INT,
   @cLangCode      NVARCHAR( 3),
   @cStorerKey     NVARCHAR( 15),
   @cFacility      NVARCHAR( 5),
   @cRefNo         NVARCHAR( 20),
   @cColumnName    NVARCHAR( 20),
   @cToLOC         NVARCHAR( 10),
   @cToID          NVARCHAR( 18), -- Blank = receive to blank ToID
   @cSKUCode       NVARCHAR( 20), -- SKU code. Not SKU barcode
   @cSKUUOM        NVARCHAR( 10),
   @nSKUQTY        INT,           -- In master unit
   @cUCC           NVARCHAR( 20),
   @cUCCSKU        NVARCHAR( 20),
   @nUCCQTY        INT,           -- In master unit. Pass in the QTY for UCCWithDynamicCaseCNT
   @cCreateUCC     NVARCHAR( 1),  -- Create UCC. 1=Yes, the rest=No
   @cLottable01    NVARCHAR( 18),
   @cLottable02    NVARCHAR( 18),
   @cLottable03    NVARCHAR( 18),
   @dLottable04    DATETIME,
   @dLottable05    DATETIME,
   @cLottable06    NVARCHAR( 30),
   @cLottable07    NVARCHAR( 30),
   @cLottable08    NVARCHAR( 30),
   @cLottable09    NVARCHAR( 30),
   @cLottable10    NVARCHAR( 30),
   @cLottable11    NVARCHAR( 30),
   @cLottable12    NVARCHAR( 30),
   @dLottable13    DATETIME,
   @dLottable14    DATETIME,
   @dLottable15    DATETIME,
   @nNOPOFlag      INT,
   @cConditionCode NVARCHAR( 10),
   @cSubreasonCode NVARCHAR( 10),
   @nErrNo         INT                    OUTPUT,
   @cErrMsg        NVARCHAR( 20)          OUTPUT,
   @cReceiptKeyOutput NVARCHAR( 10)       OUTPUT,
   @cReceiptLineNumberOutput NVARCHAR( 5) OUTPUT,
   @cSerialNo      NVARCHAR( 30) = '',     
   @nSerialQTY     INT = 0,     
   @nBulkSNO       INT = 0,     
   @nBulkSNOQTY    INT = 0,  
   @cDebug         NVARCHAR( 1) = '0'
) AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE @cReceiptKey NVARCHAR(10)
DECLARE @nUcc_QTY    INT
DECLARE @nRD_Qty     INT
DECLARE @cBusr7      NVARCHAR(30)
DECLARE @cItemClass  NVARCHAR(10)
DECLARE @cSKU        NVARCHAR(20)

SET @cConditionCode = 'OK'

SELECT @cUCC = V_String41 FROM rdt.RDTMOBREC (NOLOCK) WHERE Mobile = @nMobile

-- Handling transaction
DECLARE @nTranCount INT
SET @nTranCount = @@TRANCOUNT
BEGIN TRAN  -- Begin our own transaction
SAVE TRAN rdt_598RcvCfm02 -- For rollback or commit only our own transaction

-- Receive by UCC
IF EXISTS( SELECT TOP 1 1 FROM dbo.UCC WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND UCCNo = @cUCC)
BEGIN
   SELECT top 1
      @cItemClass = s.ItemClass,
      @cBusr7 = S.Busr7
   FROM UCC u WITH (NOLOCK)
   JOIN Receipt R WITH (NOLOCK) ON (R.externreceiptkey = U.ExternKey AND R.StorerKey = U.Storerkey)
   Join ReceiptDetail RD WITH (nolock) on (R.ReceiptKey = RD.ReceiptKey and R.StorerKey = RD.StorerKey and RD.SKU = U.SKU)
   JOIN SKU S WITH (nolock) on (S.SKU = U.SKU and S.StorerKey = U.StorerKey)
   WHERE R.UserDefine04 = @cRefNo
   AND R.StorerKey = @cStorerKey
   AND U.UccNo = @cUCC
   AND R.ASNStatus <> 'CANC'

   SELECT
      @cLottable02 = UDF03
   FROM dbo.Codelkup WITH (NOLOCK)
   WHERE ListName = 'SKUGROUP'
   AND Storerkey = @cStorerKey
   AND Code = @cBusr7

   DECLARE @curReceipt CURSOR
   SET @curReceipt = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
       SELECT
         RD.ReceiptKey,
         U.Qty,
         S.SKU,
         P.PackUOM3,
         ISNULL( SUM( QTYExpected-BeforeReceivedQTY), 0)
      FROM UCC u WITH (NOLOCK)
      JOIN Receipt R WITH (NOLOCK) ON (R.externreceiptkey = U.ExternKey AND R.StorerKey = U.Storerkey)
      Join ReceiptDetail RD WITH (nolock) on (R.ReceiptKey = RD.ReceiptKey and R.StorerKey = RD.StorerKey and RD.SKU = U.SKU)
      JOIN SKU S WITH (nolock) on (S.SKU = U.SKU and S.StorerKey = U.StorerKey)
      JOIN dbo.Pack P WITH (NOLOCK) ON (S.PackKey = P.PackKey)
      WHERE R.UserDefine04 = @cRefNo
      AND R.StorerKey = @cStorerKey
      AND U.UccNo = @cUCC
      AND R.ASNStatus <> 'CANC'
      GROUP BY RD.ReceiptKey,U.Qty,S.SKU,P.PackUOM3
   OPEN @curReceipt
   FETCH NEXT FROM @curReceipt INTO @cReceiptKey, @nUcc_QTY, @cSKU, @cSKUUOM, @nRD_Qty
   WHILE @@FETCH_STATUS = 0
   BEGIN
      IF @nRD_Qty > 0
      BEGIN
         IF @nUcc_QTY < @nRD_Qty
            SET @nRD_Qty = @nUcc_QTY

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
            @cSKUCode      = '',--@cSKU,
            @cSKUUOM       = @cSKUUOM,
            @nSKUQTY       = '',--@nRD_Qty,
            @cUCC          = @cUCC,
            @cUCCSKU       = @cSKU,--'',
            @nUCCQTY       = @nUcc_QTY,--'',
            @cCreateUCC    = '',
            @cLottable01   = @cLottable01,
            @cLottable02   = @cLottable02,
            @cLottable03   = @cLottable03,
            @dLottable04   = @dLottable04,
            @dLottable05   = NULL,
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
            @cConditionCode = @cConditionCode,
            @cSubreasonCode = '',
            @cReceiptLineNumberOutput = @cReceiptLineNumberOutput OUTPUT
         IF @nErrNo <> 0
            GOTO RollBackTran

         SET @cReceiptKeyOutput = @cReceiptKey
         SET @nUcc_QTY = @nUcc_QTY - @nRD_Qty
         --IF @nUcc_QTY = 0
         --   BREAK
      END
      FETCH NEXT FROM @curReceipt INTO @cReceiptKey, @nUcc_QTY, @cSKU, @cSKUUOM, @nRD_Qty
   END
END

-- Receive by SKU
ELSE
BEGIN
   SELECT @cBusr7 = Busr7 
   FROM dbo.SKU WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND SKU = @cSKUCode

   SELECT @cLottable02 = UDF03
   FROM dbo.Codelkup WITH (NOLOCK)
   WHERE ListName = 'SKUGROUP'
      AND Storerkey = @cStorerKey
      AND Code = @cBusr7
   
   SELECT TOP 1 
      @cReceiptKey = CRL.ReceiptKey 
   FROM dbo.ReceiptDetail RD WITH (NOLOCK)
      JOIN rdt.rdtConReceiveLog CRL WITH (NOLOCK) ON (RD.ReceiptKey = CRL.ReceiptKey)
   WHERE Mobile = @nMobile
      AND RD.StorerKey = @cStorerKey
      AND RD.SKU = @cSKUCode
      AND RD.QTYExpected > RD.BeforeReceivedQTY
   ORDER BY CRL.ReceiptKey

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
      @cSKUCode      = @cSKUCode,
      @cSKUUOM       = @cSKUUOM,
      @nSKUQTY       = 1,
      @cUCC          = '',
      @cUCCSKU       = '',
      @nUCCQTY       = '',
      @cCreateUCC    = '',
      @cLottable01   = @cLottable01,
      @cLottable02   = @cLottable02,
      @cLottable03   = @cLottable03,
      @dLottable04   = @dLottable04,
      @dLottable05   = NULL,
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
      @cConditionCode = @cConditionCode,
      @cSubreasonCode = @cSubreasonCode,
      @cReceiptLineNumberOutput = @cReceiptLineNumberOutput OUTPUT
   IF @nErrNo <> 0
      GOTO RollBackTran

   SET @cReceiptKeyOutput = @cReceiptKey
END

COMMIT TRAN rdt_598RcvCfm02
GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_598RcvCfm02
Fail:
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXEC ON RDT.rdt_598RcvCfm02 TO NSQL
GO
