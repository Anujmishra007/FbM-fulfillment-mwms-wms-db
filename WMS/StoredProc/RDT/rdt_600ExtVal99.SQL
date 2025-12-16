SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_600ExtVal99                                     */
/* Copyright      : Maersk                                              */
/* Customer: ONBR                                                       */
/*                                                                      */
/* Date        Author   Ver.     Purposes                               */
/* 2025-09-19  1.0      elb012   Project Created                        */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_600ExtVal99](
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,           
   @nInputKey    INT,           
   @cFacility    NVARCHAR( 5), 
   @cStorerKey   NVARCHAR( 15), 
   @cReceiptKey  NVARCHAR( 10), 
   @cPOKey       NVARCHAR( 10), 
   @cLOC         NVARCHAR( 10), 
   @cID          NVARCHAR( 18), 
   @cSKU         NVARCHAR( 20), 
   @cLottable01  NVARCHAR( 18), 
   @cLottable02  NVARCHAR( 18), 
   @cLottable03  NVARCHAR( 18), 
   @dLottable04  DATETIME,      
   @dLottable05  DATETIME,      
   @cLottable06  NVARCHAR( 30), 
   @cLottable07  NVARCHAR( 30), 
   @cLottable08  NVARCHAR( 30), 
   @cLottable09  NVARCHAR( 30), 
   @cLottable10  NVARCHAR( 30), 
   @cLottable11  NVARCHAR( 30), 
   @cLottable12  NVARCHAR( 30), 
   @dLottable13  DATETIME,      
   @dLottable14  DATETIME,      
   @dLottable15  DATETIME,      
   @nQTY         INT,           
   @cReasonCode  NVARCHAR( 10), 
   @cSuggToLOC   NVARCHAR( 10), 
   @cFinalLOC    NVARCHAR( 10), 
   @cReceiptLineNumber NVARCHAR( 10), 
   @nErrNo       INT            OUTPUT, 
   @cErrMsg      NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
     @nSerialNo   INT
   , @cDBName     NVARCHAR(6)
   , @nEPC        INT
   , @cSerial     NVARCHAR(MAX)
   , @cCfgEnv     NVARCHAR(6)
   , @cExternKey  NVARCHAR( 10)
   , @nScreen     INT
   , @FromScn      INT

   --Get ExtReceiptKey
   SELECT @cExternKey = ISNULL(ExternReceiptKey,'')
     FROM dbo.RECEIPT WITH (NOLOCK)
    WHERE StorerKey = @cStorerKey
      AND ReceiptKey = @cReceiptKey

   IF @nFunc = 600
   BEGIN
      IF @nStep = 1
      BEGIN
        IF @nInputKey = 1
        BEGIN
         IF @cExternKey = ''
         BEGIN
               SET @nErrNo = 94753 
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Extern Key
               GOTO Quit
         END
        END
       END--End Step 1
   END
    IF @nStep IN (5, 6)
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
                SET @nErrNo = 233752 
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
                SET @nErrNo = 148052 
                SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --DIFF LOTTABLE01
                GOTO Quit
            END
      END
   END --600
Fail:
Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_600ExtVal99] TO [NSQL]
GO