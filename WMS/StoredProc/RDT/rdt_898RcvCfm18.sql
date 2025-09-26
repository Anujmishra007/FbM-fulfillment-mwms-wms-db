
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_898RcvCfm18                                        */
/* Copyright      : MAERSK                                                 */
/* Customer       : PAGE                                                   */  
/*                                                                         */
/* Date       Rev    Author   Purposes                                     */
/* 2025-09-22 1.0    JACKC    FCR-7818 Created                             */
/***************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_898RcvCfm18](
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
   @cSubreasonCode NVARCHAR( 10)
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag  INT = 0

   DECLARE 
      @cSerialNo     NVARCHAR( 20)
      ,@nSerialQty   INT = 0

   SET @cSerialNo = @cUCC

   SELECT @nSerialQTY = Qty 
   FROM dbo.UCC WITH (NOLOCK) 
   WHERE
      StorerKey = @cStorerKey
      AND UCCNo = @cUCC

   IF @nSerialQty = 0
   BEGIN
      SET @nErrNo = 247601
      SET @cErrMsg = rdt.rdtgetmessage( 247601, @cLangCode, 'DSP') --Invalid UCC Qty
      GOTO Quit
   END 

   SET @nErrNo = 0

   BEGIN TRY
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
         @cToID          = @cToID,
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
         @cSerialNo      = @cSerialNo,
         @nSerialQty     = @nSerialQty
   END TRY
   BEGIN CATCH
      SET @nErrNo = 247602
      SET @cErrMsg = rdt.rdtgetmessage( 247602, @cLangCode, 'DSP') --Receiving Failure
      GOTO Quit
   END CATCH

   Quit:
   

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_898RcvCfm18 TO NSQL
GO
