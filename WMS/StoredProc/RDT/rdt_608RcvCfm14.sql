SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: rdt_608RcvCfm14                                        */
/* Copyright      : LF Logistics                                           */
/*                                                                         */
/* Purpose: Default lottable06                                             */
/*                                                                         */
/* Date       Rev  Author  Purposes                                        */
/* 2023-02-01 1.0  yeekung   WMS-21552 Created                             */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_608RcvCfm14](
    @nFunc          INT,
    @nMobile        INT,
    @cLangCode      NVARCHAR( 3),
    @cStorerKey     NVARCHAR( 15),
    @cFacility      NVARCHAR( 5),
    @cReceiptKey    NVARCHAR( 10),
    @cPOKey         NVARCHAR( 10),
    @cToLOC         NVARCHAR( 10),
    @cToID          NVARCHAR( 18),
    @cSKUCode       NVARCHAR( 20),
    @cSKUUOM        NVARCHAR( 10),
    @nSKUQTY        INT,
    @cUCC           NVARCHAR( 20),
    @cUCCSKU        NVARCHAR( 20),
    @nUCCQTY        INT,
    @cCreateUCC     NVARCHAR( 1),
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
    @cRDLineNo      NVARCHAR( 5)  OUTPUT,
    @nErrNo         INT           OUTPUT,
    @cErrMsg        NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF ISNULL( @cToID, '') <> ''
   BEGIN
      SET @cLottable06 = CASE WHEN LEFT (@cTOID,2) ='TA' THEN 'ZP'
                           WHEN  LEFT (@cTOID,2)  IN ('TB','TC') THEN 'CC' END
   END

   SELECT TOP 1 
      @cLottable02   = @cLottable02
   FROM RECEIPTDETAIL (NOLOCK) 
   WHERE receiptkey=@cReceiptKey
      AND SKu= @cSKUCode
      AND storerkey=@cStorerKey
   order by adddate;

     -- Receive
   EXEC rdt.rdt_Receive_V7_L05
      @nFunc         = @nFunc,
      @nMobile       = @nMobile,
      @cLangCode     = @cLangCode,
      @nErrNo        = @nErrNo OUTPUT,
      @cErrMsg       = @cErrMsg OUTPUT,
      @cStorerKey    = @cStorerKey,
      @cFacility     = @cFacility,
      @cReceiptKey   = @cReceiptKey,
      @cPOKey        = @cPOKey,
      @cToLOC        = @cToLOC,
      @cToID         = @cToID,
      @cSKUCode      = @cSKUCode,
      @cSKUUOM       = @cSKUUOM,
      @nSKUQTY       = @nSKUQTY,
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
      @nNOPOFlag     = @nNOPOFlag,
      @cConditionCode = 'OK',
      @cSubreasonCode = '',
      @cReceiptLineNumberOutput = @cRDLineNo OUTPUT
END
QUIT:
GO
GRANT EXECUTE ON RDT.rdt_608RcvCfm14 TO NSQL
GO
