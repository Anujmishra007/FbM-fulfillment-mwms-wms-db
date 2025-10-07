SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1580ExtVal29                                    */
/* Copyright      : MAERSK                                              */
/*                                                                      */
/* Purpose: Allow certain group of ASN                                  */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2025-09-30 1.0  Ung        FCR-8040 Created                          */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_1580ExtVal29 (
   @nMobile      INT,
   @nFunc        INT,
   @nStep        INT,
   @nInputKey    INT,
   @cLangCode    NVARCHAR( 3),
   @cStorerkey   NVARCHAR( 15),
   @cReceiptKey  NVARCHAR( 10),
   @cPOKey       NVARCHAR( 10),
   @cExtASN      NVARCHAR( 20),
   @cToLOC       NVARCHAR( 10),
   @cToID        NVARCHAR( 18),
   @cLottable01  NVARCHAR( 18),
   @cLottable02  NVARCHAR( 18),
   @cLottable03  NVARCHAR( 18),
   @dLottable04  DATETIME,
   @cSKU         NVARCHAR( 20),
   @nQTY         INT,
   @nErrNo       INT           OUTPUT,
   @cErrMsg      NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 1580 -- Piece receiving
   BEGIN
      IF @nStep = 1 -- ASN
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Check specific ReceiptGroup
            IF NOT EXISTS( SELECT 1
               FROM dbo.Receipt WITH (NOLOCK)
               WHERE ReceiptKey = @cReceiptKey
                  AND ReceiptGroup IN (
                     SELECT Code 
                     FROM dbo.CodeLKUP WITH (NOLOCK) 
                     WHERE ListName = 'ReceiptGRP'
                        AND StorerKey = @cStorerKey
                        AND UDF01 = @nFunc))
            BEGIN
               SET @nErrNo = 248151
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid RcvGrp
               GOTO Quit
            END
         END
      END
   END         

   Quit:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [RDT].[rdt_1580ExtVal29] TO nSQL 
GO
