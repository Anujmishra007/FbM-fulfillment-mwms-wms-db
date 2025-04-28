SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: isp_TPS_DecodeSP05                                        */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2023-05-17   1.0  yeekung   TPS-703 Created                                */
/* 2025-01-16   1.1  yeekung   UWP-28824 Correct the QTY when cast to JSON    */ 
/******************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPS_DecodeSP05] (
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
      @cUPC         NVARCHAR( 20),
      @cPackKey     NVARCHAR( 20),
      @cPackUOM     NVARCHAR( 20),
      @cPickslipno  NVARCHAR( 20),
      @cOrderkey    NVARCHAR( 20)

	--Decode Json Format
   SELECT @cStorerKey = StorerKey, @cFacility = Facility,  @nFunc = Func, @cPickslipno=ScanNo,@cBarcode = Barcode, @cUserName = UserName, @cLangCode = LangCode
   FROM OPENJSON(@json)
   WITH (
      StorerKey   NVARCHAR ( 15),
      Facility    NVARCHAR ( 5),
      Func        INT,
      ScanNo      NVARCHAR( 20),
      Barcode     NVARCHAR( 60),
      UserName    NVARCHAR( 30),
      LangCode    NVARCHAR( 3)
   )

   select @cOrderkey = orderkey
   FROM Pickheader (nolock)
   Where pickheaderkey = @cPickslipno

   SET @b_Success = 1

   -- Get SKU count        

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
                        CAST (CASE @cPackUOM  
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
   ELSE
   BEGIN

      IF EXISTS (SELECT 1 FROM dbo.StorerConfig WITH (NOLOCK) 
                  WHERE StorerKey = @cStorerKey 
                  AND configKey = 'ADAllowInsertExistingSerialNo'  
                  AND SVALUE='1')
      BEGIN

         IF NOT EXISTS(SELECT 1 FROM SerialNo WITH (NOLOCK)
                     WHERE SerialNo = @cBarcode
                     AND storerKey = @cStorerKey )
         BEGIN
            SET @jResult = (SELECT '' AS SKU
            FOR JSON PATH,INCLUDE_NULL_VALUES)
         END
         ELSE IF NOT EXISTS(SELECT 1 FROM SerialNo WITH (NOLOCK)
                     WHERE SerialNo = @cBarcode
                     AND storerKey = @cStorerKey 
                     AND ISNULL(orderkey,'')=''
                     AND status='1')
         BEGIN
            SET @n_Err = 1000101
	         SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Err Insert Duplicate SerialNO'

            SET @jResult = (SELECT '' AS SKU
            FOR JSON PATH,INCLUDE_NULL_VALUES )    
            SET @b_Success = 0
         END
         ELSE
         BEGIN
            SELECT @cUPC =  UserDefine02
            FROM SerialNo WITH (NOLOCK)
            WHERE SerialNo = @cBarcode
            AND storerKey = @cStorerKey

            IF ISNULL(@cUPC,'')=''
            BEGIN
            
   	        SET @jResult = (SELECT ISNULL(RTRIM(SKU),'') AS SKU,@cBarcode AS Serialno
               FROM SerialNo WITH (NOLOCK)
               WHERE SerialNo = @cBarcode
               AND storerKey = @cStorerKey
               FOR JSON AUTO, INCLUDE_NULL_VALUES)
            END
            ELSE
            BEGIN

   	        SET @jResult = (SELECT ISNULL(RTRIM(SKU),'') AS SKU,@cBarcode AS Serialno
               FROM UPC WITH (NOLOCK)
               WHERE UPC = @cUPC
               AND storerKey = @cStorerKey
               FOR JSON AUTO, INCLUDE_NULL_VALUES)
            END
         END
      END
      ELSE
      BEGIN
         IF NOT EXISTS(SELECT 1 FROM SerialNo WITH (NOLOCK)
               WHERE SerialNo = @cBarcode
               AND storerKey = @cStorerKey )
         BEGIN
            SET @jResult = (SELECT '' AS SKU
            FOR JSON PATH,INCLUDE_NULL_VALUES)
         END

         IF EXISTS (SELECT 1 FROM SerialNo WITH (NOLOCK)
               WHERE SerialNo = @cBarcode
               AND storerKey = @cStorerKey )
         BEGIN
            SET @n_Err = 1000101
	         SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Err Insert Duplicate SerialNO'

            SET @jResult = (SELECT '' AS SKU
            FOR JSON PATH,INCLUDE_NULL_VALUES )    
            SET @b_Success = 0
         END
      END
   END


   SELECT @cStorerKey '@cStorerKey', @cBarcode '@cBarcode', @jResult '@jResult'
QUIT:
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_DecodeSP05 TO NSQL
GO


