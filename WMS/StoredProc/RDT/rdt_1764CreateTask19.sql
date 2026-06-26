SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************************/
/* Store procedure: rdt_1764CreateTask19                                               */
/* Copyright      : Maersk                                                             */
/* Customer       : AMERICAN EAGLE                                                     */
/*                                                                                     */
/*                                                                                     */
/* Purpose: Once the RPF task is confirmed, generate a 2nd step replenishment          */
/*.        task from the PND location (RPF Task TASKDETAIL.ToLoc) to Mezzanine location*/
/*                                                                                     */
/* Modifications log:                                                                  */
/*                                                                                     */
/* Date       Rev    Author     Purposes                                               */
/* 2026-06-16 1.0.0  NickT      FCR-12990 created on base logic                        */
/***************************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1764CreateTask19] (
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

   DECLARE 
      @cMezzanine       NVARCHAR(10) = 'MEZZANINE',
      @cMezzFinalLoc    NVARCHAR(20) = '',
      @cStorerKey       NVARCHAR( 15),
      @cFacility        NVARCHAR( 5),
      @cLoseID          NVARCHAR( 1) = '',
      @nLoopIndex       INT,
      @nSuccess         INT,
      @nTranCount       INT

   DECLARE 
      @cTaskDetailKey      NVARCHAR( 10),
      @cNewTaskDetailKey   NVARCHAR( 10),
      @cPickDetailKey      NVARCHAR( 10),
      @cWaveKey            NVARCHAR( 10),
      @cSKU                NVARCHAR( 20),
      @cLOT                NVARCHAR( 10),
      @nQTY                INT,
      @nSystemQTY          INT,
      @cToLOC              NVARCHAR( 10),
      @cLogicalToLOC       NVARCHAR( 20),
      @cToID               NVARCHAR( 18),
      @cCaseID             NVARCHAR( 20),
      @cFinalLOC           NVARCHAR( 10),
      @cFinalID            NVARCHAR( 18),
      @cTransitLOC         NVARCHAR( 10),
      @nTransitCount       INT,
      @cUOM                NVARCHAR( 5),
      @nUOMQty             INT,
      @cPriority           NVARCHAR( 10),
      @cSourcePriority     NVARCHAR( 10),
      @cSourceType         NVARCHAR( 30),
      @cOrgTaskKey         NVARCHAR( 30),
      @cRefTaskKey         NVARCHAR( 10),
      @cPickMethod         NVARCHAR( 10),
      @cTaskType           NVARCHAR( 10),
      @cAreaKey            NVARCHAR( 10),
      @cOrderKey           NVARCHAR( 10),
      @cLoadKey            NVARCHAR( 10),
      @cFinalLogicalLoc    NVARCHAR( 18)

   SELECT 
      @cFacility = Facility, 
      @cStorerKey = StorerKey
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SELECT TOP 1 
      @cMezzFinalLoc = LOC,
      @cLoseID = LoseID
   FROM dbo.LOC WITH (NOLOCK)
   WHERE Facility = @cFacility
      AND Loc = @cMezzanine
      AND LocationType IN ('DYNPPICK', 'PICK')

   IF ISNULL(@cMezzFinalLoc, '') = ''
   BEGIN
      SET @nErrNo = 270201
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- No Mezzanine Loc
      GOTO Quit
   END

   DECLARE @tTaskDetails TABLE
   (
      RowRef         INT IDENTITY,
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
      LoadKey        NVARCHAR(10)
   )

   INSERT INTO @tTaskDetails 
      (  TaskDetailKey, Status, StorerKey, SKU, LOT, UOM, UOMQty, QTY, ToLoc, LogicalToLoc, ToID, CaseID, FinalLoc, FinalID,
         TransitCount, PickMethod, RefTaskKey, WaveKey, Priority, SourcePriority, SystemQTY, OrderKey, LoadKey
      )
   SELECT 
      TaskDetailKey, Status, StorerKey, SKU, LOT, UOM, UOMQty, Qty, ToLoc, LogicalToLoc, ToID, CaseID, FinalLoc, FinalID, 
      TransitCount, PickMethod, RefTaskKey, WaveKey, Priority, SourcePriority, SystemQty, OrderKey, LoadKey
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE ListKey = @cListKey
      AND StorerKey = @cStorerKey
      AND TaskType = 'RPF'
      AND Status = '9'
      AND Qty > 0 
      AND ISNULL(ReasonKey,'') = ''

   SET @nTranCount = @@TRANCOUNT
   -- Handling transaction
   IF @nTranCount = 0
      BEGIN TRAN  -- Begin our own transaction
   ELSE
      SAVE TRAN rdt_1764CreateTask19 -- For rollback or commit only our own transaction

   SET @nLoopIndex = -1
   WHILE 1 = 1
   BEGIN
      SELECT TOP 1
         @cTaskDetailKey   = TaskDetailKey,
         @cWaveKey         = WaveKey,
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
         @cSourceType      = 'rdt_1764CreateTask19',
         @cOrderKey        = OrderKey,
         @cLoadKey         = LoadKey,
         @nLoopIndex       = RowRef
      FROM @tTaskDetails
      WHERE RowRef > @nLoopIndex
      ORDER BY RowRef

      IF @@ROWCOUNT = 0
         BREAK

      IF @cMezzFinalLoc <> @cFinalLoc
      BEGIN
         -- If the final location is not Mezzanine, prompt error
         SET @nErrNo = 270202
         SET @cErrMsg = rdt.rdtGetmessage( @nErrNo, @cLangCode,'DSP') -- Taskdetail's final location is not Mezzanine
         GOTO ROLLBACK_TRAN
      END

      SET @cAreaKey = ''

      SELECT TOP 1 @cAreaKey = AD.AreaKey
      FROM dbo.AreaDetail AD WITH (NOLOCK)
      INNER JOIN dbo.LOC WITH (NOLOCK) ON AD.PutawayZone = LOC.PutawayZone
      WHERE LOC.Loc = @cToLOC
         AND LOC.Facility = @cFacility
      ORDER BY AD.AreaKey

      SELECT TOP 1
         @cFinalLogicalLoc = ISNULL(LOC.LogicalLocation,'')
      FROM dbo.LOC WITH (NOLOCK)
      JOIN dbo.PutawayZone PZ WITH (NOLOCK)
         ON LOC.FACILITY = PZ.FACILITY AND Loc.PutawayZone = PZ.PutawayZone
      LEFT JOIN dbo.SKUxLOC SL WITH (NOLOCK)  
         ON SL.StorerKey = @cStorerKey AND LOC.LOC = SL.LOC
      LEFT JOIN dbo.AreaDetail AD WITH(NOLOCK)
         ON PZ.PutawayZone = AD.PutawayZone
      WHERE LOC.LOC = @cFinalLOC
         AND LOC.FACILITY = @cFacility

      EXECUTE dbo.nspg_getkey
            'TASKDETAILKEY'
            , 10
            , @cNewTaskDetailKey OUTPUT
            , @nSuccess          OUTPUT
            , @nErrNo            OUTPUT
            , @cErrMsg           OUTPUT

      IF @nSuccess <> 1 OR @nErrNo <> 0
      BEGIN
         IF @nErrNo <= 0
            SET @nErrNo = 270203 -- Generate TaskDetailKey fail

         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
         GOTO ROLLBACK_TRAN
      END

      BEGIN TRY
         INSERT INTO dbo.TaskDetail 
         (
            TaskDetailKey, TaskType, Status, UserKey, FromLOC, FromID, ToLOC, ToID, QTY, CaseID, AreaKey, UOM, UOMQty,
            PickMethod, StorerKey, SKU, LOT, ListKey, TransitCount, SourceType, SourceKey, WaveKey, Priority, SourcePriority, TrafficCop,
            RefTaskKey, SystemQty, OrderKey, LoadKey, LogicalFromLOC, LogicalToLOC
         )
         VALUES
         (
            @cNewTaskDetailKey, 'ASTRPT', '0', @cUserName, @cToLoc, @cToID, @cFinalLoc, '', @nQTY, @cCaseID, @cAreaKey, @cUOM, @nUOMQty,
            @cPickMethod, @cStorerKey, @cSKU, @cLOT, '', @nTransitCount + 1, 'rdt_1764CreateTask19', @cTaskDetailKey, @cWaveKey, @cPriority, @cSourcePriority, NULL,
            @cRefTaskKey, @nSystemQTY, @cOrderKey, @cLoadKey, @cLogicalToLOC, @cFinalLogicalLoc
         )
      END TRY
      BEGIN CATCH
         SET @nErrNo = 270204
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Insert TaskDetailKey fail
         GOTO ROLLBACK_TRAN
      END CATCH
   END

   IF @@TRANCOUNT > @nTranCount
   BEGIN
      IF XACT_STATE() = 1
         COMMIT TRANSACTION
   END
   GOTO QUIT

   ROLLBACK_TRAN:
   IF @@TRANCOUNT > 0
   BEGIN
      IF @nTranCount = 0
      BEGIN
         ROLLBACK TRANSACTION
      END
      ELSE
      BEGIN
         IF XACT_STATE() <> -1
            ROLLBACK TRANSACTION rdt_1764CreateTask19
         ELSE
            ROLLBACK TRANSACTION 
      END
   END
   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  [RDT].[rdt_1764CreateTask19] TO [NSQL]
GO
