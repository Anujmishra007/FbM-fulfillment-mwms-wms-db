SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store Procedure: isp_SKULabel14_RP                                   */
/* Copyright: IDS                                                       */
/*                                                                      */
/* Purpose:  Receiving SKU label                                        */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver   Purposes                                  */
/* 01-08-2024   YeeKung 1.0   WMS-25947 Created                         */
/* 24-03-2025   YeeKung 1.1   FCR-4281 Add Column 6   (yeekung01)       */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_SKULabel14_RP] (
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

   DECLARE @cQTY           NVARCHAR( 20)
   DECLARE @cSKU           NVARCHAR( 60)
   DECLARE @cSusr1         NVARCHAR( 20)
   DECLARE @cRetailSKU      NVARCHAR( 20)
   DECLARE @cSusr2         NVARCHAR( 20)
   DECLARE @cSusr4         NVARCHAR( 20)
   DECLARE @cSusr6         NVARCHAR( 20)
   DECLARE @cNotes2        NVARCHAR( 120)

   SET @cSKU=@cByRef2
   SET @cQTY=@cByRef1

   SET @cPrintData = ''

   IF ISNULL( @cPrintTemplate, '') <> ''
   BEGIN

      SELECT @cSusr1 =Susr1,
             @cSusr2 = Susr2,
             @cSusr4 = Susr4,
             @cSusr6 = BUSR6,
             @cRetailSKU = RetailSKU,
             @cNotes2 = Notes2
      FROM SKU (NOLOCK) 
      WHERE SKU = @cSKU
         AND Storerkey = @cStorerKey

      SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Col01>', RTRIM( @cSusr1))
      SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Col02>', RTRIM( @cRetailSKU))
      SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Col03>', RTRIM( @cSusr2))
      SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Col04>', RTRIM( @cNotes2))
      SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Col05>', RTRIM( @cSusr4))
      SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Col06>', RTRIM( @cSusr6))


      SET @cPrintData = @cPrintTemplate
   END

END
GO
GRANT EXECUTE ON  [dbo].[isp_SKULabel14_RP] TO [NSQL]
GO
