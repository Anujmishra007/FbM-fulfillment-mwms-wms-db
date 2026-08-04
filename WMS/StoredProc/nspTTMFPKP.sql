SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: nspTTMFPKP                                         */
/* Copyright: IDS                                                       */
/*                                                                      */
/* Purpose: TM pallet pick strategy.                                    */
/* The original procedure is: nspTTMFPKZ                                */
/* Modifications log:                                                   */
/* Date        Author    Ver  Purposes                                  */
/* 2014-07-02  Ung       1.0  SOS311415 FPK task                        */
/* 2014-12-22  Ung       1.1  SOS328693 Add GroupKey                    */
/* 2016-08-23  TLTING    1.2  Performance tune - NOLOCK                 */
/* 2017-09-08  Ung       1.3  WMS-2800 Add Priority                     */
/* 2019-06-24  Desmond   1.4  INC0693341 Revise sorting                 */
/* 2020-08-27  James     1.5  WMS-14684 SHUTTLE area cannot have multi  */
/*                            user doing FPK task (james01)             */
/* 2026-05-27  FR014     1.6  RITM9021246/UWP-62997					    */
/*						      Add the "UserKeyOverRide" filter          */ 
/*							  to the task list							*/
/************************************************************************/
CREATE OR ALTER PROC [dbo].[nspTTMFPKP]
    @c_UserID        NVARCHAR(18)
   ,@c_AreaKey01     NVARCHAR(10)
   ,@c_AreaKey02     NVARCHAR(10)
   ,@c_AreaKey03     NVARCHAR(10)
   ,@c_AreaKey04     NVARCHAR(10)
   ,@c_AreaKey05     NVARCHAR(10)
   ,@c_LastLOC       NVARCHAR(10)
   ,@n_err           INT            OUTPUT
   ,@c_errmsg        NVARCHAR(250)  OUTPUT
   ,@c_FromLOC       NVARCHAR(10)   OUTPUT
   ,@c_TaskDetailKey NVARCHAR(10)   OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
       @b_debug      INT
      ,@n_starttcnt  INT -- Holds the current transaction count
      ,@n_continue   INT
      ,@b_Success    INT
      ,@c_LastLOCAisle  NVARCHAR(10)
      ,@cFoundTask    NVARCHAR( 1)
      ,@b_SkipTheTask INT

   DECLARE
       @c_StorerKey NVARCHAR(15)
      ,@c_SKU       NVARCHAR(20)
      ,@c_FromID    NVARCHAR(18)
      ,@c_ToLOC     NVARCHAR(10)
      ,@c_ToID      NVARCHAR(18)
      ,@c_LOT       NVARCHAR(10)
      ,@n_QTY       INT
      ,@c_TaskType  NVARCHAR(10)
      ,@c_LOCCategory NVARCHAR( 10)
      ,@c_LOCAisle  NVARCHAR(10)
      ,@c_Facility  NVARCHAR(5)
      ,@c_GroupKey  NVARCHAR(10)

    SELECT
       @b_debug = 0
      ,@n_starttcnt = @@TRANCOUNT
      ,@n_continue = 1
      ,@b_success = 0
      ,@n_err = 0
      ,@c_errmsg = ''
      ,@c_TaskDetailkey = ''
      ,@c_LastLOCAisle = ''

   -- Get last GroupKey by this user
   SET @c_GroupKey = ''
   SELECT TOP 1 @c_GroupKey = GroupKey
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE TaskDetail.TaskType = 'FPK'
      AND TaskDetail.Status = '9'
      AND TaskDetail.UserKey = @c_UserID
   ORDER BY EditDate DESC

   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN nspTTMFPKZ -- For rollback or commit only our own transaction

   SET @c_TaskDetailKey = ''
   
   SET @cFoundTask = ''

   DECLARE Cursor_FPKTaskCandidates CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT TaskDetailkey, GroupKey
      FROM dbo.TaskDetail WITH (NOLOCK)
         JOIN dbo.LOC WITH (NOLOCK) ON (TaskDetail.FromLOC = LOC.LOC)
         JOIN dbo.AreaDetail WITH (NOLOCK) ON (AreaDetail.PutawayZone = LOC.PutAwayZone)
      WHERE TaskDetail.TaskType = 'FPK'
         AND TaskDetail.Status = '0'
         AND TaskDetail.UserKeyOverRide IN (@c_UserID, '')
         AND (@c_AreaKey01 = '' OR AreaDetail.AreaKey = @c_AreaKey01)
         -- Exclude GroupKey taken by others
         AND NOT EXISTS (
            SELECT 1
            FROM dbo.TaskDetail T2 WITH (NOLOCK)
            WHERE T2.TaskDetailkey = TaskDetail.TaskDetailkey
               AND T2.GroupKey <> ''
               AND T2.UserKey <> ''
               AND T2.UserKey <> @c_UserID)
         AND EXISTS (
            SELECT 1
            FROM dbo.TaskManagerUserDetail tmu WITH (NOLOCK)
            WHERE PermissionType = TaskDetail.TaskType
               AND tmu.UserKey = @c_UserID
               AND (@c_AreaKey01 = '' OR tmu.AreaKey = @c_AreaKey01)
               AND tmu.Permission = '1')
      ORDER BY
         CASE WHEN TaskDetail.TaskDetailkey = @c_TaskDetailKey THEN '0' ELSE '1' END
         , TaskDetail.Priority
         , LOC.LogicalLocation
         , LOC.LOC

   -- Get a task
   OPEN Cursor_FPKTaskCandidates
   FETCH NEXT FROM Cursor_FPKTaskCandidates INTO @c_TaskDetailKey, @c_GroupKey
   WHILE @@FETCH_STATUS = 0
   BEGIN
      -- Get task info
      SELECT
         @c_TaskType  = TaskType,
         @c_StorerKey = StorerKey,
         @c_SKU       = SKU,
         @c_LOT       = LOT,
         @n_QTY       = QTY,
         @c_FromLOC   = FromLOC,
         @c_FromID    = FromID,
         @c_ToLOC     = ToLOC,
         @c_ToID      = ToID
      FROM dbo.TaskDetail WITH (NOLOCK)
      WHERE TaskDetailKey = @c_TaskDetailKey

      -- Check skip task
      SET @b_success = 0
      SET @b_SkipTheTask = 0
      EXECUTE nspCheckSkipTasks
           @c_UserID
         , @c_TaskDetailKey
         , @c_TaskType
         , ''
         , ''
         , ''
         , ''
         , ''
         , ''
         , @b_SkipTheTask  OUTPUT
         , @b_Success      OUTPUT
         , @n_err          OUTPUT
         , @c_errmsg       OUTPUT
      IF @b_success <> 1
         GOTO Fail
      IF @b_SkipTheTask = 1
      BEGIN
         FETCH NEXT FROM Cursor_FPKTaskCandidates INTO @c_TaskDetailKey, @c_GroupKey
         CONTINUE
      END

      -- Check equipment
      SET @b_success = 0
      EXECUTE nspCheckEquipmentProfile
           @c_UserID=@c_UserID
         , @c_TaskDetailKey= @c_TaskDetailKey
         , @c_StorerKey    = @c_StorerKey
         , @c_SKU          = @c_SKU
         , @c_LOT          = @c_LOT
         , @c_FromLOC      = @c_FromLOC
         , @c_FromID       = @c_FromID
         , @c_ToLOC        = @c_ToLOC
         , @c_toID         = ''--@c_toid
         , @n_QTY          = @n_QTY
         , @b_Success      = @b_success OUTPUT
         , @n_err          = @n_err     OUTPUT
         , @c_errmsg       = @c_errmsg  OUTPUT
      IF @b_success = 0
      BEGIN
         FETCH NEXT FROM Cursor_FPKTaskCandidates INTO @c_TaskDetailKey, @c_GroupKey
         CONTINUE
      END

      -- Get from LOC info
      SELECT
         @c_LOCCategory = LocationCategory,
         @c_LOCAisle = LocAisle,
         @c_Facility = Facility
      FROM dbo.LOC WITH (NOLOCK)
      WHERE LOC = @c_FromLoc

      -- Check from aisle in used
      IF @c_LOCCategory IN ('VNA', 'SHUTTLE')
      BEGIN
         IF EXISTS( SELECT 1
            FROM dbo.TaskDetail TD WITH (NOLOCK)
               JOIN dbo.LOC L1 WITH (NOLOCK) ON (TD.FromLOC = L1.LOC)
               LEFT JOIN dbo.LOC L2 WITH (NOLOCK) ON (TD.ToLOC = L2.LOC)
            WHERE TD.Status > '0' AND TD.Status < '9'
               AND @c_Facility IN (L1.Facility, L2.Facility)
               AND @c_LOCAisle IN (L1.LOCAisle, L2.LOCAisle)
               AND NOT L1.LocationCategory IN ('PND_OUT', 'PND') -- Exclude task going out from PND_OUT
               AND NOT L2.LocationCategory IN ('PND_IN', 'PND')  -- Exclude task coming in into PND_IN
               AND UserKey <> @c_UserID)
         BEGIN
            FETCH NEXT FROM Cursor_FPKTaskCandidates INTO @c_TaskDetailKey, @c_GroupKey
            CONTINUE
         END
      END

      -- Check to aisle in used
      IF @c_ToLOC <> ''
      BEGIN
         -- Get To LOC info
         SELECT
            @c_LOCCategory = LocationCategory,
            @c_LOCAisle = LocAisle,
            @c_Facility = Facility
         FROM dbo.LOC WITH (NOLOCK)
         WHERE LOC = @c_ToLOC

         -- Check To aisle in used
         IF @c_LOCCategory IN ('VNA', 'SHUTTLE')
         BEGIN
            IF EXISTS( SELECT 1
               FROM dbo.TaskDetail TD WITH (NOLOCK)
                  JOIN dbo.LOC L1 WITH (NOLOCK) ON (TD.FromLOC = L1.LOC)
                  LEFT JOIN dbo.LOC L2 WITH (NOLOCK) ON (TD.ToLOC = L2.LOC)
               WHERE TD.Status > '0' AND TD.Status < '9'
                  AND @c_Facility IN (L1.Facility, L2.Facility)
                  AND @c_LOCAisle IN (L1.LOCAisle, L2.LOCAisle)
                  AND NOT L1.LocationCategory IN ('PND_OUT', 'PND') -- Exclude task going out from PND_OUT
                  AND NOT L2.LocationCategory IN ('PND_IN', 'PND')  -- Exclude task coming in into PND_IN
                  AND UserKey <> @c_UserID)
            BEGIN
               FETCH NEXT FROM Cursor_FPKTaskCandidates INTO @c_TaskDetailKey, @c_GroupKey
               CONTINUE
            END
         END
      END

      -- Update task as in-progress
      IF NOT EXISTS( SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) WHERE TaskDetailKey = @c_TaskDetailKey AND Status = '3' AND UserKey = @c_UserID)
      BEGIN
	  
	    BEGIN TRY
         UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
             Status          = '3'
            ,UserKey         = @c_UserID
            ,ReasonKey       = ''
            ,ListKey         = CASE WHEN ListKey = '' THEN @c_TaskDetailKey ELSE '' END
            ,StartTime       = CURRENT_TIMESTAMP
            ,EditDate        = CURRENT_TIMESTAMP
            ,EditWho         = @c_UserID
            ,TrafficCop      = NULL
         WHERE TaskDetailKey = @c_TaskDetailKey
            AND Status IN ('0')
		END TRY
		
	
		BEGIN CATCH
		   --SET @n_Err = ERROR_NUMBER()
		   --SET @c_ErrMsg = ERROR_MESSAGE()
		   SET @n_Err = 90701
		   SET @c_ErrMsg = '90701 UPDTaskDtlFail'
		   GOTO Fail
		END CATCH

		IF @@ROWCOUNT <> 1
		BEGIN
		   SET @n_Err = 90701
		   SET @c_ErrMsg = '90701 UPDTaskDtlFail'
		   GOTO Fail
		END
		
      END

      SET @cFoundTask = 'Y'
      BREAK -- Task assiged sucessfully, Quit Now
   END

   -- Exit if no task
   IF @cFoundTask <> 'Y'
   BEGIN
      SET @c_TaskDetailKey = ''  --@c_TaskDetailKey still contain last record value if @@FETCH_STATUS <> 0 exit while loop
      GOTO Quit
   END

   COMMIT TRAN nspTTMFPKZ -- Only commit change made here
   GOTO Quit
   
--RollBackTran:
--   ROLLBACK TRAN nspTTMFPKZ -- Only rollback change made here
Fail:
   ROLLBACK TRAN nspTTMFPKZ -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
GRANT EXECUTE ON [dbo].[nspTTMFPKP] TO nSQL
GO