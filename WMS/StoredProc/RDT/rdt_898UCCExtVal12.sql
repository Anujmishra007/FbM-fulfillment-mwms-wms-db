
/***************************************************************************/
/* Store procedure: rdt_898UCCExtVal12                                     */
/* Copyright      : Maersk                                                 */
/* Customer       : AMERICAN EAGLE Mexico                                  */
/*                                                                         */
/*                                                                         */
/* Date       Rev  Author  Purposes                                        */
/* 2025-05-21 1.0  Jackc   FCR-12177 created                               */
/***************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_898UCCExtVal12
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

   DECLARE @nStep       INT
   DECLARE @cStorerKey  NVARCHAR(15)

   SELECT @nStep = Step, 
          @cStorerKey = StorerKey
   FROM RDT.RDTMOBREC WITH (NOLOCK) 
   WHERE Mobile = @nMobile

   IF @nFunc = 898 -- UCC receiving
   BEGIN
      IF @nStep = 6
      BEGIN
         IF NOT EXISTS (SELECT 1 FROM dbo.ReceiptDetail WITH (NOLOCK) 
                         WHERE ReceiptKey = @cReceiptKey
                         AND StorerKey = @cStorerKey
                         AND UserDefine01 = @cUCC)
         BEGIN
            SET @nErrNo = 267251
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid UCC
            GOTO Quit
         END
      END   -- @nStep = 6
   END
   
   
Quit:

END
GO

GRANT EXECUTE ON rdt.rdt_898UCCExtVal12 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
