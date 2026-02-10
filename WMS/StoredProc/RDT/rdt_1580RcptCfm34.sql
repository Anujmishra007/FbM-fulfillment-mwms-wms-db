SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: rdt_1580RcptCfm34                                      */
/* Copyright      : MAERSK                                                 */
/*                                                                         */
/* Date       Rev  Author  Purposes                                        */
/* 2025-10-01 1.0  Ung     FCR-8040 Created                                */
/***************************************************************************/
CREATE OR ALTER PROCEDURE [RDT].[rdt_1580RcptCfm34](
   @nFunc          INT,
   @nMobile        INT,
   @cLangCode      NVARCHAR( 3),
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT,
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
   @nNOPOFlag      INT,
   @cConditionCode NVARCHAR( 10),
   @cSubreasonCode NVARCHAR( 10),
   @cReceiptLineNumber NVARCHAR( 5) OUTPUT,
   @cSerialNo      NVARCHAR( 30) = '',
   @nSerialQTY     INT = 0,
   @nBulkSNO       INT = 0,
   @nBulkSNOQTY    INT = 0
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cBarcode NVARCHAR( MAX)
   DECLARE @cSNOP1   NVARCHAR( 10)
   DECLARE @cSNOP2   NVARCHAR( 10)
   DECLARE @cSNOP3   NVARCHAR( 10)

   -- Get session info
   SELECT @cBarcode = V_Barcode
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Composite barcode
   IF CHARINDEX( '&', @cBarcode) > 0
   BEGIN
      SET @cSNOP1 = rdt.rdtGetParsedString( @cBarcode, 4, '&')
      SET @cSNOP2 = rdt.rdtGetParsedString( @cBarcode, 5, '&')
      SET @cSNOP3 = rdt.rdtGetParsedString( @cBarcode, 7, '&')

      SET @cSerialNo = @cSNOP1 + @cSNOP2 + @cSNOP3
      SET @nSerialQTY = 1
   END
   ELSE
   BEGIN
      SET @cSerialNo = ''
      SET @nSerialQTY = 0
   END

   EXEC rdt.rdt_Receive
      @nFunc          = @nFunc,
      @nMobile        = @nMobile,
      @cLangCode      = @cLangCode,
      @nErrNo         = @nErrNo  OUTPUT,
      @cErrMsg        = @cErrMsg OUTPUT,
      @cStorerKey     = @cStorerKey,
      @cFacility      = @cFacility,
      @cReceiptKey    = @cReceiptKey,
      @cPOKey         = @cPOKey,
      @cToLOC         = @cToLOC,
      @cToID          = @cTOID,
      @cSKUCode       = @cSKUCode,
      @cSKUUOM        = @cSKUUOM,
      @nSKUQTY        = @nSKUQTY,
      @cUCC           = @cUCC,
      @cUCCSKU        = @cUCCSKU,
      @nUCCQTY        = @nUCCQTY,
      @cCreateUCC     = @cCreateUCC,
      @cLottable01    = @cLottable01,
      @cLottable02    = @cLottable02,
      @cLottable03    = @cLottable03,
      @dLottable04    = @dLottable04,
      @dLottable05    = @dLottable05,
      @nNOPOFlag      = @nNOPOFlag,
      @cConditionCode = @cConditionCode,
      @cSubreasonCode = @cSubreasonCode,
      @cReceiptLineNumberOutput = @cReceiptLineNumber OUTPUT,
      @cSerialNo      = @cSerialNo,
      @nSerialQTY     = @nSerialQTY,
      @nBulkSNO       = @nBulkSNO,
      @nBulkSNOQTY    = @nBulkSNOQTY
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  [RDT].[rdt_1580RcptCfm34] TO [NSQL]
GO