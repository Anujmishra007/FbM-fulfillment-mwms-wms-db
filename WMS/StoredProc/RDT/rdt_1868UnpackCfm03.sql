
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1868UnpackCfm03                                 */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date         Rev   Author      Purposes                              */
/* 2026-02-20   1.0   NYE018      FCR-10102 Created                     */
/************************************************************************/


CREATE OR ALTER PROC rdt.rdt_1868UnpackCfm03 (
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
   @nTranCount       INT

   SET @nTranCount = @@TRANCOUNT

   DECLARE
   @nCartonNo      INT,
   @cLabelNo       NVARCHAR( 20),
   @cLabelLine     NVARCHAR( 10),
   @cPickDetailKey NVARCHAR( 20),
   @cSKU           NVARCHAR( 60),
   @nPackHeaderCompleted    INT


   -- transaction
   BEGIN TRAN
   SAVE TRAN tran_SerialUnpack

   SET @cLabelNo = ''
   SET @cLabelLine = ''
   SET @cPickDetailKey = ''
   SET @cSKU = ''

   SELECT @cSKU = V_SKU FROM RDT.RDTMobrec WITH (NOLOCK) WHERE Mobile = @nMobile

   SELECT  
      @nCartonNo      = CartonNo, 
      @cLabelNo       = LabelNo, 
      @cLabelLine     = LabelLine, 
      @cPickDetailKey = PickDetailKey
   FROM dbo.PackSerialNo WITH(NOLOCK)
   WHERE  SerialNo =@cSerialNo
      AND PickSlipNo =@cPickSlipNo
      AND StorerKey=@cStorerKey
      AND SKU = @cSKU -- added SKU

   IF EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND StorerKey = @cStorerKey AND Status = '9')
   BEGIN
      UPDATE dbo.PackHeader WITH(ROWLOCK)
      SET
         Status = '0',
         EditDate = GETDATE(),
         EditWho = SUSER_SNAME()
      WHERE PickSlipNo = @cPickSlipNo AND StorerKey = @cStorerKey AND Status = '9'
      SET @nErrNo = @@ERROR
      IF @nErrNo <> 0
      BEGIN
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END
       SET @nPackHeaderCompleted = 1
   END


   DELETE FROM dbo.PackSerialNo
   WHERE PickSlipNo = @cPickSlipNo AND SerialNo = @cSerialNo 
     AND StorerKey = @cStorerKey AND SKU = @cSKU -- added SKU
   SET @nErrNo = @@ERROR
   IF @nErrNo <> 0
   BEGIN
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      EXEC rdt.rdtSetFocusField @nMobile, 1
      GOTO RollBackTran
   END

   UPDATE dbo.PackDetail WITH(ROWLOCK)
   SET 
      Qty       = Qty-1,
      EditWho   = SUSER_SNAME(),
      EditDate  = GETDATE()
   WHERE PickSlipNo = @cPickSlipNo AND StorerKey = @cStorerKey
      AND CartonNo = @nCartonNo    AND Qty > 0 AND SKU = @cSKU
      AND LabelNo = @cLabelNo      AND LabelLine = @cLabelLine
   SET @nErrNo = @@ERROR
   IF @nErrNo <> 0
   BEGIN
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      EXEC rdt.rdtSetFocusField @nMobile, 1
      GOTO RollBackTran
   END

   DELETE FROM dbo.PackDetail
   WHERE PickSlipNo = @cPickSlipNo AND StorerKey = @cStorerKey 
      AND CartonNo = @nCartonNo    AND Qty=0   AND SKU = @cSKU
      AND LabelNo = @cLabelNo      AND LabelLine = @cLabelLine
   SET @nErrNo = @@ERROR
   IF @nErrNo <> 0
   BEGIN
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      EXEC rdt.rdtSetFocusField @nMobile, 1
      GOTO RollBackTran
   END

   IF NOT EXISTS( SELECT 1 FROM dbo.PackDetail WHERE PickSlipNo = @cPickSlipNo AND StorerKey = @cStorerKey)
   BEGIN
      DELETE FROM dbo.PackHeader
      WHERE PickSlipNo = @cPickSlipNo AND StorerKey = @cStorerKey
      SET @nErrNo = @@ERROR
      IF @nErrNo <> 0
      BEGIN
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO RollBackTran
      END
   END
   ELSE
   BEGIN
      IF @nPackHeaderCompleted = 1
      BEGIN
         UPDATE dbo.PackHeader WITH(ROWLOCK)
         SET
            Status = '9',
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         WHERE PickSlipNo = @cPickSlipNo AND StorerKey = @cStorerKey AND Status = '0'
         SET @nErrNo = @@ERROR
         IF @nErrNo <> 0
         BEGIN
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
            EXEC rdt.rdtSetFocusField @nMobile, 1
            GOTO RollBackTran
         END
      END
   END

   UPDATE dbo.SerialNo WITH(ROWLOCK)
   SET 
      Status  = 1,
      EditWho = SUSER_SNAME(),
      EditDate = GETDATE()
   WHERE SerialNo = @cSerialNo AND Storerkey=@cStorerkey AND SKU = @cSKU -- added SKU
   SET @nErrNo = @@ERROR
   IF @nErrNo <> 0
   BEGIN
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
      EXEC rdt.rdtSetFocusField @nMobile, 1
      GOTO RollBackTran
   END
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

GRANT EXECUTE ON RDT.rdt_1868UnpackCfm03 TO NSQL
GO