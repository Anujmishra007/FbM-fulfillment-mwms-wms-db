SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: rdt_523DecodeSP06                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Scan dummy SKU, get actual SKU (at L09)                     */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author      Purposes                                */
/* 2024-12-18  1.0  Ung         WMS-25502 Created                       */ 
/* 2025-10-16  1.1  Ung         FCR-8112 Add serial no                  */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_523DecodeSP06
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

   DECLARE @cTempSKU       NVARCHAR( 20)
   DECLARE @cTempBarcode   NVARCHAR( 60)
   DECLARE @nPosition   INT
   
   SET @nErrNo = 0
            
   IF @nFunc = 523 -- Putaway by SKU
   BEGIN
      IF @nStep = 1 -- ID, UCC
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF LEN( @cBarcode) = 20
               SET @cID = SUBSTRING( @cBarcode, 3, 18)
         END
      END
      
      IF @nStep = 2 -- SKU
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Get actual SKU
            SET @cBarcode = LEFT( @cBarcode, 10)
   
            -- Get dummy SKU
            SELECT @cSKU = LLI.SKU
            FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
               JOIN dbo.LOTAttribute LA WITH (NOLOCK) ON (LLI.LOT = LA.LOT)
            WHERE LLI.LOC = @cLOC
               AND LLI.ID = @cID
               AND LA.Lottable09 = @cBarcode
               
            -- Not dummy, but other normal SKU
            IF @@ROWCOUNT = 0
               SET @cSKU = @cBarcode
         END
      END
   END
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXECUTE ON rdt.rdt_523DecodeSP06 TO NSQL 
GO   


