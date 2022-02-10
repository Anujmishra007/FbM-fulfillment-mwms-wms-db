IF  EXISTS (SELECT * FROM sys.objects WHERE Object_Id = OBJECT_ID(N'[PTL].[isp_803PTL_Confirm03]') AND Type in (N'P', N'PC'))
   DROP PROCEDURE [PTL].[isp_803PTL_Confirm03]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/************************************************************************/  
/* Store procedure: isp_803PTL_Confirm03                                */  
/* Copyright      : LF Logistics                                        */  
/*                                                                      */  
/* Purpose: Accept QTY in CS-PCS, format 9-999                          */  
/*                                                                      */  
/* Date       Rev  Author   Purposes                                    */  
/* 21-10-2020 1.0  YeeKung  WMS-15551 Created                           */  
/************************************************************************/  
  
CREATE PROC [PTL].[isp_803PTL_Confirm03] (  
   @cIPAddress    NVARCHAR(30),   
   @cPosition     NVARCHAR(20),  
   @cFuncKey      NVARCHAR(2),   
   @nSerialNo     INT,  
   @cInputValue   NVARCHAR(20),  
   @nErrNo        INT           OUTPUT,    
   @cErrMsg       NVARCHAR(125) OUTPUT,    
   @cDebug        NVARCHAR( 1) = ''  
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @cLangCode      NVARCHAR( 3)  
   DECLARE @cUserName      NVARCHAR( 18)  
   DECLARE @nTranCount     INT  
   DECLARE @bSuccess       INT  
   DECLARE @nFunc          INT  
   DECLARE @nQTY           INT  
   DECLARE @nPTLKey        INT  
   DECLARE @nQTY_PTL       INT  
   DECLARE @nQTY_PD        INT  
   DECLARE @nQTY_Bal       INT  
   DECLARE @nExpectedQTY   INT  
   DECLARE @nGroupKey      INT  
   DECLARE @nCartonNo      INT  
   DECLARE @cStation       NVARCHAR( 10)  
   DECLARE @cCartonID      NVARCHAR( 20)  
   DECLARE @cSKU           NVARCHAR( 20)  
   DECLARE @cDropID        NVARCHAR( 20)  
   DECLARE @cType          NVARCHAR( 10)  
   DECLARE @cWaveKey       NVARCHAR( 10)  
   DECLARE @cLoadKey       NVARCHAR( 10)  
   DECLARE @cOrderKey      NVARCHAR( 10)  
   DECLARE @cPickSlipNo    NVARCHAR( 10)  
   DECLARE @cPickDetailKey NVARCHAR( 10)  
   DECLARE @cLightMode     NVARCHAR( 4)  
   DECLARE @cOrderLineNumber NVARCHAR( 5) 
  
   DECLARE @curPTL CURSOR  
   DECLARE @curPD  CURSOR  
  
   SET @nTranCount = @@TRANCOUNT  
   SET @nFunc = 803 -- PTL piece (rdt.rdtfnc_PTLPiece)  
   SET @cInputValue = RTRIM( LTRIM( @cInputValue))  
  
   -- Get light info  
   DECLARE @cStorerKey NVARCHAR(15)  
   SELECT TOP 1   
      @cStation = DeviceID,   
      @cStorerKey = StorerKey  
   FROM PTL.LightStatus WITH (NOLOCK)   
   WHERE IPAddress = @cIPAddress   
      AND DevicePosition = @cPosition   
  
   -- Get storer config  
   SET @cLightMode = rdt.RDTGetConfig( @nFunc, 'LightMode', @cStorerKey)  
  
   /***********************************************************************************************  
                                               END TOTE  
   ***********************************************************************************************/  
   IF @cInputValue = 'END'  
   BEGIN  
      -- Unassign position if fully sorted  
      DELETE rdt.rdtPTLPieceLog  
      WHERE Station = @cStation  
         AND IPAddress = @cIPAddress   
         AND Position = @cPosition   
      IF @@ERROR <> 0  
      BEGIN  
         SET @nErrNo = 160051   
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- DEL Log Fail  
         GOTO Quit  
      END  
  
      GOTO Quit  
   END  
  
   /***********************************************************************************************  
                                              CONFIRM ORDER  
   ***********************************************************************************************/  
   ELSE IF @cInputValue = '1'  
   BEGIN  
      -- Get booking info  
      SELECT      
         @cOrderKey = OrderKey  
      FROM rdt.rdtPTLPieceLog WITH (NOLOCK)  
      WHERE IPAddress = @cIPAddress  
         AND Position = @cPosition  
        
      -- End order if fully sorted  
      IF NOT EXISTS( SELECT 1 FROM PickDetail WITH (NOLOCK) WHERE OrderKey = @cOrderKey AND CaseID <> 'SORTED')  
      BEGIN  
         SET @cLightMode = rdt.RDTGetConfig( @nFunc, 'LightModeEnd', @cStorerKey)  
           
         EXEC PTL.isp_PTL_LightUpLoc  
            @n_Func           = @nFunc  
           ,@n_PTLKey         = 0  
           ,@c_DisplayValue   = 'END'  
           ,@b_Success        = @bSuccess    OUTPUT      
           ,@n_Err            = @nErrNo      OUTPUT    
           ,@c_ErrMsg         = @cErrMsg     OUTPUT  
           ,@c_DeviceID       = @cStation  
           ,@c_DevicePos      = @cPosition  
           ,@c_DeviceIP       = @cIPAddress    
           ,@c_LModMode       = @cLightMode  
         IF @nErrNo <> 0  
            GOTO RollBackTran  
      END  
      ELSE  
      BEGIN  
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
      END  
        
      COMMIT TRAN isp_803PTL_Confirm03  
      GOTO Quit  
   END  
  
   GOTO Quit  
  
RollBackTran:  
   ROLLBACK TRAN isp_803PTL_Confirm03 -- Only rollback change made here  
Quit:  
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
      COMMIT TRAN  
END 
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON PTL.isp_803PTL_Confirm03 TO NSQL
GO 