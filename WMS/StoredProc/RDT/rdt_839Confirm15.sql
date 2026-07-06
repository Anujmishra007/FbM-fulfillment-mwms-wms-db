
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/******************************************************************************/
/* Store procedure: rdt_839Confirm15                                          */
/* Copyright      : Maersk                                                    */
/* Customer       : PAGEIND                                                   */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2026-01-05 1.0  NickT      FCR-9040. Created                               */
/******************************************************************************/
    
CREATE OR ALTER PROC rdt.rdt_839Confirm15 (
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @nStep         INT,
   @nInputKey     INT,
   @cFacility     NVARCHAR( 5) ,
   @cStorerKey    NVARCHAR( 15),
   @cType         NVARCHAR( 10),
   @cPickSlipNo   NVARCHAR( 10),
   @cPickZone     NVARCHAR( 10),
   @cDropID       NVARCHAR( 20),
   @cLOC          NVARCHAR( 10),
   @cSKU          NVARCHAR( 20),
   @nQTY          INT,
   @cLottableCode NVARCHAR( 30),
   @cLottable01   NVARCHAR( 18),
   @cLottable02   NVARCHAR( 18),
   @cLottable03   NVARCHAR( 18),
   @dLottable04   DATETIME,
   @dLottable05   DATETIME,
   @cLottable06   NVARCHAR( 30),
   @cLottable07   NVARCHAR( 30),
   @cLottable08   NVARCHAR( 30),
   @cLottable09   NVARCHAR( 30),
   @cLottable10   NVARCHAR( 30),
   @cLottable11   NVARCHAR( 30),
   @cLottable12   NVARCHAR( 30),
   @dLottable13   DATETIME,
   @dLottable14   DATETIME,
   @dLottable15   DATETIME,
   @cPackData1    NVARCHAR( 30),
   @cPackData2    NVARCHAR( 30),
   @cPackData3    NVARCHAR( 30),
   @cID           NVARCHAR( 18),
   @cSerialNo     NVARCHAR( 30),
   @nSerialQTY    INT,
   @nBulkSNO      INT,
   @nBulkSNOQTY   INT,
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR(250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @cSQL                   NVARCHAR( MAX),
      @cSQLParam              NVARCHAR( MAX),
      @cSQL1                  NVARCHAR( MAX),
      @nTranCount             INT,

      @cOrderKey              NVARCHAR( 10),
      @cLoadKey               NVARCHAR( 10),
      @cZone                  NVARCHAR( 18),
      @cPickDetailKey         NVARCHAR( 18),
      @cPickConfirmStatus     NVARCHAR( 1),
      @cPickDetailDropID      NVARCHAR( 20),
      @cUOM                   NVARCHAR( 10),
      @nQTY_Bal               INT,
      @nQTY_PD                INT,
      @bSuccess               INT,
      @nSerialNoAdded         INT = 0,
      @nLoopIndex             INT = -1,
      @nLoopIndex1            INT = -1,
      @curPD                  CURSOR,
      @cWhere                 NVARCHAR( MAX),
      @cUCC                   NVARCHAR( 20),
      @cOriUCC                NVARCHAR( 20),
      @cLOT                   NVARCHAR( 10),
      @cScannedUCC            NVARCHAR( 20),
      @cSuggestedUCC          NVARCHAR( 20),
      @cScannedUCCLoc         NVARCHAR( 10),
      @cScannedUCCLot         NVARCHAR( 10),
      @cScannedUCCID          NVARCHAR( 18),
      @cScannedUCCQty         INT,
      @cSuggestedPieceLOT     NVARCHAR( 10),
      @cScannedPieceLOT       NVARCHAR( 10),
      @cStatus                NVARCHAR( 5),
      @cUserName              NVARCHAR( 18),
      @nPickedQty             INT,
      @cReasonKey             NVARCHAR( 10),
      @cLoopOrderKey          NVARCHAR( 10),
      @cLoopOrderKeyLineNumber NVARCHAR( 5),
      @cLoopDropID             NVARCHAR( 20)

   --RDTMOBREC
   -- C_String1 -> SuggestedUCC (UCC)
   -- C_String2 -> SuggestedLOT (Piece)
   -- C_String3 -> ScannedUCC (UCC)
   -- C_String4 -> ScannedUCCLottable01 (Piece)
   -- C_String7 -> ScannedSerialNo (Piece)
   -- C_String8 -> @cScannedPieceLot (Piece)

   SELECT
      @cSuggestedUCC = C_String1,
      @cScannedUCC = C_String3,

      @cSuggestedPieceLOT = C_String2,
      @cScannedPieceLOT = C_String8,
      @cUserName = UserName
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   -- Handling transaction
   SET @nTranCount = @@TRANCOUNT


   SET @cOrderKey = ''
   SET @cLoadKey = ''
   SET @cZone = ''

   -- Get storer config
   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'

   -- Get PickHeader info
   SELECT TOP 1
      @cOrderKey = OrderKey,
      @cLoadKey = ExternOrderKey,
      @cZone = Zone
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   DECLARE @tUCCPickDetail TABLE
   (
      RowIndex             INT IDENTITY(1,1),
      PickDetailKey        NVARCHAR( 18),
      Id                   NVARCHAR(18),
      LOT                  NVARCHAR(10),
      Qty                  INT,
      UCCNo                NVARCHAR(20),
      OriUCCNo             NVARCHAR(20),
      UCCQty               INT,
      Dropid               NVARCHAR(20),
      Status               NVARCHAR(5) DEFAULT ('0')
   )

   DECLARE @tPiecePickDetail TABLE
   (
      RowIndex             INT IDENTITY(1,1),
      PickDetailKey        NVARCHAR( 18),
      Loc                  NVARCHAR( 10),
      Id                   NVARCHAR(18),
      DropID               NVARCHAR(20),
      Qty                  INT,
      Lot                  NVARCHAR( 10),
      PickedQty            INT,
      Status               NVARCHAR(5) DEFAULT ('0'),
      ReasonKey            NVARCHAR(10) DEFAULT ('')
   )

   DECLARE @tNewPickDetail TABLE
   (
      CaseID NVARCHAR( 20), 
      PickHeaderKey NVARCHAR( 18), 
      OrderKey NVARCHAR( 10), 
      OrderLineNumber NVARCHAR( 5), 
      LOT NVARCHAR( 10), 
      StorerKey NVARCHAR( 15), 
      SKU NVARCHAR( 20), 
      AltSKU NVARCHAR( 20), 
      UOM NVARCHAR( 10), 
      UOMQTY INT,
      QTYMoved INT, 
      DropID NVARCHAR( 20), 
      LOC NVARCHAR( 10), 
      ID NVARCHAR( 18), 
      PackKey NVARCHAR( 10), 
      UpdateSource NVARCHAR( 10), 
      CartonGroup NVARCHAR( 10), 
      CartonType NVARCHAR( 10), 
      ToLoc NVARCHAR( 10), 
      DoReplenish NVARCHAR( 1), 
      ReplenishZone NVARCHAR( 10), 
      DoCartonize NVARCHAR( 1), 
      PickMethod NVARCHAR( 1), 
      WaveKey NVARCHAR( 10), 
      EffectiveDate DATETIME, 
      ArchiveCop NVARCHAR( 1), 
      ShipFlag NVARCHAR( 1), 
      PickSlipNo NVARCHAR( 10), 
      TaskDetailKey NVARCHAR( 10),  
      TaskManagerReasonKey NVARCHAR( 10), 
      Notes NVARCHAR( 4000), 
      PickDetailKey NVARCHAR( 18) PRIMARY KEY, 
      Status NVARCHAR( 10), 
      SourceType NVARCHAR( 50), 
      QTY INT,
      TrafficCop NVARCHAR( 1), 
      OptimizeCop NVARCHAR( 1), 
      Channel_ID BIGINT
   )

   DECLARE @tPiecePickDetailKey TABLE
   (
      RowIndex             INT IDENTITY(1,1),
      PickDetailKey        NVARCHAR( 18)
   )

   -- Get lottable filter
   EXEC rdt.rdt_Lottable_GetCurrentSQL @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLottableCode, 4, 'LA',
      @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
      @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
      @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
      @cWhere   OUTPUT,
      @nErrNo   OUTPUT,
      @cErrMsg  OUTPUT

   /***********************************************************************************************
                                              SHORT
   ***********************************************************************************************/
   IF @cType = 'SHORT'
   BEGIN
      --------SHORT UCC
      INSERT INTO @tUCCPickDetail ( PickDetailKey, Id, LOT, Qty, UCCNo, OriUCCNo, UCCQty, Status)
      SELECT PD.PickDetailKey, PD.Id, PD.Lot, PD.Qty, RPL.Remarks, PD.DropID, RPL.ActQty, RPL.Status
      FROM RDT.rdtPickLog RPL WITH(NOLOCK)
      INNER JOIN dbo.PickDetail PD WITH(NOLOCK) ON RPL.PickDetailKey = PD.PickDetailKey
      WHERE RPL.PickSlipNo = @cPickSlipNo
         AND (RPL.Mobile = @nMobile OR RPL.AddWho = @cUserName)
         AND RPL.Status = '4'
         AND RPL.PickMethod = 'GetTask-U'

      --------SHORT Piece
      INSERT INTO @tPiecePickDetail ( PickDetailKey, Loc, Id, DropID, Qty, Lot, PickedQty, Status, ReasonKey)
      SELECT RPL.PickDetailKey, PD.Loc, PD.Id, PD.DropID, PD.Qty, PD.Lot, RPL.PickLockQty, RPL.Status, RPL.PutawayZone
      FROM RDT.rdtPickLog RPL WITH(NOLOCK)
      INNER JOIN dbo.PickDetail PD WITH(NOLOCK) ON RPL.PickDetailKey = PD.PickDetailKey
      WHERE RPL.PickSlipNo = @cPickSlipNo
         AND (RPL.Mobile = @nMobile OR RPL.AddWho = @cUserName)
         AND RPL.PickMethod = 'GetTask-P'
         AND RPL.Status = '4'
   END
   ELSE
   BEGIN
      ---- Preapare scanned UCC data
      INSERT INTO @tUCCPickDetail ( PickDetailKey, Id, LOT, Qty, UCCNo, OriUCCNo, UCCQty, Status, DropID)
      SELECT PD.PickDetailKey, PD.Id, PD.Lot, PD.Qty, RPL.Remarks, PD.DropID, RPL.ActQty, IIF(RPL.Status = '9', '9', '0'), RPL.DropID
      FROM RDT.rdtPickLog RPL WITH(NOLOCK)
      INNER JOIN dbo.PickDetail PD WITH(NOLOCK) ON RPL.PickDetailKey = PD.PickDetailKey
      WHERE RPL.PickSlipNo = @cPickSlipNo
         AND ISNULL(RPL.DropID, '') LIKE IIF(@cDropID = 'ALLDROPID', '%%', @cDropID)
         AND (RPL.Mobile = @nMobile OR RPL.AddWho = @cUserName)
         AND RPL.PickMethod = 'GetTask-U'

      INSERT INTO @tPiecePickDetailKey ( PickDetailKey)
      SELECT DISTINCT RPL.PickDetailKey
      FROM RDT.rdtPickLog RPL WITH(NOLOCK)
      INNER JOIN dbo.PickDetail PD WITH(NOLOCK) ON RPL.PickDetailKey = PD.PickDetailKey
      WHERE RPL.PickSlipNo = @cPickSlipNo
         AND ISNULL(RPL.DropID, '') LIKE IIF(@cDropID = 'ALLDROPID', '%%', @cDropID)
         AND (RPL.Mobile = @nMobile OR RPL.AddWho = @cUserName)
         AND RPL.PickMethod = 'Pick-P'

      INSERT INTO @tPiecePickDetail ( PickDetailKey, Loc, Id, DropID, Qty, Lot, PickedQty, Status)
      SELECT RPL.PickDetailKey, PD.Loc, PD.Id, PD.DropID, PD.Qty, PD.Lot, RPL.PickLockQty, RPL.Status
      FROM RDT.rdtPickLog RPL WITH(NOLOCK)
      INNER JOIN dbo.PickDetail PD WITH(NOLOCK) ON RPL.PickDetailKey = PD.PickDetailKey
      INNER JOIN @tPiecePickDetailKey TPPDK ON RPL.PickDetailKey = TPPDK.PickDetailKey
      WHERE RPL.PickSlipNo = @cPickSlipNo
         AND RPL.PickMethod = 'GetTask-P'
      UNION
      SELECT RPL.PickDetailKey, PD.Loc, PD.Id, PD.DropID, PD.Qty, PD.Lot, RPL.PickLockQty, RPL.Status
      FROM RDT.rdtPickLog RPL WITH(NOLOCK)
      INNER JOIN dbo.PickDetail PD WITH(NOLOCK) ON RPL.PickDetailKey = PD.PickDetailKey
      WHERE RPL.PickSlipNo = @cPickSlipNo
         AND ISNULL(RPL.DropID, '') LIKE IIF(@cDropID = 'ALLDROPID', '%%', @cDropID)
         AND (RPL.Mobile = @nMobile OR RPL.AddWho = @cUserName)
         AND RPL.PickMethod = 'GetTask-P'
         AND RPL.Status = '4'
   END


   /***********************************************************************************************
                                              UCC confirm
   ***********************************************************************************************/

   IF @nTranCount = 0
      BEGIN TRAN  -- Only begin transaction if not already in one

   SAVE TRAN rdt_839Confirm15 -- For rollback or commit only our own transaction

   SET @nLoopIndex = -1
   WHILE 1 = 1
   BEGIN
      SELECT TOP 1
         @cPickDetailKey = PickDetailKey,
         @cID = Id,
         @cLOT = LOT,
         @nQty = Qty,
         @cUCC = UCCNo,
         @cOriUCC = OriUCCNo,
         @cStatus = Status,
         @cLoopDropID = DropID,
         @nLoopIndex = RowIndex
      FROM @tUCCPickDetail
      WHERE RowIndex > @nLoopIndex
      ORDER BY RowIndex

      IF @@ROWCOUNT = 0
         BREAK

      SELECT @cLoopOrderKey = OrderKey, 
         @cLoopOrderKeyLineNumber = OrderLineNumber
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE PickDetailKey = @cPickDetailKey
         AND StorerKey = @cStorerKey

      IF @cStatus = '4'
      BEGIN
         IF @cType = 'SHORT'
         BEGIN
            BEGIN TRY
               UPDATE dbo.PickDetail WITH(ROWLOCK)
               SET
                  Status = '4',
                  QtyMoved = Qty,
                  Qty = 0,
                  EditDate = GETDATE(),
                  EditWho = SUSER_SNAME()
               WHERE PickDetailKey = @cPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 255603
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update pickdetail failed
               GOTO RollBackTran
            END CATCH
         END
      END
      ELSE IF @cStatus = '9'
      BEGIN
         IF @cUCC = @cOriUCC
         BEGIN
            BEGIN TRY
               UPDATE dbo.UCC WITH(ROWLOCK)
               SET
                  Status = '5',
                  OrderKey = @cLoopOrderKey,
                  OrderLineNumber = @cLoopOrderKeyLineNumber,
                  EditDate = GETDATE(),
                  EditWho = SUSER_SNAME()
               WHERE UCCNo = @cUCC
                  AND StorerKey = @cStorerkey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 255643
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Update UCC failed
               GOTO RollBackTran
            END CATCH

            BEGIN TRY
               UPDATE dbo.PickDetail WITH(ROWLOCK)
               SET
                  Status = @cPickConfirmStatus,
                  DropID = @cLoopDropID,
                  EditDate = GETDATE(),
                  EditWho = SUSER_SNAME()
               WHERE PickDetailKey = @cPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 255604
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update pickdetail failed
               GOTO RollBackTran
            END CATCH
         END
         ELSE
         BEGIN
            -- Unallocate PickDetail
            BEGIN TRY
               UPDATE dbo.PickDetail WITH(ROWLOCK)
               SET
                  Qty = 0,
                  Status = '0',
                  EditDate = GETDATE(),
                  EditWho = SUSER_SNAME()
               WHERE PickDetailKey = @cPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 255605
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update pickdetail failed
               GOTO RollBackTran
            END CATCH

            -- Mark UCC as 1
            BEGIN TRY
               UPDATE dbo.UCC WITH(ROWLOCK)
               SET
                  Status = 1,
                  OrderKey = '',
                  OrderLineNumber = '',
                  EditDate = GETDATE(),
                  EditWho = SUSER_SNAME()
               WHERE UCCNo = @cOriUCC
                  AND StorerKey = @cStorerkey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 255606
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update UCC failed
               GOTO RollBackTran
            END CATCH

            SELECT TOP 1
               @cScannedUCCID = Id,
               @cScannedUCCLot = LOT
            FROM dbo.UCC WITH(NOLOCK)
            WHERE UCCNo = @cUCC
               AND StorerKey = @cStorerKey
            
            -- re-allcoate to scanned UCC
            BEGIN TRY
               UPDATE dbo.PickDetail WITH(ROWLOCK)
               SET
                  ID = @cScannedUCCID,
                  DropID = @cUCC,
                  Qty = @nQty,
                  LOT = @cScannedUCCLot,
                  EditDate = GETDATE(),
                  EditWho = SUSER_SNAME()
               WHERE PickDetailKey = @cPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 255607
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update pickdetail failed
               GOTO RollBackTran
            END CATCH

            -- Mark UCC as 6
            BEGIN TRY
               UPDATE dbo.UCC WITH(ROWLOCK)
               SET
                  Status = '5',
                  OrderKey = @cLoopOrderKey,
                  OrderLineNumber = @cLoopOrderKeyLineNumber,
                  EditDate = GETDATE(),
                  EditWho = SUSER_SNAME()
               WHERE UCCNo = @cUCC
                  AND StorerKey = @cStorerkey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 255608
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update UCC failed
               GOTO RollBackTran
            END CATCH

            -- Confirm PickDetail
            BEGIN TRY
               UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                  Status = @cPickConfirmStatus,
                  DropID = @cLoopDropID,
                  EditDate = GETDATE(),
                  EditWho  = SUSER_SNAME()
               WHERE PickDetailKey = @cPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 255609
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update PickDetail failed
               GOTO RollBackTran
            END CATCH
         END
      END
   END


   /***********************************************************************************************
                                              Piece confirm
   ***********************************************************************************************/

   /*        New Logic Begin          */
      
   DECLARE 
      @nBreakWholeLoop        INT = 0,
      @cPieceSN               NVARCHAR( 50),
      @cPieceLot              NVARCHAR( 10),
      @cPieceLotLoc           NVARCHAR( 10),
      @cPieceLotId            NVARCHAR( 18),
      @cPieceLotDropId        NVARCHAR( 20),
      @cPieceLotUCC           NVARCHAR( 20),
      @cPieceLotQty           INT,
      @cNewPickDetailKey      NVARCHAR( 10),
      @nRowRef                INT,
      @cPDLoc                 NVARCHAR( 10),
      @cPDId                  NVARCHAR( 18),
      @cPDDropID              NVARCHAR( 20),
      @nIDLotNotMatchedQty    INT = 0,
      @nIDLotMatchedQty       INT = 0

   SET @nBreakWholeLoop = 0
   SET @nLoopIndex = -1

   WHILE 1 = 1
   BEGIN
      SELECT TOP 1
         @cPickDetailKey = PickDetailKey,
         @nQTY_PD = Qty,
         @cPDLoc = Loc,
         @cPDId = Id,
         @cPDDropID = DropID,
         @nPickedQty = PickedQty,
         @cStatus = Status,
         @cReasonKey = ReasonKey,
         @nLoopIndex = RowIndex
      FROM @tPiecePickDetail
      WHERE RowIndex > @nLoopIndex
      ORDER BY RowIndex

      IF @@ROWCOUNT = 0
         BREAK

      -- Piece short confirm
      IF @cStatus = '4'
      BEGIN
         -- I. IF @nPickedQty = 0, then just update the qty to 0
         IF @nPickedQty = 0
         BEGIN
            -- 1. Reduce the qty for PickDetail
            BEGIN TRY
               UPDATE dbo.PickDetail WITH(ROWLOCK)
               SET
                  Status = '4',
                  QtyMoved = Qty,
                  Qty = 0,
                  EditDate = GETDATE(),
                  EditWho = SUSER_SNAME()
               WHERE PickDetailKey = @cPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 255636
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update pickdetail failed
               GOTO RollBackTran
            END CATCH
         END
         -- II. ELSE IF @nPickedQty > 0, then update the picked qty, and create new pickdetail for short qty
         ELSE
         BEGIN
            -- 1. Reduce the qty for PickDetail
            BEGIN TRY
               UPDATE dbo.PickDetail WITH(ROWLOCK)
               SET
                  Qty = @nPickedQty,
                  EditDate = GETDATE(),
                  EditWho = SUSER_SNAME()
               WHERE PickDetailKey = @cPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 255641
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update pickdetail failed
               GOTO RollBackTran
            END CATCH

            -- 2. Create new pickdetail for short qty
            SET @cNewPickDetailKey = ''

            EXECUTE dbo.nspg_GetKey
               'PICKDETAILKEY',
               10 ,
               @cNewPickDetailKey OUTPUT,
               @bSuccess          OUTPUT,
               @nErrNo            OUTPUT,
               @cErrMsg           OUTPUT

            IF @bSuccess <> 1
            BEGIN
               SET @nErrNo = 255637
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Generate key failed
               GOTO RollBackTran
            END

            BEGIN TRY
               INSERT INTO PickDetail (
                  CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM,
                  UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType,
                  ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
                  EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes, SourceType,
                  PickDetailKey,
                  Status,
                  QTY,
                  TrafficCop,
                  OptimizeCop,
                  Channel_ID )
               SELECT
                  CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM,
                  UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType,
                  ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
                  EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, @cReasonKey, 'SHORT', @cPickDetailKey,
                  @cNewPickDetailKey,
                  Status,
                  @nQTY_PD - @nPickedQty,
                  TrafficCop,
                  OptimizeCop,
                  Channel_ID
               FROM dbo.PickDetail WITH (NOLOCK)
               WHERE PickDetailKey = @cPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 255638
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Insert pickdetail failed
               GOTO RollBackTran
            END CATCH

            BEGIN TRY
               UPDATE dbo.PickDetail WITH(ROWLOCK)
               SET
                  Status = '4',
                  QtyMoved = Qty,
                  Qty = 0,
                  EditDate = GETDATE(),
                  EditWho = SUSER_SNAME()
               WHERE PickDetailKey = @cNewPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 255639
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update pickdetail failed
               GOTO RollBackTran
            END CATCH
         END

         -- 3. Reduce the qty for RDT pick log
         SELECT TOP 1
            @nRowRef = RowRef
         FROM RDT.rdtPickLog WITH(NOLOCK)
         WHERE PickDetailKey = @cPickDetailKey
            AND PickSlipNo = @cPickSlipNo
            AND (Mobile = @nMobile OR AddWho = @cUserName)
            AND PickMethod = 'GetTask-P'
         
         IF @@ROWCOUNT = 1
         BEGIN
            -- If picked qty = 0, it is full short delete the pick log
            IF @nPickedQty = 0
            BEGIN
               BEGIN TRY
                  DELETE FROM RDT.rdtPickLog WITH(ROWLOCK)
                  WHERE RowRef = @nRowRef
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 255642
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Delete rdtPickLog failed
                  GOTO RollBackTran
               END CATCH
            END
            --  Else update the picked qty
            ELSE
            BEGIN
               BEGIN TRY
                  UPDATE RDT.rdtPickLog WITH(ROWLOCK)
                  SET
                     ActQty = @nPickedQty,
                     Status = IIF(@nPickedQty = PickLockQty, '9', '0')
                  WHERE RowRef = @nRowRef
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 255640
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update rdtPickLog failed
                  GOTO RollBackTran
               END CATCH
            END
         END
      END
      -- Normal piece confirm
      ELSE
      BEGIN
         SET @nIDLotNotMatchedQty = 0
         SET @nIDLotMatchedQty = 0

         SELECT 
            @cSuggestedPieceLOT = LOT,
            @cPDId = Id,
            @cPDLoc = Loc,
            @cPDDropID = DropID
         FROM dbo.PickDetail WITH(NOLOCK)
         WHERE PickDetailKey = @cPickDetailKey

         DELETE FROM @tNewPickDetail

         WHILE 1 = 1
         BEGIN
            SELECT TOP 1 
               @cPieceLot = UCC.Lot,
               @cPieceLotId = UCC.ID,
               @cPieceLotUCC = UCC.UCCNo,
               @cPieceLotLoc = UCC.Loc,
               @cPieceLotDropId = RPL.DropID,
               @cPieceSN = SN.SerialNo,
               @nRowRef = RowRef
            FROM RDT.rdtPickLog RPL WITH(NOLOCK)
            INNER JOIN dbo.SerialNo SN WITH(NOLOCK) ON SN.StorerKey = @cStorerKey AND RPL.Remarks = SN.SerialNo
            INNER JOIN dbo.UCC WITH(NOLOCK) ON UCC.StorerKey = @cStorerKey AND SN.UCCNo = UCC.UCCNo
            WHERE RPL.PickDetailKey = @cPickDetailKey
               AND RPL.PickSlipNo = @cPickSlipNo
               AND (RPL.Mobile = @nMobile OR RPL.AddWho = @cUserName)
               AND RPL.PickMethod = 'Pick-P'
               AND ISNULL(RPL.Remarks, '') <> ''
               AND ISNULL(RPL.Status, '') <> '9'
            ORDER BY IIF(UCC.LOT = @cSuggestedPieceLOT, 1, 2)

            IF @@ROWCOUNT = 0
            BEGIN
               SELECT TOP 1 
                  @cPieceLot = SN.Lot,
                  @cPieceLotId = SN.ID,
                  @cPieceLotUCC = SN.UCCNo,
                  @cPieceLotLoc = SN.Loc,
                  @cPieceLotDropId = RPL.DropID,
                  @cPieceSN = SN.SerialNo,
                  @nRowRef = RowRef
               FROM RDT.rdtPickLog RPL WITH(NOLOCK)
               INNER JOIN dbo.SerialNo SN WITH(NOLOCK) ON SN.StorerKey = @cStorerKey AND RPL.Remarks = SN.SerialNo
               WHERE RPL.PickDetailKey = @cPickDetailKey
                  AND RPL.PickSlipNo = @cPickSlipNo
                  AND (RPL.Mobile = @nMobile OR RPL.AddWho = @cUserName)
                  AND RPL.PickMethod = 'Pick-P'
                  AND ISNULL(RPL.Remarks, '') <> ''
                  AND ISNULL(RPL.Status, '') <> '9'
               ORDER BY IIF(SN.LOT = @cSuggestedPieceLOT, 1, 2)

               IF @@ROWCOUNT = 0
                  BREAK

               SET @cPieceLotUCC = ISNULL(@cPieceLotUCC, '')
            END

            -- Loc/id/lot/ucc does not match, create new pick details
            IF @cPieceLot <> @cSuggestedPieceLOT OR @cPDId <> @cPieceLotId OR @cPDLoc <> @cPieceLotLoc OR @cPDDropID <> @cPieceLotUCC
            BEGIN
               IF NOT EXISTS (SELECT 1 FROM @tNewPickDetail WHERE SourceType = @cPickDetailKey AND Loc = @cPieceLotLoc AND Id = @cPieceLotId AND DropID = @cPieceLotUCC AND Lot = @cPieceLot)
               BEGIN
                  SET @cNewPickDetailKey = ''

                  EXECUTE dbo.nspg_GetKey
                     'PICKDETAILKEY',
                     10 ,
                     @cNewPickDetailKey OUTPUT,
                     @bSuccess          OUTPUT,
                     @nErrNo            OUTPUT,
                     @cErrMsg           OUTPUT

                  IF @bSuccess <> 1
                  BEGIN
                     SET @nErrNo = 255621
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Generate key failed
                     GOTO RollBackTran
                  END

                  BEGIN TRY
                     -- Create new a PickDetail to hold the balance
                     INSERT INTO @tNewPickDetail (
                        CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM,
                        UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType,
                        ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
                        EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes, SourceType,
                        PickDetailKey,
                        Status,
                        QTY,
                        TrafficCop,
                        OptimizeCop,
                        Channel_ID )
                     SELECT
                        CaseID, PickHeaderKey, OrderKey, OrderLineNumber, @cPieceLot, StorerKey, SKU, AltSku, UOM,
                        UOMQTY, QTYMoved, @cPieceLotUCC, @cPieceLotLoc, @cPieceLotId, PackKey, UpdateSource, CartonGroup,
                        CartonType, ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
                        EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, 'Picked', @cPickDetailKey,
                        @cNewPickDetailKey,
                        Status,
                        1,
                        NULL,
                        '1',
                        Channel_ID
                     FROM dbo.PickDetail WITH (NOLOCK)
                     WHERE PickDetailKey = @cPickDetailKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 255610
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Insert pickdetail failed
                     GOTO RollBackTran
                  END CATCH
               END
               ELSE 
               BEGIN
                  BEGIN TRY
                     UPDATE @tNewPickDetail
                     SET QTY = QTY + 1
                     WHERE SourceType = @cPickDetailKey 
                        AND Loc = @cPieceLotLoc 
                        AND Id = @cPieceLotId 
                        AND DropID = @cPieceLotUCC 
                        AND Lot = @cPieceLot
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 255626
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --   Update @tNewPickDetail failed
                     GOTO RollBackTran
                  END CATCH
               END

               SET @nIDLotNotMatchedQty = @nIDLotNotMatchedQty + 1
            END
            ELSE
            BEGIN
               SET @nIDLotMatchedQty = @nIDLotMatchedQty + 1
            END

            BEGIN TRY
               UPDATE dbo.SerialNo WITH(ROWLOCK)
               SET UCCNo = '',
                  UserDefine01 = '5'
               WHERE SerialNo = @cPieceSN
                  AND StorerKey = @cStorerKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 255644
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Update SerialNo failed
               GOTO RollBackTran
            END CATCH

            -- for partil pick UCC, mark it as 6, the ops team discards the UCC box and keeps the material without the UCC
            BEGIN TRY
               UPDATE dbo.UCC WITH(ROWLOCK)
               SET 
                  Status = '6',
                  EditDate = GETDATE(),
                  EditWho = SUSER_SNAME()
               WHERE UCCNo = @cPieceLotUCC
            END TRY
            BEGIN CATCH
               SET @nErrNo = 255646
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --   Update UCC failed
               GOTO RollBackTran
            END CATCH

            BEGIN TRY
               UPDATE RDT.rdtPickLog WITH(ROWLOCK)
               SET Status = '9'
               WHERE RowRef= @nRowRef
            END TRY
            BEGIN CATCH
               SET @nErrNo = 255627
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --   Update rdtPickLog failed
               GOTO RollBackTran
            END CATCH
         END

         --Split the unpicked qty
         IF @nIDLotMatchedQty + @nIDLotNotMatchedQty < @nQTY_PD
         BEGIN
            SET @cNewPickDetailKey = ''

            EXECUTE dbo.nspg_GetKey
               'PICKDETAILKEY',
               10 ,
               @cNewPickDetailKey OUTPUT,
               @bSuccess          OUTPUT,
               @nErrNo            OUTPUT,
               @cErrMsg           OUTPUT

            IF @bSuccess <> 1
            BEGIN
               SET @nErrNo = 255628
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Generate key failed
               GOTO RollBackTran
            END

            BEGIN TRY
               -- Create new a PickDetail to hold the balance
               INSERT INTO @tNewPickDetail (
                  CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM,
                  UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType,
                  ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
                  EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes, SourceType,
                  PickDetailKey,
                  Status,
                  QTY,
                  TrafficCop,
                  OptimizeCop,
                  Channel_ID )
               SELECT
                  CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM,
                  UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType,
                  ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
                  EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, 'Unpicked', @cPickDetailKey,
                  @cNewPickDetailKey,
                  Status,
                  QTY - @nIDLotMatchedQty - @nIDLotNotMatchedQty,
                  TrafficCop,
                  OptimizeCop,
                  Channel_ID
               FROM dbo.PickDetail WITH (NOLOCK)
               WHERE PickDetailKey = @cPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 255629
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Insert pickdetail failed
               GOTO RollBackTran
            END CATCH
         END

         -- Matched Qty, mark it as picked
         BEGIN TRY
            UPDATE dbo.PickDetail WITH(ROWLOCK)
            SET Qty = @nIDLotMatchedQty,
               DropID = IIF(@nIDLotMatchedQty > 0, @cPieceLotDropId, DropID),
               EditWho = @cUserName,
               EditDate = GETDATE()
            WHERE PickDetailKey = @cPickDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 255630
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update pickdetail failed
            GOTO RollBackTran
         END CATCH

         IF @nIDLotMatchedQty > 0
         BEGIN
            BEGIN TRY
               UPDATE dbo.PickDetail WITH(ROWLOCK)
               SET Status = @cPickConfirmStatus,
                  DropID = @cPieceLotDropId,
                  EditWho = @cUserName,
                  EditDate = GETDATE()
               WHERE PickDetailKey = @cPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 255631
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update pickdetail failed
               GOTO RollBackTran
            END CATCH
         END
         ELSE
         BEGIN
            BEGIN TRY
               DELETE FROM dbo.PickDetail
               WHERE PickDetailKey = @cPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 255632
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- delete pickdetail failed
               GOTO RollBackTran
            END CATCH
         END

         -- Create new PickDetails for records 1. Loc/id/lot/ucc does not match 2. Unpicked Qty
         BEGIN TRY
            INSERT INTO dbo.PickDetail 
            (
               CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM,
               UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType,
               ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
               EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes,
               PickDetailKey,
               Status,
               QTY,
               Channel_ID )
            SELECT
               CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM,
               UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType,
               ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
               EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes,
               PickDetailKey,
               Status,
               QTY,
               Channel_ID
            FROM @tNewPickDetail
         END TRY
         BEGIN CATCH
            SET @nErrNo = 255617
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Insert pickdetail failed
            GOTO RollBackTran
         END CATCH

         SET @cPickDetailKey = ''
         WHILE 1 = 1
         BEGIN
            SELECT TOP 1 
               @cPickDetailKey = PickDetailKey
            FROM @tNewPickDetail
            WHERE PickDetailKey > @cPickDetailKey
            ORDER BY PickDetailKey

            IF @@ROWCOUNT = 0
               BREAK
            
            BEGIN TRY
               UPDATE dbo.PickDetail WITH(ROWLOCK)
               SET 
                  Status = CASE WHEN Notes = 'Picked' THEN @cPickConfirmStatus
                                 ELSE Status
                              END,
                  DropID = CASE WHEN Notes = 'Picked' THEN @cPieceLotDropId
                                 ELSE DropID
                              END
               WHERE PickDetailKey = @cPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 255633
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Insert pickdetail failed
               GOTO RollBackTran
            END CATCH
         END
      END
   END

   IF @cType <> 'SHORT'
   BEGIN
      INSERT INTO @tPiecePickDetailKey ( PickDetailKey )
      SELECT DISTINCT RPL.PickDetailKey
      FROM RDT.rdtPickLog RPL WITH(NOLOCK)
      WHERE RPL.PickSlipNo = @cPickSlipNo
         AND (RPL.Mobile = @nMobile OR RPL.AddWho = @cUserName)
         AND ISNULL(RPL.DropID, '') LIKE IIF(@cDropID = 'ALLDROPID', '%%', @cDropID)
      --    AND ISNULL(RPL.Status, '') IN( '4', '9')

      -- For normal confirm, delete all pick log records
      SET @nLoopIndex = -1
      WHILE 1 = 1
      BEGIN
         SELECT TOP 1
            @nLoopIndex = RPL.RowRef
         FROM RDT.rdtPickLog RPL WITH(NOLOCK)
         INNER JOIN @tPiecePickDetailKey TPPDK ON RPL.PickDetailKey = TPPDK.PickDetailKey
         WHERE RPL.PickSlipNo = @cPickSlipNo
            AND (RPL.Mobile = @nMobile OR RPL.AddWho = @cUserName)
            AND RowRef > @nLoopIndex
         ORDER BY RPL.RowRef

         IF @@ROWCOUNT = 0
            BREAK
         
         BEGIN TRY
            DELETE FROM RDT.rdtPickLog
            WHERE RowRef = @nLoopIndex
         END TRY
         BEGIN CATCH
            SET @nErrNo = 255618
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Delete rdtPickLog failed
            GOTO RollBackTran
         END CATCH
      END
   END

   /*        New Logic End          */

   -- Only commit if we started the transaction ourselves
   IF @nTranCount = 0 AND @@TRANCOUNT > 0
      COMMIT TRAN

   EXEC RDT.rdt_STD_EventLog
      @cActionType   = '3', -- Picking
      @cUserID       = @cUserName,
      @nMobileNo     = @nMobile,
      @nFunctionID   = @nFunc,
      @cFacility     = @cFacility,
      @cStorerKey    = @cStorerKey,
      @cLocation     = @cLOC,
      @cSKU          = @cSKU,
      @nQTY          = @nQTY,
      @cRefNo1       = @cType,
      @cPickSlipNo   = @cPickSlipNo,
      @cPickZone     = @cPickZone,
      @cDropID       = @cDropID

   GOTO Quit

RollBackTran:
   IF XACT_STATE() = -1
   BEGIN
      -- Transaction is uncommittable, must rollback entire transaction
      ROLLBACK TRAN
   END
   ELSE IF XACT_STATE() = 1
   BEGIN
      -- Transaction is committable, rollback to savepoint only
      ROLLBACK TRAN rdt_839Confirm15
   END

   INSERT INTO dbo.TraceInfo (TraceName, Step1, Step2, Step3, Step4, Step5, TimeIn, col1, Col2) 
   VALUES ('rdt_839Confirm15', @cStorerKey, ISNULL(TRY_CAST(@nMobile AS NVARCHAR(20)), ''), @cUserName, @cPickSlipNo, @cDropID, GETDATE(), 'ErrorNo', ISNULL(TRY_CAST(@nErrNo AS NVARCHAR(20)), ''))

Fail:
Quit:
   IF XACT_STATE() = 1
   BEGIN
      WHILE @@TRANCOUNT > @nTranCount
         COMMIT TRAN
   END

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_839Confirm15] TO NSQL
GO  