if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_SKULabel10_RP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure isp_SKULabel10_RP
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: isp_SKULabel10_RP                                      */
/* Copyright      : LF Logistics                                           */
/*                                                                         */
/* Date       Rev  Author   Purposes                                       */
/* 2018-11-22 1.0  Ung      WMS-6842 Created                               */
/***************************************************************************/

CREATE PROC isp_SKULabel10_RP (
   @nMobile        INT, 
   @nFunc          INT, 
   @cLangCode      NVARCHAR( 3), 
   @cStorerKey     NVARCHAR( 15), 
   @cByRef1        NVARCHAR( 20), 
   @cByRef2        NVARCHAR( 20), 
   @cByRef3        NVARCHAR( 20), 
   @cByRef4        NVARCHAR( 20), 
   @cByRef5        NVARCHAR( 20), 
   @cByRef6        NVARCHAR( 20), 
   @cByRef7        NVARCHAR( 20), 
   @cByRef8        NVARCHAR( 20), 
   @cByRef9        NVARCHAR( 20), 
   @cByRef10       NVARCHAR( 20), 
   @cPrintTemplate NVARCHAR( MAX), 
   @cPrintData     NVARCHAR( MAX) OUTPUT,
   @nErrNo         INT            OUTPUT,
   @cErrMsg        NVARCHAR( 20)  OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cPrice   NVARCHAR( 10)
   
   -- Parameter mapping
   SET @cPrice = @cByRef1
      
   SET @cPrintTemplate = REPLACE (@cPrintTemplate, '<Field01>', RTRIM( @cPrice))

   SET @cPrintData = @cPrintTemplate
   
Quit:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON isp_SKULabel10_RP TO NSQL
GO
