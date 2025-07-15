SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1581ExtVal07                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose:                                                             */
/* Modifications log:                                                   */
/* Date        Rev  Author      Purposes                                */
/* 2025-06-03  1.0  Dennis      FCR-4292                                */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1581ExtVal07
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

   DECLARE  @cReceiptType     NVARCHAR(10),
   @cMsg01                    NVARCHAR(20),
   @cMsg02                    NVARCHAR(20),
   @cMsg03                    NVARCHAR(20),
   @cMsg04                    NVARCHAR(20),
   @cMsg05                    NVARCHAR(20),
   @cMsg06                    NVARCHAR(20),
   @cMsg07                    NVARCHAR(20),
   @cMsg08                    NVARCHAR(20),
   @cMsg09                    NVARCHAR(20),
   @cMsg10                    NVARCHAR(20)

   IF @nFunc = 1581
   BEGIN
      -- Lottable
      IF @nStep = 4
      BEGIN
         IF @nInputKey = 1
         BEGIN
            SELECT TOP 1 @cReceiptType = PROCESSTYPE FROM dbo.Receipt (Nolock) WHERE RECEIPTKEY = @cReceiptKey
            IF @cReceiptType = 'R'
            BEGIN
               IF EXISTS ( SELECT 1 FROM DBO.RECEIPTDETAIL (NOLOCK) WHERE ReceiptKey = @cReceiptKey AND ToID = @cToID)
               AND NOT EXISTS ( SELECT 1 FROM DBO.RECEIPTDETAIL (NOLOCK) WHERE ReceiptKey = @cReceiptKey AND ToID = @cToID AND Lottable03 = @cLottable03)
               BEGIN
                  SET @nErrNo = -1
                  SET @cMsg01 = 'Lottable03 = '
                  SET @cMsg02 = @cLottable03
                  SET @cMsg03 = 'cannot be mixed'
                  SET @cMsg04 = 'in one Pallet'
                  EXEC rdt.rdtInsertMsgQueue @nMobile = @nMobile,
                     @nErrNo = @nErrNo,
                     @cErrMsg = @cErrMsg,
                     @cLine01 = @cMsg01,
                     @cLine02 = @cMsg02,
                     @cLine03 = @cMsg03,
                     @cLine04 = @cMsg04,
                     @cLine05 = @cMsg05,
                     @cLine06 = @cMsg06,
                     @cLine07 = @cMsg07,
                     @cLine08 = @cMsg08,
                     @cLine09 = @cMsg09,
                     @nDisplayMsg = 0
               END
            END
         END
      END

   END

Quit:
END
GO

GRANT EXECUTE ON rdt.rdt_1581ExtVal07 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
