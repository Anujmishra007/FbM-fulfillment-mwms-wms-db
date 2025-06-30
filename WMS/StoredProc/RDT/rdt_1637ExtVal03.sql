SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Store procedure: rdt_1637ExtVal03                                    */  
/* Copyright      : MAERSK                                              */  
/*                                                                      */  
/* Purpose: Validate pallet scanned must be closed before proceed       */  
/*                                                                      */  
/* Modifications log:                                                   */            
/*                                                                      */            
/* Date       Rev  Author     Purposes                                  */            
/* 2024-05-28 1.1  James      WMS-25441 Created                         */      
/************************************************************************/            

CREATE OR ALTER PROC [RDT].[rdt_1637ExtVal03] (
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

   DECLARE @cOrderKey      NVARCHAR( 10)
   DECLARE @cErrMsg01      NVARCHAR( 20)

   IF @nStep = 3 -- PalletKey
   BEGIN
      IF @nInputKey = 1  -- ENTER
      BEGIN
         IF NOT EXISTS ( SELECT 1
                         FROM dbo.PALLET WITH (NOLOCK)
                         WHERE StorerKey = @cStorerkey
                         AND   PalletKey = @cPalletKey
                         AND   [Status] = '9')
         BEGIN
            SET @nErrNo = 215651
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PltNotClosed
            GOTO Fail
         END
      END
   END

Fail:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON  [RDT].[rdt_1637ExtVal03] TO [NSQL]
GO
