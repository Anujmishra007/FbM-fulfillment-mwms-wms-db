SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1837ExtInfo03                                   */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2026-02-02  1.0  Dennis      FCR-10136 Created                       */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1837ExtInfo03] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cCartonID      NVARCHAR( 20), 
   @cPalletID      NVARCHAR( 20), 
   @cLoadKey       NVARCHAR( 10), 
   @cLoc           NVARCHAR( 10), 
   @cOption        NVARCHAR( 1), 
   @tExtValidate   VariableTable READONLY,
   @cExtendedInfo  NVARCHAR( 20) OUTPUT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cErrMsg01        NVARCHAR( 20),
           @cErrMsg02        NVARCHAR( 20),
           @cErrMsg03        NVARCHAR( 20),
           @cWaveKey         NVARCHAR(10),
           @cDocType         NVARCHAR(10),
           @cConsigneeKey    NVARCHAR(10),
           @nScn             INT

   SELECT @nScn = ISNULL( ( SELECT Value FROM @tExtValidate WHERE Variable = '@nScn'), 0),
         @cDocType = ISNULL( ( SELECT Value FROM @tExtValidate WHERE Variable = '@cDocType'), ''),
         @cWaveKey = ISNULL( ( SELECT Value FROM @tExtValidate WHERE Variable = '@cWAVEKey'), ''),
         @cConsigneeKey = ISNULL( ( SELECT Value FROM @tExtValidate WHERE Variable = '@cConsigneeKey'), '')

   IF @nScn = 5591 -- To Pallet
   BEGIN
      IF @cDocType = 'N' -- Loadkey Consignee Level
      BEGIN
         IF NOT EXISTS ( 
            SELECT 1 FROM dbo.PICKDETAIL PD WITH (NOLOCK)
            JOIN dbo.LOC LOC WITH (NOLOCK) ON ( PD.LOC = LOC.LOC)
            JOIN dbo.LoadPlanDetail LPD WITH (NOLOCK) ON ( LPD.OrderKey = PD.OrderKey)
            JOIN dbo.ORDERS O WITH (NOLOCK) ON O.OrderKey = PD.OrderKey AND O.StorerKey = PD.StorerKey AND O.ConsigneeKey = @cConsigneeKey
            WHERE PD.StorerKey = @cStorerKey
            AND   PD.Status = '5'
            AND   PD.QTY > 0
            AND   LPD.LoadKey = @cLoadKey
            AND   LOC.Facility = @cFacility
            AND   LOC.LocationCategory <> 'PPS')
         BEGIN
            SET @cErrMsg01 = ''
            SET @cErrMsg02 = ''
            SET @cErrMsg03 = ''

            SET @nErrNo = 0
            SET @cErrMsg01 = rdt.rdtgetmessage( 180031, @cLangCode, 'DSP')
            SET @cErrMsg02 = rdt.rdtgetmessage( 180033, @cLangCode, 'DSP') + @cLoadKey
            SET @cErrMsg03 = rdt.rdtgetmessage( 180034, @cLangCode, 'DSP') + @cConsigneeKey

            EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, 
                  @cErrMsg01, @cErrMsg02, @cErrMsg03
            SET @nErrNo = 0   -- Reset error no
         END
      END
      ELSE IF @cDocType = 'E' -- WAVEKEY LEVEL
      BEGIN
         IF NOT EXISTS (
            SELECT 1 FROM dbo.PICKDETAIL PD WITH (NOLOCK)
            JOIN dbo.LOC LOC WITH (NOLOCK) ON ( PD.LOC = LOC.LOC)
            JOIN dbo.ORDERS O WITH (NOLOCK) ON O.OrderKey = PD.OrderKey AND O.StorerKey = PD.StorerKey AND O.USERDEFINE09 = @cWAVEKey
            WHERE PD.StorerKey = @cStorerKey
            AND   PD.Status = '5'
            AND   PD.QTY > 0
            AND   LOC.Facility = @cFacility
            AND   LOC.LocationCategory <> 'PPS')
         BEGIN
            SET @cErrMsg01 = ''
            SET @cErrMsg02 = ''

            SET @nErrNo = 0
            SET @cErrMsg01 = rdt.rdtgetmessage( 180031, @cLangCode, 'DSP')
            SET @cErrMsg02 = rdt.rdtgetmessage( 180032, @cLangCode, 'DSP') + @cWaveKey

            EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, 
                  @cErrMsg01, @cErrMsg02
            SET @nErrNo = 0   -- Reset error no
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

GRANT EXECUTE ON rdt.rdt_1837ExtInfo03 to nSQL
GO
