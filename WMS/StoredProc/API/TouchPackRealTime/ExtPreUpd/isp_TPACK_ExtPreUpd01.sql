SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtPreUpd01                                        */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Extended Pre Update the PackSerialNo or SerialNo or etc.     */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-12-05   1.0  Sean       Cloned from isp_TPS_ExtUpd01                     */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtPreUpd01] (
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
         , @cStatus           NVARCHAR(20)
         , @bOrderExist       BIT
         , @nSNQty            INT
 
   DECLARE @cList TABLE (
      cSerialNo   NVARCHAR(50)
   )

   SET @b_Success       = 0  
   SET @n_ErrNo         = 0  
   SET @c_ErrMsg        = ''
   SET @cSerialNoKey    = ''
   SET @cSerialNo       = ''
   SET @cOrderLineNumber = ''
   SET @cStatus         = ''
   SET @bOrderExist     = 0
   SET @nSNQty          = 0

   IF ISJSON(@cInputValue2) = 0
   OR @cInputValue2 = ''
   BEGIN
      GOTO EXIT_SP
   END

   INSERT INTO @cList (cSerialNo)
   SELECT [value]
   FROM OPENJSON(@cInputValue2)
   WITH ([value] NVARCHAR(100) '$') J

   DECLARE CUR_SN CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT cSerialNo 
   FROM @cList

   OPEN CUR_SN
   FETCH NEXT FROM CUR_SN INTO @cSerialNo
   WHILE @@FETCH_STATUS = 0
   BEGIN
      SET @bOrderExist = 0
      SET @cSerialNoKey = ''

      SELECT @cOrderLineNumber = ISNULL(PD.OrderLineNumber,'')
      FROM PICKDETAIL PD (NOLOCK)
      WHERE PD.StorerKey = @cStorerKey
      AND PD.OrderKey = @cOrderKey
      AND PD.SKU = @cSKU
      AND NOT EXISTS(SELECT 1 
                     FROM SERIALNO S (NOLOCK)
                     WHERE S.OrderKey = PD.OrderKey
                     AND S.OrderLineNumber = PD.OrderLineNumber
                     AND S.SKU = PD.SKU)

      SELECT @cSerialNoKey = SerialNoKey
           , @bOrderExist = IIF(ISNULL(OrderKey,'') <> '', 1, 0)
           , @nSNQty = Qty
      FROM SERIALNO (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND SKU = @cSKU
      AND SerialNo = @cSerialNo

      IF @@ROWCOUNT = 0
      BEGIN
         -- SerialNo does not exist, create new
         EXECUTE dbo.nspg_GetKey        
                  'SerialNo',        
                  10 ,        
                  @cSerialNoKey       OUTPUT,        
                  @b_Success          OUTPUT,        
                  @n_ErrNo            OUTPUT,        
                  @c_ErrMsg           OUTPUT        
                       
         IF @b_Success <> 1        
         BEGIN        
            SET @n_Continue = 3
            SET @n_ErrNo = 14351        
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') -- 'Failed to get SerialNo Key.'        
            GOTO EXIT_SP        
         END 

         -- Determine Status based on SerialNoCapture
         IF EXISTS (SELECT 1
                    FROM SKU (NOLOCK)
                    WHERE SKU = @cSKU 
                    AND StorerKey = @cStorerKey  
                    AND SerialNoCapture IN ('1','3'))
         BEGIN
            SET @cStatus = '1'
         END
         ELSE
         BEGIN
            SET @cStatus = '6'
         END

         -- Insert into PackSerialNo
         INSERT INTO PACKSERIALNO (   PickSlipNo
                                    , CartonNo
                                    , LabelNo
                                    , LabelLine
                                    , StorerKey
                                    , SKU
                                    , SerialNo
                                    , QTY
                                    , PickDetailKey
                                    , AddWho
                                    , AddDate
                                    , EditWho
                                    , EditDate
                                    )
                           VALUES (   @cPickSlipNo
                                    , @nCartonNo
                                    , @cLabelNo
                                    , @cLabelLine
                                    , @cStorerKey
                                    , @cSKU
                                    , @cSerialNo
                                    , 1
                                    , ''
                                    , @c_UserID
                                    , GETDATE()
                                    , @c_UserID
                                    , GETDATE()
                                    )
         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 14352
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') -- 'Failed to Insert into PackSerialNo.'
            GOTO EXIT_SP
         END

         -- Insert into SerialNo
         INSERT INTO SERIALNO ( SerialNoKey
                              , OrderKey
                              , OrderLineNumber
                              , StorerKey
                              , SKU
                              , SerialNo
                              , Qty
                              , [Status]
                              , CartonNo
                              , AddWho
                              , AddDate
                              , EditWho
                              , EditDate
                              )
                       VALUES ( 
                                @cSerialNoKey
                              , @cOrderKey
                              , @cOrderLineNumber
                              , @cStorerKey
                              , @cSKU
                              , @cSerialNo
                              , 1
                              , @cStatus
                              , @nCartonNo
                              , @c_UserID
                              , GETDATE()
                              , @c_UserID
                              , GETDATE()
                              )
         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 14353
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') -- 'Failed to Insert into SerialNo.'
            GOTO EXIT_SP
         END
      END
      ELSE
      BEGIN
         -- SerialNo exists
         IF @bOrderExist = 0
         BEGIN
            -- OrderKey is empty, need to update

            -- Check if PackSerialNo already exists
            IF NOT EXISTS (SELECT 1 FROM PACKSERIALNO (NOLOCK)    
                           WHERE PickSlipNo = @cPickSlipNo    
                           AND StorerKey = @cStorerKey    
                           AND SKU = @cSKU
                           AND SerialNo = @cSerialNo)    
            BEGIN
               SET @nSNQty = CASE WHEN ISNULL(@nSNQty, 0) = 0 THEN 1 ELSE @nSNQty END

               INSERT INTO PACKSERIALNO (   PickSlipNo
                                          , CartonNo
                                          , LabelNo
                                          , LabelLine
                                          , StorerKey
                                          , SKU
                                          , SerialNo
                                          , QTY
                                          , PickDetailKey
                                          , AddWho
                                          , AddDate
                                          , EditWho
                                          , EditDate
                                          )
                                 VALUES (   @cPickSlipNo
                                          , @nCartonNo
                                          , @cLabelNo
                                          , @cLabelLine
                                          , @cStorerKey
                                          , @cSKU
                                          , @cSerialNo
                                          , @nSNQty
                                          , ''
                                          , @c_UserID
                                          , GETDATE()
                                          , @c_UserID
                                          , GETDATE()
                                          )
               IF @@ERROR <> 0
               BEGIN
                  SET @n_Continue = 3
                  SET @n_ErrNo = 14354
                  SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') -- 'Failed to Insert into PackSerialNo.'
                  GOTO EXIT_SP
               END
            END

            UPDATE SERIALNO WITH (ROWLOCK)
            SET OrderKey = @cOrderKey
              , OrderLineNumber = @cOrderLineNumber
              , [Status] = '6'
              , EditWho = @c_UserID
              , EditDate = GETDATE()
            WHERE SerialNoKey = @cSerialNoKey

            IF @@ERROR <> 0
            BEGIN
               SET @n_Continue = 3
               SET @n_ErrNo = 14355
               SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') -- 'Failed to Update SerialNo.'
               GOTO EXIT_SP
            END
         END
      END

      FETCH NEXT FROM CUR_SN INTO @cSerialNo
   END
   CLOSE CUR_SN;
   DEALLOCATE CUR_SN;

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
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON API.isp_TPACK_ExtPreUpd01 TO NSQL
GO