SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  
/************************************************************************/
/* Store procedure: rdt_1720ExtUpdSP02                                  */
/* Copyright      : Maersk WMS                                          */
/*                                                                      */
/* Purpose: Pallet Consolidation Extended Update                        */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2025-12-11  1.0  NickT    FCR-8808 Created                           */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1720ExtUpdSP02] (
      @nMobile        INT,
      @nFunc          INT,
      @cLangCode      NVARCHAR( 3),
      @nStep          INT,
      @nInputKey      INT,
      @cStorerKey     NVARCHAR( 15),
      @cFacility      NVARCHAR( 5),
      @cFromPalletID  NVARCHAR( 20),
      @cToPalletID    NVARCHAR( 20),
      @cDropID        NVARCHAR( 20),
      @nErrNo         INT           OUTPUT,
      @cErrMsg        NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cPalletLineNumber         NVARCHAR( 5),
      @cNewPalletLineNumber      NVARCHAR( 5),
      @cPickDetailKey            NVARCHAR(10),
      @cFromID                   NVARCHAR(18),
      @nQty                      INT,
      @cFromLoc                  NVARCHAR(10),
      @cSKU                      NVARCHAR(20),
      @cToLoc                    NVARCHAR(10),
      @nInvMoved                 INT = 0

   IF @nFunc = 1720
   BEGIN
      IF @nStep = 2
      BEGIN
         BEGIN TRAN

         DECLARE CUR_PalletConso CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT PD.PickDetailKey
               ,PD.ID
               ,PD.SKU
               ,PD.QTy
               ,PD.Loc
               ,PD.DropID
         FROM dbo.Pickdetail PD WITH (NOLOCK) 
         WHERE PD.StorerKey = @cStorerKey
         AND PD.Status <= '5'
         AND PD.ID = @cFromPalletID
         ORDER BY PD.PickDetailKey

         OPEN CUR_PalletConso
         FETCH NEXT FROM CUR_PalletConso INTO  @cPickDetailKey, @cFromID, @cSKU, @nQty, @cFromLoc, @cDropID
         WHILE (@@FETCH_STATUS <> -1)
         BEGIN
            SELECT TOP 1 @cToLoc = LLI.Loc 
            FROM dbo.LOTxLOCxID LLI  WITH (NOLOCK) 
            INNER JOIN dbo.Loc Loc WITH (NOLOCK) ON Loc.Loc = LLI.Loc
            WHERE LLI.StorerKey = @cStorerKey
               AND LLI.ID = @cToPalletID
               AND LLI.Qty > 0

            IF ISNULL(@cToLoc,'')  = ''
            BEGIN 
               ROLLBACK TRAN

               SET @nErrNo = 253455
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid To Pallet

               CLOSE CUR_PalletConso
               DEALLOCATE CUR_PalletConso 

               GOTO Quit
            END

            -- ID not same , need to move PickDetail ID as well.
            EXECUTE rdt.rdt_Move
               @nMobile     = @nMobile,
               @cLangCode   = @cLangCode,
               @nErrNo      = @nErrNo  OUTPUT,
               @cErrMsg     = @cErrMsg OUTPUT, -- screen limitation, 20 NVARCHAR max
               @cSourceType = 'rdt_1720ExtUpdSP02',
               @cStorerKey  = @cStorerKey,    
               @cFacility   = @cFacility,    
               @cFromLOC    = @cFromLOC,    
               @cToLOC      = @cToLOC,    
               @cFromID     = @cFromID,           -- NULL means not filter by ID. Blank is a valid ID    
               @cToID       = @cToPalletID,       -- NULL means not changing ID. Blank consider a valid ID    
               @cSKU        = @cSKU,    
               @nQTY        = @nQTY,   
               @nFunc       = @nFunc,
               @nQTYPick    = @nQTY,   
               @cCaseID     = @cDropID
            
            IF @nErrNo <> 0 
            BEGIN
               ROLLBACK TRAN

               CLOSE CUR_PalletConso
               DEALLOCATE CUR_PalletConso 

               GOTO Quit
            END

            SET @nInvMoved = 1
            FETCH NEXT FROM CUR_PalletConso INTO  @cPickDetailKey, @cFromID, @cSKU, @nQty, @cFromLoc
         END
         CLOSE CUR_PalletConso
         DEALLOCATE CUR_PalletConso 


         DECLARE CUR_PD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT PalletLineNumber
         FROM dbo.PalletDetail WITH (NOLOCK)  
         WHERE PalletKey = @cFromPalletID
         ORDER BY PalletLineNumber

         OPEN CUR_PD
         FETCH NEXT FROM CUR_PD INTO @cPalletLineNumber
         WHILE @@FETCH_STATUS <> -1
         BEGIN
            SET @cNewPalletLineNumber = ''

            SELECT
               @cNewPalletLineNumber = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( PalletLineNumber), 0) AS INT) + 1 AS VARCHAR( 5)), 5)
            FROM dbo.PalletDetail WITH (NOLOCK)
            WHERE PalletKey = @cToPalletID

            -- Inv not moved yet
            IF @nInvMoved = 0
            BEGIN
               SELECT 
                  @cFromLoc = Loc,
                  @cFromID = PalletKey,
                  @cSKU = SKU,
                  @nQty = Qty
               FROM dbo.PalletDetail WITH (NOLOCK)
               WHERE PalletKey = @cFromPalletID
                  AND PalletLineNumber = PalletLineNumber

               -- ID not same , need to move PickDetail ID as well.
               EXECUTE rdt.rdt_Move
                  @nMobile     = @nMobile,
                  @cLangCode   = @cLangCode,
                  @nErrNo      = @nErrNo  OUTPUT,
                  @cErrMsg     = @cErrMsg OUTPUT, -- screen limitation, 20 NVARCHAR max
                  @cSourceType = 'rdt_1720ExtUpdSP02',
                  @cStorerKey  = @cStorerKey,    
                  @cFacility   = @cFacility,    
                  @cFromLOC    = @cFromLOC,    
                  @cToLOC      = @cToLOC,    
                  @cFromID     = @cFromID,           -- NULL means not filter by ID. Blank is a valid ID    
                  @cToID       = @cToPalletID,       -- NULL means not changing ID. Blank consider a valid ID    
                  @cSKU        = @cSKU,    
                  @nQTY        = @nQTY,   
                  @nFunc       = @nFunc,
                  @nQTYPick    = @nQTY,   
                  @cCaseID     = @cDropID

               IF @nErrNo <> 0 
               BEGIN
                  ROLLBACK TRAN
                  GOTO Quit
               END
            END

            BEGIN TRY
               UPDATE dbo.PalletDetail WITH(ROWLOCK)
               SET 
                  PalletKey = @cToPalletID,
                  PalletLineNumber = @cNewPalletLineNumber 
               WHERE PalletKey = @cFromPalletID 
                     AND PalletLineNumber = @cPalletLineNumber
            END TRY
            BEGIN CATCH
               ROLLBACK TRAN
               SET @nErrNo = 253453
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update Pallet Detail Failed
               GOTO Quit
            END CATCH
            
            FETCH NEXT FROM CUR_PD INTO @cPalletLineNumber
         END
         CLOSE CUR_PD
         DEALLOCATE CUR_PD
         
         BEGIN TRY
            DELETE FROM dbo.Pallet
            WHERE PalletKey = @cFromPalletID
         END TRY
         BEGIN CATCH
            ROLLBACK TRAN
            SET @nErrNo = 253454
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Delete Pallet Failed
            GOTO Quit
         END CATCH

         COMMIT TRAN
      END
      ELSE IF @nStep = 3
      BEGIN
         BEGIN TRAN

         DECLARE CUR_PalletConso CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT PD.PickDetailKey
               ,PD.ID
               ,PD.SKU
               ,PD.QTy
               ,PD.Loc
         FROM dbo.Pickdetail PD WITH (NOLOCK) 
         WHERE PD.StorerKey = @cStorerKey
            AND PD.Status <= '5'
            AND PD.ID = @cFromPalletID
            AND PD.CaseID = @cDropID
         ORDER BY PD.PickDetailKey
         
         OPEN CUR_PalletConso
         FETCH NEXT FROM CUR_PalletConso INTO  @cPickDetailKey, @cFromID, @cSKU, @nQty, @cFromLoc
         WHILE (@@FETCH_STATUS <> -1)
         BEGIN
            SELECT TOP 1 @cToLoc = LLI.Loc
            FROM dbo.LOTxLOCxID LLI  WITH (NOLOCK)
            INNER JOIN dbo.Loc Loc WITH (NOLOCK) ON Loc.Loc = LLI.Loc
            WHERE LLI.StorerKey = @cStorerKey
               AND LLI.ID = @cToPalletID
               AND LLI.Qty > 0

            IF ISNULL(@cToLoc,'')  = ''
            BEGIN
               ROLLBACK TRAN
               SET @nErrNo = 253456
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid To Pallet
               GOTO Quit
            END
            
            -- ID not same , need to move PickDetail ID as well.
            EXECUTE rdt.rdt_Move
               @nMobile     = @nMobile,
               @cLangCode   = @cLangCode,
               @nErrNo      = @nErrNo  OUTPUT,
               @cErrMsg     = @cErrMsg OUTPUT, -- screen limitation, 20 NVARCHAR max    
               @cSourceType = 'rdt_1720ExtUpdSP02',
               @cStorerKey  = @cStorerKey,
               @cFacility   = @cFacility,
               @cFromLOC    = @cFromLOC,
               @cToLOC      = @cToLOC,
               @cFromID     = @cFromID,           -- NULL means not filter by ID. Blank is a valid ID    
               @cToID       = @cToPalletID,       -- NULL means not changing ID. Blank consider a valid ID    
               @cSKU        = @cSKU,
               @nQTY        = @nQTY,
               @nFunc       = @nFunc,
               @nQTYPick    = @nQTY,
               @cCaseID     = @cDropID
            
            IF @nErrNo <> 0 
            BEGIN
               ROLLBACK TRAN
               GOTO Quit
            END

            SET @nInvMoved = 1
            FETCH NEXT FROM CUR_PalletConso INTO  @cPickDetailKey, @cFromID, @cSKU, @nQty, @cFromLoc
         END
         CLOSE CUR_PalletConso
         DEALLOCATE CUR_PalletConso 


         DECLARE CUR_PD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT PalletLineNumber
         FROM dbo.PalletDetail WITH (NOLOCK)  
         WHERE PalletKey = @cFromPalletID
         AND CaseID = @cDropID
            ORDER BY PalletLineNumber

         OPEN CUR_PD

         FETCH NEXT FROM CUR_PD INTO @cPalletLineNumber
         WHILE @@FETCH_STATUS <> -1
         BEGIN
            SET @cNewPalletLineNumber = ''

            SELECT 
               @cNewPalletLineNumber = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( PalletLineNumber), 0) AS INT) + 1 AS VARCHAR( 5)), 5)
            FROM dbo.PalletDetail WITH (NOLOCK)
            WHERE PalletKey = @cToPalletID

            IF @nInvMoved = 0
            BEGIN
               SELECT 
                  @cFromLoc = Loc,
                  @cFromID = PalletKey,
                  @cSKU = SKU,
                  @nQty = Qty
               FROM dbo.PalletDetail WITH (NOLOCK)
               WHERE PalletKey = @cFromPalletID
                  AND PalletLineNumber = PalletLineNumber
                  AND CaseID = @cDropID

               -- ID not same , need to move PickDetail ID as well.
               EXECUTE rdt.rdt_Move
                  @nMobile     = @nMobile,
                  @cLangCode   = @cLangCode,
                  @nErrNo      = @nErrNo  OUTPUT,
                  @cErrMsg     = @cErrMsg OUTPUT, -- screen limitation, 20 NVARCHAR max    
                  @cSourceType = 'rdt_1720ExtUpdSP02',
                  @cStorerKey  = @cStorerKey,
                  @cFacility   = @cFacility,
                  @cFromLOC    = @cFromLOC,
                  @cToLOC      = @cToLOC,
                  @cFromID     = @cFromID,           -- NULL means not filter by ID. Blank is a valid ID    
                  @cToID       = @cToPalletID,       -- NULL means not changing ID. Blank consider a valid ID    
                  @cSKU        = @cSKU,
                  @nQTY        = @nQTY,
                  @nFunc       = @nFunc,
                  @nQTYPick    = @nQTY,
                  @cCaseID     = @cDropID
               
               IF @nErrNo <> 0 
               BEGIN
                  ROLLBACK TRAN
                  GOTO Quit
               END
            END
            
            BEGIN TRY
               UPDATE dbo.PalletDetail WITH(ROWLOCK)
               SET 
                  PalletKey = @cToPalletID,
                  PalletLineNumber = @cNewPalletLineNumber 
               WHERE PalletKey = @cFromPalletID
                  AND PalletLineNumber = @cPalletLineNumber
                  AND CaseID = @cDropID
            END TRY
            BEGIN CATCH
               ROLLBACK TRAN
               SET @nErrNo = 253451
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPalletDetFail
               GOTO Quit
            END CATCH

            FETCH NEXT FROM CUR_PD INTO @cPalletLineNumber
         END
         CLOSE CUR_PD  
         DEALLOCATE CUR_PD  

         IF NOT EXISTS ( SELECT 1 FROM dbo.PalletDetail WITH (NOLOCK) WHERE PalletKey = @cFromPalletID )
         BEGIN
            BEGIN TRY
               DELETE FROM dbo.Pallet
               WHERE PalletKey = @cFromPalletID
            END TRY
            BEGIN CATCH
               ROLLBACK TRAN
               SET @nErrNo = 253452
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DelPalletFail
               GOTO Quit
            END CATCH
         END

         COMMIT TRAN
      END
   END
   Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1720ExtUpdSP02 TO NSQL
GO
