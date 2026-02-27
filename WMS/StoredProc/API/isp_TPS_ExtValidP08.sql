SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: isp_TPS_ExtValidP08                                       */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date         Rev  Author      Purposes                                     */
/* 2024-05-08   1.0  GhChan      For basic Serial No Validate                 */
/******************************************************************************/

CREATE  OR ALTER PROC [API].[isp_TPS_ExtValidP08] (
	@json       NVARCHAR( MAX),
   @jResult    NVARCHAR( MAX) OUTPUT,
   @b_Success  INT = 1        OUTPUT,
   @n_Err      INT = 0        OUTPUT,
   @c_ErrMsg   NVARCHAR( 255) = ''  OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF
BEGIN
	DECLARE
		@cStorerKey   NVARCHAR ( 15),
      @cFacility    NVARCHAR ( 5),
      @nFunc        INT,
      @cBarcode     NVARCHAR( 60),
      @cUserName    NVARCHAR( 30),
      @cLangCode    NVARCHAR( 3),
      @cSKU         NVARCHAR( 30),
      @cScanNo      NVARCHAR( 50)

	--Decode Json Format
   SELECT @cStorerKey = StorerKey, @cFacility = Facility,  @nFunc = Func, @cBarcode = Barcode, @cUserName = UserName, @cLangCode = LangCode, @cScanNo = ScanNo
   FROM OPENJSON(@json)
   WITH (
      StorerKey   NVARCHAR ( 15),
      Facility    NVARCHAR ( 5),
      Func        INT,
      Barcode     NVARCHAR( 60),
      UserName    NVARCHAR( 30),
      LangCode    NVARCHAR( 3),
      ScanNo      NVARCHAR( 50)
   )

   SET @b_Success = 1
   SET @jResult = ''

   --IF LEN(@cBarcode) < 5
   --BEGIN
   --   SET @b_Success = 0
   --   SET @n_Err = 400000
	  -- SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Serial No must be at least 5 characters long.'
   --   SET @jResult = (SELECT '' AS SKU
   --   FOR JSON PATH,INCLUDE_NULL_VALUES ) 
   --   GOTO EXIT_SP
   --END

   -- IF LEFT(@cBarcode, 2) = '00'
   --BEGIN
   --   SET @cBarcode = SUBSTRING(@cBarcode, 3, LEN(@cBarcode))
   --END

   --IF LEN(@cBarcode) > 18
   --BEGIN
   --   SET @b_Success = 0
   --   SET @n_Err = 400000
	  -- SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Serial No must not be more than 18 characters long.'
   --   SET @jResult = (SELECT '' AS SKU
   --   FOR JSON PATH,INCLUDE_NULL_VALUES ) 
   --   GOTO EXIT_SP
   --END

   --IF EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cBarcode)
   --BEGIN
   --   SET @b_Success = 0
   --   SET @n_Err = 400000
	  -- SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Serial No cannot be same as SKU code.'
   --   SET @jResult = (SELECT '' AS SKU
   --   FOR JSON PATH,INCLUDE_NULL_VALUES ) 
   --   GOTO EXIT_SP
   --END

   IF EXISTS (SELECT 1 FROM dbo.StorerConfig WITH (NOLOCK) 
               WHERE StorerKey = @cStorerKey 
               AND configKey = 'ADAllowInsertExistingSerialNo'  
               AND SVALUE='1')
   BEGIN

      IF NOT EXISTS(SELECT 1 FROM SerialNo WITH (NOLOCK)
                  WHERE SerialNo = @cBarcode
                  AND storerKey = @cStorerKey )
      BEGIN
         GOTO PROCEED
      END
      ELSE IF NOT EXISTS(SELECT 1 FROM SerialNo WITH (NOLOCK)
                  WHERE SerialNo = @cBarcode
                  AND storerKey = @cStorerKey 
                  AND ISNULL(orderkey,'')=''
                  AND status='1')
      BEGIN
         GOTO PROCEED
      END
      ELSE
      BEGIN
   	   SET @jResult = (SELECT ISNULL(RTRIM(SKU),'') AS SKU
         FROM SerialNo WITH (NOLOCK)
         WHERE SerialNo = @cBarcode
         AND storerKey = @cStorerKey
         FOR JSON AUTO, INCLUDE_NULL_VALUES)
      END
   END
   ELSE
   BEGIN
      IF EXISTS(SELECT 1 FROM PackSerialNo WITH (NOLOCK)
            WHERE PickSlipNo=@cScanNo    
                  and StorerKey=@cStorerKey    
                  and SerialNo=@cBarcode )
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 400000
	      SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Serial No(' + @cBarcode + ') already been used or exists in PackSerialNo Table.' 
         GOTO EXIT_SP
      END

      IF EXISTS(SELECT 1 FROM SerialNo WITH (NOLOCK)
            WHERE SerialNo = @cBarcode
            AND storerKey = @cStorerKey 
            AND [Status] <> '1')
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 400000
	      SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Serial No(' + @cBarcode + ') already been used or exists in SerialNo Table.'
         GOTO EXIT_SP
      END
   END

PROCEED:
   SET @jResult = (SELECT '' AS SKU
   FOR JSON PATH,INCLUDE_NULL_VALUES)

EXIT_SP:
   SELECT @cStorerKey '@cStorerKey', @cBarcode '@cBarcode', @jResult '@jResult'

END

