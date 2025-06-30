SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

    
/******************************************************************************/      
/* Store procedure: isp_TPS_ExtUpdHld03                                       */      
/* Copyright      : Maersk                                                    */      
/*                                                                            */  
/* Description    : This Extended Update Hold Carton SP is mainly update the  */ 
/*                  Hold carton that contains AD Barcode only. It will not    */ 
/*                  support for update the non AD Barcode value.              */ 
/*                                                                            */ 
/* Date         Rev  Author     Purposes                                      */      
/* 2025-05-22   1.1  GhChan    Revamp based on isp_TPS_ExtUpdHld01            */    
/******************************************************************************/      
      
CREATE OR ALTER PROC [API].[isp_TPS_ExtUpdHld03] (      
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
   @cSKU             NVARCHAR(20), 
   @cSkuBarcode      NVARCHAR(60),    
   @cOrderLineNumber NVARCHAR(5),
   @cLblLineNumber   NVARCHAR(5),
   @cWeight          NVARCHAR(10),    
   @cCube            NVARCHAR(10),    
   @cLottableVal     NVARCHAR(20),    
   @cSerialNoKey     NVARCHAR(60),    
   @cADCode          NVARCHAR(60),    
   @nQty             INT,  
   @bsuccess         INT,    
   @nTranCount       INT,
   @cPickDetailKey   NVARCHAR(18)

DECLARE @cOtherUnit2    INT
       
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
--FROM OPENJSON(@cHoldCartonJson)    
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
FROM OPENJSON(@cHoldCartonJson)    
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
   SAVE TRAN isp_TPS_ExtUpdHld03     
    
   IF ISNULL(@cOrderKey,'') = '' AND ISNULL(@cLoadKey,'') = ''
   BEGIN    
      SET @b_Success = 0
      SET @n_Err = 1001801      
      SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'OrderKey not Found. Failed to proceed to update the SerialNo/PackSerialNo. Function : isp_TPS_ExtUpdHld03'      
      GOTO RollBackTran      
   END    

   IF NOT EXISTS (SELECT 1 FROM CODELKUP WITH (NOLOCK) WHERE Listname = 'REQEXP'AND Code ='ADBARCODE' AND storerKey = @cStorerKey)    
   BEGIN    
      SET @b_Success = 0
      SET @n_Err = 1001802      
      SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP')-- 'Codelkup ListName(REQEXP) and Code(ADBARCODE) not found. Function : isp_TPS_ExtUpdHld03'      
      GOTO RollBackTran        
   END

   SET @curAD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
   SELECT SKU, ISNULL(ADCode,'')  
   FROM @CloseCtnList    
   WHERE  ADCode <> ''
       
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
         SET @n_Err = 1001810      
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'PackOtherUnit2 cannot be less than 1. Function : isp_TPS_ExtUpdHld03'      
         GOTO RollBackTran 
      END

      SELECT   @cLblLineNumber = PD.LabelLine,  
               @cLabelNo = labelno,
               @cDropID = RTRIM(PD.DropID)
      FROM dbo.Packheader PH WITH (NOLOCK)    
         JOIN dbo.packdetail PD(nolock) ON PH.PickSlipNo=PD.PickSlipNo  
      WHERE PD.StorerKey = @cStorerKey        
         AND (@cOrderKey = '' OR PH.OrderKey = @cOrderKey)
         AND (@cLoadKey = '' OR PH.LoadKey = @cLoadKey)
         AND PD.SKU = @cSKU   
         AND Cartonno = @nCartonNo

      SELECT @cPickDetailKey = PD.PickDetailKey
      FROM dbo.PickDetail PD WITH (NOLOCK)
         JOIN Orders O WITH (NOLOCK) 
         ON PD.Orderkey = O.Orderkey AND PD.Storerkey = O.Storerkey
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

      SET @cSerialNoKey = ''

      SELECT  @cSerialNoKey = SerialNoKey
         FROM SerialNo (NOLOCK)
         WHERE StorerKEy = @cStorerKey      
         AND OrderKey = ''      
         AND SKU = @cSKU      
         AND SerialNo = @cADCode 
         AND [Status] = '1'

      --Insert/Update SerialNo 
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
            SET @n_Err = 1001804      
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') --'Failed to insert SerialNo into PackSerialNo Table. Records already exists. Function : isp_TPS_ExtUpdHld03'      
            GOTO RollBackTran
         END  

         INSERT INTO PackSerialNo(pickslipno,cartonno,labelno,labelline,storerkey,sku,serialno,qty, PickDetailKey,AddWho,AddDate,EditWho,EditDate)    
         values(@cpickslipNo,@nCartonNo,@cLabelNo,@cLblLineNumber,@cStorerKey,@csku,@cADCode,@nQty, ISNULL(@cPickDetailKey,''),@cUserName,GETDATE(),@cUserName,GETDATE())    
    
         IF @@ERROR <> 0       
         BEGIN    
            SET @b_Success = 0
            SET @n_Err = 1001803      
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Failed to insert SerialNo into PackSerialNo Table. Function : isp_TPS_ExtUpdHld03'      
            GOTO RollBackTran      
         END 

         EXECUTE dbo.nspg_GetKey      
                  'SerialNo',      
                  10 ,      
                  @cSerialNoKey      OUTPUT,      
                  @bsuccess          OUTPUT,      
                  @n_Err            OUTPUT,      
                  @c_ErrMsg           OUTPUT      
                     
         IF @bsuccess <> 1      
         BEGIN      
            SET @b_Success = 0
            SET @n_Err = 1001805      
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpdHld03'      
            GOTO RollBackTran      
         END  

         INSERT INTO SerialNo (SerialNoKey, OrderKey, OrderLineNumber, StorerKey, SKU, SerialNo, Qty, status,AddWho,AddDate,EditWho,EditDate )       
         VALUES ( @cSerialNoKey, '', '', @cStorerKey, @cSKU , @cADCode , @nQty, '1' ,@cUserName,GETDATE(),@cUserName,GETDATE())       

         IF @@ERROR <> 0       
         BEGIN       
            SET @b_Success = 0
            SET @n_Err = 1001806      
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to Insert SerialNo table. Function : isp_TPS_ExtUpdHld03'      
            GOTO RollBackTran      
         END      
      END      
      ELSE     
      BEGIN
         
         --IF @@ROWCOUNT = 0
         --BEGIN
         --   SET @b_Success = 0
         --   SET @n_Err = 1001811      
         --   SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Failed to get the existing SerialNoKey from SerialNo Table. Records already been in used. Function : isp_TPS_ExtUpdHld03'
         --   GOTO RollBackTran
         --END

         --Insert/Update PackSerialNo
         IF EXISTS(select 1 from PackSerialNo (NOLOCK)    
                  where PickSlipNo=@cpickslipNo    
                  and storerkey=@cStorerKey    
                  and sku=@csku
                  and serialno=@cADCode)    
         BEGIN
             GOTO NEXTITEM  -- PackSerialNo Exists then proceed the next records because the frontend return all the same AD for the each SKU during close carton.
            --SET @b_Success = 0
            --SET @n_Err = 1001808      
            --SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Failed to insert SerialNo into PackSerialNo Table. Records already exists. Function : isp_TPS_ExtUpdHld03'
            --GOTO RollBackTran
         END  

         INSERT INTO PackSerialNo(pickslipno,cartonno,labelno,labelline,storerkey,sku,serialno,qty, PickDetailKey,AddWho,AddDate,EditWho,EditDate)    
         values(@cpickslipNo,@nCartonNo,@cLabelNo,@cLblLineNumber,@cStorerKey,@csku,@cADCode,@nQty, ISNULL(@cPickDetailKey,''),@cUserName,GETDATE(),@cUserName,GETDATE())    
    
         IF @@ERROR <> 0       
         BEGIN    
            SET @b_Success = 0
            SET @n_Err = 1001807      
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Failed to Insert SerialNo into PackSerialNo Table. Function : isp_TPS_ExtUpdHld03'
            GOTO RollBackTran      
         END 

         UPDATE SerialNo WITH (ROWLOCK) 
         SET STATUS = '1' ,  
            EditDate = GETDATE(),  
            EditWho = @cUserName   
         WHERE SerialNoKey = @cSerialNoKey
                      
         IF @@ERROR <> 0       
         BEGIN       
            SET @b_Success = 0;
            SET @n_Err = 1001809      
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to Update SerialNo table. Function : isp_TPS_ExtUpdHld03'      
            GOTO RollBackTran      
         END      
      END

NEXTITEM:
      FETCH NEXT FROM @curAD INTO @cSKU, @cADCode    
   END

 GOTO Quit    
     
RollBackTran:    
   ROLLBACK TRAN isp_TPS_ExtUpdHld03    
    
Quit:    
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
   BEGIN
      COMMIT TRAN isp_TPS_ExtUpdHld03     
   END
END    

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_ExtUpdHld03 TO NSQL
GO