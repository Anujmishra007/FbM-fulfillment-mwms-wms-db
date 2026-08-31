SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1812GetTaskAU01                                 */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Get next pick task (only for partial pallet)                */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author    Purposes                                  */
/* 2026-04-03  1.0  NYE018    FCR-11492 Created                         */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1812GetTaskAU01] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @cUserName        NVARCHAR( 15),
   @cAreaKey         NVARCHAR( 10),
   @cListKey         NVARCHAR( 10),
   @cDropID          NVARCHAR( 20),
   @cNewTaskKey      NVARCHAR( 10) OUTPUT,
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT  -- screen limitation, 20 char max
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @bSuccess       INT
   DECLARE @bSkipTheTask   INT
   DECLARE @cFinalLOC      NVARCHAR( 10)
   DECLARE @cFinalID       NVARCHAR( 18)
   DECLARE @cFinalPAZone   NVARCHAR( 10)
   DECLARE @cFinalAisle    NVARCHAR( 10)

   DECLARE @cFacility      NVARCHAR( 5)
   DECLARE @cToLOC         NVARCHAR( 10)
   DECLARE @cToLOCAisle    NVARCHAR( 10)
   DECLARE @cToLOCCat      NVARCHAR( 10)
   DECLARE @cToPAZone      NVARCHAR( 10)

   DECLARE @cFromLOC       NVARCHAR( 10)
   DECLARE @cFromID        NVARCHAR( 18)
   DECLARE @cStorerKey     NVARCHAR( 10)
   DECLARE @cSKU           NVARCHAR( 20)
   DECLARE @cLOT           NVARCHAR( 10)
   DECLARE @nQTY           INT
   DECLARE @cToID          NVARCHAR( 18)
   DECLARE @cOrderKey      NVARCHAR( 10)
   DECLARE @cGroupKey      NVARCHAR( 10)
   DECLARE @cTaskType      NVARCHAR( 10)
   DECLARE @cPalletFinalLOC   NVARCHAR( 10)
   DECLARE @cPalletFinalZone  NVARCHAR( 10)
   DECLARE @cFinalPAZoneInLOC NVARCHAR( 10)
   DECLARE @cNextTaskByUOM NVARCHAR(  1) = ''
   DECLARE @cNextTaskByQty NVARCHAR(  1) = '' --SY01
   DECLARE @cUOM           NVARCHAR( 10) = ''
   DECLARE @cOrderBy       NVARCHAR(500) = ''
   DECLARE @cSQL           NVARCHAR(MAX) = ''

   SET @cNewTaskKey = ''

   -- Get StorerKey from RDTMOBREC
   SELECT @cStorerKey = StorerKey
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SET @cNextTaskByUOM = rdt.RDTGetConfig( @nFunc, 'NextTaskByUOM', @cStorerKey)
   IF @cNextTaskByUOM = '0'
      SET @cNextTaskByUOM = ''

   --SY01 START
   SET @cNextTaskByQty = rdt.RDTGetConfig( @nFunc, 'NextTaskByQty', @cStorerKey)
   IF @cNextTaskByQty = '0'
      SET @cNextTaskByQty = ''
   --SY01 END

   -- Get ORDER BY from CODELKUP
   SELECT @cOrderBy = NOTES
   FROM CODELKUP WITH (NOLOCK)
   WHERE LISTNAME = '1812GTAU'
     AND CODE = 'DEFAULT'
     AND STORERKEY = @cStorerKey

   -- Default ORDER BY if not configured
   IF ISNULL(@cOrderBy, '') = ''
      SET @cOrderBy = 'TaskDetail.Priority, LOC1.LogicalLocation, LOC1.LOC'

   -- Get task info
   SELECT TOP 1
      @cFinalLOC = CASE WHEN FinalLOC = '' THEN ToLOC ELSE FinalLoc END,
      @cOrderKey = OrderKey,
      @cGroupKey = ISNULL( GroupKey, ''),
      @cUOM      = ISNULL(UOM,'')
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE ListKey = @cListKey
      AND TransitCount = 0

   -- Get final LOC info
   SELECT
      @cFinalPAZone = PutawayZone,
      @cFinalAisle = LocAisle
   FROM dbo.LOC WITH (NOLOCK)
   WHERE LOC = @cFinalLOC

   -- Get FinalPAZone InLOC
   SELECT @cFinalPAZoneInLOC = InLOC FROM PutawayZone WITH (NOLOCK) WHERE PutawayZone = @cFinalPAZone

   -- Calc destination grouping
   IF @cFinalPAZoneInLOC = ''
   BEGIN
      SET @cPalletFinalLOC = @cFinalLOC
      SET @cPalletFinalZone = ''
   END
   ELSE
   BEGIN
      SET @cPalletFinalLOC = ''
      SET @cPalletFinalZone = @cFinalPAZone
   END

   -- Get next task using dynamic ORDER BY with temp table
   CREATE TABLE #TaskCandidates (
      RowNum INT IDENTITY(1,1),
      TaskDetailKey NVARCHAR(10),
      TaskType NVARCHAR(10),
      FromLOC NVARCHAR(10),
      FromID NVARCHAR(18),
      StorerKey NVARCHAR(10),
      SKU NVARCHAR(20),
      LOT NVARCHAR(10),
      QTY INT,
      ToLOC NVARCHAR(10),
      ToID NVARCHAR(18)
   )

   IF @cAreaKey = '' OR @cAreaKey = 'ALL'
      SET @cSQL = '
         INSERT INTO #TaskCandidates (TaskDetailKey, TaskType, FromLOC, FromID, StorerKey, SKU, LOT, QTY, ToLOC, ToID)
         SELECT TOP 1
            TaskDetail.TaskDetailKey, TaskDetail.TaskType, TaskDetail.FromLOC, TaskDetail.FromID
            , TaskDetail.StorerKey, TaskDetail.SKU, TaskDetail.LOT, TaskDetail.QTY, TaskDetail.ToLOC, TaskDetail.ToID
         FROM TaskDetail WITH (NOLOCK)
         INNER JOIN LOC LOC1 WITH (NOLOCK) ON (TaskDetail.FromLOC = LOC1.LOC)
         INNER JOIN LOC LOC2 WITH (NOLOCK) ON (TaskDetail.ToLOC = LOC2.LOC)
         INNER JOIN PutawayZone PAZone2 (NOLOCK) ON (LOC2.PutawayZone = PAZone2.PutawayZone)
         INNER JOIN AreaDetail WITH (NOLOCK) ON (AreaDetail.PutawayZone = LOC1.PutAwayZone)
         INNER JOIN SKU WITH (NOLOCK) ON (SKU.SKU = TaskDetail.SKU AND SKU.Storerkey = TaskDetail.Storerkey)
         INNER JOIN PACK WITH (NOLOCK) ON (PACK.PACKKey = SKU.PACKKey)
         WHERE TaskDetail.TaskType IN (''FCP'')
            AND TaskDetail.PickMethod = ''PP''
            AND TaskDetail.Status = ''0''
            AND TaskDetail.OrderKey = ''' + @cOrderKey + '''
            AND EXISTS( SELECT 1
               FROM TaskManagerUserDetail TMU WITH (NOLOCK)
                  WHERE PermissionType = TaskDetail.TaskType
                     AND TMU.UserKey = ''' + @cUserName + '''
                     AND TMU.Permission = ''1'')
           AND NOT EXISTS ( SELECT TOP 1 1
               FROM TaskManagerSkipTasks TST WITH (NOLOCK)
                  WHERE TST.TaskDetailKey = TaskDetail.TaskDetailKey
                     AND TST.TaskType = TaskDetail.TaskType
                     AND TST.USERID = ''' + @cUserName + ''')
         ORDER BY ' + @cOrderBy
   ELSE
      SET @cSQL = '
         INSERT INTO #TaskCandidates (TaskDetailKey, TaskType, FromLOC, FromID, StorerKey, SKU, LOT, QTY, ToLOC, ToID)
         SELECT TOP 1
            TaskDetail.TaskDetailKey, TaskDetail.TaskType, TaskDetail.FromLOC, TaskDetail.FromID
            , TaskDetail.StorerKey, TaskDetail.SKU, TaskDetail.LOT, TaskDetail.QTY, TaskDetail.ToLOC, TaskDetail.ToID
         FROM TaskDetail WITH (NOLOCK)
         INNER JOIN LOC LOC1 WITH (NOLOCK) ON (TaskDetail.FromLOC = LOC1.LOC)
         INNER JOIN LOC LOC2 WITH (NOLOCK) ON (TaskDetail.ToLOC = LOC2.LOC)
         INNER JOIN PutawayZone PAZone2 (NOLOCK) ON (LOC2.PutawayZone = PAZone2.PutawayZone)
         INNER JOIN AreaDetail WITH (NOLOCK) ON (AreaDetail.PutawayZone = LOC1.PutAwayZone)
         INNER JOIN SKU WITH (NOLOCK) ON (SKU.SKU = TaskDetail.SKU AND SKU.Storerkey = TaskDetail.Storerkey)
         INNER JOIN PACK WITH (NOLOCK) ON (PACK.PACKKey = SKU.PACKKey)
         WHERE AreaDetail.AreaKey = ''' + @cAreaKey + '''
            AND TaskDetail.TaskType IN (''FCP'')
            AND TaskDetail.PickMethod = ''PP''
            AND TaskDetail.Status = ''0''
            AND TaskDetail.OrderKey = ''' + @cOrderKey + '''
            AND EXISTS( SELECT 1
               FROM TaskManagerUserDetail TMU WITH (NOLOCK)
                  WHERE PermissionType = TaskDetail.TaskType
                     AND TMU.UserKey = ''' + @cUserName + '''
                     AND TMU.Permission = ''1'')
           AND NOT EXISTS ( SELECT TOP 1 1
               FROM TaskManagerSkipTasks TST WITH (NOLOCK)
                  WHERE TST.TaskDetailKey = TaskDetail.TaskDetailKey
                     AND TST.TaskType = TaskDetail.TaskType
                     AND TST.USERID = ''' + @cUserName + ''')
         ORDER BY ' + @cOrderBy

   EXEC sp_executesql @cSQL

   -- Iterate through candidates using cursor on temp table
   DECLARE @curRPTask CURSOR
   SET @curRPTask = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
      SELECT TaskDetailKey, TaskType, FromLOC, FromID, StorerKey, SKU, LOT, QTY, ToLOC, ToID
      FROM #TaskCandidates
      ORDER BY RowNum

   OPEN @curRPTask
   WHILE (1=1)
   BEGIN
      FETCH NEXT FROM @curRPTask INTO @cNewTaskKey, @cTaskType, @cFromLOC, @cFromID, @cStorerKey, @cSKU, @cLOT, @nQTY, @cToLOC, @cToID
      IF @@FETCH_STATUS <> 0
      BEGIN
         SET @cNewTaskKey = ''
         BREAK
      END

      -- Get ToLOC info
    SELECT
       @cFacility = Facility,
       @cToPAZone = PutawayZone,
       @cToLOCAisle  = LocAisle,
       @cToLOCCat = LocationCategory
      FROM LOC WITH (NOLOCK)
      WHERE LOC = @cToLOC

      -- Check if ToLOC is VNA
      IF EXISTS( SELECT 1 FROM LOC WITH (NOLOCK)
         WHERE Facility = @cFacility
            AND PutawayZone = @cToPAZone
            AND LOCAisle = @cToLOCAisle
            AND LocationCategory IN ('PND', 'PND_IN'))
            AND @cToLOCAisle <> '' -- and LocAisle is setup
            AND @cToLOCCat NOT IN ('PND', 'PND_IN') -- and itself is not PND
      BEGIN
         -- For VNA, ToLOC must be same putawayzone and aisle as current pallet destination
         IF @cToPAZone <> @cFinalPAZone OR @cToLOCAisle <> @cFinalAisle
            CONTINUE
      END
      /*
      ELSE
      BEGIN
         -- Non VNA, ToLOC must be same putawayzone as current pallet destination
         IF @cToPAZone <> @cFinalPAZone
            CONTINUE
      END
      */

      -- Check skip task
      SET @bSuccess = 0
      SET @bSkipTheTask = 0
      EXECUTE nspCheckSkipTasks
          @cUserName
         ,@cNewTaskKey
         ,@cTaskType
         ,''
         ,''
         ,''
         ,''
        ,''
         ,''
         ,@bSkipTheTask OUTPUT
         ,@bSuccess     OUTPUT
         ,@nErrNo       OUTPUT
         ,@cErrMsg      OUTPUT
      IF @bSuccess <> 1 OR @nErrNo <> 0
         GOTO Fail

      IF @bSkipTheTask = 1
         CONTINUE

      -- Check equipment profile
      SELECT @bSuccess = 0
      EXECUTE nspCheckEquipmentProfile
          @c_Userid = @cUserName
         ,@c_TaskDetailKey = @cNewTaskKey
         ,@c_StorerKey = @cStorerKey
         ,@c_sku = @cSKU
         ,@c_lot = @cLOT
         ,@c_FromLoc = @cFromLOC
         ,@c_fromID = @cFromID
         ,@c_toLoc = '' -- @c_ToLOC
         ,@c_toID = '' -- @c_ToID
         ,@n_qty = @nQTY
         ,@b_Success = @bSuccess OUTPUT
         ,@n_err = @nErrNo OUTPUT
         ,@c_errmsg = @cErrMsg OUTPUT
      IF @bSuccess <> 1 OR @nErrNo <> 0
         CONTINUE

      BREAK -- Exit loop if found a task
   END

   CLOSE @curRPTask
   DEALLOCATE @curRPTask
   DROP TABLE #TaskCandidates

   IF @cNewTaskKey = ''
   BEGIN
      IF EXISTS( SELECT 1
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE ListKey = @cListKey
            AND Status = '5')
      BEGIN
         SET @nErrNo = 263201
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoTask.ClosePL
         GOTO Fail
      END
      ELSE
      BEGIN
         SET @nErrNo = 263202
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No more task
         GOTO Fail
      END
   END

   -- Get Transit location from initial task
   DECLARE @cTransitLOC NVARCHAR( 10)
   SELECT @cTransitLOC = TransitLOC
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE ListKey = @cListKey
      AND TransitCount = 0 -- initial task

   -- Update new task
   IF @cTransitLOC = ''
      UPDATE TaskDetail WITH (ROWLOCK) SET
          Status     = '3'
         ,UserKey    = @cUserName
         ,ReasonKey  = ''
         ,ListKey    = @cListKey
         ,StartTime  = CURRENT_TIMESTAMP
         ,EditDate   = CURRENT_TIMESTAMP
         ,EditWho    = @cUserName
         ,TrafficCop = NULL
      WHERE TaskDetailKey = @cNewTaskKey
   ELSE
      UPDATE TaskDetail WITH (ROWLOCK) SET
          Status     = '3'
         ,UserKey    = @cUserName
         ,ReasonKey  = ''
         ,TransitLOC = @cTransitLOC
         ,FinalLOC   = @cToLOC
         ,FinalID    = @cToID
         ,ToLOC      = @cTransitLOC
         ,ToID       = @cDropID
         ,ListKey    = @cListKey
         ,StartTime  = CURRENT_TIMESTAMP
         ,EditDate   = CURRENT_TIMESTAMP
         ,EditWho    = @cUserName
         ,TrafficCop = NULL
      WHERE TaskDetailKey = @cNewTaskKey
   IF @@ERROR <> 0
   BEGIN
      SET @nErrNo = 263203
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdTaskDtlFail
   END

Fail:

END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1812GetTaskAU01] TO [NSQL]
GO
