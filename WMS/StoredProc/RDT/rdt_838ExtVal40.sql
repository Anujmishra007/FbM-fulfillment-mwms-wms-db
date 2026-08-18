/************************************************************************/
/* Store procedure: rdt_838ExtVal40                                     */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Customer      : ONBR                                                 */
/*                                                                      */
/* Date       Rev  Author  Purposes                                     */
/* 2026-04-13 1.0  JCH507  Created - Validate B2B Order Type only       */
/* 2026-07-28 1.1  NYE018  FCR-13548 B2C Multi UoM6: only option 2      */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_838ExtVal40] (
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

   DECLARE @cB2BUoM6Flag   NVARCHAR( 1)

   IF @nFunc = 838 -- Pack
   BEGIN
      IF @nStep = 2 -- Statistic screen
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT @cB2BUoM6Flag = C_String2 FROM rdt.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile

            IF @cB2BUoM6Flag = '1'
            BEGIN
               IF @cOption = '4'
               BEGIN
                  SET @nErrNo = 263951
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option
                  GOTO Quit 
               END
            END

            -- FCR-13548: B2C-Multi validation - only option 2 allowed
            IF EXISTS (
               SELECT 1
               FROM dbo.PickHeader PH WITH (NOLOCK)
               INNER JOIN dbo.Orders O WITH (NOLOCK) ON PH.OrderKey = O.OrderKey
               WHERE PH.PickHeaderKey = @cPickSlipNo
                  AND O.StorerKey = @cStorerKey
                  AND O.DocType = 'E'
                  AND O.ECOM_SINGLE_Flag = 'M'
            )
            BEGIN
               IF @cOption <> '2'
               BEGIN
                  SET @nErrNo = 263952
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Only option 2 allowed
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
GRANT EXECUTE ON RDT.rdt_838ExtVal40 TO NSQL
GO
