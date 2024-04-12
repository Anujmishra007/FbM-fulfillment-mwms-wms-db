GO
/****** Object:  StoredProcedure [RDT].[rdt_600ExtVal18_HRP]    Script Date: 3/21/2024 7:01:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************/
/* Store procedure: rdt_600ExtVal18_HRP                                 */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Purpose: Check lottable02 (COD), not allow to mix                    */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2024-03-13 1.0  WSE016        WMS-16932 Created                      */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_600ExtVal18_HRP] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),
   @cStorerKey   NVARCHAR( 15),
   @cReceiptKey  NVARCHAR( 10),
   @cPOKey       NVARCHAR( 10),
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
   @cReceiptLineNumber NVARCHAR( 10),
   @nErrNo       INT            OUTPUT,
   @cErrMsg      NVARCHAR( 20)  OUTPUT
)
AS
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @lot2     NVARCHAR( 18)

   IF @nFunc = 600 -- Normal receiving
   BEGIN


    IF @nStep = 3 -- ToID  
      BEGIN  
         IF @nInputKey = 1 -- ENTER  
         BEGIN  
            -- Receive to ID  
            IF @cID = ''  

			   BEGIN
               SET @nErrNo = 52962  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Need ID
               GOTO Quit

            END
      END
   END        


      IF @nStep =  6 -- Qty
      BEGIN
			SELECT @lot2 = Lottable02 FROM dbo.ReceiptDetail WITH (NOLOCK)
							WHERE ReceiptKey = @cReceiptKey
							AND   StorerKey = @cStorerKey
							AND   ToID = @cID
							AND   [Status] <> '9'

         IF @lot2 <> @cLottable02
         BEGIN
               SET @nErrNo = 1862017  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ID EXISTS
               GOTO Quit

            END
      END
   END         -- Normal receiving

   Quit:
