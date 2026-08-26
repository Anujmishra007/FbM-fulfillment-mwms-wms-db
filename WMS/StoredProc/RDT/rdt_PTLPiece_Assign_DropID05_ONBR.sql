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
/* 2026-02-20 1.0.1  NickT    FCR-9003 unassign the station only on step 4    */
/* 2026-03-10 1.1.0  Cuize    UWP-49877 unassign Only wave complete           */
/* 2026-08-21 1.2.0  NickT    FCR-14204 Add Hospital logic.                   */
/******************************************************************************/
  
CREATE OR ALTER PROC [RDT].[rdt_PTLPiece_Assign_DropID05_ONBR] (
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
  
   DECLARE @cDropID              NVARCHAR( 20)
   DECLARE @nTotalDropID         INT
   DECLARE @cIPAddress           NVARCHAR( 40)
   DECLARE @cPosition            NVARCHAR( 10)
   DECLARE @cOrderKey            NVARCHAR( 10)
   DECLARE @cWaveKey             NVARCHAR( 10)
   DECLARE @cAssignedStation     NVARCHAR( 10)
   DECLARE @cLogicalName         NVARCHAR( 10)
   DECLARE @cCartID              NVARCHAR( 10)
   DECLARE @bSuccess             INT
   DECLARE @cDeviceID            NVARCHAR( 20)
   DECLARE @cUserName            NVARCHAR( 128) 
   DECLARE @cHospLocIdentifier   NVARCHAR( 10)
   DECLARE @cBulkHospLocPrefix   NVARCHAR( 10)
   DECLARE @cHSBK                NVARCHAR( 10) = 'HSBK'

   SELECT
      @cDeviceID  = DeviceID,
      @cUserName = UserName,
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

         SET @nErrNo = 278751
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --278751 DeviceID Can not be empty
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

      IF @nStep = 99 AND @nScn = 6925 AND @nInputKey = 1 AND @cInField01 = '1'
      BEGIN

         IF @cStation <> 'HOSPITAL'
         BEGIN
            SELECT TOP 1
               @cWaveKey = WaveKey
            FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
            WHERE Station = @cStation
            AND   Method = @cMethod
            AND   SourceKey <> ''

            --Check if there are pickdetails not yet moved to cart slot
            -- IF ISNULL(@cWaveKey,'') <> '' -- At least assigned on DropID
            --    AND EXISTS(
            --       SELECT 1
            --       FROM PICKDETAIL AS PD WITH (NOLOCK)
            --               JOIN Orders O WITH (NOLOCK) ON O.orderkey = PD.orderkey
            --       WHERE PD.wavekey = @cwavekey
            --         AND PD.DropID NOT LIKE 'CART%'
            --         AND O.UserDefine04 = @cStation
            --    )
            --    BEGIN
            --       SET @nErrNo = 252861
            --       SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --WaveNotComplete
            --       GOTO Quit
            --    END


            BEGIN TRY
               UPDATE dbo.DeviceProfile WITH(ROWLOCK)
               SET 
                  STATUS = 'IDLE'
               WHERE DeviceType = 'STATION'
                  AND DeviceID = @cStation
                  AND StorerKey = @cStorerKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 278764
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Failed to update device status
               GOTO Quit
            END CATCH

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

            BEGIN TRY
               DELETE FROM PTL.PTLTran
               WHERE IPAddress = @cIPAddress
                  AND DeviceID = @cStation
                  AND Func = 803
                  AND Status = '1' -- Lighted up
                  AND LightUp= '1'
            END TRY
            BEGIN CATCH
               SET @nErrNo = 278765
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Failed to delete PTLTran
               GOTO Quit
            END CATCH
         END

         SET @cStation = ''

         GOTO Quit
      END
   -- Go to station screen
   END

     
   /***********************************************************************************************  
                                                 CHECK  
   ***********************************************************************************************/  
   IF @cType = 'CHECK'  
   BEGIN  
      -- Screen mapping  
      SET @cDropID = @cInField01  

      SET @nTotalDropID = 0
      -- Get total
      IF @cStation = 'HOSPITAL'
      BEGIN
         SELECT @nTotalDropID = COUNT(1) 
         FROM rdt.rdtPTLPieceLog WITH (NOLOCK) 
         WHERE Station = @cStation 
            AND SourceKey <> ''
            AND AddWho = @cUserName
      END
      ELSE
      BEGIN
         SELECT @nTotalDropID = COUNT(1) 
         FROM rdt.rdtPTLPieceLog WITH (NOLOCK) 
         WHERE Station = @cStation 
            AND SourceKey <> ''  
      END

      -- Check finish assign  
      IF @cDropID = '' AND @nTotalDropID > 0
      BEGIN  
         GOTO Quit  
      END  
        
      -- Check blank  
      IF @cDropID = ''   
      BEGIN  
         SET @nErrNo = 278752
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --278752 Need DropID
         GOTO Quit  
      END  
     
      -- Check DropID valid  
      IF NOT EXISTS( SELECT 1 FROM PickDetail WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND DropID = @cDropID)  
      BEGIN  
         SET @nErrNo = 278753
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --278753 Drop ID not found in PickDetail
         SET @cOutField01 = ''  
         GOTO Quit  
      END

      -- Check DropID assigned  
      IF @cStation = 'HOSPITAL'
      BEGIN
         IF EXISTS( SELECT 1
                  FROM rdt.rdtPTLPieceLog WITH (NOLOCK)   
                  WHERE StorerKey = @cStorerKey  
                     AND Method = @cMethod
                     AND SourceKey = @cDropID)  
         BEGIN
            SET @nErrNo = 278754  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --278754 Drop ID already assigned
            SET @cOutField01 = ''  
            GOTO Quit  
         END

         SET @cHospLocIdentifier = rdt.rdtGetConfig(@nFunc, 'HOSPLOCIDENTIFIER', @cStorerKey)
         IF ISNULL(@cHospLocIdentifier, '') = '' OR @cHospLocIdentifier = '0'
            SET @cHospLocIdentifier = 'HS'

         SET @cBulkHospLocPrefix = rdt.rdtGetConfig(@nFunc, 'BulkHospLoc', @cStorerKey)
         IF ISNULL(@cBulkHospLocPrefix, '') = '' OR @cBulkHospLocPrefix = '0'
            SET @cBulkHospLocPrefix = 'ONBR_HSP'

         SELECT TOP 1 
            @cOrderKey = PD.OrderKey,
            @cWaveKey = PD.Wavekey
         FROM dbo.PICKDETAIL PD WITH (NOLOCK)
         INNER JOIN dbo.Orders ORM WITH (NOLOCK)
            ON PD.orderkey = ORM.Orderkey
            AND PD.StorerKey = ORM.StorerKey
         WHERE PD.Storerkey = @cStorerKey
            AND PD.DropID = @cDropID
            AND PD.Status = '3'
         ORDER BY PD.OrderKey, PD.PickDetailKey

         IF @@ROWCOUNT = 0
         BEGIN
            SET @nErrNo = 278763  
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --  No order found for this DropID
            SET @cOutField01 = ''
            GOTO Quit
         END

         IF NOT EXISTS(SELECT 1 
                     FROM dbo.PickDetail WITH(NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND OrderKey = @cOrderKey
                        AND Wavekey = @cWaveKey
                        AND Status = '3'
                        AND (LEFT(Loc, LEN(@cHospLocIdentifier)) = @cHospLocIdentifier OR LEFT(Loc, LEN(@cBulkHospLocPrefix)) = @cBulkHospLocPrefix)
                     )
         BEGIN
            IF NOT EXISTS( SELECT 1
               FROM dbo.RFPutaway WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND FromID = @cDropID
                  AND ID IS NOT NULL
                  AND (
                        ( LEFT(SuggestedLoc, LEN(@cHospLocIdentifier)) = @cHospLocIdentifier AND LEFT(ID, LEN(@cHospLocIdentifier)) = @cHospLocIdentifier )
                        OR 
                        ( LEFT(SuggestedLoc, LEN(@cBulkHospLocPrefix)) = @cBulkHospLocPrefix  AND LEFT(ID, LEN(@cHSBK)) = @cHSBK )
                  )
            )
            BEGIN
               SET @nErrNo = 278762
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --278762 No order found in hospital location
               SET @cOutField01 = ''
               GOTO Quit
            END
         END

         IF NOT EXISTS ( SELECT 1
            FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
            WHERE Station = @cStation
            AND Method = @cMethod
            AND SourceKey = @cDropID)
         BEGIN
            -- Save assign
            BEGIN TRY
               INSERT rdt.rdtPTLPieceLog (Station, IPAddress, Position, Method, SourceKey, UserDefine01, StorerKey, Orderkey, Wavekey)
               VALUES
               (@cStation, '', '', @cMethod, @cDropID, '', @cStorerKey, @cOrderKey, @cWaveKey)
            END TRY
            BEGIN CATCH
               SET @nErrNo = 278755
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --278755 Failed to save assignment log
               GOTO Quit
            END CATCH
         END
         ELSE
         BEGIN
            DECLARE @trdtPTLPieceLog TABLE (RowRef INT NOT NULL PRIMARY KEY)

            INSERT INTO @trdtPTLPieceLog (RowRef)
            SELECT RowRef
            FROM rdt.rdtPTLPieceLog WITH (ROWLOCK)
            WHERE Station = @cStation
               AND Method = @cMethod
               AND SourceKey = @cDropID

            BEGIN TRY
               UPDATE RPPL WITH(ROWLOCK)
               SET 
                  EditDate = GETDATE(),
                  EditWho  = SUSER_SNAME()
               FROM rdt.rdtPTLPieceLog RPPL
               INNER JOIN @trdtPTLPieceLog TRPPL
                  ON RPPL.RowRef = TRPPL.RowRef
            END TRY
            BEGIN CATCH
               SET @nErrNo = 278758
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --278758 Failed to update assignment log
            END CATCH
         END

         -- Get total  
         SELECT @nTotalDropID = COUNT( DISTINCT SourceKey) 
         FROM rdt.rdtPTLPieceLog WITH (NOLOCK) 
         WHERE Station = @cStation 
            AND Method = @cMethod
            AND OrderKey = @cOrderKey
            AND SourceKey <> ''  
      END
      ELSE
      BEGIN
         IF EXISTS(
            SELECT 1
            FROM rdt.rdtPTLPieceLog WITH (NOLOCK)   
            WHERE StorerKey = @cStorerKey  
               AND Method = @cMethod
               AND ( station <> @cStation or UserDefine01 <> @cCartID )
               AND SourceKey = @cDropID)
         BEGIN
            SET @nErrNo = 278759
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --278759 Drop ID already assigned
            SET @cOutField01 = ''  
            GOTO Quit  
         END

         DECLARE @OrderStation NVARCHAR(10)
         DECLARE @OrderPosition NVARCHAR(10)
         DECLARE @OrderLoc NVARCHAR(10)

         SELECT TOP 1 @cOrderKey = PD.OrderKey,
                     @cWaveKey = PD.Wavekey,
                     @OrderStation = Orders.UserDefine04,
                     @OrderLoc = Orders.UserDefine05 --logicalPos
         FROM dbo.PICKDETAIL PD WITH (NOLOCK)
         INNER JOIN dbo.Orders Orders WITH (NOLOCK)
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
            SET @nErrNo = 278756
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --278756 No PTL position found for this Drop ID at current station
            SET @cOutField01 = ''
            GOTO Quit
         END


         IF (@OrderStation <> @cStation)
         BEGIN
            SET @nErrNo = 278757
            SET @cErrMsg = REPLACE (rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP'),'{}',@OrderStation) --278757 Tote belongs to station {}. Please scan at correct station
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
            BEGIN TRY
               INSERT rdt.rdtPTLPieceLog (Station, IPAddress, Position, Method, SourceKey, UserDefine01, StorerKey, Orderkey, Wavekey)
               VALUES
               (@cStation, @cIPAddress, @OrderPosition, @cMethod, @cDropID, @cCartID, @cStorerKey, @cOrderKey, @cWaveKey)
            END TRY
            BEGIN CATCH
               SET @nErrNo = 278760
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --278760 Failed to save assignment log
               GOTO Quit
            END CATCH
         END
         ELSE
         BEGIN
            BEGIN TRY
               UPDATE rdt.rdtPTLPieceLog
                  SET EditDate = GETDATE(),
                     EditWho  = SUSER_SNAME()
               WHERE Station = @cStation
               AND Position = @OrderPosition
               AND   Method = @cMethod
               AND   SourceKey = @cDropID
            END TRY
            BEGIN CATCH
               SET @nErrNo = 278761
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --278761 Failed to update assignment log
               GOTO Quit
            END CATCH
         END

         -- Get total  
         SELECT @nTotalDropID = COUNT( DISTINCT SourceKey) 
         FROM rdt.rdtPTLPieceLog WITH (NOLOCK) 
         WHERE Station = @cStation 
         AND   Method = @cMethod 
         AND   SourceKey <> ''  
      END

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
