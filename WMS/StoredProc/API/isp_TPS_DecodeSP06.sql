SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: isp_TPS_DecodeSP06                                        */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2023-09-13   1.0  yeekung   TPS-792 Created                                */
/* 2025-01-16   1.1  yeekung   UWP-31516 Correct the QTY when cast to JSON    */ 
/******************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPS_DecodeSP06] (
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

   IF EXISTS (SELECT 1  from UPC (nolock) 
               where UPC=@cBarcode
               AND storerkey=@cStorerKey)
   BEGIN
      SELECT @cSKU = SKU,
             @cPackUOM = UOM,
             @cPackKey = packkey
      from UPC (nolock) 
      where UPC=@cBarcode
      AND storerkey=@cStorerKey

      SET @jResult = ( SELECT
                  @cSKU AS SKU,
               CAST ( CASE @cPackUOM
                  WHEN Pack.PackUOM1  THEN Pack.CaseCNT
                  WHEN Pack.PackUOM2 THEN Pack.InnerPack
                  WHEN Pack.PackUOM3 THEN Pack.QTY
                  WHEN Pack.PackUOM4 THEN Pack.Pallet
                  WHEN Pack.PackUOM8 THEN Pack.OtherUnit1
                  WHEN Pack.PackUOM9 THEN Pack.OtherUnit2
               ELSE 1 END AS INT) AS QTY 
         FROM dbo.Pack Pack WITH (NOLOCK) 
         WHERE packkey= @cPackKey
      FOR JSON AUTO, INCLUDE_NULL_VALUES)   
   END
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_DecodeSP06 TO NSQL
GO


