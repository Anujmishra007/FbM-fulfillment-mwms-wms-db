SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************************************/
/* Store procedure: rdt_957Confirm03                                                               */
/* Copyright      : Maersk                                                                         */
/*                                                                                                 */
/* Date       Rev  Author     Purposes                                                             */
/* 01-11-2023 1.0  Ung        WMS-23916 Created                                                    */
/***************************************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_957Confirm03] (
    @nMobile      INT
   ,@nFunc        INT
   ,@cLangCode    NVARCHAR( 3)
   ,@nStep        INT
   ,@nInputKey    INT
   ,@cFacility    NVARCHAR( 5)
   ,@cStorerKey   NVARCHAR( 15)
   ,@cType        NVARCHAR( 10) -- CONFIRM/SHORT/CLOSE
   ,@cPickSlipNo  NVARCHAR( 10)
   ,@cPickZone    NVARCHAR( 10)
   ,@cDropID      NVARCHAR( 20)
   ,@cLOC         NVARCHAR( 10)
   ,@cID          NVARCHAR( 18)
   ,@cBarcode     NVARCHAR( 60)
   ,@cSKU         NVARCHAR( 20) -- SKU is blank
   ,@nQTY         INT           -- QTY is 0
   ,@nErrNo       INT           OUTPUT
   ,@cErrMsg      NVARCHAR(250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nRowCount         INT
   DECLARE @nTranCount        INT

   DECLARE @cActUCCNo         NVARCHAR( 20)
   DECLARE @cActUCCLOT        NVARCHAR( 10)
   DECLARE @cActUCCLOC        NVARCHAR( 10)
   DECLARE @cActUCCID         NVARCHAR( 18)
   DECLARE @cActUCCSKU        NVARCHAR( 20)
   DECLARE @nActUCCQTY        INT
   DECLARE @cActUCCStatus     NVARCHAR( 1)

   SET @nTranCount = @@TRANCOUNT
   
   -- Get storer config
   DECLARE @cPickConfirmStatus NVARCHAR( 1)
   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'

   -- Get UCC info
   SELECT 
      @cActUCCNo = @cBarcode, 
      @cActUCCLOT = LOT,
      @cActUCCLOC = LOC,
      @cActUCCID = ID, 
      @cActUCCSKU = SKU, 
      @nActUCCQTY = QTY, 
      @cActUCCStatus = Status
   FROM dbo.UCC WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND UCCNo = @cBarcode
      
   SET @nRowCount = @@ROWCOUNT
   
   -- Check UCC valid
   IF @nRowCount = 0
   BEGIN
      SET @nErrNo = 208351
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Not an UCC
      GOTO Quit
   END
      
   -- Check UCC status
   IF @cActUCCStatus NOT IN ('1', '3', '4')
   BEGIN
      SET @nErrNo = 208352
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Bad UCC Status
      GOTO Quit
   END
   
   -- Check UCC LOC match
   IF @cLOC <> @cActUCCLOC
   BEGIN
      SET @nErrNo = 208353
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCCLOCNotMatch
      GOTO Quit
   END

   -- Check UCC ID match
   IF @cID <> @cActUCCID
   BEGIN
      SET @nErrNo = 208354
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCCIDNotMatch
      GOTO Quit
   END
   
/*--------------------------------------------------------------------------------------------------
                                             PickDetail
--------------------------------------------------------------------------------------------------*/
   DECLARE @cOrderKey      NVARCHAR( 10) = ''
   DECLARE @cLoadKey       NVARCHAR( 10) = ''
   DECLARE @cZone          NVARCHAR( 18) = ''
   DECLARE @cPickDetailKey NVARCHAR( 10)
   DECLARE @curPD          CURSOR

   -- Get PickHeader info
   SELECT TOP 1
      @cOrderKey = OrderKey,
      @cLoadKey = ExternOrderKey,
      @cZone = Zone
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   -- Cross dock PickSlip
   IF @cZone IN ('XD', 'LB', 'LP')
      SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT PD.PickDetailKey
         FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
         WHERE RKL.PickSlipNo = @cPickSlipNo
            AND PD.LOC = @cLOC
            AND PD.ID  = @cID
            AND PD.DropID = @cActUCCNo
            AND PD.QTY > 0
            AND PD.Status <> '4'
            AND PD.Status < @cPickConfirmStatus

   -- Discrete PickSlip
   ELSE IF @cOrderKey <> ''
      SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT PD.PickDetailKey
         FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
         WHERE PD.OrderKey = @cOrderKey
            AND PD.LOC = @cLOC
            AND PD.ID  = @cID 
            AND PD.DropID = @cActUCCNo
            AND PD.QTY > 0
            AND PD.Status <> '4'
            AND PD.Status < @cPickConfirmStatus

   -- Conso PickSlip
   ELSE IF @cLoadKey <> ''
      SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT PD.PickDetailKey
         FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
            JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
         WHERE LPD.LoadKey = @cLoadKey
            AND PD.LOC = @cLOC
            AND PD.ID  = @cID 
            AND PD.DropID = @cActUCCNo
            AND PD.QTY > 0
            AND PD.Status <> '4'
            AND PD.Status < @cPickConfirmStatus

   -- Custom PickSlip
   ELSE
      SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT PD.PickDetailKey
         FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
         WHERE PD.PickSlipNo = @cPickSlipNo
            AND PD.LOC = @cLOC
            AND PD.ID  = @cID 
            AND PD.DropID = @cActUCCNo
            AND PD.QTY > 0
            AND PD.Status <> '4'
            AND PD.Status < @cPickConfirmStatus
            
   -- Handling transaction
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_957Confirm03 -- For rollback or commit only our own transaction
   
   OPEN @curPD
   FETCH NEXT FROM @curPD INTO @cPickDetailKey
   WHILE @@FETCH_STATUS = 0
   BEGIN
      -- Update PickDetail
      UPDATE dbo.PickDetail SET
         CaseID = @cActUCCNo,
         -- DropID = @cDropID, 
         Status = @cPickConfirmStatus, 
         EditDate = GETDATE(),
         EditWho = SUSER_SNAME()
      WHERE PickDetailKey = @cPickDetailKey
      IF @@ERROR <> 0 OR @@ROWCOUNT = 0
      BEGIN
         SET @nErrNo = 208355
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
         GOTO RollBackTran
      END
      FETCH NEXT FROM @curPD INTO @cPickDetailKey
   END

   -- Check UCC on PickDetail
   IF @cPickDetailKey = ''
   BEGIN
      SET @nErrNo = 208356
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC NotOn PSNO
      GOTO RollBackTran
   END

   -- Actual
   UPDATE dbo.UCC SET
      Status = '5', -- 5=Picked
      EditDate = GETDATE(),
      EditWho = SUSER_SNAME()
   WHERE StorerKey = @cStorerkey
      AND UCCNo = @cActUCCNo
   IF @@ERROR <> 0
   BEGIN
      SET @nErrNo = 208357
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD UCC Fail
      GOTO RollBackTran
   END

/*--------------------------------------------------------------------------------------------------
                                             PackDetail
--------------------------------------------------------------------------------------------------*/
   -- New carton
   DECLARE @nCartonNo INT = 0
   DECLARE @cLabelNo NVARCHAR( 20) = ''

   -- Get UCC info
   SELECT
      @cSKU = SKU,
      @nQTY = QTY
   FROM UCC WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND UCCNo = @cActUCCNo
   SET @nRowCount = @@ROWCOUNT

   -- Confirm SKU
   IF @nRowCount = 1
   BEGIN
      -- Confirm
      EXEC RDT.rdt_Pack_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
         ,@cPickSlipNo    = @cPickSlipNo
         ,@cFromDropID    = '' -- @cFromDropID
         ,@cSKU           = @cSKU
         ,@nQTY           = @nQTY
         ,@cUCCNo         = @cActUCCNo
         ,@cSerialNo      = '' -- @cSerialNo
         ,@nSerialQTY     = 0  -- @nSerialQTY
         ,@cPackDtlRefNo  = '' -- @cPackDtlRefNo
         ,@cPackDtlRefNo2 = '' -- @cPackDtlRefNo2
         ,@cPackDtlUPC    = '' -- @cPackDtlUPC
         ,@cPackDtlDropID = @cActUCCNo
         ,@nCartonNo      = @nCartonNo    OUTPUT
         ,@cLabelNo       = @cLabelNo     OUTPUT
         ,@nErrNo         = @nErrNo       OUTPUT
         ,@cErrMsg        = @cErrMsg      OUTPUT
         ,@nBulkSNO       = 0
         ,@nBulkSNOQTY    = 0
         ,@cPackData1     = ''
         ,@cPackData2     = ''
         ,@cPackData3     = ''
         ,@nUseStandard   = 1
      IF @nErrNo <> 0
         GOTO RollBackTran
   END

   -- Confirm SKU for multi SKU UCC
   IF @nRowCount > 1
   BEGIN
      DECLARE @curUCC CURSOR
      SET @curUCC = CURSOR SCROLL FOR -- Need scroll cursor for 2nd loop in below
         SELECT SKU, QTY
         FROM UCC WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND UCCNo = @cActUCCNo
         ORDER BY UCC_RowRef
      OPEN @curUCC
      FETCH NEXT FROM @curUCC INTO @cSKU, @nQTY
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- Confirm
         EXEC RDT.rdt_Pack_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
            ,@cPickSlipNo    = @cPickSlipNo
            ,@cFromDropID    = '' -- @cFromDropID
            ,@cSKU           = @cSKU
            ,@nQTY           = @nQTY
            ,@cUCCNo         = @cActUCCNo
            ,@cSerialNo      = '' -- @cSerialNo
            ,@nSerialQTY     = 0  -- @nSerialQTY
            ,@cPackDtlRefNo  = '' -- @cPackDtlRefNo
            ,@cPackDtlRefNo2 = '' -- @cPackDtlRefNo2
            ,@cPackDtlUPC    = '' -- @cPackDtlUPC
            ,@cPackDtlDropID = '' -- @cPackDtlDropID
            ,@nCartonNo      = @nCartonNo    OUTPUT
            ,@cLabelNo       = @cLabelNo     OUTPUT
            ,@nErrNo         = @nErrNo       OUTPUT
            ,@cErrMsg        = @cErrMsg      OUTPUT
            ,@nBulkSNO       = 0
            ,@nBulkSNOQTY    = 0
            ,@cPackData1     = ''
            ,@cPackData2     = ''
            ,@cPackData3     = ''
            ,@nUseStandard   = 1
         IF @nErrNo <> 0
            GOTO RollBackTran

         FETCH NEXT FROM @curUCC INTO @cSKU, @nQTY
      END
   END

   -- Event log
   EXEC RDT.rdt_STD_EventLog
      @cActionType   = '3', -- Picking
      @nMobileNo     = @nMobile,
      @nFunctionID   = @nFunc,
      @cFacility     = @cFacility,
      @cStorerKey    = @cStorerKey,
      @cLocation     = @cLOC,
      @cID           = @cID, 
      @cUCC          = @cActUCCNo,
      @cPickSlipNo   = @cPickSlipNo,
      @cPickZone     = @cPickZone,
      @cDropID       = @cDropID

   COMMIT TRAN rdt_957Confirm03
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_957Confirm03 -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO
GRANT EXECUTE ON  [RDT].[rdt_957Confirm03] TO [NSQL]
GO
