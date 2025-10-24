SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_1764CreateTask14                                      */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: For JCB                                                           */
/*                                                                            */
/* Called from:                                                               */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date       Rev    Author     Purposes                                      */
/* 2025-06-11 1.0.0  Dennis     FCR-3959 Created                              */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1764CreateTask14] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @cUserName      NVARCHAR( 15),
   @cListKey       NVARCHAR( 10),
   @nErrNo         INT          OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @bDebugFlag        BINARY = 0

   DECLARE @cSQL              NVARCHAR( MAX)
   DECLARE @cSQLParam         NVARCHAR( MAX)
   DECLARE @nTranCount        INT
   DECLARE @nRowCount         INT
   DECLARE @nSuccess          INT
   
   DECLARE @cTaskDetailKey    NVARCHAR( 10)
   DECLARE @cPickDetailKey    NVARCHAR( 10)
   DECLARE @cNewTaskDetailKey NVARCHAR( 10)
   DECLARE @cWaveKey          NVARCHAR( 10)
   DECLARE @cStorerKey        NVARCHAR( 15)
   DECLARE @cSKU              NVARCHAR( 20)=''
   DECLARE @cLOT              NVARCHAR( 10)=''
   DECLARE @nQTY              INT
   DECLARE @nSystemQTY        INT
   DECLARE @cToLOC            NVARCHAR( 10)
   DECLARE @cLogicalToLOC     NVARCHAR( 20)
   DECLARE @cToID             NVARCHAR( 18)
   DECLARE @cCaseID           NVARCHAR( 20)
   DECLARE @cFinalLOC         NVARCHAR( 10)
   DECLARE @cFinalID          NVARCHAR( 18)
   DECLARE @cTransitLOC       NVARCHAR( 10)
   DECLARE @nTransitCount     INT
   DECLARE @cUOM              NVARCHAR( 5)
   DECLARE @nUOMQty           INT
   DECLARE @cPriority         NVARCHAR( 10)
   DECLARE @cSourcePriority   NVARCHAR( 10)
   DECLARE @cSourceType       NVARCHAR( 30)
   DECLARE @cOrgTaskKey       NVARCHAR( 30)
   DECLARE @cRefTaskKey       NVARCHAR( 10)
   DECLARE @cPickMethod       NVARCHAR( 10)
   DECLARE @cTaskType         NVARCHAR( 10)

   DECLARE @cNewTaskStatus    NVARCHAR( 10)

   DECLARE @cFinalLocType     NVARCHAR( 10)
   DECLARE @cSLLocType        NVARCHAR( 10)
   DECLARE @cFinalLocCategory NVARCHAR( 10)
   DECLARE @cFinalLOCAreaKey  NVARCHAR( 10)
   DECLARE @cFinalLogicalLoc  NVARCHAR( 18)
   
   DECLARE @nCounter          INT
   DECLARE @nMax              INT
   DECLARE @cReplenByRPT      NVARCHAR( 1)
   DECLARE @cOrderKey         NVARCHAR(10)
   DECLARE @cLoadKey          NVARCHAR(10)
   DECLARE @nPABookingKey     INT = 0
   DECLARE @cToLOCAreaKey NVARCHAR(10)
   DECLARE @cToLOCPAZone NVARCHAR(10),
   @cSourceKey      NVARCHAR(30)
   SET @cToLOCPAZone = ''
   SET @cToLOCAreaKey = ''

   -- Init var
   SET @nErrNo = 0
   SET @cErrMsg = ''

   DECLARE @tTask TABLE
   (
      RowNumber      INT IDENTITY,
      TaskDetailKey  NVARCHAR(10),
      STATUS         NVARCHAR(10),
      Priority       NVARCHAR(10),
      SourcePriority NVARCHAR(10),
      StorerKey      NVARCHAR(15),
      SKU            NVARCHAR(20),
      LOT            NVARCHAR(10),
      UOM            NVARCHAR(5),
      UOMQty         INT,     
      QTY            INT,
      ToLOC          NVARCHAR(10),
      LogicalToLOC   NVARCHAR(20),
      ToID           NVARCHAR(18),
      CaseID         NVARCHAR(20),
      FinalLOC       NVARCHAR(10),
      FinalID        NVARCHAR(18),
      TransitCount   INT,
      PickMethod     NVARCHAR(10),
      RefTaskKey     NVARCHAR(10),
      WaveKey        NVARCHAR(10),
      SystemQTY      INT,
      OrderKey       NVARCHAR(10),
      SourceKey      NVARCHAR(30),
      TaskType       NVARCHAR(10),
      LoadKey        NVARCHAR(10)
   )

   -- Get initial task info
   INSERT INTO @tTask (TaskDetailKey, Status, StorerKey, SKU, LOT, UOM, UOMQty, QTY, ToLOC, LogicalToLOC, ToID, CaseID, FinalLoc, FinalID, 
                        TransitCount, PickMethod, RefTaskKey, WaveKey, Priority, SourcePriority, SystemQTY,OrderKey,LoadKey, SourceKey,TaskType)
      SELECT TaskDetailKey, Status, StorerKey, SKU, LOT, UOM, UOMQty, Qty, ToLOC, LogicalToLoc, ToID, Caseid, FinalLOC, FinalID, 
               TransitCount, PickMethod, RefTaskKey, WaveKey, Priority, SourcePriority, SystemQty,OrderKey,LoadKey,SourceKey,TaskType
      FROM dbo.TaskDetail WITH (NOLOCK)
      WHERE ListKey = @cListKey
         AND UserKey = @cUserName
         AND TaskType IN ( 'RPF','RP1')
         AND ISNULL(ReasonKey,'') = '' -- Skip the full short tasks

   SET @nMax = @@ROWCOUNT
   SET @nCounter = 1

   IF @nMax = 0
   BEGIN
      Return
   END

   IF @bDebugFlag = 1
   BEGIN
      SELECT 'Task List'
      SELECT * FROM @tTask
   END

   WHILE @nCounter <= @nMax
   BEGIN
      IF @bDebugFlag = 1
         SELECT 'Looping Tasks', @nCounter AS Counter, @nMax AS Max

      SELECT
         @cTaskDetailKey   = TASKDETAILKEY,
         @cWaveKey         = WaveKey,
         @cStorerKey       = StorerKey,
         @cToLOC           = ToLOC,
         @cLogicalToLOC    = ISNULL(LogicalToLOC,''),
         @cToID            = ToID,
         @cCaseID          = CaseID,
         @cFinalLoc        = FinalLoc,
         @cFinalID         = FinalID,
         @cPickMethod      = PickMethod,
         @cRefTaskKey      = RefTaskKey,
         @cSKU             = SKU,
         @cLOT             = LOT,
         @cUOM             = UOM,
         @nUOMQty          = UOMQty,
         @nQTY             = QTY,
         @nTransitCount    = TransitCount,
         @cPriority        = Priority,
         @cSourcePriority  = SourcePriority,
         @nSystemQTY       = SystemQty,
         @cSourceType      = 'rdt_1764CreateTask14',
         @cOrderKey        = OrderKey,
         @cSourceKey       = SourceKey,
         @cTaskType        = TaskType,
         @cLoadKey         = LoadKey
      FROM @tTask
      WHERE RowNumber = @nCounter

      IF @bDebugFlag = 1
         SELECT 'Current Task', @cTaskDetailKey
      
      SELECT @cToLOCPAZone = PutawayZone FROM LOC WITH (NOLOCK) WHERE LOC = @cToLOC
      SELECT @cToLOCAreaKey = AreaKey FROM AreaDetail WITH (NOLOCK) WHERE PutawayZone = @cToLOCPAZone 
      
      SET @cNewTaskDetailKey = ''

      IF EXISTS(SELECT 1 FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cToLOC AND LocationCategory = 'PND_OUT')
      BEGIN
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
            SET @nErrNo = 215852
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
            GOTO RollBackTran
         END

         INSERT INTO TaskDetail (
            TaskDetailKey, TaskType, Status, UserKey, FromLOC, FromID, ToLOC, ToID, QTY, AreaKey, FinalLOC,UOMQty,SystemQTY,
            PickMethod, StorerKey, SKU, LOT, ListKey, TransitCount, SourceType, WaveKey, LoadKey, Priority, SourcePriority, TrafficCop,SourceKey)
         VALUES (
            @cNewTaskDetailKey, 'RP1', '0', '', @cToLOC, @cToID, @cFinalLOC, @cToID, @nQty, @cToLOCAreaKey, @cFinalLOC,@nUOMQty,@nSystemQTY,
            'FP', @cStorerKey, @cSKU, @cLOT, @cNewTaskDetailKey, @nTransitCount+1, @cSourceType, @cWaveKey, @cLoadKey, @cPriority, @cSourcePriority, NULL,@cTaskDetailKey)

         UPDATE dbo.TASKDETAIL
            SET RefTaskKey = @cNewTaskDetailKey
         WHERE RefTaskKey = @cTaskDetailKey
            AND TaskType = 'FCP'

         SET @cNewTaskDetailKey = ''
      END
      ELSE
      BEGIN
            UPDATE dbo.TASKDETAIL
               SET STATUS = '0'
            WHERE RefTaskKey = @cTaskDetailKey
               AND TaskType = 'FCP'
               AND STATUS = 'S'
      END
      SET @nCounter = @nCounter + 1
   END --end while

   IF @bDebugFlag = 1
   BEGIN
      SELECT 'Loop finished'
      SELECT 'New Task List'
      SELECT 'Write to TaskDetail from NewTaskList'
   END

   GOTO Quit

RollBackTran:

Fail:
Quit:
   IF @bDebugFlag = 1
      SELECT 'Quit', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg

END
GO
GRANT EXECUTE ON  [RDT].[rdt_1764CreateTask14] TO [NSQL]
GO
