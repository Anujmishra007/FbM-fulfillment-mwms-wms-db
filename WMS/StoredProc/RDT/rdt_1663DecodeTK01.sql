SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_1663DecodeTK01                                        */
/* Copyright      : MAERSK                                                    */
/*                                                                            */
/* Date       Rev  Author   Purposes                                          */
/* 2018-10-02 1.0  Ung      WMS-6516 Created                                  */
/* 2018-11-01 1.1  Ung      WMS-6883 DecodeTrackNoSP output TrackNo           */
/* 2023-07-14 1.2  James    WMS-23121 Extend TrackingNo to 40 chars (james01) */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1663DecodeTK01](
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @nStep         INT,
   @nInputKey     INT,
   @cFacility     NVARCHAR( 5),
   @cStorerKey    NVARCHAR( 15),
   @cPalletKey    NVARCHAR( 20), 
   @cPalletLOC    NVARCHAR( 10), 
   @cMBOLKey      NVARCHAR( 10), 
   @cTrackNo      NVARCHAR( 40) OUTPUT, 
   @cOrderKey     NVARCHAR( 10) OUTPUT, 
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 1663 -- TrackNoToPallet
   BEGIN
      -- Get order info
      SELECT @cOrderKey = OrderKey
      FROM PickHeader WITH (NOLOCK) 
      WHERE PickHeaderKey = @cTrackNo
      
      -- Check track no valid
      IF @@ROWCOUNT = 0
      BEGIN
         SET @nErrNo = 129651
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidTrackNo
         GOTO Quit
      END

      -- Check track no valid
      IF @cOrderKey = ''
      BEGIN
         SET @nErrNo = 129652
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No order
         GOTO Quit
      END
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1663DecodeTK01 TO NSQL
GO