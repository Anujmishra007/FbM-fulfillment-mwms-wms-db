SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_1764GetTask16                                         */
/* Copyright: Maersk                                                          */
/* Customer : AEOMX MEXWMS                                                    */
/*                                                                            */
/*                                                                            */
/* Date        Rev  Author    Purposes                                        */
/* 2027-07-31  1.0  NickT     FCR-14963 Create                                */
/******************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_1764GetTask16] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @cUserName        NVARCHAR( 15),
   @cAreaKey         NVARCHAR( 10),
   @cListKey         NVARCHAR( 10),
   @cDropID          NVARCHAR( 20),
   @cNewTaskKey      NVARCHAR( 10) OUTPUT,
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @bSuccess            INT,
      @bSkipTheTask        INT,
      @cGroupKey           NVARCHAR( 10),
      @cTaskType           NVARCHAR( 10),
      @cStorerKey          NVARCHAR( 10),
      @cFromLOC            NVARCHAR( 10),
      @cFromID             NVARCHAR( 18),
      @cSKU                NVARCHAR( 20),
      @cLOT                NVARCHAR( 10),
      @nQTY                INT,
      @cFacility           NVARCHAR( 5)

   SET @cNewTaskKey = ''

   SELECT 
      @cStorerKey = StorerKey, 
      @cFacility = Facility
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Get task info
   SELECT TOP 1
      @cGroupKey = ISNULL( GroupKey, '')
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE ListKey = @cListKey
      AND TaskType IN ('RPF', 'RP1')
      AND Status = '5'
   ORDER BY TaskDetailKey

   IF @cGroupKey = ''
   BEGIN
      SET @nErrNo = 276201
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Groupkey is empty
      GOTO Fail
   END
   
   -- Get next task
   DECLARE @curRPTask CURSOR
   IF @cAreaKey = ''
   BEGIN
      SET @curRPTask = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
         SELECT 
            TaskDetailKey, TaskType, FromLOC, FromID, StorerKey, SKU, LOT, QTY
         FROM dbo.TaskDetail TD WITH (NOLOCK)
         INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON (TD.FromLOC = LOC.LOC)
         INNER JOIN AreaDetail AD WITH (NOLOCK) ON (AD.PutawayZone = LOC.PutawayZone)
         WHERE LOC.Facility = @cFacility
            AND TD.TaskType IN ('RPF', 'RP1')
            AND TD.PickMethod = 'PP'
            AND TD.UserKey IN ( @cUserName, '' )
            AND TD.Status IN ( '0', '3' )
            AND TD.UserKeyOverRide IN (@cUserName, '')
            AND TD.GroupKey = @cGroupKey
            -- Have permission in FromLOC
            AND EXISTS( SELECT 1
               FROM TaskManagerUserDetail TMU WITH (NOLOCK)
               WHERE PermissionType = TD.TaskType
                  AND TMU.UserKey = @cUserName
                  AND TMU.Permission = '1')
         ORDER BY
            CASE WHEN TD.Status = '3' THEN 1 ELSE 2 END,
            CASE WHEN TD.UserKey = @cUserName THEN 1 ELSE 2 END,
            TD.Priority,
            LOC.LogicalLocation,
            CASE WHEN TD.UserKeyOverRide = @cUserName THEN 1 ELSE 2 END,
            TaskDetailKey
   END
   ELSE
   BEGIN
      SET @curRPTask = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
         SELECT 
            TaskDetailKey, TaskType, FromLOC, FromID, StorerKey, SKU, LOT, QTY
         FROM dbo.TaskDetail TD WITH (NOLOCK)
         JOIN dbo.LOC LOC WITH (NOLOCK) ON (TD.FromLOC = LOC.LOC)
         JOIN dbo.AreaDetail AD WITH (NOLOCK) ON (AD.PutawayZone = LOC.PutawayZone)
         WHERE AD.AreaKey = @cAreaKey
            AND TD.TaskType IN ('RPF', 'RP1')
            AND TD.PickMethod = 'PP' -- Partial pallet
            AND TD.UserKey IN ( @cUserName, '' )
            AND TD.Status IN ( '0', '3' )
            AND TD.UserKeyOverRide IN (@cUserName, '')
            AND TD.GroupKey = @cGroupKey 
            -- Have permission in FromLOC
            AND EXISTS( SELECT 1
               FROM TaskManagerUserDetail TMU WITH (NOLOCK)
                  WHERE PermissionType = TD.TaskType
                     AND TMU.UserKey = @cUserName
                     AND TMU.Permission = '1')
         ORDER BY 
            CASE WHEN TD.Status = '3' THEN 1 ELSE 2 END,
            CASE WHEN TD.UserKey = @cUserName THEN 1 ELSE 2 END,
            TD.Priority,
            LOC.LogicalLocation,
            CASE WHEN TD.UserKeyOverRide = @cUserName THEN 1 ELSE 2 END,
            TaskDetailKey
   END

   OPEN @curRPTask
   WHILE ( 1 = 1 )
   BEGIN
      FETCH NEXT FROM @curRPTask INTO @cNewTaskKey, @cTaskType, @cFromLOC, @cFromID, @cStorerKey, @cSKU, @cLOT, @nQTY
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

      BREAK -- Exit loop if found a task
   END

   IF @cNewTaskKey = ''
   BEGIN
      SET @nErrNo = 276202
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No more task
      GOTO Fail
   END

   BEGIN TRY
      UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
         Status     = '3',
         UserKey    = @cUserName,
         ReasonKey  = '',
         ListKey    = @cListKey,
         StartTime  = CURRENT_TIMESTAMP,
         EditDate   = CURRENT_TIMESTAMP,
         EditWho    = @cUserName,
         TrafficCop = NULL
      WHERE TaskDetailKey = @cNewTaskKey
         AND StorerKey = @cStorerKey
         AND Status IN ( '0', '3' )
   END TRY
   BEGIN CATCH
      SET @nErrNo = 276203
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to lock task
      GOTO Fail
   END CATCH

   GOTO Quit

Fail:

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1764GetTask16] TO NSQL
GO
