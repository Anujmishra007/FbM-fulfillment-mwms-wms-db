
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Stored Procedure: nspTTMRP27                                         */
/* Copyright: Maersk WMS                                                */
/*                                                                      */
/* Purpose: TM Replenishment Strategy                                   */
/*          Dispatches next open RPF task ordered by Priority and        */
/*          LOC.LogicalLocation. Skips tasks whose FromLOC is on hold.  */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Author    Ver  Purposes                                  */
/* 2026-08-13  NYE018    1.0  FCR-14962 Created                         */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[nspTTMRP27]
    @c_UserID        NVARCHAR(18)
   ,@c_AreaKey01     NVARCHAR(10)
   ,@c_AreaKey02     NVARCHAR(10)
   ,@c_AreaKey03     NVARCHAR(10)
   ,@c_AreaKey04     NVARCHAR(10)
   ,@c_AreaKey05     NVARCHAR(10)
   ,@c_LastLOC       NVARCHAR(10)
   ,@c_TaskDetailKey NVARCHAR(10)  OUTPUT
   ,@n_Err           INT           OUTPUT
   ,@c_ErrMsg        NVARCHAR(250) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
       @n_starttcnt  INT
      ,@n_continue   INT
      ,@b_Success    INT
      ,@nRowCount    INT
      ,@c_LangCode   NVARCHAR(3)

   DECLARE
       @b_SkipTheTask INT
      ,@cFoundTask    NVARCHAR(1)

   DECLARE
       @c_StorerKey  NVARCHAR(15)
      ,@c_SKU        NVARCHAR(20)
      ,@c_FromID     NVARCHAR(18)
      ,@c_ToLOC      NVARCHAR(10)
      ,@c_ToID       NVARCHAR(18)
      ,@c_LOT        NVARCHAR(10)
      ,@n_QTY        INT
      ,@c_TaskType   NVARCHAR(10)
      ,@c_LOCCategory NVARCHAR(10)
      ,@c_LOCAisle   NVARCHAR(10)
      ,@c_Facility   NVARCHAR(5)
      ,@cTransitLOC  NVARCHAR(10)
      ,@cWaveKey     NVARCHAR(10)
      ,@cPickMethod  NVARCHAR(10)
      ,@cGroupKey    NVARCHAR(10)
      ,@c_FromLOC    NVARCHAR(10)

   SELECT
       @n_starttcnt      = @@TRANCOUNT
      ,@n_continue       = 1
      ,@b_success        = 0
      ,@n_err            = 0
      ,@c_errmsg         = ''
      ,@c_TaskDetailKey  = ''

   SELECT @c_LangCode = DefaultLangCode
   FROM rdt.rdtUser WITH (NOLOCK)
   WHERE UserName = @c_UserID

   SELECT @c_Facility = Facility
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE UserName = @c_UserID

   -- Close any leftover global cursor from prior calls
   IF CURSOR_STATUS('global', 'Cursor_RPFTaskCandidates') IN (0, 1)
      CLOSE Cursor_RPFTaskCandidates
   IF CURSOR_STATUS('global', 'Cursor_RPFTaskCandidates') IN (-1)
      DEALLOCATE Cursor_RPFTaskCandidates

   -- Build candidate cursor — two branches: area-filtered vs facility-wide
   IF @c_AreaKey01 <> '' AND @c_AreaKey01 <> 'ALL'
   BEGIN
      DECLARE Cursor_RPFTaskCandidates CURSOR FAST_FORWARD READ_ONLY FOR
         SELECT TD.TaskDetailKey
         FROM dbo.TaskDetail TD WITH (NOLOCK)
         JOIN dbo.LOC          L  WITH (NOLOCK) ON L.LOC           = TD.FromLOC
         JOIN dbo.AreaDetail   AD WITH (NOLOCK) ON AD.PutawayZone  = L.PutAwayZone
         WHERE AD.AreaKey          = @c_AreaKey01
           AND TD.TaskType         = 'RPF'
           AND TD.PickMethod       = 'FP'
           AND TD.Status           = '0'
           AND TD.UserKeyOverRide  IN (@c_UserID, '')
           AND EXISTS (
               SELECT 1
               FROM dbo.TaskManagerUserDetail TMU WITH (NOLOCK)
               WHERE TMU.PermissionType = TD.TaskType
                 AND TMU.UserKey        = @c_UserID
                 AND TMU.AreaKey        = @c_AreaKey01
                 AND TMU.Permission     = '1'
           )
           AND NOT EXISTS (
               SELECT 1
               FROM dbo.INVENTORYHOLD IH WITH (NOLOCK)
               WHERE IH.Loc  = TD.FromLOC
                 AND IH.Hold = '1'
           )
         ORDER BY
             CASE WHEN TD.UserKeyOverRide = @c_UserID THEN '0' ELSE '1' END
            ,TD.Priority
            ,L.LogicalLocation
            ,L.LOC
   END
   ELSE
   BEGIN
      DECLARE Cursor_RPFTaskCandidates CURSOR FAST_FORWARD READ_ONLY FOR
         SELECT TD.TaskDetailKey
         FROM dbo.TaskDetail TD WITH (NOLOCK)
         JOIN dbo.LOC L WITH (NOLOCK) ON L.LOC = TD.FromLOC
         WHERE TD.TaskType         = 'RPF'
           AND TD.PickMethod       = 'FP'
           AND TD.Status           = '0'
           AND TD.UserKeyOverRide  IN (@c_UserID, '')
           AND L.Facility          = @c_Facility
           AND EXISTS (
               SELECT 1
               FROM dbo.TaskManagerUserDetail TMU WITH (NOLOCK)
               WHERE TMU.PermissionType = TD.TaskType
                 AND TMU.UserKey        = @c_UserID
                 AND TMU.Permission     = '1'
           )
           AND NOT EXISTS (
               SELECT 1
               FROM dbo.INVENTORYHOLD IH WITH (NOLOCK)
               WHERE IH.Loc  = TD.FromLOC
                 AND IH.Hold = '1'
           )
         ORDER BY
             CASE WHEN TD.UserKeyOverRide = @c_UserID THEN '0' ELSE '1' END
            ,TD.Priority
            ,L.LogicalLocation
            ,L.LOC
   END

   -- Iterate candidates
   OPEN Cursor_RPFTaskCandidates
   FETCH NEXT FROM Cursor_RPFTaskCandidates INTO @c_TaskDetailKey

   WHILE @@FETCH_STATUS = 0
   BEGIN
      SET @cGroupKey = ''

      -- Get task info
      SELECT
          @c_TaskType   = TaskType
         ,@c_StorerKey  = StorerKey
         ,@c_SKU        = SKU
         ,@c_LOT        = LOT
         ,@n_QTY        = QTY
         ,@c_FromLOC    = FromLOC
         ,@c_FromID     = FromID
         ,@c_ToLOC      = ToLOC
         ,@c_ToID       = ToID
         ,@cTransitLOC  = TransitLOC
         ,@cWaveKey     = WaveKey
         ,@cPickMethod  = PickMethod
         ,@cGroupKey    = GroupKey
      FROM dbo.TaskDetail WITH (NOLOCK)
      WHERE TaskDetailKey = @c_TaskDetailKey

      -- Check skip task
      SET @b_success    = 0
      SET @b_SkipTheTask = 0
      EXECUTE nspCheckSkipTasks
           @c_UserID
          ,@c_TaskDetailKey
          ,@c_TaskType
          ,''
          ,''
          ,''
          ,''
          ,''
          ,''
          ,@b_SkipTheTask OUTPUT
          ,@b_Success     OUTPUT
          ,@n_err         OUTPUT
          ,@c_errmsg      OUTPUT
      IF @b_success <> 1
      BEGIN
         SET @n_continue = 3
         SET @c_errmsg = rdt.rdtgetmessage(@n_err, @c_LangCode, 'DSP')
         GOTO Quit
      END
      IF @b_SkipTheTask = 1
      BEGIN
         FETCH NEXT FROM Cursor_RPFTaskCandidates INTO @c_TaskDetailKey
         CONTINUE
      END

      -- Check equipment profile
      SET @b_success = 0
      EXECUTE nspCheckEquipmentProfile
           @c_UserID        = @c_UserID
          ,@c_TaskDetailKey = @c_TaskDetailKey
          ,@c_StorerKey     = @c_StorerKey
          ,@c_SKU           = @c_SKU
          ,@c_LOT           = @c_LOT
          ,@c_FromLOC       = @c_FromLOC
          ,@c_FromID        = @c_FromID
          ,@c_ToLOC         = @c_ToLOC
          ,@c_toID          = ''
          ,@n_QTY           = @n_QTY
          ,@b_Success       = @b_success OUTPUT
          ,@n_err           = @n_err     OUTPUT
          ,@c_errmsg        = @c_errmsg  OUTPUT
      IF @b_success = 0
      BEGIN
         FETCH NEXT FROM Cursor_RPFTaskCandidates INTO @c_TaskDetailKey
         CONTINUE
      END

      -- Get FromLOC attributes
      SELECT
          @c_LOCCategory = LocationCategory
         ,@c_LOCAisle    = LocAisle
         ,@c_Facility    = Facility
      FROM dbo.LOC WITH (NOLOCK)
      WHERE LOC = @c_FromLOC

      -- Skip VNA aisle in use by another user
      IF @c_LOCCategory IN ('VNA')
      BEGIN
         IF EXISTS (
            SELECT 1
            FROM dbo.TaskDetail TD WITH (NOLOCK)
            JOIN dbo.LOC L1 WITH (NOLOCK) ON TD.FromLOC = L1.LOC
            LEFT JOIN dbo.LOC L2 WITH (NOLOCK) ON TD.ToLOC = L2.LOC
            WHERE TD.Status > '0' AND TD.Status < '9'
              AND @c_Facility  IN (L1.Facility,  L2.Facility)
              AND @c_LOCAisle  IN (L1.LOCAisle,  L2.LOCAisle)
              AND NOT L1.LocationCategory IN ('PND_OUT', 'PND')
              AND NOT L2.LocationCategory IN ('PND_IN',  'PND')
              AND TD.UserKey <> @c_UserID
         )
         BEGIN
            FETCH NEXT FROM Cursor_RPFTaskCandidates INTO @c_TaskDetailKey
            CONTINUE
         END
      END

      -- Get transit LOC when not already set
      IF @cTransitLOC = ''
      BEGIN
         SET @n_err = 0
         EXECUTE rdt.rdt_GetTransitLOC
              @c_UserID
             ,@c_StorerKey
             ,@c_SKU
             ,@n_QTY
             ,@c_FromLOC
             ,@c_FromID
             ,@c_ToLOC
             ,1               -- Lock PND transit LOC
             ,@cTransitLOC OUTPUT
             ,@n_err       OUTPUT
             ,@c_errmsg    OUTPUT
             ,@nFunc = 1764
         IF @n_err <> 0
         BEGIN
            FETCH NEXT FROM Cursor_RPFTaskCandidates INTO @c_TaskDetailKey
            CONTINUE
         END
      END

      -- If reaching final ToLOC, check that aisle is also free (VNA)
      IF @cTransitLOC = @c_ToLOC
      BEGIN
         SELECT
             @c_LOCCategory = LocationCategory
            ,@c_LOCAisle    = LocAisle
            ,@c_Facility    = Facility
         FROM dbo.LOC WITH (NOLOCK)
         WHERE LOC = @c_ToLOC

         IF @c_LOCCategory IN ('VNA')
         BEGIN
            IF EXISTS (
               SELECT 1
               FROM dbo.TaskDetail TD WITH (NOLOCK)
               JOIN dbo.LOC L1 WITH (NOLOCK) ON TD.FromLOC = L1.LOC
               LEFT JOIN dbo.LOC L2 WITH (NOLOCK) ON TD.ToLOC = L2.LOC
               WHERE TD.Status > '0' AND TD.Status < '9'
                 AND @c_Facility IN (L1.Facility,  L2.Facility)
                 AND @c_LOCAisle IN (L1.LOCAisle,  L2.LOCAisle)
                 AND NOT L1.LocationCategory IN ('PND_OUT', 'PND')
                 AND NOT L2.LocationCategory IN ('PND_IN',  'PND')
                 AND TD.UserKey <> @c_UserID
            )
            BEGIN
               FETCH NEXT FROM Cursor_RPFTaskCandidates INTO @c_TaskDetailKey
               CONTINUE
            END
         END
      END

      -- Assign task to user (optimistic lock — skip if already taken)
      IF NOT EXISTS (SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK)
                     WHERE TaskDetailKey = @c_TaskDetailKey
                       AND Status = '3' AND UserKey = @c_UserID)
      BEGIN
         BEGIN TRY
            IF @cTransitLOC = @c_ToLOC
               UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
                   Status     = '3'
                  ,UserKey    = @c_UserID
                  ,ReasonKey  = ''
                  ,ListKey    = CASE WHEN ListKey = '' THEN @c_TaskDetailKey ELSE ListKey END
                  ,StartTime  = CURRENT_TIMESTAMP
                  ,EditDate   = CURRENT_TIMESTAMP
                  ,EditWho    = @c_UserID
                  ,TrafficCop = NULL
               WHERE TaskDetailKey = @c_TaskDetailKey
                 AND Status = '0'
            ELSE
               UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
                   Status     = '3'
                  ,UserKey    = @c_UserID
                  ,ReasonKey  = ''
                  ,TransitLOC = @cTransitLOC
                  ,FinalLOC   = @c_ToLOC
                  ,FinalID    = @c_ToID
                  ,ToLOC      = @cTransitLOC
                  ,ToID       = @c_FromID
                  ,ListKey    = CASE WHEN ListKey = '' THEN @c_TaskDetailKey ELSE ListKey END
                  ,StartTime  = CURRENT_TIMESTAMP
                  ,EditDate   = CURRENT_TIMESTAMP
                  ,EditWho    = @c_UserID
                  ,TrafficCop = NULL
               WHERE TaskDetailKey = @c_TaskDetailKey
                 AND Status = '0'

            SET @nRowCount = @@ROWCOUNT
         END TRY
         BEGIN CATCH
            SET @n_continue = 3
            SET @n_err    = 277801
            SET @c_errmsg = rdt.rdtgetmessage(@n_err, @c_LangCode, 'DSP') -- UpdTaskDetFail
            GOTO Quit
         END CATCH

         IF @nRowCount = 0  -- Task taken by another user between cursor fetch and update
         BEGIN
            FETCH NEXT FROM Cursor_RPFTaskCandidates INTO @c_TaskDetailKey
            CONTINUE
         END

         -- Bundle sibling RPF/FP tasks on the same pallet
         BEGIN
            DECLARE @cOtherTaskDetailKey NVARCHAR(10)
            DECLARE @cOtherTaskToLOC     NVARCHAR(10)
            DECLARE @cOtherTaskToID      NVARCHAR(18)

            SET @cOtherTaskDetailKey = ''

            DECLARE @curTask CURSOR
            SET @curTask = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT TaskDetailKey, ToLOC, ToID
               FROM dbo.TaskDetail WITH (NOLOCK)
               WHERE FromLOC        = @c_FromLOC
                 AND FromID         = @c_FromID
                 AND TaskType       = 'RPF'
                 AND Status         = '0'
                 AND TaskDetailKey <> @c_TaskDetailKey
                 AND (@cWaveKey = '' OR WaveKey = @cWaveKey)

            OPEN @curTask
            FETCH NEXT FROM @curTask INTO @cOtherTaskDetailKey, @cOtherTaskToLOC, @cOtherTaskToID
            WHILE @@FETCH_STATUS = 0
            BEGIN
               BEGIN TRY
                  IF @cTransitLOC = @c_ToLOC
                     UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
                         Status     = '3'
                        ,UserKey    = @c_UserID
                        ,ReasonKey  = ''
                        ,RefTaskKey = @c_TaskDetailKey
                        ,ListKey    = CASE WHEN ListKey = '' THEN @c_TaskDetailKey ELSE ListKey END
                        ,StartTime  = CURRENT_TIMESTAMP
                        ,EditDate   = CURRENT_TIMESTAMP
                        ,EditWho    = @c_UserID
                        ,TrafficCop = NULL
                     WHERE TaskDetailKey = @cOtherTaskDetailKey
                  ELSE
                     UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
                         Status     = '3'
                        ,UserKey    = @c_UserID
                        ,ReasonKey  = ''
                        ,RefTaskKey = @c_TaskDetailKey
                        ,TransitLOC = @cTransitLOC
                        ,FinalLOC   = @cOtherTaskToLOC
                        ,FinalID    = @cOtherTaskToID
                        ,ToLOC      = @cTransitLOC
                        ,ToID       = @c_FromID
                        ,ListKey    = CASE WHEN ListKey = '' THEN @c_TaskDetailKey ELSE ListKey END
                        ,StartTime  = CURRENT_TIMESTAMP
                        ,EditDate   = CURRENT_TIMESTAMP
                        ,EditWho    = @c_UserID
                        ,TrafficCop = NULL
                     WHERE TaskDetailKey = @cOtherTaskDetailKey
               END TRY
               BEGIN CATCH
                  SET @n_continue = 3
                  SET @n_err    = 277802
                  SET @c_errmsg = rdt.rdtgetmessage(@n_err, @c_LangCode, 'DSP') -- UpdTaskDetFail
                  GOTO Quit
               END CATCH

               FETCH NEXT FROM @curTask INTO @cOtherTaskDetailKey, @cOtherTaskToLOC, @cOtherTaskToID
            END

            -- Set own RefTaskKey when siblings were bundled
            IF @cOtherTaskDetailKey <> ''
            BEGIN
               BEGIN TRY
                  UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
                      RefTaskKey = @c_TaskDetailKey
                     ,TrafficCop = NULL
                  WHERE TaskDetailKey = @c_TaskDetailKey
               END TRY
               BEGIN CATCH
                  SET @n_continue = 3
                  SET @n_err    = 277803
                  SET @c_errmsg = rdt.rdtgetmessage(@n_err, @c_LangCode, 'DSP') -- UpdTaskDetFail
                  GOTO Quit
               END CATCH
            END
         END
      END -- sibling bundling

      SET @cFoundTask = 'Y'
      BREAK -- Task assigned, done
   END

   -- No task found
   IF ISNULL(@cFoundTask, '') <> 'Y'
   BEGIN
      SET @c_TaskDetailKey = ''
      GOTO Quit
   END

   -- Lock other open tasks in the same GroupKey so they can't be taken
   IF ISNULL(@cGroupKey, '') <> ''
   BEGIN
      DECLARE @cGKTaskDetailKey NVARCHAR(10)
      SET @cGKTaskDetailKey = ''

      DECLARE @curGroupKeyTask CURSOR
      SET @curGroupKeyTask = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT DISTINCT TD.TaskDetailKey
         FROM dbo.TaskDetail TD WITH (NOLOCK)
         JOIN dbo.LOC          L  WITH (NOLOCK) ON L.LOC          = TD.FromLOC
         JOIN dbo.AreaDetail   AD WITH (NOLOCK) ON AD.PutawayZone = L.PutAwayZone
         WHERE TD.TaskType        = 'RPF'
           AND TD.PickMethod      = 'FP'
           AND TD.GroupKey        = @cGroupKey
           AND TD.GroupKey        IS NOT NULL
           AND TD.Status          = '0'
           AND TD.UserKey         = ''
           AND TD.UserKeyOverRide IN (@c_UserID, '')
           AND TD.TaskDetailKey  <> @c_TaskDetailKey
           AND AD.AreaKey         = CASE WHEN @c_AreaKey01 <> '' THEN @c_AreaKey01 ELSE AD.AreaKey END
           AND EXISTS (
               SELECT 1
               FROM dbo.TaskManagerUserDetail TMU WITH (NOLOCK)
               WHERE TMU.PermissionType = TD.TaskType
                 AND TMU.UserKey        = @c_UserID
                 AND TMU.AreaKey        = @c_AreaKey01
                 AND TMU.Permission     = '1'
           )

      OPEN @curGroupKeyTask
      FETCH NEXT FROM @curGroupKeyTask INTO @cGKTaskDetailKey
      WHILE @@FETCH_STATUS = 0
      BEGIN
         BEGIN TRY
            UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
                UserKey    = @c_UserID
               ,ReasonKey  = ''
               ,ListKey    = CASE WHEN ListKey = '' THEN @c_TaskDetailKey ELSE ListKey END
               ,StartTime  = CURRENT_TIMESTAMP
               ,EditDate   = CURRENT_TIMESTAMP
               ,EditWho    = @c_UserID
               ,TrafficCop = NULL
            WHERE TaskDetailKey = @cGKTaskDetailKey
         END TRY
         BEGIN CATCH
            SET @n_continue = 3
            SET @n_err    = 277804
            SET @c_errmsg = rdt.rdtgetmessage(@n_err, @c_LangCode, 'DSP') -- LckTaskDetFail
            GOTO Quit
         END CATCH

         FETCH NEXT FROM @curGroupKeyTask INTO @cGKTaskDetailKey
      END
   END

Quit:
   IF CURSOR_STATUS('global', 'Cursor_RPFTaskCandidates') IN (0, 1)
      CLOSE Cursor_RPFTaskCandidates
   IF CURSOR_STATUS('global', 'Cursor_RPFTaskCandidates') IN (-1)
      DEALLOCATE Cursor_RPFTaskCandidates

   IF @n_continue = 3
   BEGIN
      SELECT @b_success = 0
      DECLARE @n_IsRDT INT
      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT

      IF @n_IsRDT = 1
      BEGIN
         WHILE @@TRANCOUNT > @n_starttcnt
            COMMIT TRAN
         RAISERROR (@n_err, 10, 1) WITH SETERROR
      END
      ELSE
      BEGIN
         IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_starttcnt
            ROLLBACK TRAN
         ELSE
         BEGIN
            WHILE @@TRANCOUNT > @n_starttcnt
               COMMIT TRAN
         END
         EXECUTE nsp_logerror @n_err, @c_errmsg, 'nspTTMRP27'
         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR
         RETURN
      END
   END
   ELSE
   BEGIN
      SELECT @b_success = 1
      WHILE @@TRANCOUNT > @n_starttcnt
         COMMIT TRAN
      RETURN
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON dbo.nspTTMRP27 TO NSQL
GO
