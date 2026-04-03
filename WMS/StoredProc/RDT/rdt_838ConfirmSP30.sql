SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: rdt_838ConfirmSP30                                           */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Date        Rev    Author       Purposes                                      */
/* 2025-12-31  1.0    Dennis       FCR-8931                                      */
/* 2026-03-30  1.1.0  JCH507       FCR-11193 PickDetail split logic              */
/* 2026-04-01  1.1.1  JCH507       FCR-11193 Update CaseId instead of DropID     */
/* 2026-04-02  1.1.0  NickT        FCR-11343 Confirm B2C singles                 */
/*********************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838ConfirmSP30 (
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
   DECLARE @cUPC        NVARCHAR( 30) = '',
   @cDocType            NVARCHAR( 10)
   
   DECLARE @cGenLabelNo_SP       NVARCHAR( 20)
   DECLARE @cPackDetailCartonID  NVARCHAR( 20)
   DECLARE @cPackByFromDropID    NVARCHAR( 1)

   DECLARE @cIsB2CSingle         NVARCHAR(1) = '0'
   DECLARE @cB2CSingleFlexPack   NVARCHAR(20) = '0'
   DECLARE @cPickdetailKey       NVARCHAR( 18)

   SELECT 
      @cIsB2CSingle        = C_String1
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile
   SET @cB2CSingleFlexPack = rdt.rdtGetConfig(@nFunc, 'B2CSingleFlexPack', @cStorerKey)


   -- Handling transaction
   DECLARE @nTranCount  INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_838ConfirmSP30 -- For rollback or commit only our own transaction

   -- For B2C single, it is pre-cartonized, it should always update existing carton and label, it won't create new carton or label, 
   --even for the first time scanning, as the carton and label are created in advance, and the PickDetail is created when confirming Pick, 
   --so it will always hit the update logic in Pack Confirm SP, it won't hit the insert logic, even for the first time scanning.
   IF @cB2CSingleFlexPack = '1' AND @cIsB2CSingle = '1'
   BEGIN
      -- Get LabelLine
      SET @cLabelLine = ''
      SELECT @cLabelLine = LabelLine
      FROM dbo.PackDetail WITH (NOLOCK) 
      WHERE PickSlipNo = @cPickSlipNo 
         AND CartonNo = @nCartonNo
         AND LabelNo = @cLabelNo
         AND SKU = @cSKU
      
      IF @cLabelLine = ''
      BEGIN
         SET @nErrNo = 262636
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No PackDetail is found
         GOTO RollBackTran
      END

      BEGIN TRY
         UPDATE dbo.PackDetail WITH (ROWLOCK) 
         SET
            Qty = IIF(Qty + 1 > ExpQty, ExpQty, Qty + 1),
            EditWho = SUSER_SNAME(),
            EditDate = GETDATE()
         WHERE PickSlipNo = @cPickSlipNo 
            AND CartonNo = @nCartonNo
            AND LabelNo = @cLabelNo
            AND LabelLine = @cLabelLine
      END TRY
      BEGIN CATCH
         SET @nErrNo = 262637
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PackDetail failed
         GOTO RollBackTran
      END CATCH

      GOTO RDT_EVENT_LOG
   END

   -- PackHeader
   IF NOT EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickslipNo = @cPickslipNo)
   BEGIN
      DECLARE @cLoadKey  NVARCHAR( 10)
      DECLARE @cOrderKey NVARCHAR( 10)
      SET @cOrderKey = ''
      SET @cLoadKey = ''

      -- Get PickHeader info
      SELECT TOP 1
         @cOrderKey = OrderKey,
         @cLoadKey = ExternOrderKey
      FROM dbo.PickHeader WITH (NOLOCK)
      WHERE PickHeaderKey = @cPickSlipNo
      
      INSERT INTO dbo.PackHeader (PickSlipNo, StorerKey, OrderKey, LoadKey)
      VALUES (@cPickSlipNo, @cStorerKey, @cOrderKey, @cLoadKey)
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 262601
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPHdrFail
         GOTO RollBackTran
      END
   END

   SELECT @cDocType = DocType,@cOrderKey = O.OrderKey
   FROM ORDERS O (NOLOCK)
   JOIN PICKHEADER PH (NOLOCK) ON PH.OrderKey = O.OrderKey
   WHERE PH.PickHeaderKey = @cPickSlipNo
     AND O.StorerKey = @cStorerKey

   -- Storer configure
   SET @cPackByFromDropID = rdt.rdtGetConfig( @nFunc, 'PackByFromDropID', @cStorerKey)
   SET @cPackDetailCartonID = rdt.RDTGetConfig( @nFunc, 'PackDetailCartonID', @cStorerKey)
   IF @cPackDetailCartonID = '0' -- DropID/LabelNo/RefNo/RefNo2/UPC/NONE
      SET @cPackDetailCartonID = 'DropID'

   -- Save decoded data to which column (initially it was carton ID only, hence the misleading PackDetailCartonID ConfigKey name)
   IF @cPackDetailCartonID = 'DropID'  SET @cDropID  = @cPackDtlDropID ELSE
   IF @cPackDetailCartonID = 'RefNo'   SET @cRefNo   = @cPackDtlRefNo  ELSE
   IF @cPackDetailCartonID = 'RefNo2'  SET @cRefNo2  = @cPackDtlRefNo2 ELSE
   IF @cPackDetailCartonID = 'UPC'     SET @cUPC     = @cPackDtlUPC

   -- Pack by drop ID, the drop ID must present in both PickDetail and PackDetail, otherwise it can't do over pack checking.
   IF @cPackByFromDropID = '1'
      SET @cDropID = @cFromDropID   
   
   SET @cNewLine = 'N'
   SET @cNewCarton = 'N'
   
   -- New carton, generate labelNo
   IF @nCartonNo = 0 -- 
   BEGIN
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
               SET @nErrNo = 262602
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenLabelNoFail
               GOTO RollBackTran
            END
         END
      END

      IF @cLabelNo = ''
      BEGIN
         SET @nErrNo = 262603
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenLabelNoFail
         GOTO RollBackTran
      END

      SET @cLabelLine = ''   
      SET @cNewLine = 'Y'
      SET @cNewCarton = 'Y'
   END
   ELSE
   BEGIN
      -- Get LabelLine
      SET @cLabelLine = ''
      SELECT @cLabelLine = LabelLine
      FROM dbo.PackDetail WITH (NOLOCK) 
      WHERE PickSlipNo = @cPickSlipNo 
         AND CartonNo = @nCartonNo
         AND LabelNo = @cLabelNo 
         AND DropID = CASE WHEN @cDocType = 'N' THEN @cDropID ELSE DropID END
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
         FROM dbo.PackDetail (NOLOCK)
         WHERE Pickslipno = @cPickSlipNo
            AND CartonNo = @nCartonNo
            AND LabelNo = @cLabelNo

         SET @cNewLine = 'Y'
      END
   END
   
   IF @cNewLine = 'Y'
   BEGIN
      IF @cUCCNo <> '' AND EXISTS (SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo AND DropID = @cUCCNo AND SKU = @cSKU)
      BEGIN
         -- Update Packdetail
         UPDATE dbo.PackDetail WITH (ROWLOCK) SET
            SKU = @cSKU,
            QTY = QTY + @nQTY,
            EditWho = 'rdt.' + SUSER_SNAME(),
            EditDate = GETDATE(),
            ArchiveCop = NULL
         WHERE PickSlipNo = @cPickSlipNo
            AND DropID = @cUCCNo
            AND SKU = @cSKU
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 262605
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPackDtlFail
            GOTO RollBackTran
         END
         SELECT @nCartonNo = CartonNo,@cLabelNo = LabelNo FROM dbo.PackDetail WITH (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo AND DropID = @cUCCNo AND SKU = @cSKU
      END
      ELSE
      BEGIN
         -- Insert PackDetail
         INSERT INTO dbo.PackDetail
            (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY,EXPQTY,
            DropID, RefNo, RefNo2, UPC,
            AddWho, AddDate, EditWho, EditDate)
         VALUES
            (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @nQTY,@nQTY,
            @cDropID, @cRefNo, @cRefNo2, @cUPC,
            'rdt.' + SUSER_SNAME(), GETDATE(), 'rdt.' + SUSER_SNAME(), GETDATE())
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 262604
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPackDtlFail
            GOTO RollBackTran
         END
      END
   END
   ELSE
   BEGIN
      -- Update Packdetail
      UPDATE dbo.PackDetail WITH (ROWLOCK) SET   
         SKU = @cSKU, 
         QTY = QTY + @nQTY, 
         EXPQTY = CASE WHEN @cDocType = 'N' AND ISNULL(@cUCCNo,'') = '' THEN EXPQTY + @nQTY ELSE EXPQTY END,
         DropID =  DropID ,
         EditWho = 'rdt.' + SUSER_SNAME(), 
         EditDate = GETDATE(), 
         ArchiveCop = NULL
      WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND LabelNo = @cLabelNo
         AND LabelLine = @cLabelLine
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 262629
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPackDtlFail
         GOTO RollBackTran
      END
   END

   -- Get system assigned CartonoNo and LabelNo
   IF @nCartonNo = 0
   BEGIN
      -- If insert cartonno = 0, system will auto assign max cartonno
      SELECT TOP 1 
         @nCartonNo = CartonNo, 
         @cLabelNo = LabelNo, 
         @cLabelLine = LabelLine
      FROM PackDetail WITH (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
         AND SKU = @cSKU
         AND AddWho = 'rdt.' + SUSER_SNAME()
      ORDER BY CartonNo DESC -- max cartonno
   END   

   --V1.1 start FCR-11193: PickDetail Split Logic
   IF ISNULL(@cUCCNo,'') = ''
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Handling PickDetail', @cUCCNo AS UCCNo, @nQty AS PackQty, @cLabelNo AS LabelNo
               , @cFromDropID AS cFromDropID

      DECLARE @nRemainQTY           INT
      DECLARE @nTotalPickQTY        INT
      DECLARE @cPickStatus          NVARCHAR(10)
      DECLARE @cLoopPickDetailKey   NVARCHAR(10)
      DECLARE @nLoopQTY             INT
      DECLARE @cLoopOrderLineNumber NVARCHAR(5)
      DECLARE @cLoopLot             NVARCHAR(10)
      DECLARE @cLoopLoc             NVARCHAR(10)
      DECLARE @cLoopID              NVARCHAR(18)
      DECLARE @cTargetPickDetailKey NVARCHAR(10)
      DECLARE @cNewPickDetailKey    NVARCHAR(10)
      DECLARE @cOperationType       NVARCHAR(10)

      -- Get PickStatus from config
      SET @cPickStatus = rdt.rdtGetConfig(@nFunc, 'PickStatus', @cStorerKey)
      IF @cPickStatus = '0'
         SET @cPickStatus = '5' -- Default to status 5 (picked)

      IF @cPackByFromDropID <> '1' OR ISNULL(@cFromDropID, '') = ''
      BEGIN
         SET @nErrNo = 262630
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END

      -- Pre-validation: Calculate total available PickDetail quantity
      SELECT @nTotalPickQTY = SUM(QTY)
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
        AND OrderKey = @cOrderKey
        AND SKU = @cSKU
        AND DropID = @cFromDropID
        AND Status = @cPickStatus
        AND QTY > 0

      -- Validation: No PickDetail found
      IF @nTotalPickQTY IS NULL
      BEGIN
         SET @nErrNo = 262621
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END

      -- Validation: Pack QTY exceeds available
      IF @nQTY > @nTotalPickQTY
      BEGIN
         SET @nErrNo = 262620
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END

      -- Initialize remaining quantity to process
      SET @nRemainQTY = @nQTY

      -- Main processing loop
      WHILE @nRemainQTY > 0
      BEGIN
         -- Get next PickDetail (smallest QTY first)
         SET @cLoopPickDetailKey = NULL

         SELECT TOP 1
            @cLoopPickDetailKey = PickDetailKey,
            @nLoopQTY = QTY,
            @cLoopOrderLineNumber = OrderLineNumber,
            @cLoopLot = Lot,
            @cLoopLoc = Loc,
            @cLoopID = ID
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
           AND OrderKey = @cOrderKey
           AND SKU = @cSKU
           AND DropID = @cFromDropID
           AND CaseId = '' -- not packed yet
           AND Status = @cPickStatus
           AND QTY > 0
         ORDER BY QTY ASC

         IF @nDebugFlag = 1
            SELECT 'Loop FromDropID PKD', @cLoopPickDetailKey AS LoopPKD, @nLoopQty AS PKDQty

         -- Post-validation: No more PickDetail
         IF @cLoopPickDetailKey IS NULL
         BEGIN
            SET @nErrNo = 262635
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            GOTO RollBackTran
         END

         -- Check if target PickDetail exists (already packed to this LabelNo)
         SET @cTargetPickDetailKey = NULL

         SELECT TOP 1 @cTargetPickDetailKey = PickDetailKey
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
           AND CaseId = @cLabelNo
           AND DropID = @cFromDropID
           AND OrderKey = @cOrderKey
           AND OrderLineNumber = @cLoopOrderLineNumber
           AND Lot = @cLoopLot
           AND SKU = @cSKU
           AND Loc = @cLoopLoc
           AND ID = @cLoopID
           AND Status = @cPickStatus

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
                  SET @nErrNo = 262624
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran
               END CATCH

               UPDATE dbo.PickDetail WITH (ROWLOCK)
               SET QTY = QTY + @nLoopQTY,
                   UOMQty = UOMQty + @nLoopQTY,
                   EditWho = SUSER_SNAME(),
                   EditDate = GETDATE(),
                   TrafficCop = NULL
               WHERE PickDetailKey = @cTargetPickDetailKey
               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 262625
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran
               END
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
                  SET @nErrNo = 262632
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
                     UOMQty = CASE WHEN UOMQty - @nRemainQTY > 0 
                              THEN UOMQty - @nRemainQTY 
                              ELSE 0 END,
                     EditWho = SUSER_SNAME(),
                     EditDate = GETDATE(),
                     TrafficCop = NULL
                  WHERE PickDetailKey = @cLoopPickDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 262633
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran
               END CATCH

               BEGIN TRY
                  UPDATE dbo.PickDetail WITH (ROWLOCK)
                  SET QTY = QTY + @nRemainQTY,
                     UOMQty = UOMQty + @nRemainQTY,
                     EditWho = SUSER_SNAME(),
                     EditDate = GETDATE(),
                     TrafficCop = NULL
                  WHERE PickDetailKey = @cTargetPickDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 262625
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
               UPDATE dbo.PickDetail WITH (ROWLOCK)
               SET QTY = QTY - @nRemainQTY,
                  UOMQty = CASE WHEN UOMQty - @nRemainQTY > 0 
                           THEN UOMQty - @nRemainQTY 
                           ELSE 0 END,
                   EditWho = SUSER_SNAME(),
                   EditDate = GETDATE()
               WHERE PickDetailKey = @cLoopPickDetailKey
               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 262634
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran
               END

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
                  SET @nErrNo = 262622
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
                     StorerKey, SKU, AltSKU, UOM, @nRemainQTY,
                     @nRemainQTY, -- QTY
                     QtyMoved, '0', --trigger restriction, status must be 0
                     DropID,
                     Loc, ID, PackKey, UpdateSource, CartonGroup, CartonType,
                     ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
                     EffectiveDate, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey,
                     Notes,
                     SUSER_SNAME(), GETDATE(), SUSER_SNAME(), GETDATE()
                  FROM dbo.PickDetail WITH (NOLOCK)
                  WHERE PickDetailKey = @cLoopPickDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 262623
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran
               END CATCH

               BEGIN TRY
                  UPDATE dbo.PickDetail WITH (ROWLOCK) 
                  SET Status = @cPickStatus 
                  WHERE PickDetailKey = @cNewPickDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 262631
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
                     SET @nErrNo = 262626
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
            INSERT INTO TRACEINFO (STEP1, STEP2, STEP3, COL1, COL2, COL3, COL4, COL5)
            VALUES (@nRemainQTY, @nLoopQTY, @cOperationType, @cLoopPickDetailKey, ISNULL(@cTargetPickDetailKey,''), @cLabelNo, @cFromDropID, SUSER_SNAME())
         END
      END

      IF @nDebugFlag = 1
         SELECT 'PKD looping finished, clear PKD Qty = 0'

      -- Cleanup: Delete RefKeyLookup for zero-qty PickDetails
      BEGIN TRY
         DELETE FROM dbo.RefKeyLookup
         WHERE PickDetailKey IN (
            SELECT PickDetailKey FROM dbo.PickDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
            AND OrderKey = @cOrderKey
            AND SKU = @cSKU
            AND DropID = @cFromDropID
            AND CaseId = ''
            AND Status = @cPickStatus
            AND QTY = 0
         )
      END TRY
      BEGIN CATCH
         SET @nErrNo = 262628
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END CATCH

      -- Cleanup: Delete zero-qty PickDetails
      BEGIN TRY
         DELETE FROM dbo.PickDetail
         WHERE StorerKey = @cStorerKey
         AND OrderKey = @cOrderKey
         AND SKU = @cSKU
         AND DropID = @cFromDropID
         AND CaseId = ''
         AND Status = @cPickStatus
         AND QTY = 0
      END TRY
      BEGIN CATCH
         SET @nErrNo = 262627
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END CATCH
   END
   --V1.1 FCR-11193 end

   -- Insert PackInfo
   IF @cUCCNo <> ''
   BEGIN
      -- PackInfo
      IF NOT EXISTS (SELECT 1 FROM dbo.PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo)
      BEGIN
         INSERT INTO dbo.PackInfo (PickslipNo, CartonNo, UCCNo, QTY)
         VALUES (@cPickSlipNo, @nCartonNo, @cUCCNo, @nQTY)
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 262606
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPackInfFail
            GOTO RollBackTran
         END
      END
      ELSE
      BEGIN
         UPDATE dbo.PackInfo SET
            UCCNo = @cUCCNo, 
            EditDate = GETDATE(), 
            EditWho = SUSER_SNAME(), 
            TrafficCop = NULL
         WHERE PickSlipNo = @cPickSlipNo
            AND CartonNo = @nCartonNo
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 262607
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDPackInfFail
            GOTO RollBackTran
         END
      END

      -- Mark UCC packed
      IF EXISTS( SELECT 1 FROM UCC WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND UCCNo = @cUCCNo AND Status < '5')
      BEGIN
         UPDATE UCC SET
            Status = '6', 
            EditWho = SUSER_SNAME(), 
            EditDate = GETDATE(), 
            TrafficCop = NULL
         WHERE StorerKey = @cStorerKey 
            AND UCCNo = @cUCCNo
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 262608
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD UCC Fail
            GOTO RollBackTran
         END
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
         SET @nErrNo = 262609
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
            FROM PackSerialNo WITH (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo
               AND StorerKey = @cStorerKey
               AND SKU = @cSKU
               AND SerialNo = @cSerialNo)
         BEGIN
            -- Insert PackSerialNo 
            INSERT INTO PackSerialNo (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, SerialNo, QTY)
            VALUES (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @cSerialNo, @nSerialQTY)
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 262610
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPackSNOFail
               GOTO RollBackTran
            END
         END
         ELSE
         BEGIN
            SET @nErrNo = 262611
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO ady scan
            GOTO RollBackTran
         END

         DELETE rdt.rdtReceiveSerialNoLog 
         WHERE ReceiveSerialNoLogKey = @nReceiveSerialNoLogKey
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 262612
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DEL TmpSN Fail
            GOTO RollBackTran
         END 

         SET @nQTY_Bal = @nQTY_Bal - @nSerialQTY
      END
         
      -- Check fully offset
      IF @nQTY_Bal <> 0
      BEGIN
         SET @nErrNo = 262613
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Offset error 
         GOTO RollBackTran
      END 

      -- Check balance
      IF EXISTS( SELECT 1
         FROM rdt.rdtReceiveSerialNoLog WITH (NOLOCK)
         WHERE Mobile = @nMobile
            AND Func = @nFunc)
      BEGIN
         SET @nErrNo = 262614
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
      FROM PackSerialNo WITH (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
         AND StorerKey = @cStorerKey
         AND SKU = @cSKU
         AND SerialNo = @cSerialNo
      SET @nRowCount = @@ROWCOUNT
      
      -- New serial no
      IF @nRowCount = 0
      BEGIN
         -- Insert PackSerialNo 
         INSERT INTO PackSerialNo (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, SerialNo, QTY)
         VALUES (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @cSerialNo, @nSerialQTY)
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 262615
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS RDSNo Fail
            GOTO RollBackTran
         END
      END
      
      -- Check serial no scanned
      ELSE
      BEGIN
         SET @nErrNo = 262616
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
      
      IF @nPackDetailInfoKey = ''
      BEGIN
         -- Insert PackDetailInfo
         INSERT INTO dbo.PackDetailInfo (
            PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, UserDefine01, UserDefine02, UserDefine03, 
            AddWho, AddDate, EditWho, EditDate)
         VALUES (
            @cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @nQTY, @cPackData1, @cPackData2, @cPackData3, 
            'rdt.' + SUSER_SNAME(), GETDATE(), 'rdt.' + SUSER_SNAME(), GETDATE())
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 262617
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PDInfoFail
            GOTO RollBackTran
         END
      END
      ELSE
      BEGIN
         -- Update PackDetailInfo
         UPDATE dbo.PackDetailInfo SET   
            QTY = QTY + @nQTY, 
            EditWho = 'rdt.' + SUSER_SNAME(), 
            EditDate = GETDATE(), 
            ArchiveCop = NULL
         WHERE PackDetailInfoKey = @nPackDetailInfoKey
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 262618
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PDInfoFail
            GOTO RollBackTran
         END
      END
   END   

   RDT_EVENT_LOG:
   --YeeKung      
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

   COMMIT TRAN rdt_838ConfirmSP30
   GOTO Quit

RollBackTran:
BEGIN
   ROLLBACK TRAN rdt_838ConfirmSP30 -- Only rollback change made here
   IF @cNewCarton = 'Y'
   BEGIN
      SET @nCartonNo = 0
      SET @cLabelNo = ''
   END
END

Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838ConfirmSP30 TO NSQL
GO
