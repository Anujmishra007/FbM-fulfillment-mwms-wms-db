SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/*********************************************************************************/
/* Store procedure: isp_TPACK_ValidateInput_Std                                  */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-12   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE  OR ALTER PROC [API].[isp_TPACK_ValidateInput_Std] (
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

	DECLARE @cInvalidQRCodeList NVARCHAR(3000)
         , @nNumberOfADField  INT
         , @nDisplayADQty     INT

   DECLARE @cADList TABLE (
      cValue NVARCHAR(100)
   )

   SET @b_Success          = 0
   SET @nNumberOfADField   = 0
   SET @nDisplayADQty      = 0

   --Validate AntiDiversion Input if found
   IF ISJSON(@cInputValue2) = 1
   AND EXISTS (SELECT 1 FROM OPENJSON(@cInputValue2))
   BEGIN
      EXEC [API].[isp_TPACK_GetTotalADCount]
              @cType             = @cType            
            , @bIsDiscrete       = @bIsDiscrete      
            , @bIsCustom         = @bIsCustom        
            , @cPickSlipNo       = @cPickSlipNo       
            , @cOrderKey         = @cOrderKey
            , @cLoadKey          = @cLoadKey          
            , @cDropID           = @cDropID
            , @cStorerKey        = @cStorerKey        
            , @cFacility         = @cFacility   
            , @cInputValue1      = @cInputValue1
            , @cInputValue2      = @cInputValue2
            , @cInputValue3      = @cInputValue3
            , @cScanType         = @cScanType
            , @cSKU              = @cSKU
            , @nCartonNo         = @nCartonNo
            , @nQty              = @nQty
            , @c_UserID          = @c_UserID
            , @cLangCode         = @cLangCode
            , @nNumberOfADField  = @nNumberOfADField  OUTPUT
            , @nDisplayADQty     = @nDisplayADQty     OUTPUT
            , @b_Success         = @b_Success         OUTPUT
            , @n_ErrNo           = @n_ErrNo           OUTPUT
            , @c_ErrMsg          = @c_ErrMsg          OUTPUT

      IF @b_Success = 0
      BEGIN
         SET @n_Continue  = 3    
         GOTO EXIT_SP
      END

      INSERT INTO @cADList
      SELECT [value]
      FROM OPENJSON(@cInputValue2)
      WITH ([value] NVARCHAR(100) '$') J

      IF @@ROWCOUNT <> @nNumberOfADField
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 11354
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + @cInvalidQRCodeList --'Incomplete input. Please fill in all required AD fields.' 
         GOTO EXIT_SP
      END
      IF EXISTS ( SELECT 1 
                  FROM CODELKUP C (NOLOCK)
                  WHERE C.ListName = 'QRTPS'
                  AND C.StorerKey = @cStorerKey)
      BEGIN
         SELECT @cInvalidQRCodeList= ISNULL(STRING_AGG(J.cValue, ', '),'')
         FROM @cADList J
         WHERE EXISTS ( SELECT 1 
                        FROM CODELKUP C (NOLOCK)
                        WHERE J.cValue LIKE C.Long
                        AND C.ListName = 'QRTPS'
                        AND C.StorerKey = @cStorerKey
                      )
         IF @cInvalidQRCodeList <> ''
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 11351
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + @cInvalidQRCodeList --'Invalid QRCode Found.(' + @cInvalidQRCodeList + ')' 
            GOTO EXIT_SP
         END
      END

      IF EXISTS ( SELECT 1
                  FROM PACKSERIALNO P (NOLOCK)
                  WHERE P.PickSlipNo = @cPickSlipNo
                  AND P.StorerKey = @cStorerKey
                  AND EXISTS (SELECT 1 
                              FROM @cADList A 
                              WHERE (P.SerialNo = A.cValue
                              OR P.Barcode = A.cValue)
                             )
      )
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 11352    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'The following SerialNo/AD already exists and in used in PackSerialNo Table.'  
         GOTO EXIT_SP
      END

      IF EXISTS ( SELECT 1
                  FROM SERIALNO S (NOLOCK)
                  WHERE S.StorerKey = @cStorerKey
                  AND EXISTS (SELECT 1 
                              FROM @cADList A 
                              WHERE S.SerialNo = A.cValue
                             )
                  AND S.[Status] >= '6'
      )
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 11353    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'The following SerialNo/AD already exists and in used in SerialNoTable.'  
         GOTO EXIT_SP
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