if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ispRDTGenCountSheet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ispRDTGenCountSheet]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Stored Procedure: ispRDTGenCountSheet                             	*/
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by: ChewKP                                                   */
/*                                                                      */
/* Purpose: Generate StockTake Count Sheet			                     */
/*                                                                      */
/* Called By: 		                                                      */
/*                                                                      */
/* PVCS Version: 1.14		                                             */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author     Purposes                                     */
/************************************************************************/

CREATE PROC ispRDTGenCountSheet (
@c_StockTakeKey NVARCHAR(10)
,@c_Loc NVARCHAR(10)
,@c_SKU NVARCHAR(20) = ''
,@c_TaskDetailKey NVARCHAR(10)
)
AS
BEGIN
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF
   	
DECLARE @c_Facility	   NVARCHAR(5),
	@c_StorerKey	      NVARCHAR(18),
	@c_AisleParm	      NVARCHAR(60),
	@c_LevelParm	      NVARCHAR(60),
	@c_ZoneParm	         NVARCHAR(60),
	@c_HostWHCodeParm    NVARCHAR(60),
	@c_ClearHistory	   NVARCHAR(1),
	@c_WithQuantity      NVARCHAR(1),
	@c_EmptyLocation     NVARCHAR(1),
	@n_LinesPerPage      int,
	@c_SKUParm           NVARCHAR(125),
	-- Added by SHONG 01 OCT 2002
	@c_AgencyParm        NVARCHAR(150),
	@c_ABCParm           NVARCHAR(60),
	@c_SkuGroupParm      NVARCHAR(125),
	@c_ExcludeQtyPicked  NVARCHAR(1),
   @c_CCSheetNoKeyName NVARCHAR(30) -- NJOW03

-- declare a select condition variable for parameters
-- SOS42806 Changed NVARCHAR(250) and NVARCHAR(255) to NVARCHAR(800)
DECLARE @c_AisleSQL	   NVARCHAR(800),
	@c_LevelSQL	         NVARCHAR(800),
	@c_ZoneSQL	         NVARCHAR(800),
	@c_HostWHCodeSQL     NVARCHAR(800),
	@c_AisleSQL2	      NVARCHAR(800),
	@c_LevelSQL2	      NVARCHAR(800),
	@c_ZoneSQL2	         NVARCHAR(800),
	@c_HostWHCodeSQL2    NVARCHAR(800),
	@c_SKUSQL            NVARCHAR(800),
	@c_SKUSQL2           NVARCHAR(800),
	@b_success           int,
	@c_AgencySQL         NVARCHAR(800),
	@c_AgencySQL2        NVARCHAR(800),
	@c_ABCSQL            NVARCHAR(800),
	@c_ABCSQL2           NVARCHAR(800), 
	@c_SkuGroupSQL       NVARCHAR(800),
	@c_SkuGroupSQL2      NVARCHAR(800)

-- Add by June 12.Mar.02 FBR063
-- SOS42806
DECLARE   @c_StorerSQL  NVARCHAR(800)
, @c_StorerSQL2 NVARCHAR(800)
, @c_StorerParm NVARCHAR(60)
, @c_GroupLottable05 NVARCHAR(10)

SELECT @c_Facility = Facility,
	-- @c_StorerKey = StorerKey,     Remark by June 12.Mar.02 FBR063
	@c_StorerParm = StorerKey,
	@c_AisleParm = AisleParm,
	@c_LevelParm = LevelParm,
	@c_ZoneParm = ZoneParm,
	@c_HostWHCodeParm = HostWHCodeParm,
	@c_WithQuantity = WithQuantity,
	@c_ClearHistory = ClearHistory,
	@c_EmptyLocation = EmptyLocation,
	@n_LinesPerPage = LinesPerPage,
	@c_SKUParm      = SKUParm,
	@c_GroupLottable05 = GroupLottable05,
	@c_AgencyParm = AgencyParm,
	@c_ABCParm = ABCParm,
	@c_SkuGroupParm = SkuGroupParm,
   @c_ExcludeQtyPicked = ExcludeQtyPicked    
FROM StockTakeSheetParameters (NOLOCK)
WHERE StockTakeKey = @c_StockTakeKey
SET NOCOUNT ON

/*
-- Remark by June 12.Mar.02 FBR063
IF @c_StorerKey IS NULL
BEGIN
RETURN
END
*/

IF @n_LinesPerPage = 0 OR @n_LinesPerPage IS NULL
SELECT @n_LinesPerPage = 999
--
---- Start - Add by June 12.Mar.02 FBR063
--EXEC ispParseParameters
--@c_StorerParm,
--'string',
--'LOTXLOCXID.StorerKey',
--@c_StorerSQL OUTPUT,
--@c_StorerSQL2 OUTPUT,
--@b_success OUTPUT
--IF @c_StorerSQL IS NULL And @c_StorerSQL2 IS NULL
--BEGIN
--RETURN
--END
---- End - Add by June 12.Mar.02  FBR063
--EXEC ispParseParameters
--@c_AisleParm,
--'string',
--'LOC.LOCAISLE',
--@c_AisleSQL OUTPUT,
--@c_AisleSQL2 OUTPUT,
--@b_success OUTPUT
--EXEC ispParseParameters
--@c_LevelParm,
--'number',
--'LOC.LocLevel',
--@c_LevelSQL OUTPUT,
--@c_LevelSQL2 OUTPUT,
--@b_success OUTPUT
--EXEC ispParseParameters
--@c_ZoneParm,
--'string',
--'LOC.PutawayZone',
--@c_ZoneSQL OUTPUT,
--@c_ZoneSQL2 OUTPUT,
--@b_success OUTPUT
--EXEC ispParseParameters
--@c_HostWHCodeParm,
--'string',
--'LOC.HostWHCode',
--@c_HostWHCodeSQL OUTPUT,
--@c_HostWHCodeSQL2 OUTPUT,
--@b_success OUTPUT
--EXEC ispParseParameters
--@c_SKUParm,
--'string',
--'LOTxLOCxID.SKU',
--@c_SKUSQL OUTPUT,
--@c_SKUSQL2 OUTPUT,
--@b_success OUTPUT

-- Purge All the historical records for this stocktakekey if clear history flag = 'Y'
--IF @c_ClearHistory = 'Y'
--BEGIN
--   DELETE CCDETAIL
--   WHERE  CCKEY = @c_StockTakeKey
--END

-- Added By SHONG 01 Oct 2002
--EXEC ispParseParameters 
--     @c_AgencyParm,
--     'string',
--     'SKU.SUSR3',
--     @c_AgencySQL OUTPUT,
--     @c_AgencySQL2 OUTPUT,
--     @b_success OUTPUT
--
--EXEC ispParseParameters 
--     @c_ABCParm,
--     'string',
--     'SKU.ABC',
--     @c_ABCSQL OUTPUT,
--     @c_ABCSQL2 OUTPUT,
--     @b_success OUTPUT
---- End
--
--EXEC ispParseParameters 
--     @c_SkuGroupParm,
--     'string',
--     'SKU.SKUGROUP',
--     @c_SkuGroupSQL OUTPUT,
--     @c_SkuGroupSQL2 OUTPUT,
--     @b_success OUTPUT

UPDATE StockTakeSheetParameters
   SET FinalizeStage = 0,
       PopulateStage = 0
WHERE StockTakeKey = @c_StockTakeKey

IF dbo.fnc_RTrim(@c_WithQuantity) = '' OR @c_WithQuantity IS NULL
SELECT @c_WithQuantity = 'N'

-- Create Temp Result Table
SELECT LOTxLOCxID.lot,
	LOTxLOCxID.loc,
	LOTxLOCxID.id,
	LOTxLOCxID.StorerKey,
	LOTxLOCxID.sku,
	LOTATTRIBUTE.Lottable01,
	LOTATTRIBUTE.Lottable02,
	LOTATTRIBUTE.Lottable03,
	LOTATTRIBUTE.Lottable04,
	LOTATTRIBUTE.Lottable05,
	Qty = 0,
	LOC.PutawayZone,
	LOC.LocLevel,
	Aisle = LOC.locAisle,
	LOC.Facility,
	LOC.CCLogicalLoc
INTO #RESULT
FROM	LOTxLOCxID (NOLOCK),
	SKU (NOLOCK),
	LOTATTRIBUTE (NOLOCK),
	LOC (NOLOCK)
WHERE	1=2

DECLARE @c_SQL NVARCHAR(max)

-- Start : SOS66279
DECLARE @c_sqlOther NVARCHAR(4000),
		  @c_sqlWhere NVARCHAR(4000),
		  @c_sqlGroup NVARCHAR(4000) 

SELECT  @c_sqlOther = ''
-- End : SOS66279

--IF dbo.fnc_RTrim(@c_GroupLottable05) = 'MIN'
--BEGIN
--	-- Start : SOS66279
--	IF NOT EXISTS (SELECT 1 FROM STOCKTAKEPARM2 WITH (NOLOCK) WHERE Stocktakekey = @c_StockTakeKey)
--	BEGIN
--	-- End : SOS66279
--		SELECT @c_SQL =  'INSERT INTO #RESULT '
--		+ 'SELECT SPACE(10),LOTxLOCxID.loc,LOTxLOCxID.id,LOTxLOCxID.StorerKey,'
--		+ 'LOTxLOCxID.sku,LOTATTRIBUTE.Lottable01,LOTATTRIBUTE.Lottable02,'
--		+ 'LOTATTRIBUTE.Lottable03,LOTATTRIBUTE.Lottable04, MIN(LOTATTRIBUTE.Lottable05),'
--	   + CASE WHEN @c_ExcludeQtyPicked = 'Y' THEN 'Qty = SUM(LOTxLOCxID.qty-LOTxLOCxID.qtypicked),' ELSE 'Qty = SUM(LOTxLOCxID.qty),' END
--		+ 'LOC.PutawayZone,LOC.LocLevel,Aisle = LOC.locAisle,LOC.Facility, LOC.CCLogicalLoc '
--		+ 'FROM	LOTxLOCxID (NOLOCK), SKU (NOLOCK), LOTATTRIBUTE (NOLOCK), LOC (NOLOCK) '
--		+ 'WHERE LOTxLOCxID.StorerKey = SKU.StorerKey '
--		+ 'AND   LOTxLOCxID.sku = SKU.sku '
--		+ 'AND   LOTxLOCxID.lot = LOTATTRIBUTE.lot '
--		+ 'AND   LOTxLOCxID.loc = LOC.loc '
--	   + CASE WHEN @c_ExcludeQtyPicked = 'Y' THEN 'AND   LOTxLOCxID.Qty-LOTxLOCxID.QtyPicked > 0 ' ELSE 'AND   LOTxLOCxID.Qty > 0 ' END
--		+ 'AND   LOC.Facility = "' + ISNULL(dbo.fnc_RTrim(@c_Facility), '') + '" '
--		+ ISNULL(dbo.fnc_RTrim(@c_StorerSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_StorerSQL2), '') + ' '
--		+ ISNULL(dbo.fnc_RTrim(@c_ZoneSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_ZoneSQL2), '') + ' '
--		+ ISNULL(dbo.fnc_RTrim(@c_AisleSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_AisleSQL2), '') + ' '
--		+ ISNULL(dbo.fnc_RTrim(@c_LevelSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_LevelSQL2), '') + ' '
--		+ ISNULL(dbo.fnc_RTrim(@c_HostWHCodeSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_HostWHCodeSQL2), '') + ' '
--		+ ISNULL(dbo.fnc_RTrim(@c_SKUSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_SKUSQL2), '') + ' '
--		+ ISNULL(dbo.fnc_RTrim(@c_AgencySQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_AgencySQL2), '') + ' '
--		+ ISNULL(dbo.fnc_RTrim(@c_ABCSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_ABCSQL2), '') + ' '
--		+ ISNULL(dbo.fnc_RTrim(@c_SkuGroupSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_SkuGroupSQL2), '') + ' '
--		+ 'GROUP BY LOTxLOCxID.loc,LOTxLOCxID.id,LOTxLOCxID.StorerKey,' -- By SHONG 26th Jul 2002, Remove the LOT from this line
--		+ 'LOTxLOCxID.sku,LOTATTRIBUTE.Lottable01,LOTATTRIBUTE.Lottable02,LOTATTRIBUTE.Lottable03,'
--		+ 'LOTATTRIBUTE.Lottable04,LOC.PutawayZone,LOC.LocLevel,LOC.locAisle, LOC.Facility, LOC.CCLogicalLoc'
--	-- Start : SOS66279
--	END 
--	ELSE
--	BEGIN
--		SELECT @c_sql = N'INSERT INTO #RESULT '
--		+ 'SELECT SPACE(10),LOTxLOCxID.loc,LOTxLOCxID.id,LOTxLOCxID.StorerKey,'
--		+ 'LOTxLOCxID.sku,LOTATTRIBUTE.Lottable01,LOTATTRIBUTE.Lottable02,'
--		+ 'LOTATTRIBUTE.Lottable03,LOTATTRIBUTE.Lottable04, MIN(LOTATTRIBUTE.Lottable05),'
--	   + CASE WHEN @c_ExcludeQtyPicked = 'Y' THEN 'Qty = SUM(LOTxLOCxID.qty-LOTxLOCxID.qtypicked),' ELSE 'Qty = SUM(LOTxLOCxID.qty),' END
--		+ 'LOC.PutawayZone,LOC.LocLevel,Aisle = LOC.locAisle,LOC.Facility, LOC.CCLogicalLoc '
--		+ 'FROM	LOTxLOCxID WITH (NOLOCK) '
--		+ 'JOIN  SKU WITH (NOLOCK) ON SKU.Storerkey = LOTxLOCxID.Storerkey AND SKU.SKU = LOTxLOCxID.SKU '
--		+ 'JOIN  LOTATTRIBUTE WITH (NOLOCK) ON LOTATTRIBUTE.LOT = LOTxLOCxID.LOT '
--		+ 'JOIN  LOC WITH (NOLOCK) ON LOC.LOC = LOTxLOCxID.LOC '
--
--		IF NOT EXISTS (SELECT 1 FROM STOCKTAKEPARM2 WITH (NOLOCK) 
--					  		WHERE Stocktakekey = @c_StockTakeKey
--					  		AND   UPPER(Tablename) = 'SKU')
--		BEGIN
--			SELECT @c_sqlOther = @c_sqlOther + ' ' 
--									+ ISNULL(dbo.fnc_RTrim(@c_SKUSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_SKUSQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_AgencySQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_AgencySQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_ABCSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_ABCSQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_SkuGroupSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_SkuGroupSQL2), '') 
--		END
--		ELSE
--		BEGIN
--			SELECT @c_sql = @c_sql + ' ' 
--									+ 'JOIN STOCKTAKEPARM2 PARM2_SKU WITH (NOLOCK) '
--									+ '  ON PARM2_SKU.Storerkey = LOTxLOCxID.Storerkey '
--									+ ' AND dbo.fnc_RTrim(dbo.fnc_LTrim(PARM2_SKU.Value)) = LOTxLOCxID.SKU '
--									+ ' AND UPPER(PARM2_SKU.Tablename) = ''SKU'' '								 
--									+ ' AND PARM2_SKU.Stocktakekey = ''' + ISNULL(dbo.fnc_RTrim(@c_StockTakeKey), '') + ''''
--		END
--
--		IF NOT EXISTS (SELECT 1 FROM STOCKTAKEPARM2 WITH (NOLOCK) 
--					  		WHERE Stocktakekey = @c_StockTakeKey
--					  		AND   UPPER(Tablename) = 'LOC')
--		BEGIN
--			SELECT @c_sqlOther = @c_sqlOther + ' '  		 
--									+ ISNULL(dbo.fnc_RTrim(@c_ZoneSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_ZoneSQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_AisleSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_AisleSQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_LevelSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_LevelSQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_HostWHCodeSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_HostWHCodeSQL2), '') 
--		END
--		ELSE
--		BEGIN
--			SELECT @c_sql = @c_sql + ' ' 
--									+ 'JOIN STOCKTAKEPARM2 PARM2_LOC WITH (NOLOCK) '
--									+ '  ON dbo.fnc_RTrim(dbo.fnc_LTrim(PARM2_LOC.Value)) = LOTxLOCxID.LOC '
--									+ ' AND UPPER(PARM2_LOC.Tablename) = ''LOC'' '
--									+ ' AND PARM2_LOC.Stocktakekey = ''' + ISNULL(dbo.fnc_RTrim(@c_StockTakeKey), '') + ''''
--		END
--	   
--		SELECT @c_sqlWhere = ' '
--               			   + CASE WHEN @c_ExcludeQtyPicked = 'Y' THEN 'WHERE LOTxLOCxID.Qty-LOTxLOCxID.QtyPicked > 0 ' ELSE 'WHERE LOTxLOCxID.Qty > 0 ' END
--									+ 'AND   LOC.Facility = "' + ISNULL(dbo.fnc_RTrim(@c_Facility), '') + '" '
--									+ ISNULL(dbo.fnc_RTrim(@c_StorerSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_StorerSQL2), '') + ' '
--
--		SELECT @c_sqlGroup = ' ' 
--									+ 'GROUP BY LOTxLOCxID.loc,LOTxLOCxID.id,LOTxLOCxID.StorerKey,' -- By SHONG 26th Jul 2002, Remove the LOT from this line
--									+ 'LOTxLOCxID.sku,LOTATTRIBUTE.Lottable01,LOTATTRIBUTE.Lottable02,LOTATTRIBUTE.Lottable03,'
--									+ 'LOTATTRIBUTE.Lottable04,LOC.PutawayZone,LOC.LocLevel,LOC.locAisle, LOC.Facility, LOC.CCLogicalLoc'	
--
--		SELECT @c_sql = @c_sql + ' ' + @c_sqlWhere + ' ' + @c_sqlOther + ' ' + @c_sqlGroup
--	END
--	-- End : SOS66279
--END
--ELSE IF dbo.fnc_RTrim(@c_GroupLottable05) = 'MAX'
--BEGIN
--	-- Start : SOS66279
--	IF NOT EXISTS (SELECT 1 FROM STOCKTAKEPARM2 WITH (NOLOCK) WHERE Stocktakekey = @c_StockTakeKey)
--	BEGIN
--	-- End : SOS66279
--		SELECT @c_SQL =  'INSERT INTO #RESULT '
--		+ 'SELECT SPACE(10),LOTxLOCxID.loc,LOTxLOCxID.id,LOTxLOCxID.StorerKey,'
--		+ 'LOTxLOCxID.sku,LOTATTRIBUTE.Lottable01,LOTATTRIBUTE.Lottable02,'
--		+ 'LOTATTRIBUTE.Lottable03,LOTATTRIBUTE.Lottable04,MAX(LOTATTRIBUTE.Lottable05),'
--	   + CASE WHEN @c_ExcludeQtyPicked = 'Y' THEN 'Qty = SUM(LOTxLOCxID.qty-LOTxLOCxID.qtypicked),' ELSE 'Qty = SUM(LOTxLOCxID.qty),' END
--		+ 'LOC.PutawayZone,LOC.LocLevel,Aisle = LOC.locAisle,LOC.Facility, LOC.CCLogicalLoc '
--		+ 'FROM	LOTxLOCxID (NOLOCK), SKU (NOLOCK), LOTATTRIBUTE (NOLOCK), LOC (NOLOCK) '
--		+ 'WHERE LOTxLOCxID.StorerKey = SKU.StorerKey '
--		+ 'AND   LOTxLOCxID.sku = SKU.sku '
--		+ 'AND   LOTxLOCxID.lot = LOTATTRIBUTE.lot '
--		+ 'AND   LOTxLOCxID.loc = LOC.loc '
--	   + CASE WHEN @c_ExcludeQtyPicked = 'Y' THEN 'AND   LOTxLOCxID.Qty-LOTxLOCxID.QtyPicked > 0 ' ELSE 'AND   LOTxLOCxID.Qty > 0 ' END
--		+ 'AND   LOC.Facility = "' + ISNULL(dbo.fnc_RTrim(@c_Facility), '') + '" '
--		+ ISNULL(dbo.fnc_RTrim(@c_StorerSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_StorerSQL2), '') + ' '
--		+ ISNULL(dbo.fnc_RTrim(@c_ZoneSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_ZoneSQL2), '') + ' '
--		+ ISNULL(dbo.fnc_RTrim(@c_AisleSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_AisleSQL2), '') + ' '
--		+ ISNULL(dbo.fnc_RTrim(@c_LevelSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_LevelSQL2), '') + ' '
--		+ ISNULL(dbo.fnc_RTrim(@c_HostWHCodeSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_HostWHCodeSQL2), '') + ' '
--		+ ISNULL(dbo.fnc_RTrim(@c_SKUSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_SKUSQL2), '') + ' '
--		+ ISNULL(dbo.fnc_RTrim(@c_AgencySQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_AgencySQL2), '') + ' '
--		+ ISNULL(dbo.fnc_RTrim(@c_ABCSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_ABCSQL2), '') + ' '
--		+ ISNULL(dbo.fnc_RTrim(@c_SkuGroupSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_SkuGroupSQL2), '') + ' '
--		+ 'GROUP BY LOTxLOCxID.loc,LOTxLOCxID.id,LOTxLOCxID.StorerKey,' -- By SHONG 26th Jul 2002, Remove the LOT from this line
--		+ 'LOTxLOCxID.sku,LOTATTRIBUTE.Lottable01,LOTATTRIBUTE.Lottable02,LOTATTRIBUTE.Lottable03,'
--		+ 'LOTATTRIBUTE.Lottable04,LOC.PutawayZone,LOC.LocLevel,LOC.locAisle, LOC.Facility, LOC.CCLogicalLoc'
--	-- Start : SOS66279
--	END 
--	ELSE
--	BEGIN
--		SELECT @c_sql = N'INSERT INTO #RESULT '
--		+ 'SELECT SPACE(10),LOTxLOCxID.loc,LOTxLOCxID.id,LOTxLOCxID.StorerKey,'
--		+ 'LOTxLOCxID.sku,LOTATTRIBUTE.Lottable01,LOTATTRIBUTE.Lottable02,'
--		+ 'LOTATTRIBUTE.Lottable03,LOTATTRIBUTE.Lottable04,MAX(LOTATTRIBUTE.Lottable05),'
--	   + CASE WHEN @c_ExcludeQtyPicked = 'Y' THEN 'Qty = SUM(LOTxLOCxID.qty-LOTxLOCxID.qtypicked),' ELSE 'Qty = SUM(LOTxLOCxID.qty),' END
--		+ 'LOC.PutawayZone,LOC.LocLevel,Aisle = LOC.locAisle,LOC.Facility, LOC.CCLogicalLoc '	
--		+ 'FROM	LOTxLOCxID WITH (NOLOCK) '
--		+ 'JOIN  SKU WITH (NOLOCK) ON SKU.Storerkey = LOTxLOCxID.Storerkey AND SKU.SKU = LOTxLOCxID.SKU '
--		+ 'JOIN  LOTATTRIBUTE WITH (NOLOCK) ON LOTATTRIBUTE.LOT = LOTxLOCxID.LOT '
--		+ 'JOIN  LOC WITH (NOLOCK) ON LOC.LOC = LOTxLOCxID.LOC '
--
--		IF NOT EXISTS (SELECT 1 FROM STOCKTAKEPARM2 WITH (NOLOCK) 
--					  		WHERE Stocktakekey = @c_StockTakeKey
--					  		AND   UPPER(Tablename) = 'SKU')
--		BEGIN
--			SELECT @c_sqlOther = @c_sqlOther + ' ' 
--									+ ISNULL(dbo.fnc_RTrim(@c_SKUSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_SKUSQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_AgencySQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_AgencySQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_ABCSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_ABCSQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_SkuGroupSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_SkuGroupSQL2), '') 
--		END
--		ELSE
--		BEGIN
--			SELECT @c_sql = @c_sql + ' ' 
--									+ 'JOIN STOCKTAKEPARM2 PARM2_SKU WITH (NOLOCK) '
--									+ ' ON  PARM2_SKU.Storerkey = LOTxLOCxID.Storerkey '
--									+ ' AND dbo.fnc_RTrim(dbo.fnc_LTrim(PARM2_SKU.Value)) = LOTxLOCxID.SKU '
--									+ ' AND UPPER(PARM2_SKU.Tablename) = ''SKU'' '
--									+ ' AND PARM2_SKU.Stocktakekey = ''' + ISNULL(dbo.fnc_RTrim(@c_StockTakeKey), '') + ''''
--		END
--
--		IF NOT EXISTS (SELECT 1 FROM STOCKTAKEPARM2 WITH (NOLOCK) 
--					  		WHERE Stocktakekey = @c_StockTakeKey
--					  		AND   UPPER(Tablename) = 'LOC')
--		BEGIN
--			SELECT @c_sqlOther = @c_sqlOther + ' '  		 
--									+ ISNULL(dbo.fnc_RTrim(@c_ZoneSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_ZoneSQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_AisleSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_AisleSQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_LevelSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_LevelSQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_HostWHCodeSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_HostWHCodeSQL2), '') 
--		END
--		ELSE
--		BEGIN
--			SELECT @c_sql = @c_sql + ' ' 
--									+ 'JOIN STOCKTAKEPARM2 PARM2_LOC WITH (NOLOCK) '
--									+ ' ON  dbo.fnc_RTrim(dbo.fnc_LTrim(PARM2_LOC.Value)) = LOTxLOCxID.LOC '
--									+ ' AND UPPER(PARM2_LOC.Tablename) = ''LOC'' '
--									+ ' AND PARM2_LOC.Stocktakekey = ''' + ISNULL(dbo.fnc_RTrim(@c_StockTakeKey), '') + ''''
--		END
--
--		SELECT @c_sqlWhere = ' ' 
--                      	   + CASE WHEN @c_ExcludeQtyPicked = 'Y' THEN 'WHERE LOTxLOCxID.Qty-LOTxLOCxID.QtyPicked > 0 ' ELSE 'WHERE LOTxLOCxID.Qty > 0 ' END
--									+ 'AND   LOC.Facility = "' + ISNULL(dbo.fnc_RTrim(@c_Facility), '') + '" '
--									+ ISNULL(dbo.fnc_RTrim(@c_StorerSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_StorerSQL2), '') + ' '
--
--		SELECT @c_sqlGroup = ' ' 
--									+ 'GROUP BY LOTxLOCxID.loc,LOTxLOCxID.id,LOTxLOCxID.StorerKey,' -- By SHONG 26th Jul 2002, Remove the LOT from this line
--									+ 'LOTxLOCxID.sku,LOTATTRIBUTE.Lottable01,LOTATTRIBUTE.Lottable02,LOTATTRIBUTE.Lottable03,'
--									+ 'LOTATTRIBUTE.Lottable04,LOC.PutawayZone,LOC.LocLevel,LOC.locAisle, LOC.Facility, LOC.CCLogicalLoc'
--
--		SELECT @c_sql = @c_sql + ' ' + @c_sqlWhere + ' ' + @c_sqlOther + ' ' + @c_sqlGroup
--	END
--	-- End : SOS66279
--END
--ELSE
BEGIN
	-- Start : SOS66279
	IF NOT EXISTS (SELECT 1 FROM STOCKTAKEPARM2 WITH (NOLOCK) WHERE Stocktakekey = @c_StockTakeKey)
	BEGIN
	-- End : SOS66279
		SELECT @c_SQL =  'INSERT INTO #RESULT '
		+ 'SELECT LOTxLOCxID.lot,LOTxLOCxID.loc,LOTxLOCxID.id,LOTxLOCxID.StorerKey,'
		+ 'LOTxLOCxID.sku,LOTATTRIBUTE.Lottable01,LOTATTRIBUTE.Lottable02,'
		+ 'LOTATTRIBUTE.Lottable03,LOTATTRIBUTE.Lottable04,LOTATTRIBUTE.Lottable05,'
	   + CASE WHEN @c_ExcludeQtyPicked = 'Y' THEN 'Qty = SUM(LOTxLOCxID.qty-LOTxLOCxID.qtypicked),' ELSE 'Qty = SUM(LOTxLOCxID.qty),' END
		+ 'LOC.PutawayZone,LOC.LocLevel,Aisle = LOC.locAisle,LOC.Facility, LOC.CCLogicalLoc '
		+ 'FROM	LOTxLOCxID (NOLOCK), SKU (NOLOCK), LOTATTRIBUTE (NOLOCK), LOC (NOLOCK) '
		+ 'WHERE LOTxLOCxID.StorerKey = SKU.StorerKey '
		+ 'AND   LOTxLOCxID.sku = SKU.sku '
		+ 'AND   LOTxLOCxID.lot = LOTATTRIBUTE.lot '
		+ 'AND   LOTxLOCxID.loc = LOC.loc '
		+ 'AND   LOC.LOC = "' + @c_Loc + '" '
	   
	   IF ISNULL(RTRIM(@c_SKU),'') <> ''
		BEGIN
		   SET @c_SQL = @c_SQL + ' AND   LOTxLOCxID.SKU = "' + ISNULL(RTRIM(@c_SKU),'') + '" '
		END
		
	   SELECT @c_SQL =  @c_SQL +  CASE WHEN @c_ExcludeQtyPicked = 'Y' THEN 'AND   LOTxLOCxID.Qty-LOTxLOCxID.QtyPicked > 0 ' ELSE 'AND   LOTxLOCxID.Qty > 0 ' END
		+ ' AND   LOC.Facility = "' + ISNULL(dbo.fnc_RTrim(@c_Facility), '') + '" '
		+ ISNULL(dbo.fnc_RTrim(@c_StorerSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_StorerSQL2), '') + ' '
		+ ISNULL(dbo.fnc_RTrim(@c_ZoneSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_ZoneSQL2), '') + ' '
		+ ISNULL(dbo.fnc_RTrim(@c_AisleSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_AisleSQL2), '') + ' '
		+ ISNULL(dbo.fnc_RTrim(@c_LevelSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_LevelSQL2), '') + ' '
		+ ISNULL(dbo.fnc_RTrim(@c_HostWHCodeSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_HostWHCodeSQL2), '') + ' '
		+ ISNULL(dbo.fnc_RTrim(@c_SKUSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_SKUSQL2), '') + ' '
		+ ISNULL(dbo.fnc_RTrim(@c_AgencySQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_AgencySQL2), '') + ' '
		+ ISNULL(dbo.fnc_RTrim(@c_ABCSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_ABCSQL2), '') + ' '
		+ ISNULL(dbo.fnc_RTrim(@c_SkuGroupSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_SkuGroupSQL2), '') + ' '
		+ 'GROUP BY LOTxLOCxID.lot, LOTxLOCxID.loc,LOTxLOCxID.id,LOTxLOCxID.StorerKey,'
		+ 'LOTxLOCxID.sku,LOTATTRIBUTE.Lottable01,LOTATTRIBUTE.Lottable02,LOTATTRIBUTE.Lottable03,'
		+ 'LOTATTRIBUTE.Lottable04,LOTATTRIBUTE.Lottable05,LOC.PutawayZone,LOC.LocLevel,LOC.locAisle, LOC.Facility, LOC.CCLogicalLoc'
	-- Start : SOS66279
	END 
--	ELSE
--   BEGIN
--		SELECT @c_sql = N'INSERT INTO #RESULT '
--		+ 'SELECT LOTxLOCxID.lot,LOTxLOCxID.loc,LOTxLOCxID.id,LOTxLOCxID.StorerKey,'
--		+ 'LOTxLOCxID.sku,LOTATTRIBUTE.Lottable01,LOTATTRIBUTE.Lottable02,'
--		+ 'LOTATTRIBUTE.Lottable03,LOTATTRIBUTE.Lottable04,LOTATTRIBUTE.Lottable05,'
--	   + CASE WHEN @c_ExcludeQtyPicked = 'Y' THEN 'Qty = SUM(LOTxLOCxID.qty-LOTxLOCxID.qtypicked),' ELSE 'Qty = SUM(LOTxLOCxID.qty),' END
--		+ 'LOC.PutawayZone,LOC.LocLevel,Aisle = LOC.locAisle,LOC.Facility, LOC.CCLogicalLoc '
--		+ 'FROM	LOTxLOCxID WITH (NOLOCK) '
--		+ 'JOIN  SKU WITH (NOLOCK) ON SKU.Storerkey = LOTxLOCxID.Storerkey AND SKU.SKU = LOTxLOCxID.SKU '
--		+ 'JOIN  LOTATTRIBUTE WITH (NOLOCK) ON LOTATTRIBUTE.LOT = LOTxLOCxID.LOT '	
--		+ 'JOIN  LOC WITH (NOLOCK) ON LOC.LOC = LOTxLOCxID.LOC '
--
--		IF NOT EXISTS (SELECT 1 FROM STOCKTAKEPARM2 WITH (NOLOCK) 
--					  		WHERE Stocktakekey = @c_StockTakeKey
--					  		AND   UPPER(Tablename) = 'SKU')
--		BEGIN
--			SELECT @c_sqlOther = @c_sqlOther + ' ' 
--									+ ISNULL(dbo.fnc_RTrim(@c_SKUSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_SKUSQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_AgencySQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_AgencySQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_ABCSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_ABCSQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_SkuGroupSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_SkuGroupSQL2), '') + ' '
--		END
--		ELSE
--		BEGIN
--			SELECT @c_sql = @c_sql + ' '
--									+ 'JOIN STOCKTAKEPARM2 PARM2_SKU WITH (NOLOCK) '
--									+ ' ON  PARM2_SKU.Storerkey = LOTxLOCxID.Storerkey '
--									+ ' AND dbo.fnc_RTrim(dbo.fnc_LTrim(PARM2_SKU.Value)) = LOTxLOCxID.SKU '
--									+ ' AND UPPER(PARM2_SKU.Tablename) = ''SKU'' '
--									+ ' AND PARM2_SKU.Stocktakekey = ''' + ISNULL(dbo.fnc_RTrim(@c_StockTakeKey), '') + ''''
--		END
--
--		IF NOT EXISTS (SELECT 1 FROM STOCKTAKEPARM2 WITH (NOLOCK) 
--					  		WHERE Stocktakekey = @c_StockTakeKey
--					  		AND   UPPER(Tablename) = 'LOC')
--		BEGIN
--			SELECT @c_sqlOther = @c_sqlOther + ' '  		 
--									+ ISNULL(dbo.fnc_RTrim(@c_ZoneSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_ZoneSQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_AisleSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_AisleSQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_LevelSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_LevelSQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_HostWHCodeSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_HostWHCodeSQL2), '') 
--		END
--		ELSE
--		BEGIN
--			SELECT @c_sql = @c_sql + ' '
--									+ 'JOIN STOCKTAKEPARM2 PARM2_LOC WITH (NOLOCK) '
--									+ ' ON  dbo.fnc_RTrim(dbo.fnc_LTrim(PARM2_LOC.Value)) = LOTxLOCxID.LOC '
--									+ ' AND UPPER(PARM2_LOC.Tablename) = ''LOC'' '
--									+ ' AND PARM2_LOC.Stocktakekey = ''' + ISNULL(dbo.fnc_RTrim(@c_StockTakeKey), '') + ''''
--		END
--
--		SELECT @c_sqlWhere = ' ' 
--                      	   + CASE WHEN @c_ExcludeQtyPicked = 'Y' THEN 'WHERE LOTxLOCxID.Qty-LOTxLOCxID.QtyPicked > 0 ' ELSE 'WHERE LOTxLOCxID.Qty > 0 ' END
--									+ 'AND   LOC.Facility = "' + ISNULL(dbo.fnc_RTrim(@c_Facility), '') + '" '
--									+ ISNULL(dbo.fnc_RTrim(@c_StorerSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_StorerSQL2), '') + ' '
--
--
--		SELECT @c_sqlGroup = ' ' 
--									+ 'GROUP BY LOTxLOCxID.lot, LOTxLOCxID.loc,LOTxLOCxID.id,LOTxLOCxID.StorerKey,'
--									+ 'LOTxLOCxID.sku,LOTATTRIBUTE.Lottable01,LOTATTRIBUTE.Lottable02,LOTATTRIBUTE.Lottable03,'
--									+ 'LOTATTRIBUTE.Lottable04,LOTATTRIBUTE.Lottable05,LOC.PutawayZone,LOC.LocLevel,LOC.locAisle, LOC.Facility, LOC.CCLogicalLoc'
--
--		SELECT @c_sql = @c_sql + ' ' + @c_sqlWhere + ' ' + @c_sqlOther + ' ' + @c_sqlGroup
--	END
	-- End : SOS66279
END
--PRINT @c_sql
EXEC (@c_sql)

--PRINT @C_SQL

--IF @c_EmptyLocation = 'Y'
--BEGIN
--	-- Start : SOS66279
--	IF NOT EXISTS (SELECT 1 FROM STOCKTAKEPARM2 WITH (NOLOCK) WHERE Stocktakekey = @c_StockTakeKey)
--	BEGIN
--	-- End : SOS66279
--		SELECT @c_SQL = N'INSERT INTO #RESULT '
--		-- Change by June 12.Mar.02  FBR063
--		--     + 'SELECT lot = space(10),loc,id = space(20),StorerKey = "' + @c_StorerKey + '"' + ',sku = space(20),'
--		+ 'SELECT lot = space(10),loc,id = space(20),StorerKey = space(10),sku = space(20),'
--		+ 'Lottable01 = space(18),Lottable02 = space(18),Lottable03 = space(18),Lottable04 = NULL,'
--		+ 'Lottable05 = NULL,Qty = 0,PutawayZone,LocLevel,Aisle = locAisle,Facility,CCLogicalLoc '
--		+ 'FROM LOC (NOLOCK) '
--		+ 'WHERE   LOC.Facility = "' + ISNULL(dbo.fnc_RTrim(@c_Facility), '') + '" '
--		+ ISNULL(dbo.fnc_RTrim(@c_ZoneSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_ZoneSQL2), '') + ' '
--		+ ISNULL(dbo.fnc_RTrim(@c_AisleSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_AisleSQL2), '') + ' '
--		+ ISNULL(dbo.fnc_RTrim(@c_LevelSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_LevelSQL2), '') + ' '
--		+ ISNULL(dbo.fnc_RTrim(@c_HostWHCodeSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_HostWHCodeSQL2), '') + ' '
--		-- Patches from IDSMY 31 Dec 2002
--		-- Remark by June 30.Oct.02 -- To prevent Syntax error, doesn't select from LOTXLOCXID table
--		--+ @c_SKUSQL + ' ' + @c_SKUSQL2 + ' ' 
--		-- Remark by SHONG 27th Mar 2003
--		-- Agency is not in LOC table
--		--+ @c_AgencySQL + ' ' + @c_AgencySQL2 + ' '
--		--+ @c_ABCSQL + ' ' + @c_ABCSQL2 + ' '
--		+ 'AND LOC NOT IN (SELECT DISTINCT LOC FROM #RESULT) ' 
--
--		EXEC ( @c_SQL )
--	-- Start : SOS66279
--	END 
--	ELSE
--	BEGIN
--		SELECT @c_SQL = N'INSERT INTO #RESULT '
--		+ 'SELECT lot = space(10),loc,id = space(20),StorerKey = space(10),sku = space(20),'
--		+ 'Lottable01 = space(18),Lottable02 = space(18),Lottable03 = space(18),Lottable04 = NULL,'
--		+ 'Lottable05 = NULL,Qty = 0,PutawayZone,LocLevel,Aisle = locAisle,Facility,CCLogicalLoc '
--		+ 'FROM LOC (NOLOCK) '
--
--		IF NOT EXISTS (SELECT 1 FROM STOCKTAKEPARM2 WITH (NOLOCK) 
--					  		WHERE Stocktakekey = @c_StockTakeKey
--					  		AND   UPPER(Tablename) = 'LOC')
--		BEGIN
--			SELECT @c_SQLOther = @c_SQLOther + ' '  		 
--									+ ISNULL(dbo.fnc_RTrim(@c_ZoneSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_ZoneSQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_AisleSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_AisleSQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_LevelSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_LevelSQL2), '') + ' '
--									+ ISNULL(dbo.fnc_RTrim(@c_HostWHCodeSQL), '') + ' ' + ISNULL(dbo.fnc_RTrim(@c_HostWHCodeSQL2), '') 
--		END
--		ELSE
--		BEGIN
--			SELECT @c_SQL = @c_SQL + ' '
--									+ 'JOIN STOCKTAKEPARM2 PARM2_LOC WITH (NOLOCK) '
--									+ ' ON  dbo.fnc_RTrim(dbo.fnc_LTrim(PARM2_LOC.Value)) = LOC.LOC '
--									+ ' AND UPPER(PARM2_LOC.Tablename) = ''LOC'' '		
--									+ ' AND PARM2_LOC.Stocktakekey = ''' + ISNULL(dbo.fnc_RTrim(@c_StockTakeKey), '') + ''''
--		END
--		
--		SELECT @c_sqlWhere = ' '
--									+ 'WHERE LOC.Facility = "' + ISNULL(dbo.fnc_RTrim(@c_Facility), '') + '" '
--									+ 'AND LOC NOT IN (SELECT DISTINCT LOC FROM #RESULT) ' 
--
--		SELECT @c_SQL = @c_SQL + ' ' + @c_sqlWhere + ' ' + @c_SQLOther
--
--		EXEC ( @c_SQL )
--	END
--	-- End : SOS66279
--END

	DECLARE @c_lot	 NVARCHAR(10),
		--@c_loc		   NVARCHAR(10),
		@c_id		      NVARCHAR(18),
		--@c_sku		   NVARCHAR(20),
		@c_Lottable01 NVARCHAR(18),
		@c_Lottable02 NVARCHAR(18),
		@c_Lottable03 NVARCHAR(18),
		@d_Lottable04	datetime,
		@d_Lottable05	datetime,
		@n_qty		   int,
		@c_Aisle	      NVARCHAR(10),
		@n_LocLevel	   int,
		@c_prev_Facility   NVARCHAR(5),
		@c_prev_Aisle	    NVARCHAR(10),
		@n_prev_LocLevel   int,
		@c_ccdetailkey	    NVARCHAR(10),
		@c_ccsheetno	    NVARCHAR(10),
		@n_err		       int,
		@c_errmsg	       NVARCHAR(250),
		@n_LineCount       int,
		@c_PreLogLocation  NVARCHAR(18),
		@c_CCLogicalLoc    NVARCHAR(18),
      @n_SystemQty       int,
      @c_PrevZone        NVARCHAR(10),
      @c_PutawayZone     NVARCHAR(10)
-- Change by SHONG
-- If default the PreXXX to BLANK, no count sheet # will generate, because prexxx = xxx cause xxx not
-- setup, equal to BLANK
SELECT @c_prev_Facility = " ", @c_prev_Aisle = "XX", @n_prev_LocLevel = 999, @c_PreLogLocation = '000'

-- Start - SOS23776
/*
DECLARE cur_1 CURSOR FAST_FORWARD READ_ONLY
FOR  SELECT lot, loc, id, StorerKey, sku, Lottable01, Lottable02, Lottable03, Lottable04, Lottable05,
            CASE WHEN @c_WithQuantity = 'Y' THEN qty ELSE 0 END,
            Facility, Aisle, LocLevel, CCLogicalLoc, qty, PutawayZone 
      FROM #RESULT
      ORDER BY Facility, PutawayZone, Aisle, LocLevel, CCLogicalLoc, Loc, SKU 
OPEN cur_1
*/
DECLARE @c_bypassPAZone NVARCHAR(1)
SELECT @c_storerkey = SUBSTRING(@c_StorerSQL, CHARINDEX('"', @c_StorerSQL, 1),
							 LEN(@c_StorerSQL) - CHARINDEX('"', @c_StorerSQL, 1))
SELECT @c_storerkey = dbo.fnc_RTrim(dbo.fnc_LTrim(REPLACE(@c_storerkey, '"', '')))
SELECT @b_success = 0

Execute nspGetRight @c_Facility,	-- facility
   @c_storerkey, 	-- Storerkey
   null,				-- Sku
   'CCSHEETBYPASSPA',	-- Configkey
   @b_success		output,
   @c_bypassPAZone output,
   @n_err			output,
   @c_errmsg		output

IF @b_success <> 1 OR @c_bypassPAZone = '0'
	SELECT @c_bypassPAZone = 'N'	
ELSE
	SELECT @c_bypassPAZone = 'Y'	

IF @c_bypassPAZone = 'N'
BEGIN
	EXEC ('DECLARE cur_1 CURSOR FAST_FORWARD READ_ONLY
			FOR  SELECT lot, loc, id, StorerKey, sku, Lottable01, Lottable02, Lottable03, Lottable04, Lottable05,
	            CASE WHEN "' + @c_WithQuantity + '" = "Y" THEN qty ELSE 0 END,
	            Facility, Aisle, LocLevel, CCLogicalLoc, qty, PutawayZone 
	      FROM #RESULT
	      ORDER BY Facility, PutawayZone, Aisle, LocLevel, CCLogicalLoc, Loc, SKU')
END
ELSE
BEGIN
	EXEC ('DECLARE cur_1 CURSOR FAST_FORWARD READ_ONLY
			FOR  SELECT lot, loc, id, StorerKey, sku, Lottable01, Lottable02, Lottable03, Lottable04, Lottable05,
	            CASE WHEN "' + @c_WithQuantity + '" = "Y" THEN qty ELSE 0 END,
	            Facility, Aisle, LocLevel, CCLogicalLoc, qty, "" as PutawayZone 
	      FROM #RESULT
	      ORDER BY Facility, Aisle, LocLevel, CCLogicalLoc, Loc, SKU')
END
SELECT @n_err = @@ERROR  
IF @n_err <> 0
BEGIN    
  CLOSE cur_1    
  DEALLOCATE cur_1    
END    
ELSE
BEGIN  
  OPEN cur_1 
-- End - SOS23776

	SELECT @n_LineCount = 0
  SELECT @c_CCSheetNoKeyName = 'CSHEET'+LTRIM(RTRIM(@c_StockTakeKey)) --NJOW03
	
	FETCH NEXT FROM cur_1 INTO @c_lot, @c_loc, @c_id, @c_StorerKey, @c_sku, @c_Lottable01, @c_Lottable02, @c_Lottable03,
	@d_Lottable04, @d_Lottable05, @n_qty, @c_Facility, @c_Aisle, @n_LocLevel, @c_CCLogicalLoc, @n_SystemQty, @c_PutawayZone 
	
	WHILE @@FETCH_STATUS <> -1
	BEGIN
	 -- select @c_Aisle '@c_Aisle', @c_prev_Aisle '@c_prev_Aisle', @n_LocLevel '@n_LocLevel', @n_prev_LocLevel '@n_prev_LocLevel'
--	   IF @n_LineCount > @n_LinesPerPage 
--	   OR dbo.fnc_RTrim(@c_PutawayZone) <> dbo.fnc_RTrim(@c_PrevZone) 
--	   OR dbo.fnc_RTrim(@c_Aisle) <> dbo.fnc_RTrim(@c_prev_Aisle)
--	   OR dbo.fnc_RTrim(@n_LocLevel) <> dbo.fnc_RTrim(@n_prev_LocLevel)
--	   BEGIN
--	      EXECUTE nspg_getkey
--	      --'CCSheetNo'
--        @c_CCSheetNoKeyName --NJOW03
--	      , 10
--	      , @c_CCSheetNo OUTPUT
--	      , @b_success OUTPUT
--	      , @n_err OUTPUT
--	      , @c_errmsg OUTPUT
--	      SELECT @n_LineCount = 1
--	   END
      
      SET @c_CCSheetNo = @c_TaskDetailKey
	
	   EXECUTE nspg_getkey
	   'CCDetailKey'
	   , 10
	   , @c_CCDetailKey OUTPUT
	   , @b_success OUTPUT
	   , @n_err OUTPUT
	   , @c_errmsg OUTPUT
	   IF dbo.fnc_RTrim(@c_lot) <> '' AND dbo.fnc_RTrim(@c_lot) IS NOT NULL 
	   BEGIN	
	      INSERT CCDETAIL (cckey, ccdetailkey, StorerKey, sku, lot, loc, id, qty, ccsheetno, Lottable01,
	      Lottable02, Lottable03, Lottable04, Lottable05, SystemQty)
	      VALUES (@c_StockTakeKey, @c_CCDetailKey, @c_StorerKey, @c_sku, @c_lot, @c_loc, @c_id, 0, @c_CCSheetNo,
	      @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05, @n_SystemQty)
	   END
	   ELSE
	   BEGIN
         
	      INSERT CCDETAIL (cckey, ccdetailkey, StorerKey, sku, lot, loc, id, qty, ccsheetno, Lottable01,
	      Lottable02, Lottable03, Lottable04, Lottable05, SystemQty, Status)
	      VALUES (@c_StockTakeKey, @c_CCDetailKey, @c_StorerKey, @c_sku, @c_lot, @c_loc, @c_id, 0, @c_CCSheetNo,
	      @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05, @n_SystemQty, 
         CASE WHEN @n_SystemQty = 0 THEN '4' ELSE '0' END)
	   END
	
	   SELECT @n_LineCount = @n_LineCount + 1
	   SELECT @c_prev_Aisle = @c_Aisle,
	         @n_prev_LocLevel = @n_LocLevel,
	         @c_PreLogLocation = @c_CCLogicalLoc,
	         @c_PrevZone = @c_PutawayZone 
	
	   FETCH NEXT FROM cur_1 INTO @c_lot, @c_loc, @c_id, @c_StorerKey, @c_sku, @c_Lottable01, @c_Lottable02,
				@c_Lottable03, @d_Lottable04, @d_Lottable05, @n_qty, @c_Facility, @c_Aisle, @n_LocLevel, @c_CCLogicalLoc,
	         @n_SystemQty, @c_PutawayZone 
	END -- WHILE
	CLOSE cur_1
	DEALLOCATE cur_1
END -- SOS23776

DROP TABLE #RESULT
-- return results

-- SELECT CCDETAIL.ccsheetno,
-- CCDETAIL.lot,
-- CCDETAIL.loc,
-- CCDETAIL.id,
-- CCDETAIL.StorerKey,
-- CCDETAIL.sku,
-- SKU.descr,
-- CCDETAIL.Lottable01,
-- CCDETAIL.Lottable02,
-- CCDETAIL.Lottable03,
-- CCDETAIL.Lottable04,
-- CCDETAIL.Lottable05,
-- CCDETAIL.qty,
-- PACK.packuom3,
-- LOC.PutawayZone,
-- LOC.LocLevel,
-- LOC.locAisle,
-- LOC.Facility
-- FROM CCDETAIL (NOLOCK),
-- SKU (NOLOCK),
-- PACK (NOLOCK),
-- LOC (NOLOCK)
-- WHERE CCDETAIL.CCKEY = @c_StockTakeKey
-- AND   CCDETAIL.LOC = LOC.LOC
-- AND   CCDETAIL.StorerKey = SKU.StorerKey
-- AND   CCDETAIL.SKU = SKU.SKU
-- AND   SKU.PackKey = PACK.PackKey
-- UNION
-- SELECT CCDETAIL.ccsheetno,
-- CCDETAIL.lot,
-- CCDETAIL.loc,
-- CCDETAIL.id,
-- CCDETAIL.StorerKey,
-- CCDETAIL.sku,
-- '',
-- CCDETAIL.Lottable01,
-- CCDETAIL.Lottable02,
-- CCDETAIL.Lottable03,
-- CCDETAIL.Lottable04,
-- CCDETAIL.Lottable05,
-- CCDETAIL.qty,
-- '',
-- LOC.PutawayZone,
-- LOC.LocLevel,
-- LOC.locAisle,
-- LOC.Facility
-- FROM CCDETAIL (NOLOCK),  LOC (NOLOCK)
-- WHERE CCDETAIL.CCKEY = @c_StockTakeKey
-- AND   CCDETAIL.LOC = LOC.LOC
-- ORDER BY LOC.Facility, LOC.locAisle, LOC.LocLevel

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

GRANT EXECUTE ON ispRDTGenCountSheet TO NSQL
GO
