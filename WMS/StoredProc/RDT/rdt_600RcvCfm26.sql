SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_600RcvCfm26                                           */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Purpose: Update RFID master                                                */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2025-12-12  yeekung   1.0   FCR-8646 Created                               */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_600RcvCfm26 (
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
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT,
   @cReceiptLineNumberOutput NVARCHAR( 5) OUTPUT,
   @cSerialNo      NVARCHAR( 30) = '',
   @nSerialQTY     INT = 0,
   @nBulkSNO       INT = 0,
   @nBulkSNOQTY    INT = 0
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cExternReceiptKey NVARCHAR( 20)
   DECLARE @cTOLocation NVARCHAR( 10)

   IF @nFunc = 600 -- Normal receiving
   BEGIN
      
      -- Receive
      EXEC rdt.rdt_Receive_V7
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
         @nUCCQTY       = 0,
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
         @nNOPOFlag     = @nNOPOFlag,
         @cConditionCode = @cConditionCode,
         @cSubreasonCode = '',
         @cReceiptLineNumberOutput = @cReceiptLineNumberOutput OUTPUT,
         @cSerialNo     = @cSerialNo,
         @nSerialQTY    = @nSerialQTY

      IF @nErrNo <> 0
      BEGIN
         GOTO QUIT
      END   

      SELECT @cExternReceiptKey = ExternReceiptKey
      FROM Receipt (NOLOCK)   
      WHERE ReceiptKey = @cReceiptKey

      SELECT @cTOLocation = Userdefine02
      FROM CODELKUP (NOLOCK)
      WHERE LISTNAME = 'ONAPIENVE'
         AND StorerKey = @cStorerKey
         AND Code = '1'

      INSERT INTO RFIDMaster ( RFIDNo,StorerKey,TIDNo,SKU,Status,DocRefno2,Source ) 
      VALUES (@cSerialNo,@cStorerKey,@cExternReceiptKey,@cSKUCode,'0',@cLottable02,@cTOLocation)

      IF @@ERROR <> 0
         GOTO QUIT
   END
   QUIT:
END
GO
GRANT EXECUTE ON rdt.rdt_600RcvCfm26 TO NSQL
GO
