SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: rdt_898ExtVal99_ONBR                                   */
/* Copyright      : Maersk WMS                                             */
/* Customer       : ONBR                                                   */
/*                                                                         */
/* Date       Rev    Author     Purposes                                   */
/* 2025-11-27 1.0    Dennis     FCR-9273 Created                           */
/***************************************************************************/

CREATE OR ALTER   PROCEDURE [RDT].[rdt_898ExtVal99_ONBR]
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
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @cStorerKey  NVARCHAR( 15),
     @cExternKey  NVARCHAR( 10),
     @cDocType    NVARCHAR( 1)

   SELECT @cStorerKey = StorerKey
   FROM rdt.RDTMOBREC WITH (NOLOCK) 
   WHERE Mobile = @nMobile 

   --Get ExtReceiptKey
   SELECT @cExternKey = ISNULL(ExternReceiptKey,''),
          @cDocType = ISNULL(DOCTYPE,'')
     FROM dbo.RECEIPT WITH (NOLOCK)
    WHERE StorerKey = @cStorerKey
      AND ReceiptKey = @cReceiptKey
 
   IF @nFunc = 898
   BEGIN
      IF @nStep = 5   
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @cLottable02 NOT IN 
            (SELECT CODE 
               FROM CODELKUP WITH(NOLOCK)
               WHERE Storerkey = @cStorerKey
               AND LISTNAME = 'HOSTWHCODE')
            BEGIN
               SET @nErrNo = 233752 
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DIFF Lottable02
               GOTO Quit
            END
         END
      END --st5
      ELSE IF @nStep = 8
      BEGIN
         IF NOT EXISTS (SELECT 1 FROM RECEIPTDETAIL (NOLOCK) WHERE ReceiptKey = @cReceiptKey AND SKU = @cSKU AND StorerKey = @cStorerKey AND QTYExpected > QTYRECEIVED )
         AND @cDocType = 'R'
         BEGIN
            SET @nErrNo = 252251 
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid SKU
            GOTO Quit
         END
      END
   END --898

Quit:

END


GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_898ExtVal99_ONBR TO NSQL
GO