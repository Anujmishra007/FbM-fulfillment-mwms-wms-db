SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_838ConfirmSP28                                        */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date       Rev  Author      Purposes                                       */
/* Jun23 2025 1.0  Cuize       FCR-4649                                       */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838ConfirmSP28 (
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

   DECLARE  @nTranCount       INT,
            @cUserName        NVARCHAR( 18),
            @cWaveKey         NVARCHAR(10)

   SET @nTranCount = @@TRANCOUNT

   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_838ConfirmSP28 -- For rollback or commit only our own transaction

   -- Standard confirm
   EXEC rdt.rdt_Pack_Confirm
       @nMobile        = @nMobile
      ,@nFunc          = @nFunc
      ,@cLangCode      = @cLangCode
      ,@nStep          = @nStep
      ,@nInputKey      = @nInputKey
      ,@cFacility      = @cFacility
      ,@cStorerKey     = @cStorerKey
      ,@cPickSlipNo    = @cPickSlipNo
      ,@cFromDropID    = @cFromDropID
      ,@cSKU           = @cSKU
      ,@nQTY           = @nQTY
      ,@cUCCNo         = @cUCCNo
      ,@cSerialNo      = @cSerialNo
      ,@nSerialQTY     = @nSerialQTY
      ,@cPackDtlRefNo  = @cPackDtlRefNo
      ,@cPackDtlRefNo2 = @cPackDtlRefNo2
      ,@cPackDtlUPC    = @cPackDtlUPC
      ,@cPackDtlDropID = @cPackDtlDropID
      ,@nCartonNo      = @nCartonNo      OUTPUT
      ,@cLabelNo       = @cLabelNo       OUTPUT
      ,@nErrNo         = @nErrNo         OUTPUT
      ,@cErrMsg        = @cErrMsg        OUTPUT
      ,@nBulkSNO       = @nBulkSNO
      ,@nBulkSNOQTY    = @nBulkSNOQTY
      ,@cPackData1     = @cPackData1
      ,@cPackData2     = @cPackData2
      ,@cPackData3     = @cPackData3
      ,@nUseStandard   = 1 -- Force use back standard logic, otherwise infinite loop

   IF @@ERROR <> 0
   BEGIN
      GOTO RollBackTran
   END

   DECLARE @cLoadKey    NVARCHAR( 10)
   DECLARE @cOrderKey   NVARCHAR( 10)

   SET @cLoadKey = ''
   SET @cOrderKey = ''

   --Scan dropID
   SELECT TOP 1
      @cOrderKey = Orderkey
   FROM dbo.pickdetail WITH (NOLOCK)
   WHERE Storerkey = @cStorerKey
   AND SKU = @cSKU
   AND DropID = @cFromDropID


   --UPDATE Pickdetail.OrderKey to Packdetail.Refno2
   UPDATE dbo.Packdetail
      SET RefNo2 = @cOrderKey,
          EditDate = GETDATE(),
          EditWho = 'rdt.' + SUSER_SNAME()
   WHERE LabelNo = @cLabelNo
      AND SKU = @cSKU
      AND StorerKey = @cStorerKey
   IF @@ERROR <> 0
   BEGIN
      SET @nErrNo = 240902
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PackDetailFail
      GOTO RollBackTran
   END


   DECLARE @nQtyPicked INT
   DECLARE @loop_PickDetailKey NVARCHAR(20)
   DECLARE @loop_lot NVARCHAR(10)
   DECLARE @loop_loc NVARCHAR(10)
   DECLARE @loop_orderline NVARCHAR(10)
   DECLARE @loop_uom NVARCHAR(10)
   DECLARE @loop_uomqty INT
   DECLARE @Input_Qty INT
   DECLARE @bSuccess INT

   SET @Input_Qty = @nQTY

   WHILE( @Input_Qty >0 )
   BEGIN
      SELECT top 1
         @loop_PickDetailKey = PD.PickDetailKey,
         --@cFromDropID    = PD.DropID,
         @loop_lot       = PD.Lot,
         @loop_loc       = PD.Loc,
         @loop_orderline = PD.OrderLineNumber,
         @loop_uom       = PD.UOM,
         @loop_uomqty    = PD.UOMQty,
         @nQtyPicked     = PD.qty
      FROM dbo.PickDetail PD WITH(NOLOCK)
         --LEFT JOIN dbo.PACKDETAIL PackD WITH(NOLOCK) ON (PackD.LabelNo = PD.DROPID AND PackD.SKU = PD.Sku AND PackD.RefNo2 = PD.OrderKey)
      WHERE PD.StorerKey = @cStorerKey
        AND PD.SKU = @cSKU
        AND PD.Orderkey = @cOrderKey
        AND PD.dropid = @cFromDropID
        --AND ISNULL(PackD.LabelNo,'') = '' -- Not Packed
        AND PD.status = 5
        AND PD.qty > 0
      ORDER BY PD.UOM DESC,(CASE WHEN PD.qty-@Input_Qty>=0 THEN PD.qty-@Input_Qty ELSE 99999+@Input_Qty-PD.qty END)

      IF @@ROWCOUNT = 0
         BREAK

      --@loop_qty is actual packed qty for this line
      DECLARE @loop_qty INT

      IF @nQtyPicked <= @Input_Qty
         SET @loop_qty = @nQtyPicked
      ELSE
         SET @loop_qty = @Input_Qty

      DECLARE @c_newpickdetailkey        NVARCHAR(10)
      DECLARE @n_remainqty               INT = 0
      DECLARE @packed_PickDetailKey NVARCHAR(10)

      SET @n_remainqty = @nQtyPicked - @Input_Qty

      -- Only use option 'NEW'
--       --Check if exist same LabelNo, orderkey, sku, lot and loc in PICKDETAIL
--       SELECT TOP 1 @packed_PickDetailKey = PickDetailKey
--       FROM dbo.PICKDETAIL WITH(NOLOCK)
--       WHERE StorerKey = @cStorerKey
--         AND OrderKey = @cOrderkey
--         AND SKU = @cSKU
--         AND DROPID = @cLabelNo --packed @cLabelNo
--         AND Lot = @loop_lot
--         AND Loc = @loop_loc
--         AND OrderLineNumber = @loop_orderline
--         AND UOM = @loop_uom
--         AND UOMQty = @loop_uomqty
--
--       IF ISNULL(@packed_PickDetailKey,'') <> ''
--       BEGIN
--          UPDATE dbo.PICKDETAIL WITH (ROWLOCK)
--          SET Qty = (CASE WHEN @n_remainqty<0 THEN 0 ELSE @n_remainqty END)
--            ,TrafficCop = NULL
--          WHERE Pickdetailkey = @loop_PickDetailKey
--
--          IF @@ERROR <> 0
--          BEGIN
--             SET @nErrNo = 219951
--             SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
--             GOTO RollBackTran
--          END
--
--          --decrease qty from this line
--          IF @n_remainqty<= 0
--          BEGIN
--             DELETE FROM PICKDETAIL WHERE Pickdetailkey = @loop_PickDetailKey AND Qty = 0
--             IF @@ERROR <> 0
--             BEGIN
--                SET @nErrNo = 219952
--                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
--                GOTO RollBackTran
--             END
--          END
--
--          --Merge qty
--          UPDATE dbo.PICKDETAIL WITH (ROWLOCK)
--          SET Qty = Qty + @loop_qty
--            ,TrafficCop = NULL
--          WHERE Pickdetailkey = @packed_PickDetailKey
--
--          IF @@ERROR <> 0
--          BEGIN
--             SET @nErrNo = 219953
--             SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
--             GOTO RollBackTran
--          END
--       END

      IF @n_remainqty > 0 AND ISNULL(@packed_PickDetailKey,'') = ''
      BEGIN
         EXECUTE nspg_GetKey
              'PICKDETAILKEY',
              10,
              @c_newpickdetailkey OUTPUT,
              @bSuccess OUTPUT,
              @nErrNo OUTPUT,
              @cErrMsg OUTPUT

         IF NOT @bSuccess = 1
         BEGIN
            GOTO RollBackTran
         END

         INSERT dbo.PICKDETAIL
         (PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot,
          Storerkey, Sku, AltSku, UOM, UOMQty, Qty, QtyMoved, Status,
          DropID, Loc, ID, PackKey, UpdateSource, CartonGroup, CartonType,
          ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod,
          WaveKey, EffectiveDate, OptimizeCop, ShipFlag, PickSlipNo, Channel_ID, TaskDetailKey
         )
         SELECT @c_newpickdetailkey,PICKDETAIL.CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot,
            Storerkey, Sku, AltSku, UOM,
            @n_remainqty,
            @n_remainqty, QtyMoved, Status,
            PICKDETAIL.DropId, Loc, ID, PackKey, UpdateSource, CartonGroup, CartonType,
            ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod,
            WaveKey, EffectiveDate, '9', ShipFlag, PickSlipNo, Channel_ID
            ,TaskDetailKey
         FROM dbo.PICKDETAIL WITH(NOLOCK)
         WHERE PickdetailKey = @loop_PickDetailKey

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 240901
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
            GOTO RollBackTran
         END
      END

      --SPLIT PICK
      IF ISNULL(@packed_PickDetailKey,'') = '' AND @Input_Qty > 0
      BEGIN
         UPDATE dbo.PICKDETAIL WITH (ROWLOCK)
         SET
            PICKDETAIL.DROPID = @cLabelNo
           ,Qty = @loop_qty
           ,UOMQty = @loop_qty
           ,TrafficCop = NULL
         WHERE Pickdetailkey = @loop_PickDetailKey

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 240901
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PickDetailFail
            GOTO RollBackTran
         END
      END

      SET @Input_Qty = @Input_Qty - @nQtyPicked
      IF (@n_remainqty >= 0 OR @Input_Qty <= 0)
         BREAK
   END


   SELECT  @cUserName = UserName
   FROM   RDT.RDTMobrec (NOLOCK)
   WHERE  Mobile = @nMobile

   SELECT TOP 1 @cLoadKey = ISNULL(Loadkey,'')
      FROM LOADPLANDETAIL WITH(NOLOCK)
   WHERE OrderKey = @cOrderKey

   SELECT TOP 1 @cWavekey =ISNULL( Wavekey,'')
      FROM WAVEDETAIL WITH(NOLOCK)
   WHERE OrderKey = @cOrderKey


   EXEC RDT.rdt_STD_EventLog
        @cActionType    = '8', -- Packing
        @cUserID        = @cUserName,
        @nMobileNo      = @nMobile,
        @nFunctionID    = 838,
        @cFacility      = @cFacility,
        @cStorerKey     = @cStorerkey,
        @cSKU           = @cSKU,
        @nQTY           = @nQTY,
        @cOrderKey      = @cOrderKey,
        @cLoadKey        = @cLoadKey,
        @cPickSlipNo     = @cPickSlipNo,
        @cDropID         = @cFromDropID,
        @cWaveKey        = @cWavekey,
        @cLabelNo        = @cLabelNo,
        @nCartonNo      = @nCartonNo



   COMMIT TRAN rdt_838ConfirmSP28
   GOTO Quit

   RollBackTran:
   BEGIN
      ROLLBACK TRAN rdt_838ConfirmSP28 -- Only rollback change made here
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

GRANT EXECUTE ON RDT.rdt_838ConfirmSP28 TO NSQL
GO
