SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/*********************************************************************************/
/* Store procedure: isp_TPACK_ValidateInput11                                    */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-10-29   1.0  GCH225     Cloned from isp_TPS_ExtValidP11 (FCR-7558)       */
/*********************************************************************************/

CREATE  OR ALTER PROC [API].[isp_TPACK_ValidateInput11] (
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
      cRawValue   NVARCHAR(100)
    , BangPos     INT
    , QPos        INT
    , DecodedSN   NVARCHAR(30)
    , DecodedUPC  NVARCHAR(30)
   )

   SET @b_Success = 0

   --Validate AntiDiversion Input if found
   IF ISJSON(@cInputValue2) = 1
   AND EXISTS (SELECT 1 FROM OPENJSON(@cInputValue2))
   BEGIN
      INSERT INTO @cADList
      SELECT [value]
           , CHARINDEX('!', J.[value])
           , CHARINDEX('?', J.[value])
           , SUBSTRING(J.[value], CHARINDEX('?', J.[value]) + 1, CHARINDEX('!', J.[value]) - CHARINDEX('?', J.[value]) - 1)
           , SUBSTRING(J.[value], CHARINDEX('!', J.[value]) + 1, LEN(J.[value]) - CHARINDEX('!', J.[value]))
      FROM OPENJSON(@cInputValue2)
      WITH ([value] NVARCHAR(100) '$') J

      SELECT @cInvalidQRCodeList= ISNULL(STRING_AGG(J.cRawValue, ', '),'')
      FROM @cADList J
      WHERE BangPos = 0
      OR QPos = 0
      OR BangPos > QPos
   
      IF @cInvalidQRCodeList <> ''
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 14051
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + '(' + @cInvalidQRCodeList  + ')' --'Invalid format: must contain "?" before "!".' 
         GOTO EXIT_SP
      END
   
      SELECT @cInvalidQRCodeList= ISNULL(STRING_AGG(J.cRawValue, ', '),'')
      FROM @cADList J
      WHERE NOT EXISTS( SELECT 1 
                        FROM UPC (NOLOCK)
                        WHERE StorerKey = @cStorerKey
                        AND SKU = @cSKU
                        AND UPC = J.DecodedUPC
      )
   
      IF @cInvalidQRCodeList <> ''
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 14052
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')  + '(' + @cInvalidQRCodeList  + ')' --'Invalid QR Code, current SKU does not found in UPC table.' 
         GOTO EXIT_SP
      END

      SELECT @cInvalidQRCodeList= ISNULL(STRING_AGG(J.cRawValue, ', '),'')
      FROM @cADList J
      WHERE EXISTS ( SELECT 1
                     FROM SERIALNO SN (NOLOCK)
                     WHERE SN.StorerKey = @cStorerKey
                     AND SN.SKU = @cSKU
                     AND SN.SerialNo = J.DecodedSN
                     AND EXISTS (SELECT 1
                                 FROM SKU S (NOLOCK)
                                 WHERE S.StorerKey = SN.StorerKey
                                 AND S.SKU = SN.SKU
                                 AND S.SerialNoCapture = '3'
                                 AND S.SUSR4 = 'AD'
                     )
                     AND SN.[Status] NOT IN ('1','9','CANC')
      )

      IF @cInvalidQRCodeList <> ''
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 14053
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')  + '(' + @cInvalidQRCodeList  + ')' --'Invalid QR Code, current SerialNo already been used.' 
         GOTO EXIT_SP
      END

      SELECT @cInvalidQRCodeList= ISNULL(STRING_AGG(J.cRawValue, ', '),'')
      FROM @cADList J
      WHERE EXISTS ( SELECT 1
                     FROM SERIALNO SN (NOLOCK)
                     WHERE SN.StorerKey = @cStorerKey
                     AND SN.SKU = @cSKU
                     AND SN.SerialNo = J.DecodedSN
                     AND NOT EXISTS (SELECT 1
                                 FROM SKU S (NOLOCK)
                                 WHERE S.StorerKey = SN.StorerKey
                                 AND S.SKU = SN.SKU
                                 AND S.SerialNoCapture = '3'
                                 AND S.SUSR4 = 'AD'
                     )
                     AND SN.[Status] <> '1'
      )

      IF @cInvalidQRCodeList <> ''
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 14054
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')  + '(' + @cInvalidQRCodeList  + ')' --'Invalid QR Code, current SerialNo already been used.' 
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