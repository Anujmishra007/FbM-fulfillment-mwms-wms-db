SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_600ExtVal_MICHE                                 */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Purpose: Check empty pallet  for Michelin IDN                        */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2015-12-27 1.0  NYE018     FCR-9252 Created                          */
/************************************************************************/

CREATE OR ALTER   PROC [RDT].[rdt_600ExtVal_MICHE] (
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
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_cnt INT

   IF @nFunc = 600 -- Normal receiving
   BEGIN
   IF @nInputKey = 1
      BEGIN
      IF @nStep = 1
         BEGIN
            SELECT @n_cnt = count(1)
               FROM receiptdetail with(nolock)
            WHERE storerkey = @cStorerKey
               AND receiptkey = @cReceiptKey 
               AND (len(lottable02) <> 4 OR RDT.rdtIsInteger(lottable02) = 0)
               IF @n_cnt > 0
               BEGIN
                        SET @nErrNo = 254951
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- DOT should only 4 digits
                        GOTO Fail
               END


            SELECT @n_cnt = COUNT(1)
               FROM RECEIPTDETAIL rpdl WITH(NOLOCK)
            INNER JOIN STORER s WITH(NOLOCK) ON rpdl.storerkey = s.storerkey
            WHERE rpdl.ReceiptKey = @cReceiptKey
               AND rpdl.StorerKey  = @cStorerKey
               AND CAST(SUBSTRING(rpdl.Lottable02,3,2)+SUBSTRING(rpdl.Lottable02,1,2) AS INT) > CAST(RIGHT(STR(DATEPART(YEAR, GETDATE())),2) + REPLACE(STR(DATEPART(WEEK, GETDATE())),' ','') AS INT)
            IF @n_cnt > 0
            BEGIN
                  SET @nErrNo = 254953
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- DOT should not more than today 
                  GOTO Fail
            END
         END
      END
   END

Fail:
Quit:

END
GO

GRANT EXECUTE ON  [RDT].[rdt_600ExtVal_MICHE] TO [NSQL]
GO