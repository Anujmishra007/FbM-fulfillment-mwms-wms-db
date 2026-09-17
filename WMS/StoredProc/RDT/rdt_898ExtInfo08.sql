SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_898ExtInfo08                                    */
/* Copyright      : Maersk                                              */
/* Customer       : Granite                                             */
/*                                                                      */
/* Date       Rev    Author  Purposes                                   */
/* 2024-10-07 1.0.0  NLT013  FCR-926 Created                            */
/* 2025-01-02 1.1.0  JCH507  FCR-1103 Adapt for extscn02                */
/* 2026-09-14 1.2.0  NickT   FCR-15183 Add new extended info for step3,6*/
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_898ExtInfo08]
    @nMobile       INT
   ,@nFunc         INT
   ,@cLangCode     NVARCHAR( 3)
   ,@nStep         INT
   ,@nAfterStep    INT
   ,@nInputKey     INT
   ,@cReceiptKey   NVARCHAR( 10)
   ,@cPOKey        NVARCHAR( 10)
   ,@cLOC          NVARCHAR( 10)
   ,@cToID         NVARCHAR( 18)
   ,@cLottable01   NVARCHAR( 18)
   ,@cLottable02   NVARCHAR( 18)
   ,@cLottable03   NVARCHAR( 18)
   ,@dLottable04   DATETIME
   ,@cUCC          NVARCHAR( 20)
   ,@cSKU          NVARCHAR( 20)
   ,@nQTY          INT
   ,@cParam1       NVARCHAR( 20)
   ,@cParam2       NVARCHAR( 20)
   ,@cParam3       NVARCHAR( 20)
   ,@cParam4       NVARCHAR( 20)
   ,@cParam5       NVARCHAR( 20)
   ,@cOption       NVARCHAR( 1)
   ,@cExtendedInfo NVARCHAR( 20) OUTPUT
   ,@nErrNo       INT            OUTPUT
   ,@cErrMsg      NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @cStorerKey                NVARCHAR(15),
      @cChannel                  NVARCHAR(20),
      @nReceivedUCCQty           INT,
      @nBalanceUCCQty            INT

   SELECT @cStorerKey = StorerKey
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   SET @cExtendedInfo = ''
   SET @cChannel= ''
   IF @nFunc = 898 -- UCC receiving   
    BEGIN  
      IF @nAfterStep = 3 -- palletID  
      BEGIN  
         SET @nBalanceUCCQty = 0
         SELECT @nBalanceUCCQty = COUNT(DISTINCT USERDEFINE01) 
         FROM dbo.Receiptdetail WITH (NOLOCK) 
         WHERE Storerkey = @cStorerKey 
            AND ReceiptKey = @cReceiptKey 
            AND BeforeReceivedQty = 0
            AND USERDEFINE01 IS NOT NULL
            AND USERDEFINE01 <> ''
         
         SET @nBalanceUCCQty = ISNULL(@nBalanceUCCQty, 0)
         
         SET @nReceivedUCCQty = 0

         SELECT @nReceivedUCCQty = COUNT(DISTINCT USERDEFINE01) 
         FROM dbo.Receiptdetail WITH (NOLOCK) 
         WHERE Storerkey = @cStorerKey 
            AND ReceiptKey = @cReceiptKey 
            AND BeforeReceivedQty > 0
            AND USERDEFINE01 IS NOT NULL
            AND USERDEFINE01 <> ''

         SET @nReceivedUCCQty = ISNULL(@nReceivedUCCQty, 0)

         -- Output balance/total  
         SET @cExtendedInfo = CONCAT('REC:',@nReceivedUCCQty,' BAL:',@nBalanceUCCQty) 
      END
      ELSE IF @nAfterStep = 6 -- UCC      
      BEGIN
         IF LEFT(@cToID, 2) <> 'DM'
         BEGIN
            SET @cLottable01 = ''
            SET @cChannel = ''
            SELECT 
               @cLottable01 = Lottable01,
               @cChannel = CHANNEL
            FROM dbo.ReceiptDetail WITH (NOLOCK)
            WHERE storerkey = @cStorerKey
               AND ReceiptKey = @cReceiptKey
               AND USERDEFINE01 IS NOT NULL
               AND USERDEFINE01 = @cUCC
            
            SET @cLottable01 = ISNULL(@cLottable01, '')
            SET @cChannel = ISNULL(@cChannel, '')

            SET @nBalanceUCCQty = 0
            SELECT @nBalanceUCCQty = COUNT(DISTINCT USERDEFINE01) 
            FROM dbo.Receiptdetail WITH (NOLOCK) 
            WHERE Storerkey = @cStorerKey 
               AND ReceiptKey = @cReceiptKey 
               AND BeforeReceivedQty = 0
               AND USERDEFINE01 IS NOT NULL
               AND USERDEFINE01 <> ''

            SET @nBalanceUCCQty = ISNULL(@nBalanceUCCQty, 0)

               -- Get ASN Lottables    
            SELECT  @cExtendedInfo = Concat(@cLottable01,'|',@cChannel,'|',@nBalanceUCCQty)
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

GRANT EXECUTE ON  [RDT].[rdt_898ExtInfo08] TO [NSQL]
GO
