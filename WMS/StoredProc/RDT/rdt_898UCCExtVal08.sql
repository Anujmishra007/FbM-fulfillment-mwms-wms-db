SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Store procedure: rdt_898UCCExtVal08                                     */
/* Copyright      : LF Logistics                                           */
/*                                                                         */
/* Date       Rev  Author  Purposes                                        */
/* 2023-11-12 1.0  YeeKung WMS-24078. Created                              */
/***************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_898UCCExtVal08]
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

   IF @nFunc = 898 -- UCC receiving
   BEGIN
      

      DECLARE @cStorerKey  NVARCHAR( 15)
      DECLARE @cUCCUDF03   NVARCHAR( 20)
      DECLARE @cExterKey   NVARCHAR( 20)

      -- Get StorerKey
      SELECT @cStorerKey = StorerKey FROM Receipt WITH (NOLOCK) WHERE ReceiptKey = @cReceiptKey


      -- Get UCC info
      SELECT 
         @cUCCUDF03 = UserDefined03, 
         @cExterKey = ExternKey
      FROM dbo.UCC WITH (NOLOCK) 
      WHERE StorerKey = @cStorerKey 
         AND UCCNo = @cUCC

      -- Check UCC format
      IF @@ROWCOUNT > 0
      BEGIN
         IF ISNULL( @cUCCUDF03, '') <> '' -- (james01)
         BEGIN
            -- Get ReceiptDetail info
            IF NOT EXISTS( SELECT TOP 1 1 
               FROM dbo.ReceiptDetail WITH (NOLOCK) 
               WHERE ReceiptKey = @cReceiptKey
                  AND RTRIM( UserDefine03) + RTRIM( UserDefine02) = @cUCCUDF03)
            BEGIN
               SET @nErrNo = 208701
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UDF3 Not In RD
               GOTO Quit
            END
         END
      
         -- Check ExternKey in ASN
         IF @cExterKey <> ''
            IF NOT EXISTS( SELECT TOP 1 1 
               FROM dbo.ReceiptDetail WITH (NOLOCK) 
               WHERE ReceiptKey = @cReceiptKey
                  AND ExternReceiptKey = @cExterKey)
            BEGIN
               SET @nErrNo = 208702
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ExtKey NotInRD
               GOTO Quit
            END

         
         IF  EXISTS( SELECT 1
                     FROM UCC UCC
                        LEFT JOIN Receiptdetail RD on UCC.SourceKey = concat(RD.ReceiptKey, RD.ReceiptLineNumber) 
                     WHERE UCC.Storerkey = @cStorerKey
                        AND UCC.UCCNo = @cUCC
                        AND  UCC.Sourcetype = 'ASN'
                     Group by UCC.UCCNo, UCC.SKU
                     HAVING COUNT(Distinct Lottable03) > 1 OR COUNT(Distinct Lottable08) > 1
                     )   
         BEGIN
            SET @nErrNo = 208703
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NotMixUCCLot
            GOTO QUIT
         END
      END



   END

   GOTO Quit

Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_898UCCExtVal08] TO [NSQL]
GO
