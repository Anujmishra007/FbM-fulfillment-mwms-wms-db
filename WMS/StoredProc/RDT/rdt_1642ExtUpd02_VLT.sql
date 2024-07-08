
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Store procedure: rdt_1642ExtUpd02_VLT                                */  
/* Purpose To activiate Scanned Flag in Fn1642 with ScanToDoor Rpt      */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 24-05-2024 1.0  WSE016     Created to change Fn1642 Scanned Flag     */ 
/* 04-06-2024 1.1  PPA374     Update to check pack details and to show  */
/* message that everything is loaded.                                   */
/*                                                                      */  
/************************************************************************/  
  
CREATE OR ALTER   PROC [RDT].[rdt_1642ExtUpd02_VLT] (  
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

BEGIN  
  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
  
   DECLARE  @nStartTCnt        INT,   
            @cLoadkey          NVARCHAR( 10),  
            @cExternOrderKey   NVARCHAR( 20),   
            @cConsigneeKey     NVARCHAR( 15),    
            @cLP_LaneNumber    NVARCHAR( 5),   
            @cOrderkey         NVARCHAR( 10),   
            @cFacility         NVARCHAR( 5),   
            @cStorerKey        NVARCHAR( 15),   
            @cSku              NVARCHAR( 20),   
            @cLot              NVARCHAR( 10),   
            @cFromLoc          NVARCHAR( 10),   
            @cMoveRefKey       NVARCHAR( 10),   
            @cID               NVARCHAR( 18),   
            @cMBOL4DropID      NVARCHAR( 10),   
            @nQty              INT,   
            @bSuccess          INT,
            @PickSLipNo        NVARCHAR(20)
  
   SELECT @cFacility = Facility, @cStorerKey = StorerKey FROM RDT.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile  
  
   SET @nStartTCnt = @@TRANCOUNT    
   BEGIN TRAN    
   SAVE TRAN rdt_1642ExtUpd02_VLT    
  
   IF @nInputKey = 1  
   BEGIN  
      IF @nStep = 2   
      BEGIN  
         IF ISNULL( @cDropID, '') = ''  
         BEGIN  
            SET @nErrNo = 53801     
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DROPID REQ  
            GOTO RollbackTran
         END  
 
         select top 1 @PickSLipNo = PickSlipNo from PackDetail (NOLOCK)
         where dropid = @cDropID
         and storerkey = @cStorerKey

         select top 1 @cOrderKey = OrderKey from PICKHEADER (NOLOCK) where PickHeaderKey = @PickSLipNo

         -- Get the mbolkey for this particular dropid  
         SELECT @cMBOL4DropID = MbolKey, @cLoadKey = LoadKey    
         FROM dbo.MBOLDetail WITH (NOLOCK)   
         WHERE OrderKey = @cOrderKey  
  
  
         -- Add record into RDTScanToTruck (borrowed from james01 - rdt_1642ExtUpd01 )  
         IF NOT EXISTS ( SELECT 1 FROM RDT.RDTScanToTruck WITH (NOLOCK)   
                         WHERE MBOLKey = @cMBOL4DropID  
                         AND   RefNo = @cDropID  
                         AND  [Status] = '9')  
         BEGIN  
            INSERT INTO RDT.RDTScanToTruck  
                   (MBOLKey, LoadKey, CartonType, RefNo, URNNo, Status, AddWho, AddDate, EditWho, EditDate)  
            VALUES (@cMBOLKey, @cLoadKey, '', @cDropID, '', '9', sUser_sName(), GETDATE(), sUser_sName(), GETDATE())   
  
            IF @@ERROR <> 0  
            BEGIN  
               SET @nErrNo = 53806  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Ins Scn2Truck Fail
               GOTO RollbackTran 
            END  
         END  -- not exists 
  
         IF @nstep = 2 and
         not exists (select 1 from Dropid (NOLOCK) where dropid in (select dropid from packdetail (NOLOCK) where PickSlipNo = @PickSLipNo) and status < 9)
         BEGIN  
            update orders
            set status = 8
            where OrderKey = @cOrderkey
            SET @nErrNo = 217969
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Order is Loaded' 
            SET @nErrNo = 0
            GOTO Quit
         END
         GOTO Quit  
    
      END -- step2
   END--Inputkey =1 
  
   RollbackTran:
      IF ISNULL( @nErrNo, 0) <> 0  -- Error Occured - Process And Return    
         ROLLBACK TRAN rdt_1642ExtUpd02_VLT    

   Quit:  
      WHILE @@TRANCOUNT > @nStartTCnt -- Commit until the level we started    
         COMMIT TRAN rdt_1642ExtUpd02_VLT

END -- sp
GO

GRANT EXECUTE ON  [RDT].[rdt_1642ExtUpd02_VLT] TO [NSQL]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



