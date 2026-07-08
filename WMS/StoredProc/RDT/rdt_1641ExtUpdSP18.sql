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
/* 2026-07-08  2.0  Dennis   FCR-12828  Add Step 4 Close Pallet         */
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
            @cToID NVARCHAR( 18),
            @nLoopId          INT = 0,
            @nRowCount        INT,
            @nMaxId           INT,
            @cMoveFromLOC     NVARCHAR(10),
            @cMoveFromID      NVARCHAR(18),
            @nMoveQTY         INT,
            @cMoveSKU         NVARCHAR(18)

   -- Temporary table to store multiple SKU records for the same UCC
   DECLARE @tMoveList TABLE
   (
      ID       INT IDENTITY(1,1),
      FromLOC  NVARCHAR(10),
      FromID   NVARCHAR(18),
      QTY      INT,
      SKU      NVARCHAR(18)
   )

   SELECT @nStep     = Step,
          @nInputKey = InputKey,
          @cDropLOC  = V_String5,
          @cOption   = LEFT(ISNULL(I_Field01, ''), 1)
   FROM RDT.RDTMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nStep = 4
   BEGIN
      IF @nInputKey = 1 AND @cOption = '1'
      BEGIN
         UPDATE dbo.DROPID WITH (ROWLOCK) SET
            Status = '9'
         WHERE DropID = @cDropID
         IF @@ERROR <> 0 OR @@ROWCOUNT = 0
         BEGIN
            SET @nErrNo = 69206
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd DROPIDFail
            GOTO Quit
         END
      END
   END

   IF @nStep = 3
   BEGIN
      IF @nInputKey = 1
      BEGIN
         SET @nTranCount = @@TRANCOUNT
         BEGIN TRAN  -- Begin our own transaction
         SAVE TRAN rdt_1641ExtUpdSP18 -- For rollback or commit only our own transaction

         -- Update PickDetail with DropID
         UPDATE PICKDETAIL SET DROPID = @cDropID 
         WHERE CASEID = @cUCCNo AND StorerKey = @cStorerKey 

         -- Insert all SKU records from the UCC into temporary table
         INSERT INTO @tMoveList (FromLOC, FromID, QTY, SKU)
         SELECT LOC, ID, SUM(QTY), SKU
         FROM PickDetail (NOLOCK)
         WHERE CASEID = @cUCCNo
            AND StorerKey = @cStorerKey
         GROUP BY LOC, ID, SKU

         -- Get the maximum ID for loop counter
         SELECT @nMaxId = MAX(ID) FROM @tMoveList

         -- Loop through each SKU record and execute rdt_Move
         WHILE @nLoopId < @nMaxId
         BEGIN
            SELECT TOP 1
               @nLoopId = ID,
               @cMoveFromLOC = FromLOC,
               @cMoveFromID = FromID,
               @nMoveQTY = QTY,
               @cMoveSKU = SKU
            FROM @tMoveList
            WHERE ID > @nLoopId
            ORDER BY ID
            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount = 0
               BREAK

            -- Execute Move procedure for each SKU
            EXECUTE rdt.rdt_Move
               @nMobile     = @nMobile,
               @cLangCode   = @cLangCode,
               @nErrNo      = @nErrNo  OUTPUT,
               @cErrMsg     = @cErrMsg OUTPUT,
               @cSourceType = 'rdt_1641ExtUpdSP18',
               @cStorerKey  = @cStorerKey,
               @cFacility   = @cFacility,
               @cFromLOC    = @cMoveFromLOC,
               @cToLOC      = @cMoveFromLOC,
               @cFromID     = @cMoveFromID,
               @cToID       = @cDropID,
               @nQTYPick    = @nMoveQTY,
               @nQTY        = @nMoveQTY,
               @cFromLOT    = NULL,
               @nFunc       = @nFunc,
               @cCaseID     = @cUCCNo,
               @cSKU        = @cMoveSKU
            
            -- Check if any error occurred during the move
            IF @nErrNo <> 0
            BEGIN
               ROLLBACK TRAN
               GOTO QUIT
            END
         END

         -- Clear the temporary table for next iteration (if needed)
         DELETE FROM @tMoveList

         COMMIT TRAN rdt_1641ExtUpdSP18
      END
   END

   GOTO Quit

Quit:
END
GO

GRANT EXECUTE ON  [RDT].[rdt_1641ExtUpdSP18] TO [NSQL]
GO