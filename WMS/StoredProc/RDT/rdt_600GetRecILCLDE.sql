
/******************************************************************************/
/* Store procedure: rdt_600GetRecILCLDE                                       */
/* Copyright: LF Logistics                                                    */
/*                                                                            */
/* Purpose: Retrieve ReceitDetail Null Lottables                              */
/*                                                                            */
/* Date        Author Ver.       Purposes                                     */
/* 07-11-2025   1.0   WSE016     Only Auto populate Lottable03                */
/*                               if there is only 1 Lottable06 value          */
/*                               for the same ReceiptKey                      */
/******************************************************************************/
      
CREATE OR ALTER PROC [RDT].[rdt_600GetRecILCLDE] (
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
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @nLottable03Cnt INT

   IF @nFunc = 600
   BEGIN
      IF @nStep = 4
      BEGIN
         SELECT @nLottable03Cnt = COUNT (DISTINCT Lottable03) FROM dbo.RECEIPTDETAIL WITH (NOLOCK) WHERE RECEIPTKEY = @cReceiptKey   AND StorerKey = @cStorerKey
         --If in the RECEIPTDETAIL there is only one Customer PO (Lottable03) preopulate it, in other case Lottable03 field would be empty
         IF @nLottable03Cnt = 1
         BEGIN
            SELECT TOP 1 @cLottable03 = Lottable03 FROM dbo.RECEIPTDETAIL WITH (NOLOCK) WHERE RECEIPTKEY = @cReceiptKey   AND StorerKey = @cStorerKey
         END

         ELSE
         BEGIN
            SET @cLottable03 = ''
         END

         --Check id the DropID was already used in the same ReceiptKey, in tat case use the last values set of lot7,8 and 9 (Lenght, Width and Height)
         IF EXISTS (SELECT 1 FROM dbo.RECEIPTDETAIL WITH (NOLOCK) WHERE RECEIPTKEY = @cReceiptKey AND StorerKey = @cStorerKey AND ToID= @cID)
         BEGIN
            SELECT TOP 1 @cLottable07 = Lottable07 FROM dbo.RECEIPTDETAIL WITH (NOLOCK) WHERE RECEIPTKEY = @cReceiptKey AND StorerKey = @cStorerKey AND ToID= @cID
            SELECT TOP 1 @cLottable08 = Lottable08 FROM dbo.RECEIPTDETAIL WITH (NOLOCK) WHERE RECEIPTKEY = @cReceiptKey AND StorerKey = @cStorerKey AND ToID= @cID
            SELECT TOP 1 @cLottable09 = Lottable09 FROM dbo.RECEIPTDETAIL WITH (NOLOCK) WHERE RECEIPTKEY = @cReceiptKey AND StorerKey = @cStorerKey AND ToID= @cID
         END
         END --Step 4



         --If user goes back from the step 6 to the step 5
         IF @nStep = 6 AND @nInputKey = 0
         BEGIN
         SELECT @nLottable03Cnt = COUNT (DISTINCT Lottable03) FROM dbo.RECEIPTDETAIL WITH (NOLOCK) WHERE RECEIPTKEY = @cReceiptKey AND StorerKey = @cStorerKey
         --If in the RECEIPTDETAIL there is only one Customer PO (Lottable03) preopulate it, in other case Lottable03 field would be empty
         IF @nLottable03Cnt = 1
         BEGIN
            SELECT TOP 1 @cLottable03 = Lottable03 FROM dbo.RECEIPTDETAIL WITH (NOLOCK) WHERE RECEIPTKEY = @cReceiptKey AND StorerKey = @cStorerKey
         END
         ELSE
         BEGIN
            SET @cLottable03 = ''
         END
         --Check id the DropID was already used in the same ReceiptKey, in tat case use the last values set of lot7,8 and 9 (Lenght, Width and Height)
         IF EXISTS (SELECT 1 FROM dbo.RECEIPTDETAIL WITH (NOLOCK) WHERE RECEIPTKEY = @cReceiptKey AND StorerKey = @cStorerKey AND ToID= @cID)
         BEGIN
            SELECT TOP 1 @cLottable07 = Lottable07 FROM dbo.RECEIPTDETAIL WITH (NOLOCK) WHERE RECEIPTKEY = @cReceiptKey AND StorerKey = @cStorerKey AND ToID= @cID
            SELECT TOP 1 @cLottable08 = Lottable08 FROM dbo.RECEIPTDETAIL WITH (NOLOCK) WHERE RECEIPTKEY = @cReceiptKey AND StorerKey = @cStorerKey AND ToID= @cID
            SELECT TOP 1 @cLottable09 = Lottable09 FROM dbo.RECEIPTDETAIL WITH (NOLOCK) WHERE RECEIPTKEY = @cReceiptKey AND StorerKey = @cStorerKey AND ToID= @cID
         END
      END ----Step 6
   END
END -- End Procedure
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_600GetRecILCLDE TO NSQL
GO
