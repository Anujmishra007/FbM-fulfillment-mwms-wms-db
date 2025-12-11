SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  
/************************************************************************/
/* Store procedure: rdt_1720ExtValidSP02                                */
/* Purpose: Validate                                                    */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2025-12-07 1.0  NickT      FCR-8808 Created                          */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_1720ExtValidSP02 (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @cStorerKey     NVARCHAR( 15),
   @cFacility      NVARCHAR( 5),
   @cFromPalletID  NVARCHAR( 20),
   @cToPalletID    NVARCHAR( 20),
   @cDropID        NVARCHAR( 20),
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF

DECLARE
   @cAllowConsolidatePalletStatus5 NVARCHAR(5)

   SET @cAllowConsolidatePalletStatus5 = rdt.RDTGetConfig( @nFunc, 'AllowConsolidatePalletStatus5', @cStorerKey)

IF @nFunc = 1720
BEGIN
   IF @nStep = 1
   BEGIN
      IF @cAllowConsolidatePalletStatus5 = '0'
      BEGIN
         IF EXISTS (SELECT 1 
                     FROM dbo.Pallet WITH (NOLOCK) 
                     WHERE PalletKey = @cFromPalletID 
                        AND Status = '5')
         BEGIN
            SET @nErrNo = 253101
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Pallet was Scaned To Truck
            EXEC rdt.rdtSetFocusField @nMobile, 1
            GOTO QUIT
         END
      END

      IF EXISTS ( SELECT 1 FROM dbo.Pallet PL WITH (NOLOCK) 
                  INNER JOIN dbo.PalletDetail PD WITH (NOLOCK) ON PD.PalletKey = PL.PalletKey 
                  WHERE PL.PalletKey = @cFromPalletID 
                     AND PL.Status = '9'
                     AND ISNULL(PD.UserDefine04,'') <> ''
                  )
      BEGIN
         SET @nErrNo = 253102
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Pallet was Shipped
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO QUIT
      END
   END
   ELSE IF @nStep = 2
   BEGIN
      IF @cFromPalletID = @cToPalletID
      BEGIN
         SET @nErrNo = 253107
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- To Pallet cannot be the same as From Pallet
         GOTO QUIT
      END

      IF @cAllowConsolidatePalletStatus5 = '0'
      BEGIN
         IF EXISTS (SELECT 1 
                     FROM dbo.Pallet WITH (NOLOCK) 
                     WHERE PalletKey = @cToPalletID 
                        AND Status = '5')
         BEGIN
            SET @nErrNo = 253103
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Pallet was Scaned To Truck
            GOTO QUIT
         END
      END

      IF EXISTS ( SELECT 1 FROM dbo.Pallet PL WITH (NOLOCK) 
                  INNER JOIN dbo.PalletDetail PD WITH (NOLOCK) ON PD.PalletKey = PL.PalletKey 
                  WHERE PL.PalletKey = @cToPalletID 
                     AND PL.Status = '9'
                     AND ISNULL(PD.UserDefine04,'') <> ''
                  )
      BEGIN
         SET @nErrNo = 253104
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Pallet was Shipped
         GOTO QUIT
      END

      DECLARE 
         @cSrcPalletMBOLKey               NVARCHAR(10),
         @cDestPalletMBOLKey              NVARCHAR(10),
         @cSrcPalletConsigneeKey          NVARCHAR(15),
         @cDestPalletConsigneeKey         NVARCHAR(15)

      SELECT TOP 1
         @cSrcPalletMBOLKey = MD.MBOLKey,
         @cSrcPalletConsigneeKey = ORM.ConsigneeKey
      FROM dbo.ORDERS ORM WITH(NOLOCK)
      INNER JOIN dbo.MBOLDetail MD WITH(NOLOCK) ON MD.OrderKey = ORM.OrderKey
      INNER JOIN dbo.PalletDetail PD WITH(NOLOCK) ON PD.OrderKey = ORM.OrderKey
      WHERE PD.PalletKey = @cFromPalletID
         AND ORM.StorerKey = @cStorerKey

      SELECT TOP 1
         @cDestPalletMBOLKey = MD.MBOLKey,
         @cDestPalletConsigneeKey = ORM.ConsigneeKey
      FROM dbo.ORDERS ORM WITH(NOLOCK)
      INNER JOIN dbo.MBOLDetail MD WITH(NOLOCK) ON MD.OrderKey = ORM.OrderKey
      INNER JOIN dbo.PalletDetail PD WITH(NOLOCK) ON PD.OrderKey = ORM.OrderKey
      WHERE PD.PalletKey = @cToPalletID
         AND ORM.StorerKey = @cStorerKey

      IF ISNULL(@cSrcPalletMBOLKey, '-1') <> ISNULL(@cDestPalletMBOLKey, '-2')
      BEGIN
         SET @nErrNo = 253105
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Different MBOLs
         GOTO QUIT
      END

      IF ISNULL(@cSrcPalletConsigneeKey, '-1') <> ISNULL(@cDestPalletConsigneeKey, '-2')
      BEGIN
         SET @nErrNo = 253106
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Different Ship-to
         GOTO QUIT
      END
   END
   ELSE IF Step = 3
   BEGIN
      IF NOT EXISTS ( SELECT  1 FROM dbo.PalletDetail WITH (NOLOCK) WHERE CaseID = @cToteNo ) 
      BEGIN 
            SET @nErrNo = 253108
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidTote
            GOTO QUIT
      END
         
      IF EXISTS ( SELECT 1 FROM dbo.PalletDetail WITH (NOLOCK) WHERE CaseID = @cToteNo AND Status = '5')
      BEGIN
            SET @nErrNo = 253109
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Tote is scaned to truck
            GOTO QUIT
      END
      
      IF EXISTS ( SELECT 1 FROM dbo.PalletDetail WITH (NOLOCK) WHERE CaseID = @cToteNo AND Status = '9' AND UserDefine04 <> '' )
      BEGIN
            SET @nErrNo = 253110
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Tote is shipped
            GOTO QUIT
      END
      
      IF NOT EXISTS ( SELECT 1 FROM dbo.PalletDetail WITH (NOLOCK) WHERE CaseID = @cToteNo AND Status = '3' ) 
      BEGIN
            SET @nErrNo = 253111
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pallet is not closed
            GOTO QUIT
      END
   END
END

QUIT:
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXEC ON RDT.rdt_1720ExtValidSP02 TO NSQL
GO

