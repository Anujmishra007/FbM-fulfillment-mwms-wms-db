SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Procedure: ispRLREPDM                                          */
/* Creation Date: 02/10/2025                                             */
/* Copyright: Maersk                                                     */
/*                                                                       */
/* Updates:                                                              */
/* Date         Ver   Author   Config Change                             */
/* 02/10/2025   1.0   PPA374   Created - JCB replenishment task creation */
/*************************************************************************/

CREATE OR ALTER PROC [dbo].[ispRLREPDM]
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

   DECLARE @c_taskdetailkey NVARCHAR(20),
           @b_Success INT,
           @n_RowCount INT,
           @n_i INT;

   -- Step 1: Create temp table for results
   CREATE TABLE #Results (
      SeqRowID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
      TaskDetailKey NVARCHAR(20) NULL,
      TaskType NVARCHAR(10),
      Storerkey NVARCHAR(50),
      SKU NVARCHAR(50),
      LOT NVARCHAR(50),
      UOM NVARCHAR(50),
      UOMQty INT,
      Qty INT,
      FromLoc NVARCHAR(50),
      LogicalFromLoc NVARCHAR(50),
      FromID NVARCHAR(50),
      ToLoc NVARCHAR(50),
      LogicalToLoc NVARCHAR(50),
      ToID NVARCHAR(50),
      CaseID NVARCHAR(50),
      PickMethod NVARCHAR(50),
      Status INT,
      StatusMsg NVARCHAR(250),
      Priority INT,
      SourcePriority INT,
      HoldKey NVARCHAR(50),
      UserKey NVARCHAR(50),
      UserPosition NVARCHAR(10),
      UserKeyOverRide NVARCHAR(50),
      StartTime DATETIME,
      EndTime DATETIME,
      SourceType NVARCHAR(50),
      SourceKey NVARCHAR(50),
      PickDetailKey NVARCHAR(50),
      OrderKey NVARCHAR(50),
      OrderLineNumber NVARCHAR(50),
      ListKey NVARCHAR(50),
      WaveKey NVARCHAR(50),
      ReasonKey NVARCHAR(50),
      Message01 NVARCHAR(50),
      Message02 NVARCHAR(50),
      Message03 NVARCHAR(50),
      AddDate DATETIME,
      AddWho NVARCHAR(50),
      EditDate DATETIME,
      EditWho NVARCHAR(50),
      TrafficCop NVARCHAR(50),
      ArchiveCop NVARCHAR(50),
      SystemQty INT,
      RefTaskKey NVARCHAR(50),
      LoadKey NVARCHAR(50),
      AreaKey NVARCHAR(50),
      DropID NVARCHAR(50),
      TransitCount INT,
      TransitLOC NVARCHAR(50),
      FinalLOC NVARCHAR(50),
      FinalID NVARCHAR(50),
      GroupKey NVARCHAR(50),
      PendingMoveIn INT,
      QtyReplen INT,
      DeviceID NVARCHAR(50)
   );

   CREATE NONCLUSTERED INDEX IX_Results_FromLoc ON #Results(FromLoc);

   -- Step 2: Delete replenishment that cannot be done
   DELETE R
   FROM dbo.REPLENISHMENT AS R
      LEFT JOIN dbo.TaskDetail AS TD WITH (NOLOCK)
         ON  R.ID = TD.FromID
		 AND ((TD.Lot = R.Lot) OR (TD.Lot = ''))
         AND R.Storerkey = TD.Storerkey
         AND TD.Status NOT IN ('X', '9')
      LEFT JOIN dbo.LOTxLOCxID AS LLI WITH (NOLOCK)
         ON  R.Storerkey = LLI.Storerkey
         AND R.ID = LLI.Id
		 AND R.Lot = LLI.Lot
         AND (LLI.QtyAllocated > 0 OR LLI.QtyPicked > 0 OR LLI.QtyReplen > 0)
   WHERE R.Confirmed = 'N'
      AND (TD.FromID IS NOT NULL OR LLI.Id IS NOT NULL)
      AND R.Storerkey = @c_Storerkey;

   -- Step 3: Pre-aggregate ID count
   WITH LLI_Counts AS (
      SELECT LOC, COUNT(DISTINCT ID) AS IDCount
      FROM dbo.LOTxLOCxID WITH(NOLOCK)
      WHERE Qty > 0
      GROUP BY LOC
   )

   -- Step 4: Populate #Results with deduplicated rows (RowID = 1)
   INSERT INTO #Results (
      TaskType, Storerkey, SKU, LOT, UOM, UOMQty, Qty,
      FromLoc, LogicalFromLoc, FromID, ToLoc, LogicalToLoc, ToID,
      CaseID, PickMethod, Status, StatusMsg, Priority, SourcePriority,
      HoldKey, UserKey, UserPosition, UserKeyOverRide, StartTime, EndTime,
      SourceType, SourceKey, PickDetailKey, OrderKey, OrderLineNumber, ListKey, WaveKey,
      ReasonKey, Message01, Message02, Message03, AddDate, AddWho, EditDate,
      EditWho, TrafficCop, ArchiveCop, SystemQty, RefTaskKey, LoadKey, AreaKey,
      DropID, TransitCount, TransitLOC, FinalLOC, FinalID, GroupKey, PendingMoveIn, QtyReplen, DeviceID
   )
   SELECT
      Sub.TaskType, Sub.Storerkey, Sub.SKU, Sub.LOT, Sub.UOM, Sub.UOMQty, Sub.Qty,
      Sub.FromLoc, Sub.LogicalFromLoc, Sub.FromID, Sub.ToLoc, Sub.LogicalToLoc, Sub.ToID,
      Sub.CaseID, Sub.PickMethod, Sub.Status, Sub.StatusMsg, Sub.Priority, Sub.SourcePriority,
      Sub.HoldKey, Sub.UserKey, Sub.UserPosition, Sub.UserKeyOverRide, Sub.StartTime, Sub.EndTime,
      Sub.SourceType, Sub.SourceKey, Sub.PickDetailKey, Sub.OrderKey, Sub.OrderLineNumber, Sub.ListKey, Sub.WaveKey,
      Sub.ReasonKey, Sub.Message01, Sub.Message02, Sub.Message03, Sub.AddDate, Sub.AddWho, Sub.EditDate,
      Sub.EditWho, Sub.TrafficCop, Sub.ArchiveCop, Sub.SystemQty, Sub.RefTaskKey, Sub.LoadKey, Sub.AreaKey,
      Sub.DropID, Sub.TransitCount, Sub.TransitLOC, Sub.FinalLOC, Sub.FinalID, Sub.GroupKey, Sub.PendingMoveIn, Sub.QtyReplen, Sub.DeviceID
   FROM (
      SELECT
         'RPF' AS TaskType,
         R.Storerkey,
         R.SKU,
         R.LOT,
         R.UOM,
         R.Qty AS UOMQty,
         R.Qty,
         R.FromLoc,
         L1.LogicalLocation AS LogicalFromLoc,
         R.ID AS FromID,
         IIF(L3.Loc IS NULL, R.ToLoc, L3.Loc) AS ToLoc,
         L2.LogicalLocation AS LogicalToLoc,
         R.ToID,
         R.RefNo AS CaseID,
         R.Remark AS PickMethod,
         0 AS Status,
         '' AS StatusMsg,
         3 AS Priority,
         3 AS SourcePriority,
         '' AS HoldKey,
         '' AS UserKey,
         '1' AS UserPosition,
         '' AS UserKeyOverRide,
         GETDATE() AS StartTime,
         GETDATE() AS EndTime,
         'ispRLREPDM' AS SourceType,
         R.ReplenishmentKey AS SourceKey,
         '' AS PickDetailKey,
         '' AS OrderKey,
         '' AS OrderLineNumber,
         '' AS ListKey,
         '' AS WaveKey,
         '' AS ReasonKey,
         L1.PutawayZone AS Message01,
         L1.LocationGroup AS Message02,
         L1.LocationCategory AS Message03,
         GETDATE() AS AddDate,
         SUSER_NAME() AS AddWho,
         GETDATE() AS EditDate,
         SUSER_NAME() AS EditWho,
         NULL AS TrafficCop,
         NULL AS ArchiveCop,
         R.Qty AS SystemQty,
         '' AS RefTaskKey,
         '' AS LoadKey,
         AD.AreaKey AS AreaKey,
         R.DropID,
         0 AS TransitCount,
         IIF(L3.Loc IS NULL, '', L3.Loc) AS TransitLOC,
         R.ToLoc AS FinalLOC,
         R.ID AS FinalID,
         '' AS GroupKey,
         0 AS PendingMoveIn,
         R.Qty AS QtyReplen,
         '' AS DeviceID,
         ROW_NUMBER() OVER(
            PARTITION BY R.FromLoc, R.ID, R.Qty, R.LOT
            ORDER BY COALESCE(L3.MaxPallet,0) - COALESCE(LLI.IDCount,0) DESC, L3.Loc
         ) AS RowID
      FROM dbo.REPLENISHMENT R WITH(NOLOCK)
         INNER JOIN dbo.LOC L1 WITH(NOLOCK) ON R.FromLoc = L1.Loc
         INNER JOIN dbo.AreaDetail AD WITH(NOLOCK) ON L1.PutawayZone = AD.PutawayZone
         LEFT JOIN dbo.LOC L3 WITH(NOLOCK)
             ON L1.LocAisle = L3.LocAisle
            AND L1.Floor = L3.Floor
            AND L3.LocationCategory = 'PND_OUT'
            AND L1.Facility = L3.Facility
         LEFT JOIN LLI_Counts LLI ON L3.Loc = LLI.LOC
         INNER JOIN dbo.LOC L2 WITH(NOLOCK) 
            ON L2.Loc = IIF(L3.Loc IS NOT NULL, L3.Loc, R.ToLoc)
      WHERE R.Storerkey = @c_Storerkey
	     AND   R.Confirmed = 'N'
         AND   L1.Facility = @c_Facility
         AND   L2.Facility = @c_Facility
   ) AS Sub
   WHERE Sub.RowID = 1;

   -- Step 5: Count rows to know how many keys required
   SELECT @n_RowCount = COUNT(*) FROM #Results;

   -- Step 6: Create #Keys and generate keys
   CREATE TABLE #Keys (
      SeqRowID INT IDENTITY(1,1) PRIMARY KEY,
      TaskDetailKey NVARCHAR(20) NOT NULL
   );

   SET @n_i = 1;
   WHILE @n_i <= @n_RowCount
   BEGIN
      EXEC nspg_getkey  
         'TaskDetailKey',
         10,
         @c_taskdetailkey OUTPUT,
         @b_Success OUTPUT,
         @n_err OUTPUT,
         @c_ErrMsg OUTPUT;

      INSERT INTO #Keys (TaskDetailKey) VALUES (@c_taskdetailkey);

      SET @n_i += 1;
   END;

   -- Step 7: Assign keys in a set-based update
   UPDATE R
   SET R.TaskDetailKey = K.TaskDetailKey
   FROM #Results R
      INNER JOIN #Keys K 
	     ON R.SeqRowID = K.SeqRowID

   -- Step 8: Return final results with all columns explicitly
   INSERT INTO dbo.TaskDetail
   SELECT
      TaskDetailKey,
      TaskType,
      Storerkey,
      SKU,
      LOT,
      UOM,
      UOMQty,
      Qty,
      FromLoc,
      LogicalFromLoc,
      FromID,
      ToLoc,
      LogicalToLoc,
      ToID,
      CaseID,
      PickMethod,
      Status,
      StatusMsg,
      Priority,
      SourcePriority,
      HoldKey,
      UserKey,
      UserPosition,
      UserKeyOverRide,
      StartTime,
      EndTime,
      SourceType,
      SourceKey,
      PickDetailKey,
      OrderKey,
      OrderLineNumber,
      ListKey,
      WaveKey,
      ReasonKey,
      Message01,
      Message02,
      Message03,
      AddDate,
      AddWho,
      EditDate,
      EditWho,
      TrafficCop,
      ArchiveCop,
      SystemQty,
      RefTaskKey,
      LoadKey,
      AreaKey,
      DropID,
      TransitCount,
      TransitLOC,
      FinalLOC,
      FinalID,
      GroupKey,
      PendingMoveIn,
      QtyReplen,
      DeviceID
   FROM #Results R
   WHERE NOT EXISTS (SELECT 1 FROM dbo.TaskDetail TD WITH(NOLOCK) WHERE TD.Storerkey = R.Storerkey AND TD.FromID = R.FromID AND Status NOT IN ('9','X'));

   -- Step 9: update REPLENISHMENT table to mark lines as processed
   UPDATE RP
   SET 
      RP.Confirmed = 'Y', RP.ArchiveCop = NULL
   FROM REPLENISHMENT RP WITH(ROWLOCK)
      INNER JOIN #Results R 
	     ON RP.ReplenishmentKey = R.SourceKey;

   -- Step 10: Cleanup
   DROP TABLE #Results;
   DROP TABLE #Keys;
END
