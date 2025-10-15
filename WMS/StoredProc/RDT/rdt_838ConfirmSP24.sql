
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_838ConfirmSP24                                  */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Update PickDetail.DropID, base on SKU, Lottable01           */
/*                                                                      */
/* Date       Rev  Author      Purposes                                 */
/* 2025-03-17 1.0  Dennis      FCR-2814 Created                         */
/* 2025-05-12 1.1  Dennis      UWP-34249 Performance Tune               */
/* 2025-10-14 1.2  NickT       UWP-42331 Add PKD query cond: Lottable01 */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_838ConfirmSP24] (
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
   DECLARE @cPickDetailKey NVARCHAR( 10)

   DECLARE @cGenLabelNo_SP       NVARCHAR( 20)
   DECLARE @cPackDetailCartonID  NVARCHAR( 20)
   DECLARE @cPackByFromDropID    NVARCHAR( 1)

   -- Get PickHeader info
   SELECT TOP 1
      @cOrderKey = OrderKey,
      @cLoadKey = ExternOrderKey
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   DECLARE @cLottable01 NVARCHAR( 18)
      -- Get session info
   SELECT @cLottable01 = V_Lottable01 FROM rdt.rdtMobRec WITH (NOLOCK) WHERE Mobile = @nMobile
      
   -- Handling transaction
   DECLARE @nTranCount  INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_838ConfirmSP24 -- For rollback or commit only our own transaction
   
   -- PackHeader
   IF NOT EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickslipNo = @cPickslipNo)
   BEGIN
      INSERT INTO dbo.PackHeader (PickSlipNo, StorerKey, OrderKey, LoadKey)
      VALUES (@cPickSlipNo, @cStorerKey, @cOrderKey, @cLoadKey)
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 208301
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPHdrFail
         GOTO RollBackTran
      END
   END

   -- Storer configure
   SET @cPackByFromDropID = rdt.rdtGetConfig( @nFunc, 'PackByFromDropID', @cStorerKey)
   SET @cPackDetailCartonID = rdt.RDTGetConfig( @nFunc, 'PackDetailCartonID', @cStorerKey)
   IF @cPackDetailCartonID = '0' -- DropID/LabelNo/RefNo/RefNo2/UPC/NONE
      SET @cPackDetailCartonID = 'DropID'

   -- Save decoded data to which column (initially it was carton ID only, hence the misleading PackDetailCartonID ConfigKey name)
   IF @cPackDetailCartonID = 'DropID'  SET @cDropID  = @cPackDtlDropID ELSE
   IF @cPackDetailCartonID = 'RefNo'   SET @cRefNo   = @cPackDtlRefNo ELSE
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
               SET @nErrNo = 208302
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenLabelNoFail
               GOTO RollBackTran
            END
         END
      END

      IF @cLabelNo = ''
      BEGIN
         SET @nErrNo = 208303
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
         FROM dbo.PackDetail (NOLOCK)
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
         SET @nErrNo = 208304
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPackDtlFail
         GOTO RollBackTran
      END
   END
   ELSE
   BEGIN
      -- Update Packdetail
      UPDATE dbo.PackDetail WITH (ROWLOCK) SET   
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
         SET @nErrNo = 208305
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
            SET @nErrNo = 208306
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
            SET @nErrNo = 208307
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
            SET @nErrNo = 208308
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
         SET @nErrNo = 208309
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
            SELECT TOP 1 @cPickDetailKey = pkd.PickDetailKey
            FROM dbo.PickDetail pkd (NOLOCK)
            INNER JOIN dbo.PickHeader pkh (NOLOCK) ON pkh.OrderKey = pkd.OrderKey AND pkh.StorerKey = pkd.StorerKey
            INNER JOIN dbo.LOTAttribute LA WITH (NOLOCK) ON (pkd.LOT = LA.LOT)
            LEFT JOIN dbo.PackSerialNo psn (NOLOCK) ON psn.PickDetailKey = pkd.PickDetailKey
            WHERE pkd.StorerKey = @cStorerKey
            AND pkh.PickHeaderKey = @cPickSlipNo
            AND LA.Lottable01 = @cLottable01
            AND pkd.SKU = @cSKU
            AND psn.PackSerialNoKey IS NULL
            
            IF ISNULL(@cPickDetailKey,'')=''
            BEGIN
               SET @nErrNo = 208327
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PickDetail NotFound
               GOTO RollBackTran
            END
            -- Insert PackSerialNo 
            INSERT INTO PackSerialNo (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, SerialNo, QTY,PICKDETAILKEY)
            VALUES (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @cSerialNo, @nSerialQTY,@cPickDetailKey)
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 208310
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPackSNOFail
               GOTO RollBackTran
            END
         END
         ELSE
         BEGIN
            SET @nErrNo = 208311
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO ady scan
            GOTO RollBackTran
         END

         DELETE rdt.rdtReceiveSerialNoLog 
         WHERE ReceiveSerialNoLogKey = @nReceiveSerialNoLogKey
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 208312
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DEL TmpSN Fail
            GOTO RollBackTran
         END 

         SET @nQTY_Bal = @nQTY_Bal - @nSerialQTY
      END
         
      -- Check fully offset
      IF @nQTY_Bal <> 0
      BEGIN
         SET @nErrNo = 208313
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Offset error 
         GOTO RollBackTran
      END 

      -- Check balance
      IF EXISTS( SELECT 1
         FROM rdt.rdtReceiveSerialNoLog WITH (NOLOCK)
         WHERE Mobile = @nMobile
            AND Func = @nFunc)
      BEGIN
         SET @nErrNo = 208314
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
         SELECT TOP 1 @cPickDetailKey = pkd.PickDetailKey
         FROM dbo.PickDetail pkd (NOLOCK)
         INNER JOIN dbo.PickHeader pkh (NOLOCK) ON pkh.OrderKey = pkd.OrderKey AND pkh.StorerKey = pkd.StorerKey
         INNER JOIN dbo.LOTAttribute LA WITH (NOLOCK) ON (pkd.LOT = LA.LOT)
         LEFT JOIN dbo.PackSerialNo psn (NOLOCK) ON psn.PickDetailKey = pkd.PickDetailKey
         WHERE pkd.StorerKey = @cStorerKey
         AND pkh.PickHeaderKey = @cPickSlipNo
         AND LA.Lottable01 = @cLottable01
         AND pkd.SKU = @cSKU
         AND psn.PackSerialNoKey IS NULL

         IF ISNULL(@cPickDetailKey,'')=''
         BEGIN
            SET @nErrNo = 208327
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PickDetail NotFound
            GOTO RollBackTran
         END
         -- Insert PackSerialNo 
         INSERT INTO PackSerialNo (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, SerialNo, QTY,PickDetailKey)
         VALUES (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @cSerialNo, @nSerialQTY,@cPickDetailKey)
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 208315
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS RDSNo Fail
            GOTO RollBackTran
         END
      END
      
      -- Check serial no scanned
      ELSE
      BEGIN
         SET @nErrNo = 208316
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
            SET @nErrNo = 208317
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
            SET @nErrNo = 208318
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PDInfoFail
            GOTO RollBackTran
         END
      END
   END
   
   /***********************************************************************************************
                                                PickDetail
   ***********************************************************************************************/
   DECLARE @nQTY_PD INT
   SET @cPickDetailKey = ''
   
   SET @nQTY_Bal = @nQTY

   -- PickDetail
   DECLARE @curPD CURSOR
   IF @cPackByFromDropID = '1'
      SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR         
         SELECT PickDetailKey, PD.QTY
         FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN dbo.LOTAttribute LA WITH (NOLOCK) ON (PD.LOT = LA.LOT)
         WHERE PD.OrderKey = @cOrderKey
            AND PD.StorerKey = @cStorerKey
            AND PD.SKU = @cSKU
            AND LA.Lottable01 = @cLottable01
            AND PD.CaseID = ''
            AND PD.DropID = @cFromDropID
            AND PD.Status = '5'
            AND PD.Status <> '4'
   ELSE
      SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR         
         SELECT PickDetailKey, PD.QTY
         FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN dbo.LOTAttribute LA WITH (NOLOCK) ON (PD.LOT = LA.LOT)
         WHERE PD.OrderKey = @cOrderKey
            AND PD.StorerKey = @cStorerKey
            AND PD.SKU = @cSKU
            AND LA.Lottable01 = @cLottable01
            AND PD.CaseID = ''
            AND PD.Status = '5'
            AND PD.Status <> '4'
   OPEN @curPD 
   FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY_PD 
   WHILE @@FETCH_STATUS = 0
   BEGIN
      -- Exact match
      IF @nQTY_PD = @nQTY_Bal
      BEGIN
         -- Confirm PickDetail
         UPDATE dbo.PickDetail WITH (ROWLOCK) SET 
            CaseID = @cLabelNo,
            EditDate = GETDATE(), 
            EditWho  = SUSER_SNAME(), 
            TrafficCop = NULL
         WHERE PickDetailKey = @cPickDetailKey
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 208319
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
            GOTO RollBackTran
         END

         SET @nQTY_Bal = 0 -- Reduce balance
      END
      
      -- PickDetail have less
		ELSE IF @nQTY_PD < @nQTY_Bal
      BEGIN
         -- Confirm PickDetail
         UPDATE dbo.PickDetail WITH (ROWLOCK) SET 
            CaseID = @cLabelNo,
            EditDate = GETDATE(), 
            EditWho  = SUSER_SNAME() , 
            TrafficCop = NULL
         WHERE PickDetailKey = @cPickDetailKey
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 208320
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
            GOTO RollBackTran
         END

         SET @nQTY_Bal = @nQTY_Bal - @nQTY_PD -- Reduce balance
      END
      
      -- PickDetail have more
		ELSE IF @nQTY_PD > @nQTY_Bal
      BEGIN
         -- Get new PickDetailkey
         DECLARE @cNewPickDetailKey NVARCHAR( 10)
         EXECUTE dbo.nspg_GetKey
            'PICKDETAILKEY', 
            10 ,
            @cNewPickDetailKey OUTPUT,
            @bSuccess          OUTPUT,
            @nErrNo            OUTPUT,
            @cErrMsg           OUTPUT
         IF @bSuccess <> 1
         BEGIN
            SET @nErrNo = 208321
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- nspg_GetKey
            GOTO RollBackTran
         END

         -- Create new a PickDetail to hold the balance
         INSERT INTO dbo.PickDetail (
            CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM, 
            UOMQTY, QTYMoved, Status, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType, 
            ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey, Channel_ID, 
            EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes, 
            PickDetailKey, 
            QTY, 
            TrafficCop,
            OptimizeCop)
         SELECT 
            CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot, StorerKey, SKU, AltSku, UOM, 
            UOMQTY, QTYMoved, Status, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, 
            CartonType, ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey, Channel_ID,
            EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes, 
            @cNewPickDetailKey, 
            @nQTY_PD - @nQTY_Bal, -- QTY
            NULL, -- TrafficCop
            '1'   -- OptimizeCop
         FROM dbo.PickDetail WITH (NOLOCK) 
			WHERE PickDetailKey = @cPickDetailKey			            
         IF @@ERROR <> 0
         BEGIN
				SET @nErrNo = 208322
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- INS PKDtl Fail
            GOTO RollBackTran
         END

         -- Split RefKeyLookup
         IF EXISTS( SELECT 1 FROM RefKeyLookup WITH (NOLOCK) WHERE PickDetailKey = @cPickDetailKey)
         BEGIN
            -- Insert into
            INSERT INTO dbo.RefKeyLookup (PickDetailkey, PickSlipNo, OrderKey, OrderLineNumber, Loadkey)
            SELECT @cNewPickDetailKey, PickSlipNo, OrderKey, OrderLineNumber, Loadkey
            FROM RefKeyLookup WITH (NOLOCK) 
            WHERE PickDetailKey = @cPickDetailKey
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 208323
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- INS RefKeyFail
               GOTO RollBackTran
            END
         END
         
         -- Change orginal PickDetail with exact QTY (with TrafficCop)
         UPDATE dbo.PickDetail WITH (ROWLOCK) SET 
            QTY = @nQTY_Bal, 
            EditDate = GETDATE(), 
            EditWho  = SUSER_SNAME(), 
            Trafficcop = NULL
         WHERE PickDetailKey = @cPickDetailKey 
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 208324
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
            GOTO RollBackTran
         END

         -- Confirm orginal PickDetail with exact QTY
         UPDATE dbo.PickDetail WITH (ROWLOCK) SET 
            CaseID = @cLabelNo,
            EditDate = GETDATE(), 
            EditWho  = SUSER_SNAME(), 
            TrafficCop = NULL
         WHERE PickDetailKey = @cPickDetailKey
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 208325
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
            GOTO RollBackTran
         END
         
         SET @nQTY_Bal = 0 -- Reduce balance
      END

      -- Exit condition
      IF @nQTY_Bal = 0
         BREAK

      FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY_PD 
   END
   
   -- Check offset
   IF @nQTY_Bal <> 0
   BEGIN
      SET @nErrNo = 208326
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Offset error
      GOTO RollBackTran
   END

   -- Event log      
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

   COMMIT TRAN rdt_838ConfirmSP24
   GOTO Quit

RollBackTran:
BEGIN
   ROLLBACK TRAN rdt_838ConfirmSP24 -- Only rollback change made here
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

GRANT EXECUTE ON RDT.rdt_838ConfirmSP24 TO NSQL
GO