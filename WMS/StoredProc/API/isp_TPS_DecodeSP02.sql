SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  StoredProcedure [API].[isp_TPS_DecodeSP02]    Script Date: 6/3/2020 4:50:51 PM ******/


/******************************************************************************/
/* Store procedure: isp_TPS_DecodeSP02                                        */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2021-10-04   1.0  Chermaine  TPS-597 Created                               */
/* 2023-09-13   1.1  YeeKung    TPS-792 DefaultQTY              (yeekung01)   */
/******************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPS_DecodeSP02] (
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

   IF(LEFT(RIGHT(@cBarcode, 14), 3) = '240')
   BEGIN
    SELECT @cSKU = SUBSTRING(RIGHT(@cBarcode, 14), 4, 11)
   END


	--SET @jResult = '[{"SKU":"' + @cSKU + '"}]'
	SET @jResult = (SELECT ISNULL(@cSKU,'') AS SKU,1 AS QTY
      FOR JSON PATH,INCLUDE_NULL_VALUES)
	SET @n_Err = 0
	SET @c_ErrMsg = ''


   --SELECT @cStorerKey '@cStorerKey', @cBarcode '@cBarcode', @cSKU '@cSKU'

END


SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_DecodeSP02 TO NSQL
GO


