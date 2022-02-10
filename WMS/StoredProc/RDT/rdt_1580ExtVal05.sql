IF EXISTS (SELECT name FROM sysobjects WHERE name = 'rdt_1580ExtVal05' AND type = 'P')
   DROP PROC rdt.rdt_1580ExtVal05
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/
/* Store procedure: rdt_1580ExtVal05                                    */
/* Copyright      : LF logistics                                        */
/*                                                                      */
/* Purpose: check mix SKU on carton (L01)                               */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author      Purposes                                */
/* 17-03-2017  1.0  Ung         WMS-1364 Created                        */
/************************************************************************/

CREATE PROCEDURE rdt.rdt_1580ExtVal05
    @nMobile      INT
   ,@nFunc        INT
   ,@nStep        INT
   ,@nInputKey    INT
   ,@cLangCode    NVARCHAR( 3)
   ,@cStorerKey   NVARCHAR( 15)
   ,@cReceiptKey  NVARCHAR( 10) 
   ,@cPOKey       NVARCHAR( 10) 
   ,@cExtASN      NVARCHAR( 20)
   ,@cToLOC       NVARCHAR( 10) 
   ,@cToID        NVARCHAR( 18) 
   ,@cLottable01  NVARCHAR( 18) 
   ,@cLottable02  NVARCHAR( 18) 
   ,@cLottable03  NVARCHAR( 18) 
   ,@dLottable04  DATETIME  
   ,@cSKU         NVARCHAR( 20) 
   ,@nQTY         INT
   ,@nErrNo       INT           OUTPUT 
   ,@cErrMsg      NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   IF @nStep = 5 -- SKU QTY
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         -- Get receipt info
         DECLARE @cDocType NVARCHAR(1)
         SELECT @cDocType = DocType FROM Receipt WITH (NOLOCK) WHERE ReceiptKey = @cReceiptKey
         
         IF @cDocType = 'A' AND @cLottable01 <> ''
         BEGIN
            -- Check mix SKU in carton (L01)
            IF EXISTS( SELECT TOP 1 1 
               FROM ReceiptDetail WITH (NOLOCK) 
               WHERE ReceiptKey = @cReceiptKey 
                  AND Lottable01 = @cLottable01
                  AND SKU <> @cSKU
                  AND BeforeReceivedQTY > 0)
            BEGIN
               SET @nErrNo = 106951
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Mix SKU in CTN
               GOTO Quit
            END
         END
      END
   END

Quit:
END
GO

GRANT EXECUTE ON rdt.rdt_1580ExtVal05 TO NSQL 
GO   

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
