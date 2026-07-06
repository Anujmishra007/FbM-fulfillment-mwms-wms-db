
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*********************************************************************************/
/* Store procedure: rdt_1868UnpickConfirm                                        */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Date         Rev   Author      Purposes                                       */
/* 2024-11-05   1.0   TLE109      FCR-917 Serial Unpack and Unpick               */
/* 2026-02-20   1.1   NYE018      UWP-48932 corrected the ErrNo & ErrMsg         */
/* 2026-07-06   1.2   NickT       UWP-60041 Add pickdetail to hold unpicked Qty  */
/*********************************************************************************/
CREATE OR ALTER PROC rdt.rdt_1868UnpickConfirm (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 5),
   @cStorerKey       NVARCHAR( 15),
   @cSerialNo        NVARCHAR( 100),
   @cPickSlipNo      NVARCHAR( 20),
   @cOrderKey        NVARCHAR( 20),
   @cPickDetailKey   NVARCHAR( 18),
   @cSKU             NVARCHAR( 40),
   @cToLOC           NVARCHAR( 20),
   @cLoadKey         NVARCHAR( 20),
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
      @cUnPickConfirmSP NVARCHAR( 20),
      @nTranCount       INT,
      @nRowCount        INT,
      @cSQL             NVARCHAR( MAX),
      @cSQLParam        NVARCHAR( MAX),
      @cUserName        NVARCHAR( 128) = SUSER_NAME()

   SET @nTranCount = @@TRANCOUNT

   SET @cUnPickConfirmSP = rdt.RDTGetConfig( @nFunc, 'UnPickConfirmSP', @cStorerKey)
   IF @cUnPickConfirmSP = '0'
   BEGIN
      SET @cUnPickConfirmSP = ''
   END
-------------------------------------------Customer---------------------------------------------

   IF @cUnPickConfirmSP <> '' AND EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cUnPickConfirmSP AND type = 'P')
   BEGIN
      SET @cSQL = 'EXEC rdt.' + RTRIM( @cUnPickConfirmSP) +
      ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' +
      ' @cSerialNo, @cPickSlipNo, @cOrderKey, @cPickDetailKey, @cSKU, @cToLOC, @cLoadKey, ' +
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
      ' @cOrderKey      NVARCHAR( 20), ' +
      ' @cPickDetailKey NVARCHAR( 20), ' +
      ' @cSKU           NVARCHAR( 40), ' +
      ' @cToLOC         NVARCHAR( 20), ' +
      ' @cLoadKey       NVARCHAR( 20), ' +
      ' @nErrNo         INT  OUTPUT,   ' +
      ' @cErrMsg        NVARCHAR( 20)  OUTPUT  ' 

      EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
         @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,
         @cSerialNo, @cPickslipNo, @cOrderKey, @cPickDetailKey, @cSKU, @cToLOC, @cLoadKey,
         @nErrNo OUTPUT, @cErrMsg OUTPUT
      IF @nErrNo <> 0
      BEGIN
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      END
      GOTO Quit 
   END

-------------------------------------------Standard---------------------------------------------
   DECLARE
      @nCartonNo              INT,
      @bsuccess               INT,
      @cFromLoc               NVARCHAR( 20),
      @cFromID                NVARCHAR( 36),
      @cDropID                NVARCHAR( 40),
      @cLabelNo               NVARCHAR( 20),
      @cLot                   NVARCHAR( 10),
      @cLabelLine             NVARCHAR( 10),
      @cOrderLineNumber       NVArCHAR( 5),
      @cNewPickDetailKey      NVARCHAR( 18),
      @cReducedPickDetailQty  NVARCHAR( 1) = 'N',
      @cPSLoadKey             NVARCHAR( 10),
      @cPSOrderKey            NVARCHAR( 10),
      @cPSZone                NVARCHAR( 18),
      @cPickConfirmStatus     NVARCHAR(1),
      @cScanOut               NVARCHAR(1)

   SET @cFromLOC = ''
   SET @cFromID = ''
   SET @cDropID = ''
   SET @cLabelNo = ''

   SET @cPSOrderKey = ''
   SET @cPSLoadKey = ''
   SET @cPSZone = ''
   SET @cScanOut = 'Y'

   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'

   SELECT TOP 1
      @cPSOrderKey = OrderKey,
      @cPSLoadKey = ExternOrderKey,
      @cPSZone = Zone
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   BEGIN TRAN
   SAVE TRAN tran_SerialUnpick

   IF @cOrderKey = '' AND @cLoadKey <> ''
   BEGIN
      SELECT TOP 1
         @cFromLOC       = PD.Loc,
         @cFromID        = PD.ID,
         @cDropID        = PD.DropID,
         @cOrderLineNumber = PD.OrderLineNumber,
         @cOrderKey = LPD.OrderKey,
         @cLot = PD.Lot
      FROM dbo.LoadPlanDetail AS LPD WITH(NOLOCK)
      INNER JOIN dbo.PICKDETAIL AS PD WITH(NOLOCK) ON LPD.OrderKey = PD.OrderKey
      WHERE LPD.LoadKey = @cLoadKey AND PD.StorerKey = @cStorerKey 
         AND PD.PickDetailKey = @cPickDetailKey AND PD.Sku = @cSKU 
         AND PD.Qty > 0
      ORDER BY PD.AddDate ASC
      SELECT @nRowCount = @@ROWCOUNT
   END
   ELSE
   BEGIN
      SELECT TOP 1
         @cFromLOC       = Loc,
         @cFromID        = ID,
         @cDropID        = DropID,
         @cOrderLineNumber = OrderLineNumber,
         @cLot = Lot
      FROM dbo.PICKDETAIL WITH(NOLOCK)
      WHERE StorerKey = @cStorerKey  AND OrderKey = @cOrderKey
         AND PickDetailKey = @cPickDetailKey AND Sku = @cSKU 
         AND Qty > 0
      ORDER BY AddDate ASC
      SELECT @nRowCount = @@ROWCOUNT
   END

   IF @nRowCount = 0 OR ISNULL(@cFromLOC, '') = ''
   BEGIN
      SET @nErrNo = 272601
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  -- No available PickDetail record exists
      GOTO RollBackTran
   END

   BEGIN TRY
      UPDATE dbo.PICKDETAIL WITH(ROWLOCK)
      SET Qty = Qty - 1
      WHERE PickDetailKey = @cPickDetailKey
         AND StorerKey = @cStorerKey
         AND OrderKey = @cOrderKey 
         AND Qty > 0

      IF @@ROWCOUNT > 0
         SET @cReducedPickDetailQty = 'Y'
   END TRY
   BEGIN CATCH
      SET @nErrNo = 272602
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to reduce PickDetail Qty
      GOTO RollBackTran
   END CATCH

   -- Cross dock PickSlip
   IF @cPSZone IN ('XD', 'LB', 'LP') 
   BEGIN
      IF EXISTS( SELECT 1
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
            INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND PD.QTY > 0
               AND (PD.Status = '4' OR PD.Status < @cPickConfirmStatus))
      BEGIN
         SET @cScanOut = 'N'
      END
   END
   -- Discrete PickSlip
   ELSE IF @cPSOrderKey <> '' 
   BEGIN
      IF EXISTS( SELECT 1
               FROM dbo.PickDetail PD WITH (NOLOCK)
               INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               WHERE PD.OrderKey = @cOrderKey
                  AND PD.QTY > 0
                  AND (PD.Status = '4' OR PD.Status < @cPickConfirmStatus))
      BEGIN
         SET @cScanOut = 'N'
      END
   END
   -- Conso PickSlip
   ELSE IF @cPSLoadKey <> ''
   BEGIN
      -- Check outstanding PickDetail
      IF EXISTS( SELECT 1
         FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
         INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
         INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
         WHERE LPD.LoadKey = @cLoadKey
            AND PD.QTY > 0
            AND (PD.Status = '4' OR PD.Status < @cPickConfirmStatus))
      BEGIN
         SET @cScanOut = 'N'
      END
   END

   IF @cScanOut = 'N'
   BEGIN
      BEGIN TRY
         UPDATE dbo.PickingInfo WITH(ROWLOCK)
         SET ScanOutDate = NULL
         WHERE PickSlipNo = @cPickSlipNo
      END TRY
      BEGIN CATCH
         SET @nErrNo = 272604
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to update ScanOutDate to NULL in PickingInfo
         GOTO RollBackTran
      END CATCH
   END

   BEGIN TRY
      EXECUTE rdt.rdt_Move
         @nMobile     = @nMobile,    
         @cLangCode   = @cLangCode,    
         @nErrNo      = @nErrNo  OUTPUT,    
         @cErrMsg     = @cErrMsg OUTPUT,
         @cSourceType = 'rdt_1868UnpickConfirm',
         @cStorerKey  = @cStorerKey,
         @cFacility   = @cFacility,    
         @cFromLOC    = @cFromLOC,    
         @cToLOC      = @cToLOC,    
         @cFromID     = @cFromID,    
         @cFromLOT    = @cLot,
         @cSKU        = @cSKU,
         @nQTY        = 1, 
         @nFunc       = @nFunc,    
         @cOrderKey   = @cOrderKey,    
         @cDropID     = @cDropID
   END TRY
   BEGIN CATCH
      SET @nErrNo = 272605
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to move the item to the new location
      GOTO RollBackTran
   END CATCH

   IF @nErrNo <> 0
   BEGIN
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO RollBackTran
   END

   -- Generate new pickdetail record to hold the reduced qty
   -- if new pickdetail record is generated, increase the qty of the new record by 1
   IF @cReducedPickDetailQty = 'Y'
   BEGIN
      SELECT TOP 1 @cNewPickDetailKey = PickDetailKey
      FROM dbo.PICKDETAIL WITH(NOLOCK)
      WHERE StorerKey = @cStorerKey 
         AND OrderKey = @cOrderKey
         AND OrderLineNumber = @cOrderLineNumber
         AND Status = '0'
         AND Qty > 0
         AND Sku = @cSKU 
         AND Loc = @cToLOC 
         AND Lot = @cLot
         AND ID = ''
      ORDER BY AddDate DESC
      SELECT @nRowCount = @@ROWCOUNT

      IF @nRowCount = 0 OR ISNULL(@cNewPickDetailKey, '') = ''
      BEGIN
         SET @bsuccess = 1
         EXECUTE dbo.nspg_GetKey
            'PICKDETAILKEY',
            10 ,
            @cNewPickDetailKey   OUTPUT,
            @bsuccess            OUTPUT,
            @nErrNo              OUTPUT,
            @cErrMsg             OUTPUT

         IF @bsuccess <> 1 OR ISNULL(@cNewPickDetailKey, '') = ''
         BEGIN
            SET @nErrNo = 272606
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to generate PickDetailKey
            GOTO RollBackTran
         END

         IF @nErrNo <> 0
            GOTO RollBackTran

         BEGIN TRY
            -- Create a new PickDetail to hold the balance
            INSERT INTO dbo.PICKDETAIL (
               CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM, UOMQTY, QTYMoved,
               Status, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType, ToLoc, DoReplenish, ReplenishZone,
               DoCartonize, PickMethod, WaveKey, EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, PickDetailKey,
               QTY,
               TrafficCop,
               OptimizeCop)
            SELECT
               CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot, StorerKey, SKU, AltSku, UOM, UOMQTY, QTYMoved,
               '0', DropID, @cToLOC, '', PackKey, UpdateSource, CartonGroup, CartonType, ToLoc, DoReplenish, ReplenishZone,
               DoCartonize, PickMethod, WaveKey, EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, @cNewPickDetailKey,
               1,
               NULL, --TrafficCop,
               '1'  --OptimizeCop
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE PickDetailKey = @cPickDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 272607
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to insert new PickDetail record
            GOTO RollBackTran
         END CATCH
      END
      ELSE
      BEGIN
         BEGIN TRY
            UPDATE dbo.PICKDETAIL WITH(ROWLOCK)
            SET 
               Qty = Qty + 1,
               EditDate = GETDATE(),
               EditWho = @cUserName
            WHERE PickDetailKey = @cNewPickDetailKey
               AND StorerKey = @cStorerKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 272608
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to increase PickDetail Qty
            GOTO RollBackTran
         END CATCH
      END
   END

   BEGIN TRY
      DELETE FROM dbo.PICKDETAIL
      WHERE StorerKey = @cStorerKey 
         AND PickDetailKey = @cPickDetailKey
         AND OrderKey = @cOrderKey 
         AND Qty = 0
   END TRY
   BEGIN CATCH
      SET @nErrNo = 272603
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Fail to delete PickDetailKey record
      GOTO RollBackTran
   END CATCH

   COMMIT TRAN tran_SerialUnpick
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN tran_SerialUnpick
Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1868UnpickConfirm TO NSQL
GO