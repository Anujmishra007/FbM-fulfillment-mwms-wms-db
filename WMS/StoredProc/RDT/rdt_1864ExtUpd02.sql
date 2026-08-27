SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/**********************************************************************************************/
/*   Stored procedure : rdt_1864ExtUpd02                                                      */
/*   Type             : RDT ExtendedUpdateSP  (storer config ConfigKey = ExtendedUpdateSP)    */
/*   Creation Date    : 12-08-2026                                                            */
/*   Author           : PFI025                                                                */
/*   Written by       : PFI025                                                                */             
/*   Purpose          : Generate PackHeader / PackDetail rows for EDI after the last pick     */  
/*                      confirm of an order (custom UPDATE hook).                             */
/*                                                                                            */
/*   Description:                                                                             */
/*   Runs AFTER picking is already fully complete (PickDetail.Status = '5' on every line for  */
/*   the order). This SP does not confirm anything and does not touch PickDetail.Status.      */
/*   Its only job: once the order has nothing left unpicked, generate PackHeader/PackDetail.  */
/*   rows (Status = '9' = packed) for EDI. No zones, no move, no UCC, no serial, no printing, */
/*   no EDI transmit-log calls - this only writes pack data; whatever downstream process reads*/
/*   it for EDI runs separately.                                                              */
/*   Safe to be triggered more than once for the same pickslip - already-packed DropID+SKU.   */
/*   combinations are skipped, so it will not duplicate rows.                                 */
/*                                                                                            */
/*   Trigger step:                                                                            */
/*   Gated on @nFunc = 1864 AND @nStep = 5 - the step that fires after the LAST pick confirm. */
/*   Adjust if your step numbering differs.                                                   */
/*                                                                                            */
/*   Change log:                                                                              */
/*   v1.0  12-08-2026  PFI025  Initial version (implemented as ExtendedInfoSP).               */
/*   v2.0  27-08-2026  PFI025  Code-review rework (FCR-15582 / RITM9062445):                  */
/*                             - Converted from ExtendedInfoSP to ExtendedUpdateSP;           */
/*                             - Removed the @cExtendedInfo OUTPUT parameter                  */
/*                             - Renamed per coding convention: rdt_1864ExtUpd02.             */
/*   v2.1  27-08-2026  PFI025  Re-numbered error codes to the newly assigned message range    */
/*                             279351-279400 (was 261001-261004):                             */
/*                               279351 Cleanup Stale Pack Fail                               */
/*                               279352 Insert PackHeader Fail                                */
/*                               279353 Update PackHeader Status Fail                         */
/*                               279354 Insert PackDetail Fail                                */
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

   -- Order fully picked? If any line is still outstanding, do nothing yet.
   IF EXISTS (
      SELECT 1 FROM dbo.PickDetail WITH (NOLOCK)
      WHERE OrderKey = @cOrderKey
         AND QTY > 0
         AND Status <> '4'
         AND Status < '5'
   )
      RETURN

   BEGIN TRAN
   SAVE TRAN rdt_1864ExtUpd02

   -- Clean up stale pack data from a PRIOR pick cycle for this order
   BEGIN TRY
      DELETE PDT
      FROM dbo.PackDetail PDT
      JOIN dbo.PackHeader PH ON PH.PickSlipNo = PDT.PickSlipNo
      WHERE PH.OrderKey = @cOrderKey
         AND PH.PickSlipNo <> @cPickSlipNo

      DELETE FROM dbo.PackHeader
      WHERE OrderKey = @cOrderKey
         AND PickSlipNo <> @cPickSlipNo
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 279351
      SET @cErrMsg = 'Cleanup Stale Pack Fail'
      GOTO RollBackTran
   END CATCH

   IF NOT EXISTS (SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo)
   BEGIN
      BEGIN TRY
         INSERT INTO dbo.PackHeader (PickSlipNo, StorerKey, OrderKey, LoadKey, Status)
         VALUES (@cPickSlipNo, @cStorerKey, @cOrderKey, @cLoadKey, '9')
      END TRY
      BEGIN CATCH
         SET @nErrNo  = 279352
         SET @cErrMsg = 'Insert PackHeader Fail'
         GOTO RollBackTran
      END CATCH
   END
   ELSE
   BEGIN
      BEGIN TRY
         UPDATE dbo.PackHeader SET
            Status = '9'
         WHERE PickSlipNo = @cPickSlipNo
            AND Status <> '9'
      END TRY
      BEGIN CATCH
         SET @nErrNo  = 279353
         SET @cErrMsg = 'Update PackHeader Status Fail'
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
      SET @nErrNo  = 279354
      SET @cErrMsg = 'Insert PackDetail Fail'
      GOTO RollBackTran
   END CATCH

   COMMIT TRAN rdt_1864ExtUpd02
   GOTO Quit

RollBackTran:
   IF (XACT_STATE()) = -1
   BEGIN
      IF @nTranCount = 0
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

