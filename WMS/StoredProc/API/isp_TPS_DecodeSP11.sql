SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/******************************************************************************/      
/* Store procedure: isp_TPS_DecodeSP11                                        */      
/* Copyright      : Maersk                                                    */      
/*                                                                            */      
/* Date         Rev  Author      Purposes                                     */      
/* 2026-04-20   1.0  GCH225      FCR-11777 Created                            */ 
/******************************************************************************/      
      
CREATE OR ALTER PROC [API].[isp_TPS_DecodeSP11] (      
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
      @nQPos          INT,
      @nBangPos       INT,
      @cUPCValue    NVARCHAR(100),
      @cEPCValue    NVARCHAR(100)
          
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

   SET @n_Err = 0
   SET @c_ErrMsg = ''
   SET @b_Success = 1     
   SET @cUPCValue = ''
   SET @cEPCValue = ''
     
   IF  CHARINDEX(';', @cBarcode) > 0
   BEGIN
      SET @cUPCValue = LEFT(@cBarcode, CHARINDEX(';', @cBarcode) - 1)
      SET @cEPCValue = RIGHT(@cBarcode, LEN(@cBarcode) - CHARINDEX(';', @cBarcode))
   END
   ELSE
   BEGIN
      SET @cUPCValue = @cBarcode
   END

   SELECT @cSKU = SKU
   FROM UPC (NOLOCK)
   WHERE StorerKey = @cStorerKey
   AND UPC = @cUPCValue

   IF @@ROWCOUNT = 0 OR @cSKU IS NULL OR @cSKU = ''
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 400000
	   SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Not able to find SKU for current UPC('  + @cUPCValue + ').'
      SET @jResult = (SELECT '' AS SKU
                      FOR JSON PATH,INCLUDE_NULL_VALUES 
                      )
      GOTO EXIT_SP
   END

   IF EXISTS ( SELECT 1
               FROM SKU (NOLOCK)
               WHERE StorerKey = @cStorerKey
               AND SKU = @cSKU
               AND BUSR5 = 'Y'
   )
   BEGIN
      IF @cEPCValue = ''
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 400000
         SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Need to scan EPC for this SKU('  + @cSKU + ').' 
         SET @jResult = (SELECT '' AS SKU
                         FOR JSON PATH,INCLUDE_NULL_VALUES 
                         )
         GOTO EXIT_SP
      END
      ELSE
      BEGIN
         IF LEN(@cEPCValue) <> 24
         BEGIN
            SET @b_Success = 0
            SET @n_Err = 400000
            SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'The length of EPC value (' + @cEPCValue + ') is not correct.'
            SET @jResult = (SELECT '' AS SKU
                           FOR JSON PATH,INCLUDE_NULL_VALUES 
                           )
            GOTO EXIT_SP
         END
      END
   END
   ELSE
   BEGIN
      IF @cEPCValue <> ''
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 400000
         SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Current SKU('  + @cSKU + ') does not require EPC scan, but got EPC value (' + @cEPCValue + ').' 
         SET @jResult = (SELECT '' AS SKU
                         FOR JSON PATH,INCLUDE_NULL_VALUES 
                         )
         GOTO EXIT_SP
      END
   END

   SET @jResult =  JSON_QUERY('[{"SKU":"' + @cSKU + '"}]')
EXIT_SP:
END    
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
