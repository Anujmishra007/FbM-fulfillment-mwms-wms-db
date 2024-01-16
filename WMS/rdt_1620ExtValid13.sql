SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_1620ExtValid13                                  */
/* Purpose: DropID cannot mix wave                                      */
/*                                                                      */
/* Called from: rdtfnc_Cluster_Pick                                     */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 2023-12-07  1.0  James      WMS-24296. Created                       */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1620ExtValid13] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cStorerkey       NVARCHAR( 15),
   @cWaveKey         NVARCHAR( 10),
   @cLoadKey         NVARCHAR( 10),
   @cOrderKey        NVARCHAR( 10),
   @cLoc             NVARCHAR( 10),
   @cDropID          NVARCHAR( 20),
   @cSKU             NVARCHAR( 20),
   @nQty             INT,
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
)
AS

	SET NOCOUNT ON
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS OFF
	SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cTempOrderKey     NVARCHAR( 10)
   DECLARE @cTempWaveKey      NVARCHAR( 10)

   SET @nErrNo = 0

   IF @nFunc = 1620
   BEGIN
      IF @nStep = 7
      BEGIN
         IF @nInputKey = 1
         BEGIN
            SELECT @cWaveKey = ISNULL( V_String1, '')
            FROM RDT.RDTMOBREC WITH (NOLOCK)
            WHERE Mobile = @nMobile

            SELECT TOP 1 @cTempOrderKey = PD.OrderKey
            FROM dbo.PICKDETAIL PD WITH (NOLOCK)
            WHERE PD.Storerkey = @cStorerkey
            AND   PD.DropID = @cDropID
            AND   PD.[Status] < '9'
            ORDER BY 1

            -- If this dropid already picked something
            IF ISNULL( @cTempOrderKey, '') <> ''
            BEGIN
               -- Check if the orders inside this dropid has the same
               -- wavekey as the one that user scan from screen 1
               SELECT @cTempWaveKey = UserDefine09
               FROM dbo.ORDERS WITH (NOLOCK)
               WHERE OrderKey = @cTempOrderKey

               IF @cTempWaveKey <> @cWaveKey
               BEGIN
                  SET @nErrNo = 209601
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --OtherWaveInTote
                  GOTO Quit
               END
            END
         END
      END
   END

QUIT:
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXECUTE ON  [RDT].[rdt_1620ExtValid13] TO [NSQL]
GO
