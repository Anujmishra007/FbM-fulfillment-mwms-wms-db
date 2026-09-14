SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/********************************************************************************/
/* Store procedure: rdt_994PackCfmSP01                                          */
/* Copyright      : Maersk                                                      */
/*                                                                              */
/* Purpose: AEOMX                                                               */
/*                                                                              */
/* Date       Rev      Author      Purposes                                     */
/* 2026-09-12 1.0.0.   NYE018.     FCR-16295  use pickslipno instead of dropid. */
/********************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_994PackCfmSP01] (
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR(  3)
   ,@nStep           INT
   ,@nInputKey       INT
   ,@cFacility       NVARCHAR(  5)
   ,@cStorerKey      NVARCHAR( 15)
   ,@cPickSlipNo     NVARCHAR( 10)
   ,@cFromDropID     NVARCHAR( 20)
   ,@cPackDtlDropID  NVARCHAR( 20)
   ,@cPrintPackList  NVARCHAR(  1) OUTPUT
   ,@nErrNo          INT           OUTPUT
   ,@cErrMsg         NVARCHAR(250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag  INT = 0

   DECLARE @bSuccess           INT
   DECLARE @cLoadKey           NVARCHAR( 10)
   DECLARE @cOrderKey          NVARCHAR( 10)
   DECLARE @cZone              NVARCHAR( 18)
   DECLARE @nPackQTY           INT
   DECLARE @nPickQTY           INT
   DECLARE @cPickStatus        NVARCHAR(1)
   DECLARE @cPackConfirm       NVARCHAR(1)
   DECLARE @cPackByFromDropID  NVARCHAR(1)

   DECLARE @tPickDetail TABLE (
      PickDetailKey NVARCHAR(18)
   )

   SET @cOrderKey   = ''
   SET @cLoadKey    = ''
   SET @cZone       = ''
   SET @cPackConfirm = ''
   SET @nPackQTY    = 0
   SET @nPickQTY    = 0

   -- Storer config
   SET @cPickStatus = rdt.rdtGetConfig(@nFunc, 'PickStatus', @cStorerKey)
   IF @cPickStatus = '0'
      SET @cPickStatus = '5'

   SET @cPackByFromDropID = rdt.rdtGetConfig(@nFunc, 'PackByFromDropID', @cStorerKey)

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_994PackCfmSP01', @cPickSlipNo AS PickSlipNo, @cFromDropID AS FromDropID

   -- Guard: this SP is not compatible with PackByFromDropID mode
   IF @cPackByFromDropID = '1'
   BEGIN
      SET @nErrNo  = 281201
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Pack by FromDropID is enabled
      GOTO Quit
   END

   -- Guard: already confirmed
   IF EXISTS(SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Status = '9')
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Pack was closed. Return'
      GOTO Quit
   END

   -- Get PickHeader info
   SELECT TOP 1
      @cOrderKey = OrderKey,
      @cLoadKey  = ExternOrderKey,
      @cZone     = Zone
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   -- Calc total packed qty
   SELECT @nPackQTY = ISNULL(SUM(QTY), 0)
   FROM dbo.PackDetail WITH (NOLOCK)
   WHERE PickSlipNo = @cPickSlipNo

   ---------------------------------------------------------------------------
   -- StepA: Determine whether PickSlipNo is fully picked and packed
   ---------------------------------------------------------------------------

   -- Cross dock PickSlip
   IF @cZone IN ('XD', 'LB', 'LP')
   BEGIN
      IF EXISTS(SELECT TOP 1 1
         FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
         WHERE RKL.PickSlipNo = @cPickSlipNo
            AND PD.Status < '5'
            AND PD.QTY > 0
            AND (PD.Status = '4' OR PD.Status <> @cPickStatus))  -- Short or not yet picked
         SET @cPackConfirm = 'N'
      ELSE
         SET @cPackConfirm = 'Y'

      IF @cPackConfirm = 'Y'
      BEGIN
         SELECT @nPickQTY = SUM(QTY)
         FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
         WHERE RKL.PickSlipNo = @cPickSlipNo

         IF @nPickQTY <> @nPackQTY
            SET @cPackConfirm = 'N'
      END
   END

   -- Discrete PickSlip
   ELSE IF @cOrderKey <> ''
   BEGIN
      IF EXISTS(SELECT TOP 1 1
         FROM dbo.PickDetail PD WITH (NOLOCK)
         WHERE PD.OrderKey = @cOrderKey
            AND PD.Status < '5'
            AND PD.QTY > 0
            AND (PD.Status = '4' OR PD.Status <> @cPickStatus))  -- Short or not yet picked
         SET @cPackConfirm = 'N'
      ELSE
         SET @cPackConfirm = 'Y'

      IF @cPackConfirm = 'Y'
      BEGIN
         SELECT @nPickQTY = SUM(PD.QTY)
         FROM dbo.PickDetail PD WITH (NOLOCK)
         WHERE PD.OrderKey = @cOrderKey

         IF @nPickQTY <> @nPackQTY
            SET @cPackConfirm = 'N'
      END
   END

   -- Conso PickSlip
   ELSE IF @cLoadKey <> ''
   BEGIN
      IF EXISTS(SELECT TOP 1 1
         FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON (LPD.OrderKey = PD.OrderKey)
         WHERE LPD.LoadKey = @cLoadKey
            AND PD.Status < '5'
            AND PD.QTY > 0
            AND (PD.Status = '4' OR PD.Status <> @cPickStatus))  -- Short or not yet picked
         SET @cPackConfirm = 'N'
      ELSE
         SET @cPackConfirm = 'Y'

      IF @cPackConfirm = 'Y'
      BEGIN
         SELECT @nPickQTY = SUM(PD.QTY)
         FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON (LPD.OrderKey = PD.OrderKey)
         WHERE LPD.LoadKey = @cLoadKey

         IF @nPickQTY <> @nPackQTY
            SET @cPackConfirm = 'N'
      END
   END

   -- Custom PickSlip
   ELSE
   BEGIN
      IF EXISTS(SELECT TOP 1 1
         FROM dbo.PickDetail PD WITH (NOLOCK)
         WHERE PD.PickSlipNo = @cPickSlipNo
            AND PD.Status < '5'
            AND PD.QTY > 0
            AND (PD.Status = '4' OR PD.Status <> @cPickStatus))  -- Short or not yet picked
         SET @cPackConfirm = 'N'
      ELSE
         SET @cPackConfirm = 'Y'

      IF @cPackConfirm = 'Y'
      BEGIN
         SELECT @nPickQTY = SUM(PD.QTY)
         FROM dbo.PickDetail PD WITH (NOLOCK)
         WHERE PD.PickSlipNo = @cPickSlipNo

         IF @nPickQTY <> @nPackQTY
            SET @cPackConfirm = 'N'
      END
   END

   IF @nDebugFlag = 1
      SELECT 'Pack confirm check result', @cPackConfirm AS PackConfirm

   ---------------------------------------------------------------------------
   -- StepB: Not fully packed — nothing to do
   ---------------------------------------------------------------------------
   IF @cPackConfirm <> 'Y'
      GOTO Quit

   ---------------------------------------------------------------------------
   -- StepC: Fully packed — collect PickDetail keys then commit updates
   ---------------------------------------------------------------------------

   -- Collect PickDetail records for this PickSlipNo that are ready to close
   BEGIN TRY
      IF @cZone IN ('XD', 'LB', 'LP')
         INSERT INTO @tPickDetail (PickDetailKey)
         SELECT PD.PickDetailKey
         FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
         WHERE RKL.PickSlipNo = @cPickSlipNo
            AND PD.Status = @cPickStatus
            AND PD.Qty > 0

      ELSE IF @cOrderKey <> ''
         INSERT INTO @tPickDetail (PickDetailKey)
         SELECT PickDetailKey
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE OrderKey = @cOrderKey
            AND Status = @cPickStatus
            AND Qty > 0

      ELSE IF @cLoadKey <> ''
         INSERT INTO @tPickDetail (PickDetailKey)
         SELECT PD.PickDetailKey
         FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON (LPD.OrderKey = PD.OrderKey)
         WHERE LPD.LoadKey = @cLoadKey
            AND PD.Status = @cPickStatus
            AND PD.Qty > 0

      ELSE
         INSERT INTO @tPickDetail (PickDetailKey)
         SELECT PickDetailKey
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
            AND Status = @cPickStatus
            AND Qty > 0
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 281202
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END CATCH

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Start StepC updates', @cPickSlipNo AS PickSlipNo
      SELECT * FROM @tPickDetail
   END

   -- Transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN
   SAVE TRAN rdt_994PackCfmSP01

   -- Update PickDetail: set DropID = CaseID and stamp Notes as [PACKED]
   BEGIN TRY
      UPDATE PD WITH (ROWLOCK)
      SET PD.DropID      = PD.CaseID,
          --PD.Notes       = ISNULL(PD.Notes, '') + '[PACKED]',
          PD.EditDate    = GETDATE(),
          PD.EditWho     = SUSER_SNAME(),
          PD.TrafficCop  = NULL
      FROM dbo.PickDetail PD
      JOIN @tPickDetail tPD ON (PD.PickDetailKey = tPD.PickDetailKey)
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 281203
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
      GOTO RollBackTran
   END CATCH

   -- Update PickDetail status separately to avoid PICK-TRF config constraint
   BEGIN TRY
      UPDATE PD WITH (ROWLOCK)
      SET PD.[Status] = '5',
          PD.EditDate = GETDATE(),
          PD.EditWho  = SUSER_SNAME()
      FROM dbo.PickDetail PD
      JOIN @tPickDetail tPD ON (PD.PickDetailKey = tPD.PickDetailKey)
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 281204
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
      GOTO RollBackTran
   END CATCH

   -- Confirm pack: close PackHeader
   BEGIN TRY
      UPDATE dbo.PackHeader SET
         Status = '9'
      WHERE PickSlipNo = @cPickSlipNo
         AND Status <> '9'
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 281205
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- PackCfm Fail
      GOTO RollBackTran
   END CATCH

   COMMIT TRAN rdt_994PackCfmSP01
   GOTO Quit

   RollBackTran:
      IF XACT_STATE() = -1
         ROLLBACK TRAN
      ELSE IF XACT_STATE() = 1
         ROLLBACK TRAN rdt_994PackCfmSP01

   Quit:
      IF @nDebugFlag = 1
         SELECT 'Quit', @nErrNo, @cErrMsg
      WHILE @@TRANCOUNT > @nTranCount
         COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_994PackCfmSP01] TO [NSQL]
GO
