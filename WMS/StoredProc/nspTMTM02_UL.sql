SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Stored Procedure: nspTMTM02_UL                                          */
/* Copyright: Maersk                                                       */
/* Customer : Unilever. Called by nspTMTM01_UL                             */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Ver.    Author     Purposes                                */
/* 2025-06-23   1.0.0   NickT      FCR-5519 Create                         */
/* 2025-07-04   1.0.1   Jackc      FCR-5519 1. Add tasktype output         */
/*                                 2. Change schema                        */
/* 2025-07-04   1.0.2   Jackc      FCR-5519 Add task check after get one   */
/* 2025-08-22   1.0.3   Jackc      FCR-5519 Fix begin tran issue           */
/***************************************************************************/
CREATE OR ALTER PROC [RDT].[nspTMTM02_UL]
   @c_userid                  NVARCHAR(18),
   @c_AreaKey01               NVARCHAR(10),
   @c_ttmStrategykey          NVARCHAR(10),
   @c_InterLeaveTasks         NVARCHAR(10),
   @cContinueALLTaskWithinAisle NVARCHAR(10),
   @c_LastLOC                 NVARCHAR(10),
   @b_Success                 INT             OUTPUT,
   @n_err                     INT             OUTPUT,
   @c_errmsg                  NVARCHAR(250)   OUTPUT,
   @c_TaskDetailKey           NVARCHAR(20)    OUTPUT,
   @c_TTMTaskType             NVARCHAR(20)    OUTPUT, --V1.0.1
   @n_Mobile                  INT = 0,
   @n_Func                    INT = 0,
   @c_StorerKey               NVARCHAR( 15) = ''

AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @nRowCount                 INT,
      @cLastAisle                NVARCHAR(10),
      @bDebug                    INT = 0,
      @nIsRDT                    INT = 0
      ,@c_LastLOCAisle  NVARCHAR(10)
      ,@c_FoundTask    NVARCHAR( 1)
      ,@b_SkipTheTask INT

      --V1.0.2 start
      ,@c_SKU                    NVARCHAR(20)
      ,@c_TaskType               NVARCHAR(10)
      ,@c_FromID                 NVARCHAR(18)
      ,@c_ToLOC                  NVARCHAR(10)
      ,@c_ToID                   NVARCHAR(18)
      ,@c_LOT                    NVARCHAR(10)
      ,@n_QTY                    INT
      ,@c_LOCCategory            NVARCHAR( 10)
      ,@c_LOCAisle               NVARCHAR(10)
      ,@c_Facility               NVARCHAR(5)
      ,@c_GroupKey               NVARCHAR(10)
      ,@c_FromLOC                NVARCHAR(10)
      ,@c_TransitLOC             NVARCHAR( 10) 
      --V1.0.2 end

   DECLARE @tTaskType TABLE 
   (
      ID INT IDENTITY(1,1) Primary Key,
      TaskType NVARCHAR(10)
   )

   DECLARE @tAisleInUsed TABLE
   ( 
      Rowref INT identity(1,1) Primary Key,
      LocAIsle NVARCHAR(10),
      UserKey NVARCHAR(18)
   )

   DECLARE @tExcludedTaskDetailKey TABLE
   (
      TaskDetailKey NVARCHAR(20) Primary Key
   )

   SET @b_Success = 1
   SET @n_err = 0
   SET @c_errmsg = ''
   SET @c_TaskDetailKey = ''

   EXEC RDT.rdtIsRDT @nIsRDT OUTPUT
   SET @bDebug = CASE WHEN @nIsRDT = 1 THEN 0 ELSE 1 END

   IF @bDebug = 1
      SELECT 'Running nspTMTM02_UL' AS DebugInfo,
             @c_userid AS UserID,
             @c_AreaKey01 AS AreaKey01,
             @c_ttmStrategykey AS ttmStrategyKey,
             @c_InterLeaveTasks AS InterLeaveTasks,
             @cContinueALLTaskWithinAisle AS ContinueALLTaskWithinAisle,
             @c_LastLOC AS LastLOC

   /* --V1.0.1
   IF @c_InterLeaveTasks <> '1'
      RETURN
   */

   SELECT @nRowCount = COUNT(*)
   FROM dbo.TaskManagerUser TMU WITH (NOLOCK)
   INNER JOIN dbo.EquipmentProfile EP WITH (NOLOCK) ON TMU.EquipmentProfileKey = EP.EquipmentProfileKey
   WHERE TMU.Userkey = @c_userid
      AND TMU.EquipmentProfileKey = 'VNA'

   IF @nRowCount > 0
   BEGIN
      INSERT INTO @tAisleInUsed( LocAisle, UserKey )
      SELECT 
         LOC.LocAisle,
         TD.UserKey
      FROM dbo.TaskDetail TD WITH (NOLOCK)
      INNER JOIN dbo.LOC WITH (NOLOCK) ON  TD.FromLOC = LOC.Loc
      INNER JOIN dbo.TaskManagerUser TMU WITH (NOLOCK) ON TD.UserKey = TMU.UserKey
      INNER JOIN dbo.EquipmentProfile EP WITH (NOLOCK) ON TMU.EquipmentProfileKey = EP.EquipmentProfileKey
      WHERE TMU.EquipmentProfileKey = 'VNA'
         AND TD.UserKey <> @c_userid
         AND TD.Status = '3'
      ORDER BY LOC.LocAisle
   END

   IF @bDebug = 1
   BEGIN
      SELECT 'Aisle in Use'
      SELECT * FROM @tAisleInUsed
   END

   --FCR-5519 Excluded TaskType, these task types will not be considered for standard interleaving, follow the customize logic
   INSERT INTO @tTaskType (TaskType)
   VALUES('FCP'), ('FCP1'), ('FPK'), ('FPK1'), ('RPF'), ('RP1')

   IF ISNULL(RTRIM(@c_LastLOC) ,'') <> ''
   BEGIN
      SELECT @cLastAisle = ISNULL(LOCAisle ,'')
      FROM dbo.LOC WITH (NOLOCK)
      WHERE Loc = @c_LastLOC

      IF @bDebug = 1
      BEGIN
         SELECT 
            @cLastAisle '@cLastAisle',
            @c_userid '@c_userid',
            @c_AreaKey01 '@c_AreaKey01'
      END
   END

   IF @bDebug = 1
      SELECT 'Start to find task'

   WHILE 1=1 --v1.0.2
   BEGIN
      SET @c_TaskDetailKey = ''
      SET @nRowCount = 0

      IF @cContinueALLTaskWithinAisle = '1' AND ISNULL(@cLastAisle, '') <> ''
      BEGIN
         IF @bDebug = 1
            SELECT 'ConitnueAllTaskWithinAisle ON,FromLoc logic', @cLastAisle AS LastAisle

         SELECT TOP 1
            @c_TaskDetailKey = TD.TaskDetailKey
         FROM dbo.TaskDetail TD WITH (NOLOCK)
         INNER JOIN dbo.Wave W WITH (NOLOCK) ON W.WaveKey = TD.WaveKey
         INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON LOC.Loc = TD.FromLoc
         INNER JOIN dbo.PutawayZone PZ WITH (NOLOCK) ON PZ.PutawayZone = LOC.PutawayZone
         INNER JOIN dbo.AreaDetail AD WITH (NOLOCK) ON AD.PutawayZone = PZ.PutawayZone
         INNER JOIN @tTaskType T ON TD.TaskType = T.TaskType
         INNER JOIN dbo.TaskManagerUserDetail TMUD WITH (NOLOCK)
            ON  TMUD.AreaKey = AD.AreaKey
            AND TMUD.Permission = '1'
            AND TMUD.PermissionType = TD.TaskType
            AND TMUD.UserKey = @c_userid
         WHERE LOC.LocAisle = @cLastAisle
            AND AD.AreaKey = CASE WHEN ISNULL(RTRIM(@c_AreaKey01) ,'') = '' THEN AD.AreaKey ELSE @c_AreaKey01 END
            AND TD.Status = '0'
            AND TD.UserKey = ''
            AND NOT EXISTS ( SELECT 1 FROM @tExcludedTaskDetailKey ETD WHERE ETD.TaskDetailKey = TD.TaskDetailKey ) --V1.0.2
         ORDER BY
            CASE WHEN W.UserDefine08 IS NULL OR LTRIM(RTRIM(W.UserDefine08)) = '' THEN 1 ELSE 0 END,
            W.UserDefine08,
            TD.Priority,
            LOC.LocAisle

         SELECT @nRowCount = @@ROWCOUNT

         IF @nRowCount = 0
         BEGIN
            IF @bDebug = 1
               SELECT 'ConitnueAllTaskWithinAisle ON,ToLoc logic', @cLastAisle AS LastAisle

            SELECT TOP 1
                  @c_TaskDetailKey = TD.TaskDetailKey
            FROM dbo.TaskDetail TD WITH (NOLOCK)
            INNER JOIN dbo.Wave W WITH (NOLOCK) ON W.WaveKey = TD.WaveKey
            INNER JOIN dbo.LOC WITH (NOLOCK) ON LOC.Loc = TD.ToLoc
            INNER JOIN dbo.PutawayZone PZ WITH (NOLOCK) ON PZ.PutawayZone = LOC.PutawayZone
            INNER JOIN dbo.AreaDetail AD WITH (NOLOCK) ON AD.PutawayZone = PZ.PutawayZone
            INNER JOIN @tTaskType T ON TD.TaskType = T.TaskType
            INNER JOIN dbo.TaskManagerUserDetail TMUD WITH (NOLOCK)
               ON TMUD.AreaKey = AD.AreaKey
               AND TMUD.Permission = '1'
               AND TMUD.PermissionType = TD.TaskType
               AND TMUD.UserKey = @c_userid
            WHERE LOC.LocAisle = @cLastAisle
               AND AD.AreaKey = CASE WHEN ISNULL(RTRIM(@c_AreaKey01) ,'') = '' THEN AD.AreaKey ELSE @c_AreaKey01 END
               AND TD.Status = '0'
               AND TD.UserKey = ''
               AND NOT EXISTS ( SELECT 1 FROM @tExcludedTaskDetailKey ETD WHERE ETD.TaskDetailKey = TD.TaskDetailKey ) --V1.0.2
            ORDER BY
               CASE WHEN W.UserDefine08 IS NULL OR LTRIM(RTRIM(W.UserDefine08)) = '' THEN 1 ELSE 0 END,
               W.UserDefine08,
               TD.Priority,
               LOC.LocAisle

            SELECT @nRowCount = @@ROWCOUNT
         END
      END

      IF @nRowCount = 0
      BEGIN
         IF @bDebug = 1
            SELECT 'ConitnueAllTaskWithinAisle OFF,FromLoc logic', @cLastAisle AS LastAisle

         SELECT TOP 1
            @c_TaskDetailKey = TD.TaskDetailKey
         FROM dbo.TaskDetail TD WITH (NOLOCK)
         INNER JOIN dbo.Wave W WITH (NOLOCK) ON W.WaveKey = TD.WaveKey
         INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON LOC.Loc = TD.FromLoc
         INNER JOIN dbo.PutawayZone PZ WITH (NOLOCK) ON PZ.PutawayZone = LOC.PutawayZone
         INNER JOIN dbo.AreaDetail AD WITH (NOLOCK) ON AD.PutawayZone = PZ.PutawayZone
         INNER JOIN @tTaskType T ON TD.TaskType = T.TaskType
         INNER JOIN dbo.TaskManagerUserDetail TMUD WITH (NOLOCK)
            ON TMUD.AreaKey = AD.AreaKey
            AND TMUD.Permission = '1'
            AND TMUD.PermissionType = TD.TaskType
         WHERE AD.AreaKey = CASE WHEN ISNULL(RTRIM(@c_AreaKey01) ,'') ='' THEN AD.AreaKey ELSE @c_AreaKey01 END
            AND TD.status = '0'
            AND TD.userkey = ''
            AND TMUD.UserKey = @c_userid
            AND NOT EXISTS ( SELECT 1 FROM @tAisleInUsed AIU  WHERE AIU.LocAisle = LOC.LocAisle )
            AND NOT EXISTS ( SELECT 1 FROM @tExcludedTaskDetailKey ETD WHERE ETD.TaskDetailKey = TD.TaskDetailKey )
         ORDER BY
            CASE WHEN W.UserDefine08 IS NULL OR LTRIM(RTRIM(W.UserDefine08)) = '' THEN 1 ELSE 0 END,
            W.UserDefine08,
            TD.Priority,
            LOC.LocAisle

         SELECT @nRowCount = @@ROWCOUNT
      END

      IF @nRowCount = 0
      BEGIN
         IF @bDebug = 1
            SELECT 'ConitnueAllTaskWithinAisle OFF,ToLoc logic', @cLastAisle AS LastAisle

         SELECT TOP 1
            @c_TaskDetailKey = TD.TaskDetailKey
         FROM dbo.TaskDetail TD WITH (NOLOCK)
         INNER JOIN dbo.Wave W WITH (NOLOCK) ON W.WaveKey = TD.WaveKey
         INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON LOC.Loc = TD.ToLoc
         INNER JOIN dbo.PutawayZone PZ WITH (NOLOCK) ON PZ.PutawayZone = LOC.PutawayZone
         INNER JOIN dbo.AreaDetail AD WITH (NOLOCK) ON AD.PutawayZone = PZ.PutawayZone
         INNER JOIN @tTaskType T ON TD.TaskType = T.TaskType
         INNER JOIN dbo.TaskManagerUserDetail TMUD WITH (NOLOCK)
            ON TMUD.AreaKey = AD.AreaKey
            AND TMUD.Permission = '1'
            AND TMUD.PermissionType = TD.TaskType
         WHERE AD.AreaKey = CASE WHEN ISNULL(RTRIM(@c_AreaKey01) ,'') = '' THEN AD.AreaKey ELSE @c_AreaKey01 END
            AND TD.Status = '0'
            AND TD.UserKey = ''
            AND TMUD.UserKey = @c_userid
            AND NOT EXISTS ( SELECT 1 FROM @tAisleInUsed AIU WHERE AIU.LocAisle = LOC.LocAisle )
            AND NOT EXISTS ( SELECT 1 FROM @tExcludedTaskDetailKey ETD WHERE ETD.TaskDetailKey = TD.TaskDetailKey )
         ORDER BY
               CASE WHEN W.UserDefine08 IS NULL OR LTRIM(RTRIM(W.UserDefine08)) = '' THEN 1 ELSE 0 END,
               W.UserDefine08,
               TD.Priority,
               LOC.LocAisle

         SELECT @nRowCount = @@ROWCOUNT
      END

      --V1.0.2 start
      IF @nRowCount = 0
      BEGIN
         IF @bDebug = 1
            SELECT 'No task found.'

         SET @c_TaskDetailKey = ''
         GOTO Quit
      END

      -- Get task info
      SELECT
         @c_TaskType  = TaskType,
         @c_StorerKey = StorerKey,
         @c_SKU       = SKU,
         @c_LOT       = LOT,
         @n_QTY       = QTY,
         @c_FromLOC   = FromLOC,
         @c_TransitLOC = TransitLoc,
         @c_FromID    = FromID,
         @c_ToLOC     = ToLOC,
         @c_ToID      = ToID
      FROM dbo.TaskDetail WITH (NOLOCK)
      WHERE TaskDetailKey = @c_TaskDetailKey

      IF @bDebug = 1
         SELECT 'Candidate task found', 
                @c_TaskDetailKey AS TaskDetailKey,
                @c_TaskType AS TaskType,
                @c_StorerKey AS StorerKey,
                @c_SKU AS SKU,
                @c_LOT AS LOT,
                @n_QTY AS QTY,
                @c_FromLOC AS FromLOC,
                @c_TransitLOC AS TransitLoc,
                @c_FromID AS FromID,
                @c_ToLOC AS ToLOC,
                @c_ToID AS ToID

      -- Check skip task
      IF @bDebug = 1
         SELECT 'Check task in skip'

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
         IF @bDebug = 1
            SELECT 'Task in skip list', @c_TaskDetailKey AS TaskDetailKey

         INSERT INTO @tExcludedTaskDetailKey (TaskDetailKey) VALUES (@c_TaskDetailKey)
         CONTINUE
      END

      -- start to check the candidate task
      IF @bDebug = 1
         SELECT 'Check equipment quailifed'

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
         IF @bDebug = 1
            SELECT 'Equipment not qualified for task', @c_TaskDetailKey AS TaskDetailKey

         INSERT INTO @tExcludedTaskDetailKey (TaskDetailKey) VALUES (@c_TaskDetailKey)
         CONTINUE
      END

      IF @bDebug = 1
      BEGIN
         SELECT 'Task found', @c_TaskDetailKey AS TaskDetailKey, @c_TaskType AS TaskType
         SELECT 'Excluded Task'
         SELECT * FROM @tExcludedTaskDetailKey
      END
         
      SET @c_FoundTask = 'Y'
      BREAK
   END --WHILE v1.0.2

   --V1.0.2 start
   IF @bDebug = 1
      SELECT 'Update taks detail'

   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT

   IF @nTranCount = 0 --V1.0.3
      BEGIN TRAN  -- Begin our own transaction
   ELSE
      SAVE TRAN nspTMTM02_UL -- For rollback or commit only our own transaction

   -- Get transit LOC
   IF @c_TransitLOC = ''
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
         , @c_TransitLOC OUTPUT 
         , @n_err       OUTPUT
         , @c_errmsg    OUTPUT
         , @nFunc = 1764
      IF @n_err <> 0
      BEGIN
         GOTO RollBackTran
      END
   END

   IF @bDebug = 1
      SELECT 'Get Transit LOC, Update TaskDetail', @c_TransitLOC AS TransitLoc

   -- Update task as in-progress
   IF NOT EXISTS( SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) WHERE TaskDetailKey = @c_TaskDetailKey AND Status = '3' AND UserKey = @c_UserID)
   BEGIN
      IF @c_TransitLOC = @c_ToLOC
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
            AND Status IN ('0')
      ELSE
         UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
            Status     = '3'
            ,UserKey    = @c_UserID
            ,ReasonKey  = ''
            ,TransitLOC = @c_TransitLOC
            ,FinalLOC   = @c_ToLOC
            ,FinalID    = @c_ToID
            ,ToLOC      = @c_TransitLOC
            ,ToID       = @c_FromID
            ,ListKey    = CASE WHEN ListKey = '' THEN @c_TaskDetailKey ELSE ListKey END
            ,StartTime  = CURRENT_TIMESTAMP
            ,EditDate   = CURRENT_TIMESTAMP
            ,EditWho    = @c_UserID
            ,TrafficCop = NULL
         WHERE TaskDetailKey = @c_TaskDetailKey
            AND Status IN ('0')

      IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
      BEGIN
         SET @n_Err = 241401
         SET @c_ErrMsg = rdt.rdtgetmessage( @n_err, 'ENG', 'DSP') --update task fail
         GOTO RollBackTran
      END
   END

   IF @c_TaskDetailKey <> '' AND @c_FoundTask = 'Y'
   BEGIN
      SELECT @c_TTMTaskType = @c_TaskType
   END
   ELSE
   BEGIN
      SET @c_TTMTaskType = ''
   END

   COMMIT TRAN nspTMTM02_UL -- Commit our own transaction
   GOTO Quit
   --V1.0.2 end

   RollbackTran:
      IF @nTranCount > 0
         ROLLBACK TRAN nspTMTM02_UL
      ELSE
         ROLLBACK TRAN
      SET @b_Success = 0
      GOTO Quit

   Fail:
      SET @b_Success = 0
      GOTO Quit

   Quit:
   IF @bDebug = 1
      SELECT 'Quit', @c_TaskDetailKey AS TaskDetailKey, @c_TTMTaskType AS TaskType, @n_err AS ErrNo, @b_Success AS Success

END -- End Proc
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[nspTMTM02_UL] TO NSQL
GO