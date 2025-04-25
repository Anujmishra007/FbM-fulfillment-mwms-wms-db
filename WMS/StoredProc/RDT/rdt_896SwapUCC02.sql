SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_896SwapUCC02                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: PUMA CHL                                                    */
/*                                                                      */
/* Date       Rev    Author     Purposes                                */
/* 2025-03-14 1.0.0  JCH507     FCR-3287 Created (Copy from SwapUCC01)  */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_896SwapUCC02] (
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,           
   @nInputKey    INT,           
   @cStorerKey   NVARCHAR( 15), 
   @cFacility    NVARCHAR( 5),  
   @cBarcode     NVARCHAR( 60), 
   @cRPLKey      NVARCHAR( 10), 
   @cFromLOC     NVARCHAR( 10)  OUTPUT, 
   @cFromID      NVARCHAR( 18)  = '' OUTPUT, 
   @cReplenKey   NVARCHAR( 10)  OUTPUT, -- Compulsory, the task selected after swap
   @cSKU         NVARCHAR( 20)  OUTPUT, -- In FromLOC, FromID mode, SKU is blank
   @nQTY         INT            OUTPUT, -- In FromLOC, FromID mode, QTY is 0
   @cUCCNo       NVARCHAR( 20)  OUTPUT, -- Actual UCC scanned
   @cToID        NVARCHAR( 18)  OUTPUT, 
   @cToLOC       NVARCHAR( 10)  OUTPUT, 
   @cLottable01  NVARCHAR( 18)  OUTPUT, 
   @cLottable02  NVARCHAR( 18)  OUTPUT, 
   @cLottable03  NVARCHAR( 18)  OUTPUT, 
   @dLottable04  DATETIME       OUTPUT, 
   @dLottable05  DATETIME       OUTPUT, 
   @cLottable06  NVARCHAR( 30)  OUTPUT, 
   @cLottable07  NVARCHAR( 30)  OUTPUT, 
   @cLottable08  NVARCHAR( 30)  OUTPUT, 
   @cLottable09  NVARCHAR( 30)  OUTPUT, 
   @cLottable10  NVARCHAR( 30)  OUTPUT, 
   @cLottable11  NVARCHAR( 30)  OUTPUT, 
   @cLottable12  NVARCHAR( 30)  OUTPUT, 
   @dLottable13  DATETIME       OUTPUT, 
   @dLottable14  DATETIME       OUTPUT, 
   @dLottable15  DATETIME       OUTPUT, 
   @nErrNo       INT            OUTPUT, 
   @cErrMsg      NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @bDebugFlag        BINARY = 0

   DECLARE @cActUCCNo         NVARCHAR( 20)
   DECLARE @cActUCCLOT        NVARCHAR( 10)
   DECLARE @cActUCCLotable01  NVARCHAR( 18)
   DECLARE @cActUCCLOC        NVARCHAR( 10)
   DECLARE @cActUCCID         NVARCHAR( 18)
   DECLARE @cActUCCSKU        NVARCHAR( 20)
   DECLARE @cActUCCStatus     NVARCHAR( 1)
   DECLARE @nActUCCQTY        INT

   DECLARE @cTaskUCCNo        NVARCHAR( 20)
   DECLARE @cTaskLOT          NVARCHAR( 10)
   DECLARE @cTaskToLOC        NVARCHAR( 10)
   DECLARE @cTaskToID         NVARCHAR( 18)
   DECLARE @cTaskUCCStatus    NVARCHAR( 1)
   DECLARE @cTaskUCCLOT       NVARCHAR( 10)
   DECLARE @cTaskUCCLotable01 NVARCHAR( 18)
   DECLARE @cTaskUCCLOC       NVARCHAR( 10)
   DECLARE @cTaskUCCID        NVARCHAR( 18)
   DECLARE @cTaskUCCSKU       NVARCHAR( 20)
   DECLARE @nTaskUCCQTY       INT
   DECLARE @nTaskQTYReplen    INT
   DECLARE @nTaskPendingMoveIn INT

   DECLARE @cNewPickDetailKey NVARCHAR( 10)
   DECLARE @cPickDetailKey    NVARCHAR( 10)
   DECLARE @cLOT              NVARCHAR( 10)
   DECLARE @nQTY_Bal          INT
   DECLARE @curPD             CURSOR

   DECLARE @tTaskPD TABLE
   (
      PickDetailKey NVARCHAR( 10) NOT NULL,
      LOT           NVARCHAR( 10) NOT NULL,
      QTY           INT           NOT NULL
      PRIMARY KEY CLUSTERED (PickDetailKey)
   )
   
   DECLARE @tActPD TABLE
   (
      PickDetailKey NVARCHAR( 10) NOT NULL,
      LOT           NVARCHAR( 10) NOT NULL,
      QTY           INT           NOT NULL
      PRIMARY KEY CLUSTERED (PickDetailKey)
   )
         
   -- Get actual UCC info
   -- v1.0.0 start
   SELECT 
      @cActUCCNo = @cUCCNo, 
      @cActUCCLOT = UCC.LOT, 
      @cActUCCLOC = LOC,
      @cActUCCID = ID, 
      @cActUCCSKU = UCC.SKU, 
      @nActUCCQTY = QTY, 
      @cActUCCStatus = Status,
      @cActUCCLotable01 = LA.Lottable01
   FROM dbo.UCC WITH (NOLOCK)
   JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK)
      ON (LA.LOT = UCC.LOT AND LA.StorerKey = UCC.StorerKey)
   WHERE UCC.StorerKey = @cStorerKey
      AND UCCNo = @cUCCNo

   IF @bDebugFlag = 1
      SELECT 'ActUCC', @cActUCCNo AS ActUCCNo, @cActUCCLOT AS ActUCCLOT, @cActUCCLOC AS ActUCCLOC, @cActUCCID AS ActUCCID, 
            @cActUCCSKU AS ActUCCSKU, @nActUCCQTY AS ActUCCQTY, @cActUCCStatus AS ActUCCStatus, @cActUCCLotable01 AS ActUCCLottable01
   --v1.0.0 end

/*--------------------------------------------------------------------------------------------------
                                                Swap UCC
--------------------------------------------------------------------------------------------------*/
/*
   Task dispatched:
   Specified task
   Any task in the FromLOC and, FromID

   Actual UCC scanned:
   UCC free from alloc
   UCC with alloc
   UCC with replen

   All scenarios:
   1. Specified task, UCC is on the task, no swap
   2. Any task in FromLOC and FromID, UCC is on those tasks, no swap
   
   3. Task UCC, swap with free UCC 
      3.1 No swap LOT
      3.2 Swap LOT
   4. Task UCC, swap with alloc UCC 
      4.1 No swap LOT
      4.2 Swap LOT
   -- AS UCCStatus is still 3, it won't go into step5 scenario
   --5. Task UCC, swap with replen UCC (only happen under specified task mode)
      --5.1 No swap LOT
      --5.2 Swap LOT

   Note:
   Step 1 and 2 is basically getting a task
   Step 3, 4, 5 is the swap logic
*/

   -- 1. Specified task, UCC is on the task, no swap
   IF @cRPLKey <> ''
   BEGIN
      -- Get task info
      SELECT 
         @cReplenKey = ReplenishmentKey, 
         @cTaskUCCNo = RefNo, 
         @cTaskLOT = LOT, 
         @cTaskToLOC = ToLOC, 
         @cTaskToID = ToID, 
         @nTaskPendingMoveIn = ISNULL( PendingMoveIn, 0), 
         @nTaskQTYReplen = ISNULL( QTYReplen, 0)
      FROM dbo.Replenishment WITH (NOLOCK)
      WHERE ReplenishmentKey = @cRPLKey
      
      -- UCC on task
      IF @cTaskUCCNo = @cActUCCNo
      BEGIN
         IF @bDebugFlag = 1
            SELECT 'RPLKey<>'', TaskUCC = ActUCC, No Swap'
         GOTO Quit
      END
   END

   -- 2. Any task in FromLOC and FromID, UCC is on those tasks, no swap
   ELSE
   BEGIN
      SET @cReplenKey = ''

      -- Get task info (match UCCNo)
      SELECT @cReplenKey = ReplenishmentKey
      FROM dbo.Replenishment WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND FromLOC = @cFromLOC
         AND ID = @cFromID
         AND RefNo = @cUCCNo
         AND Confirmed = 'N'
      
      -- UCC on task
      IF @cReplenKey <> ''
      BEGIN
         IF @bDebugFlag = 1
            SELECT 'Step2 - RPLKey is empty, ActUCC in the same FromLoc, FromID, No Swap'
         GOTO Quit
      END

      -- Find a task (match FromLOC, FromID, SKU, QTY)
      SELECT TOP 1 
         @cReplenKey = ReplenishmentKey, 
         @cTaskUCCNo = RefNo, 
         @cTaskLOT = RP.LOT, 
         @cTaskToLOC = ToLOC, 
         @cTaskToID = ToID, 
         @nTaskPendingMoveIn = ISNULL( PendingMoveIn, 0), 
         @nTaskQTYReplen = ISNULL( QTYReplen, 0)
      FROM dbo.Replenishment RP WITH (NOLOCK)
      JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK)
         ON (LA.LOT = RP.LOT AND LA.StorerKey = RP.StorerKey)
      WHERE RP.StorerKey = @cStorerKey
         AND FromLOC = @cFromLOC
         AND ID = @cFromID
         AND RP.SKU = @cActUCCSKU
         AND QTY = @nActUCCQTY
         AND LA.Lottable01 = @cActUCCLotable01 --v1.0.0
         AND Confirmed = 'N'
         AND RefNo <> ''
      ORDER BY CASE WHEN RP.LOT = @cActUCCLOT THEN 1 ELSE 2 END
      
      -- Check matching task
      IF @cReplenKey = ''
      BEGIN
         SET @nErrNo = 235051
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No Replen task
         GOTO Quit
      END
   END

   -- Get task UCC info
   --v1.0.0 start
   SELECT 
      @cTaskUCCLOT = UCC.LOT, 
      @cTaskUCCLOC = LOC,
      @cTaskUCCID = ID, 
      @cTaskUCCSKU = UCC.SKU, 
      @nTaskUCCQTY = QTY, 
      @cTaskUCCStatus = Status,
      @cTaskUCCLotable01 = LA.Lottable01
   FROM dbo.UCC WITH (NOLOCK)
   JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK)
      ON (LA.LOT = UCC.LOT AND LA.StorerKey = UCC.StorerKey)
   WHERE UCC.StorerKey = @cStorerKey
      AND UCCNo = @cTaskUCCNo

   IF @bDebugFlag = 1
      SELECT 'TaskUCC', @cTaskUCCLOT AS TaskUCCLOT, @cTaskUCCLOC AS TaskUCCLOC, @cTaskUCCID AS TaskUCCID, 
            @cTaskUCCSKU AS TaskUCCSKU, @nTaskUCCQTY AS TaskUCCQTY, @cTaskUCCStatus AS TaskUCCStatus, @cTaskUCCLotable01 AS TaskUCCLottable01
      
   -- Check Act UCC valid
   EXEC RDT.rdtIsValidUCC @cLangCode, @nErrNo OUTPUT, @cErrMsg OUTPUT
      ,@cActUCCNo -- UCC
      ,@cStorerKey
      ,'134' 
      ,@cChkLOC = @cFromLOC
      ,@cChkID  = @cFromID
      ,@cChkSKU = @cTaskUCCSKU
      ,@nChkQTY = @nActUCCQTY
   IF @nErrNo <> 0
      GOTO Quit

   -- check the act UCC not from a confirmed replenishment task
   IF EXISTS (SELECT 1 FROM dbo.Replenishment WITH (NOLOCK) WHERE RefNo = @cActUCCNo AND Confirmed = 'Y')
   BEGIN
      SET @nErrNo = 235095
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCCConfirmed
      GOTO Quit
   END
   
   -- Loc, ID, SKU check is covered in rdtIsValidUCC
   -- Check UCC QTY
   IF @nTaskUCCQTY <> @nActUCCQTY
   BEGIN
      SET @nErrNo = 235052
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC QTY Diff
      GOTO Quit
   END
   -- Check UCC lottable01
   IF @cTaskUCCLotable01 <> @cActUCCLotable01
   BEGIN
      SET @nErrNo = 235075
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC Lottable01 Diff
      GOTO Quit
   END
   --V1.0.0 end

   DECLARE @nTranCount  INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_896SwapUCC02 -- For rollback or commit only our own transaction

   -- 3. task UCC, swap with free UCC 
   IF @cActUCCStatus = '1'
   BEGIN
      IF @bDebugFlag = 1
         SELECT 'Step3 - Swap with free UCC'
      
      -- NO swap LOT
      IF @cTaskLOT = @cActUCCLOT
      BEGIN
         IF @bDebugFlag = 1
            SELECT 'No swap LOT'

         -- Task
         UPDATE dbo.Replenishment WITH (ROWLOCK)
         SET
            RefNo = @cActUCCNo,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME(), 
            ArchiveCop = NULL
         WHERE ReplenishmentKey = @cReplenKey
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 235053
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd RPL Fail
            GOTO RollBackTran
         END

         --V1.0.0 START
         --Pickdetail
         UPDATE dbo.PickDetail WITH (ROWLOCK)
         SET
            DropID = @cActUCCNo,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME(),
            TrafficCop = NULL
         FROM dbo.PickDetail PD
         WHERE Storerkey = @cStorerKey
            AND DropID = @cTaskUCCNo
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 235076
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd PickDetail Fail
            GOTO RollBackTran
         END
         --v1.0.0 END
      END -- step3, no swap lot
      
      -- Swap LOT
      ELSE
      BEGIN
         IF @bDebugFlag = 1
            SELECT 'Swap LOT'

         -- Task
         UPDATE dbo.Replenishment WITH (ROWLOCK)
         SET
            LOT = @cActUCCLOT, 
            RefNo = @cActUCCNo,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME(), 
            ArchiveCop = NULL
         WHERE ReplenishmentKey = @cReplenKey
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 235054
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd RPL Fail
            GOTO RollBackTran
         END

         --V1.0.0 START
         --Pickdetail
         UPDATE dbo.PickDetail WITH (ROWLOCK)
         SET
            Lot = @cActUCCLOT,
            DropID = @cActUCCNo,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         FROM dbo.PickDetail PD
         WHERE Storerkey = @cStorerKey
            AND DropID = @cTaskUCCNo
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 235077
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd PickDetail Fail
            GOTO RollBackTran
         END
         --v1.0.0 END
         
         -- Locking
         IF @nTaskQTYReplen > 0
         BEGIN
            IF @bDebugFlag = 1
               SELECT 'Handle QtyReplen'

            -- Task
            UPDATE dbo.LOTxLOCxID WITH (ROWLOCK)
            SET
               QTYReplen = QTYReplen - @nTaskQTYReplen, 
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME()
            WHERE LOT = @cTaskLOT
               AND LOC = @cFromLOC
               AND ID = @cFromID
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 235055
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd LLI Fail
               GOTO RollBackTran
            END

            -- Actual
            UPDATE dbo.LOTxLOCxID WITH (ROWLOCK)
            SET
               QTYReplen = QTYReplen + @nTaskQTYReplen, 
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME()
            WHERE LOT = @cActUCCLOT
               AND LOC = @cFromLOC
               AND ID = @cFromID
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 235056
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd LLI Fail
               GOTO RollBackTran
            END
         END
         
         --V1.0.0 start
         --The customer's pick face capacity is unlitmited. No need to consider PendingMoveIn
         /*
         -- Booking
         IF @nTaskPendingMoveIn > 0
         BEGIN
            EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
               ,'' --FromLOC
               ,'' --FromID
               ,'' --SuggLOC
               ,'' --Storer
               ,@nErrNo  OUTPUT
               ,@cErrMsg OUTPUT
               ,@cUCCNo = @cTaskUCCNo
            IF @nErrNo <> 0
               GOTO RollbackTran

            EXEC rdt.rdt_Putaway_PendingMoveIn '', 'LOCK'
               ,@cFromLOC --FromLOC
               ,@cFromID  --FromID
               ,@cTaskToLOC --SuggLOC
               ,@cStorerKey --Storer
               ,@nErrNo  OUTPUT
               ,@cErrMsg OUTPUT
               ,@cSKU = @cActUCCSKU
               ,@nPutawayQTY = @nActUCCQTY
               ,@cFromLOT = @cActUCCLOT
               ,@cToID = @cTaskToID
               ,@cUCCNo = @cActUCCNo
               ,@nFunc = @nFunc
            IF @nErrNo <> 0
               GOTO RollBackTran
         END
         */
         --V1.0.0 end
      END --step 3 swap lot

      IF @bDebugFlag = 1
         SELECT 'Step3 - Update UCC Status'

      -- Task
      UPDATE dbo.UCC WITH (ROWLOCK)
      SET
         Status = '1', -- 1=Received
         EditDate = GETDATE(),
         EditWho = SUSER_SNAME()
      WHERE StorerKey = @cStorerkey
         AND UCCNo = @cTaskUCCNo
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 235057
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD UCC Fail
         GOTO RollBackTran
      END

      -- Actual
      UPDATE dbo.UCC WITH (ROWLOCK)
      SET
         Status = '4', -- 4=Replen
         EditDate = GETDATE(),
         EditWho = SUSER_SNAME()
      WHERE StorerKey = @cStorerkey
         AND UCCNo = @cActUCCNo
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 235058
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD UCC Fail
         GOTO RollBackTran
      END
      
      GOTO CommitTran
   END -- swap with free ucc

   DECLARE @cAllowOverAllocations NVARCHAR( 1) = '0'
   DECLARE @bSuccess INT = 0
   EXECUTE nspGetRight
      @cFacility,             -- Facility
      @cStorerKey,            -- Storerkey
      '',                     -- SKU
      'ALLOWOVERALLOCATIONS', -- ConfigKey
      @bSuccess              OUTPUT,
      @cAllowOverAllocations OUTPUT,
      0, -- @n_err                 OUTPUT,
      '' -- @c_errmsg              OUTPUT
   IF @bSuccess <> 1
   BEGIN
      SET @nErrNo = 235059
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspGetRight
      GOTO Quit
   END

   -- 4. task UCC, swap with alloc UCC
   -- TaskUCC and ActUCC have pickdetail data, but ActUCC doesn't have a replenishment task
   IF @cActUCCStatus = '3'
   BEGIN
      IF @bDebugFlag = 1
         SELECT 'Step4 - Swap with alloc UCC'

      --V1.0.0 start
      /*
      -- Replenish LOT could be partially or fully overallocated in pick face (have PickDetail)
      IF @cAllowOverAllocations = '1' AND
         (SELECT QTY-QTYAllocated-QTYPicked FROM dbo.LOT WITH (NOLOCK) WHERE LOT = @cTaskLOT) < @nTaskUCCQTY 
      BEGIN
         -- Get task PickDetail
         SET @nQTY_Bal = @nTaskUCCQTY
         SET @curPD = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
            SELECT PD.PickDetailKey, PD.LOT, PD.QTY
            FROM dbo.PickDetail PD WITH (NOLOCK)
            WHERE PD.StorerKey = @cStorerkey
               AND PD.LOT = @cTaskLOT
               AND PD.LOC = @cTaskToLOC
               AND PD.Status = '0'
               AND PD.QTY > 0
         OPEN @curPD
         FETCH NEXT FROM @curPD INTO @cPickDetailKey, @cLOT, @nQTY
         WHILE @@FETCH_STATUS = 0
         BEGIN
            IF @nQTY <= @nQTY_Bal
            BEGIN
               INSERT INTO @tTaskPD (PickDetailKey, LOT, QTY) VALUES (@cPickDetailKey, @cLOT, @nQTY)
               SET @nQTY_Bal = @nQTY_Bal - @nQTY
            END
            ELSE
            BEGIN
               -- Get new PickDetailkey
               EXECUTE dbo.nspg_GetKey
                  'PICKDETAILKEY',
                  10 ,
                  @cNewPickDetailKey OUTPUT,
                  @bSuccess          OUTPUT,
                  @nErrNo            OUTPUT,
                  @cErrMsg           OUTPUT
               IF @bSuccess <> 1
               BEGIN
                  SET @nErrNo = 235060
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_GetKey
                  GOTO RollBackTran
               END
      
               -- Create new a PickDetail to hold the balance
               INSERT INTO dbo.PickDetail (
                  CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM,
                  UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType,
                  ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
                  EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes,
                  PickDetailKey,
                  Status, 
                  QTY,
                  TrafficCop,
                  OptimizeCop)
               SELECT
                  CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot, StorerKey, SKU, AltSku, UOM,
                  UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup,
                  CartonType, ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
                  EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes,
                  @cNewPickDetailKey,
                  Status, 
                  @nQTY - @nQTY_Bal, -- QTY
                  NULL, -- TrafficCop
                  '1'   -- OptimizeCop
               FROM dbo.PickDetail WITH (NOLOCK)
      			WHERE PickDetailKey = @cPickDetailKey
               IF @@ERROR <> 0
               BEGIN
      				SET @nErrNo = 235061
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PKDtl Fail
                  GOTO RollBackTran
               END
      
               -- Split RefKeyLookup
               IF EXISTS( SELECT 1 FROM RefKeyLookup WITH (NOLOCK) WHERE PickDetailKey = @cPickDetailKey)
               BEGIN
                  -- Insert into
                  INSERT INTO dbo.RefKeyLookup (PickDetailkey, PickSlipNo, OrderKey, OrderLineNumber, Loadkey)
                  SELECT @cNewPickDetailKey, PickSlipNo, OrderKey, OrderLineNumber, Loadkey
                  FROM RefKeyLookup WITH (NOLOCK) 
                  WHERE PickDetailKey = @cPickDetailKey
                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 235062
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS RefKeyFail
                     GOTO RollBackTran
                  END
               END
      
               -- Change orginal PickDetail with exact QTY (with TrafficCop)
               UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                  QTY = @nQTY_Bal,
                  EditDate = GETDATE(),
                  EditWho  = SUSER_SNAME(),
                  Trafficcop = NULL
               WHERE PickDetailKey = @cPickDetailKey
               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 235063
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
                  GOTO RollBackTran
               END

               INSERT INTO @tTaskPD (PickDetailKey, LOT, QTY) VALUES (@cPickDetailKey, @cLOT, @nQTY_Bal)
               SET @nQTY_Bal = 0
            END
            
            IF @nQTY_Bal = 0
               BREAK
         
            FETCH NEXT FROM @curPD INTO @cPickDetailKey, @cLOT, @nQTY
         END
      END
      */
      --Get task pickdetail
      INSERT INTO @tTaskPD (PickDetailKey, LOT, QTY)
      SELECT PD.PickDetailKey, PD.LOT, PD.QTY
      FROM dbo.PickDetail PD WITH (NOLOCK)
         JOIN UCC WITH (NOLOCK) ON (UCC.UCCNo = PD.DropID)
      WHERE UCC.StorerKey = @cStorerkey
         AND PD.StorerKey = @cStorerkey
         AND UCC.UCCNo = @cTaskUCCNo
         AND UCC.Status = '4'
         AND PD.Status = '0'
         AND PD.QTY > 0
      --V1.0.0 end

      -- Get actual PickDetail
      INSERT INTO @tActPD (PickDetailKey, LOT, QTY)
      SELECT PD.PickDetailKey, PD.LOT, PD.QTY
      FROM dbo.PickDetail PD WITH (NOLOCK)
         JOIN UCC WITH (NOLOCK) ON (UCC.UCCNo = PD.DropID)
      WHERE UCC.StorerKey = @cStorerkey
         AND PD.StorerKey = @cStorerkey
         AND UCC.UCCNo = @cActUCCNo
         AND UCC.Status = '3'
         AND PD.Status = '0'
         AND PD.QTY > 0

      IF @bDebugFlag = 1
      BEGIN
         SELECT 'Task UCC PickDetail'
         SELECT * FROM @tTaskPD
         SELECT 'ActUCC PickDetail'
         SELECT * FROM @tActPD
      END

      --V1.0.0 start
      -- Remove the check, because the sum(Pickdetail.Qty) <= UCCQty     
      -- Check PickDetail changed
      /*
      IF @nActUCCQTY <> (SELECT ISNULL( SUM( QTY), 0) FROM @tActPD)
      BEGIN
         SET @nErrNo = 235064
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PKDtl changed
         GOTO RollBackTran
      END
      */
      --V1.0.0 end

      -- NO swap LOT
      IF @cTaskLOT = @cActUCCLOT
      BEGIN
         IF @bDebugFlag = 1
            SELECT 'Step4 - No swap LOT'
            
         -- Task
         UPDATE dbo.Replenishment WITH (ROWLOCK)
         SET
            RefNo = @cActUCCNo,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME(), 
            ArchiveCop = NULL
         WHERE ReplenishmentKey = @cReplenKey
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 235060
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd RPL Fail
            GOTO RollBackTran
         END

         -- Swap pickdetail dropid - Task
         SET @curPD = CURSOR FOR
            SELECT PickDetailKey FROM @tTaskPD ORDER BY PickDetailKey
         OPEN @curPD
         FETCH NEXT FROM @curPD INTO @cPickDetailKey
         WHILE @@FETCH_STATUS = 0
         BEGIN
            -- Update PickDetail
            UPDATE dbo.PickDetail WITH (ROWLOCK)
            SET
               DropID = @cActUCCNo,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME(),
               TrafficCop = NULL
            FROM dbo.PickDetail PD
            WHERE PickDetailKey = @cPickDetailKey
            IF @@ERROR <> 0 OR @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 235061
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
               GOTO RollBackTran
            END
            FETCH NEXT FROM @curPD INTO @cPickDetailKey
         END
         
         -- swap pickdetail dropid - Actual
         SET @curPD = CURSOR FOR
            SELECT PickDetailKey FROM @tActPD ORDER BY PickDetailKey
         OPEN @curPD
         FETCH NEXT FROM @curPD INTO @cPickDetailKey
         WHILE @@FETCH_STATUS = 0
         BEGIN
            -- Update PickDetail
            UPDATE dbo.PickDetail WITH (ROWLOCK)
            SET
               DropID = @cTaskUCCNo,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME(),
               TrafficCop = NULL
            FROM dbo.PickDetail PD
            WHERE PickDetailKey = @cPickDetailKey
            IF @@ERROR <> 0 OR @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 235062
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
               GOTO RollBackTran
            END
            FETCH NEXT FROM @curPD INTO @cPickDetailKey
         END
      END -- step4 no swap lot
      
      -- Swap LOT
      ELSE
      BEGIN
         IF @bDebugFlag = 1
            SELECT 'Step4 - Swap LOT'

         -- Unallocate (task)
         SET @curPD = CURSOR FOR
            SELECT PickDetailKey FROM @tTaskPD ORDER BY PickDetailKey
         OPEN @curPD
         FETCH NEXT FROM @curPD INTO @cPickDetailKey
         WHILE @@FETCH_STATUS = 0
         BEGIN
            UPDATE dbo.PickDetail WITH (ROWLOCK)
            SET
               QTY = 0,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME()
            WHERE PickDetailKey = @cPickDetailKey
            IF @@ERROR <> 0 OR @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 235078
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
               GOTO RollBackTran
            END
            FETCH NEXT FROM @curPD INTO @cPickDetailKey
         END
         
         -- Unallocate (actual)
         SET @curPD = CURSOR FOR
            SELECT PickDetailKey FROM @tActPD ORDER BY PickDetailKey
         OPEN @curPD
         FETCH NEXT FROM @curPD INTO @cPickDetailKey
         WHILE @@FETCH_STATUS = 0
         BEGIN
            UPDATE dbo.PickDetail WITH (ROWLOCK)
            SET
               QTY = 0,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME()
            WHERE PickDetailKey = @cPickDetailKey
            IF @@ERROR <> 0 OR @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 235079
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--UPD PKDtl Fail
               GOTO RollBackTran
            END
            FETCH NEXT FROM @curPD INTO @cPickDetailKey
         END

         -- Reallocate (task)
         SET @curPD = CURSOR FOR
            SELECT PickDetailKey, QTY FROM @tTaskPD ORDER BY PickDetailKey
         OPEN @curPD
         FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY
         WHILE @@FETCH_STATUS = 0
         BEGIN
            UPDATE dbo.PickDetail WITH (ROWLOCK)
            SET
               LOT = @cActUCCLOT,
               DropID = @cActUCCNo, --v1.0.0
               QTY = @nQTY,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME()
            WHERE PickDetailKey = @cPickDetailKey
            IF @@ERROR <> 0 OR @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 235080
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO RollBackTran
            END
            FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY
         END

         -- Reallocate (actual)
         SET @curPD = CURSOR FOR
            SELECT PickDetailKey, QTY FROM @tActPD ORDER BY PickDetailKey
         OPEN @curPD
         FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY
         WHILE @@FETCH_STATUS = 0
         BEGIN
            UPDATE dbo.PickDetail WITH (ROWLOCK)
            SET
               LOT = @cTaskLOT,
               DropID = @cTaskUCCNo,
               QTY = @nQTY,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME()
            WHERE PickDetailKey = @cPickDetailKey
            IF @@ERROR <> 0 OR @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 235081
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO RollBackTran
            END
            FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY
         END

         -- Update replenishment lot and refno
         UPDATE dbo.Replenishment WITH (ROWLOCK)
         SET
            LOT = @cActUCCLOT, 
            RefNo = @cActUCCNo,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME(), 
            ArchiveCop = NULL
         WHERE ReplenishmentKey = @cReplenKey
         IF @@ERROR <> 0 OR @@ROWCOUNT = 0
         BEGIN
            SET @nErrNo = 235067
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd RPL Fail
            GOTO RollBackTran
         END
         
         -- Locking
         IF @nTaskQTYReplen > 0
         BEGIN
            -- Task
            UPDATE dbo.LOTxLOCxID SET
               QTYReplen = QTYReplen - @nTaskQTYReplen, 
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME()
            WHERE LOT = @cTaskLOT
               AND LOC = @cFromLOC
               AND ID = @cFromID
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 235068
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd LLI Fail
               GOTO RollBackTran
            END

            -- Actual
            UPDATE dbo.LOTxLOCxID SET
               QTYReplen = QTYReplen + @nTaskQTYReplen, 
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME()
            WHERE LOT = @cActUCCLOT
               AND LOC = @cFromLOC
               AND ID = @cFromID
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 235069
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd LLI Fail
               GOTO RollBackTran
            END
         END
         
         --V1.0.0 start
         --The customer's pick face capacity is unlitmited. No need to consider PendingMoveIn
         /*
         -- Booking
         IF @nTaskPendingMoveIn > 0
         BEGIN
            EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
               ,'' --FromLOC
               ,'' --FromID
               ,'' --SuggLOC
               ,'' --Storer
               ,@nErrNo  OUTPUT
               ,@cErrMsg OUTPUT
               ,@cUCCNo = @cTaskUCCNo
            IF @nErrNo <> 0
               GOTO RollbackTran

            EXEC rdt.rdt_Putaway_PendingMoveIn '', 'LOCK'
               ,@cFromLOC --FromLOC
               ,@cFromID  --FromID
               ,@cTaskToLOC --SuggLOC
               ,@cStorerKey --Storer
               ,@nErrNo  OUTPUT
               ,@cErrMsg OUTPUT
               ,@cSKU = @cActUCCSKU
               ,@nPutawayQTY = @nActUCCQTY
               ,@cFromLOT = @cActUCCLOT
               ,@cToID = @cTaskToID
               ,@cUCCNo = @cActUCCNo
               ,@nFunc = @nFunc
            IF @nErrNo <> 0
            GOTO RollBackTran
         END
         */
      END -- step4 swap lot

      IF @bDebugFlag = 1
         SELECT 'Step4 - Update UCC Status'
      -- Task
      UPDATE dbo.UCC SET
         Status = '3', -- 3=Allocated
         EditDate = GETDATE(),
         EditWho = SUSER_SNAME()
      WHERE StorerKey = @cStorerkey
         AND UCCNo = @cTaskUCCNo
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 235063
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD UCC Fail
         GOTO RollBackTran
      END

      -- Actual
      UPDATE dbo.UCC SET
         Status = '4', -- 4=Replen
         EditDate = GETDATE(),
         EditWho = SUSER_SNAME()
      WHERE StorerKey = @cStorerkey
         AND UCCNo = @cActUCCNo
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 235064
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD UCC Fail
         GOTO RollBackTran
      END
   END -- swap with alloc ucc

   -- 5. task UCC, swap with alloc UCC
   -- both TaskUCC and ActUCC have replenishment and pickdetail data
   IF @cActUCCStatus = '4'
   BEGIN
      IF @bDebugFlag = 1
         SELECT 'Step5 - Swap with Replened UCC'

      --V1.0.0 start
      /*
      -- Replenish LOT could be partially or fully overallocated in pick face (have PickDetail)
      IF @cAllowOverAllocations = '1' AND
         (SELECT QTY-QTYAllocated-QTYPicked FROM dbo.LOT WITH (NOLOCK) WHERE LOT = @cTaskLOT) < @nTaskUCCQTY 
      BEGIN
         -- Get task PickDetail
         SET @nQTY_Bal = @nTaskUCCQTY
         SET @curPD = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
            SELECT PD.PickDetailKey, PD.LOT, PD.QTY
            FROM dbo.PickDetail PD WITH (NOLOCK)
            WHERE PD.StorerKey = @cStorerkey
               AND PD.LOT = @cTaskLOT
               AND PD.LOC = @cTaskToLOC
               AND PD.Status = '0'
               AND PD.QTY > 0
         OPEN @curPD
         FETCH NEXT FROM @curPD INTO @cPickDetailKey, @cLOT, @nQTY
         WHILE @@FETCH_STATUS = 0
         BEGIN
            IF @nQTY <= @nQTY_Bal
            BEGIN
               INSERT INTO @tTaskPD (PickDetailKey, LOT, QTY) VALUES (@cPickDetailKey, @cLOT, @nQTY)
               SET @nQTY_Bal = @nQTY_Bal - @nQTY
            END
            ELSE
            BEGIN
               -- Get new PickDetailkey
               EXECUTE dbo.nspg_GetKey
                  'PICKDETAILKEY',
                  10 ,
                  @cNewPickDetailKey OUTPUT,
                  @bSuccess          OUTPUT,
                  @nErrNo            OUTPUT,
                  @cErrMsg           OUTPUT
               IF @bSuccess <> 1
               BEGIN
                  SET @nErrNo = 235060
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_GetKey
                  GOTO RollBackTran
               END
      
               -- Create new a PickDetail to hold the balance
               INSERT INTO dbo.PickDetail (
                  CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM,
                  UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType,
                  ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
                  EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes,
                  PickDetailKey,
                  Status, 
                  QTY,
                  TrafficCop,
                  OptimizeCop)
               SELECT
                  CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot, StorerKey, SKU, AltSku, UOM,
                  UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup,
                  CartonType, ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
                  EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes,
                  @cNewPickDetailKey,
                  Status, 
                  @nQTY - @nQTY_Bal, -- QTY
                  NULL, -- TrafficCop
                  '1'   -- OptimizeCop
               FROM dbo.PickDetail WITH (NOLOCK)
      			WHERE PickDetailKey = @cPickDetailKey
               IF @@ERROR <> 0
               BEGIN
      				SET @nErrNo = 235061
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PKDtl Fail
                  GOTO RollBackTran
               END
      
               -- Split RefKeyLookup
               IF EXISTS( SELECT 1 FROM RefKeyLookup WITH (NOLOCK) WHERE PickDetailKey = @cPickDetailKey)
               BEGIN
                  -- Insert into
                  INSERT INTO dbo.RefKeyLookup (PickDetailkey, PickSlipNo, OrderKey, OrderLineNumber, Loadkey)
                  SELECT @cNewPickDetailKey, PickSlipNo, OrderKey, OrderLineNumber, Loadkey
                  FROM RefKeyLookup WITH (NOLOCK) 
                  WHERE PickDetailKey = @cPickDetailKey
                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 235062
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS RefKeyFail
                     GOTO RollBackTran
                  END
               END
      
               -- Change orginal PickDetail with exact QTY (with TrafficCop)
               UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                  QTY = @nQTY_Bal,
                  EditDate = GETDATE(),
                  EditWho  = SUSER_SNAME(),
                  Trafficcop = NULL
               WHERE PickDetailKey = @cPickDetailKey
               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 235063
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
                  GOTO RollBackTran
               END

               INSERT INTO @tTaskPD (PickDetailKey, LOT, QTY) VALUES (@cPickDetailKey, @cLOT, @nQTY_Bal)
               SET @nQTY_Bal = 0
            END
            
            IF @nQTY_Bal = 0
               BREAK
         
            FETCH NEXT FROM @curPD INTO @cPickDetailKey, @cLOT, @nQTY
         END
      END
      */
      --Get task pickdetail
      INSERT INTO @tTaskPD (PickDetailKey, LOT, QTY)
      SELECT PD.PickDetailKey, PD.LOT, PD.QTY
      FROM dbo.PickDetail PD WITH (NOLOCK)
         JOIN UCC WITH (NOLOCK) ON (UCC.UCCNo = PD.DropID)
      WHERE UCC.StorerKey = @cStorerkey
         AND PD.StorerKey = @cStorerkey
         AND UCC.UCCNo = @cTaskUCCNo
         AND UCC.Status = '4'
         AND PD.Status = '0'
         AND PD.QTY > 0
      --V1.0.0 end

      -- Get actual PickDetail
      INSERT INTO @tActPD (PickDetailKey, LOT, QTY)
      SELECT PD.PickDetailKey, PD.LOT, PD.QTY
      FROM dbo.PickDetail PD WITH (NOLOCK)
         JOIN UCC WITH (NOLOCK) ON (UCC.UCCNo = PD.DropID)
      WHERE UCC.StorerKey = @cStorerkey
         AND PD.StorerKey = @cStorerkey
         AND UCC.UCCNo = @cActUCCNo
         AND UCC.Status = '4'
         AND PD.Status = '0'
         AND PD.QTY > 0

      IF @bDebugFlag = 1
      BEGIN
         SELECT 'Task UCC PickDetail'
         SELECT * FROM @tTaskPD
         SELECT 'ActUCC PickDetail'
         SELECT * FROM @tActPD
      END

      --V1.0.0 start
      -- Remove the check, because the sum(Pickdetail.Qty) <= UCCQty     
      -- Check PickDetail changed
      /*
      IF @nActUCCQTY <> (SELECT ISNULL( SUM( QTY), 0) FROM @tActPD)
      BEGIN
         SET @nErrNo = 235064
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PKDtl changed
         GOTO RollBackTran
      END
      */
      --V1.0.0 end

      -- NO swap LOT
      IF @cTaskLOT = @cActUCCLOT
      BEGIN
         IF @bDebugFlag = 1
            SELECT 'Step5 - No swap LOT'
            
         -- Acutal
         UPDATE dbo.Replenishment WITH (ROWLOCK)
         SET
            RefNo = @cTaskUCCNo,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME(), 
            ArchiveCop = NULL
         WHERE StorerKey = @cStorerKey
            AND RefNo = @cActUCCNo
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 235065
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd RPL Fail
            GOTO RollBackTran
         END

         -- Task
         UPDATE dbo.Replenishment WITH (ROWLOCK)
         SET
            RefNo = @cActUCCNo,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME(), 
            ArchiveCop = NULL
         WHERE ReplenishmentKey = @cReplenKey
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 235066
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd RPL Fail
            GOTO RollBackTran
         END

         -- Swap pickdetail dropid - Task
         SET @curPD = CURSOR FOR
            SELECT PickDetailKey FROM @tTaskPD ORDER BY PickDetailKey
         OPEN @curPD
         FETCH NEXT FROM @curPD INTO @cPickDetailKey
         WHILE @@FETCH_STATUS = 0
         BEGIN
            -- Update PickDetail
            UPDATE dbo.PickDetail WITH (ROWLOCK)
            SET
               DropID = @cActUCCNo,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME(),
               TrafficCop = NULL
            FROM dbo.PickDetail PD
            WHERE PickDetailKey = @cPickDetailKey
            IF @@ERROR <> 0 OR @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 235067
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
               GOTO RollBackTran
            END
            FETCH NEXT FROM @curPD INTO @cPickDetailKey
         END
         
         -- swap pickdetail dropid - Actual
         SET @curPD = CURSOR FOR
            SELECT PickDetailKey FROM @tActPD ORDER BY PickDetailKey
         OPEN @curPD
         FETCH NEXT FROM @curPD INTO @cPickDetailKey
         WHILE @@FETCH_STATUS = 0
         BEGIN
            -- Update PickDetail
            UPDATE dbo.PickDetail WITH (ROWLOCK)
            SET
               DropID = @cTaskUCCNo,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME(),
               TrafficCop = NULL
            FROM dbo.PickDetail PD
            WHERE PickDetailKey = @cPickDetailKey
            IF @@ERROR <> 0 OR @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 235068
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
               GOTO RollBackTran
            END
            FETCH NEXT FROM @curPD INTO @cPickDetailKey
         END
      END -- step4 no swap lot
      
      -- Swap LOT
      ELSE
      BEGIN
         IF @bDebugFlag = 1
            SELECT 'Step5 - Swap LOT'

         -- Unallocate (task)
         SET @curPD = CURSOR FOR
            SELECT PickDetailKey FROM @tTaskPD ORDER BY PickDetailKey
         OPEN @curPD
         FETCH NEXT FROM @curPD INTO @cPickDetailKey
         WHILE @@FETCH_STATUS = 0
         BEGIN
            UPDATE dbo.PickDetail WITH (ROWLOCK)
            SET
               QTY = 0,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME()
            WHERE PickDetailKey = @cPickDetailKey
            IF @@ERROR <> 0 OR @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 235069
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
               GOTO RollBackTran
            END
            FETCH NEXT FROM @curPD INTO @cPickDetailKey
         END
         
         -- Unallocate (actual)
         SET @curPD = CURSOR FOR
            SELECT PickDetailKey FROM @tActPD ORDER BY PickDetailKey
         OPEN @curPD
         FETCH NEXT FROM @curPD INTO @cPickDetailKey
         WHILE @@FETCH_STATUS = 0
         BEGIN
            UPDATE dbo.PickDetail WITH (ROWLOCK)
            SET
               QTY = 0,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME()
            WHERE PickDetailKey = @cPickDetailKey
            IF @@ERROR <> 0 OR @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 235070
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--UPD PKDtl Fail
               GOTO RollBackTran
            END
            FETCH NEXT FROM @curPD INTO @cPickDetailKey
         END

         -- Reallocate (task)
         SET @curPD = CURSOR FOR
            SELECT PickDetailKey, QTY FROM @tTaskPD ORDER BY PickDetailKey
         OPEN @curPD
         FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY
         WHILE @@FETCH_STATUS = 0
         BEGIN
            UPDATE dbo.PickDetail WITH (ROWLOCK)
            SET
               LOT = @cActUCCLOT,
               DropID = @cActUCCNo, --v1.0.0
               QTY = @nQTY,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME()
            WHERE PickDetailKey = @cPickDetailKey
            IF @@ERROR <> 0 OR @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 235071
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO RollBackTran
            END
            FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY
         END

         -- Reallocate (actual)
         SET @curPD = CURSOR FOR
            SELECT PickDetailKey, QTY FROM @tActPD ORDER BY PickDetailKey
         OPEN @curPD
         FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY
         WHILE @@FETCH_STATUS = 0
         BEGIN
            UPDATE dbo.PickDetail WITH (ROWLOCK)
            SET
               LOT = @cTaskLOT,
               DropID = @cTaskUCCNo,
               QTY = @nQTY,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME()
            WHERE PickDetailKey = @cPickDetailKey
            IF @@ERROR <> 0 OR @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 235072
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO RollBackTran
            END
            FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY
         END
         
         --v1.0.0 start
         --Swap refno in Replenishment
         --Actual UCC
         UPDATE dbo.Replenishment WITH (ROWLOCK)
         SET
            LOT = @cTaskUCCLOT, 
            RefNo = @cTaskUCCNo,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME(), 
            ArchiveCop = NULL
         WHERE RefNo = @cActUCCNo
         IF @@ERROR <> 0 OR @@ROWCOUNT = 0
         BEGIN
            SET @nErrNo = 235073
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd RPL Fail
            GOTO RollBackTran
         END
         --v1.0.0 end

         -- Task UCC
         UPDATE dbo.Replenishment WITH (ROWLOCK)
         SET
            LOT = @cActUCCLOT, 
            RefNo = @cActUCCNo,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME(), 
            ArchiveCop = NULL
         WHERE ReplenishmentKey = @cReplenKey
         IF @@ERROR <> 0 OR @@ROWCOUNT = 0
         BEGIN
            SET @nErrNo = 235074
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd RPL Fail
            GOTO RollBackTran
         END
         
         -- V1.0.0 start
         -- No need to handle QtyReplen, as the qty between Task UCC and ActUCC are same
         /*
         -- Locking
         IF @nTaskQTYReplen > 0
         BEGIN
            -- Task
            UPDATE dbo.LOTxLOCxID SET
               QTYReplen = QTYReplen - @nTaskQTYReplen, 
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME()
            WHERE LOT = @cTaskLOT
               AND LOC = @cFromLOC
               AND ID = @cFromID
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 235068
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd LLI Fail
               GOTO RollBackTran
            END

            -- Actual
            UPDATE dbo.LOTxLOCxID SET
               QTYReplen = QTYReplen + @nTaskQTYReplen, 
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME()
            WHERE LOT = @cActUCCLOT
               AND LOC = @cFromLOC
               AND ID = @cFromID
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 235069
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd LLI Fail
               GOTO RollBackTran
            END
         END
         */
         

         --The customer's pick face capacity is unlitmited. No need to consider PendingMoveIn
         /*
         -- Booking
         IF @nTaskPendingMoveIn > 0
         BEGIN
            EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
               ,'' --FromLOC
               ,'' --FromID
               ,'' --SuggLOC
               ,'' --Storer
               ,@nErrNo  OUTPUT
               ,@cErrMsg OUTPUT
               ,@cUCCNo = @cTaskUCCNo
            IF @nErrNo <> 0
               GOTO RollbackTran

            EXEC rdt.rdt_Putaway_PendingMoveIn '', 'LOCK'
               ,@cFromLOC --FromLOC
               ,@cFromID  --FromID
               ,@cTaskToLOC --SuggLOC
               ,@cStorerKey --Storer
               ,@nErrNo  OUTPUT
               ,@cErrMsg OUTPUT
               ,@cSKU = @cActUCCSKU
               ,@nPutawayQTY = @nActUCCQTY
               ,@cFromLOT = @cActUCCLOT
               ,@cToID = @cTaskToID
               ,@cUCCNo = @cActUCCNo
               ,@nFunc = @nFunc
            IF @nErrNo <> 0
            GOTO RollBackTran
         END
         */
         --V1.0.0 end
      END -- step4 swap lot

      --V1.0.0 start
      -- Remove UCC status update statements, as both of UCC status should be 4. No change.
      -- Task
      --V1.0.0 end
   END -- swap with replen ucc
   --V1.0.0 end

CommitTran:
   -- Log UCC swap
   IF @cTaskUCCNo <> @cActUCCNo
   BEGIN
      INSERT INTO rdt.SwapUCC (Func, UCC, NewUCC, ReplenGroup, UCCStatus, NewUCCStatus)
      VALUES (@nFunc, @cTaskUCCNo, @cActUCCNo, @cReplenKey, @cTaskUCCStatus, @cActUCCStatus)
   END

   COMMIT TRAN rdt_896SwapUCC02
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_896SwapUCC02 -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO
GRANT EXECUTE ON  [RDT].[rdt_896SwapUCC02] TO [NSQL]
GO
