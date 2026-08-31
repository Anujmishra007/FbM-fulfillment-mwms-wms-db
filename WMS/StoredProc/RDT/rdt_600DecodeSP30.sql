
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*****************************************************************************/
/* Stored Procedure: rdt_600DecodeSP30                                       */
/* Creation Date: 2026-08-18                                                 */
/* Copyright: MAERSK                                                         */
/*                                                                           */
/* Purpose : Auto-populate SKU from SSCC during Normal Receiving FCR-15433   */
/*                for ARLA                                                   */
/* Called By: rdtfnc_NormalReceipt_V7 (DecodeSP for Function 600)            */
/*                                                                           */
/* Data Modifications:                                                       */
/*                                                                           */
/* Updates:                                                                  */
/* Date         Author   Ver  Purpose                                        */
/* 2026-08-18   NYE018   1.0  FCR-15433 Initial version created              */
/*****************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_600DecodeSP30] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cStorerKey   NVARCHAR( 15),
   @cReceiptKey  NVARCHAR( 10),
   @cPOKey       NVARCHAR( 10),
   @cLOC         NVARCHAR( 10),
   @cBarcode     NVARCHAR( 2000)  OUTPUT,
   @cFieldName   NVARCHAR( 10),
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
      IF @nStep = 3 -- ID (SSCC) screen
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF ISNULL( @cID, '') <> ''
            BEGIN
               -- Look up the ASN detail line where ToID matches the scanned SSCC.
               -- rdt_600ExtValARLA already validates the SSCC exists; here we only
               -- retrieve the SKU so the next screen can pre-populate it.
               SELECT TOP 1
                  @cSKU = SKU
               FROM dbo.ReceiptDetail WITH (NOLOCK)
               WHERE ReceiptKey = @cReceiptKey
                  AND StorerKey  = @cStorerKey
                  AND ToID       = @cID
               ORDER BY ReceiptLineNumber
            END
         END
      END -- End Step 3
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_600DecodeSP30] TO NSQL
GO
