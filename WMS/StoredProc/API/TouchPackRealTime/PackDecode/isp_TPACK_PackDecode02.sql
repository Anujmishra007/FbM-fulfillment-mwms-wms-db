SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_PackDecode02                                       */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Check the Pack Decode Config                                 */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-10-14   1.0  GCH225     Cloned from isp_TPS_DecodeSP02 (TPS-597)         */
/* 2026-03-05   2.0  GCH225     UWP-49985: Support Decode InputValue 2 and 3     */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_PackDecode02] (
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

   IF NOT(LEFT(RIGHT(@cInputValue1, 14), 3) = '240')
   BEGIN
      SET @n_ErrNo = 12301
	   SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Invalid Barcode. Failed to decode it.'    
      GOTO QUIT
   END
  
   SET @cSKU = SUBSTRING(RIGHT(@cInputValue1, 14), 4, 11)

   IF NOT EXISTS (SELECT 1
                  FROM SKU (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND SKU = @cSKU
   )
   BEGIN
      SET @n_ErrNo = 12302
	   SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Invalid Barcode. SKU Not Found.'    
      GOTO QUIT
   END

   SET @b_Success = 1

QUIT:
END
