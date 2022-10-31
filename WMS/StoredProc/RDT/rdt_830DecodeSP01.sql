
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_830DecodeSP01                                         */
/* Copyright: LF Logistics                                                    */
/*                                                                            */
/* Purpose: Decode SKU by loc                                                 */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 10-10-2020  YeeKung   1.0   WMS-15415 Created                              */
/* 30-09-2021  YeeKung   1.1   WMS-16543 Add multisku (yeekung01)             */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_830DecodeSP01 ( 
  @nMobile      INT,               
  @nFunc        INT,               
  @cLangCode    NVARCHAR( 3),      
  @nStep        INT,               
  @nInputKey    INT,               
  @cStorerKey   NVARCHAR( 15),        
  @cFacility    NVARCHAR( 20),   
  @cLOC         NVARCHAR( 10),   
  @cDropid      NVARCHAR( 20),
  @cpickslipno  NVARCHAR( 20), 
  @cBarcode     NVARCHAR( 60),
  @cFieldName   NVARCHAR( 10),     
  @cUPC         NVARCHAR( 20)  OUTPUT,
  @cSKU         NVARCHAR( 20)  OUTPUT,
  @nQTY         INT            OUTPUT,
  @cLottable01  NVARCHAR( 18)  OUTPUT,
  @cLottable02  NVARCHAR( 18)  OUTPUT,
  @cLottable03  NVARCHAR( 18)  OUTPUT,
  @dLottable04  DATETIME       OUTPUT,
  @dLottable05  DATETIME       OUTPUT,
  @cLottable06  NVARCHAR( 30)  OUTPUT,
  @cLottable07  NVARCHAR( 30)  OUTPUT,
  @cLottable08  NVARCHAR( 30)  OUTPUT,
  @cLottable09  NVARCHAR( 30)  OUTPUT,
  @cLottable10  NVARCHAR( 30)  OUTPUT,
  @cLottable11  NVARCHAR( 30)  OUTPUT,
  @cLottable12  NVARCHAR( 30)  OUTPUT,
  @dLottable13  DATETIME       OUTPUT,
  @dLottable14  DATETIME       OUTPUT,
  @dLottable15  DATETIME       OUTPUT,
  @nErrNo       INT            OUTPUT,
  @cErrMsg      NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   declare @ctempsku nvarchar(20),
           @cZone nvarchar(20),
           @cPH_OrderKey nvarchar(20),
           @cPH_LoadKey nvarchar(20),
           @nRowCount INT

   DECLARE @cInField04  NVARCHAR( 60)  
   DECLARE @cOutField04 NVARCHAR( 60) 
   DECLARE @cOutField03 NVARCHAR( 60) 

   -- Get session info  
   SELECT   
      @cInField04 = I_Field04, -- SKU  
      @cOutField04 = O_Field04,
      @cOutField03 = O_Field03
   FROM rdt.rdtMobRec WITH (NOLOCK)  
   WHERE Mobile = @nMobile  
     
   -- Other than return from MultiSKU barcode screen  
   IF @cInField04 <> @cOutField04    
   BEGIN
      IF NOT EXISTS (SELECT 1          
            FROM          
            (          
               SELECT StorerKey, SKU FROM dbo.SKU SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU.SKU = @cSKU          
               UNION ALL          
               SELECT StorerKey, SKU FROM dbo.SKU SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU.AltSKU = @cSKU          
               UNION ALL          
               SELECT StorerKey, SKU FROM dbo.SKU SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU.RetailSKU = @cSKU          
               UNION ALL          
               SELECT StorerKey, SKU FROM dbo.SKU SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU.ManufacturerSKU = @cSKU          
               UNION ALL          
               SELECT StorerKey, SKU FROM dbo.UPC UPC WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND UPC.UPC = @cSKU          
            ) A          
            WHERE A.SKU =@cUPC) OR ISNULL(@cSKU,'')=''
      BEGIN
         SET @nErrNo = 160001
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid SKU
         GOTO QUIT
      END
   END
Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_830DecodeSP01 TO NSQL
GO
