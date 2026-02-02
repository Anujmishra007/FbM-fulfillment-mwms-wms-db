
/****** Object:  StoredProcedure [RDT].[rdt_684ExtValJCB]    Script Date: 7/14/2025 9:24:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*************************************************************************************/
/* Store procedure: [rdt_684ExtValJCB]                                               */
/* Copyright: Maersk                                                                 */
/*                                                                                   */
/* Date         Rev   Author   Purposes                                              */
/* 18/03/2025   1.0   PPA374   UWP-31642 Not allow receipt to the LPN with inventory */
/* 29/05/2025   1.1   PPA374   Preventing XDock ASNs from receiving                  */
/*************************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_684ExtValJCB] (
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
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
   @cPrintChk AS NVARCHAR(1)

   SELECT TOP 1 @cPrintChk = Long FROM dbo.CODELKUP WITH(NOLOCK) WHERE LISTNAME = 'JCBPrintCh' AND Storerkey = @cStorerKey

   IF @nFunc = 684
   BEGIN
      -- 29/05/2025 Preventing XDock ASNs from receiving 
	  IF @nStep = 1 --ASN
	  BEGIN
	     IF EXISTS (SELECT 1 FROM dbo.RECEIPTDETAIL WITH(NOLOCK) WHERE TRIM(SKU) LIKE 'XD%' AND ReceiptKey = @cReceiptKey)
		 BEGIN
		    SET @nErrNo = 218089
			SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')--'Cant take XDOCK ASN'
			GOTO QUIT
		 END

		 IF (SELECT TOP 1 Printer FROM RDT.RDTMOBREC WITH(NOLOCK) WHERE Mobile = @nMobile) = '' AND @cPrintChk = '1'
		 BEGIN
		    SET @nErrNo = 218145
			SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --'No label printer'
			GOTO QUIT
		 END

		 IF EXISTS (SELECT 1 FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK)
                    LEFT JOIN dbo.STORER S WITH(NOLOCK)
                    ON RD.Lottable08 = S.StorerKey AND TYPE = '5'
                    WHERE RD.ReceiptKey = @cReceiptKey
                    AND RD.StorerKey = @cStorerKey
                    AND S.StorerKey IS NULL)
		 BEGIN
		    SET @nErrNo = 218146
			SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')--'NonExisting Supplier'
			GOTO QUIT
		 END
	  END

      -- 18/03/2025 Not allow to receive to an LPN that is already in the inventory
      IF @nStep = 3 -- ID
      BEGIN
         IF @nInputKey = 1
		 BEGIN
		    IF EXISTS (SELECT 1 FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK) INNER JOIN RECEIPT R WITH(NOLOCK) ON R.ReceiptKey = RD.ReceiptKey WHERE ToId = @cID AND RD.UserDefine10 = 'Y' AND R.StorerKey = @cStorerKey AND R.Status < '9')
			BEGIN
			   SET @nErrNo = 218090
			   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')--'Pallet is closed'
			   GOTO QUIT
			END
		 END

         BEGIN
            IF EXISTS (SELECT 1 
                       FROM dbo.LOTxLOCxID LLI WITH(NOLOCK) 
                       WHERE ID = @cID 
                         AND storerkey = @cStorerKey 
                         AND Qty > 0)
            BEGIN
               SET @nErrNo = 218075
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 'LPN exists in inv.'
               GOTO Quit
            END
         END
      END

	  ELSE IF @nStep = 4 -- SKU
	  BEGIN
         IF @nInputKey = 1
         BEGIN
		    IF NOT EXISTS (SELECT 1 FROM dbo.RECEIPTDETAIL WITH(NOLOCK) WHERE SKU = @cSKU AND ReceiptKey = @cReceiptKey AND StorerKey = @cStorerKey AND (POKey = @cPOKey OR @cPOKey = 'NOPO'))
			BEGIN
			   SET @nErrNo = 218091
			   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')--'SKU not in PO'
			   GOTO QUIT
			END

			IF EXISTS (SELECT 1 FROM dbo.SKU WITH(NOLOCK) WHERE SKU = @cSKU AND ISNULL(STDGROSSWGT,0) = 0) 
			AND (SELECT C_String2 FROM RDT.RDTMOBREC WITH(NOLOCK) WHERE Mobile = @nMobile) = 'M'
			BEGIN
			   SET @nErrNo = 218147
			   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')--'Case pal need SKUWGT'
			   GOTO QUIT
			END

			IF EXISTS (SELECT 1 FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK)
					  INNER JOIN dbo.SKU S WITH(NOLOCK)
					  ON RD.SKU = S.SKU
					  WHERE RD.SKU = @cSKU
					  AND RD.StorerKey = @cStorerKey
					  AND STATUS < '9'
					  AND ToId <> ''
					  AND (QtyReceived >0 OR BeforeReceivedQty > 0)
					  AND S.STDGROSSWGT = 0)
			BEGIN
			   SET @nErrNo = 218148
			   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')--'Measure SKU first'
			   GOTO QUIT
			END

		 END
      END

      ELSE IF @nstep = 6 -- QTY
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF EXISTS (SELECT 1 
                       FROM dbo.RECEIPTDETAIL WITH(NOLOCK) 
                       WHERE toid = @cID 
                         AND storerkey = @cStorerKey 
                         AND Lottable03 <> @cLottable03
						 AND Lottable03 <> ''
						 AND ReceiptKey = @cReceiptKey)

            -- 25/02/2025 Not allow diff BUs on same LPN Modify by VJI011 end
            BEGIN
               SET @nErrNo = 218076
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- '18076^Multi BU on ID'
               GOTO Quit
            END

			IF @nQTY > 1 AND TRIM(@cLottable01) <> ''
			BEGIN
			   SET @nErrNo = 218149
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 'SN SKU 1EA at a time'
               GOTO Quit
			END
         END
      END
   END

Quit:
END

GO
GRANT EXECUTE ON [RDT].[rdt_684ExtValJCB] TO [NSQL]
GO
