SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*************************************************************************/
/* Store procedure: [rdt_600ExtVal_RIM]                                  */
/* Copyright: Maersk                                                     */
/*                                                                       */
/*                                                                       */
/* Date         Rev   Author   Purposes                                  */
/* 19/02/2024   1.0   WSE016   Lot01/04 Valid & Prevert OverReceipt      */
/*                                                                       */
/*************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_600ExtVal_RIM]
(
   @nMobile INT,
   @nFunc INT,
   @cLangCode NVARCHAR(3),
   @nStep INT,
   @nInputKey INT,
   @cFacility NVARCHAR(5),
   @cStorerKey NVARCHAR(15),
   @cReceiptKey NVARCHAR(10),
   @cPOKey NVARCHAR(10),
   @cLOC NVARCHAR(10),
   @cID NVARCHAR(18),
   @cSKU NVARCHAR(20),
   @cLottable01 NVARCHAR(18),
   @cLottable02 NVARCHAR(18),
   @cLottable03 NVARCHAR(18),
   @dLottable04 DATETIME,
   @dLottable05 DATETIME,
   @cLottable06 NVARCHAR(30),
   @cLottable07 NVARCHAR(30),
   @cLottable08 NVARCHAR(30),
   @cLottable09 NVARCHAR(30),
   @cLottable10 NVARCHAR(30),
   @cLottable11 NVARCHAR(30),
   @cLottable12 NVARCHAR(30),
   @dLottable13 DATETIME,
   @dLottable14 DATETIME,
   @dLottable15 DATETIME,
   @nQTY INT,
   @cReasonCode NVARCHAR(10),
   @cSuggToLOC NVARCHAR(10),
   @cFinalLOC NVARCHAR(10),
   @cReceiptLineNumber NVARCHAR(10),
   @nErrNo INT OUTPUT,
   @cErrMsg NVARCHAR(20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   IF @nFunc = 600
   BEGIN
      IF @nStep = 6 -- Check Lottable01/04
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF NOT EXISTS (SELECT 1  FROM dbo.RECEIPTDETAIL WITH (NOLOCK)
                        WHERE ReceiptKey = @cReceiptKey
                           AND Lottable01 = @cLottable01)
            BEGIN
               SET @nErrNo = 218386
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --218386 Lottable01 Not Exist
               GOTO Quit
            END

            IF NOT EXISTS (SELECT 1 FROM dbo.RECEIPTDETAIL WITH (NOLOCK)
                           WHERE ReceiptKey = @cReceiptKey
                              AND Lottable01 = @cLottable01
                              AND Lottable04 = @dLottable04
                              AND POKey = @cPOKey)
            BEGIN
               SET @nErrNo = 218387
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --218387 Lottable01/04 Mismatch
               GOTO Quit
            END

            IF EXISTS (SELECT 1 FROM dbo.RECEIPTDETAIL WITH(NOLOCK) 
                        WHERE toid = @cID 
                           AND storerkey = @cStorerKey
                           AND POKey <> @cPOKey
                           AND Lottable01 <> @cLottable01
                           AND Lottable04 <> @dLottable04)
            BEGIN
                  SET @nErrNo = 218388
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --218388 LPN Used Diff PO
                  GOTO Quit
            END

            IF EXISTS (SELECT 1 FROM dbo.RECEIPTDetail WITH(NOLOCK) 
                        WHERE Receiptkey = @cReceiptKey
                           AND Storerkey = @CStorerkey
                           AND POKey = @cPOKey
                           AND Lottable01 = @cLottable01
                           AND Lottable04 = @dLottable04
                           HAVING SUM(BeforeReceivedQty) + @nQTY >SUM(QTYExpected))
            BEGIN
               SET @nErrNo = 218389
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 218389 Over Receipt
               GOTO Quit
            END
         END
      END
   END

Quit:
END
GO
