
/***************************************************************************/
/* Store procedure: rdt_898ExtVal15                                        */
/* Copyright      : Maersk WMS                                             */
/* Customer       : AMERICAN EAGLE Mexico                                  */
/*                                                                         */
/* Date       Rev    Author    Purposes                                    */
/* 2026-05-21 1.0    Jackc     FCR-12177 Created                           */
/***************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_898ExtVal15]
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

   DECLARE @cStorerKey  NVARCHAR( 15)

   SELECT @cStorerKey = StorerKey
   FROM rdt.RDTMOBREC WITH (NOLOCK) 
   WHERE Mobile = @nMobile 
 
   IF @nFunc = 898
   BEGIN
      IF @nStep = 8
      BEGIN
         IF NOT EXISTS (SELECT 1 FROM dbo.RECEIPTDETAIL WITH (NOLOCK) 
                        WHERE ReceiptKey = @cReceiptKey 
                        AND SKU = @cSKU 
                        AND StorerKey = @cStorerKey 
                        AND UserDefine01 = @cUCC )
         BEGIN
            SET @nErrNo = 267301
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU not match
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

GRANT EXECUTE ON rdt.rdt_898ExtVal15 TO NSQL
GO

