
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_600ExtVal_PGPE                                        */
/* Copyright      : LF Logistics                                              */
/* Customer       : PGPE                                                      */
/*                                                                            */
/* Purpose: Add multiple validations during the goods receiving process       */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 2026-05-04   FRO014    1.0   RITM9002092/UWP-61805                         */
/*                              Ensure Pallet ID has no more than 5 lots,     */
/*                              lot expiration dates within a Pallet ID       */
/*                              differ by no more than 90 days, Pallet ID     */
/*                              has not been used, and Pallet ID quantity     */
/*                              does not exceed the SPS configured limit      */
/* 2026-08-18   Dennis    1.1   UWP-63764                                     */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_600ExtVal_PGPE]
   @nMobile            INT,
   @nFunc              INT,
   @cLangCode          NVARCHAR( 3),
   @nStep              INT,
   @nInputKey          INT,
   @cFacility          NVARCHAR( 5),
   @cStorerKey         NVARCHAR( 15),
   @cReceiptKey        NVARCHAR( 10),
   @cPOKey             NVARCHAR( 10),
   @cLOC               NVARCHAR( 10),
   @cID                NVARCHAR( 18),
   @cSKU               NVARCHAR( 20),
   @cLottable01        NVARCHAR( 18),
   @cLottable02        NVARCHAR( 18),
   @cLottable03        NVARCHAR( 18),
   @dLottable04        DATETIME,
   @dLottable05        DATETIME,
   @cLottable06        NVARCHAR( 30),
   @cLottable07        NVARCHAR( 30),
   @cLottable08        NVARCHAR( 30),
   @cLottable09        NVARCHAR( 30),
   @cLottable10        NVARCHAR( 30),
   @cLottable11        NVARCHAR( 30),
   @cLottable12        NVARCHAR( 30),
   @dLottable13        DATETIME,
   @dLottable14        DATETIME,
   @dLottable15        DATETIME,
   @nQTY               INT,
   @cReasonCode        NVARCHAR( 10),
   @cSuggToLOC         NVARCHAR( 10),
   @cFinalLOC          NVARCHAR( 10),
   @cReceiptLineNumber NVARCHAR( 10),
   @nErrNo             INT           OUTPUT,
   @cErrMsg            NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nPalletExists   TINYINT  = 0
   DECLARE @dMinExpDate     DATETIME
   DECLARE @dMaxExpDate     DATETIME
   DECLARE @nQtyAccumulated INT      = 0
   DECLARE @nMaxQtyPallet   INT      = 0

   IF @nFunc = 600
   BEGIN
      -- Not allow to receive a used LPN
      IF @nStep = 3 -- ID
      BEGIN
         -- Check on PERARCHIVE
         IF EXISTS (
            SELECT 1
            FROM PERARCHIVE.dbo.RECEIPTDETAIL WITH (NOLOCK)
            WHERE ReceiptKey        <> @cReceiptKey
              AND ToId               = @cID
              AND BeforeReceivedQty  > 0
              AND StorerKey          = @cStorerKey
         )
         BEGIN
            SET @nPalletExists = 1
         END

         -- Check on WMS
         IF EXISTS (
            SELECT 1
            FROM dbo.RECEIPTDETAIL WITH (NOLOCK)
            WHERE ReceiptKey        <> @cReceiptKey
              AND ToId               = @cID
              AND BeforeReceivedQty  > 0
              AND StorerKey          = @cStorerKey
         )
         BEGIN
            SET @nPalletExists = 1
         END

         IF @nPalletExists > 0
         BEGIN
            SET @nErrNo  = 275052
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Used LPN
            GOTO Quit
         END
      END

      -- No more than 5 lots of the same SKU allowed on a pallet;
      -- difference between lots cannot exceed 90 days
      IF @nStep = 6 -- SKU, Qty
      BEGIN
         -- Check if there is only one SKU on the pallet
         IF (SELECT COUNT(DISTINCT SKU)
             FROM dbo.RECEIPTDETAIL WITH (NOLOCK)
             WHERE ReceiptKey       = @cReceiptKey
               AND ToId             = @cID
               AND BeforeReceivedQty > 0
               AND StorerKey        = @cStorerKey) = 1
         BEGIN
            -- Check number of batches (max 5)
            IF (
               SELECT COUNT(DISTINCT Lottable01) + 1
               FROM dbo.RECEIPTDETAIL WITH (NOLOCK)
               WHERE ReceiptKey       = @cReceiptKey
                 AND ToId             = @cID
                 AND BeforeReceivedQty > 0
                 AND StorerKey        = @cStorerKey
                 AND SKU              = @cSKU) > 5
            BEGIN
               SET @nErrNo  = 275053
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Max 5 batches
               GOTO Quit
            END

            -- Check difference in expiration dates <= 90 days
            SELECT @dMinExpDate = MIN(Lottable04),
                   @dMaxExpDate = MAX(Lottable04)
            FROM dbo.RECEIPTDETAIL WITH (NOLOCK)
            WHERE ReceiptKey       = @cReceiptKey
              AND ToId             = @cID
              AND BeforeReceivedQty > 0
              AND StorerKey        = @cStorerKey
              AND SKU              = @cSKU

            IF @dMinExpDate > @dLottable04
               SET @dMinExpDate = @dLottable04

            IF @dMaxExpDate < @dLottable04
               SET @dMaxExpDate = @dLottable04

            IF DATEDIFF(DAY, @dMinExpDate, @dMaxExpDate) > 90
            BEGIN
               SET @nErrNo  = 275054
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Diff.ExpDate>90days
               GOTO Quit
            END
         END

         -- Check that the quantity does not exceed the maximum pallet size
         SET @nQtyAccumulated = ISNULL((
            SELECT SUM(QtyReceived)
            FROM dbo.RECEIPTDETAIL WITH (NOLOCK)
            WHERE ReceiptKey = @cReceiptKey
              AND ToId       = @cID
              AND StorerKey  = @cStorerKey
              AND SKU        = @cSKU), 0) + @nQTY

         SET @nMaxQtyPallet = ISNULL((
            SELECT p.Pallet
            FROM dbo.SKU s WITH (NOLOCK)
            INNER JOIN dbo.PACK p WITH (NOLOCK) ON p.PackKey = s.PackKey
            WHERE s.StorerKey = @cStorerKey
              AND s.SKU       = @cSKU), 0)

         IF @nMaxQtyPallet < @nQtyAccumulated
         BEGIN
            SET @nErrNo  = 275055
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Qty>MaxPallet
            GOTO Quit
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

GRANT EXECUTE ON [RDT].[rdt_600ExtVal_PGPE] TO NSQL
GO
