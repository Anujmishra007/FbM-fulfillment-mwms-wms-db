SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtPreUpd03                                        */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Extended Pre Update the PackSerialNo or SerialNo or etc.     */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-12-05   1.0  Sean       Cloned from isp_TPS_ExtUpd03                     */
/* 2026-03-27   1.1  JWF011     UWP-52830: Fix logic                             */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtPreUpd03] (
	  @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @cInputValue1         NVARCHAR(128)     = ''
   , @cInputValue2         NVARCHAR(MAX)     = ''
   , @cInputValue3         NVARCHAR(128)     = ''
   , @cScanType            NVARCHAR(20)      = ''
   , @cSKU                 NVARCHAR(20)      = ''
   , @nCartonNo            INT               = 0
   , @cLabelNo             NVARCHAR(20)      = ''
   , @cLabelLine           NVARCHAR(20)      = ''
   , @nQty                 INT               = 0       
   , @c_UserID             NVARCHAR(256)     = ''  
   , @cLangCode            NVARCHAR(3)       = ''
   , @b_Success            INT               = 0   OUTPUT
   , @n_ErrNo              INT               = 0   OUTPUT
   , @c_ErrMsg             NVARCHAR(250)     = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue        INT            = 1  
         , @n_StartCnt        INT            = @@TRANCOUNT  

   DECLARE @cSerialNoKey      NVARCHAR(10)
         , @cSerialNo         NVARCHAR(50)  
         , @cOrderLineNumber  NVARCHAR(5)
         , @cLblLineNumber    NVARCHAR(5)
         , @cCurOrderKey      NVARCHAR(20)
         , @cUCCNo            NVARCHAR(30)
         , @nSNQTY            INT
         , @nRemainQty        INT
         , @cDuplicateVal     NVARCHAR(1000)

   DECLARE @CURSOR_AD CURSOR
   DECLARE @cList TABLE (
      cSerialNo   NVARCHAR(100)
   )

   SET @b_Success         = 0  
   SET @n_ErrNo           = 0  
   SET @c_ErrMsg          = ''
   SET @cSerialNoKey      = ''
   SET @cSerialNo         = ''
   SET @cOrderLineNumber  = ''
   SET @cDuplicateVal     = ''

   -- Get current OrderKey from PickHeader if not provided
   SELECT @cCurOrderKey = OrderKey  
   FROM PICKHEADER (NOLOCK)  
   WHERE PickHeaderKey = @cPickSlipNo  
  
   IF ISNULL(@cCurOrderKey, '') <> ''  
      SET @cOrderKey = @cCurOrderKey  

   -- Check if this is UCC mode
   IF @cScanType = 'ucc'
   AND EXISTS (SELECT 1 
               FROM SKU S (NOLOCK)
               INNER JOIN PACK P (NOLOCK)
               ON S.PackKey = P.PackKey
               WHERE S.StorerKey = @cStorerKey
               AND S.SKU = @cSKU
               AND S.SerialNoCapture = '1'
               AND P.OtherUnit2 = 1
              )
   BEGIN    
      SET @cUCCNo = @cInputValue1
      SET @nRemainQty = @nQty

      UPDATE UCC WITH (ROWLOCK)  
      SET   Status = '6',
            EditDate = GETDATE(),  
            EditWho = @c_UserID    
      WHERE UCCNo = @cUCCNo  
         AND SKU = @cSKU 
         AND StorerKey = @cStorerKey  
  
      SET @CURSOR_AD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
      SELECT SerialNoKey, SUM(Qty) 
      FROM SERIALNO (NOLOCK)      
      WHERE SKU = @cSKU  
      AND UserDefine01 = @cUCCNo  
      AND StorerKey = @cStorerKey  
      AND Status IN ('0', '1') 
      GROUP BY SerialNoKey
      ORDER BY SerialNoKey  
  
      OPEN @CURSOR_AD      
      FETCH NEXT FROM @CURSOR_AD INTO @cSerialNoKey, @nSNQTY    
      WHILE @@FETCH_STATUS = 0      
      BEGIN    
         SELECT @cLblLineNumber = PD.LabelLine  
              , @cLabelNo = PD.LabelNo  
         FROM dbo.PackHeader PH (NOLOCK)
         JOIN dbo.PackDetail PD (NOLOCK) 
         ON PH.PickSlipNo = PD.PickSlipNo  
         WHERE PD.StorerKey = @cStorerKey        
         AND PH.PickSlipNo = @cPickSlipNo        
         AND PD.CartonNo = @nCartonNo 
         AND PD.SKU = @cSKU   
  
         SELECT @cOrderLineNumber = PD.OrderLineNumber           
         FROM dbo.PickDetail PD (NOLOCK)        
         WHERE PD.StorerKey = @cStorerKey        
         AND PD.OrderKey = @cOrderKey        
         AND PD.SKU = @cSKU         
         AND NOT EXISTS (SELECT 1 
                         FROM dbo.SerialNo S (NOLOCK)         
                         WHERE S.OrderKey = PD.OrderKey        
                         AND S.OrderLineNumber = PD.OrderLineNumber        
                         AND S.SKU = PD.SKU)   
  
         IF ISNULL(@cOrderLineNumber, '') = ''  
         BEGIN  
            SELECT TOP 1 @cOrderLineNumber = PD.OrderLineNumber           
            FROM dbo.PickDetail PD (NOLOCK)        
            WHERE PD.StorerKey = @cStorerKey        
            AND PD.OrderKey = @cOrderKey        
            AND PD.SKU = @cSKU       
         END  
              
         SELECT @cSerialNo = SerialNo
         FROM dbo.SerialNo (NOLOCK) 
         WHERE SerialNoKey = @cSerialNoKey
  
         INSERT INTO PACKSERIALNO (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, SerialNo, Qty, AddWho, AddDate, EditWho, EditDate)  
         VALUES (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLblLineNumber, @cStorerKey, @cSKU, @cSerialNo, 1, @c_UserID, GETDATE(), @c_UserID, GETDATE())  

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 14410
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') --'Failed to Insert into PackSerialNo.'
            GOTO EXIT_SP
         END
                                               
         UPDATE SerialNo WITH (ROWLOCK) SET      
            OrderKey = @cOrderKey,       
            OrderLineNumber = ISNULL(@cOrderLineNumber, ''),  
            LabelLine = @cLblLineNumber,  
            CartonNo = @nCartonNo,  
            PickSlipNo = @cPickSlipNo,  
            TrafficCop = NULL,  
            Status = '1',
            EditDate = GETDATE(),  
            EditWho = @c_UserID   
         WHERE SerialNoKey = @cSerialNoKey  

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 14411
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') --'Failed to Update SerialNo.'
            GOTO EXIT_SP
         END
  
         SET @nRemainQty = @nRemainQty - @nSNQTY  

         IF @nRemainQty = 0   
            BREAK;  
  
         FETCH NEXT FROM @CURSOR_AD INTO @cSerialNoKey, @nSNQTY 
      END  
      CLOSE @CURSOR_AD
      DEALLOCATE @CURSOR_AD

      IF @nRemainQty <> 0  
      BEGIN        
         SET @n_Continue = 3
         SET @n_ErrNo = 14401      
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') -- 'Quantity Not Match.'        
         GOTO EXIT_SP        
      END     
   END  
   ELSE  
   BEGIN  
      -- Non-UCC mode: process serial numbers from @cInputValue2 JSON array
      IF ISJSON(@cInputValue2) = 0
      OR @cInputValue2 = ''
      BEGIN
         GOTO EXIT_SP
      END

      IF @cOrderKey = ''      
      BEGIN  
         SET @n_Continue = 3
         SET @n_ErrNo = 14402      
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') -- 'OrderKey cannot be empty.'   
         GOTO EXIT_SP     
      END  

      -- Insert serial numbers from JSON array
      INSERT INTO @cList (cSerialNo)
      SELECT [value]
      FROM OPENJSON(@cInputValue2)
      WITH ([value] NVARCHAR(100) '$') J

      -- Check for duplicates
      SELECT @cDuplicateVal = STRING_AGG(D.cSerialNo, ', ') 
      FROM (
         SELECT cSerialNo 
         FROM @cList
         GROUP BY cSerialNo
         HAVING COUNT(1) > 1
      ) AS D

      IF LEN(@cDuplicateVal) > 1
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 14404      
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') + '(' + @cDuplicateVal + ')' -- 'One or more duplicate serial numbers were detected.'      
         GOTO EXIT_SP 
      END

      SET @CURSOR_AD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
      SELECT cSerialNo    
      FROM @cList      
      WHERE cSerialNo <> ''      
         
      OPEN @CURSOR_AD      
      FETCH NEXT FROM @CURSOR_AD INTO @cSerialNo     
      WHILE @@FETCH_STATUS = 0      
      BEGIN      
         SELECT @cLblLineNumber = PD.LabelLine
              , @cLabelNo = PD.LabelNo 
         FROM dbo.PackHeader PH (NOLOCK)
         JOIN dbo.PackDetail PD (NOLOCK) 
         ON PH.PickSlipNo = PD.PickSlipNo  
         WHERE PD.StorerKey = @cStorerKey        
         AND PH.PickSlipNo = @cPickSlipNo        
         AND PD.CartonNo = @nCartonNo 
         AND PD.SKU = @cSKU  

         SELECT @cOrderLineNumber = PD.OrderLineNumber         
         FROM dbo.PickDetail PD (NOLOCK)        
         WHERE PD.StorerKey = @cStorerKey        
         AND PD.OrderKey = @cOrderKey        
         AND PD.SKU = @cSKU         
         AND NOT EXISTS (SELECT 1 
                         FROM dbo.SerialNo S (NOLOCK)         
                         WHERE S.OrderKey = PD.OrderKey        
                         AND S.OrderLineNumber = PD.OrderLineNumber        
                         AND S.SKU = PD.SKU)  

         IF ISNULL(@cOrderLineNumber, '') = ''  
         BEGIN  
            SELECT TOP 1 @cOrderLineNumber = PD.OrderLineNumber           
            FROM dbo.PickDetail PD (NOLOCK)        
            WHERE PD.StorerKey = @cStorerKey        
            AND PD.OrderKey = @cOrderKey        
            AND PD.SKU = @cSKU       
         END 

         SET @cSerialNoKey = ''

         SELECT @cSerialNoKey = SerialNoKey
         FROM dbo.SerialNo (NOLOCK) 
         WHERE StorerKey = @cStorerKey 
         AND SKU = @cSKU 
         AND SerialNo = @cSerialNo

         IF @@ROWCOUNT = 0
         BEGIN        
            EXECUTE dbo.nspg_GetKey        
                     'SerialNo',        
                     10 ,        
                     @cSerialNoKey  OUTPUT,        
                     @b_Success     OUTPUT,        
                     @n_ErrNo       OUTPUT,        
                     @c_ErrMsg      OUTPUT        
                       
            IF @b_Success <> 1        
            BEGIN        
               SET @n_Continue = 3
               SET @n_ErrNo = 14405        
               SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') -- 'Failed to get SerialNo Key.'        
               GOTO EXIT_SP        
            END        
                                                 
            INSERT INTO SERIALNO (SerialNoKey, OrderKey, OrderLineNumber, StorerKey, SKU, SerialNo, Qty, Status, LabelLine, CartonNo, PickSlipNo, AddWho, AddDate, EditWho, EditDate)         
            VALUES (@cSerialNoKey, @cOrderKey, ISNULL(@cOrderLineNumber, ''), @cStorerKey, @cSKU, @cSerialNo, @nQty, '1', @cLabelLine, @nCartonNo, @cPickSlipNo, @c_UserID, GETDATE(), @c_UserID, GETDATE())         
  
            IF @@ERROR <> 0         
            BEGIN         
               SET @n_Continue = 3
               SET @n_ErrNo = 14406        
               SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') -- 'Failed to Insert into SerialNo.'        
               GOTO EXIT_SP        
            END        
         END        
         ELSE   
         BEGIN          
            UPDATE SerialNo WITH (ROWLOCK) SET      
               OrderKey = @cOrderKey,       
               OrderLineNumber = ISNULL(@cOrderLineNumber, ''),  
               LabelLine = @cLabelLine,  
               CartonNo = @nCartonNo,  
               PickSlipNo = @cPickSlipNo,  
               TrafficCop = NULL,  
               Status = '1',
               EditDate = GETDATE(),  
               EditWho = @c_UserID   
            WHERE SerialNoKey = @cSerialNoKey    
                        
            IF @@ERROR <> 0         
            BEGIN         
               SET @n_Continue = 3
               SET @n_ErrNo = 14407        
               SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') -- 'Failed to Update SerialNo.'        
               GOTO EXIT_SP        
            END        
         END   
         
         INSERT INTO PACKSERIALNO (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, SerialNo, Qty, AddWho, AddDate, EditWho, EditDate)      
         VALUES (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @cSerialNo, @nQty, @c_UserID, GETDATE(), @c_UserID, GETDATE())      
      
         IF @@ERROR <> 0         
         BEGIN         
            SET @n_Continue = 3
            SET @n_ErrNo = 14408        
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') -- 'Failed to Insert into PackSerialNo.'        
            GOTO EXIT_SP        
         END 
         
         FETCH NEXT FROM @CURSOR_AD INTO @cSerialNo        
      END 
      CLOSE @CURSOR_AD
      DEALLOCATE @CURSOR_AD
   END  

EXIT_SP:
   IF @n_Continue = 3  -- Error Occurred - Process And Return      
   BEGIN      
      SET @b_Success = 0      
      IF @@TRANCOUNT > @n_StartCnt AND @@TRANCOUNT = 1 
      BEGIN               
         ROLLBACK TRAN      
      END      
      ELSE      
      BEGIN      
         WHILE @@TRANCOUNT > @n_StartCnt      
         BEGIN      
            COMMIT TRAN      
         END      
      END   
      RETURN      
   END      
   ELSE      
   BEGIN      
      SELECT @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END