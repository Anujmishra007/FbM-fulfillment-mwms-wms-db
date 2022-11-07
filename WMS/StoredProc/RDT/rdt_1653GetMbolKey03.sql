SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1653GetMbolKey03                                */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Called from: rdt_TrackNo_SortToPallet_GetMbolKey                     */
/*                                                                      */
/* Purpose: Get MBOLKey                                                 */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2022-09-15  1.0  James    WMS-20667. Created                         */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1653GetMbolKey03] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cTrackNo       NVARCHAR( 40),
   @cOrderKey      NVARCHAR( 20),
   @cPalletKey     NVARCHAR( 20) OUTPUT,
   @cMBOLKey       NVARCHAR( 10) OUTPUT,
   @cLane          NVARCHAR( 20) OUTPUT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cCur_ShipperKey   NVARCHAR( 15) = ''
   DECLARE @cNew_ShipperKey   NVARCHAR( 15) = ''
   DECLARE @cCur_OrderKey     NVARCHAR( 10) = ''
   DECLARE @cPalletNotAllowMixShipperKey  NVARCHAR( 1)

   IF ISNULL( @cOrderKey, '') = ''
      SELECT @cOrderKey = OrderKey,
             @cNew_ShipperKey = ShipperKey
      FROM dbo.ORDERS WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND   TrackingNo = @cTrackNo
   ELSE
      SELECT @cNew_ShipperKey = ShipperKey
      FROM dbo.ORDERS WITH (NOLOCK)
      WHERE OrderKey = @cOrderKey

   SET @cMBOLKey = ''
   SELECT @cMBOLKey = MbolKey
   FROM dbo.MBOLDETAIL WITH (NOLOCK)
   WHERE OrderKey = @cOrderKey

   SET @cLane = ''
   SELECT @cLane = ExternMbolKey
   FROM dbo.MBOL WITH (NOLOCK)
   WHERE MbolKey = @cMBOLKey
   
   IF @cMBOLKey <> '' AND @cLane <> ''
   BEGIN
      IF EXISTS ( SELECT 1 FROM MBOL WITH (NOLOCK)
                  WHERE MbolKey = @cMBOLKey
                  AND   [Status] = '9')
      BEGIN
         SET @nErrNo = 191451
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MBOL Shipped
         GOTO Quit
      END

      SET @cPalletKey = ''
      SELECT TOP 1 
         @cPalletKey = PalletKey
      FROM dbo.PALLETDETAIL WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND   UserDefine01 = @cOrderKey
      ORDER BY EditDate DESC 

      SET @cPalletNotAllowMixShipperKey = rdt.RDTGetConfig( @nFunc, 'PalletNotAllowMixShipperKey', @cStorerkey)  
      IF @cPalletNotAllowMixShipperKey = '0'  
         SET @cPalletNotAllowMixShipperKey = ''  
  
      -- 1 pallet 1 shipperkey  
      IF @cPalletNotAllowMixShipperKey = '1'  
      BEGIN  
         -- Get orderkey from existing pallet  
         SELECT TOP 1 @cCur_OrderKey = UserDefine01  
         FROM dbo.PALLETDETAIL WITH (NOLOCK)  
         WHERE PalletKey = @cPalletKey  
         AND   StorerKey = @cStorerKey  
         AND   [Status] = '0'  
         ORDER BY 1  
  
         -- Get shipperkey from orders on existing pallet  
         SELECT @cCur_ShipperKey = ShipperKey  
         FROM dbo.ORDERS WITH (NOLOCK)  
         WHERE OrderKey = @cCur_OrderKey  
  
         -- Validate if same shipperkey  
         IF @cCur_ShipperKey <> @cNew_ShipperKey  
         BEGIN  
            SET @cMBOLKey = ''  
            SET @cPalletKey = ''  
            SET @cLane = ''  
         END  
      END
   END

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1653GetMbolKey03 TO NSQL
GO
