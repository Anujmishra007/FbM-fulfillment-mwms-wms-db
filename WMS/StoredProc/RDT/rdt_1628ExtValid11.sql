SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_1628ExtValid11                                     */
/* Purpose: Validate lane assignment before picking                        */
/*                                                                         */
/* Called from: rdtfnc_Cluster_Pick                                        */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date        Rev  Author     Purposes                                    */
/* 2026-05-26  1.0  NYE018     FCR-12622 Created - Lane assignment check   */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1628ExtValid11] (
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

   DECLARE @cOrderKeyFromWave   NVARCHAR( 10),
           @cLoadKeyFromOrder   NVARCHAR( 10),
           @cLaneLoc            NVARCHAR( 10),
           @cUserName           NVARCHAR( 18)

   SELECT @cUserName = UserName FROM rdt.RDTMOBREC WITH(NOLOCK) WHERE Mobile = @nMobile

   SET @nErrNo = 0

   -- Step 1: WaveKey scan validation
   IF @nStep = 1
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         -- Only validate if WaveKey is provided
         IF ISNULL(@cWaveKey, '') <> ''
         BEGIN
            -- Fetch first OrderKey from WAVEDETAIL for this WaveKey
            SELECT TOP 1 @cOrderKeyFromWave = WD.OrderKey
            FROM dbo.WAVEDETAIL WD WITH (NOLOCK)
            WHERE WD.WaveKey = @cWaveKey

            IF @cOrderKeyFromWave IS NOT NULL
            BEGIN
               -- Fetch LoadKey from ORDERS table
               SELECT @cLoadKeyFromOrder = O.LoadKey
               FROM dbo.ORDERS O WITH (NOLOCK)
               WHERE O.OrderKey = @cOrderKeyFromWave

               IF @cLoadKeyFromOrder IS NOT NULL AND ISNULL(@cLoadKeyFromOrder, '') <> ''
               BEGIN
                  -- Fetch lane from LOADPLANLANEDETAIL table
                  SELECT TOP 1 @cLaneLoc = LPLD.Loc
                  FROM dbo.LOADPLANLANEDETAIL LPLD WITH (NOLOCK)
                  WHERE LPLD.LoadKey = @cLoadKeyFromOrder

                  -- If no entry found or LOC is empty, error
                  IF @cLaneLoc IS NULL OR ISNULL(@cLaneLoc, '') = ''
                  BEGIN
                     SET @nErrNo = 267951
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Lane not assigned
                     GOTO Quit
                  END
               END
               ELSE
               BEGIN
                  -- No LoadKey found on the order
                  SET @nErrNo = 267952
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Lane not assigned
                  GOTO Quit
               END
            END
            ELSE
            BEGIN
               -- No order found in wave
               SET @nErrNo = 267953
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No order in wave
               GOTO Quit
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

GRANT EXECUTE ON RDT.rdt_1628ExtValid11 TO NSQL
GO
