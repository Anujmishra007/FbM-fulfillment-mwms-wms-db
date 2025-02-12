/******************************************************************************/
/* Store procedure: rdt_598ExtValidPMI                                        */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Purpose:                                                                   */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2024-12-26  PYU015    1.0   WMS UWP-28661. Created                         */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_598ExtValidPMI] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),
   @cStorerKey   NVARCHAR( 15),
   @cRefNo       NVARCHAR( 20),
   @cColumnName  NVARCHAR( 20),
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
   @cReceiptKey  NVARCHAR( 10),
   @cReceiptLineNumber NVARCHAR( 10),
   @nErrNo       INT            OUTPUT,
   @cErrMsg      NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   
   IF @nFunc = 598 -- Container receive
   BEGIN
      IF @nStep = 3 -- ID
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF EXISTS(SELECT 1
                        FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK)
                       WHERE RD.StorerKey = @cStorerKey
                         AND RD.ToId = @cID
                         AND RD.BeforeReceivedQty > 0)
            BEGIN
               SET @nErrNo = 219936
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID Used
               GOTO Quit
            END
         END
      END
   END

Quit:
END

GO 
GRANT EXECUTE ON [rdt].[rdt_598ExtValidPMI] TO [NSQL]
GO
