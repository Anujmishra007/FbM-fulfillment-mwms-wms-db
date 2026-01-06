
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_605ExtValidSP03                                 */
/*                                                                      */
/* Customer: Indonesia-MICHELIN                                         */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2026-01-05  1.0  Jackc       FCR-9215 Created                        */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_605ExtValidSP03] (
   @nMobile      INT,          
   @nFunc        INT,          
   @cLangCode    NVARCHAR( 3), 
   @nStep        INT,          
   @nInputKey    INT,          
   @cFacility    NVARCHAR( 5), 
   @cStorerKey   NVARCHAR( 15),
   @cReceiptKey  NVARCHAR( 10),
   @cRefNo       NVARCHAR( 20),
   @cID          NVARCHAR( 18),
   @nErrNo             INT            OUTPUT,
   @cErrMsg            NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag        INT = 0

   DECLARE @cExternReceiptKey NVARCHAR(20)
   DECLARE @cOldestDOT        NVARCHAR(4)
   DECLARE @cNewestDOT        NVARCHAR(4)
   DECLARE @cSKU              NVARCHAR(20)
   DECLARE @cSUSR4            NVARCHAR(18)
   DECLARE @nSumSNQty         INT
   DECLARE @nSumRPDQty        INT
   DECLARE @nOldestYear       INT 
   DECLARE @nOldestWeek       INT
   DECLARE @nNewestYear       INT
   DECLARE @nNewestWeek       INT
   DECLARE @nWeekDiff         INT

   IF @nFunc = 605
   BEGIN
      IF @nInputKey = 1
      BEGIN
         IF @nStep = 1
         BEGIN
            IF ISNULL(@cReceiptKey, '') = ''
               SELECT @cReceiptKey    = RTRIM(LTRIM(ISNULL(ReceiptKey, '')))
               FROM ReceiptDetail WITH (NOLOCK)
               WHERE ExternReceiptKey = @cRefNo
                  AND StorerKey = @cStorerKey

            SELECT @nSumSNQty = SUM(SN.Qty) 
            FROM dbo.SerialNO SN WITH (NOLOCK)
            JOIN dbo.ReceiptDetail RD WITH (NOLOCK)
               ON SN.StorerKey = RD.StorerKey
               AND SN.UserDefine01 = RD.Lottable01
               AND SN.UserDefine02 = RD.ExternLineNo
            WHERE RD.ReceiptKey = @cReceiptKey
               AND RD.StorerKey = @cStorerKey

            SELECT 
               @nSumRPDQty = SUM(QTYExpected),
               @cSKU       = MAX(SKU)
            FROM dbo.ReceiptDetail WITH (NOLOCK)
            WHERE ReceiptKey = @cReceiptKey
               AND StorerKey = @cStorerKey

            IF ISNULL(@nSumSNQty, 0) = 0
            BEGIN
               SET @nErrNo = 255401
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END

            IF @nSumSNQty <> @nSumRPDQty
            BEGIN
               SET @nErrNo = 255402
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END

            SELECT TOP 1 @cOldestDOT = Lottable02
            FROM dbo.ReceiptDetail WITH (NOLOCK)
            WHERE ReceiptKey = @cReceiptKey 
               AND StorerKey = @cStorerKey 
               AND ISNUMERIC(Lottable02) = 1 
               AND LEN(Lottable02) = 4
            ORDER BY CAST(RIGHT(Lottable02,2) + LEFT(Lottable02,2) AS INT) ASC

            SELECT TOP 1 @cNewestDOT = Lottable02
            FROM dbo.ReceiptDetail WITH (NOLOCK)
            WHERE ReceiptKey = @cReceiptKey 
               AND StorerKey = @cStorerKey 
               AND ISNUMERIC(Lottable02) = 1 
               AND LEN(Lottable02) = 4
            ORDER BY CAST(RIGHT(Lottable02,2) + LEFT(Lottable02,2) AS INT) DESC

            IF ISNULL(@cOldestDOT,'') = '' OR ISNULL(@cNewestDOT,'') = ''
            BEGIN
               SET @nErrNo = 255403
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END

            IF @nDebugFlag = 1
               SELECT @cNewestDOT AS NewestDOT, @cOldestDOT AS cOldestDOT

            IF ISNUMERIC(@cOldestDOT) = 1 AND ISNUMERIC(@cNewestDOT) = 1 AND LEN(@cOldestDOT) = 4 AND LEN(@cNewestDOT) = 4
            BEGIN
               SET @nOldestWeek = CAST(LEFT(@cOldestDOT,2) AS INT)
               SET @nOldestYear = CAST(RIGHT(@cOldestDOT,2) AS INT)
               SET @nNewestWeek = CAST(LEFT(@cNewestDOT,2) AS INT)
               SET @nNewestYear = CAST(RIGHT(@cNewestDOT,2) AS INT)
               IF @nNewestYear > @nOldestYear
                  SET @nWeekDiff = (@nNewestYear - @nOldestYear) * 52 + (@nNewestWeek - @nOldestWeek)
               ELSE
                  SET @nWeekDiff = @nNewestWeek - @nOldestWeek
            END
            ELSE
            BEGIN
               SET @nErrNo = 255404
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END

            SELECT @cSUSR4 = SUSR4 
            FROM SKU WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND SKU = @cSKU

            IF @@ROWCOUNT > 0 AND ISNULL(@cSUSR4,'') = ''
               SET @cSUSR4 = '0'

            IF ISNUMERIC (@cSUSR4) <> 1
            BEGIN
               SET @nErrNo = 255405
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END

            IF @nWeekDiff > CAST(@cSUSR4 AS INT) AND @cSUSR4 <> '0'
            BEGIN
               SET @nErrNo = 255406
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END 
         END--st1
      END --Enter
   END --605
END

Quit:    
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_605ExtValidSP03 to nSQL
GO
