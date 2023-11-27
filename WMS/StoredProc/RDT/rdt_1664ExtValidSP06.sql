
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1664ExtValidSP06                                */
/* Copyright      : LF Logistics                                        */
/* Purpose        : rdt_1664ExtValidSP05->rdt_1664ExtValidSP06          */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2023-11-10 1.0  yeekung    WMS-24120 Created                         */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_1664ExtValidSP06 (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @cStorerKey      NVARCHAR( 15),
   @cMBOLKey        NVARCHAR( 10),
   @cOrderKey       NVARCHAR( 10),
   @cTrackNo        NVARCHAR( 18),
   @nValid          INT            OUTPUT,
   @nErrNo          INT            OUTPUT,
   @cErrMsg         NVARCHAR( 20)  OUTPUT,
   @cErrMsg1        NVARCHAR( 20)  OUTPUT,
   @cErrMsg2        NVARCHAR( 20)  OUTPUT,
   @cErrMsg3        NVARCHAR( 20)  OUTPUT,
   @cErrMsg4        NVARCHAR( 20)  OUTPUT,
   @cErrMsg5        NVARCHAR( 20)  OUTPUT
)
AS

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cDriverName       NVARCHAR( 30)
   DECLARE @cOtherReference   NVARCHAR( 30)
   DECLARE @cPlatform         NVARCHAR( 20)
   DECLARE @cShipperKey       NVARCHAR( 15)
   DECLARE @nStep             INT
   DECLARE @nInputKey         INT

   SELECT 
      @nStep = Step, 
      @nInputKey = InputKey
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
   
   IF @nFunc = 1664 -- Track no to MBOL creation
   BEGIN
      IF @nStep = 2 -- Track no
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Get MBOL info
            SELECT 
               @cDriverName = DriverName, 
               @cOtherReference = OtherReference
            FROM dbo.MBOL WITH (NOLOCK)
            WHERE MbolKey = @cMBOLKey
            
            -- Get order info
            SELECT @cShipperKey = ShipperKey
            FROM dbo.ORDERS WITH (NOLOCK)
            WHERE TrackingNo = @cTrackNo
            AND   StorerKey = @cStorerKey
            
            SELECT @cPlatform = ISNULL( Platform, '') 
            FROM dbo.OrderInfo WITH (NOLOCK) 
            WHERE OrderKey = @cOrderKey
            
            -- Cannot Mix shipperkey
            IF @cDriverName <> @cShipperKey AND @cDriverName <> 'ALL'
            BEGIN
                SET @nErrNo = 208651
                SET @cErrMsg1 = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Mismatch MBOL
            
                SET @nValid = 0 -- Insert message queue
                GOTO QUIT
            END

            -- Cannot Mix platform
			   IF @cPlatform NOT LIKE @cOtherReference AND @cOtherReference <> 'ALL' --NL01
            BEGIN  
                SET @nErrNo = 208652
                SET @cErrMsg1 = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Mismatch MBOL
            
                SET @nValid = 0 -- Insert message queue
                GOTO QUIT
            END
         END
      END
   END

Quit:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1664ExtValidSP06 TO NSQL
GO