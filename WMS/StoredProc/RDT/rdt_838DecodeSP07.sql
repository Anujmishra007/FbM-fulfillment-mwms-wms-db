
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/
/* Store procedure: rdt_838DecodeSP07                                   */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Purpose: Decode SKU & Default QTY                                    */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2022-07-04  1.  YeeKung     WMS-19592 Add UPC qty (yeekung01)       */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_838DecodeSP07
   @nMobile          INT,          
   @nFunc            INT,          
   @cLangCode        NVARCHAR( 3), 
   @nStep            INT,          
   @nInputKey        INT,          
   @cFacility        NVARCHAR( 5), 
   @cStorerKey       NVARCHAR( 15),
   @cPickSlipNo      NVARCHAR( 10),
   @cFromDropID      NVARCHAR( 20),
   @cBarcode         NVARCHAR( 60),
   @cSKU             NVARCHAR( 20)  OUTPUT, 
   @nQTY             INT            OUTPUT, 
   @cPackDtlRefNo    NVARCHAR( 20)  OUTPUT, 
   @cPackDtlRefNo2   NVARCHAR( 20)  OUTPUT, 
   @cPackDtlUPC      NVARCHAR( 30)  OUTPUT, 
   @cPackDtlDropID   NVARCHAR( 20)  OUTPUT, 
   @nErrNo           INT            OUTPUT, 
   @cErrMsg          NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @bSuccess INT
   DECLARE @cUPC NVARCHAR( 30)
   DECLARE @cFieldAttr08   NVARCHAR( 1)
   DECLARE @cInField08     NVARCHAR( 60)
   DECLARE @cQTY           NVARCHAR( 5)
   
   -- If user key in sku
   IF EXISTS ( SELECT 1 FROM dbo.SKU WITH (NOLOCK, INDEX(PKSKU)) 
               WHERE StorerKey = @cStorerKey
               AND   SKU = @cBarcode)
   BEGIN
      SET @cSKU = @cBarcode

      SELECT @cFieldAttr08 = FieldAttr08,
             @cInField08 = I_Field08
      FROM RDT.RDTMOBREC WITH (NOLOCK)
      WHERE Mobile = @nMobile
       
      SET @cQTY = CASE WHEN @cFieldAttr08 = 'O' THEN '' ELSE @cInField08 END
      IF RDT.rdtIsValidQTY( @cQTY, 1) = 1
         SET @nQTY = CAST( @cQty AS INT)
      ELSE
         SET @nQTY = 1
   END
   ELSE  -- If user key in Altsku
   BEGIN
      SET @cSKU = ''
      SELECT @cSKU = SKU 
      FROM UPC (NOLOCK)
      WHERE upc = @cBarcode   
      AND   StorerKey = @cStorerKey

      IF ISNULL( @cSKU, '') <> ''
      BEGIN
         SELECT @nQTY = PACK.CaseCnt  
         FROM dbo.PACK PACK WITH (NOLOCK)
         JOIN dbo.SKU SKU WITH (NOLOCK) ON ( PACK.PackKey = SKU.PACKKey)
         WHERE SKU.StorerKey = @cStorerKey
         AND   SKU.Sku = @cSKU
      END
      ELSE
      BEGIN
         SET @cSKU = @cBarcode
         SET @nQTY = 0
      END
   END
Quit:

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXECUTE ON rdt.rdt_838DecodeSP07 TO NSQL 
GO   