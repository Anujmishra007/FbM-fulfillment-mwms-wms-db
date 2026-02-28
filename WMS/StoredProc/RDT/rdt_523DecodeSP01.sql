SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: rdt_523DecodeSP01                                         */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Purpose: Ikea decode label                                                 */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 06-05-2018  James     1.0   WMS5310 - Created                              */
/* 2025-08-25  Jackc     1.1   Update in/out params to adapt to new entry     */
/* 2025-10-16  Ung       1.2   FCR-8112 Add serial no                         */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_523DecodeSP01] (
    @nMobile      INT,
    @nFunc        INT,
    @cLangCode    NVARCHAR( 3),
    @nStep        INT,
    @nInputKey    INT,
    @cFacility    NVARCHAR( 5),
    @cStorerKey   NVARCHAR( 15),
    @cBarcode     NVARCHAR( 60),
    @cBarcodeUCC  NVARCHAR( 60),
    @cID          NVARCHAR( 18)  OUTPUT,
    @cUCC         NVARCHAR( 20)  OUTPUT,
    @cLOC         NVARCHAR( 10)  OUTPUT,
    @cSKU         NVARCHAR( 20)  OUTPUT,
    @nQty         INT            OUTPUT, 
    @cSerialNo    NVARCHAR( 30)  OUTPUT, 
    @cLottable01  NVARCHAR( 18)  OUTPUT, 
    @cLottable02  NVARCHAR( 18)  OUTPUT, 
    @cLottable03  NVARCHAR( 18)  OUTPUT, 
    @dLottable04  DATETIME       OUTPUT, 
    @nErrNo       INT            OUTPUT,
    @cErrMsg      NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 523 -- Pallet Putaway
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         IF @nStep = 1 -- FROM ID
            SET @cID = SUBSTRING( @cID, 3, LEN( @cID) - 3)

         IF @nStep = 2 -- SKU
            SET @cSKU = LEFT( @cSKU, 13)
      END   -- ENTER
   END

Quit:

END
GO
