SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_600ExtVal33                                     */
/* Copyright      : MAERSK                                              */
/*                                                                      */
/* Purpose: Validate SKU mix on same pallet (ID) within same ASN       */
/*                                                                      */
/* Date         Rev  Author     Purposes                                */
/* 2026-08-12   1.0  Dennis     FCR-15474 Created                       */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_600ExtVal33 (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR(  3),
   @nStep        INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR(  5),
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
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 600 -- Normal Receiving
   BEGIN
      IF @nStep = 4 -- SKU
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Check if another SKU was already received on the same pallet (ID) in this ASN
            IF EXISTS (
               SELECT 1 FROM dbo.ReceiptDetail WITH (NOLOCK)
               WHERE StorerKey  = @cStorerKey
               AND   ReceiptKey = @cReceiptKey
               AND   ToID       = @cID
               AND   SKU       <> @cSKU
               AND   QtyReceived > 0
            )
            BEGIN
               SET @nErrNo = 270554
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- SKU Mix not allowed
               GOTO Quit
            END
         END
      END
   END

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_600ExtVal33 TO NSQL
GO
