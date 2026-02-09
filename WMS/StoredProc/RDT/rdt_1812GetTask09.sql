SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1812GetTask09                                   */
/* Copyright      : maersk                                              */
/*                                                                      */
/* Purpose: Get next pick task for whole area until finish              */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author    Purposes                                  */
/* 2026-02-06  1.0  NickT     FCR-10467. Created                        */
/************************************************************************/
    
CREATE OR ALTER PROC [rdt].[rdt_1812GetTask09] (
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
   DECLARE @cLoadKey       NVARCHAR( 10)
   DECLARE @cGroupKey      NVARCHAR( 10)
   DECLARE @cTaskType      NVARCHAR( 10)
   DECLARE @cPalletFinalLOC   NVARCHAR( 10)
   DECLARE @cPalletFinalZone  NVARCHAR( 10)
   DECLARE @cFinalPAZoneInLOC NVARCHAR( 10)

   SELECT @cStorerKey = StorerKey
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SET @cNewTaskKey = ''
    
   -- Get task info
   SELECT TOP 1
      @cFinalLOC = CASE WHEN FinalLOC = '' THEN ToLOC ELSE FinalLoc END
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE ListKey = @cListKey
      AND TransitCount = 0

   SELECT TOP 1    
      @cGroupKey = GroupKey
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE ListKey = @cListKey
      AND Status = '5'
      AND ISNULL(GroupKey, '') <> ''
      AND TaskType IN ('FCP', 'FCP1')
      AND UserKey = @cUserName
   ORDER BY EditDate DESC

   SET @cGroupKey = ISNULL(@cGroupKey, '-1')
    
   -- Get final LOC info
   SELECT
      @cFinalPAZone = PutawayZone,
      @cFinalAisle = LocAisle,
      @cFacility = Facility
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

   -- Get next task
   DECLARE @curRPTask CURSOR
   IF @cAreaKey = '' OR @cAreaKey = 'ALL'
      SET @curRPTask = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
         SELECT TOP 1 TD.TaskDetailKey, TD.TaskType, TD.FromLOC, TD.FromID, TD.SKU, TD.LOT, TD.QTY, TD.ToLOC, TD.ToID
         FROM dbo.TaskDetail TD WITH (NOLOCK)
         JOIN dbo.LOC WITH (NOLOCK) ON (TD.FromLOC = LOC.LOC)
         WHERE TD.TaskType IN ('FCP', 'FCP1')
            AND TD.Status = '0'
            AND TD.UserKeyOverRide IN (@cUserName, '')
            AND LOC.Facility = @cFacility
            AND TD.UserKey IN (@cUserName, '')
            AND TD.GroupKey = IIF(@cGroupKey = '-1', TD.GroupKey, @cGroupKey)
            -- AND NOT EXISTS( SELECT 1
            --    FROM TD T1 WITH (NOLOCK)
            --    WHERE TD.GroupKey <> '' 
            --       AND T1.GroupKey = TD.GroupKey 
            --       AND T1.Status < '9'
            --       AND T1.UserKey NOT IN (@cUserName, ''))
            -- AND EXISTS( SELECT 1 
            --    FROM TaskManagerUserDetail tmu WITH (NOLOCK)
            --    WHERE PermissionType = TD.TASKTYPE
            --      AND tmu.UserKey = @cUserName
            --      AND tmu.Permission = '1')
         ORDER BY
             TD.Priority
            ,CASE WHEN TD.UserKeyOverRide = @cUserName THEN '0' ELSE '1' END
            ,CASE WHEN TD.UserKey = @cUserName THEN '0' ELSE '1' END
            ,LOC.LogicalLocation
            ,LOC.LOC
            ,TD.TaskDetailKey
   ELSE    
      SET @curRPTask = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
         SELECT TOP 1 TD.TaskDetailKey, TD.TaskType, TD.FromLOC, TD.FromID, TD.SKU, TD.LOT, TD.QTY, TD.ToLOC, TD.ToID
         FROM dbo.TaskDetail TD WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) ON (TD.FromLOC = LOC.LOC)
            JOIN AreaDetail WITH (NOLOCK) ON (AreaDetail.PutawayZone = LOC.PutAwayZone)
         WHERE AreaDetail.AreaKey = @cAreaKey
            AND TD.TaskType IN ('FCP', 'FCP1')
            AND TD.Status = '0'
            AND TD.UserKey IN (@cUserName, '')
            AND TD.UserKeyOverRide IN (@cUserName, '')
            AND TD.GroupKey = IIF(@cGroupKey = '-1', TD.GroupKey, @cGroupKey)
            -- AND NOT EXISTS( SELECT 1
            --    FROM TaskDetail T1 WITH (NOLOCK)
            --    WHERE TD.GroupKey <> '' 
            --       AND T1.GroupKey = TD.GroupKey 
            --       AND T1.Status < '9'
            --       AND T1.UserKey NOT IN (@cUserName, ''))
            -- AND EXISTS( SELECT 1 
            --    FROM TaskManagerUserDetail tmu WITH (NOLOCK)
            --    WHERE PermissionType = TD.TASKTYPE
            --      AND tmu.UserKey = @cUserName
            --      AND tmu.AreaKey = @cAreaKey
            --      AND tmu.Permission = '1')
         ORDER BY
             TD.Priority
            ,CASE WHEN TD.UserKeyOverRide = @cUserName THEN '0' ELSE '1' END
            ,CASE WHEN TD.UserKey = @cUserName THEN '0' ELSE '1' END
            ,LOC.LogicalLocation
            ,LOC.LOC
            ,TD.TaskDetailKey
    
   OPEN @curRPTask
   WHILE (1=1)
   BEGIN
      FETCH NEXT FROM @curRPTask INTO @cNewTaskKey, @cTaskType, @cFromLOC, @cFromID, @cSKU, @cLOT, @nQTY, @cToLOC, @cToID
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
          @c_userid = @cUserName
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
    
   IF @cNewTaskKey = ''
   BEGIN
      IF EXISTS( SELECT 1
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE ListKey = @cListKey
            AND Status = '5')
      BEGIN
         SET @nErrNo = 258501
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Groupkey complete! CLOSE PALLET to continue
         GOTO Fail
      END
      ELSE
      BEGIN
         SET @nErrNo = 258502
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No more tas
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
      BEGIN TRY
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
      END TRY
      BEGIN CATCH
         SET @nErrNo = 258503
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update TaskDetail failed
      END CATCH
   ELSE
      BEGIN TRY
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
      END TRY
      BEGIN CATCH
         SET @nErrNo = 258504
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update TaskDetail failed
      END CATCH

Fail:
    
END 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON  [RDT].[rdt_1812GetTask09] TO [NSQL]
GO