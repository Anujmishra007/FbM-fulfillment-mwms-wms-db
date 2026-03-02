SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_898ExtInfo07                                    */
/* Copyright      : Maersk                                              */
/* Customer       : UAE Levis                                           */
/*                                                                      */
/* Date       Rev    Author  Purposes                                   */
/* 2026-02-25 1.0.0  NLT013  FCR-10628 Created                          */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_898ExtInfo07]
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

   SET @cExtendedInfo = ''

   DECLARE 
      @cStorerKey       NVARCHAR(20),
      @cFacility        NVARCHAR(10),
      @cDocType         NVARCHAR( 1),
      @nUCCCount        INT

   SELECT @cStorerKey = StorerKey,
      @cFacility = Facility
   FROM RDT.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   -- Get Receipt info
   SELECT @cDocType = DOCTYPE
   FROM dbo.Receipt WITH (NOLOCK)
   WHERE ReceiptKey = @cReceiptKey
      AND StorerKey = @cStorerKey
      AND Facility = @cFacility

   -- Only apply when DOCTYPE = 'A'
   IF @cDocType <> 'A'
      GOTO Quit

   IF @nFunc = 898 -- UCC receiving
   BEGIN
      IF @nAfterStep IN ( 6, 8, 9 ) -- UCC
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT @nUCCCount = COUNT(DISTINCT UCCNo)
            FROM dbo.UCC WITH (NOLOCK)
            WHERE ID = @cTOID
               AND ReceiptKey = @cReceiptKey
               AND StorerKey = @cStorerKey
               AND Status NOT IN ('5', '6', '9')

            SET @cExtendedInfo = 'Received UCC: ' +  CAST (@nUCCCount AS NVARCHAR(5))
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

GRANT EXECUTE ON  [RDT].[rdt_898ExtInfo07] TO [NSQL]
GO
