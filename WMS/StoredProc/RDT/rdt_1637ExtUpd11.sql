SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1637ExtUpd11                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2025-08-13 1.0  Dennis     FCR-6080  Created                         */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1637ExtUpd11] (
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @nStep         INT,
   @nInputKey     INT,
   @cStorerkey    NVARCHAR( 15),
   @cContainerKey NVARCHAR( 10),
   @cMBOLKey      NVARCHAR( 10),
   @cSSCCNo       NVARCHAR( 20),
   @cPalletKey    NVARCHAR( 18),
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

   DECLARE @cData1 NVARCHAR(60)
   DECLARE @cData2 NVARCHAR(60)
   DECLARE @cData3 NVARCHAR(60)
   DECLARE @cData4 NVARCHAR(60),
   @nRowCount INT

   IF @nFunc = 1637 -- Scan to container
   BEGIN
      IF @nStep = 3
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT @cData1 = UserDefine03,
                  @cData2 = UserDefine01
            FROM dbo.PALLETDETAIL WITH (NOLOCK)
            WHERE PalletKey = @cPalletKey
            AND StorerKey = @cStorerkey

            SELECT @cData3 = CT.KeyName,@cData4 = CT.TrackingNo 
            FROM dbo.PALLET P WITH (NOLOCK)
            JOIN dbo.CARTONTRACK CT WITH (NOLOCK) ON CT.LABELNO = P.PalletKey
            WHERE P.StorerKey = @cStorerkey
            AND   P.PalletKey = @cPalletKey
            AND   CT.CARRIERNAME <> ''
            AND   CT.CARRIERNAME <> 'INTERNAL'

            SET @nRowCount = @@ROWCOUNT
            IF @nRowCount = 0
            BEGIN
               SELECT @cData3 = CT.KeyName,@cData4 = CT.TrackingNo 
               FROM dbo.PALLETDETAIL P WITH (NOLOCK)
               JOIN dbo.CARTONTRACK CT WITH (NOLOCK) ON CT.LABELNO = P.CASEID
               WHERE P.StorerKey = @cStorerkey
               AND   P.PalletKey = @cPalletKey
               AND   CT.CARRIERNAME <> ''
               AND   CT.CARRIERNAME <> 'INTERNAL'
            END

            UPDATE dbo.ContainerDetail SET
               UserDefine01 = @cData3,--Keyname
               UserDefine02 = @cData1,--UserDefine03
               UserDefine03 = @cData4,--TrackingNo
               UserDefine04 = @cData2 --UserDefine01
            WHERE ContainerKey = @cContainerKey AND PalletKey = @cPalletKey

         END
      END
   END

Quit:
GO

GRANT EXECUTE ON  [RDT].[rdt_1637ExtUpd11] TO [NSQL]
GO
