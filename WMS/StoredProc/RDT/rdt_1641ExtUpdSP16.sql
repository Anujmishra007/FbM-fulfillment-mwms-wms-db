SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1641ExtUpdSP16                                  */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Called from: rdtfnc_Pallet_Build                                     */
/*                                                                      */
/* Purpose: Build pallet & palletdetail                                 */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2025-03-07  1.0  Dennis   FCR-2636  Created                          */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1641ExtUpdSP16] (
   @nMobile     INT,
   @nFunc       INT,
   @cLangCode   NVARCHAR( 3),
   @cUserName   NVARCHAR( 15),
   @cFacility   NVARCHAR( 5),
   @cStorerKey  NVARCHAR( 15),
   @cDropID     NVARCHAR( 20),
   @cUCCNo      NVARCHAR( 20),
   @nErrNo      INT          OUTPUT,
   @cErrMsg     NVARCHAR( 20) OUTPUT  -- screen limitation, 20 char max
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  @nStep         INT,
            @nInputKey     INT,
            @nTranCount    INT,
            @nPD_Qty       INT,
            @cSKU          NVARCHAR( 20),
            @cOrderKey     NVARCHAR( 10),
            @cWaveKey      NVARCHAR( 10),
            @cPickSlipNo   NVARCHAR( 10),
            @cPalletLineNumber   NVARCHAR( 5),
            @cCaseID         NVARCHAR(20),
            @cDropLoc        NVARCHAR(10),
            @nQty            INT,
            @cOtherPalletKey NVARCHAR( 30) = '',
            @cRoute          NVARCHAR( 20) = '',
            @cOption         NVARCHAR( 1) = '',
            @cToID NVARCHAR( 18)

   SELECT @nStep = Step,
          @nInputKey = InputKey,
          @cDropLOC  = V_String5
   FROM RDT.RDTMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nStep = 3
   BEGIN
      IF @nInputKey = 1
      BEGIN
         SELECT TOP 1 @cOrderKey = PD.OrderKey, @cWaveKey = PD.WaveKey
         FROM dbo.PickDetail PD WITH (NOLOCK)
         WHERE Storerkey = @cStorerKey
         AND   EXISTS ( SELECT 1 
                        FROM dbo.DropIDDetail DD WITH (NOLOCK)
                        JOIN dbo.Dropid D WITH (NOLOCK) ON ( DD.Dropid = D.Dropid)
                        WHERE D.Dropid = @cDropID
                        AND   D.Droploc = @cDropLOC
                        AND   D.[Status] = '0'
                        AND   D.DropIDType = 'B'
                        AND   PD.DropID = DD.ChildId)

         SET @cToID = LEFT( @cDropID, 18)
         -- insert to Eventlog
         EXEC RDT.rdt_STD_EventLog
            @cActionType   = '4', -- Move
            @cUserID       = @cUserName,
            @nMobileNo     = @nMobile,
            @nFunctionID   = @nFunc,
            @cFacility     = @cFacility,
            @cStorerKey    = @cStorerkey,
            @cToLocation   = @cDropLoc,
            @cToID         = @cToID,
            @cDropID       = @cDropID, 
            @cOrderKey     = @cOrderkey,
            @cWaveKey      = @cWaveKey,
            @cRefNo2       = @cOrderkey,
            @cRefNo3       = @cUCCNo
      END
   END

   GOTO Quit

Quit:
END
GO
GRANT EXECUTE ON  [RDT].[rdt_1641ExtUpdSP16] TO [NSQL]
GO
