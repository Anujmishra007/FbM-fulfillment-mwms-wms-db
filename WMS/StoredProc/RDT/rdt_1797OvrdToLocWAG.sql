
/**************************************************************************/
/* Store procedure: rdt_1797OvrdToLocWAG                                     */
/*                                                                        */
/* Purpose:         WAG - Whiteaway Extended Validation SP                 */
/*                                                                        */
/* Validation Rules:														*/
/*     Location Override Confirmation                                      */
/*			> To Location must be designated for WAG storer					*/
/*			> Disallow override to loc if breach loc.MaxPallet          	*/
/*			> IF override to PF then must be correct SKU					*/
/*			> IF override to PF then must not breach location max limit		*/
/*                                                                        */
/* Date        Rev  Author   Purposes                                     */
/* 27-04-2026  1.0  JRA432   Initial Version                              */
/* 27/05/2026  1.1  JRA432   Additional Validations                       */
/**************************************************************************/

CREATE OR ALTER               PROC [RDT].[rdt_1797OvrdToLocWAG] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @cTaskdetailKey   NVARCHAR( 10),
   @cSuggToLOC       NVARCHAR( 10),
   @cToLOC           NVARCHAR( 10),
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   --Default Skip Override Reason Code Screen (0 = Reason Code Required / -1 = No Reason Code)
   SET @nErrNo = -1

   DECLARE 
	  @cStorerKey          NVARCHAR(15),
	  @cFacility		NVARCHAR(15),
	  @cSKU				NVARCHAR(20),
	  @cFromId			NVARCHAR(18),
	  @cSkuPutawayZone	NVARCHAR(15),
	  @cLocPutawayZone	NVARCHAR(15),
	  @cLocLevel		INT,
	  @cLoseId			nvarchar(1),
	  @nMaxPallet		INT,
	  @nCountPallet		INT,
	  @cFromLoc			NVARCHAR(10),
	  @nQty				INT= 0,
	  @nPFQty			INT = 0,
	  @nPFQtyLimit		INT = 0	  --@cI_Field01		nvarchar(60)

   SELECT @cStorerKey = StorerKey , @cFacility = Facility
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   SELECT  
      @cSKU = SKU,
	  @cFromLoc = FromLoc,
	  @cFromId = FromID,
	  @nQty = Qty
   FROM dbo.TaskDetail WITH(NOLOCK)
   WHERE Storerkey = @cStorerKey
   AND TaskDetailKey = @cTaskdetailKey

   BEGIN -- To Location must be designated for WAG storer   
      --Get To Location Putaway Zone
	  SELECT TOP 1 @cLocPutawayZone = LOC.PutawayZone 
	  FROM dbo.LOC WITH(NOLOCK) 
	  WHERE Facility = @cFacility
	  AND Loc = @cToLOC

      --Check Putaway Zone is valid for specific Storer vs Codelkup (ListName = VALIDZONE)
	  IF NOT EXISTS(SELECT 1 FROM dbo.Codelkup WITH(NOLOCK)
					WHERE Storerkey = @cStorerKey
					AND Code2 = @cFacility
					AND ListName = 'VALIDZONE'
					AND UDF01 = 'PUTAWAYZONE'
					AND Code = @cLocPutawayZone)
	  BEGIN
	     SET @nErrNo = 52754
	     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InvalidLOC
	     GOTO Quit
	  END
   END

   -- Do not allow override to new location if loc.MaxPallet will be breached
   BEGIN
      SELECT
	     @nMaxPallet = ISNULL(MaxPallet, 0),
		 @cLoseId = CASE WHEN ISNULL(LoseId,'0') IN ('0','N','') THEN '0' ELSE '1' END
	  FROM dbo.Loc (NOLOCK)
	  WHERE Facility = @cFacility
	  AND Loc = @cToLOC
	  IF @nMaxPallet = 0 OR @nMaxPallet = ''
	     -- No max pallet limit defined for location
	     GOTO SkipMaxPalCheck 
	  IF @cLoseId = '0' 
	  BEGIN
	     SELECT 
		    @nCountPallet = COUNT(DISTINCT ID) 
		 FROM Dbo.Lotxlocxid (NOLOCK)
		 WHERE Storerkey = @cStorerKey 
		 AND Loc = @cToLOC 
		 AND Id <> @cFromID
		 AND Qty > 0

		 IF @nCountPallet >= @nMaxPallet 
		 BEGIN
		    SET @nErrNo = 263655
			SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Over max pallet capacity
			GOTO Quit
		 END
      END
   END
   SkipMaxPalCheck:

   -- When overrriding to a pickface check pickface is for the right SKU
   IF EXISTS(SELECT 1 FROM dbo.SkuxLoc (NOLOCK) 
			 WHERE Storerkey = @cStorerKey 
			 AND Loc = @cToLOC 
			 AND Sku <> @cSKU
			 AND LocationType = 'PICK')
   BEGIN
      SET @nErrNo = 1
	  SET @cErrMsg = 'PF for diff SKU' --rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- PF for diff SKU
	  GOTO Quit
   END
   
   -- When overrriding to a pickface check that inventory can fit within defined max limit			   
   IF EXISTS(SELECT 1 FROM dbo.SkuxLoc (NOLOCK) 
			 WHERE Storerkey = @cStorerKey 
			 AND Loc = @cToLOC 
			 AND Sku = @cSKU
			 AND LocationType = 'PICK')
   BEGIN
	  --Calc PF current qty + expected qty in replen tasks 
	  SELECT 
	     @nPFQty = SUM(ISNULL(SxL.Qty, 0)) + SUM(ISNULL(TD.QTY, 0))
	  FROM TaskDetail TD
	  JOIN SkuxLoc SxL ON SxL.StorerKey = TD.StorerKey AND SxL.Sku = TD.Sku AND (SxL.Loc = TD.FinalLoc OR SxL.Loc = TD.ToLoc)
	  WHERE TD.StorerKey = @cStorerKey
	  AND TD.TaskType in ('RPT','RPF') 
	  AND TD.[Status] not in ( '9','X')
	  AND TD.Sku = @cSKU 
	  AND (TD.FinalLoc = @cToLOC OR TD.ToLoc = @cToLOC)
	  -- Get PF location limit
	  SELECT @nPFQtyLimit = QtyLocationLimit 
	  FROM dbo.SkuxLoc (NOLOCK)
	  WHERE Storerkey = @cStorerKey 
	  AND Loc = @cToLOC 
	  AND Sku = @cSKU
	  AND LocationType = 'PICK'

	  IF @nPFQtyLimit > 0 AND @nPFQty + @nQty > @nPFQtyLimit
	  BEGIN
	     SET @nErrNo = 1
		 SET @cErrMsg = 'Over Max PF Qty' --rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Over Max PF Qty
		 GOTO Quit
	  END
   END
Quit:

END

GO
 
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
GRANT EXECUTE ON RDT.rdt_1797OvrdToLocWAG TO NSQL
GO

