

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_600DecodeSP28                                         */
/* Copyright: LF Logistics                                                    */
/*                                                                            */
/* Purpose: Extended putaway                                                  */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2026-08-10  Dennis    1.0   FCR-14211 Created                              */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_600DecodeSP28] (
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
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cLottablecode NVARCHAR(30)

   IF @nFunc = 600 -- Normal receiving
   BEGIN
      IF @nStep = 4 -- SKU
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SET @cSKU = ''  -- Prevent RDTMOBREC V_SKU from leaking into SKU validation

            DECLARE @cDefaultlot NVARCHAR(1)
            SET @cDefaultlot=rdt.RDTGetConfig( @nFunc, 'LotDefaultQty', @cStorerKey)

            SELECT TOP 1 @cLottablecode=LottableCode
            FROM sku (NOLOCK)
            WHERE sku=@cBarcode
            AND storerkey=@cStorerKey

            IF ISNULL(@cDefaultlot,'')<>''
               AND EXISTS(SELECT 1 FROM rdt.rdtLottableCode (NOLOCK)
                          WHERE Function_ID IN(0,@nFunc)
                          AND StorerKey=@cStorerKey
                          AND lottablecode=@clottablecode
                          AND Visible='1'
                          AND lottableno=10)
            BEGIN
               SET @nqty=1
            END
            ELSE
            BEGIN
               SET @nQTY=''
            end

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

GRANT EXECUTE ON rdt.rdt_600DecodeSP28 TO NSQL
GO