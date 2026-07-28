
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: rdt_838DecodeSP20                                   */
/* Copyright      : Maersk WMS                                          */
/* Customer       : Brazil - CDS01 - LAQUILA                            */
/*                                                                      */
/* Purpose: Return UPC.Qty by PickDetail.UOM                            */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2026-04-21  1.0  NickT       FCR-12178 Created                       */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_838DecodeSP20
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR( 3),
   @nStep               INT,
   @nInputKey           INT,
   @cFacility           NVARCHAR( 5),
   @cStorerKey          NVARCHAR( 15),
   @cPickSlipNo         NVARCHAR( 10),
   @cFromDropID         NVARCHAR( 20),
   @cBarcode            NVARCHAR( 60),
   @cBarcode2           NVARCHAR( 60),
   @cSKU                NVARCHAR( 20)  OUTPUT,
   @nQTY                INT            OUTPUT,
   @cPackDtlRefNo       NVARCHAR( 20)  OUTPUT,
   @cPackDtlRefNo2      NVARCHAR( 20)  OUTPUT,
   @cPackDtlUPC         NVARCHAR( 30)  OUTPUT,
   @cPackDtlDropID      NVARCHAR( 20)  OUTPUT,
   @cSerialNo           NVARCHAR( 30)  OUTPUT,
   @cFromDropIDDecode   NVARCHAR( 20)  OUTPUT,
   @cToDropIDDecode     NVARCHAR( 20)  OUTPUT,
   @cUCCNo              NVARCHAR( 20)  OUTPUT,
   @nErrNo              INT            OUTPUT,
   @cErrMsg             NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 838
   BEGIN
      IF @nStep = 3  -- SKU QTY
      BEGIN
         IF @nInputKey = 1
         BEGIN

            DECLARE @cUPC           NVARCHAR( 30)
            DECLARE @cPUOM          NVARCHAR( 10)
            DECLARE @cRefNo2        NVARCHAR( 30)
            DECLARE @nPUOM_Div      INT
            DECLARE @nScannedUOMQty INT
            DECLARE @nTotalUOMQty   INT
            DECLARE @nStartIndex    INT
            DECLARE @nEndIndex      INT

            SELECT @cUPC = LEFT( @cBarcode, 30)
            SET @cPUOM = ''
            SET @nQTY = 0
            SET @cSKU = ''

            SELECT TOP 1
               @cPUOM = PD.UOM,
               @nPUOM_Div = ISNULL(TRY_CAST(
                     CASE PD.UOM
                        WHEN '2' THEN Pack.CaseCNT
                        WHEN '3' THEN Pack.InnerPack
                        WHEN '6' THEN Pack.QTY
                        WHEN '1' THEN Pack.Pallet
                        WHEN '4' THEN Pack.OtherUnit1
                        WHEN '5' THEN Pack.OtherUnit2
                        ELSE -1
                     END
                  AS INT), 1),
               @cSKU = UPC.sku
            FROM dbo.SKU SKU WITH (NOLOCK)
            INNER JOIN dbo.UPC WITH(NOLOCK) ON SKU.sku = UPC.sku AND SKU.StorerKey = UPC.StorerKey
            INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)
            INNER JOIN dbo.PICKDETAIL PD WITH(NOLOCK) ON PD.SKU = UPC.SKU AND PD.StorerKey = UPC.StorerKey
            WHERE SKU.StorerKey = @cStorerKey
               AND UPC.UPC = @cUPC
               AND PD.DropID = @cFromDropID
               AND PD.UOM = CASE UPC.UOM
                        WHEN Pack.PackUOM1 THEN '2' -- Case
                        WHEN Pack.PackUOM2 THEN '3' -- Inner pack
                        WHEN Pack.PackUOM3 THEN '6' -- Master unit
                        WHEN Pack.PackUOM4 THEN '1' -- Pallet
                        WHEN Pack.PackUOM8 THEN '4' -- Other unit 1
                        WHEN Pack.PackUOM9 THEN '5' -- Other unit 2
                        ELSE ''
                  END
            ORDER BY PickDetailKey

            IF @@ROWCOUNT > 0 AND ISNULL(@cPUOM, '') <> '' AND ISNULL(@nPUOM_Div, -1) <> -1
            BEGIN
               SET @cPUOM = ISNULL(@cPUOM, '1') -- Default to 1 if UOM not found, available values: 1, 2, 6
               SET @nPUOM_Div = ISNULL(@nPUOM_Div, 1) -- Default to 1 if UOM division not found, available values depend on the pack configuration
               SET @nPUOM_Div = IIF(@nPUOM_Div = 0, 1, @nPUOM_Div)

               SELECT @nTotalUOMQty = SUM(PD.Qty)
               FROM dbo.PickDetail PD WITH (NOLOCK)
               WHERE PD.StorerKey = @cStorerKey
                  AND PD.DropID = @cFromDropID
                  AND PD.Status = '5'
                  AND PD.SKU = @cSKU
                  AND PD.UOM = @cPUOM
               GROUP BY PD.UOM

               SET @nTotalUOMQty = ISNULL(@nTotalUOMQty, 0) / @nPUOM_Div

               SELECT TOP 1 @cRefNo2 = RefNo2
               FROM dbo.PackDetail WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND DropID = @cFromDropID
                  AND SKU = @cSKU
                  AND PickslipNo = @cPickSlipNo
               ORDER BY ADDDate ASC

               SET @nScannedUOMQty = 0

               IF ISNULL(@cRefNo2, '') <> '' AND CHARINDEX(@cPUOM + ':', @cRefNo2) > 0
               BEGIN
                  SET @nStartIndex = CHARINDEX(@cPUOM + ':', @cRefNo2)
                  SET @nEndIndex = CHARINDEX(';', @cRefNo2,  CHARINDEX(@cPUOM + ':', @cRefNo2) + 1)

                  IF @nStartIndex > 0 AND @nEndIndex > @nStartIndex
                  BEGIN
                     SET @nStartIndex += LEN(@cPUOM) + 1
                     SET @nScannedUOMQty = ISNULL(TRY_CAST(SUBSTRING( @cRefNo2, @nStartIndex, @nEndIndex - @nStartIndex) AS INT), 0)
                  END
               END

               IF @nTotalUOMQty <= @nScannedUOMQty
               BEGIN
                  SET @nErrNo = 264702
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No UPC quantity to pack
                  GOTO Quit
               END

               SET @nQTY = @nPUOM_Div
            END
            ELSE
            BEGIN
               SET @nErrNo = 264703
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No matched UPC found
               GOTO Quit
            END
         END
      END
   END

Quit:

END
GO

GRANT EXECUTE ON rdt.rdt_838DecodeSP20 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
