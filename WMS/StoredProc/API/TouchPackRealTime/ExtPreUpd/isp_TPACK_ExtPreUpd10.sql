SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtPreUpd10                                        */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Extended Pre Update the PackSerialNo or SerialNo or etc.     */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-10-23   1.0  GCH225     Cloned from isp_TPS_ExtUpd10 (FCR-5168)          */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtPreUpd10] (
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

   DECLARE @cAntiDiversion    NVARCHAR(100)
         , @cSerialNoKey      NVARCHAR(10)
         , @cOrderLineNumber  NVARCHAR(5)
        

   
   DECLARE @CURSOR_AD CURSOR
   DECLARE @cADList TABLE (
      cValue NVARCHAR(100)
   )

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = ''
   SET @cAntiDiversion     = ''
   SET @cSerialNoKey       = ''
   SET @cOrderLineNumber   = ''

   IF ISJSON(@cInputValue2) = 0
   OR @cInputValue2 = ''
   BEGIN
      GOTO EXIT_SP
   END

   INSERT INTO @cADList
   SELECT [value]
   FROM OPENJSON(@cInputValue2)
   WITH ([value] NVARCHAR(100) '$') J

   SET @CURSOR_AD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT SerialNoKey 
        , SerialNo
   FROM SERIALNO S (NOLOCK)
   INNER JOIN @cADList AD
   ON S.SerialNo = AD.cValue
   WHERE S.StorerKey = @cStorerKey
   AND S.SKU = @cSKU

   OPEN @CURSOR_AD
   FETCH NEXT FROM @CURSOR_AD INTO @cAntiDiversion, @cAntiDiversion
   WHILE @@FETCH_STATUS = 0
   BEGIN
      SELECT @cOrderLineNumber = ISNULL(PD.OrderLineNumber,'')
      FROM PICKDETAIL PD (NOLOCK)      
      WHERE PD.StorerKey = @cStorerKey      
         AND PD.OrderKey = @cOrderKey      
         AND PD.SKU = @cSKU       
         AND NOT EXISTS(SELECT 1
                        FROM SERIALNO S (NOLOCK)       
                        WHERE S.OrderKey = PD.OrderKey      
                        AND S.OrderLineNumber = PD.OrderLineNUmber      
                        AND S.SKU = PD.SKU
                        ) 
      
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
                                 , Barcode
                                 )
                        VALUES (   @cPickSlipNo
                                 , @nCartonNo
                                 , @cLabelNo
                                 , @cLabelLine
                                 , @cStorerKey
                                 , @cSKU
                                 , @cAntiDiversion
                                 , @nQty
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
         SET @n_ErrNo = 12401
         SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Insert into PackSerialNo.'
         GOTO EXIT_SP
      END

      UPDATE SerialNo
      SET OrderKey = @cOrderKey
        , OrderLineNumber = @cOrderLineNumber
        , PickSlipNo = @cPickSlipNo
        , CartonNo = @nCartonNo
        , LabelLine = @cLabelLine
        , EditDate = GETDATE()
        , EditWho = @c_UserID
      WHERE SerialNoKey = @cSerialNoKey

      IF @@ERROR <> 0       
      BEGIN       
         SET @n_Continue = 3
         SET @n_ErrNo = 12402      
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') -- 'Failed to Update the SerialNo table.'      
         GOTO EXIT_SP
      END  

      FETCH NEXT FROM @CURSOR_AD INTO @cSerialNoKey, @cAntiDiversion
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


