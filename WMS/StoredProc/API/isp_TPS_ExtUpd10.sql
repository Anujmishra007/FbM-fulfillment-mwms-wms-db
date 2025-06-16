SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

  
    
/******************************************************************************/      
/* Store procedure: isp_TPS_ExtUpd10                                          */      
/* Copyright      : Maersk                                                    */      
/*                                                                            */      
/* Date         Rev  Author     Purposes                                      */      
/* 2025-06-16   1.0  GhChan    FCR-5168 Created                               */      
/******************************************************************************/      
      
CREATE OR ALTER PROC [API].[isp_TPS_ExtUpd10] (      
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
   @cStatus          NVARCHAR(20),
   @cPickDetailKey   NVARCHAR(18) 
       
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
   SAVE TRAN isp_TPS_ExtUpd10     
    
   IF ISNULL(@cOrderKey,'') = ''    
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 1002951      
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'OrderKey cannot be empty. Function : isp_TPS_ExtUpd10'      
      GOTO RollBackTran       
   END  
   
   IF NOT EXISTS (SELECT 1 FROM CODELKUP WITH (NOLOCK) WHERE Listname = 'REQEXP'AND Code ='ADBARCODE' AND storerKey = @cStorerKey)    
   BEGIN    
      SET @b_Success = 0
      SET @n_Err = 1002952      
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'ListName(REQEXP) and Code(ADBARCODE) is not found. Function : isp_TPS_ExtUpd10'      
      GOTO RollBackTran       
   END

   SET @curAD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
   SELECT SKU,SkuBarcode,ADCode  
   FROM @CloseCtnList    
   WHERE (SkuBarcode <> '' OR ADCode <> '')    
       
   OPEN @curAD    
   FETCH NEXT FROM @curAD INTO @cSKU, @cSkuBarcode, @cADCode   
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
         SET @n_Err = 1002958      
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'PackOtherUnit2 cannot be less than 1. Function : isp_TPS_ExtUpd10'      
         GOTO RollBackTran 
      END

      IF @cSkuBarcode <> ''    
      BEGIN    
         SET @cSerialNo = @cSkuBarcode    
      END    
      ELSE    
      BEGIN    
         SET @cSerialNo = @cADCode    
      END      
      
      SELECT @cOrderLineNumber = PD.OrderLineNumber       
            ,@cPickDetailKey = ISNULL(PD.PickDetailKey,'')
      FROM dbo.PickDetail PD WITH (NOLOCK)      
      WHERE PD.StorerKey = @cStorerKey      
         AND PD.OrderKey = @cOrderKey      
         AND PD.SKU = @cSKU       
         AND PD.OrderLineNumber Not IN (  SELECT S.OrderLineNumber 
                                          FROM dbo.SerialNo S WITH (NOLOCK)       
                                          WHERE S.OrderKey = @cOrderKey      
                                             AND S.OrderLineNumber = PD.OrderLineNUmber      
                                             AND S.SKU = @cSKU  ) 
      SELECT @cLblLineNumber = PD.LabelLine  
           , @cLabelNo = labelno  
      FROM dbo.Packheader PH WITH (NOLOCK)    
         JOIN dbo.packdetail PD(nolock) ON PH.PickSlipNo=PD.PickSlipNo
      WHERE PD.StorerKey = @cStorerKey      
         AND PH.OrderKey = @cOrderKey      
         AND PD.SKU = @cSKU
      
      SET @cSerialNoKey = ''

      SELECT  @cSerialNoKey = SerialNoKey
      FROM SerialNo (NOLOCK)
      WHERE StorerKEy = @cStorerKey      
      AND SKU = @cSKU      
      AND SerialNo = @cSerialNo 

      IF @@ROWCOUNT = 0
      BEGIN      
         EXECUTE dbo.nspg_GetKey      
                  'SerialNo',      
                  10 ,      
                  @cSerialNoKey  OUTPUT,      
                  @bsuccess      OUTPUT,      
                  @n_Err         OUTPUT,      
                  @c_ErrMsg      OUTPUT      
                     
         IF @bsuccess <> 1      
         BEGIN     
            SET @b_Success = 0
            SET @n_Err = 1002953      
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpd10'      
            GOTO RollBackTran      
         END       
    
         INSERT INTO PackSerialNo(pickslipno,cartonno,labelno,labelline,storerkey,sku,serialno,qty, PickDetailKey,AddWho,AddDate,EditWho,EditDate)    
         values(@cpickslipNo,@nCartonNo,@cLabelNo,@cLblLineNumber,@cStorerKey,@csku,@cSerialNo,@nQty, @cPickDetailKey,@cUserName,GETDATE(),@cUserName,GETDATE())    
    
         IF @@ERROR <> 0       
         BEGIN       
            SET @b_Success = 0
            SET @n_Err = 1002954      
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'Fail to Insert PackSerialNo table. Function : isp_TPS_ExtUpd10'      
            GOTO RollBackTran      
         END      
                  
         INSERT INTO SerialNo (SerialNoKey, OrderKey, OrderLineNumber, StorerKey, SKU, SerialNo, Qty, [Status],CartonNo, LabelLine,AddWho,AddDate,EditWho,EditDate )       
         VALUES ( @cSerialNoKey, @cOrderKey, @cOrderLineNumber, @cStorerKey, @cSKU, @cSerialNo, @nQty, '1', @nCartonNo, @cLblLineNumber,@cUserName,GETDATE(),@cUserName,GETDATE())       

         IF @@ERROR <> 0       
         BEGIN       
            SET @b_Success = 0
            SET @n_Err = 1002955      
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'Fail to Insert SerialNo table. Function : isp_TPS_ExtUpd10'      
            GOTO RollBackTran      
         END      
      END      
      ELSE
      BEGIN    
         IF EXISTS(  SELECT  1
                     FROM SerialNo (NOLOCK)
                     WHERE StorerKEy = @cStorerKey      
                        AND SKU = @cSKU      
                        AND SerialNo = @cSerialNo
                        AND OrderKey <> ''
                        AND [Status] <> '1'
                        )
         BEGIN
            GOTO NEXTITEM -- SerialNo Exists then proceed the next records because the frontend return all the same AD for the each SKU during close carton.
         END

         UPDATE SerialNo
         SET OrderKey = @cOrderKey
            ,OrderLineNumber = @cOrderLineNumber
            ,PickSlipNo = @cpickslipNo
            ,CartonNo = @nCartonNo
            ,LabelLine = @cLblLineNumber
            ,EditDate = GETDATE()
            ,EditWho = @cUserName
         WHERE SerialNoKey = @cSerialNoKey

         IF @@ERROR <> 0       
         BEGIN       
            SET @b_Success = 0
            SET @n_Err = 1002956      
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'Fail to Update SerialNo table. Function : isp_TPS_ExtUpd10'      
            GOTO RollBackTran      
         END     

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
   
         INSERT INTO PackSerialNo(pickslipno,cartonno,labelno,labelline,storerkey,SerialNo,sku,qty, PickDetailKey,AddWho,AddDate,EditWho,EditDate)    
         values(@cpickslipno,@nCartonNo,@cLabelNo,@cLblLineNumber,@cStorerKey,@cserialno,@csku,@nQty, @cPickDetailKey, @cUserName,GETDATE(),@cUserName,GETDATE())    
    
         IF @@ERROR <> 0       
         BEGIN 
            SET @b_Success = 0
            SET @n_Err = 1002957      
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'Fail to Insert PackSerialNo table. Function : isp_TPS_ExtUpd10'      
            GOTO RollBackTran      
         END
      END

NEXTITEM:
      FETCH NEXT FROM @curAD INTO @cSKU, @cSkuBarcode, @cADCode      
   END 
 GOTO Quit    
     
 RollBackTran:    
      ROLLBACK TRAN isp_TPS_ExtUpd10    
    
   Quit:    
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
      BEGIN
         COMMIT TRAN isp_TPS_ExtUpd10     
      END
    
END      
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_ExtUpd10 TO NSQL
GO


