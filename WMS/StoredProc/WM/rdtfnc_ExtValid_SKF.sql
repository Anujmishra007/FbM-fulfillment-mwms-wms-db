SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: rdtfnc_ExtValid_SKF                                          */
/* Copyright      : Maersk WMS                                                   */
/* Customer       : SKF                                                          */
/*                                                                               */
/* Purpose: Extended validation for Move ID before finalization                  */
/*          Validates SKU mixing in override locations                           */
/*          Validates weight capacity for location overrides                     */
/*          Validates Batch mixing in override locations                         */
/*          Validates MaxPallet in override locations                            */
/*          Validates Zones in override locations                                */
/*          Validates ABC in override locations                                  */
/*          Validates putaway zone matching and condition code                   */
/*                                                                               */
/* Date       Rev  Author      Purposes                                          */
/* 2025-10-13 1.0  SYO054      mixing restrictions validation                    */
/*                                                                               */
/*********************************************************************************/

CREATE     PROCEDURE [RDT].[rdtfnc_ExtValid_SKF] (
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR(3),
   @nStep               INT,
   @nInputKey           INT,
   @cFacility           NVARCHAR(5),
   @cStorerKey          NVARCHAR(15),
   @cID                 NVARCHAR(18),
   @cFromLoc            NVARCHAR(10),
   @cToLoc              NVARCHAR(10),
   @cSKU                NVARCHAR(20),
   @cReceiptKey         NVARCHAR(10),
   @cReceiptLineNumber  NVARCHAR(10),
   @nErrNo              INT OUTPUT,
   @cErrMsg             NVARCHAR(20) OUTPUT
) AS

SET NOCOUNT ON
SET @nErrNo = 0
SET @cErrMsg = ''

DECLARE      @n_StdGrossWgt     FLOAT,
             @cInbStageLoc      NVARCHAR(10),
             @n_TotalWeight     FLOAT,
             @cDamagePutawayZone NVARCHAR(20)

-- Only validate ToLoc step
IF @nStep <> 3 -- Step_ToLoc

  SELECT @cDamagePutawayZone = SValue 
   FROM rdt.StorerConfig 
   WHERE Function_ID = '664' AND StorerKey = @cStorerKey AND ConfigKey = 'DamagePutawayZone' 
   
--BEGIN: OK pallets shouldnt go damage location and damage pallets shouldnt go to rack location
-- Check putaway zone match and condition code
DECLARE @c_LocPutawayZone NVARCHAR(10), @c_SKUPutawayZone NVARCHAR(10), @c_ConditionCode NVARCHAR(10)
SELECT @c_LocPutawayZone = L.putawayzone, @c_SKUPutawayZone = S.putawayzone
FROM LOC L WITH (NOLOCK), SKU S WITH (NOLOCK)
WHERE L.LOC = @cToLOC AND L.Facility = @cFacility
AND S.SKU = @cSKU AND S.StorerKey = @cStorerKey

SELECT @c_ConditionCode = ConditionCode
FROM RECEIPTDETAIL WITH (NOLOCK)
WHERE ToId = @cID

IF @c_LocPutawayZone <> @c_SKUPutawayZone AND @c_ConditionCode = 'OK' AND @c_LocPutawayZone <> @cDamagePutawayZone
BEGIN
   SET @nErrNo = 218159
   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
   GOTO QUIT
END

-- Validate condition code vs putaway zone restrictions
IF @c_ConditionCode <> 'OK' AND @c_LocPutawayZone <> @cDamagePutawayZone
BEGIN
   SET @nErrNo = 218160
   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
   GOTO QUIT
END

IF @c_ConditionCode = 'OK' AND @c_LocPutawayZone = @cDamagePutawayZone
BEGIN
   SET @nErrNo = 218161
   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
   GOTO QUIT
END
--END: OK pallets shouldnt go damage location and damage pallets shouldnt go to rack location
--BEGIN: SKU ABC and Location ABC should match
-- Check LOC.ABC vs SKU.ABC
DECLARE @c_LocABC NVARCHAR(1), @c_SKUABC NVARCHAR(1)
SELECT @c_LocABC = L.ABC, @c_SKUABC = S.ABC
FROM LOC L WITH (NOLOCK), SKU S WITH (NOLOCK)
WHERE L.LOC = @cToLOC AND L.Facility = @cFacility
AND S.SKU = @cSKU AND S.StorerKey = @cStorerKey

IF @c_LocABC <> @c_SKUABC
BEGIN
   SET @nErrNo = 218157
   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
   GOTO QUIT
END

-- Check ABC mismatch in pending receipts
IF EXISTS (
   SELECT 1
   FROM RECEIPTDETAIL RD WITH (NOLOCK)
   JOIN LOC L WITH (NOLOCK) ON RD.ToLoc = L.LOC
   JOIN SKU S WITH (NOLOCK) ON RD.SKU = S.SKU AND RD.StorerKey = S.StorerKey
   WHERE RD.ToLoc = @cToLOC AND RD.FinalizeFlag = 'N'
   AND L.ABC <> S.ABC
)
BEGIN
   SET @nErrNo = 218157
   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
   GOTO QUIT
END
--END: SKU ABC and Location ABC should match
--BEGIN: Different SKU shoulnt be mixed in a location
-- Check for different SKU in override location (existing inventory)
IF EXISTS (SELECT 1 FROM LOTxLOCxID LLI (NOLOCK)
           WHERE LLI.LOC = @cToLoc AND LLI.QTY > 0 AND LLI.SKU <> @cSKU)
BEGIN
   SET @nErrNo = 237766
   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --SKU mixing not allowed
   GOTO QUIT
END

-- Check for different SKU in override location (pending receipts)
IF EXISTS (SELECT 1 FROM RECEIPTDETAIL RD (NOLOCK)
           WHERE RD.StorerKey = @cStorerKey AND RD.ToLoc = @cToLoc 
             AND RD.FinalizeFlag = 'N' AND RD.SKU <> @cSKU AND RD.BeforeReceivedQty > 0)
BEGIN
   SET @nErrNo = 237766
   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --SKU mixing not allowed
   GOTO QUIT
END
--END: Different SKU shoulnt be mixed in a location
--BEGIN: Putaway shouldnt allow more than location max pallet capacity
-- Check MaxPallet capacity
DECLARE @n_MaxPallets INT
DECLARE @n_CurrentPallets INT

SELECT @n_MaxPallets = MaxPallet
FROM LOC WITH (NOLOCK)
WHERE LOC = @cToLOC AND Facility = @cFacility

SELECT @n_CurrentPallets = (
   SELECT COUNT(DISTINCT ID)
   FROM LOTxLOCxID WITH (NOLOCK)
   WHERE LOC = @cToLOC AND QTY > 0
) + (
   SELECT COUNT(DISTINCT ToId)
   FROM RECEIPTDETAIL WITH (NOLOCK)
   WHERE ToLoc = @cToLOC AND FinalizeFlag = 'N'
)

IF @n_CurrentPallets >= @n_MaxPallets
BEGIN
   SET @nErrNo = 218156
   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
   GOTO QUIT
END
--END: Putaway shouldnt allow more than location max pallet capacity
--BEGIN: Putaway shouldnt allow to mix different batches
-- Check for different Lottable10
DECLARE @c_ExistingLot10 NVARCHAR(20)
SELECT TOP 1 @c_ExistingLot10 = LA.Lottable10
FROM LOTxLOCxID LLI WITH (NOLOCK)
JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON LLI.LOT = LA.LOT
WHERE LLI.LOC = @cToLOC AND LLI.QTY > 0 
AND LA.Lottable10 <> (SELECT Lottable10 FROM RECEIPTDETAIL WITH (NOLOCK) WHERE ToId = @cID)

IF @c_ExistingLot10 IS NULL
BEGIN
   SELECT TOP 1 @c_ExistingLot10 = Lottable10
   FROM RECEIPTDETAIL WITH (NOLOCK)
   WHERE ToLoc = @cToLOC AND FinalizeFlag = 'N' 
   AND Lottable10 <> (SELECT Lottable10 FROM RECEIPTDETAIL WITH (NOLOCK) WHERE ToId = @cID)
END

IF @c_ExistingLot10 IS NOT NULL
BEGIN
   SET @nErrNo = 218155
   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
   GOTO QUIT
END
--END: Putaway shouldnt allow to mix different batches
  -- BEGIN : Weight validation
        -- Calculate putaway pallet weight
SELECT @n_StdGrossWgt = RD.BeforeReceivedQty * S.StdGrossWgt
FROM RECEIPTDETAIL RD WITH (NOLOCK)
JOIN SKU S WITH (NOLOCK) ON RD.SKU = S.SKU AND RD.StorerKey = S.StorerKey
WHERE RD.ToId = @cID

-- Calculate total weight: putaway + existing + pending pallets

SELECT @n_TotalWeight = @n_StdGrossWgt + 
    ISNULL((SELECT SUM((LLI.QTY - LLI.QtyPicked + LLI.PendingMoveIN) * S.StdGrossWgt) 
        FROM LOTxLOCxID LLI WITH (NOLOCK) 
        JOIN SKU S WITH (NOLOCK) ON LLI.SKU = S.SKU AND LLI.StorerKey = S.StorerKey
        WHERE LLI.LOC = @cToLOC), 0) +
    ISNULL((SELECT SUM(RD.BeforeReceivedQty * S.StdGrossWgt)
        FROM RECEIPTDETAIL RD WITH (NOLOCK)
        JOIN SKU S WITH (NOLOCK) ON RD.SKU = S.SKU AND RD.StorerKey = S.StorerKey
        WHERE RD.ToLoc = @cToLOC AND RD.FinalizeFlag = 'N' AND RD.ToLoc <> @cInbStageLoc), 0)

-- Validate against location weight capacity
IF @n_TotalWeight > (SELECT TOP 1 WeightCapacity FROM LOC WITH (NOLOCK) WHERE LOC = @cToLOC)
BEGIN
      SET @nErrNo = 218158
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO QUIT
END

   -- END : Weight validation
--END: Putaway shouldnt allow if pallet weight exceeds the location weight capacity
QUIT:
GO
