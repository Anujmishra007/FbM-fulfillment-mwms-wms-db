/************************************************************************/
/* Store procedure: rdt_838ExtVal38                                     */
/* Copyright      : Maersk                                              */
/* Customer       : LAQUILA                                             */
/*                                                                      */
/* Date       Rev  Author  Purposes                                     */
/* 2026-01-15 1.0  FRO014  UWP-47425 RITM8508166 Created                */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_838ExtVal38] (
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

   IF @nFunc = 838 -- Pack
   BEGIN
      IF @nStep = 2 -- SKU, QTY
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            ---- Check Drop ID packed
            IF @cFromDropID <> '' AND @cOption = '1' -- NEW
            BEGIN
               DECLARE @nPickDetailTotalQty  INT
               DECLARE @nPPATotalQty         INT

               SELECT @nPPATotalQty = SUM(CQTY)
               FROM rdt.RDTPPA WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND DropID = @cFromDropID

               SELECT @nPickDetailTotalQty = SUM(QTY)
               FROM dbo.PICKDETAIL WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND DropID = @cFromDropID
                  AND STATUS = '5'

               IF ISNULL(@nPPATotalQty, 0) <> ISNULL(@nPickDetailTotalQty, 0)
               BEGIN
                  SET @nErrNo = 257451
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DropID without PPA at 100%
                  GOTO Quit
               END
            END
         END
      END
   END

Quit:

END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_838ExtVal38 TO NSQL
GO