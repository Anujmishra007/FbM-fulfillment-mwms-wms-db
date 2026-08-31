
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/******************************************************************************/
/* Store procedure: rdt_839Confirm17                                          */
/* Copyright      : Maersk                                                    */
/* Customer       : PAGEIND                                                   */
/*                                                                            */
/* copied from rdt_839Confirm15.sql and modified for PAGEIND                  */
/*                                                                            */   
/* Date       Rev  Author     Purposes                                        */
/* 2026-08-20 1.2  NYE018     FCR-12865 add the logic for SNnotRequired.      */
/******************************************************************************/
    
CREATE OR ALTER PROC rdt.rdt_839Confirm17 (
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

   DECLARE @tPickedKeys TABLE 
   (
      PickDetailKey NVARCHAR(18) PRIMARY KEY
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

   SAVE TRAN rdt_839Confirm17 -- For rollback or commit only our own transaction

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
               SET @nErrNo = 279201
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
               SET @nErrNo = 279202
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Update UCC failed
               GOTO RollBackTran
            END CATCH

            BEGIN TRY
               UPDATE dbo.PickDetail WITH(ROWLOCK)
               SET
                  Status = @cPickConfirmStatus,
                  Notes = DropID,
                  DropID = @cLoopDropID,
                  EditDate = GETDATE(),
                  EditWho = SUSER_SNAME()
               WHERE PickDetailKey = @cPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 279203
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
               SET @nErrNo = 279204
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
               SET @nErrNo = 279205
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
               SET @nErrNo = 279206
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
               SET @nErrNo = 279207
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update UCC failed
               GOTO RollBackTran
            END CATCH

            -- Confirm PickDetail
            BEGIN TRY
               UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                  Status = @cPickConfirmStatus,
                  Notes = DropID,
                  DropID = @cLoopDropID,
                  EditDate = GETDATE(),
                  EditWho  = SUSER_SNAME()
               WHERE PickDetailKey = @cPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 279208
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
               SET @nErrNo = 279209
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
               SET @nErrNo = 279210
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
               SET @nErrNo = 279211
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
                  EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, @cReasonKey, Notes, @cPickDetailKey,
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
               SET @nErrNo = 279212
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
               SET @nErrNo = 279213
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
                  SET @nErrNo = 279214
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
                  SET @nErrNo = 279215
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update rdtPickLog failed
                  GOTO RollBackTran
               END CATCH
            END
         END
      END
      -- Normal piece confirm (no serial no: confirm directly using PickLockQty)
      ELSE
      BEGIN
         IF @nPickedQty > 0
         BEGIN
            BEGIN TRY
               UPDATE dbo.PickDetail WITH(ROWLOCK)
               SET Status   = @cPickConfirmStatus,
                   QtyMoved = @nPickedQty,
                   DropID   = @cDropID,
                   EditDate = GETDATE(),
                   EditWho  = SUSER_SNAME()
               WHERE PickDetailKey = @cPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo  = 279216
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
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
            SET @nErrNo = 279217
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
      ROLLBACK TRAN rdt_839Confirm17
   END

   INSERT INTO dbo.TraceInfo (TraceName, Step1, Step2, Step3, Step4, Step5, TimeIn, col1, Col2) 
   VALUES ('rdt_839Confirm17', @cStorerKey, ISNULL(TRY_CAST(@nMobile AS NVARCHAR(20)), ''), @cUserName, @cPickSlipNo, @cDropID, GETDATE(), 'ErrorNo', ISNULL(TRY_CAST(@nErrNo AS NVARCHAR(20)), ''))

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

GRANT EXECUTE ON [rdt].[rdt_839Confirm17] TO NSQL
GO  