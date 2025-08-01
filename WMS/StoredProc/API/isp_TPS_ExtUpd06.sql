SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

  
    
/******************************************************************************/      
/* Store procedure: isp_TPS_ExtUpd06                                          */      
/* Copyright      : Maersk                                                    */      
/*                                                                            */      
/* Date         Rev  Author     Purposes                                      */      
/* 2025-02-25   1.0  YeeKung    TPS-744 Created                               */      
/******************************************************************************/      
      
CREATE OR ALTER PROC [API].[isp_TPS_ExtUpd06] (      
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
    
DECLARE @curAD CURSOR    
DECLARE     
   @cSKU             NVARCHAR(20),    
   @cSkuBarcode      NVARCHAR(60),    
   @cOrderLineNumber NVARCHAR(5),
   @cLblLineNumber   NVARCHAR(5),
   @cWeight          NVARCHAR(10),    
   @cCube            NVARCHAR(10),    
   @cLottableVal     NVARCHAR(20),    
   @cSerialNoKey     NVARCHAR(60),    
   @cSerialNo        NVARCHAR(2000),    
   @cADCode          NVARCHAR(60),    
   @nQty             INT,  
   @nSNQTY           INT,
   @bsuccess         INT,
   @nTranCount       INT,
   @cStatus          NVARCHAR(20)
       
DECLARE @CloseCtnList TABLE (    
   SKU             NVARCHAR( 20),    
   QTY             INT,    
   Weight          FLOAT,    
   Cube            FLOAT,      
   lottableVal     NVARCHAR(60),    
   SkuBarcode      NVARCHAR(60),    
   ADCode          NVARCHAR(60)    
)    
    
    
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
   SAVE TRAN isp_TPS_ExtUpd06     
    
   IF @cOrderKey <> ''    
   BEGIN    
      IF EXISTS (SELECT 1 FROM CODELKUP WITH (NOLOCK) WHERE Listname = 'REQEXP'AND Code ='ADBARCODE' AND storerKey = @cStorerKey)    
      BEGIN    
         SET @curAD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
         SELECT SKU,SkuBarcode,ADCode  
         FROM @CloseCtnList    
         WHERE (SkuBarcode <> '' OR ADCode <> '')    
       
         OPEN @curAD    
         FETCH NEXT FROM @curAD INTO @cSKU, @cSkuBarcode, @cADCode   
         WHILE @@FETCH_STATUS <> -1    
         BEGIN    
            IF EXISTS (SELECT 1 FROM SKU WITH (NOLOCK) WHERE storerKey = @cStorerKey AND SKU = @cSKU AND susr4 = 'AD')    
            BEGIN    
               IF @cSkuBarcode <> ''    
               BEGIN    
                  SET @cSerialNo = @cSkuBarcode    
               END    
               ELSE    
               BEGIN    
                  SET @cSerialNo = @cADCode    
               END    

               DECLARE  @n_Foundpos INT,      
                        @n_LastFoundpos INT      
               
               SET @n_Foundpos = 0      
               SET @n_LastFoundpos = 0    
               
               WHILE 1=1      
               BEGIN      
                  SELECT @n_Foundpos = CHARINDEX('/', @cSerialNo, @n_Foundpos + 1)      
                        
                  IF @n_Foundpos > 0       
                     SET @n_LastFoundpos = @n_Foundpos      
                  ELSE      
                     BREAK              
               END       
                     
               IF @n_LastFoundpos > 0      
                  SELECT @cSerialNo = SUBSTRING(@cSerialNo, @n_LastFoundpos + 1, LEN(@cSerialNo) - @n_LastFoundpos)      
               ELSE      
                  SELECT @cSerialNo = @cSerialNo     
  
    
               IF NOT EXISTS ( SELECT 1 FROM SerialNo WITH (NOLOCK)      
                           WHERE StorerKEy = @cStorerKey      
                           AND SKU = @cSKU      
                           AND SerialNo = @cSerialNo )      
               BEGIN      
                  EXECUTE dbo.nspg_GetKey      
                           'SerialNo',      
                           10 ,      
                           @cSerialNoKey      OUTPUT,      
                           @bsuccess          OUTPUT,      
                           @n_Err            OUTPUT,      
                           @c_ErrMsg           OUTPUT      
                     
                  IF @bsuccess <> 1      
                  BEGIN      
                     SET @n_Err = 1001601      
                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpd06'      
                     GOTO RollBackTran      
                  END      
                      
                  SELECT @cOrderLineNumber = PD.OrderLineNumber       
                        ,@nQty             = PD.Qty      
                  FROM dbo.PickDetail PD WITH (NOLOCK)      
                  WHERE PD.StorerKey = @cStorerKey      
                  AND PD.OrderKey = @cOrderKey      
                  AND PD.SKU = @cSKU       
                  AND PD.OrderLineNumber Not IN ( SELECT S.OrderLineNumber FROM       
                                                   dbo.SerialNo S WITH (NOLOCK)       
                                                   WHERE S.OrderKey = @cOrderKey      
                                                   AND S.OrderLineNumber = PD.OrderLineNUmber      
                                                   AND S.SKU = @cSKU  )       
                     
                  SET @nQty =  1

                  SELECT @cLblLineNumber = PD.LabelLine  
                  FROM dbo.Packheader PH WITH (NOLOCK)    JOIN
                  dbo.packdetail PD(nolock) ON PH.PickSlipNo=PD.PickSlipNo
                  WHERE PD.StorerKey = @cStorerKey      
                  AND PH.OrderKey = @cOrderKey      
                  AND PD.SKU = @cSKU        
    
                  INSERT INTO PackSerialNo(pickslipno,cartonno,labelno,labelline,storerkey,sku,serialno,qty,AddWho,AddDate,EditWho,EditDate)    
                  values(@cpickslipNo,@nCartonNo,@cLabelNo,@cLblLineNumber,@cStorerKey,@csku,@cSerialNo,@nQty,@cUserName,GETDATE(),@cUserName,GETDATE())    
    
                  IF @@ERROR <> 0       
                  BEGIN       
                     SET @n_Err = 1001602      
                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'Fail to Insert PackSerialNo table. Function : isp_TPS_ExtUpd06'      
                     GOTO RollBackTran      
                  END      
                  
                  INSERT INTO SerialNo (SerialNoKey, OrderKey, OrderLineNumber, StorerKey, SKU, SerialNo, Qty, status,CartonNo,AddWho,AddDate,EditWho,EditDate )       
                  VALUES ( @cSerialNoKey, '','', @cStorerKey, @cSKU , @cSerialNo , @nQty, '1','',@cUserName,GETDATE(),@cUserName,GETDATE())       

                  IF @@ERROR <> 0       
                  BEGIN       
                     SET @n_Err = 1001603      
                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'Fail to Insert SerialNo table. Function : isp_TPS_ExtUpd06'      
                     GOTO RollBackTran      
                  END      
               END      
               ELSE IF EXISTS (SELECT 1 FROM SerialNo WITH (NOLOCK)      
                           WHERE StorerKEy = @cStorerKey      
                           AND OrderKey = ''      
                           AND SKU = @cSKU      
                           AND SerialNo = @cSerialNo )      
               BEGIN    
                  SELECT @cOrderLineNumber = PD.OrderLineNumber       
                        ,@nQty             = PD.Qty      
                  FROM dbo.PickDetail PD WITH (NOLOCK)      
                  WHERE PD.StorerKey = @cStorerKey      
                  AND PD.OrderKey = @cOrderKey      
                  AND PD.SKU = @cSKU       
                  AND PD.OrderLineNumber Not IN ( SELECT S.OrderLineNumber FROM       
                                                   dbo.SerialNo S WITH (NOLOCK)       
                                                   WHERE S.OrderKey = @cOrderKey      
                                                   AND S.OrderLineNumber = PD.OrderLineNUmber      
                                                   AND S.SKU = @cSKU  )  
                                                   
                  SELECT @cLblLineNumber = PD.LabelLine  
                  FROM dbo.Packheader PH WITH (NOLOCK)    JOIN
                  dbo.packdetail PD(nolock) ON PH.PickSlipNo=PD.PickSlipNo
                  WHERE PD.StorerKey = @cStorerKey      
                  AND PH.OrderKey = @cOrderKey      
                  AND PD.SKU = @cSKU        
    
                  IF NOT EXISTS(select 1 from packserialno (nolock)    
                        where pickslipno=@cpickslipNo    
                        and storerkey=@cStorerKey    
                        and sku=@csku
                        and serialno=@cSerialNo)    
                  BEGIN   
  
                     SET @nQty = CASE WHEN ISNULL(@nQty,'') IN(0,'') then 1 ELSE @nQty END  

                     SELECT @nSNQTY=qty
                     FROM SerialNo (NOLOCK)
                     WHERE StorerKEy = @cStorerKey      
                     AND OrderKey = ''      
                     AND SKU = @cSKU      
                     AND SerialNo = @cSerialNo 

                     INSERT INTO PackSerialNo(pickslipno,cartonno,labelno,labelline,storerkey,SerialNo,sku,qty,AddWho,AddDate,EditWho,EditDate)    
                     values(@cpickslipno,@nCartonNo,@cLabelNo,@cLblLineNumber,@cStorerKey,@cserialno,@csku,@nSNQTY,@cUserName,GETDATE(),@cUserName,GETDATE())    
    
                     IF @@ERROR <> 0       
                     BEGIN       
                        SET @n_Err = 1001604      
                        SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'Fail to Insert PackSerialNo table. Function : isp_TPS_ExtUpd06'      
                        GOTO RollBackTran      
                     END
               END    
               END
            END    
            FETCH NEXT FROM @curAD INTO @cSKU, @cSkuBarcode, @cADCode      
         END  
      END    
   END    
 GOTO Quit    
     
 RollBackTran:    
      ROLLBACK TRAN isp_TPS_ExtUpd06    
    
   Quit:    
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
      BEGIN
         COMMIT TRAN isp_TPS_ExtUpd06    
         SET @b_Success = '1'  
      END
    
END      
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_ExtUpd06 TO NSQL
GO


