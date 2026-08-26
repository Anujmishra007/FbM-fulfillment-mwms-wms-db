SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_840GenLabelNo09                                */
/* Copyright      : Maersk                                                    */
/* Customer       : RIMAN JPN                                                 */
/* Purpose        : Generate 12-digit sequential LabelNo for PackDetail       */
/*                  Sequence: 000000000001 ~ 999999999999                     */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date         Author    Ver.    Purposes                                    */
/* 2026-08-20   DennisA   1.0.0   FCR-14958 Created, Configkey=ExtendedLabelNoSP */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_840GenLabelNo09]
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cStorerkey      NVARCHAR( 15),
   @cOrderKey       NVARCHAR( 10),
   @cPickSlipNo     NVARCHAR( 10),
   @cTrackNo        NVARCHAR( 20),
   @cSKU            NVARCHAR( 20),
   @cLabelNo        NVARCHAR( 20) OUTPUT,
   @nCartonNo       INT           OUTPUT,
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @bSuccess INT = 1

   EXECUTE nspg_GetKey
      'PACKNO_RIMAN',
      12,
      @cLabelNo  OUTPUT,
      @bSuccess  OUTPUT,
      @nErrNo    OUTPUT,
      @cErrMsg   OUTPUT

   IF @bSuccess <> 1
   BEGIN
      SET @nErrNo = 277654
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Gen LabelNo Fail
      GOTO Quit
   END

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_840GenLabelNo09 TO NSQL
GO
