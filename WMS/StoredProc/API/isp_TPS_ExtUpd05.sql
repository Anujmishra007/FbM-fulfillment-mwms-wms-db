SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
 
/******************************************************************************/        
/* Store procedure: isp_TPS_ExtUpd05                                          */        
/* Copyright      : LFLogistics                                               */        
/*                                                                            */        
/* Date         Rev  Author     Purposes                                      */        
/* 2025-01-21   1.0  yeekung    TPS-970 Created                               */
/* 2026-04-20   2.0  GCH225     FCR-11777 Created                            */  
/******************************************************************************/        
        
CREATE OR ALTER  PROC [API].[isp_TPS_ExtUpd05] (        
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
         
DECLARE  @cJITOrders       NVARCHAR(20)
       , @nPickslipPackQty INT
       , @nPickslipPickQty INT
       , @cCartonNo        NVARCHAR(5)
       , @nTranCount       INT
       , @bSuccess         INT
       , @b_Debug          INT

DECLARE @cTransmitLogKey   NVARCHAR(20)
      , @c_QCmdClass       NVARCHAR(10) = ''  
      , @cUPCEPC           NVARCHAR(100)
      , @cLblLineNumber    NVARCHAR(10)
      , @cSKU              NVARCHAR(30)
      , @c_UPC         NVARCHAR(100)
      , @c_EPC         NVARCHAR(100)
      , @c_Separator       NVARCHAR(5)
      , @n_Position        INT

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
    
DECLARE @pickSKUDetail TABLE (  
   SKU              NVARCHAR( 30),    
   QtyToPack        INT,  
   OrderKey         NVARCHAR( 30),  
   PickslipNo       NVARCHAR( 30),  
   LoadKey          NVARCHAR( 30),--externalOrderKey  
   PickDetailStatus NVARCHAR ( 3)  
)  

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

INSERT INTO @pickSKUDetail  
SELECT *  
FROM OPENJSON(@pickSkuDetailJson)  
WITH (  
   SKU               NVARCHAR( 20)  '$.SKU',  
   QtyToPack         INT            '$.QtyToPack',  
   OrderKey          NVARCHAR( 10)  '$.OrderKey',  
   PickslipNo        NVARCHAR( 30)  '$.PickslipNo',  
   LoadKey           NVARCHAR( 10)  '$.LoadKey',  
   PickDetailStatus  NVARCHAR( 1)   '$.PickDetailStatus'  
)  
       
--SELECT 'aa',* FROM @CloseCtnList      
BEGIN      
   SET @nTranCount = @@TRANCOUNT      
   BEGIN TRAN      
   SAVE TRAN isp_TPS_ExtUpd05   

   SELECT @cOrderKey = OrderKey
   FROM PickHeader (NOLOCK)
   WHERE PickHeaderkey = @cPickSlipNo

   SELECT @c_Separator = NULLIF(RTRIM(Option1), '')
   FROM StorerConfig WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey 
   AND ConfigKey = 'SKUDecode';

   IF NOT EXISTS (SELECT 1 
                  FROM @CloseCtnList 
                  WHERE (SkuBarcode <> '' OR ADCode <> ''))
   OR @c_Separator = ''
   BEGIN
      GOTO SkipEPC
   END
   
   DECLARE CUR_PSN CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
   SELECT SKU, ISNULL(SkuBarcode, ADCode) AS SkuBarcode    
   FROM @CloseCtnList      
   WHERE (SkuBarcode <> '' OR ADCode <> '') 
   AND CHARINDEX(';', ISNULL(SkuBarcode, ADCode)) > 0 -- Only process those with ';' in barcode
      
   OPEN CUR_PSN      
   FETCH NEXT FROM CUR_PSN INTO @cSKU, @cUPCEPC     
   WHILE @@FETCH_STATUS <> -1      
   BEGIN 
      SET @c_UPC = ''
      SET @c_EPC = ''
      SET @n_Position = CHARINDEX(@c_Separator, @cUPCEPC)

      IF @n_Position<= 0
      BEGIN
         GOTO NEXTITEM
      END

      SET @c_UPC = LEFT(@cUPCEPC, @n_Position - 1)
      SET @c_EPC = SUBSTRING(@cUPCEPC, @n_Position + LEN(@c_Separator), LEN(@cUPCEPC));

      IF EXISTS ( SELECT 1
                  FROM PACKSERIALNO (NOLOCK)
                  WHERE PickSlipNo = @cPickSlipNo
                  AND StorerKey  = @cStorerKey
                  AND SerialNo   = @c_EPC
      )
      BEGIN
         SET @b_Success = 0;
         SET @n_Err = 90031;
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP')  --' EPC already scanned (ispSKUDCPA02)';
         GOTO RollBackTran;
      END

      SELECT  @cLblLineNumber = LabelLine
            , @cLabelNo = LabelNo
      FROM PACKDETAIL (NOLOCK)
      WHERE StorerKey = @cStorerKey        
      AND PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      AND SKU = @cSKU   
      
      INSERT INTO PACKSERIALNO( PickSlipNo
                              , CartonNo
                              , LabelNo
                              , LabelLine
                              , StorerKey
                              , SKU
                              , SerialNo
                              , Qty
                              , Barcode
                              , AddWho
                              , AddDate
                              , EditWho
                              , EditDate)    
                        VALUES( @cPickSlipNo
                              , @nCartonNo
                              , @cLabelNo
                              , @cLblLineNumber
                              , @cStorerKey
                              , @cSKU
                              , @c_EPC
                              , 1
                              , @cUPCEPC
                              , @cUserName
                              , GETDATE()
                              , @cUserName
                              , GETDATE())  

      IF @@ERROR <> 0         
      BEGIN         
         SET @b_Success = 0;
         SET @n_Err = 1003451        
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'Failed to insert into PACKSERIALNO table. Function : isp_TPS_ExtUpd05
         GOTO RollBackTran        
      END  
      
NEXTITEM:
      FETCH NEXT FROM CUR_PSN INTO @cSKU, @cUPCEPC        
   END
   CLOSE CUR_PSN;
   DEALLOCATE CUR_PSN;

SkipEPC:

   EXEC nspGetRight    
      @c_Facility   = @cFacility   
   ,  @c_StorerKey  = @cStorerKey   
   ,  @c_sku        = ''    
   ,  @c_ConfigKey  = 'TPS-JITOrders'    
   ,  @b_Success    = @b_Success       OUTPUT    
   ,  @c_authority  = @cJITOrders      OUTPUT    
   ,  @n_err        = @n_Err           OUTPUT    
   ,  @c_errmsg     = @c_ErrMsg        OUTPUT  
   
   IF ISNULL(@cJITOrders,'') = '1'
   BEGIN
      IF NOT EXISTS (SELECT 1
                     FROM Transmitlog2 (NOLOCK)
                     WHERE TableName = 'WSCRSOLBLJTV2'
                        AND Key1 = @cOrderkey 
                        AND Key2 = (@nCartonNo + 1)
                        AND Key3 = @cStorerKey)
      BEGIN
         SELECT @nPickslipPackQty = ISNULL(SUM(PD.Qty),0)   
         FROM PackDetail PD WITH (NOLOCK)   
         JOIN packInfo PKI WITH (NOLOCK) ON (PD.PickSlipNo = PKI.PickSlipNo AND PD.CartonNo = PKI.CartonNo)  
         WHERE PD.pickslipno = @cPickSlipNo 
            AND PD.Storerkey = @cStorerKey 
            AND PKI.CartonStatus = 'Closed'  
         
         SELECT @nPickslipPickQty = SUM(QtyToPack) 
         FROM @pickSKUDetail 
         WHERE pickslipNo = @cPickSlipNo  

         IF @nPickslipPackQty <> @nPickslipPickQty
         BEGIN
            SET @cCartonNo = CAST(@nCartonNo + 1 AS NVARCHAR(5) )

            -- Insert transmitlog2 here  
            EXECUTE ispGenTransmitLog2   
               @c_TableName      = 'WSCRSOLBLJTV2',   
               @c_Key1           = @cOrderKey,   
               @c_Key2           = @cCartonNo,   
               @c_Key3           = @cStorerkey,   
               @c_TransmitBatch  = '',   
               @b_Success        = @bSuccess      OUTPUT,      
               @n_err            = @n_Err         OUTPUT,      
               @c_errmsg         = @c_ErrMsg    OUTPUT      
      
            IF @bSuccess <> 1      
               GOTO QUIT  
      
            SELECT @cTransmitLogKey = transmitlogkey  
            FROM dbo.TRANSMITLOG2 WITH (NOLOCK)  
            WHERE tablename = 'WSCRSOLBLJTV2'  
               AND   key1 = @cOrderKey
               AND   key2 = @cCartonNo
               AND   key3 = @cStorerkey  

            EXEC dbo.isp_QCmd_WSTransmitLogInsertAlert   
               @c_QCmdClass         = @c_QCmdClass,   
               @c_FrmTransmitlogKey = @cTransmitLogKey,   
               @c_ToTransmitlogKey  = @cTransmitLogKey,   
               @b_Debug             = @b_Debug,   
               @b_Success           = @bSuccess         OUTPUT,   
               @n_Err               = @n_Err            OUTPUT,   
               @c_ErrMsg            = @c_ErrMsg         OUTPUT   

            IF @bSuccess <> 1      
               GOTO QUIT  
                  
         END

      END
   END

   GOTO Quit      
       
 RollBackTran:      
      ROLLBACK TRAN isp_TPS_ExtUpd05      
      
   Quit:      
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started    
      BEGIN  
         COMMIT TRAN isp_TPS_ExtUpd05      
         SET @b_Success = '1'    
      END  
      
END        
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_ExtUpd05 TO NSQL
GO