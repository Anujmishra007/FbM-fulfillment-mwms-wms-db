SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
  
/************************************************************************/    
/* Store procedure: rdt_1653GetMbolKey04                                */
/* Copyright      : MAERSK                                              */    
/*                                                                      */    
/* Called from: rdt_TrackNo_SortToPallet_GetMbolKey                     */    
/*                                                                      */    
/* Purpose: Get MBOLKey/Lane/Pallet                                     */
/*                                                                      */    
/* Modifications log:                                                   */    
/* Date        Rev  Author   Purposes                                   */    
/* 2024-07-05  1.0  CYU027   FCR 539. Created                           */
/* 2024-09-20  1.1  CYU027   Add Validation TrackNo                     */
/************************************************************************/
    
CREATE OR ALTER PROC [RDT].[rdt_1653GetMbolKey04] (
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
   @cLane          NVARCHAR( 20) OUTPUT, --Pallet Location
   @nErrNo         INT           OUTPUT,    
   @cErrMsg        NVARCHAR( 20) OUTPUT    
) AS    
BEGIN    
   SET NOCOUNT ON    
   SET ANSI_NULLS OFF    
   SET QUOTED_IDENTIFIER OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
    
   DECLARE @cCur_ShipperKey               NVARCHAR( 15) = ''
   DECLARE @cNew_ShipperKey               NVARCHAR( 15) = ''
   DECLARE @cCur_OrderKey                 NVARCHAR( 10) = ''
   DECLARE @cPalletNotAllowMixShipperKey  NVARCHAR( 1)

   IF EXISTS ( SELECT 1 FROM dbo.PalletDetail WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND (CaseID = @cTrackNo OR TrackingNo = @cTrackNo))
   BEGIN
      SET @nErrNo = 219157
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --TrackNo In Use
      GOTO Quit
   END


   SELECT @cNew_ShipperKey = ShipperKey
   FROM dbo.ORDERS WITH (NOLOCK)
   WHERE OrderKey = @cOrderKey
    
   SET @cMBOLKey = ''    
   SELECT @cMBOLKey = MbolKey    
   FROM dbo.MBOLDETAIL WITH (NOLOCK)    
   WHERE OrderKey = @cOrderKey

   IF @cMBOLKey = ''
   BEGIN
      SET @nErrNo = 219101
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No MBOL found”
      GOTO Quit
   END
   ELSE
   BEGIN    
      IF EXISTS ( SELECT 1 FROM MBOL WITH (NOLOCK)    
                  WHERE MbolKey = @cMBOLKey    
                  AND   [Status] = '9')    
      BEGIN    
         SET @nErrNo = 219102
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MBOL Shipped    
         GOTO Quit    
      END    
    
      SET @cPalletKey = ''    
      SELECT TOP 1     
         @cPalletKey = PalletKey
      FROM dbo.PALLETDETAIL WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey    
      AND   UserDefine01 = @cMBOLKey
      AND   Status = '0'
      ORDER BY EditDate DESC

      SET @cLane = ''
      SELECT TOP 1
         @cLane = LOC
      FROM dbo.PALLETDETAIL WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
        AND   UserDefine01 = @cMBOLKey
      ORDER BY EditDate DESC

      SET @cPalletNotAllowMixShipperKey = rdt.RDTGetConfig( @nFunc, 'PalletNotAllowMixShipperKey', @cStorerkey)    
      IF @cPalletNotAllowMixShipperKey = '0'    
         SET @cPalletNotAllowMixShipperKey = ''    
    
      -- 1 pallet 1 shipperkey    
      IF @cPalletNotAllowMixShipperKey = '1' AND @cPalletKey <> ''   
      BEGIN    
         -- Get orderkey from existing pallet    
         SELECT TOP 1 @cCur_OrderKey = Orderkey,
                      @cLane = LOC
         FROM dbo.PALLETDETAIL WITH (NOLOCK)    
         WHERE PalletKey = @cPalletKey    
         AND   StorerKey = @cStorerKey    
         AND   [Status] = '0'     -- CHANGES   
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
            GOTO Quit
         END    
      END

      IF @cPalletKey = ''
         SET @cPalletKey = 'NEW PALLET'

   END    
Quit:
END 
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1653GetMbolKey04 TO NSQL
GO
