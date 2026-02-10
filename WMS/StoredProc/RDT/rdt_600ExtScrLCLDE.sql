SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************************/
/* Stored Procedure: rdt_600ExtScrLCLDE                                       */
/*                                                                            */
/* Updates:                                                                   */
/* Date         Author  Ver.    Purposes                                      */
/* 05/05/2025   WSE016  1.1     Checks lottable                               */
/******************************************************************************/
CREATE or ALTER         PROC [RDT].[rdt_600ExtScrLCLDE]
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR( 3),
   @nStep               INT,
   @nScn                INT,
   @nInputKey           INT,
   @cFacility           NVARCHAR( 5),
   @cStorerKey          NVARCHAR( 15),
   @cSuggLOC            NVARCHAR( 10) OUTPUT,
   @cLOC                NVARCHAR( 20) OUTPUT,
   @cID                 NVARCHAR( 20) OUTPUT,
   @cSKU                NVARCHAR( 20) OUTPUT,
   @cReceiptKey         NVARCHAR( 10),
   @cPOKey              NVARCHAR( 10),
   @cReasonCode         NVARCHAR( 10),
   @cReceiptLineNumber  NVARCHAR( 5),
   @cPalletType         NVARCHAR( 10),
   @cInField01          NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,  @cLottable01 NVARCHAR( 18) OUTPUT,
   @cInField02          NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,  @cLottable02 NVARCHAR( 18) OUTPUT,
   @cInField03          NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,  @cLottable03 NVARCHAR( 18) OUTPUT,
   @cInField04          NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,  @dLottable04 DATETIME      OUTPUT,
   @cInField05          NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,  @dLottable05 DATETIME      OUTPUT,
   @cInField06          NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,  @cLottable06 NVARCHAR( 30) OUTPUT,
   @cInField07          NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,  @cLottable07 NVARCHAR( 30) OUTPUT,
   @cInField08          NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,  @cLottable08 NVARCHAR( 30) OUTPUT,
   @cInField09          NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,  @cLottable09 NVARCHAR( 30) OUTPUT,
   @cInField10          NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,  @cLottable10 NVARCHAR( 30) OUTPUT,
   @cInField11          NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,  @cLottable11 NVARCHAR( 30) OUTPUT,
   @cInField12          NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,  @cLottable12 NVARCHAR( 30) OUTPUT,
   @cInField13          NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,  @dLottable13 DATETIME      OUTPUT,
   @cInField14          NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,  @dLottable14 DATETIME      OUTPUT,
   @cInField15          NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,  @dLottable15 DATETIME      OUTPUT,
   @nAction             INT,
   @nAfterScn           INT OUTPUT, 
   @nAfterStep          INT OUTPUT, 
   @nErrNo              INT            OUTPUT, 
   @cErrMsg             NVARCHAR( 20)  OUTPUT
AS    
BEGIN   
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
Declare  
      @cCustomer      NVARCHAR(18),
      @cCustomer1      NVARCHAR(18)
         SELECT  TOP 1  @cCustomer = ISNULL(Lottable01,'')
         FROM dbo.ReceiptDetail RD WITH (NOLOCK)
          WHERE ToId = @cID
            AND   BeforeReceivedQty > 0
         SELECT  TOP 1  @cCustomer1 = ISNULL(Lottable01,'')
         FROM dbo.ReceiptDetail RD WITH (NOLOCK)
          WHERE Lottable03 = @cLottable03
   IF @nFunc = 600
   BEGIN
      IF @nStep = 5
      BEGIN
         -- prevent to mix Customer
        IF   @cCustomer <> @cCustomer1
         BEGIN
            SET @nErrNo = 218370
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --Mixed Customer on PLT
            GOTO Quit
         END 
         --Check lottable06 (Customer SKU) value is not equal to LCLCASE
		 IF @cLottable06 = 'LCLDE_BOX'
		 BEGIN
            SET @nErrNo = 218367
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Customer SKU can not be LCLCASE'
            GOTO Quit
         END
		--Check lottable06 (Customer SKU) value is not equal to LCLCASE
		 IF @cLottable06 = 'LCLDE_PLT'
		 BEGIN
            SET @nErrNo = 218368
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Customer SKU can not be LCLPAL'
            GOTO Quit
         END
		--Check lottable06 (Customer PO) value exists in receipt
		 IF NOT EXISTS (SELECT 1 FROM dbo.RECEIPTDETAIL WITH (NOLOCK) WHERE RECEIPTKEY = @cReceiptKey AND StorerKey = @cStorerKey AND Sku= @cSKU AND Lottable03 = @cLottable03)
		 BEGIN
            SET @nErrNo = 218369
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Customer SKU not exists in receipt'
            GOTO Quit
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
GRANT EXECUTE ON [RDT].[rdt_600ExtScrLCLDE] TO [NSQL]
