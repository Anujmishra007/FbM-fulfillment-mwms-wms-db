IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[RDT].[rdt_1641ExtUpdSP05]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_1641ExtUpdSP05]

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO    

/************************************************************************/      
/* Store procedure: rdt_1641ExtUpdSP05                                  */      
/* Copyright      : IDS                                                 */      
/*                                                                      */      
/* Called from: rdtfnc_Pallet_Build                                     */      
/*                                                                      */      
/* Purpose: Build pallet & palletdetail                                 */      
/*                                                                      */      
/* Modifications log:                                                   */      
/* Date        Rev  Author   Purposes                                   */      
/* 2019-10-29  1.0  James    WMS-11018 Created                          */    
/* 2020-01-17  1.1  James    WMS-11855 Ecom orders enhancement (james01)*/    
/* 2020-03-24  1.2  James    WMS-12641 Ecom orders enhancement (james02)*/  
/* 2020-08-10  1.3  YeeKung  WMS-14625 Reopen Pallet (yeekung01)        */
/************************************************************************/      
      
CREATE PROC [RDT].[rdt_1641ExtUpdSP05] (      
   @nMobile     INT,      
   @nFunc       INT,      
   @cLangCode   NVARCHAR( 3),      
   @cUserName   NVARCHAR( 15),      
   @cFacility   NVARCHAR( 5),      
   @cStorerKey  NVARCHAR( 15),      
   @cDropID     NVARCHAR( 20),      
   @nErrNo      INT          OUTPUT,      
   @cErrMsg     NVARCHAR( 20) OUTPUT  -- screen limitation, 20 char max      
) AS      
BEGIN      
   SET NOCOUNT ON      
   SET ANSI_NULLS OFF      
   SET QUOTED_IDENTIFIER OFF      
   SET CONCAT_NULL_YIELDS_NULL OFF      
       
   DECLARE  @nStep         INT,    
            @nInputKey     INT,    
            @nTranCount    INT,    
            @nPD_Qty       INT,    
            @cSKU          NVARCHAR( 20),    
            @cCartonID     NVARCHAR( 20),    
            @cOrderKey     NVARCHAR( 10),    
            @cPickSlipNo   NVARCHAR( 10),    
            @cPalletLineNumber   NVARCHAR( 5),    
            @cCaseID         NVARCHAR(20),    
            @nQty            INT,    
            @cOtherPalletKey NVARCHAR( 30) = '',  
            @cSUSR1          NVARCHAR( 20) = '',  
            @cConsigneeKey   NVARCHAR( 15) = '',  
            @cOption         NVARCHAR( 1) = '',  
            @cOrderGroup     NVARCHAR( 20) = '',  
            @cC_ISOCntryCode NVARCHAR( 10) = '',  
            @cUserDefine01   NVARCHAR( 30) = '',  
            @cOrders_M_Company   NVARCHAR( 45) = '',  
            @cShipperKey      NVARCHAR( 15) = ''  
                   
    
   SELECT @nStep = Step,    
          @nInputKey = InputKey,    
          @cCartonID = I_Field03    
   FROM RDT.RDTMobRec WITH (NOLOCK)    
   WHERE Mobile = @nMobile    
    
   SET @nTranCount = @@TRANCOUNT    
    
   BEGIN TRAN    
   SAVE TRAN rdt_1641ExtUpdSP05    
       
   IF @nStep = 3    
   BEGIN    
      IF @nInputKey = 1    
      BEGIN    
         SELECT TOP 1 @cOtherPalletKey = PalletKey  
         FROM dbo.PALLETDETAIL AS p WITH (NOLOCK)  
         WHERE StorerKey = @cStorerKey    
         AND   CaseId = @cCartonID    
         AND  [Status] < '9'  
         ORDER BY 1  
  
         IF @@ROWCOUNT > 0  
         BEGIN    
            SET @nErrNo = 145651    
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Ctn In Other Plt    
            GOTO RollBackTran    
         END   
  
    
         IF EXISTS ( SELECT 1 FROM dbo.PalletDetail WITH (NOLOCK)     
                     WHERE StorerKey = @cStorerKey    
                     AND   CaseId = @cCartonID    
                     AND  [Status] < '9')    
        BEGIN    
            SET @nErrNo = 145652    
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --CartonExist    
            GOTO RollBackTran    
         END    
  
         -- Check if pallet id exists before    
         IF NOT EXISTS ( SELECT 1     
                         FROM dbo.Pallet WITH (NOLOCK)    
                         WHERE PalletKey = @cDropID)  
         BEGIN    
            -- Insert Pallet info    
            INSERT INTO dbo.Pallet (PalletKey, StorerKey) VALUES (@cDropID, @cStorerKey)    
    
            IF @@ERROR <> 0    
            BEGIN    
               SET @nErrNo = 145653    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPLTFail    
               GOTO RollBackTran    
            END    
         END    
    
         -- Insert PalletDetail     
         DECLARE CUR_PalletDetail CURSOR LOCAL READ_ONLY FAST_FORWARD FOR     
         SELECT PickSlipNo, SKU, ISNULL( SUM( Qty), 0)    
         FROM dbo.PackDetail WITH (NOLOCK)    
         WHERE StorerKey = @cStorerKey    
         AND   LabelNo = @cCartonID    
         GROUP BY PickSlipNo, SKU    
         OPEN CUR_PalletDetail    
         FETCH NEXT FROM CUR_PalletDetail INTO @cPickSlipNo, @cSKU, @nPD_Qty    
         WHILE @@FETCH_STATUS <> -1     
         BEGIN    
            -- (james01)  
            --if orders.ordergroup = ‘ECOM’, insert orders.ISOcntrycode   
            --into palletdetail.udf01 when user scan carton label number  
              
            SELECT @cOrderKey = OrderKey     
            FROM dbo.PackHeader WITH (NOLOCK)     
            WHERE PickSlipNo = @cPickSlipNo     
  
            SELECT @cConsigneeKey = ConsigneeKey,   
                   @cOrderGroup = OrderGroup,   
                   @cC_ISOCntryCode = C_ISOCntryCode,  
                   @cOrders_M_Company = M_Company,  
                   @cShipperKey = ShipperKey  
            FROM dbo.ORDERS WITH (NOLOCK)  
            WHERE OrderKey = @cOrderKey  
              
            IF @cOrderGroup = 'ECOM'  
               SET @cUserDefine01 = SUBSTRING( RTRIM( @cC_ISOCntryCode) +   
                                    RTRIM( @cOrders_M_Company) +   
                                    RTRIM( @cShipperKey), 1, 30)  
            ELSE  
            BEGIN  
               SELECT @cSUSR1 = SUSR1  
               FROM dbo.Storer WITH (NOLOCK)     
               WHERE StorerKey = @cConsigneeKey    
                 
               SET @cUserDefine01 = @cSUSR1  
            END              
  
            INSERT INTO dbo.PalletDetail     
            (PalletKey, PalletLineNumber, CaseId, StorerKey, Sku, Qty, UserDefine01, UserDefine02)     
            VALUES    
            (@cDropID, 0, @cCartonID, @cStorerKey, @cSKU, @nPD_Qty, @cUserDefine01, @cOrderKey)    
              
            IF @@ERROR <> 0    
            BEGIN    
               SET @nErrNo = 145654    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPLTDetFail    
               CLOSE CUR_PalletDetail          
               DEALLOCATE CUR_PalletDetail                   
               GOTO RollBackTran    
            END    
                
            FETCH NEXT FROM CUR_PalletDetail INTO @cPickSlipNo, @cSKU, @nPD_Qty    
         END    
         CLOSE CUR_PalletDetail          
         DEALLOCATE CUR_PalletDetail    
      END    
   END    
  
   IF @nStep = 4    
   BEGIN    
      IF @nInputKey = 1    
      BEGIN    
         SELECT @cOption = I_Field01    
         FROM RDT.RDTMobRec WITH (NOLOCK)    
         WHERE Mobile = @nMobile    
  
         IF @cOption = '1'  
         BEGIN  
            IF NOT EXISTS ( SELECT 1 FROM dbo.Pallet WITH (NOLOCK)    
                            WHERE StorerKey = @cStorerKey    
                            AND   PalletKey = @cDropID    
                            AND  [Status] < '9')    
            BEGIN    
               SET @nErrNo = 145655    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PLTKeyNotFound    
               GOTO RollBackTran    
            END   
  
            IF NOT EXISTS ( SELECT 1 FROM dbo.PALLETDETAIL WITH (NOLOCK)    
                            WHERE StorerKey = @cStorerKey    
                            AND   PalletKey = @cDropID    
                            AND  [Status] < '9')    
            BEGIN    
               SET @nErrNo = 145656    
           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No Ctn Scanned    
               GOTO RollBackTran    
            END   
  
            UPDATE dbo.PALLETDETAIL WITH (ROWLOCK) SET     
               [Status] = '9'    
            WHERE StorerKey = @cStorerKey    
            AND   PalletKey = @cDropID    
            AND   [Status] < '9'    
    
            IF @@ERROR <> 0    
           BEGIN    
               SET @nErrNo = 145657    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd PLTDet Err    
               GOTO RollBackTran    
            END    
    
            UPDATE dbo.PALLET WITH (ROWLOCK) SET     
               [Status] = '9'    
            WHERE StorerKey = @cStorerKey    
            AND   PalletKey = @cDropID    
            AND   [Status] < '9'    
    
            IF @@ERROR <> 0    
            BEGIN    
               SET @nErrNo = 145658    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Close Plt Fail    
               GOTO RollBackTran    
            END    
         END  
      END  
   END  

   IF @nStep = 7  --(yeekung01)
   BEGIN  
      IF @nInputKey = 1  
      BEGIN  
           
         IF NOT EXISTS( SELECT 1 FROM PALLETDETAIL PD (NOLOCK) JOIN MBOLDETAIL MD (NOLOCK)  
                     ON PD.UserDefine02=MD.OrderKey  JOIN  PICKDETAIL PKD (nolock)   
                     ON MD.ORDERKEY=PKD.ORDERKEY  
                     WHERE PD.StorerKey = @cStorerKey  
                     AND   PD.PalletKey = @cDropID  
                     AND   PKD.STATUS = 9  
                     AND   PD.STATUS=9)  
         BEGIN  
            
            UPDATE dbo.PALLETDETAIL WITH (ROWLOCK) SET   
               [Status] = '0'  
            WHERE StorerKey = @cStorerKey  
            AND   PalletKey = @cDropID  
            AND   [Status] = '9'  
           
            IF @@ERROR <> 0  
            BEGIN  
               SET @nErrNo = 145659  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd pltdt fail  
               GOTO RollBackTran  
            END  
  
            UPDATE dbo.PALLET WITH (ROWLOCK) SET   
               [Status] = '0'  
               ,[TrafficCop]= NULL  
            WHERE StorerKey = @cStorerKey  
            AND   PalletKey = @cDropID  
            AND   [Status] = '9'  
  
            IF @@ERROR <> 0  
            BEGIN  
               SET @nErrNo = 145660  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd pltdt fail  
               GOTO RollBackTran  
            END  
  
         END  
         ELSE  
         BEGIN  
            SET @nErrNo = 145661  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PltShipped  
            GOTO RollBackTran  
         END  
      END  
   END  
  
   GOTO Quit    
    
   RollBackTran:    
      ROLLBACK TRAN rdt_1641ExtUpdSP05    
    
   Quit:    
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started    
         COMMIT TRAN rdt_1641ExtUpdSP05    
    
      
Fail:      
END      
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1641ExtUpdSP05 to nSQL
GO
