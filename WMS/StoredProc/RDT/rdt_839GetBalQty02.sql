
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/******************************************************************************/
/* Store procedure: rdt_839GetBalQty02                                        */
/* Copyright      : Maersk                                                    */
/* Customer       : PAGEIND                                                   */
/* copied from rdt_839GetBalQty01.sql and modified for PAGEIND                */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2026-08-21 1.1  NYE018     FCR-12865 consider scenario of no serial no.    */
/******************************************************************************/
    
CREATE OR ALTER PROC rdt.rdt_839GetBalQty02 (
   @nMobile                   INT,                
   @nFunc                     INT,                
   @cLangCode                 NVARCHAR( 3),       
   @nStep                     INT,                
   @nInputKey                 INT,                
   @cFacility                 NVARCHAR( 5) ,      
   @cStorerKey                NVARCHAR( 15),
   @cPickSlipNo               NVARCHAR( 10),
   @cLot                      NVARCHAR( 20), 
   @cLOC                      NVARCHAR( 10),
   @cSKU                      NVARCHAR( 20),
   @nTotalLocReqQty           INT           OUTPUT,
   @nTotalLocPickedQty        INT           OUTPUT,
   @nTotalPSNReqQty           INT           OUTPUT,
   @nTotalPSNPickedQty        INT           OUTPUT,
   @nErrNo                    INT           OUTPUT,
   @cErrMsg                   NVARCHAR(250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cPickConfirmStatus NVARCHAR( 1) = ''
   DECLARE @cOrderKey  NVARCHAR(10) = ''
   DECLARE @cLoadKey   NVARCHAR(10) = ''
   DECLARE @cZone      NVARCHAR(18) = ''

   -- Get storer config
   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'

   -- Get PickHeader info
   SELECT TOP 1
      @cOrderKey = OrderKey,
      @cLoadKey = ExternOrderKey,
      @cZone = Zone
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   DECLARE @nQty     INT = 0

   SET @nErrNo = 0
   SET @cErrMsg = ''
   SET @nTotalPSNReqQty = 0
   SET @nTotalPSNPickedQty = 0
   SET @nTotalLocReqQty = 0
   SET @nTotalLocPickedQty = 0

   IF @cZone IN ('XD', 'LB', 'LP')
   BEGIN
      --LOC
      BEGIN
         -- Total piece Required Qty
         BEGIN
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(PD.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND PD.LOC = @cLOC
               AND PD.UOM = '6'
               AND PD.Status <> '4'
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)

            SET @nTotalLocReqQty += @nQty
         END

         -- Total UCC Required Qty
         BEGIN
            --1. Not picked yet
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(UCC.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON (PD.DropID = UCC.UCCNo AND PD.StorerKey = UCC.StorerKey AND PD.Lot = UCC.LOT)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND PD.LOC = @cLOC
               AND PD.UOM = '2'
               AND PD.Status < @cPickConfirmStatus
               AND PD.Status <> '4'
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)
            SET @nTotalLocReqQty += @nQty

            --2. Already picked
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(UCC.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON (PD.Notes IS NOT NULL AND PD.Notes = UCC.UCCNo AND PD.StorerKey = UCC.StorerKey AND PD.Lot = UCC.LOT)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND PD.LOC = @cLOC
               AND PD.UOM = '2'
               AND PD.Status = @cPickConfirmStatus
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)
            SET @nTotalLocReqQty += @nQty
         END

         -- Total piece Picked Qty
         -- 1. Picked UCC Qty
         SET @nTotalLocPickedQty += @nQty
         --2. Picked piece Qty
         BEGIN
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(PD.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND PD.LOC = @cLOC
               AND PD.UOM = '6'
               AND PD.Status = @cPickConfirmStatus
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)

            SET @nTotalLocPickedQty += @nQty
         END
      END -- LOC

      --PickSlipNo
      BEGIN
         -- Total piece Required Qty
         BEGIN
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(PD.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND PD.UOM = '6'
               AND PD.Status <> '4'
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)

            SET @nTotalPSNReqQty += @nQty
         END

         -- Total UCC Required Qty
         BEGIN
            --1. Not picked yet
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(UCC.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON (PD.DropID = UCC.UCCNo AND PD.StorerKey = UCC.StorerKey AND PD.Lot = UCC.LOT)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND PD.UOM = '2'
               AND PD.Status < @cPickConfirmStatus
               AND PD.Status <> '4'
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)
            SET @nTotalPSNReqQty += @nQty

            --2. Already picked
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(UCC.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON (PD.Notes IS NOT NULL AND PD.Notes = UCC.UCCNo AND PD.StorerKey = UCC.StorerKey AND PD.Lot = UCC.LOT)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND PD.UOM = '2'
               AND PD.Status = @cPickConfirmStatus
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)
            SET @nTotalPSNReqQty += @nQty
         END

         -- Total piece Picked Qty
         -- 1. Picked UCC Qty
         SET @nTotalPSNPickedQty += @nQty
         --2. Picked piece Qty
         BEGIN
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(PD.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND PD.UOM = '6'
               AND PD.Status = @cPickConfirmStatus
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)

            SET @nTotalPSNPickedQty += @nQty
         END
      END -- PickSlipNo
   END
   -- Discrete PickSlip
   ELSE IF @cOrderKey <> ''
   BEGIN
      --LOC
      BEGIN
         -- Total piece Required Qty
         BEGIN
            SET @nQty = 0
            SELECT @nQty= ISNULL(SUM(PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON (PH.OrderKey = PD.OrderKey)
            WHERE PH.PickHeaderKey = @cPickSlipNo
               AND PD.LOC = @cLOC
               AND PD.UOM = '6'
               AND PD.Status <> '4'
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)

            SET @nTotalLocReqQty += @nQty
         END

         -- Total UCC Required Qty
         BEGIN
            --1. Not picked yet
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(UCC.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON (PH.OrderKey = PD.OrderKey)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.DropID = UCC.UCCNo AND PD.StorerKey = UCC.StorerKey AND PD.Lot = UCC.LOT
            WHERE PH.PickHeaderKey = @cPickSlipNo
               AND PD.LOC = @cLOC
               AND PD.UOM = '2'
               AND PD.Status < @cPickConfirmStatus
               AND PD.Status <> '4'
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)
            SET @nTotalLocReqQty += @nQty

            --2. Already picked
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(UCC.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON (PH.OrderKey = PD.OrderKey)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON (PD.Notes IS NOT NULL AND PD.Notes = UCC.UCCNo AND PD.StorerKey = UCC.StorerKey AND PD.Lot = UCC.LOT)
            WHERE PH.PickHeaderKey = @cPickSlipNo
               AND PD.LOC = @cLOC
               AND PD.UOM = '2'
               AND PD.Status = @cPickConfirmStatus
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)
            SET @nTotalLocReqQty += @nQty
         END

         -- Total piece Picked Qty
         -- 1. Picked UCC Qty
         SET @nTotalLocPickedQty += @nQty
         --2. Picked piece Qty
         BEGIN
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON (PH.OrderKey = PD.OrderKey)
            WHERE PH.PickHeaderKey = @cPickSlipNo
               AND PD.LOC = @cLOC
               AND PD.UOM = '6'
               AND PD.Status = @cPickConfirmStatus
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)

            SET @nTotalLocPickedQty += @nQty
         END
      END -- LOC

      --PickSlipNo
      BEGIN
         -- Total piece Required Qty
         BEGIN
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON (PH.OrderKey = PD.OrderKey)
            WHERE PH.PickHeaderKey = @cPickSlipNo
               AND PD.UOM = '6'
               AND PD.Status <> '4'
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)

            SET @nTotalPSNReqQty += @nQty
         END

         -- Total UCC Required Qty
         BEGIN
            --1. Not picked yet
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(UCC.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON (PH.OrderKey = PD.OrderKey)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.DropID = UCC.UCCNo AND PD.StorerKey = UCC.StorerKey AND PD.Lot = UCC.Lot
            WHERE PH.PickHeaderKey = @cPickSlipNo
               AND PD.UOM = '2'
               AND PD.Status < @cPickConfirmStatus
               AND PD.Status <> '4'
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)
            SET @nTotalPSNReqQty += @nQty

            --2. Already picked
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(UCC.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON (PH.OrderKey = PD.OrderKey)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON (PD.Notes IS NOT NULL AND PD.Notes = UCC.UCCNo AND PD.StorerKey = UCC.StorerKey AND PD.Lot = UCC.LOT)
            WHERE PH.PickHeaderKey = @cPickSlipNo
               AND PD.UOM = '2'
               AND PD.Status = @cPickConfirmStatus
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)
            SET @nTotalPSNReqQty += @nQty
         END

         -- Total piece Picked Qty
         -- 1. Picked UCC Qty
         SET @nTotalPSNPickedQty += @nQty
         --2. Picked piece Qty
         BEGIN
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON (PH.OrderKey = PD.OrderKey)
            WHERE PH.PickHeaderKey = @cPickSlipNo
               AND PD.UOM = '6'
               AND PD.Status = @cPickConfirmStatus
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)

            SET @nTotalPSNPickedQty += @nQty
         END
      END -- PickSlipNo
   END
   -- Conso PickSlip
   ELSE IF @cLoadKey <> ''
   BEGIN
      --LOC
      BEGIN
         -- Total piece Required Qty
         BEGIN
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.LoadPlanDetail LPD WITH(NOLOCK) ON PD.OrderKey = LPD.OrderKey
            INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON (LPD.LoadKey = PH.LoadKey)
            WHERE PH.PickHeaderKey = @cPickSlipNo
               AND PD.LOC = @cLOC
               AND PD.UOM = '6'
               AND PD.Status <> '4'
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)

            SET @nTotalLocReqQty += @nQty
         END

         -- Total UCC Required Qty
         BEGIN
            --1. Not picked yet
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(UCC.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.LoadPlanDetail LPD WITH(NOLOCK) ON PD.OrderKey = LPD.OrderKey
            INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON (LPD.LoadKey = PH.LoadKey)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.DropID = UCC.UCCNo AND PD.StorerKey = UCC.StorerKey AND PD.Lot = UCC.Lot
            WHERE PH.PickHeaderKey = @cPickSlipNo
               AND PD.LOC = @cLOC
               AND PD.UOM = '2'
               AND PD.Status < @cPickConfirmStatus
               AND PD.Status <> '4'
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)
            SET @nTotalLocReqQty += @nQty

            --2. Already picked
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(UCC.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.LoadPlanDetail LPD WITH(NOLOCK) ON PD.OrderKey = LPD.OrderKey
            INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON (LPD.LoadKey = PH.LoadKey)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON (PD.Notes IS NOT NULL AND PD.Notes = UCC.UCCNo AND PD.StorerKey = UCC.StorerKey AND PD.Lot = UCC.LOT)
            WHERE PH.PickHeaderKey = @cPickSlipNo
               AND PD.LOC = @cLOC
               AND PD.UOM = '2'
               AND PD.Status = @cPickConfirmStatus
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)
            SET @nTotalLocReqQty += @nQty
         END

         -- Total piece Picked Qty
         -- 1. Picked UCC Qty
         SET @nTotalLocPickedQty += @nQty
         --2. Picked piece Qty
         BEGIN
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.LoadPlanDetail LPD WITH(NOLOCK) ON PD.OrderKey = LPD.OrderKey
            INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON (LPD.LoadKey = PH.LoadKey)
            WHERE PH.PickHeaderKey = @cPickSlipNo
               AND PD.LOC = @cLOC
               AND PD.UOM = '6'
               AND PD.Status = @cPickConfirmStatus
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)

            SET @nTotalLocPickedQty += @nQty
         END
      END -- LOC

      --PickSlipNo
      BEGIN
         -- Total piece Required Qty
         BEGIN
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.LoadPlanDetail LPD WITH(NOLOCK) ON PD.OrderKey = LPD.OrderKey
            INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON (LPD.LoadKey = PH.LoadKey)
            WHERE PH.PickHeaderKey = @cPickSlipNo
               AND PD.UOM = '6'
               AND PD.Status <> '4'
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)

            SET @nTotalPSNReqQty += @nQty
         END

         -- Total UCC Required Qty
         BEGIN
            --1. Not picked yet
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(UCC.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.LoadPlanDetail LPD WITH(NOLOCK) ON PD.OrderKey = LPD.OrderKey
            INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON (LPD.LoadKey = PH.LoadKey)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.DropID = UCC.UCCNo AND PD.StorerKey = UCC.StorerKey AND PD.Lot = UCC.Lot
            WHERE PH.PickHeaderKey = @cPickSlipNo
               AND PD.UOM = '2'
               AND PD.Status < @cPickConfirmStatus
               AND PD.Status <> '4'
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)
            SET @nTotalPSNReqQty += @nQty

            --2. Already picked
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(UCC.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.LoadPlanDetail LPD WITH(NOLOCK) ON PD.OrderKey = LPD.OrderKey
            INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON (LPD.LoadKey = PH.LoadKey)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON (PD.Notes IS NOT NULL AND PD.Notes = UCC.UCCNo AND PD.StorerKey = UCC.StorerKey AND PD.Lot = UCC.LOT)
            WHERE PH.PickHeaderKey = @cPickSlipNo
               AND PD.UOM = '2'
               AND PD.Status = @cPickConfirmStatus
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)
            SET @nTotalPSNReqQty += @nQty
         END

         -- Total piece Picked Qty
         -- 1. Picked UCC Qty
         SET @nTotalPSNPickedQty += @nQty
         --2. Picked piece Qty
         BEGIN
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.LoadPlanDetail LPD WITH(NOLOCK) ON PD.OrderKey = LPD.OrderKey
            INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON (LPD.LoadKey = PH.LoadKey)
            WHERE PH.PickHeaderKey = @cPickSlipNo
               AND PD.UOM = '6'
               AND PD.Status = @cPickConfirmStatus
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)

            SET @nTotalPSNPickedQty += @nQty
         END
      END -- PickSlipNo
   END
   -- Custom PickSlip
   ELSE
   BEGIN
      --LOC
      BEGIN
         -- Total piece Required Qty
         BEGIN
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND PD.LOC = @cLOC
               AND PD.UOM = '6'
               AND PD.Status <> '4'
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)

            SET @nTotalLocReqQty += @nQty
         END

         -- Total UCC Required Qty
         BEGIN
            --1. Not picked yet
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(UCC.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.DropID = UCC.UCCNo AND PD.StorerKey = UCC.StorerKey AND PD.Lot = UCC.Lot
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND PD.LOC = @cLOC
               AND PD.UOM = '2'
               AND PD.Status < @cPickConfirmStatus
               AND PD.Status <> '4'
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)
            SET @nTotalLocReqQty += @nQty

            --2. Already picked
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(UCC.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON (PD.Notes IS NOT NULL AND PD.Notes = UCC.UCCNo AND PD.StorerKey = UCC.StorerKey AND PD.Lot = UCC.LOT)
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND PD.LOC = @cLOC
               AND PD.UOM = '2'
               AND PD.Status = @cPickConfirmStatus
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)
            SET @nTotalLocReqQty += @nQty
         END

         -- Total piece Picked Qty
         -- 1. Picked UCC Qty
         SET @nTotalLocPickedQty += @nQty
         --2. Picked piece Qty
         BEGIN
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND PD.LOC = @cLOC
               AND PD.UOM = '6'
               AND PD.Status = @cPickConfirmStatus
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)

            SET @nTotalLocPickedQty += @nQty
         END
      END -- LOC

      --PickSlipNo
      BEGIN
         -- Total piece Required Qty
         BEGIN
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND PD.UOM = '6'
               AND PD.Status <> '4'
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)

            SET @nTotalPSNReqQty += @nQty
         END

         -- Total UCC Required Qty
         BEGIN
            --1. Not picked yet
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(UCC.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.DropID = UCC.UCCNo AND PD.StorerKey = UCC.StorerKey AND PD.Lot = UCC.Lot
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND PD.UOM = '2'
               AND PD.Status < @cPickConfirmStatus
               AND PD.Status <> '4'
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)
            SET @nTotalPSNReqQty += @nQty

            --2. Already picked
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(UCC.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON (PD.Notes IS NOT NULL AND PD.Notes = UCC.UCCNo AND PD.StorerKey = UCC.StorerKey AND PD.Lot = UCC.LOT)
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND PD.UOM = '2'
               AND PD.Status = @cPickConfirmStatus
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)
            SET @nTotalPSNReqQty += @nQty
         END

         -- Total piece Picked Qty
         -- 1. Picked UCC Qty
         SET @nTotalPSNPickedQty += @nQty
         --2. Picked piece Qty
         BEGIN
            SET @nQty = 0
            SELECT @nQty = ISNULL(SUM(PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND PD.UOM = '6'
               AND PD.Status = @cPickConfirmStatus
               AND PD.QTY > 0
            SET @nQty = ISNULL(@nQty, 0)

            SET @nTotalPSNPickedQty += @nQty
         END
      END -- PickSlipNo
   END
   SET @nTotalPSNPickedQty = @nTotalPSNReqQty - @nTotalPSNPickedQty -- no serial number
END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_839GetBalQty02] TO NSQL
GO  