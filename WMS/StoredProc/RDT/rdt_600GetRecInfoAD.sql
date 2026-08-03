SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************************************************************/  
/* Store procedure: rdt_600GetRecInfoAD                                                                                          */  
/* Copyright      : Maersk WMS                                                                                                   */  
/*                                                                                                                               */  
/* Date         Rev   Author   Purposes                                                                                          */  
/* 14-07-2026   1.0   AGA399   Auto populate Lottable03 equal to ExternPoKey                                                     */  
/*********************************************************************************************************************************/  
  
CREATE OR ALTER PROC [RDT].[rdt_600GetRecInfoAD]  
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
   @nQTY         INT         OUTPUT,   
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
  
   IF @nFunc = 600  
   BEGIN  
      IF @nStep = 4 AND @nInputKey = 1  
      BEGIN  
        SELECT @cLottable03 = ExternPoKey FROM Receiptdetail WITH (NOLOCK) WHERE receiptkey = @cReceiptKey AND StorerKey = @cStorerKey --IB NO  
      END --Step 4  
  
      --If user goes back from the step 6 to the step 5  
      IF @nStep = 6 AND @nInputKey = 0  
      BEGIN  
        SELECT @cLottable03 = ExternPoKey FROM Receiptdetail WITH (NOLOCK) WHERE receiptkey = @cReceiptKey AND StorerKey = @cStorerKey --IB NO  
      END --Step 6  
  
   END  
END -- End Procedure  

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON rdt.rdt_600GetRecInfoAD TO NSQL
GO