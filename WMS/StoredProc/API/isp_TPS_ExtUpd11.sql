SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

  
    
/******************************************************************************/      
/* Store procedure: isp_TPS_ExtUpd11                                          */      
/* Copyright      : Maersk                                                    */      
/*                                                                            */      
/* Date         Rev  Author     Purposes                                      */      
/* 2025-08-28   1.0  GCH225     FCR-7558 Created                              */     
/* 2025-09-30   2.0  GCH225     FCR-8274 Allow Update Return Serialno         */   
/******************************************************************************/      
      
CREATE OR ALTER PROC [API].[isp_TPS_ExtUpd11] (      
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
   @cSKU                NVARCHAR(20),    
   @cSkuBarcode         NVARCHAR(60),    
   @cLblLineNumber      NVARCHAR(5),
   @cWeight             NVARCHAR(10),    
   @cCube               NVARCHAR(10),    
   @cLottableVal        NVARCHAR(20),    
   @cSerialNoKey        NVARCHAR(60),    
   @cSerialNo           NVARCHAR(2000),    
   @cADCode             NVARCHAR(60),    
   @nQty                FLOAT,  
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
   @cSerialNoCapture    NVARCHAR(1)
       
DECLARE @CloseCtnList TABLE (    
   SKU             NVARCHAR( 20),    
   QTY             INT,    
   Weight          FLOAT,    
   Cube            FLOAT,      
   lottableVal     NVARCHAR(60),    
   SkuBarcode      NVARCHAR(60),    
   ADCode          NVARCHAR(60)    
)    
    
SET @b_Success = 0

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
   SAVE TRAN isp_TPS_ExtUpd11     
    
   IF ISNULL(@cOrderKey,'') = ''    
   BEGIN
      SET @n_Err = 1003201      
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'OrderKey cannot be empty. Function: isp_TPS_ExtUpd11'      
      GOTO RollBackTran       
   END  
   
   IF NOT EXISTS (SELECT 1 FROM CODELKUP WITH (NOLOCK) WHERE Listname = 'REQEXP'AND Code ='ADBARCODE' AND storerKey = @cStorerKey)    
   BEGIN    
      SET @n_Err = 1003202      
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'ListName(REQEXP) and Code(ADBARCODE) is not found. Function : isp_TPS_ExtUpd11'      
      GOTO RollBackTran       
   END

   SET @curAD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
   SELECT  H.SKU
         , H.SkuBarcode
         , H.ADCode
         , S.SUSR4
         , S.SerialNoCapture
         , P.OtherUnit2
   FROM @CloseCtnList H  
   INNER JOIN SKU S (NOLOCK)
   ON H.SKU = S.SKU
   INNER JOIN PACK P (NOLOCK)
   ON S.PACKKey = P.PackKey
   WHERE (H.SkuBarcode <> '' OR H.ADCode <> '')    
   AND S.StorerKey = @cStorerKey 
   AND S.SUSR4 = 'AD'
       
   OPEN @curAD    
   FETCH NEXT FROM @curAD INTO @cSKU, @cSkuBarcode, @cADCode, @cSUSR4, @cSerialNoCapture, @nQty
   WHILE @@FETCH_STATUS <> -1    
   BEGIN    
      IF @nQty < 1
      BEGIN
         SET @n_Err = 1003203      
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'PackOtherUnit2 cannot be less than 1. Function: isp_TPS_ExtUpd11'      
         GOTO RollBackTran 
      END

      SET @cSerialNo = IIF( @cSkuBarcode <> '', @cSkuBarcode ,@cADCode)
      
      SET @nQPos = CHARINDEX('?', @cSerialNo);
      SET @nBangPos = CHARINDEX('!', @cSerialNo);

      IF @nQPos = 0 OR @nBangPos = 0 OR @nQPos > @nBangPos
      BEGIN
         SET @n_Err = 1003204     
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Invalid format: must contain "?" before "!". Function: isp_TPS_ExtUpd11'      
         GOTO RollBackTran 
      END

      SET @cFirstValue = ''
      SET @cSecondValue = ''

      --SerialNo
      SET @cFirstValue = SUBSTRING(@cSerialNo, @nQPos + 1, @nBangPos - @nQPos - 1)
      
      --UPC
      SET @cSecondValue = SUBSTRING(@cSerialNo, @nBangPos + 1, LEN(@cSerialNo) - @nBangPos)

      IF NOT EXISTS( SELECT 1 
                     FROM UPC (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                     AND SKU = @cSKU
                     AND UPC = @cSecondValue
      )
      BEGIN
         SET @n_Err = 1003210
	      SET @c_ErrMsg = 'UPC('  + @cSecondValue + ') ' + API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') --'with current SKU does not found in UPC table.. Function: isp_TPS_ExtUpd11' 
         GOTO RollBackTran
      END

      IF EXISTS(SELECT 1 
                FROM PackSerialNo (NOLOCK)
                WHERE PickSlipNo = @cpickslipNo    
                AND StorerKey = @cStorerKey    
                AND SerialNo = @cFirstValue
                AND SKU = @cSKU
      )
      BEGIN
         SET @n_Err = 1003205     
         SET @c_ErrMsg = '(' + @cFirstValue + ')' + API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'This serial no already been used or exists in PackSerialNo Table. Function: isp_TPS_ExtUpd11'      
         GOTO RollBackTran 
      END

      SET @cSerialNoKey = ''
      SET @cStatus = ''
      SET @cSerialNoOrderKey = ''

      SELECT @cSerialNoKey = SerialNoKey
            ,@cStatus =[Status]
            ,@cSerialNoOrderKey =ISNULL(OrderKey,'')
      FROM SerialNo (NOLOCK)
      WHERE SerialNo = @cFirstValue
         AND storerKey = @cStorerKey
         AND SKU = @cSKU

      IF @@ROWCOUNT <> 0
      BEGIN
         IF @cSerialNoCapture = '3'
         BEGIN
            --if Status '1' means new SerialNo, can proceed. 
            --if Status '9' or 'CANC' means either return or cancel order, can proceed too.
            IF  @cStatus NOT IN ('1','9', 'CANC')
            BEGIN
               SET @n_Err = 1003206
	            SET @c_ErrMsg = '(' + @cFirstValue + ')'  + API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'This serial no already been used in SerialNo Table. Function: isp_TPS_ExtUpd11'
               GOTO RollBackTran
            END
         END
         ELSE
         BEGIN
            --if Status '1' means new SerialNo, can proceed.
            IF @cStatus NOT IN ('1')
            BEGIN
               SET @n_Err = 1003206
	            SET @c_ErrMsg = '(' + @cFirstValue + ')'  + API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'This serial no already been used in SerialNo Table. Function: isp_TPS_ExtUpd11'
               GOTO RollBackTran
            END
         END
      END    

      SELECT @cLblLineNumber = PD.LabelLine  
           , @cLabelNo = PD.Labelno    
      FROM dbo.Packheader PH (NOLOCK)    
         JOIN dbo.packdetail PD(NOLOCK) 
         ON PH.PickSlipNo=PD.PickSlipNo
      WHERE PH.StorerKey = @cStorerKey      
         AND PH.PickSlipNo = @cpickslipno
         AND PD.CartonNo = @nCartonNo
         AND PD.SKU = @cSKU

      IF @cSerialNoKey <> ''
      BEGIN      
         UPDATE SerialNo WITH (ROWLOCK)
         SET Qty = IIF(@cStatus = '1', Qty + @nQty, @nQty)
           , [Status] = IIF(@cStatus = '1', [Status], '1')
           , EditDate = GETDATE()
           , EditWho = @cUserName
         WHERE SerialNoKey = @cSerialNoKey

         IF @@ERROR <> 0       
         BEGIN       
            SET @n_Err = 1003207      
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'Fail to Update SerialNo table. Function : isp_TPS_ExtUpd11'      
            GOTO RollBackTran      
         END  
      END      
      ELSE
      BEGIN   
         EXECUTE dbo.nspg_GetKey
               'SerialNo',
               10 ,
               @cSerialNoKey  OUTPUT,
               @b_Success     OUTPUT,
               @n_Err         OUTPUT,
               @c_ErrMsg      OUTPUT

         IF @b_Success <> 1
         BEGIN
            SET @n_Err = 1003212
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpd11'
            GOTO RollBackTran
         END

         INSERT INTO SerialNo (SerialNoKey, OrderKey, OrderLineNumber, StorerKey, SKU, SerialNo, Qty, status,LabelLine,Cartonno,pickslipno ,AddWho,AddDate,EditWho,EditDate)         
         VALUES ( @cSerialNoKey, '', '', @cStorerKey, @cSKU , @cFirstValue , @nQty, '1','','','',@cUserName,GETDATE(),@cUserName,GETDATE() )         
  
         IF @@ERROR <> 0         
         BEGIN         
            SET @n_Err = 1003208        
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to Insert SerialNo table. Function : isp_TPS_ExtUpd11'        
            GOTO RollBackTran        
         END            
      END

      INSERT INTO PackSerialNo(pickslipno,cartonno,labelno,labelline,storerkey,SerialNo,sku,qty, PickDetailKey,AddWho,AddDate,EditWho,EditDate)    
      VALUES(@cpickslipno,@nCartonNo,@cLabelNo,@cLblLineNumber,@cStorerKey,@cFirstValue,@csku,@nQty, '', @cUserName,GETDATE(),@cUserName,GETDATE())    
    
      IF @@ERROR <> 0       
      BEGIN 
         SET @n_Err = 1003209      
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'Fail to Insert PackSerialNo table. Function : isp_TPS_ExtUpd11'      
         GOTO RollBackTran      
      END

      UPDATE PACKDETAIL WITH (ROWLOCK)
      SET UPC = @cSecondValue
        , EditWho = @cUserName
        , EditDate =GETDATE()
        , ArchiveCop = NULL
      WHERE PickSlipNo = @cpickslipNo
      AND CartonNo = @nCartonNo
      AND LabelNo = @cLabelNo
      AND LabelLine = @cLblLineNumber

      IF @@ERROR <> 0       
      BEGIN 
         SET @n_Err = 1003211      
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 'Fail to Update the PackDetail table. Function : isp_TPS_ExtUpd11'      
         GOTO RollBackTran      
      END

NEXTITEM:
      FETCH NEXT FROM @curAD INTO @cSKU, @cSkuBarcode, @cADCode, @cSUSR4, @cSerialNoCapture, @nQty
   END 
   CLOSE @curAD
   DEALLOCATE @curAD

SET @b_Success = 1
GOTO Quit 
     
 RollBackTran:    
      ROLLBACK TRAN isp_TPS_ExtUpd11    
    
   Quit:    
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
      BEGIN
         COMMIT TRAN isp_TPS_ExtUpd11     
      END
END      
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_ExtUpd11 TO NSQL
GO


