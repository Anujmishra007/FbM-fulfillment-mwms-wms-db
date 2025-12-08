
/************************************************************************/
/* Store procedure: rdt_1812SwapID05                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: base on same type of LOC Categorys,SKU, Qty. For JCB        */
/*                                                                      */
/* Date        Rev     Author      Purposes                             */
/* 2025-06-11  1.0.0   Jackc       FCR-3959 Created                     */
/* 2025-10-10  1.0.1   Dennis      FCR-3959                             */
/************************************************************************/
CREATE OR ALTER PROCEDURE rdt.rdt_1812SwapID05
   @nMobile           INT,
   @nFunc             INT,
   @cLangCode         NVARCHAR( 3),
   @cTaskDetailKey    NVARCHAR( 10),
   @cNewID            NVARCHAR( 18),
   @cNewTaskDetailKey NVARCHAR( 10) OUTPUT,
   @nErrNo            INT           OUTPUT,
   @cErrMsg           NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag     INT = 0

   DECLARE @nRowCount      INT  
  
   DECLARE @cOtherPickDetailKey NVARCHAR(10)  
   DECLARE @cFCPTaskDetailKey NVARCHAR(10)    
   DECLARE @cFPKTaskDetailKey NVARCHAR(10)  
     
   DECLARE @cNewSKU           NVARCHAR( 20)  
   DECLARE @cNewLOT           NVARCHAR( 10)  
   DECLARE @cNewLOC           NVARCHAR( 10)
   DECLARE @cNewLocCate       NVARCHAR( 10)  
   DECLARE @nNewQTY           INT  
   DECLARE @nNewAvailableQty  INT

   DECLARE @cPickDetailKey    NVARCHAR(10)  
   DECLARE @cStorerKey        NVARCHAR( 15)  
   DECLARE @cTaskKey          NVARCHAR( 10)  
   DECLARE @cTaskType         NVARCHAR( 10)  
   DECLARE @cTaskSKU          NVARCHAR( 20)  
   DECLARE @cTaskLOT          NVARCHAR( 10)  
   DECLARE @cTaskFromLoc      NVARCHAR( 10)  
   DECLARE @cTaskFromID       NVARCHAR( 18)
   DECLARE @cTaskFromLocCate NVARCHAR( 10)
   DECLARE @cTaskPickMethod   NVARCHAR( 10)  
   DECLARE @nTaskQTY          INT  
   DECLARE @nQTY              INT
   DECLARE @cUserName         NVARCHAR(18)
   DECLARE @cLottable03       NVARCHAR(60)

   SELECT @cLottable03 = O_Field01
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   DECLARE @tList TABLE
   (
      ID                      INT IDENTITY(1,1),
      SKU                     NVARCHAR(20),
      QTY                     INT
   )

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_1812SwapID05', @cTaskDetailKey AS TaskKey, @cNewID AS NewID
  
   -- Check blank
   IF @cNewID = ''
   BEGIN
      SET @nErrNo = 239901 
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need ID
      GOTO Quit
   END

   IF @nDebugFlag = 1
      SELECT 'Validating the current task'

   -- Get task info  
   SELECT  
      @cStorerKey = StorerKey,   
      @cTaskType = TaskType,   
      @cTaskFromLoc = FromLOC,  
      @cTaskFromID = FromID,
      @cTaskPickMethod = TD.PickMethod,   
      @cUserName = USERKEY,
      --@nTaskQTY = SystemQty, FP task qty = 0
      @cTaskFromLocCate = LOC.LocationCategory  
   FROM dbo.TaskDetail TD WITH (NOLOCK)
   JOIN dbo.LOC  WITH (NOLOCK)
      ON TD.FromLOC = LOC.LOC
   WHERE TD.TaskDetailKey = @cTaskDetailKey  
   IF @@ROWCOUNT = 0  
   BEGIN  
      SET @nErrNo = 239902  
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --BadTaskDtlKey  
      GOTO Quit  
   END

      --Only FP support overwrite
   IF @cTaskPickMethod <> 'FP'
   BEGIN
      SET @nErrNo = 239903
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Cannot swap id  
      GOTO Quit 
   END

   --Only from loc in the specific category support overwrite
   IF NOT EXISTS (
      SELECT 1 
      FROM dbo.CodeLKUP WITH (NOLOCK)
      WHERE LISTNAME = 'JCBBKFRMLC'
         AND StorerKey = @cStorerKey
         AND Long = @cTaskFromLocCate
   )
   BEGIN
      SET @nErrNo = 239904
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Cannot swap id on this loc
      GOTO Quit 
   END

   --Get SKU info as FP task doesn't have these data. (Mix SKU not support)
   INSERT INTO @tList (SKU, QTY)
   SELECT SKU, SUM(Qty)
   FROM dbo.LOTxLOCxID WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND ID = @cTaskFromID
      AND QTY - QtyPicked > 0
   GROUP BY SKU

   IF @nDebugFlag = 1
      SELECT * FROM @tList

   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT

   --SWAP Tasks
   IF EXISTS ( SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) WHERE FromID = @cNewID AND Status = '0' AND TASKTYPE IN ('FCP','FCP1') AND PickMethod = 'FP' )
   BEGIN
      SELECT @cNewTaskDetailKey = TaskDetailKey
      FROM dbo.TaskDetail WITH (NOLOCK)
      WHERE FromID = @cNewID AND Status = '0' AND TASKTYPE IN ('FCP','FCP1') AND PickMethod = 'FP' 

      UPDATE TASKDETAIL SET STATUS = '0',USERKEY = '' WHERE TASKDETAILKEY = @cTaskDetailKey
      UPDATE TASKDETAIL SET STATUS = '3',USERKEY = @cUserName,ListKey = TaskDetailKey WHERE TASKDETAILKEY = @cNewTaskDetailKey

      GOTO CommitTran
   END

   --new id cannot have any open tasks
   IF EXISTS (
      SELECT 1
      FROM dbo.TaskDetail WITH (NOLOCK)
      WHERE FromID = @cNewID
         AND Status NOT IN ('9','X')
   )
   BEGIN
      SET @nErrNo = 239905
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --id has open task
      GOTO Quit 
   END

   --new id should not be hold
   IF EXISTS (
      SELECT 1
      FROM dbo.InventoryHold WITH (NOLOCK)
      WHERE StorerKey = @cStorerkey
         AND Id = @cNewID
   )
   BEGIN
      SET @nErrNo = 239906
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --id on hold
      GOTO Quit
   END

   -- Get new ID info
   -- Ensure the ID only has one SKU
   DECLARE @nLoopIndex INT = -1
   WHILE 1=1
   BEGIN
      SELECT TOP 1
         @cTaskSKU = SKU,
         @nTaskQTY = QTY,
         @nLoopIndex = id
      FROM @tList
      WHERE id > @nLoopIndex
      ORDER BY id
      SET @nRowCount = @@ROWCOUNT

      IF @nRowCount = 0
         BREAK

      SELECT @cLottable03 = LA.LOTTABLE03  
      FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
      JOIN dbo.LOC WITH (NOLOCK)
         ON LLI.Loc = LOC.LOC
      JOIN dbo.LOTAttribute LA WITH (NOLOCK)
         ON LLI.Lot = LA.Lot AND LLI.StorerKey = LA.StorerKey AND LA.SKU = LLI.SKU
      WHERE LLI.StorerKey = @cStorerKey
         AND ID = @cTaskFromID
         AND LLI.QTY - LLI.QtyPicked > 0
         AND LLI.SKU = @cTaskSKU

      IF NOT EXISTS (
         SELECT 1 FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
         JOIN dbo.LOC WITH (NOLOCK)
            ON LLI.Loc = LOC.LOC
         JOIN dbo.LOTAttribute LA WITH (NOLOCK)
            ON LLI.Lot = LA.Lot AND LLI.StorerKey = LA.StorerKey AND LA.SKU = LLI.SKU
         WHERE LLI.StorerKey = @cStorerKey
            AND LLI.ID = @cNewID
            AND LLI.SKU = @cTaskSKU
            AND (LLI.QtyAllocated + LLI.QtyPicked + LLI.QtyReplen) = 0
            AND LA.Lottable03 = @cLottable03
         GROUP BY ID,LLI.SKU
         HAVING SUM(LLI.QTY) = @nTaskQTY
      )   
      BEGIN
         SET @nErrNo = 239907
         SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') --Invalid ID
         GOTO Quit
      END
   END

   SELECT
      @cNewSKU = SKU,
      @nNewQTY = SUM(QTY),
      @nNewAvailableQty = SUM(Qty - QtyAllocated - QtyPicked - QtyReplen),
      @cNewLOC = LLI.LOC,
      @cNewLocCate = LOC.LocationCategory
   FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
   JOIN dbo.LOC WITH (NOLOCK)
      ON LLI.Loc = LOC.LOC
   WHERE StorerKey = @cStorerKey
      AND ID = @cNewID
      AND QTY > 0
   GROUP BY SKU, LLI.LOC, LOC.LocationCategory

   IF @cNewLocCate <> @cTaskFromLocCate
   BEGIN
      SET @nErrNo = 239912
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Cannot swap id from this loc
      GOTO Quit 
   END


   /*--------------------------------------------------------------------------------------------------

                                                Swap ID

   --------------------------------------------------------------------------------------------------*/
   DECLARE @tOrdToAllocate TABLE
   (
      OrdRowRef         INT IDENTITY (1, 1) NOT NULL,
      OrderKey          NVARCHAR (10) NOT NULL,
      OrderLineNumber   NVARCHAR(5) NOT NULL,
      SKU               NVARCHAR(20) NOT NULL,
      PackKey           NVARCHAR(10) NOT NULL,
      WaveKey           NVARCHAR(10),
      PickSlipNo        NVARCHAR(10),
      QtyToAlloc        INT NOT NULL
   )

   DECLARE @tPKDCandidates TABLE
   (
      PKDRowRef         INT IDENTITY  NOT NULL, 
      PickDetailKey     NVARCHAR( 10) NOT NULL,
      CaseID            NVARCHAR( 20) NOT NULL,
      PickHeaderKey     NVARCHAR( 18) NOT NULL,
      OrderKey          NVARCHAR( 10) NOT NULL,
      OrderLineNumber   NVARCHAR( 5)  NOT NULL,
      SKU               NVARCHAR( 20) NOT NULL, 
      QTY               INT           NOT NULL,
      Lot               NVARCHAR( 10) NOT NULL,
      StorerKey         NVARCHAR( 15) NOT NULL,
      UOM               NVARCHAR( 10) NOT NULL,
      UOMQty            INT           NOT NULL,
      DropID            NVARCHAR( 20) NULL,
      Loc               NVARCHAR( 10) NOT NULL,
      ID                NVARCHAR( 18) NULL,
      PackKey           NVARCHAR( 10) NOT NULL,
      CartonGroup       NVARCHAR( 10) NULL,
      PickMethod        NVARCHAR( 1)  NOT NULL,
      WaveKey           NVARCHAR( 10) NULL,
      PickSlipNo        NVARCHAR( 10) NULL
   )

   DECLARE @tAllocation TABLE
   (
      PickDetailKey     NVARCHAR( 10) NOT NULL,
      CaseID            NVARCHAR( 20) NULL,
      PickHeaderKey     NVARCHAR( 18) NOT NULL,
      OrderKey          NVARCHAR( 10) NOT NULL,
      OrderLineNumber   NVARCHAR( 5)  NOT NULL,
      SKU               NVARCHAR( 20) NOT NULL, 
      QTY               INT           NOT NULL,
      Lot               NVARCHAR( 10) NOT NULL,
      StorerKey         NVARCHAR( 15) NOT NULL,
      UOM               NVARCHAR( 10) NOT NULL,
      UOMQty            INT           NOT NULL,
      DropID            NVARCHAR( 20) NULL,
      Loc               NVARCHAR( 10) NOT NULL,
      ID                NVARCHAR( 18) NULL,
      PackKey           NVARCHAR( 10) NOT NULL,
      CartonGroup       NVARCHAR( 10) NULL,
      PickMethod        NVARCHAR( 1)  NOT NULL,
      WaveKey           NVARCHAR( 10) NULL,
      PickSlipNo        NVARCHAR( 10) NULL,
      PRIMARY KEY CLUSTERED (PickDetailKey)
   )

   DECLARE @tAvailableLots TABLE
   (
      Lot            NVARCHAR(10),
      AvailableQty   INT,
      AllocatedQty   INT
   )

   DECLARE 
      @nOrdLoopIndex       INT,
      @nOrdCounter         INT,
      @cOrdToAlloc         NVARCHAR(10),
      @cOrdLineToAlloc     NVARCHAR( 5),
      @cSKUToAlloc         NVARCHAR(20),
      @cWaveKeyToAlloc     NVARCHAR(10),
      @cPSNOToAlloc        NVARCHAR(10),
      @cPackKeyToAlloc     NVARCHAR(10),
      @cNewPickDetailKey   NVARCHAR(18),
      @cAllocatedLot       NVARCHAR(10),
      @cPKDNotes           NVARCHAR(1024),
      @nQtyToAlloc         INT,
      @nBal_Qty            INT,
      @bSuccess            BIT


   IF @nDebugFlag = 1
      SELECT 'Start Swapping ID'

   INSERT INTO @tPKDCandidates ( PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY, 
                                    Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, 
                                    PickMethod, WaveKey, PickSlipNo)
   SELECT PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY, 
          LOT, StorerKey, UOM, UOMQTY, DropID, Loc, ID, PackKey, CartonGroup, 
          PickMethod, WaveKey, PickSlipNo
   FROM dbo.PickDetail WITH (NOLOCK)
   WHERE Storerkey = @cStorerKey
      AND TaskDetailKey = @cTaskDetailKey
      AND ID = @cTaskFromID
      AND [Status] = '0'

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'PKD Candidates to swap'
      SELECT * FROM @tPKDCandidates
   END

   INSERT INTO @tOrdToAllocate (OrderKey, OrderLineNumber, SKU, PackKey, WaveKey, PickSlipNo, QtyToAlloc)
      SELECT
         ORDERKEY,
         OrderLineNumber,
         SKU,
         PackKey,
         WAVEKEY,
         PickSlipNo,
         SUM(Qty) AS QtyToAlloc
      FROM @tPKDCandidates
      GROUP BY OrderKey, OrderLineNumber, SKU, PackKey, WaveKey, PickSlipNo 

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Orders to reallocate'
      SELECT * FROM @tOrdToAllocate
   END

   -- prepare order loops index
   SET @nOrdLoopIndex = 1
   SELECT @nOrdCounter = COUNT(1) FROM @tOrdToAllocate

   WHILE @nOrdLoopIndex <= @nOrdCounter
   BEGIN
      SELECT    
         @cOrdToAlloc = OrderKey,
         @cOrdLineToAlloc = OrderLineNumber,
         @cWaveKeyToAlloc = WaveKey,
         @cSKUToAlloc = SKU,
         @cPackKeyToAlloc  = PackKey,
         @cPSNOToAlloc = PickSlipNo,
         @nQtyToAlloc = QtyToAlloc
      FROM @tOrdToAllocate
      WHERE OrdRowRef = @nOrdLoopIndex

      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Handling OrdToAllocate'
         SELECT @nOrdLoopIndex AS LoopIndex, @nOrdCounter AS TotalRow, @cOrdToAlloc AS OrderKey, @cOrdLineToAlloc AS OrderLineNumber, 
               @nQtyToAlloc AS QtyToAlloc
      END

      INSERT INTO @tAvailableLots (Lot, AvailableQty, AllocatedQty)
         SELECT 
            LLI.Lot,
            SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.QtyReplen) AS AvailableQty,
            SUM(ISNULL(t.QTY,0)) AS AllocatedQty
         FROM dbo.lotxlocxid LLI WITH (NOLOCK)
         LEFT JOIN (
                  SELECT Lot, SUM(QTY) AS QTY
                  FROM @tAllocation
                  GROUP BY Lot
                  ) t
            ON LLI.Lot = t.Lot
         WHERE LLI.StorerKey = @cStorerKey
            AND LLI.SKU = @cSKUToAlloc
            AND LLI.Loc = @cNewLoc
            AND LLI.ID = @cNewID
         GROUP BY LLI.Lot
         HAVING SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.QtyReplen) - SUM(ISNULL(t.QTY,0)) > 0
         ORDER BY LLI.Lot DESC

         IF @nDebugFlag = 1
         BEGIN
            SELECT 'Get available Lot'
            SELECT * FROM @tAvailableLots
         END

         --initiate parameters for lot looping
         DECLARE @nRemainingQty INT = @nQtyToAlloc

         WHILE @nRemainingQty > 0
         BEGIN
            SELECT TOP 1
               @cAllocatedLot = Lot,
               @nBal_Qty = AvailableQty - AllocatedQty
            FROM @tAvailableLots
            WHERE AvailableQty > AllocatedQty
            ORDER BY AvailableQty DESC

            IF @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 239913
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- No enough lot found
               GOTO Quit
            END

            IF @nDebugFlag = 1
            BEGIN
               SELECT 'Remaining Ord Qty', @nRemainingQty, 'Allocating lot:', @cAllocatedLot AS Lot, @nBal_Qty AS BalQty
            END

            IF @nBal_Qty >= @nRemainingQty
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Bal_Qty >= Ord Qty'


               EXECUTE dbo.nspg_GetKey
               'PICKDETAILKEY',
               10 ,
               @cNewPickDetailKey OUTPUT,
               @bSuccess          OUTPUT,
               @nErrNo            OUTPUT,
               @cErrMsg           OUTPUT

               IF @bSuccess <> 1
               BEGIN
                  SET @nErrNo = 239914
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GetKey Fail
                  GOTO RollBackTran
               END

               INSERT INTO @tAllocation (PickDetailKey, 
                           CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY, 
                           Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, PickMethod, WaveKey, 
                           PickSlipNo)
               SELECT @cNewPickDetailKey, 
                     '', '', @cOrdToAlloc, @cOrdLineToAlloc, @cSKUToAlloc, @nRemainingQty, 
                     @cAllocatedLot, @cStorerKey, 6, @nRemainingQty, '', @cNewLOC, @cNewID, @cPackKeyToAlloc, '', '', @cWaveKeyToAlloc, 
                     @cPSNOToAlloc


               SET @nRemainingQty = 0
            END
            ELSE -- BalQty < ReaminingQty
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'BAL_Qty < PickDetail Qty'


               EXECUTE dbo.nspg_GetKey
               'PICKDETAILKEY',
               10 ,
               @cNewPickDetailKey OUTPUT,
               @bSuccess          OUTPUT,
               @nErrNo            OUTPUT,
               @cErrMsg           OUTPUT

               IF @bSuccess <> 1
               BEGIN
                  SET @nErrNo = 239915
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GetKey Fail
                  GOTO RollBackTran
               END

               INSERT INTO @tAllocation (PickDetailKey, 
                           CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY, 
                           Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, PickMethod, WaveKey, 
                           PickSlipNo)
               SELECT @cNewPickDetailKey, 
                     '', '', @cOrdToAlloc, @cOrdLineToAlloc, @cSKUToAlloc, @nBal_Qty, 
                     @cAllocatedLot, @cStorerKey, 6, @nBal_Qty, '', @cNewLOC, @cNewID, @cPackKeyToAlloc, '', '', @cWaveKeyToAlloc, 
                     @cPSNOToAlloc

               SET @nRemainingQty -= @nBal_Qty

               IF @nDebugFlag = 1
                  SELECT @nRemainingQty AS RemainingQty
               
               --Delete the lot which is full allocated
               DELETE FROM @tAvailableLots WHERE Lot = @cAllocatedLot

               IF @nDebugFlag = 1
               BEGIN
                  SELECT 'Delete lot from AvailableLots table', @cAllocatedLot AS lot
                  SELECT 'new available Lot'
                  SELECT * FROM @tAvailableLots
               END
            END -- BalQty < ReaminingQty
         END --loop lot for one order line

         --Get next ord line to handle
         --Clear the availablelots and refill in with the latest temp allocated result
         DELETE FROM @tAvailableLots

         IF @nDebugFlag = 1
         BEGIN
            SELECT '@tAllocation Table after handing each PKD'
            SELECT * FROM @tAllocation
            SELECT 'Delete AvailableLots temp table for next refill'
         END

         SET @nOrdLoopIndex += 1
   END -- OrdToAllocation loop end

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Allocation finished'
      SELECT 'Order to Allocation'
      SELECT * FROM @tOrdToAllocate
      SELECT 'Allocation result'
      SELECT * FROM @tAllocation
      SELECT 'Unallocate and delete original pickdetail'
   END

   --Handle the pysical tables based on re-allocaton result
   --Unallocate and delete the original pick detail

   BEGIN TRY
      UPDATE PD WITH (ROWLOCK)
      SET PD.Status = '0',
            PD.Qty = 0,
            PD.TaskDetailKey = '', --Make trigger do not delete the original task
            PD.EditDate = GETDATE(),
            PD.EditWho = SUSER_SNAME()
      FROM dbo.PickDetail PD WITH (ROWLOCK)
      WHERE StorerKey = @cStorerKey
         AND TaskDetailKey = @cTaskDetailKey
   END TRY
   BEGIN CATCH
      SET @nErrNo = 239916
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PKD failed
      GOTO RollBackTran
   END CATCH

   BEGIN TRY
      DELETE FROM dbo.PickDetail
      WHERE PickDetailKey IN (SELECT PickDetailKey FROM @tPKDCandidates)
   END TRY
   BEGIN CATCH
      SET @nErrNo = 239917
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Delete PKD failed
      GOTO RollBackTran
   END CATCH
   
   --Set PKD notes
   SET @cPKDNotes = 'Swap original ID ' + @cTaskFromID
   
   IF @nDebugflag = 1
      SELECT 'Genreated new Pickdetail'

   BEGIN TRY
      INSERT INTO dbo.PickDetail 
         (PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, Qty, 
            Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, 
            PickMethod, WaveKey, PickSlipNo, Status, EditDate, EditWho, Notes, TaskDetailKey)
         SELECT PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, Qty,
                  LOT, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup,
                  PickMethod, WaveKey, PickSlipNo, '0', GETDATE(), SUSER_SNAME(), @cPKDNotes, @cTaskDetailKey 
         FROM @tAllocation
   END TRY
   BEGIN CATCH
      SET @nErrNo = 239918
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Generate PKD failed
      GOTO RollBackTran
   END CATCH

   IF @nDebugFlag = 1
      SELECT 'Update taskdetail to new loc, new id'
   
   BEGIN TRY
      UPDATE dbo.TaskDetail WITH (ROWLOCK)
      SET
         FromLoc = @cNewLoc,
         FromID = @cNewID,
         ToID = CASE WHEN ToID = FromID THEN @cNewID ELSE ToID END
      WHERE TaskDetailKey = @cTaskDetailKey
   END TRY
   BEGIN CATCH
      SET @nErrNo = 239919
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd task failed
      GOTO RollBackTran
   END CATCH

   CommitTran:
      GOTO Quit
   RollBackTran:
      IF @nDebugFlag = 1
         SELECT 'RollbackTran', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
   Quit:
      IF @nDebugFlag = 1
         SELECT 'Quit', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
END
GO

GRANT EXECUTE ON rdt.rdt_1812SwapID05 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
