
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************************/
/* Store procedure: rdt_994ExtScn01_LabelNoConfirm                                     */
/* Copyright      : Maersk                                                             */
/* Customer       : AEOMX                                                              */
/*                                                                                     */
/*                                                                                     */
/* Date        Rev    Author     Purposes                                              */
/* 2026-09-12  1.0.0  NYE018     FCR-16295 Move inv to marshalling lane and send IML   */
/*                               Adapted from rdt_838ExtScn10_LabelNoConfirm           */
/*                               Key diff: DropID filter uses @cPickSlipNo             */
/*                               (set by rdt_994ExtScn01_MoveToPack) not @cFromDropID  */
/* 2026-09-15  1.0.1  NYE018     FCR-16295 Merge PickDetail rows after notes update    */
/***************************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_994ExtScn01_LabelNoConfirm] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR(  3),
   @nStep        INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR(  5),
   @cStorerKey   NVARCHAR( 15),
   @cPickSlipNo  NVARCHAR( 10),
   @cFromDropID  NVARCHAR( 20),
   @nCartonNo    INT,
   @cLabelNo     NVARCHAR( 20),
   @cWaveKey     NVARCHAR( 10),
   @cWaveType    NVARCHAR( 20),
   @nErrNo       INT           OUTPUT,
   @cErrMsg      NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag  INT = 0

   DECLARE
      @cMoveFromLoc     NVARCHAR( 10),
      @cMoveFromID      NVARCHAR( 18),
      @cMoveToID        NVARCHAR( 18),
      @cMoveSKU         NVARCHAR( 20),
      @cMoveLot         NVARCHAR( 10),
      @nMoveQty         INT,
      @nQTYAlloc        INT,
      @nQTYPick         INT,
      @cMoveDropID      NVARCHAR( 20),
      @cMoveCaseID      NVARCHAR( 20),
      @cMarshallingLane NVARCHAR( 10),
      @cWaveSubType     NVARCHAR( 20),
      @cPickStatus      NVARCHAR(  1),
      @cMoveQTYAlloc    NVARCHAR(  1),
      @cMoveQTYPick     NVARCHAR(  1),
      @cInterModalVehicle NVARCHAR( 30),
      @cSendRTLIMLFlag  NVARCHAR(  1) = '',
      @cSendECOMIMLFlag NVARCHAR(  1) = '',
      @cPackHdrOrderKey NVARCHAR( 10),
      @cUserName        NVARCHAR( 18),
      @nRowCount        INT = 0,
      @nCounter         INT,
      @bSuccess         INT,
      @nTranCount       INT

   -- In FN994, PickDetail.DropID is set to @cPickSlipNo by rdt_994ExtScn01_MoveToPack.
   -- All pick detail lookups therefore filter on DropID = @cPickSlipNo instead of @cFromDropID.
   DECLARE @cDropIDFilter NVARCHAR( 20)
   SET @cDropIDFilter = @cPickSlipNo

   DECLARE @tMoveList TABLE (
      RowNumber   INT IDENTITY(1,1) PRIMARY KEY,
      FromLoc     NVARCHAR( 10) NOT NULL,
      FromID      NVARCHAR( 18) NOT NULL,
      ToLoc       NVARCHAR( 10) NOT NULL,
      ToID        NVARCHAR( 18) NOT NULL,
      SKU         NVARCHAR( 20) NOT NULL,
      Lot         NVARCHAR( 10) NOT NULL,
      Qty         INT           NOT NULL,
      CaseID      NVARCHAR( 20) NOT NULL,
      DropID      NVARCHAR( 20) NOT NULL
   )

   DECLARE @tPickDetail TABLE (
      PickDetailKey NVARCHAR(18) PRIMARY KEY
   )

   DECLARE @tPD TABLE (
      PickDetailKey   NVARCHAR( 18) NOT NULL PRIMARY KEY CLUSTERED,
      CaseID          NVARCHAR( 20) NOT NULL,
      OrderKey        NVARCHAR( 10) NOT NULL,
      OrderLineNumber NVARCHAR(  5) NOT NULL,
      UOM             NVARCHAR( 10) NOT NULL,
      Lot             NVARCHAR( 10) NOT NULL,
      SKU             NVARCHAR( 20) NOT NULL,
      DropID          NVARCHAR( 20) NOT NULL,
      Loc             NVARCHAR( 10) NOT NULL,
      ID              NVARCHAR( 18) NOT NULL,
      Qty             INT           NOT NULL
   )

   DECLARE @tMerged TABLE (
      KeepPickDetailKey NVARCHAR( 18) NOT NULL PRIMARY KEY CLUSTERED,
      OrderKey          NVARCHAR( 10) NOT NULL,
      OrderLineNumber   NVARCHAR(  5) NOT NULL,
      Loc               NVARCHAR( 10) NOT NULL,
      ID                NVARCHAR( 18) NOT NULL,
      CaseID            NVARCHAR( 20) NOT NULL,
      Lot               NVARCHAR( 10) NOT NULL,
      MergedQty         INT           NOT NULL,
      RecordCount       INT           NOT NULL
   )

   SET @nErrNo  = 0
   SET @cErrMsg = ''

   IF @nDebugFlag = 1
      SELECT 'rdt_994ExtScn01_LabelNoConfirm: Start',
             @cPickSlipNo AS PickSlipNo, @cLabelNo AS LabelNo,
             @cWaveKey AS WaveKey, @cWaveType AS WaveType

   -- Get username
   SELECT @cUserName = UserName
   FROM rdt.RDTMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Get WaveSubType (UserDefine05) for marshalling lane lookup
   SELECT @cWaveSubType = ISNULL(UserDefine05, '')
   FROM dbo.Wave WITH (NOLOCK)
   WHERE WaveKey = @cWaveKey

   -- Get config
   SET @cMoveQTYAlloc = rdt.RDTGetConfig(@nFunc, 'MoveQTYAlloc', @cStorerKey)
   SET @cMoveQTYPick  = rdt.RDTGetConfig(@nFunc, 'MoveQTYPick',  @cStorerKey)
   SET @cPickStatus   = rdt.RDTGetConfig(@nFunc, 'PickStatus',   @cStorerKey)
   IF @cPickStatus = '0'
      SET @cPickStatus = '5'

   -- Resolve marshalling lane from CODELKUP AEOMXSTG (UDF02)
   SET @nRowCount = 0
   SELECT @cMarshallingLane = UDF02
   FROM dbo.CODELKUP WITH (NOLOCK)
   WHERE LISTNAME  = 'AEOMXSTG'
     AND StorerKey = @cStorerKey
     AND Code      = @cWaveType
     AND Code2     = @cWaveSubType

   SET @nRowCount = @@ROWCOUNT

   IF @nRowCount = 0 OR ISNULL(@cMarshallingLane, '') = ''
   BEGIN
      SET @nErrNo  = 281251
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --MarshallingLaneNotFound
      GOTO Quit
   END

   IF NOT EXISTS (SELECT 1 FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cMarshallingLane AND Facility = @cFacility)
   BEGIN
      SET @nErrNo  = 281257
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --InvalidMarshallingLane
      GOTO Quit
   END

   -- Validate config
   IF @cMoveQTYAlloc <> '1' AND @cMoveQTYPick <> '1'
   BEGIN
      SET @nErrNo  = 281252
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --IncorrectSetup
      GOTO Quit
   END

   IF @cMoveQTYAlloc = '1' AND @cPickStatus = '5'
   BEGIN
      SET @nErrNo  = 281253
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --IncorrectSetup
      GOTO Quit
   END

   IF @cMoveQTYPick = '1' AND @cPickStatus < '5'
   BEGIN
      SET @nErrNo  = 281254
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --IncorrectSetup
      GOTO Quit
   END

   -- Build move list from PickDetail.
   -- In FN994, MoveToPack has already set PickDetail.DropID = @cPickSlipNo,
   -- so we filter DropID = @cDropIDFilter (= @cPickSlipNo) here.
   BEGIN TRY
      INSERT INTO @tMoveList (FromLoc, FromID, ToLoc, ToID, SKU, Lot, Qty, CaseID, DropID)
      SELECT
         Loc,
         ID,
         @cMarshallingLane,
         LEFT(@cLabelNo, 18),  -- LabelNo becomes the destination ID
         SKU,
         LOT,
         SUM(QTY),
         @cLabelNo,
         @cDropIDFilter
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
        AND CaseID    = @cLabelNo
        AND DropID    = @cDropIDFilter
        AND Status    = @cPickStatus
        AND QTY       > 0
      GROUP BY Loc, ID, SKU, LOT
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 281255
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --InsertMoveListFailed
      GOTO Quit
   END CATCH

   BEGIN TRY
      INSERT INTO @tPickDetail (PickDetailKey)
      SELECT PickDetailKey
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
        AND CaseID    = @cLabelNo
        AND DropID    = @cDropIDFilter
        AND Status    = @cPickStatus
        AND QTY       > 0
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 281258
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --InsertPickDetailFailed
      GOTO Quit
   END CATCH

   IF @nDebugFlag = 1
      SELECT 'MoveList', * FROM @tMoveList

   -- Determine IML trigger flags
   SELECT TOP 1
      @cInterModalVehicle = OD.InterModalVehicle
   FROM dbo.PackDetail PD WITH (NOLOCK)
   JOIN dbo.PickDetail PKD WITH (NOLOCK)
      ON PD.StorerKey = PKD.StorerKey
     AND PD.LabelNo   = PKD.CaseID
     AND PKD.Status   = @cPickStatus
     AND PKD.Qty      > 0
   JOIN dbo.ORDERS OD WITH (NOLOCK) ON PKD.OrderKey = OD.OrderKey
   WHERE PD.PickSlipNo = @cPickSlipNo
     AND PD.CartonNo   = @nCartonNo
   ORDER BY OD.OrderKey

   IF @cWaveType = 'ECOM'
   BEGIN
      IF @cInterModalVehicle = 'VA'
      BEGIN
         -- ECOM + VA -> WSAEOSHIPLBL
         SELECT TOP 1 @cPackHdrOrderKey = OrderKey
         FROM dbo.PackHeader WITH (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo

         IF ISNULL(@cPackHdrOrderKey, '') = ''
         BEGIN
            SET @nErrNo  = 281261
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --PackHeaderNotFound
            GOTO Quit
         END
         SET @cSendECOMIMLFlag = 'Y'
         SET @cSendRTLIMLFlag  = 'N'
      END
      ELSE
      BEGIN
         -- ECOM non-VA -> WSSOTMSGENLBL
         SET @cSendECOMIMLFlag = 'N'
         SET @cSendRTLIMLFlag  = 'Y'
      END
   END
   ELSE IF @cWaveType = 'RTL'
   BEGIN
      IF EXISTS (SELECT 1 FROM dbo.CODELKUP WITH (NOLOCK)
                 WHERE LISTNAME  = 'AEOTMSLBL'
                   AND StorerKey = @cStorerKey
                   AND Code      = @cInterModalVehicle)
      BEGIN
         -- RTL with carrier code -> WSSOTMSGENLBL
         SET @cSendECOMIMLFlag = 'N'
         SET @cSendRTLIMLFlag  = 'Y'
      END
   END
   -- WHSLE or RTL without carrier: no IML

   IF @nDebugFlag = 1
      SELECT 'SendIMLFlags',
             @cSendECOMIMLFlag  AS SendECOMIMLFlag,
             @cSendRTLIMLFlag   AS SendRTLIMLFlag,
             @cWaveType         AS WaveType,
             @cInterModalVehicle AS InterModalVehicle

   SET @nTranCount = @@TRANCOUNT
   IF @nTranCount = 0
      BEGIN TRAN
   ELSE
      SAVE TRAN rdt_994ExtScn01_LabelNoConfirm

   IF EXISTS (SELECT 1 FROM @tMoveList)
   BEGIN
      SET @nCounter = 0

      WHILE 1 = 1
      BEGIN
         SELECT TOP 1
            @nCounter     = RowNumber,
            @cMoveFromLoc = FromLoc,
            @cMoveFromID  = FromID,
            @cMoveToID    = ToID,
            @cMoveSKU     = SKU,
            @cMoveLot     = Lot,
            @nMoveQty     = Qty,
            @cMoveCaseID  = CaseID,
            @cMoveDropID  = DropID
         FROM @tMoveList
         WHERE RowNumber > @nCounter
         ORDER BY RowNumber

         IF @@ROWCOUNT = 0
            BREAK

         IF @cMoveQTYAlloc = '1'
         BEGIN
            SET @nQTYAlloc = @nMoveQty
            SET @nQTYPick  = 0
         END
         ELSE
         BEGIN
            SET @nQTYAlloc = 0
            SET @nQTYPick  = @nMoveQty
         END

         IF @nDebugFlag = 1
            SELECT 'Moving inventory', @nCounter AS RowNumber,
               @cMoveFromLoc AS FromLoc, @cMarshallingLane AS ToLoc,
               @cMoveFromID AS FromID, @cMoveToID AS ToID,
               @cMoveSKU AS SKU, @cMoveLot AS Lot, @nMoveQty AS Qty,
               @cMoveCaseID AS CaseID

         EXECUTE rdt.rdt_Move
            @nMobile     = @nMobile,
            @cLangCode   = @cLangCode,
            @nErrNo      = @nErrNo   OUTPUT,
            @cErrMsg     = @cErrMsg  OUTPUT,
            @cSourceType = 'rdt_994ExtScn01_LabelNoConfirm',
            @cStorerKey  = @cStorerKey,
            @cFacility   = @cFacility,
            @cFromLOC    = @cMoveFromLoc,
            @cToLoc      = @cMarshallingLane,
            @cFromID     = @cMoveFromID,
            @cToID       = @cMoveToID,
            @cSKU        = @cMoveSKU,
            @nQTY        = @nMoveQty,
            @nQTYAlloc   = @nQTYAlloc,
            @nQTYPick    = @nQTYPick,
            @cFromLOT    = @cMoveLot,
            @cCaseID     = @cMoveCaseID,
            @nFunc       = @nFunc
         IF @nErrNo <> 0
            GOTO RollBackTran

         EXEC RDT.rdt_STD_EventLog
            @cActionType = '3',
            @cUserID     = @cUserName,
            @nMobileNo   = @nMobile,
            @nFunctionID = @nFunc,
            @cFacility   = @cFacility,
            @cStorerKey  = @cStorerKey,
            @cLocation   = @cMoveFromLoc,
            @cToLocation = @cMarshallingLane,
            @cID         = @cMoveFromID,
            @cToID       = @cMoveToID,
            @cSKU        = @cMoveSKU,
            @nQTY        = @nMoveQty,
            @cLOT        = @cMoveLot,
            @cCaseID     = @cMoveCaseID,
            @cPickSlipNo = @cPickSlipNo,
            @cDropID     = @cMoveDropID,
            @cLabelNo    = @cLabelNo
      END -- end move loop

      -- Stamp [PACKED] on PickDetail notes after moving inventory
      BEGIN TRY
         UPDATE PD WITH (ROWLOCK)
         SET PD.Notes      = ISNULL(PD.Notes, '') + '[PACKED]',
             PD.EditDate   = GETDATE(),
             PD.EditWho    = @cUserName,
             PD.TrafficCop = NULL
         FROM dbo.PickDetail PD
         JOIN @tPickDetail tPD ON (PD.PickDetailKey = tPD.PickDetailKey)
      END TRY
      BEGIN CATCH
         SET @nErrNo  = 281259
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --UpdatePickDetailFailed
         GOTO RollBackTran
      END CATCH
   END -- move inventory

   -- IML Case 1: ECOM + VA -> WSAEOSHIPLBL
   IF @cSendECOMIMLFlag = 'Y'
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Generating ECOM Transmit Log (WSAEOSHIPLBL)', @cPackHdrOrderKey AS OrderKey

      EXEC dbo.ispGenTransmitLog2
         @c_TableName     = 'WSAEOSHIPLBL',
         @c_Key1          = @cPackHdrOrderKey,
         @c_Key2          = '',
         @c_Key3          = @cStorerKey,
         @c_TransmitBatch = '',
         @b_success       = @bSuccess OUTPUT,
         @n_err           = @nErrNo   OUTPUT,
         @c_errmsg        = @cErrMsg  OUTPUT

      IF @bSuccess <> 1
      BEGIN
         SET @nErrNo  = CASE WHEN @nErrNo = 0 THEN 281260 ELSE @nErrNo END
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --GenECOMTransLogFail
         GOTO RollBackTran
      END
   END

   -- IML Case 2: ECOM non-VA / RTL with carrier -> WSSOTMSGENLBL
   IF @cSendRTLIMLFlag = 'Y'
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Generating RTL Transmit Log (WSSOTMSGENLBL)', @cLabelNo AS LabelNo

      EXEC dbo.ispGenTransmitLog2
         @c_TableName     = 'WSSOTMSGENLBL',
         @c_Key1          = @cPickSlipNo,
         @c_Key2          = @cLabelNo,
         @c_Key3          = @cStorerKey,
         @c_TransmitBatch = '',
         @b_success       = @bSuccess OUTPUT,
         @n_err           = @nErrNo   OUTPUT,
         @c_errmsg        = @cErrMsg  OUTPUT

      IF @bSuccess <> 1
      BEGIN
         SET @nErrNo  = CASE WHEN @nErrNo = 0 THEN 281256 ELSE @nErrNo END
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --GenTransLogFail
         GOTO RollBackTran
      END
   END

   -- Merge PickDetails for this pick slip
   IF @nDebugFlag = 1
      SELECT 'Merge PickDetail for PickSlip', @cPickSlipNo AS PickSlipNo

   BEGIN TRY
      INSERT INTO @tPD (PickDetailKey, OrderKey, OrderLineNumber, UOM, Lot, SKU, DropID, Loc, ID, CaseID, Qty)
      SELECT PD.PickDetailKey, PD.OrderKey, PD.OrderLineNumber, PD.UOM, PD.Lot, PD.SKU, PD.DropID, PD.Loc, PD.ID, PD.CaseID, PD.Qty
      FROM dbo.PickDetail PD WITH (NOLOCK)
      WHERE PD.StorerKey = @cStorerKey
         AND PD.DropID   = @cDropIDFilter
         AND PD.Status   = @cPickStatus
         AND PD.CaseID   = @cLabelNo
         AND PD.Qty > 0
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 281262
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --InsPDFailed
      GOTO RollBackTran
   END CATCH

   IF EXISTS (SELECT 1 FROM @tPD)
   BEGIN
      BEGIN TRY
         INSERT INTO @tMerged (KeepPickDetailKey, OrderKey, OrderLineNumber, Loc, ID, CaseID, Lot, MergedQty, RecordCount)
         SELECT MIN(PickDetailKey), OrderKey, OrderLineNumber, Loc, ID, CaseID, Lot, SUM(Qty), COUNT(1)
         FROM @tPD
         GROUP BY OrderKey, OrderLineNumber, Loc, ID, CaseID, Lot
      END TRY
      BEGIN CATCH
         SET @nErrNo  = 281264
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --MergePickDetailFailed
         GOTO RollBackTran
      END CATCH

      IF @nDebugFlag = 1
      BEGIN
         SELECT '@tPD to merge'
         SELECT * FROM @tPD
         SELECT '@tMerged'
         SELECT * FROM @tMerged
      END

      BEGIN TRY
         DELETE PD FROM dbo.PickDetail PD WITH (ROWLOCK)
         JOIN @tPD tPD ON PD.PickDetailKey = tPD.PickDetailKey
         LEFT JOIN @tMerged M ON PD.PickDetailKey = M.KeepPickDetailKey
         WHERE M.KeepPickDetailKey IS NULL
      END TRY
      BEGIN CATCH
         SET @nErrNo  = 281265
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --DeleteMergeDuplicatesFailed
         GOTO RollBackTran
      END CATCH

      BEGIN TRY
         UPDATE PD WITH (ROWLOCK) SET
            PD.DropID   = @cDropIDFilter,
            PD.Qty      = M.MergedQty,
            PD.EditDate = GETDATE(),
            PD.EditWho  = 'rdt.' + SUSER_SNAME()
         FROM dbo.PickDetail PD
         INNER JOIN @tMerged M ON PD.PickDetailKey = M.KeepPickDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo  = 281266
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --UpdateDropIDQtyFailed
         GOTO RollBackTran
      END CATCH

   END

   IF @nTranCount = 0
      COMMIT TRANSACTION

   GOTO Quit

   RollBackTran:
      IF XACT_STATE() = -1
         ROLLBACK TRAN
      ELSE IF @nTranCount > 0 AND XACT_STATE() = 1
         ROLLBACK TRAN rdt_994ExtScn01_LabelNoConfirm
      ELSE IF XACT_STATE() = 1
         ROLLBACK TRAN

   Quit:
      IF @nDebugFlag = 1
         SELECT 'rdt_994ExtScn01_LabelNoConfirm: End', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
      WHILE @@TRANCOUNT > @nTranCount
         COMMIT TRAN

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_994ExtScn01_LabelNoConfirm TO NSQL
GO
