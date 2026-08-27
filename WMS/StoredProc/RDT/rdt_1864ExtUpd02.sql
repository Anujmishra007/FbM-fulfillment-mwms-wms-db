SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/**********************************************************************************************/
/* Store procedure: rdt_1864ExtUpd02                                                          */
/* Copyright: Maersk                                                                          */
/* Customer : EVEREST                                                                         */
/*                                                                                            */
/* Purpose:                                                                                   */
/*   RDT ExtendedUpdateSP (storer config ConfigKey = ExtendedUpdateSP) for Function 1864,     */
/*   Step 5. After the last pick confirm of an order, generate PackHeader / PackDetail rows   */
/*   (Status = '9' = packed) for downstream ASN/EDI. Idempotent - re-runs skip already-packed */
/*   DropID+SKU combinations, so no duplicate rows are created.                               */
/*                                                                                            */
/* Date         Author  Ver.  Purposes                                                        */
/* 2026-08-27   PFI025  1.0   Generate PackHeader/PackDetail after final pick confirm (EDI).   */
/**********************************************************************************************/
CREATE OR ALTER PROCEDURE [RDT].[rdt_1864ExtUpd02]
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @nStep         INT,
   @nAfterStep    INT,
   @nInputKey     INT,
   @cFacility     NVARCHAR( 5),
   @cStorerKey    NVARCHAR( 15),
   @cPickSlipNo   NVARCHAR( 10),
   @cPickZone     NVARCHAR( 10),
   @cSuggLOC      NVARCHAR( 10),
   @cLOC          NVARCHAR( 10),
   @cID           NVARCHAR( 18),
   @cSKU          NVARCHAR( 20),
   @cLottable01   NVARCHAR( 18),
   @cLottable02   NVARCHAR( 18),
   @cLottable03   NVARCHAR( 18),
   @dLottable04   DATETIME,
   @dLottable05   DATETIME,
   @cLottable06   NVARCHAR( 30),
   @cLottable07   NVARCHAR( 30),
   @cLottable08   NVARCHAR( 30),
   @cLottable09   NVARCHAR( 30),
   @cLottable10   NVARCHAR( 30),
   @cLottable11   NVARCHAR( 30),
   @cLottable12   NVARCHAR( 30),
   @dLottable13   DATETIME,
   @dLottable14   DATETIME,
   @dLottable15   DATETIME,
   @nTaskQTY      INT,
   @cToLOC        NVARCHAR( 10),
   @cOption       NVARCHAR( 1),
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @nErrNo  = 0
   SET @cErrMsg = ''

   IF @nFunc <> 1864 OR @nStep <> 5
      RETURN  -- not the hook point we care about - no-op

   DECLARE @cOrderKey  NVARCHAR( 20)
   DECLARE @cLoadKey   NVARCHAR( 20)
   DECLARE @nTranCount INT = @@TRANCOUNT

   SELECT
      @cOrderKey = OrderKey,
      @cLoadKey  = LoadKey
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   IF @cOrderKey IS NULL OR @cOrderKey = ''
      RETURN  -- nothing to associate the completeness check with

   -- Order fully picked? If any line has not yet reached status '5', do nothing yet.
   -- Status '4' is treated as outstanding and therefore blocks pack generation.
   IF EXISTS (
      SELECT 1 FROM dbo.PickDetail WITH (NOLOCK)
      WHERE OrderKey = @cOrderKey
         AND QTY > 0
         AND Status < '5'
   )
      RETURN

   BEGIN TRAN
   SAVE TRAN rdt_1864ExtUpd02

   -- Clean up stale PackDetail from a PRIOR pick cycle for this order
   BEGIN TRY
      DELETE PDT
      FROM dbo.PackDetail PDT
      JOIN dbo.PackHeader PH ON PH.PickSlipNo = PDT.PickSlipNo
      WHERE PH.OrderKey = @cOrderKey
         AND PH.PickSlipNo <> @cPickSlipNo
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 279351
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  -- Cleanup Stale PackDetail Fail
      GOTO RollBackTran
   END CATCH

   -- Clean up stale PackHeader from a PRIOR pick cycle for this order
   BEGIN TRY
      DELETE FROM dbo.PackHeader
      WHERE OrderKey = @cOrderKey
         AND PickSlipNo <> @cPickSlipNo
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 279352
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  -- Cleanup Stale PackHeader Fail
      GOTO RollBackTran
   END CATCH

   IF NOT EXISTS (SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo)
   BEGIN
      BEGIN TRY
         INSERT INTO dbo.PackHeader (PickSlipNo, StorerKey, OrderKey, LoadKey, Status)
         VALUES (@cPickSlipNo, @cStorerKey, @cOrderKey, @cLoadKey, '9')
      END TRY
      BEGIN CATCH
         SET @nErrNo  = 279353
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  -- Insert PackHeader Fail
         GOTO RollBackTran
      END CATCH
   END
   ELSE
   BEGIN
      BEGIN TRY
         UPDATE dbo.PackHeader WITH (ROWLOCK) SET
            Status = '9'
         WHERE PickSlipNo = @cPickSlipNo
            AND Status <> '9'
      END TRY
      BEGIN CATCH
         SET @nErrNo  = 279354
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  -- Update PackHeader Status Fail
         GOTO RollBackTran
      END CATCH
   END

   BEGIN TRY
      INSERT INTO dbo.PackDetail
         (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, DropID,
          AddWho, AddDate, EditWho, EditDate)
      SELECT
         @cPickSlipNo,
         DENSE_RANK() OVER (ORDER BY PD.DropID),
         PD.DropID,       -- LabelNo = DropID; no separate license-plate generation
         '00000',
         PD.StorerKey,
         PD.SKU,
         SUM(PD.QTY),
         PD.DropID,
         SUSER_SNAME(), GETDATE(), SUSER_SNAME(), GETDATE()
      FROM dbo.PickDetail PD WITH (NOLOCK)
      WHERE PD.OrderKey = @cOrderKey
         AND PD.Status = '5'
         AND PD.DropID <> ''
         AND NOT EXISTS (
            SELECT 1 FROM dbo.PackDetail PDT WITH (NOLOCK)
            WHERE PDT.PickSlipNo = @cPickSlipNo
               AND PDT.LabelNo = PD.DropID
               AND PDT.SKU = PD.SKU
         )
      GROUP BY PD.DropID, PD.SKU, PD.StorerKey
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 279355
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  -- Insert PackDetail Fail
      GOTO RollBackTran
   END CATCH

   COMMIT TRAN rdt_1864ExtUpd02
   GOTO Quit

RollBackTran:
   IF (XACT_STATE()) = -1
   BEGIN
      ROLLBACK TRANSACTION;
   END
   IF (XACT_STATE()) = 1
   BEGIN
      IF @nTranCount > 0
         ROLLBACK TRANSACTION rdt_1864ExtUpd02;
      ELSE
         ROLLBACK TRANSACTION;
   END

Quit:
   WHILE @@TRANCOUNT > @nTranCount AND XACT_STATE() = 1
      COMMIT TRAN

   IF XACT_STATE() = -1 AND @nTranCount = 0
      ROLLBACK TRANSACTION;
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [RDT].[rdt_1864ExtUpd02] TO NSQL
GO
