SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_838ExtVal31                                     */
/* Copyright      : Maersk WMS                                          */
/* Customer       : REDBULL                                             */
/*                                                                      */
/* Date       Rev    Author      Purposes                               */
/* 2025-05-06 1.0    NLT013      UWP-33515 Created                      */
/* 2025-06-03 1.1.0  NLT013      UWP-33515 Rollback to first version    */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838ExtVal31 (
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
      @cPickSlipNoForSerialNo       NVARCHAR( 10),
      @nRowCount                    INT

   IF @nFunc = 838 -- Pack
   BEGIN
      IF @nStep = 9 -- SerialNo
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT @cPickSlipNoForSerialNo = PickSlipNo
            FROM dbo.PackSerialNo WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND SerialNo = @cSerialNo
         
            SELECT @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               IF @cPickSlipNoForSerialNo <> @cPickSlipNo
               BEGIN
                  SET @nErrNo = 237702    --SerialNo was scanned to other PickSlipNo
               END
               ELSE
               BEGIN
                  SET @nErrNo = 237703    --SerialNo was scanned to current PickSlipNo
               END
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
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

GRANT EXECUTE ON RDT.rdt_838ExtVal31 TO NSQL
GO
