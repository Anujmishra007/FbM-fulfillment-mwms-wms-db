SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_GenReplenishmentJCB                               */
/*                                                                         */
/* Copyright: Maersk                                                       */
/*                                                                         */
/* Updates:                                                                */
/* Date           Author      Change                                       */
/* 30/09/2025     PPA374      JCB Replenishment                            */
/***************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_GenReplenishmentJCB]
   @c_Zone01     NVARCHAR(10),
   @c_Zone02     NVARCHAR(10),
   @c_Zone03     NVARCHAR(10),
   @c_Zone04     NVARCHAR(10),
   @c_Zone05     NVARCHAR(10),
   @c_Zone06     NVARCHAR(10),
   @c_Zone07     NVARCHAR(10),
   @c_Zone08     NVARCHAR(10),
   @c_Zone09     NVARCHAR(10),
   @c_Zone10     NVARCHAR(10),
   @c_Zone11     NVARCHAR(10),
   @c_Zone12     NVARCHAR(10),
   @c_ReplenFlag NVARCHAR(10),
   @c_storerkey  NVARCHAR(15)         
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cFacility AS NVARCHAR(50)

   SELECT TOP 1 @cFacility = Facility FROM dbo.FACILITY WITH(NOLOCK) WHERE UserDefine01 = @c_storerkey

   -- temp table for targets
   CREATE TABLE #REPLENREQ
   (
      SKU       NVARCHAR(30),
      ToLoc     NVARCHAR(20),
      TargetQty INT,
	  ColorCode NVARCHAR(30)
   )

   -- result table
   CREATE TABLE #REPLENAVAIL
   (
      SKU       NVARCHAR(30),
      ToLoc     NVARCHAR(20),
      TargetQty INT,
      FromLoc   NVARCHAR(20),
      Lot       NVARCHAR(20),
      ID        NVARCHAR(20),
      Qty       INT,
      CaseID    NVARCHAR(20),
      ReplenishmentGroup NVARCHAR(10),
      ReplenishmentKey   NVARCHAR(10)
   );

   -- Aggregate TaskDetail to reduce join volume
   WITH TaskDetailAgg AS (
      SELECT 
         TD.Sku,
         TD.FinalLoc,
         TD.StorerKey,
         SUM(ISNULL(TD.Qty, 0)) AS Qty
      FROM dbo.TaskDetail TD WITH(NOLOCK)
      WHERE TD.TaskType IN ('RPF','RP1')
         AND TD.Status IN ('0','3','H','S')
	     AND Storerkey = @c_storerkey
      GROUP BY TD.Sku, TD.FinalLoc, TD.StorerKey
   )
   INSERT INTO #REPLENREQ (SKU, ToLoc, TargetQty, ColorCode)
   SELECT DISTINCT
      SL.SKU,
      SL.Loc,
      SL.QtyLocationLimit - ISNULL(SL.Qty,0) - ISNULL(TA.Qty, 0) - SUM(ISNULL(R.Qty,0))OVER(PARTITION BY R.SKU, R.ToLoc) AS TargetQty,
	  L.ColorCode
   FROM dbo.SKUxLOC SL WITH(NOLOCK)
      INNER JOIN dbo.LOC L WITH(NOLOCK)
         ON SL.Loc = L.Loc
	    AND L.Facility = @cFacility
      LEFT JOIN dbo.TaskDetailAgg TA WITH(NOLOCK)
         ON SL.Loc = TA.FinalLoc
        AND SL.Sku = TA.Sku
        AND SL.StorerKey = TA.StorerKey
      LEFT JOIN dbo.REPLENISHMENT R WITH(NOLOCK)
         ON ISNULL(R.Confirmed,'N') = 'N'
	    AND R.ToLoc = SL.Loc
	    AND R.Sku = SL.Sku
	    AND R.Storerkey = SL.StorerKey
   WHERE SL.StorerKey = @c_storerkey
      AND SL.LocationType = 'PICK'
      AND SL.Qty <= SL.QtyLocationMinimum
      AND SL.Qty < SL.QtyLocationLimit;

   -- Build candidates with a stable row order (change ORDER BY to change priority)
   WITH CodeLkupFiltered AS (
      SELECT Short, Long, UDF01, StorerKey, ListName, UDF02, UDF03
      FROM dbo.CODELKUP WITH(NOLOCK)
      WHERE ListName = 'JCBREPLENL'
   )
   SELECT 
      RR.SKU,
      RR.ToLoc,
      RR.TargetQty,
      LLI.Loc AS FromLoc,
      LLI.Lot,
      LLI.ID,
      LLI.Qty,
      LA.Lottable11 AS CaseID,
      ROW_NUMBER() OVER (PARTITION BY RR.SKU, RR.ToLoc ORDER BY LA.Lot, LLI.Lot, LLI.Qty DESC, LLI.ID) AS rn
   INTO #AvailRaw
   FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
      INNER JOIN dbo.LOC L WITH(NOLOCK) ON LLI.Loc = L.Loc
      INNER JOIN CodeLkupFiltered C WITH(NOLOCK)
         ON L.LocationType = C.Short
        AND L.LocationCategory = C.Long
        AND L.PutawayZone = C.UDF01
        AND LLI.StorerKey = C.StorerKey
      INNER JOIN #REPLENREQ RR WITH(NOLOCK)
         ON LLI.Sku = RR.SKU
      INNER JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK)
         ON LLI.Lot = LA.Lot
        AND LLI.StorerKey = LA.StorerKey
      OUTER APPLY (
         SELECT COUNT(DISTINCT LLI2.SKU) AS SKUCount
         FROM dbo.LOTxLOCxID LLI2 WITH(NOLOCK)
         WHERE LLI2.ID = LLI.ID
            AND LLI2.StorerKey = LLI.StorerKey
      ) AS SKUCount
   WHERE LLI.StorerKey = @c_storerkey
      AND LLI.Qty > 0
      AND LLI.QtyAllocated = 0
      AND LLI.QtyPicked = 0
      AND LLI.QtyReplen = 0
      AND LLI.QtyExpected = 0
      AND ((LA.Lottable11 <> '' AND C.UDF02 = '1') OR LA.Lottable11 = '')
      AND (SKUCount.SKUCount = 1 OR C.UDF03 = '1' OR LA.Lottable11 <> '')
      AND L.LocationFlag IN ('','NONE')
      AND L.Status = 'OK'
	  AND LA.Lottable03 = ISNULL(RR.ColorCode,'')
      AND LLI.Qty <= RR.TargetQty;  -- exclude single items larger than target

   -- Add a covering index to speed per-group, per-rn lookups
   CREATE INDEX IX_AvailRaw_SKU_ToLoc_rn ON #AvailRaw(SKU, ToLoc, rn) INCLUDE (Qty, FromLoc, Lot, ID, CaseID, TargetQty);

   -- Build small groups table to iterate deterministically
   SELECT SKU, ToLoc, TargetQty, MAX(rn) AS MaxRn
   INTO #Groups
   FROM #AvailRaw
   GROUP BY SKU, ToLoc, TargetQty;

   -- Generate batch-level replenishment group
   DECLARE 
      @b_success INT,
      @n_err INT,
      @c_errmsg NVARCHAR(255),
      @c_ReplenishmentGroup NVARCHAR(10);

   -- Cursor over groups; light-weight FAST_FORWARD cursor
   DECLARE 
      @SKU NVARCHAR(30), 
	  @ToLoc NVARCHAR(20), 
	  @TargetQty INT, 
	  @MaxRn INT;

   DECLARE grp CURSOR LOCAL FAST_FORWARD FOR
      SELECT 
	     SKU, 
		 ToLoc, 
		 TargetQty, 
		 MaxRn 
	  FROM #Groups;

   OPEN grp;
   FETCH NEXT FROM grp 
   INTO 
      @SKU, 
	  @ToLoc, 
	  @TargetQty, 
	  @MaxRn;

   WHILE @@FETCH_STATUS = 0
   BEGIN
      -- accumulator and row pointer for this group
      DECLARE @Accum INT = 0;
      DECLARE @rn INT = 1;

      -- loop rows in order; check each row and insert only if it fits
      WHILE @rn <= @MaxRn
      BEGIN
         DECLARE 
		    @Qty INT, 
			@FromLoc NVARCHAR(20), 
			@Lot NVARCHAR(20), 
			@ID NVARCHAR(20), 
			@CaseID NVARCHAR(20);
         DECLARE @c_ReplenishmentKey NVARCHAR(10);

         SELECT 
	        @Qty = Qty, 
		    @FromLoc = FromLoc, 
		    @Lot = Lot, 
		    @ID = ID, 
		    @CaseID = CaseID
         FROM #AvailRaw
         WHERE SKU = @SKU 
	        AND ToLoc = @ToLoc 
		    AND rn = @rn;

         IF @Qty IS NULL
            BREAK;

         IF @Accum + @Qty <= @TargetQty
         BEGIN
            EXECUTE nspg_GetKey
               @keyname       = 'REPLENISHGROUP',
               @fieldlength   = 10,
               @keystring     = @c_ReplenishmentGroup OUTPUT,
               @b_success     = @b_success OUTPUT,
               @n_err         = @n_err OUTPUT,
               @c_errmsg      = @c_errmsg OUTPUT;

	        IF @b_success <> 1  
            BEGIN  
               SET @n_err = 63524
			   SET @c_errmsg = 'NSQL ' + CONVERT(CHAR(5), @n_err) + ' could not create REPLENISHGROUP'
			   GOTO QUIT
            END

            -- Generate unique key per row
            EXECUTE nspg_GetKey 
               @keyname       = 'REPLENISHKEY',
               @fieldlength   = 10,
               @keystring     = @c_ReplenishmentKey OUTPUT,
               @b_success     = @b_success OUTPUT, 
               @n_err         = @n_err OUTPUT, 
               @c_errmsg      = @c_errmsg OUTPUT;

		    IF @b_success <> 1  
            BEGIN  
               SET @n_err = 63525
			   SET @c_errmsg = 'NSQL ' + CONVERT(CHAR(5), @n_err) + ' could not create REPLENISHKEY'
			   GOTO QUIT
            END

            INSERT INTO #REPLENAVAIL 
               (SKU, ToLoc, TargetQty, FromLoc, Lot, ID, Qty, CaseID, ReplenishmentGroup, ReplenishmentKey)
            VALUES 
               (@SKU, @ToLoc, @TargetQty, @FromLoc, @Lot, @ID, @Qty, @CaseID, @c_ReplenishmentGroup, @c_ReplenishmentKey);

            SET @Accum = @Accum + @Qty;

            IF @Accum = @TargetQty
               BREAK;
         END
         SET @rn = @rn + 1;
      END
      FETCH NEXT FROM grp 
	  INTO 
	     @SKU, 
		 @ToLoc, 
		 @TargetQty, 
		 @MaxRn;
   END

   CLOSE grp;
   DEALLOCATE grp;

   -- result
   INSERT INTO REPLENISHMENT
   SELECT 
      ReplenishmentGroup, 
      ReplenishmentKey, 
      @c_storerkey, 
      SKU, 
      FromLoc, 
      ToLoc, 
      Lot, 
      ID, 
      Qty, 
      0, 
      0, 
      3, 
      'EA',--IIF(CaseID = '', 'PL', 'EA'), 
      'JCBPK', 
      NULL, 
      'N', 
      '', 
      IIF(CaseID = '', 'FP', 'PP'), 
      GETDATE(), 
      'WMSFrontEnd', 
      GETDATE(), 
      'WMSFrontEnd', 
      CaseID, 
      IIF(CaseID = '', ID, CaseID), 
      '', 
      '',  
      FromLoc, 
      0, 
      IIF(CaseID = '', ID, CaseID), 
      '', 
      0, 
      0
   FROM #REPLENAVAIL RA
   WHERE NOT EXISTS (
      SELECT 1 FROM dbo.REPLENISHMENT R WITH(NOLOCK) 
	  WHERE R.Storerkey = @c_storerkey 
	     AND R.Id = RA.ID 
		 AND ISNULL(R.Confirmed,'N') = 'N'
	  )
         AND NOT EXISTS (
		    SELECT 1 FROM dbo.TaskDetail TD WITH(NOLOCK) 
			WHERE TD.Storerkey = @c_storerkey 
			   AND TD.FromID = RA.ID 
			   AND TD.Status NOT IN ('9','X')
			)

   QUIT:
   -- cleanup
   DROP INDEX IX_AvailRaw_SKU_ToLoc_rn ON #AvailRaw;
   DROP TABLE #Groups;
   DROP TABLE #AvailRaw;
   DROP TABLE #REPLENREQ;
   DROP TABLE #REPLENAVAIL;
END
