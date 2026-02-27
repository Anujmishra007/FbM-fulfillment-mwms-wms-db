
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1868UnpickCfm01                                 */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date         Rev   Author      Purposes                              */
/* 2026-02-20   1.0   NYE018      FCR-10102 Created                     */
/************************************************************************/


CREATE OR ALTER PROC rdt.rdt_1868UnpickCfm01 (
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
   @cPickDetailKey   NVARCHAR( 20),
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
   @nTranCount       INT

   SET @nTranCount = @@TRANCOUNT
   SELECT @cSKU = V_SKU FROM RDT.RDTMobrec WITH (NOLOCK) WHERE Mobile = @nMobile

   DECLARE
   @nCartonNo      INT,
   @cFromLoc       NVARCHAR( 20),
   @cFromID        NVARCHAR( 36),
   @cDropID        NVARCHAR( 40),
   @cLabelNo       NVARCHAR( 20),
   @cLabelLine     NVARCHAR( 10),
   @cOrderLineNumber  NVARCHAR( 5)

   SET @cFromLOC = ''
   SET @cFromID = ''
   SET @cDropID = ''
   SET @cLabelNo = ''

   BEGIN TRAN
   SAVE TRAN tran_SerialUnpick

   IF @cOrderKey = '' AND @cLoadKey <> ''
   BEGIN
      SELECT TOP 1
         @cFromLOC       = PD.Loc,
         @cFromID        = PD.ID,
         @cDropID        = PD.DropID,
         @cOrderLineNumber = PD.OrderLineNumber,
         @cOrderKey = LPD.OrderKey
      FROM dbo.LoadPlanDetail AS LPD WITH(NOLOCK)
      INNER JOIN dbo.PICKDETAIL AS PD WITH(NOLOCK) ON LPD.OrderKey = PD.OrderKey
      WHERE LPD.LoadKey = @cLoadKey AND PD.StorerKey = @cStorerKey 
         AND PD.PickDetailKey = @cPickDetailKey AND PD.Sku = @cSKU 
         AND PD.Qty > 0
      ORDER BY PD.AddDate ASC
   END
   ELSE
   BEGIN
      SELECT TOP 1
         @cFromLOC       = Loc,
         @cFromID        = ID,
         @cDropID        = DropID,
         @cOrderLineNumber = OrderLineNumber
      FROM dbo.PICKDETAIL WITH(NOLOCK)
      WHERE StorerKey = @cStorerKey  AND OrderKey = @cOrderKey
         AND PickDetailKey = @cPickDetailKey AND Sku = @cSKU 
         AND Qty > 0
      ORDER BY AddDate ASC
   END

   IF @cFromLOC = ''
   BEGIN
      SET @nErrNo = 259501
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  --259501^From LOC Not Exists
      GOTO RollBackTran
   END


   UPDATE dbo.PICKDETAIL WITH(ROWLOCK)
   SET Qty = Qty - 1
   WHERE StorerKey = @cStorerKey AND PickDetailKey = @cPickDetailKey
      AND OrderKey = @cOrderKey AND Qty > 0 AND SKU = @cSKU -- added SKU
   SET @nErrNo = @@ERROR
   IF @nErrNo <> 0
   BEGIN
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO RollBackTran
   END

   DELETE FROM dbo.PICKDETAIL
   WHERE StorerKey = @cStorerKey AND PickDetailKey = @cPickDetailKey
      AND OrderKey = @cOrderKey AND Qty = 0 AND SKU = @cSKU -- added SKU
   SET @nErrNo = @@ERROR
   IF @nErrNo <> 0
   BEGIN
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO RollBackTran
   END


   IF NOT EXISTS( SELECT 1 FROM  dbo.PICKDETAIL WITH(NOLOCK) WHERE StorerKey = @cStorerKey  AND OrderKey = @cOrderKey)
   BEGIN
      UPDATE dbo.PickingInfo WITH(ROWLOCK)
      SET ScanOutDate = NULL
      WHERE PickSlipNo = @cPickSlipNo
      SET @nErrNo = @@ERROR
      IF @nErrNo <> 0
      BEGIN
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END
   END




   EXECUTE rdt.rdt_Move
      @nMobile     = @nMobile,    
      @cLangCode   = @cLangCode,    
      @nErrNo      = @nErrNo  OUTPUT,    
      @cErrMsg     = @cErrMsg OUTPUT,
      @cSourceType = 'rdt_1868UnpickCfm01',
      @cStorerKey  = @cStorerKey,
      @cFacility   = @cFacility,    
      @cFromLOC    = @cFromLOC,    
      @cToLOC      = @cToLOC,    
      @cFromID     = @cFromID,    
      @cSKU        = @cSKU,
      @nQTY        = 1, 
      @nFunc       = @nFunc,    
      @cOrderKey   = @cOrderKey,    
      @cDropID     = @cDropID
   IF @nErrNo <> 0       
   BEGIN
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO RollBackTran
   END

   -- OrderDetail's status should be 0,5 no need update to 1,2,3 
   -- UPDATE dbo.OrderDetail WITH (ROWLOCK)
   -- SET [Status] = CASE WHEN ( QtyAllocated > 0) AND ( QtyPicked > 0)  AND ( QtyAllocated <> QtyPicked) THEN '3' 
   --    WHEN (OpenQty +FreeGoodQty) = (QtyAllocated+QtyPicked+ShippedQty) THEN '2' 
   --    WHEN ((OpenQty + FreeGoodQty) <> QtyAllocated + QtyPicked) AND ( QtyAllocated + QtyPicked) > 0  AND ( ShippedQty = 0) THEN '1' 
   --    WHEN ( QtyAllocated + ShippedQty + QtyPicked = 0) THEN '0' END, 
   -- EditWho = SUSER_SNAME(),
   -- EditDate = GETDATE(),
   -- TrafficCop = NULL
   -- WHERE OrderKey = @cOrderKey AND   OrderLineNumber = @cOrderLineNumber
   -- SET @nErrNo = @@ERROR
   -- IF @nErrNo <> 0
   -- BEGIN
   --    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
   --    GOTO RollBackTran
   -- END

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

GRANT EXECUTE ON RDT.rdt_1868UnpickCfm01 TO NSQL
GO