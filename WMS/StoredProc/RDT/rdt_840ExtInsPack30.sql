SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_840ExtInsPack30                                       */
/* Copyright      : Maersk                                                    */
/* Customer       : RIMAN JPN                                                 */
/* Purpose        : Extended insert pack for fn 840 (Pack By TrackNo)        */
/*                  Configkey = ExtendedInsPackSP                             */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date         Author    Ver.    Purposes                                    */
/* 2026-08-20   DennisA   1.0.0   FCR-14958 Created                          */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_840ExtInsPack30]
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cStorerkey      NVARCHAR( 15),
   @cOrderKey       NVARCHAR( 10),
   @cPickSlipNo     NVARCHAR( 10),
   @cTrackNo        NVARCHAR( 20),
   @cSKU            NVARCHAR( 20),
   @nQty            INT,
   @nCartonNo       INT,
   @cSerialNo       NVARCHAR( 30),
   @nSerialQTY      INT,
   @cLabelNo        NVARCHAR( 20) OUTPUT,
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount         INT
   DECLARE @cUserName          NVARCHAR( 18)
   DECLARE @cLoadKey           NVARCHAR( 10)
   DECLARE @cRoute             NVARCHAR( 10)
   DECLARE @cConsigneeKey      NVARCHAR( 15)
   DECLARE @cPickDetailKey     NVARCHAR( 10)
   DECLARE @cLottable02        NVARCHAR( 18)
   DECLARE @cExtendedLabelNoSP NVARCHAR( 20)
   DECLARE @cCurLabelNo        NVARCHAR( 20)
   DECLARE @cCurLabelLine      NVARCHAR( 5)
   DECLARE @bSuccess           INT
   DECLARE @cSQL               NVARCHAR( MAX)
   DECLARE @cSQLParam          NVARCHAR( MAX)

   SET @nTranCount = @@TRANCOUNT

   SELECT
      @cUserName   = UserName,
      @cLottable02 = V_Lottable02
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile
   BEGIN TRAN
   SAVE TRAN rdt_840ExtInsPack30

   IF EXISTS (SELECT 1 FROM rdt.rdtTrackLog WITH (NOLOCK)
              WHERE PickSlipNo = @cPickSlipNo
              AND Storerkey    = @cStorerkey
              AND CartonNo     = @nCartonNo
              AND UserName     = @cUserName
              AND SKU          = @cSKU)
   BEGIN
      BEGIN TRY
         UPDATE rdt.rdtTrackLog WITH (ROWLOCK) SET
            Qty      = ISNULL(Qty, 0) + 1,
            EditWho  = @cUserName,
            EditDate = GetDate()
         WHERE PickSlipNo = @cPickSlipNo
         AND Storerkey    = @cStorerkey
         AND CartonNo     = @nCartonNo
         AND UserName     = @cUserName
         AND SKU          = @cSKU
      END TRY
      BEGIN CATCH
         SET @nErrNo = 277656
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UpdLog Failed'
         GOTO RollbackTran
      END CATCH
   END
   ELSE
   BEGIN
      BEGIN TRY
         INSERT INTO rdt.rdtTrackLog ( PickSlipNo, Mobile, UserName, Storerkey, Orderkey, TrackNo, SKU, Qty, CartonNo )
         VALUES (@cPickSlipNo, @nMobile, @cUserName, @cStorerkey, @cOrderKey, @cTrackNo, @cSKU, 1, @nCartonNo)
      END TRY
      BEGIN CATCH
         SET @nErrNo = 277657
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'InsLog Failed'
         GOTO RollbackTran
      END CATCH
   END

   -- Create PackHeader if not yet created
   IF NOT EXISTS (SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo)
   BEGIN
      SELECT @cLoadKey      = ISNULL(RTRIM(LoadKey),'')
           , @cRoute        = ISNULL(RTRIM(Route),'')
           , @cConsigneeKey = ISNULL(RTRIM(ConsigneeKey),'')
      FROM dbo.Orders WITH (NOLOCK)
      WHERE Orderkey = @cOrderkey

      BEGIN TRY
         INSERT INTO dbo.PACKHEADER
            (PickSlipNo, StorerKey, OrderKey, LoadKey, Route, ConsigneeKey, OrderRefNo, TtlCnts, [STATUS])
         VALUES
            (@cPickSlipNo, @cStorerkey, @cOrderkey, @cLoadKey, @cRoute, @cConsigneeKey, '', 0, '0')
      END TRY
      BEGIN CATCH
         SET @nErrNo = 277658
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'InsPKHDR Failed'
         GOTO RollbackTran
      END CATCH
   END

   SELECT TOP 1 @cPickDetailKey = PID.PickDetailKey
   FROM dbo.PickDetail PID WITH (NOLOCK)
   JOIN dbo.LotAttribute LA WITH (NOLOCK) ON PID.LOT = LA.LOT
   WHERE PID.Orderkey   = @cOrderKey
   AND   PID.Storerkey  = @cStorerKey
   AND   PID.Status     < '9'
   AND   PID.SKU        = @cSKU
   AND   LA.Lottable02  = @cLottable02
   AND   QtyMoved       = 0

   BEGIN TRY
      UPDATE dbo.PickDetail WITH (ROWLOCK) SET
         QtyMoved = 1, Trafficcop = NULL
      WHERE PickDetailKey = @cPickDetailKey
   END TRY
   BEGIN CATCH
      SET @nErrNo = 277659
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UpdPickDet Failed'
      GOTO RollbackTran
   END CATCH

   -- Update PackDetail.Qty if already exists
   IF EXISTS (SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)
              WHERE PickSlipNo = @cPickSlipNo
              AND CartonNo     = @nCartonNo
              AND SKU          = @cSKU)
   BEGIN
      BEGIN TRY
         UPDATE dbo.PackDetail WITH (ROWLOCK) SET
            Qty      = Qty + 1,
            EditDate = GETDATE(),
            EditWho  = 'rdt.' + sUser_sName()
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo     = @nCartonNo
         AND SKU          = @cSKU
      END TRY
      BEGIN CATCH
         SET @nErrNo = 277660
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UpdPackDet Failed'
         GOTO RollbackTran
      END CATCH
   END
   ELSE  -- Insert new PackDetail
   BEGIN
      -- Check if same carton exists before (diff SKU can scan into same carton)
      IF NOT EXISTS (SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                     AND CartonNo     = @nCartonNo)
      BEGIN
         SET @cExtendedLabelNoSP = rdt.RDTGetConfig( @nFunc, 'ExtendedLabelNoSP', @cStorerKey)
         IF @cExtendedLabelNoSP NOT IN ('0', '') AND
            EXISTS( SELECT 1 FROM sys.sysobjects WHERE name = @cExtendedLabelNoSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedLabelNoSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cOrderKey, @cPickSlipNo, @cTrackNo, @cSKU, @cLabelNo OUTPUT, @nCartonNo OUTPUT,' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT '

            SET @cSQLParam =
               '@nMobile                   INT,           ' +
               '@nFunc                     INT,           ' +
               '@cLangCode                 NVARCHAR( 3),  ' +
               '@nStep                     INT,           ' +
               '@nInputKey                 INT,           ' +
               '@cStorerkey                NVARCHAR( 15), ' +
               '@cOrderKey                 NVARCHAR( 10), ' +
               '@cPickSlipNo               NVARCHAR( 10), ' +
               '@cTrackNo                  NVARCHAR( 20), ' +
               '@cSKU                      NVARCHAR( 20), ' +
               '@cLabelNo                  NVARCHAR( 20) OUTPUT,  ' +
               '@nCartonNo                 INT           OUTPUT,  ' +
               '@nErrNo                    INT           OUTPUT,  ' +
               '@cErrMsg                   NVARCHAR( 20) OUTPUT   '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cOrderKey, @cPickSlipNo, @cTrackNo, @cSKU, @cLabelNo OUTPUT, @nCartonNo OUTPUT,
               @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'EXT UPD FAIL'
               GOTO RollbackTran
            END
         END
         ELSE
         BEGIN
            -- Get new LabelNo
            EXECUTE isp_GenUCCLabelNo
               @cStorerKey,
               @cLabelNo   OUTPUT,
               @bSuccess   OUTPUT,
               @nErrNo     OUTPUT,
               @cErrMsg    OUTPUT

            IF @bSuccess <> 1
            BEGIN
               SET @nErrNo = 76472
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'GET LABEL Fail'
               GOTO RollbackTran
            END
         END

         -- CartonNo = 0 & LabelLine = '00000', trigger will auto assign
         BEGIN TRY
            INSERT INTO dbo.PackDetail
               (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, Refno, AddWho, AddDate, EditWho, EditDate, DropID)
            VALUES
               (@cPickSlipNo, 0, @cLabelNo, '00000', @cStorerKey, @cSku, 1,
               '', 'rdt.' + sUser_sName(), GETDATE(), 'rdt.' + sUser_sName(), GETDATE(), '')
         END TRY
         BEGIN CATCH
            SET @nErrNo = 277661
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'InsPackDet Failed'
            GOTO RollbackTran
         END CATCH
      END
      ELSE
      BEGIN
         SET @cCurLabelNo   = ''
         SET @cCurLabelLine = ''

         SELECT TOP 1 @cCurLabelNo = LabelNo
         FROM dbo.PackDetail WITH (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo     = @nCartonNo

         SELECT @cCurLabelLine = RIGHT( '00000' + CAST( CAST( ISNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)
         FROM dbo.PACKDETAIL WITH (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo     = @nCartonNo

         -- Use the existing LabelNo
         BEGIN TRY
            INSERT INTO dbo.PackDetail
               (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, Refno, AddWho, AddDate, EditWho, EditDate, DropID)
            VALUES
               (@cPickSlipNo, @nCartonNo, @cCurLabelNo, @cCurLabelLine, @cStorerKey, @cSku, 1,
               '', 'rdt.' + sUser_sName(), GETDATE(), 'rdt.' + sUser_sName(), GETDATE(), '')
         END TRY
         BEGIN CATCH
            SET @nErrNo = 277662
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'InsPackDet2 Failed'
            GOTO RollbackTran
         END CATCH
      END
   END

   -- Insert PACKSERIALNO
   BEGIN TRY
      INSERT INTO dbo.PACKSERIALNO
         (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, SerialNo, QTY, Barcode)
      VALUES
         (@cPickSlipNo, @nCartonNo, ISNULL(NULLIF(@cLabelNo,''), @cCurLabelNo), @cCurLabelLine,
          @cStorerkey, @cSku, @cSerialNo, 1, @cOrderKey)
   END TRY
   BEGIN CATCH
      SET @nErrNo = 277655
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InsSerialNo Fail
      GOTO RollbackTran
   END CATCH

   GOTO Quit

RollbackTran:
   ROLLBACK TRAN rdt_840ExtInsPack30
Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_840ExtInsPack30 TO NSQL
GO
