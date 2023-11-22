/****** Object:  StoredProcedure [API].[isp_TPS_DecodeSP03]    Script Date: 6/3/2020 4:50:51 PM ******/

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
    
    
/******************************************************************************/      
/* Store procedure: isp_TPS_DecodeSP03                                        */      
/* Copyright      : LFLogistics                                               */      
/*                                                                            */      
/* Date         Rev  Author     Purposes                                      */      
/* 2022-02-15   1.0  yeekung  WMS-17771 Created                               */ 
/* 2023-09-13   1.1  YeeKung  TPS-792 DefaultQTY              (yeekung01)     */
/******************************************************************************/      
      
CREATE OR ALTER PROC [API].[isp_TPS_DecodeSP03] (      
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
     
 DECLARE @n_Foundpos INT,      
    @n_LastFoundpos INT      
    
   SET @n_Foundpos = 0      
   SET @n_LastFoundpos = 0    
     
   WHILE 1=1      
   BEGIN      
      SELECT @n_Foundpos = CHARINDEX('/', @cBarcode, @n_Foundpos + 1)      
            
      IF @n_Foundpos > 0       
         SET @n_LastFoundpos = @n_Foundpos      
      ELSE      
         BREAK              
   END       
         
   IF @n_LastFoundpos > 0      
      SELECT @jResult = SUBSTRING(@cBarcode, @n_LastFoundpos + 1, LEN(@cBarcode) - @n_LastFoundpos)      
   ELSE      
      SELECT @jResult = @cBarcode     
  
   IF NOT EXISTS(SELECT 1 FROM SerialNo WITH (NOLOCK)    
            WHERE SerialNo = @jResult    
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
      SET @jResult = (SELECT '' AS SKU  
      FOR JSON PATH,INCLUDE_NULL_VALUES)  
   END  
   ELSE  
   BEGIN  
    SET @jResult = (SELECT ISNULL(RTRIM(SKU),'') AS SKU,1 AS QTY  
      FROM SerialNo WITH (NOLOCK)  
      WHERE SerialNo = @cBarcode  
      AND storerKey = @cStorerKey  
      FOR JSON AUTO, INCLUDE_NULL_VALUES)  
   END
    
    
   --IF LEN(@jResult) = 0      
   --BEGIN      
   --  SET @jResult = (SELECT '' AS SKU    
   --      FOR JSON PATH,INCLUDE_NULL_VALUES)    
   --END    
   --ELSE IF LEN(@jResult) > 30      
   --BEGIN      
   --   SET @jResult = (SELECT '' AS SKU    
   --   FOR JSON PATH,INCLUDE_NULL_VALUES)    
   --END      
    
   SET @n_Err = 0    
   SET @c_ErrMsg = ''    
       
   --SELECT @cStorerKey '@cStorerKey', @cBarcode '@cBarcode', @jResult '@jResult'    
       
END    
    
    
SET QUOTED_IDENTIFIER OFF 