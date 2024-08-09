
/************************************************************************/
/* Store procedure: [rdt_511ExtValVLT]                                  */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Purpose: not allow to put pallet into location if maxpallet  <> 0    */
/*                                                                      */
/* Date         VER   Author   Purpose:                                 */
/* 21/03/2024   1.0   PPA374   Not allow to put LPN over max            */
/* 15/07/2024   1.1   PPA374   Adding pick check and PA, Replen check   */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_511ExtValVLT] (
@nMobile         INT,
@nFunc           INT,
@cLangCode       NVARCHAR( 3),
@nStep           INT,
@nInputKey       INT,
@cStorerKey      NVARCHAR( 15),
@cFromID         NVARCHAR( 18),
@cFromLOC        NVARCHAR( 10),
@cToLOC          NVARCHAR( 10),
@cToID           NVARCHAR( 18),
@nErrNo          INT OUTPUT,
@cErrMsg         NVARCHAR( 20) OUTPUT
) AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF

DECLARE
@LOCAvail int,
@LOCCat	  NVARCHAR(40),
@LOCFlag NVARCHAR(20),
@LoseIDChk	int,
@SKUChk		int,
@SKUPickChk int,
@TOZONE NVARCHAR(20),
@PNDPICKChk int,
@cFacility NVARCHAR(20),
@FromLoc NVARCHAR(20),
@LOCType NVARCHAR(20)
	
select top 1 @cFacility = Facility from rdt.rdtmobrec (NOLOCK) where Mobile = @nMobile
select top 1 @FromLoc = LOC from LOTxLOCxID (NOLOCK) where qty > 0 and StorerKey = @cStorerKey and id = @cFromID

IF @nFunc = 511
BEGIN

   IF @nStep = 1
   BEGIN
      --LPN is in multiple locations, should fix before moving.
      IF exists (select 1 from LOTXLOCXID LLI (NOLOCK) where id = @cFromID and qty > 0 and StorerKey = @cStorerKey
      and exists (select 1 from LOTXLOCXID (NOLOCK) where id = @cFromID and qty > 0 and loc <> lli.loc and StorerKey = @cStorerKey))
	  BEGIN
         SET @nErrNo = 217973 
		 SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LPN is in multiple locations, should fix before moving
      END
   
      --LPN got putaway task. Should not be moved.
      ELSE IF exists (select 1 from LOTXLOCXID (NOLOCK) where ID = @cFromID and PendingMoveIN > 0 and StorerKey = @cStorerKey) and 
      EXISTS (SELECT 1 FROM loc (NOLOCK) WHERE loc = @FromLOC and FACILITY = @cFacility AND (LocationType IN (SELECT code FROM CODELKUP (NOLOCK) 
      WHERE LISTNAME = 'HUSQINBLOC' AND Storerkey = @cStorerKey) or LocationCategory = 'PND'))
	  BEGIN
	     SET @nErrNo = 217974 
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LPN got putaway task. Should not be moved.
      END
   
      --LPN got replen task. Should not be moved.
      ELSE IF exists (select 1 from LOTXLOCXID (NOLOCK) where ID = @cFromID and QtyReplen > 0 and StorerKey = @cStorerKey)
	  BEGIN
         SET @nErrNo = 217975
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LPN got replen task. Should not be moved.
      END
   END

   IF @nStep = 3
   BEGIN
      select @LOCAvail = coalesce((select top 1 MaxPallet from LOC WITH (NOLOCK) where loc = @cToLoc and facility = @cfacility)
      -
      (select count(distinct id) from LOTxLOCxID WITH (NOLOCK) where storerkey = @cStorerkey and loc = @cToLoc and qty+PendingMoveIN> 0),0)

      select top 1 @LOCCat = locationcategory FROM LOC WITH (NOLOCK) where loc = @cToLOC and Facility = @cFacility
      select top 1 @LOCType = locationtype FROM LOC WITH (NOLOCK) where loc = @cToLOC and Facility = @cFacility
      select top 1 @LOCFlag = LocationFlag from loc WITH (NOLOCK) where loc = @cToLOC and Facility = @cFacility
      select top 1 @LoseIDChk = loseid from loc with (NOLOCK) where loc = @cToLOC and Facility = @cFacility

      set @SKUChk = case when exists (select 1 from LOTxLOCxID (NOLOCK) where id = @cFromID and qty > 0 and loc = @cFromLOC and StorerKey = @cStorerKey and sku = any (select sku from LOTxLOCxID with (nolock) where (qty > 0 or PendingMoveIN > 0) and StorerKey = @cStorerKey and loc = @cToLOC)) then 1 else 0 end
      set @TOZONE = case when exists (select 1 from loc (NOLOCK) where loc = @cToLOC and Facility = @cFacility and PutawayZone in (select code from CODELKUP WITH (NOLOCK) where LISTNAME = 'HUSQZONE' and Storerkey = @cStorerKey and short = 1)) then 1 else 0 end
      set @PNDPICKChk = case when (select top 1 LocationType from loc (NOLOCK) where loc = @cFromLoc and Facility = @cFacility and loc like 'B_999%') = 'PND' and exists(select 1 from pickdetail (NOLOCK) where id = @cFromID and status = 5 and dropid <> '' and Storerkey = @cStorerKey)  then 1 else 0 end
      set @SKUPickChk = case when exists (select 1 from LOTxLOCxID with (nolock) where StorerKey = @cStorerKey and id = @cFromID and qty > 0 and loc = @cFromLOC and sku = any (select sku from SKUxLOC with (nolock) where loc = @cToLOC and QtyLocationLimit > 0 and StorerKey = @cStorerKey)) then 1 else 0 end

      --Target location is not in the Husqvarna listed zone
      IF @TOZONE = 0
      BEGIN
         SET @nErrNo = 217976
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Target location is not in the Husqvarna listed zone
      END

      --Maximum capacity is reached or target location is a pick location that got different SKU in it.
	  ELSE IF (@LOCAvail < 1 or @LOCAvail is null)
	  and ((@LoseIDChk = 1 and @SKUChk = 0) or (@LoseIDChk = 0))
	  and @LOCCat in (select Code from codelkup (NOLOCK) where listname = 'MAXPALCHK' and storerkey = @cStorerKey and short = 1)
	  BEGIN
         SET @nErrNo = 217977 
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Maximum capacity is reached or target location is a pick location that got different SKU in it.
	  END

      --Target location got flag or is on hold.
	  ELSE IF isnull(@LOCFlag,'') not in ('','NONE') or exists (select 1 from INVENTORYHOLD (NOLOCK) where hold = 1 and loc=@cToLOC and Storerkey = @cStorerKey)
	  BEGIN
         SET @nErrNo = 217978
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Target location got flag enabled or is on hold.
	  END

	  --LPN is picked and needs to be moved to the marshalling lane.
	  ELSE IF @PNDPICKChk = 1 and @cToLOC <> 
	  (select top 1 OtherReference from mbol (NOLOCK) where Facility = @cFacility 
	  and mbolkey = (select top 1 mbolkey from orders (NOLOCK) where StorerKey = @cStorerKey and orderkey = 
	  (select top 1 OrderKey from pickdetail (NOLOCK) where Storerkey = @cStorerKey and id = @cFromID)))
	  BEGIN
         SET @nErrNo = 217979
		 SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LPN is picked and needs to be moved to the marshalling lane.
	  END

      --Target location is a pick location with no SKU setup or a different SKU setup than the SKU on the LPN.
      ELSE IF @LOCType in ('PICK','CASE') and @SKUPickChk = 0
	  BEGIN
	     SET @nErrNo = 217980
	     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Target location is a pick location with no SKU or different SKU setup than on the LPN.
	  END
   END
END


GRANT EXECUTE ON [RDT].[rdt_511ExtValVLT] TO [NSQL]
