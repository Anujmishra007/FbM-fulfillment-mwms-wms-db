SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store Procedure:  isp_DynamicReplenishment_Granite                   */
/* Creation Date:  25-June-2024                                         */
/* Copyright: Maersk WMS                                                */
/* Written by:  USH022                                                  */
/* JIRA TICKET: UWP-20446                                               */
/* Purpose:  Dynamic Replenishment for order                            */
/*                                                                      */
/* Input Parameters:                                                    */
/*  @c_WaveKey                                                          */
/*  @c_StorerKey                                                        */
/*  @c_Facility                                                         */
/*  @c_Uom                                                              */
/*  @c_PickMethod                                                       */
/*  @c_LocationType                                                     */
/*                                                                      */
/* Output Parameters:  None                                             */
/*                                                                      */
/* Return Status:  None                                                 */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* PVCS Version: 1.3                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date             Author      Ver         Purposes                    */
/* YYYY-DD-MM       {author}    {ver}       Close Cursor                */
/* 2024-07-16        USH022      V.0        Dynamic Replenishment       */
/************************************************************************/
 CREATE OR ALTER PROCEDURE [dbo].[isp_DynamicReplenishment_Granite]
    @c_WaveKey       NVARCHAR(10),
    @b_Success int OUTPUT,
    @n_err     int OUTPUT,
    @c_errmsg  NVARCHAR(250) OUTPUT,
    @c_Code       NVARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON
    -- SQL 2005 Standard
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE
    @c_StorerKey     NVARCHAR(10),
    @c_Facility          NVARCHAR(20),
    @c_LocationType      NVARCHAR(10),
    @c_PickMethod        NVARCHAR(10),
    @c_Sku               NVARCHAR(20),
    @c_Lot               NVARCHAR( 10),
    @c_Id                NVARCHAR( 18),
    @c_UomQty            NVARCHAR( 10),
    @c_DropId            NVARCHAR(20),
    @c_MoveRefKey        NVARCHAR(10),
    @n_continue          INT,
    @c_PickFaceLocation  NVARCHAR(50),
    @c_DynamicPickFaceLocation NVARCHAR(50),
    @n_MinQty           INT,
    @n_MaxQty           INT,
    @n_StartTranCnt     INT,
    @c_ReplenishmentKey NVARCHAR(50),
    @c_UCCNo            NVARCHAR(20),
    @c_PickDetailKey    NVARCHAR(18),
    @c_Loc              NVARCHAR(10),
    @c_PutawayZone      NVARCHAR(10),
    @c_UOM              NVARCHAR(10),
    @c_OrderKey         NVARCHAR(10),
    @n_UCCQty           INT,
    @c_FromLoc          NVARCHAR(50),
    @c_ToLoc            NVARCHAR(50),
    @n_UCC_RowRef       INT,
    @n_qtytoReplen      INT ,
	@c_successFlag		NVARCHAR(1)

    -- Error check for WaveKey existence
    IF NOT EXISTS(SELECT 1 FROM WaveDetail WITH (NOLOCK) WHERE WaveKey = @c_WaveKey)
    BEGIN
        SELECT @n_continue = 3;
        SELECT @n_err = 63501;
        SELECT @c_errmsg='NSQL' + CONVERT(char(5), @n_err) + ': No Orders being populated into WaveDetail. (isp_DynamicReplenishment)';
        GOTO RETURN_SP;
    END;

    -- Begin Transaction
    SET @n_StartTranCnt = @@TRANCOUNT;
	SET @n_continue = 1;
	SET @c_successFlag = 'N';
	BEGIN TRAN;
    SELECT TOP 1 @c_StorerKey = o.StorerKey, @c_Facility = o.Facility FROM ORDERS o (NOLOCK) WHERE o.OrderKey IN (
    select wd.OrderKey from WAVEdetail wd (nolock) where wavekey in (@c_WaveKey))

    IF EXISTS( SELECT 1
               FROM PICKDETAIL PD (NOLOCK)
               JOIN WAVEDETAIL WD (NOLOCK) ON pd.Orderkey = wd.orderkey
               JOIN SkuxLoc sl WITH (NOLOCK) on  sl.Storerkey = pd.StorerKey
                                                        and sl.Sku = pd.sku
                                                        AND sl.Locationtype = 'PICK'
               JOIN Loc l (NOLOCK) ON sl.loc = l.loc AND l.Facility = @c_Facility
               WHERE wd.WaveKey = @c_WaveKey
               AND l.loc IS NULL)
    BEGIN
        SELECT @n_continue = 3
        SELECT @n_err = 63501
        SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Pick Face Not Setup. (isp_DynamicReplenishment)'
        GOTO RETURN_SP;
    END

    IF @n_continue = 1 OR @n_continue = 2
    BEGIN

        DECLARE cur_repleinshment CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
        SELECT PD.StorerKey, PD.Sku, PD.Lot, PD.ID,  PD.DropID,  PD.Loc ,  loc.PutawayZone FROM PickDetail PD (NOLOCK)
            JOIN LOC loc WITH (NOLOCK) ON (PD.loc = loc.loc)
        WHERE
        PD.WaveKey = @c_WaveKey
            AND PD.UOM = '6'
            AND loc.LocationType = 'CASE'
            AND PD.STATUS = '0'
        AND NOT EXISTS (SELECT 1 FROM Replenishment r(NOLOCK)
                        WHERE r.ReplenishmentGroup = loc.PutawayZone
                        AND  r.DropID = pd.DropID
                        AND  r.Confirmed = 'N'
                        AND  r.Wavekey = @c_Wavekey
                        )
        GROUP BY PD.StorerKey, PD.Sku, PD.Lot, PD.ID,  PD.DropID,  PD.Loc, loc.PutawayZone
        ORDER BY PD.StorerKey, PD.Sku, PD.Loc
        OPEN cur_repleinshment
        FETCH NEXT FROM cur_repleinshment INTO @c_StorerKey, @c_Sku, @c_Lot, @c_Id, @c_DropId, @c_FromLoc, @c_PutawayZone
        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE @n_ReplenQty INT;
            SELECT Top 1
               @n_ReplenQty = UCC.Qty
            FROM UCC WITH (NOLOCK)
            WHERE UCC.UCCno = @c_DropId
            AND UCC.Storerkey = @c_Storerkey
            SET @n_UCCQty = @n_ReplenQty;
            SET @c_ToLoc = ''
            -- 1. Find Pick Face
            SELECT TOP 1 @c_ToLoc = loc.Loc
            FROM LOC loc (NOLOCK)
            JOIN dbo.SKUXLOC sl (NOLOCK) ON loc.loc = sl.loc
            JOIN LOTxLOCxID lli (NOLOCK) ON sl.storerkey = lli.storerkey
                                        AND sl.sku = lli.sku
                                        AND sl.loc = lli.loc
            WHERE lli.SKU = @c_Sku
            AND lli.StorerKey = @c_StorerKey
            AND sl.LocationType = 'PICK'
            AND loc.Facility = @c_Facility
            GROUP BY loc.Loc, loc.LogicalLocation, sl.QtyLocationLimit
--HAVING SUM(lli.Qty - lli.QtyPicked + lli.QtyAllocated + lli.PendingMoveIn) + @n_UCCQty <= sl.QtyLocationLimit
            HAVING SUM(lli.Qty - lli.QtyPicked + lli.PendingMoveIn) + @n_UCCQty <= sl.QtyLocationLimit
            ORDER BY loc.LogicalLocation
            -- Find Same Friend in DP loc can fit in
            IF @c_ToLoc = ''
            BEGIN
               SELECT TOP 1 @c_Loc = loc.Loc
               FROM LOTxLOCxID lli (NOLOCK)
               JOIN LOC loc (NOLOCK) ON loc.loc = lli.loc
               WHERE lli.SKU = @c_Sku
               AND lli.StorerKey = @c_StorerKey
               AND loc.LocationType = 'DYNPICKP'
               AND loc.Facility = @c_Facility
               AND  loc.MaxCarton > 0
               GROUP BY loc.Loc, loc.MaxCarton, loc.LogicalLocation
               HAVING (CEILING(SUM(lli.Qty - lli.QtyPicked + lli.PendingMoveIn)/@n_UCCQty) <= LOC.MaxCarton)
               ORDER BY loc.LogicalLocation
            END
            -- Find Empty in DP loc can fit in
            IF @c_ToLoc = ''
            BEGIN
               SELECT TOP 1 @c_ToLoc = loc.Loc
               FROM LOC loc (NOLOCK)
               LEFT OUTER JOIN LOTxLOCxID lli (NOLOCK)  ON  loc.loc = lli.loc
                                                         AND lli.StorerKey = @c_StorerKey
               WHERE loc.LocationType = 'DYNPICKP'
               AND  loc.Facility = @c_Facility
               AND  loc.MaxCarton > 0
               GROUP BY loc.Loc, loc.LogicalLocation
               HAVING (SUM(ISNULL(lli.Qty,0) - ISNULL(lli.QtyPicked,0) + ISNULL(lli.PendingMoveIn,0)) = 0)
               ORDER BY loc.LogicalLocation
            END
            IF @c_ToLoc = ''
            BEGIN
               SELECT @n_continue = 3
               SELECT @n_err = 63501
               SELECT @c_errmsg='No empty dynamic/pick face location available for SKU. (isp_DynamicReplenishment)'
               GOTO RETURN_SP;
            END
            -- REPLNISHMENT START
            -- generate REPLENISHKEY key and holding into @c_ReplenishmentKey variable
            EXECUTE dbo.nspg_GetKey 'REPLENISHKEY', 10,
            @keystring     = @c_ReplenishmentKey OUTPUT,
            @b_Success     = @b_success          OUTPUT,
            @n_err         = @n_err              OUTPUT,
            @c_errmsg      = @c_errmsg           OUTPUT

            --Generating the MoveRefKey
            EXECUTE nspg_getkey
            @KeyName       ='MoveRefKey'
            ,@fieldlength   = 10
            ,@keystring     = @c_MoveRefKey       OUTPUT
            ,@b_Success     = @b_success          OUTPUT
            ,@n_err         = @n_err              OUTPUT
            ,@c_errmsg      = @c_errmsg           OUTPUT

            INSERT INTO Replenishment
            (ReplenishmentKey, ReplenishmentGroup, StorerKey, Sku, Lot, FromLoc, toloc, Id, Qty, UOM, DropId, Wavekey, MoveRefkey, QtyReplen, pendingmovein)
            VALUES
            (@c_ReplenishmentKey, @c_PutawayZone, @c_StorerKey, @c_Sku, @c_Lot, @c_FromLoc, @c_Toloc, @c_Id, @n_ReplenQty, @c_UOM, @c_DropId, @c_Wavekey, @c_MoveRefkey,@n_ReplenQty,@n_ReplenQty);

            IF @@ERROR <> 0
            BEGIN
               SET @n_continue  = 3
               SET  @c_ErrMsg =  'Replenishement data inserting failed'
               GOTO RETURN_SP;
            END
            -- CURSOR TO UPDATE MoveRef Key
            DECLARE updateMoveRefKeyCursor CURSOR FOR
            SELECT PickDetailKey
            FROM PICKDETAIL (NOLOCK) PD
            WHERE PD.Storerkey = @c_StorerKey AND DropID = @c_DropId
            AND PD.WaveKey = @c_WaveKey AND PD.status = '0';
            OPEN updateMoveRefKeyCursor;
            FETCH NEXT FROM updateMoveRefKeyCursor INTO @c_PickDetailKey
            WHILE @@FETCH_STATUS = 0
            BEGIN
               UPDATE PICKDETAIL WITH (ROWLOCK) SET MoveRefKey = @c_MoveRefKey
               ,trafficcop = null
               where PickDetailKey = @c_PickDetailKey;
				FETCH NEXT FROM updateMoveRefKeyCursor INTO @c_PickDetailKey;
            END;
            CLOSE updateMoveRefKeyCursor;
            DEALLOCATE updateMoveRefKeyCursor;
			SELECT @c_successFlag = 'Y';
        FETCH NEXT FROM cur_repleinshment INTO @c_StorerKey, @c_Sku, @c_Lot, @c_Id, @c_DropId, @c_FromLoc, @c_PutawayZone
        END
        CLOSE cur_repleinshment;
        DEALLOCATE cur_repleinshment;

		SELECT @c_successFlag = 'N';
       --Proactive Replenshment Scenario
        DECLARE proactive_cur CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT sl.StorerKey, sl.SKU, sl.Loc, sl.QtyLocationMinimum,  sl.QtyLocationLimit
                , QtyToRepl = sl.QtyLocationLimit - SUM(lli.Qty - lli.QtyPicked + lli.PendingMoveIN)
        FROM SKUxLoc sl (NOLOCK)
        JOIN LOTXLOCXID lli (NOLOCK)
            ON sl.StorerKey = lli.StorerKey AND sl.SKU = lli.SKU AND sl.LOC= lli.LOC
        JOIN LOC l (NOLOCK) ON lli.Loc = l.loc
        WHERE sl.LocationType = 'PICK'
            AND sl.StorerKey = @c_StorerKey
            AND l.Facility = @c_Facility
        GROUP BY sl.StorerKey, sl.SKU, sl.LOC, sl.QtyLocationMinimum, sl.QtyLocationLimit
        --HAVING SUM(lli.Qty - lli.QtyPicked + lli.QtyAllocated + lli.PendingMoveIN) <= sl.QtyLocationMinimum
        HAVING SUM(lli.Qty - lli.QtyPicked + lli.PendingMoveIN) <= sl.QtyLocationMinimum
        OPEN proactive_cur
        FETCH NEXT FROM proactive_cur INTO @c_Storerkey,@c_SKU, @c_PickFaceLocation, @n_MinQty, @n_MaxQty, @n_qtytoReplen;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Check if there is enough stock in case locations
            SET @c_UCCNo = '';
            DECLARE cur_toCheckEnoughStock CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT
            ucc.UCCNo,
            ucc.UCC_RowRef,
            ucc.Qty
            FROM LOTXLOCXID lli (NOLOCK)
                JOIN UCC ucc (NOLOCK) ON lli.sku = ucc.sku AND lli.StorerKey = ucc.StorerKey
                JOIN SKUXLOC sl (NOLOCK) ON lli.sku = sl.sku AND lli.StorerKey = sl.StorerKey AND sl.sku = ucc.sku
            WHERE
                lli.SKU = @c_SKU AND
                ucc.STATUS = '1' AND -- 1 means available qty
                sl.LocationType = 'CASE' AND
                ucc.Qty <= @n_ReplenQty
                ORDER BY UCC.Qty DESC
            OPEN cur_toCheckEnoughStock;
            FETCH NEXT FROM cur_toCheckEnoughStock INTO @c_UCCNo, @n_UCC_RowRef, @n_ReplenQty;
            WHILE @@FETCH_STATUS = 0 AND @n_qtytoReplen > 0
            BEGIN
                IF @n_ReplenQty > @n_qtytoReplen
                BEGIN
                    BREAK
                END
                IF @c_UCCNo IS NOT NULL
                BEGIN
                    -- REPLINSHMENT START
                    -- generate REPLENISHKEY key and holding into @c_ReplenishmentKey variable
                    EXECUTE dbo.nspg_GetKey 'REPLENISHKEY', 10,
                    @keystring     = @c_ReplenishmentKey OUTPUT,
                    @b_Success     = @b_success          OUTPUT,
                    @n_err         = @n_err              OUTPUT,
                    @c_errmsg      = @c_errmsg           OUTPUT

                    SELECT @c_PutawayZone = loc.PutawayZone
                    FROM LOC (NOLOCK) loc WHERE loc.loc = @c_Loc;
                    --Generating the MoveRefKey
                    EXECUTE nspg_getkey
                    @KeyName       ='MoveRefKey'
                    ,@fieldlength   = 10
                    ,@keystring     = @c_MoveRefKey       OUTPUT
                    ,@b_Success     = @b_success          OUTPUT
                    ,@n_err = @n_err              OUTPUT
                    ,@c_errmsg      = @c_errmsg           OUTPUT

                    INSERT INTO Replenishment
                    (ReplenishmentKey, ReplenishmentGroup, StorerKey, Sku, Lot, Id, Qty, UOM, DropId, Wavekey, MoveRefkey)
                    VALUES
                    (@c_ReplenishmentKey, @c_PutawayZone, @c_StorerKey, @c_Sku, @c_Lot, @c_Id, @n_ReplenQty, @c_UOM, @c_DropId, @c_Wavekey, @c_MoveRefkey);

                    IF @@ERROR <> 0
                    BEGIN
                        SET @n_continue  = 3
                        SET  @c_ErrMsg =  'Replenishement data inserting failed'
                    GOTO RETURN_SP;
                    END
                        -- CURSOR TO UPDATE MoveRef Key
                        DECLARE updateMoveRefKeyCursor CURSOR FOR
                        SELECT PickDetailKey
                        FROM PICKDETAIL (NOLOCK) PD
                        WHERE PD.Storerkey = @c_StorerKey AND DropID = @c_DropId;

                        OPEN updateMoveRefKeyCursor;
                        FETCH NEXT FROM updateMoveRefKeyCursor INTO @c_PickDetailKey
                        WHILE @@FETCH_STATUS = 0
                        BEGIN
                            UPDATE PICKDETAIL SET MoveRefKey = @c_MoveRefKey, TrafficCop = null where PickDetailKey = @c_PickDetailKey;
                            FETCH NEXT FROM updateMoveRefKeyCursor INTO @c_PickDetailKey;
                        END;
                        CLOSE updateMoveRefKeyCursor;
                        DEALLOCATE updateMoveRefKeyCursor;

                        -- UPDATE UCC SATTUS
                        UPDATE UCC WITH (ROWLOCK) SET STATUS = '3' WHERE SKU = @c_Sku AND StorerKey = @c_StorerKey
                        and UCC_RowRef = @n_UCC_RowRef;
                        SET @n_qtytoReplen  = @n_qtytoReplen - @n_ReplenQty
                        -- REPLNISHMENT END
                END
                ELSE
                BEGIN
                    SELECT @n_continue = 3
                    SELECT @n_err = 63501
                    SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Not enough stock in case locations for SKU. (isp_DynamicReplenishment)'
                END

            FETCH NEXT FROM cur_toCheckEnoughStock INTO @c_UCCNo, @n_UCC_RowRef, @n_ReplenQty;
            END
		END
		SELECT @c_successFlag = 'Y';
        FETCH NEXT FROM proactive_cur INTO @c_Storerkey,@c_SKU, @c_PickFaceLocation, @n_MinQty, @n_MaxQty, @n_qtytoReplen;
        END
    END

    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
		IF @c_successFlag = 'Y'
		BEGIN
			SELECT @c_errmsg = 'Replenishment Done'
		END;
    END
	ELSE
	BEGIN
		SELECT @c_errmsg = 'Replenishment not done, Something went wrong in current transaction'
	END

    -- Error handling and commit/rollback
RETURN_SP:
    IF CURSOR_STATUS('LOCAL', 'cur_repleinshment') IN (0, 1)
    BEGIN
        CLOSE cur_repleinshment;
        DEALLOCATE cur_repleinshment;
    END;

    IF CURSOR_STATUS('LOCAL', 'updateMoveRefKeyCursor') IN (0, 1)
    BEGIN
        CLOSE updateMoveRefKeyCursor;
        DEALLOCATE updateMoveRefKeyCursor;
    END;

    IF CURSOR_STATUS('LOCAL', 'cur_toCheckEnoughStock') IN (0, 1)
    BEGIN
        CLOSE cur_toCheckEnoughStock;
        DEALLOCATE cur_toCheckEnoughStock;
    END;

    IF @n_continue = 3  -- Error Occurred - Process And Return
    BEGIN
        SELECT @b_Success = 0;
        IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_StartTranCnt
        BEGIN
            ROLLBACK TRAN;
        END
		ELSE
		BEGIN
			WHILE @@TRANCOUNT > @n_StartTranCnt
			BEGIN
				COMMIT TRAN
			END
		END
		execute nsp_logerror @n_err, @c_errmsg, 'isp_DynamicReplenishment_Granite'
		RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
		RETURN
    END
    ELSE
    BEGIN
        SELECT @b_Success = 1;
        IF @@TRANCOUNT > @n_StartTranCnt
        BEGIN
            COMMIT TRAN;
        END;
        RETURN;
    END;
GO
