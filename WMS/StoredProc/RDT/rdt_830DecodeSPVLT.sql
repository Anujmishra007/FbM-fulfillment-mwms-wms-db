
/**************************************************************************************/
/* Stored Procedure: rdt_830DecodeSPVLT                                               */
/*                                                                                    */
/* Updates:                                                                           */
/* Date         Author  Ver.  Purposes                                                */
/* 05-MAY-2024  PPA374  1.0   Allowing to scan ID instead of SKU for WA and VNA picks */
/* 2024-10-29   PXL009  1.1   FCR-759 ID and UCC Length Issue                         */
/**************************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_830DecodeSPVLT]
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
   @cDefaultQTY  INT            OUTPUT,
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
   @cUserDefine01 NVARCHAR(30)  OUTPUT,
   @nErrNo       INT            OUTPUT,
   @cErrMsg      NVARCHAR( 20)  OUTPUT
AS
BEGIN   
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   IF @nFunc = 830 and @nStep = 3 and @nInputKey = 1
   BEGIN
      IF (SELECT count (DISTINCT SKU) FROM lotxlocxid (NOLOCK) WHERE Id = @cBarcode AND StorerKey = @cStorerKey AND qty > 0 AND loc = @cLOC) > 1
      BEGIN
         SET @nErrNo = 217915
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MultiSKUID
         GOTO skip
      END

      IF (SELECT count (DISTINCT sku) FROM SKU (NOLOCK) WHERE ALTSKU = @cBarcode AND StorerKey = @cStorerKey) > 1
      OR
      (SELECT count (DISTINCT sku) FROM UPC (NOLOCK) WHERE UPC = @cBarcode AND StorerKey = @cStorerKey) > 1
      BEGIN
         SET @nErrNo = 217916
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MultiSKUBarcode
         GOTO skip
      END

      IF EXISTS (SELECT 1 FROM sku (NOLOCK) WHERE sku = @cBarcode AND StorerKey = @cStorerKey)
      BEGIN
         SET @cUPC = LEFT( @cBarcode, 30)
         GOTO skip
      END

      IF EXISTS (SELECT 1 FROM sku (NOLOCK) WHERE ALTSKU = @cBarcode AND StorerKey = @cStorerKey)
      BEGIN
         SET @cUPC = LEFT( (SELECT sku FROM sku (NOLOCK) WHERE ALTSKU = @cBarcode AND StorerKey = @cStorerKey), 30)
         GOTO skip
      END

      IF EXISTS (SELECT 1 FROM UPC (NOLOCK) WHERE UPC = @cBarcode AND StorerKey = @cStorerKey)
      BEGIN
         SET @cUPC = LEFT( (SELECT SKU FROM UPC (NOLOCK) WHERE UPC = @cBarcode AND StorerKey = @cStorerKey), 30)
         GOTO skip
      END

      IF EXISTS (SELECT 1 FROM LOTxLOCxID (NOLOCK) WHERE Id = @cBarcode AND qty > 0 AND @cBarcode <> '' AND Loc = @cLOC AND StorerKey = @cStorerKey)
      BEGIN
         SET @cUPC = LEFT( (SELECT top 1 sku FROM LOTxLOCxID (NOLOCK) WHERE Id = @cBarcode AND qty > 0 AND Loc = @cLOC AND StorerKey = @cStorerKey), 30)
         GOTO skip
      END
      ELSE
      BEGIN
         SET @nErrNo = 217917
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --IDorSKUNotFound
         GOTO Quit
      END

      SKIP:
      SET @cDefaultQTY = (select sum(qty) from PICKDETAIL (NOLOCK) where loc = @cLOC 
      AND not exists (select 1 from loc (NOLOCK) where Facility = @cFacility and LocationType in ('PICK','CASE') and loc = @cLOC)
      and sku = @cSKU and Storerkey = @cStorerKey and OrderKey = (select top 1 OrderKey from PICKHEADER (NOLOCK) where PickHeaderKey = @cpickslipno))
   END

Quit:
END
GO
GRANT EXECUTE ON [RDT].[rdt_830DecodeSPVLT] TO [NSQL]
