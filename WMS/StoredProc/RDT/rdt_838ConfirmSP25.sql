SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_838ConfirmSP25                                  */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: HILLSAU Pack confirm update labelno to caseid               */
/*                                                                      */
/* Date       Rev  Author      Purposes                                 */
/* 2025-03-19 1.0  YWA059      FCR-2495 for HillSAU Pack confirm        */
/* 2025-04-01 1.1.0 YWA059     UWP-32214 Merge Code                     */
/************************************************************************/

CREATE OR ALTER   PROC [RDT].[rdt_838ConfirmSP25] (
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
   ,@nUseStandard    INT = 0
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cSQL        NVARCHAR(MAX)
   DECLARE @cSQLParam   NVARCHAR(MAX)

   DECLARE @bSuccess    INT
   DECLARE @cLabelLine  NVARCHAR( 5)
   DECLARE @cNewLine    NVARCHAR( 1)
   DECLARE @cNewCarton  NVARCHAR( 1)
   DECLARE @cDropID     NVARCHAR( 20) = ''
   DECLARE @cRefNo      NVARCHAR( 20) = ''
   DECLARE @cRefNo2     NVARCHAR( 30) = ''
   DECLARE @cUPC        NVARCHAR( 30) = ''
   DECLARE @cLoadKey    NVARCHAR( 10) = ''
   DECLARE @cOrderKey   NVARCHAR( 10) = ''
   DECLARE @cPickDetailKey       NVARCHAR( 20) = ''
   DECLARE @cGenLabelNo_SP       NVARCHAR( 20)
   DECLARE @cPackDetailCartonID  NVARCHAR( 20)
   DECLARE @LinkSNoOrdDet        NVARCHAR( 20)
   DECLARE @cPackByFromDropID    NVARCHAR( 1)


   -- Handling transaction
   DECLARE @nTranCount  INT

   SET @nTranCount = @@TRANCOUNT

   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_838ConfirmSP25 -- For rollback or commit only our own transaction

   -- PackHeader
   IF NOT EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickslipNo = @cPickslipNo)
   BEGIN
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
         SET @nErrNo = 219651
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPHdrFail
         GOTO RollBackTran
      END
   END

   --Check if over pack per batchno begin
   IF(@nStep <> 99 AND @cPackData1 <> '')
   BEGIN
      DECLARE @sum_picked_qty      INT
      DECLARE @totalpacked_qty     INT
      DECLARE @sum_qty_notpick     INT
      DECLARE @sum_qty_shortpick   INT

      SELECT @sum_picked_qty = SUM(CASE WHEN pkd.Status = '5' THEN Qty ELSE 0 END)
            ,@sum_qty_notpick = SUM(CASE WHEN pkd.Status = '0' THEN Qty ELSE 0 END)
            ,@sum_qty_shortpick = SUM(CASE WHEN pkd.Status = '4' THEN Qty ELSE 0 END)
      FROM dbo.PICKDETAIL pkd WITH (NOLOCK)
      INNER JOIN dbo.LOTATTRIBUTE lta WITH (NOLOCK)
         ON pkd.Lot = lta.Lot 
         AND pkd.Storerkey = lta.StorerKey
         AND pkd.Sku = lta.Sku
      WHERE pkd.PickSlipNo = @cPickSlipNo
         AND pkd.Storerkey = @cStorerKey
         AND pkd.Sku = @cSKU
         AND lta.Lottable01 = @cPackData1
         AND pkd.Qty > 0

      IF (ISNULL(@sum_picked_qty,0) = 0 AND ISNULL(@sum_qty_notpick,0) = 0 AND ISNULL(@sum_qty_shortpick,0) = 0)
      BEGIN
         SET @nErrNo = 235801
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'Invalid BatchNo'
         GOTO RollBackTran
      END
      
      SELECT @totalpacked_qty = SUM(Qty)
      FROM dbo.PackDetailInfo WITH (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
         AND Storerkey = @cStorerKey
         AND Sku = @cSKU
         AND UserDefine01 = @cPackData1

      IF (@sum_picked_qty - ISNULL(@totalpacked_qty,0) < @nQTY)
      BEGIN
         SET @nErrNo = 219954
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --over pack
         GOTO RollBackTran
      END

      IF (@sum_picked_qty = ISNULL(@totalpacked_qty,0))
      BEGIN
         IF (ISNULL(@sum_qty_notpick,0) > 0)
         BEGIN
            SET @nErrNo = 235802
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'Not picked'
            GOTO RollBackTran
         END
         IF (ISNULL(@sum_qty_shortpick,0) > 0)
         BEGIN
            SET @nErrNo = 235803
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'Short picked'
            GOTO RollBackTran
         END
      END
   END
   --Check if over pack per batchno end

   -- Storer configure
   SET @LinkSNoOrdDet = rdt.rdtGetConfig( @nFunc, 'LinkSNoOrdDet', @cStorerKey)
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
               SET @nErrNo = 219652
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenLabelNoFail
               GOTO RollBackTran
            END
         END
      END

      IF @cLabelNo = ''
      BEGIN
         SET @nErrNo = 219653
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

   IF @cNewLine = 'Y'
   BEGIN
      -- Insert PackDetail
      INSERT INTO dbo.PackDetail
         (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY,
         DropID, RefNo, RefNo2, UPC,
         AddWho, AddDate, EditWho, EditDate)
      VALUES
         (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @nQTY,
         @cDropID, @cRefNo, @cRefNo2, @cUPC,
         'rdt.' + SUSER_SNAME(), GETDATE(), 'rdt.' + SUSER_SNAME(), GETDATE())

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 219654
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPackDtlFail
         GOTO RollBackTran
      END
   END
   ELSE
   BEGIN
      -- Update Packdetail
      UPDATE dbo.PackDetail WITH (ROWLOCK) 
      SET
         SKU = @cSKU,
         QTY = QTY + @nQTY,
         EditWho = 'rdt.' + SUSER_SNAME(),
         EditDate = GETDATE(),
         ArchiveCop = NULL
      WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND LabelNo = @cLabelNo
         AND LabelLine = @cLabelLine

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 219655
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPackDtlFail
         GOTO RollBackTran
      END
   END

   DECLARE @nQtyPicked INT
   DECLARE @loop_PickDetailKey NVARCHAR(20)
   DECLARE @loop_lot NVARCHAR(10)
   DECLARE @loop_loc NVARCHAR(10)
   DECLARE @loop_orderline NVARCHAR(10)
   DECLARE @loop_orderkey NVARCHAR(10)
   DECLARE @loop_uom NVARCHAR(10)
   DECLARE @loop_uomqty INT
   DECLARE @Input_Qty INT

   SET @Input_Qty = @nQTY

   WHILE(@nStep <> 99 AND @cPackData1 <> '' AND @Input_Qty >0)
   BEGIN
      SELECT top 1
         @loop_PickDetailKey = PD.PickDetailKey,
         @cFromDropID    = PD.DropID,
         @loop_lot       = PD.Lot,
         @loop_loc       = PD.Loc,
         @loop_orderkey  = PD.OrderKey,
         @loop_orderline = PD.OrderLineNumber,
         @loop_uom       = PD.UOM,
         @loop_uomqty    = PD.UOMQty,
         @nQtyPicked     = PD.qty
      FROM dbo.PickDetail PD WITH(NOLOCK)
      INNER JOIN dbo.LotAttribute LA WITH(NOLOCK) ON (PD.LOT = LA.LOT)
      LEFT JOIN dbo.PACKDETAIL PackD WITH(NOLOCK) ON (PackD.PickSlipNo = PD.PickSlipNo AND PACKd.LabelNo = PD.CaseID AND PackD.SKU = PD.Sku)
      WHERE PD.StorerKey = @cStorerKey
        AND PD.SKU = @cSKU
        AND ISNULL(LA.Lottable01,'') = @cPackData1
        AND PD.PickSlipNo = @cPickSlipNo
        AND ISNULL(PackD.LabelNo,'') = '' -- Not Packed
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

      --Check if exist same LabelNo, orderkey, sku, lot and loc in PICKDETAIL
      SELECT TOP 1 @packed_PickDetailKey = PickDetailKey
      FROM dbo.PICKDETAIL WITH(NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND PickSlipNo = @cPickSlipNo
         AND SKU = @cSKU
         AND CaseID = @cLabelNo
         AND OrderKey = @loop_orderkey
         AND Lot = @loop_lot
         AND Loc = @loop_loc
         AND OrderLineNumber = @loop_orderline
         AND UOM = @loop_uom
         AND UOMQty = @loop_uomqty

      IF ISNULL(@packed_PickDetailKey,'') <> ''
      BEGIN
         UPDATE dbo.PICKDETAIL WITH (ROWLOCK)
         SET Qty = (CASE WHEN @n_remainqty<0 THEN 0 ELSE @n_remainqty END)
            ,TrafficCop = NULL
         WHERE Pickdetailkey = @loop_PickDetailKey

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 219951
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
            GOTO RollBackTran
         END

         --decrease qty from this line
         IF @n_remainqty<= 0
         BEGIN
            DELETE FROM PICKDETAIL WHERE Pickdetailkey = @loop_PickDetailKey AND Qty = 0
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 219952
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO RollBackTran
            END
         END

         --Merge qty
         UPDATE dbo.PICKDETAIL WITH (ROWLOCK)
         SET Qty = Qty + @loop_qty
            ,TrafficCop = NULL
         WHERE Pickdetailkey = @packed_PickDetailKey

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 219953
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
            GOTO RollBackTran
         END
      END

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
            UOMQty, -- no need change
            @n_remainqty, QtyMoved, Status,
            PICKDETAIL.DropId, Loc, ID, PackKey, UpdateSource, CartonGroup, CartonType,
            ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod,
            WaveKey, EffectiveDate, '9', ShipFlag, PickSlipNo, Channel_ID
            , TaskDetailKey
         FROM dbo.PICKDETAIL WITH(NOLOCK)
         WHERE PickdetailKey = @loop_PickDetailKey

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 234165
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
            GOTO RollBackTran
         END
      END

      --SPLIT PICK
      IF ISNULL(@packed_PickDetailKey,'') = '' AND @Input_Qty > 0
      BEGIN
         UPDATE dbo.PICKDETAIL WITH (ROWLOCK)
         SET 
            PICKDETAIL.CaseID = @cLabelNo
            ,Qty = @loop_qty
            ,TrafficCop = NULL
         WHERE Pickdetailkey = @loop_PickDetailKey

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 234166
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
            GOTO RollBackTran
         END
      END

      SET @Input_Qty = @Input_Qty - @nQtyPicked
      IF (@n_remainqty >= 0 OR @Input_Qty <= 0)
         BREAK
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
            SET @nErrNo = 219656
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPackInfFail
            GOTO RollBackTran
         END
      END
      ELSE
      BEGIN
         UPDATE dbo.PackInfo WITH(ROWLOCK)
         SET
            UCCNo = @cUCCNo,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME(),
            TrafficCop = NULL
         WHERE PickSlipNo = @cPickSlipNo
            AND CartonNo = @nCartonNo

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 219657
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDPackInfFail
            GOTO RollBackTran
         END
      END

      -- Mark UCC packed
      IF EXISTS( SELECT 1 FROM dbo.UCC WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND UCCNo = @cUCCNo AND Status < '5')
      BEGIN
         UPDATE dbo.UCC SET
            Status = '6',
            EditWho = SUSER_SNAME(),
            EditDate = GETDATE(),
            TrafficCop = NULL
         WHERE StorerKey = @cStorerKey
            AND UCCNo = @cUCCNo

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 219658
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
         SET @nErrNo = 219659
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
            IF @LinkSNoOrdDet = '1'
            BEGIN
               SELECT @cOrderKey = OrderKey, @cLoadKey = ExternOrderKey
               FROM dbo.PickHeader WITH (NOLOCK)
               WHERE PickHeaderKey = @cPickSlipNo

               IF ISNULL(@cOrderKey, '') <> ''
               BEGIN
                  SELECT
                     @cPickDetailKey = ISNULL(PD.PickDetailKey,'')
                  FROM dbo.PickHeader PH WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PH.OrderKey = PD.OrderKey)
                  LEFT OUTER JOIN
                     (SELECT COUNT(1) AS SNCnt,PickDetailKey
                     FROM dbo.PackSerialNo PSN WITH(NOLOCK)
                     WHERE PSN.PickSlipNo = @cPickSlipNo
                     AND PSN.StorerKey = @cStorerKey
                     AND PSN.sku = @cSku
                     GROUP BY PSN.PickDetailKey) pack
                  ON PD.PickDetailKey = pack.PickDetailKey
                  WHERE PH.PickHeaderKey = @cPickSlipNo
                     AND PD.Status = '5'
                     AND PD.StorerKey  = @cStorerKey
                     AND PD.Qty > ISNULL(SNCnt,0)
                     AND PD.SKU = @cSKU
               END
               ELSE IF ISNULL(@cLoadKey, '') <> ''
               BEGIN
                  SELECT
                     @cPickDetailKey = ISNULL(PD.PickDetailKey,'')
                  FROM dbo.PickHeader PH WITH (NOLOCK)
                  JOIN dbo.LoadPlanDetail LPD WITH (NOLOCK) ON PH.ExternOrderKey = LPD.LoadKey
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (LPD.OrderKey = PD.OrderKey)
                  LEFT OUTER JOIN
                     (SELECT COUNT(1) AS SNCnt,PickDetailKey
                     FROM dbo.PackSerialNo PSN WITH(NOLOCK)
                     WHERE PSN.PickSlipNo = @cPickSlipNo
                     AND PSN.StorerKey = @cStorerKey
                     AND PSN.sku = @cSku
                     GROUP BY PSN.PickDetailKey) pack
                  ON PD.PickDetailKey = pack.PickDetailKey
                  WHERE PH.PickHeaderKey = @cPickSlipNo
                     AND PD.Status = '5'
                     AND PD.StorerKey = @cStorerKey
                     AND PD.Qty > ISNULL(SNCnt,0)
                     AND PD.SKU = @cSKU
               END
               ELSE
               BEGIN
                  SELECT
                     @cPickDetailKey = ISNULL(PD.PickDetailKey,'')
                  FROM dbo.PickDetail PD WITH (NOLOCK)
                  LEFT OUTER JOIN
                     (SELECT COUNT(1) AS SNCnt,PickDetailKey
                     FROM dbo.PackSerialNo PSN WITH(NOLOCK)
                     WHERE PSN.PickSlipNo = @cPickSlipNo
                     AND PSN.StorerKey = @cStorerKey
                     AND PSN.sku = @cSku
                     GROUP BY PSN.PickDetailKey) pack
                  ON PD.PickDetailKey = pack.PickDetailKey
                  WHERE PD.PickSlipNo = @cPickSlipNo
                     AND PD.Status = '5'
                     AND PD.StorerKey  = @cStorerKey
                     AND PD.Qty > ISNULL(SNCnt,0)
                     AND PD.SKU = @cSKU
               END
            END

            IF ISNULL(@cPickDetailKey,'') = ''
            BEGIN
               SET @nErrNo = 219669
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --pickdetail not found
               GOTO RollBackTran
            END

            -- Insert PackSerialNo
            INSERT INTO dbo.PackSerialNo (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, SerialNo, QTY, PickDetailKey)
            VALUES (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @cSerialNo, @nSerialQTY, @cPickDetailKey)
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 219660
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPackSNOFail
               GOTO RollBackTran
            END
         END
         ELSE
         BEGIN
            SET @nErrNo = 219661
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO ady scan
            GOTO RollBackTran
         END

         DELETE rdt.rdtReceiveSerialNoLog
         WHERE ReceiveSerialNoLogKey = @nReceiveSerialNoLogKey

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 219662
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DEL TmpSN Fail
            GOTO RollBackTran
         END

         SET @nQTY_Bal = @nQTY_Bal - @nSerialQTY
      END

      -- Check fully offset
      IF @nQTY_Bal <> 0
      BEGIN
         SET @nErrNo = 219663
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Offset error
         GOTO RollBackTran
      END

      -- Check balance
      IF EXISTS( SELECT 1
         FROM rdt.rdtReceiveSerialNoLog WITH (NOLOCK)
         WHERE Mobile = @nMobile
            AND Func = @nFunc)
      BEGIN
         SET @nErrNo = 219664
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
         IF @LinkSNoOrdDet = '1'
         BEGIN
            SELECT @cOrderKey = OrderKey, @cLoadKey = ExternOrderKey
            FROM dbo.PickHeader WITH (NOLOCK)
            WHERE PickHeaderKey = @cPickSlipNo

            IF ISNULL(@cOrderKey, '') <> ''
            BEGIN
               SELECT
                  @cPickDetailKey = ISNULL(PD.PickDetailKey,'')
               FROM dbo.PickHeader PH WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PH.OrderKey = PD.OrderKey)
                  LEFT OUTER JOIN
                  (SELECT COUNT(1) AS SNCnt,PickDetailKey
                  FROM dbo.PackSerialNo PSN WITH(NOLOCK)
                  WHERE PSN.PickSlipNo = @cPickSlipNo
                  AND PSN.StorerKey = @cStorerKey
                  AND PSN.sku = @cSku
                  GROUP BY PSN.PickDetailKey) pack
               ON PD.PickDetailKey = pack.PickDetailKey
               WHERE PH.PickHeaderKey = @cPickSlipNo
                  AND PD.Status = '5'
                  AND PD.StorerKey  = @cStorerKey
                  AND PD.Qty > ISNULL(SNCnt,0)
                  AND PD.SKU = @cSKU
            END
            ELSE IF ISNULL(@cLoadKey, '') <> ''
            BEGIN
               SELECT
                  @cPickDetailKey = ISNULL(PD.PickDetailKey,'')
               FROM dbo.PickHeader PH WITH (NOLOCK)
               JOIN dbo.LoadPlanDetail LPD WITH (NOLOCK) ON PH.ExternOrderKey = LPD.LoadKey
               JOIN dbo.PickDetail PD WITH (NOLOCK) ON (LPD.OrderKey = PD.OrderKey)
               LEFT OUTER JOIN
                  (SELECT COUNT(1) AS SNCnt,PickDetailKey
                  FROM dbo.PackSerialNo PSN WITH(NOLOCK)
                  WHERE PSN.PickSlipNo = @cPickSlipNo
                  AND PSN.StorerKey = @cStorerKey
                  AND PSN.sku = @cSku
                  GROUP BY PSN.PickDetailKey) pack
               ON PD.PickDetailKey = pack.PickDetailKey
               WHERE PH.PickHeaderKey = @cPickSlipNo
                  AND PD.Status = '5'
                  AND PD.StorerKey  = @cStorerKey
                  AND PD.Qty > ISNULL(SNCnt,0)
                  AND PD.SKU = @cSKU
            END
            else
            BEGIN
               SELECT
               @cPickDetailKey = ISNULL(PD.PickDetailKey,'')
               FROM dbo.PickDetail PD WITH (NOLOCK)
               LEFT OUTER JOIN
                  (SELECT COUNT(1) AS SNCnt,PickDetailKey
                  FROM dbo.PackSerialNo PSN WITH(NOLOCK)
                  WHERE PSN.PickSlipNo = @cPickSlipNo
                  AND PSN.StorerKey = @cStorerKey
                  AND PSN.sku = @cSku
                  GROUP BY PSN.PickDetailKey) pack
               ON PD.PickDetailKey = pack.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.Status = '5'
                  AND PD.StorerKey  = @cStorerKey
                  AND PD.Qty > ISNULL(SNCnt,0)
                  AND PD.SKU = @cSKU
            END
         END

         IF ISNULL(@cPickDetailKey,'') = ''
         BEGIN
            SET @nErrNo = 219670
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --pickdetail not found
            GOTO RollBackTran
         END

         -- Insert PackSerialNo
         INSERT INTO dbo.PackSerialNo (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, SerialNo, QTY, PickDetailKey)
         VALUES (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @cSerialNo, @nSerialQTY, @cPickDetailKey)

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 219665
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS RDSNo Fail
            GOTO RollBackTran
         END
      END

      -- Check serial no scanned
      ELSE
      BEGIN
         SET @nErrNo = 219666
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
            SET @nErrNo = 219667
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PDInfoFail
            GOTO RollBackTran
         END
      END
      ELSE
      BEGIN
         -- Update PackDetailInfo
         UPDATE dbo.PackDetailInfo WITH(ROWLOCK) 
         SET
            QTY = QTY + @nQTY,
            EditWho = 'rdt.' + SUSER_SNAME(),
            EditDate = GETDATE(),
            ArchiveCop = NULL
         WHERE PackDetailInfoKey = @nPackDetailInfoKey

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 219668
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PDInfoFail
            GOTO RollBackTran
         END
      END
   END

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

   COMMIT TRAN rdt_838ConfirmSP25
   GOTO Quit

RollBackTran:
BEGIN
   ROLLBACK TRAN rdt_838ConfirmSP25 -- Only rollback change made here
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

GRANT EXECUTE ON  [RDT].[rdt_838ConfirmSP25] TO [NSQL]
GO