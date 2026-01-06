
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_832ExtValid03                                   */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2025-09-17   1.0  Cuize      FCR-7763                                */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_832ExtValid03] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cStorerKey     NVARCHAR( 15),
   @cFacility      NVARCHAR( 5),
   @tExtVal        VariableTable READONLY,
   @cDoc1Value     NVARCHAR( 20),
   @cCartonID      NVARCHAR( 20),
   @cCartonSKU     NVARCHAR( 20),
   @nCartonQTY     INT,
   @cPackInfo      NVARCHAR( 4),
   @cCartonType    NVARCHAR( 10),
   @cCube          NVARCHAR( 10),
   @cWeight        NVARCHAR( 10),
   @cPackInfoRefNo NVARCHAR( 20),
   @cPickSlipNo    NVARCHAR( 10),
   @nCartonNo      INT,
   @cLabelNo       NVARCHAR( 20),
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 1024) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 832 -- Carton pack
   BEGIN
      IF @nStep = 1  -- Doc
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Check blank
            IF @cDoc1Value = ''
            BEGIN
               SET @nErrNo = 247051
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need PickslipNo
               GOTO Quit
            END

            IF NOT EXISTS(
               SELECT 1 FROM PackHeader WITH (NOLOCK )
               WHERE Storerkey = @cStorerKey
                 AND PickSlipNo = @cDoc1Value
            )
            BEGIN
               SET @nErrNo = 247055
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --247055PackHeaderNotExists
               GOTO Quit
            END

            IF NOT EXISTS(
               SELECT 1 FROM PackHeader WITH (NOLOCK )
               WHERE Storerkey = @cStorerKey
                 AND PickSlipNo = @cDoc1Value
                 AND status = 9 -- Packed
            )
            BEGIN
               SET @nErrNo = 247052
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --247002PackStatusWrong
               GOTO Quit
            END
         END
      END

      IF @nStep = 2  -- Doc
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN

            IF NOT EXISTS(
               SELECT 1 FROM PACKDETAIL WITH (NOLOCK )
               WHERE Storerkey = @cStorerKey
                 AND PickSlipNo = @cDoc1Value
                 AND RefNO2 = @cCartonID
            )
            BEGIN
               SET @nErrNo = 247053
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --247053CartonIdNotValid
               GOTO Quit
            END

         END
      END

      IF @nStep = 4  -- RefNo
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF ISNULL(@cPackInfoRefNo,'') = ''
            BEGIN
               SET @nErrNo = 247054
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --247054NeedRefNo
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

GRANT EXECUTE ON rdt.rdt_832ExtValid03 to nSQL
GO
