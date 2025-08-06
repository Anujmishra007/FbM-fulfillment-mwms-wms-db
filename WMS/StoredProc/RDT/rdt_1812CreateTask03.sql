SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1812CreateTask03                                */
/* Copyright      : Maersk WMS                                          */
/*                                                                      */
/* Purpose: Generate next task, if current task is transit for JCB      */
/*                                                                      */
/* Date       Rev    Author     Purposes                                */
/* 2025-06-10 1.0.0  Dennis     FCR-3959 Created                        */
/* 2025-06-26 1.0.1  Jackc      FCR-3959 Fill in srckey when create task*/
/*                               add update pickdetail logic            */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_1812CreateTask03] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @cUserName      NVARCHAR( 15), 
   @cListKey       NVARCHAR( 10),
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag        INT = 0

   DECLARE @nTranCount        INT
   DECLARE @nSuccess          INT
   DECLARE @cFacility         NVARCHAR( 5)
   DECLARE @cSQL              NVARCHAR( MAX)
   DECLARE @cSQLParam         NVARCHAR( MAX)
   DECLARE @cTaskDetailKey    NVARCHAR( 10)
   DECLARE @cNewTaskDetailKey NVARCHAR( 10)
   DECLARE @cStatus           NVARCHAR( 10)
   DECLARE @cWaveKey          NVARCHAR( 10)
   DECLARE @cLoadKey          NVARCHAR( 10)
   DECLARE @cStorerKey        NVARCHAR( 15)
   DECLARE @cSKU              NVARCHAR( 20)=''
   DECLARE @cLOT              NVARCHAR( 10)=''
   DECLARE @nQTY              INT
   DECLARE @cFromLOC          NVARCHAR( 10)
   DECLARE @cToLOC            NVARCHAR( 10)
   DECLARE @cToID             NVARCHAR( 18)
   DECLARE @cFinalLOC         NVARCHAR( 10)
   DECLARE @cFinalID          NVARCHAR( 18)
   DECLARE @cTransitLOC       NVARCHAR( 10)
   DECLARE @nTransitCount     INT
   DECLARE @cPriority         NVARCHAR( 10)
   DECLARE @cSourcePriority   NVARCHAR( 10)
   DECLARE @cSourceType       NVARCHAR( 30)
   DECLARE @cSkipPnDLocation  NVARCHAR( 30)
   DECLARE @c_LOCCategory     NVARCHAR(10)
   
   DECLARE @cSetTransitLoc    NVARCHAR(1) = 'N',
   @nRowCount        INT,
   @cOrderType       NVARCHAR(10),
   @cTaskType        NVARCHAR(10),
   @cUDF01           NVARCHAR(50),   
   @cOrdCompany      NVARCHAR(100)
   DECLARE @tTask TABLE
   (
      id INT IDENTITY(1,1),
      TaskDetailKey NVARCHAR(10), 
      StorerKey     NVARCHAR(15),
      SKU           NVARCHAR(20),
      QTY           INT, 
      FromLoc       NVARCHAR(10),
      ToLOC         NVARCHAR(10),
      ToID          NVARCHAR(18),
      FinalLOC      NVARCHAR(10),
      FinalID       NVARCHAR(18),
      TransitLOC    NVARCHAR(10),
      TransitCount  INT,
      TaskType      NVARCHAR(10),
      Priority      NVARCHAR(10),
      SourcePriority NVARCHAR(10),
      RefTaskKey    NVARCHAR(10),  
      OrderKey      NVARCHAR(10)
   )
   DECLARE @nLoopIndex INT = -1
   DECLARE @cOrderKey   NVARCHAR( 10)
   DECLARE @cDefaultMarshLane NVARCHAR(10)
   DECLARE @cDefaultKittingLoc NVARCHAR(10)
   DECLARE @cToLOCAreaKey NVARCHAR(10)
   DECLARE @cToLOCPAZone NVARCHAR(10)
   DECLARE @cRefTaskKey NVARCHAR(10)

   -- Init var
   SET @nErrNo = 0
   SET @cErrMsg = ''

   IF @nDebugFlag = 1
      SELECT 'Running rdt_1812CreateTask03',  @cUserName AS UserName, @cListKey AS ListKey

   SELECT @cFacility = Facility
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   -- Get ToLOC from latest transit task
   SELECT TOP 1 
      @cWaveKey        = WaveKey, 
      @cLoadKey        = LoadKey, 
      @cStorerKey      = StorerKey, 
      @cStatus         = Status, 
      @cToLOC          = ToLOC, 
      @cToID           = ToID, 
      @nQTY            = QTY, 
      @nTransitCount   = TransitCount, 
      @cPriority       = Priority, 
      @cSourcePriority = SourcePriority, 
      @cSourceType     = 'rdt_1812CreateTask03'
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE ListKey = @cListKey
   AND UserKey = @cUserName
   ORDER BY TransitCount DESC

   SET @cToLOCPAZone = ''
   SET @cToLOCAreaKey = ''
   SELECT @cToLOCPAZone = PutawayZone FROM LOC WITH (NOLOCK) WHERE LOC = @cToLOC
   SELECT @cToLOCAreaKey = AreaKey FROM AreaDetail WITH (NOLOCK) WHERE PutawayZone = @cToLOCPAZone

   IF @nDebugFlag = 1
      SELECT 'ToLoc info', @cToLOC AS ToLoc, @cToLOCPAZone AS ToLocPAZone, @cToLOCAreaKey AS ToLocAreaKey 
   /***********************************************************************************************
                                             Standard confirm
   ***********************************************************************************************/

   -- Task not completed/SKIP/CANCEL
   IF @cStatus <> '9'
      RETURN

   -- Get initial task info
   INSERT INTO @tTask (TaskDetailKey, StorerKey, SKU, QTY, FromLoc, ToLOC, ToID, FinalLOC, FinalID,TaskType,OrderKey,TransitCount, Priority, SourcePriority,RefTaskKey)
   SELECT TaskDetailKey, StorerKey, SKU, QTY, FromLoc, @cToLOC, @cToID, FinalLOC, FinalID,TaskType,OrderKey,TransitCount, Priority, SourcePriority,RefTaskKey
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE ListKey = @cListKey
   AND UserKey = @cUserName
   AND TaskType IN ('FCP','FCP1')
   AND Status = '9'

   IF @nDebugFlag = 1
   BEGIN
      SELECT '@tTask'
      SELECT * FROM @tTask
   END

   WHILE(1=1)
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Loop @tTask'

      SELECT TOP 1
         @nLoopIndex      = ID,
         @cTaskDetailKey  = TaskDetailKey,
         @cToLOC          = ToLOC, 
         @cToID           = ToID, 
         @nQTY            = QTY, 
         @nTransitCount   = TransitCount, 
         @cPriority       = Priority, 
         @cSourcePriority = SourcePriority, 
         @cTaskType       = TaskType,
         @cOrderKey       = OrderKey,
         @cRefTaskKey     = RefTaskKey,
         @cSourceType     = 'rdt_1812CreateTask03'
      FROM @tTask
      WHERE ID > @nLoopIndex
      ORDER BY ID

      SELECT @nRowCount = @@ROWCOUNT

      IF @nRowCount = 0
         BREAK

      IF @nDebugFlag = 1
         SELECT 'Handling task', @nLoopIndex+1 AS RowNumber, @cTaskDetailKey AS TaskDetailKey

      --Get Order info
      SELECT TOP 1
         @cOrderType = [type],
         @cOrdCompany = c_company
      FROM dbo.TaskDetail TD WITH (NOLOCK)
      JOIN dbo.ORDERS ORD WITH (NOLOCK)
         ON TD.OrderKey = ORD.OrderKey
      WHERE TD.TaskDetailKey = @cTaskDetailKey

      SELECT TOP 1 
         @cUDF01 = ISNULL(UDF01,''),
         @cDefaultKittingLoc = LOC.LOC
      FROM dbo.CodeLKUP CL WITH (NOLOCK)
      JOIN dbo.LOC LOC WITH (NOLOCK) ON CL.LONG = LOC.LocationCategory
      WHERE CL.LISTNAME = 'JCBKITORDT'
         AND CL.Short = 'Y'
         AND CL.Code = @cOrderType
         AND StorerKey = @cStorerKey
      ORDER BY CASE WHEN LOC.STATUS <> 'OK' OR LOC.LocationFLAG NOT IN ('','NONE') THEN 2 ELSE 1 END, LOC.LogicalLocation,LOC.LOC

      SET @nRowCount = @@ROWCOUNT

      IF @nDebugFlag = 1
         SELECT 'OrderInfo', @cOrderType AS OrderType, @cOrdCompany AS Company, @cUDF01 AS RequireKit, @cDefaultKittingLoc AS DefKitLoc

      IF @nRowCount = 0
      BEGIN--Non kitting orders
         IF @nDebugFlag = 1
            SELECT 'Non Kitting orders'

         IF EXISTS(SELECT 1 FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cToLOC AND LocationCategory = 'PND_OUT') AND @cTaskType = 'FCP'
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'PND_OUT logic'

            SELECT TOP 1  @cDefaultMarshLane = L.LOC
            FROM dbo.CODELKUP CL WITH (NOLOCK)
            JOIN dbo.LOC L WITH (NOLOCK) ON CL.SHORT = L.LOC
            WHERE CL.LISTNAME = 'JCBCOMPML'
               AND CL.LONG = @cOrdCompany
               AND CL.Storerkey = @cStorerKey
            ORDER BY CASE WHEN L.STATUS <> 'OK' OR L.LocationFLAG NOT IN ('','NONE') THEN 2 ELSE 1 END, L.LogicalLocation,LOC

            IF ISNULL(@cDefaultMarshLane,'') = ''
            BEGIN
               SET @nErrNo = 240951
               SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') --No default marshaling lane
               GOTO Fail
            END

            SET @nSuccess = 0
            EXECUTE dbo.nspg_getkey
               'TASKDETAILKEY'
               , 10
               , @cNewTaskDetailKey OUTPUT
               , @nSuccess          OUTPUT
               , @nErrNo            OUTPUT
               , @cErrMsg           OUTPUT
            IF @nSuccess <> 1
            BEGIN
               SET @nErrNo = 240952
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
               GOTO RollBackTran
            END

            INSERT INTO TaskDetail (
               TaskDetailKey, TaskType, Status, UserKey, FromLOC, FromID, ToLOC, ToID, QTY, AreaKey, FinalLOC,OrderKey,
               PickMethod, StorerKey, SKU, LOT, ListKey, TransitCount, SourceType, WaveKey, LoadKey, Priority, SourcePriority, TrafficCop,
               SourceKey,RefTaskKey)
            VALUES (
               @cNewTaskDetailKey, 'FCP1', '0', '', @cToLOC, @cToID, @cDefaultMarshLane, @cToID, 0, @cToLOCAreaKey, @cDefaultMarshLane,@cOrderKey,
               'FP', @cStorerKey, @cSKU, @cLOT, '', @nTransitCount+1, @cSourceType, @cWaveKey, @cLoadKey, @cPriority, @cSourcePriority, NULL,
               @cTaskDetailKey,@cRefTaskKey)
         END --PND_out
      END --non kitting order
      ELSE -- Kitting orders
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Kitting orders'

         IF EXISTS(SELECT 1 FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cToLOC AND LocationCategory = 'PND_OUT')
         BEGIN--TO LOC = PND
            IF @nDebugFlag = 1
               SELECT 'ToLoc is PND'
 
            IF @cTaskType = 'FCP'
            BEGIN
               IF @cUDF01 IN ('Y','H')
               BEGIN
                  IF @nDebugFlag = 1
                     SELECT 'Kitting location logic'

                  SELECT @cStatus = CASE WHEN @cUDF01 = 'Y' THEN '0' ELSE 'H' END
                  
                  IF ISNULL(@cDefaultKittingLoc,'') = ''
                  BEGIN
                     SET @nErrNo = 240953
                     SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') --Cannot Find a valid Kitting LOC
                     GOTO Fail
                  END

                  SET @nSuccess = 0
                  EXECUTE dbo.nspg_getkey
                     'TASKDETAILKEY'
                     , 10
                     , @cNewTaskDetailKey OUTPUT
                     , @nSuccess          OUTPUT
                     , @nErrNo            OUTPUT
                     , @cErrMsg           OUTPUT
                  IF @nSuccess <> 1
                  BEGIN
                     SET @nErrNo = 240954
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
                     GOTO RollBackTran
                  END

                  INSERT INTO TaskDetail (
                     TaskDetailKey, TaskType, Status, UserKey, FromLOC, FromID, ToLOC, ToID, QTY, AreaKey, FinalLOC,OrderKey,
                     PickMethod, StorerKey, SKU, LOT, ListKey, TransitCount, SourceType, WaveKey, LoadKey, Priority, SourcePriority, TrafficCop,
                     SourceKey,RefTaskKey)
                  VALUES (
                     @cNewTaskDetailKey, 'FCP1', @cStatus, '', @cToLOC, @cToID, @cDefaultKittingLoc, @cToID, 0, @cToLOCAreaKey, @cDefaultKittingLoc,@cOrderKey,
                     'FP', @cStorerKey, @cSKU, @cLOT, '', @nTransitCount+1, @cSourceType, @cWaveKey, @cLoadKey, @cPriority, @cSourcePriority, NULL,
                     @cTaskDetailKey,@cRefTaskKey)
               END --UDF = Y, H
               ELSE --V1.0.1
               BEGIN
                  IF @nDebugFlag = 1
                     SELECT 'MarshallingLane logic'

                  SELECT TOP 1  @cDefaultMarshLane = L.LOC
                  FROM dbo.CODELKUP CL WITH (NOLOCK)
                  JOIN dbo.LOC L WITH (NOLOCK) ON CL.SHORT = L.LOC
                  WHERE CL.LISTNAME = 'JCBCOMPML'
                     AND CL.LONG = @cOrdCompany
                     AND CL.Storerkey = @cStorerKey
                  ORDER BY CASE WHEN L.STATUS <> 'OK' OR L.LocationFLAG NOT IN ('','NONE') THEN 2 ELSE 1 END, L.LogicalLocation,LOC

                  IF ISNULL(@cDefaultMarshLane,'') = ''
                  BEGIN
                     SET @nErrNo = 240955
                     SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') --No default marshaling lane
                     GOTO Fail
                  END

                  SET @nSuccess = 0
                  EXECUTE dbo.nspg_getkey
                     'TASKDETAILKEY'
                     , 10
                     , @cNewTaskDetailKey OUTPUT
                     , @nSuccess          OUTPUT
                     , @nErrNo            OUTPUT
                     , @cErrMsg           OUTPUT
                  IF @nSuccess <> 1
                  BEGIN
                     SET @nErrNo = 240956
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
                     GOTO RollBackTran
                  END

                  INSERT INTO TaskDetail (
                     TaskDetailKey, TaskType, Status, UserKey, FromLOC, FromID, ToLOC, ToID, QTY, AreaKey, FinalLOC,OrderKey,
                     PickMethod, StorerKey, SKU, LOT, ListKey, TransitCount, SourceType, WaveKey, LoadKey, Priority, SourcePriority, TrafficCop,
                     SourceKey,RefTaskKey)
                  VALUES (
                     @cNewTaskDetailKey, 'FCP1', '0', '', @cToLOC, @cToID, @cDefaultMarshLane, @cToID, 0, @cToLOCAreaKey, @cDefaultMarshLane,@cOrderKey,
                     'FP', @cStorerKey, @cSKU, @cLOT, '', @nTransitCount+1, @cSourceType, @cWaveKey, @cLoadKey, @cPriority, @cSourcePriority, NULL,
                     @cTaskDetailKey,@cRefTaskKey)
               END--UDF = N
            END
         END --PND
         ELSE--NOT PND
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'ToLoc not PND'

            IF @cTaskType = 'FCP'
            BEGIN
               IF @cUDF01 IN ('Y','H')
               BEGIN
                  SELECT @cStatus = CASE WHEN @cUDF01 = 'Y' THEN '0' ELSE 'H' END

                  SELECT TOP 1  @cDefaultMarshLane = L.LOC
                  FROM dbo.CODELKUP CL WITH (NOLOCK)
                  JOIN dbo.LOC L WITH (NOLOCK) ON CL.SHORT = L.LOC
                  WHERE CL.LISTNAME = 'JCBCOMPML'
                     AND CL.LONG = @cOrdCompany
                     AND CL.Storerkey = @cStorerKey
                  ORDER BY CASE WHEN L.STATUS <> 'OK' OR L.LocationFLAG NOT IN ('','NONE') THEN 2 ELSE 1 END, L.LogicalLocation,LOC

                  IF ISNULL(@cDefaultMarshLane,'') = ''
                  BEGIN
                     SET @nErrNo = 240957
                     SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') --No default marshaling lane
                     GOTO Fail
                  END

                  SET @nSuccess = 0
                  EXECUTE dbo.nspg_getkey
                     'TASKDETAILKEY'
                     , 10
                     , @cNewTaskDetailKey OUTPUT
                     , @nSuccess          OUTPUT
                     , @nErrNo            OUTPUT
                     , @cErrMsg           OUTPUT
                  IF @nSuccess <> 1
                  BEGIN
                     SET @nErrNo = 240958
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
                     GOTO RollBackTran
                  END

                  INSERT INTO TaskDetail (
                     TaskDetailKey, TaskType, Status, UserKey, FromLOC, FromID, ToLOC, ToID, QTY, AreaKey, FinalLOC,OrderKey,
                     PickMethod, StorerKey, SKU, LOT, ListKey, TransitCount, SourceType, WaveKey, LoadKey, Priority, SourcePriority, TrafficCop,
                     SourceKey,RefTaskKey)
                  VALUES (
                     @cNewTaskDetailKey, 'FCP1', @cStatus, '', @cToLOC, @cToID, @cDefaultMarshLane, @cToID, 0, @cToLOCAreaKey, @cDefaultMarshLane,@cOrderKey,
                     'FP', @cStorerKey, @cSKU, @cLOT, '', @nTransitCount+1, @cSourceType, @cWaveKey, @cLoadKey, @cPriority, @cSourcePriority, NULL,
                     @cTaskDetailKey,@cRefTaskKey)
               END --UDF1=Y,H
            END
            ELSE IF @cTaskType = 'FCP1' AND EXISTS
                     (SELECT 1 
                     FROM dbo.CodeLKUP CL WITH (NOLOCK)
                     JOIN dbo.LOC WITH (NOLOCK)
                        ON CL.LONG = LOC.LocationCategory AND LOC.LOC = @cToLOC
                     WHERE CL.LISTNAME = 'JCBKITORDT'
                        AND CL.Short = 'Y'
                        AND CL.Code = @cOrderType)
            BEGIN
               SELECT TOP 1  @cDefaultMarshLane = L.LOC
               FROM dbo.CODELKUP CL WITH (NOLOCK)
               JOIN dbo.LOC L WITH (NOLOCK) ON CL.SHORT = L.LOC
               WHERE CL.LISTNAME = 'JCBCOMPML'
                  AND CL.LONG = @cOrdCompany
                  AND CL.Storerkey = @cStorerKey
               ORDER BY CASE WHEN L.STATUS <> 'OK' OR L.LocationFLAG NOT IN ('','NONE') THEN 2 ELSE 1 END, L.LogicalLocation,LOC

               IF ISNULL(@cDefaultMarshLane,'') = ''
               BEGIN
                  SET @nErrNo = 240959
                  SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') --No default marshaling lane
                  GOTO Fail
               END

               SET @nSuccess = 0
               EXECUTE dbo.nspg_getkey
                  'TASKDETAILKEY'
                  , 10
                  , @cNewTaskDetailKey OUTPUT
                  , @nSuccess          OUTPUT
                  , @nErrNo            OUTPUT
                  , @cErrMsg           OUTPUT
               IF @nSuccess <> 1
               BEGIN
                  SET @nErrNo = 240960
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
                  GOTO RollBackTran
               END

               INSERT INTO TaskDetail (
                  TaskDetailKey, TaskType, Status, UserKey, FromLOC, FromID, ToLOC, ToID, QTY, AreaKey, FinalLOC,OrderKey,
                  PickMethod, StorerKey, SKU, LOT, ListKey, TransitCount, SourceType, WaveKey, LoadKey, Priority, SourcePriority, TrafficCop,
                  SourceKey,RefTaskKey)
               VALUES (
                  @cNewTaskDetailKey, 'FCP1', '0', '', @cToLOC, @cToID, @cDefaultMarshLane, @cToID, 0, @cToLOCAreaKey, @cDefaultMarshLane,@cOrderKey,
                  'FP', @cStorerKey, @cSKU, @cLOT, '', @nTransitCount+1, @cSourceType, @cWaveKey, @cLoadKey, @cPriority, @cSourcePriority, NULL,
                  @cTaskDetailKey,@cRefTaskKey)
            END --Marshelling lane
         END --not pnd
      END --Kitting orders

      --V1.0.1 start

      IF EXISTS (
         SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE TaskDetailKey = @cNewTaskDetailKey)
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Redirect pickdetail to new task', @cTaskDetailKey AS OldTask, @cNewTaskDetailKey AS NewTask

         BEGIN TRY
            UPDATE dbo.PickDetail WITH (ROWLOCK)
            SET
               TaskDetailKey = @cNewTaskDetailKey
            WHERE StorerKey = @cStorerKey
               AND TaskDetailKey = @cTaskDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 240961
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
            GOTO RollBackTran
         END CATCH
      END

      SET @cNewTaskDetailKey = '' 
      --V1.0.1 end
   END --END while

   GOTO Quit

   RollBackTran:
   Fail:

   Quit:
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Quit', @nErrNo AS ErrNO, @cErrMsg AS ErrMsg
      END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1812CreateTask03] TO NSQL
GO
