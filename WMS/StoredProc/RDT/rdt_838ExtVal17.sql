
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_838ExtVal17                                     */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Finish pack same SKU then only allow start new one          */
/*          Finish pack same Style then only allow start new one        */
/*          One pickslip handle by one operator at any time             */
/*          Don't need to handle short scenario                         */
/*                                                                      */
/* Date       Rev  Author      Purposes                                 */
/* 09-11-2023 1.0  Ung         WMS-23961 base on rdt_838ExtVal05        */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838ExtVal17 (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 5),
   @cStorerKey       NVARCHAR( 15),
   @cPickSlipNo      NVARCHAR( 10),
   @cFromDropID      NVARCHAR( 20),
   @nCartonNo        INT,
   @cLabelNo         NVARCHAR( 20),
   @cSKU             NVARCHAR( 20),
   @nQTY             INT,
   @cUCCNo           NVARCHAR( 20),
   @cCartonType      NVARCHAR( 10),
   @cCube            NVARCHAR( 10),
   @cWeight          NVARCHAR( 10),
   @cRefNo           NVARCHAR( 20),
   @cSerialNo        NVARCHAR( 30),
   @nSerialQTY       INT,
   @cOption          NVARCHAR( 1),
   @cPackDtlRefNo    NVARCHAR( 20), 
   @cPackDtlRefNo2   NVARCHAR( 20), 
   @cPackDtlUPC      NVARCHAR( 30), 
   @cPackDtlDropID   NVARCHAR( 20), 
   @cPackData1       NVARCHAR( 30), 
   @cPackData2       NVARCHAR( 30), 
   @cPackData3       NVARCHAR( 30),
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 838 -- Pack
   BEGIN
      IF @nStep = 3 -- SKU, QTY
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            DECLARE @cPrevSKU   NVARCHAR(20) = ''
            DECLARE @cCurrStyle NVARCHAR(20) = ''
            DECLARE @cPrevStyle NVARCHAR(20) = ''
            DECLARE @cOrderKey  NVARCHAR(10)
            DECLARE @cLoadKey   NVARCHAR(10)
            
            DECLARE @cMsg1 NVARCHAR(20) = ''
            DECLARE @cMsg2 NVARCHAR(20) = ''
            DECLARE @cMsg3 NVARCHAR(20) = ''
            DECLARE @cMsg4 NVARCHAR(20) = ''

            -- Get packed SKU
            SELECT TOP 1 
               @cPrevSKU = SKU.SKU,
               @cPrevStyle = SKU.Style
            FROM dbo.PackDetail PD WITH (NOLOCK) 
               JOIN dbo.SKU WITH (NOLOCK) ON (PD.StorerKey = SKU.StorerKey AND PD.SKU = SKU.SKU)
            WHERE PD.PickSlipNo = @cPickSlipNo 
               -- AND PD.CartonNo = @nCartonNo
               AND PD.QTY > 0
            ORDER BY PD.EditDate DESC

            -- Get pick slip info
            IF @cPrevSKU <> ''
               SELECT 
                  @cOrderKey = OrderKey, 
                  @cLoadKey = LoadKey 
               FROM dbo.PickHeader WITH (NOLOCK) 
               WHERE PickHeaderKey = @cPickSlipNo

            -- Different SKU
            IF @cPrevSKU <> '' AND @cPrevSKU <> @cSKU
            BEGIN
               DECLARE @nPrevSKUPickQTY INT = 0
               DECLARE @nPrevSKUPackQTY INT = 0
               
               -- Get previous SKU pick QTY
               IF @cOrderKey <> ''
                  SELECT @nPrevSKUPickQTY = ISNULL( SUM( PD.QTY), 0)
                  FROM dbo.PickDetail PD WITH (NOLOCK)
                     JOIN dbo.SKU WITH (NOLOCK) ON (PD.StorerKey = SKU.StorerKey AND PD.SKU = SKU.SKU)                  
                  WHERE PD.OrderKey = @cOrderKey
                     AND SKU.SKU = @cPrevSKU
                     AND PD.Status <> '4'
               ELSE IF @cLoadKey <> ''
                  SELECT @nPrevSKUPickQTY = ISNULL( SUM( PD.QTY), 0)
                  FROM dbo.Orders O WITH (NOLOCK) 
                     JOIN dbo.PickDetail PD WITH (NOLOCK) ON (O.OrderKey = PD.OrderKey)
                     JOIN dbo.SKU WITH (NOLOCK) ON (PD.StorerKey = SKU.StorerKey AND PD.SKU = SKU.SKU)
                  WHERE O.LoadKey = @cLoadKey
                     AND SKU.SKU = @cPrevSKU
                     AND PD.Status <> '4'

               -- Get previous SKU pack QTY
               SELECT @nPrevSKUPackQTY = ISNULL( SUM( PD.QTY), 0)
               FROM dbo.PackDetail PD WITH (NOLOCK)
                  JOIN dbo.SKU WITH (NOLOCK) ON (PD.StorerKey = SKU.StorerKey AND PD.SKU = SKU.SKU)                  
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND SKU.SKU = @cPrevSKU
               
               -- Prev SKU not yet finish pack
               IF @nPrevSKUPickQTY <> @nPrevSKUPackQTY
               BEGIN
                  SET @cMsg1 = rdt.rdtgetmessage( 208551, @cLangCode, 'DSP') --PREVIOUS SKU
                  SET @cMsg2 = rdt.rdtgetmessage( 208552, @cLangCode, 'DSP') --NOT YET FINISH
                  SET @cMsg3 = rdt.rdtgetmessage( 208553, @cLangCode, 'DSP') --PICK QTY:
                  SET @cMsg4 = rdt.rdtgetmessage( 208554, @cLangCode, 'DSP') --PACK QTY:
                  
                  SET @cMsg3 = RTRIM( @cMsg3) + ' ' + CAST( @nPrevSKUPickQTY AS NVARCHAR(5))
                  SET @cMsg4 = RTRIM( @cMsg4) + ' ' + CAST( @nPrevSKUPackQTY AS NVARCHAR(5))

                  EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, '', @cMsg1, @cMsg2, '', @cPrevSKU, '', @cMsg3, @cMsg4
                  SET @nErrNo = -1

                  -- EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU
                  GOTO Quit
               END
            END

            -- Get SKU info
            SELECT @cCurrStyle = Style FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU
            
            -- Different style
            IF @cPrevStyle <> '' AND @cPrevStyle <> @cCurrStyle
            BEGIN
               DECLARE @nPrevStylePickQTY INT = 0
               DECLARE @nPrevStylePackQTY INT = 0
               
               -- Get previous style pick QTY
               IF @cOrderKey <> ''
                  SELECT @nPrevStylePickQTY = ISNULL( SUM( PD.QTY), 0)
                  FROM dbo.PickDetail PD WITH (NOLOCK)
                     JOIN dbo.SKU WITH (NOLOCK) ON (PD.StorerKey = SKU.StorerKey AND PD.SKU = SKU.SKU)                  
                  WHERE PD.OrderKey = @cOrderKey
                     AND SKU.Style = @cPrevStyle
                     AND PD.Status <> '4'
               ELSE IF @cLoadKey <> ''
                  SELECT @nPrevStylePickQTY = ISNULL( SUM( PD.QTY), 0)
                  FROM dbo.Orders O WITH (NOLOCK) 
                     JOIN dbo.PickDetail PD WITH (NOLOCK) ON (O.OrderKey = PD.OrderKey)
                     JOIN dbo.SKU WITH (NOLOCK) ON (PD.StorerKey = SKU.StorerKey AND PD.SKU = SKU.SKU)
                  WHERE O.LoadKey = @cLoadKey
                     AND SKU.Style = @cPrevStyle
                     AND PD.Status <> '4'
                     
               -- Get previous style pack QTY
               SELECT @nPrevStylePackQTY = ISNULL( SUM( PD.QTY), 0)
               FROM dbo.PackDetail PD WITH (NOLOCK)
                  JOIN dbo.SKU WITH (NOLOCK) ON (PD.StorerKey = SKU.StorerKey AND PD.SKU = SKU.SKU)                  
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND SKU.Style = @cPrevStyle
               
               -- Prev style not yet finish pack
               IF @nPrevStylePickQTY <> @nPrevStylePackQTY
               BEGIN
                  SET @cMsg1 = rdt.rdtgetmessage( 208555, @cLangCode, 'DSP') --PREVIOUS STYLE
                  SET @cMsg2 = rdt.rdtgetmessage( 208556, @cLangCode, 'DSP') --NOT YET FINISH
                  SET @cMsg3 = rdt.rdtgetmessage( 208557, @cLangCode, 'DSP') --PICK QTY:
                  SET @cMsg4 = rdt.rdtgetmessage( 208558, @cLangCode, 'DSP') --PACK QTY:
                  
                  SET @cMsg3 = RTRIM( @cMsg3) + ' ' + CAST( @nPrevStylePickQTY AS NVARCHAR(5))
                  SET @cMsg4 = RTRIM( @cMsg4) + ' ' + CAST( @nPrevStylePackQTY AS NVARCHAR(5))

                  EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, '', @cMsg1, @cMsg2, '', @cPrevStyle, '', @cMsg3, @cMsg4
                  SET @nErrNo = -1

                  -- EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU
                  GOTO Quit
               END
            END

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

GRANT EXECUTE ON RDT.rdt_838ExtVal17 TO NSQL
GO
