SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: rdt_598RcvCfm05                                           */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: Receive across multiple ASN                                       */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2025-07-09  1.0  YeeKung      FCR-5719 Created                             */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_598RcvCfm05] (
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
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cReceiptKey  NVARCHAR(10)
   DECLARE @nQTY_Bal     INT
   DECLARE @nQTY         INT
   DECLARE @cExternReceiptKey NVARCHAR( 20)
   DECLARE @nStep	     INT

   SELECT @nStep = Step
   FROM Rdt.RdtMobRec (NOLOCK)
   WHERE Mobile = @nMobile

   -- Copy QTY to process
   IF @nStep = 6 
      SET @nQTY_Bal = @nSKUQTY
   ELSE IF @nStep = 14
   BEGIN
      IF @nBulkSNO  = '1'
         SET @nQTY_Bal = @nBulkSNOQTY
      ELSE
         SET @nQTY_Bal = @nSerialQTY
   END

   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_598RcvCfm05 -- For rollback or commit only our own transaction


   IF OBJECT_ID('tempdb..#ExternReceiptKey') IS NOT NULL  
         DROP TABLE #ExternReceiptKey  
      CREATE TABLE #ExternReceiptKey  (  
         ExternReceiptKey     NVARCHAR( 10))  



   INSERT INTO #ExternReceiptKey (ExternReceiptKey)
      SELECT  SN.Userdefine01 
      FROM rdt.rdtReceiveSerialNoLog RSL WITH (NOLOCK) 
      JOIN SerialNo SN WITH (NOLOCK) ON (RSL.SerialNo =SN.SerialNo  AND RSL.StorerKey = SN.StorerKey )
      WHERE  RSL.StorerKey = @cStorerKey
         AND SN.SKU = @cSKUCode
         AND RSL.Mobile =  @nMobile
   group by SN.Userdefine01 


   IF EXISTS ( SELECT 1
            FROM Receipt R WITH (NOLOCK) 
               JOIN rdt.rdtConReceiveLog CRL WITH (NOLOCK) ON (R.ReceiptKey = CRL.ReceiptKey)
               JOIN #ExternReceiptKey ERK WITH (NOLOCK) ON (ERK.ExternReceiptKey =R.ExternReceiptKey )
            WHERE CRL.Mobile = @nMobile
               AND RD.StorerKey = @cStorerKey
               AND ASNStatus = '0'
               )
   BEGIN
      UPDATE R
         SET R.asnstatus = '1'  
      FROM Receipt R WITH (NOLOCK) 
         JOIN rdt.rdtConReceiveLog CRL WITH (NOLOCK) ON (R.ReceiptKey = CRL.ReceiptKey)
         JOIN #ExternReceiptKey ERK WITH (NOLOCK) ON (ERK.ExternReceiptKey =R.ExternReceiptKey )
      WHERE CRL.Mobile = @nMobile
         AND RD.StorerKey = @cStorerKey
         AND ASNStatus = '0'

      IF @@ERROR <> 0 
      BEGIN
         GOTO RollBackTran
      END
   END

   DECLARE @curReceipt CURSOR
   SET @curReceipt = CURSOR FOR
      SELECT CRL.ReceiptKey, ISNULL( SUM( QTYExpected-BeforeReceivedQTY), 0),RD.Lottable03
      FROM Receipt R WITH (NOLOCK) 
         JOIN dbo.ReceiptDetail RD WITH (NOLOCK) ON (R.ReceiptKey = RD.ReceiptKey)
         JOIN rdt.rdtConReceiveLog CRL WITH (NOLOCK) ON (RD.ReceiptKey = CRL.ReceiptKey)
         JOIN #ExternReceiptKey ERK WITH (NOLOCK) ON (ERK.ExternReceiptKey =R.ExternReceiptKey )
      WHERE CRL.Mobile = @nMobile
         AND RD.StorerKey = @cStorerKey
         AND RD.SKU = @cSKUCode
      GROUP BY CRL.ReceiptKey,RD.SKU,RD.Lottable03
      ORDER BY CRL.ReceiptKey
   OPEN @curReceipt
   FETCH NEXT FROM @curReceipt INTO @cReceiptKey, @nQTY,@cLottable03
   WHILE @@FETCH_STATUS = 0
   BEGIN
      IF @nQTY > 0
      BEGIN
         IF @nQTY_Bal < @nQTY
            SET @nQTY = @nQTY_Bal

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
            @nSKUQTY       = @nQTY,
            @cUCC          = '',
            @cUCCSKU       = '',
            @nUCCQTY       = '',
            @cCreateUCC    = '',
            @cLottable01   = @cLottable01,         -- ReceiptKey
            @cLottable02   = @cLottable02,   -- ExternReceiptKey
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
            @cReceiptLineNumberOutput = @cReceiptLineNumberOutput OUTPUT,
            @cSerialNo      = @cSerialNo,
            @nSerialQTY     = @nSerialQTY,
            @nBulkSNO       = @nBulkSNO,
            @nBulkSNOQTY    = @nBulkSNOQTY

         IF @nErrNo <> 0
            GOTO RollBackTran

         SET @cReceiptKeyOutput = @cReceiptKey
         SET @nQTY_Bal = @nQTY_Bal - @nQTY
         IF @nQTY_Bal = 0
            BREAK
      END
      FETCH NEXT FROM @curReceipt INTO @cReceiptKey, @nQTY,@cLottable03
   END

   -- If still have balance, means offset has error
   IF @nQTY_Bal <> 0
   BEGIN
      SET @nErrNo = 242201
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Offset error
      GOTO RollBackTran
   END

   IF EXISTS ( SELECT 1
               FROM ReceiptDetail (NOLOCK)
               WHERE ReceiptKey = Receiptkey
                  AND StorerKey = @cStorerkey
               HAVING SUM(BeforeReceivedQTY)= SUM(QTYExpected)
               )
   BEGIN
      UPDATE Receipt WITH (ROWLOCK) 
      SET ASNStatus ='X4'
      WHERE ReceiptKey = Receiptkey
         AND StorerKey = @cStorerkey
         AND ASNStatus  = '1'

      IF @@ERROR <> 0 
      BEGIN
         GOTO RollBackTran
      END
   END

   GOTO Quit

   RollBackTran:
      ROLLBACK TRAN rdt_598RcvCfm05
   Fail:
   Quit:
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
         COMMIT TRAN
END
GO
GRANT EXECUTE ON  [RDT].[rdt_598RcvCfm05] TO [NSQL]
GO
