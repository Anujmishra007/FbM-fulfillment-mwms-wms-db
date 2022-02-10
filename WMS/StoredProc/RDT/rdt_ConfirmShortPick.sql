if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_ConfirmShortPick]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [RDT].[rdt_ConfirmShortPick]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_ConfirmShortPick                                */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose: Print GS1 label                                             */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2012-03-11 1.0  Ung      SOS238698 Created                           */
/************************************************************************/

CREATE PROC rdt.rdt_ConfirmShortPick (
   @nMobile    INT,
   @nFunc      INT, 
   @cLangCode  NVARCHAR( 3),
   @cWaveKey   NVARCHAR( 10),
   @cLoadKey   NVARCHAR( 10), 
   @cOrderkey  NVARCHAR( 10),
   @nErrNo     INT  OUTPUT,
   @cErrMsg    NVARCHAR(1024) OUTPUT -- screen limitation, 20 char max
) AS

SET NOCOUNT ON
SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE @cPickDetailKey NVARCHAR( 10)
DECLARE @cPickSlipNo    NVARCHAR( 10)

DECLARE @nTranCount     INT
SET @nTranCount = @@TRANCOUNT
BEGIN TRAN
SAVE TRAN rdt_ConfirmShortPick

/*--------------------------------------------------------------------------------------------------

                                          PickDetail line

--------------------------------------------------------------------------------------------------*/
DECLARE @curPD CURSOR
IF @cOrderKey <> ''
   SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT PickDetailKey
      FROM PickDetail WITH (NOLOCK)
      WHERE OrderKey = @cOrderKey
         AND Status = '4'

IF @cLoadKey <> ''
   SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT PickDetailKey
      FROM PickDetail PD WITH (NOLOCK)
         INNER JOIN OrderDetail OD WITH (NOLOCK) ON (OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber)
      WHERE OD.LoadKey = @cLoadKey
         AND PD.Status = '4'
      
IF @cWaveKey <> ''
   SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT PickDetailKey
      FROM PickDetail PD WITH (NOLOCK)
         INNER JOIN OrderDetail OD WITH (NOLOCK) ON (OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber)
         INNER JOIN WaveDetail WD  WITH (NOLOCK) ON (OD.OrderKey = WD.OrderKey)
      WHERE WD.WaveKey = @cWaveKey
         AND PD.Status = '4'

OPEN @curPD
FETCH NEXT FROM @curPD INTO @cPickDetailKey
WHILE @@FETCH_STATUS = 0
BEGIN
   -- Unallocate
   UPDATE PickDetail SET
      QTY = 0
   WHERE PickDetailKey = @cPickDetailKey
   IF @@ERROR <> 0
   BEGIN
      SET @nErrNo = 75551
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPickDtlFail
      GOTO RollBackTran
   END

   -- Confirm short pick
   UPDATE PickDetail SET
      Status = 0
   WHERE PickDetailKey = @cPickDetailKey
   IF @@ERROR <> 0
   BEGIN
      SET @nErrNo = 75552
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPickDtlFail
      GOTO RollBackTran
   END
   FETCH NEXT FROM @curPD INTO @cPickDetailKey
END


/*--------------------------------------------------------------------------------------------------

                                             PickSlip 

--------------------------------------------------------------------------------------------------*/
DECLARE @curPickSlipNo CURSOR
IF @cOrderKey <> ''
   SET @curPickSlipNo = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT PickHeaderKey FROM PickHeader WITH (NOLOCK) WHERE OrderKey = @cOrderKey

IF @cLoadKey <> ''
   SET @curPickSlipNo = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT PickHeaderKey FROM PickHeader WITH (NOLOCK) WHERE ExternOrderKey = @cLoadKey

IF @cWaveKey <> ''
   SET @curPickSlipNo = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT PickHeaderKey 
      FROM PickHeader PH WITH (NOLOCK)
         INNER JOIN WaveDetail WD  WITH (NOLOCK) ON (PH.OrderKey = WD.OrderKey)
      WHERE WD.WaveKey = @cWaveKey

OPEN @curPickSlipNo
FETCH NEXT FROM @curPickSlipNo INTO @cPickSlipNo
WHILE @@FETCH_STATUS = 0
BEGIN
   -- Scan out
   IF EXISTS( SELECT 1 FROM dbo.PickingInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND ScanOutDate IS NULL)
   BEGIN
      UPDATE dbo.PickingInfo SET
         ScanOutDate = GETDATE()
      WHERE PickSlipNo = @cPickSlipNo
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 75553
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPickInfFail
         GOTO RollBackTran
      END
   END
   
   -- Pack confirm
   IF EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Status <> 9)
   BEGIN
      UPDATE dbo.PackHeader SET
         Status = 9
      WHERE PickSlipNo = @cPickSlipNo
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 75554
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPackHdrFail
         GOTO RollBackTran
      END
   END
   FETCH NEXT FROM @curPickSlipNo INTO @cPickSlipNo   
END

COMMIT TRAN rdt_ConfirmShortPick -- Only commit change made in rdt_ConfirmShortPick
GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_ConfirmShortPick -- Only rollback change made in rdt_ConfirmShortPick
Quit:
   -- Commit until the level we started
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN
Fail:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_ConfirmShortPick TO NSQL
GO
