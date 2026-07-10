
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_838ExtUpd36                                           */
/* Copyright      : Maersk WMS                                                */
/* Customer       : AEOMX                                                     */
/*                                                                            */
/* Date       Rev     Author     Purposes                                     */
/* 2026-07-08  1.1.0  NickT      FCR-14763 Add B2C Single logic               */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838ExtUpd36 (
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
      @nCurrentScn            INT,
      @nCurrentStep           INT,
      @cB2CSingleFlag         NVARCHAR( 1),
      @cPrintPackList         NVARCHAR( 1)

   SET @cB2CSingleFlag = ''
   SET @cPrintPackList = ''

   SELECT 
      @nCurrentStep = Step, 
      @nCurrentScn = Scn,
      @cB2CSingleFlag = C_STRING7
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 838 -- Pack
   BEGIN
      IF @nCurrentStep = 99 -- ExtScnSP
      BEGIN
         IF @nCurrentScn IN (4653, 6971) -- 4653 = CartonType screen, 6971 = CartonType change screen
         BEGIN
            IF @nInputKey = 1 -- Enter
            BEGIN
               IF ISNULL(@cB2CSingleFlag, '') = 'Y'
               BEGIN
                  -- Pack completed
                  IF EXISTS( SELECT 1 FROM dbo.PackDetail WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Qty > 0 AND Qty = ExpQty)
                     AND NOT EXISTS (SELECT 1 FROM dbo.PackDetail WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Qty < ExpQty)
                     AND EXISTS (SELECT 1 FROM dbo.PickDetail PD WITH (NOLOCK)
                                 INNER JOIN dbo.PickHeader PH WITH(NOLOCK) ON PD.StorerKey = PH.StorerKey AND PD.OrderKey = PH.OrderKey
                                 WHERE PH.PickHeaderKey = @cPickSlipNo
                                    AND PD.StorerKey = @cStorerKey
                                    AND PH.Status <> '9')
                  BEGIN
                     EXEC rdt.rdt_Pack_PackConfirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
                        ,@cPickSlipNo
                        ,@cFromDropID
                        ,@cPackDtlDropID
                        ,@cPrintPackList OUTPUT
                        ,@nErrNo         OUTPUT
                        ,@cErrMsg        OUTPUT

                     IF @nErrNo <> 0
                        GOTO Quit
                  END
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

GRANT EXECUTE ON RDT.rdt_838ExtUpd36 TO NSQL
GO
