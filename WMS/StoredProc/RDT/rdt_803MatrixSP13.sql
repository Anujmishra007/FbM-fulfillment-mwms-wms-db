SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_803MatrixSP13                                   */
/* Copyright      : Cuize                                               */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2025-11-27 1.0.0  Cuize    FCR-9003 Created                          */
/************************************************************************/

CREATE OR ALTER   PROC [RDT].[rdt_803MatrixSP13] (
    @nMobile    INT
   ,@nFunc      INT
   ,@cLangCode  NVARCHAR( 3)
   ,@nStep      INT
   ,@nInputKey  INT
   ,@cFacility  NVARCHAR( 5)
   ,@cStorerKey NVARCHAR( 15)
   ,@cLight     NVARCHAR( 1)
   ,@cStation   NVARCHAR( 10)
   ,@cMethod    NVARCHAR( 1)
   ,@cSKU       NVARCHAR( 20)
   ,@cIPAddress NVARCHAR( 40)
   ,@cPosition  NVARCHAR( 10)
   ,@cDisplay   NVARCHAR( 5)
   ,@nErrNo     INT            OUTPUT
   ,@cErrMsg    NVARCHAR( 20)  OUTPUT
   ,@cResult01  NVARCHAR( 20)  OUTPUT
   ,@cResult02  NVARCHAR( 20)  OUTPUT
   ,@cResult03  NVARCHAR( 20)  OUTPUT
   ,@cResult04  NVARCHAR( 20)  OUTPUT
   ,@cResult05  NVARCHAR( 20)  OUTPUT
   ,@cResult06  NVARCHAR( 20)  OUTPUT
   ,@cResult07  NVARCHAR( 20)  OUTPUT
   ,@cResult08  NVARCHAR( 20)  OUTPUT
   ,@cResult09  NVARCHAR( 20)  OUTPUT
   ,@cResult10  NVARCHAR( 20)  OUTPUT
 )
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF


   DECLARE @cCR                     NVARCHAR( 1)
   DECLARE @cLF                     NVARCHAR( 1)
   DECLARE @bSuccess                INT
   DECLARE @cDropID                 NVARCHAR( 20)
--    DECLARE @cToDropID               NVARCHAR( 20)
   DECLARE @cOrderKey               NVARCHAR( 10)
   DECLARE @cCartID                 NVARCHAR( 10)
   DECLARE @cOrderLoadKey           NVARCHAR(10)
   DECLARE @cOrderLoc               NVARCHAR(10)
   DECLARE @cToSlotLoc              NVARCHAR(10)
   DECLARE @cLogicalPos             NVARCHAR(10)
   DECLARE @cLightMode              NVARCHAR(4)
   DECLARE @cWaveKey                NVARCHAR(10)
   DECLARE @cDisplayPosition        NVARCHAR(10)


   SET @cCR = CHAR( 13)
   SET @cLF = CHAR( 10)
   SET @cResult01 = ''
   SET @cResult02 = ''
   SET @cResult03 = ''
   SET @cResult04 = ''
   SET @cResult05 = ''
   SET @cResult06 = ''
   SET @cResult07 = ''
   SET @cResult08 = ''
   SET @cResult09 = ''
   SET @cResult10 = ''

   -- Get PTLTran info
   SELECT TOP 1
      @cOrderKey = OrderKey,
      @cDropID = DropID,
      @cSKU = SKU,
      @cOrderLoc = LOC,
      @cStation = DeviceID,
      @cStorerkey = Storerkey,
      @cCartID    = SourceKey,
      @cWaveKey   = Remarks
   FROM PTL.PTLTran WITH (NOLOCK)
   WHERE IPAddress = @cIPAddress
     AND DevicePosition = @cPosition
     AND Func = 803
     AND Status = '1' -- Lighted up
     AND LightUp= '1'
   Order BY AddDate DESC

   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo = 252858
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Can not find order
      GOTO Quit
   END


   SELECT TOP 1
      @cLogicalPOS = S.LogicalPOS,
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



   SET @cResult08= 'GOTO SLOT:'+@cOrderLoc

   --1. All this SLOT finished
   IF NOT EXISTS(
      SELECT 1 FROM PICKDETAIL AS PD WITH (NOLOCK )
         JOIN Orders O WITH (NOLOCK ) ON O.orderkey = PD.orderkey
      WHERE PD.wavekey = @cwavekey
        AND O.UserDefine05 = @cOrderLoc
        AND PD.DropID NOT LIKE 'CART%'
        --AND PD.pickdetailkey <> @cPickDetailkey
   )
   BEGIN
      SET @cLightMode = rdt.RDTGetConfig( @nFunc, 'LightModeEnd', @cStorerKey)    -- flashing yellow and turns blue
      SET @cResult09 = '** SLOT COMPLETE **'
   END

   --2. This SLOT not finish, this order not finished
   ELSE
   BEGIN
      SET @cLightMode = rdt.RDTGetConfig( @nFunc, 'LightMode', @cStorerKey)    -- flashing yellow and turns off
   END

   --All pickdetail moved to cart slot
   IF NOT EXISTS(SELECT 1
      FROM PICKDETAIL AS PD WITH (NOLOCK)
      JOIN Orders O WITH (NOLOCK) ON O.orderkey = PD.orderkey
      WHERE PD.wavekey = @cwavekey
         AND PD.DropID NOT LIKE 'CART%'
        AND O.UserDefine04 = @cStation
   )
   BEGIN
      SET @cResult09 = '** WAVE COMPLETED **'

      SELECT TOP 1
         @cDisplayPosition = DevicePosition
      FROM DeviceProfile WITH(NOLOCK )
      WHERE DeviceType = 'STATION'
         AND DeviceID   = @cStation
         AND StorerKey  = @cStorerKey
         AND DeviceModel = 'DISPLAY'

      EXEC PTL.isp_PTL_LightUpLoc -- SEND 'COMPLETE' TO THE DISPLAY
           @n_Func           = 805
         ,@n_PTLKey         = 0
         ,@c_DisplayValue   = 'COMPLETE' --'Complete message'
         ,@b_Success        = @bSuccess    OUTPUT
         ,@n_Err            = @nErrNo      OUTPUT
         ,@c_ErrMsg         = @cErrMsg     OUTPUT
         ,@c_DeviceID       = @cStation
         ,@c_DevicePos      = @cDisplayPosition
         ,@c_DeviceIP       = @cIPAddress
         ,@c_LModMode       = @cLightMode
         ,@c_DeviceModel    = 'BATCH12'

   END


   IF @cLight = '1'  -- light up
   BEGIN


      EXEC PTL.isp_PTL_LightUpLoc
           @n_Func           = 805
         ,@n_PTLKey         = 0
         ,@c_DisplayValue   = ''
         ,@b_Success        = @bSuccess    OUTPUT
         ,@n_Err            = @nErrNo      OUTPUT
         ,@c_ErrMsg         = @cErrMsg     OUTPUT
         ,@c_DeviceID       = @cStation
         ,@c_DevicePos      = @cPosition
         ,@c_DeviceIP       = @cIPAddress
         ,@c_LModMode       = @cLightMode

   END

Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_803MatrixSP13] TO [NSQL]
GO
