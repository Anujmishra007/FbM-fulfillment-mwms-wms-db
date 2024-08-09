
/*************************************************************************/
/* Store procedure: [rdt_513ExtValVLT]                                   */
/* Copyright: Maersk                                                     */
/*                                                                       */
/*                                                                       */
/* Date         Rev   Author   Purposes                                  */
/* 21/03/2024   1.0   PPA374   Check that LPN will not breach max pallet */
/* 15/07/2024   1.1   PPA374   Check pick, PA and replen                 */
/*************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_513ExtValVLT] (
@nMobile    INT,
@nFunc      INT,
@cLangCode  NVARCHAR( 3),
@nStep      INT,
@nInputKey  INT,
@cStorerKey NVARCHAR( 15),
@cFacility  NVARCHAR(  5),
@cFromLOC   NVARCHAR( 10),
@cFromID    NVARCHAR( 18),
@cSKU       NVARCHAR( 20),
@nQTY       INT,
@cToID      NVARCHAR( 18),
@cToLOC     NVARCHAR( 10),
@nErrNo     INT OUTPUT,
@cErrMsg    NVARCHAR( 20) OUTPUT
) AS
BEGIN
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF

DECLARE
@LOCAvail  INT,
@LOCCat    NVARCHAR(40),
@LOCFlag   NVARCHAR(20),
@LoseIDChk INT,
@SKUChk    INT,
@TOZONE    NVARCHAR(20),
@LOCType   NVARCHAR(20)

   IF @nFunc = 513
   BEGIN
     
      IF @nStep = 2
      BEGIN
	     --LPN is in multiple locations, should fix before moving.
		 IF exists (select 1 from LOTXLOCXID LLI (NOLOCK) where id = @cFromID and qty > 0 and StorerKey = @cStorerKey
         and exists (select 1 from LOTXLOCXID (NOLOCK) where id = @cFromID and qty > 0 and loc <> lli.loc and StorerKey = @cStorerKey))
		 BEGIN
		    SET @nErrNo = 217981 
		    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LPN is in multiple locations, should fix before moving.
		 END

		 --LPN got putaway task. Should not be moved.
		 ELSE IF exists (select 1 from LOTXLOCXID (NOLOCK) where ID = @cFromID and PendingMoveIN > 0 and StorerKey = @cStorerKey) and 
         EXISTS (SELECT 1 FROM loc (NOLOCK) WHERE loc = @cFromLOC and FACILITY = @cFacility AND (LocationType IN (SELECT code FROM CODELKUP (NOLOCK) 
         WHERE LISTNAME = 'HUSQINBLOC' AND Storerkey = @cStorerKey) or LocationCategory = 'PND'))
		 BEGIN
	        SET @nErrNo = 217982 
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LPN got putaway task. Should not be moved.
         END

		 --LPN got replen task. Should not be moved.
         ELSE IF exists (select 1 from LOTXLOCXID (NOLOCK) where ID = @cFromID and QtyReplen > 0 and StorerKey = @cStorerKey)
         BEGIN
            SET @nErrNo = 217983
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LPN got replen task. Should not be moved.
         END

	  END

	  IF @nStep = 5 
      BEGIN
         --Format or length of the target LPN is incorrect.
		 IF isnull(@cToID,'')<>'' AND (len(replace(rtrim(ltrim(isnull(@cToID,''))),' ',''))<>10 OR CHARINDEX(' ',@cToId)>0)
         BEGIN   
            SET @nErrNo = 217901
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  --BadFormat/Len
         END
      END

      ELSE IF @nStep = 6
	  BEGIN
	     select top 1 @LOCType = locationtype FROM LOC WITH (NOLOCK) where loc = @cToLOC and Facility = @cFacility
      
         SELECT @LOCAvail = coalesce((SELECT TOP 1 MaxPallet FROM LOC (NOLOCK) WHERE loc = @cToLoc and facility = @cFacility)
         -
         (SELECT count(distinct id) FROM LOTxLOCxID (NOLOCK) WHERE storerkey = @cstorerkey and loc = @cToLoc AND qty+PendingMoveIN> 0),0)

         SELECT TOP 1 @LOCCat = locationcategory FROM LOC WITH (NOLOCK) WHERE loc = @cToLOC and Facility = @cFacility
         SELECT TOP 1 @LOCFlag = LocationFlag FROM loc WITH (NOLOCK) WHERE loc = @cToLOC and Facility = @cFacility
         SELECT TOP 1 @LoseIDChk = loseid FROM loc WITH (NOLOCK) WHERE loc = @cToLOC and Facility = @cFacility

         SET @SKUChk = CASE WHEN @cSKu IN (SELECT sku FROM LOTxLOCxID (NOLOCK) WHERE StorerKey = @cStorerKey and loc = @cToLOC AND (qty > 0 OR PendingMoveIN > 0)) THEN 1 ELSE 0 END
         SET @TOZONE = CASE WHEN @cToLOC IN (SELECT loc FROM loc (NOLOCK) WHERE Facility = @cFacility and PutawayZone IN (SELECT code FROM CODELKUP WITH (NOLOCK) WHERE LISTNAME = 'HUSQZONE' AND Storerkey = @cStorerKey AND short = 1)) THEN 1 ELSE 0 END

	     --Target location is not in the Husqvarna listed zone
         IF @TOZONE = 0
         BEGIN
            SET @nErrNo = 217902 
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LocNotAssign
         END

	     --Maximum capacity is reached or target location is a pick location that got different SKU in it.
         ELSE IF (@LOCAvail < 1 OR @LOCAvail is null) 
         AND ((@LoseIDChk = 1 AND @SKUChk = 0) OR (@LoseIDChk = 0))
         AND @cToID NOT IN (SELECT id FROM LOTxLOCxID (NOLOCK) WHERE loc = @cToLOC AND (qty > 0 OR PendingMoveIN > 0) AND sku = @cSKU and StorerKey = @cStorerKey)
         AND @LOCCat IN (SELECT Code FROM codelkup WITH (NOLOCK) WHERE listname = 'MAXPALCHK' AND storerkey = @cStorerKey AND short = 1)
         BEGIN
            SET @nErrNo = 217903 
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  --OverMaxPallet
         END

	     --Target location got flag or is on hold.
         ELSE IF isnull(@LOCFlag,'') NOT IN ('','NONE') OR @cToLOC IN (SELECT loc FROM INVENTORYHOLD WITH (NOLOCK) WHERE hold = 1 AND loc <>'' and Storerkey = @cStorerKey)
         BEGIN
            SET @nErrNo = 217904
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  --LocOnHold
         END

	     --If target location is not pick location then LPN ID is required.
         ELSE IF isnull(@cToID,'') = '' AND @LoseIDChk = 0 
         BEGIN
            SET @nErrNo = 217905
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NeedID
         END

	     --If target LPN ID is same as the source and location is different and LPN ID is not blank and target location is not pick location (with lose id)
	     --or SKU is different than in target location and not full qty of the SKU is moved then it is a duplicate.
         ELSE IF EXISTS
         (SELECT 1 FROM LOTxLOCxID WITH (NOLOCK) WHERE id = @cToID AND (qty > 0 OR PendingMoveIN > 0) AND id <> '' AND StorerKey = @cStorerKey 
         AND ((loc <> @cToLoc AND @cToLoc NOT IN (SELECT loc FROM loc WITH (NOLOCK) WHERE Facility = @cFacility and LoseId = 1 and LocationType IN ('PICK','CASE'))) 
         OR sku <> @cSKU) AND (SELECT sum(qty) FROM LOTxLOCxID WITH (NOLOCK) WHERE ID = @cToID AND SKU = @cSKU and StorerKey = @cStorerKey) <> @nQTY)
         BEGIN
            SET @nErrNo = 217906
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DuplicateID
         END
			   
         --If target LPN ID is not blank and target location is not pick face and lot on the target LPN of the SKU that is moved is different, than move
         --is not allowed to avoid creating LPNs with multiple lots on it.
         ELSE IF EXISTS
         (SELECT 1 FROM LOTxLOCxID (NOLOCK) WHERE id = @cToID AND (qty > 0 OR PendingMoveIN > 0) AND id <> '' AND StorerKey = @cStorerKey 
         AND ((loc <> @cToLoc AND @cToLoc NOT IN (SELECT loc FROM loc (NOLOCK) WHERE Facility = @cFacility AND LocationType IN ('PICK','CASE'))) 
         OR sku <> @cSKU OR ((SELECT TOP 1 lot FROM lotxlocxid (NOLOCK) WHERE id = @cFromID AND qty > 0 AND loc = @cFromLOC and StorerKey = @cStorerKey) 
         NOT IN (SELECT lot FROM LOTxLOCxID (NOLOCK) WHERE StorerKey = @cStorerKey and id = @cToID AND qty > 0)
         AND (SELECT count(distinct lot) FROM lotxlocxid (NOLOCK) WHERE StorerKey = @cStorerKey AND loc = @cFromLOC) > 1
         AND @cToLoc NOT IN (SELECT loc FROM loc WITH (NOLOCK) WHERE Facility = @cFacility AND LoseId = 1 and LocationType IN ('PICK','CASE')))
         )AND (SELECT sum(qty) FROM LOTxLOCxID WITH (NOLOCK) WHERE ID = @cToID AND SKU = @cSKU and StorerKey = @cStorerKey) <> @nQTY)
         BEGIN
            SET @nErrNo = 217907
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DifferentLot
         END

	     --Not allowing to move to target location if location is not commingle and SKU count would become more than one.
         ELSE IF EXISTS (SELECT 1 FROM LOTxLOCxID WITH (NOLOCK) WHERE (qty > 0 OR PendingMoveIN > 0) AND loc = @cToLoc AND @cSKU <> Sku AND StorerKey = @cStorerKey
         AND loc NOT IN (SELECT loc FROM loc WITH (NOLOCK) WHERE CommingleSku = 1 and Facility = @cFacility))
         BEGIN
            SET @nErrNo = 217908
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --OtherSKULOC
         END

	     ELSE IF NOT EXISTS (select loc from SKUxLOC (NOLOCK) where QtyLocationLimit > 0 and sku = @cSKU and loc = @cToLOC and StorerKey = @cStorerKey)
	     and @LOCType in ('PICK','CASE')
	     BEGIN
	        SET @nErrNo = 217984
	        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Target location is a pick location with no SKU or different SKU setup than on the LPN.
	     END
      END
   END
END

GRANT EXECUTE ON [RDT].[rdt_513ExtValVLT] TO [NSQL]

