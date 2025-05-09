



SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: isp_TPS_DecodeSP08                                        */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2024-12-13   1.0  yeekung   TPS-949 Created                                */
/******************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPS_DecodeSP08] (
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
      @cPackKey     NVARCHAR( 20),
      @cPackUOM     NVARCHAR( 20)

	--Decode Json Format
   SELECT @cStorerKey = StorerKey, @cFacility = Facility,  @nFunc = Func, @cBarcode = Barcode, @cUserName = UserName, @cLangCode = LangCode
   FROM OPENJSON(@json)
   WITH (
      StorerKey   NVARCHAR ( 15),
      Facility    NVARCHAR ( 5),
      Func        INT,
      Barcode     NVARCHAR( 60),
      UserName    NVARCHAR( 30),
      LangCode    NVARCHAR( 3)
   )

   SET @b_Success = 1

   IF EXISTS (SELECT 1  from SKU (nolock) 
               where ( ManufacturerSku = @cBarcode
                     OR RetailSKU = @cBarcode
                     OR AltSKU = @cBarcode)
               AND storerkey=@cStorerKey)
   BEGIN
      IF LEFT(@cBarcode,2) <> '69'
      BEGIN
         SET @n_Err = 1000651
	      SET @c_ErrMsg =  API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'1000651 Err Scan UPC Barcode : isp_TPS_DecodeSP08'  

         SET @jResult = (SELECT '' AS SKU
         FOR JSON PATH,INCLUDE_NULL_VALUES )    
         SET @b_Success = 0
         GOTO QUIT
      END

      SET @jResult =  (SELECT ISNULL(RTRIM(SKU),'') AS SKU
                 from SKU (nolock) 
               where ( ManufacturerSku = @cBarcode
                     OR RetailSKU = @cBarcode
                     OR AltSKU = @cBarcode)
               AND storerkey=@cStorerKey
               FOR JSON AUTO, INCLUDE_NULL_VALUES)
   END
   ELSE
   BEGIN
      SET @n_Err = 1000652
	   SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'1000652 Err Must Scan UPC Barcode : isp_TPS_DecodeSP08'  

      SET @jResult = (SELECT '' AS SKU
      FOR JSON PATH,INCLUDE_NULL_VALUES )    
      SET @b_Success = 0
      GOTO QUIT
   END


   QUIT:
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_DecodeSP08 TO NSQL
GO



