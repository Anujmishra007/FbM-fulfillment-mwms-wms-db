SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: isp_TPS_ExtValidP10                                       */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date         Rev  Author      Purposes                                     */
/* 2024-05-08   1.0  GhChan      FCR-5168 Cloned from isp_TPS_ExtValidP10     */
/******************************************************************************/

CREATE  OR ALTER PROC [API].[isp_TPS_ExtValidP10] (
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
		@cStorerKey    NVARCHAR ( 15),
      @cFacility     NVARCHAR ( 5),
      @nFunc         INT,
      @cBarcode      NVARCHAR( 60),
      @cUserName     NVARCHAR( 30),
      @cLangCode     NVARCHAR( 3),
      @cScanNo       NVARCHAR( 50),
      @cSku          NVARCHAR(20),
      @cOrderKey     NVARCHAR(10),
      @cStatus       NVARCHAR(10),
      @cSerialNoSku  NVARCHAR(20)

	--Decode Json Format
   SELECT @cStorerKey = StorerKey, @cFacility = Facility,  @nFunc = Func, @cBarcode = Barcode, @cUserName = UserName, @cLangCode = LangCode, @cScanNo = ScanNo, @cSku = Sku
   FROM OPENJSON(@json)
   WITH (
      StorerKey   NVARCHAR ( 15),
      Facility    NVARCHAR ( 5),
      Func        INT,
      Barcode     NVARCHAR( 60),
      UserName    NVARCHAR( 30),
      LangCode    NVARCHAR( 3),
      ScanNo      NVARCHAR( 50),
      Sku         NVARCHAR(20)
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
   --IF EXISTS (SELECT 1 FROM dbo.StorerConfig WITH (NOLOCK) 
   --            WHERE StorerKey = @cStorerKey 
   --            AND configKey = 'ADAllowInsertExistingSerialNo'  
   --            AND SVALUE='1')
   --BEGIN

   --   IF NOT EXISTS(SELECT 1 FROM SerialNo WITH (NOLOCK)
   --               WHERE SerialNo = @cBarcode
   --               AND storerKey = @cStorerKey )
   --   BEGIN
   --      GOTO PROCEED
   --   END
   --   ELSE IF NOT EXISTS(SELECT 1 FROM SerialNo WITH (NOLOCK)
   --               WHERE SerialNo = @cBarcode
   --               AND storerKey = @cStorerKey 
   --               AND ISNULL(orderkey,'')=''
   --               AND status='1')
   --   BEGIN
   --      GOTO PROCEED
   --   END
   --   ELSE
   --   BEGIN
   --	   SET @jResult = (SELECT ISNULL(RTRIM(SKU),'') AS SKU
   --      FROM SerialNo WITH (NOLOCK)
   --      WHERE SerialNo = @cBarcode
   --      AND storerKey = @cStorerKey
   --      FOR JSON AUTO, INCLUDE_NULL_VALUES)
   --   END
   --END
   --ELSE
   --BEGIN

   IF @cSku = ''
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 400000
	   SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Sku cannot be empty or null.' 
      GOTO EXIT_SP
   END

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

   SELECT @cSerialNoSku = ISNULL(Sku,'')
         ,@cStatus =[Status]
         ,@cOrderKey =ISNULL(OrderKey,'')
   FROM SerialNo WITH (NOLOCK)
   WHERE SerialNo = @cBarcode
      AND storerKey = @cStorerKey

   IF @@ROWCOUNT = 0
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 400000
	   SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Invalid Serial No(' + @cBarcode + '), SerialNo not found in SerialNo Table.'
      GOTO EXIT_SP
   END
   ELSE
   BEGIN
      IF @cSku <> @cSerialNoSku
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 400000
	      SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Current Serial No(' + @cBarcode + ') not match with Sku(' + @cSerialNoSku + ') in SerialNo Table.'
         GOTO EXIT_SP
      END

      IF @cOrderKey <> '' OR @cStatus <> '1'
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 400000
	      SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Serial No(' + @cBarcode + ') already been used in SerialNo Table.'
         GOTO EXIT_SP
      END
   END    
   
   --END

PROCEED:
   SET @jResult = (SELECT '' AS SKU
   FOR JSON PATH,INCLUDE_NULL_VALUES)

EXIT_SP:
   SELECT @cStorerKey '@cStorerKey', @cBarcode '@cBarcode', @jResult '@jResult'

END

