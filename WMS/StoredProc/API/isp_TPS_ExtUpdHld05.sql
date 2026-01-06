SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

    
/*******************************************************************************/      
/* Store procedure: isp_TPS_ExtUpdHld05                                        */      
/* Copyright      : Maersk                                                     */      
/*                                                                             */  
/* Description    : This Extended Update Hold Carton SP is mainly update the   */ 
/*                  Hold carton that contains AD Barcode only. It will not     */ 
/*                  support for update the non AD Barcode value.               */
/*                  And this SP is only for old method, which will add the     */
/*                  transactional data into SerialNo Table.                    */
/*                                                                             */ 
/* Date         Rev  Author     Purposes                                       */      
/* 2025-06-16   1.1  GCH225     FCR-4548 Modified based on isp_TPS_ExtUpdHld03 */    
/*******************************************************************************/      
      
CREATE OR ALTER PROC [API].[isp_TPS_ExtUpdHld05] (      
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
    
DECLARE @curSerialNo CURSOR    
DECLARE     
   @cSKU             NVARCHAR(20), 
   @cSkuBarcode      NVARCHAR(60),    
   @cOrderLineNumber NVARCHAR(5),
   @cLabelLine   NVARCHAR(5),
   @cWeight          NVARCHAR(10),    
   @cCube            NVARCHAR(10),    
   @cLottableVal     NVARCHAR(20),    
   @cSerialNoKey     NVARCHAR(60),    
   @cADCode          NVARCHAR(60),    
   @nQty             INT,  
   @bsuccess         INT,    
   @nTranCount       INT,
   @cPickDetailKey   NVARCHAR(18),  
   @cCurOrderkey     NVARCHAR(20),
   @cSerialNo        NVARCHAR(50)

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
   SAVE TRAN isp_TPS_ExtUpdHld05     
    
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
      SET @n_Err = 1003101        
      SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'OrderKey or LoadKey Not Found. Failed to proceed to update the SerialNo/PackSerialNo. Function : isp_TPS_ExtUpdHld05'        
      GOTO RollBackTran       
   END   

   IF NOT EXISTS (SELECT 1 FROM CODELKUP WITH (NOLOCK) WHERE Listname = 'REQEXP'AND Code ='ADBARCODE' AND storerKey = @cStorerKey)    
   BEGIN    
      SET @b_Success = 0
      SET @n_Err = 1003102      
      SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP')-- 'Codelkup ListName(REQEXP) and Code(ADBARCODE) not found. Function : isp_TPS_ExtUpdHld05'      
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
         SET @n_Err = 1003103      
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'No SkuBarcode or ADBarcode found. Function : isp_TPS_ExtUpdHld05'      
         GOTO RollBackTran   
      END

      IF LEN(@cSerialNo) < 5
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 1003104
	      SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') --'Error: Serial No must be at least 5 characters long. Function : isp_TPS_ExtUpdHld05'
         GOTO RollBackTran 
      END

       IF LEFT(@cSerialNo, 2) = '00'
      BEGIN
         SET @cSerialNo = SUBSTRING(@cSerialNo, 3, LEN(@cSerialNo))
      END

      IF LEN(@cSerialNo) > 18
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 1003105
	      SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') --'Error: Serial No must not be more than 18 characters long. Function : isp_TPS_ExtUpdHld05'
         GOTO RollBackTran 
      END

      IF EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSerialNo)
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 1003106
	      SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') --'Error: Serial No cannot be same as SKU code. Function : isp_TPS_ExtUpdHld05'
         GOTO RollBackTran
      END

      IF EXISTS (SELECT 1 FROM PackSerialNo (NOLOCK) 
      WHERE StorerKey = @cStorerKey 
      AND SerialNo = @cSerialNo
      AND PickSlipNo = @cPickSlipNo
      )
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 1003107
	      SET @c_ErrMsg = '(' + @cSerialNo + ')' + API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') --'Error: Serial No already been packed in PackSerialNo. Function : isp_TPS_ExtUpdHld05'
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
         SET @n_Err = 1003108
	      SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') --'Error: Serial No been used in SerialNo table. Function : isp_TPS_ExtUpdHld05'
         GOTO RollBackTran
      END

      SELECT @cLabelLine = PD.LabelLine ,
             @cDropID = CASE WHEN ISNULL(PD.DropID,'') = '' THEN RTRIM(ISNULL(@cDropID,'')) ELSE  RTRIM(ISNULL(PD.DropID,'')) END 
      FROM dbo.Packheader PH WITH (NOLOCK)    
         JOIN dbo.packdetail PD(nolock) ON PH.PickSlipNo=PD.PickSlipNo
      WHERE PH.StorerKey = @cStorerKey      
         AND PH.PickSlipNo = @cPickSlipNo
         AND PD.SKU = @cSKU
         AND PD.Cartonno = @nCartonNo

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
         SET @n_Err = 1003109
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpdHld05'
         GOTO RollBackTran
      END

      INSERT INTO SerialNo (SerialNoKey,Orderkey, Orderlinenumber, StorerKey, SKU, SerialNo, Qty,pickslipno,CartonNo,status,AddWho,AddDate,EditWho,EditDate)
      VALUES ( @cSerialNoKey,'','', @cStorerKey, @cSKU, @cSerialNo, 1, '', '', '1', @cUserName, GETDATE(), @cUserName, GETDATE())

      IF @@ERROR <> 0
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 1003110
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail Insert SerialNO Function : isp_TPS_ExtUpdHld05' 
         GOTO RollBackTran
      END
         
      INSERT INTO PackSerialNo(Pickslipno,cartonno,labelno,labelline,storerkey,sku,serialno,qty,PickDetailKey,Barcode,AddWho,AddDate,EditWho,EditDate)    
      values(@cPickSlipNo,@nCartonNo,@cLabelNo,@cLabelLine,@cStorerKey,@cSKU,@cSerialNo,1,ISNULL(@cPickDetailKey,''),@cADCode,@cUserName,GETDATE(),@cUserName,GETDATE())    
    
      IF @@ERROR <> 0
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 1003111
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail Insert PackSerialNo Function : isp_TPS_ExtUpdHld05' 
         GOTO RollBackTran
      END  

NEXTITEM:
      FETCH NEXT FROM @curSerialNo INTO @cSKU, @cSkuBarcode, @cADCode
   END

   CLOSE @curSerialNo;
   DEALLOCATE @curSerialNo;

   GOTO Quit    
     
RollBackTran:    
   ROLLBACK TRAN isp_TPS_ExtUpdHld05    
    
Quit:    
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
   BEGIN
      COMMIT TRAN isp_TPS_ExtUpdHld05     
   END
END    

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_ExtUpdHld05 TO NSQL
GO