
/******************************************************************************/
/* Store procedure: rdt_600GetRcvInfo13                                          */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: Pass through lottables from decoding                              */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 2025-11-13   Cuize     1.0   FCR-7822 Created                              */
/******************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_600GetRcvInfo13
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
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF


   DECLARE @cReceiptLottable02  NVARCHAR( 18)
   DECLARE @cReceiptLottable03  NVARCHAR( 18)
   DECLARE @cReceiptLottable06  NVARCHAR( 30)


   IF @nFunc = 600 -- Normal receive v7
   BEGIN
      IF @nStep = 4
      BEGIN

         SELECT TOP 1
            @cReceiptLottable02= Lottable02,
            @cReceiptLottable03= Lottable03,
            @cReceiptLottable06= Lottable06
         FROM dbo.ReceiptDetail WITH (NOLOCK)
         WHERE ReceiptKey = @cReceiptKey
            AND POKey = CASE WHEN @cPOKey = 'NOPO' THEN POKey ELSE @cPOKey END
            AND SKU = @cSKU
         ORDER BY
            CASE WHEN @cID = ToID THEN 0 ELSE 1 END,
            CASE WHEN QTYExpected > 0 AND QTYExpected > BeforeReceivedQTY THEN 0 ELSE 1 END,
            ReceiptLineNumber


         IF ISNULL(@cReceiptLottable02,'') <> '' AND @cReceiptLottable02 <> @cLottable02
         BEGIN
            SET @nErrNo = 251101
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Bad Lottables
            GOTO Quit
         END

         IF ISNULL(@cReceiptLottable03,'') <> '' AND @cReceiptLottable03 <> @cLottable03
         BEGIN
            SET @nErrNo = 251102
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Bad Lottables
            GOTO Quit
         END

         IF ISNULL(@cReceiptLottable06,'') <> '' AND @cReceiptLottable06 <> @cLottable06
         BEGIN
            SET @nErrNo = 251103
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Bad Lottables
            GOTO Quit
         END

      END

   END -- 600
Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON rdt.rdt_600GetRcvInfo13 TO NSQL
GO
