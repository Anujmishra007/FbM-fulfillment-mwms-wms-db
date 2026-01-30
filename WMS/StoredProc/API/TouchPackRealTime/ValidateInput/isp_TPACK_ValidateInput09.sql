SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/*********************************************************************************/
/* Store procedure: isp_TPACK_ValidateInput09                                    */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-10-29   1.0  GCH225     Cloned from isp_TPS_ExtValidP09 (FCR-4548)       */
/*********************************************************************************/

CREATE  OR ALTER PROC [API].[isp_TPACK_ValidateInput09] (
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

   DECLARE @cADList TABLE (
      cValue NVARCHAR(100)
   )

   SET @b_Success = 0

   --Validate AntiDiversion Input if found
   IF ISJSON(@cInputValue2) = 1
   AND EXISTS (SELECT 1 FROM OPENJSON(@cInputValue2))
   BEGIN
      INSERT INTO @cADList
      SELECT IIF(LEFT([value], 2) = '00'
               , SUBSTRING([value], 3, LEN([value]))
               ,[value]
            )
      FROM OPENJSON(@cInputValue2)
      WITH ([value] NVARCHAR(100) '$') J

      SELECT @cInvalidQRCodeList= ISNULL(STRING_AGG(J.cValue, ', '),'')
      FROM @cADList J
      WHERE LEN(J.cValue) < 5 OR LEN(J.cValue) > 18

      IF @cInvalidQRCodeList <> ''
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 14001
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + '(' + @cInvalidQRCodeList  + ')' --'Serial No must be at least 5 or NOT more than 18 characters long.
         GOTO EXIT_SP
      END

      SELECT @cInvalidQRCodeList= ISNULL(STRING_AGG(J.cValue, ', '),'')
      FROM @cADList J
      WHERE EXISTS ( SELECT 1 
                     FROM SKU S (NOLOCK)
                     WHERE S.StorerKey = @cStorerKey
                     AND S.SKU = J.cValue
                   )
   
      IF @cInvalidQRCodeList <> ''
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 14002
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + '(' + @cInvalidQRCodeList  + ')' --'Serial No cannot be same as SKU code.
         GOTO EXIT_SP
      END

      SELECT @cInvalidQRCodeList= ISNULL(STRING_AGG(J.cValue, ', '),'')
      FROM @cADList J
      WHERE EXISTS ( SELECT 1 
                     FROM PACKSERIALNO P (NOLOCK)
                     WHERE P.PickSlipNo = @cPickSlipNo    
                     AND P.StorerKey = @cStorerKey    
                     AND P.SerialNo = J.cValue 
                   )
   
      IF @cInvalidQRCodeList <> ''
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 14003
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + '(' + @cInvalidQRCodeList  + ')' --'Serial No already been packed in PackSerialNo Table.
         GOTO EXIT_SP
      END

      SELECT @cInvalidQRCodeList= ISNULL(STRING_AGG(J.cValue, ', '),'')
      FROM @cADList J
      WHERE EXISTS ( SELECT 1 
                     FROM SERIALNO S (NOLOCK)
                     WHERE S.SerialNo = J.cValue
                     AND S.StorerKey = @cStorerKey
                     AND S.[Status] <> '1'
                   )
   
      IF @cInvalidQRCodeList <> ''
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 14004
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + '(' + @cInvalidQRCodeList  + ')' --'Serial No already been used or exists in SerialNo Table.
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