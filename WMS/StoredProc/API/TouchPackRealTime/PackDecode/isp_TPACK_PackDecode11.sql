SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_PackDecode11                                       */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : MODT UPC;EPC Decode                                          */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-04-20   1.0  GCH225     FCR-11777 Created                                */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_PackDecode11] (
	  @cType             NVARCHAR(30)      = ''
   , @bIsDiscrete       BIT               = 0
   , @bIsCustom         BIT               = 0
   , @cPickSlipNo       NVARCHAR(10)      = ''
   , @cOrderKey         NVARCHAR(10)      = ''
   , @cLoadKey          NVARCHAR(10)      = ''
   , @cDropID           NVARCHAR(20)      = ''
   , @cStorerKey        NVARCHAR(15)      = ''
   , @cFacility         NVARCHAR(5)       = ''
   , @cInputValue1      NVARCHAR(128)     = ''
   , @cInputValue2      NVARCHAR(MAX)     = ''  OUTPUT
   , @cInputValue3      NVARCHAR(128)     = ''  OUTPUT
   , @c_UserID          NVARCHAR(256)     = ''
   , @cLangCode         NVARCHAR(3)       = ''
   , @cSKU              NVARCHAR(20)      = ''  OUTPUT
   , @nQty              INT                     OUTPUT
   , @b_Success         INT               = 0   OUTPUT
   , @n_ErrNo           INT               = 0   OUTPUT
   , @c_ErrMsg          NVARCHAR(250)     = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
   
   DECLARE @cUPC  NVARCHAR(100)
         , @cEPC  NVARCHAR(100)
         , @cSeparator NVARCHAR(5)  -- UPC+EPC separator; read from StorerConfig.Option1 (required)
         , @nPos  INT

   SET @b_Success = 0  

   EXEC [dbo].[ispSKUDC18] 
         @c_Storerkey = @cStorerKey
       , @c_Sku = @cInputValue1
       , @c_NewSku = @cSKU       OUTPUT
       , @b_Success = @b_Success OUTPUT
       , @n_Err = @n_ErrNo       OUTPUT
       , @c_ErrMsg = @c_ErrMsg   OUTPUT

   IF @b_Success = 0 OR @cSKU = ''
   BEGIN
      SET @b_Success = 0
      IF @n_ErrNo = 0
      BEGIN
         SET @n_ErrNo = 15701
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Not able to decode SKU for current barcode.
      END
      GOTO QUIT
   END

   SELECT @cSeparator = NULLIF(RTRIM(Option1), '')
    FROM STORERCONFIG (NOLOCK)
    WHERE StorerKey = @cStorerKey 
    AND ConfigKey = 'SKUDecode';
 
   IF @cSeparator IS NULL
   BEGIN
      SET @b_Success = 0
      SET @n_ErrNo = 15702;
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --'UPC+EPC separator not configured in StorerConfig.Option1'
      GOTO QUIT
   END

   SET @nPos = CHARINDEX(@cSeparator, @cInputValue1);
   IF  @nPos > 0
   BEGIN
       SET @cUPC = LEFT(@cInputValue1, @nPos - 1);
       SET @cEPC = SUBSTRING(@cInputValue1, @nPos + LEN(@cSeparator), LEN(@cInputValue1));
   END
   SET @cInputValue2 = '["' + @cEPC + '"]'
   SET @cInputValue3 = ''
   SET @b_Success = 1

QUIT:
END
