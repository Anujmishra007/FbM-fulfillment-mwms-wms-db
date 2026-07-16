SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/*********************************************************************************/
/* Store procedure: isp_TPACK_ValidateInput05                                    */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-12-17   1.0  JWF011     Cloned from isp_TPS_ExtValidP05                  */
/* 2025-12-24   2.0  GCH225     New logic added.                                 */
/* 2026-06-17   3.0  JWF011     FCR-13553: Add logic for diff style&color SKU    */
/* 2026-06-23   3.1  JWF011     FCR-13553: Fix diff style&color SKU validation   */
/* 2026-06-29   3.2  JWF011     FCR-13553: Fix bug                               */
/*********************************************************************************/

CREATE  OR ALTER PROC [API].[isp_TPACK_ValidateInput05] (
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

   DECLARE @cInvalidQRCodeList	NVARCHAR(3000)
         , @cStyleColor          NVARCHAR(20)     = ''
         , @cSKUToValidate       NVARCHAR(20)     = ''
         , @nPackQty             INT              = 0
         , @nPickQty             INT              = 0
   
   DECLARE @cADList TABLE (
		cValue NVARCHAR(100)
	)

   SET @b_Success = 0

   IF @cScanType = 'ucc'
   BEGIN
      IF NOT EXISTS(SELECT 1
							FROM SERIALNO (NOLOCK)
							WHERE UserDefine01 = @cInputValue1   
							AND [Status] in ('0','1')
							AND Storerkey = @cStorerKey
      )
		BEGIN
			SET @n_Continue = 3
			SET @n_ErrNo = 14902
			SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + '(' + @cInputValue1 + ').'  --'No SerialNo mapped with UCCNo(@cInputValue1)'
			GOTO EXIT_SP
		END
   END
   ELSE
   BEGIN
      --Validate AntiDiversion Input if found
      IF ISJSON(@cInputValue2) = 1
      AND EXISTS (SELECT 1 FROM OPENJSON(@cInputValue2))
      BEGIN
         INSERT INTO @cADList
         SELECT [value]
         FROM OPENJSON(@cInputValue2)
         WITH ([value] NVARCHAR(100) '$') J
         
         SELECT @cInvalidQRCodeList = ISNULL(STRING_AGG(J.cValue, ', '),'')
         FROM @cADList J

         IF SUBSTRING(@cInvalidQRCodeList,1,1) NOT IN ('Y','y')
			AND LEN(@cInvalidQRCodeList) <> 18
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 14903
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + '(' + @cInvalidQRCodeList + ')' --'Invalid SerialNo Format. (@cInvalidQRCodeList)'
            GOTO EXIT_SP
         END
      END
   END

   IF @cScanType = 'sku'
      AND EXISTS (SELECT 1
                  FROM STORERCONFIG (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND ConfigKey = 'TPS-PackDetail'
      )
      AND LEN(@cSKU) - LEN(REPLACE(@cSKU, '_', '')) = 2
      AND PARSENAME(REPLACE(@cSKU, '_', '.'), 3) <> ''  -- style
      AND PARSENAME(REPLACE(@cSKU, '_', '.'), 2) <> ''  -- color
      AND PARSENAME(REPLACE(@cSKU, '_', '.'), 1) <> ''  -- size
   BEGIN
      DECLARE CUR_SKU CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT(SKU)
      FROM PICKDETAIL (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND OrderKey = @cOrderKey
      AND LEN(SKU) - LEN(REPLACE(SKU, '_', '')) = 2
      AND PARSENAME(REPLACE(SKU, '_', '.'), 3) <> ''  -- style
      AND PARSENAME(REPLACE(SKU, '_', '.'), 2) <> ''  -- color
      AND PARSENAME(REPLACE(SKU, '_', '.'), 1) <> ''  -- size
      AND SKU NOT LIKE ISNULL(LEFT(@cSKU, CHARINDEX('_', @cSKU, CHARINDEX('_', @cSKU) + 1) - 1), '') + '_%'
      OPEN CUR_SKU
      FETCH NEXT FROM CUR_SKU INTO @cSKUToValidate
      WHILE @@FETCH_STATUS = 0
      BEGIN
         SELECT @cStyleColor = ISNULL(LEFT(@cSKUToValidate, CHARINDEX('_', @cSKUToValidate, CHARINDEX('_', @cSKUToValidate) + 1) - 1), '')
         SET @nPackQty = ( SELECT COALESCE(SUM(QTY), 0)
                           FROM PACKDETAIL (NOLOCK)
                           WHERE StorerKey = @cStorerKey
                           AND PickSlipNo = @cPickSlipNo
                           AND SKU LIKE @cStyleColor + '_%'
                         )
         IF @nPackQty > 0
         BEGIN
            SET @nPickQty = ( SELECT COALESCE(SUM(QTY), 0)
                              FROM PICKDETAIL (NOLOCK)
                              WHERE StorerKey = @cStorerKey
                              AND OrderKey = @cOrderKey
                              AND SKU LIKE @cStyleColor + '_%'
                            )
            IF @nPackQty <> @nPickQty
            BEGIN
               SET @n_Continue = 3
               SET @n_ErrNo = 14904
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + '(' + @cStyleColor + ')' --'Not allow to pack current SKU when previous SKU with different style_color not finished packing. (@cStyleColor)'
               GOTO EXIT_SP
            END
         END
         FETCH NEXT FROM CUR_SKU INTO @cSKUToValidate
      END
      CLOSE CUR_SKU
      DEALLOCATE CUR_SKU
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
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [API].[isp_TPACK_ValidateInput05] TO NSQL
GO