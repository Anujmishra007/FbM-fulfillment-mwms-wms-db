
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/**********************************************************************************/
/* Store procedure: rdt_838ExtVal41                                               */
/* Copyright      : Maersk                                                        */
/*                                                                                */
/* Purposes: Customized  validation for AEO MEX packing (Fn 838)                  */
/*                                                                                */
/* Date       Rev    Author      Purposes                                         */
/* 2026/06/30 1.0.0  Jackc       FCR-12984 Created                                */
/* 2026/07/28 1.0.1  Jackc       FCR-12984 Add one more condition skip validation */
/* 2026/09/18 1.1.0  Jackc       UWP-66709 Not allow enter if Dropid is full packed*/
/**********************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838ExtVal41 (
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
      @cMultiPSNOChk       NVARCHAR( 1), --V1.1.0
      @cWaveKey            NVARCHAR( 10),
      @cPickUoM            NVARCHAR( 10),
      @cWaveType           NVARCHAR( 20),
      @cWaveSubType        NVARCHAR( 20),
      @cDropIDLoc          NVARCHAR( 10),
      @cMsg01              NVARCHAR( 20),
      @cMsg02              NVARCHAR( 20),
      @cMsg03              NVARCHAR( 20),
      @nRowCount           INT,
      @nFromDropID_PickQty INT,
      @nFromDropID_PackQty INT

   IF @nFunc = 838
   BEGIN
      --V1.1.0
      SET @cPickStatus = rdt.RDTGetConfig( @nFunc, 'PickStatus', @cStorerKey)
      IF @cPickStatus = '0'
         SET @cPickStatus = '5'

      SET @cMultiPSNOChk = rdt.RDTGetConfig( @nFunc, 'MultiPSNOChk', @cStorerKey) --V1.1.0

      IF @nStep = 1 -- Screen 1: Scan DropID (Tote or UCC)
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SET @cWaveKey     = ''
            SET @cPickUom     = 0
            SET @cWaveType    = ''
            SET @cWaveSubType = ''

            -- Fetch WaveKey and UoM for this DropID
            SELECT TOP 1
               @cWaveKey = ISNULL( WaveKey, ''),
               @cPickUom = UOM,
               @cDropIDLoc = ISNULL( Loc, '')
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey 
               AND DropID = @cFromDropID
               AND Status = @cPickStatus
            ORDER BY PickDetailKey DESC

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount = 0
            BEGIN
               SET @nErrNo = 272302
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- PickDetail not found
               GOTO Quit
            END

            -- Check picking is completed; status < 3 means not yet picked
            IF EXISTS (
               SELECT 1 FROM dbo.PickDetail WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND DropID = @cFromDropID
                  AND Status < @cPickStatus AND Status <> '4'
            )
            BEGIN
               SET @nErrNo = 272303
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Picking not finished
               GOTO Quit
            END

            -- Fetch wave type attributes
            SELECT
               @cWaveType    = ISNULL( UserDefine03, ''),
               @cWaveSubType = ISNULL( UserDefine05, '')
            FROM dbo.Wave WITH (NOLOCK)
            WHERE WaveKey = @cWaveKey

            -- Skip PTW validation for Wholesale UCC (ML, UoM=2) or ECOM single-order
            IF NOT ( ( @cWaveType = 'WHSLE' AND @cWaveSubType = 'ML' AND @cPickUom = '2' )
                  OR ( @cWaveType = 'ECOM'  AND @cWaveSubType = 'S' ) 
                  OR (@cPickUOM = '2' AND @cDropIDLoc = 'STGVASML')) --V1.0.1
            BEGIN
               IF NOT EXISTS (SELECT 1 FROM rdt.RDTPTLPIECELOG WITH (NOLOCK) WHERE CartonID = @cFromDropID)
               BEGIN
                  SET @nErrNo = 272304
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- PTW log not found
                  GOTO Quit
               END

               IF EXISTS (SELECT 1 FROM rdt.RDTPTLPIECELOG WITH (NOLOCK) WHERE CartonID = @cFromDropID AND ISNULL(UserDefine02, '') <> 'COMPLETE')
               BEGIN
                  SET @nErrNo = 272301
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Sort pendiente
                  GOTO Quit
               END
            END

            --V1.1.0 If exists FromDropID with Multiple PSNO, throw an error
            IF NOT (@cWaveType = 'ECOM' AND @cWaveSubType = 'S') AND @cMultiPSNOChk = '1' -- not ECOM Single and Multi PSNO check enabled
            BEGIN
               IF EXISTS (SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)
                        WHERE StorerKey = @cStorerKey
                           AND DropID = @cFromDropID
                           AND PickSlipNo <> @cPickSlipNo)
               BEGIN
                  SET @nErrNo = 272310
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- DropID in Multi PSNO
                  GOTO Quit
               END

               --Check FromDropID in Multi PSNO in pickdetail
               DECLARE @tPSNO TABLE(
                  PickSlipNo  NVARCHAR(10) NOT NULL
               )

               BEGIN TRY
                  INSERT INTO @tPSNO (PickSlipNo)
                  SELECT DISTINCT PH.PickHeaderKey
                  FROM dbo.PickDetail PD (NOLOCK)
                  JOIN dbo.PickHeader PH (NOLOCK)
                     ON PD.OrderKey = PH.OrderKey
                  WHERE PD.StorerKey = @cStorerKey
                     AND PD.DropID = @cFromDropID
                     AND PD.Status = @cPickStatus
               END TRY
               BEGIN CATCH
                  -- Handle any errors that occur during the insert
                  SET @nErrNo = 272311
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END CATCH

               BEGIN TRY
                  INSERT INTO @tPSNO (PickSlipNo)
                  SELECT DISTINCT PH.PickHeaderKey
                  FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LoadPlanDetail LPD WITH (NOLOCK)
                     ON PD.OrderKey = LPD.OrderKey
                  JOIN dbo.PickHeader PH WITH (NOLOCK)
                     ON PH.ExternOrderKey = LPD.LoadKey
                  WHERE PD.StorerKey = @cStorerKey
                     AND PD.DropID = @cFromDropID
                     AND PD.Status = @cPickStatus
               END TRY
               BEGIN CATCH
                  -- Handle any errors that occur during the insert
                  SET @nErrNo = 272312
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END CATCH

               IF (SELECT COUNT (DISTINCT PickSlipNo) FROM @tPSNO) > 1
               BEGIN
                  SET @nErrNo = 272313
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END
            END -- V1.1.0 FromDropID multi PSNO check
         END -- ENTER
      END -- Step 1

      IF @nStep = 2 -- Validate Option
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT @cWaveType = C_String2
            FROM rdt.RDTMOBREC WITH (NOLOCK)
            WHERE Mobile = @nMobile

            --V1.1 start
            SELECT @nFromDropID_PickQty = ISNULL(SUM(QTY), 0)
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND DropID = @cFromDropID
               AND Status = @cPickStatus

            SELECT @nFromDropID_PackQty = ISNULL(SUM(QTY), 0)
            FROM dbo.PackDetail PD WITH (NOLOCK)
            JOIN dbo.PackHeader PH WITH (NOLOCK)
               ON (PD.PickSlipNo = PH.PickSlipNo)
               AND PH.Status = '0'
            WHERE PD.StorerKey = @cStorerKey
               AND PD.DropID = @cFromDropID

            IF @nFromDropID_PickQty = @nFromDropID_PackQty
            BEGIN
               SET @cMsg01 = '272309 - Full packed'
               SET @cMsg02 = 'ESC para cerrar'
               SET @cMsg03 = ''

               EXEC rdt.rdtInsertMsgQueue
                  @nMobile = @nMobile,  
                  @nErrNo = @nErrNo OUTPUT,  
                  @cErrMsg = @cErrMsg OUTPUT, -- screen limitation, 20 char max  
                  @cLine01 = @cMsg01,  
                  @cLine02 = @cMsg02,  
                  @cLine03 = @cMsg03,
                  @nDisplayMsg = 0 

               SET @nErrNo = 272309
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END

            IF @nFromDropID_PackQty > @nFromDropID_PickQty
            BEGIN
               SET @nErrNo = 272314
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- PackQty > PickQty
               GOTO Quit
            END

            IF NOT EXISTS (
               SELECT 1
                  FROM dbo.PickDetail WITH (NOLOCK)
                  WHERE DropID = @cFromDropID
                     AND StorerKey = @cStorerKey
                     AND Status = @cPickStatus
                     AND Qty > 0
                     AND CHARINDEX('[PACKED]', ISNULL(NOTES, '')) = 0)
            BEGIN
               SET @nErrNo = 272308
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Unpacked Pick detail not found
               GOTO Quit
            END
            --V1.1 end

            IF @cWaveType = 'ECOM' AND @cOption <> '2'
            BEGIN
               SET @nErrNo = 272305
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ECOM: Invalid Option
               GOTO Quit
            END

            IF @cWaveType <> 'ECOM' AND @cOption <> '1'
            BEGIN    
               SET @nErrNo = 272306
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
               SET @nErrNo = 272307
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Opt2 not allowed
               GOTO Quit
            END
         END -- Enter
      END --step 5

   END -- Func 838

Quit:
   IF @nDebugFlag = 1
      SELECT 'Quit', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838ExtVal41 TO NSQL
GO
