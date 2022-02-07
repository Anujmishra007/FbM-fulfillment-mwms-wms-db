if exists (select * from dbo.sysobjects where id = object_id(N'rdt.rdt_803DecodeSP01') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure rdt.rdt_803DecodeSP01
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_803DecodeSP01                                         */
/* Copyright: LF Logistics                                                    */
/*                                                                            */
/* Purpose: HM India decode IT69 label return SKU                             */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2020-05-10  James     1.0   WMS-12226 Created                              */
/******************************************************************************/

CREATE PROC rdt.rdt_803DecodeSP01 (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),
   @cStorerKey   NVARCHAR( 15),
   @cStation     NVARCHAR( 10),
   @cMethod      NVARCHAR( 10),
   @cBarcode     NVARCHAR( 60),
   @cUPC         NVARCHAR( 30)  OUTPUT,
   @nErrNo       INT            OUTPUT,
   @cErrMsg      NVARCHAR( 20)  OUTPUT  
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nStep = 3 -- SKU
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         SET @cUPC = SUBSTRING( RTRIM( @cBarcode), 3, 13) -- SKU  
      END   -- ENTER
   END   -- @nStep = 3

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_803DecodeSP01 TO NSQL
GO
