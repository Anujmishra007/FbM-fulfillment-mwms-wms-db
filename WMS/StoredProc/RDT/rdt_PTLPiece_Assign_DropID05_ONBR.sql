SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF 
GO  

/******************************************************************************/  
/* Store procedure: rdt_PTLPiece_Assign_DropID05_ONBR                         */
/* Copyright      : Maersk                                                    */
/*                                                                            */  
/* Date       Rev  Author   Purposes                                          */
/* 2025-11-27 1.0.0  Cuize    FCR-9003 Created                                */
/******************************************************************************/
  
ALTER   PROC [RDT].[rdt_PTLPiece_Assign_DropID05_ONBR] (
   @nMobile          INT,   
   @nFunc            INT,   
   @cLangCode        NVARCHAR( 3),   
   @nStep            INT,   
   @nInputKey        INT,   
   @cFacility        NVARCHAR( 5),   
   @cStorerKey       NVARCHAR( 15),    
   @cStation         NVARCHAR( 10),    
   @cMethod          NVARCHAR( 1),  
   @cType            NVARCHAR( 15), --POPULATE-IN/POPULATE-OUT/CHECK  
   @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,     
   @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,     
   @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,     
   @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,     
   @cInField05       NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,     
   @cInField06       NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,    
   @cInField07       NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,    
   @cInField08       NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,    
   @cInField09       NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,    
   @cInField10       NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,    
   @cInField11       NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,   
   @cInField12       NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,   
   @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,   
   @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,   
   @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,   
   @nScn             INT           OUTPUT,  
   @nErrNo           INT           OUTPUT,   
   @cErrMsg          NVARCHAR( 1024) OUTPUT
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @cDropID           NVARCHAR( 20)
   DECLARE @nTotalDropID      INT
   DECLARE @cIPAddress        NVARCHAR( 40)
   DECLARE @cPosition         NVARCHAR( 10)
   DECLARE @cOrderKey         NVARCHAR( 10)
   DECLARE @cWaveKey          NVARCHAR( 10)
   DECLARE @cAssignedStation  NVARCHAR( 10)
   DECLARE @cLogicalName      NVARCHAR( 10)
   DECLARE @cCartID           NVARCHAR( 10)
   DECLARE @bSuccess          INT
   DECLARE @cDeviceID        NVARCHAR( 20)




   SELECT
      @cDeviceID  = DeviceID,
      @cCartID = V_String42
      FROM rdt.rdtMobRec (NOLOCK)
   WHERE Mobile = @nMobile
   
   /***********************************************************************************************  
                                                POPULATE  
   ***********************************************************************************************/  
   IF @cType = 'POPULATE-IN'  
   BEGIN

      IF ISNULL(@cDeviceID,'') = ''
      BEGIN

         SET @nErrNo = 252859
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DeviceID Can not be empty
         GOTO Quit

      END


      -- Get stat  
      SELECT @nTotalDropID = COUNT( DISTINCT SourceKey) 
      FROM rdt.rdtPTLPieceLog WITH (NOLOCK) 
      WHERE Station = @cStation 
      AND   Method = @cMethod 
      AND   SourceKey <> ''  
        
     -- Prepare next screen var
     SET @cOutField01 = ''
     SET @cOutField02 = CAST( @nTotalDropID AS NVARCHAR(5))

     -- Go to batch screen
     SET @nScn = 4602
   END  
        

   IF @cType = 'POPULATE-OUT'
   BEGIN

      UPDATE DeviceProfile SET STATUS = 'IDLE'
      WHERE DeviceType = 'STATION'
        AND DeviceID = @cStation
        AND StorerKey = @cStorerKey


      -- Off all lights
      EXEC PTL.isp_PTL_TerminateModule
           @cStorerKey
         ,@nFunc
         ,@cStation
         ,'STATION'
         ,@bSuccess    OUTPUT
         ,@nErrNo       OUTPUT
         ,@cErrMsg      OUTPUT
      IF @nErrNo <> 0
         GOTO Quit

      DELETE FROM PTL.PTLTran
      WHERE IPAddress = @cIPAddress
        AND DeviceID = @cStation
        AND Func = 803
        AND Status = '1' -- Lighted up
        AND LightUp= '1'

      SET @cStation = ''

      GOTO Quit


  -- Go to station screen
   END

     
   /***********************************************************************************************  
                                                 CHECK  
   ***********************************************************************************************/  
   IF @cType = 'CHECK'  
   BEGIN  
      -- Screen mapping  
      SET @cDropID = @cInField01  
        
      -- Get total  
      SELECT @nTotalDropID = COUNT(1) FROM rdt.rdtPTLPieceLog WITH (NOLOCK) WHERE Station = @cStation AND SourceKey <> ''  
        
      -- Check finish assign  
      IF @cDropID = '' AND @nTotalDropID > 0  
      BEGIN  
         GOTO Quit  
      END  
        
      -- Check blank  
      IF @cDropID = ''   
      BEGIN  
         SET @nErrNo = 187951  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need DropID  
         GOTO Quit  
      END  
     
      -- Check DropID valid  
      IF NOT EXISTS( SELECT 1 FROM PickDetail WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND DropID = @cDropID)  
      BEGIN  
         SET @nErrNo = 187952  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Bad DropID  
         SET @cOutField01 = ''  
         GOTO Quit  
      END  
     
      -- Check DropID assigned  
      IF EXISTS(
         SELECT 1
         FROM rdt.rdtPTLPieceLog WITH (NOLOCK)   
         WHERE StorerKey = @cStorerKey  
            AND Method = @cMethod
            AND ( station <> @cStation or UserDefine01 <> @cCartID )
            AND SourceKey = @cDropID)  
      BEGIN  
         SET @nErrNo = 187953  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DropIDAssigned  
         SET @cOutField01 = ''  
         GOTO Quit  
      END

      DECLARE @OrderStation NVARCHAR(10)
      DECLARE @OrderPosition NVARCHAR(10)
      DECLARE @OrderLoc NVARCHAR(10)

--
      SELECT TOP 1 @cOrderKey = PD.OrderKey,
                   @cWaveKey = PD.Wavekey,
                   @OrderStation = Orders.UserDefine04,
                   @OrderLoc = Orders.UserDefine05 --logicalPos
      FROM dbo.PICKDETAIL PD WITH (NOLOCK)
         JOIN dbo.Orders Orders WITH (NOLOCK)
            ON PD.orderkey = Orders.Orderkey
      WHERE PD.Storerkey = @cStorerKey
         AND   PD.DropID = @cDropID
         AND   PD.[Status] = '3'
         AND Orders.UserDefine04 = @cStation -- Order assigned to this station
      ORDER BY 1


      SELECT TOP 1
         @OrderPosition = DevicePosition,
         @cIPAddress = IPAddress
      FROM dbo.DeviceProfile  WITH (NOLOCK)
         WHERE DeviceType = 'STATION'
         AND DeviceID = @cStation
         AND LOC = @OrderLoc
         AND StorerKey = @cStorerKey

      IF @@ROWCOUNT = 0 OR ISNULL(@OrderPosition,'') = ''
      BEGIN
         SET @nErrNo = 252857
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Can not find station/position
         SET @cOutField01 = ''
         GOTO Quit
      END


      IF (@OrderStation <> @cStation)
      BEGIN
         SET @nErrNo = 252856
         SET @cErrMsg = REPLACE (rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP'),'{}',@OrderStation)--Tote belongs to station {}
         SET @cOutField01 = ''
         GOTO Quit
      END


      IF NOT EXISTS ( SELECT 1
          FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
          WHERE Station = @cStation
          AND Position = @OrderPosition
          AND Method = @cMethod
          AND SourceKey = @cDropID)
      BEGIN

         -- Save assign
         INSERT rdt.rdtPTLPieceLog (Station, IPAddress, Position, Method, SourceKey, UserDefine01, StorerKey, Orderkey, Wavekey)
         VALUES
         (@cStation, @cIPAddress, @OrderPosition, @cMethod, @cDropID, @cCartID, @cStorerKey, @cOrderKey, @cWaveKey)

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 187957
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS Log fail
            GOTO Quit
         END
      END
      ELSE
      BEGIN
         UPDATE rdt.rdtPTLPieceLog
            SET EditDate = GETDATE(),
                EditWho  = SUSER_SNAME()
         WHERE Station = @cStation
           AND Position = @OrderPosition
           AND   Method = @cMethod
           AND   SourceKey = @cDropID
      END


      -- Get total  
      SELECT @nTotalDropID = COUNT( DISTINCT SourceKey) 
      FROM rdt.rdtPTLPieceLog WITH (NOLOCK) 
      WHERE Station = @cStation 
      AND   Method = @cMethod 
      AND   SourceKey <> ''  
  
      -- Prepare current screen var  
      SET @cOutField01 = '' -- DropID  
      SET @cOutField02 = CAST( @nTotalDropID AS NVARCHAR(5))  

  
   END  
  
Quit:  
  
END  
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON RDT.rdt_PTLPiece_Assign_DropID05_ONBR TO NSQL
GO
