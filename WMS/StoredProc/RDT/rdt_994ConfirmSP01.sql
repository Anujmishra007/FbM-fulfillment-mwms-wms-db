SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: rdt_994ConfirmSP01                                           */
/* Copyright      : Maersk                                                       */
/* Customer       : AEOMX                                                        */
/*                                                                               */
/* Date        Rev      Author       Purposes                                    */
/* 2026-09-12  1.0.0    JackC        FCR-16295 Created based on 838ConfirmSP35   */
/*********************************************************************************/

CREATE OR ALTER PROC rdt.rdt_994ConfirmSP01 (
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR( 3)
   ,@nStep           INT
   ,@nInputKey       INT
   ,@cFacility       NVARCHAR( 5)
   ,@cStorerKey      NVARCHAR( 15)
   ,@cPickSlipNo     NVARCHAR( 10)
   ,@cFromDropID     NVARCHAR( 20)
   ,@cSKU            NVARCHAR( 20)
   ,@nQTY            INT
   ,@cUCCNo          NVARCHAR( 20)
   ,@cSerialNo       NVARCHAR( 30)
   ,@nSerialQTY      INT
   ,@cPackDtlRefNo   NVARCHAR( 20)
   ,@cPackDtlRefNo2  NVARCHAR( 20)
   ,@cPackDtlUPC     NVARCHAR( 30)
   ,@cPackDtlDropID  NVARCHAR( 20)
   ,@nCartonNo       INT           OUTPUT
   ,@cLabelNo        NVARCHAR( 20) OUTPUT
   ,@nErrNo          INT           OUTPUT
   ,@cErrMsg         NVARCHAR(250) OUTPUT
   ,@nBulkSNO        INT
   ,@nBulkSNOQTY     INT
   ,@cPackData1      NVARCHAR( 30)
   ,@cPackData2      NVARCHAR( 30)
   ,@cPackData3      NVARCHAR( 30)
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag     INT = 0

   DECLARE @cSQL           NVARCHAR(MAX)
   DECLARE @cSQLParam      NVARCHAR(MAX)

   DECLARE @bSuccess    INT
   DECLARE @cLabelLine  NVARCHAR( 5)
   DECLARE @cNewLine    NVARCHAR( 1)
   DECLARE @cNewCarton  NVARCHAR( 1)
   DECLARE @cDropID     NVARCHAR( 20) = ''
   DECLARE @cRefNo      NVARCHAR( 20) = ''
   DECLARE @cRefNo2     NVARCHAR( 30) = ''
   DECLARE @cUPC        NVARCHAR( 30) = ''

   DECLARE @cGenLabelNo_SP       NVARCHAR( 20)
   DECLARE @cPackDetailCartonID  NVARCHAR( 20)
   DECLARE @cPackByFromDropID    NVARCHAR( 1)
   DECLARE @cLoadKey             NVARCHAR( 10)
   DECLARE @cOrderKey            NVARCHAR( 10)

   --Customization variables V1.0
   DECLARE
      @cWaveKey            NVARCHAR( 10),
      @cWaveType           NVARCHAR( 20)

   --Initialize variable values
   SELECT
      @cWaveKey = C_String1,
      @cWaveType = C_String2
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Storer configure
   SET @cPackByFromDropID = rdt.rdtGetConfig( @nFunc, 'PackByFromDropID', @cStorerKey)

   -- 994 packs by PickSlipNo, not by DropID — PackByFromDropID must be off
   IF @cPackByFromDropID = '1'
   BEGIN
      SET @nErrNo = 281170
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PackByFromDropID must be off
      GOTO Quit
   END

   SET @cRefNo = @cWaveKey

   IF @nDebugFlag = 1
      SELECT 'Executing 994ConfirmSP01', @cPickSlipNo AS PSNO, @cFromDropID AS FromDropID, @cWaveKey AS WaveKey, @cWaveType AS WaveType
            ,@nCartonNo AS CartonNo, @cLabelNo AS LabelNo

   -- Handling transaction
   DECLARE @nTranCount  INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_994ConfirmSP01 -- For rollback or commit only our own transaction

   --V1.0.1 start
   SET @cOrderKey = ''
   SET @cLoadKey = ''

   SELECT TOP 1
      @cOrderKey = OrderKey,
      @cLoadKey = ExternOrderKey
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo
   --V1.0.1 end

   IF ISNULL(@cOrderKey, '') = '' AND ISNULL(@cLoadKey, '') = ''
   BEGIN
      SET @nErrNo = 281186
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --OrderKey and LoadKey both empty
      GOTO RollBackTran
   END


   -- PackHeader
   IF NOT EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickslipNo = @cPickslipNo)
   BEGIN
      -- Get PickHeader info
      BEGIN TRY
         INSERT INTO dbo.PackHeader (PickSlipNo, StorerKey, OrderKey, LoadKey)
         VALUES (@cPickSlipNo, @cStorerKey, @cOrderKey, @cLoadKey)
      END TRY
      BEGIN CATCH
         SET @nErrNo = 281151
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPHdrFail
         GOTO RollBackTran
      END CATCH
   END

   SET @cNewLine = 'N'
   SET @cNewCarton = 'N'

   -- New carton, generate labelNo
   IF @nCartonNo = 0 --
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'New carton, generate labelNo'

      SET @cLabelNo = ''

      IF @cUCCNo <> ''
      BEGIN
         IF rdt.RDTGetConfig( @nFunc, 'DefaultUCCtoLabelNo', @cStorerkey) = '1'
            SET @cLabelNo = @cUCCNo
      END

      IF @cLabelNo = ''
      BEGIN
         SET @cGenLabelNo_SP = rdt.RDTGetConfig( @nFunc, 'GenLabelNo_SP', @cStorerkey)
         IF @cGenLabelNo_SP = '0'
            SET @cGenLabelNo_SP = ''

         IF @cGenLabelNo_SP <> ''
         BEGIN
            IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cGenLabelNo_SP AND type = 'P')
            BEGIN
               SET @cSQL = 'EXEC dbo.' + RTRIM( @cGenLabelNo_SP) +
                  ' @cPickslipNo, ' +
                  ' @nCartonNo,   ' +
                  ' @cLabelNo     OUTPUT '
               SET @cSQLParam =
                  ' @cPickslipNo  NVARCHAR(10),       ' +
                  ' @nCartonNo    INT,                ' +
                  ' @cLabelNo     NVARCHAR(20) OUTPUT '
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                  @cPickslipNo,
                  @nCartonNo,
                  @cLabelNo OUTPUT
            END
         END
         ELSE
         BEGIN
            EXEC isp_GenUCCLabelNo
               @cStorerKey,
               @cLabelNo      OUTPUT,
               @bSuccess      OUTPUT,
               @nErrNo        OUTPUT,
               @cErrMsg       OUTPUT
            IF @nErrNo <> 0
            BEGIN
               SET @nErrNo = 281152
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenLabelNoFail
               GOTO RollBackTran
            END
         END
      END

      IF @cLabelNo = ''
      BEGIN
         SET @nErrNo = 281153
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenLabelNoFail
         GOTO RollBackTran
      END

      SET @cLabelLine = ''
      SET @cNewLine = 'Y'
      SET @cNewCarton = 'Y'
   END
   ELSE
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Existing carton, get lableline'
      -- Get LabelLine
      SET @cLabelLine = ''

      --V1.0 ECOM is precartonized, one PSNO one carton. The initial PackDetail doesn't have DropID value (FromDropID)
      SELECT @cLabelLine = LabelLine
      FROM dbo.PackDetail WITH (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND LabelNo = @cLabelNo
         --AND DropID = CASE WHEN @cWaveType = 'ECOM' THEN DropID ELSE @cDropID END
         AND SKU = @cSKU

      IF @cLabelLine = ''
         SELECT @cLabelLine = LabelLine
         FROM dbo.PackDetail WITH (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
            AND CartonNo = @nCartonNo
            AND LabelNo = @cLabelNo
            AND SKU = ''

      IF @cLabelLine = ''
      BEGIN
         SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)
         FROM dbo.PackDetail WITH (NOLOCK)
         WHERE Pickslipno = @cPickSlipNo
            AND CartonNo = @nCartonNo
            AND LabelNo = @cLabelNo

         SET @cNewLine = 'Y'
      END
   END

   IF @nDebugFlag = 1
      SELECT 'After geting LabelNo, LableLine', @cNewCarton AS NewCarton, @cNewLine AS NewLine, @nCartonNo AS CartonNo,
               @cLabelNo AS LabelNo, @cLabelLine AS LabelLine

   IF @cNewLine = 'Y'
   BEGIN
      -- Insert PackDetail
      BEGIN TRY
         INSERT INTO dbo.PackDetail
            (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY,EXPQTY,
            DropID, RefNo, RefNo2, UPC,
            AddWho, AddDate, EditWho, EditDate)
         VALUES
            (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @nQTY,@nQTY, --V1.0
            '', @cRefNo, @cRefNo2, @cUPC,
            'rdt.' + SUSER_SNAME(), GETDATE(), 'rdt.' + SUSER_SNAME(), GETDATE())
      END TRY
      BEGIN CATCH
         SET @nErrNo = 281155
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPackDtlFail
         GOTO RollBackTran
      END CATCH
   END
   ELSE
   BEGIN
      -- Update Packdetail
      BEGIN TRY
         UPDATE dbo.PackDetail WITH (ROWLOCK) SET
            SKU = @cSKU,
            QTY = QTY + @nQTY,
            EXPQTY =  CASE WHEN @cWaveType = 'ECOM' THEN EXPQTY ELSE EXPQTY + @nQTY  END, --V1.0 ECOM is precartonized, not need to update ExtQty
            RefNo = @cRefNo,
            --DropID =  @cDropID,
            EditWho = 'rdt.' + SUSER_SNAME(),
            EditDate = GETDATE(),
            ArchiveCop = NULL
         WHERE PickSlipNo = @cPickSlipNo
            AND CartonNo = @nCartonNo
            AND LabelNo = @cLabelNo
            AND LabelLine = @cLabelLine
      END TRY
      BEGIN CATCH
         SET @nErrNo = 281156
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPackDtlFail
         GOTO RollBackTran
      END CATCH
   END

   -- Get system assigned CartonoNo and LabelNo
   IF @nCartonNo = 0
   BEGIN
      -- If insert cartonno = 0, system will auto assign max cartonno
      SELECT TOP 1
         @nCartonNo = CartonNo,
         @cLabelNo = LabelNo,
         @cLabelLine = LabelLine
      FROM dbo.PackDetail WITH (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
         AND SKU = @cSKU
         AND AddWho = 'rdt.' + SUSER_SNAME()
      ORDER BY CartonNo DESC -- max cartonno
   END

   --V1.0 PickDetail Split Logic (set packed qty's pickdetail.caseid to labelno)
   IF ISNULL(@cUCCNo,'') = '' AND @cWaveType <> 'ECOM' -- ECOM no need to handle pickdetail. PKD.CaseId is labelno
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Handling PickDetail', @cUCCNo AS UCCNo, @nQty AS PackQty, @cLabelNo AS LabelNo

      DECLARE @nRemainQTY           INT
      DECLARE @nTotalPickQTY        INT
      DECLARE @cPickStatus          NVARCHAR(10)
      DECLARE @cLoopPickDetailKey   NVARCHAR(10)
      DECLARE @nLoopQTY             INT
      DECLARE @cLoopOrderLineNumber NVARCHAR(5)
      DECLARE @cLoopLot             NVARCHAR(10)
      DECLARE @cLoopLoc             NVARCHAR(10)
      DECLARE @cLoopID              NVARCHAR(18)
      DECLARE @cLoopOrderKey        NVARCHAR(10)
      DECLARE @cLoopTaskDetailKey   NVARCHAR(10)
      DECLARE @cTargetPickDetailKey NVARCHAR(10)
      DECLARE @cNewPickDetailKey    NVARCHAR(10)
      DECLARE @cOperationType       NVARCHAR(10)

      -- Get PickStatus from config
      SET @cPickStatus = rdt.rdtGetConfig(@nFunc, 'PickStatus', @cStorerKey)
      IF @cPickStatus = '0'
         SET @cPickStatus = '5' -- Default to status 5 (picked)

      -- Pre-validation for Non-ECOM: Calculate total available PickDetail quantity.
      IF @cOrderKey <> ''
         SELECT @nTotalPickQTY = SUM(QTY)
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
           AND OrderKey  = @cOrderKey
           AND SKU       = @cSKU
           AND Status    = @cPickStatus
           AND QTY       > 0
           AND (
               (CaseId IS NULL OR CaseId = '')
               OR NOT EXISTS (
                   SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)
                   WHERE PickSlipNo = @cPickSlipNo AND LabelNo = CaseId
               )
           )
      ELSE IF @cLoadKey <> ''
         SELECT @nTotalPickQTY = SUM(PD.QTY)
         FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
         JOIN dbo.PickDetail PD WITH (NOLOCK) ON PD.OrderKey = LPD.OrderKey
         WHERE LPD.LoadKey  = @cLoadKey
           AND PD.StorerKey = @cStorerKey
           AND PD.SKU       = @cSKU
           AND PD.Status    = @cPickStatus
           AND PD.QTY       > 0
           AND (
               (PD.CaseId IS NULL OR PD.CaseId = '')
               OR NOT EXISTS (
                   SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)
                   WHERE PickSlipNo = @cPickSlipNo AND LabelNo = PD.CaseId
               )
           )

      -- Validation: No PickDetail found
      IF @nTotalPickQTY IS NULL
      BEGIN
         SET @nErrNo = 281171
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END

      -- Validation: Pack QTY exceeds available
      IF @nQTY > @nTotalPickQTY
      BEGIN
         SET @nErrNo = 281173
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END

      -- Initialize remaining quantity to process
      SET @nRemainQTY = @nQTY

      -- Main processing loop
      WHILE @nRemainQTY > 0
      BEGIN
         -- Get next PickDetail (order by pickdetailkey)
         SET @cLoopPickDetailKey = NULL

         IF @cOrderKey <> ''
            SELECT TOP 1
               @cLoopPickDetailKey   = PickDetailKey,
               @nLoopQTY             = QTY,
               @cLoopOrderLineNumber = OrderLineNumber,
               @cLoopOrderKey        = OrderKey,
               @cLoopLot             = Lot,
               @cLoopLoc             = Loc,
               @cLoopID              = ID,
               @cLoopTaskDetailKey   = TaskDetailKey
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
              AND OrderKey  = @cOrderKey
              AND SKU       = @cSKU
              AND Status    = @cPickStatus
              AND QTY       > 0
              AND (
                  (CaseId IS NULL OR CaseId = '')
                  OR NOT EXISTS (
                      SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)
                      WHERE PickSlipNo = @cPickSlipNo AND LabelNo = CaseId
                  )
              )
            ORDER BY PickDetailKey
         ELSE IF @cLoadKey <> ''
            SELECT TOP 1
               @cLoopPickDetailKey   = PD.PickDetailKey,
               @nLoopQTY             = PD.QTY,
               @cLoopOrderLineNumber = PD.OrderLineNumber,
               @cLoopOrderKey        = PD.OrderKey,
               @cLoopLot             = PD.Lot,
               @cLoopLoc             = PD.Loc,
               @cLoopID              = PD.ID,
               @cLoopTaskDetailKey   = PD.TaskDetailKey
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON PD.OrderKey = LPD.OrderKey
            WHERE LPD.LoadKey  = @cLoadKey
              AND PD.StorerKey = @cStorerKey
              AND PD.SKU       = @cSKU
              AND PD.Status    = @cPickStatus
              AND PD.QTY       > 0
              AND (
                  (PD.CaseId IS NULL OR PD.CaseId = '')
                  OR NOT EXISTS (
                      SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)
                      WHERE PickSlipNo = @cPickSlipNo AND LabelNo = PD.CaseId
                  )
              )
            ORDER BY PD.PickDetailKey

         IF @nDebugFlag = 1
            SELECT 'Loop PSNO PKD', @cLoopPickDetailKey AS LoopPKD, @nLoopQty AS PKDQty

         -- Post-validation: No more PickDetail - skip and log to TraceInfo
         IF @cLoopPickDetailKey IS NULL
         BEGIN
            BEGIN TRY
               INSERT INTO dbo.TRACEINFO (TraceName, STEP1, STEP2, STEP3, COL1, COL2, COL3, COL4, COL5)
               VALUES ('rdt_994ConfirmSP01', 'SkipPKD',
                        ISNULL(TRY_CAST(@nRemainQTY AS NVARCHAR(10)), ''), '0',
                        @cOrderKey, @cSKU, @cPickSlipNo, @cLabelNo, SUSER_SNAME())
            END TRY
            BEGIN CATCH
               -- Handle the error if the insert fails
               SELECT 'SkipPKD: Failed to insert into TRACEINFO'
            END CATCH

            SET @nErrNo = 281172
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No more PickDetail available
            GOTO RollBackTran -- Exit loop, skip PickDetail update， clean up
         END

         -- Check if target PickDetail exists (already packed to this LabelNo)
         SET @cTargetPickDetailKey = NULL

         SELECT TOP 1 @cTargetPickDetailKey = PickDetailKey
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey       = @cStorerKey
           AND CaseId          = @cLabelNo
           AND OrderKey        = @cLoopOrderKey
           AND OrderLineNumber  = @cLoopOrderLineNumber
           AND Lot             = @cLoopLot
           AND SKU             = @cSKU
           AND Loc             = @cLoopLoc
           AND ID              = @cLoopID
           AND Status          = @cPickStatus
           AND ISNULL(TaskDetailKey, '')   = ISNULL(@cLoopTaskDetailKey, '')

         IF @nDebugFlag = 1
            SELECT 'Finding exact same pkd', @cTargetPickDetailKey AS TargetPKD

         -- Case A: Use entire record (@nLoopQTY <= @nRemainQTY)
         IF @nLoopQTY <= @nRemainQTY
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'PKDQty <= RemainQty', @nLoopQTY AS PKDQty, @nRemainQTY AS RemainQty

            IF @cTargetPickDetailKey IS NOT NULL
            BEGIN
               -- Merge: Add quantity to target
               SET @cOperationType = 'MERGE'

               IF @nDebugFlag = 1
                  SELECT 'Set old pkd to 0, merge Qty to LabelNo PKD'

               -- Set source QTY to 0 (will be deleted in cleanup)
               BEGIN TRY
                  UPDATE dbo.PickDetail WITH (ROWLOCK)
                  SET QTY = 0,
                     EditWho = SUSER_SNAME(),
                     EditDate = GETDATE(),
                     TrafficCop = NULL
                  WHERE PickDetailKey = @cLoopPickDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 281174
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran
               END CATCH

               BEGIN TRY
                  UPDATE dbo.PickDetail WITH (ROWLOCK)
                  SET QTY = QTY + @nLoopQTY,
                     UOMQty = CASE WHEN UOM = '6' THEN UOMQty + @nLoopQTY ELSE UOMQty END,
                     EditWho = SUSER_SNAME(),
                     EditDate = GETDATE(),
                     TrafficCop = NULL
                  WHERE PickDetailKey = @cTargetPickDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 281175
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran
               END CATCH
            END
            ELSE
            BEGIN
               SET @cOperationType = 'UPDATE'

               IF @nDebugFlag = 1
                  SELECT 'Update old PKD'

               BEGIN TRY
                  UPDATE dbo.PickDetail WITH (ROWLOCK)
                  SET CaseId = @cLabelNo,
                     EditWho = SUSER_SNAME(),
                     EditDate = GETDATE(),
                     TrafficCop = NULL
                  WHERE PickDetailKey = @cLoopPickDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 281176
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran
               END CATCH
            END

            SET @nRemainQTY = @nRemainQTY - @nLoopQTY
         END
         -- Case B: Split record (@nLoopQTY > @nRemainQTY)
         ELSE
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'PKDQty > RemainQty', @nLoopQTY AS PKDQty, @nRemainQTY AS RemainQty

            IF @cTargetPickDetailKey IS NOT NULL
            BEGIN
               -- Merge: Add remaining quantity to target
               SET @cOperationType = 'MERGE'

               IF @nDebugFlag = 1
                  SELECT 'reduce old pkd qty, merge Qty to LabelNo PKD'

               -- Reduce source QTY
               BEGIN TRY
                  UPDATE dbo.PickDetail WITH (ROWLOCK)
                  SET QTY = QTY - @nRemainQTY,
                     UOMQty = CASE WHEN UOM = '6' AND (UOMQty - @nRemainQTY > 0)
                              THEN UOMQty - @nRemainQTY
                              WHEN UOM = '6' AND (UOMQty - @nRemainQTY <= 0)
                              THEN 0
                              ELSE UOMQty END,
                     EditWho = SUSER_SNAME(),
                     EditDate = GETDATE(),
                     TrafficCop = NULL
                  WHERE PickDetailKey = @cLoopPickDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 281177
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran
               END CATCH

               BEGIN TRY
                  UPDATE dbo.PickDetail WITH (ROWLOCK)
                  SET QTY = QTY + @nRemainQTY,
                     UOMQty = CASE WHEN UOM = '6' THEN UOMQty + @nRemainQTY ELSE UOMQty END,
                     EditWho = SUSER_SNAME(),
                     EditDate = GETDATE(),
                     TrafficCop = NULL
                  WHERE PickDetailKey = @cTargetPickDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 281178
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran
               END CATCH
            END
            ELSE
            BEGIN
               -- Split: Create new PickDetail with remaining quantity
               SET @cOperationType = 'SPLIT'

                IF @nDebugFlag = 1
                  SELECT 'reduce old pkd qty, create a new LabelNo PKD'

                -- Reduce source QTY
               BEGIN TRY
                  UPDATE dbo.PickDetail WITH (ROWLOCK)
                  SET QTY = QTY - @nRemainQTY,
                     UOMQty = CASE WHEN UOM = '6' AND (UOMQty - @nRemainQTY > 0)
                                 THEN UOMQty - @nRemainQTY
                                 WHEN UOM = '6' AND (UOMQty - @nRemainQTY <= 0)
                                 THEN 0
                                 ELSE UOMQty END,
                     EditWho = SUSER_SNAME(),
                     EditDate = GETDATE()
                  WHERE PickDetailKey = @cLoopPickDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 281179
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran
               END CATCH

               -- Generate new PickDetailKey
               EXEC nspg_GetKey
                  'PICKDETAILKEY',
                  10,
                  @cNewPickDetailKey OUTPUT,
                  @bSuccess OUTPUT,
                  @nErrNo OUTPUT,
                  @cErrMsg OUTPUT
               IF @bSuccess <> 1
               BEGIN
                  SET @nErrNo = 281180
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran
               END

               -- Insert new PickDetail
               BEGIN TRY
                  INSERT INTO dbo.PickDetail (
                     PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot,
                     StorerKey, SKU, AltSKU, UOM, UOMQty, QTY, QtyMoved, Status,
                     DropID, Loc, ID, PackKey, UpdateSource, CartonGroup, CartonType,
                     ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
                     EffectiveDate, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey,
                     Notes, AddWho, AddDate, EditWho, EditDate
                  )
                  SELECT
                     @cNewPickDetailKey,
                     @cLabelNo, PickHeaderKey, OrderKey, OrderLineNumber, Lot,
                     StorerKey, SKU, AltSKU, UOM,
                     CASE WHEN UOM = '6' THEN @nRemainQTY ELSE UOMQty END,
                     @nRemainQTY, -- QTY
                     QtyMoved, '0', --trigger restriction, status must be 0
                     DropID,
                     Loc, ID, PackKey, UpdateSource, CartonGroup, CartonType,
                     ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
                     EffectiveDate, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey,
                     '',
                     SUSER_SNAME(), GETDATE(), SUSER_SNAME(), GETDATE()
                  FROM dbo.PickDetail WITH (NOLOCK)
                  WHERE PickDetailKey = @cLoopPickDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 281181
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran
               END CATCH

               BEGIN TRY
                  UPDATE dbo.PickDetail WITH (ROWLOCK)
                  SET Status = @cPickStatus
                  WHERE PickDetailKey = @cNewPickDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 281182
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran
               END CATCH

               -- Copy RefKeyLookup if exists for source
               IF EXISTS (SELECT 1 FROM dbo.RefKeyLookup WITH (NOLOCK) WHERE PickDetailKey = @cLoopPickDetailKey)
               BEGIN
                  BEGIN TRY
                     INSERT INTO dbo.RefKeyLookup (PickDetailKey, PickSlipNo, OrderKey, OrderLineNumber, LoadKey)
                     SELECT @cNewPickDetailKey, PickSlipNo, OrderKey, OrderLineNumber, LoadKey
                     FROM dbo.RefKeyLookup WITH (NOLOCK)
                     WHERE PickDetailKey = @cLoopPickDetailKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 281183
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                     GOTO RollBackTran
                  END CATCH
               END
            END

            SET @nRemainQTY = 0
         END

         -- Debug logging
         IF @nDebugFlag = 2
         BEGIN
            BEGIN TRY
               INSERT INTO dbo.TRACEINFO (TraceName, STEP1, STEP2, STEP3, COL1, COL2, COL3, COL4, COL5)
               VALUES ('rdt_994ConfirmSP01', 'PKD Debug',
                        ISNULL(TRY_CAST(@nRemainQTY AS NVARCHAR(10)), ''),
                        ISNULL(TRY_CAST(@nLoopQTY   AS NVARCHAR(10)), ''),
                        @cOperationType, @cLoopPickDetailKey, ISNULL(@cTargetPickDetailKey,''), @cLabelNo, SUSER_SNAME())
            END TRY
            BEGIN CATCH
               SELECT 'PKD HandlingDebug: Failed to insert into TRACEINFO'
            END CATCH
         END
      END

      IF @nDebugFlag = 1
         SELECT 'PKD looping finished, clear PKD Qty = 0'

      -- Cleanup: Delete RefKeyLookup for zero-qty PickDetails
      BEGIN
         BEGIN TRY
            IF @cOrderKey <> ''
               DELETE FROM dbo.RefKeyLookup
               WHERE PickDetailKey IN (
                  SELECT PickDetailKey FROM dbo.PickDetail WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                    AND OrderKey  = @cOrderKey
                    AND SKU       = @cSKU
                    AND Status    = @cPickStatus
                    AND QTY       = 0
                    AND (
                        (CaseId IS NULL OR CaseId = '')
                        OR NOT EXISTS (
                            SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)
                            WHERE PickSlipNo = @cPickSlipNo AND LabelNo = CaseId
                        )
                    )
               )
            ELSE IF @cLoadKey <> ''
               DELETE FROM dbo.RefKeyLookup
               WHERE PickDetailKey IN (
                  SELECT PD.PickDetailKey
                  FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON PD.OrderKey = LPD.OrderKey
                  WHERE LPD.LoadKey  = @cLoadKey
                    AND PD.StorerKey = @cStorerKey
                    AND PD.SKU       = @cSKU
                    AND PD.Status    = @cPickStatus
                    AND PD.QTY       = 0
                    AND (
                        (PD.CaseId IS NULL OR PD.CaseId = '')
                        OR NOT EXISTS (
                            SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)
                            WHERE PickSlipNo = @cPickSlipNo AND LabelNo = PD.CaseId
                        )
                    )
               )
         END TRY
         BEGIN CATCH
            SET @nErrNo = 281184
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            GOTO RollBackTran
         END CATCH

         -- Cleanup: Delete zero-qty PickDetails
         BEGIN TRY
            IF @cOrderKey <> ''
               DELETE FROM dbo.PickDetail
               WHERE StorerKey = @cStorerKey
                 AND OrderKey  = @cOrderKey
                 AND SKU       = @cSKU
                 AND Status    = @cPickStatus
                 AND QTY       = 0
                 AND (
                     (CaseId IS NULL OR CaseId = '')
                     OR NOT EXISTS (
                         SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)
                         WHERE PickSlipNo = @cPickSlipNo AND LabelNo = CaseId
                     )
                 )
            ELSE IF @cLoadKey <> ''
               DELETE PD
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
               JOIN dbo.PickDetail PD ON PD.OrderKey = LPD.OrderKey
               WHERE LPD.LoadKey  = @cLoadKey
                 AND PD.StorerKey = @cStorerKey
                 AND PD.SKU       = @cSKU
                 AND PD.Status    = @cPickStatus
                 AND PD.QTY       = 0
                 AND (
                     (PD.CaseId IS NULL OR PD.CaseId = '')
                     OR NOT EXISTS (
                         SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)
                         WHERE PickSlipNo = @cPickSlipNo AND LabelNo = PD.CaseId
                     )
                 )
         END TRY
         BEGIN CATCH
            SET @nErrNo = 281185
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            GOTO RollBackTran
         END CATCH
      END
   END
   ELSE
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'ECOM wave, skip pickdetail handling'
   END
   --V1.0 PickDetail Split Logic (set packed qty's pickdetail.caseid to labelno)

   -- Insert PackInfo
   IF @cUCCNo <> ''
   BEGIN
      -- PackInfo
      IF NOT EXISTS (SELECT 1 FROM dbo.PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo)
      BEGIN
         BEGIN TRY
            INSERT INTO dbo.PackInfo (PickslipNo, CartonNo, UCCNo, QTY)
            VALUES (@cPickSlipNo, @nCartonNo, @cUCCNo, @nQTY)
         END TRY
         BEGIN CATCH
            SET @nErrNo = 281157
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPackInfFail
            GOTO RollBackTran
         END CATCH
      END
      ELSE
      BEGIN
         BEGIN TRY
            UPDATE dbo.PackInfo WITH (ROWLOCK) SET
               UCCNo = @cUCCNo,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME(),
               TrafficCop = NULL
            WHERE PickSlipNo = @cPickSlipNo
               AND CartonNo = @nCartonNo
         END TRY
         BEGIN CATCH
            SET @nErrNo = 281158
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDPackInfFail
            GOTO RollBackTran
         END CATCH
      END

      -- Mark UCC packed
      IF EXISTS( SELECT 1 FROM dbo.UCC WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND UCCNo = @cUCCNo AND Status < '5')
      BEGIN
         BEGIN TRY
            UPDATE dbo.UCC SET
               Status = '6',
               EditWho = SUSER_SNAME(),
               EditDate = GETDATE(),
               TrafficCop = NULL
            WHERE StorerKey = @cStorerKey
               AND UCCNo = @cUCCNo
         END TRY
         BEGIN CATCH
            SET @nErrNo = 281159
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD UCC Fail
            GOTO RollBackTran
         END CATCH
      END
   END

   -- Many serial no
   IF @nBulkSNO = 1
   BEGIN
      DECLARE @nReceiveSerialNoLogKey INT
      DECLARE @nQTY_Bal INT

      -- Check SNO QTY
      IF (SELECT ISNULL( SUM( QTY), 0)
         FROM rdt.rdtReceiveSerialNoLog WITH (NOLOCK)
         WHERE Mobile = @nMobile
            AND Func = @nFunc) <> @nBulkSNOQTY
      BEGIN
         SET @nErrNo = 281160
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SN QTYNotTally
         GOTO RollBackTran
      END

      SET @nQTY_Bal = @nQTY

      -- Loop serial no
      WHILE (1=1)
      BEGIN
         SELECT TOP 1
            @nReceiveSerialNoLogKey = ReceiveSerialNoLogKey,
            @cSerialNo = SerialNo,
            @nSerialQTY = QTY
         FROM rdt.rdtReceiveSerialNoLog WITH (NOLOCK)
         WHERE Mobile = @nMobile
            AND Func = @nFunc

         IF @@ROWCOUNT = 0
            BREAK

         -- Check serial no scanned
         IF NOT EXISTS( SELECT 1
            FROM dbo.PackSerialNo WITH (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo
               AND StorerKey = @cStorerKey
               AND SKU = @cSKU
               AND SerialNo = @cSerialNo)
         BEGIN
            -- Insert PackSerialNo
            BEGIN TRY
               INSERT INTO dbo.PackSerialNo (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, SerialNo, QTY)
               VALUES (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @cSerialNo, @nSerialQTY)
            END TRY
            BEGIN CATCH
               SET @nErrNo = 281161
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPackSNOFail
               GOTO RollBackTran
            END CATCH
         END
         ELSE
         BEGIN
            SET @nErrNo = 281162
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO ady scan
            GOTO RollBackTran
         END

         BEGIN TRY
            DELETE rdt.rdtReceiveSerialNoLog
            WHERE ReceiveSerialNoLogKey = @nReceiveSerialNoLogKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 281163
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DEL TmpSN Fail
            GOTO RollBackTran
         END CATCH

         SET @nQTY_Bal = @nQTY_Bal - @nSerialQTY
      END

      -- Check fully offset
      IF @nQTY_Bal <> 0
      BEGIN
         SET @nErrNo = 281164
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Offset error
         GOTO RollBackTran
      END

      -- Check balance
      IF EXISTS( SELECT 1
         FROM rdt.rdtReceiveSerialNoLog WITH (NOLOCK)
         WHERE Mobile = @nMobile
            AND Func = @nFunc)
      BEGIN
         SET @nErrNo = 281165
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Offset error
         GOTO RollBackTran
      END
   END

   -- Serial no
   ELSE IF @cSerialNo <> ''
   BEGIN
      -- Get serial no info
      DECLARE @nRowCount INT
      DECLARE @nPackSerialNoKey  INT
      DECLARE @cChkSerialSKU NVARCHAR( 20)
      DECLARE @nChkSerialQTY INT

      SELECT
         @nPackSerialNoKey = PackSerialNoKey,
         @cChkSerialSKU = SKU,
         @nChkSerialQTY = QTY
      FROM dbo.PackSerialNo WITH (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
         AND StorerKey = @cStorerKey
         AND SKU = @cSKU
         AND SerialNo = @cSerialNo
      SET @nRowCount = @@ROWCOUNT

      -- New serial no
      IF @nRowCount = 0
      BEGIN
         -- Insert PackSerialNo
         BEGIN TRY
            INSERT INTO dbo.PackSerialNo (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, SerialNo, QTY)
            VALUES (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @cSerialNo, @nSerialQTY)
         END TRY
         BEGIN CATCH
            SET @nErrNo = 281166
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS RDSNo Fail
            GOTO RollBackTran
         END CATCH
      END

      -- Check serial no scanned
      ELSE
      BEGIN
         SET @nErrNo = 281167
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO ady scan
         GOTO RollBackTran
      END
   END

   -- Pack data
   IF @cPackData1 <> '' OR
      @cPackData2 <> '' OR
      @cPackData3 <> ''
   BEGIN
      DECLARE @nPackDetailInfoKey BIGINT

      -- Get PackDetailInfo
      SET @nPackDetailInfoKey = 0
      SELECT @nPackDetailInfoKey = PackDetailInfoKey
      FROM dbo.PackDetailInfo WITH (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND LabelNo = @cLabelNo
         AND SKU = @cSKU
         AND UserDefine01 = @cPackData1
         AND UserDefine02 = @cPackData2
         AND UserDefine03 = @cPackData3

      IF @nPackDetailInfoKey = 0
      BEGIN
         -- Insert PackDetailInfo
         BEGIN TRY
            INSERT INTO dbo.PackDetailInfo (
               PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, UserDefine01, UserDefine02, UserDefine03,
               AddWho, AddDate, EditWho, EditDate)
            VALUES (
               @cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @nQTY, @cPackData1, @cPackData2, @cPackData3,
               'rdt.' + SUSER_SNAME(), GETDATE(), 'rdt.' + SUSER_SNAME(), GETDATE())
         END TRY
         BEGIN CATCH
            SET @nErrNo = 281168
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PDInfoFail
            GOTO RollBackTran
         END CATCH
      END
      ELSE
      BEGIN
         -- Update PackDetailInfo
         BEGIN TRY
            UPDATE dbo.PackDetailInfo SET
               QTY = QTY + @nQTY,
               EditWho = 'rdt.' + SUSER_SNAME(),
               EditDate = GETDATE(),
               ArchiveCop = NULL
            WHERE PackDetailInfoKey = @nPackDetailInfoKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 281169
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PDInfoFail
            GOTO RollBackTran
         END CATCH
      END
   END

   EXEC RDT.rdt_STD_EventLog
   @cActionType         = '3',
   @nMobileNo           = @nMobile,
   @nFunctionID         = @nFunc,
   @cFacility           = @cFacility,
   @cStorerKey          = @cStorerkey,
   @nQTY                = @nQTY,
   @cUCC                = @cUCCNo,
   @cOrderKey           = @cOrderKey,
   @cSKU                = @cSKU,
   @cRefNo1             = @nCartonNo,
   @cPickSlipNo         = @cPickSlipNo,   -- ZG01
   @cLabelNo            = @cLabelNo       -- ZG01

   COMMIT TRAN rdt_994ConfirmSP01
   GOTO Quit

RollBackTran:
BEGIN
   IF XACT_STATE() = -1
      ROLLBACK TRAN
   ELSE IF XACT_STATE() = 1
      ROLLBACK TRAN rdt_994ConfirmSP01 -- Only rollback change made here

   IF @cNewCarton = 'Y'
   BEGIN
      SET @nCartonNo = 0
      SET @cLabelNo = ''
   END
END

Quit:
   IF @nDebugFlag = 1
      SELECT 'End of 994ConfirmSP01', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg, @nCartonNo AS CartonNo, @cLabelNo AS LabelNo

   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_994ConfirmSP01 TO NSQL
GO
