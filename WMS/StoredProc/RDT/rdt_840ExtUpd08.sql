if exists (select * from  dbo.sysobjects where id = object_id(N'[rdt].[rdt_840ExtUpd08]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [rdt].[rdt_840ExtUpd08]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/  
/* Store procedure: rdt_840ExtUpd08                                     */  
/* Purpose: Trigger HM related interface and misc update                */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2019-11-19 1.0  James      WMS-11146. Created                        */ 
/* 2020-04-15 1.1  James      WMS-12877 Update order status = '1' when  */
/*                            short pack occured (james01)              */
/*                            Add isp_AssignPackLabelToOrderByLoad      */
/*                            Prompt when short pick                    */
/* 2021-04-01 1.2 YeeKung     WMS-16717 Add serialno and serialqty      */
/*                            Params (yeekung01)                        */
/************************************************************************/  
  
CREATE PROC [RDT].[rdt_840ExtUpd08] (  
   @nMobile     INT,  
   @nFunc       INT,   
   @cLangCode   NVARCHAR( 3),   
   @nStep       INT,   
   @nInputKey   INT,   
   @cStorerkey  NVARCHAR( 15),   
   @cOrderKey   NVARCHAR( 10),   
   @cPickSlipNo NVARCHAR( 10),   
   @cTrackNo    NVARCHAR( 20),   
   @cSKU        NVARCHAR( 20),   
   @nCartonNo   INT, 
   @cSerialNo   NVARCHAR( 30), 
   @nSerialQTY  INT,    
   @nErrNo      INT           OUTPUT,   
   @cErrMsg     NVARCHAR( 20) OUTPUT  
)  
AS  
  
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF   
  
   DECLARE @nTranCount        INT,   
           @nExpectedQty      INT,  
           @nPackedQty        INT,   
           @nOriginalQty      INT,  
           @nPickQty          INT,  
           @nPackQty          INT,  
           @bSuccess          INT,  
           @nShortPack        INT,  
           @cCode             NVARCHAR( 10),
           @cUpdateSource     NVARCHAR( 10),
           @cFacility         NVARCHAR( 5)
  
   DECLARE @cErrMsg01         NVARCHAR( 20)

   SELECT @cFacility = Facility FROM RDT.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile
   
   IF @nStep = 3   
   BEGIN  
      IF @nInputKey = 0   
      BEGIN 
         SET @nPickQty = 0
         SELECT @nPickQty = ISNULL(SUM(Qty), 0) FROM PickDetail WITH (NOLOCK)
         WHERE Orderkey = @cOrderkey
            AND Storerkey = @cStorerkey
            AND Status < '9'

         SET @nPackQty = 0
         SELECT @nPackQty = ISNULL(SUM(Qty), 0) FROM dbo.PackDetail WITH (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
         
         -- If picked something on this orders
         IF @nPickQty > 0
         BEGIN
            IF @nPickQty > @nPackQty
            BEGIN
               SET @cErrMsg01 = rdt.rdtgetmessage( 146154, @cLangCode, 'DSP') --ORDERS SHORT PICK
            
               EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg01

               SET @nErrNo = 0
               SET @cErrMsg = ''
               GOTO Quit
            END
         END
      END
   END
   
   IF @nStep = 4  
   BEGIN  
      IF @nInputKey = 1  
      BEGIN  
         SET @nTranCount = @@TRANCOUNT    
         BEGIN TRAN  -- Begin our own transaction    
         SAVE TRAN rdt_840ExtUpd08 -- For rollback or commit only our own transaction    

         -- Customer orders need trigger TL2 if short pack
         IF NOT EXISTS ( SELECT 1 FROM dbo.CODELKUP C WITH (NOLOCK) 
                         JOIN dbo.Orders O WITH (NOLOCK) ON (C.Code = O.OrderGroup AND C.StorerKey = O.StorerKey)
                         WHERE C.ListName = 'HMCOSORD'
                         AND   C.Long = 'M'
                         AND   O.OrderKey = @cOrderkey
                         AND   O.StorerKey = @cStorerKey)
         BEGIN 
            SET @nShortPack = 0  
  
            SELECT @nOriginalQty = ISNULL( SUM( OriginalQty), 0)  
            FROM dbo.Orders O WITH (NOLOCK)  
            JOIN dbo.ORDERDETAIL OD WITH (NOLOCK) ON ( O.OrderKey = OD.OrderKey)  
            WHERE O.OrderKey = @cOrderKey  
            AND   O.StorerKey = @cStorerkey  
  
            SELECT @nPackQty = ISNULL( SUM( QTY), 0)  
            FROM dbo.PackDetail PD WITH (NOLOCK)  
            JOIN dbo.PackHeader PH WITH (NOLOCK) ON ( PD.PickSlipNo = PH.PickSlipNo)  
            WHERE PH.OrderKey = @cOrderKey           
            AND   PH.StorerKey = @cStorerkey  
  
            -- Compare packed qty to order qty to check if short qty  
            IF @nOriginalQty > @nPackQty      
               SET @nShortPack = 1  

            SELECT @cUpdateSource = UpdateSource
            FROM dbo.ORDERS WITH (NOLOCK)
            WHERE OrderKey = @cOrderKey
            
            -- Short pick/pack or partial allocate need trigger order value recalculate  
            IF @nShortPack = 1 AND @cUpdateSource <> '1'  
            BEGIN  
               -- Insert transmitlog2 here 
               SET @bSuccess = 1  
               EXEC ispGenTransmitLog2   
                     @c_TableName        = 'WSORDUPDATE'  
                  ,@c_Key1             = @cOrderKey  
                  ,@c_Key2             = ''  
                  ,@c_Key3             = @cStorerkey  
                  ,@c_TransmitBatch    = ''  
                  ,@b_Success          = @bSuccess    OUTPUT  
                  ,@n_err              = @nErrNo      OUTPUT  
                  ,@c_errmsg           = @cErrMsg     OUTPUT        
  
               IF @bSuccess <> 1      
                  GOTO RollBackTran  
  
               UPDATE dbo.Orders WITH (ROWLOCK) SET  
                  [Status] = '1',
                  SOStatus = 'HOLD',  
                  Trafficcop = NULL,  
                  EditDate = GETDATE(),  
                  EditWho = sUSER_sNAME()  
               WHERE StorerKey = @cStorerkey  
               AND   OrderKey = @cOrderKey  
               AND   SOStatus <> 'HOLD'  
  
               IF @@ERROR <> 0  
               BEGIN  
                  SET @nErrNo = 146151  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UPD HOLD FAIL'  
                  GOTO RollBackTran  
               END
               
               GOTO CommitTrans        
            END  
         END
         
         -- Trigger pack confirm  
         UPDATE dbo.PackHeader WITH (ROWLOCK) SET  
            STATUS = '9',  
            EditWho = 'rdt.' + sUser_sName(),  
            EditDate = GETDATE()  
         WHERE PickSlipNo = @cPickSlipNo  
         AND   [Status] < '9'  
  
         IF @@ERROR <> 0  
         BEGIN  
            SET @nErrNo = 146152  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Packcfm fail  
            GOTO RollBackTran    
         END  
            
         UPDATE dbo.Orders WITH (ROWLOCK) SET 
            SOStatus = '0',  
            EditWho = 'rdt.' + sUser_sName(),  
            EditDate = GETDATE()  
         WHERE OrderKey = @cOrderKey

         IF @@ERROR <> 0  
         BEGIN  
            SET @nErrNo = 146153  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Packcfm fail  
            GOTO RollBackTran    
         END

         -- (james01)
         -- Update packdetail.labelno=pickdetail.dropid
         -- Get storer config
         DECLARE @cAssignPackLabelToOrdCfg NVARCHAR(1)
         EXECUTE nspGetRight
            @cFacility,
            @cStorerKey,
            '', --@c_sku
            'AssignPackLabelToOrdCfg',
            @bSuccess                 OUTPUT,
            @cAssignPackLabelToOrdCfg OUTPUT,
            @nErrNo                   OUTPUT,
            @cErrMsg                  OUTPUT
         IF @nErrNo <> 0
            GOTO RollBackTran

         -- Assign
         IF @cAssignPackLabelToOrdCfg = '1'
         BEGIN
            -- Update PickDetail, base on PackDetail.DropID
            EXEC isp_AssignPackLabelToOrderByLoad
                  @cPickSlipNo
               ,@bSuccess OUTPUT
               ,@nErrNo   OUTPUT
               ,@cErrMsg  OUTPUT
            IF @nErrNo <> 0
               GOTO RollBackTran
         END
  
         GOTO CommitTrans  
        
         RollBackTran:    
               ROLLBACK TRAN rdt_840ExtUpd08    
  
         CommitTrans:    
            WHILE @@TRANCOUNT > @nTranCount    
               COMMIT TRAN    
      END  
   END  
     
   Quit:
    
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_840ExtUpd08 TO NSQL
GO