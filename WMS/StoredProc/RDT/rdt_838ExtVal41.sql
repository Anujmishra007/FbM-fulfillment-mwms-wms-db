
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_838ExtVal41                                     */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purposes: Customized  validation for AEO MEX packing (Fn 838)        */
/*                                                                      */
/* Date       Rev  Author      Purposes                                 */
/* 2026/06/30 1.0  Jackc       FCR-12984 Created                        */
/************************************************************************/

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

   DECLARE
      @cPickStatus         NVARCHAR( 1),     
      @cWaveKey            NVARCHAR( 10),
      @cPickUoM            NVARCHAR( 10),
      @cWaveType           NVARCHAR( 20),
      @cWaveSubType        NVARCHAR( 20),
      @nRowCount           INT

   IF @nFunc = 838
   BEGIN
      IF @nStep = 1 -- Screen 1: Scan DropID (Tote or UCC)
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SET @cPickStatus = rdt.RDTGetConfig( @nFunc, 'PickStatus', @cStorerKey)
            IF @cPickStatus = '0'
               SET @cPickStatus = '5'

            SET @cWaveKey     = ''
            SET @cPickUom     = 0
            SET @cWaveType    = ''
            SET @cWaveSubType = ''

            -- Fetch WaveKey and UoM for this DropID
            SELECT TOP 1
               @cWaveKey = ISNULL( WaveKey, ''),
               @cPickUom = UOM
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey 
               AND DropID = @cFromDropID
               AND Status = @cPickStatus

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
                  OR ( @cWaveType = 'ECOM'  AND @cWaveSubType = 'S' ) )
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

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838ExtVal41 TO NSQL
GO
