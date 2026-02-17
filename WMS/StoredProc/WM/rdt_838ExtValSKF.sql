SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_838ExtValSKF                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2205-11-13  1.0  SYO054   Packing validations - Block SKUs and Batches*/
/*                            getting mixed.                            */
/************************************************************************/

CREATE  PROCEDURE [RDT].[rdt_838ExtValSKF] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cFacility       NVARCHAR( 5),
   @cStorerKey      NVARCHAR( 15),
   @cPickSlipNo     NVARCHAR( 10),
   @cFromDropID     NVARCHAR( 20),
   @nCartonNo       INT,
   @cLabelNo        NVARCHAR( 20),
   @cSKU            NVARCHAR( 20),
   @nQTY            INT,
   @cUCCNo          NVARCHAR( 20),
   @cCartonType     NVARCHAR( 10),
   @cCube           NVARCHAR( 10),
   @cWeight         NVARCHAR( 10),
   @cRefNo          NVARCHAR( 20),
   @cSerialNo       NVARCHAR( 30),
   @nSerialQTY      INT,
   @cOption         NVARCHAR( 1),
   @cPackDtlRefNo   NVARCHAR( 20),
   @cPackDtlRefNo2  NVARCHAR( 20),
   @cPackDtlUPC     NVARCHAR( 30),
   @cPackDtlDropID  NVARCHAR( 20),
   @cPackData1      NVARCHAR( 30),
   @cPackData2      NVARCHAR( 30),
   @cPackData3      NVARCHAR( 30),
   @nErrNo          INT            OUTPUT,
   @cErrMsg         NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cLabelCode                      NVARCHAR (30),
      @nSkuLimit                       INT,
      @nSkuCheck01                     NVARCHAR (30),
      @cOrderKey                       NVARCHAR( 10),
      @cSerialNoCapture                NVARCHAR( 1),
      @nSKUWeight                      FLOAT,
      @nSKUCube                        FLOAT,
      @cSKUBrand                       NVARCHAR( 10),
      @cOrderConsigneeKey              NVARCHAR( 15),
      @cOrderC_Zip                     NVARCHAR( 18),
      @cDefaultConsigneeKey            NVARCHAR( 15),
      @cCustomerPalletType             NVARCHAR( 10),
      @cCustomerPalletCube             NVARCHAR( 20),
      @cCustomerPalletHeight           NVARCHAR( 20),
      @cCustomerPalletWeight           NVARCHAR( 20),
      @cCustomerPalletMixBrands        NVARCHAR( 20),
      @cCustomerPalletProductGrouping  NVARCHAR( 18),
      @cAddPackValidtn                 NVARCHAR( 20)

   IF @nFunc = 838
   BEGIN
      IF @nStep = 3
      BEGIN
         -- SKU and Batch validation for dropID
         IF EXISTS (SELECT 1 FROM dbo.PackDetail WITH(NOLOCK) WHERE DropID = @cPackDtlDropID AND StorerKey = @cStorerKey)
         BEGIN
            -- Check for different SKU in the same dropID
            IF EXISTS (SELECT 1 FROM dbo.PackDetail WITH(NOLOCK) WHERE DropID = @cPackDtlDropID AND StorerKey = @cStorerKey AND SKU <> @cSKU)
            BEGIN
               SET @nErrNo = 218154
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, N'DSP')
               GOTO Quit
            END

            -- Check for different Batch (Lottable10) in the same dropID
            IF EXISTS (SELECT TOP 1 * FROM dbo.PackDetail PD WITH(NOLOCK) 
                                            INNER JOIN dbo.LOTXLOCXID LLI WITH(NOLOCK) ON PD.RefNo2 = LLI.Id AND PD.StorerKey = LLI.StorerKey AND PD.SKU = LLI.Sku
                                            INNER JOIN dbo.LOTATTRIBUTE LA on LA.Lot = LLI.Lot AND LA.StorerKey = LLI.StorerKey AND LA.Sku = LLI.Sku
                      WHERE PD.DropID = @cPackDtlDropID AND PD.StorerKey = @cStorerKey 
                      AND LA.Lottable10 <> (SELECT TOP 1 Lottable10 FROM dbo.LOTXLOCXID LLI1 WITH(NOLOCK) 
                                             --INNER JOIN dbo.PackDetail PD1 WITH(NOLOCK) ON PD1.RefNo2 = LLI1.Id AND PD1.StorerKey = LLI1.StorerKey AND PD1.SKU = LLI1.Sku
                                             INNER JOIN dbo.LOTATTRIBUTE LA1 ON LA1.Lot = LLI1.Lot AND LA1.StorerKey = LLI1.StorerKey AND LA1.Sku = LLI1.Sku
                                             WHERE LLI1.Id = @cFromDropID AND LLI1.SKU = @cSKU AND LLI1.StorerKey = @cStorerKey))
            BEGIN
               SET @nErrNo = 218155
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, N'DSP')
               GOTO Quit
            END
         END
      END
   END
   GOTO Quit
Quit:
END
GO
