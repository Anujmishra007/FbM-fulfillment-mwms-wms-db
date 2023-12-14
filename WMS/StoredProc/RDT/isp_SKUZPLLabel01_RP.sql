SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO 
/************************************************************************/  
/* Store Procedure:  isp_SKUZPLLabel01_RP                               */  
/*                                                                      */  
/* Copyright: MAERSK                                                    */  
/*                                                                      */  
/* Purpose:  Print SKU ZPL label                                        */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author  Ver   Purposes                                  */  
/* 2023-11-15   James   1.0   WMS-24148. Created                        */  
/************************************************************************/  
CREATE OR ALTER   PROC [dbo].[isp_SKUZPLLabel01_RP] (  
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
   @cErrMsg     NVARCHAR( 20)  OUTPUT,  -- screen limitation, 20 char max 
   @cCodePage   NVARCHAR( 50)  OUTPUT
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   SET @cPrintData = ''  
  
   SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field01>', RTRIM( @cByRef1))   -- EXTERNORDERKEY  
   SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field02>', RTRIM( @cByRef2))   -- SKU  
  
   IF ISNULL( @cPrintTemplate, '') <> ''  
      SET @cPrintData = @cPrintTemplate  
  
   SET @cCodePage = '850'

END  

GO
GRANT EXECUTE ON isp_SKUZPLLabel01_RP TO NSQL 
GO   

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO