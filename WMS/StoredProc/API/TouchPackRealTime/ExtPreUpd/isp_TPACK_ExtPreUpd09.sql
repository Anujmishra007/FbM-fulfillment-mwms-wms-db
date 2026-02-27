SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtPreUpd09                                        */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : This Extended Update Close Carton SP is mainly update the    */
/*                  Close carton that contains AD Barcode only. It will not      */
/*                  support for update the non AD Barcode value.                 */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-12-17   1.0  JWF011     Cloned from isp_TPS_ExtUpd09                     */
/* 2025-12-24   2.0  GCH225     New logic added                                  */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtPreUpd09] (
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

   DECLARE @n_Continue     INT = 1  
         , @n_StartCnt     INT = @@TRANCOUNT   

   DECLARE @cSerialNoKey   NVARCHAR(10)
         , @cSerialNo      NVARCHAR(50) 
         , @nSNQTY         INT
         , @nRemainQty     INT

   DECLARE @CURSOR_AD      CURSOR

   DECLARE @cList TABLE (
      cSerialNo   NVARCHAR(100)
   )

   SET @b_Success    = 0
   SET @n_ErrNo      = 0
   SET @c_ErrMsg     = ''

   SET @cSerialNoKey = ''
   SET @cSerialNo    = ''
   SET @nRemainQty = 0

   IF @cScanType = 'ucc'
   BEGIN
      IF(SELECT SUM(Qty)
         FROM SERIALNO (NOLOCK)
         WHERE SKU = @cSKU
         AND UserDefine01 = @cInputValue1
         AND StorerKey = @cStorerKey
         AND [Status] IN ('0', '1')
      ) <> @nQty
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 14853
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') -- 'Pack Quantity Not Match with SerialNo Quantity.'
         GOTO EXIT_SP
      END

      SET @nRemainQty = @nQty

      SET @CURSOR_AD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT  SerialNoKey
            , SerialNo
            , Qty
      FROM SERIALNO (NOLOCK)
      WHERE SKU = @cSKU
      AND UserDefine01 = @cInputValue1
      AND StorerKey = @cStorerKey
      AND [Status] IN ('0', '1')
      ORDER BY SerialNoKey

      OPEN @CURSOR_AD
      FETCH NEXT FROM @CURSOR_AD INTO @cSerialNoKey
                                    , @cSerialNo
                                    , @nSNQTY
      WHILE @@FETCH_STATUS = 0
      BEGIN
         INSERT INTO PACKSERIALNO (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, SerialNo, Qty, AddWho, AddDate, EditWho, EditDate)
         VALUES (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @cSerialNo, @nSNQTY, @c_UserID, GETDATE(), @c_UserID, GETDATE())

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 14851
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') --'Failed to Insert into PackSerialNo.'
            GOTO EXIT_SP
         END

         UPDATE SERIALNO WITH (ROWLOCK) 
         SET TrafficCop = NULL
          , [Status] = '1'
          , EditDate = GETDATE()
          , EditWho = @c_UserID
         WHERE SerialNoKey = @cSerialNoKey

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 14852
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') --'Failed to Update SerialNo.'
            GOTO EXIT_SP
         END

         SET @nRemainQty = @nRemainQty - @nSNQTY

         IF @nRemainQty = 0
            BREAK;

         FETCH NEXT FROM @CURSOR_AD INTO @cSerialNoKey
                                       , @cSerialNo
                                       , @nSNQTY
      END
      CLOSE @CURSOR_AD
      DEALLOCATE @CURSOR_AD
   END
   ELSE
   BEGIN
      --Validate AntiDiversion Input if found
      IF ISJSON(@cInputValue2) = 1
      AND EXISTS (SELECT 1 FROM OPENJSON(@cInputValue2))
      BEGIN
         INSERT INTO @cList (cSerialNo)
         SELECT [value]
         FROM OPENJSON(@cInputValue2)
         WITH ([value] NVARCHAR(100) '$') J

         SET @CURSOR_AD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT cSerialNo
         FROM @cList

         OPEN @CURSOR_AD
         FETCH NEXT FROM @CURSOR_AD INTO @cSerialNo
         WHILE @@FETCH_STATUS = 0
         BEGIN
            SET @cSerialNoKey = ''

            SELECT @cSerialNoKey = SerialNoKey
            FROM SERIALNO (NOLOCK) 
            WHERE StorerKey = @cStorerKey 
            AND SKU = @cSKU 
            AND SerialNo = @cSerialNo

            IF @@ROWCOUNT = 0
            BEGIN        
               EXECUTE dbo.nspg_GetKey        
                       'SerialNo'        
                    ,  10         
                    ,  @cSerialNoKey  OUTPUT        
                    ,  @b_Success     OUTPUT        
                    ,  @n_ErrNo       OUTPUT        
                    ,  @c_ErrMsg      OUTPUT        
                       
               IF @b_Success <> 1        
               BEGIN        
                  SET @n_Continue = 3
                  SET @n_ErrNo = 14855
                  SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') -- 'Failed to get SerialNo Key.'        
                  GOTO EXIT_SP        
               END        
                                                 
               INSERT INTO SERIALNO (SerialNoKey, OrderKey, OrderLineNumber, StorerKey, SKU, SerialNo, Qty, [Status], LabelLine, CartonNo, PickSlipNo, AddWho, AddDate, EditWho, EditDate)         
               VALUES (@cSerialNoKey, '', '', @cStorerKey, @cSKU, @cSerialNo, @nQty, '1', '', '', '', @c_UserID, GETDATE(), @c_UserID, GETDATE())         
  
               IF @@ERROR <> 0         
               BEGIN         
                  SET @n_Continue = 3
                  SET @n_ErrNo = 14856        
                  SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') -- 'Failed to Insert into SerialNo.'        
                  GOTO EXIT_SP        
               END
            END
            ELSE
            BEGIN
               UPDATE SerialNo WITH (ROWLOCK)          
               SET TrafficCop = NULL  
                 , [Status] = '1'
                 , EditDate = GETDATE() 
                 , EditWho = @c_UserID   
               WHERE SerialNoKey = @cSerialNoKey    
                        
               IF @@ERROR <> 0         
               BEGIN         
                  SET @n_Continue = 3
                  SET @n_ErrNo = 14857        
                  SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') -- 'Failed to Update SerialNo.'        
                  GOTO EXIT_SP        
               END        
            END   
         
            INSERT INTO PACKSERIALNO (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, SerialNo, Qty, AddWho, AddDate, EditWho, EditDate)      
            VALUES (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @cSerialNo, @nQty, @c_UserID, GETDATE(), @c_UserID, GETDATE())      
      
            IF @@ERROR <> 0         
            BEGIN         
               SET @n_Continue = 3
               SET @n_ErrNo = 14858
               SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') -- 'Failed to Insert into PackSerialNo.'        
               GOTO EXIT_SP        
            END 
         
            FETCH NEXT FROM @CURSOR_AD INTO @cSerialNo        
         END
         CLOSE @CURSOR_AD
         DEALLOCATE @CURSOR_AD
      END
   END

EXIT_SP:
   IF @n_Continue = 3  -- Error Occured - Process And Return      
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