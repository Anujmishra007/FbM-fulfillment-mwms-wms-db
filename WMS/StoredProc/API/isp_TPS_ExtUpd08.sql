SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

  
    
/******************************************************************************/      
/* Store procedure: isp_TPS_ExtUpd08                                          */      
/* Copyright      : Maersk                                                    */      
/*                                                                            */      
/* Date         Rev  Author     Purposes                                      */      
/* 2025-05-08   1.0  GhChan     FCR-4548                                     */ 
/******************************************************************************/      
      
CREATE OR ALTER PROC [API].[isp_TPS_ExtUpd08] (      
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
   @pickSkuDetailJson   NVARCHAR( MAX),
   @b_Success       INT = 1        OUTPUT,    
   @n_Err           INT = 0        OUTPUT,    
   @c_ErrMsg        NVARCHAR( 255) = ''  OUTPUT     
)      
AS      
      
SET NOCOUNT ON      
SET QUOTED_IDENTIFIER OFF      
SET ANSI_NULLS OFF      
SET CONCAT_NULL_YIELDS_NULL OFF      
    
DECLARE @curSerialNo CURSOR    
DECLARE     
   @cSKU             NVARCHAR(20),    
   @cSkuBarcode      NVARCHAR(60),    
   @cPickDetailKey   NVARCHAR(18),
   @cLabelLine       NVARCHAR(5),    
   @cSerialNoKey     NVARCHAR(60),     
   @cSerialNo        NVARCHAR(50),    
   @cADCode          NVARCHAR(60), 
   @nTranCount       INT,  
   @cCurOrderkey     NVARCHAR(20)
       
DECLARE @CloseCtnList TABLE (    
   SKU             NVARCHAR( 20),    
   QTY             INT,    
   Weight          FLOAT,    
   Cube            FLOAT,      
   lottableVal     NVARCHAR(60),    
   SkuBarcode      NVARCHAR(60),    
   ADCode          NVARCHAR(60)    
)    
    
SET @b_Success = 1 
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
INSERT INTO @CloseCtnList (SKU, QTY, WEIGHT, CUBE, lottableVal,SkuBarcode, ADCode)    
SELECT     
Hdr.SKU    
, Hdr.Qty    
, Hdr.Weight    
, Hdr.Cube    
, Hdr.lottableValue    
, Det.barcodeVal    
, Det.AntiDiversionCode    
FROM OPENJSON(@cCloseCartonJson)    
WITH (    
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
   SAVE TRAN isp_TPS_ExtUpd08     
   
   SELECT @cCurOrderkey = Orderkey  
   FROM PICKHEADER (NOLOCK)  
   WHERE Pickheaderkey = @cpickslipNo  
  
   IF ISNULL( @cCurOrderkey,'') <>''  
      SET @cOrderkey = @cCurOrderkey  

   SET @cOrderKey = ISNULL(@cOrderKey,'')
   SET @cLoadKey = ISNULL(@cLoadKey,'')
   IF @cOrderKey = '' AND @cLoadKey = ''     
   BEGIN
      SET @b_Success = 0;
      SET @n_Err = 1002762        
      SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'OrderKey or LoadKey Not found, failed to proceed. Function : isp_TPS_ExtUpd08'        
      GOTO RollBackTran       
   END   

   IF NOT EXISTS (SELECT 1 FROM CODELKUP WITH (NOLOCK) WHERE Listname = 'REQEXP'AND Code ='ADBARCODE' AND storerKey = @cStorerKey)    
   BEGIN 
      SET @b_Success = 0
      SET @n_Err = 1002751      
      SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'REQEXP Codelkup is not setup. Function : isp_TPS_ExtUpd08'      
      GOTO RollBackTran      
   END

   SET @curSerialNo = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT SKU,ISNULL(RTRIM(SkuBarcode),''),ISNULL(RTRIM(ADCode),'')
   FROM @CloseCtnList
   WHERE (SkuBarcode <> '' OR ADCode <> '')

   OPEN @curSerialNo
   FETCH NEXT FROM @curSerialNo INTO @cSKU, @cSkuBarcode, @cADCode
   WHILE @@FETCH_STATUS <> -1
   BEGIN
      SET @cSerialNo = ''
      SET @cLabelLine = ''

      IF NOT EXISTS (SELECT 1 FROM SKU WITH (NOLOCK) WHERE storerKey = @cStorerKey AND SKU = @cSKU AND susr4 = 'AD')    
      BEGIN    
         GOTO NEXTITEM
      END  

      IF @cSkuBarcode <> ''    
      BEGIN    
         SET @cSerialNo = @cSkuBarcode    
      END    
      ELSE IF @cADCode <> ''      
      BEGIN    
         SET @cSerialNo = @cADCode    
      END 
      
      IF @cSerialNo = ''
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 1002753      
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'No SkuBarcode or ADBarcode found. Function : isp_TPS_ExtUpd08'      
         GOTO RollBackTran   
      END

      IF LEN(@cSerialNo) < 5
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 1002754
	      SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') --'Error: Serial No must be at least 5 characters long. Function : isp_TPS_ExtUpd08'
         GOTO RollBackTran 
      END

       IF LEFT(@cSerialNo, 2) = '00'
      BEGIN
         SET @cSerialNo = SUBSTRING(@cSerialNo, 3, LEN(@cSerialNo))
      END

      IF LEN(@cSerialNo) > 18
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 1002755
	      SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') --'Error: Serial No must not be more than 18 characters long. Function : isp_TPS_ExtUpd08'
         GOTO RollBackTran 
      END

      IF EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSerialNo)
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 1002756
	      SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') --'Error: Serial No cannot be same as SKU code. Function : isp_TPS_ExtUpd08'
         GOTO RollBackTran
      END

      IF EXISTS (SELECT 1 FROM PackSerialNo (NOLOCK) 
      WHERE StorerKey = @cStorerKey 
      AND SerialNo = @cSerialNo
      AND PickSlipNo = @cPickSlipNo
      )
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 1002757
	      SET @c_ErrMsg = '(' + @cSerialNo + ')' + API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') --'Error: Serial No already been packed in PackSerialNo. Function : isp_TPS_ExtUpd08'
         GOTO RollBackTran
      END

      IF EXISTS ( SELECT 1 FROM SerialNo WITH (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND SKU = @cSKU
                        AND SerialNo = @cSerialNo
                        AND [Status] <> '1'
                        )
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 1002758
	      SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') --'Error: Serial No been used in SerialNo table. Function : isp_TPS_ExtUpd08'
         GOTO RollBackTran
      END

      SELECT @cLabelLine = PD.LabelLine ,
             @cDropID = CASE WHEN ISNULL(PD.DropID,'') = '' THEN RTRIM(ISNULL(@cDropID,'')) ELSE  RTRIM(ISNULL(PD.DropID,'')) END 
      FROM dbo.Packheader PH WITH (NOLOCK)    
         JOIN dbo.packdetail PD(nolock) ON PH.PickSlipNo=PD.PickSlipNo
      WHERE PH.StorerKey = @cStorerKey      
         AND PH.PickSlipNo = @cPickSlipNo
         AND PD.Cartonno = @nCartonNo
         AND PD.SKU = @cSKU

      SELECT @cPickDetailKey = PD.PickDetailKey
      FROM dbo.PickDetail PD WITH (NOLOCK)
         JOIN Orders O WITH (NOLOCK) ON PD.Orderkey = O.Orderkey AND PD.Storerkey = O.Storerkey
      WHERE PD.StorerKey = @cStorerKey
         AND (@cOrderKey = '' OR O.OrderKey = @cOrderKey)
         AND (@cLoadKey = '' OR O.LoadKey = @cLoadKey)
         AND (@cDropID = '' OR PD.DropID = @cDropID)
         AND PD.SKU = @cSKU
         AND NOT EXISTS (  SELECT 1
                              FROM PackSerialNo PSN (NOLOCK)
                              WHERE PSN.PickDetailKey = PD.PickDetailKey
                              GROUP BY PSN.PickDetailKey
                              HAVING SUM(PSN.Qty) = PD.Qty
                              )

      EXECUTE dbo.nspg_GetKey
               'SerialNo',
               10 ,
               @cSerialNoKey  OUTPUT,
               @b_Success     OUTPUT,
               @n_Err         OUTPUT,
               @c_ErrMsg      OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_Err = 1002759
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpd08'
         GOTO RollBackTran
      END

      INSERT INTO SerialNo (SerialNoKey,Orderkey, Orderlinenumber, StorerKey, SKU, SerialNo, Qty,pickslipno,CartonNo,status,AddWho,AddDate,EditWho,EditDate)
      VALUES ( @cSerialNoKey,'','', @cStorerKey, @cSKU, @cSerialNo, 1, '', '', '1', @cUserName, GETDATE(), @cUserName, GETDATE())

      IF @@ERROR <> 0
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 1002760
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail Insert SerialNO Function : isp_TPS_ExtUpd08' 
         GOTO RollBackTran
      END
         
      INSERT INTO PackSerialNo(Pickslipno,cartonno,labelno,labelline,storerkey,sku,serialno,qty,PickDetailKey,Barcode,AddWho,AddDate,EditWho,EditDate)    
      values(@cPickSlipNo,@nCartonNo,@cLabelNo,@cLabelLine,@cStorerKey,@cSKU,@cSerialNo,1,ISNULL(@cPickDetailKey,''),@cADCode,@cUserName,GETDATE(),@cUserName,GETDATE())    
    
      IF @@ERROR <> 0
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 1002761
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail Insert PackSerialNo Function : isp_TPS_ExtUpd08' 
         GOTO RollBackTran
      END  

NEXTITEM:
      FETCH NEXT FROM @curSerialNo INTO @cSKU, @cSkuBarcode, @cADCode
   END

   CLOSE @curSerialNo;
   DEALLOCATE @curSerialNo;

   GOTO QUIT
   --IF ISNULL(@cOrderKey,'') <> ''    
   --BEGIN    
   --   IF EXISTS (SELECT 1 FROM CODELKUP WITH (NOLOCK) WHERE Listname = 'REQEXP'AND Code ='ADBARCODE' AND storerKey = @cStorerKey)    
   --   BEGIN    
   --      SET @curAD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
   --      SELECT SKU,SkuBarcode,ADCode  
   --      FROM @CloseCtnList    
   --      WHERE (SkuBarcode <> '' OR ADCode <> '')    
       
   --      OPEN @curAD    
   --      FETCH NEXT FROM @curAD INTO @cSKU, @cSkuBarcode, @cADCode   
   --      WHILE @@FETCH_STATUS <> -1    
   --      BEGIN    
   --         IF EXISTS (SELECT 1 FROM SKU WITH (NOLOCK) WHERE storerKey = @cStorerKey AND SKU = @cSKU AND susr4 = 'AD')    
   --         BEGIN    
   --            IF @cSkuBarcode <> ''    
   --            BEGIN    
   --               SET @cSerialNo = @cSkuBarcode    
   --            END    
   --            ELSE    
   --            BEGIN    
   --               SET @cSerialNo = @cADCode    
   --            END    
               
   --            IF LEN(@cSerialNo) = 20 AND @cSerialNo LIKE '0%'
   --            BEGIN
   --               SET @cSerialNo = SUBSTRING(@cSerialNo, PATINDEX('%[^0]%', @cSerialNo), LEN(@cSerialNo))
   --            END
   --            IF NOT EXISTS ( SELECT 1 FROM SerialNo WITH (NOLOCK)      
   --                        WHERE StorerKEy = @cStorerKey      
   --                        AND SKU = @cSKU      
   --                        AND SerialNo = @cSerialNo )      
   --            BEGIN      
   --               EXECUTE dbo.nspg_GetKey      
   --                        'SerialNo',      
   --                        10 ,      
   --                        @cSerialNoKey      OUTPUT,      
   --                        @bsuccess          OUTPUT,      
   --                        @nErrNo            OUTPUT,      
   --                        @cErrMsg           OUTPUT      
                     
   --               IF @bsuccess <> 1      
   --               BEGIN      
   --                  SET @n_Err = 1002751      
   --                  SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpd08'      
   --                  GOTO RollBackTran      
   --               END      
                      
   --               SELECT @cOrderLineNumber = PD.OrderLineNumber       
   --                     ,@nQty             = PD.Qty      
   --               FROM dbo.PickDetail PD WITH (NOLOCK)      
   --               WHERE PD.StorerKey = @cStorerKey      
   --               AND PD.OrderKey = @cOrderKey      
   --               AND PD.SKU = @cSKU       
   --               AND PD.OrderLineNumber Not IN ( SELECT S.OrderLineNumber FROM       
   --                                                dbo.SerialNo S WITH (NOLOCK)       
   --                                                WHERE S.OrderKey = @cOrderKey      
   --                                                AND S.OrderLineNumber = PD.OrderLineNUmber      
   --                                                AND S.SKU = @cSKU  )       
                     
   --               SET @nQty =  1

                  
   --               IF EXISTS ( SELECT 1
   --                           FROM SKU (NOLOCK)
   --                           WHERE SKU = @cSKU 
   --                              AND  StorerKey = @cStorerKey  
   --                              AND SerialNoCapture IN ('1','3'))
   --               BEGIN
   --                  SET @cStatus ='1'
   --               END
   --               ELSE
   --               BEGIN
   --                  SET @cStatus ='6'
   --               END
                  

   --                SELECT @cLblLineNumber = PD.LabelLine  
   --               FROM dbo.Packheader PH WITH (NOLOCK)    JOIN
   --               dbo.packdetail PD(nolock) ON PH.PickSlipNo=PD.PickSlipNo
   --               WHERE PD.StorerKey = @cStorerKey      
   --               AND PH.OrderKey = @cOrderKey      
   --               AND PD.SKU = @cSKU        
    

 
   --               INSERT INTO PackSerialNo(pickslipno,cartonno,labelno,labelline,storerkey,sku,serialno,qty)    
   --               values(@cpickslipNo,@nCartonNo,@cLabelNo,@cLblLineNumber,@cStorerKey,@csku,@cSerialNo,@nQty)    
    
   --               IF @@ERROR <> 0       
   --               BEGIN       
   --                  SET @b_Success = 0
   --                  SET @n_Err = 1002752      
   --                  SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to Insert PackSerialNo table. Function : isp_TPS_ExtUpd08'      
   --                  GOTO RollBackTran      
   --               END      
                  
   --               INSERT INTO SerialNo (SerialNoKey, OrderKey, OrderLineNumber, StorerKey, SKU, SerialNo, Qty, status,CartonNo )       
   --               VALUES ( @cSerialNoKey, @cOrderKey, ISNULL(@cOrderLineNumber,''), @cStorerKey, @cSKU , @cSerialNo , @nQty, @cStatus,@nCartonNo)       

   --               IF @@ERROR <> 0       
   --               BEGIN      
   --                  SET @b_Success = 0
   --                  SET @n_Err = 1002753      
   --                  SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to Insert SerialNo table. Function : isp_TPS_ExtUpd08'      
   --                  GOTO RollBackTran      
   --               END      
   --            END      
   --            ELSE IF EXISTS (SELECT 1 FROM SerialNo WITH (NOLOCK)      
   --                        WHERE StorerKEy = @cStorerKey      
   --                        AND OrderKey = ''      
   --                        AND SKU = @cSKU      
   --                        AND SerialNo = @cSerialNo )      
   --            BEGIN    
   --               SELECT @cOrderLineNumber = PD.OrderLineNumber       
   --                     ,@nQty             = PD.Qty      
   --               FROM dbo.PickDetail PD WITH (NOLOCK)      
   --               WHERE PD.StorerKey = @cStorerKey      
   --               AND PD.OrderKey = @cOrderKey      
   --               AND PD.SKU = @cSKU       
   --               AND PD.OrderLineNumber Not IN ( SELECT S.OrderLineNumber FROM       
   --                                                dbo.SerialNo S WITH (NOLOCK)       
   --                                                WHERE S.OrderKey = @cOrderKey      
   --                                                AND S.OrderLineNumber = PD.OrderLineNUmber      
   --                                                AND S.SKU = @cSKU  )  
                                                   
   --               SELECT @cLblLineNumber = PD.LabelLine  
   --               FROM dbo.Packheader PH WITH (NOLOCK)    JOIN
   --               dbo.packdetail PD(nolock) ON PH.PickSlipNo=PD.PickSlipNo
   --               WHERE PD.StorerKey = @cStorerKey      
   --               AND PH.OrderKey = @cOrderKey      
   --               AND PD.SKU = @cSKU        
    
   --               IF NOT EXISTS(select 1 from packserialno (nolock)    
   --                     where pickslipno=@cpickslipNo    
   --                     and storerkey=@cStorerKey    
   --                     and sku=@csku
   --                     and serialno=@cSerialNo)    
   --               BEGIN   
  
   --                  SET @nQty = CASE WHEN ISNULL(@nQty,'') IN(0,'') then 1 ELSE @nQty END  

   --                  SELECT @nSNQTY=qty
   --                  FROM SerialNo (NOLOCK)
   --                  WHERE StorerKEy = @cStorerKey      
   --                  AND OrderKey = ''      
   --                  AND SKU = @cSKU      
   --                  AND SerialNo = @cSerialNo 

   --                  INSERT INTO PackSerialNo(pickslipno,cartonno,labelno,labelline,storerkey,SerialNo,sku,qty)    
   --                  values(@cpickslipno,@nCartonNo,@cLabelNo,@cLblLineNumber,@cStorerKey,@cserialno,@csku,@nSNQTY)    
    
   --                  IF @@ERROR <> 0       
   --                  BEGIN       
   --                     SET @n_Err = 1002754      
   --                     SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to Insert PackSerialNo table. Function : isp_TPS_ExtUpd08'      
   --                     GOTO RollBackTran      
   --                  END      
   --               END    

   --               UPDATE SerialNo WITH (ROWLOCK) SET    
   --                  OrderKey = @cOrderKey,    
   --                  OrderLineNumber = ISNULL(@cOrderLineNumber,''),    
   --                  STATUS = '6'    
   --               WHERE StorerKEy = @cStorerKey      
   --               AND OrderKey = ''      
   --               AND SKU = @cSKU      
   --               AND SerialNo = @cSerialNo    
                      
   --               IF @@ERROR <> 0       
   --               BEGIN       
   --                  SET @b_Success = 0
   --                  SET @n_Err = 1002755      
   --                  SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to Update SerialNo table. Function : isp_TPS_ExtUpd08'      
   --                  GOTO RollBackTran      
   --               END      
   --            END    
   --         END    
   --         FETCH NEXT FROM @curAD INTO @cSKU, @cSkuBarcode, @cADCode      
   --      END  
   --   END    
   --END    
   --ELSE
   --BEGIN
   --   SET @b_Success = 0
   --   SET @n_Err = 1002756      
   --   SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'OrderKey is empty failed to proceed to update the SerialNo/PackSerialNo. Function : isp_TPS_ExtUpd08'      
   --   GOTO RollBackTran      
   --END 
     
 RollBackTran:    
      ROLLBACK TRAN isp_TPS_ExtUpd08    

QUIT:  
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
      BEGIN
         COMMIT TRAN isp_TPS_ExtUpd08           
      END
    
END      
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_ExtUpd08 TO NSQL
GO


