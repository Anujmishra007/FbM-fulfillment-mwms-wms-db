SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_638ExtValid15                                   */
/* Purpose: COLUMBIA UK                                                 */
/*                                                                      */
/*                                                                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-01-28 1.0  Jackc      FCR-10307. Created                        */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_638ExtValid15] (
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @nStep         INT,
   @nInputKey     INT,
   @cFacility     NVARCHAR( 5),
   @cStorerKey    NVARCHAR( 15),
   @cReceiptKey   NVARCHAR( 10),
   @cRefNo        NVARCHAR( 60), 
   @cID           NVARCHAR( 18),
   @cLOC          NVARCHAR( 10),
   @cSKU          NVARCHAR( 20),
   @nQTY          INT,
   @cLottable01   NVARCHAR( 18),
   @cLottable02   NVARCHAR( 18),
   @cLottable03   NVARCHAR( 18),
   @dLottable04   DATETIME,
   @dLottable05   DATETIME,
   @cLottable06   NVARCHAR( 30),
   @cLottable07   NVARCHAR( 30),
   @cLottable08   NVARCHAR( 30),
   @cLottable09   NVARCHAR( 30),
   @cLottable10   NVARCHAR( 30),
   @cLottable11   NVARCHAR( 30),
   @cLottable12   NVARCHAR( 30),
   @dLottable13   DATETIME,
   @dLottable14   DATETIME,
   @dLottable15   DATETIME,
   @cData1        NVARCHAR( 60),
   @cData2        NVARCHAR( 60),
   @cData3        NVARCHAR( 60),
   @cData4        NVARCHAR( 60),
   @cData5        NVARCHAR( 60),
   @cOption       NVARCHAR( 1),
   @dArriveDate   DATETIME,
   @tExtUpdateVar VariableTable READONLY,
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cErrMsg1    NVARCHAR(20)
   DECLARE @cErrMsg2    NVARCHAR(125)
   DECLARE @cErrMsg3    NVARCHAR(125)
   /*DECLARE @cErrMsg4    NVARCHAR(20)
   DECLARE @cErrMsg5    NVARCHAR(20)
   DECLARE @cErrMsg6    NVARCHAR(20)
   DECLARE @cErrMsg7    NVARCHAR(20)
   DECLARE @cErrMsg8    NVARCHAR(20)
   DECLARE @cErrMsg9    NVARCHAR(20)
   DECLARE @cErrMsg10   NVARCHAR(20)
   DECLARE @cErrMsg11   NVARCHAR(20)
   DECLARE @cErrMsg12   NVARCHAR(20)
   DECLARE @cErrMsg13   NVARCHAR(20)
   DECLARE @cErrMsg14   NVARCHAR(20)
   DECLARE @cErrMsg15   NVARCHAR(20)*/
   DECLARE @cCLLong     NVARCHAR(250)

   SET @nErrNo = 0

   IF @nFunc = 638 -- ECOM return
   BEGIN
      IF @nStep = 3 -- SKU
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.SKU WITH (NOLOCK)
                           WHERE StorerKey = @cStorerKey
                              AND SKU = @cSKU
                              AND SUSR3 = 1
                           )
            BEGIN

               SELECT @cCLLong = LONG FROM dbo.CODELKUP 
               WHERE LISTNAME = 'CSCCAMBMSG' 
                  AND StorerKey = @cStorerKey

               IF @@ROWCOUNT = 0
                  SET @cCLLong = ''

               SET @cErrMsg1  = 'SKU ' + @cSKU
               SET @cErrMsg2  = SUBSTRING(@cCLLong, 1, 125)
               SET @cErrMsg3  = SUBSTRING(@cCLLong, 126, 125)

               EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT,    
                  @cLine01       = @cErrMsg1,
                  @cLine02       = @cErrMsg2,
                  @cLine03       = @cErrMsg3,
                  @nDisplayMsg   = 0 
               
               SET @nErrNo=0
            END        
         END   
      END
   END
   
Quit:
GO
GRANT EXECUTE ON  [RDT].[rdt_638ExtValid15] TO [NSQL]
GO
