SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_PackDecode08                                       */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Check the Pack Decode Config                                 */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-10-14   1.0  GCH225     Cloned from isp_TPS_DecodeSP08 (TPS-949)         */
/* 2026-03-05   2.0  GCH225     UWP-49985: Support Decode InputValue 2 and 3     */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_PackDecode08] (
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

   SET @b_Success = 0

   IF NOT EXISTS ( SELECT 1 
               FROM SKU (NOLOCK) 
               WHERE ( ManufacturerSku = @cInputValue1
                     OR RetailSKU = @cInputValue1
                     OR AltSKU = @cInputValue1)
               AND StorerKey=@cStorerKey)
   BEGIN
      SET @n_ErrNo = 12751
	   SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Invalid Barcode. Record not found.'  
      GOTO QUIT
   END
   
   IF LEFT(@cInputValue1,2) <> '69'
   BEGIN
      SET @n_ErrNo = 12752
	   SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Invalid Barcode Format Prefix (69) not found.'    
      GOTO QUIT
   END

   SELECT @cSKU = RTRIM(SKU)
   FROM SKU (NOLOCK) 
   WHERE ( ManufacturerSku = @cInputValue1
         OR RetailSKU = @cInputValue1
         OR AltSKU = @cInputValue1)
   AND StorerKey=@cStorerKey

   IF @@ROWCOUNT = 0
   BEGIN
      SET @n_ErrNo = 12753
	   SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Decode.'    
      GOTO QUIT
   END

   SET @b_Success = 1

QUIT:
END



