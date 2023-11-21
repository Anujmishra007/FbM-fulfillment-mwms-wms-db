SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Store procedure: rdt_727Inquiry03                                       */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date       Rev  Author   Purposes                                       */
/* 2018-03-05 1.0  Ung      WMS-4201 Created                               */
/* 2019-09-20 1.1  YeeKung  WMS-10536 Change the parameter                 */  
/* 2023-10-03 1.2  Yeekung  WMS-23791 Extended Params (yeekung01)          */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_727Inquiry03] (
   @nMobile      INT,
   @nFunc        INT,
   @nStep        INT,
   @cLangCode    NVARCHAR(3),
   @cStorerKey   NVARCHAR(15),
   @cOption      NVARCHAR(1),
   @cParam1      NVARCHAR(60),
   @cParam2      NVARCHAR(60),
   @cParam3      NVARCHAR(60),
   @cParam4      NVARCHAR(60),
   @cParam5      NVARCHAR(60),
   @c_oFieled01  NVARCHAR(20) OUTPUT,
   @c_oFieled02  NVARCHAR(20) OUTPUT,
   @c_oFieled03  NVARCHAR(20) OUTPUT,
   @c_oFieled04  NVARCHAR(20) OUTPUT,
   @c_oFieled05  NVARCHAR(20) OUTPUT,
   @c_oFieled06  NVARCHAR(20) OUTPUT,
   @c_oFieled07  NVARCHAR(20) OUTPUT,
   @c_oFieled08  NVARCHAR(20) OUTPUT,
   @c_oFieled09  NVARCHAR(20) OUTPUT,
   @c_oFieled10  NVARCHAR(20) OUTPUT,
   @c_oFieled11  NVARCHAR(20) OUTPUT,
   @c_oFieled12  NVARCHAR(20) OUTPUT,
   @nNextPage    INT          OUTPUT,
   @nErrNo       INT          OUTPUT,
   @cErrMsg      NVARCHAR(20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @nErrNo = 0

   IF @cOption = '1' -- KA outbound VAS
   BEGIN
      IF @nStep = 2
      BEGIN
         DECLARE @cID         NVARCHAR( 18)
         DECLARE @cPickSlipNo NVARCHAR( 10)
         DECLARE @cSKU        NVARCHAR( 20)
         DECLARE @cConsigneeKey NVARCHAR( 15)

         DECLARE @cUDF01      NVARCHAR( 30)
         DECLARE @cUDF02      NVARCHAR( 30)
         DECLARE @cUDF03      NVARCHAR( 30)
         DECLARE @cUDF04      NVARCHAR( 30)
         DECLARE @cUFD05      NVARCHAR( 30)

         -- Parameter mapping
         SET @cID = @cParam1
         SET @cPickSlipNo = @cParam2
         SET @cSKU = @cParam3

         -- Check both ID and PSNO blank
         IF @cID = '' AND @cPickSlipNo = ''
         BEGIN
            SET @nErrNo = 120451
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need ID/PSNO
            EXEC rdt.rdtSetFocusField @nMobile, 2  -- ID
            GOTO QUIT
         END

         -- Check both ID and PSNO key-in
         IF @cID <> '' AND @cPickSlipNo <> ''
         BEGIN
            SET @nErrNo = 120452
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Either ID/PSNO
            EXEC rdt.rdtSetFocusField @nMobile, 2  -- ID
            GOTO QUIT
         END

         -- ID
         IF @cID <> ''
         BEGIN
            -- Check ID valid
            IF NOT EXISTS( SELECT 1
               FROM PickDetail WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND DropID = @cID)
            BEGIN
               SET @nErrNo = 120453
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid ID
               EXEC rdt.rdtSetFocusField @nMobile, 2  -- ID
               GOTO QUIT
            END
         END

         -- PickSlipNo
         IF @cPickSlipNo <> ''
         BEGIN
            -- Get PickHeader info
            DECLARE @cOrderKey NVARCHAR(10)
            DECLARE @cLoadKey NVARCHAR(10)
            DECLARE @cZone NVARCHAR(18)
            SELECT TOP 1
               @cOrderKey = OrderKey,
               @cLoadKey = ExternOrderKey,
               @cZone = Zone
            FROM dbo.PickHeader WITH (NOLOCK)
            WHERE PickHeaderKey = @cPickSlipNo

            -- Check PSNO valid
            IF @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 120454
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid PSNO
               EXEC rdt.rdtSetFocusField @nMobile, 4  -- PickSlipNo
               GOTO Quit
            END

            -- Cross dock PickSlip
            IF @cZone IN ('XD', 'LB', 'LP')
            BEGIN
               -- Check diff storer
               IF EXISTS( SELECT TOP 1 1
                  FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                     JOIN dbo.Orders O WITH (NOLOCK) ON (O.OrderKey = RKL.Orderkey)
                  WHERE RKL.PickSlipNo = @cPickSlipNo
                    AND O.StorerKey <> @cStorerKey)
               BEGIN
                  SET @nErrNo = 120455
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff storer
                  GOTO Quit
               END
            END

            -- Discrete PickSlip
            ELSE IF @cOrderKey <> ''
            BEGIN
               -- Get order info
               DECLARE @cChkStorerKey NVARCHAR(15)
               SELECT @cChkStorerKey = StorerKey
               FROM dbo.Orders WITH (NOLOCK)
               WHERE OrderKey = @cOrderKey

               -- Check storer
               IF @cChkStorerKey <> @cStorerKey
               BEGIN
                  SET @nErrNo = 120456
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff storer
                  GOTO Quit
               END
            END

            -- Conso PickSlip
            ELSE IF @cLoadKey <> ''
            BEGIN
               -- Check diff storer
               IF EXISTS( SELECT TOP 1 1
                  FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                     JOIN dbo.Orders O (NOLOCK) ON (LPD.OrderKey = O.OrderKey)
                  WHERE LPD.LoadKey = @cLoadKey
                     AND O.StorerKey <> @cStorerKey)
               BEGIN
                  SET @nErrNo = 120457
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff storer
                  GOTO Quit
               END
            END
         END

         -- SKU
         IF @cSKU = ''
         BEGIN
            SET @nErrNo = 120458
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need SKU
            EXEC rdt.rdtSetFocusField @nMobile, 6  -- SKU
            GOTO QUIT
         END

         -- Get consignee SKU info
         IF @cID <> ''
         BEGIN
            SELECT TOP 1
               @cConsigneeKey = ConsigneeKey
            FROM Orders O WITH (NOLOCK)
               JOIN Pickdetail PD WITH (NOLOCK) ON (O.OrderKey = PD.OrderKey)
            WHERE O.StorerKey  = @cStorerKey
               AND PD.DropID = @cID
         END

         IF @cPickSlipNo <> ''
         BEGIN
            SELECT TOP 1
               @cConsigneeKey = O.ConsigneeKey
            FROM Orders O WITH (NOLOCK)
               JOIN PickHeader PH WITH (NOLOCK) ON (O.OrderKey = PH.OrderKey)
            WHERE O.StorerKey  = @cStorerKey
               AND PH.PickHeaderKey = @cPickSlipNo
         END

         -- Check consignee
         IF @@ROWCOUNT = 0
         BEGIN
            SET @nErrNo = 120459
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No Consignee
            GOTO QUIT
         END

         -- Get consignee SKU info
         SELECT
            @cUDF01 = UDF01,
            @cUDF02 = UDF02,
            @cUDF03 = UDF03,
            @cUDF04 = UDF04,
            @cUFD05 = UDF05
         FROM ConsigneeSKU WITH (NOLOCK)
         WHERE ConsigneeKey = @cConsigneeKey
            AND StorerKey = @cStorerKey
            AND ConsigneeSKU = @cSKU

         -- Check consignee SKU
         IF @@ROWCOUNT = 0
         BEGIN
            SET @nErrNo = 120460
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoConsigneeSKU
            GOTO QUIT
         END

         SET @c_oFieled01 = rdt.rdtgetmessage( 120461, @cLangCode, 'DSP') -- KA Outbound VAS
         SET @c_oFieled02 = ''
         SET @c_oFieled03 = '1. ' + LEFT( @cUDF01, 17)
         SET @c_oFieled04 = '2. ' + LEFT( @cUDF01, 17)
         SET @c_oFieled05 = '3. ' + LEFT( @cUDF01, 17)
         SET @c_oFieled06 = '4. ' + LEFT( @cUDF01, 17)
         SET @c_oFieled07 = '5. ' + LEFT( @cUDF01, 17)
         SET @c_oFieled08 = ''
         SET @c_oFieled09 = ''
         SET @c_oFieled10 = ''

         SET @nNextPage = 0
      END
   END

Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_727Inquiry03] TO [NSQL]
GO
