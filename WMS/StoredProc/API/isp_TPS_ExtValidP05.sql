
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: isp_TPS_ExtValidP05                                       */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2024-12-23    1.0  YeeKung  FCR_1822 Created                                */
/******************************************************************************/

CREATE  OR ALTER PROC [API].[isp_TPS_ExtValidP05] (
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
      @cSKU         NVARCHAR( 30)

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

   IF SUBSTRING(@cBarcode,1,1) NOT IN ('Y','y') OR LEN(@cBarcode) <> 18
   BEGIN
      SET @n_Err = 1009999
      SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Err SerialNO format'

      SET @jResult = (SELECT '' AS SKU
      FOR JSON PATH,INCLUDE_NULL_VALUES )    
      SET @b_Success = 0
         
   END
   ELSE
   BEGIN
      SET @jResult = (SELECT @cBarcode AS SerialNo
      FOR JSON PATH,INCLUDE_NULL_VALUES )    
         SET @b_Success = 1
   END



   SELECT @cStorerKey '@cStorerKey', @cBarcode '@cBarcode', @jResult '@jResult'

END

