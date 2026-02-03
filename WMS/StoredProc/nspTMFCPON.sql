SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Stored Procedure  : nspTMFCPON                                                */
/* Copyright         : Maersk                                                    */
/* Customer          : ON RUNNING                                                */
/* Description       : Additional ability base on nspTTMFCP5: lock all tasks with*/
/*                     same groupkey                                             */
/*                                                                               */
/* Date        Author    Ver     Purposes                                        */
/* 2026-01-29  NickT     1.0.0   FCR-10467 Created, copied from nspTTMFCP5       */
/*********************************************************************************/
CREATE OR ALTER PROC [dbo].[nspTMFCPON]
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
       @c_StorerKey   NVARCHAR(15)
      ,@c_SKU         NVARCHAR(20)
      ,@c_FromID      NVARCHAR(18)
      ,@c_ToLOC       NVARCHAR(10)
      ,@c_ToID        NVARCHAR(18)
      ,@c_LOT         NVARCHAR(10)
      ,@n_QTY         INT
      ,@nRowCount     INT
      ,@c_TaskType    NVARCHAR(10)
      ,@c_LOCCategory NVARCHAR(10)
      ,@c_LOCAisle    NVARCHAR(10)
      ,@c_Facility    NVARCHAR(5)
      ,@cTransitLOC   NVARCHAR(10)
      ,@cFacility     NVARCHAR(5)
      ,@cLangCode     NVARCHAR(3)
      ,@cGroupKey     NVARCHAR(10)

   SELECT 
       @b_debug = 0
      ,@n_starttcnt = @@TRANCOUNT
      ,@n_continue = 1
      ,@b_success = 0
      ,@n_err = 0
      ,@c_errmsg = ''
      ,@c_TaskDetailkey = ''
      ,@c_LastLOCAisle = ''

   -- Get session info
   SELECT
      @cLangCode = Lang_Code, 
      @cFacility = Facility
   FROM rdt.rdtMobRec WITH (NOLOCK) 
   WHERE UserName = SUSER_SNAME()

   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN nspTMFCPON -- For rollback or commit only our own transaction
      
   SET @c_TaskDetailKey = ''

   IF @c_AreaKey01 <> '' AND @c_AreaKey01 <> 'ALL'
   BEGIN
      DECLARE Cursor_FPKTaskCandidates CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT TaskDetailkey
         FROM dbo.TaskDetail WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) ON (TaskDetail.FromLOC = LOC.LOC)
            JOIN AreaDetail WITH (NOLOCK) ON (AreaDetail.PutawayZone = LOC.PutAwayZone)
         WHERE AreaDetail.AreaKey = @c_AreaKey01
            AND TaskDetail.TaskType IN ('FCP', 'FCP1')
            AND TaskDetail.Status = '0'
            AND TaskDetail.UserKey IN (@c_userid, '')
            AND TaskDetail.UserKeyOverRide IN (@c_userid, '')
            AND NOT EXISTS( SELECT 1
               FROM TaskDetail T1 WITH (NOLOCK)
               WHERE TaskDetail.GroupKey <> '' 
                  AND T1.GroupKey = TaskDetail.GroupKey 
                  AND T1.Status < '9'
                  AND T1.UserKey NOT IN (@c_userid, ''))
            AND EXISTS( SELECT 1 
               FROM TaskManagerUserDetail tmu WITH (NOLOCK)
               WHERE PermissionType = TaskDetail.TASKTYPE
                 AND tmu.UserKey = @c_UserID
                 AND tmu.AreaKey = @c_AreaKey01
                 AND tmu.Permission = '1')
         ORDER BY
             TaskDetail.Priority
            ,CASE WHEN TaskDetail.UserKeyOverRide = @c_userid THEN '0' ELSE '1' END
            ,TaskDetail.GroupKey
            ,TaskDetail.TaskDetailKey
   END
   ELSE
   BEGIN
      DECLARE Cursor_FPKTaskCandidates CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT TaskDetailkey
         FROM dbo.TaskDetail WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) ON (TaskDetail.FromLOC = LOC.LOC)
         WHERE dbo.TaskDetail.TaskType IN ('FCP', 'FCP1')
            AND TaskDetail.Status = '0'
            AND TaskDetail.UserKeyOverRide IN (@c_userid, '')
            AND LOC.Facility = @cFacility
            AND TaskDetail.UserKey IN (@c_userid, '')
            AND NOT EXISTS( SELECT 1
               FROM TaskDetail T1 WITH (NOLOCK)
               WHERE TaskDetail.GroupKey <> '' 
                  AND T1.GroupKey = TaskDetail.GroupKey 
                  AND T1.Status < '9'
                  AND T1.UserKey NOT IN (@c_userid, ''))
            AND EXISTS( SELECT 1 
               FROM TaskManagerUserDetail tmu WITH (NOLOCK)
               WHERE PermissionType = TaskDetail.TASKTYPE
                 AND tmu.UserKey = @c_UserID
                 AND tmu.Permission = '1')
         ORDER BY
             TaskDetail.Priority
            ,CASE WHEN TaskDetail.UserKeyOverRide = @c_userid THEN '0' ELSE '1' END
            ,TaskDetail.GroupKey
            ,TaskDetail.TaskDetailKey
   END

   -- Get a task
   OPEN Cursor_FPKTaskCandidates
   FETCH NEXT FROM Cursor_FPKTaskCandidates INTO @c_TaskDetailKey
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
         @c_ToID      = ToID, 
         @cTransitLOC = TransitLOC
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
         FETCH NEXT FROM Cursor_FPKTaskCandidates INTO @c_TaskDetailKey
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
         FETCH NEXT FROM Cursor_FPKTaskCandidates INTO @c_TaskDetailKey
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
      IF @c_LOCCategory IN ('VNA')
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
               AND UserKey <> @c_userid)
         BEGIN
            FETCH NEXT FROM Cursor_FPKTaskCandidates INTO @c_TaskDetailKey
            CONTINUE
         END
      END

      -- Get transit LOC
      IF @cTransitLOC = ''
      BEGIN
         SET @n_err = 0
         EXECUTE rdt.rdt_GetTransitLOC 
              @c_UserID
            , @c_StorerKey
            , @c_SKU
            , @n_QTY
            , @c_FromLOC
            , @c_FromID
            , @c_ToLOC
            , 1             -- Lock PND transit LOC. 1=Yes, 0=No
            , @cTransitLOC OUTPUT 
            , @n_err       OUTPUT
            , @c_errmsg    OUTPUT
            , @nFunc = 1812
         IF @n_err <> 0
         BEGIN
            FETCH NEXT FROM Cursor_RPFTaskCandidates INTO @c_TaskDetailKey
            CONTINUE
         END
      END
      
      -- Reach final LOC
      IF @cTransitLOC = @c_ToLOC 
      BEGIN
         -- Get To LOC info
         SELECT 
            @c_LOCCategory = LocationCategory, 
            @c_LOCAisle = LocAisle, 
            @c_Facility = Facility
         FROM dbo.LOC WITH (NOLOCK) 
         WHERE LOC = @c_ToLOC
         
         -- Check To aisle in used
         IF @c_LOCCategory IN ('VNA')
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
                  AND UserKey <> @c_userid)
            BEGIN
               FETCH NEXT FROM Cursor_RPFTaskCandidates INTO @c_TaskDetailKey
               CONTINUE
            END
         END
      END
      
      -- Update task as in-progress
      IF NOT EXISTS( SELECT 1 FROM dbo.TaskDetail WITH (ROWLOCK) WHERE TaskDetailKey = @c_TaskDetailKey AND Status = '3' AND UserKey = @c_UserID)
      BEGIN
         IF @cTransitLOC = @c_ToLOC
         BEGIN
            BEGIN TRY 
               UPDATE TaskDetail WITH (ROWLOCK) SET
                  Status     = '3'
                  ,UserKey    = @c_UserID
                  ,ReasonKey  = ''
                  ,ListKey    = CASE WHEN ListKey = '' THEN @c_TaskDetailKey ELSE ListKey END
                  ,StartTime  = CURRENT_TIMESTAMP
                  ,EditDate   = CURRENT_TIMESTAMP
                  ,EditWho    = @c_UserID
                  ,TrafficCop = NULL
               WHERE TaskDetailKey = @c_TaskDetailKey
                  AND Status IN ('0')

               SET @nRowCount = @@ROWCOUNT

               IF @nRowCount <> 1
               BEGIN
                  SET @n_Err = 257701
                  SET @c_ErrMsg = rdt.rdtgetmessage( @n_Err, @cLangCode, 'DSP') --Multiple TaskDetails are found
                  GOTO Fail
               END
            END TRY
            BEGIN CATCH
               SET @n_Err = 257702
               SET @c_ErrMsg = rdt.rdtgetmessage( @n_Err, @cLangCode, 'DSP') --Update TaskDetail Failed
               GOTO Fail
            END CATCH
         END
         ELSE
         BEGIN
            BEGIN TRY
               UPDATE TaskDetail WITH (ROWLOCK) SET
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
                  AND Status IN ('0')
            SET @nRowCount = @@ROWCOUNT

               IF @nRowCount <> 1
               BEGIN
                  SET @n_Err = 257703
                  SET @c_ErrMsg = rdt.rdtgetmessage( @n_Err, @cLangCode, 'DSP') --Multiple TaskDetails are found
                  GOTO Fail
               END
            END TRY
            BEGIN CATCH
               SET @n_Err = 257704
               SET @c_ErrMsg = rdt.rdtgetmessage( @n_Err, @cLangCode, 'DSP') --Update TaskDetail Failed
               GOTO Fail
            END CATCH
         END
      END

      SELECT @cGroupKey = ISNULL(GroupKey, '')
      FROM dbo.TaskDetail WITH(NOLOCK)
      WHERE TaskDetailKey = @c_TaskDetailKey

      IF @cGroupKey <> ''
      BEGIN
         DECLARE @tTaskDetail TABLE
         (
            RowRef      INT IDENTITY(1,1),
            TaskDetailKey     NVARCHAR(10)
         )
         INSERT INTO @tTaskDetail (TaskDetailKey)
         SELECT DISTINCT TD.TaskDetailKey
         FROM dbo.TaskDetail TD WITH(NOLOCK)
         INNER JOIN dbo.LOC WITH(NOLOCK) ON LOC.Facility = @cFacility AND TD.FromLoc = LOC.Loc
         INNER JOIN dbo.AreaDetail AD WITH(NOLOCK) ON LOC.PutawayZone = AD.PutawayZone
         WHERE TD.StorerKey = @c_StorerKey
            AND TD.TaskDetailKey <> @c_TaskDetailKey
            AND TD.TaskType IN ('FCP', 'FCP1')
            AND TD.Status = '0'
            AND TD.UserKeyOverRide IN (@c_userid, '')
            AND TD.UserKey = ''
            AND TD.GroupKey IS NOT NULL
            AND AD.AreaKey = @c_AreaKey01
            AND TD.GroupKey = @cGroupKey

         IF @@ROWCOUNT > 0
         BEGIN
            DECLARE @nLoopIndex INT = -1
            DECLARE @cLoopTaskDetailKey NVARCHAR(10)
            WHILE 1 = 1
            BEGIN
               SELECT TOP 1 @nLoopIndex = RowRef,
                  @cLoopTaskDetailKey = TaskDetailKey
               FROM @tTaskDetail
               WHERE RowRef > @nLoopIndex
               ORDER BY RowRef

               IF @@ROWCOUNT = 0
                  BREAK
               BEGIN TRY
                  UPDATE dbo.TaskDetail WITH(ROWLOCK)
                  SET UserKey    = @c_UserID
                     ,EditDate   = GETDATE()
                     ,EditWho    = @c_UserID
                     ,TrafficCop = NULL
                  WHERE StorerKey = @c_StorerKey
                     AND TaskDetailKey = @cLoopTaskDetailKey
               END TRY
               BEGIN CATCH
                  SET @n_Err = 257705
                  SET @c_ErrMsg = rdt.rdtgetmessage( @n_Err, @cLangCode, 'DSP') --Update TaskDetail Failed
                  GOTO Fail
               END CATCH
            END
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

   COMMIT TRAN nspTMFCPON -- Only commit change made here
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN nspTMFCPON -- Only rollback change made here
Fail:
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
GRANT EXECUTE ON [dbo].[nspTMFCPON] TO nSQL
GO
