
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*********************************************************************************/
/* Store procedure: rdt_1868UnpackConfirm                                        */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Date         Rev   Author      Purposes                                       */
/* 2024-11-05   1.0   TLE109      FCR-917 Serial Unpack and Unpick               */
/* 2026-07-06   1.1   NickT       UWP-60041 Add pickdetail to hold unpicked Qty  */
/*********************************************************************************/

CREATE OR ALTER PROC rdt.rdt_1868UnpackConfirm (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 5),
   @cStorerKey       NVARCHAR( 15),
   @cSerialNo        NVARCHAR( 100),
   @cPickSlipNo      NVARCHAR( 20),
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
)
AS
BEGIN

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
   @cUnPackConfirmSP NVARCHAR( 20),
   @nTranCount       INT,
   @cSQL             NVARCHAR( MAX),
   @cSQLParam        NVARCHAR( MAX)

   SET @nTranCount = @@TRANCOUNT

   SET @cUnPackConfirmSP = rdt.RDTGetConfig( @nFunc, 'UnPackConfirmSP', @cStorerKey)
   IF @cUnPackConfirmSP = '0'
   BEGIN
      SET @cUnPackConfirmSP = ''
   END 
-------------------------------------------Customer---------------------------------------------

   IF @cUnPackConfirmSP <> '' AND EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cUnPackConfirmSP AND type = 'P')
   BEGIN
      SET @cSQL = 'EXEC rdt.' + RTRIM( @cUnPackConfirmSP) +
      ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' +
      ' @cSerialNo, @cPickSlipNo,' +
      ' @nErrNo OUTPUT, @cErrMsg OUTPUT ' 

      SET @cSQLParam = 
      ' @nMobile        INT,           ' +
      ' @nFunc          INT,           ' +
      ' @cLangCode      NVARCHAR( 3),  ' +
      ' @nStep          INT,           ' +
      ' @nInputKey      INT,           ' +
      ' @cFacility      NVARCHAR( 5),  ' +
      ' @cStorerKey     NVARCHAR( 15), ' +
      ' @cSerialNo      NVARCHAR( 100),' +
      ' @cPickSlipNo    NVARCHAR( 20), ' + 
      ' @nErrNo         INT OUTPUT,     ' +
      ' @cErrMsg        NVARCHAR( 20)  OUTPUT' 

      EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
         @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,
         @cSerialNo, @cPickslipNo,
         @nErrNo OUTPUT, @cErrMsg OUTPUT
      IF @nErrNo <> 0
      BEGIN
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      END
      GOTO Quit 
   END



-------------------------------------------Standard---------------------------------------------

   DECLARE
      @nCartonNo                 INT,
      @cLabelNo                  NVARCHAR( 20),
      @cLabelLine                NVARCHAR( 10),
      @cPickDetailKey            NVARCHAR( 20),
      @cSKU                      NVARCHAR( 40),
      @nPackDetailQty            INT


   -- transaction
   BEGIN TRAN
   SAVE TRAN tran_SerialUnpack

   SET @cLabelNo = ''
   SET @cLabelLine = ''
   SET @cPickDetailKey = ''
   SET @cSKU = ''
   SELECT  
      @nCartonNo      = CartonNo, 
      @cLabelNo       = LabelNo, 
      @cLabelLine     = LabelLine, 
      @cPickDetailKey = PickDetailKey, 
      @cSKU           = SKU
   FROM dbo.PackSerialNo WITH(NOLOCK)
   WHERE  SerialNo =@cSerialNo
      AND PickSlipNo =@cPickSlipNo
      AND StorerKey=@cStorerKey
   IF @cSKU = ''
   BEGIN
      SET @nErrNo = 228265 
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  --28265^SKU Not Exists
      GOTO RollBackTran
   END

   IF EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND StorerKey = @cStorerKey AND Status = '9')
   BEGIN
      BEGIN TRY
         UPDATE dbo.PackHeader WITH(ROWLOCK)
         SET
            Status = '0',
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         WHERE PickSlipNo = @cPickSlipNo 
            AND StorerKey = @cStorerKey 
            AND Status = '9'
      END TRY
      BEGIN CATCH
         SET @nErrNo = 272901
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to update PackHeader to 0
         GOTO RollBackTran
      END CATCH
   END

   BEGIN TRY
      DELETE FROM dbo.PackSerialNo
      WHERE PickSlipNo = @cPickSlipNo 
         AND SerialNo = @cSerialNo 
         AND StorerKey = @cStorerKey
   END TRY
   BEGIN CATCH
      EXEC rdt.rdtSetFocusField @nMobile, 1
      SET @nErrNo = 272902
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to delete PackSerialNo record
      GOTO RollBackTran
   END CATCH

   BEGIN TRY
      UPDATE dbo.PackDetail WITH(ROWLOCK)
      SET 
         Qty       = Qty-1,
         EditWho   = SUSER_SNAME(),
         EditDate  = GETDATE()
      WHERE PickSlipNo = @cPickSlipNo AND StorerKey = @cStorerKey
         AND CartonNo = @nCartonNo    AND Qty > 0 AND SKU = @cSKU
         AND LabelNo = @cLabelNo      AND LabelLine = @cLabelLine
   END TRY
   BEGIN CATCH
      EXEC rdt.rdtSetFocusField @nMobile, 1
      SET @nErrNo = 272903
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to reduce PackDetail Qty
      GOTO RollBackTran
   END CATCH

   BEGIN TRY
      DELETE FROM dbo.PackDetail
      WHERE PickSlipNo = @cPickSlipNo AND StorerKey = @cStorerKey 
         AND CartonNo = @nCartonNo    AND Qty=0   AND SKU = @cSKU
         AND LabelNo = @cLabelNo      AND LabelLine = @cLabelLine
   END TRY
   BEGIN CATCH
      EXEC rdt.rdtSetFocusField @nMobile, 1
      SET @nErrNo = 272904
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to delete PackDetail record
      GOTO RollBackTran
   END CATCH

   SELECT @nPackDetailQty = COUNT(DISTINCT LabelNo)
   FROM dbo.PackDetail WITH(NOLOCK)
   WHERE PickSlipNo = @cPickSlipNo
      AND StorerKey = @cStorerKey

   SET @nPackDetailQty = ISNULL(@nPackDetailQty, 0)

   IF @nPackDetailQty = 0
   BEGIN
      BEGIN TRY
         DELETE FROM dbo.PackHeader
         WHERE PickSlipNo = @cPickSlipNo 
            AND StorerKey = @cStorerKey
      END TRY
      BEGIN CATCH
         EXEC rdt.rdtSetFocusField @nMobile, 1
         SET @nErrNo = 272905
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to delete PackHeader record
         GOTO RollBackTran
      END CATCH
   END

   IF @nPackDetailQty > 0
   BEGIN TRY
      UPDATE dbo.PackHeader WITH(ROWLOCK)
      SET 
         TTLCNTS = @nPackDetailQty,
         EditWho = SUSER_SNAME(),
         EditDate = GETDATE()
      WHERE PickSlipNo = @cPickSlipNo 
         AND StorerKey = @cStorerKey
   END TRY
   BEGIN CATCH
      EXEC rdt.rdtSetFocusField @nMobile, 1
      SET @nErrNo = 272907
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to update PackHeader TTLCNTS
      GOTO RollBackTran
   END CATCH
   
   BEGIN TRY
      UPDATE dbo.SerialNo WITH(ROWLOCK)
      SET 
         Status  = 1,
         EditWho = SUSER_SNAME(),
         EditDate = GETDATE()
      WHERE SerialNo = @cSerialNo AND Storerkey=@cStorerkey
   END TRY
   BEGIN CATCH
      EXEC rdt.rdtSetFocusField @nMobile, 1
      SET @nErrNo = 272906
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to update SerialNo's status to 1
      GOTO RollBackTran
   END CATCH

   COMMIT TRAN tran_SerialUnpack
   GOTO Quit
  

RollBackTran:
   ROLLBACK TRAN tran_SerialUnpack
Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1868UnpackConfirm TO NSQL
GO