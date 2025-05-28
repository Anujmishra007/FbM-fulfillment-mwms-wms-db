
/************************************************************************/
/* Store procedure: rdt_1819ExtValVNM                                   */
/*                                                                      */
/* Purpose: Vietnam MICHELIN                                            */
/*                                                                      */
/* Date        Rev  Author   Purposes                                   */
/* 25-04-2025  1.0  PYU015   FCR-4226 Created                           */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1819ExtValVNM] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cFromID         NVARCHAR( 18),
   @cSuggLOC        NVARCHAR( 10),
   @cPickAndDropLOC NVARCHAR( 10),
   @cToLOC          NVARCHAR( 10),
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cStorerKey        NVARCHAR( 15)
   DECLARE @cNoMixLottable03  NVARCHAR(1)
   DECLARE @cComminglesku     NVARCHAR(1)
   DECLARE @cLocLevel         INT
   DECLARE @Cnt               INT
   DECLARE @cValidLottable03  NVARCHAR(30)
   DECLARE @cValid8Weeks      NVARCHAR(30)
   DECLARE @cValidPalletType  NVARCHAR(30)
   DECLARE @cValidMultiDeep   NVARCHAR(30)
   
   
   SELECT @cStorerKey = StorerKey
   FROM rdt.RDTMOBREC WITH (NOLOCK) 
   WHERE Mobile = @nMobile

   IF @nFunc = 1819 -- Putaway by ID
   BEGIN
      IF @nStep = 2 -- ToLoc
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT @cValidLottable03 = SValue
            FROM rdt.StorerConfig WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND Function_ID = 1819
               AND ConfigKey = 'ValidLottable03'

            SELECT @cValid8Weeks = SValue
            FROM rdt.StorerConfig WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
              AND Function_ID = 1819
              AND ConfigKey = 'Valid8Weeks'

            SELECT @cValidPalletType = SValue
            FROM rdt.StorerConfig WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND Function_ID = 1819
               AND ConfigKey = 'ValidPalletType'


            SELECT @cValidMultiDeep = SValue
            FROM rdt.StorerConfig WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND Function_ID = 1819
               AND ConfigKey = 'ValidMultiDeep'

            SELECT @cNoMixLottable03 = NoMixLottable03,
                  @cComminglesku = CommingleSku,
                  @cLocLevel = LocLevel
            FROM LOC WITH(NOLOCK)
            WHERE LOC = @cToLOC

            IF @cValidLottable03 = '1' AND @cNoMixLottable03 = '1'
            BEGIN
               SET @Cnt = 0
               SELECT @Cnt = COUNT(1)
               FROM LOTxLOCxID t WITH(NOLOCK)
               INNER JOIN LOTATTRIBUTE attr WITH(NOLOCK) ON t.Lot = attr.Lot
               WHERE t.StorerKey = @cStorerKey
                  AND t.Loc = @cToLOC
                  AND t.Qty - t.QtyPicked > 0
                  AND EXISTS (
                     SELECT 1
                     FROM LOTxLOCxID f
                     INNER JOIN LOTATTRIBUTE attr1 on f.Lot = attr1.Lot
                     WHERE f.StorerKey = @cStorerKey
                        and f.Id  = @cFromID
                        and f.Qty > 0
                        AND attr.Lottable03 <> attr1.Lottable03
                     )

               IF @Cnt > 0
               BEGIN
                  SET @nErrNo = 219971
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Diff Lot03
                  GOTO Quit
               END
            END

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
                     AND f.Id  = @cFromID
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
               SET @nErrNo = 219972
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Not Meet 8 Week rule
               GOTO Quit
               END
            END

            IF @cValidMultiDeep = '1' AND @cComminglesku =  '0' AND @cLocLevel > 1
            BEGIN
               SET @Cnt = 0
               SELECT @Cnt = COUNT(1)
               FROM LOTxLOCxID LLI WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
               AND Loc = @cToLOC
               AND Qty - QtyPicked > 0
               AND EXISTS(
                           SELECT 1
                           FROM LOTxLOCxID LLI1 WITH(NOLOCK)
                           WHERE LLI1.storerkey = @cStorerKey
                              AND LLI1.Id = @cFromID
                              AND LLI1.qty > 0
                              AND LLI1.sku <> LLI.sku
               )

               IF @Cnt > 0
               BEGIN
               SET @nErrNo = 219973
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Diff Sku
               GOTO Quit
               END            
            END

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
                        INNER JOIN LOTxLOCxID lli1 WITH (NOLOCK) 
                           ON sku1.Sku = lli1.sku AND sku1.StorerKey = lli1.storerkey
                        WHERE lli1.StorerKey = @cStorerKey
                           AND lli1.id = @cFromID
                           AND lli1.qty > 0
                           AND sku1.BUSR6 <> S.BUSR6
                     )
               IF @Cnt > 0
               BEGIN
                  SET @nErrNo = 219974
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Diff pallet type
                  GOTO Quit
               END   
            END
         END --Inputkey = 1
      END --step2
   END --1816

   Quit:
END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1819ExtValVNM] TO NSQL
GO

