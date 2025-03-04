
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
  
CREATE OR ALTER PROC [RDT].[rdt_1642ExtUpd02_VLT] (  
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
  
   DECLARE  
   @nStartTCnt        INT,   
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
 
         SELECT TOP 1 @PickSLipNo = PickSlipNo from dbo.PackDetail WITH(NOLOCK)
         WHERE DropID = @cDropID
            AND StorerKey = @cStorerKey

         SELECT TOP 1 @cOrderKey = OrderKey FROM PICKHEADER WITH(NOLOCK) WHERE PickHeaderKey = @PickSLipNo

         -- Get the mbolkey for this particular dropid  
         SELECT @cMBOL4DropID = MbolKey, @cLoadKey = LoadKey    
         FROM dbo.MBOLDetail WITH (NOLOCK)   
         WHERE OrderKey = @cOrderKey  
    
         -- Add record into RDTScanToTruck (borrowed from james01 - rdt_1642ExtUpd01 )  
         IF NOT EXISTS (SELECT 1 FROM RDT.RDTScanToTruck WITH (NOLOCK)
         WHERE MBOLKey = @cMBOL4DropID  
            AND RefNo = @cDropID
            AND [Status] = '9')
                  AND NOT EXISTS(SELECT 1 FROM dbo.Dropid WITH (NOLOCK)
                     WHERE Dropid = @cDropID
                     AND DropIDType = 'B')
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
         ELSE
            INSERT INTO RDT.RDTScanToTruck
            (MBOLKey, LoadKey, CartonType, RefNo, URNNo, Status, AddWho, AddDate, EditWho, EditDate)
            SELECT O.MBOLKey, D.Loadkey, '', Dropid, '', '9', sUser_sName(), GETDATE(), sUser_sName(), GETDATE()
            FROM dbo.ORDERS O WITH(NOLOCK)
               INNER JOIN dbo.PICKHEADER PH WITH(NOLOCK)
               ON O.OrderKey = PH.OrderKey
               INNER JOIN dbo.Dropid D WITH(NOLOCK)
               ON D.PickSlipNo = PH.PickHeaderKey
               WHERE exists
               (SELECT ChildId FROM dbo.DropidDetail DD WITH(NOLOCK)
                  WHERE Dropid = @cDropID and D.Dropid = DD.ChildId)
                  AND NOT EXISTS (SELECT 1 FROM RDT.RDTScanToTruck RSTT WITH(NOLOCK) WHERE RSTT.RefNo = D.Dropid and RSTT.Status = '9' and RSTT.MBOLKey = O.MBOLKey)

         IF @nstep = 2 AND
         NOT EXISTS (SELECT 1 FROM Dropid D WITH(NOLOCK) WHERE EXISTS (SELECT 1 FROM dbo.PackDetail PD WITH(NOLOCK) WHERE D.dropid = PD.Dropid
               AND PickSlipNo = @PickSLipNo) and Status < '9')
               AND (SELECT TOP 1 DropIDType FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) <> 'B'
         BEGIN
            UPDATE dbo.ORDERS WITH(ROWLOCK)
            SET STATUS = '8'
            WHERE OrderKey = @cOrderkey
                     AND StorerKey = @cStorerKey
               SET @nErrNo = 217969
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Order is Loaded' 
               SET @nErrNo = 0
               GOTO Quit
         END
      
         ELSE IF @nStep = 2 AND EXISTS (select 1 from dbo.Dropid WITH(NOLOCK) WHERE dropid = @cDropID and DropIDType = 'B')
         BEGIN
            UPDATE dbo.Dropid WITH(ROWLOCK)
            SET STATUS = '9', Droploc = @cDoor, AdditionalLoc = @cDoor
            WHERE exists
            (SELECT 1 FROM dbo.PackDetail PD WITH(NOLOCK)
            WHERE Dropid.Dropid = PD.DropID and StorerKey = @cStorerKey
            AND EXISTS
            (SELECT 1 FROM dbo.DropidDetail DD WITH(NOLOCK) WHERE Dropid = @cDropID and PD.Dropid = DD.ChildId))

                  /*IF exists
                  (select * from ORDERS O (NOLOCK)
            where StorerKey = @cStorerKey
                  and exists
            (select 1 from PICKHEADER PH (NOLOCK)
            where O.OrderKey = PH.OrderKey
            and exists
            (select 1 from PackDetail PD (NOLOCK)
            where StorerKey = @cStorerKey
                  and PH.PickHeaderKey = PD.PickSlipNo
            and exists
            (select 1 from Dropid D (NOLOCK)
            where exists (select 1 from DropidDetail DD (NOLOCK) where DD.Dropid = @cDropID and D.Dropid = DD.ChildId)
            and PD.DropID = D.Dropid
            and not exists (select 1 from Dropid D2 (NOLOCK) where status < 9 and D2.PickSlipNo = PD.PickSlipNo)))))
                  BEGIN*/
            UPDATE dbo.ORDERS WITH(ROWLOCK)
            SET Status = '8'
            WHERE EXISTS
            (SELECT 1 FROM PICKHEADER PH WITH(NOLOCK)
            WHERE Orders.OrderKey = PH.OrderKey
            AND EXISTS
            (SELECT 1 FROM dbo.PackDetail PD WITH(NOLOCK)
            WHERE PH.PickHeaderKey = PD.PickSlipNo
            AND EXISTS
            (SELECT 1 FROM dbo.Dropid D WITH(NOLOCK)
            WHERE EXISTS (SELECT 1 FROM dbo.DropidDetail DD WITH(NOLOCK) WHERE DD.Dropid = @cDropID AND D.Dropid = DD.ChildId)
            AND PD.DropID = D.Dropid
            AND NOT EXISTS (SELECT 1 FROM dbo.Dropid D2 (NOLOCK) WHERE STATUS < '9' and D2.PickSlipNo = PD.PickSlipNo))))
                  --END
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

GRANT EXECUTE ON [RDT].[rdt_1642ExtUpd02_VLT] TO [NSQL]
GO
