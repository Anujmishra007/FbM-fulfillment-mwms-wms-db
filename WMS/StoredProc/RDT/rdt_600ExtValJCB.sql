SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*************************************************************************************/
/* Store procedure: [rdt_600ExtValJCB]                                               */
/* Copyright: Maersk                                                                 */
/*                                                                                   */
/*                                                                                   */
/* Date         Rev   Author   Purposes                                              */
/* 19/02/2025   1.0   TPT001   UWP-31642 Do not use ID from different ASN            */
/* 25/02/2025   1.1   VJI011   UWP-31642 Not allow diff BUs on same LPN              */
/* 18/03/2025   1.2   PPA374   UWP-31642 Not allow receipt to the LPN with inventory */
/*************************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_600ExtValJCB] (
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
   @nErrNo             INT            OUTPUT,
   @cErrMsg            NVARCHAR( 20)  OUTPUT
) AS

BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   IF @nFunc = 600
   BEGIN
      --18/03/2025 Not allow to receive to an LPN that is already in the inventory
      IF @nStep = 3 --ID
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF EXISTS (SELECT 1 FROM dbo.LOTxLOCxID LLI WITH(NOLOCK) WHERE ID = @cID AND storerkey = @cStorerKey AND Qty > 0)
            BEGIN
               SET @nErrNo = 218044
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'LPN exists in inv.'
               GOTO Quit
            END
         END
      END

      ELSE IF @nstep = 6 --QTY
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF EXISTS (SELECT 1 FROM dbo.RECEIPTDETAIL WITH(NOLOCK) 
                     WHERE toid = @cID 
                     AND storerkey = @cStorerKey 
                     AND Lottable03 <> @cLottable03)

            --25/02/2025 Not allow diff BUs on same LPN Modify by VJI011 end
            BEGIN
               SET @nErrNo = 218045
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Multi BU on ID'
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


GRANT EXECUTE ON [RDT].[rdt_600ExtValJCB] TO [NSQL]
GO
