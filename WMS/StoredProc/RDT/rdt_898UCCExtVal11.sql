SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Store procedure: rdt_898UCCExtVal11                                     */
/* Copyright      :                                                        */
/*                                                                         */
/* Date       Rev  Author  Purposes                                        */
/* 2025-11-26 1.0  Dennis  FCR-8723 . Created                              */
/***************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_898UCCExtVal11]
    @nMobile     INT
   ,@nFunc       INT
   ,@cLangCode   NVARCHAR(  3)
   ,@cReceiptKey NVARCHAR( 10)
   ,@cPOKey      NVARCHAR( 10)
   ,@cLOC        NVARCHAR( 10)
   ,@cToID       NVARCHAR( 18)
   ,@cLottable01 NVARCHAR( 18)
   ,@cLottable02 NVARCHAR( 18)
   ,@cLottable03 NVARCHAR( 18)
   ,@dLottable04 DATETIME
   ,@cUCC        NVARCHAR( 20)
   ,@nErrNo      INT           OUTPUT
   ,@cErrMsg     NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 898 -- UCC receiving
   BEGIN
      DECLARE  @cUSUCCValidation       NVARCHAR (30)
               , @cListName            NVARCHAR (28)
               , @cPrefixLength        VARCHAR (1)
               , @nDelimeterPosition   INT
               , @cStorerKey           NVARCHAR(15)
               , @cSKU                 NVARCHAR(20)
               , @cSKUSUSR1            NVARCHAR(18)
               , @cUCCUDF08            NVARCHAR(30)
               , @cUCCUDF09            NVARCHAR(30)
               , @cDocType             NVARCHAR(1)
               , @nRowCount            INT


      -- Get StorerKey
      SELECT @cStorerKey = StorerKey,@cDocType = DocType FROM Receipt WITH (NOLOCK) WHERE ReceiptKey = @cReceiptKey 

      IF @cDocType = 'R'
      BEGIN
         DECLARE @cStyle NVARCHAR(20)

         SELECT @cStyle = STYLE
         FROM dbo.SKU SKU WITH(NOLOCK) 
         WHERE SKU.SKU = @cSKU 
            AND SKU.StorerKey = @cStorerKey

         IF EXISTS(
            SELECT 1 FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK) 
            WHERE RD.ReceiptKey = @cReceiptKey 
               AND RD.StorerKey = @cStorerKey
         ) AND NOT EXISTS(
            SELECT 1 FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK) 
            JOIN SKU SKU WITH(NOLOCK) 
               ON RD.SKU = SKU.SKU AND RD.StorerKey = SKU.StorerKey
            WHERE RD.ReceiptKey = @cReceiptKey 
               AND RD.StorerKey = @cStorerKey
               AND SKU.STYLE = @cStyle
         )
         BEGIN
            SET @nErrNo = 225309 
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- SKUStyleDoesNotMatch
            GOTO Quit
         END
      END
   END

   GOTO Quit

Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_898UCCExtVal11] TO [NSQL]
GO
