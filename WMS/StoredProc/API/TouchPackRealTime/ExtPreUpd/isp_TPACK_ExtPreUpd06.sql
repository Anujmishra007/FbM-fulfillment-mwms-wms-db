SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtPreUpd06                                        */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Extended Pre Update the PackSerialNo or SerialNo or etc.     */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-10-28   1.0  GCH225     Cloned from isp_TPS_ExtUpd06 (TPS-744)           */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtPreUpd06] (
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

   DECLARE @n_Continue     INT            = 1  
         , @n_StartCnt     INT            = @@TRANCOUNT  

   DECLARE @cSerialNoKey      NVARCHAR(10)
         , @cSerialNo         NVARCHAR(50)  
         , @cOrderLineNumber  NVARCHAR(5)
 
   DECLARE @cList TABLE (
      cSerialNo   NVARCHAR(50)
   )

   SET @b_Success    = 0  
   SET @n_ErrNo      = 0  
   SET @c_ErrMsg     = ''
   SET @cSerialNoKey = ''
   SET @cSerialNo    = ''

   IF ISJSON(@cInputValue2) = 0
   OR @cInputValue2 = ''
   BEGIN
      GOTO EXIT_SP
   END

   INSERT INTO @cList (cSerialNo)
   SELECT SUBSTRING([value]
                  , LEN([value]) - CHARINDEX('/', REVERSE([value])) + 1
                  , LEN([value]) - (LEN([value]) - CHARINDEX('/', REVERSE([value]))
                                    )
                  )
   FROM OPENJSON(@cInputValue2)
   WITH ([value] NVARCHAR(100) '$') J

   DECLARE CUR_SN CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT cSerialNo 
   FROM @cList

   OPEN CUR_SN
   FETCH NEXT FROM CUR_SN INTO @cSerialNo
   WHILE @@FETCH_STATUS = 0
   BEGIN
      SELECT @cSerialNoKey = SerialNoKey
      FROM SERIALNO (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND SKU = @cSKU
      AND SerialNo = @cSerialNo

      IF @@ROWCOUNT = 0
      BEGIN
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
            SET @n_ErrNo = 12351        
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo ,@cLangCode ,'DSP') -- 'Failed to get SerialNo Key.'        
            GOTO EXIT_SP        
         END 

         INSERT INTO SERIALNO ( SerialNoKey
                              , OrderKey
                              , OrderLineNumber
                              , StorerKey
                              , SKU
                              , SerialNo
                              , Qty
                              , AddWho
                              , AddDate
                              , EditWho
                              , EditDate
                              , [Status]
                              )
                       VALUES ( 
                                @cSerialNoKey
                              , ''
                              , ''
                              , @cStorerKey
                              , @cSKU
                              , @cSerialNo
                              , 1
                              , @c_UserID
                              , GETDATE()
                              , @c_UserID
                              , GETDATE()
                              , '1'
                              )
         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 13252
            SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Insert into SerialNo.'
            GOTO EXIT_SP
         END
      END

      IF NOT EXISTS( SELECT 1 
                     FROM PACKSERIALNO (NOLOCK)    
                     WHERE PickSlipNo = @cPickSlipNo
                     AND StorerKey = @cStorerKey
                     AND SKU = @cSKU
                     AND SerialNo = @cSerialNo
      )    
      BEGIN  
         INSERT INTO PACKSERIALNO (PickSlipNo
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
                                 , Barcode
                                 )
                           VALUES (@cPickSlipNo
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
                                 , ''
                                 )
         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 13253
            SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Insert into PackSerialNo.'
            GOTO EXIT_SP
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

