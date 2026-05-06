
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************************/
/* Store procedure: rdt_1819ExtValIDN                                                  */
/*                                                                                     */
/* Purpose: Vietnam MICHELIN                                                           */
/*                                                                                     */
/* Date        Rev  Author   Purposes                                                  */
/* 12-12-2025  1.0  PYU015   UWP-54107 Created                                         */
/***************************************************************************************/

CREATE OR ALTER   PROC [RDT].[rdt_1819ExtValIDN] (
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
) 
AS
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
   DECLARE @cValidDOTWeeks    NVARCHAR(30)
   DECLARE @cValidPalletType  NVARCHAR(30)
   DECLARE @cValidMultiDeep   NVARCHAR(30)
   DECLARE @cInField01        NVARCHAR(60)
   
   
   SELECT @cStorerKey = StorerKey
       ,  @cInField01 = I_Field01
   FROM rdt.RDTMOBREC WITH (NOLOCK) 
   WHERE Mobile = @nMobile

   IF @nFunc = 1819 -- Putaway by ID
   BEGIN
      IF @nStep = 2-- ToLoc
      OR (@nStep =  5 AND @cInField01 = '1')
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT @cValidLottable03 = SValue
              FROM rdt.StorerConfig WITH(NOLOCK)
             WHERE StorerKey = @cStorerKey
               AND Function_ID = @nFunc
               AND ConfigKey = 'ValidLottable03'

            SELECT @cValidDOTWeeks = SValue
              FROM rdt.StorerConfig WITH(NOLOCK)
             WHERE StorerKey = @cStorerKey
               AND Function_ID = @nFunc
               AND ConfigKey = 'ValidDOTWeeks'

            SELECT @cValidPalletType = SValue
              FROM rdt.StorerConfig WITH(NOLOCK)
             WHERE StorerKey = @cStorerKey
               AND Function_ID = @nFunc
               AND ConfigKey = 'ValidPalletType'


            SELECT @cValidMultiDeep = SValue
              FROM rdt.StorerConfig WITH(NOLOCK)
             WHERE StorerKey = @cStorerKey
               AND Function_ID = @nFunc
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
                  SET @nErrNo = 263751
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Diff Lot03
                  GOTO Quit
               END
            END

            IF @cValidDOTWeeks = '1'
            BEGIN
               IF dbo.fnc_GetDot_MichWeek_Mix_Rule(@cStorerKey,@cFromID,@cToLOC) = 0
               BEGIN
               SET @nErrNo = 263752
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Not Meet DOT Week rule
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
               SET @nErrNo = 263753
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
                  SET @nErrNo = 263754
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Diff pallet type
                  GOTO Quit
               END   
            END

            IF EXISTS(
                SELECT 1
                  FROM LOTxLOCxID WITH(NOLOCK)
                  WHERE StorerKey = @cStorerKey
                   AND Loc = @cToLOC
                   AND QtyAllocated > 0
            )
            BEGIN
                  SET @nErrNo = 263755
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Loc Alloc
                  GOTO Quit
            END

         END --Inputkey = 1
      END --step2
   END --1816

   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1819ExtValIDN TO NSQL
GO