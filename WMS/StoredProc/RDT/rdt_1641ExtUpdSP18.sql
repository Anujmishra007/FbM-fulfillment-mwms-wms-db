SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1641ExtUpdSP18                                  */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Called from: rdtfnc_Pallet_Build                                     */
/*                                                                      */
/* Purpose: Build pallet & palletdetail                                 */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2025-03-07  1.0  Dennis   FCR-10354  Created                         */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1641ExtUpdSP18] (
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
            @cFromLOC        NVARCHAR(10),
            @cFromID         NVARCHAR(18),
            @cDropLoc        NVARCHAR(10),
            @nQty            INT,
            @cLOT            NVARCHAR(10),
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
         SET @nTranCount = @@TRANCOUNT
         BEGIN TRAN  -- Begin our own transaction
         SAVE TRAN rdt_1641ExtUpdSP18 -- For rollback or commit only our own transaction

         UPDATE PICKDETAIL SET DROPID = @cDropID WHERE CASEID = @cUCCNo AND StorerKey = @cStorerKey 

         SELECT @cFromLOC = LOC,
            @cFromID = ID,
            @nQTY = SUM(QTY),
            @cSKU = SKU
         FROM PickDetail (NOLOCK)
         WHERE CASEID = @cUCCNo
         AND StorerKey = @cStorerKey
         GROUP BY LOC,ID,SKU

         EXECUTE rdt.rdt_Move
            @nMobile     = @nMobile,
            @cLangCode   = @cLangCode,
            @nErrNo      = @nErrNo  OUTPUT,
            @cErrMsg     = @cErrMsg OUTPUT,
            @cSourceType = 'rdt_1641ExtUpdSP18',
            @cStorerKey  = @cStorerKey,
            @cFacility   = @cFacility,
            @cFromLOC    = @cFromLoc,
            @cToLOC      = @cFromLOC,
            @cFromID     = @cFromID,
            @cToID       = @cDropID,
            @nQTYPick    = @nQTY,  --(JH01) @nPackedQty,
            @nQTY        = @nQTY,  --(JH01) @nPackedQty,
            @cFromLOT    = NULL,
            @nFunc       = @nFunc,
            @cCaseID     = @cUCCNo,
            @cSKU        = @cSKU
         
         IF @nErrNo <> 0
         BEGIN
            ROLLBACK TRAN
            GOTO QUIT
         END
         COMMIT TRAN rdt_1641ExtUpdSP18
      END
   END

   GOTO Quit

Quit:
END
GO
GRANT EXECUTE ON  [RDT].[rdt_1641ExtUpdSP18] TO [NSQL]
GO
