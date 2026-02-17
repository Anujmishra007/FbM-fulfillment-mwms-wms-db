SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
  
/************************************************************************/  
/* Store procedure: rdt_PTLPiece_Confirm_Order14_ONBR                   */
/* Copyright      : Maersk                                              */
/*                                                                      */  
/* Purpose: Confirm by order                                            */  
/*                                                                      */  
/* Date       Rev  Author      Purposes                                 */
/* 2025-11-27 1.0.0  Cuize    FCR-9003 Created                          */
/************************************************************************/  
  
CREATE OR ALTER   PROC [RDT].[rdt_PTLPiece_Confirm_Order14_ONBR] (
    @nMobile      INT  
   ,@nFunc        INT  
   ,@cLangCode    NVARCHAR( 3)  
   ,@nStep        INT  
   ,@nInputKey    INT  
   ,@cFacility    NVARCHAR( 5)  
   ,@cStorerKey   NVARCHAR( 15)  
   ,@cLight       NVARCHAR( 1)  
   ,@cStation     NVARCHAR( 10)  
   ,@cMethod      NVARCHAR( 1)   
   ,@cSKU         NVARCHAR( 20)  
   ,@cIPAddress   NVARCHAR( 40) OUTPUT  
   ,@cPosition    NVARCHAR( 10) OUTPUT  
   ,@nErrNo       INT           OUTPUT  
   ,@cErrMsg      NVARCHAR(250) OUTPUT  
   ,@cResult01    NVARCHAR( 20) OUTPUT  
   ,@cResult02    NVARCHAR( 20) OUTPUT  
   ,@cResult03    NVARCHAR( 20) OUTPUT  
   ,@cResult04    NVARCHAR( 20) OUTPUT  
   ,@cResult05    NVARCHAR( 20) OUTPUT  
   ,@cResult06    NVARCHAR( 20) OUTPUT  
   ,@cResult07    NVARCHAR( 20) OUTPUT  
   ,@cResult08    NVARCHAR( 20) OUTPUT  
   ,@cResult09    NVARCHAR( 20) OUTPUT  
   ,@cResult10    NVARCHAR( 20) OUTPUT  
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
     
   DECLARE @bSuccess          INT  

   DECLARE @cOrderKey         NVARCHAR( 10)  
   DECLARE @cDisplay          NVARCHAR( 5)
   DECLARE @cPickConfirmStatus      NVARCHAR( 10)
   DECLARE @cDropID           NVARCHAR( 20)
   DECLARE @cCartID           NVARCHAR( 10)
   DECLARE @cOrderLoc         NVARCHAR(10)
   DECLARE @cWaveKey          NVARCHAR(10)
--    DECLARE  @cToDropID        NVARCHAR( 20)
   DECLARE  @cToSlotLoc       NVARCHAR(10)
   DECLARE @cMoveRefKey    NVARCHAR( 10)


   DECLARE @cFromLOC          NVARCHAR( 10)
   DECLARE @cFromID           NVARCHAR( 18)
   DECLARE @cLOT              NVARCHAR( 10)
   DECLARE @nQty              INT

   -- Get assign info  
   SELECT top 1
      @cDropID = SourceKey,
      @cCartID = UserDefine01,
      @cIPAddress = IPAddress,
      @cPosition = Position
   FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
   WHERE Station = @cStation
   ORDER BY EditDate desc

   DECLARE @cPickDetailkey NVARCHAR(10)

   SELECT TOP 1
          @cPickdetailKey= PD.PickDetailKey,
          @cOrderKey = PD.orderkey,
          @cOrderLoc = orders.UserDefine05,
          @cFromID = PD.ID,
          @cLOT = PD.LOT,
          @cFromLOC = PD.LOC,
          @nQty = PD.Qty,
          @cWaveKey = PD.wavekey
   FROM dbo.PickDetail PD WITH (NOLOCK)
      JOIN dbo.Orders Orders WITH (NOLOCK)
         ON PD.orderkey = Orders.Orderkey
   WHERE PD.DropID = @cDropID
      AND PD.SKU = @cSKU
      AND PD.Storerkey = @cStorerKey
      AND PD.qty > 0
      AND Orders.UserDefine04 = @cStation -- Order assigned to this station
      AND PD.DropID NOT LIKE @cCartID + '%' -- NOT moved to cartid

   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo = 252858
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Can not find SKU in DropID
      GOTO Quit
   END

   -- Get storer config
   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'

   DECLARE @nTranCount INT

   -- Handling transaction
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN Confirm_Order14_ONBR -- For rollback or commit only our own transaction


   SELECT TOP 1
--       @cToDropID   = @cCartID + '_' +
--                      RIGHT('000' + CAST(S.LogicalPOS AS VARCHAR(3)), 3),
      @cToSlotLoc  = C.LOC,
      @cPosition   = S.DevicePosition
   FROM dbo.DeviceProfile AS S WITH (NOLOCK)      -- STATION
   JOIN dbo.DeviceProfile AS C WITH (NOLOCK)      -- CART
       ON C.LogicalPOS = S.LogicalPOS
          AND C.DeviceType = 'CART'
          AND C.DeviceID   = @cCartID
          AND C.StorerKey  = @cStorerKey
   WHERE S.DeviceType = 'STATION'
     AND S.DeviceID   = @cStation
     AND S.LOC        = @cOrderLoc
     AND S.StorerKey  = @cStorerKey;

   /***********************************************************************************************

                                      CONFIRM ORDER

***********************************************************************************************/
   INSERT INTO PTL.PTLTran (
      Func,IPAddress, DeviceID, DevicePosition, Status, PTLType,LightUp,
      DeviceProfileLogKey, DropID, OrderKey, Storerkey, SKU, LOC, ExpectedQTY, QTY, SourceKey, Remarks)
   VALUES (
             803,@cIPAddress, @cStation, @cPosition, '1', 'PIECE', 1,
             '', @cDropID, @cOrderKey, @cStorerKey, @cSKU, @cOrderLoc, 1, @nQty, @cCartID, @cWaveKey)

   IF @@ERROR <> ''
      BEGIN
         SET @nErrNo = 175253
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo ,@cLangCode ,'DSP') --INS PTL Fail
         GOTO RollBackTran
      END



   -- Get new MoveRefKey
   EXECUTE dbo.nspg_GetKey
           'MOVEREFKEY',
           10 ,
           @cMoveRefKey OUTPUT,
           @bSuccess    OUTPUT,
           @nErrNo      OUTPUT,
           @cErrMsg     OUTPUT
   IF @bSuccess <> 1
   BEGIN
      SET @nErrNo = 102009
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GetKey Fail
      GOTO RollBackTran
   END

--    EXECUTE rdt.rdt_Move
--            @nMobile      = @nMobile,
--            @cLangCode    = @cLangCode,
--            @nErrNo       = @nErrNo  OUTPUT,
--            @cErrMsg      = @cErrMsg OUTPUT, -- screen limitation, 20 NVARCHAR max
--            @cSourceType  = 'rdt_PTLPiece_Confirm_Order14_ONBR',
--            @cStorerKey   = @cStorerKey,
--            @cFacility    = @cFacility,
--            @cFromLOC     = @cFromLOC,
--            @cToLOC       = @cToSlotLoc,
--            @cFromID      = @cFromID,     -- NULL means not filter by ID. Blank is a valid ID
--            @cToID        = @cToSlotLoc,       -- NULL means not changing ID. Blank consider a valid ID
--            @cSKU         = @cSKU,
--            @nQTY         = @nQty,
--            @nQTYAlloc    = @nQty,
--            @nFunc        = @nFunc
--    IF @nErrNo <> 0
--       GOTO RollBackTran
--




   IF @nQty = 1
   BEGIN

      UPDATE dbo.PickDetail WITH (ROWLOCK) SET
         --Status = @cPickConfirmStatus,
         MoveRefKey = @cMoveRefKey,
         DropID = @cToSlotLoc,
         EditDate = GETDATE(),
         EditWho  = SUSER_SNAME()
      WHERE PickDetailKey = @cPickDetailKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 102001
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
         GOTO RollBackTran
      END


   END
   ELSE
   BEGIN-- qty > 1

      -- Get new PickDetailkey
      DECLARE @cNewPickDetailKey NVARCHAR( 10)
      EXECUTE dbo.nspg_GetKey
              'PICKDETAILKEY',
              10 ,
              @cNewPickDetailKey OUTPUT,
              @bSuccess          OUTPUT,
              @nErrNo            OUTPUT,
              @cErrMsg           OUTPUT
      IF @bSuccess <> 1
         BEGIN
            SET @nErrNo = 102004
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- nspg_GetKey
            GOTO RollBackTran
         END

      -- Create new a PickDetail to hold the balance
      INSERT INTO dbo.PickDetail (
         CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM,
         UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType,
         ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
         EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes,
         PickDetailKey,
         Status,
         QTY,
         TrafficCop,
         OptimizeCop)
      SELECT
         CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot, StorerKey, SKU, AltSku, UOM,
         UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup,
         CartonType, ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
         EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes,
         @cNewPickDetailKey,
         Status,
         @nQty - 1, -- QTY
         NULL, -- TrafficCop
         '1'   -- OptimizeCop
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE PickDetailKey = @cPickDetailKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 102005
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- INS PKDtl Fail
         GOTO RollBackTran
      END

      -- Split RefKeyLookup
      IF EXISTS( SELECT 1 FROM RefKeyLookup WITH (NOLOCK) WHERE PickDetailKey = @cPickDetailKey)
      BEGIN
         -- Insert into
         INSERT INTO dbo.RefKeyLookup (PickDetailkey, PickSlipNo, OrderKey, OrderLineNumber, Loadkey)
         SELECT @cNewPickDetailKey, PickSlipNo, OrderKey, OrderLineNumber, Loadkey
         FROM RefKeyLookup WITH (NOLOCK)
         WHERE PickDetailKey = @cPickDetailKey
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 102006
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- INS RefKeyFail
            GOTO RollBackTran
         END
      END
      -- Change orginal PickDetail with exact QTY (with TrafficCop)
      UPDATE dbo.PickDetail WITH (ROWLOCK) SET
         QTY = 1,
         EditDate = GETDATE(),
         EditWho  = SUSER_SNAME(),
         Trafficcop = NULL
         WHERE PickDetailKey = @cPickDetailKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 102007
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
         GOTO RollBackTran
      END

      -- Confirm orginal PickDetail with exact QTY
      UPDATE dbo.PickDetail WITH (ROWLOCK) SET
         --Status = @cPickConfirmStatus,
         MoveRefKey = @cMoveRefKey,
         DropID = @cToSlotLoc,
         EditDate = GETDATE(),
         EditWho  = SUSER_SNAME()
      WHERE PickDetailKey = @cPickDetailKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 102008
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
         GOTO RollBackTran
      END

   END

--    --2. Move Inventory
--
--
--    /***********************************************************************************************
--
--                                            Move Inv
--
--    ***********************************************************************************************/

   DECLARE @cPackKey       NVARCHAR( 10)
   DECLARE @cPackUOM3      NVARCHAR( 10)
-- Get SKU info
   SELECT
      @cPackKey = SKU.PackKey,
      @cPackUOM3 = Pack.PackUOM3
   FROM SKU WITH (NOLOCK)
      JOIN Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)
   WHERE StorerKey = @cStorerKey
     AND SKU = @cSKU
--
-- --
-- Move LOTxLOCxID
   EXEC dbo.nspItrnAddMove
        @n_ItrnSysId     = NULL          -- int
      , @c_StorerKey     = @cStorerKey   -- NVARCHAR(15)
      , @c_Sku           = @cSKU         -- NVARCHAR(20)
      , @c_Lot           = @cLOT         -- NVARCHAR(10)
      , @c_FromLoc       = @cFromLOC         -- NVARCHAR(10)
      , @c_FromID        = @cFromID          -- NVARCHAR(18)
      , @c_ToLoc         = @cToSlotLoc       -- NVARCHAR(10)
      , @c_ToID          = @cToSlotLoc        -- NVARCHAR(18)
      , @c_Status        = ''            -- NVARCHAR(10)
      , @c_lottable01    = ''            -- NVARCHAR(18)
      , @c_lottable02    = ''            -- NVARCHAR(18)n
      , @c_lottable03    = ''            -- NVARCHAR(18)
      , @d_lottable04    = ''            -- datetime
      , @d_lottable05    = ''            -- datetime
      , @n_casecnt       = 0             -- int
      , @n_innerpack     = 0             -- int
      , @n_qty           = 1    -- int
      , @n_pallet        = 0             -- int
      , @f_cube          = 0             -- float
      , @f_grosswgt      = 0             -- float
      , @f_netwgt        = 0             -- float
      , @f_otherunit1    = 0             -- float
      , @f_otherunit2    = 0             -- float
      , @c_SourceKey     = ''            -- NVARCHAR(20)
      , @c_SourceType    = 'rdt_PTLPiece_Confirm_Order14_ONBR'  -- NVARCHAR(30)
      , @c_PackKey       = @cPackKey     -- NVARCHAR(10)
      , @c_UOM           = @cPackUOM3    -- NVARCHAR(10)
      , @b_UOMCalc       = 1             -- int
      , @d_EffectiveDate = ''            -- datetime
      , @c_itrnkey       = ''            -- NVARCHAR(10)   OUTPUT
      , @b_Success       = @bSuccess     -- int        OUTPUT
      , @n_err           = @nErrNo       -- int        OUTPUT
      , @c_errmsg        = @cErrMsg      -- NVARCHAR(250)  OUTPUT
      , @c_MoveRefKey    = @cMoveRefKey

   SET @nErrNo = @@ERROR
   IF @nErrNo <> 0
   BEGIN
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO RollBackTran
   END


   -- Draw matrix (and light up)  
   EXEC rdt.rdt_PTLPiece_Matrix @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey  
      ,@cLight  
      ,@cStation  
      ,@cMethod  
      ,@cSKU  
      ,@cIPAddress   
      ,@cPosition  
      ,@cDisplay  
      ,@nErrNo     OUTPUT  
      ,@cErrMsg    OUTPUT  
      ,@cResult01  OUTPUT  
      ,@cResult02  OUTPUT  
      ,@cResult03  OUTPUT  
      ,@cResult04  OUTPUT  
      ,@cResult05  OUTPUT  
      ,@cResult06  OUTPUT  
      ,@cResult07  OUTPUT  
      ,@cResult08  OUTPUT  
      ,@cResult09  OUTPUT  
      ,@cResult10  OUTPUT  
   IF @nErrNo <> 0  
      GOTO RollBackTran  
     
   GOTO Quit
     
RollBackTran:
   ROLLBACK TRAN Confirm_Order14_ONBR -- Only rollback change made here
   Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN

END  
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON RDT.rdt_PTLPiece_Confirm_Order14_ONBR TO NSQL
GO
