SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

    
/*******************************************************************************/      
/* Store procedure: isp_TPS_ExtUpdHld07                                        */      
/* Copyright      : Maersk                                                     */      
/*                                                                             */  
/*                                                                             */ 
/* Date         Rev  Author     Purposes                                       */    
/* 2025-09-30   1.0  GCH225     FCR-8323 Created                               */ 
/* 2025-10-22   1.1  GCH225     FCR-8323 FCR-7968 Add Duplicate SN Check.     */
/*******************************************************************************/      
      
CREATE OR ALTER PROC [API].[isp_TPS_ExtUpdHld07] (      
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
   @cHoldCartonJson   NVARCHAR (MAX),    
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
   @cSKU                NVARCHAR(20),    
   @cSkuBarcode         NVARCHAR(60), 
   @cLblLineNumber      NVARCHAR(5),
   @cWeight             NVARCHAR(10),    
   @cCube               NVARCHAR(10),    
   @cLottableVal        NVARCHAR(20),    
   @cSerialNoKey        NVARCHAR(60),    
   @cSerialNo           NVARCHAR(2000),    
   @cADCode             NVARCHAR(60),    
   @nQty                INT,  
   @nSNQTY              INT,
   @bsuccess            INT,
   @nTranCount          INT,
   @cStatus             NVARCHAR(20),
   @nQPos               INT,
   @nBangPos            INT,
   @cFirstValue         NVARCHAR(100),
   @cSecondValue        NVARCHAR(100),
   @cSerialNoOrderKey   NVARCHAR(10),
   @cSUSR4              NVARCHAR(18),
   @cSerialNoCapture    NVARCHAR(1),
   @cCurOrderkey        NVARCHAR(10),
   @cUCCNo              NVARCHAR(30),
   @cOrderLineNumber    NVARCHAR(5),
   @cDuplicateVal       NVARCHAR(1000)

DECLARE @cOtherUnit2    INT
       
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
    
SET @b_Success = 0
SET @cDuplicateVal = ''

INSERT INTO @CloseCtnList (UCC, SKU, QTY, WEIGHT, CUBE, lottableVal,SkuBarcode, ADCode)    
SELECT     
  HDR.UCC  
, Hdr.SKU    
, Hdr.Qty    
, Hdr.Weight    
, Hdr.Cube    
, Hdr.lottableValue    
, Det.barcodeVal    
, Det.AntiDiversionCode    
FROM OPENJSON(@cHoldCartonJson)    
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
   SAVE TRAN isp_TPS_ExtUpdHld07     
   
   SELECT @cCurOrderkey = Orderkey  
   FROM PICKHEADER (NOLOCK)  
   WHERE Pickheaderkey = @cpickslipNo  
  
   IF ISNULL( @cCurOrderkey,'') <>''  
      SET @cOrderkey = @cCurOrderkey  
  
   SELECT @nQTY =QTY,@cUCCNo = UCC,@cSKU = SKU  
   FROM @CloseCtnList  
   WHERE ISNULL(UCC,'') <>''  

   IF @@ROWCOUNT > 0
   AND EXISTS (SELECT 1 
               FROM SKU S(NOLOCK)
               INNER JOIN PACK P (NOLOCK)
               ON S.PACKKey = P.PackKey
               WHERE S.StorerKey = @cStorerKey
               AND S.SKU = @cSKU
               AND S.SerialNoCapture = '1'
               AnD P.OtherUnit2 = 1
      )
   BEGIN  
      UPDATE UCC WITH (ROWLOCK)  
      SET   status='6',
            EditDate = GETDATE(),  
            EditWho = @cUserName    
      where UCCNo=@cUCCNo  
         AND SKU = @cSKU 
         AND Storerkey = @cStorerKey  
  
      SET @curAD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
      SELECT serialnokey, qty
      FROM serialno (NOLOCK)      
      WHERE SKU = @cSKU  
      AND Userdefine01 = @cUCCNo  
      AND Storerkey = @cStorerKey  
      AND Status in ('0','1')
      ORDER BY serialnokey  
  
      OPEN @curAD      
      FETCH NEXT FROM @curAD INTO @cSerialNoKey, @nSNQTY    
      WHILE @@FETCH_STATUS <> -1      
      BEGIN    
  
         SELECT @cLblLineNumber = PD.LabelLine,  
                @cLabelNo = PD.labelno  
         FROM dbo.Packheader PH (NOLOCK)    
         JOIN dbo.packdetail PD (NOLOCK) 
         ON PH.PickSlipNo=PD.PickSlipNo  
         WHERE PH.StorerKey = @cStorerKey        
            AND PH.PickSlipNo = @cpickslipno        
            AND PD.Cartonno = @nCartonNo 
            AND PD.SKU = @cSKU   

         SELECT @cOrderLineNumber = PD.OrderLineNumber           
         FROM dbo.PickDetail PD WITH (NOLOCK)        
         WHERE PD.StorerKey = @cStorerKey        
         AND PD.OrderKey = @cOrderKey        
         AND PD.SKU = @cSKU         
         AND PD.OrderLineNumber Not IN ( SELECT S.OrderLineNumber     
                                         FROM dbo.SerialNo S WITH (NOLOCK)         
                                         WHERE S.OrderKey = @cOrderKey        
                                         AND S.OrderLineNumber = PD.OrderLineNUmber        
                                         AND S.SKU = @cSKU  )   
  
         IF ISNULL(@cOrderLineNumber,'')=''  
         BEGIN              SELECT TOP 1 @cOrderLineNumber = PD.OrderLineNumber           
            FROM dbo.PickDetail PD WITH (NOLOCK)        
            WHERE PD.StorerKey = @cStorerKey        
            AND PD.OrderKey = @cOrderKey        
            AND PD.SKU = @cSKU       
         END  
              
         SELECT @cSerialNo = SerialNo
         FROM dbo.SerialNo WITH (NOLOCK) 
         WHERE  SerialNokey = @cSerialNokey
  
         INSERT INTO PACKSERIALNO (Pickslipno, cartonno,LabelNo,labelline,storerkey,sku,serialno,qty,AddWho,AddDate,EditWho,EditDate)  
         VALUES(@cpickslipno,@nCartonNo,@cLabelNo,@cLblLineNumber,@cStorerKey,@cSKU,@cSerialNo,1,@cUserName,GETDATE(),@cUserName,GETDATE())  
                                               
  
         UPDATE SerialNo WITH (ROWLOCK) SET      
            OrderKey = @cOrderKey,       
            OrderLineNumber = ISNULL(@cOrderLineNumber,''),  
            LabelLine = @cLblLineNumber,  
            CartonNo = @nCartonNo,  
            pickslipno = @cpickslipno,  
            trafficcop=null,  
            status='1',
            EditDate = GETDATE(),  
            EditWho = @cUserName   
         WHERE SerialNokey = @cSerialNoKey  
  
         SET @nQTY = @nQTY - @nSNQTY  

         IF @nQTY = 0   
            BREAK;  
  
         FETCH NEXT FROM @curAD INTO @cSerialNoKey, @nSNQTY 
      END  
      CLOSE @curAD
      DEALLOCATE @curAD

      IF @nQTY<>0  
      BEGIN        
         SET @n_Err = 1003401        
         SET @c_ErrMsg =API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'Quantity Not Match. Function : isp_TPS_ExtUpdHld07'        
         GOTO RollBackTran        
      END     
   END  
   ELSE  
   BEGIN  
      IF @cOrderKey = ''      
      BEGIN      
         SET @n_Err = 1003402      
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'OrderKey cannot be empty. Function: isp_TPS_ExtUpdHld07'      
         GOTO RollBackTran          
      END 
      
      IF NOT EXISTS (SELECT 1 FROM CODELKUP WITH (NOLOCK) WHERE Listname = 'REQEXP'AND Code ='ADBARCODE' AND storerKey = @cStorerKey)      
      BEGIN      
         SET @n_Err = 1003403      
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'ListName(REQEXP) and Code(ADBARCODE) is not found. Function : isp_TPS_ExtUpdHld07'      
         GOTO RollBackTran                 
      END

      ;WITH Combined AS (
         SELECT RTRIM(SkuBarcode) AS Val
         FROM @CloseCtnList
         WHERE SkuBarcode <> '' AND SkuBarcode IS NOT NULL
         UNION ALL
         SELECT RTRIM(ADCode) AS Val
         FROM @CloseCtnList
         WHERE ADCode <> '' AND ADCode IS NOT NULL
      )
      SELECT @cDuplicateVal = STRING_AGG(D.Val, ', ') 
      FROM (
         SELECT Val 
         FROM Combined
         GROUP BY Val
         HAVING COUNT(1) > 1
      ) AS D

      IF LEN(@cDuplicateVal) > 1
      BEGIN
         SET @n_Err = 1003408      
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') + '(' + @cDuplicateVal + ')' -- 'One or more duplicate serial numbers were detected.'      
         GOTO RollBackTran 
      END

      SET @curAD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
      SELECT  H.SKU
            , H.SkuBarcode
            , H.ADCode
      FROM @CloseCtnList H
      WHERE (H.SkuBarcode <> '' OR H.ADCode <> '')    

      OPEN @curAD      
      FETCH NEXT FROM @curAD INTO @cSKU, @cSkuBarcode, @cADCode
      WHILE @@FETCH_STATUS <> -1      
      BEGIN      
         SET @cSerialNo = IIF( @cSkuBarcode <> '', @cSkuBarcode ,@cADCode)

         SELECT @cLblLineNumber = PD.LabelLine  
              , @cLabelNo = PD.LabelNo   
         FROM dbo.Packheader PH (NOLOCK)    
         JOIN dbo.PackDetail PD (NOLOCK) 
         ON PH.PickSlipNo = PD.PickSlipNo  
         WHERE PH.StorerKey = @cStorerKey        
         AND PH.PickSlipNo = @cpickslipno        
         AND PD.Cartonno = @nCartonNo 
         AND PD.SKU = @cSKU  

         SELECT @cOrderLineNumber = PD.OrderLineNumber         
              , @nQty = PD.Qty        
         FROM dbo.PickDetail PD WITH (NOLOCK)        
         WHERE PD.StorerKey = @cStorerKey        
         AND PD.OrderKey = @cOrderKey        
         AND PD.SKU = @cSKU         
         AND PD.OrderLineNumber NOT IN ( SELECT S.OrderLineNumber          
                                          FROM dbo.SerialNo S WITH (NOLOCK)         
                                          WHERE S.OrderKey = @cOrderKey        
                                          AND S.OrderLineNumber = PD.OrderLineNUmber        
                                          AND S.SKU = @cSKU  )   
            
         SET @nQty = CASE WHEN ISNULL(@nQty,'') IN(0,'') then 1 ELSE @nQty END   

         IF ISNULL(@cOrderLineNumber,'')=''  
         BEGIN  
              
            SELECT TOP 1 @cOrderLineNumber = PD.OrderLineNumber           
            FROM dbo.PickDetail PD WITH (NOLOCK)        
            WHERE PD.StorerKey = @cStorerKey        
            AND PD.OrderKey = @cOrderKey        
            AND PD.SKU = @cSKU       
         END  

         SET @cSerialNoKey = ''

         SELECT @cSerialNoKey = SerialNoKey
         FROM dbo.SerialNo WITH (NOLOCK) 
         WHERE StorerKey = @cStorerKey 
         AND SKU = @cSKU 
         AND SerialNo = @cSerialNo

         IF @@ROWCOUNT = 0  
         BEGIN 
            EXECUTE dbo.nspg_GetKey        
                     'SerialNo',        
                     10 ,        
                     @cSerialNoKey      OUTPUT,        
                     @b_Success          OUTPUT,        
                     @n_Err            OUTPUT,        
                     @c_ErrMsg           OUTPUT        
                       
            IF @b_Success <> 1        
            BEGIN        
               SET @n_Err = 1003404        
               SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpdHld07'        
               GOTO RollBackTran        
            END        
                                              
            INSERT INTO SerialNo (SerialNoKey, OrderKey, OrderLineNumber, StorerKey, SKU, SerialNo, Qty, status,LabelLine,Cartonno,pickslipno ,AddWho,AddDate,EditWho,EditDate)         
            VALUES ( @cSerialNoKey, @cOrderKey, ISNULL(@cOrderLineNumber,''), @cStorerKey, @cSKU , @cSerialNo , @nQty, '1',@cLblLineNumber,@nCartonNo,@cpickslipNo,@cUserName,GETDATE(),@cUserName,GETDATE() )         
  
            IF @@ERROR <> 0         
            BEGIN         
               SET @n_Err = 1003405        
               SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to Insert SerialNo table. Function : isp_TPS_ExtUpdHld07'        
               GOTO RollBackTran        
            END        
         END
         ELSE   
         BEGIN 
            UPDATE SerialNo WITH (ROWLOCK) SET      
               OrderKey = @cOrderKey,       
               OrderLineNumber = ISNULL(@cOrderLineNumber,''),  
               LabelLine = @cLblLineNumber,  
               CartonNo = @nCartonNo,  
               pickslipno = @cpickslipno,  
               trafficcop=null,  
               status='1',
               EditDate = GETDATE(),  
               EditWho = @cUserName   
            WHERE Serialnokey = @cSerialNoKey    
                        
            IF @@ERROR <> 0         
            BEGIN         
               SET @n_Err = 1003406        
               SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to Update SerialNo table. Function : isp_TPS_ExtUpdHld07'        
               GOTO RollBackTran        
            END        
         END
            
         INSERT INTO PackSerialNo(pickslipno,cartonno,labelno,labelline,storerkey,sku,serialno,qty,AddWho,AddDate,EditWho,EditDate)      
         values(@cpickslipNo,@nCartonNo,@cLabelNo,@cLblLineNumber,@cStorerKey,@csku,@cSerialNo,@nQty,@cUserName,GETDATE(),@cUserName,GETDATE())      
      
         IF @@ERROR <> 0         
         BEGIN         
            SET @n_Err = 1003407        
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to Insert SerialNo table. Function : isp_TPS_ExtUpdHld07'        
            GOTO RollBackTran        
         END   

         FETCH NEXT FROM @curAD INTO @cSKU, @cSkuBarcode, @cADCode
      END
      CLOSE @curAD
      DEALLOCATE @curAD
   END  

SET @b_Success = 1  
GOTO Quit 
     
RollBackTran:    
   ROLLBACK TRAN isp_TPS_ExtUpdHld07    
    
Quit:    
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
   BEGIN
      COMMIT TRAN isp_TPS_ExtUpdHld07     
   END
END    

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_ExtUpdHld07 TO NSQL
GO