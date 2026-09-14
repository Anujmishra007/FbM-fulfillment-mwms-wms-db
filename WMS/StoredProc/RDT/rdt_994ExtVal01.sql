
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************************/
/* Store procedure: rdt_994ExtVal01                                                    */
/* Copyright      : Maersk                                                             */
/*                                                                                     */
/* Purposes: Customized validation for AEO MEX packing (Fn 994)                        */
/*                                                                                     */
/* Date       Rev    Author      Purposes                                              */
/* 2026/09/10 1.0.0  Jackc       FCR-16295 Created (copied from 838ExtScn10)           */
/* 2026/09/12 1.0.1  Jackc       FCR-16295 For ECOM M, PickedQty must be = ExpectedQty */
/***************************************************************************************/

CREATE OR ALTER PROC rdt.rdt_994ExtVal01 (
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

   DECLARE @nDebugFlag     INT = 0

   DECLARE
      @cPickStatus         NVARCHAR( 1),
      @cWaveKey            NVARCHAR( 10),
      @cPickUoM            NVARCHAR( 10),
      @cWaveType           NVARCHAR( 20),
      @cWaveSubType        NVARCHAR( 20),
      @cDropIDLoc          NVARCHAR( 10),
      @cOrderKey           NVARCHAR( 10),
      @cLoadKey            NVARCHAR( 10),   
      @nRowCount           INT

   DECLARE @tPKD TABLE (
      PickDetailKey  NVARCHAR( 18) PRIMARY KEY,
      DropID         NVARCHAR( 20),
      Status         NVARCHAR( 10),
      Sku            NVARCHAR( 20),
      Qty            INT,
      WaveKey        NVARCHAR( 10)
   )

   IF @nDebugFlag = 1
      SELECT 'Running 994ExtVal01'

   IF @nFunc = 994
   BEGIN
      IF @nStep = 1 -- Screen 1: Scan PSNO
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'Step 1 ext validation'

            SET @cPickStatus = rdt.RDTGetConfig( @nFunc, 'PickStatus', @cStorerKey)
            IF @cPickStatus = '0'
               SET @cPickStatus = '5'

            -- V1.0.0 start
            --Not allow FromDropID
            IF ISNULL(@cFromDropID, '') <> '' OR ISNULL(@cPackDtlDropID, '') <> ''
            BEGIN
               SET @nErrNo = 280858
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Only PSNO allowed
               GOTO Quit
            END

            SET @cOrderKey = ''
            SET @cLoadKey = ''

            SELECT
               @cOrderKey = OrderKey,
               @cLoadKey = ExternOrderKey
            FROM dbo.PickHeader WITH (NOLOCK)
            WHERE PickHeaderKey = @cPickSlipNo

            IF ISNULL(@cOrderKey, '') = '' AND ISNULL(@cLoadKey, '') = ''
            BEGIN
               SET @nErrNo = 280859
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --OrderKey and LoadKey both empty
               GOTO Quit
            END

            IF @nDebugFlag = 1
               SELECT 'Check PickDetail', @cOrderKey AS OrderKey, @cLoadKey AS LoadKey, @cPickSlipNo AS PSNO

            BEGIN TRY
               IF @cOrderKey <> ''
               BEGIN
                  INSERT INTO @tPKD (PickDetailKey, DropID, Status, Sku, Qty, WaveKey)
                  SELECT PickDetailKey, DropID, Status, Sku, Qty, ISNULL(WaveKey, '')
                  FROM dbo.PickDetail WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND OrderKey  = @cOrderKey
                     AND QTY       > 0
               END
               ELSE IF @cLoadKey <> ''
               BEGIN
                  INSERT INTO @tPKD (PickDetailKey, DropID, Status, Sku, Qty, WaveKey)
                  SELECT PD.PickDetailKey, PD.DropID, PD.Status, PD.Sku, PD.Qty, ISNULL(PD.WaveKey, '')
                  FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON PD.OrderKey = LPD.OrderKey
                  WHERE LPD.LoadKey  = @cLoadKey
                     AND PD.StorerKey = @cStorerKey
                     AND PD.QTY > 0
               END
            END TRY
            BEGIN CATCH
               SET @nErrNo = 280860
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Ins @tPKD Fail
               GOTO Quit
            END CATCH

            IF NOT EXISTS (SELECT 1 FROM @tPKD)
            BEGIN
               SET @nErrNo = 280863
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- PickDetail not found
               GOTO Quit
            END

            IF EXISTS (SELECT 1 FROM @tPKD WHERE Status < @cPickStatus AND Status <> '4')
            BEGIN
               SET @nErrNo = 280861
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Picking Pendiente
               GOTO Quit
            END

            IF EXISTS (SELECT 1 FROM @tPKD WHERE Status = '5')
            BEGIN
               SET @nErrNo = 280862
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Pack Parcial
               GOTO Quit
            END

            IF EXISTS (SELECT 1 FROM @tPKD WHERE Status NOT IN ('3', '4'))
            BEGIN
               SET @nErrNo = 280864
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Invalid PickDetail Status
               GOTO Quit
            END

            IF EXISTS (
               SELECT 1 FROM @tPKD t
               JOIN rdt.RDTPTLPIECELOG WITH (NOLOCK) 
                  ON SourceKey = t.DropID AND StorerKey = @cStorerKey
            )
            BEGIN
               SET @nErrNo = 280865
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Sort Inicio en PTW
               GOTO Quit
            END

            -- ECOM: verify picked qty matches expected qty per SKU
            SELECT TOP 1 @cWaveType = ISNULL(W.UserDefine03, '')
            FROM @tPKD t
            JOIN dbo.Wave W WITH (NOLOCK) ON W.WaveKey = t.WaveKey

            IF @cWaveType = 'ECOM' --V1.0.1
            BEGIN
               IF EXISTS (
                  SELECT 1
                  FROM (
                     SELECT Sku, SUM(Qty) AS PickedQty
                     FROM @tPKD
                     GROUP BY Sku
                  ) PD
                  FULL OUTER JOIN (
                     SELECT SKU, SUM(ExpQty) AS ExpectedQty
                     FROM dbo.PackDetail WITH (NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                     GROUP BY SKU
                  ) PKD ON PKD.SKU = PD.Sku
                  WHERE ISNULL(PD.PickedQty, 0) <> ISNULL(PKD.ExpectedQty, 0)
               )
               BEGIN
                  SET @nErrNo = 280866
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- ECOM SKU qty mismatch
                  GOTO Quit
               END
            END
         END -- ENTER
      END -- Step 1

      IF @nStep = 2 -- Validate Option
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT @cWaveType = C_String2
            FROM rdt.RDTMOBREC WITH (NOLOCK)
            WHERE Mobile = @nMobile

            IF @cWaveType = 'ECOM' AND @cOption <> '2'
            BEGIN
               SET @nErrNo = 280855
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ECOM: Invalid Option
               GOTO Quit
            END

            IF @cWaveType <> 'ECOM' AND @cOption <> '1'
            BEGIN
               SET @nErrNo = 280856
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option
               GOTO Quit
            END
         END -- ENTER
      END -- Step 2

      IF @nStep = 5 -- print label
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @cOption <> '1'
            BEGIN
               SET @nErrNo = 280857
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Opt2 not allowed
               GOTO Quit
            END
         END -- Enter
      END --step 5

   END -- Func 994

Quit:
   IF @nDebugFlag = 1
      SELECT 'Quit', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_994ExtVal01 TO NSQL
GO
