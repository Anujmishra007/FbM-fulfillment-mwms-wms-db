SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/******************************************************************************/
/* Store procedure: rdt_600ExtInfoLCLDE                                       */
/* Copyright      : LF Logistics                                              */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 23-05-2025   WSE016       1.0   WMS-?                                      */
/******************************************************************************/
CREATE or ALTER   PROCEDURE [RDT].[rdt_600ExtInfoLCLDE]
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @nStep         INT,
   @nAfterStep    INT,
   @nInputKey     INT,
   @cFacility     NVARCHAR( 5),
   @cStorerKey    NVARCHAR( 15),
   @cReceiptKey   NVARCHAR( 10),
   @cPOKey        NVARCHAR( 10),
   @cLOC          NVARCHAR( 10),
   @cID           NVARCHAR( 18),
   @cSKU          NVARCHAR( 20),
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
   @nQTY         INT,
   @cReasonCode  NVARCHAR( 10),
   @cSuggToLOC   NVARCHAR( 10),
   @cFinalLOC    NVARCHAR( 10),
   @cReceiptLineNumber NVARCHAR( 10),
   @cExtendedInfo NVARCHAR(20)  OUTPUT,
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   IF @nFunc = 600 -- Normal receive v7
   BEGIN
      IF @nAfterStep = 6 -- QTY
      BEGIN
         IF @cSKU <> ''
         BEGIN
            -- Get expected, received QTY
            DECLARE @nQTYExp INT
            DECLARE @nQTYRcv INT
            SELECT 
               @nQTYExp = ISNULL( SUM( QTYExpected), 0), 
               @nQTYRcv = ISNULL( SUM( BeforeReceivedQTY), 0)
            FROM ReceiptDetail WITH (NOLOCK)
            WHERE ReceiptKey = @cReceiptKey
				AND Lottable03 = @cLottable03
				AND SKU = @cSKU
            DECLARE @cMsg NVARCHAR( 20) 
            SET @cMsg = rdt.rdtgetmessage( 218366, @cLangCode, 'DSP') --REC: 
            -- Show statistic
            SET @cExtendedInfo = 
			   --RTRIM( @cMsg) + ' ' + 
			     @cLottable03 +  ' ' +
               CAST( @nQTYRcv AS NVARCHAR(6)) + '/' + 
               CAST( @nQTYExp AS NVARCHAR(5))
         END
      END
   END
Quit:
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO   
GRANT EXECUTE ON [RDT].[rdt_600ExtInfoLCLDE] TO [NSQL]
