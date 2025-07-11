
/**********************************************************************************************/
/* Store procedure: rdt_600ExtUpd_Sony                                                        */
/* Copyright      : Maersk                                                                    */
/*                                                                                            */
/* Purpose: Check if the value of UCC set by user is correct base on  custoemr requirements   */
/*                                                                                            */
/* Date       Rev  Author     Purposes                                                        */
/* 2025-07-08 1.0  AGA399     Created                                                         */
/**********************************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_600ExtUpd_Sony] (
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
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 600
   BEGIN
     IF @nStep = 14 -- Serial No
     BEGIN
		 IF LEN (@cUCC) <> 13
			 BEGIN
				SET @nErrNo = 232158
				SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Incorrect Lenght Serial No'  
				GOTO Quit
			 END

		  IF LEFT (@cUCC,4) <> 'S01'
			 BEGIN
				SET @nErrNo = 232159
				SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Incorrect Prefix Serial No'  
				GOTO Quit
			 END
		  IF TRY_PARSE(SUBSTRING(@cUCC, 5, 7) AS int)IS NULL
			 BEGIN
				SET @nErrNo = 232160
				SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Not Numeric Serial No'  
				GOTO Quit
			 END
		END --Step14
	Quit:
END
