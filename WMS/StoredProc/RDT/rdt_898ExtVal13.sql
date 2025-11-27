SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: rdt_898ExtVal13                                        */
/* Copyright      : Maersk WMS                                             */
/* Customer       : Granite                                                */
/*                                                                         */
/* Date       Rev    Author     Purposes                                   */
/* 2025-11-21 1.1.0  Dennis     FCR-8723 Sku validation                    */
/***************************************************************************/

CREATE OR ALTER   PROCEDURE [RDT].[rdt_898ExtVal13]
    @nMobile     INT
   ,@nFunc       INT
   ,@cLangCode   NVARCHAR(  3)
   ,@nStep       INT
   ,@nInputKey   INT
   ,@cReceiptKey NVARCHAR( 10)
   ,@cPOKey      NVARCHAR( 10)
   ,@cLOC        NVARCHAR( 10)
   ,@cToID       NVARCHAR( 18)
   ,@cLottable01 NVARCHAR( 18)
   ,@cLottable02 NVARCHAR( 18)
   ,@cLottable03 NVARCHAR( 18)
   ,@dLottable04 DATETIME
   ,@cUCC        NVARCHAR( 20)
   ,@cSKU        NVARCHAR( 20)
   ,@nQTY        INT
   ,@cParam1     NVARCHAR( 20) OUTPUT
   ,@cParam2     NVARCHAR( 20) OUTPUT
   ,@cParam3     NVARCHAR( 20) OUTPUT
   ,@cParam4     NVARCHAR( 20) OUTPUT
   ,@cParam5     NVARCHAR( 20) OUTPUT
   ,@cOption     NVARCHAR( 1)
   ,@nErrNo      INT       OUTPUT
   ,@cErrMsg     NVARCHAR( 20) OUTPUT 
AS
BEGIN
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE
      @cFacility        NVARCHAR( 5),  
      @cStorerKey       NVARCHAR( 15)

   SELECT @cStorerKey = StorerKey,
      @cFacility = Facility
   FROM rdt.rdtMobRec WITH (NOLOCK) 
   WHERE Mobile = @nMobile 

   IF @nFunc = 898
   BEGIN
      IF @nStep = 8 -- SKU
      BEGIN 
         IF @nInputKey = 1
         BEGIN
            IF EXISTS(SELECT 1 FROM RECEIPT WHERE ReceiptKey = @cReceiptKey AND StorerKey = @cStorerKey AND DocType ='R')
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
                  WHERE RD.ReceiptKey = @cReceiptKey 
                     AND RD.StorerKey = @cStorerKey
                     AND RD.UserDefine10 = @cStyle
               )
               BEGIN
                  SET @nErrNo = 225309 
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- SKUStyleDoesNotMatch
                  GOTO Quit
               END
            END
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

GRANT EXECUTE ON rdt.rdt_898ExtVal13 TO NSQL
GO