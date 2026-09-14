SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: rdt_994ExtInfo01                                       */
/* Copyright      : Maersk                                                 */
/* Customer       : AEOMX                                                  */
/*                                                                         */
/*                                                                         */
/* Date       Rev    Author      Purposes                                  */
/* 2026-09-10 1.0.0  JackC       FCR-16295 Created based on 838ExtInfo12   */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_994ExtInfo01] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nAfterStep     INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @tVar           VariableTable READONLY,
   @cExtendedInfo  NVARCHAR( 20) OUTPUT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag INT = 0

   DECLARE
      @cSuggestedCartonType   NVARCHAR( 20) = '',
      @cPickSlipNo            NVARCHAR( 10),
      @cFromDropID            NVARCHAR( 20) = '',
      @cOrderKey              NVARCHAR( 10),
      @cLoadKey               NVARCHAR( 10), 
      @cPickStatus            NVARCHAR( 1)

   IF @nFunc = 994 -- Pack
   BEGIN
      IF(@nStep = 3 AND @nAfterStep = 3) -- Scan SKU on st3
      BEGIN
         DECLARE
            @nTotalPickQty INT = 0,
            @nTotalPackQty INT = 0,
            @nRemainingPackQty INT = 0

         SET @cPickStatus = rdt.RDTGetConfig( @nFunc, 'PickStatus', @cStorerKey)
         IF @cPickStatus = '0'
            SET @cPickStatus = '5'

         SELECT @cPickSlipNo = Value FROM @tVar WHERE Variable = '@cPickSlipNo'

         SELECT
            @cOrderKey = OrderKey,
            @cLoadKey = ExternOrderKey
         FROM dbo.PickHeader WITH (NOLOCK)
         WHERE PickHeaderKey = @cPickSlipNo

         IF ISNULL(@cOrderKey,'') <> ''
         BEGIN
            SELECT @nTotalPickQty = SUM(Qty)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND PD.OrderKey  = @cOrderKey
               AND PD.Status    = @cPickStatus
               AND PD.Qty > 0
         END
         ELSE IF ISNULL(@cLoadKey,'') <> ''
         BEGIN
            SELECT @nTotalPickQty = SUM(Qty)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON PD.OrderKey = LPD.OrderKey
            WHERE PD.StorerKey = @cStorerKey
               AND LPD.LoadKey  = @cLoadKey
               AND PD.Status    = @cPickStatus
               AND PD.Qty > 0
         END

         SELECT @nTotalPackQty = SUM(Qty)
         FROM dbo.PackDetail PD WITH (NOLOCK)
         WHERE PD.StorerKey = @cStorerKey
            AND PD.PickSlipNo = @cPickSlipNo

         SET @nRemainingPackQty = ISNULL(@nTotalPickQty,0) - ISNULL(@nTotalPackQty,0)

         SET @cExtendedInfo = 'REM to PACK: ' + ISNULL(TRY_CAST(@nRemainingPackQty AS NVARCHAR( 10)), 'ERR')
         GOTO Quit
      END--st3
   END

   Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  [RDT].[rdt_994ExtInfo01] TO [NSQL]
GO
