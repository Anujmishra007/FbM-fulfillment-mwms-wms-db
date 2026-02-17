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
/* 2025-08-13 1.2  Dennis     FCR-6080  Add Validation                  */      
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
   DECLARE @cErrMsg01      NVARCHAR( 20),
   @cExternMbolKey         NVARCHAR( 60)

   IF @nFunc = 1637
   BEGIN
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
            IF NOT EXISTS (SELECT 1 FROM dbo.PALLETDETAIL PD WITH (NOLOCK)
                           JOIN dbo.ORDERS O WITH (NOLOCK) ON O.OrderKey = PD.UserDefine01 AND  O.StorerKey = @cStorerkey
                           JOIN dbo.CONTAINER C WITH (NOLOCK) ON C.ContainerKey = @cContainerKey AND C.Carrieragent = O.ShipperKey
                           WHERE PD.StorerKey = @cStorerkey
                           AND   PD.PalletKey = @cPalletKey)
            BEGIN
               SET @nErrNo = 215652
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DifferentCarrier
               GOTO Fail
            END
            IF NOT EXISTS (SELECT 1 FROM dbo.PALLET P WITH (NOLOCK)
                           JOIN dbo.CARTONTRACK CT WITH (NOLOCK) ON CT.LABELNO = P.PalletKey
                           WHERE P.StorerKey = @cStorerkey
                           AND   P.PalletKey = @cPalletKey
                           AND   CT.CARRIERNAME <> ''
                           AND   CT.CARRIERNAME <> 'INTERNAL')
            AND NOT EXISTS (SELECT 1 FROM dbo.PALLETDETAIL P WITH (NOLOCK)
                           JOIN dbo.CARTONTRACK CT WITH (NOLOCK) ON CT.LABELNO = P.CASEID
                           WHERE P.StorerKey = @cStorerkey
                           AND   P.PalletKey = @cPalletKey
                           AND   P.CASEID <> ''
                           AND   P.CASEID IS NOT NULL
                           AND   CT.CARRIERNAME <> ''
                           AND   CT.CARRIERNAME <> 'INTERNAL')
            BEGIN
               SET @nErrNo = 215653
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pallet has no Carrier Label
               GOTO Fail
            END

         END
      END
      IF @nStep = 6
      BEGIN
         IF @nInputKey = 1  -- ENTER
         BEGIN
            SELECT TOP 1 @cExternMbolKey = PD.UserDefine03 FROM dbo.CONTAINER C WITH (NOLOCK) 
            JOIN CONTAINERDETAIL CD WITH (NOLOCK) ON CD.ContainerKey = C.CONTAINERKEY
            JOIN PALLETDETAIL PD WITH (NOLOCK) ON PD.PalletKey = CD.PALLETKEY AND PD.StorerKey = @cStorerkey
            WHERE C.ContainerKey = @cContainerKey

            IF EXISTS ( SELECT 1 FROM PALLETDETAIL PD WITH (NOLOCK)
                        LEFT JOIN dbo.CONTAINERDETAIL CD WITH (NOLOCK) ON CD.PalletKey = PD.PalletKey
                        WHERE PD.StorerKey = @cStorerkey
                        AND PD.UserDefine03 = @cExternMbolKey
                        AND (CD.ContainerKey = '' OR CD.ContainerKey IS NULL))
            OR NOT EXISTS (SELECT 1 FROM dbo.CONTAINERDETAIL CD WITH (NOLOCK) WHERE CD.ContainerKey = @cContainerKey )
            BEGIN
               SET @nErrNo = 215654
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NotAllPalletsScanned
               GOTO Fail
            END
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
