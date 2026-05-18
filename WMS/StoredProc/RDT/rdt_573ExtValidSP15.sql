SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_573ExtValidSP15                                 */
/*                                                                      */
/* Customer: AMERICAN EAGLE Mexico                                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-05-06 1.0  JackC      FCR-12179 Created                         */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_573ExtValidSP15 (
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR(3),
   @nStep         INT,
   @cStorerKey    NVARCHAR(15),
   @cFacility     NVARCHAR(5),
   @cReceiptKey1  NVARCHAR(20),
   @cReceiptKey2  NVARCHAR(20),
   @cReceiptKey3  NVARCHAR(20),
   @cReceiptKey4  NVARCHAR(20),
   @cReceiptKey5  NVARCHAR(20),
   @cLoc          NVARCHAR(20),
   @cID           NVARCHAR(18),
   @cUCC          NVARCHAR(20),
   @nErrNo        INT          OUTPUT,
   @cErrMsg       NVARCHAR(20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nInputKey               INT
   DECLARE @cExistingPutawayZone    NVARCHAR(20)
   DECLARE @cNewPutawayZone         NVARCHAR(20)
   DECLARE @cUCCFromReceivedDetail  NVARCHAR(10)

   IF @nFunc = 573
   BEGIN
      IF @nStep = 4 -- UCC scan step
      BEGIN

         SELECT @nInputKey = InputKey FROM rdt.rdtMobRec WITH (NOLOCK) WHERE Mobile = @nMobile

         IF @nInputKey = 1 -- ENTER pressed
         BEGIN
            -- Check if UCCFromReceivedDetail config is enabled
            SET @cUCCFromReceivedDetail = rdt.RDTGetConfig(@nFunc, 'UCCFromReceivedDetail', @cStorerKey)

            IF ISNULL(@cUCCFromReceivedDetail, '0') <> '1'
            BEGIN
               SET @nErrNo = 265752
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END

            -- Step 1: Get existing Putaway Zone from pallet (within current session)
            SELECT TOP 1 @cExistingPutawayZone = SKU.PutawayZone
            FROM dbo.ReceiptDetail RD (NOLOCK)
            JOIN rdt.rdtConReceiveLog CRL (NOLOCK) ON RD.ReceiptKey = CRL.ReceiptKey
            JOIN dbo.SKU (NOLOCK) ON RD.StorerKey = SKU.StorerKey AND RD.SKU = SKU.SKU
            WHERE RD.ToID = @cID
              AND CRL.Mobile = @nMobile
            ORDER BY RD.ReceiptLineNumber

            -- Step 2: If pallet has items, compare with new SKU's zone
            IF @cExistingPutawayZone IS NOT NULL
            BEGIN
               SELECT TOP 1 @cNewPutawayZone = SKU.PutawayZone
               FROM dbo.ReceiptDetail RD (NOLOCK)
               JOIN rdt.rdtConReceiveLog CRL (NOLOCK) ON RD.ReceiptKey = CRL.ReceiptKey
               JOIN dbo.SKU (NOLOCK) ON RD.StorerKey = SKU.StorerKey AND RD.SKU = SKU.SKU
               WHERE RD.UserDefine01 = @cUCC
                 AND CRL.Mobile = @nMobile
               ORDER BY RD.ReceiptLineNumber

               IF @cExistingPutawayZone <> ISNULL(@cNewPutawayZone, '')
               BEGIN
                  SET @nErrNo = 265751
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END
            END --
         END
      END --step 4
   END --573

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_573ExtValidSP15 TO NSQL
GO
