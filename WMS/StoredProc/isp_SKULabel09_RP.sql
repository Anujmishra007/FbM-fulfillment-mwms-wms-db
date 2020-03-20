IF EXISTS (SELECT name FROM sysobjects WHERE name = 'isp_SKULabel09_RP' AND type = 'P')
   DROP PROC isp_SKULabel09_RP
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/
/* Store Procedure:  isp_SKULabel09_RP                                  */
/*                                                                      */
/* Copyright: IDS                                                       */
/*                                                                      */
/* Purpose:  Receiving SKU label                                        */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver   Purposes                                  */
/* 10-Oct-2018  Ung     1.0   WMS-6462 Created                          */
/* 17-Oct-2019  James   1.1   WMS-10894 Add username (james01)          */
/************************************************************************/
CREATE PROC [dbo].[isp_SKULabel09_RP] (
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

   DECLARE @cFromLOC       NVARCHAR( 10)
   DECLARE @cSKU           NVARCHAR( 20)
   DECLARE @cLottable01    NVARCHAR( 18)
   DECLARE @cSuggestedLOC  NVARCHAR( 10)

   -- Parameter mapping
   SET @cFromLOC = @cByRef1
   SET @cSKU = @cByRef2
   SET @cLottable01 = @cByRef3
   SET @cSuggestedLOC = @cByRef4

   SET @cPrintData = ''

   SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field01>', RTRIM( @cSKU))  
   SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field02>', SUBSTRING( RTRIM( @cSuggestedLOC), 1, 3))  
   SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field03>', SUBSTRING( RTRIM( @cSuggestedLOC), 4, 3))  
   SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field04>', SUBSTRING( RTRIM( @cSuggestedLOC), 7, 2))  
   SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field05>', SUBSTRING( RTRIM( @cSuggestedLOC), 9, 1))  
   SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field06>', SUBSTRING( RTRIM( @cSuggestedLOC), 10, 1))  
   SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field07>', RTRIM( @cFromLOC))  
   SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field08>', RTRIM( @cLottable01))  
   SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field09>', RIGHT( SUSER_SNAME(), 4))  -- (james01)

   IF ISNULL( @cPrintTemplate, '') <> ''
      SET @cPrintData = @cPrintTemplate  
END
GO
GRANT EXECUTE ON isp_SKULabel09_RP TO NSQL 
GO   

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
