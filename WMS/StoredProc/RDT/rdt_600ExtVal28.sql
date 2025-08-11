SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_600ExtVal28                                     */
/* Copyright      : MAERSK                                              */
/*                                                                      */
/* Purpose: FCR-6888                                                    */
/*                                                                      */
/* Date         Rev  Author     Purposes                                  */
/* 06-Aug-2025  1.0  Cuize      FCR-6888. Created                         */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_600ExtVal28 (
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

   DECLARE  @cPalletRecvSP       NVARCHAR( 20),
            @cPrinter_Paper       NVARCHAR( 10),
            @cPrinter             NVARCHAR( 10),
            @cPalletLabel NVARCHAR( 10)



SELECT
   @cPrinter            = Printer,
   @cPrinter_Paper      = Printer_Paper
FROM rdt.RDTMOBREC WITH(NOLOCK)
WHERE Mobile = @nMobile

   IF @nFunc = 600 -- Normal receiving
   BEGIN
      IF @nStep = 1 -- ID
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN


            SET @cPalletLabel = rdt.RDTGetConfig( @nFunc, 'PalletLabel', @cStorerKey)
            IF @cPalletLabel = '0'
               SET @cPalletLabel = ''

            SET @cPalletRecvSP = rdt.RDTGetConfig( @nFunc, 'PalletRecvSP', @cStorerKey)
            IF @cPalletRecvSP = '0'
               SET @cPalletRecvSP = ''

            --Wrong Config PalletRecvSP
            IF @cPalletRecvSP = ''
            BEGIN
               SET @nErrNo = 243701
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END

            IF @cPrinter = '' AND @cPrinter_Paper = ''
            BEGIN
               SET @nErrNo = 243702
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoPrinter
               GOTO Quit
            END

            IF @cPalletLabel = ''
            BEGIN
               SET @nErrNo = 243703
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoLabelConfig
               GOTO Quit
            END

         END
      END

      IF @nStep = 6 -- QTY screen
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN

            IF @cSKU = 'LCLPLT' AND @nQTY <> 1
            BEGIN
               SET @nErrNo = 243704
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --QtyMustBe1
               GOTO Quit
            END

         END
      END
   END         

   Quit:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [RDT].[rdt_600ExtVal28] TO nSQL
GO
