SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_898ExtVal16                                     */
/* Copyright      : MAERSK                                              */
/*                                                                      */
/* Purpose: Validate PO Mix not allowed on pallet                       */
/*          Check if scanned ID already has inventory or receipt with   */
/*          different ExternPOKey                                       */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-06-03 1.0  Dennis     FCR-13584 Created                         */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_898ExtVal16 (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cReceiptKey  NVARCHAR( 10),
   @cPOKey       NVARCHAR( 10),
   @cLOC         NVARCHAR( 10),
   @cToID        NVARCHAR( 18),
   @cLottable01  NVARCHAR( 18),
   @cLottable02  NVARCHAR( 18),
   @cLottable03  NVARCHAR( 18),
   @dLottable04  DATETIME,
   @cUCC         NVARCHAR( 20),
   @cSKU         NVARCHAR( 20),
   @nQTY         INT,
   @cParam1      NVARCHAR( 20) OUTPUT,
   @cParam2      NVARCHAR( 20) OUTPUT,
   @cParam3      NVARCHAR( 20) OUTPUT,
   @cParam4      NVARCHAR( 20) OUTPUT,
   @cParam5      NVARCHAR( 20) OUTPUT,
   @cOption      NVARCHAR( 1),
   @nErrNo       INT           OUTPUT,
   @cErrMsg      NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cExternPOKey NVARCHAR( 30)
   DECLARE @nHasInventory INT = 0
   DECLARE @cStorerKey NVARCHAR( 15)

   -- Get StorerKey from rdtMobRec
   SELECT @cStorerKey = StorerKey
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 898 -- UCC Receiving
   BEGIN
      IF @nStep = 3 -- TO ID screen
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Get ExternPOKey from ReceiptDetail using scanned PO
            SELECT TOP 1 @cExternPOKey = Lottable06
            FROM dbo.ReceiptDetail WITH (NOLOCK)
            WHERE ReceiptKey = @cReceiptKey
               AND POKey = @cPOKey
               AND StorerKey = @cStorerKey
            ORDER BY AddDate DESC

            IF @cExternPOKey IS NULL
               SET @cExternPOKey = ''

            -- Check if pallet already has inventory in LOTxLOCxID with different PO
            IF EXISTS (
               SELECT 1
               FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
                  JOIN dbo.LOTAttribute LA WITH (NOLOCK) ON LLI.LOT = LA.LOT
               WHERE LLI.StorerKey = @cStorerKey
                  AND LLI.ID = @cToID
                  AND LLI.QTY - LLI.QTYPicked > 0
                  AND ISNULL(LA.Lottable06, '') <> @cExternPOKey
            )
            BEGIN
               SET @nErrNo = 268701
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- PO Mix not allowed
               GOTO Quit
            END

            -- Check if pallet has any inventory
            IF EXISTS (
               SELECT 1
               FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
               WHERE LLI.StorerKey = @cStorerKey
                  AND LLI.ID = @cToID
                  AND LLI.QTY - LLI.QTYPicked > 0
            )
               SET @nHasInventory = 1

            -- If no inventory, check if any receipt detail already received onto this pallet with different PO
            IF @nHasInventory = 0
            BEGIN
               IF EXISTS (
                  SELECT 1
                  FROM dbo.ReceiptDetail WITH (NOLOCK)
                  WHERE ReceiptKey = @cReceiptKey
                     AND ToID = @cToID
                     AND StorerKey = @cStorerKey
                     AND ISNULL(Lottable06, '') <> @cExternPOKey
               )
               BEGIN
                  SET @nErrNo = 268701
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- PO Mix not allowed
                  GOTO Quit
               END
            END
         END
      END
   END

Quit:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_898ExtVal16] TO nSQL
GO
