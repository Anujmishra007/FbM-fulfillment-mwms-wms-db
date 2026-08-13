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
/* 2026-07-22 1.0.1  Jackc      FCR-13319 Post Pick status is 3         */
/* 2026-08-07 1.1.0  NickT      UWP-63642 Fix some issues.              */
/* 2026-08-13 1.2.0  NickT      UWP-64065 Add LOC CheckDigit            */
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
      @cFacility                    NVARCHAR(5) = '',
      @cLabelNo                     NVARCHAR(20) = '',
      @cPackedWaveKey               NVARCHAR(10) = '',
      @cPackedUCCNo                 NVARCHAR(20) = '',
      @cIntermodalVehicle           NVARCHAR(30) = '',
      @cConsigneeKey                NVARCHAR(15) = '',
      @cOrderType                   NVARCHAR(10) = '',
      @cPickSlipNo                  NVARCHAR(18) = '',
      @cLoc                         NVARCHAR(10) = '',
      @cLocationType                NVARCHAR(10) = '',
      @cWaveKey                     NVARCHAR(10) = '',
      @cStatus                      NVARCHAR(10) = '',
      @cLOCCheckDigitSP             NVARCHAR(20) = '',
      @cPOSTPICK                    NVARCHAR(8) = 'POSTPICK',
      @cSTAGEOB                     NVARCHAR(8) = 'STAGEOB',
      @cECOM                        NVARCHAR(8) = 'ECOM',
      @nRowCount                    INT = 0

   SET @nErrNo = 0
   SET @cErrMsg = ''

   SELECT
      @cFacility     = Facility,
      @cLoc          = V_String5,
      @cLOCCheckDigitSP = V_String31
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 1641
   BEGIN
      IF @nStep = 2 -- Loc
      BEGIN
         IF @nInputKey = 1 -- Enter
         BEGIN
            SELECT
               @cLoc     = I_Field02
            FROM rdt.RDTMOBREC WITH(NOLOCK)
            WHERE Mobile = @nMobile

            IF @cLOCCheckDigitSP = '1'
            BEGIN
               EXEC rdt.rdt_LOCLookUp_CheckDigit @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility,
                  @cLoc        OUTPUT,
                  @nErrNo      OUTPUT,
                  @cErrMsg     OUTPUT
               
               IF @nErrNo <> 0
               BEGIN
                  GOTO Quit
               END
            END

            SELECT @cLocationType = LocationType
            FROM dbo.LOC WITH(NOLOCK)
            WHERE Facility = @cFacility
               AND Loc = @cLoc
            SET @cLocationType = ISNULL(@cLocationType, '')

            IF @cLocationType NOT IN (@cPOSTPICK, @cSTAGEOB)
            BEGIN
               SET @nErrNo = 271263
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Location Type must be POSTPICK or STAGEOB
               GOTO Quit
            END
         END
      END
      ELSE IF @nStep = 3 -- UCC
      BEGIN
         IF @nInputKey = 1 -- Enter
         BEGIN
            SET @cUCCNo = TRIM(@cUCCNo)

            SELECT @cLocationType = LocationType
            FROM dbo.LOC WITH(NOLOCK)
            WHERE Facility = @cFacility
               AND Loc = @cLoc
            SET @cLocationType = ISNULL(@cLocationType, '')

            IF @cLocationType = @cPOSTPICK
            BEGIN
               SET @cWaveKey = ''
               SET @cStatus = ''
               SELECT TOP 1 @cWaveKey = WaveKey,
                     @cStatus = Status
               FROM dbo.PickDetail WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND DropID = @cUCCNo
                  AND WaveKey IS NOT NULL
                  AND WaveKey <> ''
               ORDER BY PickDetailKey
               SELECT @nRowCount = @@ROWCOUNT

               IF @nRowCount = 0
               BEGIN
                  SET @nErrNo = 271251
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Scanned value does not exist in PickDetail
                  GOTO Quit
               END

               IF ISNULL(@cStatus, '') <> '3' --V1.0.1 Pick status is 3
               BEGIN
                  SET @nErrNo = 271252
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Wrong pick status
                  GOTO Quit
               END

               IF EXISTS (SELECT 1 FROM dbo.DropIDDetail WITH(NOLOCK) WHERE DropID = @cDropID AND ChildID = @cUCCNo)
               BEGIN
                  SET @nErrNo = 271253
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UCC has been scanned
                  GOTO Quit
               END

               -- Check different WaveKey than the one packed
               IF EXISTS(SELECT 1
                        FROM dbo.DropIDDetail WITH(NOLOCK)
                        WHERE DropID = @cDropID
                           AND ISNULL(UserDefine02, '') <> @cWaveKey)
               BEGIN
                  SET @nErrNo = 271254
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Different WaveKey than the one packed
                  GOTO Quit
               END
            END
            ELSE IF @cLocationType = @cSTAGEOB
            BEGIN
               -- 1. Check if Scanned value is PACKDETAIL.LabelNo
               SET @cPickSlipNo = ''
               SET @cStatus = ''
               SET @cLabelNo = ''

               SELECT TOP 1
                  @cPickSlipNo = PD.PickSlipNo,
                  @cStatus = PKD.Status,
                  @cLabelNo = PD.LabelNo,
                  @cWaveKey = PKD.WaveKey,
                  @cIntermodalVehicle = OD.IntermodalVehicle,
                  @cConsigneeKey = OD.ConsigneeKey,
                  @cOrderType = OD.Type
               FROM dbo.PackDetail PD WITH(NOLOCK)
               INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON PD.LabelNo = PKD.DropID AND PD.StorerKey = PKD.StorerKey
               INNER JOIN dbo.ORDERS OD WITH(NOLOCK) ON PKD.OrderKey = OD.OrderKey AND PKD.StorerKey = OD.StorerKey
               WHERE PD.LabelNo = @cUCCNo
                  AND PD.StorerKey = @cStorerKey
               ORDER BY PD.PickSlipNo, PD.CartonNo, PD.LabelNo, PD.LabelLine
               SELECT @nRowCount = @@ROWCOUNT

               IF @nRowCount = 0
               BEGIN
                  GOTO CHK_TRACKINGNO_1
               END

               IF ISNULL(@cStatus, '') <> '5'
               BEGIN
                  SET @nErrNo = 271255
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Wrong pick status
                  GOTO Quit
               END

               IF ISNULL(@cPickSlipNo, '') <> ''
               BEGIN
                  GOTO CHK_BUILD_PALLET
               END

               -- 2. Check if Scanned value is PACKINFO.TrackingNo
               CHK_TRACKINGNO_1:
               IF EXISTS (SELECT 1 FROM dbo.PACKINFO WITH(NOLOCK)
                           WHERE TrackingNo IS NOT NULL
                           AND TrackingNo = @cUCCNo)
               BEGIN
                  -- fetch the PACKDETAIL.LabelNo by querying PACKDETAIL.PickSlipNo = PACKINFO.PickSlipNo AND PACKDETAIL.CartonNo = PACKINFO.CartonNo
                  SET @cPickSlipNo = ''
                  SET @cStatus = ''
                  SET @cLabelNo = ''

                  SELECT TOP 1
                     @cPickSlipNo = PD.PickSlipNo,
                     @cStatus = PKD.Status,
                     @cLabelNo = PD.LabelNo,
                     @cWaveKey = PKD.WaveKey,
                     @cIntermodalVehicle = OD.IntermodalVehicle,
                     @cConsigneeKey = OD.ConsigneeKey,
                     @cOrderType = OD.Type
                  FROM dbo.PackDetail PD WITH(NOLOCK)
                  INNER JOIN dbo.PackInfo PI WITH(NOLOCK) ON PD.PickSlipNo = PI.PickSlipNo AND PD.CartonNo = PI.CartonNo
                  INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON PD.LabelNo = PKD.DropID AND PD.StorerKey = PKD.StorerKey
                  INNER JOIN dbo.ORDERS OD WITH(NOLOCK) ON PKD.OrderKey = OD.OrderKey AND PKD.StorerKey = OD.StorerKey
                  WHERE PI.TrackingNo = @cUCCNo
                     AND PD.StorerKey = @cStorerKey
                  ORDER BY PD.PickSlipNo, PD.CartonNo, PD.LabelNo, PD.LabelLine
                  SELECT @nRowCount = @@ROWCOUNT

                  IF @nRowCount = 0
                  BEGIN
                     GOTO CHK_TRACKINGNO_2
                  END

                  IF ISNULL(@cStatus, '') <> '5'
                  BEGIN
                     SET @nErrNo = 271255
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Wrong pick status
                     GOTO Quit
                  END

                  GOTO CHK_BUILD_PALLET
               END

               -- 3. Extract the last 12 characters of the scanned barcode. Check this value for PACKINFO.TrackingNo match.
               CHK_TRACKINGNO_2:
               IF (LEN(@cUCCNo) >= 12)
               BEGIN
                  SET @cUCCNo = RIGHT(@cUCCNo, 12)
                  IF EXISTS (SELECT 1 FROM dbo.PACKINFO WITH(NOLOCK)
                           WHERE TrackingNo IS NOT NULL
                           AND TrackingNo = @cUCCNo)
                  BEGIN
                     -- Fetch the PACKDETAIL.LabelNo by querying PACKDETAIL.PickSlipNo = PACKINFO.PickSlipNo AND PACKDETAIL.CartonNo = PACKINFO.CartonNo
                     SET @cPickSlipNo = ''
                     SET @cStatus = ''
                     SET @cLabelNo = ''

                     SELECT TOP 1
                        @cPickSlipNo = PD.PickSlipNo,
                        @cStatus = PKD.Status,
                        @cLabelNo = PD.LabelNo,
                        @cWaveKey = PKD.WaveKey,
                        @cIntermodalVehicle = OD.IntermodalVehicle,
                        @cConsigneeKey = OD.ConsigneeKey,
                        @cOrderType = OD.Type
                     FROM dbo.PackDetail PD WITH(NOLOCK)
                     INNER JOIN dbo.PackInfo PI WITH(NOLOCK) ON PD.PickSlipNo = PI.PickSlipNo AND PD.CartonNo = PI.CartonNo
                     INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON PD.LabelNo = PKD.DropID AND PD.StorerKey = PKD.StorerKey
                     INNER JOIN dbo.ORDERS OD WITH(NOLOCK) ON PKD.OrderKey = OD.OrderKey AND PKD.StorerKey = OD.StorerKey
                     WHERE PI.TrackingNo = @cUCCNo
                        AND PD.StorerKey = @cStorerKey
                     ORDER BY PD.PickSlipNo, PD.CartonNo, PD.LabelNo, PD.LabelLine
                     SELECT @nRowCount = @@ROWCOUNT

                     IF @nRowCount = 0
                     BEGIN
                        SET @nErrNo = 271256
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Scanned value does not exist in PackDetail
                        GOTO Quit
                     END

                     IF ISNULL(@cStatus, '') <> '5'
                     BEGIN
                        SET @nErrNo = 271255
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Wrong pick status
                        GOTO Quit
                     END
                     GOTO CHK_BUILD_PALLET
                  END
               END

               -- IF the scanned value is not found in PACKDETAIL.LabelNo or PACKINFO.TrackingNo, return error
               SET @nErrNo = 271257
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid UCC
               GOTO Quit

               -- Compare WaveKey from scanned UCC and packed UCC
               CHK_BUILD_PALLET:
               IF EXISTS (SELECT 1 FROM dbo.DropIDDetail WITH(NOLOCK) WHERE DropID = @cDropID AND ChildID = @cLabelNo)
               BEGIN
                  SET @nErrNo = 271258
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UCC has been scanned
                  GOTO Quit
               END

               -- It is not an empty pallet,
               -- 1. check the IntermodalVehicle for ECOM order
               -- 2. check the WaveKey and ConsigneeKey for non-ECOM order
               IF EXISTS (SELECT 1
                        FROM dbo.DropIDDetail WITH(NOLOCK)
                        WHERE DropID = @cDropID
                           AND ChildID IS NOT NULL
                           AND ChildID <> '')
               BEGIN
                  IF @cOrderType = @cECOM
                  BEGIN
                     IF EXISTS(SELECT 1
                              FROM dbo.DropIDDetail WITH(NOLOCK)
                              WHERE DropID = @cDropID
                                 AND ISNULL(UserDefine01, '') <> @cIntermodalVehicle)
                     BEGIN
                        SET @nErrNo = 271259
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Different Intermodal Vehicle
                        GOTO Quit
                     END
                  END
                  ELSE
                  BEGIN
                     IF EXISTS(SELECT 1
                              FROM dbo.DropIDDetail WITH(NOLOCK)
                              WHERE DropID = @cDropID
                                 AND ISNULL(UserDefine02, '') <> @cWaveKey)
                     BEGIN
                        SET @nErrNo = 271260
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Different WaveKey
                        GOTO Quit
                     END

                     IF EXISTS(SELECT 1
                              FROM dbo.DropIDDetail WITH(NOLOCK)
                              WHERE DropID = @cDropID
                                 AND ISNULL(UserDefine03, '') <> @cConsigneeKey)
                     BEGIN
                        SET @nErrNo = 271261
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Different ConsigneeKey
                        GOTO Quit
                     END
                  END
               END
            END
            ELSE
            BEGIN
               SET @nErrNo = 271262
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Loc
               GOTO Quit
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

GRANT EXEC ON RDT.rdt_1641ExtValidSP28 TO NSQL
GO

