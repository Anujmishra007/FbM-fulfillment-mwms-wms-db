SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: isp_TPS_DecodeSP01                                        */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2021-09-22   1.0  Chermaine  TPS-616 Created                               */
/* 2023-06-23   1.1  YeeKung    TPS-734 Add Duplicate sNo Valid (yeekung01)   */
/* 2024-02-20   1.2  YeeKung    TPS-888 Add SKU decode and QTY (yeekung02)    */
/******************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPS_DecodeSP01] (
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
      @cPrevBarcodeJson NVARCHAR( MAX)

	--Decode Json Format
   SELECT @cStorerKey = StorerKey, @cFacility = Facility,  @nFunc = Func, @cBarcode = Barcode, @cUserName = UserName, @cLangCode = LangCode,
      @cPrevBarcodeJson = PreviousBarcode
   FROM OPENJSON(@json)
   WITH (
      StorerKey   NVARCHAR ( 15),
      Facility    NVARCHAR ( 5),
      Func        INT,
      Barcode     NVARCHAR( 60),
      UserName    NVARCHAR( 30),
      LangCode    NVARCHAR( 3),
      PreviousBarcode    NVARCHAR( max) as json 
   )

   SET @b_Success = 1

   IF EXISTS ( SELECT 1
               FROM OPENJSON(@cPrevBarcodeJson)
                WITH (
                     PreviousBarcode    NVARCHAR( max) '$.PreviousBarcode' AS JSON --(cc09)  
                     )
               WHERE PreviousBarcode = @cBarcode
            )
   BEGIN
      SET @n_Err = 400000
	   SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Err Insert Duplicate SerialNO'

      SET @jResult = (SELECT '' AS SKU
      FOR JSON PATH,INCLUDE_NULL_VALUES )    
      SET @b_Success = 0
   END

   IF EXISTS (SELECT 1 FROM dbo.StorerConfig WITH (NOLOCK) 
               WHERE StorerKey = @cStorerKey 
               AND configKey = 'ADAllowInsertExistingSerialNo'  
               AND SVALUE='1')
   BEGIN

      IF NOT EXISTS(SELECT 1 FROM SerialNo WITH (NOLOCK)
                  WHERE SerialNo = @cBarcode
                  AND storerKey = @cStorerKey )
      BEGIN
         SET @jResult = (SELECT @cBarcode AS SKU, 1 AS QTY --yeekung02
         FOR JSON PATH,INCLUDE_NULL_VALUES)
      END
      ELSE IF NOT EXISTS(SELECT 1 FROM SerialNo WITH (NOLOCK)
                  WHERE SerialNo = @cBarcode
                  AND storerKey = @cStorerKey 
                  AND ISNULL(orderkey,'')=''
                  AND status='1')
      BEGIN
         SET @jResult = (SELECT '' AS SKU
         FOR JSON PATH,INCLUDE_NULL_VALUES)
      END
      ELSE
      BEGIN
   	   SET @jResult = (SELECT ISNULL(RTRIM(SKU),'') AS SKU
         FROM SerialNo WITH (NOLOCK)
         WHERE SerialNo = @cBarcode
         AND storerKey = @cStorerKey
         FOR JSON AUTO, INCLUDE_NULL_VALUES)
      END

      SET @n_Err = 0
	   SET @c_ErrMsg = ''
   END
   ELSE
   BEGIN
      IF NOT EXISTS(SELECT 1 FROM SerialNo WITH (NOLOCK)
            WHERE SerialNo = @cBarcode
            AND storerKey = @cStorerKey )
      BEGIN
         SET @jResult = (SELECT @cBarcode AS SKU, 1 AS QTY --yeekung02
         FOR JSON PATH,INCLUDE_NULL_VALUES)
      END

      IF EXISTS (SELECT 1 FROM SerialNo WITH (NOLOCK)
            WHERE SerialNo = @cBarcode
            AND storerKey = @cStorerKey )
      BEGIN
         SET @n_Err = 400000
	      SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Err Insert Duplicate SerialNO'

         SET @jResult = (SELECT '' AS SKU
         FOR JSON PATH,INCLUDE_NULL_VALUES )    
         SET @b_Success = 0
      END
   END


   SELECT @cStorerKey '@cStorerKey', @cBarcode '@cBarcode', @jResult '@jResult'

END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_DecodeSP01 TO NSQL
GO


