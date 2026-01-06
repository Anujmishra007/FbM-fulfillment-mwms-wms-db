

/******************************************************************************/
/* Store procedure: rdt_513ExtValVNM                                          */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: Vietnam MICHELIN                                                  */
/*                                                                            */
/* Date        Rev  Author   Purposes                                         */
/* 25-04-2025  1.0  PYU015   FCR-4216 Created                                 */
/******************************************************************************/

CREATE OR ALTER   PROCEDURE [RDT].[rdt_513ExtValVNM]
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cStorerKey      NVARCHAR( 15),
   @cFacility       NVARCHAR(  5),
   @cFromLOC        NVARCHAR( 10),
   @cFromID         NVARCHAR( 18),
   @cSKU            NVARCHAR( 20),
   @nQTY            INT,
   @cToID           NVARCHAR( 18),
   @cToLOC          NVARCHAR( 10),
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cNoMixLottable03 NVARCHAR(1)
   DECLARE @cComminglesku    NVARCHAR(1)
   DECLARE @cLocLevel        INT
   DECLARE @Cnt              INT
   DECLARE @cValidLottable03  NVARCHAR(30)
   DECLARE @cValid8Weeks      NVARCHAR(30)
   DECLARE @cValidPalletType  NVARCHAR(30)
   DECLARE @cValidMultiDeep   NVARCHAR(30)

   IF @nFunc = 513 -- Move by SKU
   BEGIN
      IF @nStep = 6 -- ToLOC
      BEGIN
         IF @nInputKey = 1 -- Enter
         BEGIN
            SELECT @cValidLottable03 = SValue
            FROM rdt.StorerConfig WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND Function_ID = 513
               AND ConfigKey = 'ValidLottable03'

            SELECT @cValid8Weeks = SValue
            FROM rdt.StorerConfig WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND Function_ID = 513
               AND ConfigKey = 'Valid8Weeks'

            SELECT @cValidPalletType = SValue
            FROM rdt.StorerConfig WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND Function_ID = 513
               AND ConfigKey = 'ValidPalletType'


            SELECT @cValidMultiDeep = SValue
            FROM rdt.StorerConfig WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND Function_ID = 513
               AND ConfigKey = 'ValidMultiDeep'


            SELECT @cNoMixLottable03 = NoMixLottable03,
                  @cComminglesku = CommingleSku,
                  @cLocLevel = LocLevel
            FROM LOC WITH(NOLOCK)
            WHERE LOC = @cToLOC


            --In the non empty destination location (ToLOC), if existing stock's lottable03 contains the sub inventory code which is different to the source lottable03 sub inventory code, 
            --the the move needs to be rejected. This happens under the pretense that ToLoc.NoMixedLottable03='1'.
            IF @cValidLottable03 = '1' AND @cNoMixLottable03 = '1'
            BEGIN
               SET @Cnt = 0
               SELECT @Cnt = COUNT(1)
               FROM LOTxLOCxID lli WITH(NOLOCK)
               INNER JOIN LOTATTRIBUTE attr WITH(NOLOCK) ON lli.Lot = attr.Lot
               WHERE lli.StorerKey = @cStorerKey
                  AND lli.Loc = @cToLOC
                  AND lli.Qty - lli.QtyPicked > 0
                  AND EXISTS (
                     SELECT 1
                     FROM LOTxLOCxID f WITH (NOLOCK)
                     INNER JOIN LOTATTRIBUTE attr1 WITH (NOLOCK) ON f.Lot = attr1.Lot
                     WHERE f.StorerKey = @cStorerKey
                        AND f.Loc = @cFromLOC
                        and f.Id  = @cFromID
                        AND f.Sku = @cSKU
                        and f.Qty > 0
                        AND attr.Lottable03 <> attr1.Lottable03
                         )

               IF @Cnt > 0
               BEGIN
                  SET @nErrNo = 219981 
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Diff Lot03
                  GOTO Quit
               END
            END

            --In the non empty destination location(ToLOC), if existing stock's DOT(lottable02) and expiry (lottable04) does not satisfy the "8 week rule"(See attached solution design document for DOT logic),
            --then the move needs to be rejected.
            IF @cValid8Weeks = '1'
            BEGIN
               SET @Cnt = 0
               SELECT @Cnt = COUNT(1)
               FROM LOTxLOCxID iil WITH(NOLOCK)
               INNER JOIN LOTATTRIBUTE attr WITH(NOLOCK) ON iil.Lot = attr.Lot
               WHERE iil.StorerKey = @cStorerKey
                  AND iil.Loc = @cToLOC
                  AND iil.Qty - iil.QtyPicked > 0
                  AND LEN(attr.lottable02) = 4
                  AND EXISTS(
                  SELECT 1
                     FROM LOTxLOCxID f WITH(NOLOCK)
                  INNER JOIN LOTATTRIBUTE attrf WITH(NOLOCK) ON f.lot = attrf.lot
                  WHERE f.StorerKey = @cStorerKey
                     AND f.Loc = @cFromLOC
                     AND f.Id  = @cFromID
                     AND f.Sku = @cSKU
                     AND f.Qty > 0
                     AND f.Sku = iil.Sku
                     AND (
                        SUBSTRING(attr.Lottable02,3,2) <> SUBSTRING(attrf.Lottable02,3,2)
                     OR  CAST(SUBSTRING(attr.Lottable02,1,2) AS int) < CAST(SUBSTRING(attrf.Lottable02,1,2) AS int) - 8
                     OR  CAST(SUBSTRING(attr.Lottable02,1,2) AS int) > CAST(SUBSTRING(attrf.Lottable02,1,2) AS int) + 8
                        )
                  )

               IF @Cnt > 0
               BEGIN
                  SET @nErrNo = 219982
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Not Meet 8 Week rule
                  GOTO Quit
               END
            END


            --If the non empty target location is a multideep location where loc.comminglesku=0 and existing stock is different to the source, then the move needs to be rejected.
            IF @cValidMultiDeep = '1' AND @cComminglesku =  '0' AND @cLocLevel > 1
            BEGIN
               SET @Cnt = 0
               SELECT @Cnt = COUNT(1)
               FROM LOTxLOCxID WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND Loc = @cToLOC
                  AND Qty - QtyPicked > 0
                  AND Sku <> @cSKU

               IF @Cnt > 0
               BEGIN
                  SET @nErrNo = 219983
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Diff Sku
                  GOTO Quit
               END
            END

            -- In the non empty destination location(ToLOC), if existing stock's sku.userdefine06(pallet type) is different to the source, then the move needs to be rejected.
            IF @cValidPalletType = '1'
            BEGIN
               SET @Cnt = 0
               SELECT @Cnt = COUNT(1)
               FROM LOTxLOCxID LLI WITH(NOLOCK)
               INNER JOIN SKU S WITH(NOLOCK) ON LLI.StorerKey = S.StorerKey AND LLI.Sku = S.Sku
               WHERE LLI.StorerKey = @cStorerKey
                  AND LLI.Loc = @cToLOC
                  AND LLI.Qty - LLI.QtyPicked > 0
                  AND EXISTS
                     (
                     SELECT 1
                        FROM SKU sku1 WITH (NOLOCK)
                        WHERE sku1.StorerKey = @cStorerKey
                        AND sku1.Sku = @cSKU
                        AND sku1.BUSR6 <> S.BUSR6
                     )
               IF @Cnt > 0
               BEGIN
                  SET @nErrNo = 219984
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Diff pallet type
                  GOTO Quit
               END   
            END
         END --inputkey=1
      END --step6
   END --fnc 513

   Quit:
END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_513ExtValVNM] TO NSQL
GO

