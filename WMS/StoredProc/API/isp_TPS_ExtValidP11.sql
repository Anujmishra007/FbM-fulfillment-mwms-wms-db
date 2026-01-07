SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: isp_TPS_ExtValidP11                                       */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date         Rev  Author      Purposes                                     */
/* 2025-08-27   1.0  GCH225      FCR-7558 Created                             */
/* 2025-09-30   2.0  GCH225     FCR-8274 Allow Update Return Serialno         */ 
/******************************************************************************/

CREATE  OR ALTER PROC [API].[isp_TPS_ExtValidP11] (
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
      @cSerialNoSku  NVARCHAR(20),
      @nQPos          INT,
      @nBangPos       INT,
      @cFirstValue     NVARCHAR(100),
      @cSecondValue    NVARCHAR(100)


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

   SET @b_Success = 0
   SET @jResult = ''

   IF @cSku = ''
   BEGIN
      SET @n_Err = 400000
	   SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Sku cannot be empty or null.' 
      GOTO EXIT_SP
   END

   SET @nQPos = CHARINDEX('?', @cBarcode);
   SET @nBangPos = CHARINDEX('!', @cBarcode);

   IF @nQPos = 0 OR @nBangPos = 0 OR @nQPos > @nBangPos
   BEGIN
      SET @n_Err = 400000
	   SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Invalid format: must contain "?" before "!".' 
      GOTO EXIT_SP
   END

   --SerialNo
   SET @cFirstValue = SUBSTRING(@cBarcode, @nQPos + 1, @nBangPos - @nQPos - 1)
   
   --UPC
   SET @cSecondValue = SUBSTRING(@cBarcode, @nBangPos + 1, LEN(@cBarcode) - @nBangPos)

   
   IF NOT EXISTS( SELECT 1 
                  FROM UPC (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND SKU = @cSKU
                  AND UPC = @cSecondValue
   )
   BEGIN
      SET @n_Err = 400000
	   SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Invalid QR Code: UPC('  + @cSecondValue + ') with current SKU does not found in UPC table.' 
      GOTO EXIT_SP
   END

   IF EXISTS(SELECT 1 
             FROM PackSerialNo WITH (NOLOCK)
             WHERE PickSlipNo = @cScanNo    
               AND StorerKey = @cStorerKey    
               AND SerialNo = @cFirstValue 
               AND SKU = @cSku)
   BEGIN
      SET @n_Err = 400000
	   SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Serial No(' + @cFirstValue + ') already been used or exists in PackSerialNo Table.' 
      GOTO EXIT_SP
   END

   SELECT @cSerialNoSku = ISNULL(Sku,'')
         ,@cStatus =[Status]
         ,@cOrderKey =ISNULL(OrderKey,'')
   FROM SerialNo WITH (NOLOCK)
   WHERE SerialNo = @cFirstValue
   AND StorerKey = @cStorerKey

   IF @@ROWCOUNT <> 0
   BEGIN
      IF @cSku <> @cSerialNoSku
      BEGIN
         SET @n_Err = 400000
	      SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Current Serial No(' + @cFirstValue + ') not match with Sku(' + @cSerialNoSku + ') in SerialNo Table.'
         GOTO EXIT_SP
      END

      IF EXISTS (SELECT 1 
                 FROM SKU (NOLOCK)
                 WHERE StorerKey = @cStorerKey
                 AND SKU = @cSku
                 AND SerialNoCapture = '3'
                 AND SUSR4 = 'AD'
      )
      BEGIN
         --if Status '1' means new SerialNo, can proceed. 
         --if Status '9' or 'CANC' means either return or cancel order, can proceed too.
         IF @cStatus NOT IN ('1','9','CANC')
         BEGIN
            SET @n_Err = 400000
	         SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Serial No(' + @cFirstValue + ') already been used in SerialNo Table.'
            GOTO EXIT_SP
         END
      END
      ELSE
      BEGIN
         --if Status '1' means new SerialNo, can proceed.
         IF @cStatus NOT IN ('1')
         BEGIN
            SET @n_Err = 400000
	         SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Serial No(' + @cFirstValue + ') already been used in SerialNo Table.'
            GOTO EXIT_SP
         END
      END
   END

   SET @b_Success = 1
   SET @jResult = (SELECT '' AS SKU
   FOR JSON PATH,INCLUDE_NULL_VALUES)

EXIT_SP:
   SELECT @cStorerKey '@cStorerKey', @cBarcode '@cBarcode', @jResult '@jResult'

END

