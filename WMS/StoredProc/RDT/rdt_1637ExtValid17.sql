SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: rdt_1637ExtValid17                                        */
/* Copyright      : Maersk                                                    */
/* Customer       : HBDS                                                      */
/*                                                                            */
/* Date       Rev    Author     Purposes                                      */
/* 2025-10-21 1.0.0  NLT013     FCR-8619 Created                              */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1637ExtValid17] (
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @nStep         INT,
   @nInputKey     INT,
   @cStorerkey    NVARCHAR( 15),
   @cContainerKey NVARCHAR( 10),
   @cContainerNo  NVARCHAR( 20),
   @cMBOLKey      NVARCHAR( 10),
   @cSSCCNo       NVARCHAR( 20),
   @cPalletKey    NVARCHAR( 30),
   @cTrackNo      NVARCHAR( 20),
   @cOption       NVARCHAR( 1),
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @nRowCount           INT,
      @cStatus             NVARCHAR( 10),
      @cOrderKey           NVARCHAR( 10),
      @cCurrentContainerNo   NVARCHAR(20),
      @cPickConfirmStatus  NVARCHAR( 1),
      @cMBOLKeyScanned     NVARCHAR( 10)

   SET @nErrNo = 0

   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'
   IF @cPickConfirmStatus NOT IN ( '3', '5')
      SET @cPickConfirmStatus = '5'

   IF @nFunc  = 1637
   BEGIN
      IF @nStep = 3 --ContainerKey & Pallet Key
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF EXISTS (SELECT 1 FROM dbo.ContainerDetail WITH (NOLOCK)
                        WHERE ContainerKey = @cContainerKey
                           AND PalletKey = @cPalletKey)
            BEGIN
               SET @nErrNo = 249501
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Duplicate PalletID
               GOTO Quit
            END

            IF EXISTS (SELECT 1 FROM dbo.ContainerDetail WITH (NOLOCK)
                        WHERE ContainerKey <> @cContainerKey
                           AND PalletKey = @cPalletKey)
            BEGIN
               SET @nErrNo = 249502
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Already Scanned in Different Container'
               GOTO Quit
            END
         END
      END
   END

Fail:

Quit:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  [RDT].[rdt_1637ExtValid17] TO [NSQL]
GO
