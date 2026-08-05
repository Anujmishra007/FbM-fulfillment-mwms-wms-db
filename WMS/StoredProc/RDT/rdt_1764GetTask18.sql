
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1764GetTask18                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Get next replenish task grouped by VNA aisle and ToLoc type */
/*          copy from rdt_1764GetTask05                                 */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author    Purposes                                  */
/* 04-Aug-2026 1.0  NYE018    FCR-14574 Create                          */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_1764GetTask18] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @cUserName        NVARCHAR( 15),
   @cAreaKey         NVARCHAR( 10),
   @cListKey         NVARCHAR( 10),
   @cDropID          NVARCHAR( 20),
   @cNewTaskKey      NVARCHAR( 10)    OUTPUT,
   @nErrNo           INT          OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT  -- screen limitation, 20 char max
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @bSuccess                INT
   DECLARE @bSkipTheTask            INT
   DECLARE @cFacility               NVARCHAR( 5)
   DECLARE @cToLOC                  NVARCHAR( 10)
   DECLARE @cFromLOC                NVARCHAR( 10)
   DECLARE @cFromID                 NVARCHAR( 18)
   DECLARE @cStorerKey              NVARCHAR( 10)
   DECLARE @cSKU                    NVARCHAR( 20)
   DECLARE @cLOT                    NVARCHAR( 10)
   DECLARE @nQTY                    INT
   DECLARE @cToID                   NVARCHAR( 18)
   DECLARE @cTaskType               NVARCHAR( 10)
   DECLARE @nMaxCartons             INT
   DECLARE @cResult                 NVARCHAR( 10)
   DECLARE @nTotCtn                 INT

   -- VNA aisle grouping variables
   DECLARE @cFirstFromLOC           NVARCHAR( 10)
   DECLARE @cFirstFromAisle         NVARCHAR( 10)
   DECLARE @cFirstFromLocType       NVARCHAR( 10)
   DECLARE @cFirstFromPAZone        NVARCHAR( 10)
   DECLARE @bIsVNAAisle             INT
   DECLARE @cFirstToLOC             NVARCHAR( 10)
   DECLARE @cFirstToLocType         NVARCHAR( 10)
   DECLARE @cFirstToPAZone          NVARCHAR( 10)
   DECLARE @bFirstToConveyor        INT
   DECLARE @nFirstPriority          INT
   DECLARE @nReplenGroupByPriority  INT

   SET @cNewTaskKey = ''
   SET @bIsVNAAisle = 0
   SET @bFirstToConveyor = 0
   SET @nReplenGroupByPriority = 0
   SET @nFirstPriority = 0
   SET @cFirstFromAisle = ''
   SET @cFacility = ''

   SELECT @cStorerKey = StorerKey
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Check max cartons
   SET @cResult = ''
   SET @cResult = rdt.RDTGetConfig( 1764, 'MaxCartons', @cStorerkey)
   IF ISNUMERIC(@cResult) = 1 AND @cResult NOT IN ('', '0')
   BEGIN
      SET @nMaxCartons = CAST(@cResult AS INT)

      SET @nTotCtn = 0
      SELECT @nTotCtn = COUNT(DISTINCT UCCNo)
      FROM rdt.rdtRPFLog WITH (NOLOCK)
      WHERE DropID = @cDropID

      IF @nTotCtn + 1 > @nMaxCartons
      BEGIN
         SET @nErrNo = 276801
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Exceed Max Ctns
         GOTO Fail
      END
   END

   -- Get first assigned task info (TransitCount = 0 = initial task on this pallet)
   SELECT TOP 1
      @cFirstFromLOC  = FromLOC,
      @cFirstToLOC    = CASE WHEN FinalLOC = '' THEN ToLOC ELSE FinalLOC END,
      @nFirstPriority = Priority
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE ListKey = @cListKey
      AND TransitCount = 0

   -- Get first task FromLoc location info to determine VNA aisle
   SELECT
      @cFacility         = Facility,
      @cFirstFromAisle   = LocAisle,
      @cFirstFromLocType = LocationType,
      @cFirstFromPAZone  = PutawayZone
   FROM dbo.LOC WITH (NOLOCK)
   WHERE LOC = @cFirstFromLOC

   -- Determine if first task FromLoc is a VNA aisle
   -- VNA aisle: LocationType = 'CASE' and PutawayZone in VNA source zones
   IF @cFirstFromLocType = 'CASE' AND @cFirstFromPAZone IN ('CSCAP1','CSCEA1','CSCFW1')
      SET @bIsVNAAisle = 1

   -- Get first task ToLoc info to determine CONVEYOR vs non-CONVEYOR grouping
   SELECT
      @cFirstToLocType = LocationType,
      @cFirstToPAZone  = PutawayZone
   FROM dbo.LOC WITH (NOLOCK)
   WHERE LOC = @cFirstToLOC

   -- CONVEYOR: LocationType = 'OTHER' and PutawayZone in conveyor zone
   IF @cFirstToLocType = 'OTHER' AND @cFirstToPAZone IN ('CSCCNVYR')
      SET @bFirstToConveyor = 1

   -- Get ReplenGroupByPriority storer config
   -- SValue = 1: group only tasks with same Priority; SValue = 0: no priority restriction
   SET @cResult = ''
   SET @cResult = rdt.RDTGetConfig( 1764, 'ReplenGroupByPriority', @cStorerKey)
   IF ISNUMERIC(@cResult) = 1
      SET @nReplenGroupByPriority = CAST(@cResult AS INT)

   -- Get next task
   DECLARE @curRPTask CURSOR
   IF @cAreaKey = ''
      SET @curRPTask = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
         SELECT
            TaskDetailKey, TaskType, FromLOC, FromID, StorerKey, SKU, LOT, QTY, ToLOC, ToID
         FROM dbo.TaskDetail WITH (NOLOCK)
            INNER JOIN dbo.LOC LOC1 WITH (NOLOCK) ON (TaskDetail.FromLOC = LOC1.LOC)
            INNER JOIN dbo.LOC LOC2 WITH (NOLOCK) ON (TaskDetail.ToLOC = LOC2.LOC)
            INNER JOIN dbo.AreaDetail WITH (NOLOCK) ON (AreaDetail.PutawayZone = LOC1.PutAwayZone)
         WHERE TaskDetail.TaskType IN ('RPF')
            AND TaskDetail.PickMethod = 'PP' -- Partial pallet
            AND TaskDetail.Status = '0'
            AND TaskDetail.UserKeyOverRide IN (@cUserName, '')
            -- Must be from same VNA aisle as first task (LOC1 = FromLoc)
            AND LOC1.LocationType = 'CASE'
            AND LOC1.PutawayZone IN ('CSCAP1','CSCEA1','CSCFW1')
            AND LOC1.LocAisle = @cFirstFromAisle
            AND LOC1.LocAisle <> ''
            -- ToLoc type must match first task: all CONVEYOR or all non-CONVEYOR
            AND (
               (  @bFirstToConveyor = 1
                  AND LOC2.LocationType = 'OTHER'
                  AND LOC2.PutawayZone IN ('CSCCNVYR'))
               OR
               (  @bFirstToConveyor = 0
                  AND LOC2.LocationType IN ('PICK','DYNPPICK')
                  AND LOC2.PutawayZone IN ('CSCAP2','CSCEA2','CSCFW2'))
            )
            -- Priority grouping: ReplenGroupByPriority=1 restricts to same priority as first task
            AND TaskDetail.Priority = CASE WHEN @nReplenGroupByPriority = 1
                                          THEN @nFirstPriority
                                          ELSE TaskDetail.Priority
                                     END
            -- User must have RPF permission
            AND EXISTS( SELECT 1
               FROM dbo.TaskManagerUserDetail TMU WITH (NOLOCK)
               WHERE PermissionType = TaskDetail.TaskType
                  AND TMU.UserKey = @cUserName
                  AND TMU.Permission = '1')
            -- VNA aisle lock: only 1 user per VNA aisle at any given time
            AND NOT EXISTS( SELECT 1
               FROM dbo.TaskDetail TD WITH (NOLOCK)
                  JOIN dbo.LOC LOC3 WITH (NOLOCK) ON LOC3.LOC = TD.FromLOC
               WHERE LOC3.Facility = @cFacility
                  AND LOC3.LocAisle = LOC1.LocAisle
                  AND LOC3.LocationType = 'CASE'
                  AND LOC3.PutawayZone IN ('CSCAP1','CSCEA1','CSCFW1')
                  AND LOC3.LocAisle <> ''
                  AND TD.Status > '0' AND TD.Status < '9'
                  AND TD.UserKey <> @cUserName)
         ORDER BY
             TaskDetail.Priority
            ,CASE WHEN TaskDetail.UserKeyOverRide = @cUserName THEN '0' ELSE '1' END
            ,LOC1.LogicalLocation
            ,LOC1.LOC
   ELSE
      SET @curRPTask = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
         SELECT
            TaskDetailKey, TaskType, FromLOC, FromID, StorerKey, SKU, LOT, QTY, ToLOC, ToID
         FROM dbo.TaskDetail WITH (NOLOCK)
            INNER JOIN dbo.LOC LOC1 WITH (NOLOCK) ON (TaskDetail.FromLOC = LOC1.LOC)
            INNER JOIN dbo.LOC LOC2 WITH (NOLOCK) ON (TaskDetail.ToLOC = LOC2.LOC)
            INNER JOIN dbo.AreaDetail WITH (NOLOCK) ON (AreaDetail.PutawayZone = LOC1.PutAwayZone)
         WHERE AreaDetail.AreaKey = @cAreaKey
            AND TaskDetail.TaskType IN ('RPF')
            AND TaskDetail.PickMethod = 'PP' -- Partial pallet
            AND TaskDetail.Status = '0'
            AND TaskDetail.UserKeyOverRide IN (@cUserName, '')
            -- Must be from same VNA aisle as first task (LOC1 = FromLoc)
            AND LOC1.LocationType = 'CASE'
            AND LOC1.PutawayZone IN ('CSCAP1','CSCEA1','CSCFW1')
            AND LOC1.LocAisle = @cFirstFromAisle
            AND LOC1.LocAisle <> ''
            -- ToLoc type must match first task: all CONVEYOR or all non-CONVEYOR
            AND (
               (  @bFirstToConveyor = 1
                  AND LOC2.LocationType = 'OTHER'
                  AND LOC2.PutawayZone IN ('CSCCNVYR'))
               OR
               (  @bFirstToConveyor = 0
                  AND LOC2.LocationType IN ('PICK','DYNPPICK')
                  AND LOC2.PutawayZone IN ('CSCAP2','CSCEA2','CSCFW2'))
            )
            -- Priority grouping: ReplenGroupByPriority=1 restricts to same priority as first task
            AND TaskDetail.Priority = CASE WHEN @nReplenGroupByPriority = 1
                                          THEN @nFirstPriority
                                          ELSE TaskDetail.Priority
                                     END
            -- User must have RPF permission
            AND EXISTS( SELECT 1
               FROM dbo.TaskManagerUserDetail TMU WITH (NOLOCK)
               WHERE PermissionType = TaskDetail.TaskType
                  AND TMU.UserKey = @cUserName
                  AND TMU.Permission = '1')
            -- VNA aisle lock: only 1 user per VNA aisle at any given time
            AND NOT EXISTS( SELECT 1
               FROM dbo.TaskDetail TD WITH (NOLOCK)
                  JOIN dbo.LOC LOC3 WITH (NOLOCK) ON LOC3.LOC = TD.FromLOC
               WHERE LOC3.Facility = @cFacility
                  AND LOC3.LocAisle = LOC1.LocAisle
                  AND LOC3.LocationType = 'CASE'
                  AND LOC3.PutawayZone IN ('CSCAP1','CSCEA1','CSCFW1')
                  AND LOC3.LocAisle <> ''
                  AND TD.Status > '0' AND TD.Status < '9'
                  AND TD.UserKey <> @cUserName)
         ORDER BY
             TaskDetail.Priority
            ,CASE WHEN TaskDetail.UserKeyOverRide = @cUserName THEN '0' ELSE '1' END
            ,LOC1.LogicalLocation
            ,LOC1.LOC

   OPEN @curRPTask
   WHILE (1=1)
   BEGIN
      FETCH NEXT FROM @curRPTask INTO @cNewTaskKey, @cTaskType, @cFromLOC, @cFromID, @cStorerKey, @cSKU, @cLOT, @nQTY, @cToLOC, @cToID
      IF @@FETCH_STATUS <> 0
      BEGIN
         SET @cNewTaskKey = ''
         BREAK
      END

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

      BREAK -- Exit loop when valid task found
   END

   IF @cNewTaskKey = ''
   BEGIN
      IF EXISTS( SELECT 1
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE ListKey = @cListKey
            AND Status = '5')
      BEGIN
         SET @nErrNo = 276802
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- NoTask.ClosePL
         GOTO Fail
      END
      ELSE
      BEGIN
         SET @nErrNo = 276803
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No more task
         GOTO Fail
      END
   END

   -- Get Transit location from initial task
   DECLARE @cTransitLOC NVARCHAR( 10)
   SELECT @cTransitLOC = TransitLOC
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE ListKey = @cListKey
      AND TransitCount = 0 -- initial task

   -- Update new task to in-progress
   BEGIN TRY
      IF @cTransitLOC = ''
         UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
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
         UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
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
   END TRY
   BEGIN CATCH
      SET @nErrNo = 276804
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdTaskDtlFail
      GOTO Fail
   END CATCH

Fail:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1764GetTask18] TO NSQL
GO
