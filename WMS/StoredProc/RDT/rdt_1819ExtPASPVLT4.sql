
/************************************************************************/
/* Store procedure: rdt_1819ExtPASPVLT4                                 */
/*                                                                      */
/* Date         Author   Purposes                                       */
/* 19/06/2024   PPA374   Identify location for putaway                  */
/* 08/08/2024   PPA374   Amended as per review comments                 */
/*                                                                      */
/*                                                                      */
/************************************************************************/

CREATE OR ALTER   PROC [RDT].[rdt_1819ExtPASPVLT4] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @cUserName        NVARCHAR( 18),
   @cStorerKey       NVARCHAR( 15), 
   @cFacility        NVARCHAR( 5), 
   @cFromLOC         NVARCHAR( 10),
   @cID              NVARCHAR( 18),
   @cSuggLOC         NVARCHAR( 10)  OUTPUT,
   @cPickAndDropLOC  NVARCHAR( 10)  OUTPUT,
   @cFitCasesInAisle NVARCHAR( 1)   OUTPUT,
   @nPABookingKey    INT            OUTPUT, 
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
) AS

BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE 
   @nTranCount   INT,
   @SKU          NVARCHAR(20),
   @Style        NVARCHAR(10),
   @ABC          NVARCHAR(3),
   @Class        NVARCHAR(10),
   @cFromLOCType NVARCHAR(20),
   @cFromLocPAZ  NVARCHAR(20)

   UPDATE dbo.LOTxLOCxID WITH(ROWLOCK)
   SET PendingMoveIN = 0
   WHERE StorerKey = @cStorerKey
   AND PendingMoveIN > 0
   AND id <> ''
   AND NOT EXISTS (SELECT 1 FROM dbo.LOTxLOCxID lli2 WHERE qty>0 AND dbo.LOTxLOCxID.id = lli2.Id)

   IF EXISTS (SELECT 1 FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
   WHERE StorerKey = @cStorerKey
   AND PendingMoveIN > 0 AND Qty = 0 AND ID <> ''
   AND EXISTS (SELECT 1 FROM dbo.LOC L WITH(NOLOCK) WHERE LocationType = 'PND' AND facility = @cFacility AND LLI.loc = L.Loc))
   BEGIN
      UPDATE dbo.LOTxLOCxID
      SET PendingMoveIN = 0
	  WHERE StorerKey = @cStorerKey
      AND PendingMoveIN > 0 AND qty = 0 AND ID <> ''
      AND EXISTS (SELECT 1 FROM dbo.LOC L WITH(NOLOCK) WHERE LocationType = 'PND' AND facility = @cFacility AND dbo.LOTxLOCxID.loc = L.Loc)
      AND EXISTS (SELECT 1 FROM dbo.LOTxLOCxID LLI2 WITH(NOLOCK) WHERE dbo.LOTxLOCxID.Id = LLI2.Id AND StorerKey = @cStorerKey AND qty > 0 AND exists
      (SELECT 1 FROM dbo.LOC L2 WITH(NOLOCK) WHERE L2.Loc = LLI2.Loc 
      AND EXISTS (SELECT 1 FROM dbo.CODELKUP WITH(NOLOCK) WHERE LISTNAME = 'HUSQALLZON' AND Storerkey = @cStorerKey AND L2.PutawayZone = Code)))
   END

   IF EXISTS (SELECT 1 FROM dbo.LOTxLOCxID WITH(NOLOCK)
   WHERE StorerKey = @cStorerKey
   AND PendingMoveIN > 0 AND ID <> ''
   AND EXISTS (SELECT 1 FROM dbo.LOTxLOCxID LLI2 WITH(NOLOCK) WHERE LLI2.StorerKey = @cStorerKey AND dbo.LOTxLOCxID.Id = LLI2.Id AND LLI2.Qty > 0 AND ID <> ''
   AND EXISTS (SELECT 1 FROM dbo.LOC L WITH(NOLOCK) WHERE L.Loc = LLI2.Loc AND (LocationCategory = 'VNA' or LocationType = 'DAMAGED') AND Facility = @cFacility)))
   BEGIN
      UPDATE dbo.LOTxLOCxID
      SET PendingMoveIN = 0
      WHERE StorerKey = @cStorerKey
      AND PendingMoveIN > 0 AND ID <> ''
      AND EXISTS (SELECT 1 FROM dbo.LOTxLOCxID LLI2 WITH(NOLOCK) WHERE LLI2.StorerKey = @cStorerKey AND dbo.LOTxLOCxID.Id = LLI2.Id AND LLI2.Qty > 0 AND ID <> ''
      AND EXISTS (SELECT 1 FROM dbo.LOC L WITH(NOLOCK) WHERE L.Loc = LLI2.Loc AND (LocationCategory = 'VNA' or LocationType = 'DAMAGED') AND Facility = @cFacility))
   END

   IF EXISTS (SELECT 1 FROM dbo.LOTxLOCxID WITH(NOLOCK) 
   WHERE StorerKey = @cStorerKey
   AND PendingMoveIN > 0 AND ID <> ''
   AND EXISTS (SELECT 1 FROM dbo.LOTxLOCxID LLI2 WITH(NOLOCK) WHERE LLI2.StorerKey = @cStorerKey AND dbo.LOTxLOCxID.Id = LLI2.Id AND LLI2.Qty > 0 AND ID <> ''
   AND EXISTS (SELECT 1 FROM dbo.LOC L WITH(NOLOCK) WHERE L.Loc = LLI2.Loc AND Facility = @cFacility
   AND EXISTS (SELECT 1 FROM dbo.CODELKUP C WITH(NOLOCK) WHERE C.Storerkey = @cStorerKey AND C.Code = L.putawayzone AND C.LISTNAME = 'WAZONEHUSQ'))))
   BEGIN
      UPDATE dbo.LOTxLOCxID
      SET PendingMoveIN = 0
      WHERE StorerKey = @cStorerKey
      AND PendingMoveIN > 0 AND ID <> ''
      AND EXISTS (SELECT 1 FROM dbo.LOTxLOCxID LLI2 WHERE LLI2.StorerKey = @cStorerKey AND dbo.LOTxLOCxID.Id = LLI2.Id AND LLI2.Qty > 0 AND ID <> ''
      AND EXISTS (SELECT 1 FROM dbo.LOC L WITH(NOLOCK) WHERE L.Loc = LLI2.Loc AND Facility = @cFacility
      AND EXISTS (SELECT 1 FROM dbo.CODELKUP C WITH(NOLOCK) WHERE C.Storerkey = @cStorerKey AND C.Code = L.putawayzone AND C.LISTNAME = 'WAZONEHUSQ')))
   END

   SELECT TOP 1 @SKU = SKU FROM dbo.LOTxLOCxID WITH(NOLOCK) WHERE qty > 0 AND StorerKey = @cStorerkey AND ID = @cID AND Loc = @cFromLOC
   SELECT TOP 1 @Style = Style, @ABC = ABC, @Class = CLASS FROM dbo.SKU WITH(NOLOCK) WHERE Sku = @SKU AND StorerKey = @cStorerkey
   SELECT TOP 1 @cFromLOCType = LocationType, @cFromLocPAZ = PutawayZone FROM dbo.LOC WITH(NOLOCK) WHERE Facility = @cFacility AND loc = @cFromLOC

   --Check that LPN got only one SKU
   IF (SELECT COUNT(DISTINCT sku) FROM dbo.LOTxLOCxID WITH(NOLOCK) WHERE qty > 0 AND id = @cID AND loc = @cFromLOC AND storerkey = @cStorerKey)>1
   AND (1 NOT IN (SELECT short FROM dbo.CODELKUP WITH(NOLOCK) WHERE LISTNAME = 'HUSQPASSKU' AND storerkey = @cStorerKey) 
   OR 0 IN (SELECT short FROM dbo.CODELKUP WITH(NOLOCK) WHERE LISTNAME = 'HUSQPASSKU' AND storerkey = @cStorerKey))
   BEGIN
      SET @nErrNo = 217987
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO RollBackTran
   END

   --Check if pick location for SKU is set
   IF EXISTS (SELECT Sku FROM dbo.LOTxLOCxID WITH(NOLOCK)
   WHERE id = @cID
   AND qty > 0
   AND loc = @cFromLOC
   AND storerkey = @cStorerKey
   AND NOT EXISTS 
   (SELECT Sku FROM dbo.SKUxLOC WITH(NOLOCK)
   WHERE storerkey = @cStorerKey
   AND sku = dbo.LOTxLOCxID.Sku
   AND locationtype in ('PICK','CASE')
   AND QtyLocationLimit > 0))

   BEGIN
      SET @nErrNo = 217988
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO RollBackTran
   END

   --Establish an LPN type
   DECLARE @LPNPATYPE nvarchar(20)

   IF @Style = 'SHLV'
   BEGIN
      SET @nErrNo = 218028
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO RollBackTran
   END

   IF @Style = 'CON'
   BEGIN
      SET @nErrNo = 218029
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU is consumable
      GOTO RollBackTran
   END

   --Battery
   IF @Style = 'B'
   BEGIN
      SET @LPNPAType = 'Battery' 
   END

   --VelocityA
   ELSE IF @ABC = 'A'
   BEGIN
      SET @LPNPAType = 'VelocityA' 
   END

   --VelocityB
   ELSE IF	@ABC = 'B'
   BEGIN
      SET @LPNPAType = 'VelocityB' 
   END

   --VelocityC
   ELSE IF @ABC = 'C'
   BEGIN
      SET @LPNPAType = 'VelocityC' 
   END
	
   --VelocityE
   ELSE IF @ABC = 'E'
   BEGIN
      SET @LPNPAType = 'VelocityE' 
   END

   ELSE --Error if LPN type could not be established
   BEGIN
      SET @nErrNo = 217989
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Unknown PA LPN type'
      GOTO RollBackTran
   END

   --FLYMO check
   DECLARE @Flymo int
   SET @Flymo = 0

   IF @Class = 'FLY'
   BEGIN
      SET @Flymo = 1
   END

   IF NOT EXISTS (SELECT 1 FROM dbo.CODELKUP WITH(NOLOCK) WHERE listname = 'HUSQLPNTYP' AND udf01 = @LPNPAType AND short = 'VNA' AND Storerkey = @cStorerKey)
   BEGIN
      GOTO SkipVNA
   END

   --Creating list of available PnDs
   DECLARE @AvailablePnDAisle as TABLE (AvailablePnDAisle NVARCHAR(20))
   
   INSERT INTO @AvailablePnDAisle
   SELECT LocAisle FROM
   (SELECT MaxPallet, 
   (SELECT COUNT(DISTINCT ID) FROM dbo.LOTxLOCxID WITH(NOLOCK) WHERE qty+PendingMoveIN > 0 AND loc = L.Loc AND StorerKey = @cStorerKey AND ID <> @cID) SpaceTaken, --Finding how many pallets are in the location AND how much can fit there.
   L.Loc, LocationType, LocationFlag, LocationCategory, L.Cube, WeightCapacity, Status, PutawayZone, LocAisle,
   ISNULL(TotalWeight,0)TotalWeight, ISNULL(TotalCube,0)TotalCube, --This is FROM T1 table which calculate how much weight AND cube is in the location based on SKU qty.
   IDWeight, IDCube
   FROM dbo.LOC L WITH(NOLOCK)

   LEFT JOIN
   (
   SELECT Loc, SUM((LLI.qty+PendingMoveIN) * STDGROSSWGT) TotalWeight, SUM((LLI.qty+PendingMoveIN) * (WidthUOM3 * LengthUOM3 * HeightUOM3)) TotalCube --Fnding how much weight AND cube is in the location based on SKU qty.
   FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
   INNER JOIN dbo.SKU S WITH(NOLOCK)
   on LLI.Sku = S.Sku
   INNER JOIN dbo.PACK P WITH(NOLOCK)
   on s.PACKKey = p.PackKey
   WHERE (LLI.qty+PendingMoveIN)> 0
   AND LLI.StorerKey = @cStorerKey
   AND S.StorerKey = @cStorerKey
   AND id <> @cID
   GROUP BY loc
   )T1
   ON L.Loc = T1.Loc

   CROSS JOIN
   (SELECT ISNULL(SUM(lli.qty * STDGROSSWGT),0) IDWeight, ISNULL(SUM(lli.qty * (WidthUOM3 * LengthUOM3 * HeightUOM3)),0) IDCube FROM dbo.LOTxLOCxID LLI(NOLOCK) 
   INNER JOIN dbo.SKU S WITH(NOLOCK) ON LLI.Sku = S.Sku INNER JOIN dbo.PACK P WITH(NOLOCK) ON S.PACKKey = P.PackKey
   WHERE lli.qty > 0 AND LLI.storerkey = @cStorerKey AND id = @cID AND loc = @cFromLOC AND s.StorerKey = @cStorerKey)T2

   WHERE facility = @cFacility
   AND EXISTS (SELECT 1 FROM dbo.CODELKUP CLU WITH(NOLOCK) WHERE L.PutawayZone = CLU.Code AND CLU.LISTNAME = 'VNAZONHUSQ' AND CLU.Storerkey = @cStorerKey)
   AND LocationCategory = 'PND'
   AND LocationFlag in ('','NONE')
   AND status = 'OK'
   AND not EXISTS (SELECT 1 FROM dbo.INVENTORYHOLD WITH(NOLOCK) WHERE Hold = 1 AND ISNULL(loc,'') <> '' AND loc = l.loc AND Storerkey = @cStorerKey))T1

   WHERE MaxPallet - SpaceTaken > 0 AND 
   CASE WHEN 
   (1 NOT IN (SELECT short FROM dbo.CODELKUP WITH(NOLOCK) WHERE LISTNAME = 'HUSQCHKPND' AND storerkey = @cStorerKey) 
   OR 0 IN (SELECT short FROM dbo.CODELKUP WITH(NOLOCK) WHERE LISTNAME = 'HUSQCHKPND' AND storerkey = @cStorerKey))
   THEN 1 
   WHEN Cube - TotalCube - IDCube >= 0 AND WeightCapacity - TotalWeight - IDWeight >= 0 THEN 1 ELSE 0
   END = 1

   IF NOT EXISTS (SELECT 1 FROM @AvailablePnDAisle) AND
   NOT EXISTS (SELECT 1 FROM dbo.CODELKUP WITH(NOLOCK) WHERE listname = 'HUSQLPNTYP' AND udf01 = @LPNPAType AND short = 'WA' AND Storerkey = @cStorerKey)
   BEGIN
      SET @nErrNo = 218006
	  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'No available PnD'
	  GOTO RollBackTran
   END

   --Creating list of available VNA locations
   DECLARE @AvailableLoc as TABLE
   (AvailableLoc NVARCHAR(20),
   PALogicalLoc NVARCHAR(20),
   LocType NVARCHAR(20))

   INSERT INTO @AvailableLoc
   SELECT TOP 1 Loc, PALogicalLoc, 'VNA' FROM
   (SELECT SUBSTRING(L.Loc,6,1) LocLevel, MaxPallet, 
   (SELECT COUNT(DISTINCT ID) FROM dbo.LOTxLOCxID WITH(NOLOCK) WHERE qty+PendingMoveIN > 0 AND loc = L.Loc AND StorerKey = @cStorerKey AND id <> @cID) SpaceTaken, --Finding how many pallets are in the location AND how much can fit there.
   L.Loc, LocationType, LocationFlag, LocationCategory, l.Cube, WeightCapacity, Status, PutawayZone, LocAisle,
   ISNULL(TotalWeight,0)TotalWeight, ISNULL(TotalCube,0)TotalCube, --This is FROM T1 table which calculate how much weight AND cube is in the location based on SKU qty.
   IDWeight, IDCube, PALogicalLoc
   FROM dbo.LOC L WITH(NOLOCK)

   LEFT JOIN
   (
   SELECT SUM((lli.qty+PendingMoveIN) * STDGROSSWGT) TotalWeight, SUM((lli.qty+PendingMoveIN) * (WidthUOM3 * LengthUOM3 * HeightUOM3)) TotalCube, --Fnding how much weight AND cube is in the location based on SKU qty.
   Loc
   FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
   INNER JOIN dbo.SKU S WITH(NOLOCK)
   ON LLI.Sku = S.Sku
   INNER JOIN dbo.PACK P WITH(NOLOCK)
   ON S.PACKKey = P.PackKey
   WHERE (lli.qty+PendingMoveIN)> 0
   AND LLI.StorerKey = @cStorerKey
   AND id <> @cID
   GROUP BY loc
   )T1
   ON L.Loc = T1.Loc

   CROSS JOIN
   (SELECT ISNULL(SUM(lli.qty * STDGROSSWGT),0) IDWeight, ISNULL(SUM(lli.qty * (WidthUOM3 * LengthUOM3 * HeightUOM3)),0) IDCube FROM dbo.LOTxLOCxID LLI(NOLOCK) 
   INNER JOIN dbo.SKU S WITH(NOLOCK)
   on LLI.Sku = S.Sku
   INNER JOIN dbo.PACK P WITH(NOLOCK)
   on S.PACKKey = P.PackKey
   WHERE LLI.qty > 0 AND LLI.storerkey = @cStorerKey AND id = @cID AND loc = @cFromLOC)T2

   WHERE facility = @cFacility
   AND (EXISTS (SELECT 1 FROM dbo.CODELKUP CLU WITH(NOLOCK) WHERE L.PutawayZone = CLU.Code AND CLU.Storerkey = @cStorerKey AND CLU.LISTNAME = 'VNAZONHUSQ'))
   AND (EXISTS (SELECT 1 FROM dbo.CODELKUP CLU WITH(NOLOCK) WHERE L.LocationCategory = CLU.Code AND CLU.Storerkey = @cStorerKey AND CLU.LISTNAME = 'VNACATHUSQ'))
   AND (EXISTS (SELECT 1 FROM dbo.CODELKUP CLU WITH(NOLOCK) WHERE L.LocationType = CLU.Code AND CLU.Storerkey = @cStorerKey AND CLU.LISTNAME = 'VNATYPHUSQ'))
   AND LocationFlag in ('','NONE')
   AND status = 'OK'
   AND LocAisle IN (SELECT AvailablePnDAisle FROM @AvailablePnDAisle)
   AND NOT EXISTS (SELECT 1 FROM dbo.INVENTORYHOLD WITH(NOLOCK) WHERE Hold = 1 AND ISNULL(loc,'') <> '' AND loc = l.loc AND Storerkey = @cStorerKey))T3

   WHERE MaxPallet - SpaceTaken > 0 AND Cube - TotalCube - IDCube > 0 AND WeightCapacity - TotalWeight - IDWeight > 0
   
   --Filter by product type
   AND ((@Flymo = 1 AND EXISTS (SELECT 1 FROM dbo.CODELKUP CLU WITH(NOLOCK) WHERE T3.LocLevel = CLU.Long AND CLU.listname = 'HUSQLPNTYP' AND CLU.udf01 = 'Flymo' AND CLU.short = 'VNA' AND CLU.Storerkey = @cStorerKey))or @Flymo <> 1)
   AND ((EXISTS (SELECT 1 FROM dbo.CODELKUP CLU WITH(NOLOCK) WHERE T3.LocLevel = CLU.long AND CLU.listname = 'HUSQLPNTYP' AND CLU.udf01 = @LPNPAType AND CLU.short = 'VNA' AND CLU.Storerkey = @cStorerKey)))

   ORDER BY PALogicalLoc

   IF not EXISTS (SELECT 1 FROM @AvailableLoc) and
   not EXISTS (SELECT 1 FROM dbo.CODELKUP WITH(NOLOCK) WHERE listname = 'HUSQLPNTYP' AND udf01 = @LPNPAType AND short = 'WA' AND Storerkey = @cStorerKey)
   BEGIN
      SET @nErrNo = 218007
	  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'No suitable VNA Loc'
	  GOTO RollBackTran
   END

   SkipVNA:
   --Creating list of available Wide Aisle locations
   IF NOT EXISTS (SELECT 1 FROM dbo.CODELKUP WITH(NOLOCK) WHERE listname = 'HUSQLPNTYP' AND udf01 = @LPNPAType AND short = 'WA' AND Storerkey = @cStorerKey)
   BEGIN
      GOTO SkipWA
   END
   
   DECLARE @AvailableWALoc AS TABLE (AvailableWALoc NVARCHAR(20), PALogicalLoc NVARCHAR(20))
   
   INSERT INTO @AvailableWALoc
   SELECT Loc, PALogicalLoc FROM
   (SELECT SUBSTRING(L.Loc,6,1) LocLevel, MaxPallet, 
   (SELECT COUNT(DISTINCT ID) FROM dbo.LOTxLOCxID WITH(NOLOCK) WHERE qty+PendingMoveIN > 0 AND loc = L.Loc AND StorerKey = @cStorerKey AND id <> @cID) SpaceTaken, --Finding how many pallets are in the location AND how much can fit there.
   L.Loc, LocationType, LocationFlag, LocationCategory, L.Cube, WeightCapacity, Status, PutawayZone, LocAisle,
   ISNULL(TotalWeight,0)TotalWeight, ISNULL(TotalCube,0)TotalCube, --This is FROM T1 table which calculate how much weight AND cube is in the location based on SKU qty.
   IDWeight, IDCube, PALogicalLoc
   FROM dbo.LOC L WITH(NOLOCK)

   LEFT JOIN
   (
   SELECT SUM((lli.qty+PendingMoveIN) * STDGROSSWGT) TotalWeight, SUM((lli.qty+PendingMoveIN) * (WidthUOM3 * LengthUOM3 * HeightUOM3)) TotalCube, --Fnding how much weight AND cube is in the location based on SKU qty.
   Loc
   FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
   INNER JOIN dbo.SKU S WITH(NOLOCK)
   ON LLI.Sku = S.Sku
   INNER JOIN dbo.PACK P WITH(NOLOCK)
   ON S.PACKKey = p.PackKey
   WHERE (lli.qty+PendingMoveIN)> 0
   AND LLI.StorerKey = @cStorerKey
   AND id <> @cID
   GROUP BY loc
   )T1
   ON L.Loc = T1.Loc

   CROSS JOIN
   (SELECT ISNULL(SUM(lli.qty * STDGROSSWGT),0) IDWeight, ISNULL(SUM(lli.qty * (WidthUOM3 * LengthUOM3 * HeightUOM3)),0) IDCube FROM dbo.LOTxLOCxID LLI(NOLOCK) 
   INNER JOIN dbo.SKU S WITH(NOLOCK)
   ON LLI.Sku = S.Sku
   INNER JOIN dbo.PACK P WITH(NOLOCK)
   ON S.PACKKey = P.PackKey
   WHERE lli.qty > 0 AND LLI.storerkey = @cStorerKey AND id = @cID AND loc = @cFromLOC)T2

   WHERE facility = @cFacility
   AND (EXISTS (SELECT 1 FROM dbo.CODELKUP CLU WITH(NOLOCK) WHERE L.PutawayZone = CLU.Code AND CLU.Storerkey = @cStorerKey AND CLU.LISTNAME = 'WAZONEHUSQ'))
   AND (EXISTS (SELECT 1 FROM dbo.CODELKUP CLU WITH(NOLOCK) WHERE L.LocationCategory = CLU.Code AND CLU.Storerkey = @cStorerKey AND CLU.LISTNAME = 'WACATHUSQ'))
   AND (EXISTS (SELECT 1 FROM dbo.CODELKUP CLU WITH(NOLOCK) WHERE L.LocationType = CLU.code AND CLU.Storerkey = @cStorerKey AND CLU.LISTNAME = 'WATYPEHUSQ'))
   AND LocationFlag in ('','NONE')
   AND status = 'OK'
   AND not EXISTS (SELECT 1 FROM dbo.INVENTORYHOLD WITH(NOLOCK) WHERE Hold = 1 AND ISNULL(loc,'') <> '' AND loc = l.loc AND Storerkey = @cStorerKey))T3

   WHERE MaxPallet - SpaceTaken > 0 AND Cube - TotalCube - IDCube > 0 AND WeightCapacity - TotalWeight - IDWeight > 0

   --Filter by product type
   AND ((@Flymo = 1 AND EXISTS (SELECT 1 FROM dbo.CODELKUP CLU WITH(NOLOCK) WHERE T3.LocLevel = CLU.Long AND CLU.listname = 'HUSQLPNTYP' AND CLU.udf01 = 'Flymo' AND CLU.short = 'WA' AND CLU.Storerkey = @cStorerKey))or @Flymo <> 1)
   AND ((EXISTS (SELECT 1 FROM dbo.CODELKUP CLU WITH(NOLOCK) WHERE T3.LocLevel = CLU.Long AND CLU.listname = 'HUSQLPNTYP' AND CLU.udf01 = @LPNPAType AND CLU.short = 'WA' AND CLU.Storerkey = @cStorerKey)))	

   --Creating proximity check for Wide Aisle locations
   INSERT INTO @AvailableLoc
   SELECT TOP 1 AvailableWALoc, PALogicalLoc, 'WA' FROM
   (SELECT AvailableWALoc, PALogicalLoc,
   ABS(CONVERT(float,(CONVERT(nvarchar(3),ASCII(SUBSTRING(AvailableWALoc,1,1)))+
   CONVERT(nvarchar(3),ASCII(SUBSTRING(AvailableWALoc,2,1)))+
   CONVERT(nvarchar(3),ASCII(SUBSTRING(AvailableWALoc,3,1)))+
   CONVERT(nvarchar(3),ASCII(SUBSTRING(AvailableWALoc,4,1)))+
   CONVERT(nvarchar(3),ASCII(SUBSTRING(AvailableWALoc,5,1)))+
   CONVERT(nvarchar(3),ASCII(SUBSTRING(AvailableWALoc,6,1)))+
   CONVERT(nvarchar(3),ASCII(SUBSTRING(AvailableWALoc,7,1)))))
   - Coordinates2)Proximity
   FROM @AvailableWALoc
   CROSS JOIN
   (SELECT 
   CONVERT(nvarchar(3),ASCII(SUBSTRING(Loc,1,1)))+
   CONVERT(nvarchar(3),ASCII(SUBSTRING(Loc,2,1)))+
   CONVERT(nvarchar(3),ASCII(SUBSTRING(Loc,3,1)))+
   CONVERT(nvarchar(3),ASCII(SUBSTRING(Loc,4,1)))+
   CONVERT(nvarchar(3),ASCII(SUBSTRING(Loc,5,1)))+
   CONVERT(nvarchar(3),ASCII(SUBSTRING(Loc,6,1)))+
   CONVERT(nvarchar(3),ASCII(SUBSTRING(Loc,7,1)))Coordinates2
   FROM dbo.SKUxLOC WITH(NOLOCK) --Retrieving pick SKUs 
   WHERE StorerKey = @cStorerKey 
   AND sku = (SELECT TOP 1 sku FROM dbo.LOTxLOCxID WITH(NOLOCK) WHERE qty > 0 AND id = @cID AND loc = @cFromLOC AND storerkey = @cStorerKey)
   AND QtyLocationLimit > 0)T1)T2
   ORDER BY Proximity, PALogicalLoc

   IF NOT EXISTS (SELECT 1 FROM @AvailableWALoc)
   AND NOT EXISTS (SELECT 1 FROM dbo.CODELKUP WITH(NOLOCK) WHERE listname = 'HUSQLPNTYP' AND udf01 = @LPNPAType AND short = 'VNA' AND Storerkey = @cStorerKey)
   BEGIN
      SET @nErrNo = 218008
	  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'No suitable WA Loc'
	  GOTO RollBackTran
   END

   ------custom code before global putaway SP END
   SkipWA:

   DECLARE @LocAisle NVARCHAR(10),
   @PendingLoc NVARCHAR(20)

   SET @PendingLoc = CASE WHEN EXISTS (SELECT 1 FROM dbo.LOTxLOCxID WITH(NOLOCK) WHERE id = @cID AND PendingMoveIN > 0 AND StorerKey = @cStorerKey) then
   (SELECT TOP 1 LOC FROM dbo.LOTxLOCxID WITH(NOLOCK) WHERE id = @cID AND PendingMoveIN > 0 AND StorerKey = @cStorerKey) ELSE '' END

   SET @cSuggLOC = CASE WHEN @PendingLoc <> '' THEN @PendingLoc
   WHEN not EXISTS (SELECT 1 FROM @AvailableLoc) THEN '' ELSE (SELECT TOP 1 AvailableLoc FROM @AvailableLoc ORDER BY PALogicalLoc) END 

   SELECT TOP 1 @LocAisle = locaisle FROM dbo.LOC WITH(NOLOCK) WHERE Facility = @cFacility AND loc = (SELECT TOP 1 AvailableLoc FROM @AvailableLoc ORDER BY PALogicalLoc)

   SET @cPickAndDropLOC = CASE WHEN NOT EXISTS (SELECT 1 FROM @AvailableLoc) 
   OR (SELECT TOP 1 LocType FROM @AvailableLoc ORDER BY PALogicalLoc) <> 'VNA' 
   OR (@cFromLOCType = 'PND' AND EXISTS (SELECT 1 FROM dbo.CODELKUP WITH(NOLOCK) WHERE @cFromLocPAZ = code AND storerkey = @cStorerKey AND LISTNAME = 'VNAZONHUSQ'))
   THEN ''
   else
   (SELECT TOP 1 Loc FROM
   (SELECT MaxPallet, 
   (SELECT COUNT(DISTINCT ID) FROM dbo.LOTxLOCxID WITH(NOLOCK) WHERE qty+PendingMoveIN > 0 AND loc = L.Loc AND StorerKey = @cStorerKey AND id <> @cID) SpaceTaken, --Finding how many pallets are in the location AND how much can fit there.
   L.Loc, LocationType, LocationFlag, LocationCategory, L.Cube, WeightCapacity, Status, PutawayZone, LocAisle,
   ISNULL(TotalWeight,0)TotalWeight, ISNULL(TotalCube,0)TotalCube, --This is FROM T1 table which calculate how much weight AND cube is in the location based on SKU qty.
   IDWeight, IDCube
   FROM dbo.LOC L WITH(NOLOCK)

   LEFT JOIN
   (
   SELECT SUM((lli.qty+PendingMoveIN) * STDGROSSWGT) TotalWeight, SUM((lli.qty+PendingMoveIN) * (WidthUOM3 * LengthUOM3 * HeightUOM3)) TotalCube, --Fnding how much weight AND cube is in the location based on SKU qty.
   Loc
   FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
   INNER JOIN dbo.SKU S WITH(NOLOCK)
   ON LLI.Sku = S.Sku
   INNER JOIN dbo.PACK P WITH(NOLOCK)
   ON S.PACKKey = P.PackKey
   WHERE (lli.qty+PendingMoveIN)> 0
   AND LLI.StorerKey = @cStorerKey
   AND id <> @cID
   GROUP BY loc
   )T1
   ON L.Loc = T1.Loc

   CROSS JOIN
   (SELECT ISNULL(SUM(lli.qty * STDGROSSWGT),0) IDWeight, ISNULL(SUM(lli.qty * (WidthUOM3 * LengthUOM3 * HeightUOM3)),0) IDCube FROM dbo.LOTxLOCxID LLI(NOLOCK) 
   INNER JOIN dbo.SKU S WITH(NOLOCK) ON LLI.Sku = S.Sku INNER JOIN dbo.PACK P WITH(NOLOCK) ON S.PACKKey = P.PackKey
   WHERE lli.qty > 0 AND LLI.storerkey = @cStorerKey AND id = @cID AND loc = @cFromLOC)T2

   WHERE facility = @cFacility
   AND EXISTS (SELECT code FROM dbo.CODELKUP CLU WITH(NOLOCK) WHERE L.PutawayZone = CLU.code AND CLU.LISTNAME = 'VNAZONHUSQ' AND CLU.Storerkey = @cStorerKey)
   AND L.LocationCategory = 'PND'
   AND L.LocationFlag in ('','NONE')
   AND Status = 'OK'
   AND LocAisle = @LocAisle
   AND NOT EXISTS (SELECT 1 FROM dbo.INVENTORYHOLD WITH(NOLOCK) WHERE Hold = 1 AND ISNULL(loc,'') <> '' AND loc = l.loc AND Storerkey = @cStorerKey))T1

   WHERE MaxPallet - SpaceTaken > 0 AND 
   CASE WHEN 
   (1 NOT IN (SELECT short FROM dbo.CODELKUP WITH(NOLOCK) WHERE LISTNAME = 'HUSQCHKPND' AND storerkey = @cStorerKey) 
   OR 0 IN (SELECT short FROM dbo.CODELKUP WITH(NOLOCK) WHERE LISTNAME = 'HUSQCHKPND' AND storerkey = @cStorerKey))
   THEN 1 
   WHEN Cube - TotalCube - IDCube >= 0 AND WeightCapacity - TotalWeight - IDWeight >= 0 THEN 1 ELSE 0
   END = 1) END

   SET @cFitCasesInAisle = ''

   DECLARE @PnDRequired int
   SET @PnDRequired = CASE WHEN (SELECT TOP 1 LocType FROM @AvailableLoc ORDER BY PALogicalLoc) = 'VNA' THEN 1 ELSE 0 END

   IF @PnDRequired = 1 AND not EXISTS (SELECT 1 FROM @AvailablePnDAisle)
   BEGIN
      SET @nErrNo = 217990
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No PnD loc available
      GOTO Quit
   END

   -- Check suggest loc
   IF @cSuggLOC = ''
   BEGIN
      SET @nErrNo = 217991
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No PA loc available
      GOTO Quit
   END
   
   -- Lock suggested location
   BEGIN
      -- Get LOC aisle
      DECLARE 
      @cLOCAisle  NVARCHAR(10),
      @cLOCCat    NVARCHAR(10),
      @cPAZone    NVARCHAR(10),
      @cPAPNDReq  NVARCHAR(10)
   
      -- Handling transaction
      RollBackTran:
      SET @nTranCount = @@TRANCOUNT
      BEGIN TRAN  -- Begin our own transaction
      SAVE TRAN rdt_1819ExtPASPVLT4 -- For rollback or commit only our own transaction
      
      IF @nErrNo<>0
      BEGIN
         GOTO RollbackTran2
      END

      SET @nPABookingKey = 0
      IF @cFitCasesInAisle <> 'Y'
      BEGIN
         EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK'
         ,@cFromLOC
         ,@cID
         ,@cSuggLOC
         ,@cStorerKey
         ,@nErrNo  OUTPUT
         ,@cErrMsg OUTPUT
         ,@nPABookingKey = @nPABookingKey OUTPUT

         IF @nErrNo <> 0
            GOTO RollBackTran2
      END

      -- Lock PND location
      IF @cPickAndDropLOC <> ''
      BEGIN
         EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK'
         ,@cFromLOC
         ,@cID
         ,@cPickAndDropLOC
         ,@cStorerKey
         ,@nErrNo  OUTPUT
         ,@cErrMsg OUTPUT
         ,@nPABookingKey = @nPABookingKey OUTPUT

         IF @nErrNo <> 0
            GOTO RollBackTran2
      END

   UPDATE dbo.LOTxLOCxID
   SET PendingMoveIN = PendingMoveIN / 2
   WHERE id = @cID AND loc = @PendingLoc AND storerkey = @cStorerKey AND PendingMoveIN > 0 AND ID <> ''

   COMMIT TRAN rdt_1819ExtPASPVLT4 -- Only commit change made here
   END

   DELETE FROM dbo.RFPUTAWAY
   WHERE id = @cID AND StorerKey = @cStorerKey

   UPDATE dbo.LOTxLOCxID
   SET PendingMoveIN = 0
   WHERE StorerKey = @cStorerKey
   AND PendingMoveIN > 0 AND qty = 0 AND id = @cID AND ID <> ''
   AND EXISTS (SELECT 1 FROM dbo.LOC L WITH(NOLOCK) WHERE LocationType = 'PND' AND facility = @cFacility AND dbo.LOTxLOCxID.loc = L.Loc)
   AND EXISTS (SELECT 1 FROM dbo.LOTxLOCxID LLI2 WITH(NOLOCK) WHERE dbo.LOTxLOCxID.Id = LLI2.Id AND StorerKey = @cStorerKey AND qty > 0 AND exists
   (SELECT 1 FROM dbo.LOC L2 WITH(NOLOCK) WHERE L2.Loc = LLI2.Loc 
   AND EXISTS (SELECT 1 FROM dbo.CODELKUP WITH(NOLOCK) WHERE LISTNAME = 'HUSQALLZON' AND Storerkey = @cStorerKey AND L2.PutawayZone = Code)))

   GOTO Quit

   RollBackTran2:
   ROLLBACK TRAN rdt_1819ExtPASPVLT4 -- Only rollback change made here

   Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
   COMMIT TRAN

END
GO
GRANT EXECUTE ON [RDT].[rdt_1819ExtPASPVLT4] TO [NSQL]
GO