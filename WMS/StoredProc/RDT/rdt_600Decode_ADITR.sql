SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/**************************************************************************************************/  
/* Store procedure: rdt_600Decode_ADITR                                                           */  
/* Copyright: Maersk                                                                              */  
/*                                                                                                */  
/* Purpose: Normal Receipt V7 decode SKU in case be possible for customer ADITR01                 */  
/*                                                                                                */  
/* Date        Author    Ver.  Purposes                                                           */  
/* 13-07-2026  AGA399    1.0   Created for autopopulate SKU if there is only one SKU              */  
/**************************************************************************************************/  
  
CREATE OR ALTER PROC [RDT].[rdt_600Decode_ADITR] (
   @nMobile      INT,  
   @nFunc        INT,  
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,  
   @nInputKey    INT,  
   @cStorerKey   NVARCHAR( 15),  
   @cReceiptKey  NVARCHAR( 10),  
   @cPOKey       NVARCHAR( 10),  
   @cLOC         NVARCHAR( 10),  
   @cBarcode     NVARCHAR( 2000)  OUTPUT,  
   @cFieldName   NVARCHAR( 10),  
   @cID          NVARCHAR( 18)  OUTPUT,  
   @cSKU         NVARCHAR( 20)  OUTPUT,  
   @nQTY         INT            OUTPUT,  
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
) AS  
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
DECLARE @nSKUCnt INT  
  
  
   IF @nFunc = 600 -- Normal receiving  
   BEGIN  
      IF @nStep = 3 -- SKU  
      BEGIN  
         IF @nInputKey = 1 -- ENTER  
         BEGIN  
             IF @cBarcode <> ''  
             BEGIN  
                SELECT @nSKUCnt = COUNT (DISTINCT SKU) FROM dbo.RECEIPTDETAIL WITH (NOLOCK) WHERE RECEIPTKEY = @cReceiptKey AND StorerKey = @cStorerKey AND POKey = @cPOKey  
                --If in the RECEIPTDETAIL there is only one Maersk SKU(LCLCASE or LCLPAL) preopulate it, in other case SKU field would be empty  
                IF @nSKUCnt = 1  
                BEGIN  
                    SELECT TOP 1 @cSKU = SKU FROM dbo.RECEIPTDETAIL WITH (NOLOCK) WHERE RECEIPTKEY = @cReceiptKey AND StorerKey = @cStorerKey AND POKey = @cPOKey  
                END  
             END  
         END  
      END --End Step 3  
   END  
     
  
Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON rdt.rdt_600Decode_ADITR TO NSQL
GO