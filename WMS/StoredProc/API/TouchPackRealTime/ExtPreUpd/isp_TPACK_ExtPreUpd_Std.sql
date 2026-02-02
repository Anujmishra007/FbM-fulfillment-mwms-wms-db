SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtPreUpd_Std                                      */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Extended Pre Update Std the PackSerialNo or SerialNo or etc. */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-12   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtPreUpd_Std] (
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

   DECLARE @n_Continue           INT            = 1  
         , @n_StartCnt           INT            = @@TRANCOUNT   

   DECLARE @cExtUpdateSP            NVARCHAR(256)
         , @bINS_SerialNo_Barcode   BIT
         , @nPackOtherUnit2         INT
         , @cAntiDiversion          NVARCHAR(100)
         , @nPackSerialNoKey        BIGINT
         , @cSerialNoKey            NVARCHAR(10)
         , @cCheckSNStatus          NVARCHAR(10)
         , @bINS_PSN                BIT
         , @bINS_SN                 BIT

   
   DECLARE @CURSOR_AD CURSOR
   DECLARE @cADList TABLE (
      cValue NVARCHAR(100)
   )

   SET @b_Success             = 0  
   SET @n_ErrNo               = 0  
   SET @c_ErrMsg              = ''
   SET @bINS_SerialNo_Barcode = 0
   SET @nPackOtherUnit2       = 0
   SET @cAntiDiversion        = ''
   SET @nPackSerialNoKey      = 0
   SET @cSerialNoKey          = ''
   SET @cCheckSNStatus        = ''
   SET @bINS_PSN              = 1
   SET @bINS_SN               = 1

   IF ISJSON(@cInputValue2) = 0
   OR @cInputValue2 = ''
   BEGIN
      GOTO EXIT_SP
   END

   INSERT INTO @cADList
   SELECT [value]
   FROM OPENJSON(@cInputValue2)
   WITH ([value] NVARCHAR(100) '$') J

   SELECT @cCheckSNStatus=[Status] 
   FROM SERIALNO (NOLOCK)
   WHERE StorerKey = @cStorerKey
   AND PickSlipNo = @cPickSlipNo
   AND SerialNo = @cInputValue1

   IF @@ROWCOUNT > 1
   BEGIN
      IF @cCheckSNStatus >= '6'
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 10751
         SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'The following SerialNo/AD already exists and in used in SerialNoTable.'
         GOTO EXIT_SP
      END
      SET @bINS_SerialNo_Barcode = 1
   END

   IF EXISTS (
      SELECT 1 
      FROM SKU (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND SKU = @cSKU
      AND SUSR4 = 'AD'
   )
   BEGIN
      SELECT @nPackOtherUnit2 = P.OtherUnit2
      FROM SKU S (NOLOCK)
         JOIN PACK P (NOLOCK) 
         ON S.PACKKey = P.PackKey
      WHERE  S.SKU = @cSKU
         AND S.StorerKey = @cStorerKey

      SET @nQty = @nPackOtherUnit2
   END

   SET @CURSOR_AD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT cValue 
   FROM @cADList

   OPEN @CURSOR_AD
   FETCH NEXT FROM @CURSOR_AD INTO @cAntiDiversion
   WHILE @@FETCH_STATUS = 0
   BEGIN
      SET @nPackSerialNoKey   = 0
      SET @cSerialNoKey       = ''
      SET @bINS_PSN           = 1
      SET @bINS_SN            = 1
      
      IF @bINS_SerialNo_Barcode = 1
      BEGIN
         SELECT @nPackSerialNoKey = PackSerialNoKey
         FROM PACKSERIALNO (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND LabelNo = @cLabelNo
         AND SKU = @cSKU
         AND SerialNo = @cInputValue1
         AND Barcode = @cAntiDiversion

         IF @@ROWCOUNT = 1
         BEGIN
            SET @bINS_PSN = 0  
         END

         
         SELECT @cSerialNoKey = SerialNoKey
         FROM SERIALNO (NOLOCK)
         WHERE  StorerKey = @cStorerKey
         AND SerialNo = @cInputValue1
         AND SKU = @cSKU
         AND [Status] < '6'

         IF @@ROWCOUNT = 1
         BEGIN
            SET @bINS_SN = 0
         END
      END
      ELSE
      BEGIN
         SELECT @nPackSerialNoKey = PackSerialNoKey
         FROM PACKSERIALNO (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND LabelNo = @cLabelNo
         AND SKU = @cSKU
         AND SerialNo = @cAntiDiversion

         IF @@ROWCOUNT = 1
         BEGIN
            SET @bINS_PSN = 0  
         END

         SELECT @cSerialNoKey = SerialNoKey
         FROM SERIALNO (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND SerialNo = @cAntiDiversion
         AND SKU = @cSKU
         AND [Status] < '6'

         IF @@ROWCOUNT = 1
         BEGIN
            SET @bINS_SN = 0
         END
      END


      IF @bINS_PSN = 0
      BEGIN
         UPDATE PACKSERIALNO WITH (ROWLOCK)
         SET QTY = QTY + @nQty
            , EditWho = @c_UserID
            , EditDate = GETDATE()
         WHERE PackSerialNoKey = @nPackSerialNoKey

         IF @@Error <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 10752
            SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update into PackSerialNo.'
            GOTO EXIT_SP
         END
      END
      ELSE
      BEGIN
         INSERT INTO PACKSERIALNO ( PickSlipNo
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
                         VALUES ( @cPickSlipNo
                                  , @nCartonNo
                                  , @cLabelNo
                                  , @cLabelLine
                                  , @cStorerKey
                                  , @cSKU
                                  , IIF(@bINS_SerialNo_Barcode = 1, @cInputValue1, @cAntiDiversion)
                                  , @nQty
                                  , ''
                                  , @c_UserID
                                  , GETDATE()
                                  , @c_UserID
                                  , GETDATE()
                                  , IIF(@bINS_SerialNo_Barcode = 1, @cAntiDiversion, '')
                                  )
         IF @@Error <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 10753
            SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Insert into PackSerialNo.'
            GOTO EXIT_SP
         END
      END

      IF @bINS_SN = 0
      BEGIN
         UPDATE SERIALNO WITH (ROWLOCK)
         SET Qty = Qty + @nQty
            , EditWho = @c_UserID
            , EditDate = GETDATE()
         WHERE SerialNoKey = @cSerialNoKey

         IF @@Error <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 10754
            SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update into SerialNo.'
            GOTO EXIT_SP
         END
      END
      ELSE
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
            SET @n_ErrNo = 10755        
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
                              , IIF(@bINS_SerialNo_Barcode = 1, @cInputValue1, @cAntiDiversion)
                              , @nQty
                              , @c_UserID
                              , GETDATE()
                              , @c_UserID
                              , GETDATE()
                              , '1'
                              )
         IF @@Error <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 10756
            SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Insert into SerialNo.'
            GOTO EXIT_SP
         END
      END

      FETCH NEXT FROM @CURSOR_AD INTO @cAntiDiversion
   END
   CLOSE @CURSOR_AD;
   DEALLOCATE @CURSOR_AD;

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

