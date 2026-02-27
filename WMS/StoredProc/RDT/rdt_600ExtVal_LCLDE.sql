SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Store procedure: rdt_600ExtVal_LCLDE                                 */  
/* Purpose: Validate  UCC                                               */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2025-05-19 1.0  WSE016     Inital Code Dev.                          */  
/************************************************************************/  
CREATE or ALTER     PROC [RDT].[rdt_600ExtVal_LCLDE] (
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
SET QUOTED_IDENTIFIER OFF    
SET ANSI_NULLS OFF    
SET CONCAT_NULL_YIELDS_NULL OFF    
SET @nErrNo = 0   
Declare  
      @cCustomer      NVARCHAR(18),
      @cCustomer1      NVARCHAR(18)
   IF @nFunc = 600 -- Normal receiving
   BEGIN
      -- Prevent mixing Customer
      IF @nStep = 6
      BEGIN
         -- Get session info
         SELECT @nInputKey = InputKey FROM rdt.rdtMobRec WITH (NOLOCK) WHERE Mobile = @nMobile 
         IF @nInputKey = 1    
         BEGIN    
            -- If pallet not receive before then no need further check
            IF NOT EXISTS ( SELECT 1 FROM dbo.RECEIPTDETAIL RD WITH (NOLOCK)
                           WHERE ToId = @cID
                           GROUP BY RD.ReceiptKey
                           HAVING ISNULL( SUM( RD.BeforeReceivedQty), 0) > 0)
               GOTO Quit
            SELECT  TOP 1  @cCustomer = ISNULL(Lottable01,'')
            FROM dbo.ReceiptDetail RD WITH (NOLOCK)
            WHERE ToId = @cID
               AND   BeforeReceivedQty > 0
            SELECT  TOP 1  @cCustomer1 = ISNULL(Lottable01,'')
            FROM dbo.ReceiptDetail RD WITH (NOLOCK)
            WHERE Lottable03 = @cLottable03
            -- prevent to mix Customer
            IF @cCustomer <> @cCustomer1
            BEGIN
               SET @nErrNo = 218370
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --Mixed Customer on PLT
               GOTO Quit
            END 
         END    
   END
QUIT:  
END
GO


SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_600ExtVal_LCLDE TO NSQL
GO
