SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_1764GetTask12                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Get next replenish task (Levis)                             */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author    Purposes                                  */
/* 2024-12-06  1.0  JCH507    FCR-1157 (Copied from Generic GetNextTask)*/
/* 2025-05-20  1.1  NLT013    UWP-34684 Assign wrong task to user       */
/* 2025-06-05  1.1.0  NLT013  UWP-34684 Fix issue: Cursor is not allocated*/
/*                            , it causes unpected error                */
/* 2025-09-22 1.2.0 NickT     FCR-7693 Add user override priority in task*/
/* 2025-09-10  1.2.0  NLT013  FCR-7730 add AreaKey limitation           */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1764GetTask12] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @cUserName        NVARCHAR( 15),
   @cAreaKey         NVARCHAR( 10),
   @cListKey         NVARCHAR( 10),
   @cDropID          NVARCHAR( 20),
   @cNewTaskKey      NVARCHAR( 10)  OUTPUT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT  -- screen limitation, 20 char max
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @bDebugFlag     BINARY = 0

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
   DECLARE @cWaveKey       NVARCHAR( 10)
   DECLARE @cPalletFinalLOC NVARCHAR( 10)
   DECLARE @cOrderGroup    NVARCHAR( 20)
   DECLARE @cTaskType      NVARCHAR( 10)
   DECLARE @cPickMethod    NVARCHAR( 10)

   DECLARE @cLastToLoc     NVARCHAR( 10) --v1.0

   DECLARE @cFinalLocCategory NVARCHAR( 10)
   DECLARE @cFinalLocType     NVARCHAR( 10)
   DECLARE @cSLLocType        NVARCHAR( 10)

   SET @cNewTaskKey = ''

   -- Get task info
   SELECT TOP 1
      @cLastToLoc = ToLoc, --v1.0
      @cFinalLOC = CASE WHEN FinalLOC = '' THEN ToLOC ELSE FinalLoc END,
      @cWaveKey = WaveKey,
      @cPickMethod = PickMethod, --v1.0
      @cStorerKey = StorerKey
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE ListKey = @cListKey
      AND TransitCount = 0

   IF @bDebugFlag = 1
      SELECT 'Handled Task Info', @cLastToLoc AS LastToLoc, @cFinalLOC AS FinalLoc, @cWaveKey AS WaveKey, @cPickMethod AS PickMethod

   -- Get final LOC info
   SELECT
      @cFinalPAZone = PutawayZone,
      @cFinalAisle = LocAisle
   FROM dbo.LOC WITH (NOLOCK)
   WHERE LOC = @cFinalLOC

   IF @bDebugFlag = 1
      SELECT 'Handled FinalLoc Info', @cFinalPAZone AS FinalPAZone, @cFinalAisle AS FinalAisle

   --V1.0 JCH507
   /*
   -- Get order info
   SELECT TOP 1
      @cOrderGroup = O.OrderGroup
   FROM dbo.Orders O WITH (NOLOCK)
      JOIN dbo.WaveDetail WD WITH (NOLOCK) ON (O.OrderKey = WD.OrderKey)
   WHERE WD.WaveKey = @cWaveKey
   ORDER BY O.OrderKey


   -- Calc destination grouping
   IF @cOrderGroup = 'L'  --L/RT/WS. L=Launch, RT=Retail, WS=Wholesale
      SET @cPalletFinalLOC = @cFinalLOC
   ELSE
      SET @cPalletFinalLOC = ''
   */
   SET @cPalletFinalLOC = ''
   --V1.0 JCH507 END

   -- V1.1 NLT013 BEGIN
   -- Get the final location
   -- 1. if any task (without TransitLoc) is completed, get top 1 ToLoc
   SELECT TOP 1 @cPalletFinalLOC = ToLoc
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE ListKey = @cListKey
      AND ToLoc <> ''
      AND FinalLOC = ''
      AND TaskType = 'RPF'
      AND Status = '5'
      AND TransitCount = 0

   -- 2. if no task in found, search the task with TransitLoc, get top 1 FinalLoc
   IF ISNULL(@cPalletFinalLOC, '') = ''
   BEGIN
      SELECT TOP 1 @cPalletFinalLOC = FinalLOC
      FROM dbo.TaskDetail WITH (NOLOCK)
      WHERE ListKey = @cListKey
         AND FinalLOC <> ''
         AND TaskType = 'RPF'
         AND Status = '5'
         AND TransitCount = 0
   END

   SET @cPalletFinalLOC = IIF(ISNULL(@cPalletFinalLOC, '') = '', @cFinalLOC, @cPalletFinalLOC)

   IF @cPalletFinalLOC = ''
   BEGIN
      SET @nErrNo = 230304
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No Final Loc
      GOTO Fail
   END
   ELSE
   BEGIN
      SELECT TOP 1
         @cFinalLocCategory = LOC.LocationCategory,
         @cFinalLocType = LOC.LocationType,
         @cSLLocType    = SL.LocationType
      FROM dbo.LOC WITH (NOLOCK)
      JOIN dbo.PutawayZone PZ WITH (NOLOCK)
         ON LOC.FACILITY = PZ.FACILITY AND Loc.PutawayZone = PZ.PutawayZone
      LEFT JOIN dbo.SKUxLOC SL WITH (NOLOCK)  
         ON SL.StorerKey = @cStorerKey AND LOC.LOC = SL.LOC
      LEFT JOIN dbo.AreaDetail AD WITH(NOLOCK)
         ON PZ.PutawayZone = AD.PutawayZone
      WHERE LOC.LOC = @cPalletFinalLOC

      IF @bDebugFlag = 1
         SELECT 'Get Final Loc Info', @cFinalLocCategory AS FinalLocCategory, @cFinalLocType AS FinalLocType, @cSLLocType AS SLLocType
   END
   -- V1.1 NLT013 END

   -- Get next task
   -- If 2nd task type is ASTMV, move the whole DropID to final location, the tasks should have the same final location
   -- If 2nd task type is ASTRPT, will create seperate ASTRPT task for each box, the tasks should have the same final location type
   DECLARE @curRPTask CURSOR
   IF @cAreaKey = ''
   BEGIN
      IF @cFinalLocType = 'PND' AND @cFinalLocCategory = 'Induction' --ASTMV
      BEGIN
         SET @curRPTask = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
            SELECT
               TaskDetailKey, TaskType, FromLOC, FromID, StorerKey, SKU, LOT, QTY, ToLOC, ToID
            FROM dbo.TaskDetail WITH (NOLOCK)
            INNER JOIN dbo.LOC WITH (NOLOCK) ON (TaskDetail.FromLOC = LOC.LOC)
            INNER JOIN dbo.AreaDetail WITH (NOLOCK) ON (AreaDetail.PutawayZone = LOC.PutAwayZone)
            WHERE TaskDetail.TaskType = 'RPF'
               AND TaskDetail.Status = '0'
               AND TaskDetail.UserKeyOverRide IN (@cUserName, '')
               AND TaskDetail.WaveKey = @cWaveKey
               AND TaskDetail.PickMethod = @cPickMethod -- V1.0 Should be FP
               AND TaskDetail.ToLOC = @cPalletFinalLOC --V1.1
               -- Have permission in FromLOC
               AND EXISTS( SELECT 1
                  FROM dbo.TaskManagerUserDetail TMU WITH (NOLOCK)
                     WHERE PermissionType = TaskDetail.TaskType
                        AND TMU.UserKey = @cUserName
                        AND TMU.AreaKey = AreaDetail.AreaKey
                        AND TMU.Permission = '1')
            ORDER BY TaskDetail.Priority, 
               CASE WHEN TaskDetail.UserKeyOverRide = @cUserName THEN '0' ELSE '1' END,
               LOC.LogicalLocation, LOC.LOC
      END
      ELSE IF (@cSLLocType = 'PICK' OR @cFinalLocType = 'DYNAMICPK') AND @cFinalLocCategory = 'Shelving' --ASTRPT
      BEGIN
         SET @curRPTask = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
            SELECT
               TaskDetailKey, TaskType, FromLOC, FromID, StorerKey, SKU, LOT, QTY, ToLOC, ToID
            FROM dbo.TaskDetail WITH (NOLOCK)
            INNER JOIN dbo.LOC WITH (NOLOCK) ON (TaskDetail.FromLOC = LOC.LOC)
            INNER JOIN dbo.LOC AS LOC1 WITH (NOLOCK) ON (TaskDetail.ToLoc = LOC1.LOC)
            INNER JOIN dbo.AreaDetail WITH (NOLOCK) ON (AreaDetail.PutawayZone = LOC.PutAwayZone)
            WHERE TaskDetail.TaskType = 'RPF'
               AND TaskDetail.Status = '0'
               AND TaskDetail.UserKeyOverRide IN (@cUserName, '')
               AND TaskDetail.WaveKey = @cWaveKey
               AND TaskDetail.PickMethod = @cPickMethod -- V1.0 Should be PP
               AND LOC1.LocationType = @cFinalLocType --V1.1
               -- Have permission in FromLOC
               AND EXISTS( SELECT 1
                  FROM dbo.TaskManagerUserDetail TMU WITH (NOLOCK)
                     WHERE PermissionType = TaskDetail.TaskType
                        AND TMU.UserKey = @cUserName
                        AND TMU.AreaKey = AreaDetail.AreaKey
                        AND TMU.Permission = '1')
            ORDER BY TaskDetail.Priority, 
               CASE WHEN TaskDetail.UserKeyOverRide = @cUserName THEN '0' ELSE '1' END,
               LOC.LogicalLocation, LOC.LOC
      END
   END
   ELSE
   BEGIN
      IF @cFinalLocType = 'PND' AND @cFinalLocCategory = 'Induction' --ASTMV
      BEGIN
         SET @curRPTask = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
            SELECT
               TaskDetailKey, TaskType, FromLOC, FromID, StorerKey, SKU, LOT, QTY, ToLOC, ToID
            FROM dbo.TaskDetail WITH (NOLOCK)
            INNER JOIN dbo.LOC WITH (NOLOCK) ON (TaskDetail.FromLOC = LOC.LOC)
            INNER JOIN dbo.AreaDetail WITH (NOLOCK) ON (AreaDetail.PutawayZone = LOC.PutAwayZone)
            WHERE AreaDetail.AreaKey = @cAreaKey
               AND TaskDetail.TaskType = 'RPF'
               AND TaskDetail.Status = '0'
               AND TaskDetail.UserKeyOverRide IN (@cUserName, '')
               AND TaskDetail.WaveKey = @cWaveKey
               AND TaskDetail.PickMethod = @cPickMethod -- V1.0 Should be FP
               AND TaskDetail.ToLOC = @cPalletFinalLOC --V1.1 
               -- Have permission in FromLOC
               AND EXISTS( SELECT 1
                  FROM dbo.TaskManagerUserDetail TMU WITH (NOLOCK)
                     WHERE PermissionType = TaskDetail.TaskType
                        AND TMU.UserKey = @cUserName
                        AND TMU.AreaKey = AreaDetail.AreaKey
                        AND TMU.Permission = '1')
            ORDER BY TaskDetail.Priority, 
               CASE WHEN TaskDetail.UserKeyOverRide = @cUserName THEN '0' ELSE '1' END,
               LOC.LogicalLocation, LOC.LOC
      END
      ELSE IF (@cSLLocType = 'PICK' OR @cFinalLocType = 'DYNAMICPK') AND @cFinalLocCategory = 'Shelving' --ASTRPT
      BEGIN
         SET @curRPTask = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
            SELECT
               TaskDetailKey, TaskType, FromLOC, FromID, StorerKey, SKU, LOT, QTY, ToLOC, ToID
            FROM dbo.TaskDetail WITH (NOLOCK)
            INNER JOIN dbo.LOC WITH (NOLOCK) ON (TaskDetail.FromLOC = LOC.LOC)
            INNER JOIN dbo.LOC AS LOC1 WITH (NOLOCK) ON (TaskDetail.ToLoc = LOC1.LOC)
            INNER JOIN dbo.AreaDetail WITH (NOLOCK) ON (AreaDetail.PutawayZone = LOC.PutAwayZone)
            WHERE AreaDetail.AreaKey = @cAreaKey
               AND TaskDetail.TaskType = 'RPF'
               AND TaskDetail.Status = '0'
               AND TaskDetail.UserKeyOverRide IN (@cUserName, '')
               AND TaskDetail.WaveKey = @cWaveKey
               AND LOC1.LocationType = @cFinalLocType --V1.1 
               AND TaskDetail.PickMethod = @cPickMethod -- V1.0 Should be PP
               -- Have permission in FromLOC
               AND EXISTS( SELECT 1
                  FROM dbo.TaskManagerUserDetail TMU WITH (NOLOCK)
                     WHERE PermissionType = TaskDetail.TaskType
                        AND TMU.UserKey = @cUserName
                        AND TMU.AreaKey = AreaDetail.AreaKey
                        AND TMU.Permission = '1')
            ORDER BY TaskDetail.Priority, 
               CASE WHEN TaskDetail.UserKeyOverRide = @cUserName THEN '0' ELSE '1' END,
               LOC.LogicalLocation, LOC.LOC
      END
   END

   DECLARE @nCursorStatus SMALLINT
   SELECT @nCursorStatus = CURSOR_STATUS('variable', '@curRPTask')

   IF @nCursorStatus IN (-2, -3) -- -2 Not applicable. -3 A cursor with the specified name does not exist.
   BEGIN
      SET @cNewTaskKey = ''
      GOTO CHK_TASK_KEY
   END

   OPEN @curRPTask
   WHILE (1=1)
   BEGIN
      FETCH NEXT FROM @curRPTask INTO @cNewTaskKey, @cTaskType, @cFromLOC, @cFromID, @cStorerKey, @cSKU, @cLOT, @nQTY, @cToLOC, @cToID
      IF @@FETCH_STATUS <> 0
      BEGIN
         SET @cNewTaskKey = ''
         BREAK
      END

      IF @bDebugFlag = 1
         SELECT 'Loop Tasks', @cNewTaskKey AS Task, @cFromLOC AS FromLoc, @cToLOC AS ToLoc

      -- Get ToLOC info
   	SELECT
   	   @cFacility = Facility,
   	   @cToPAZone = PutawayZone,
   	   @cToLOCAisle  = LocAisle,
	      @cToLOCCat = LocationCategory
      FROM dbo.LOC WITH (NOLOCK)
      WHERE LOC = @cToLOC

      IF @bDebugFlag = 1
         SELECT 'Check PAZone', @cToPAZone AS ToPAZone, @cFinalPAZone AS FinalPAZone
      --V1.0 Start
      -- NewTask's ToLoc PAZone must be same as the last Final Loc's PAZone
      -- Then the transit loc will be same
      IF @cToPAZone <> @cFinalPAZone
      BEGIN
         SELECT 'PAZoen not equal, next'
         CONTINUE
      END
      /*
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
      */
      --V1.0 End

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
      BEGIN
         SELECT 'Task Skipped, next'
         CONTINUE
      END

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
      BEGIN
         SELECT 'Equipment not qualified, next'
         CONTINUE
      END

      BREAK -- Exit loop if found a task
   END

CHK_TASK_KEY:
   IF @cNewTaskKey = ''
   BEGIN
      IF EXISTS( SELECT 1
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE ListKey = @cListKey
            AND Status = '5')
      BEGIN
         SET @nErrNo = 230301
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoTask.ClosePL
         GOTO Fail
      END
      ELSE
      BEGIN
         SET @nErrNo = 230302
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
   BEGIN TRY
      IF @cTransitLOC = ''
         UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
            Status     = '3'
            ,UserKey    = @cUserName
            ,ReasonKey  = ''
            ,ListKey = @cListKey --V1.0
            ,StartTime  = CURRENT_TIMESTAMP
            ,EditDate   = CURRENT_TIMESTAMP
            ,EditWho    = @cUserName
            ,TrafficCop = NULL
         WHERE TaskDetailKey = @cNewTaskKey
      ELSE
         UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
            Status     = '3'
            ,UserKey    = @cUserName
            ,ReasonKey  = ''
            ,TransitLOC = @cTransitLOC
            ,FinalLOC   = IIF(FinalLoc = '', @cToLOC, FinalLoc) --V1.1 NLT013 update FinalLoc only if FinalLoc is empty
            ,FinalID    = @cToID
            ,ToLOC      = @cTransitLOC
            ,ToID       = @cDropID
            ,ListKey    = @cListKey
            ,StartTime  = CURRENT_TIMESTAMP
            ,EditDate   = CURRENT_TIMESTAMP
            ,EditWho    = @cUserName
            ,TrafficCop = NULL
         WHERE TaskDetailKey = @cNewTaskKey
   END TRY
   BEGIN CATCH
      SET @nErrNo = 230303
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdTaskDtlFail
   END CATCH

Fail:

IF @bDebugFlag = 1
   SELECT 'Quit', @nErrNo, @cErrMsg

END
GO
GRANT EXECUTE ON  [RDT].[rdt_1764GetTask12] TO [NSQL]
GO
