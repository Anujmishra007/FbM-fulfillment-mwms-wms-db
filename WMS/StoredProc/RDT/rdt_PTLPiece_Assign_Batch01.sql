IF  EXISTS (SELECT * FROM sys.objects WHERE Object_Id = OBJECT_ID(N'[RDT].[rdt_PTLPiece_Assign_Batch01]') AND Type in (N'P', N'PC'))
   DROP PROCEDURE rdt.rdt_PTLPiece_Assign_Batch01
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/******************************************************************************/  
/* Store procedure: rdt_PTLPiece_Assign_Batch01                               */  
/* Copyright      : LFLogistics                                               */  
/*                                                                            */  
/* Date       Rev  Author   Purposes                                          */  
/* 12-03-2021 1.0  yeekung  WMS-16066 Created                                 */  
/******************************************************************************/  
  
CREATE PROC [RDT].[rdt_PTLPiece_Assign_Batch01] (  
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
   @cErrMsg          NVARCHAR( 20) OUTPUT  
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @nTranCount  INT  
   DECLARE @cSQL           NVARCHAR(MAX)  
   DECLARE @cSQLParam      NVARCHAR(MAX)  
  
   DECLARE @cIPAddress      NVARCHAR(40)  
   DECLARE @cPosition       NVARCHAR(10)  
   DECLARE @cBatchKey NVARCHAR(20)  
   DECLARE @cCartonID NVARCHAR(20)  
   DECLARE @cLogicalPos NVARCHAR(20)  
   DECLARE @cLOC NVARCHAR(10)  
  
   DECLARE @tVar           VariableTable  
   DECLARE @cCurrentSP NVARCHAR( 60)  
  
   SET @nTranCount = @@TRANCOUNT  
  
   DECLARE @cAssignExtUpdSP NVARCHAR( 20) --(yeekung01)  
   SET @cAssignExtUpdSP = rdt.RDTGetConfig( @nFunc, 'AssignExtUpdSP', @cStorerKey)  
   IF @cAssignExtUpdSP = '0'  
      SET @cAssignExtUpdSP = ''  
  
   /***********************************************************************************************  
                                                POPULATE  
   ***********************************************************************************************/  
   IF @cType = 'POPULATE-IN'  
   BEGIN  
      IF @nInputKey=0  
      BEGIN  
         SET @cOutField01=''  
         SET @nScn = 4606  
      END  
      ELSE  
      BEGIN  
  
  
         SELECT @cBatchKey=BatchKey  
         FROM rdt.rdtptlpiecelog (NOLOCK)  
         where station=@cStation  
         and storerkey=@cStorerKey  
  
         -- Prepare next screen var  
     SET @cOutField01 = @cBatchKey  
     SET @cOutField02 = '' -- OrderKey  
     SET @cOutField03 = '' -- Position  
  
         IF ISNULL(@cBatchKey,'') = ''  
         BEGIN  
            -- Enable disable field  
            SET @cFieldAttr01 = ''  -- WaveKey  
            SET @cFieldAttr04 = 'O' -- CartonID  
  
          EXEC rdt.rdtSetFocusField @nMobile, 1 -- WaveKey  
         END  
         ELSE  
         BEGIN  
            SET @cFieldAttr01 = 'o'  -- WaveKey  
            SET @cFieldAttr03 = '' -- CartonID  
  
          EXEC rdt.rdtSetFocusField @nMobile, 3-- WaveKey  
         END  
      END  
  
      IF @nScn = 4606  
      BEGIN  
         SET @cOutField01=''  
      END  
      ELSE  
         -- Go to batch screen  
     SET @nScn = 4605  
   END  
        
  
   IF @cType = 'POPULATE-OUT'  
   BEGIN  
      IF @nScn=4606  
      BEGIN  
         SELECT @cBatchKey=BatchKey  
         FROM rdt.rdtptlpiecelog (NOLOCK)  
         where station=@cStation  
         and storerkey=@cStorerKey  
  
         -- Prepare next screen var  
     SET @cOutField01 = @cBatchKey  
     SET @cOutField02 = '' -- OrderKey  
     SET @cOutField03 = '' -- Position  
         SET @cOutField04 = ''  
         SET @cOutField05 = ''  
  
         SET @nscn=4605  
         SET @nErrNo='-1'  
         GOTO quit  
      END  
  
      SET @cFieldAttr01 = '' -- WaveKey  
      SET @cFieldAttr03 = '' -- CartonID  
   END  
  
     
   /***********************************************************************************************  
                                                 CHECK  
   ***********************************************************************************************/  
   IF @cType = 'CHECK'  
   BEGIN  
  
      IF @nScn=4605  
      BEGIN  
         SET @cBatchKey=CASE WHEN @cFieldAttr01 = '' THEN @cInField01 ELSE @cOutField01 END  
         SET @cPosition=@cOutField02  
         SET @cLogicalPos=@cOutField03  
         SET @cCartonID=CASE WHEN @cFieldAttr04 = '' THEN @cInField04 ELSE @cOutField04 END  
         SET @cLoc = @cOutField05  
  
         IF @cFieldAttr01=''  
         BEGIN  
  
            IF ISNULL(@cBatchKey,'')=''   
            BEGIN  
               SET @nErrNo = 172301   
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ASNIsBlank  
               GOTO QUIT  
            END  
  
            IF NOT EXISTS (SELECT 1 from receipt (NOLOCK) where UserDefine10=@cBatchKey and storerkey=@cStorerKey and status=0)  
            BEGIN  
               SET @nErrNo = 172302  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidASN  
               GOTO QUIT  
            END  
  
            DECLARE @cUserID NVARCHAR(20)  
  
            SELECT @cUserID=username  
            from rdt.rdtmobrec (NOLOCK)   
            where mobile=@nMobile  
  
  
            -- Handling transaction  
            BEGIN TRAN  -- Begin our own transaction  
            SAVE TRAN rdt_PTLPiece_Assign -- For rollback or commit only our own transaction  
  
            -- Loop orders  
            DECLARE @cPreassignPos NVARCHAR(10)  
            DECLARE @cuserdefine01 NVARCHAR(10)  
            DECLARE @csku NVARCHAR(20)  
            DECLARE @cUserdefine02 nvarchar(20)  
  
            DECLARE @cPrePos CURSOR  
            SET @cPrePos = CURSOR FOR  
               SELECT TOP 8  
                    DP.DevicePosition  
               FROM dbo.DeviceProfile DP WITH (NOLOCK)  
               WHERE DP.DeviceType = 'STATION'  
                  AND DP.DeviceID = @cStation  
                  AND NOT EXISTS( SELECT 1  
                     FROM rdt.rdtPTLPieceLog Log WITH (NOLOCK)  
                     WHERE Log.Station = @cStation  
                        AND Log.Position = DP.DevicePosition)  
               group by DP.DevicePosition  
               ORDER BY DP.DevicePosition  
            OPEN @cPrePos  
            FETCH NEXT FROM @cPrePos INTO @cPosition  
            WHILE @@FETCH_STATUS = 0  
            BEGIN  
  
               DECLARE @curOrder CURSOR  
               SET @curOrder = CURSOR FOR  
               SELECT   
                     DP.IPAddress,   
                     DP.Loc  
               FROM dbo.DeviceProfile DP WITH (NOLOCK)  
               WHERE DP.DeviceType = 'STATION'  
                  AND DP.DeviceID = @cStation  
                  AND DP.DevicePosition=@cPosition  
  
               OPEN @curOrder  
               FETCH NEXT FROM @curOrder INTO @cIPAddress, @cLoc  
               WHILE @@FETCH_STATUS = 0  
               BEGIN  
                  IF EXISTS (SELECT 1 FROM rdt.rdtPTLPieceLog (NOLOCK)   
                              WHERE storerkey=@cStorerKey  
                              AND batchkey=@cBatchKey  
                              AND loc=@cloc  
                              AND station<>@cStation)  
                  BEGIN  
                     SELECT @cCartonID=cartonid,  
                     @cuserdefine01=userdefine01  
                     ,@csku=sku  
                     ,@cuserdefine02=userdefine02  
                     FROM rdt.rdtPTLPieceLog (NOLOCK)   
                     WHERE storerkey=@cStorerKey  
                     AND batchkey=@cBatchKey  
                     AND loc=@cloc  
                     AND station<>@cStation  
                  END  
                  ELSE  
                  BEGIN  
                     SET @cCartonID=''  
                  END  
  
  
                  INSERT rdt.rdtPTLPieceLog (Station, IPAddress, Position,batchkey,loc,storerkey,cartonid)  
                  VALUES (@cStation, @cIPAddress, @cPosition,@cBatchKey,@cLOC,@cStorerKey,@cCartonID)  
  
                  IF @@ERROR <> 0  
                  BEGIN  
                     SET @nErrNo = 172303  
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS Log fail  
                     GOTO RollBackTran  
                  END  
  
                  UPDATE rdt.rdtPTLPieceLog  
                  SET   
                     userdefine01=CASE WHEN ISNULL(@cuserdefine01,'')='' THEN userdefine01 ELSE @cuserdefine01 END  
                     ,sku =CASE WHEN ISNULL(@csku,'')='' THEN sku ELSE @csku END  
                     ,userdefine02 =CASE WHEN ISNULL(@cUserdefine02,'')='' THEN UserDefine02 ELSE @cUserdefine02 END  
                  WHERE Station=@cStation  
                  AND IPAddress=@cIPAddress  
                  AND loc=@cLoc  
  
                  FETCH NEXT FROM @curOrder INTO @cIPAddress,@cLoc  
               END  
  
               FETCH NEXT FROM @cPrePos INTO @cPosition  
            END  
  
            set @cPosition=''  
  
            SELECT TOP 1   
               @cPosition = PTL.Position  
               ,@cLogicalPos=DP.logicalPos  
               ,@cloc=ptl.loc  
            FROM rdt.rdtPTLPieceLog PTL WITH (NOLOCK)  
            JOIN deviceprofile DP on (PTL.station=DP.deviceid)  
            WHERE Station = @cStation  
            AND CartonID = ''  
            ORDER BY RowRef   
  
            IF ISNULL(@cPosition,'')<>''  
            BEGIN  
               -- Prepare current screen var  
               SET @cOutField01 = @cBatchKey  
               SET @cOutField02 = @cPosition  
               SET @cOutField03 = @cLogicalPos  
               SET @cOutField04 = ''  
               SET @cOutField05 = @cLoc  
              
               -- Enable / Disable field  
               SET @cFieldAttr01 = 'O' -- BatchKey  
               SET @cFieldAttr04 = ''  -- CartonID  
  
               EXEC rdt.rdtSetFocusField @nMobile, 4 -- CartonID  
  
               SET @nErrNo = -1  
              
               GOTO QUIT  
            END  
  
         END  
  
         -- CartonID enable  
         IF @cFieldAttr04 = ''  
         BEGIN  
            IF (@cPosition<>'')  
            BEGIN                  -- Check blank carton  
               IF @cCartonID = ''  
               BEGIN  
                  SET @nErrNo = 172304  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need CartonID  
                  EXEC rdt.rdtSetFocusField @nMobile, 4 -- CartonID  
                  GOTO Quit  
               END  
     
               -- Check barcode format  
               IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'CartonID', @cCartonID) = 0  
               BEGIN  
                  SET @nErrNo = 172305  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format  
                  EXEC rdt.rdtSetFocusField @nMobile, 4 -- CartonID  
                  SET @cOutField04 = ''  
                  GOTO Quit  
               END  
  
               -- Check carton assigned  
               IF EXISTS( SELECT 1  
                  FROM rdt.rdtPTLPieceLog WITH (NOLOCK)  
                  WHERE Station = @cStation  
                     AND CartonID = @cCartonID)  
               BEGIN  
                  SET @nErrNo = 172306  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --CartonAssigned  
                  EXEC rdt.rdtSetFocusField @nMobile, 4 -- CartonID  
                  SET @cOutField04 = ''  
                  GOTO Quit  
               END  
  
               SELECT TOP 1   
                  @cLoc=PTL.Loc  
               FROM rdt.rdtPTLPieceLog PTL WITH (NOLOCK)  
               JOIN deviceprofile DP on (PTL.station=DP.deviceid)  
               WHERE Station = @cStation  
               and  PTL.Position= @cPosition   
               and  DP.logicalPos=@cLogicalPos  
               and  PTL.Cartonid=''  
               order by DP.logicalPos  
  
               -- Save assign  
               UPDATE rdt.rdtPTLPieceLog WITH (ROWLOCK)   
               SET  
                  CartonID = @cCartonID  
               WHERE Station = @cStation  
                  AND position = @cPosition  
                  and loc=@cLoc  
               IF @@ERROR <> 0  
               BEGIN  
                  SET @nErrNo = 172307  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD Log fail  
                  GOTO Quit  
               END  
  
               SET @cPosition=''  
  
               SELECT TOP 1   
                  @cPosition = DP.deviceposition  
                  ,@cLogicalPos=DP.logicalPos  
                  ,@cLoc=ptl.loc  
               FROM rdt.rdtPTLPieceLog PTL WITH (NOLOCK)  
                JOIN deviceprofile DP on (PTL.station=DP.deviceid and ptl.position = dp.deviceposition and PTL.loc=dp.loc)  
                JOIN Loc L ON (L.loc=PTL.Loc)  
               WHERE DP.deviceid = @cStation  
               AND CartonID = ''  
               ORDER BY L.LogicalLocation  
  
               IF ISNULL(@cPosition,'')<>''  
               BEGIN  
                  -- Prepare current screen var  
                  SET @cOutField01 = @cBatchKey  
                  SET @cOutField02 = @cPosition  
                  SET @cOutField03 = @cLogicalPos  
                  SET @cOutField04 = ''  
                  SET @cOutField05 = @cLoc  
                  SET @nErrNo = -1  
  
                  GOTO QUIT  
               END  
               ELSE  
               BEGIN  
                  SET @nScn=4606  
                  SET @cOutField01=''  
                  SET @cBatchKey=''  
                  SET @cInField01=''  
                  SET @nErrNo = -1  
               END  
            END  
            ELSE  
            BEGIN  
               SET @nScn=4606  
               SET @nErrNo = -1  
               SET @cOutField01=''  
               SET @cBatchKey=''  
               SET @cInField01=''  
            END  
         END  
  
         SET @cInField01=''  
         -- Enable / Disable field  
         SET @cFieldAttr01 = '' -- BatchKey  
         SET @cFieldAttr04 = ''  -- CartonID  
      END  
  
      IF @nScn=4606  
      BEGIN   
         DECLARE @cReceiptkey NVARCHAR(20)  
  
         SELECT @cUserID=username  
         from rdt.rdtmobrec (NOLOCK)   
         where mobile=@nMobile  
  
         SELECT @cBatchKey=BatchKey  
         FROM rdt.rdtPTLPieceLog (NOLOCK)  
         WHERE station=@cStation  
         AND storerkey=@cStorerKey  
  
         SET @creceiptkey= @cInField01   
  
         IF NOT EXISTS (SELECT 1 FROM receipt (nolock) WHERE UserDefine10=@cBatchKey AND receiptkey=@cReceiptkey AND storerkey=@cStorerKey AND status=0)  
         BEGIN  
            SET @nErrNo = 172302  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidASN  
            GOTO QUIT  
         END  
  
           
         SELECT TOP 1 @cPosition=Position,  
                      @cIPAddress=IPAddress,  
                      @cloc=loc  
         FROM rdt.rdtPTLPieceLog (NOLOCK)  
         WHERE EditWho=@cUserID  
         AND UserDefine02<>''  
         ORDER BY EditDate DESC  
           
         UPDATE rdt.rdtPTLPieceLog WITH(ROWLOCK)  
         SET UserDefine02=''  
         WHERE Position=@cPosition  
         AND IPAddress=@cIPAddress  
         AND loc=@cLOC  
  
         UPDATE rdt.rdtPTLPieceLog WITH(ROWLOCK)  
         SET UserDefine03=@cReceiptkey  
         WHERE station=@cStation  
         AND storerkey=@cStorerKey  
  
      END  
  
   END  
  
   GOTO Quit  
  
  
RollBackTran:  
   ROLLBACK TRAN rdt_PTLPiece_Assign  
  
Quit:  
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
      COMMIT TRAN  
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_PTLPiece_Assign_Batch01 TO NSQL
GO