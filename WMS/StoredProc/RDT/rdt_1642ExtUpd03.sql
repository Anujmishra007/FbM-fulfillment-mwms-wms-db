SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Store procedure: rdt_1642ExtUpd03                                    */  
/* Purpose: Add RDT.RDTScanToTruck and AUTOSHIP                         */  
/*                                                                      */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2015-05-08 1.0  PSJ036     Add RDT.RDTScanToTruck and AUTOSHIP       */  
/************************************************************************/  
  
CREATE OR ALTER   PROC [RDT].[rdt_1642ExtUpd03] (  
   @nMobile          INT,   
   @nFunc            INT,   
   @nStep            INT,   
   @nInputKey        INT,   
   @cLangCode        NVARCHAR( 3),    
   @cDropID          NVARCHAR( 20),   
   @cMbolKey         NVARCHAR( 10),   
   @cDoor            NVARCHAR( 20),   
   @cOption          NVARCHAR( 1),    
   @cRSNCode         NVARCHAR( 10),   
   @nAfterStep       INT,   
   @nErrNo           INT           OUTPUT,   
   @cErrMsg          NVARCHAR( 20) OUTPUT    
)  
AS  
  
SET NOCOUNT ON  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS OFF  
  
   DECLARE @nStartTCnt        INT,   
           @cLoadkey          NVARCHAR( 10),  
           @cExternOrderKey   NVARCHAR( 20),   
           @cConsigneeKey     NVARCHAR( 15),    
           @cLP_LaneNumber    NVARCHAR( 5),   
           @cOrderkey         NVARCHAR( 10),   
           @cFacility         NVARCHAR( 5),   
           @cStorerKey        NVARCHAR( 15),   
           @cSku              NVARCHAR( 20),
		   @cCaseId 		  NVARCHAR( 20),
           @cLot              NVARCHAR( 10),   
           @cFromLoc          NVARCHAR( 10),   
           @cMoveRefKey       NVARCHAR( 10),
           @cAutoShipMBOL     NVARCHAR( 10),
           @nKeyCount         INT = 0,
           @nWarningNo        INT = 0,
           @cUserName         NVARCHAR( 128),		   
           @cID               NVARCHAR( 18),   
           @cMBOL4DropID      NVARCHAR( 10),   
		   @cDocType           NVARCHAR( 1),
           @nQty              INT,   
           @bSuccess          INT   
  
  
   SELECT @cFacility = Facility, @cStorerKey = StorerKey, @cUserName = UserName FROM RDT.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile  
   
   SET @cAutoShipMBOL = rdt.rdtGetConfig(@nFunc, 'AUTOSHIPMBOL', @cStorerKey)
   IF @cAutoShipMBOL = '0'
   SET @cAutoShipMBOL = ''

   SET @nStartTCnt = @@TRANCOUNT
   BEGIN TRAN
   SAVE TRAN rdt_1642ExtUpd03

   IF @nStep = 2  
		BEGIN  
			IF @nInputKey = 1    
			BEGIN  
				IF ISNULL(@cDropID, '') = ''  
				BEGIN  
					SET @nErrNo  = 257561     
					SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- DROPID REQ  
					GOTO Quit  
				END  

				SELECT TOP 1 
					   @cCaseId = CaseId
				FROM dbo.PALLETDETAIL
				WHERE StorerKey = @cStorerKey
				  AND PalletKey = @cDropID
				  AND [Status]  = '9'

				IF ISNULL(@cCaseId, '') = ''  
				BEGIN  
					SET @nErrNo  = 257562     
					SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Bad Pallet  
					GOTO Quit  
				END  

				SELECT TOP 1 
					   @cOrderKey = OrderKey   
				FROM dbo.PickDetail WITH (NOLOCK)   
				WHERE StorerKey = @cStorerKey  
				  AND CaseId    = @cCaseId  
				  AND [Status] < '9'  

				IF ISNULL(@cOrderKey, '') = ''  
				BEGIN  
					SET @nErrNo  = 257563     
					SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Order Shipped  
					GOTO Quit  
				END		 

				/* Get MBOL and LoadKey */
				SELECT TOP 1
					   @cMBOLKey = MbolKey,
					   @cLoadKey = LoadKey
				FROM dbo.MBOLDetail WITH (NOLOCK)   
				WHERE OrderKey = @cOrderKey  

				/* Insert into RDTScanToTruck */
				IF NOT EXISTS ( SELECT 1 
								FROM RDT.RDTScanToTruck WITH (NOLOCK)   
								WHERE MBOLKey = @cMBOLKey  
								  AND RefNo   = @cDropID  
								  AND [Status] = '9')  
				BEGIN  
					INSERT INTO RDT.RDTScanToTruck  
						(MBOLKey, LoadKey, CartonType, RefNo, URNNo, Status,
						 AddWho, AddDate, EditWho, EditDate, Door)  
					VALUES 
						(@cMBOLKey, @cLoadKey, '', @cDropID, '', '9',
						 sUser_sName(), GETDATE(), sUser_sName(), GETDATE(), @cDoor)   

					IF @@ERROR <> 0  
					BEGIN  
						SET @nErrNo  = 257564  
						SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- InsScn2TrkFail  
						GOTO Quit  
					END
				END 

				/* Auto Ship MBOL */
				IF @cAutoShipMBOL = '1'
				BEGIN
					SET @nKeyCount  = 0
					SET @nWarningNo = 0

					BEGIN TRY
						EXEC [WM].[lsp_WaveShip] 
							@c_WaveKey            = '',
							@c_MBOLkey            = @cMBOLKey,
							@c_ShipMode           = 'MBOL',
							@n_TotalSelectedKeys  = 1,
							@c_ProceedWithWarning = 'N',
							@c_UserName           = @cUserName,
							@n_KeyCount           = @nKeyCount   OUTPUT,
							@b_Success            = @bSuccess    OUTPUT,
							@n_err                = @nErrNo      OUTPUT,
							@c_ErrMsg             = @cErrMsg     OUTPUT,
							@n_WarningNo          = @nWarningNo  OUTPUT
					END TRY
					BEGIN CATCH
						SET @nErrNo  = 257565
						SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- AUTO SHIP FAIL
						GOTO Quit
					END CATCH
				 END
			  END 
		   END 



Quit:
IF ISNULL( @nErrNo, 0) <> 0  -- Error Occured - Process And Return    
   ROLLBACK TRAN rdt_1642ExtUpd03    
 
WHILE @@TRANCOUNT > @nStartTCnt -- Commit until the level we started    
   COMMIT TRAN rdt_1642ExtUpd03 
   
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1642ExtUpd03] TO [NSQL]
GO   
