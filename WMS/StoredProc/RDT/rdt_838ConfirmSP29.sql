SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: rdt_838ConfirmSP29                                           */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Date        Rev    Author       Purposes                                      */
/* Aug-15-2025 1.0    Cuize        FCR-5513 Update refno = 'NA'                  */
/* 2025-08-27  1.0.1  JackC        FCR-5513 Only update empty refno to NA        */
/*********************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838ConfirmSP29 (
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

   DECLARE @nTranCount  INT

   SET @nTranCount = @@TRANCOUNT

   IF @nTranCount = 0
      BEGIN TRAN  -- Begin our own transaction
   ELSE
      SAVE TRAN rdt_838ConfirmSP29 -- For rollback or commit only our own transaction

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
      ,@cPackDtlUPC    = @cUCCNo         -- PackDetail.UPC = UCCNo
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


   BEGIN TRY
      UPDATE dbo.PackDetail SET
         RefNo = 'NA',
         EditDate = GETDATE(),
         EditWho = SUSER_SNAME()
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND labelNo = @cLabelNo
         AND (RefNo IS NULL OR LTRIM(RTRIM(RefNo)) = '')
   END TRY
   BEGIN CATCH
      SET @nErrNo = 244501
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDPackInfFail
      GOTO RollBackTran
   END CATCH

   IF @nTranCount = 0
      COMMIT TRAN
   ELSE
      COMMIT TRAN rdt_838ConfirmSP29
   GOTO Quit

   RollBackTran:
   BEGIN
      IF @nTranCount = 0
         ROLLBACK TRAN
      ELSE
         ROLLBACK TRAN rdt_838ConfirmSP29 -- Only rollback change made here
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

GRANT EXECUTE ON RDT.rdt_838ConfirmSP29 TO NSQL
GO
