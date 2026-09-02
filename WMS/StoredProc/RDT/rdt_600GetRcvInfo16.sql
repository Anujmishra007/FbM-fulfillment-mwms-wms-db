
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*****************************************************************************/
/* Stored Procedure: rdt_600GetRcvInfo16                                     */
/* Creation Date: 2026-08-18                                                 */
/* Copyright: MAERSK                                                         */
/*                                                                           */
/* Purpose : Auto-populate QTY from SSCC during Normal Receiving  FCR-15433  */
/*                for ARLA                                                   */
/* Called By: rdtfnc_NormalReceipt_V7 (GetReceiveInfoSP for Function 600)    */
/*                                                                           */
/* Data Modifications:                                                       */
/*                                                                           */
/* Updates:                                                                  */
/* Date         Author   Ver  Purpose                                        */
/* 2026-08-18   NYE018   1.0  FCR-15433 Initial version created              */
/*****************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_600GetRcvInfo16] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cStorerKey   NVARCHAR( 15),
   @cReceiptKey  NVARCHAR( 10),
   @cPOKey       NVARCHAR( 10),
   @cLOC         NVARCHAR( 10),
   @cID          NVARCHAR( 18)  OUTPUT,
   @cSKU         NVARCHAR( 20)  OUTPUT,
   @nQTY         INT            OUTPUT,
   @cLottable01  NVARCHAR( 18)  OUTPUT,
   @cLottable02  NVARCHAR( 18)  OUTPUT,
   @cLottable03  NVARCHAR( 18)  OUTPUT,
   @dLottable04  DATETIME       OUTPUT,
   @dLottable05  DATETIME       OUTPUT,
   @cLottable06  NVARCHAR( 30)  OUTPUT,
   @cLottable07  NVARCHAR( 30)  OUTPUT,
   @cLottable08  NVARCHAR( 30)  OUTPUT,
   @cLottable09  NVARCHAR( 30)  OUTPUT,
   @cLottable10  NVARCHAR( 30)  OUTPUT,
   @cLottable11  NVARCHAR( 30)  OUTPUT,
   @cLottable12  NVARCHAR( 30)  OUTPUT,
   @dLottable13  DATETIME       OUTPUT,
   @dLottable14  DATETIME       OUTPUT,
   @dLottable15  DATETIME       OUTPUT,
   @nErrNo       INT            OUTPUT,
   @cErrMsg      NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 600 -- Normal receiving
   BEGIN
      IF @nStep = 4 -- SKU screen (operator confirmed SKU, system now populates QTY)
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Retrieve the remaining expected QTY and lottables from the ASN detail
            -- line that matches the confirmed SKU and scanned SSCC (ToID = @cID).
            -- Priority: exact SSCC match first, then lines with remaining qty.
            SELECT TOP 1
               @nQTY        = CASE WHEN QTYExpected > BeforeReceivedQTY
                                   THEN QTYExpected - BeforeReceivedQTY
                                   ELSE 0
                              END,
               @cLottable01 = Lottable01,
               @cLottable02 = Lottable02,
               @cLottable03 = Lottable03,
               @dLottable04 = Lottable04,
               @dLottable05 = Lottable05,
               @cLottable06 = Lottable06,
               @cLottable07 = Lottable07,
               @cLottable08 = Lottable08,
               @cLottable09 = Lottable09,
               @cLottable10 = Lottable10,
               @cLottable11 = Lottable11,
               @cLottable12 = Lottable12,
               @dLottable13 = Lottable13,
               @dLottable14 = Lottable14,
               @dLottable15 = Lottable15
            FROM dbo.ReceiptDetail WITH (NOLOCK)
            WHERE ReceiptKey = @cReceiptKey
               AND POKey     = CASE WHEN @cPOKey = 'NOPO' THEN POKey ELSE @cPOKey END
               AND SKU       = @cSKU
               AND ToID      = @cID
            ORDER BY
               CASE WHEN QTYExpected > 0 AND QTYExpected > BeforeReceivedQTY THEN 0 ELSE 1 END,
               ReceiptLineNumber
         END
      END -- End Step 4

      -- Step 5 (lottable screen): lottables already populated at Step 4; no action needed.
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_600GetRcvInfo16] TO NSQL
GO
