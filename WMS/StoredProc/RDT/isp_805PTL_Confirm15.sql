

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
      
/************************************************************************/      
/* Store procedure: isp_805PTL_Confirm15                                */
/* Copyright      : Maersk                                              */
/*                                                                      */      
/* Purpose: Accept QTY in CS-PCS, format 9-999                          */      
/*                                                                      */      
/* Date       Rev  Author   Purposes                                    */      
/* 02-12-2025 1.0  Cuize    FCR-9003 Created                            */
/************************************************************************/      
      
CREATE  OR ALTER  PROC [PTL].[isp_805PTL_Confirm15] (
   @cIPAddress    NVARCHAR(30),      
   @cPosition     NVARCHAR(20),      
   @cFuncKey      NVARCHAR(2),      
   @nSerialNo     INT,      
   @cInputValue   NVARCHAR(20),      
   @nErrNo        INT           OUTPUT,      
   @cErrMsg       NVARCHAR(125) OUTPUT,      
   @cDebug        NVARCHAR( 1) = '',
   @cFacility     NVARCHAR( 20)
)      
AS
BEGIN TRY

   SET NOCOUNT ON      
   SET QUOTED_IDENTIFIER OFF      
   SET ANSI_NULLS OFF      
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  @nMobile             INT
   DECLARE  @cWaveKey            NVARCHAR( 10)
   DECLARE  @cLoadKey            NVARCHAR( 10)
   DECLARE  @cOrderKey           NVARCHAR( 10)
   DECLARE  @cDisplay            NVARCHAR( 5)
   DECLARE  @cDynamicSlot        NVARCHAR( 1)
   DECLARE  @cUpdateCaseID       NVARCHAR( 1)
   DECLARE  @cAutoScanOut        NVARCHAR( 1)
   DECLARE  @cDropID             NVARCHAR( 20)
   DECLARE  @cToDropID               NVARCHAR( 20)
   DECLARE  @cToSlotLoc              NVARCHAR(10)
   DECLARE  @cNewDropID          NVARCHAR( 20)
   DECLARE  @cCartID             NVARCHAR( 10)
   DECLARE  @cOrderLoc           NVARCHAR(10)
   DECLARE  @cFromLOC            NVARCHAR( 10)
   DECLARE  @cFromID             NVARCHAR( 18)
   DECLARE  @cLOT                NVARCHAR( 10)
   DECLARE  @nQty                INT
   DECLARE  @nTranCount          INT
   DECLARE  @cSKU                NVARCHAR( 20)
   DECLARE  @cUserName           NVARCHAR( 18)
   DECLARE  @cStation            NVARCHAR( 10)
   DECLARE  @cStorerKey          NVARCHAR(15)
   DECLARE  @bSuccess            INT


   -- Get PTLTran info
   SELECT TOP 1
      @cOrderKey = OrderKey,
      @cDropID = DropID,
      @cSKU = SKU,
      @cUserName = EditWho,
      @cStation = DeviceID,
      @cStorerkey = Storerkey
   FROM PTL.PTLTran WITH (NOLOCK)
   WHERE IPAddress = @cIPAddress
     AND DevicePosition = @cPosition
     AND Func = 805
     AND Status = '1' -- Lighted up
     AND LightUp= '1'


   SELECT TOP 1
      @nMobile         = Mobile
   FROM rdt.rdtMobrec WITH (NOLOCK)
   WHERE username=@cUserName
     AND Func = 805


   -- Handling transaction
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN isp_805PTL_Confirm15 -- For rollback or commit only our own transaction

   -- Get assign info
   SELECT top 1
      @cDropID = SourceKey,
      @cCartID = UserDefine01
   FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
   WHERE Station = @cStation
   ORDER BY EditDate desc


   SELECT TOP 1
      @cOrderKey  = PD.orderkey,
      @cOrderLoc  = orders.UserDefine05,
      @cFromID    = PD.ID,
      @cLOT       = PD.LOT,
      @cFromLOC   = PD.LOC,
      @nQty       = PD.qty
   FROM dbo.PickDetail PD WITH (NOLOCK)
      JOIN dbo.Orders Orders WITH (NOLOCK)
      ON PD.orderkey = Orders.Orderkey
   WHERE PD.DropID = @cDropID
     AND PD.SKU = @cSKU
     AND PD.Storerkey = @cStorerKey
     AND PD.qty > 0


   SELECT TOP 1
      @cToDropID   = @cCartID + '_' +
                     RIGHT('000' + CAST(S.LogicalPOS AS VARCHAR(3)), 3),
      @cToSlotLoc  = C.LOC
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
--
--    --1. UPDATE DROPID
--       UPDATE PICKDETAIL WITH (ROWLOCK )
--       SET DropID = @cToDropID
--       WHERE DROPID = @cDropID
--         AND SKU = @cSKU
--
--    --2. Move Inventory
--
--
--    /***********************************************************************************************
--
--                                            Move Inv
--
--    ***********************************************************************************************/
--
--    EXECUTE rdt.rdt_Move
--            @nMobile     	= @nMobile,
--            @cLangCode   	= 'ENG',
--            @nErrNo      	= @nErrNo  OUTPUT,
--            @cErrMsg     	= @cErrMsg OUTPUT, -- screen limitation, 20 NVARCHAR max
--            @cSourceType 	= 'rdtfnc_MoveToLOC',
--            @cStorerKey  	= @cStorerKey,
--            @cFacility   	= @cFacility,
--            @cFromLOC    	= @cFromLOC,
--            @cToLOC      	= @cToSlotLoc,
--            @cFromID     	= @cFromID,     -- NULL means not filter by ID. Blank is a valid ID
--            @cToID       	= @cToDropID,       -- NULL means not changing ID. Blank consider a valid ID
--            @cSKU        	= @cSKU,
--            @nQTY        	= @nQty,
--            @nQTYAlloc      = @nQty,
--            @nFunc   		   = 805
--
--    IF @nErrNo <> 0
--    BEGIN
--       --SET @cErrMsg = @cCartSlotLoc
--       GOTO RollBackTran
--    END


   -- EventLog
   EXEC RDT.rdt_STD_EventLog
        @cActionType = '3',
        @nMobileNo   = @nMobile,
        @nFunctionID = 805,
        @cFacility   = @cFacility,
        @cStorerKey  = @cStorerkey,
        @cOrderKey   = @cOrderKey,
        @cPickSlipNo = '',
        @cDropID     = @cPosition,
        @cSKU        = @cSKU,
        @cDeviceID   = @cStation,
        @cToLocation = @cToSlotLoc,
        @nQty        = 1



   --TODO ALL FINISH, unassign and light down

   IF NOT EXISTS(
      SELECT 1
       FROM PICKDETAIL AS PD WITH (NOLOCK)
               JOIN Orders O WITH (NOLOCK) ON O.orderkey = PD.orderkey
       WHERE PD.wavekey = @cwavekey
         AND PD.orderkey = @cOrderKey
         AND O.UserDefine05 = @cOrderLoc
         AND PD.DropID NOT LIKE @cCartID + '%')
   BEGIN
      -- Off all lights
      EXEC PTL.isp_PTL_TerminateModule
           @cStorerKey
         ,805
         ,@cStation
         ,'STATION'
         ,@bSuccess    OUTPUT
         ,@nErrNo      OUTPUT
         ,@cErrMsg     OUTPUT
      IF @nErrNo <> 0
         GOTO RollBackTran
   END



      IF @nErrNo<>0
         GOTO Quit






   RollBackTran:
   ROLLBACK TRAN isp_805PTL_Confirm15 -- Only rollback change made here

   -- Raise error to go to catch block
   RAISERROR ('', 16, 1) WITH SETERROR

END TRY
BEGIN CATCH
IF @cDebug = 0
   -- RelightUp
   EXEC PTL.isp_PTL_LightUpLoc
        @n_Func           = 805
      ,@n_PTLKey         = 0
      ,@c_DisplayValue   = 'ERR'
      ,@b_Success        = @bSuccess    OUTPUT
      ,@n_Err            = @nErrNo      OUTPUT
      ,@c_ErrMsg         = @cErrMsg     OUTPUT
      ,@c_DeviceID       = @cStation
      ,@c_DevicePos      = @cPosition
      ,@c_DeviceIP       = @cIPAddress
      ,@c_LModMode       = '99'

END CATCH

   Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN

GO
GRANT EXECUTE ON  [PTL].[isp_805PTL_Confirm15] TO [NSQL]
GO


SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
