
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_838ExtVal19                                     */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purposes: Customized validation for Levis US                         */
/*                                                                      */
/* Date       Rev  Author      Purposes                                 */
/* 2024/06/18 1.0  Jackc       FCR-392 created                          */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838ExtVal19 (
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

   DECLARE  @nTotalPick       INT,
            @nTotalPack       INT,
            @cCartTrkLabelNo NVARCHAR( 20)

   IF @nFunc = 838 -- Pack
   BEGIN
      IF @nStep = 2 -- statistic screen
      BEGIN
         IF @nInputKey = 1
         BEGIN
            -- Get total pick and total pack from RDTMOBREC
            --V_Integer4     = @nTotalPick,
            --V_Integer5     = @nTotalPack,
            SELECT @nTotalPick = ISNULL(V_Integer4,0)
                  ,@nTotalPack = ISNULL(V_Integer5,0)
            FROM RDT.RDTMOBREC WITH (NOLOCK)
            WHERE Mobile = @nMobile

            IF @nTotalPick = 0
            BEGIN
               SET @nErrNo = 217501
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Nothing Picked
               GOTO Quit
            END

            IF @nTotalPick < @nTotalPack
            BEGIN
               SET @nErrNo = 217502
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PickedMoreThanPacked
               GOTO Quit
            END

            IF @nTotalPick = @nTotalPack AND @cOption = '1'
            BEGIN
               SET @nErrNo = 217503
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option
               GOTO Quit
            END

         END
      END -- step2
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838ExtVal19 TO NSQL
GO
