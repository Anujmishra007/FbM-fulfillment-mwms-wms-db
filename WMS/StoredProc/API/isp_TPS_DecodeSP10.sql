SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/******************************************************************************/      
/* Store procedure: isp_TPS_DecodeSP10                                        */      
/* Copyright      : Maersk                                                    */      
/*                                                                            */      
/* Date         Rev  Author      Purposes                                     */      
/* 2025-09-17   1.0  GCH225      FCR-7558 Created                             */ 
/******************************************************************************/      
      
CREATE OR ALTER PROC [API].[isp_TPS_DecodeSP10] (      
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
      @cFirstValue     NVARCHAR(100),
      @cSecondValue    NVARCHAR(100)
          
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
     
   SET @nQPos = CHARINDEX('?', @cBarcode);
   SET @nBangPos = CHARINDEX('!', @cBarcode);

   IF @nQPos = 0 OR @nBangPos = 0 OR @nQPos > @nBangPos
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 400000
	   SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Invalid format: must contain "?" before "!".' 
      SET @jResult = (SELECT '' AS SKU
                      FOR JSON PATH,INCLUDE_NULL_VALUES 
                      )
      GOTO EXIT_SP
   END

   --SerialNo
   SET @cFirstValue = SUBSTRING(@cBarcode, @nQPos + 1, @nBangPos - @nQPos - 1)
   
   --UPC
   SET @cSecondValue = SUBSTRING(@cBarcode, @nBangPos + 1, LEN(@cBarcode) - @nBangPos)

   IF NOT EXISTS(SELECT 1
      FROM UPC (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND UPC = @cSecondValue
   )
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 400000
	   SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Current UPC('  + @cSecondValue + ') is not found in UPC table.' 
      SET @jResult = (SELECT '' AS SKU
                      FOR JSON PATH,INCLUDE_NULL_VALUES 
                      )
      GOTO EXIT_SP
   END

   IF(SELECT COUNT(1) 
      FROM UPC (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND UPC = @cSecondValue
   ) > 1
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 400000
	   SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Current UPC('  + @cSecondValue + ') contains more than 1 SKUs. Failed to proceed decode and get the right SKU.' 
      SET @jResult = (SELECT '' AS SKU
                      FOR JSON PATH,INCLUDE_NULL_VALUES 
                      )
      GOTO EXIT_SP
   END

   SET @jResult =  ( SELECT ISNULL(RTRIM(SKU),'') AS SKU
                     FROM UPC (NOLOCK) 
                     WHERE StorerKey = @cStorerKey
                     AND UPC = @cSecondValue
                     FOR JSON AUTO, INCLUDE_NULL_VALUES)
EXIT_SP:
END    
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
