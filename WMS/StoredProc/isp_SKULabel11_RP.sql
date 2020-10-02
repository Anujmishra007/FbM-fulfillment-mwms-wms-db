IF EXISTS (SELECT name FROM sysobjects WHERE name = 'isp_SKULabel11_RP' AND type = 'P')
   DROP PROC isp_SKULabel11_RP
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store Procedure:  isp_SKULabel11_RP                                  */
/* Copyright: LF logistics                                              */
/*                                                                      */
/* Purpose:  Receiving SKU label                                        */
/*                                                                      */
/* Date         Author  Ver   Purposes                                  */
/* 06-May-2020  Ung     1.0   WMS-13140 Created                         */
/************************************************************************/
CREATE PROC [dbo].[isp_SKULabel11_RP] (
   @nMobile     INT,   
   @nFunc       INT,   
   @cLangCode   NVARCHAR( 3),   
   @cStorerKey  NVARCHAR( 15),   
   @cByRef1     NVARCHAR( 20),   
   @cByRef2     NVARCHAR( 20),   
   @cByRef3     NVARCHAR( 20),   
   @cByRef4     NVARCHAR( 20),   
   @cByRef5     NVARCHAR( 20),   
   @cByRef6     NVARCHAR( 20),   
   @cByRef7     NVARCHAR( 20),   
   @cByRef8     NVARCHAR( 20),   
   @cByRef9     NVARCHAR( 20),   
   @cByRef10    NVARCHAR( 20),   
   @cPrintTemplate NVARCHAR( MAX),   
   @cPrintData  NVARCHAR( MAX) OUTPUT,  
   @nErrNo      INT            OUTPUT,  
   @cErrMsg     NVARCHAR( 20)  OUTPUT  -- screen limitation, 20 char max     
) 
AS
BEGIN
   SET NOCOUNT ON   
   SET QUOTED_IDENTIFIER OFF   
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @cReceiptKey        NVARCHAR( 10)
   DECLARE @cReceiptLineNumber NVARCHAR( 5)
   DECLARE @cSKU               NVARCHAR( 20)
   DECLARE @cUDF09             NVARCHAR( 10)
   DECLARE @cToLOC             NVARCHAR( 10)
   DECLARE @cLottable01        NVARCHAR( 18)
   DECLARE @nPackQTYIndicator  INT

   SET @cPrintData = ''

   -- Parameter mapping
   SET @cReceiptKey = @cByRef1
   SET @cReceiptLineNumber = @cByRef2

   -- Get receipt info
   DECLARE @cProcessType NVARCHAR(1)
   SELECT @cProcessType = ISNULL( ProcessType, '')
   FROM Receipt WITH (NOLOCK)
   WHERE ReceiptKey = @cReceiptKey

   IF @cProcessType = 'N'
   BEGIN
      -- Get Receipt detail info
      SELECT 
         @cSKU = SKU, 
         @cUDF09 = UserDefine09, 
         @cToLOC = ToLOC, 
         @cLottable01 = Lottable01
      FROM ReceiptDetail WITH (NOLOCK)
      WHERE ReceiptKey = @cReceiptKey
         AND ReceiptLineNumber = @cReceiptLineNumber
      
      -- Get SKU info
      SELECT @nPackQTYIndicator = PackQTYIndicator FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU

      SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field01>', RTRIM( @cSKU))  
      SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field02>', SUBSTRING( RTRIM( @cUDF09), 1, 3))  
      SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field03>', SUBSTRING( RTRIM( @cUDF09), 4, 3))  
      SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field04>', SUBSTRING( RTRIM( @cUDF09), 7, 2))  
      SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field05>', SUBSTRING( RTRIM( @cUDF09), 9, 1))  
      SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field06>', SUBSTRING( RTRIM( @cUDF09), 10, 1))  
      SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field07>', RTRIM( @cToLOC))  
      SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field08>', RTRIM( @cLottable01))  
      SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field09>', RIGHT( SUSER_SNAME(), 4))
      SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field10>', RTRIM( CAST( @nPackQTYIndicator AS NVARCHAR(2))))
      
      SET @cPrintData = @cPrintTemplate  
   END
   ELSE
      SET @nErrNo = -1 -- No print and skip err message
END
GO
GRANT EXECUTE ON isp_SKULabel11_RP TO NSQL 
GO   

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
