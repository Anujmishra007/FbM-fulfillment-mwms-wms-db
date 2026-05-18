SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store procedure: rdt_600ExtValBRF                                     */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Purpose: Check if pallet already received.                           */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-04-15 1.0  Cuize      FCR-11068 Created                         */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_600ExtValBRF (
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,           
   @nInputKey    INT,           
   @cFacility    NVARCHAR( 5), 
   @cStorerKey   NVARCHAR( 15), 
   @cReceiptKey  NVARCHAR( 10), 
   @cPOKey       NVARCHAR( 10), 
   @cLOC         NVARCHAR( 10), 
   @cID          NVARCHAR( 18), 
   @cSKU         NVARCHAR( 20), 
   @cLottable01  NVARCHAR( 18), 
   @cLottable02  NVARCHAR( 18), 
   @cLottable03  NVARCHAR( 18), 
   @dLottable04  DATETIME,      
   @dLottable05  DATETIME,      
   @cLottable06  NVARCHAR( 30), 
   @cLottable07  NVARCHAR( 30), 
   @cLottable08  NVARCHAR( 30), 
   @cLottable09  NVARCHAR( 30), 
   @cLottable10  NVARCHAR( 30), 
   @cLottable11  NVARCHAR( 30), 
   @cLottable12  NVARCHAR( 30), 
   @dLottable13  DATETIME,      
   @dLottable14  DATETIME,      
   @dLottable15  DATETIME,      
   @nQTY         INT,           
   @cReasonCode  NVARCHAR( 10), 
   @cSuggToLOC   NVARCHAR( 10), 
   @cFinalLOC    NVARCHAR( 10), 
   @cReceiptLineNumber NVARCHAR( 10), 
   @nErrNo       INT            OUTPUT, 
   @cErrMsg      NVARCHAR( 20)  OUTPUT
)
AS
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nPalletQty     INT

   IF @nFunc = 600 -- Normal receiving
   BEGIN

      IF @nStep = 3 -- ID
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF EXISTS ( SELECT 1 FROM dbo.ReceiptDetail WITH (NOLOCK)
                        WHERE ReceiptKey <> @cReceiptKey
                        AND   StorerKey = @cStorerKey
                        AND   ToID = @cID
                        AND   [Status] <> '9')
            BEGIN
               SET @nErrNo = 144101
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ID EXISTS 
               GOTO Fail
            END
         END   -- ENTER
      END      -- ID

      IF @nStep = 6 -- SKU, Qty
      BEGIN
         SELECT @nPalletQty = PALLET
         FROM dbo.SKU SKU WITH (NOLOCK)
         JOIN dbo.Pack PACK WITH (NOLOCK) ON ( SKU.PACKKey = PACK.PackKey)
         WHERE StorerKey = @cStorerKey
         AND   SKU = @cSKU

         IF (@nPalletQty > 0 AND @nQTY > @nPalletQty)
         BEGIN
            SET @nErrNo = 144102
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- > PALLETT CFG 
            GOTO Fail
         END

         DECLARE @nQTYExpected_Total INT
         DECLARE @nBeforeReceivedQTY_Total INT

         SELECT @nQTYExpected_Total = IsNULL(SUM (QTYExpected),0) ,
                @nBeforeReceivedQTY_Total = IsNULL( SUM( BeforeReceivedQTY), 0)
         FROM dbo.ReceiptDetail (NOLOCK)
          WHERE ReceiptKey = @cReceiptKey
            AND SKU = @cSKU

         IF (@nQTY + @nBeforeReceivedQTY_Total) > @nQTYExpected_Total -- Added for UWP-54217
         BEGIN
            SET @nErrNo = 263405
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'OverASNTotalQty'
            GOTO Fail
         END


      END
   END         -- Normal receiving

   Fail:
   Quit:

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [RDT].[rdt_600ExtValBRF] TO nSQL
GO
