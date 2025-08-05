SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: rdt_835PackConfirm02                                */
/* Copyright      : MAERSK                                              */
/*                                                                      */
/* Purpose: Pick and pack confirm                                       */
/*                                                                      */
/* Called from: rdtfnc_Pallet_Pack                                      */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2025-05-07  1.0  James       FCR-3769. Created                       */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_835PackConfirm02] (
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @cStorerKey    NVARCHAR( 15),
   @cFacility     NVARCHAR( 5),
   @tPackCfm      VariableTable READONLY,
   @cPrintPackList  NVARCHAR( 1) OUTPUT,
   @nErrNo        INT            OUTPUT,
   @cErrMsg       NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount     INT
   DECLARE @cZone          NVARCHAR( 10)
   DECLARE @cPickDetailKey NVARCHAR( 10)
   DECLARE @cLoadKey       NVARCHAR( 10)
   DECLARE @nQTY_PD        INT
   DECLARE @bSuccess       INT
   DECLARE @n_err          INT
   DECLARE @c_errmsg       NVARCHAR( 20)
   DECLARE @cUserName      NVARCHAR( 18)
   DECLARE @cShipperKey    NVARCHAR( 15)
   DECLARE @cPickConfirmStatus NVARCHAR( 1)
   DECLARE @cSQL           NVARCHAR( MAX)
   DECLARE @cSQLParam      NVARCHAR( MAX)
   DECLARE @cRoute         NVARCHAR( 20)
   DECLARE @cOrderRefNo    NVARCHAR( 18)
   DECLARE @cConsigneekey  NVARCHAR( 15)
   DECLARE @cLot           NVARCHAR( 10)
   DECLARE @cLabelNo       NVARCHAR( 20)
   DECLARE @nCartonNo      INT
   DECLARE @cLabelLine     NVARCHAR( 5)
   DECLARE @cShipLabel     NVARCHAR( 10)
   DECLARE @cDelNotes      NVARCHAR( 10)
   DECLARE @cPaperPrinter  NVARCHAR( 10)
   DECLARE @cLabelPrinter  NVARCHAR( 10)
   DECLARE @cPalletID      NVARCHAR( 20)
   DECLARE @cCartonCount   NVARCHAR( 5)
   DECLARE @cPackByPickDetailDropID NVARCHAR( 1)
   DECLARE @cPackByPickDetailID     NVARCHAR( 1)
   DECLARE @cSKU           NVARCHAR( 20)
   DECLARE @cDropID        NVARCHAR( 20)
   DECLARE @nStep          INT
   DECLARE @nInputKey      INT
   DECLARE @nQty           INT
   DECLARE @nSum_Picked    INT
   DECLARE @nSum_Packed    INT
   DECLARE @nSum_PickDQty  INT
   DECLARE @nSum_PackDQty  INT
   DECLARE @cGenLabelNo_SP NVARCHAR( 20)
   DECLARE @cUpdatePickDetail NVARCHAR( 1)
   DECLARE @cGenPalletDetail  NVARCHAR( 1)
   DECLARE @cGenPackInfo   NVARCHAR( 1)
   DECLARE @cCartonType    NVARCHAR( 10)
   DECLARE @cPackConfirm   NVARCHAR(1)
   DECLARE @nPickQty       INT
   DECLARE @nCartonWeight  FLOAT
   DECLARE @nCartonCube    FLOAT
   DECLARE @tGenLabelNo    VARIABLETABLE
   DECLARE @cCartonCountCfg   NVARCHAR(1)
   DECLARE @cUCCNo         NVARCHAR( 20)
   DECLARE @cUCC_SKU       NVARCHAR( 20)
   DECLARE @nUCC_QTY       INT
   DECLARE @cCurLabelNo    NVARCHAR( 20)
   DECLARE @cUpdPalletDetailLoc  NVARCHAR( 10)
   DECLARE @cLoc           NVARCHAR( 10)
   DECLARE @cPD_SKU        NVARCHAR( 20)
   DECLARE @nPD_Qty        INT
   DECLARE @cSerialNo      NVARCHAR( 50)
   DECLARE @nSNQty         INT
   DECLARE @curPD          CURSOR
   DECLARE @curPDSKU       CURSOR
   DECLARE @curPrint       CURSOR
   DECLARE @curPackDtl     CURSOR
   DECLARE @curSN          CURSOR
   DECLARE @cSerialNoKey   NVARCHAR( 10)
   DECLARE @cSerialNoCapture  NVARCHAR( 1)

   SET @nErrNo = 0
   SET @cPrintPackList = 'N'
   SET @cPackConfirm = ''

   SELECT @cLabelPrinter = Printer,
          @cPaperPrinter = Printer_Paper,
          @cUserName = UserName
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   DECLARE @tPickDetail TABLE
   (
      DropID           NVARCHAR( 20)   NOT NULL,
      SKU              NVARCHAR( 20)   NOT NULL,
      Qty              INT             NOT NULL
   )

   DECLARE @tPickSlipNo TABLE
   (
      PickSlipNo       NVARCHAR( 10)   NOT NULL,
      CartonNo         INT             NOT NULL, 
      LabelNo          NVARCHAR( 20)   NOT NULL
   )

   DECLARE @tSerialNo TABLE
   (
      StorerKey        NVARCHAR( 15)   NOT NULL,
      SKU              NVARCHAR( 20)   NOT NULL,
      SerialNo         NVARCHAR( 50)   NOT NULL
   )

   -- Get extended ExtendedPltBuildCfmSP
   DECLARE @cExtendedPackCfmSP NVARCHAR(20)
   SET @cExtendedPackCfmSP = rdt.rdtGetConfig( @nFunc, 'ExtendedPackCfmSP', @cStorerKey)
   IF @cExtendedPackCfmSP = '0'
      SET @cExtendedPackCfmSP = ''  

   SET @cGenLabelNo_SP = rdt.RDTGetConfig( @nFunc, 'GenLabelNo_SP', @cStorerKey) 
   IF @cGenLabelNo_SP = '0'
      SET @cGenLabelNo_SP = ''  

   SET @cCartonType = rdt.RDTGetConfig( @nFunc, 'CartonType', @cStorerKey) 
   IF @cCartonType = '0'
      SET @cCartonType = ''  

   SET @cUpdatePickDetail = rdt.RDTGetConfig( @nFunc, 'UpdatePickDetail', @cStorerKey)
   SET @cGenPackInfo = rdt.RDTGetConfig( @nFunc, 'GenPackInfo', @cStorerKey)
   SET @cGenPalletDetail = rdt.RDTGetConfig( @nFunc, 'GenPalletDetail', @cStorerKey)
   SET @cCartonCountCfg = rdt.RDTGetConfig( @nFunc, 'CartonCountCfg', @cStorerKey)
   
   SET @cUpdPalletDetailLoc = rdt.RDTGetConfig( @nFunc, 'UpdPalletDetailLoc', @cStorerKey)
   IF @cUpdPalletDetailLoc = '0'
      SET @cUpdPalletDetailLoc = ''

   -- Variable mapping
   SELECT @cPalletID = Value FROM @tPackCfm WHERE Variable = '@cPltValue'
   SELECT @cCartonCount = Value FROM @tPackCfm WHERE Variable = '@cCartonCount'
   SELECT @cPackByPickDetailDropID = Value FROM @tPackCfm WHERE Variable = '@cPackByPickDetailDropID'
   SELECT @cPackByPickDetailID = Value FROM @tPackCfm WHERE Variable = '@cPackByPickDetailID'
   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'

   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN
   SAVE TRAN rdt_835PackConfirm02

   SELECT @nSum_PickDQty = ISNULL( SUM( Qty), 0)
   FROM dbo.PickDetail WITH (NOLOCK)     
   WHERE ( ( @cPackByPickDetailDropID = '1' AND DropID = @cPalletID) OR 
            ( @cPackByPickDetailID = '1' AND ID = @cPalletID))
   AND   Status <> '4'
   AND   StorerKey  = @cStorerKey

   SELECT @nSum_PackDQty = ISNULL( SUM( PD.Qty), 0)
   FROM dbo.PackDetail PD WITH (NOLOCK)
   JOIN dbo.PackHeader PH WITH (NOLOCK) ON ( PD.PickSlipNo = PH.PickSlipNo)
   JOIN dbo.PickDetail PID WITH (NOLOCK) ON ( PD.DropID = PID.DropID AND PD.SKU = PID.Sku AND PH.OrderKey = PID.OrderKey)
   WHERE PD.StorerKey = @cStorerKey
   AND ( ( @cPackByPickDetailDropID = '1' AND PID.DropID = @cPalletID) OR 
                  ( @cPackByPickDetailID = '1' AND ID = @cPalletID))

   IF ( @nSum_PickDQty <= @nSum_PackDQty) AND @nSum_PackDQty > 0
   BEGIN
      SET @nErrNo = 237901
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Fully Packed'
      GOTO RollBackTran
   END

   SELECT @nPickQty = ISNULL( SUM( QTY  ), 0)
   FROM dbo.PickDetail PD (NOLOCK)     
   WHERE ( ( @cPackByPickDetailDropID = '1' AND DropID = @cPalletID) OR 
            ( @cPackByPickDetailID = '1' AND ID = @cPalletID))
   AND   PD.Status < @cPickConfirmStatus
   AND   PD.Status <> '4'
   AND   PD.QTY > 0
   AND   PD.StorerKey  = @cStorerKey

   SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT PD.PickDetailKey, SKU, QTY, DropID
   FROM dbo.PickDetail PD (NOLOCK)     
   WHERE ( ( @cPackByPickDetailDropID = '1' AND DropID = @cPalletID) OR 
            ( @cPackByPickDetailID = '1' AND ID = @cPalletID))
   AND   PD.Status < @cPickConfirmStatus
   AND   PD.Status <> '4'
   AND   PD.QTY > 0
   AND   PD.StorerKey  = @cStorerKey
   ORDER BY PD.PickDetailKey
   OPEN @curPD
   FETCH NEXT FROM @curPD INTO @cPickDetailKey, @cSKU, @nQTY_PD, @cDropID
   WHILE @@FETCH_STATUS = 0
   BEGIN
      SELECT @cSerialNoCapture = SerialNoCapture
      FROM dbo.SKU WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND   SKU = @cSKU

      -- Get PickDetail info  
      DECLARE @cPD_LoadKey      NVARCHAR( 10)  
      DECLARE @cPD_OrderKey     NVARCHAR( 10)  
      DECLARE @cOrderLineNumber NVARCHAR( 5)  
      SELECT 
         @cPD_Loadkey = O.LoadKey, 
         @cPD_OrderKey = OD.OrderKey, 
         @cOrderLineNumber = OD.OrderLineNumber,
         @cLot = PD.LOT
      FROM dbo.PickDetail PD WITH (NOLOCK) 
      INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON (OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber)
      INNER JOIN dbo.Orders O WITH (NOLOCK) ON (OD.OrderKey = O.OrderKey)
      WHERE PD.PickDetailkey = @cPickDetailKey  

      -- Get PickSlipNo  
      DECLARE @cPickSlipNo NVARCHAR(10)  
      SET @cPickSlipNo = ''  
      SELECT @cPickSlipNo = PickHeaderKey FROM PickHeader WITH (NOLOCK) WHERE OrderKey = @cPD_OrderKey  
      IF @cPickSlipNo = ''  
         SELECT TOP 1 @cPickSlipNo = PickHeaderKey FROM PickHeader WITH (NOLOCK) WHERE ExternOrderKey = @cPD_Loadkey  

      IF @cUpdatePickDetail = '1'
      BEGIN
         -- Exact match
         IF @nQTY_PD = @nPickQty
         BEGIN
            -- Confirm PickDetail
            UPDATE dbo.PickDetail WITH (ROWLOCK) SET
               Status = @cPickConfirmStatus, 
               EditWho = @cUserName,
               EditDate = GETDATE()
            WHERE PickDetailKey = @cPickDetailKey

            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 237902
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'OffSetPDtlFail'
               GOTO RollBackTran
            END

            SET @nPickQty = @nPickQty - @nQTY_PD -- Reduce balance -- SOS# 176144
         END
         -- PickDetail have less
         ELSE IF @nQTY_PD < @nPickQty
         BEGIN
            -- Confirm PickDetail
            UPDATE dbo.PickDetail WITH (ROWLOCK) SET
               Status = @cPickConfirmStatus, 
               EditWho = @cUserName,
               EditDate = GETDATE()
            WHERE PickDetailKey = @cPickDetailKey

            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 237903
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'OffSetPDtlFail'
               GOTO RollBackTran
            END

            SET @nPickQty = @nPickQty - @nQTY_PD -- Reduce balance
         END
         -- PickDetail have more, need to split
         ELSE IF @nQTY_PD > @nPickQty
         BEGIN
            IF @nPickQty > 0 -- SOS# 176144
            BEGIN
               -- If Status = '5' (full pick), split line if neccessary
               -- If Status = '4' (short pick), no need to split line if already last RPL line to update,
               -- just have to update the pickdetail.qty = short pick qty
               -- Get new PickDetailkey
               DECLARE @cNewPickDetailKey NVARCHAR( 10)
               EXECUTE dbo.nspg_GetKey
                  @KeyName       = 'PICKDETAILKEY',
                  @fieldlength   = 10 ,
                  @keystring     = @cNewPickDetailKey OUTPUT,
                  @b_Success     = @bSuccess          OUTPUT,
                  @n_err         = @nErrNo            OUTPUT,
                  @c_errmsg      = @cErrMsg           OUTPUT

               IF @bSuccess <> 1
               BEGIN
                  SET @nErrNo = 237904
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'GetDetKeyFail'
                  GOTO RollBackTran
               END

               -- Create a new PickDetail to hold the balance
               INSERT INTO dbo.PICKDETAIL (
                  CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM, UOMQTY, QTYMoved,
                  Status, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType, ToLoc, DoReplenish, ReplenishZone,
                  DoCartonize, PickMethod, WaveKey, EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, PickDetailKey,
                  QTY,
                  TrafficCop,
                  OptimizeCop)
               SELECT
                  CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot, StorerKey, SKU, AltSku, UOM, UOMQTY, QTYMoved,
                  '0', DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType, ToLoc, DoReplenish, ReplenishZone,
                  DoCartonize, PickMethod, WaveKey, EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, @cNewPickDetailKey,
                  @nQTY_PD - @nPickQty, -- QTY
                  NULL, --TrafficCop,
                  '1'  --OptimizeCop
               FROM dbo.PickDetail WITH (NOLOCK)
               WHERE PickDetailKey = @cPickDetailKey

               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 237905
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Ins PDtl Fail'
                  GOTO RollBackTran
               END

               -- If short pick & no split line needed. Update pickdetail.qty with no trafficcop
               -- Change orginal PickDetail with exact QTY (with TrafficCop)
               UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                  QTY = @nPickQty,
                  Trafficcop = NULL, 
                  EditWho = @cUserName,
                  EditDate = GETDATE()
               WHERE PickDetailKey = @cPickDetailKey

               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 237906
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'OffSetPDtlFail'
                  GOTO RollBackTran
               END

               UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                  Status = @cPickConfirmStatus, 
                  EditWho = @cUserName,
                  EditDate = GETDATE()
               WHERE PickDetailKey = @cPickDetailKey

               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 237907
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'OffSetPDtlFail'
                  GOTO RollBackTran
               END

               SET @nPickQty = 0 -- Reduce balance
            END
         END
      END

      BEGIN TRY
         IF NOT EXISTS( SELECT 1 FROM @tPickDetail WHERE DropID = @cDropID AND SKU = @cSKU)
            INSERT INTO @tPickDetail (DropID, SKU, Qty) VALUES 
            (@cDropID, @cSKU, @nQTY_PD)
         ELSE
            UPDATE @tPickDetail SET 
               Qty = Qty + @nQTY_PD 
            WHERE  DropID = @cDropID 
            AND    SKU = @cSKU
      END TRY
      BEGIN CATCH
         SET @nErrNo = 237908
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'OffSetPDtlFail'
         GOTO RollBackTran
      END CATCH

      FETCH NEXT FROM @curPD INTO @cPickDetailKey, @cSKU, @nQTY_PD, @cDropID
   END

   SELECT 
      @cZone = Zone,
      @cPD_OrderKey = OrderKey,
      @cPD_LoadKey = ExternOrderKey
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   IF NOT EXISTS (SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE Pickslipno = @cPickSlipNo)
   BEGIN
      SELECT 
         @cRoute = [Route], 
         @cOrderRefNo = SUBSTRING(ExternOrderKey, 1, 18), 
         @cConsigneekey = ConsigneeKey 
      FROM dbo.Orders WITH (NOLOCK) 
      WHERE OrderKey = @cPD_OrderKey
      AND   StorerKey = @cStorerKey
   
      INSERT INTO dbo.PackHeader
      (Route, OrderKey, OrderRefNo, Loadkey, Consigneekey, StorerKey, PickSlipNo)
      VALUES
      (@cRoute, @cPD_OrderKey, @cOrderRefNo, @cPD_LoadKey, @cConsigneekey, @cStorerKey, @cPickSlipNo)

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 237909
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Ins PackH Err'
         GOTO RollBackTran
      END 
   END

   SET @curPDSKU = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
   SELECT SKU, Qty, DropID
   FROM @tPickDetail
   ORDER BY SKU
   OPEN @curPDSKU
   FETCH NEXT FROM @curPDSKU INTO @cPD_SKU, @nPD_Qty, @cDropID
   WHILE @@FETCH_STATUS = 0
   BEGIN
      SET @curPackDtl = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
      SELECT SerialNo, SUM(Qty)
      FROM dbo.SerialNo WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
	  AND   UCCNo = @cDropID
      AND   SKU = @cPD_SKU
      AND   [Status] < '6'
      GROUP BY SerialNo
      ORDER BY SerialNo
      OPEN @curPackDtl
      FETCH NEXT FROM @curPackDtl INTO @cSerialNo, @nSNQty
      WHILE @@FETCH_STATUS = 0
      BEGIN
         IF NOT EXISTS (SELECT 1 FROM dbo.PackDetail WITH (NOLOCK) 
            WHERE PickSlipNo = @cPickSlipNo
			AND   DropID = @cDropID
            AND   SKU = @cPD_SKU
            AND   RefNo = @cSerialNo)
         BEGIN
            SET @nCartonNo = 0

			SET @cLabelNo = @cDropID

            INSERT INTO dbo.PackDetail
               (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, Refno, AddWho, AddDate, EditWho, EditDate, DropID)
            VALUES
               (@cPickSlipNo, 0, @cLabelNo, '00000', @cStorerKey, @cPD_SKU, @nSNQty,
               @cSerialNo, 'rdt.' + sUser_sName(), GETDATE(), 'rdt.' + sUser_sName(), GETDATE(), @cDropID)

            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 237910
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'InsPackDtlFail'
               GOTO RollBackTran
            END 

            SELECT TOP 1 
				@nCartonNo = CartonNo,
				@cLabelLine = LabelLine
            FROM dbo.PackDetail WITH (NOLOCK) 
            WHERE PickSlipNo = @cPickSlipNo
            AND   LabelNo = @cLabelNo
			AND   SKU = @cPD_SKU
			AND   DropID = @cDropID
			AND   RefNo = @cSerialNo
            ORDER BY 1 

            IF @cGenPackInfo = '1'
            BEGIN
               SELECT
                  @nCartonWeight = ISNULL( SUM( PD.QTY * SKU.STDGrossWGT), 0),
                  @nCartonCube   = ISNULL( SUM( PD.QTY * SKU.STDCube), 0),
                  @nQTY = ISNULL( SUM( PD.Qty), 0)
               FROM dbo.PackDetail PD WITH (NOLOCK)
               JOIN SKU WITH (NOLOCK) ON ( PD.StorerKey = SKU.StorerKey AND PD.SKU = SKU.SKU)
               WHERE PD.PickSlipNo = @cPickSlipNo
               AND PD.CartonNo = @nCartonNo

               IF NOT EXISTS ( SELECT 1 FROM dbo.PackInfo WITH (NOLOCK)
                                 WHERE PickSlipNo = @cPickSlipNo
                                 AND   CartonNo = @nCartonNo)
               BEGIN
                  -- Insert PackInfo
                  INSERT INTO dbo.PackInfo (PickSlipNo, CartonNo, Weight, Cube, Qty, CartonType) VALUES
                  (@cPickSlipNo, @nCartonNo, @nCartonWeight, @nCartonCube, @nQTY, @cCartonType)

                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 237911
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Ins PInfo Fail'
                     GOTO RollBackTran
                  END
               END
               ELSE
               BEGIN
                  -- Update PackInfo
                  UPDATE dbo.PackInfo WITH (ROWLOCK) SET
                     Weight = @nCartonWeight,
                     Cube = @nCartonCube, 
                     Qty = Qty + @nQTY,
                     EditWho = @cUserName,
                     EditDate = GETDATE()
                  WHERE PickSlipNo = @cPickSlipNo
                  AND CartonNo = @nCartonNo

                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 237912
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Upd PInfo Fail'
                     GOTO RollBackTran
                  END
               END
            END

            IF NOT EXISTS ( SELECT 1 FROM @tPickSlipNo WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo)
               INSERT INTO @tPickSlipNo (PickSlipNo, CartonNo, LabelNo) VALUES (@cPickSlipNo, @nCartonNo, @cDropID)
         END -- DropID not exists
         ELSE
         BEGIN
            SELECT TOP 1
                     @nCartonNo = CartonNo,
                     @cLabelNo = LabelNo,
                     @cLabelLine = @cLabelLine
            FROM dbo.PackDetail WITH (NOLOCK) 
            WHERE PickSlipNo = @cPickSlipNo
            AND   DropID = @cDropID
            AND   SKU = @cPD_SKU
            AND   RefNo = @cSerialNo
            ORDER BY 1

            UPDATE dbo.PackDetail WITH (ROWLOCK) SET
               QTY = QTY + @nSNQty, 
               EditWho = @cUserName,
               EditDate = GETDATE()
            WHERE PickSlipNo = @cPickSlipNo
            AND   CartonNo = @nCartonNo
            AND   LabelNo = @cLabelNo
            AND   LabelLine = @cLabelLine

            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 237913
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UpdPackDtlFail'
               GOTO RollBackTran
            END
         END   -- DropID exists and SKU exists (update qty only)

         IF @cSerialNoCapture NOT IN ('', '1')
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
               AND SKU = @cPD_SKU
               AND SerialNo = @cSerialNo
            SET @nRowCount = @@ROWCOUNT

            -- New serial no
            IF @nRowCount = 0
            BEGIN
               -- Insert PackSerialNo
               INSERT INTO PackSerialNo (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, SerialNo, QTY)
               VALUES (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @cSerialNo, @nSNQty)
               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 237914
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PackSNo Err
                  GOTO RollBackTran
               END
            END

            -- Check serial no scanned
            ELSE
            BEGIN
               SET @nErrNo = 237915
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO ady scan
               GOTO RollBackTran
            END

            IF NOT EXISTS ( SELECT 1
                            FROM @tSerialNo
                            WHERE StorerKey = @cStorerKey
                            AND   SKU = @cPD_SKU
                            AND   SerialNo = @cSerialNo)
            BEGIN
               INSERT INTO @tSerialNo ( StorerKey, SKU, SerialNo) VALUES 
               ( @cStorerKey, @cSKU, @cSerialNo)
            END

            FETCH NEXT FROM @curPackDtl INTO @cSerialNo, @nSNQty
         END
      END

      IF @cGenPalletDetail = '1'
      BEGIN
         IF NOT EXISTS ( SELECT 1 FROM dbo.Pallet WITH (NOLOCK) 
                           WHERE PalletKey = @cPalletID
						   AND   StorerKey = @cStorerKey)
         BEGIN
            INSERT INTO dbo.Pallet (PalletKey, StorerKey, Status) VALUES 
            (@cPalletID, @cStorerKey, '0')

            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 237917
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'InsPltInfoFail'
               GOTO RollBackTran
            END
		END
   
        IF NOT EXISTS ( SELECT 1 FROM dbo.PalletDetail WITH (NOLOCK) 
                WHERE PalletKey = @cPalletID
                AND   StorerKey = @cStorerKey
                AND   CaseID = @cDropID
                AND   SKU = @cPD_SKU)
        BEGIN
            INSERT INTO dbo.PalletDetail (PalletKey, PalletLineNumber, CaseId, Sku, Qty, StorerKey, Status, Loc) VALUES 
               
			(@cPalletID, '0', @cDropID, @cSku, @nPD_Qty, @cStorerKey, '0', @cUpdPalletDetailLoc)

            IF @@ERROR <> 0
            BEGIN
                SET @nErrNo = 237919
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'InsPldInfoFail'
                GOTO RollBackTran
            END
        END
         
      END

      FETCH NEXT FROM @curPDSKU INTO @cPD_SKU, @nPD_Qty, @cDropID
   END

   SET @nSum_Packed = 0
   SELECT @nSum_Packed = ISNULL( SUM( Qty), 0)
   FROM dbo.PackDetail PD WITH (NOLOCK) 
   WHERE PickSlipNo = @cPickSlipNo

   SET @nSum_Picked = 0

   -- conso picklist   
   If ISNULL(@cZone, '') = 'XD' OR ISNULL(@cZone, '') = 'LB' OR ISNULL(@cZone, '') = 'LP' 
   BEGIN    
      -- Check outstanding PickDetail
      IF EXISTS( SELECT TOP 1 1
                  FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND   PD.Status < '5'
                  AND    PD.QTY > 0
                  AND   (PD.Status = '4' OR PD.Status <> @cPickConfirmStatus))  -- Short or not yet pick
         SET @cPackConfirm = 'N'
      ELSE
         SET @cPackConfirm = 'Y'

      -- Check fully packed
      IF @cPackConfirm = 'Y'
      BEGIN
         SELECT @nSum_Picked = SUM( QTY) 
         FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
         JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
         WHERE RKL.PickSlipNo = @cPickSlipNo
         
         IF @nSum_Picked <> @nSum_Packed
            SET @cPackConfirm = 'N'
      END
   END
   -- Discrete PickSlip
   ELSE IF ISNULL(@cPD_OrderKey, '') <> '' 
   BEGIN
      -- Check outstanding PickDetail
      IF EXISTS( SELECT TOP 1 1
                  FROM dbo.PickDetail PD WITH (NOLOCK)
                  WHERE PD.OrderKey = @cPD_OrderKey
                  AND   PD.Status < '5'
                  AND   PD.QTY > 0
                  AND  (PD.Status = '4' OR PD.Status <> @cPickConfirmStatus))  -- Short or not yet pick
         SET @cPackConfirm = 'N'
      ELSE
         SET @cPackConfirm = 'Y'
      
      -- Check fully packed
      IF @cPackConfirm = 'Y'
      BEGIN
         SELECT @nSum_Picked = SUM( PD.QTY) 
         FROM dbo.PickDetail PD WITH (NOLOCK) 
         WHERE PD.OrderKey = @cPD_OrderKey
         
         IF @nSum_Picked <> @nSum_Packed
            SET @cPackConfirm = 'N'
      END
   END
   ELSE
   BEGIN
      -- Check outstanding PickDetail
      IF EXISTS( SELECT TOP 1 1 
                  FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (LPD.OrderKey = PD.OrderKey)
                  WHERE LPD.LoadKey = @cLoadKey
                  AND   PD.Status < '5'
                  AND   PD.QTY > 0
                  AND  (PD.Status = '4' OR PD.Status <> @cPickConfirmStatus))  -- Short or not yet pick
         SET @cPackConfirm = 'N'
      ELSE
         SET @cPackConfirm = 'Y'
      
      -- Check fully packed
      IF @cPackConfirm = 'Y'
      BEGIN
         SELECT @nSum_Picked = SUM( PD.QTY) 
         FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
         JOIN dbo.PickDetail PD WITH (NOLOCK) ON (LPD.OrderKey = PD.OrderKey)
         WHERE LPD.LoadKey = @cLoadKey
         
         IF @nSum_Picked <> @nSum_Packed
            SET @cPackConfirm = 'N'
      END
   END

   -- Pack confirm
   IF @cPackConfirm = 'Y'
   BEGIN
      SET @cPrintPackList = 'Y'

      -- (james03)
      -- Update packdetail.labelno = pickdetail.caseid/dropid
      -- Get storer config
      DECLARE @cAssignPackLabelToOrdCfg NVARCHAR(1)
      EXECUTE nspGetRight
         @cFacility,
         @cStorerKey,
         '', --@c_sku
         'AssignPackLabelToOrdCfg',
         @bSuccess                 OUTPUT,
         @cAssignPackLabelToOrdCfg OUTPUT,
         @nErrNo                   OUTPUT,
         @cErrMsg                  OUTPUT
      IF @nErrNo <> 0
         GOTO RollBackTran

      -- Assign
      IF @cAssignPackLabelToOrdCfg = '1'
      BEGIN
         -- Update PickDetail, base on PackDetail.DropID
         EXEC isp_AssignPackLabelToOrderByLoad
             @cPickSlipNo
            ,@bSuccess OUTPUT
            ,@nErrNo   OUTPUT
            ,@cErrMsg  OUTPUT
         IF @nErrNo <> 0
            GOTO RollBackTran
      END   
      
      UPDATE dbo.PackHeader WITH (ROWLOCK) SET 
         [Status] = '9', 
         EditWho = @cUserName,
         EditDate = GETDATE()
      WHERE PickSlipNo = @cPickSlipNo
      AND   [Status] < '9'

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 237920
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PackCfm Fail
         GOTO RollBackTran
      END

      EXEC isp_ScanOutPickSlip
         @c_PickSlipNo = @cPickSlipNo,
         @n_err = @nErrNo OUTPUT,
         @c_errmsg = @cErrMsg OUTPUT

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 237921
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Scan Out Fail
         GOTO RollBackTran
      END
   END

   --Pack confirm only can update serialno.status = 6 (packed)
   IF EXISTS ( SELECT 1 
               FROM dbo.PACKHEADER WITH (NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo
               AND   [Status] = '9')
   BEGIN
      -- Pack confirm only can update serial status
      SET @curSN = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
      SELECT SN.SerialNoKey
      FROM dbo.SerialNo SN WITH (NOLOCK)
      JOIN dbo.PACKDETAIL PD WITH (NOLOCK) ON 
         ( SN.StorerKey = PD.StorerKey AND SN.SKU = PD.SKU AND SN.SerialNo = PD.RefNo)
      WHERE SN.[Status] < '6'
      AND   PD.PickSlipNo = @cPickSlipNo
      OPEN @curSN
      FETCH NEXT FROM @curSN INTO @cSerialNoKey
      WHILE @@FETCH_STATUS = 0
      BEGIN
         UPDATE dbo.SerialNo SET
            [Status] = '6',
            EditWho = @cUserName,
            EditDate = GETDATE()
         WHERE SerialNoKey = @cSerialNoKey

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 237916
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD SNO Err
            GOTO RollBackTran
         END

         FETCH NEXT FROM @curSN INTO @cSerialNoKey
      END
   END

   GOTO Quit

   RollBackTran:
      ROLLBACK TRAN rdt_835PackConfirm02

   Quit:
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
         COMMIT TRAN rdt_835PackConfirm02

   IF @nErrNo <> 0
      GOTO Fail

   SET @cShipLabel = rdt.RDTGetConfig( @nFunc, 'ShipLabel', @cStorerKey)
   IF @cShipLabel = '0'
      SET @cShipLabel = ''

   IF @cShipLabel <> ''
   BEGIN
      SET @curPrint = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
      SELECT PickSlipNo, CartonNo
      FROM @tPickSlipNo
      GROUP BY PickSlipNo, CartonNo
      ORDER BY PickSlipNo, CartonNo
      OPEN @curPrint
      FETCH NEXT FROM @curPrint INTO @cPickSlipNo, @nCartonNo
      WHILE @@FETCH_STATUS = 0
      BEGIN
         DECLARE @tSHIPPLABEL AS VariableTable
         DELETE FROM @tSHIPPLABEL
         INSERT INTO @tSHIPPLABEL (Variable, Value) VALUES ( '@cPickSlipNo',  @cPickSlipNo)
         INSERT INTO @tSHIPPLABEL (Variable, Value) VALUES ( '@cDropID',      @cDropID)
         INSERT INTO @tSHIPPLABEL (Variable, Value) VALUES ( '@cShipperKey',  @cShipperKey)
         INSERT INTO @tSHIPPLABEL (Variable, Value) VALUES ( '@nFromCartonNo',  @nCartonNo)
         INSERT INTO @tSHIPPLABEL (Variable, Value) VALUES ( '@nToCartonNo',    @nCartonNo)

         -- Print label
         EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cLabelPrinter, '', 
            @cShipLabel, -- Report type
            @tSHIPPLABEL, -- Report params
            'rdt_835PackConfirm02', 
            @nErrNo  OUTPUT,
            @cErrMsg OUTPUT 

         FETCH NEXT FROM @curPrint INTO @cPickSlipNo, @nCartonNo
      END
   END



   Fail:
END
GO


SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_835PackConfirm02 TO NSQL
GO