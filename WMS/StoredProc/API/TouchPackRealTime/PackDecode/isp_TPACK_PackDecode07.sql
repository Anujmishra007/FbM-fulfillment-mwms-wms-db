SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_PackDecode07                                       */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Check the Pack Decode Config                                 */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-10-14   1.0  GCH225     Cloned from isp_TPS_DecodeSP07 (FCR_1822)        */
/* 2026-03-05   2.0  GCH225     UWP-49985: Support Decode InputValue 2 and 3     */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_PackDecode07] (
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

   DECLARE @cUPC  NVARCHAR(30)

   SET @b_Success    = 0
   SET @cUPC         = ''

   IF SUBSTRING(@cInputValue1,1 ,1) NOT IN ('Y','y') 
   OR LEN(@cInputValue1) <> 18
   BEGIN
      SET @n_ErrNo = 12701
	   SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Invalid SerialNo Format. Record not found.'  
      GOTO QUIT
   END

   SELECT @cSKU = U.SKU
        , @nQty = CAST( CASE U.UOM 
                        WHEN P.PackUOM1 THEN P.CaseCNT
                        WHEN P.PackUOM2 THEN P.InnerPack  
                        WHEN P.PackUOM3 THEN P.QTY  
                        WHEN P.PackUOM4 THEN P.Pallet  
                        WHEN P.PackUOM8 THEN P.OtherUnit1  
                        WHEN P.PackUOM9 THEN P.OtherUnit2
                        ELSE 1 END 
                     AS INT)
   FROM UPC U (NOLOCK) 
   INNER JOIN PACK P (NOLOCK)
   ON P.PackKey = U.PackKey
   WHERE UPC = @cInputValue1
   AND StorerKey = @cStorerKey


   IF @@ROWCOUNT = 0
   BEGIN
      SELECT @cSKU = RTRIM(SKU)
           , @cUPC = UserDefine02
      FROM SERIALNO (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND SerialNo = @cInputValue1
      
      IF @@ROWCOUNT = 0
      BEGIN
         SET @n_ErrNo = 12702
	      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Invalid Barcode. Record not found.'  
         GOTO QUIT
      END
      ELSE
      BEGIN
         IF @cUPC <> ''
         BEGIN
   	      SELECT @cSKU = RTRIM(SKU)
            FROM UPC (NOLOCK)
            WHERE StorerKey = @cStorerKey
            AND UPC = @cUPC
         END
      END

      IF NOT EXISTS (SELECT 1 
                     FROM STORERCONFIG (NOLOCK) 
                     WHERE StorerKey = @cStorerKey 
                     AND ConfigKey = 'ADAllowInsertExistingSerialNo'  
                     AND SValue = '1'
      )
      BEGIN
         SET @n_ErrNo = 12703
	      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Not Allow Insert Duplicate Serial No.'  
         GOTO QUIT
      END  
   END
   
   SET @b_Success = 1

QUIT:
END



