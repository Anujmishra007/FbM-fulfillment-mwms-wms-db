SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO 

/******************************************************************************/            
/* Store procedure: rdt_1841ExtValid07                                        */            
/* Copyright      : MAERSK                                                    */            
/*                                                                            */            
/* Purpose: Check qty entered against receiptdetail.qtyexpected               */ 
/*          Switch 05 -> 07 (duplicate 05)                                    */
/*                                                                            */            
/*                                                                            */            
/* Date        Rev  Author       Purposes                                     */            
/* 2024-05-08  1.0  James        WMS-25413. Created                           */            
/******************************************************************************/            
            
CREATE OR ALTER PROCEDURE rdt.rdt_1841ExtValid07            
   @nMobile        INT,            
   @nFunc          INT,            
   @cLangCode      NVARCHAR( 3),            
   @nStep          INT,            
   @nAfterStep     INT,            
   @nInputKey      INT,            
   @cFacility      NVARCHAR( 5),             
   @cStorerKey     NVARCHAR( 15),            
   @cReceiptKey    NVARCHAR( 10),            
   @cLane          NVARCHAR( 10),            
   @cUCC           NVARCHAR( 20),            
   @cToID          NVARCHAR( 18),            
   @cSKU           NVARCHAR( 20),            
   @nQty           INT,            
   @cOption        NVARCHAR( 1),                           
   @cPosition      NVARCHAR( 20),            
   @tExtValidVar   VariableTable READONLY,             
   @nErrNo         INT           OUTPUT,             
   @cErrMsg        NVARCHAR( 20) OUTPUT            
AS            
BEGIN            
   SET NOCOUNT ON            
   SET QUOTED_IDENTIFIER OFF            
   SET ANSI_NULLS OFF            
   SET CONCAT_NULL_YIELDS_NULL OFF            
       
   DECLARE @nQtyExpected   INT = 0
   DECLARE @nQtySorted     INT = 0

   IF @nStep = 8 -- Qty          
   BEGIN          
      IF @nInputKey = 1 -- ENTER          
      BEGIN                  
         SELECT @nQtyExpected = ISNULL( SUM( QtyExpected), 0)
         FROM dbo.RECEIPTDETAIL WITH (NOLOCK)
         WHERE ReceiptKey = @cReceiptKey
         AND   SKU = @cSKU

         SELECT @nQtySorted = ISNULL( SUM( Qty), 0)
         FROM RDT.rdtPreReceiveSort WITH (NOLOCK) 
         WHERE ReceiptKey = @cReceiptKey
         AND   SKU = @cSKU
         AND   [Status] = '1'

         IF @nQtyExpected > 0 AND ( @nQtyExpected < (@nQty + @nQtySorted))
         BEGIN          
            SET @nErrNo = 214951          
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Exceed QtyExp          
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

GRANT EXECUTE ON RDT.rdt_1841ExtValid07 TO NSQL
GO  