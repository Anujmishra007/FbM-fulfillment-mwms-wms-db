SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************/
/* Stored Procedure: ispRLREPVL                                         */
/* Creation Date: 12/07/2017                                            */
/* Copyright: LFL                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: Releases replenishment tasks and updates to loc as required */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Config Change                                  */
/* 02/05/2024   PPA374							                                    */
/* 29/08/2024   PPA374   Assigning replenishment priority based on BRD  */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[ispRLREPVL]
@c_Facility  NVARCHAR(10)='',
@c_zone02    NVARCHAR(10)='',
@c_zone03    NVARCHAR(10)='',
@c_zone04    NVARCHAR(10)='',
@c_zone05    NVARCHAR(10)='',
@c_zone06    NVARCHAR(10)='',
@c_zone07    NVARCHAR(10)='',
@c_zone08    NVARCHAR(10)='',
@c_zone09    NVARCHAR(10)='',
@c_zone10    NVARCHAR(10)='',
@c_zone11    NVARCHAR(10)='',
@c_zone12    NVARCHAR(10)='',
@c_Storerkey NVARCHAR(15)='',
@n_err       INT OUTPUT,
@c_ErrMsg    NVARCHAR(250) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   DECLARE
   @n_continue                INT
   ,@n_starttcnt              INT
   ,@b_Success                INT
   ,@c_SKU                    NVARCHAR(20)
   ,@c_ToLoc                  NVARCHAR(10)
   ,@c_Lot                    NVARCHAR(10)
   ,@c_FromLoc                NVARCHAR(10)
   ,@c_ID                     NVARCHAR(18)
   ,@c_ToID                   NVARCHAR(18)
   ,@n_Qty                    INT
   ,@c_Replenishmentkey       NVARCHAR(10)
   ,@c_ReplenishmentGroup     NVARCHAR(10)
   ,@c_PrevReplenishmentGroup NVARCHAR(10)
   ,@c_ReplenGroupList        NVARCHAR(250)
   ,@c_UOM                    NVARCHAR(10)
   ,@c_Priority               NVARCHAR(10)
   SELECT  @n_starttcnt=@@TRANCOUNT , @n_continue=1, @b_success=0, @n_err=0, @c_errmsg=''
   SELECT @c_PrevReplenishmentGroup = '', @c_ReplenGroupList = ''
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF NOT EXISTS (SELECT 1 FROM dbo.REPLENISHMENT R WITH(NOLOCK)
	  INNER JOIN dbo.LOC WITH(NOLOCK) ON (LOC.Loc = R.ToLoc)
      WHERE (LOC.putawayZone IN (@c_Zone02, @c_Zone03, @c_Zone04, @c_Zone05, @c_Zone06, @c_Zone07, @c_Zone08, @c_Zone09, @c_Zone10, @c_Zone11, @c_Zone12)
      OR @c_Zone02 = 'ALL')
      AND LOC.Facility = 'UK001'
      AND R.Confirmed = 'N'
      AND R.StorerKey = 'HUSQ')
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_ErrMsg = CONVERT(CHAR(250), @n_err), @n_err = 71000
         SELECT @c_ErrMsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err) + ': No replenishment to release.' + ' ( '+' SQLSvr MESSAGE= '+ @c_ErrMsg + ' ) '
      END
   END
   -----Create replenishment task
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      BEGIN TRAN
         DECLARE CUR_REPLENISH CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT R.StorerKey, R.Sku, R.FromLoc, R.Id, R.ToLoc, R.ToID, R.UOM, R.Qty, R.Lot, R.ReplenishmentKey, ISNULL(R.ReplenishmentGroup,''), R.Priority
         FROM dbo.REPLENISHMENT R WITH(NOLOCK)
         INNER JOIN dbo.LOC WITH(NOLOCK) ON (LOC.Loc = R.ToLoc)
         WHERE (LOC.putawayZone IN (@c_Zone02, @c_Zone03, @c_Zone04, @c_Zone05, @c_Zone06, @c_Zone07, @c_Zone08, @c_Zone09, @c_Zone10, @c_Zone11, @c_Zone12)
         OR @c_Zone02 = 'ALL')
         AND LOC.Facility = 'UK001'
         AND R.Confirmed = 'N'
         AND R.StorerKey = 'HUSQ'
         ORDER BY R.ReplenishmentGroup, R.Replenishmentkey
         OPEN CUR_REPLENISH
         FETCH FROM CUR_REPLENISH INTO @c_Storerkey, @c_Sku, @c_FromLoc, @c_ID, @c_ToLoc, @c_ToID, @c_UOM, @n_Qty, @c_Lot, @c_Replenishmentkey, @c_ReplenishmentGroup, @c_Priority
         WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2)
         BEGIN
            IF (@c_ReplenishmentGroup <> @c_PrevReplenishmentGroup) AND ISNULL(@c_ReplenishmentGroup,'') <> ''
            BEGIN
               SET @c_ReplenGroupList = RTRIM(@c_ReplenGroupList) + RTRIM(@c_ReplenishmentGroup) +','
            END
            IF ISNULL(@c_ToId,'') = ''
               SET @c_ToID = @c_ID
            IF ISNULL(@c_Priority,'') = ''
               SET @c_Priority = '9'
            EXEC isp_InsertTaskDetail
            @c_TaskType            = 'RPF'
            ,@c_Storerkey          = 'HUSQ'
            ,@c_Sku                = @c_Sku
            ,@c_Lot                = @c_Lot
            ,@c_UOM                = @c_UOM
            ,@n_UOMQty             = @n_Qty
            ,@n_Qty                = @n_Qty
            ,@c_FromLoc            = @c_Fromloc
            ,@c_FromID             = @c_ID
            ,@c_ToLoc              = @c_ToLoc
            ,@c_ToID               = @c_ToID
            ,@c_PickMethod         = '?TASKQTY' --?TASKQTY=(Qty available - taskqty)
            ,@c_Priority           = @c_Priority
            ,@c_SourcePriority     = '9'
            ,@c_SourceType         = 'ispRLREPVL'
            ,@c_SourceKey          = @c_Replenishmentkey
            ,@c_AreaKey            = '?F'  -- ?F=Get from location areakey
            ,@c_Groupkey           = @c_ReplenishmentGroup
            ,@c_CallSource         = 'REPLENISHMENT'
            ,@n_QtyReplen          = @n_Qty
            ,@n_PendingMoveIn      = @n_Qty
            ,@c_LinkTaskToReplen   = 'Y'
            ,@b_Success            = @b_Success OUTPUT
            ,@n_Err                = @n_err OUTPUT
            ,@c_ErrMsg             = @c_errmsg OUTPUT
            UPDATE dbo.TaskDetail
            SET PickMethod = 'FP'
            WHERE PickMethod <> 'FP'
            AND TaskType = 'RPF'
            AND Storerkey = 'HUSQ'
			--Assigning priority to the task based on the criteria
			--Task for the same SKU already exists
			UPDATE dbo.TaskDetail
			SET Priority = 4, Message01 = 'Priority 4', Message02 = 'Task for SKU exists'
            WHERE Storerkey = 'HUSQ' 
			AND EXISTS
            (SELECT TaskDetailKey FROM dbo.TaskDetail TD WITH(NOLOCK)
            WHERE storerkey = 'HUSQ'
            AND taskdetail.taskdetailkey = TD.TaskDetailKey
            AND TaskType = 'RPF'
            AND EXISTS (SELECT 1 FROM dbo.TaskDetail TD2 WITH(NOLOCK) WHERE STATUS NOT IN ('9','X') AND TD2.Sku = TD.Sku AND TD2.TaskDetailKey <> TD.TaskDetailKey AND TD2.Storerkey = 'HUSQ'))
            AND message01 = ''
			AND SourceKey = @c_Replenishmentkey
			--All pickFaces are empty
            UPDATE dbo.TaskDetail
			SET Priority = 2, Message01 = 'Priority 2', Message02 = 'Pickfaces are empty'
            WHERE Message01 = ''
			AND Storerkey = 'HUSQ'
            AND SourceKey = @c_Replenishmentkey
			AND EXISTS
            (SELECT 1 FROM dbo.TaskDetail TD WITH(NOLOCK)
            WHERE taskdetail.taskdetailkey = TD.TaskDetailKey
            AND storerkey = 'HUSQ'
            AND TaskType = 'RPF'
            AND NOT EXISTS
            (SELECT 1 FROM dbo.SKUxLOC SL WITH(NOLOCK)
            WHERE storerkey = 'HUSQ'
            AND LocationType = 'PICK'
            AND qty > 0
            AND TD.Sku = SL.Sku))
			--One PickFace
			UPDATE dbo.TaskDetail
			SET Priority = '3', Message01 = 'Priority 3', Message02 = 'One pickface for SKU'
			WHERE Message01 = ''
			AND Storerkey = 'HUSQ'
			AND SourceKey = @c_Replenishmentkey
			AND EXISTS
            (SELECT 1 FROM dbo.TaskDetail TD WITH(NOLOCK)
            WHERE taskdetail.taskdetailkey = TD.TaskDetailKey
			AND storerkey = 'HUSQ'
            AND TaskType = 'RPF'
            AND EXISTS
            (SELECT COUNT(Loc), Sku FROM dbo.SKUxLOC SL WITH(NOLOCK)
            WHERE storerkey = 'HUSQ'
            AND LocationType = 'PICK'
            AND TD.Sku = sl.Sku
            GROUP BY Sku
            HAVING COUNT(Loc) = 1))
			--Multiple PickFaces
            UPDATE dbo.TaskDetail
			SET Priority = '5', Message01 = 'Priority 5', Message02 = 'Multiple pickfaces'
			WHERE Message01 = ''
			AND Storerkey = 'HUSQ'
			AND SourceKey = @c_Replenishmentkey
			AND EXISTS
			(SELECT 1 FROM dbo.TaskDetail TD WITH(NOLOCK)
            WHERE taskdetail.taskdetailkey = TD.TaskDetailKey
			AND storerkey = 'HUSQ'
            AND TaskType = 'RPF'
            AND EXISTS
            (SELECT COUNT(Loc), Sku FROM dbo.SKUxLOC SL WITH(NOLOCK)
            WHERE storerkey = 'HUSQ'
            AND LocationType = 'PICK'
            AND TD.Sku = sl.Sku
            GROUP BY Sku
            HAVING COUNT(Loc) > 1))
			--Set priority if no above update had captured the task
			UPDATE dbo.TaskDetail
            SET Priority = '6', Message02 = 'No criteria found'
            WHERE SourceKey = @c_Replenishmentkey
            AND Storerkey = 'HUSQ'
			AND Message01 = ''
			
			IF EXISTS (SELECT TOP 1 1 FROM dbo.LOTxLOCxID WITH(NOLOCK)
            WHERE PendingMoveIN > 0
            AND StorerKey = 'HUSQ'
            AND NOT EXISTS
            (SELECT 1 FROM dbo.TaskDetail TD WITH(NOLOCK) WHERE Storerkey = 'HUSQ' AND Status NOT IN ('9','X') AND TD.ToLoc = LOTxLOCxID.Loc
            AND TaskType IN ('RPF','RP1'))
            AND EXISTS
            (SELECT 1 FROM dbo.loc WITH(NOLOCK) WHERE loc.loc = LOTxLOCxID.Loc AND LocationType IN ('PICK','CASE') AND Facility = 'UK001'))
			BEGIN
               -- Create temp table with appropriate columns
               IF OBJECT_ID('tempdb..#LotxLocxid_NoActiveTask') IS NOT NULL
                  DROP TABLE #LotxLocxid_NoActiveTask;

               SELECT TOP 0
                  LLI.LOC
               INTO #LotxLocxid_NoActiveTask
               FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
               LEFT JOIN dbo.TaskDetail TD WITH(NOLOCK) ON 1 = 0
               INNER JOIN dbo.Loc LOC WITH(NOLOCK) ON 1 = 0;

               -- Insert actual data
               INSERT INTO #LotxLocxid_NoActiveTask
               SELECT 
                  LLI.Loc
               FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
               -- JOIN to LOC: must exist
                  JOIN dbo.Loc LOC WITH(NOLOCK)
                     ON LOC.Loc = LLI.Loc
                        AND LOC.LocationType IN ('PICK', 'CASE')
                        AND LOC.Facility = 'UK001'
               -- LEFT JOIN to TaskDetail: must NOT exist (i.e., no active task for this ToLoc)
                  LEFT JOIN dbo.TaskDetail TD WITH(NOLOCK)
                     ON TD.ToLoc = LLI.Loc
                        AND TD.StorerKey = 'HUSQ'
                        AND TD.Status NOT IN ('9', 'X')
                        AND TD.TaskType IN ('RPF', 'RP1')
                WHERE
                   LLI.PendingMoveIN > 0
                   AND LLI.StorerKey = 'HUSQ'
				   AND LOC.Facility  = 'UK001'
                   AND TD.TaskDetailKey IS NULL;  -- ensures no matching task found

                UPDATE LLI
                SET LLI.PendingMoveIN = 0
                FROM dbo.LOTxLOCxID LLI
                JOIN #LotxLocxid_NoActiveTask Temp
                   ON LLI.Loc = Temp.Loc
                WHERE PendingMoveIN > 0
                AND StorerKey = 'HUSQ';
            END
			
			IF EXISTS (SELECT TOP 1 1 FROM LOTxLOCxID WITH(NOLOCK)
            where storerkey = 'HUSQ'
            and QtyReplen > 0
            and not exists
            (select 1 from TaskDetail TD WITH(NOLOCK) where lotxlocxid.Id = TD.FromID and lotxlocxid.Sku = TD.Sku and TD.Storerkey = 'HUSQ'
            and status not in ('9','X') and TaskType in ('RPF','RP1') and td.FromLoc = LOTxLOCxID.Loc)
            and exists
            (select 1 from loc WITH(NOLOCK) where loc.loc = LOTxLOCxID.Loc and Facility = 'UK001'))
			BEGIN
               -- Create temp table with appropriate columns
               IF OBJECT_ID('tempdb..#LotxLocxid_NoActiveTask2') IS NOT NULL
                  DROP TABLE #LotxLocxid_NoActiveTask2;

               SELECT TOP 0
                  LLI.LOC
               INTO #LotxLocxid_NoActiveTask2
               FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
                  LEFT JOIN dbo.TaskDetail TD WITH(NOLOCK) ON 1 = 0
                  INNER JOIN dbo.Loc LOC WITH(NOLOCK) ON 1 = 0;

               -- Insert actual data 
               INSERT INTO #LotxLocxid_NoActiveTask2
               SELECT LLI.Loc
               FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
                  LEFT JOIN dbo.TaskDetail TD WITH(NOLOCK)
                     ON LLI.Id = TD.FromID 
                        AND LLI.Sku = TD.Sku
                        AND TD.Status NOT IN ('9','X')
                        AND TD.TaskType IN ('RPF', 'RP1')
                        AND TD.FromLoc = LLI.Loc
                  INNER JOIN dbo.Loc LOC WITH(NOLOCK)
                     ON LOC.Loc = LLI.Loc
               WHERE LLI.StorerKey = 'HUSQ'
                  AND LLI.QtyReplen > 0
                  AND TD.TaskDetailKey IS NULL
                  AND LOC.Facility = 'UK001';

               UPDATE LLI
               SET LLI.QtyReplen = 0
               FROM dbo.LOTxLOCxID LLI
                  JOIN #LotxLocxid_NoActiveTask2 Temp
                     ON LLI.Loc = Temp.Loc
               WHERE QtyReplen > 0
                  AND StorerKey = 'HUSQ'
			END

            IF @b_Success <> 1
            BEGIN
               SELECT @n_continue = 3
            END
            SET @c_PrevReplenishmentGroup = @c_ReplenishmentGroup
            FETCH FROM CUR_REPLENISH INTO @c_Storerkey, @c_Sku, @c_FromLoc, @c_ID, @c_ToLoc, @c_ToID, @c_UOM, @n_Qty, @c_Lot, @c_Replenishmentkey, @c_ReplenishmentGroup, @c_Priority
         END
         CLOSE CUR_REPLENISH
         DEALLOCATE CUR_REPLENISH
         IF @n_continue IN(1,2) AND @c_ReplenGroupList <> ''
         BEGIN
            SELECT @c_ReplenGroupList = LEFT(@c_ReplenGroupList, LEN(@c_ReplenGroupList) - 1)
            SELECT @c_ErrMsg = 'Release Replenishment Task Completed. Groupkey: ' + @c_ReplenGroupList
         END
      END
      RETURN_SP:
      IF @n_continue=3  -- Error Occured - Process And Return
      BEGIN
         SELECT @b_success = 0
         IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_starttcnt
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
		 execute nsp_logerror @n_err, @c_errmsg, "ispRLREPVL"
         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
         RETURN
      END
   ELSE
   BEGIN
      SELECT @b_success = 1
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
