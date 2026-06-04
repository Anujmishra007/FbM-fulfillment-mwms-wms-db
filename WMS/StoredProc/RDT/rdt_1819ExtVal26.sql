SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1819ExtVal26                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Customer: DAIMLER TRUCK AG                                           */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Ver.  Author      Purposes                               */
/* 2026-06-03  1.0   NickT       FCR-12893. Created                     */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1819ExtVal26]
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
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @cFacility              NVARCHAR( 5),
      @cStorerKey             NVARCHAR( 15),
      @cVAS                   NVARCHAR(10) = 'VAS',
      @cPND                   NVARCHAR(10) = 'PND',
      @cDAM                   NVARCHAR(3) = 'DAM',
      @cPNDMEZZA              NVARCHAR(10) = 'PND-MEZZA',
      @cLottable02            NVARCHAR(18),
      @cLocationType          NVARCHAR(10),
      @cPickAndDropLOCAisle   NVARCHAR(10),
      @cLocAisle              NVARCHAR(10),
      @cSKU                   NVARCHAR(20),
      @cConditionCode         NVARCHAR(10),
      @nSKUQty                INT,
      @nUCCQty                INT,
      @nLottable02Qty         INT,
      @nDAMPallet             INT,
      @nRowCount              INT,
      @nContainGOO            INT,
      @nContainOtherThanGOO   INT

   -- Change ID
   IF @nFunc = 1819
   BEGIN
      SELECT @cStorerKey = StorerKey,
         @cFacility = Facility
      FROM rdt.RDTMOBREC WITH(NOLOCK)
      WHERE Mobile = @nMobile

      IF @nStep = 1 --FromID
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SET @nDAMPallet = 0

            SELECT @cConditionCode = ISNULL(ConditionCode, '')
            FROM dbo.RECEIPTDETAIL WITH(NOLOCK)
            WHERE ID = @cFromID
               AND StorerKey = @cStorerKey

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount = 0
            BEGIN
               SET @nErrNo = 268451
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID does not exist in ReceiptDetail
               GOTO Quit
            END

            IF @cConditionCode = @cDAM
            BEGIN
               SET @nDAMPallet = 1
            END

            SET @nContainGOO = 0
            SET @nContainOtherThanGOO = 0
            IF EXISTS(SELECT 1
                     FROM dbo.LOTATTRIBUTE LA WITH(NOLOCK)
                     INNER JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK) 
                        ON LA.Lot = LLI.Lot
                        AND LA.StorerKey = LLI.StorerKey
                        AND LA.Sku = LLI.Sku
                     WHERE LLI.StorerKey = @cStorerKey
                        AND LLI.ID = @cFromID
                        AND (LLI.Qty - LLI.QtyPicked - LLI.QtyPickInProcess > 0)
                        AND ISNULL(LA.LOTTABLE02, '') = 'GOO'
                     )
            BEGIN
               SET @nContainGOO = 1
            END

            IF EXISTS(SELECT 1
                     FROM dbo.LOTATTRIBUTE LA WITH(NOLOCK)
                     INNER JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK) 
                        ON LA.Lot = LLI.Lot
                        AND LA.StorerKey = LLI.StorerKey
                        AND LA.Sku = LLI.Sku
                     WHERE LLI.StorerKey = @cStorerKey
                        AND LLI.ID = @cFromID
                        AND (LLI.Qty - LLI.QtyPicked - LLI.QtyPickInProcess > 0)
                        AND ISNULL(LA.LOTTABLE02, '') <> 'GOO'
                     )
            BEGIN
               SET @nContainOtherThanGOO = 1
            END

            IF ISNULL(@nDAMPallet, 0) = 1
            BEGIN
               IF @nContainGOO = 1
               BEGIN
                  SET @nErrNo = 268452
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Not allow mix GOO and DAM inventory
                  GOTO Quit
               END

               IF EXISTS(SELECT 1
                     FROM dbo.LOTATTRIBUTE LA WITH(NOLOCK)
                     INNER JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK) 
                        ON LA.Lot = LLI.Lot
                        AND LA.StorerKey = LLI.StorerKey
                        AND LA.Sku = LLI.Sku
                     WHERE LLI.StorerKey = @cStorerKey
                        AND LLI.ID = @cFromID
                        AND (LLI.Qty - LLI.QtyPicked - LLI.QtyPickInProcess > 0)
                        AND ISNULL(LA.LOTTABLE02, '') <> @cDAM
                     )
               BEGIN
                  SET @nErrNo = 268455
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Not allow mix None-DAM and DAM inventory
                  GOTO Quit
               END
            END

            IF @nContainGOO = 1
            BEGIN
               IF @nContainOtherThanGOO = 1
               BEGIN
                  SET @nErrNo = 268454
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Not allow mix GOO and non-GOO inventory
                  GOTO Quit
               END

               --A pallet either has mono-SKU UCCs or multi-SKU UCCs or Loose inventory, but never a MIX.
               DECLARE 
                  @nMonoSKU_UCC        INT, 
                  @nMultiSKU_UCC       INT, 
                  @nLooseInv           INT
               
               SELECT @nMonoSKU_UCC = COUNT(*)
               FROM (
                  SELECT UCCNo
                  FROM dbo.UCC WITH(NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND ID = @cFromID
                  GROUP BY UCCNo
                  HAVING COUNT(DISTINCT SKU) = 1
               ) AS MonoSKU
               
               SET @nMonoSKU_UCC = ISNULL(@nMonoSKU_UCC, 0)

               SELECT @nMultiSKU_UCC = COUNT(*)
               FROM (
                  SELECT UCCNo
                  FROM dbo.UCC WITH(NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND ID = @cFromID
                  GROUP BY UCCNo
                  HAVING COUNT(DISTINCT SKU) > 1
               ) AS MultiSKU

               SET @nMultiSKU_UCC = ISNULL(@nMultiSKU_UCC, 0)

               SELECT @nLooseInv = COUNT(*)
               FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
               WHERE LLI.StorerKey = @cStorerKey
               AND LLI.ID = @cFromID
               AND (LLI.Qty - LLI.QtyPicked - LLI.QtyPickInProcess > 0)
               AND NOT EXISTS (
                     SELECT 1 FROM dbo.UCC WITH(NOLOCK)
                     WHERE UCC.StorerKey = LLI.StorerKey
                        AND UCC.SKU = LLI.SKU
                        AND UCC.Lot = LLI.Lot
                        AND UCC.Loc = LLI.Loc
                        AND UCC.ID = LLI.ID
               )

               SET @nLooseInv = ISNULL(@nLooseInv, 0)

               IF CASE 
                     WHEN (@nMonoSKU_UCC > 0 AND @nMultiSKU_UCC > 0) THEN 1
                     WHEN (@nMonoSKU_UCC > 0 AND @nLooseInv > 0) THEN 1
                     WHEN (@nMultiSKU_UCC > 0 AND @nLooseInv > 0) THEN 1
                  ELSE 0 END = 1
               BEGIN
                  SET @nErrNo = 268453
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Not allow mix of Mono-SKU UCCs, Multi-SKU UCCs and Loose inventory
                  GOTO Quit
               END
            END
         END--enter
      END --st1
      ELSE IF @nStep = 2 --TOLoc
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT @cConditionCode = ConditionCode
            FROM dbo.RECEIPTDETAIL WITH(NOLOCK)
            WHERE ID = @cFromID
               AND StorerKey = @cStorerKey

            -- 1. If both PickAndDropLOC and SuggLOC exist, validate against PickAndDropLOC, otherwise validate against SuggLOC
            IF ISNULL(@cPickAndDropLOC, '') <> '' AND ISNULL(@cToLOC, '') <> '' AND @cPickAndDropLOC <> @cToLOC
            BEGIN
               SELECT 
                  @cLocationType = LocationType,
                  @cLocAisle = LocAisle
               FROM dbo.LOC WITH(NOLOCK)
               WHERE LOC = @cToLoc
                  AND Facility = @cFacility

               SELECT @cPickAndDropLOCAisle = LocAisle
               FROM dbo.LOC WITH(NOLOCK)
               WHERE LOC = @cPickAndDropLOC
                  AND Facility = @cFacility

               -- For Mono-SKU UCC pallet, ToLoc must be PND
               IF ISNULL(@cLocationType, '') <> @cPND
               BEGIN
                  SET @nErrNo = 268461
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  ToLoc must be PND for Mono-SKU UCC inventory
                  GOTO Quit
               END

               -- Aisle must be same between PickAndDropLOC and ToLoc for Mono-SKU UCC pallet
               IF ISNULL(@cLocAisle, '') <> ISNULL(@cPickAndDropLOCAisle, '')
               BEGIN
                  SET @nErrNo = 268462
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Different aisle between PickAndDropLOC and ToLoc
                  GOTO Quit
               END
            END
            ELSE IF ISNULL(@cPickAndDropLOC, '') = '' AND ISNULL(@cSuggLOC, '') <> '' AND ISNULL(@cToLOC, '') <> '' AND @cSuggLOC <> @cToLOC
            BEGIN
               SELECT @cLocationType = LocationType
               FROM dbo.LOC WITH(NOLOCK)
               WHERE LOC = @cToLOC
                  AND Facility = @cFacility

               -- 2. If Pallet is DAM
               IF ISNULL(@cConditionCode, '') = @cDAM
               BEGIN
                  -- ToLoc must be VAS for DAM inventory
                  IF ISNULL(@cLocationType, '') <> @cVAS
                  BEGIN
                     SET @nErrNo = 268456
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Location must be VAS for DAM inventory
                     GOTO Quit
                  END
               END
               ELSE -- 3. If Pallet is not DAM, MEZZANINE FLOW, location type must be PND-MEZZA
               BEGIN
                  -- ToLoc must be PND-MEZZA for not DAM inventory
                  IF ISNULL(@cLocationType, '') <> @cPNDMEZZA
                  BEGIN
                     SET @nErrNo = 268464
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --   Location must be PND-MEZZA for None-DAM inventory
                     GOTO Quit
                  END
               END
            END

            SELECT @nSKUQty = COUNT(DISTINCT SKU)
            FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
            WHERE LLI.StorerKey = @cStorerKey
               AND LLI.ID = @cFromID
               AND (LLI.Qty - LLI.QtyPicked - LLI.QtyPickInProcess > 0)

            SET @nSKUQty = ISNULL(@nSKUQty, 0)

            SELECT @nLottable02Qty = COUNT(DISTINCT LA.Lottable02)
            FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
            INNER JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK)
               ON LA.Lot = LLI.Lot
               AND LA.StorerKey = LLI.StorerKey
               AND LA.Sku = LLI.Sku
            WHERE LLI.StorerKey = @cStorerKey
               AND LLI.ID = @cFromID
               AND (LLI.Qty - LLI.QtyPicked - LLI.QtyPickInProcess > 0)

            SET @nLottable02Qty = ISNULL(@nLottable02Qty, 0)

            SELECT @nUCCQty = COUNT(DISTINCT UCC.UCCNo)
            FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
            INNER JOIN dbo.UCC WITH(NOLOCK)
               ON UCC.Lot = LLI.Lot
               AND UCC.StorerKey = LLI.StorerKey
               AND UCC.Sku = LLI.Sku
               AND UCC.Loc = LLI.Loc
               AND UCC.ID = LLI.ID
            WHERE LLI.StorerKey = @cStorerKey
               AND LLI.ID = @cFromID
               AND (LLI.Qty - LLI.QtyPicked - LLI.QtyPickInProcess > 0 OR LLI.PendingMoveIN + LLI.QtyExpected > 0)

            SET @nUCCQty = ISNULL(@nUCCQty, 0)

            -- Do the common validations: I.check mix SKU II. check mix Lottable02 III. Check available space on ToLoc

            -- I.check mix SKU 
            -- Single SKU pallet, not allow to mix with other SKU on ToLoc
            IF @nSKUQty = 1
            BEGIN
               SELECT TOP 1 @cSKU = SKU
               FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
               WHERE LLI.StorerKey = @cStorerKey
                  AND LLI.ID = @cFromID
                  AND (LLI.Qty - LLI.QtyPicked - LLI.QtyPickInProcess > 0)
               ORDER BY SKU

               IF EXISTS(SELECT 1 
                        FROM dbo.LOTxLOCxID LLI WITH(NOLOCK) 
                        INNER JOIN dbo.LOC WITH(NOLOCK) ON LLI.Loc = LOC.Loc AND LOC.Facility = @cFacility
                        WHERE LLI.StorerKey = @cStorerKey
                           AND LLI.Loc = @cToLoc
                           AND LOC.CommingleSku IN ('0', 'N')
                           AND LLI.SKU <> @cSKU
                           AND (LLI.Qty - LLI.QtyPicked - LLI.QtyPickInProcess > 0 OR LLI.PendingMoveIN + LLI.QtyExpected > 0 )
               )
               BEGIN
                  SET @nErrNo = 268457
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Not allow to mix SKU on ToLoc
                  GOTO Quit
               END
            END
            ELSE -- Multi-SKU pallet, not allow to put it to single sku location
            BEGIN
               IF EXISTS(SELECT 1 
                        FROM dbo.LOC WITH(NOLOCK)
                        WHERE Loc = @cToLoc
                           AND Facility = @cFacility
                           AND LOC.CommingleSku IN ('0', 'N')
               )
               BEGIN
                  SET @nErrNo = 268458
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Not allow to mix SKU on ToLoc
                  GOTO Quit
               END
            END

            -- II. check mix Lottable02
            -- Single type of Lottable02 value, not allow to mix with other Lottable02 value on ToLoc
            IF @nLottable02Qty = 1
            BEGIN
               SELECT TOP 1 @cLottable02 = LA.Lottable02
               FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
               INNER JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK)
                  ON LA.Lot = LLI.Lot
                  AND LA.StorerKey = LLI.StorerKey
                  AND LA.Sku = LLI.Sku
               WHERE LLI.StorerKey = @cStorerKey
                  AND LLI.ID = @cFromID
                  AND (LLI.Qty - LLI.QtyPicked - LLI.QtyPickInProcess > 0)
               ORDER BY LLI.SKU, LLI.LOT

               IF EXISTS(SELECT 1 
                        FROM dbo.LOTxLOCxID LLI WITH(NOLOCK) 
                        INNER JOIN dbo.LOC WITH(NOLOCK) ON LLI.Loc = LOC.Loc AND LOC.Facility = @cFacility
                        INNER JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK) ON LA.Lot = LLI.Lot AND LA.StorerKey = LLI.StorerKey AND LA.Sku = LLI.Sku
                        WHERE LLI.StorerKey = @cStorerKey
                           AND LLI.Loc = @cToLoc
                           AND LOC.NoMixLottable02 IN ('1', 'Y')
                           AND ISNULL(LA.Lottable02, '') <> @cLottable02
                           AND (LLI.Qty - LLI.QtyPicked - LLI.QtyPickInProcess > 0 OR LLI.PendingMoveIN + LLI.QtyExpected > 0 )
               )
               BEGIN
                  SET @nErrNo = 268459
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Not allow to mix Lottable02 on ToLoc
                  GOTO Quit
               END
            END
            ELSE -- Multiple types of Lottable02 value, not allow to put it to location which does not allow mix Lottable02
            BEGIN
               IF EXISTS(SELECT 1 
                        FROM dbo.LOC WITH(NOLOCK)
                        WHERE LOC = @cToLoc
                           AND Facility = @cFacility
                           AND LOC.NoMixLottable02 IN ('1', 'Y')
               )
               BEGIN
                  SET @nErrNo = 268460
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Not allow to mix Lottable02 on ToLoc
                  GOTO Quit
               END
            END

            -- III. Check available space on ToLoc
             -- For simplicity, we only check if there is available space when the inventory contains UCC. The space check will be bypassed for non-UCC inventory as long as there is no mix of SKU or Lottable02, which means the inventory can always be put in if there is no mix, even for the location with limited capacity. This is to avoid the situation that the validation fails due to inaccurate available space calculation result.
            IF @nUCCQty > 0
            BEGIN
               DECLARE @nToLocAvailableSpace INT
               SELECT
                  @nToLocAvailableSpace = IIF(LOC.MaxCarton = 0, 99999, LOC.MaxCarton) - ISNULL(COUNT(DISTINCT UCC2.UCCNo), 0) - ISNULL(COUNT(DISTINCT UCC.UCCNo), 0)
               FROM dbo.LOC WITH(NOLOCK)
               LEFT JOIN dbo.UCC WITH(NOLOCK) ON LOC.Loc = UCC.Loc AND UCC.StorerKey = @cStorerKey AND UCC.Status IN ('1', '3', '4')
               LEFT JOIN dbo.RFPutaway RFP WITH(NOLOCK) ON  RFP.StorerKey = @cStorerKey AND RFP.SuggestedLOC = @cToLoc
               LEFT JOIN dbo.UCC UCC2 WITH(NOLOCK) ON RFP.StorerKey = UCC2.StorerKey AND RFP.FromLOC = UCC2.Loc AND RFP.CaseID IS NOT NULL AND RFP.CaseID = UCC2.UCCNo AND RFP.SKU = UCC2.SKU
               WHERE LOC.Facility = @cFacility
                  AND LOC.Loc = @cToLoc
               GROUP BY LOC.Loc, LOC.MaxCarton

               IF ISNULL(@nToLocAvailableSpace, 99999) < @nUCCQty
               BEGIN
                  SET @nErrNo = 268463
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Not enough available space on ToLoc
                  GOTO Quit
               END
            END
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

GRANT EXECUTE ON  [RDT].[rdt_1819ExtVal26] TO [NSQL]
GO
