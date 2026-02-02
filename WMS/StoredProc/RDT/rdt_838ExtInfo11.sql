SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_838ExtInfo11                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date       Rev Author      Purposes                                  */
/* 2025-12-05 1.0 FRO014      UWP-45994 RITM8496059 - Show Weight Info  */
/************************************************************************/

CREATE OR ALTER   PROC [RDT].[rdt_838ExtInfo11] (
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

   DECLARE 
         @cSKU             NVARCHAR( 20),
         @cPickSlipNo      NVARCHAR( 10),
         @cPackDtlDropID   NVARCHAR( 20),
         @cFromDropID      NVARCHAR( 20),
         @cPackDtlRefNo    NVARCHAR( 20),
         @cPackDtlRefNo2   NVARCHAR( 20),
         @cLabelNo         NVARCHAR( 20),
         @cCartonType      NVARCHAR( 10),
         @cCube            NVARCHAR( 10),
         @cWeight          NVARCHAR( 10),
         @cRefNo           NVARCHAR( 20),
         @cLabelLine       NVARCHAR( 5),
         @cUCCCounter      NVARCHAR( 5),
         @nCartonNo        INT = 0,
         @nTTL_Picked      INT = 0,
         @nTTL_Packed      INT = 0,
         @nQty          INT = 0,
         @nTotalWeight    INT = 0,
         @cOrderKey        NVARCHAR( 10) = '',
         @cLoadKey         NVARCHAR( 10) = '',
         @cZone            NVARCHAR( 10) = '',
         @cPSType          NVARCHAR( 10) = ''

   IF @nFunc = 838 -- Pack
   BEGIN
      IF 1 IN (@nStep, @nAfterStep) OR 2 IN (@nStep, @nAfterStep) or 3 IN (@nStep, @nAfterStep) -- SKU QTY
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Table mapping
            SELECT @cPackDtlDropID  = Value FROM @tVar WHERE Variable = '@cPackDtlDropID'
            SELECT @nCartonNo       = Value FROM @tVar WHERE Variable = '@nCartonNo'
            SELECT @cFromDropID     = Value FROM @tVar WHERE Variable = '@cFromDropID'
            SELECT @cPickSlipNo     = Value FROM @tVar WHERE Variable = '@cPickSlipNo'
            SELECT @cSKU            = Value FROM @tVar WHERE Variable = '@cSKU'
            SELECT @cLabelNo        = Value FROM @tVar WHERE Variable = '@cLabelNo'

            SELECT   -- Get PackDetail (
               @nQty          = SUM(pd.Qty),
               @nTotalWeight  = SUM(pd.Qty*s.GrossWgt)
            FROM dbo.PackDetail pd WITH (NOLOCK)
            INNER JOIN dbo.SKU s WITH (NOLOCK) ON s.Sku = pd.SKU AND pd.StorerKey = s.StorerKey
            WHERE pd.StorerKey = @cStorerKey
               AND pd.LabelNo  = @cLabelNo
               --AND CartonNo = @nCartonNo                  
            
            SET @cExtendedInfo = 'Qty/Weight: ' + CONVERT(NVARCHAR(10), @nQty) + '/' + CONVERT(NVARCHAR(10), @nTotalWeight)
         END
      END
   END

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_838ExtInfo11] TO NSQL
GO
