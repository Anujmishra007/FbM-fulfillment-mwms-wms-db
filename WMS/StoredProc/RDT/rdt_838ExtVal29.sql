SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_838ExtVal29                                     */
/* Copyright      : Maersk WMS                                          */
/* Customer       : Royal Enfield                                       */
/*                                                                      */
/* Date       Rev  Author      Purposes                                 */
/* 2025-04-18 1.0  CYU027      FCR-3473 Created                         */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838ExtVal29 (
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

   DECLARE @nMaxWeight FLOAT
   DECLARE @nInputWeight FLOAT

   IF @nFunc = 838 -- Pack
   BEGIN
      IF @nStep = 4 -- Weight
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN

            SET @nInputWeight = ISNULL( CAST( @cWeight AS FLOAT), 0)

            IF @nInputWeight > 0
            BEGIN

               SELECT
                  @nMaxWeight= ISNULL( MaxWeight, 0)
               FROM Cartonization WITH (NOLOCK)
                  INNER JOIN Storer WITH (NOLOCK) ON (Storer.CartonGroup = Cartonization.CartonizationGroup)
               WHERE Storer.StorerKey = @cStorerKey
                 AND Cartonization.CartonType = @cCartonType

               IF @nInputWeight > @nMaxWeight
               BEGIN
                  SET @nErrNo = 237001
                  SET @cErrMsg = REPLACE (rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP'),'{}',@nMaxWeight)--Max Weight cannot exceed {}
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

GRANT EXECUTE ON RDT.rdt_838ExtVal29 TO NSQL
GO
