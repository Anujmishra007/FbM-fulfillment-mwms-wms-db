SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/***************************************************************************/
/* Store procedure: rdt_523DecodeSP05                                      */
/* Copyright      : Maersk                                                 */
/*                                                                         */
/* Purpose: Decode label return SKU + Lottable06 + Lottable12              */
/*                                                                         */
/* Modifications log:                                                      */
/* Date        Rev  Author      Purposes                                   */
/* 2025-03-11  1.0  James       FCR-3371. Created                          */
/* 2025-08-25  1.1  Jackc       Change in/out params to adapt to new entry */  
/* 2025-10-16  1.2  Ung         FCR-8112 Add serial no                     */
/***************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_523DecodeSP05
   @nMobile           INT,           
   @nFunc             INT,           
   @cLangCode         NVARCHAR( 3),  
   @nStep             INT,           
   @nInputKey         INT,           
   @cFacility         NVARCHAR( 5),  
   @cStorerKey        NVARCHAR( 15), 
   @cBarcode          NVARCHAR( 60),
   @cBarcodeUCC       NVARCHAR( 60), 
   @cID               NVARCHAR( 18)  OUTPUT, 
   @cUCC              NVARCHAR( 20)  OUTPUT, 
   @cLOC              NVARCHAR( 10)  OUTPUT, 
   @cSKU              NVARCHAR( 20)  OUTPUT, 
   @nQTY              INT            OUTPUT, 
   @cSerialNo         NVARCHAR( 30)  OUTPUT,
   @cLottable01       NVARCHAR( 18)  OUTPUT, 
   @cLottable02       NVARCHAR( 18)  OUTPUT, 
   @cLottable03       NVARCHAR( 18)  OUTPUT, 
   @dLottable04       DATETIME       OUTPUT, 
   @nErrNo            INT            OUTPUT, 
   @cErrMsg           NVARCHAR( 20)  OUTPUT    
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cUPC        NVARCHAR( 30)
   DECLARE @cTempSKU    NVARCHAR( 20)
   DECLARE @cSKUStatus  NVARCHAR( 10) = ''
   DECLARE @bSuccess    INT

   SET @nErrNo = 0
            
   IF @nStep = 2 -- SKU
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         IF LEN(@cBarcode) = 29  -- IT69
         BEGIN
            SET @cSKU = SUBSTRING ( @cBarcode, 3, 10) + 
                        SUBSTRING ( @cBarcode, 18, 2) + 
                        SUBSTRING ( @cBarcode, 21, 1) + 
                        SUBSTRING ( @cBarcode, 13, 3)
         END
         ELSE  -- Price Tag
         BEGIN
            SET @cTempSKU = SUBSTRING ( @cBarcode, 3, 14)   -- ManufacturerSKU

            EXEC [RDT].[rdt_GETSKU]    
               @cStorerKey  = @cStorerkey,    
               @cSKU        = @cTempSKU      OUTPUT,    
               @bSuccess    = @bSuccess      OUTPUT,    
               @nErr        = @nErrNo        OUTPUT,    
               @cErrMsg     = @cErrMsg       OUTPUT,  
               @cSKUStatus  = @cSKUStatus    

            SET @cSKU = @cTempSKU
         END
      END
   END
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXECUTE ON rdt.rdt_523DecodeSP05 TO NSQL 
GO   


