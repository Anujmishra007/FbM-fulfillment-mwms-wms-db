SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: rdt_898ExtVal14                                        */
/* Copyright      : Maersk WMS                                             */
/* Customer       : ONBR                                                   */
/*                                                                         */
/* Date       Rev    Author    Purposes                                    */
/* 2025-11-27 1.0    NickT     UWP-45365 Merge code, created by psj036     */
/***************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_898ExtVal14]
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
   SELECT 
      @cExternKey = ISNULL(ExternReceiptKey,''),
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
            -- Lottable02
            IF NOT EXISTS 
            (
                SELECT 1 
                FROM DBO.CODELKUP WITH(NOLOCK)
                WHERE Storerkey = @cStorerKey
                  AND LISTNAME = 'HOSTWHCODE'
                  AND CODE = @cLottable02
            )
            BEGIN
                SET @nErrNo = 253251
                SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --DIFF LOTTABLE02
                GOTO Quit
            END

            -- Lottable01
            IF NOT EXISTS
            (
                SELECT 1 
                FROM DBO.CODELKUP WITH(NOLOCK)
                WHERE Storerkey = @cStorerKey
                  AND LISTNAME = 'LOT01LIST'
                  AND CODE = @cLottable01
            )
            BEGIN
                SET @nErrNo = 253252 
                SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --DIFF LOTTABLE01
                GOTO Quit
            END
         END
      END -- step 5
      ELSE IF @nStep = 8
      BEGIN
         IF NOT EXISTS (SELECT 1 FROM DBO.RECEIPTDETAIL (NOLOCK) WHERE ReceiptKey = @cReceiptKey AND SKU = @cSKU AND StorerKey = @cStorerKey AND QTYExpected > QTYRECEIVED )
         AND @cDocType = 'R'
         BEGIN
            SET @nErrNo = 253253
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

GRANT EXECUTE ON rdt.rdt_898ExtVal14 TO NSQL
GO

