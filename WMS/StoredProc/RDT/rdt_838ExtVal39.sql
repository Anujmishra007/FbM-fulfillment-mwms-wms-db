SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_838ExtVal39                                     */
/* Copyright      : Maersk WMS                                          */
/* Customer       : LEVIS UAE                                           */
/*                                                                      */
/* Date       Rev    Author      Purposes                               */
/* 2026-02-18 1.0    SSR259      FCR-10629 Full UCC Pack Modification   */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838ExtVal39 (
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

   DECLARE @cPickCompleteValidation NVARCHAR(1)

   IF @nFunc = 838
   BEGIN
      -- Step 1: Picking Complete Validation (Configurable)
      IF @nStep = 1 
      BEGIN
         IF @cPickSlipNo <> ''
         BEGIN
            SET @cPickCompleteValidation = rdt.RDTGetConfig(@nFunc, 'PickCompleteValidation', @cStorerKey)

            IF @cPickCompleteValidation = '1'
            BEGIN
               IF EXISTS (SELECT 1 FROM dbo.PICKDETAIL WITH (NOLOCK)
                          WHERE PickSlipNo = @cPickSlipNo
                          AND Status NOT IN ('4','5'))
               BEGIN
                  SET @nErrNo = 259201
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END
            END
         END
      END

      -- Step 4: Option 1 RefNo Mandatory
      IF @nStep = 4 
      BEGIN
         IF @cOption = '1' 
         BEGIN
            IF @nInputKey = 1
            BEGIN
               IF ISNULL(@cRefNo, '') = ''
               BEGIN
                  SET @nErrNo = 259203
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END
            END
         END
      END

      -- Step 8: UCC UOM = 2 Validation
      IF @nStep = 8 
      BEGIN
         IF @cUCCNo <> ''
         BEGIN
            -- Retrieve actual valus from DB for validation
            DECLARE @cCheckUOM NVARCHAR(20) = NULL
            DECLARE @cCheckStatus NVARCHAR(10) = NULL
            DECLARE @cCheckDropID NVARCHAR(50) = NULL

            SELECT TOP 1 
               @cCheckUOM = UOM, 
               @cCheckStatus = Status,
               @cCheckDropID = DropID
            FROM dbo.PICKDETAIL WITH (NOLOCK)
            WHERE DropID = @cUCCNo
              AND PickSlipNo = @cPickSlipNo
              AND StorerKey = @cStorerKey
              
            -- Check: Must exist, Match UOM=2, Match Status=5
            IF (@cCheckDropID IS NULL OR @cCheckUOM <> '2' OR @cCheckStatus <> '5')
            BEGIN
               SET @nErrNo = 259202
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Invalid PickDetail UOM
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

GRANT EXECUTE ON RDT.rdt_838ExtVal39 TO NSQL
GO
