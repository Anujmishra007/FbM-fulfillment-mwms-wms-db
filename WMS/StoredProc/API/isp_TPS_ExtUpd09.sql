SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
 
/******************************************************************************/        
/* Store procedure: isp_TPS_ExtUpd09                                          */        
/* Copyright      : Maersk                                                    */        
/*                                                                            */  
/* Description    : This Extended Update Close Carton SP is mainly update the */ 
/*                  Close carton that contains AD Barcode only. It will not   */ 
/*                  support for update the non AD Barcode value.              */ 
/*                                                                            */        
/* Date         Rev  Author     Purposes                                      */        
/* 2025-05-29   1.0  GhChan     Revamp based on isp_TPS_ExtUpd03              */ 
/******************************************************************************/        
        
CREATE OR ALTER  PROC [API].[isp_TPS_ExtUpd09] (        
 @cStorerKey      NVARCHAR( 15),      
   @cFacility       NVARCHAR( 5),        
   @nFunc           INT,            
   @cUserName       Nvarchar( 128),      
   @cLangCode       NVARCHAR( 3),       
   @cScanNo         NVARCHAR( 50),      
   @cpickslipNo     NVARCHAR( 30),      
   @cDropID         NVARCHAR( 50),      
   @cOrderKey       NVARCHAR( 10),      
   @cLoadKey        NVARCHAR( 10),      
   @cZone           NVARCHAR( 18),      
   @EcomSingle      NVARCHAR( 1),       
   @nCartonNo       INT,            
   @cCartonType     NVARCHAR( 10),       
   @cType           NVARCHAR( 30),       
   @fCartonWeight   FLOAT,           
   @fCartonCube     FLOAT,           
   @cWorkstation    NVARCHAR( 30),       
   @cLabelNo        NVARCHAR( 20),      
   @cCloseCartonJson   NVARCHAR (MAX),   
	@pickSkuDetailJson  NVARCHAR (MAX),   
   @b_Success       INT = 1        OUTPUT,      
   @n_Err           INT = 0        OUTPUT,      
   @c_ErrMsg        NVARCHAR( 255) = ''  OUTPUT       
)        
AS        
        
SET NOCOUNT ON        
SET QUOTED_IDENTIFIER OFF        
SET ANSI_NULLS OFF        
SET CONCAT_NULL_YIELDS_NULL OFF        
      
DECLARE @curAD CURSOR      
DECLARE       
   @cSKU             NVARCHAR(20),   
   @cLblLineNumber   NVARCHAR(5),  
   @cWeight          NVARCHAR(10),      
   @cCube            NVARCHAR(10),      
   @cLottableVal     NVARCHAR(20),      
   @cSerialNoKey     NVARCHAR(60), 
   @cSerialNo        NVARCHAR(50),
   @cADCode          NVARCHAR(60),      
   @nQty             INT, 
   @nSNQty             INT, 
   @nTranCount       INT,  
   @cUCCNo           NVARCHAR(30),  
   @cCurOrderkey     NVARCHAR(20),
   @cPickDetailKey   NVARCHAR(18)  
         
DECLARE @CloseCtnList TABLE (     
   UCC             NVARCHAR( 30),  
   SKU             NVARCHAR( 20),      
   QTY             INT,      
   Weight          FLOAT,      
   Cube            FLOAT,        
   lottableVal     NVARCHAR(60),      
   SkuBarcode      NVARCHAR(60),      
   ADCode          NVARCHAR(60)      
)      
      
SET @b_Success = '1'     
--INSERT INTO @CloseCtnList      
--SELECT *      
--FROM OPENJSON(@cCloseCartonJson)      
--WITH (      
--   SKU             NVARCHAR( 20) '$.SKU',      
--   Qty             INT           '$.PackedQty',      
--   Weight          Float         '$.WEIGHT',      
--   Cube            Float         '$.CUBE',      
--   lottableValue   NVARCHAR(60)  '$.Lottable',       
--   SkuBarcode      NVARCHAR( 60) '$.SkuBarcode'       
--)      
INSERT INTO @CloseCtnList (UCC,SKU, QTY, WEIGHT, CUBE, lottableVal,SkuBarcode, ADCode)      
SELECT     
HDR.UCC  
, Hdr.SKU      
, Hdr.Qty      
, Hdr.Weight      
, Hdr.Cube      
, Hdr.lottableValue      
, Det.barcodeVal      
, Det.AntiDiversionCode      
FROM OPENJSON(@cCloseCartonJson)      
WITH (      
   UCC            NVARCHAR( 30)  '$.UCC',    
   SKU            NVARCHAR( 20)  '$.SKU',      
   Qty            INT            '$.PackedQty',      
   Weight         FLOAT          '$.WEIGHT',      
   Cube           FLOAT          '$.CUBE',      
   lottableValue  NVARCHAR(60)   '$.Lottable',       
   barcodeObj     NVARCHAR(MAX)  '$.barcodeObj' AS JSON       
) AS Hdr      
OUTER APPLY OPENJSON(barcodeObj)      
WITH (      
   barcodeVal        NVARCHAR(60) '$.barcodeVal',      
   AntiDiversionCode NVARCHAR(60) '$.AntiDiversionCode'      
) AS Det      
       
--SELECT 'aa',* FROM @CloseCtnList      
BEGIN      
   SET @nTranCount = @@TRANCOUNT      
   BEGIN TRAN      
   SAVE TRAN isp_TPS_ExtUpd09   

   IF EXISTS (SELECT 1   
              FROM @CloseCtnList  
              WHERE ISNULL(UCC,'') <>'')  
   BEGIN  
      SELECT @nQTY =QTY,@cUCCNo = UCC,@cSKU = SKU  
      FROM @CloseCtnList  
       WHERE ISNULL(UCC,'') <>''  
          
      UPDATE UCC WITH (ROWLOCK)  
      SET   status='6',
            EditDate = GETDATE(),  
            EditWho = @cUserName    
      where uccno=@cUCCNo  
         AND SKU = @cSKU 
         AND Storerkey = @cStorerKey  
  
      SET @curAD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
      SELECT serialnokey,SUM(qty) 
      FROM serialno (NOLOCK)      
      WHERE SKU = @cSKU  
         AND Userdefine01 = @cUCCNo  
         AND Storerkey = @cStorerKey  
         AND Status in ('0','1') 
      GROUP BY serialnokey
      ORDER BY serialnokey  
  
      OPEN @curAD      
      FETCH NEXT FROM @curAD INTO @cSerialNoKey, @nSNQTY    
      WHILE @@FETCH_STATUS <> -1      
      BEGIN    
  
         SELECT @cLblLineNumber = PD.LabelLine,  
                @cLabelNo = labelno  
         FROM dbo.Packheader PH WITH (NOLOCK)    JOIN  
         dbo.packdetail PD(nolock) ON PH.PickSlipNo=PD.PickSlipNo  
         WHERE PD.StorerKey = @cStorerKey        
            AND PH.OrderKey = @cOrderKey        
            AND PD.SKU = @cSKU   
            AND Cartonno = @nCartonNo 
              
         SELECT @cSerialNo = SerialNo
         FROM dbo.SerialNo WITH (NOLOCK) 
         WHERE  SerialNokey = @cSerialNokey
  
         INSERT INTO PACKSERIALNO (Pickslipno, cartonno,LabelNo,labelline,storerkey,sku,serialno,qty,AddWho,AddDate,EditWho,EditDate)  
         VALUES(@cpickslipno,@nCartonNo,@cLabelNo,@cLblLineNumber,@cStorerKey,@cSKU,@cSerialNo,1,@cUserName,GETDATE(),@cUserName,GETDATE())  
                                               
         UPDATE SerialNo WITH (ROWLOCK) SET      
            trafficcop=null,  
            status='1',
            EditDate = GETDATE(),  
            EditWho = @cUserName   
         WHERE SerialNokey = @cSerialNokey  
  
         SET @nQTY = @nQTY - @nSNQTY  

         IF @nQTY = 0   
            BREAK;  
  
         FETCH NEXT FROM @curAD INTO @cSerialNoKey, @nSNQTY 
      END  
      CLOSE @curAD;
      DEALLOCATE @curAD;

      IF @nQTY<>0  
      BEGIN        
         SET @b_Success = 0;
         SET @n_Err = 1002851        
         SET @c_ErrMsg =API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'Quantity Not Match. Function : isp_TPS_ExtUpd09'        
         GOTO RollBackTran        
      END     
   END  
   ELSE  
   BEGIN  
      SELECT @cCurOrderkey = Orderkey  
      FROM PICKHEADER (NOLOCK)  
      WHERE Pickheaderkey = @cpickslipNo  
  
      IF ISNULL( @cCurOrderkey,'') <>''  
         SET @cOrderkey = @cCurOrderkey  

      IF @cOrderKey = ''      
      BEGIN
         SET @b_Success = 0;
         SET @n_Err = 1002858        
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'No OrderKey found, failed to proceed. Function : isp_TPS_ExtUpd09'        
         GOTO RollBackTran       
      END   
      
      IF NOT EXISTS (SELECT 1 FROM CODELKUP WITH (NOLOCK) WHERE Listname = 'REQEXP'AND Code ='ADBARCODE' AND storerKey = @cStorerKey)      
      BEGIN      
         SET @b_Success = 0;
         SET @n_Err = 1002859        
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'ListName(REQEXP) and Code(ADBARCODE) setup not found. Function : isp_TPS_ExtUpd09'        
         GOTO RollBackTran          
      END
      
      SET @curAD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
      SELECT SKU, ISNULL(ADCode,'')      
      FROM @CloseCtnList      
      WHERE (SkuBarcode <> '' OR ADCode <> '')      
         
      OPEN @curAD      
      FETCH NEXT FROM @curAD INTO @cSKU, @cADCode     
      WHILE @@FETCH_STATUS <> -1      
      BEGIN      
         IF NOT EXISTS (SELECT 1 FROM SKU WITH (NOLOCK) WHERE storerKey = @cStorerKey AND SKU = @cSKU AND susr4 = 'AD')      
         BEGIN      
            GOTO NEXTITEM 
         END  

         SELECT @nQty = Pack.OtherUnit2
         FROM SKU SKU (NOLOCK)
            JOIN PACK PACK (NOLOCK) 
            ON SKU.PACKKey = PACK.PackKey
         WHERE  SKU.SKU = @cSKU
            AND SKU.StorerKey = @cStorerKey

         IF @nQty < 1
         BEGIN
            SET @b_Success = 0
            SET @n_Err = 1002861      
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'PackOtherUnit2 cannot be less than 1. Function : isp_TPS_ExtUpd09'      
            GOTO RollBackTran 
         END

         SELECT @cPickDetailKey = PD.PickDetailKey
         FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN Orders O WITH (NOLOCK) 
            ON PD.Orderkey = O.Orderkey AND PD.Storerkey = O.Storerkey
         WHERE PD.StorerKey = @cStorerKey
            AND O.OrderKey = @cOrderKey
            AND PD.SKU = @cSKU

         SELECT @cLblLineNumber = PD.LabelLine,  
                  @cLabelNo = labelno  
         FROM dbo.Packheader PH WITH (NOLOCK)    JOIN  
         dbo.packdetail PD(nolock) ON PH.PickSlipNo=PD.PickSlipNo  
         WHERE PD.StorerKey = @cStorerKey        
            AND PH.OrderKey = @cOrderKey        
            AND PD.SKU = @cSKU   
            AND Cartonno = @nCartonNo 

         SET @cSerialNoKey = ''
         SELECT  @cSerialNoKey = SerialNoKey
         FROM SerialNo (NOLOCK)
         WHERE StorerKEy = @cStorerKey      
         AND OrderKey = ''      
         AND SKU = @cSKU      
         AND SerialNo = @cADCode 
         AND [Status] = '1'

         IF @@ROWCOUNT = 0  
         BEGIN        
            --Insert/Update PackSerialNo
            IF EXISTS(select 1 from PackSerialNo (NOLOCK)    
                     where PickSlipNo=@cpickslipNo    
                     and storerkey=@cStorerKey    
                     and sku=@csku
                     and serialno=@cADCode)    
            BEGIN
               SET @b_Success = 0
               SET @n_Err = 1002862      
               SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') --'Failed to insert SerialNo into PackSerialNo Table. Records already exists. Function : isp_TPS_ExtUpd09'      
               GOTO RollBackTran
            END  

            INSERT INTO PackSerialNo(pickslipno,cartonno,labelno,labelline,storerkey,sku,serialno,qty, PickDetailKey,AddWho,AddDate,EditWho,EditDate)    
            values(@cpickslipNo,@nCartonNo,@cLabelNo,@cLblLineNumber,@cStorerKey,@csku,@cADCode,@nQty, ISNULL(@cPickDetailKey,''),@cUserName,GETDATE(),@cUserName,GETDATE())  
      
            IF @@ERROR <> 0         
            BEGIN         
               SET @b_Success = 0;
               SET @n_Err = 1002853        
               SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to Insert SerialNo table. Function : isp_TPS_ExtUpd09'        
               GOTO RollBackTran        
            END  

            EXECUTE dbo.nspg_GetKey        
                     'SerialNo',        
                     10 ,        
                     @cSerialNoKey      OUTPUT,        
                     @b_Success          OUTPUT,        
                     @n_Err            OUTPUT,        
                     @c_ErrMsg           OUTPUT        
                       
            IF @b_Success <> 1        
            BEGIN        
               SET @n_Err = 1002852        
               SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpd09'        
               GOTO RollBackTran        
            END 

            INSERT INTO SerialNo (SerialNoKey, OrderKey, OrderLineNumber, StorerKey, SKU, SerialNo, Qty, status,LabelLine,Cartonno,pickslipno ,AddWho,AddDate,EditWho,EditDate)         
            VALUES ( @cSerialNoKey, '', '', @cStorerKey, @cSKU , @cADCode , @nQty, '1','','','',@cUserName,GETDATE(),@cUserName,GETDATE() )         
  
            IF @@ERROR <> 0         
            BEGIN         
               SET @b_Success = 0;
               SET @n_Err = 1002860        
               SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to Insert SerialNo table. Function : isp_TPS_ExtUpd09'        
               GOTO RollBackTran        
            END                
         END        
         ELSE   
         BEGIN
            --IF @@ROWCOUNT = 0
            --BEGIN
            --   SET @b_Success = 0
            --   SET @n_Err = 1002863      
            --   SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Failed to get the existing SerialNoKey from SerialNo Table. Records already been in used. Function : isp_TPS_ExtUpd09'
            --   GOTO RollBackTran
            --END
            
            IF EXISTS(select 1 from PackSerialNo (NOLOCK)    
                     where PickSlipNo=@cpickslipNo    
                     and storerkey=@cStorerKey    
                     and sku=@csku
                     and serialno=@cADCode)    
            BEGIN
               GOTO NEXTITEM  -- PackSerialNo Exists then proceed the next records because the frontend return all the same AD for the each SKU during close carton.

               --SET @b_Success = 0
               --SET @n_Err = 1002864      
               --SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Failed to insert SerialNo into PackSerialNo Table. Records already exists. Function : isp_TPS_ExtUpd09'
               --GOTO RollBackTran
            END  

            INSERT INTO PackSerialNo(pickslipno,cartonno,labelno,labelline,storerkey,sku,serialno,qty, PickDetailKey,AddWho,AddDate,EditWho,EditDate)    
            values(@cpickslipNo,@nCartonNo,@cLabelNo,@cLblLineNumber,@cStorerKey,@csku,@cADCode,@nQty, ISNULL(@cPickDetailKey,''),@cUserName,GETDATE(),@cUserName,GETDATE())     
      
            IF @@ERROR <> 0         
            BEGIN         
               SET @b_Success = 0;
               SET @n_Err = 1002854        
               SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to Insert PackSerialNo table. Function : isp_TPS_ExtUpd09'        
               GOTO RollBackTran        
            END           

            UPDATE SerialNo WITH (ROWLOCK) 
            SET      
               trafficcop=null,  
               status='1',
               EditDate = GETDATE(),  
               EditWho = @cUserName   
            WHERE Serialnokey = @cSerialNoKey    
                        
            IF @@ERROR <> 0         
            BEGIN         
               SET @b_Success = 0;
               SET @n_Err = 1002855        
               SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to Update SerialNo table. Function : isp_TPS_ExtUpd09'        
               GOTO RollBackTran        
            END        
         END  

         --ELSE  
         --BEGIN  
         --   IF EXISTS (SELECT 1 FROM SerialNo WITH (NOLOCK)        
         --               WHERE StorerKey = @cStorerKey            
         --               AND SKU = @cSKU        
         --               AND SerialNo = @cSerialNo )        
         --   BEGIN
         --      SELECT @cSerialNoKey = SerialNoKey
         --      FROM dbo.SerialNo WITH (NOLOCK) 
         --      WHERE StorerKey = @cStorerKey 
         --         AND SKU = @cSKU 
         --         AND SerialNo = @cSerialNo

         --      IF NOT EXISTS(select 1 from packserialno (nolock)      
         --            where pickslipno=@cpickslipNo      
         --            and storerkey=@cStorerKey      
         --            and sku=@csku  
         --            and serialno=@cSerialNo)      
         --      BEGIN
         --         INSERT INTO PackSerialNo(pickslipno,cartonno,labelno,labelline,storerkey,SerialNo,sku,qty,AddWho,AddDate,EditWho,EditDate)      
         --         values(@cpickslipno,@nCartonNo,@cLabelNo,@cLblLineNumber,@cStorerKey,@cserialno,@csku,1,@cUserName,GETDATE(),@cUserName,GETDATE())      
      
         --         IF @@ERROR <> 0         
         --         BEGIN         
         --            SET @b_Success = 0;
         --            SET @n_Err = 1002856        
         --            SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to Insert SerialNo table. Function : isp_TPS_ExtUpd09'        
         --            GOTO RollBackTran        
         --         END        
         --      END      
  
         --      UPDATE SerialNo WITH (ROWLOCK) 
         --      SET      
         --         trafficcop=null,  
         --         status='1',
         --         EditDate = GETDATE(),  
         --         EditWho = @cUserName   
         --      WHERE Serialnokey = @cSerialNoKey 
  
         --      IF @@ERROR <> 0         
         --      BEGIN         
         --         SET @b_Success = 0;
         --         SET @n_Err = 1002857        
         --         SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to Update SerialNo table. Function : isp_TPS_ExtUpd09'        
         --         GOTO RollBackTran        
         --      END        
         --   END    
         --END  
NEXTITEM:
         FETCH NEXT FROM @curAD INTO @cSKU, @cADCode        
      END
      CLOSE @curAD;
      DEALLOCATE @curAD;
   END  
   
   GOTO Quit      
       
 RollBackTran:      
      ROLLBACK TRAN isp_TPS_ExtUpd09      
      
   Quit:      
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started    
      BEGIN  
         COMMIT TRAN isp_TPS_ExtUpd09      
      END  
      
END        
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_ExtUpd09 TO NSQL
GO


