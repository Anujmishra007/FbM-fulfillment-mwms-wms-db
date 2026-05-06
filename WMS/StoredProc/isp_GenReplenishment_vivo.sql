SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***************************************************************************/
/* Stored Procedure: isp_GenReplenishment_vivo                             */
/* Creation Date:                                                          */
/* Copyright: MAERSK                                                       */
/*                                                                         */
/* Purpose: Perform Replenishment for Vivo only from Bulk type location    */
/*                                                                         */
/* Called By: nsp_FullPallet_ReplenishmentRpt02                            */
/*            @c_ReplenFlag --  N = Normal                                 */
/*                          --  W = Wave                                   */
/*                          -- PP = Pallet + (Pre-Pick)                    */
/*                          -- FP = Full Pallet                            */
/*                          -- FP+PARM = Full Pallet with Zone(9,10)=SKU   */
/*                             and Zone(11,12)=Aisle                       */
/*                          -- FP+PARM2 = Full Pallet To Zone03 From Zone02*/
/*                          -- FP+UCC=Full Plt(BULK->CASE)+UCC(CASE->PICK) */
/*                                                                         */
/* Version: 1.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author     Ver   Purposes                                  */
/* 24-oct-2025	ABS060		1.0		Generate replenishment only from Bulk  */
/*									type location						   */
/***************************************************************************/

CREATE OR ALTER  PROC [dbo].[isp_GenReplenishment_vivo]
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
   @c_ReplenFlag NVARCHAR(10) = 'WHC', -- N = Normal
                                    -- W = Wave
                                    -- PP = (Pre-Pick)
                                    -- FP = Full Pallet
                                    -- WHC = Wave Healthcare
                                    -- PPHC = Pre Pick Healthcare
                                    -- FP+PARM = Full Pallet with Zone(9,10)=SKU and Zone(11,12)=Aisle
                                    -- FP+PARM2 = Full Pallet between Zone 2 and Zone 3
                                    -- FP+UCC = Full Pallet (BULK to CASE) + UCC (CASE to PICK)

   @c_storerkey  NVARCHAR(15) -- SOS#156197
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   DECLARE @n_continue INT
   /* continuation flag
   1=Continue
   2=failed but continue processsing
   3=failed do not continue processing
   4=successful but skip furthur processing */
   DECLARE @n_starttcnt INT
   SELECT  @n_starttcnt = @@TRANCOUNT

   DECLARE @b_debug              INT,
           @c_Packkey            NVARCHAR(10),
           @c_UOM                NVARCHAR(10),
           @n_qtytaken           INT,
           @n_Pallet             INT,
           @n_FullPackQty        INT,
           @n_FullPackQtyPP      INT,
           @c_LocationType       NVARCHAR(10),
           @c_Facility           NVARCHAR(5),
           @n_Qty                INT,
           @n_QtyLocationLimit   INT,
           @n_QtyPicked          INT,
           @n_QtyAllocated       INT,
           @n_QtyLocationMinimum INT,
           @n_CaseCnt            INT,
           @n_ReplenQty          INT,
           @c_PickCode           NVARCHAR(10),
           @c_LogicalLocation    NVARCHAR(20),
           @c_SortColumn         NVARCHAR(30),
           @n_Cnt                INT,
           @n_QtyAvailable       INT,
           @c_priority           NVARCHAR(5),
           @c_ReplenQtyFlag      NVARCHAR(1),
           @c_ReplenishmentGroup NVARCHAR(10),
           @c_ReplExclProdNearExpiry   NVARCHAR(10), --NJOW04
           @n_NearExpiryDay      INT, --NJOW04
           @c_UCCNo              NVARCHAR(20),   --ML01
           @c_OPTION5            NVARCHAR(MAX),  --ML01
           @c_BulkLocType        NVARCHAR(MAX)   --ML01

   DECLARE @t_Bulk_LocType TABLE (
      LocationType NVARCHAR(10) NULL
   );
      

   DECLARE @b_success INT,
           @n_err INT,
           @c_errmsg NVARCHAR(255)

   SET @c_Facility = @c_Zone01
   SET @c_ReplenQtyFlag = '0'

   SELECT @n_continue = 1,
          @b_debug = 0

   EXECUTE nspg_GetKey
           @keyname       = 'REPLENISHGROUP',
           @fieldlength   = 10,
           @keystring     = @c_ReplenishmentGroup    OUTPUT,
           @b_success     = @b_success   OUTPUT,
           @n_err         = @n_err       OUTPUT,
           @c_errmsg      = @c_errmsg    OUTPUT
   IF NOT @b_success = 1
   BEGIN
      SELECT @n_continue = 3
   END

   IF ISNUMERIC(@c_Zone12) = 1 AND @c_Zone12 <> ''
   BEGIN
      SELECT @b_debug = CAST(@c_Zone12 AS INT)
   END

   IF ISNULL(RTRIM(@c_storerkey),'') = '' -- SOS#156197
   BEGIN
      SELECT @c_storerkey = 'ALL'
   END

   --NJOW02
   IF @c_ReplenFlag = 'FP+PARM'
   BEGIN
   	  IF ISNULL(@c_Zone10,'') = ''
   	     SET @c_Zone10 = 'ZZZZZZZZZZ'
   	  IF ISNULL(@c_Zone12,'') = ''
   	     SET @c_Zone12 = 'ZZZZZZZZZZ'
   END

   --WL01
   IF @c_ReplenFlag = 'FP+PARM2'
   BEGIN
   	  IF ISNULL(@c_Zone02,'') = ''
   	     SET @c_Zone02 = ''
   	  IF ISNULL(@c_Zone03,'') = ''
   	     SET @c_Zone03 = ''
   END

   CREATE TABLE #REPLENISHMENT
   (
      StorerKey    NVARCHAR(15),
      SKU          NVARCHAR(20),
      FromLOC      NVARCHAR(10),
      ToLOC        NVARCHAR(10),
      Lot          NVARCHAR(10),
      Id           NVARCHAR(18),
      Qty          INT,
      QtyMoved     INT,
      QtyInPickLOC INT,
      Priority     NVARCHAR(10),
      UOM          NVARCHAR(10),
      PackKey      NVARCHAR(10),
      UCCNo        NVARCHAR(20)    --ML01
   )

   CREATE TABLE #LOT_SORT
   (
      LOT        NVARCHAR(10),
      SortColumn NVARCHAR(20)
   )

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      DECLARE @c_CurrentSKU                 NVARCHAR(20),
              @c_CurrentStorer              NVARCHAR(15),
              @c_CurrentLOC                 NVARCHAR(10),
              @c_CurrentPriority            NVARCHAR(5),
              @n_CurrentFullCase            INT,
              @n_CurrentSeverity            INT,
              @c_FromLOC                    NVARCHAR(10),
              @c_FromLot                    NVARCHAR(10),
              @c_FromId                     NVARCHAR(18),
              @n_FromQty                    INT,
              @n_RemainingQty               INT,
              @n_PossibleCases              INT,
              @n_remainingcases             INT,
              @n_OnHandQty                  INT,
              @n_fromcases                  INT,
              @c_ReplenishmentKey           NVARCHAR(10),
              @n_numberofrecs               INT,
              @n_limitrecs                  INT,
              @c_FromLot2                   NVARCHAR(10),
              @b_DoneCheckOverAllocatedLots INT,
              @n_SKULocAvailableQty         INT,
              @n_LotSKUQTY                  INT,
              @c_SQLStatement               NVARCHAR(4000), --NJOW02
              @c_SQLCondition               NVARCHAR(2000), --NJOW02
              @c_PrevStorer                 NVARCHAR(15)    --ML01

      SELECT  @c_CurrentSKU      = SPACE(20),
              @c_CurrentStorer   = SPACE(15),
              @c_CurrentLOC      = SPACE(10),
              @c_CurrentPriority = SPACE(5),
              @n_CurrentFullCase = 0,
              @n_CurrentSeverity = 9999999,
              @n_FromQty         = 0,
              @n_RemainingQty    = 0,
              @n_PossibleCases   = 0,
              @n_remainingcases  = 0,
              @n_fromcases       = 0,
              @n_numberofrecs    = 0,
              @n_limitrecs       = 5,
              @n_LotSKUQTY       = 0,
              @c_SQLCondition    = '' --NJOW02

      IF @c_Storerkey <> 'ALL'
      BEGIN
      	 SELECT @c_SQLCondition = @c_SQLCondition + ' AND SKUxLOC.StorerKey = ''' + RTRIM(@c_storerkey) + ''''
      END

      IF @c_Zone02 <> 'ALL'
      BEGIN
      	 IF @c_ReplenFlag = 'FP+PARM'
      	 BEGIN
      	    SELECT @c_SQLCondition = @c_SQLCondition + ' AND LOC.PutawayZone IN ( '''+RTRIM(ISNULL(@c_Zone02,'')) +''',''' +
                                                      	                               RTRIM(ISNULL(@c_Zone03,'')) +''',''' +
                                                      	                               RTRIM(ISNULL(@c_Zone04,'')) +''',''' +
                                                      	                               RTRIM(ISNULL(@c_Zone05,'')) +''',''' +
                                                      	                               RTRIM(ISNULL(@c_Zone06,'')) +''',''' +
                                                      	                               RTRIM(ISNULL(@c_Zone07,'')) +''',''' +
                                                      	                               RTRIM(ISNULL(@c_Zone08,'')) +''')'
         END
         --WL01
         ELSE IF @c_ReplenFlag = 'FP+PARM2'
         BEGIN
      	    SELECT @c_SQLCondition = @c_SQLCondition + ' AND LOC.PutawayZone IN ( '''+RTRIM(ISNULL(@c_Zone03,'')) +''')'
         END
         ELSE
         BEGIN
      	    SELECT @c_SQLCondition = @c_SQLCondition + ' AND LOC.PutawayZone IN ( '''+RTRIM(ISNULL(@c_Zone02,'')) +''',''' +
                                                      	                               RTRIM(ISNULL(@c_Zone03,'')) +''',''' +
                                                      	                               RTRIM(ISNULL(@c_Zone04,'')) +''',''' +
                                                      	                               RTRIM(ISNULL(@c_Zone05,'')) +''',''' +
                                                      	                               RTRIM(ISNULL(@c_Zone06,'')) +''',''' +
                                                      	                               RTRIM(ISNULL(@c_Zone07,'')) +''',''' +
                                                      	                               RTRIM(ISNULL(@c_Zone08,'')) +''',''' +
                                                      	                               RTRIM(ISNULL(@c_Zone09,'')) +''',''' +
                                                      	                               RTRIM(ISNULL(@c_Zone10,'')) +''',''' +
                                                      	                               RTRIM(ISNULL(@c_Zone11,'')) +''',''' +
                                                      	                               RTRIM(ISNULL(@c_Zone12,'')) +''')'
         END
      END

      IF @c_ReplenFlag = 'FP+PARM'
      BEGIN
      	 SELECT @c_SQLCondition = @c_SQLCondition + ' AND SKUxLOC.Sku BETWEEN ''' + RTRIM(ISNULL(@c_Zone09,'')) + ''' AND ''' + RTRIM(ISNULL(@c_Zone10,'')) + ''''
      	                                          + ' AND LOC.LocAisle BETWEEN ''' + RTRIM(ISNULL(@c_Zone11,'')) + ''' AND ''' + RTRIM(ISNULL(@c_Zone12,'')) + ''''
      END

		  SELECT @c_SQLStatement = 'DECLARE Cur_ReplenSkuLoc CURSOR FAST_FORWARD READ_ONLY FOR ' +
                               'SELECT SKUxLOC.ReplenishmentPriority, ' +
                               'SKUxLOC.StorerKey, '+
                               'SKUxLOC.SKU, ' +
                               'SKUxLOC.LOC, ' +
                               'SKUxLOC.Qty, ' +
                               'SKUxLOC.QtyPicked, ' +
                               'SKUxLOC.QtyAllocated, ' +
                               'SKUxLOC.QtyLocationLimit, ' +
                               'SKUxLOC.QtyLocationMinimum, ' +
                               'PACK.CaseCnt, ' +
                               'PACK.Pallet, ' +
                               'SKU.PickCode, ' +
                               'SKUxLOC.LocationType, ' +
                               'SC2.Svalue '  + --NJOW04
                               'FROM    SKUxLOC (NOLOCK) ' +
                               'JOIN    LOC WITH ( NOLOCK ) ON SKUxLOC.Loc = LOC.Loc ' +
                               'JOIN    SKU WITH ( NOLOCK ) ON SKU.StorerKey = SKUxLOC.StorerKey AND ' +
                               '                               SKU.SKU = SKUxLOC.SKU ' +
                               'JOIN    PACK WITH ( NOLOCK ) ON PACK.PackKey = SKU.PACKKey ' +
                               'LEFT JOIN V_STORERCONFIG2 SC2 ON SKUXLOC.Storerkey = SC2.Storerkey AND SC2.Configkey = ''REPLEXCLPRODNEAREXPIRY_DAY'' ' + --NJOW04
                               'WHERE   LOC.Facility = ''' + RTRIM(ISNULL(@c_Facility,'')) +''' ' +
                               'AND SKUxLOC.LocationType IN ( ''PICK'', ''CASE'' ) ' +
                               'AND LOC.LocationFlag NOT IN ( ''DAMAGE'', ''HOLD'' ) ' +
                               RTRIM(ISNULL(@c_SQLCondition,'')) + ' ' +
                               'ORDER BY SKUxLOC.ReplenishmentPriority, SKUxLOC.Loc '

      EXEC(@c_SQLStatement)

      OPEN Cur_ReplenSkuLoc
      FETCH NEXT FROM cur_ReplenSkuLoc INTO @c_CurrentPriority, @c_CurrentStorer, @c_CurrentSKU, @c_CurrentLoc, @n_Qty,
                                            @n_QtyPicked, @n_QtyAllocated, @n_QtyLocationLimit, @n_QtyLocationMinimum,
                                            @n_CaseCnt, @n_Pallet, @c_PickCode, @c_LocationType, @c_ReplExclProdNearExpiry --NJOW04
      SET @c_PrevStorer = ''  --ML01

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         --ML01-S
         IF @c_CurrentStorer <> @c_PrevStorer
         BEGIN
            SET @c_PrevStorer = @c_CurrentStorer
            SET @c_OPTION5 = ''
            SET @c_BulkLocType = ''

            DELETE FROM @t_Bulk_LocType

            SELECT @c_OPTION5 = OPTION5 FROM dbo.fnc_GetRight2('', @c_CurrentStorer, '', 'CustomReplen_LocType') WHERE Authority='1'
            SET @c_BulkLocType = dbo.fnc_GetParamValueFromString('@c_BulkLocType', @c_OPTION5, @c_BulkLocType)

            INSERT INTO @t_Bulk_LocType(LocationType)
            SELECT DISTINCT TRIM(value)
              FROM STRING_SPLIT(@c_BulkLocType, ',')
             WHERE value<>''
             ORDER BY 1

            IF @@ROWCOUNT <= 0
               INSERT INTO @t_Bulk_LocType(LocationType) VALUES('BULK')
         END
         --ML01-E

			   SET @c_ReplenQtyFlag = '0'

         IF EXISTS(SELECT 1 FROM TASKDETAIL TD WITH (NOLOCK)
                   WHERE TD.Status IN ( '0','3','5')
                     AND TD.TaskType = 'RPF'
                     AND TD.ToLoc = @c_CurrentLoc
                     AND TD.Storerkey = @c_CurrentStorer
                     AND TD.Sku       = @c_CurrentSKU)
         BEGIN
      	     IF @b_debug = 1
      	     BEGIN
      	        PRINT 'Skip Replenishement, Work In Progress TM task found'
      	        PRINT '  SKU: ' + @c_CurrentSKU
      	        PRINT '  LOC: ' + @c_CurrentLOC
      	     END

            GOTO GET_NEXT_RECORD
         END

      	  IF EXISTS(SELECT 1 FROM REPLENISHMENT R WITH (NOLOCK)
      	            WHERE R.Storerkey = @c_CurrentStorer AND
      	                  R.Sku = @c_CurrentSKU AND
                           R.ToLoc = @c_CurrentLOC AND
                           R.Confirmed = 'N')
      	  BEGIN
      	     IF @b_debug = 1
      	     BEGIN
      	        PRINT 'Deleting Previous Replenishment Record'
      	        PRINT '  SKU: ' + @c_CurrentSKU
      	        PRINT '  LOC: ' + @c_CurrentLOC
      	     END

      	  	 DELETE REPLENISHMENT
      	  	 FROM REPLENISHMENT R
      	  	 JOIN SKUxLOC SL WITH (NOLOCK) ON SL.StorerKey = R.Storerkey AND
      	  	                                 SL.Sku = R.Sku AND SL.Loc = R.ToLoc
      	  	 WHERE R.Storerkey = @c_CurrentStorer AND
                     R.Sku = @c_CurrentSKU AND
                     R.ToLoc = @c_CurrentLOC AND
                     R.Confirmed = 'N' AND
                     SL.LocationType = @c_LocationType AND
                     R.ReplenishmentGroup NOT IN('DYNAMIC')
      	  END

         SET @n_ReplenQty = @n_QtyLocationLimit - ( @n_Qty - @n_QtyPicked )

         SET @n_QtyAvailable = ( @n_Qty - @n_QtyPicked )

         IF @c_ReplenFlag = 'W' OR @c_ReplenFlag = 'WHC' -- Wave Replen for Healthcare TH
         BEGIN
			     --SET @n_ReplenQty = @n_QtyLocationLimit - @n_QtyLocationMinimum -  @n_Qty - @n_QtyPicked - @n_QtyAllocated
			    /* IF @n_Qty - (@n_QtyPicked + @n_QtyAllocated) < 0
			     BEGIN
			        SET @n_ReplenQty = @n_QtyLocationLimit + ( (@n_Qty - (@n_QtyPicked + @n_QtyAllocated)) * -1 )
			     END
			     ELSE
			      BEGIN
			        SET @n_ReplenQty = @n_QtyLocationLimit - ( (@n_Qty - (@n_QtyPicked + @n_QtyAllocated)) )
			      END */
               IF @n_Qty - (@n_QtyPicked ) < 0
			     BEGIN
			        SET @n_ReplenQty = @n_QtyLocationLimit + ( (@n_Qty - (@n_QtyPicked )) * -1 )
			     END
			     ELSE
			      BEGIN
			        SET @n_ReplenQty = @n_QtyLocationLimit - ( (@n_Qty - (@n_QtyPicked )) )
			      END 

			     IF @n_ReplenQty < 0
			     BEGIN
			        SET @c_ReplenQtyFlag = '1'
			     	  IF @c_LocationType = 'PICK' and (@c_ReplenFlag IN ('WHC','PPHC','W','N'))
			     	  BEGIN
			     	  	SET @n_ReplenQty = @n_QtyLocationLimit
			     	  END
			     	  ELSE
			     	  BEGIN
			     	  	SET @n_ReplenQty = @n_Pallet
			     	  END
			     END
            SET @n_QtyAvailable = ( @n_QtyAvailable - @n_QtyAllocated )
			   END
         ELSE IF @c_ReplenFlag = 'PP'
         BEGIN
			     SET @n_ReplenQty = @n_ReplenQty + @n_QtyAllocated

			     --IF @c_LocationType = 'CASE'
			     --   SET @n_ReplenQty = @n_ReplenQty +  @n_Pallet
            SET @n_QtyAvailable = ( @n_QtyAvailable - @n_QtyAllocated )
			   END
			   ELSE IF @c_ReplenFlag = 'PPHC' -- For Healthcare TH
         BEGIN
			     SET @n_ReplenQty = @n_ReplenQty + @n_QtyAllocated

			     --IF @c_LocationType = 'CASE'
			     --   SET @n_ReplenQty = @n_ReplenQty

            SET @n_QtyAvailable = ( @n_QtyAvailable - @n_QtyAllocated )
			   END

         IF @b_debug = 1
         BEGIN
            PRINT '**'
			      PRINT 'Storer :' + @c_CurrentStorer
			      PRINT 'SKU: ' + @c_CurrentSKU
            PRINT 'Loc: ' +  @c_CurrentLoc
            PRINT '   Qty Replen: ' + CONVERT(NVARCHAR(10), @n_ReplenQty)
            PRINT '   Qty Available: ' + CONVERT(NVARCHAR(10), @n_QtyAvailable)
            PRINT '   Qty Location Minimum: ' + CONVERT(NVARCHAR(10), @n_QtyLocationMinimum)
			     PRINT '   Replen Qty Flag : ' + @c_ReplenQtyFlag + ' '
			     PRINT '   Location Limit: ' + CONVERT(NVARCHAR(10), @n_QtyLocationLimit)
            PRINT '   Case Qty: ' +  CONVERT(NVARCHAR(10), @n_CaseCnt)
            PRINT '   Pallet Qty: ' + CONVERT(NVARCHAR(10), @n_Pallet)
            PRINT '   Location Type: ' + @c_LocationType
            PRINT ''
			   END

			   IF @n_QtyAvailable > @n_QtyLocationMinimum
			      GOTO GET_NEXT_RECORD

			   SET @n_RemainingQty = @n_ReplenQty

			   DELETE #LOT_SORT

			   INSERT INTO #LOT_SORT (
			   	LOT, SortColumn
			   )
			      SELECT DISTINCT LOT, ''
			      FROM dbo.LOTxLOCxID LLL WITH (NOLOCK)
			      WHERE LLL.StorerKey = @c_CurrentStorer
			      AND   LLL.SKU = @c_CurrentSKU
			      AND   LLL.LOC = @c_CurrentLOC
			      AND   LLL.Qty - QtyAllocated - QtyPicked < 0

			   IF @b_debug = 1
			   BEGIN
			      PRINT '***'
			      PRINT '>>> Current LOC: ' + @c_CurrentLOC
			   END

            --ML01-S
            IF @c_ReplenFlag = 'FP+UCC'
            BEGIN
			      INSERT INTO #LOT_SORT (LOT, SortColumn)
               SELECT DISTINCT
                      LOTxLOCxID.LOT
                    , ISNULL(CONVERT(NVARCHAR(8),LOTTABLE04,112),'00000000') + ISNULL(CONVERT(NVARCHAR(8),LOTTABLE05,112),'00000000') AS SortColumn
                 FROM LOTxLOCxID WITH ( NOLOCK )
                 JOIN LOC WITH ( NOLOCK ) ON LOTxLOCxID.LOC = LOC.LOC
                 JOIN LOTATTRIBUTE WITH ( NOLOCK ) ON LOTxLOCxID.LOT = LOTATTRIBUTE.LOT
                 JOIN dbo.LOT LOT WITH (NOLOCK) ON LOT.LOT = LOTxLOCxID.LOT
                 JOIN dbo.ID ID WITH (NOLOCK) ON ID.ID = LOTxLOCxID.ID
                 JOIN dbo.SKUxLOC SL WITH (NOLOCK) ON SL.StorerKey = LOTxLOCxID.StorerKey AND SL.SKU = LOTxLOCxID.SKU AND SL.LOC = LOTxLOCxID.LOC
                WHERE LOTxLOCxID.StorerKey = @c_CurrentStorer
                  AND LOTxLOCxID.SKU = @c_CurrentSKU
                  AND LOC.LocationFlag NOT IN ('DAMAGE','HOLD')
                  AND LOC.Facility = @c_Facility
                  AND LOC.Status = 'OK'
                  AND LOT.Status = 'OK'
                  AND ID.Status = 'OK'
                  AND (@c_LocationType='PICK' AND LOC.Locationtype='CASE'
                    OR @c_LocationType='CASE' AND LOC.Locationtype IN (SELECT LocationType From @t_Bulk_LocType))
                  AND LOTxLOCxID.LOC <> @c_CurrentLOC
                  AND (LOTxLOCxID.Qty - LOTxLOCxID.QtyPicked - LOTxLOCxID.QtyAllocated) > 0
                  AND (@c_LocationType='PICK' AND SL.Locationtype<>'PICK'
                    OR @c_LocationType='CASE' AND SL.Locationtype NOT IN ('CASE','PICK'))
                  AND NOT EXISTS(SELECT 1 FROM #LOT_SORT L WHERE L.LOT = LOTxLOCxID.LOT)
                ORDER BY SortColumn
            END
            ELSE
            --ML01-E
			   IF LEFT(@c_PickCode,5) = 'nspRP'
			   BEGIN
			      INSERT INTO #LOT_SORT (LOT, SortColumn)
			      EXEC(@c_PickCode + ' ''' + @c_CurrentStorer + ''','
                                          + ' ''' + @c_CurrentSKU + ''','
                                          + ' ''' + @c_CurrentLOC + ''','
                                          + ' ''' + @c_Facility + ''','
                                          + ' ''''' )
			   END
			   ELSE
			   BEGIN
			      INSERT INTO #LOT_SORT (LOT, SortColumn)
                   SELECT DISTINCT
                          LOTxLOCxID.LOT,
                          CASE WHEN LOTTABLE04 IS NULL THEN '00000000'
                               ELSE CONVERT(CHAR(4), DATEPART(year, LOTTABLE04)) +
                                    RIGHT('0' + CONVERT(NVARCHAR(2), DATEPART(month, LOTTABLE04)),2) +
                                    RIGHT('0' + CONVERT(NVARCHAR(2), DATEPART(day, LOTTABLE04)),2)
                          END +
                          CASE WHEN LOTTABLE05 IS NULL THEN '00000000'
                               ELSE CONVERT(NVARCHAR(4), DATEPART(year, LOTTABLE05)) +
                                    RIGHT('0' + CONVERT(NVARCHAR(2), DATEPART(month, LOTTABLE05)),2) +
                                    RIGHT('0' + CONVERT(NVARCHAR(2), DATEPART(day, LOTTABLE05)),2)
                          END AS SortColumn
                   FROM   LOTxLOCxID WITH ( NOLOCK )
                   JOIN   LOC WITH ( NOLOCK ) ON LOTxLOCxID.LOC = LOC.LOC
                   JOIN   LOTATTRIBUTE WITH ( NOLOCK ) ON LOTxLOCxID.LOT = LOTATTRIBUTE.LOT
                   JOIN   dbo.LOT LOT WITH (NOLOCK) ON LOT.LOT = LOTxLOCxID.LOT
                   JOIN   dbo.ID ID WITH (NOLOCK) ON ID.ID = LOTxLOCxID.ID
                   JOIN   dbo.SKUxLOC SL WITH (NOLOCK) ON
                             SL.StorerKey = LOTxLOCxID.StorerKey
                             AND SL.SKU = LOTxLOCxID.SKU
                             AND SL.LOC = LOTxLOCxID.LOC
                   WHERE  LOTxLOCxID.StorerKey = @c_CurrentStorer AND
                          LOTxLOCxID.SKU = @c_CurrentSKU AND
                          LOC.LocationFlag <> 'DAMAGE' AND
                          LOC.LocationFlag <> 'HOLD' AND
                          LOC.Facility = @c_Facility AND
                          LOC.Status = 'OK' AND
                          LOT.Status = 'OK' AND
                          ID.Status = 'OK' AND
                          LOC.Status <> 'HOLD' AND
                          --LOC.Locationtype NOT IN ('CASE','PICK') AND -- (SHONGxx)
						  LOC.Locationtype IN (SELECT LocationType From @t_Bulk_LocType) and
                          LOTxLOCxID.LOC <> @c_CurrentLOC AND
                          (LOTxLOCxID.Qty - LOTxLOCxID.QtyPicked - LOTxLOCxID.QtyAllocated) > 0 AND
                          SL.Locationtype <> 'CASE' AND --- SOS#152090 ---
                          SL.Locationtype <> 'PICK' AND --- SOS#152090 ---
                          NOT EXISTS(SELECT 1 FROM #LOT_SORT L WHERE L.LOT = LOTxLOCxID.LOT)
                  ORDER BY SortColumn
			   END

			   --NJOW04
			   SET @n_NearExpiryDay = 0
			   IF ISNULL(@c_ReplExclProdNearExpiry,'0') <> '0' AND ISNUMERIC(@c_ReplExclProdNearExpiry) = 1
			   BEGIN
			   	  SET @n_NearExpiryDay = CONVERT(int, @c_ReplExclProdNearExpiry) * -1
			   	  DELETE #LOT_SORT
			   	  FROM #LOT_SORT
			   	  JOIN LOTATTRIBUTE LA (NOLOCK) ON #LOT_SORT.Lot = LA.Lot
			   	  WHERE ISNULL(#LOT_SORT.SortColumn,'') <> ''  --Exclude overallocation lot
			   	  AND DATEADD(Day, @n_NearExpiryDay, LA.Lottable04) <= GETDATE()
			   END

         SELECT @n_Cnt = COUNT(1) FROM #LOT_SORT

         IF @b_debug = 1
         BEGIN
            IF @n_Cnt = 0
            BEGIN
               PRINT '**** No Stock Available'
            END
         END

         IF @n_Cnt = 0
            GOTO GET_NEXT_RECORD

			   DECLARE cur_LOT CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
			   SELECT DISTINCT LOT, SortColumn
			   FROM   #LOT_SORT
			   ORDER BY SortColumn

			   OPEN cur_LOT

			   FETCH NEXT FROM cur_LOT INTO @c_FromLot, @c_SortColumn

			   WHILE @@FETCH_STATUS <> -1 AND @n_RemainingQty > 0
			   BEGIN
            IF @b_debug = 1
            BEGIN
               PRINT '****'
			   	    PRINT '>>> LOT : ' + @c_FromLOT
			      END

               --ML01-S
               IF @c_ReplenFlag = 'FP+UCC'
			         DECLARE CUR_LOTxLOCxID_REPLEN CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                  SELECT   LLI.LOC,
                           LLI.ID,
                           CASE WHEN ISNULL(UCC.UCCNo,'')<>'' THEN UCC.Qty ELSE (LLI.QTY - LLI.QTYPICKED - LLI.QTYALLOCATED) END AS OnHandQty,
                           LOC.LogicalLocation,
                           UCCNo=ISNULL(UCC.UCCNo,'')
                  FROM dbo.LOTxLOCxID LLI (NOLOCK)
                  JOIN dbo.LOC LOC WITH (NOLOCK) ON LLI.LOC = LOC.Loc
                  JOIN dbo.ID ID WITH (NOLOCK) ON LLI.ID = ID.Id
                  JOIN dbo.SKUxLOC SL WITH (nolock) ON SL.StorerKey = LLI.StorerKey AND SL.SKU = LLI.SKU AND SL.LOC = LLI.LOC
                  LEFT JOIN UCC (NOLOCK) ON LLI.Storerkey=UCC.Storerkey AND LLI.Sku=UCC.Sku AND LLI.Lot=UCC.Lot AND LLI.Loc=UCC.Loc AND LLI.ID=UCC.ID
                                        AND UCC.Status='1' AND LLI.QTY - LLI.QTYPICKED - LLI.QTYALLOCATED>=UCC.Qty AND UCC.Qty>0 AND @c_LocationType='PICK'
                  WHERE LLI.LOT = @c_FromLot
                    AND LOC.LocationFlag NOT IN ('DAMAGE', 'HOLD')
                    AND LOC.Facility = @c_Facility
                    AND LOC.Status = 'OK'
                    AND ID.Status = 'OK'
                    AND LOC.LocationCategory <> 'shelving'
                    AND (@c_LocationType='PICK' AND LOC.Locationtype='CASE'
                      OR @c_LocationType='CASE' AND LOC.Locationtype IN (SELECT LocationType From @t_Bulk_LocType))
                    AND (@c_LocationType='PICK' AND SL.Locationtype<>'PICK'
                      OR @c_LocationType='CASE' AND SL.Locationtype NOT IN ('CASE','PICK'))
                    AND (LLI.QTY - LLI.QTYPICKED - LLI.QTYALLOCATED) > 0
                    AND NOT (@c_LocationType='CASE' AND LLI.ID='')
                  ORDER BY
                  CASE WHEN LOC.LocationCategory <> 'shelving' THEN 0 ELSE 1 END,
                  CASE WHEN LOC.LocationType = 'PICK' THEN 0 ELSE 1 END,
                  CASE WHEN LOC.LocationType IN (SELECT LocationType From @t_Bulk_LocType) THEN 0 ELSE 1 END,
                  OnHandQty, LOC.LogicalLocation
               ELSE
               --ML01-E
			         DECLARE CUR_LOTxLOCxID_REPLEN CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                   SELECT   LLI.LOC,
                            LLI.ID,
                            (LLI.QTY - LLI.QTYPICKED - LLI.QTYALLOCATED) AS OnHandQty,
                            LOC.LogicalLocation,
                            CAST('' AS NVARCHAR(20)) AS UCCNo   --ML01
                   FROM     dbo.LOTxLOCxID LLI (NOLOCK)
                   JOIN dbo.LOC LOC WITH (NOLOCK) ON LLI.LOC = LOC.Loc
                   JOIN dbo.ID ID WITH (NOLOCK) ON LLI.ID = ID.Id
                   JOIN dbo.SKUxLOC SL WITH (nolock) ON SL.StorerKey = LLI.StorerKey AND
                      SL.SKU = LLI.SKU AND SL.LOC = LLI.LOC
                   WHERE    LOT = @c_FromLot AND
                            LOC.LocationFlag NOT IN ('DAMAGE', 'HOLD') AND
                            LOC.Facility = @c_Facility AND
                            LOC.Status = 'OK' AND
                            ID.Status = 'OK' AND
                            LOC.LocationCategory <> 'shelving' AND
                            --LOC.Locationtype NOT IN ('CASE','PICK') AND -- (SHONGxx)
							LOC.Locationtype IN (SELECT LocationType From @t_Bulk_LocType) and
                            SL.Locationtype <> 'CASE' AND --- SOS#152090 ---
                            SL.Locationtype <> 'PICK' AND --- SOS#152090 ---
                            (LLI.QTY - LLI.QTYPICKED - LLI.QTYALLOCATED) > 0 AND
                            LOC.PUTAWAYZONE = CASE WHEN @c_ReplenFlag = 'FP+PARM2' THEN @c_Zone02 ELSE LOC.PUTAWAYZONE END   --WL01
                   ORDER BY
                   CASE WHEN LOC.LocationCategory <> 'shelving' THEN 0 ELSE 1 END,
                   CASE WHEN LOC.LocationType = 'PICK' THEN 0 ELSE 1 END,
                   CASE WHEN LOC.LocationType IN (SELECT LocationType From @t_Bulk_LocType) THEN 0 ELSE 1 END,
                   OnHandQty, LOC.LogicalLocation

                OPEN CUR_LOTxLOCxID_REPLEN

                FETCH NEXT FROM CUR_LOTxLOCxID_REPLEN INTO
                @c_FromLoc, @c_FromID, @n_OnHandQty, @c_LogicalLocation
                , @c_UCCNo   --ML01
                WHILE @@FETCH_STATUS <> -1
                BEGIN

                   --- SOS#152090 (Start) ---
                   -- **** Update OnHandQTY to avoid getting the same OnHandQTY when loop into 2nd Pick Location with same SKU *** --
                   SET @n_LotSKUQTY = 0
                   SELECT @n_LotSKUQTY = SUM(QTY)
                   From #Replenishment (NOLOCK)
                   Where Lot = @c_FromLot
                   AND FromLOC = @c_FromLoc
                   AND ID = @c_FromId

                   If @b_debug = 1
                   BEGIN
                       PRINT '*****'
                       SELECT 'Original Lot QTY: ' , @n_OnHandQty, 'Located Replen QTY: ' , @n_LotSKUQTY
                   END

                   SET @n_OnHandQty = @n_OnHandQty - ISNULL(@n_LotSKUQTY,0)

                   IF @n_OnHandQTy <= 0
                      GOTO GET_NEXT_LOT

                   IF @c_ReplenFlag IN ('FP+PARM') AND @n_OnHandQty  > @n_RemainingQty  --NJOW02
                   BEGIN
                   	  SET @n_RemainingQty  = 0
                   	  BREAK
                   END

                   --- SOS#152090 (End) ---

                   IF @b_debug = 1
                   BEGIN
                     SELECT   @c_FromLOC 'From Loc',
                              @c_FromLot 'From lot',
                              @c_FromId  'From ID',
                              @n_OnHandQty '@n_OnHandQty'
                   END

                   IF @n_CaseCnt IS NULL OR @n_CaseCnt = 0
                      SET @n_CaseCnt = 1

                   IF @n_OnHandQty < @n_RemainingQty
                      SET  @n_PossibleCases = FLOOR(@n_OnHandQty / @n_CaseCnt)
                   ELSE
                      SET  @n_PossibleCases = CEILING(@n_RemainingQty / (@n_CaseCnt * 1.00) )

                   If @b_debug = 1
                   BEGIN
                     PRINT '>>>  On Hand Qty: ' + CONVERT(NVARCHAR(10), @n_OnHandQty)
                     PRINT '     Case Cnt:' + CONVERT(NVARCHAR(10), @n_CaseCnt)
                     PRINT '>>>  Remaining Qty: ' + CONVERT(NVARCHAR(10), @n_RemainingQty)
                     PRINT '     Possible Cases: ' + CONVERT(NVARCHAR(10), @n_PossibleCases)
                   END

                   SELECT   @c_Packkey = PACK.PackKey,
                            @c_UOM = PACK.PackUOM3
                   FROM     SKU (NOLOCK),
                            PACK (NOLOCK)
                   WHERE    SKU.PackKey = PACK.Packkey AND
                            SKU.StorerKey = @c_CurrentStorer AND
                            SKU.SKU = @c_CurrentSKU

                   IF @c_LocationType = 'PICK'
                   BEGIN
                      IF @c_ReplenFlag IN ('PPHC','WHC')
                      BEGIN
                         IF @c_ReplenQtyFlag = '1'
                         BEGIN
                            SET @n_FullPackQty = @n_QtyLocationLimit
                         END
                         ELSE
                         BEGIN
                             SET @n_FullPackQty = @n_OnHandQty
                         END
                      END
                      ELSE IF @c_ReplenFlag IN ('W','N')
                      BEGIN
                         IF @n_QtyLocationLimit = 0 AND @n_CaseCnt > 1
                         BEGIN
                            SET @n_FullPackQty = @n_CaseCnt
                         END
                         ELSE
                         BEGIN
                            --SET @n_FullPackQty = @n_PossibleCases
                            --IF @n_PossibleCases = 0 --NJOW01
                               SET @n_FullPackQty = @n_OnHandQty    --NJOW03
                            --ELSE
                               --SET @n_FullPackQty = @n_PossibleCases * @n_CaseCnt
                         END
                      END
                      --ML01-S
                      ELSE IF @c_ReplenFlag = 'FP+UCC'
                      BEGIN
                         SET @n_FullPackQty = CASE WHEN ISNULL(@c_UCCNo,'')<>'' THEN @n_OnHandQty ELSE 0 END
                      END
                      --ML01-E
                      ELSE
                      BEGIN
                          SET @n_FullPackQty = @n_OnHandQty
                      END
                   END
                   ELSE --none pick
                   BEGIN
                      --ML01-S
                      IF @c_ReplenFlag = 'FP+UCC'
                      BEGIN
                         SET @n_FullPackQty = CASE WHEN ISNULL(@c_FromID,'')<>'' THEN @n_OnHandQty ELSE 0 END
                      END
                      ELSE
                      --ML01-E
                      SET @n_FullPackQty = @n_Pallet
                   END


                   ----------------------------------------------------------------------------------------------------
                   If @b_debug = 1
                   BEGIN
                      PRINT '>>>  Full Pack Qty: ' + CONVERT(NVARCHAR(10), @n_FullPackQty)
                   END

                   IF ( @n_OnHandQty <= @n_FullPackQty ) AND
                      ( @n_OnHandQty <= @n_RemainingQty )
                   BEGIN
			   			        IF @c_LocationType = 'PICK' AND (@c_ReplenFlag = 'WHC' OR @c_ReplenFlag = 'PPHC')
			   			        BEGIN
			   			        	 SET @n_FromQty = @n_OnHandQty
			   			        END
			   			        ELSE
			   			        BEGIN
			   			        	 IF @n_PossibleCases > 0
			   			        	 	  IF @c_ReplenFlag = 'WHC' OR @c_ReplenFlag = 'PPHC'
			   			        	 	  	  SELECT @n_FromQty = @n_CaseCnt * @n_PossibleCases
			   			        	 	  ELSE
			   			        	 	  	  SELECT @n_FromQty = @n_OnHandQty
			   			        	 ELSE
			   			        	    IF @c_ReplenFlag = 'N' OR @c_ReplenFlag = 'W' --NJOW01
			   			        	       SELECT @n_FromQty = @n_OnHandQty
			   			        	    ELSE
			   			        	 	     SELECT @n_FromQty = 0
			   			        END

                      SELECT   @n_RemainingQty = @n_RemainingQty - @n_FromQty
                   END
                   ELSE
                   BEGIN
                      -- Case Pick Location
                      -- Only Allow Full Pallet, if 90%, Let it go
                      IF @c_LocationType = 'CASE'
                      BEGIN
                         --IF ( @n_OnHandQty >= @n_FullPackQty ) AND
                         --   ( (@n_RemainingQty * 1.00) / @n_FullPackQty) * 100 > 90
                         --BEGIN
                            --SELECT  @n_FromQty = @n_FullPackQty
                            IF @c_ReplenFlag = 'WHC' OR @c_ReplenFlag = 'PPHC'
                            BEGIN
                               IF  (@n_OnHandQty %  @n_CaseCnt) > 0
			   						           BEGIN
			   						           		IF @n_OnHandQty < @n_CaseCnt
			   						           			 SELECT  @n_FromQty = 0
			   						           		Else
			   						           			 SELECT  @n_FromQty = @n_OnHandQty - ( @n_OnHandQty % @n_CaseCnt )
			   						           	--IF @
                                             --SET @n_FromQty = @n_CaseCnt * @n_PossibleCases
			   						           END
                               ELSE
			   						           BEGIN
                                  SELECT  @n_FromQty = @n_OnHandQty
			   						           END
                            END
                            ELSE
                            BEGIN
                               IF FLOOR(@n_OnHandQty / @n_CaseCnt) > 0
			   							            SELECT  @n_FromQty = @n_OnHandQty
                               ELSE
                                  SELECT  @n_FromQty = 0
                            END
                         --END
                         --ELSE
                         --   SET @n_FromQty = 0
                      END
                      ELSE
                      BEGIN
                         IF ( @n_OnHandQty >= @n_FullPackQty )
			   					          IF @c_ReplenFlag = 'PPHC' OR @c_ReplenFlag = 'WHC'
                            BEGIN
			   					          	 SET @n_FromQty = @n_RemainingQty
			   					          END
			   					          ELSE
			   					          BEGIN
			   					          	 SET @n_FromQty = @n_FullPackQty
			   					          END
                         ELSE
                         BEGIN
                            IF @c_ReplenFlag = 'PPHC' OR @c_ReplenFlag = 'WHC'
                            BEGIN
			   							         SET @n_FromQty = @n_RemainingQty
                            END
                            ELSE
                            BEGIN
                               SET @n_FromQty = 0
                            END
                         END
                      END

                      SELECT   @n_RemainingQty = @n_RemainingQty - @n_FromQty
                   END

                   IF @b_debug = 1
                   BEGIN
			   		          PRINT 'Possible CASE: ' + CAST(@n_PossibleCases AS NVARCHAR(10))
                      PRINT 'Qty To Take: ' + CAST(@n_FromQty AS NVARCHAR(10))
			   	         END

                   IF @n_FromQty > 0
                   BEGIN
                      IF @n_continue = 1 OR @n_continue = 2
                      BEGIN
                         INSERT   #REPLENISHMENT
                                  (
                                    StorerKey,
                                    SKU,
                                    FromLOC,
                                    ToLOC,
                                    Lot,
                                    Id,
                                    Qty,
                                    UOM,
                                    PackKey,
                                    Priority,
                                    QtyMoved,
                                    QtyInPickLOC,
                                    UCCNo          --ML01
                                  )
                         VALUES   (
                                    @c_CurrentStorer,
                                    @c_CurrentSKU,
                                    @c_FromLOC,
                                    @c_CurrentLOC,
                                    @c_FromLot,
                                    @c_FromId,
                                    @n_FromQty,
                                    @c_UOM,
                                    @c_Packkey,
                                    @c_CurrentPriority,
                                    0,
                                    0,
                                    @c_UCCNo          --ML01
                                    )
                      END
                      SELECT   @n_numberofrecs = @n_numberofrecs + 1
                   END -- if from qty > 0

			         IF @n_RemainingQty <= 0
			            BREAK

              -- If the remaining qty < 90% of the Case then Break
              IF @c_LocationType = 'PICK' AND
                 ( (@n_RemainingQty / (@n_CaseCnt * 1.00)) * 100 ) < 90
              BEGIN
                 SET @n_RemainingQty = 0
                 BREAK
              END

   		     GET_NEXT_LOT: --- SOS#152090 ---
			   		FETCH NEXT FROM CUR_LOTxLOCxID_REPLEN INTO
                   @c_FromLoc, @c_FromID, @n_OnHandQty, @c_LogicalLocation
                   , @c_UCCNo   --ML01
			   	      END -- while CUR_LOTxLOCxID_REPLEN
			   	      CLOSE CUR_LOTxLOCxID_REPLEN
			   	      DEALLOCATE CUR_LOTxLOCxID_REPLEN

			       IF @n_RemainingQty = 0
			          BREAK

			       FETCH NEXT FROM cur_LOT INTO @c_FromLot, @c_SortColumn
			   END --while cur_LOT
			   CLOSE cur_LOT
			   DEALLOCATE cur_LOT

         GET_NEXT_RECORD:
         FETCH NEXT FROM cur_ReplenSkuLoc INTO @c_CurrentPriority, @c_CurrentStorer, @c_CurrentSKU, @c_CurrentLoc, @n_Qty,
                                               @n_QtyPicked, @n_QtyAllocated, @n_QtyLocationLimit, @n_QtyLocationMinimum,
                                               @n_CaseCnt, @n_Pallet, @c_PickCode, @c_LocationType, @c_ReplExclProdNearExpiry --NJOW04
			END -- while cur_replenskuloc
			CLOSE Cur_ReplenSkuLoc
			DEALLOCATE Cur_ReplenSkuLoc

      IF @n_continue = 1 OR
         @n_continue = 2
      BEGIN
         /* Update the column QtyInPickLOC in the Replenishment Table */
         IF @n_continue = 1 OR
            @n_continue = 2
            BEGIN
               UPDATE   #REPLENISHMENT
               SET      QtyInPickLOC = SKUxLOC.Qty - SKUxLOC.QtyPicked
               FROM     SKUxLOC (NOLOCK)
               WHERE    #REPLENISHMENT.StorerKey = SKUxLOC.StorerKey AND
                        #REPLENISHMENT.SKU = SKUxLOC.SKU AND
                        #REPLENISHMENT.toLOC = SKUxLOC.LOC
            END
      END --continue end
      /* Insert Into Replenishment Table Now */

      DECLARE CUR1 CURSOR FAST_FORWARD READ_ONLY
      FOR SELECT  R.FromLoc,
                     R.Id,
                     R.ToLoc,
                     R.Sku,
                     R.Qty,
                     R.StorerKey,
                     R.Lot,
                     R.PackKey,
                     R.Priority,
                     R.UOM,
                     R.UCCNo          --ML01
             FROM    #REPLENISHMENT R
      OPEN CUR1
	DECLARE 
    @prevFromLoc NVARCHAR(10) = '',
    @prevToLoc   NVARCHAR(10) = '',
    @prevSKU     NVARCHAR(20) = '',
    @prevGroup   NVARCHAR(10) = ''

      FETCH NEXT FROM CUR1 INTO @c_FromLoc, @c_FromId, @c_CurrentLoc,
         @c_CurrentSKU, @n_FromQty, @c_CurrentStorer, @c_FromLot, @c_PackKey,
         @c_Priority, @c_UOM,
         @c_UCCNo   --ML01
      WHILE @@FETCH_STATUS <> -1
      BEGIN
	  -- Check if the same FromLoc, ToLoc, SKU combination repeats
    IF @c_FromLoc = @prevFromLoc 
       AND @c_CurrentLoc = @prevToLoc 
       AND @c_CurrentSKU = @prevSKU
    BEGIN
        -- Reuse previous replenishment group
        SET @c_ReplenishmentGroup = @prevGroup
    END
    ELSE
    BEGIN
        -- Generate a new replenishment group
        EXECUTE nspg_GetKey
                @keyname       = 'REPLENISHGROUP',
                @fieldlength   = 10,
                @keystring     = @c_ReplenishmentGroup OUTPUT,
                @b_success     = @b_success OUTPUT,
                @n_err         = @n_err OUTPUT,
                @c_errmsg      = @c_errmsg OUTPUT

        IF @b_success <> 1
        BEGIN
            SET @n_continue = 3
            BREAK
        END

        -- Save current as previous
        SET @prevFromLoc = @c_FromLoc
        SET @prevToLoc   = @c_CurrentLoc
        SET @prevSKU     = @c_CurrentSKU
        SET @prevGroup   = @c_ReplenishmentGroup
    END

    -- Now generate ReplenishmentKey (unique per line)
         EXECUTE nspg_GetKey 'REPLENISHKEY', 10, @c_ReplenishmentKey OUTPUT,
            @b_success OUTPUT, @n_err OUTPUT, @c_errmsg OUTPUT
         IF NOT @b_success = 1
            BEGIN
               BREAK
            END
			
         IF @b_success = 1
            BEGIN
               INSERT   REPLENISHMENT
                        (
                          replenishmentgroup,
                          ReplenishmentKey,
                          StorerKey,
                          Sku,
                          FromLoc,
                          ToLoc,
                          Lot,
                          Id,
                          Qty,
                          UOM,
                          PackKey,
                          Confirmed,
                          RefNo   --ML01
                        )
               VALUES   (
                          @c_ReplenishmentGroup,
                          @c_ReplenishmentKey,
                          @c_CurrentStorer,
                          @c_CurrentSku,
                          @c_FromLoc,
                          @c_CurrentLoc,
                          @c_FromLot,
                          @c_FromId,
                          @n_FromQty,
                          @c_UOM,
                          @c_PackKey,
                          'N',
                          @c_UCCNo   --ML01
                        )
               SELECT   @n_err = @@ERROR
               IF @n_err <> 0
                  BEGIN
                     SELECT   @n_continue = 3
                     SELECT   @c_errmsg = CONVERT(CHAR(250), @n_err),
                              @n_err = 63524   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                     SELECT   @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err) +
                              ': Insert into live pickdetail table failed.  Preallocated QTY Needs to be Manually Adjusted! (nspOrderProcessing)' +
                              ' ( ' + ' SQLSvr MESSAGE=' +
                              LTrim(RTrim(@c_errmsg)) +
                              ' ) '
                  END
            END -- IF @b_success = 1
         FETCH NEXT FROM CUR1 INTO @c_FromLoc, @c_FromId, @c_CurrentLoc,
            @c_CurrentSKU, @n_FromQty, @c_CurrentStorer, @c_FromLot,
            @c_PackKey, @c_Priority, @c_UOM,
            @c_UCCNo   --ML01
      END -- While CUR1
      CLOSE CUR1
      DEALLOCATE CUR1

 --   d Insert Replenishment
      IF @n_continue = 3  -- Error Occured - Process And Return
      BEGIN
         SELECT   @b_success = 0
         IF @@TRANCOUNT = 1 AND
            @@TRANCOUNT > @n_starttcnt
            BEGIN
               ROLLBACK TRAN
            END
         ELSE
            BEGIN
               WHILE @@TRANCOUNT > @n_starttcnt
               BEGIN
                  COMMIT TRAN
               END
            END
         EXECUTE nsp_logerror @n_err, @c_errmsg,
            'nsp_ReplenishmentRpt_Alloc'
         --RAISERROR @n_err @c_errmsg
         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
         RETURN
      END
      ELSE
      BEGIN
         SELECT   @b_success = 1
         WHILE @@TRANCOUNT > @n_starttcnt
            BEGIN
               COMMIT TRAN
            END
      END
   END --Continue end
END --SP end
