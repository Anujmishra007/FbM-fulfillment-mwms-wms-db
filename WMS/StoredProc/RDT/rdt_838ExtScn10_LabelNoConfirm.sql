
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************************/
/* Store procedure: rdt_838ExtScn10_LabelNoConfirm                                     */
/* Copyright      : Maersk                                                             */
/* Customer       : AEOMX                                                              */
/*                                                                                     */
/*                                                                                     */
/* Date        Rev    Author     Purposes                                              */
/* 2026-07-06  1.0.0  JackC      FCR-12984 Move inv to marshalling lane and send IML   */
/* 2026-07-11  1.0.1  JackC      FCR-12984 Update IML parameters                       */
/* 2026-07-23  1.0.2  JackC      FCR-12984 New IML trigger requirement                 */
/***************************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_838ExtScn10_LabelNoConfirm] (
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

   SET @nErrNo  = 0
   SET @cErrMsg = ''

   IF @nDebugFlag = 1
      SELECT 'rdt_838ExtScn10_LabelNoConfirm: Start'

   -- Get username
   SELECT @cUserName = UserName
   FROM rdt.RDTMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Get WaveSubType for marshalling lane lookup
   SELECT @cWaveSubType = ISNULL(UserDefine05, '')
   FROM dbo.Wave WITH (NOLOCK)
   WHERE WaveKey = @cWaveKey

   -- Get config
   SET @cMoveQTYAlloc = rdt.RDTGetConfig(@nFunc, 'MoveQTYAlloc', @cStorerKey)
   SET @cMoveQTYPick  = rdt.RDTGetConfig(@nFunc, 'MoveQTYPick',  @cStorerKey)
   SET @cPickStatus   = rdt.RDTGetConfig(@nFunc, 'PickStatus',   @cStorerKey)
   IF @cPickStatus = '0'
      SET @cPickStatus = '5'
   
   SET @nRowCount = 0
   -- Resolve marshalling lane from CODELKUP
   SELECT @cMarshallingLane = UDF02
   FROM dbo.CODELKUP WITH (NOLOCK)
   WHERE LISTNAME    = 'AEOMXSTG'
     AND StorerKey   = @cStorerKey
     AND Code        = @cWaveType
     AND Code2       = @cWaveSubType
   
   SET @nRowCount = @@ROWCOUNT
   
   IF @nRowCount = 0 OR ISNULL(@cMarshallingLane, '') = ''
   BEGIN
      SET @nErrNo  = 272701
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --MarshallingLaneNotFound
      GOTO Quit
   END

   IF NOT EXISTS (SELECT 1 FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cMarshallingLane AND Facility = @cFacility)
   BEGIN
      SET @nErrNo  = 272707
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --InvalidMarshallingLane
      GOTO Quit
   END

   -- Validate config
   IF @cMoveQTYAlloc <> '1' AND @cMoveQTYPick <> '1'
   BEGIN
      SET @nErrNo  = 272702
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --IncorrectSetup
      GOTO Quit
   END

   IF @cMoveQTYAlloc = '1' AND @cPickStatus = '5'
   BEGIN
      SET @nErrNo  = 272703
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --IncorrectSetup
      GOTO Quit
   END

   IF @cMoveQTYPick = '1' AND @cPickStatus < '5'
   BEGIN
      SET @nErrNo  = 272704
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --IncorrectSetup
      GOTO Quit
   END

   -- Build move list from PickDetail (CaseID = LabelNo, DropID = FromDropID)
   BEGIN TRY
      INSERT INTO @tMoveList (FromLoc, FromID, ToLoc, ToID, SKU, Lot, Qty, CaseID, DropID)
      SELECT
         Loc,            -- FromLoc
         ID,             -- FromID
         @cMarshallingLane, -- ToLoc
         LEFT(@cLabelNo, 18), --Make labelno as toID
         SKU,
         LOT,
         SUM(QTY),
         @cLabelNo,
         @cFromDropID
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
        AND CaseID    = @cLabelNo
        AND DropID    = @cFromDropID
        AND Status    = @cPickStatus
        AND QTY       > 0
      GROUP BY Loc, ID, SKU, LOT
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 272705
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --InsertMoveListFailed
      GOTO Quit
   END CATCH

   BEGIN TRY
      INSERT INTO @tPickDetail (PickDetailKey)
      SELECT PickDetailKey
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
        AND CaseID    = @cLabelNo
        AND DropID    = @cFromDropID
        AND Status    = @cPickStatus
        AND QTY       > 0
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 272708
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --InsertPickDetailFailed
      GOTO Quit
   END CATCH

   IF @nDebugFlag = 1
      SELECT 'MoveList', * FROM @tMoveList

   --set sendIMLFlag
   -- Get InterModalVehicle for all wave types
   SELECT TOP 1
      @cInterModalVehicle = OD.InterModalVehicle
   FROM dbo.PackDetail PD WITH (NOLOCK)
   JOIN dbo.WAVE        WITH (NOLOCK) ON PD.RefNo      = WAVE.WaveKey
   JOIN dbo.WAVEDETAIL WD WITH (NOLOCK) ON WAVE.WaveKey = WD.WaveKey
   JOIN dbo.ORDERS     OD WITH (NOLOCK) ON WD.OrderKey  = OD.OrderKey
   WHERE PD.PickSlipNo = @cPickSlipNo
     AND PD.CartonNo   = @nCartonNo
   ORDER BY OD.OrderKey

   IF @cWaveType = 'ECOM'
   BEGIN
      IF @cInterModalVehicle = 'VA'
      BEGIN
         -- Case 1: WSAEOSHIPLBL
         SELECT TOP 1 @cPackHdrOrderKey = OrderKey
         FROM dbo.PackHeader WITH (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo

         IF ISNULL(@cPackHdrOrderKey, '') = ''
         BEGIN
            SET @nErrNo = 272711
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --PackHeaderNotFound
            GOTO Quit
         END

         SET @cSendECOMIMLFlag = 'Y'
      END
      ELSE
         SET @cSendRTLIMLFlag = 'Y'  -- Case 2: WSSOTMSGENLBL
   END
   ELSE IF @cWaveType = 'RTL'
   BEGIN
      IF EXISTS (SELECT 1 FROM dbo.CODELKUP WITH (NOLOCK)
                 WHERE LISTNAME  = 'AEOTMSLBL'
                   AND StorerKey = @cStorerKey
                   AND Code      = @cInterModalVehicle)
         SET @cSendRTLIMLFlag = 'Y'  -- Case 2: WSSOTMSGENLBL
   END
   -- else: no IML

   IF @nDebugFlag = 1
      SELECT 'SendIMLFlags', @cSendECOMIMLFlag AS SendECOMIMLFlag, @cSendRTLIMLFlag AS SendRTLIMLFlag,
             @cWaveType AS WaveType, @cInterModalVehicle AS InterModalVehicle

   SET @nTranCount = @@TRANCOUNT
   IF @nTranCount = 0
      BEGIN TRAN
   ELSE
      SAVE TRAN rdt_838ExtScn10_LabelNoConfirm

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
            SELECT 'Moving inventory', @nCounter AS RowNumber, @cMoveFromLoc AS FromLoc, @cMarshallingLane AS ToLoc, @cMoveFromID AS FromID,
               @cMoveToID AS ToID, @cMoveSKU AS SKU, @cMoveLot AS Lot, @nMoveQty AS Qty, @cMoveCaseID AS CaseID

         EXECUTE rdt.rdt_Move
            @nMobile     = @nMobile,
            @cLangCode   = @cLangCode,
            @nErrNo      = @nErrNo   OUTPUT,
            @cErrMsg     = @cErrMsg  OUTPUT,
            @cSourceType = 'rdt_838ExtScn10_LabelNoConfirm',
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
            @cActionType    = '3',
            @cUserID        = @cUserName,
            @nMobileNo      = @nMobile,
            @nFunctionID    = @nFunc,
            @cFacility      = @cFacility,
            @cStorerKey     = @cStorerKey,
            @cLocation      = @cMoveFromLoc,
            @cToLocation    = @cMarshallingLane,
            @cID            = @cMoveFromID,
            @cToID          = @cMoveToID,
            @cSKU           = @cMoveSKU,
            @nQTY           = @nMoveQty,
            @cLOT           = @cMoveLot,
            @cCaseID        = @cMoveCaseID,
            @cPickSlipNo    = @cPickSlipNo,
            @cDropID        = @cMoveDropID,
            @cLabelNo       = @cLabelNo
      END -- end loop

      BEGIN TRY
         UPDATE PD  WITH (ROWLOCK)
         SET PD.Notes = ISNULL(PD.Notes, '') + '[PACKED]',
            PD.EditDate = GETDATE(),
            PD.EditWho = @cUserName,
            PD.TrafficCop = NULL
         FROM dbo.PickDetail PD
         JOIN @tPickDetail tPD ON (PD.PickDetailKey = tPD.PickDetailKey)
      END TRY
      BEGIN CATCH
         SET @nErrNo  = 272709
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Update pick detail failed
         GOTO RollBackTran
      END CATCH
   END -- move inventory

   -- Case 1: ECOM + VA -> WSAEOSHIPLBL
   IF @cSendECOMIMLFlag = 'Y'
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Generating ECOM Transmit Log for IML (WSAEOSHIPLBL)', @cPackHdrOrderKey AS OrderKey

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
         SET @nErrNo  = CASE WHEN @nErrNo = 0 THEN 272710 ELSE @nErrNo END
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --GenECOMTransLogFail
         GOTO RollBackTran
      END
   END

   -- Case 2: ECOM non-VA / RTL -> WSSOTMSGENLBL
   IF @cSendRTLIMLFlag = 'Y'
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Generating RTL Transmit Log for IML (WSSOTMSGENLBL)', @cLabelNo AS LabelNo

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
         SET @nErrNo  = CASE WHEN @nErrNo = 0 THEN 272706 ELSE @nErrNo END
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --GenTransLogFail
         GOTO RollBackTran
      END
   END

   IF @nTranCount = 0
      COMMIT TRANSACTION; -- who start the tran who close the tran

   GOTO Quit

   RollBackTran:
      IF @nTranCount > 0 AND XACT_STATE() <> -1
         ROLLBACK TRAN rdt_838ExtScn10_LabelNoConfirm
      ELSE
         ROLLBACK TRAN

   Quit:
      IF @nDebugFlag = 1
         SELECT 'rdt_838ExtScn10_LabelNoConfirm: End', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
      WHILE @@TRANCOUNT > @nTranCount
         COMMIT TRAN

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838ExtScn10_LabelNoConfirm TO NSQL
GO
