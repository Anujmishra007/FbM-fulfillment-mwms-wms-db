SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*******************************************************************************/  
/* Store procedure: rdt_600ExtScnAD                                            */  
/* CUSTOMER :   ADITR01                                                        */  
/* Modifications log:                                                          */  
/*                                                                             */  
/* Date       Rev  Author     Purposes                                         */  
/* 2026-07-16 1.0  AGA399     Print label in last step without ESC in step 3   */  
/*                                                                             */  
/*******************************************************************************/  
    
CREATE OR ALTER PROC [RDT].[rdt_600ExtScnAD] (  
   @nMobile      INT,  
   @nFunc        INT,  
   @cLangCode    NVARCHAR( 3),  
   @nStep INT,  
   @nScn  INT,  
   @nInputKey    INT,  
   @cFacility    NVARCHAR( 5),  
   @cStorerKey   NVARCHAR( 15),  
  
   @tExtScnData   VariableTable READONLY,  
  
   @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,  @cLottable01 NVARCHAR( 18) OUTPUT,  
   @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,  @cLottable02 NVARCHAR( 18) OUTPUT,  
   @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,  @cLottable03 NVARCHAR( 18) OUTPUT,  
   @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,  @dLottable04 DATETIME      OUTPUT,  
   @cInField05       NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,  @dLottable05 DATETIME      OUTPUT,  
   @cInField06       NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,  @cLottable06 NVARCHAR( 30) OUTPUT,  
   @cInField07       NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,  @cLottable07 NVARCHAR( 30) OUTPUT,  
   @cInField08       NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,  @cLottable08 NVARCHAR( 30) OUTPUT,  
   @cInField09       NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,  @cLottable09 NVARCHAR( 30) OUTPUT,  
   @cInField10       NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,  @cLottable10 NVARCHAR( 30) OUTPUT,  
   @cInField11       NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,  @cLottable11 NVARCHAR( 30) OUTPUT,  
   @cInField12       NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,  @cLottable12 NVARCHAR( 30) OUTPUT,  
   @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,  @dLottable13 DATETIME      OUTPUT,  
   @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,  @dLottable14 DATETIME      OUTPUT,  
   @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,  @dLottable15 DATETIME      OUTPUT,  
   @nAction      INT, --0 Jump Screen, 1 Validation(pass through all input fields), 2 Update, 3 Prepare output fields .....  
   @nAfterScn    INT OUTPUT, @nAfterStep    INT OUTPUT,  
   @nErrNo             INT            OUTPUT,  
   @cErrMsg            NVARCHAR( 20)  OUTPUT,  
   @cUDF01  NVARCHAR( 250) OUTPUT, @cUDF02 NVARCHAR( 250) OUTPUT, @cUDF03 NVARCHAR( 250) OUTPUT,  
   @cUDF04  NVARCHAR( 250) OUTPUT, @cUDF05 NVARCHAR( 250) OUTPUT, @cUDF06 NVARCHAR( 250) OUTPUT,  
   @cUDF07  NVARCHAR( 250) OUTPUT, @cUDF08 NVARCHAR( 250) OUTPUT, @cUDF09 NVARCHAR( 250) OUTPUT,  
   @cUDF10  NVARCHAR( 250) OUTPUT, @cUDF11 NVARCHAR( 250) OUTPUT, @cUDF12 NVARCHAR( 250) OUTPUT,  
   @cUDF13  NVARCHAR( 250) OUTPUT, @cUDF14 NVARCHAR( 250) OUTPUT, @cUDF15 NVARCHAR( 250) OUTPUT,  
   @cUDF16  NVARCHAR( 250) OUTPUT, @cUDF17 NVARCHAR( 250) OUTPUT, @cUDF18 NVARCHAR( 250) OUTPUT,  
   @cUDF19  NVARCHAR( 250) OUTPUT, @cUDF20 NVARCHAR( 250) OUTPUT, @cUDF21 NVARCHAR( 250) OUTPUT,  
   @cUDF22  NVARCHAR( 250) OUTPUT, @cUDF23 NVARCHAR( 250) OUTPUT, @cUDF24 NVARCHAR( 250) OUTPUT,  
   @cUDF25  NVARCHAR( 250) OUTPUT, @cUDF26 NVARCHAR( 250) OUTPUT, @cUDF27 NVARCHAR( 250) OUTPUT,  
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT, @cUDF30 NVARCHAR( 250) OUTPUT  
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE  
      @cPrinter_Paper       NVARCHAR(10),  
      @cPrinter             NVARCHAR(10),  
      @cReceiptKey          NVARCHAR(10),  
      @cReceiptLineNumber   NVARCHAR(5),  
      @cPOKey               NVARCHAR(10),  
      @cID                  NVARCHAR(18)  

   SELECT  
      @nStep               = Step,  
      @nScn                = Scn,  
      @cReceiptKey        = V_Receiptkey,  
      @cReceiptLineNumber = V_String7,  
      @cID                = V_ID,  
      @cPOKey             = V_POKey,  
      @cPrinter            = Printer,  
      @cPrinter_Paper      = Printer_Paper  
   FROM rdt.RDTMOBREC WITH(NOLOCK)  
   WHERE Mobile = @nMobile  

      IF @nStep = 7  
      BEGIN  
         IF @nAction = 2  
         BEGIN  
            DECLARE @cPalletLabel NVARCHAR( 10)  
            DECLARE @tPalletLabel   VariableTable  
  
            SET @cPalletLabel = rdt.RDTGetConfig( @nFunc, 'PalletLabel', @cStorerKey)  
            IF @cPalletLabel = '0'  
               SET @cPalletLabel = ''  
  
            -- Auto print pallet label if setup  
            IF @cPalletLabel <> ''  
            BEGIN  
               -- Common params  
               INSERT INTO @tPalletLabel (Variable, Value) VALUES  
              ( '@cStorerKey', @cStorerKey),  
              ( '@cReceiptKey', @cReceiptKey),  
              ( '@cReceiptLineNumber_Start', @cReceiptLineNumber),  
              ( '@cReceiptLineNumber_End', @cReceiptLineNumber),  
              ( '@cPOKey', @cPOKey),  
              ( '@cToID', @cID)  
  
               -- Print label  
               EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPrinter, @cPrinter_Paper,  
                    @cPalletLabel, -- Report type  
                    @tPalletLabel, -- Report params  
                    'rdt_600ExtScnAD',  
                    @nErrNo  OUTPUT,  
                    @cErrMsg OUTPUT  
  
               IF @nErrNo <> 0 -- error, keep current screen  
               BEGIN  
                  SET @nAfterScn = 4036  
                  SET @nAfterStep = 7  
                  GOTO Quit  
               END  
  
            END --@cPalletLabel <> ''  
         END--@nAction = 2  
      END--@nStep = 7  
Quit:  
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON rdt.rdt_600ExtScnAD TO NSQL
GO