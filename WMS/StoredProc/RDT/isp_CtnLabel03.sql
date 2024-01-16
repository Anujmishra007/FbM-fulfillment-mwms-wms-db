SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: isp_CtnLabel03                                         */
/* Copyright      : LF Logistics                                           */
/*                                                                         */
/* Date       Rev  Author   Purposes                                       */
/* 2023-01-08 1.0  yeekung  WMS-24438 Created                              */
/***************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_CtnLabel03] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @cStorerKey       NVARCHAR( 15),
   @cByRef1          NVARCHAR( 20),
   @cByRef2          NVARCHAR( 20),
   @cByRef3          NVARCHAR( 20),
   @cByRef4          NVARCHAR( 20),
   @cByRef5          NVARCHAR( 20),
   @cByRef6          NVARCHAR( 20),
   @cByRef7          NVARCHAR( 20),
   @cByRef8          NVARCHAR( 20),
   @cByRef9          NVARCHAR( 20),
   @cByRef10         NVARCHAR( 20),
   @cPrintTemplate   NVARCHAR( MAX),
   @cPrintData       NVARCHAR( MAX) OUTPUT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT,
   @cCodePage        NVARCHAR( 50)  OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cParams1    NVARCHAR( 60)
          ,@cParams2    NVARCHAR( 60)
          ,@cParams3    NVARCHAR( 60)
          ,@cParams4    NVARCHAR( 60)


   SET @cPrintData = @cPrintTemplate

   SELECT @cParams1 = style,
          @cParams2 = size,
          @cParams3 = @cByRef1,
          @cParams4 = len(descr)
   FROM SKU (NOLOCK)
   WHERE (SKU = @cByRef1 OR MANUFACTURERSKU = @cByRef1)
      AND Storerkey = @cStorerKey

   SET @cPrintData = REPLACE (@cPrintData,'<Field01>',RTRIM(ISNULL(@cParams1,'')))
   SET @cPrintData = REPLACE (@cPrintData,'<Field02>',RTRIM(ISNULL(@cParams2,'')))
   SET @cPrintData = REPLACE (@cPrintData,'<Field03>',RTRIM(ISNULL(@cParams3,'')))
   SET @cPrintData = REPLACE (@cPrintData,'<Field04>',RTRIM(ISNULL(@cParams4,'')))
          
   SET @cCodePage = '850'                        
                                                 
   GOTO Quit

Quit:
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON dbo.isp_CtnLabel03 TO NSQL
GO

