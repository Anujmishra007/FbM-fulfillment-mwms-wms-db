SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1641ExtValidSP28                                */
/* Copyright      : Maersk                                              */
/* Customer       : AEOMX - American Eagle                              */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev    Author     Purposes                                */
/* 2026-06-24 1.0.0  NickT      FCR-13319 Created                       */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_1641ExtValidSP28 (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR(3),
   @nStep        INT,
   @nInputKey    INT,
   @cStorerKey   NVARCHAR(15),
   @cDropID      NVARCHAR(20),
   @cUCCNo       NVARCHAR(20),
   @cPrevLoadKey NVARCHAR(10),
   @cParam1      NVARCHAR(20),
   @cParam2      NVARCHAR(20),
   @cParam3      NVARCHAR(20),
   @cParam4      NVARCHAR(20),
   @cParam5      NVARCHAR(20),
   @nErrNo       INT           OUTPUT,
   @cErrMsg      NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cLabelNo            NVARCHAR(20) = '',
      @nRowCount           INT = 0

   SET @nErrNo = 0
   SET @cErrMsg = ''

   IF @nFunc = 1641
   BEGIN
      IF @nStep = 3 -- UCC
      BEGIN
         IF @nInputKey = 1 -- Enter
         BEGIN
            SET @cUCCNo = TRIM(@cUCCNo)
            -- 1. Check if Scanned value is PACKDETAIL.LabelNo
            IF EXISTS (SELECT 1 FROM dbo.PACKDETAIL WITH(NOLOCK) WHERE LabelNo = @cUCCNo AND StorerKey = @cStorerKey)
            BEGIN
               GOTO Quit
            END

            -- 2. Check if Scanned value is PACKINFO.TrackingNo
            IF EXISTS (SELECT 1 FROM dbo.PACKINFO WITH(NOLOCK)
                        WHERE TrackingNo IS NOT NULL
                        AND TrackingNo = @cUCCNo)
            BEGIN
               -- fetch the PACKDETAIL.LabelNo by querying PACKDETAIL.PickSlipNo = PACKINFO.PickSlipNo AND PACKDETAIL.CartonNo = PACKINFO.CartonNo
               SET @cLabelNo = ''

               SELECT TOP 1 @cLabelNo = TRIM(PD.LabelNo)
               FROM dbo.PackDetail PD WITH(NOLOCK)
               INNER JOIN dbo.PackInfo PI WITH(NOLOCK) ON PD.PickSlipNo = PI.PickSlipNo AND PD.CartonNo = PI.CartonNo
               WHERE PI.TrackingNo = @cUCCNo
                  AND PD.StorerKey = @cStorerKey
               ORDER BY PD.LabelNo
               SELECT @nRowCount = @@ROWCOUNT

               IF @nRowCount > 0 AND @cLabelNo IS NOT NULL AND @cLabelNo <> ''
               BEGIN
                  GOTO Quit
               END
               ELSE
               BEGIN
                  SET @nErrNo = 271251
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Scanned value does not exist in PackDetail
                  GOTO Quit
               END
            END

            -- 3. Extract the last 12 characters of the scanned barcode. Check this value for PACKINFO.TrackingNo match.
            IF (LEN(@cUCCNo) >= 12)
            BEGIN
               SET @cUCCNo = RIGHT(@cUCCNo, 12)
               IF EXISTS (SELECT 1 FROM dbo.PACKINFO WITH(NOLOCK)
                        WHERE TrackingNo IS NOT NULL
                        AND TrackingNo = @cUCCNo)
               BEGIN
                  -- Fetch the PACKDETAIL.LabelNo by querying PACKDETAIL.PickSlipNo = PACKINFO.PickSlipNo AND PACKDETAIL.CartonNo = PACKINFO.CartonNo
                  SET @cLabelNo = ''

                  SELECT TOP 1 @cLabelNo = TRIM(PD.LabelNo)
                  FROM dbo.PackDetail PD WITH(NOLOCK)
                  INNER JOIN dbo.PackInfo PI WITH(NOLOCK) ON PD.PickSlipNo = PI.PickSlipNo AND PD.CartonNo = PI.CartonNo
                  WHERE PI.TrackingNo = @cUCCNo
                     AND PD.StorerKey = @cStorerKey
                  ORDER BY PD.LabelNo
                  SELECT @nRowCount = @@ROWCOUNT

                  IF @nRowCount > 0 AND @cLabelNo IS NOT NULL AND @cLabelNo <> ''
                  BEGIN
                     GOTO Quit
                  END
                  ELSE
                  BEGIN
                     SET @nErrNo = 271252
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Scanned value does not exist in PackDetail
                     GOTO Quit
                  END
               END
            END

            SET @nErrNo = 271253
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid UCC
            GOTO Quit
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

GRANT EXEC ON RDT.rdt_1641ExtValidSP28 TO NSQL
GO

