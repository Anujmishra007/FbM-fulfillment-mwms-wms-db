SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: mspSkuRPL01                                           */
/* Creation Date:  27-Feb-2026                                             */
/* Copyright: Maersk                                                       */
/* Written by:Supriya S                                                    */
/*                                                                         */
/* Purpose: This Stored procedure include Replenishment logic and          */
/*        : Task creation as well as Replenishment record generation       */
/*                                                                         */
/* Called By:  msp_BEJ_AutoInventoryReplenishment (Scheduler Job)          */
/*                                                                         */
/* PVCS Version:                                                           */
/*                                                                         */
/* Version: MWMS V2                                                        */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date        Author   Ver   Purposes                                     */
/* 10-Feb-2026 SSA01    1.0   Create UWP-47046                             */
/***************************************************************************/
CREATE OR ALTER   PROC [dbo].[mspSKURPL01]
   @c_Storerkey  NVARCHAR(15)   = '',
   @c_Facility   NVARCHAR(5)    = '',
   @c_PickLocType  NVARCHAR(15),
   @c_DynamicPickLocType  NVARCHAR(15),
   @c_ReplGroup  NVARCHAR(15),
   @b_Success    INT OUTPUT,
   @n_Err        INT OUTPUT,
   @c_ErrMsg     NVARCHAR(255) OUTPUT,
   @b_Debug      INT = 0
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt          INT            = @@TRANCOUNT
      , @n_Continue              INT            = 1
      , @c_ReplenishmentKey      NVARCHAR(10)   = ''
      , @c_FromLOC                    NVARCHAR(10)
      , @c_FromLot                    NVARCHAR(10)
      , @c_FromId                     NVARCHAR(18)
      , @n_QtyAvailable               INT
      , @c_Packkey            NVARCHAR(10)
      , @c_UOM                NVARCHAR(10)
      , @c_prevFromLOC NVARCHAR(10) = ''
      , @n_Qty               INT = 0
	 ,  @n_QtyToReplen INT = 0
	 , @c_Sku              NVARCHAR(20) = ''
     , @n_Min          INT
     , @n_Max         INT
     , @c_Loc     NVARCHAR(10) = ''
	 , @c_Priority NVARCHAR(1) = ''
	 , @c_Type NVARCHAR(10) = ''
	 , @c_DynamicPickLoc NVARCHAR(10) = ''


   WHILE @@TRANCOUNT > 0
   BEGIN
     COMMIT TRAN
   END

   BEGIN TRAN

     /* Open Orders to update priority to tasks*/
       IF @n_Continue=1 OR @n_Continue=2
       BEGIN
           IF OBJECT_ID('tempdb..#skuQtyVivo','u') IS NOT NULL
           BEGIN
             DROP TABLE #skuQtyVivo;
           END

           CREATE TABLE #skuQtyVivo
           (
             Sku            NVARCHAR(20)   NOT NULL DEFAULT('')
           , Qty       INT            NOT NULL DEFAULT(0)
           , Loc      NVARCHAR(10)   NOT NULL DEFAULT('')
           , Min          int NOT NULL DEFAULT(0)
           , Max          int NOT NULL DEFAULT(0)
           , QtyAvailable int NOT NULL DEFAULT(0)
           , QtyToReplen int NOT NULL DEFAULT(0)
           , Priority int NOT NULL DEFAULT(0)
           , Type  NVARCHAR(10)   NOT NULL DEFAULT('')
          )

          INSERT INTO #skuQtyVivo
          SELECT od.sku, sum(od.openQty), ISNULL(sl.Loc,''),
            MIN(ISNULL(sl.QtyLocationMinimum,0)) AS min,
            MAX(ISNULL(sl.QtyLocationLimit,0)) AS max
            ,0,0,0,ISNULL(sl.LocationType,'')
          FROM ORDERS o WITH (NOLOCK)
          JOIN ORDERDETAIL od WITH (NOLOCK) on od.OrderKey = o.Orderkey
          LEFT JOIN SKUxLOC sl WITH (NOLOCK) ON sl.StorerKey = o.StorerKey
            AND sl.SKU = od.SKU
            AND sl.LocationType = @c_PickLocType
          WHERE o.StorerKey = @c_StorerKey
          AND o.Facility = @c_Facility
          AND o.Status = '0'
          GROUP BY od.sku,sl.Loc,sl.QtyLocationMinimum,sl.QtyLocationLimit,sl.LocationType
          HAVING sum(od.openqty) > 0
          ORDER BY od.sku

          update sQty set QtyAvailable =  ISNULL(li.avaialbleQty, 0),Priority = '9' ,Type=@c_PickLocType
		  from #skuQtyVivo sQty
          LEFT JOIN (SELECT ISNULL(SUM(LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen),0) as avaialbleQty, Loc.loc as loc, LLI.sku as sku
                       FROM LOTxLOCxID LLI (NOLOCK)
                       JOIN LOC (NOLOCK) ON (LLI.Loc = LOC.LOC)
                       JOIN ID (NOLOCK) ON (LLI.Id = ID.ID)
                       JOIN LOT (NOLOCK) ON (LLI.LOT = LOT.LOT)
                       JOIN LOTATTRIBUTE LA (NOLOCK) ON LOT.LOT = LA.LOT
                       WHERE LOC.LocationFlag = 'NONE'
                       AND LOC.Status = 'OK'
                       AND LOT.Status = 'OK'
                       AND ID.Status = 'OK'
                       AND LOC.Facility = @c_Facility
                       AND (LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen) > 0
                       AND LLI.STORERKEY =  @c_StorerKey
                       AND LOC.LocationType =  @c_PickLocType
                       GROUP BY Loc.Loc, LLI.sku) li ON sQty.sku = li.sku
					   WHERE sQty.Loc = li.loc


          update sQty set QtyAvailable =  ISNULL(li.avaialbleQty, 0),Priority = '7' ,Type=@c_DynamicPickLocType
		  from #skuQtyVivo sQty
          LEFT JOIN (SELECT ISNULL(SUM(LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen),0) as avaialbleQty, LLI.sku as sku
                       FROM LOTxLOCxID LLI (NOLOCK)
                       JOIN LOC (NOLOCK) ON (LLI.Loc = LOC.LOC)
                       JOIN ID (NOLOCK) ON (LLI.Id = ID.ID)
                       JOIN LOT (NOLOCK) ON (LLI.LOT = LOT.LOT)
                       JOIN LOTATTRIBUTE LA (NOLOCK) ON LOT.LOT = LA.LOT
                       WHERE LOC.LocationFlag = 'NONE'
                       AND LOC.Status = 'OK'
                       AND LOT.Status = 'OK'
                       AND ID.Status = 'OK'
                       AND LOC.Facility = @c_Facility
                       AND (LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen) > 0
                       AND LLI.STORERKEY =  @c_StorerKey
                       AND LOC.LocationType =  @c_DynamicPickLocType
                       GROUP BY LLI.sku) li ON sQty.sku = li.sku
					   WHERE ISNULL(sQty.Loc,'') = '';



		    Update sQty set QtyToReplen = Max-sQty.QtyAvailable  from #skuQtyVivo sQty
        WHERE  sQty.QtyAvailable < sQty.Qty AND sQty.QtyAvailable > Min AND sQty.Priority = '9'

        Update sQty set sQty.Priority = 5 from #skuQtyVivo sQty
        WHERE  sQty.QtyAvailable < sQty.Qty AND sQty.QtyAvailable < Min AND sQty.Loc <> ''

        Update sQty set QtyToReplen = sQty.Qty-sQty.QtyAvailable from #skuQtyVivo sQty
        WHERE sQty.Loc = '' AND sQty.QtyAvailable < sQty.Qty AND sQty.Priority = '7'

        DELETE s
        FROM #skuQtyVivo s
        WHERE EXISTS (
            SELECT 1
            FROM (
                SELECT t.Sku, SUM(t.Qty) AS TotalQty
                FROM TaskDetail t WITH (NOLOCK)
                WHERE StorerKey = @c_StorerKey
                      AND TaskType = 'RPF'
                      AND Status IN ('Q', '0', '1', '3')
                GROUP BY t.Sku
            ) agg
            WHERE agg.Sku = s.Sku
             AND agg.TotalQty >= s.QtyToReplen
        )

       IF OBJECT_ID('tempdb..#replenVivo','u') IS NOT NULL
           BEGIN
             DROP TABLE #replenVivo;
           END

           CREATE TABLE #replenVivo
           (
             Sku            NVARCHAR(20)   NOT NULL DEFAULT('')
           , fromLoc      NVARCHAR (20)          NOT NULL DEFAULT('')
           , Loc      NVARCHAR(10)   NOT NULL DEFAULT('')
           , fromId          NVARCHAR(18) NOT NULL DEFAULT('')
           , fromLot   NVARCHAR(10) NOT NULL DEFAULT('')
           , Qty          int NOT NULL DEFAULT(0)
           , UOM NVARCHAR(10) NOT NULL DEFAULT('')
           , PackKey NVARCHAR(20) NOT NULL DEFAULT('')
           , Priority int NOT NULL DEFAULT(0)
           , Status NVARCHAR(10) NOT NULL DEFAULT('')
          )


	  DECLARE CUR_OPEN_ORDERS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
       SELECT  Sku, Qty, Loc, Min, Max, QtyAvailable, QtyToReplen , Priority
           , Type  FROM #skuQtyVivo sqt where sqt.Priority <> '5'

       OPEN CUR_OPEN_ORDERS

       FETCH NEXT FROM CUR_OPEN_ORDERS INTO @c_Sku, @n_Qty, @c_Loc, @n_Min, @n_Max,@n_QtyAvailable, @n_QtyToReplen, @c_Priority, @c_Type

       WHILE @@FETCH_STATUS <> -1
       BEGIN

              IF ISNULL(@c_Loc,'') = ''
              BEGIN
                  SELECT TOP 1 @c_DynamicPickLoc = LOC from LOC WITH (NOLOCK)
                   WHERE LOC.LocationFlag = 'NONE'
                   AND LOC.Status = 'OK'
                   AND LOC.Facility = @c_Facility
                   AND LOC.LocationType = @c_DynamicPickLocType
                   AND NOT EXISTS (SELECT 1 FROM #replenVivo WHERE loc = LOC.LOC )
                   GROUP BY LOC.LOC
                   ORDER BY LOC.LOC

                  IF EXISTS(SELECT 1 FROM LOTxLOCxID LLI (NOLOCK)
                       WHERE LLI.STORERKEY =  @c_StorerKey
                       AND LLI.Loc = @c_DynamicPickLoc
                      )
                  BEGIN
                     IF EXISTS (SELECT 1 FROM LOTxLOCxID LLI (NOLOCK)
                       JOIN LOC (NOLOCK) ON (LLI.Loc = LOC.LOC)
                       JOIN ID (NOLOCK) ON (LLI.Id = ID.ID)
                       JOIN LOT (NOLOCK) ON (LLI.LOT = LOT.LOT)
                       JOIN LOTATTRIBUTE LA (NOLOCK) ON LOT.LOT = LA.LOT
                       WHERE LOC.LocationFlag = 'NONE'
                       AND LOC.Status = 'OK'
                       AND LOT.Status = 'OK'
                       AND ID.Status = 'OK'
                       AND LOC.Facility = @c_Facility
                       AND (LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen) = 0
                       AND LLI.STORERKEY =  @c_StorerKey
                       AND LLI.Loc = @c_DynamicPickLoc
                       AND LOC.LocationType = @c_DynamicPickLocType
                       GROUP BY LLI.Storerkey, LLI.sku)
                       BEGIN
                        SET @c_Loc = @c_DynamicPickLoc
                       END
                       ELSE
                        BEGIN
                          SET @c_Loc = ''
                        END
                    END
                    ELSE
                    BEGIN
                      SET @c_Loc = @c_DynamicPickLoc
                    END
                      IF(ISNULL(@c_Loc,'') = '' )
                      BEGIN
                        SET @n_QtyToReplen = 0
                      END
                      ELSE
                      BEGIN
                      UPDATE sqt set Loc = @c_Loc from #skuQtyVivo sqt where sqt.Sku = @c_Sku and sqt.Loc = ''
                      END
            END

          WHILE @n_QtyToReplen > 0
          BEGIN
                  SELECT Top 1 @c_FromLOC = LLI.LOC,
                                  @c_FromID = LLI.ID,
                                  @c_FromLot = LLI.Lot
                         FROM     dbo.LOTxLOCxID LLI (NOLOCK)
                         JOIN dbo.LOC LOC WITH (NOLOCK) ON LLI.LOC = LOC.Loc
                         JOIN dbo.ID ID WITH (NOLOCK) ON LLI.ID = ID.Id
                         JOIN dbo.SKUxLOC SL WITH (nolock) ON SL.StorerKey = LLI.StorerKey AND
                            SL.SKU = LLI.SKU AND SL.LOC = LLI.LOC
                         WHERE LOC.LocationFlag NOT IN ('DAMAGE', 'HOLD') AND
                                  LOC.Facility = @c_Facility AND
                                  LOC.Status = 'OK' AND
                                  ID.Status = 'OK' AND
                                  LOC.LocationCategory <> 'shelving' AND
                                  (LOC.Locationtype = 'BULK' OR LOC.LocationType = 'PICK') AND
                                  (LLI.QTY - LLI.QTYPICKED - LLI.QTYALLOCATED) > 0
                                  AND LLI.STORERKEY =  @c_StorerKey
                                  AND LLI.Sku = @c_Sku
                                  AND NOT EXISTS (SELECT 1 FROM #replenVivo WHERE Sku = @c_Sku AND fromLoc = LLI.LOC)

                         ORDER BY
                          CASE WHEN LOC.LocationCategory <> 'shelving' THEN 0 ELSE 1 END,
                          CASE WHEN LOC.LocationType = 'PICK' THEN 0 ELSE 1 END,
                          CASE WHEN LOC.LocationType = 'BULK' THEN 0 ELSE 1 END,
                         LLI.QTY - LLI.QTYPICKED - LLI.QTYALLOCATED

                  SELECT @n_QtyAvailable = SUM(LLI.QTY - LLI.QTYPICKED - LLI.QTYALLOCATED)
                         FROM  dbo.LOTxLOCxID LLI (NOLOCK)
                         JOIN dbo.LOC LOC WITH (NOLOCK) ON LLI.LOC = LOC.Loc
                         JOIN dbo.ID ID WITH (NOLOCK) ON LLI.ID = ID.Id
                         JOIN dbo.SKUxLOC SL WITH (nolock) ON SL.StorerKey = LLI.StorerKey AND
                            SL.SKU = LLI.SKU AND SL.LOC = LLI.LOC
                         WHERE LOC.LocationFlag NOT IN ('DAMAGE', 'HOLD') AND
                                  LOC.Facility = @c_Facility AND
                                  LOC.Status = 'OK' AND
                                  ID.Status = 'OK' AND
                                  LOC.LocationCategory <> 'shelving' AND
                                  (LOC.Locationtype = 'BULK' OR LOC.LocationType = 'PICK') AND
                                  (LLI.QTY - LLI.QTYPICKED - LLI.QTYALLOCATED) > 0
                                  AND LLI.STORERKEY =  @c_StorerKey
                                  AND LLI.Sku = @c_Sku
                                  AND LOC.loc = ISNULL(@c_FromLoc,'')


                  IF @n_QtyAvailable > 0 AND NOT EXISTS (SELECT 1 FROM #replenVivo WHERE Sku = @c_Sku AND fromLoc = @c_FromLoc)
                  BEGIN
                  SET @n_Qty = CASE WHEN @n_QtyAvailable >= @n_QtyToReplen THEN @n_QtyToReplen ELSE @n_QtyAvailable END
                   insert into #replenVivo (Sku, fromLoc, Loc, fromId, fromLot, Qty, UOM, PackKey,Priority)
                    SELECT sQty.Sku,  @c_FromLOC, sQty.Loc, @c_FromID, @c_FromLot, @n_Qty, '', '',@c_Priority
                    FROM #skuQtyVivo sQty
                    WHERE sQty.Sku = @c_Sku AND sQty.priority <> '5'

                     SET @n_QtyToReplen =  @n_QtyToReplen - @n_Qty
                  END
                  ELSE
                   BEGIN
                    -- No available inventory found for replenishment, break the loop to avoid infinite loop
                    BREAK
                 END


        END
          FETCH NEXT FROM CUR_OPEN_ORDERS INTO  @c_Sku, @n_Qty, @c_Loc, @n_Min, @n_Max, @n_QtyAvailable,  @n_QtyToReplen, @c_Priority, @c_Type
       END
       CLOSE CUR_OPEN_ORDERS
       DEALLOCATE CUR_OPEN_ORDERS

      UPDATE rpl set UOM = PACK.PackUOM3, PackKey = PACK.PackKey from #replenVivo rpl
      JOIN SKU WITH (NOLOCK) ON rpl.Sku = SKU.SKU AND SKU.StorerKey = @c_StorerKey
      JOIN PACK WITH (NOLOCK) ON SKU.PackKey = PACK.PackKey
    END


   IF @n_continue = 1
   BEGIN
      -- Do not execute it Replenishment Task not done yet
               UPDATE r
                SET r.Status = 'ELIGIBLE' -- or any column you want to update
                FROM #replenVivo r
                WHERE NOT EXISTS (
                    SELECT 1
                    FROM TaskDetail WITH (NOLOCK)
                    WHERE Sku = r.Sku
                      AND ToLoc = r.Loc
                      AND StorerKey = @c_StorerKey
                      AND TaskType = 'RPF'
                      AND Status IN ('Q', '0', '1', '3')
                )
                AND NOT EXISTS (
                    SELECT 1
                    FROM Replenishment RP WITH (NOLOCK)
                    WHERE RP.Sku = r.Sku
                      AND RP.ToLoc = r.Loc
                      AND RP.StorerKey = @c_StorerKey
                      AND RP.Confirmed = 'N'
                );

    /* Insert Into Replenishment Table Now */

        DECLARE CUR_REPLENISH CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
        SELECT  Sku, fromLoc, Loc, fromId, fromLot, Qty,UOM,PackKey,priority FROM #replenVivo
        WHERE Status = 'ELIGIBLE'

        OPEN CUR_REPLENISH

       FETCH NEXT FROM CUR_REPLENISH INTO @c_Sku,@c_FromLOC , @c_Loc, @c_FromId,@c_FromLot,@n_Qty, @c_UOM, @c_PackKey,@c_Priority

       WHILE @@FETCH_STATUS <> -1
       BEGIN
        -- Generate a new replenishment group
        EXECUTE nspg_GetKey
                @keyname       = 'REPLENISHGROUP',
                @fieldlength   = 10,
                @keystring     = @c_ReplGroup OUTPUT,
                @b_success     = @b_success OUTPUT,
                @n_err         = @n_err OUTPUT,
                @c_errmsg      = @c_errmsg OUTPUT

       EXECUTE nspg_GetKey
                  'REPLENISHKEY'
               ,  10
               ,  @c_ReplenishmentKey OUTPUT
               ,  @b_success          OUTPUT
               ,  @n_err              OUTPUT
               ,  @c_errmsg           OUTPUT

          INSERT INTO REPLENISHMENT (Replenishmentgroup
                   , ReplenishmentKey,StorerKey, Sku, FromLoc, Id, Lot, ToLoc, Qty, UOM, PackKey, Confirmed)
          VALUES (@c_ReplGroup,@c_ReplenishmentKey,@c_StorerKey, @c_Sku, @c_FromLoc, @c_FromId, @c_FromLot, @c_Loc, @n_Qty, @c_UOM, @c_PackKey,'N')

          EXEC isp_InsertTaskDetail
              @c_TaskType              = 'RPF'
             ,@c_Storerkey             = @c_Storerkey
             ,@c_Sku                   = @c_Sku
             ,@c_Lot                   = @c_FromLot
             ,@c_UOM                   = @c_UOM
             ,@n_UOMQty                = @n_Qty
             ,@n_Qty                   = @n_Qty
             ,@c_FromLoc               = @c_Fromloc
             ,@c_FromID                = @c_FromId
             ,@c_ToLoc                 = @c_Loc
             ,@c_ToID                  = @c_FromId
             ,@c_PickMethod            = '?TASKQTY' --?TASKQTY=(Qty available - taskqty)
             ,@c_Priority              = @c_Priority
             ,@c_SourcePriority        = @c_Priority
             ,@c_SourceType            = 'mspSKURPL01'
             ,@c_SourceKey             = @c_Replenishmentkey
             ,@c_AreaKey               = '?F'  -- ?F=Get from location areakey
             ,@c_Groupkey              = @c_ReplGroup
             ,@c_CallSource            = 'REPLENISHMENT'
             ,@n_QtyReplen             = @n_Qty
             ,@n_PendingMoveIn         = @n_Qty
             ,@c_LinkTaskToReplen      = 'Y'
			       ,@c_ZeroSystemQty         = 'Y'
             ,@b_Success               = @b_Success OUTPUT
             ,@n_Err                   = @n_err OUTPUT
             ,@c_ErrMsg                = @c_errmsg OUTPUT
             IF @b_Success <> 1
          BEGIN
               SELECT @n_continue = 3
               SELECT @c_ErrMsg = CONVERT(CHAR(250) ,@n_err),@n_err = 62082
               SELECT @c_ErrMsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err)+
                        ': Insert Into TaskDetail Failed (mspSKURPL01)'
                     +' ( '+' SQLSvr MESSAGE='+ TRIM(@c_ErrMsg) +' ) '
          END

          FETCH NEXT FROM CUR_REPLENISH INTO  @c_Sku,@c_FromLOC , @c_Loc, @c_FromId,@c_FromLot,@n_Qty, @c_UOM, @c_PackKey,@c_Priority
       END
       CLOSE CUR_REPLENISH
       DEALLOCATE CUR_REPLENISH
    END
-- End Insert Replenishment
  -- start updating priority for open tasks
  IF(@n_Continue = 1 OR @n_Continue = 2)
  BEGIN
            BEGIN TRY
            UPDATE TD
            SET TD.Priority = '5',TD.SourcePriority = '5'
            FROM TASKDETAIL TD WITH (ROWLOCK)
            JOIN #skuQtyVivo sqv ON
                TD.Sku = sqv.Sku AND
                TD.ToLoc = sqv.Loc AND
                TD.StorerKey = @c_StorerKey
            WHERE
                sqv.Priority =  '9' AND
                TD.TaskType = 'RPF' AND
                TD.Status NOT IN ('X','9') AND
                TD.SourcePriority = '9'
        END TRY
        BEGIN CATCH
            SELECT @n_continue = 3
            SET @c_ErrMsg = ERROR_MESSAGE()
            SET @n_err = 550159
            SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(6), @n_err)  + '(' + @c_errmsg + '): Update on TaskDetail Failed. (mspSKURPL01)'
            EXECUTE nsp_logerror @n_err, @c_errmsg, 'mspSKURPL01'
        END CATCH
    END

QUIT_SP:

   IF @n_continue = 3
   BEGIN
    IF @@TRANCOUNT > 0
      BEGIN
        ROLLBACK TRAN
    END
    RAISERROR (@c_errmsg, 16, 1) WITH SETERROR
   END
   ELSE
   BEGIN
    WHILE @@TRANCOUNT > 0
      BEGIN
        COMMIT TRAN
    END
   END

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
END
GO
