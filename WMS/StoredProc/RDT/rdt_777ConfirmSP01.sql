SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_777ConfirmSP01                                  */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: HILLSAU Pack confirm update labelno to caseid               */
/*                                                                      */
/* Date       Rev  Author      Purposes                                 */
/* 2025-11-20 1.0  NickT       FCR-9200 for USA Levis Pack confirm      */
/************************************************************************/

CREATE OR ALTER   PROC [RDT].[rdt_777ConfirmSP01] (
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

   DECLARE @cSQL                 NVARCHAR(MAX)  
   DECLARE @cSQLParam            NVARCHAR(MAX)  
   DECLARE @cPackConfirmSP       NVARCHAR(20)  
   DECLARE @cLabelLine           NVARCHAR( 5)
   DECLARE @cNewLine             NVARCHAR( 1)
   DECLARE @cNewCarton           NVARCHAR( 1)
   DECLARE @cDropID              NVARCHAR( 20) = ''
   DECLARE @cRefNo               NVARCHAR( 20) = ''
   DECLARE @cRefNo2              NVARCHAR( 30) = ''
   DECLARE @cUPC                 NVARCHAR( 30) = ''
   DECLARE @cLoadKey             NVARCHAR( 10)
   DECLARE @cOrderKey            NVARCHAR( 10)
   DECLARE @cFirstOrderKey       NVARCHAR(10) = @cFromDropID
   DECLARE @cPickConfirmStatus   NVARCHAR( 1)
   DECLARE @cWaveKey             NVARCHAR(10)
   DECLARE @cPickDetailKey       NVARCHAR(18)
   DECLARE @cNewPickDetailKey    NVARCHAR(18)
   DECLARE @cGenLabelNo_SP       NVARCHAR( 20)
   DECLARE @cPackDetailCartonID  NVARCHAR( 20)
   DECLARE @nRowCount            INT
   DECLARE @b_Success            INT
   DECLARE @nLoopIndex           INT
   DECLARE @nPickQty             INT
   DECLARE @nMPOCFlag            INT
   DECLARE @bSuccess             INT

   DECLARE @tPackData TABLE
   (
      RowIndex             INT IDENTITY(1,1) PRIMARY KEY,
      PickSlipNo           NVARCHAR(10),
      PickDetailKey        NVARCHAR(18),
      OrderKey             NVARCHAR(10),
      SKU                  NVARCHAR(20),
      Qty                  INT,
      PackedQty            INT
   )

   EXEC dbo.msp_GetMPOCRequired 
         @c_OrderKey = @cFirstOrderKey,
         @n_MPOCFlag = @nMPOCFlag OUTPUT,
         @b_Success = 1,
         @n_Err = @nErrNo OUTPUT,
         @c_ErrMsg = @cErrMsg OUTPUT

   SELECT @cWaveKey = WaveKey
   FROM dbo.WaveDetail WITH(NOLOCK)
   WHERE OrderKey = @cFirstOrderKey

   IF @nErrNo <> 0
      GOTO Quit

   -- Handling transaction
   DECLARE @nTranCount  INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_777ConfirmSP01 -- For rollback or commit only our own transaction
   
   -- Normal Order
   IF @nMPOCFlag <> 1
   BEGIN
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
            SET @nErrNo = 251851
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPHdrFail
            GOTO RollBackTran
         END
      END

      -- Storer configure
      SET @cPackDetailCartonID = rdt.RDTGetConfig( @nFunc, 'PackDetailCartonID', @cStorerKey)
      IF @cPackDetailCartonID = '0' -- DropID/LabelNo/RefNo/RefNo2/UPC/NONE
         SET @cPackDetailCartonID = 'DropID'

      SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
      IF @cPickConfirmStatus = '0'
         SET @cPickConfirmStatus = '5'

      -- Save decoded data to which column (initially it was carton ID only, hence the misleading PackDetailCartonID ConfigKey name)
      IF @cPackDetailCartonID = 'DropID'  SET @cDropID  = @cPackDtlDropID ELSE
      IF @cPackDetailCartonID = 'RefNo'   SET @cRefNo   = @cPackDtlRefNo  ELSE
      IF @cPackDetailCartonID = 'RefNo2'  SET @cRefNo2  = @cPackDtlRefNo2 ELSE
      IF @cPackDetailCartonID = 'UPC'     SET @cUPC     = @cPackDtlUPC

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
                  SET @nErrNo = 251852
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenLabelNoFail
                  GOTO RollBackTran
               END
            END
         END

         IF @cLabelNo = ''
         BEGIN
            SET @nErrNo = 251853
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
            SUSER_SNAME(), GETDATE(), SUSER_SNAME(), GETDATE())
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 251854
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
            EditWho = SUSER_SNAME(), 
            EditDate = GETDATE(), 
            ArchiveCop = NULL
         WHERE PickSlipNo = @cPickSlipNo
            AND CartonNo = @nCartonNo
            AND LabelNo = @cLabelNo
            AND LabelLine = @cLabelLine
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 251855
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
            AND AddWho = SUSER_SNAME()
         ORDER BY CartonNo DESC -- max cartonno
      END   

      -- PackInfo
      IF NOT EXISTS (SELECT 1 FROM dbo.PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo)
      BEGIN
         INSERT INTO dbo.PackInfo (PickslipNo, CartonNo, UCCNo, QTY, CartonType)
         VALUES (@cPickSlipNo, @nCartonNo, @cUCCNo, @nQTY, '')
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 251856
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPackInfFail
            GOTO RollBackTran
         END
      END
      ELSE
      BEGIN
         UPDATE dbo.PackInfo SET
            UCCNo = @cUCCNo,
            Qty = Qty + @nQTY,
            EditDate = GETDATE(), 
            EditWho = SUSER_SNAME(), 
            TrafficCop = NULL
         WHERE PickSlipNo = @cPickSlipNo
            AND CartonNo = @nCartonNo
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 251857
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDPackInfFail
            GOTO RollBackTran
         END
      END

      -- Insert PackInfo
      IF @cUCCNo <> ''
      BEGIN
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
               SET @nErrNo = 251858
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
            SET @nErrNo = 251859
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
                  SET @nErrNo = 251860
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPackSNOFail
                  GOTO RollBackTran
               END
            END
            ELSE
            BEGIN
               SET @nErrNo = 251861
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO ady scan
               GOTO RollBackTran
            END

            DELETE rdt.rdtReceiveSerialNoLog 
            WHERE ReceiveSerialNoLogKey = @nReceiveSerialNoLogKey
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 251862
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DEL TmpSN Fail
               GOTO RollBackTran
            END 

            SET @nQTY_Bal = @nQTY_Bal - @nSerialQTY
         END
            
         -- Check fully offset
         IF @nQTY_Bal <> 0
         BEGIN
            SET @nErrNo = 251863
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Offset error 
            GOTO RollBackTran
         END 

         -- Check balance
         IF EXISTS( SELECT 1
            FROM rdt.rdtReceiveSerialNoLog WITH (NOLOCK)
            WHERE Mobile = @nMobile
               AND Func = @nFunc)
         BEGIN
            SET @nErrNo = 251864
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Offset error 
            GOTO RollBackTran
         END
      END

      -- Serial no
      ELSE IF @cSerialNo <> ''
      BEGIN
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
               SET @nErrNo = 251865
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS RDSNo Fail
               GOTO RollBackTran
            END
         END
         
         -- Check serial no scanned
         ELSE
         BEGIN
            SET @nErrNo = 251866
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
               SUSER_SNAME(), GETDATE(), SUSER_SNAME(), GETDATE())
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 251867
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PDInfoFail
               GOTO RollBackTran
            END
         END
         ELSE
         BEGIN
            -- Update PackDetailInfo
            UPDATE dbo.PackDetailInfo SET   
               QTY = QTY + @nQTY, 
               EditWho = SUSER_SNAME(), 
               EditDate = GETDATE(), 
               ArchiveCop = NULL
            WHERE PackDetailInfoKey = @nPackDetailInfoKey
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 251868
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PDInfoFail
               GOTO RollBackTran
            END
         END
      END
   END
   ELSE
   -- MPOC Order
   BEGIN
      DECLARE @InputQty INT = @nQty
      DELETE FROM @tPackData

      INSERT INTO @tPackData (PickSlipNo, PickDetailKey, OrderKey, SKU, Qty, PackedQty)
      SELECT PH.PickHeaderKey, PD.PickDetailKey, PD.OrderKey, PD.SKU, PD.Qty, 0
      FROM dbo.PickDetail PD WITH(NOLOCK)
      INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON PD.StorerKey = PH.StorerKey AND PD.OrderKey = PH.OrderKey
      INNER JOIN dbo.WaveDetail WD WITH(NOLOCK) ON PD.OrderKey = WD.OrderKey
      WHERE WD.WaveKey = @cWaveKey
         AND PD.StorerKey = @cStorerKey
         AND PD.SKU = @cSKU
         AND PD.Status = '5'
         AND LEN(CaseID) < 18
      ORDER BY PD.Qty DESC

      SET @nLoopIndex = -1

      WHILE 1 = 1
      BEGIN
         SET @cOrderKey = ''
         SET @cLoadKey = ''
         SET @cPickSlipNo = ''
         SET @cPickDetailKey = ''
         SET @cSKU = ''
         SET @nPickQty = 0

         SELECT TOP 1
            @cPickSlipNo = PickSlipNo,
            @cPickDetailKey = PickDetailKey,
            @cSKU = SKU,
            @nPickQty = Qty,
            @cOrderKey = OrderKey,
            @nLoopIndex = RowIndex
         FROM @tPackData
         WHERE RowIndex > @nLoopIndex
         ORDER BY RowIndex

         SELECT @nRowCount = @@ROWCOUNT

         IF @nRowCount = 0 OR @InputQty < 0
            BREAK

         -- Get PickHeader info
         SELECT TOP 1
            @cLoadKey = ExternOrderKey
         FROM dbo.PickHeader WITH (NOLOCK)
         WHERE PickHeaderKey = @cPickSlipNo
         
         IF NOT EXISTS(SELECT 1 FROM dbo.PackHeader WITH(NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND StorerKey = @cStorerKey AND OrderKey = @cOrderKey)
         BEGIN
            BEGIN TRY
               INSERT INTO dbo.PackHeader (PickSlipNo, StorerKey, OrderKey, LoadKey)
               VALUES (@cPickSlipNo, @cStorerKey, @cOrderKey, @cLoadKey)
            END TRY
            BEGIN CATCH
               SET @nErrNo = 251870
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Insert PackHeader Failed
               GOTO RollBackTran
            END CATCH
         END

         IF @nCartonNo = 0 -- New Carton
         BEGIN
            SET @cLabelNo = ''
            
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
                     SET @nErrNo = 251871
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenLabelNoFail
                     GOTO RollBackTran
                  END
               END
            END

            IF @cLabelNo = ''
            BEGIN
               SET @nErrNo = 251872
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenLabelNoFail
               GOTO RollBackTran
            END

            SET @cLabelLine = ''   
            SET @cNewLine = 'Y'
            SET @cNewCarton = 'Y'
         END
         BEGIN -- Existsing Carton
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
            BEGIN TRY
               INSERT INTO dbo.PackDetail
                  (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, 
                  DropID, RefNo, RefNo2, UPC,
                  AddWho, AddDate, EditWho, EditDate)
               VALUES
                  (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @nQTY, 
                  @cDropID, @cRefNo, @cRefNo2, @cUPC,
                  SUSER_SNAME(), GETDATE(), SUSER_SNAME(), GETDATE())
            END TRY
            BEGIN CATCH
               SET @nErrNo = 251873
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPackDtlFail
               GOTO RollBackTran
            END CATCH
         END
         ELSE
         BEGIN
            BEGIN TRY
               -- Update Packdetail
               UPDATE dbo.PackDetail WITH (ROWLOCK) SET   
                  SKU = @cSKU, 
                  QTY = QTY + @nQTY, 
                  EditWho = SUSER_SNAME(), 
                  EditDate = GETDATE(), 
                  ArchiveCop = NULL
               WHERE PickSlipNo = @cPickSlipNo
                  AND CartonNo = @nCartonNo
                  AND LabelNo = @cLabelNo
                  AND LabelLine = @cLabelLine
            END TRY
            BEGIN CATCH
               SET @nErrNo = 251874
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
            FROM PackDetail WITH (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo
               AND SKU = @cSKU
               AND AddWho = SUSER_SNAME()
            ORDER BY CartonNo DESC -- max cartonno
         END   

         -- PackInfo
         IF NOT EXISTS (SELECT 1 FROM dbo.PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo)
         BEGIN
            BEGIN TRY
               INSERT INTO dbo.PackInfo (PickslipNo, CartonNo, UCCNo, QTY, RefNo, CartonType)
               VALUES (@cPickSlipNo, @nCartonNo, @cUCCNo, @nQTY, @cLabelNo, '')
            END TRY
            BEGIN CATCH
               SET @nErrNo = 251875
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPackInfFail
               GOTO RollBackTran
            END CATCH
         END
         ELSE
         BEGIN
            BEGIN TRY
               UPDATE dbo.PackInfo SET
                  UCCNo = @cUCCNo,
                  Qty = Qty + @nQTY,
                  EditDate = GETDATE(), 
                  EditWho = SUSER_SNAME(), 
                  TrafficCop = NULL
               WHERE PickSlipNo = @cPickSlipNo
                  AND CartonNo = @nCartonNo
            END TRY
            BEGIN CATCH
               SET @nErrNo = 251876
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDPackInfFail
               GOTO RollBackTran
            END CATCH
         END

         UPDATE @tPackData
         SET PackedQty = IIF (@InputQty <= @nPickQty, @InputQty, @nPickQty)
         WHERE RowIndex = @nLoopIndex

         SET @InputQty = @InputQty - @nPickQty
      END
   END

   IF @nMPOCFlag <> 1
   BEGIN
      WHILE @nQTY > 0
      BEGIN
         SELECT TOP 1 
            @cPickDetailKey = PickDetailKey,
            @nPickQTY = Qty
         FROM dbo.PickDetail PD WITH(NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND OrderKey = @cFirstOrderKey
            AND SKU = @cSKU
            AND Qty > 0
            AND Status = @cPickConfirmStatus
            AND LEN(CaseID) < 18
         ORDER BY OrderKey, OrderLineNumber, PickDetailKey

         SELECT @nRowCount = @@ROWCOUNT
         IF @nRowCount = 0
            BREAK

         IF @nPickQTY > @nQTY
         BEGIN
            EXECUTE nspg_GetKey
               'PICKDETAILKEY'
               , 10
               , @cNewPickDetailKey    OUTPUT
               , @b_Success            OUTPUT
               , @nErrNo               OUTPUT
               , @cErrMsg              OUTPUT

            IF @b_Success <> 1
            BEGIN
               SET @nErrNo = 251869
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Generate PickDetailKey Failed
               GOTO RollBackTran
            END

            INSERT INTO dbo.PickDetail (
               CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM,
               UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType,
               ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
               EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes,
               PickDetailKey,
               Status, 
               QTY,
               TrafficCop,
               OptimizeCop)
            SELECT
               CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot, StorerKey, SKU, AltSku, UOM,
               UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup,
               CartonType, ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
               EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes,
               @cNewPickDetailKey,
               Status, 
               @nPickQTY - @nQTY,
               NULL, -- TrafficCop
               '1'   -- OptimizeCop
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE PickDetailKey = @cPickDetailKey
         END

         UPDATE dbo.PickDetail WITH(ROWLOCK)
         SET CaseID = @cLabelNo,
            Qty = @nQTY,
            EditDate = GETDATE(),
            EditWho = SUSER_NAME(),
            TrafficCop = NULL
         WHERE PickDetailKey = @cPickDetailKey

         SET @nQTY = @nQTY - @nPickQTY
      END

      UPDATE dbo.PackInfo WITH(ROWLOCK)
      SET RefNo = @cLabelNo,
         CartonType = ''
      WHERE PickSlipNo = @cPickSlipNo
   END
   ELSE
   BEGIN
      DECLARE @nPackedQty  INT
      SET @nLoopIndex = -1

      WHILE 1 = 1
      BEGIN
         SET @cPickDetailKey = ''
         SET @nPickQty = 0
         SET @nPackedQty = 0

         SELECT TOP 1
            @cPickDetailKey = PickDetailKey,
            @nPickQty = Qty,
            @nPackedQty = PackedQty,
            @nLoopIndex = RowIndex
         FROM @tPackData
         WHERE PackedQty > 0
            AND RowIndex > @nLoopIndex
         ORDER BY RowIndex

         SELECT @nRowCount = @@ROWCOUNT

         IF @nRowCount = 0
            BREAK

         IF @nPickQty > @nPackedQty
         BEGIN
            EXECUTE nspg_GetKey
               'PICKDETAILKEY'
               , 10
               , @cNewPickDetailKey    OUTPUT
               , @b_Success            OUTPUT
               , @nErrNo               OUTPUT
               , @cErrMsg              OUTPUT

            IF @b_Success <> 1
            BEGIN
               SET @nErrNo = 251877
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Generate PickDetailKey Failed
               GOTO RollBackTran
            END

            INSERT INTO dbo.PickDetail (
               CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM,
               UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType,
               ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
               EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes,
               PickDetailKey,
               Status, 
               QTY,
               TrafficCop,
               OptimizeCop)
            SELECT
               CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot, StorerKey, SKU, AltSku, UOM,
               UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup,
               CartonType, ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
               EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes,
               @cNewPickDetailKey,
               Status, 
               @nPickQty - @nPackedQty,
               NULL, -- TrafficCop
               '1'   -- OptimizeCop
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE PickDetailKey = @cPickDetailKey
         END

         UPDATE dbo.PickDetail WITH(ROWLOCK)
         SET CaseID = @cLabelNo,
            Qty = @nPackedQty,
            EditDate = GETDATE(),
            EditWho = SUSER_NAME(),
            TrafficCop = NULL
         WHERE PickDetailKey = @cPickDetailKey
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

   COMMIT TRAN rdt_777ConfirmSP01
   GOTO Quit

RollBackTran:
BEGIN
   ROLLBACK TRAN rdt_777ConfirmSP01 -- Only rollback change made here
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

GRANT EXECUTE ON  [RDT].[rdt_777ConfirmSP01] TO [NSQL]
GO