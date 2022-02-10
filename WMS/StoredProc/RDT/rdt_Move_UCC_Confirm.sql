if exists (select * from dbo.sysobjects where id = object_id(N'[rdt].[rdt_Move_UCC_Confirm]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [rdt].[rdt_Move_UCC_Confirm]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/******************************************************************************/
/* Store procedure: rdt_Move_UCC_Confirm                                      */
/* Copyright      : LF Logistics                                              */
/*                                                                            */
/* Purpose: standard and custom confirm SP                                    */
/*                                                                            */
/* Date       Rev  Author   Purposes                                          */
/* 2020-05-04 1.0  Ung      WMS-12637 Created                                 */
/******************************************************************************/
CREATE  PROCEDURE [RDT].[rdt_Move_UCC_Confirm] (
   @nMobile        INT, 
   @nFunc          INT, 
   @cLangCode      NVARCHAR( 3),
   @nStep          INT, 
   @nInputKey      INT, 
   @cStorerKey     NVARCHAR( 15),
   @cFacility      NVARCHAR( 5),
   @cToID          NVARCHAR( 18),
   @cToLoc         NVARCHAR( 10),
   @cFromLoc       NVARCHAR( 10),
   @cFromID        NVARCHAR( 18),
   @cUCC1          NVARCHAR( 20),
   @cUCC2          NVARCHAR( 20),
   @cUCC3          NVARCHAR( 20),
   @cUCC4          NVARCHAR( 20),
   @cUCC5          NVARCHAR( 20),
   @cUCC6          NVARCHAR( 20),
   @cUCC7          NVARCHAR( 20),
   @cUCC8          NVARCHAR( 20),
   @cUCC9          NVARCHAR( 20),
   @i              INT           OUTPUT, 
   @nErrNo         INT           OUTPUT, 
   @cErrMsg        NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @cSQL        NVARCHAR( MAX)
   DECLARE @cSQLParam   NVARCHAR( MAX)
   DECLARE @cConfirmSP  NVARCHAR( 20)
   DECLARE @nTranCount  INT

   SET @nTranCount = @@TRANCOUNT

   -- Get storer config
   SET @cConfirmSP = rdt.rdtGetConfig( @nFunc, 'ConfirmSP', @cStorerKey)
   IF @cConfirmSP = '0'
      SET @cConfirmSP = ''  

   /***********************************************************************************************
                                             Custom confirm
   ***********************************************************************************************/
   IF @cConfirmSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cConfirmSP AND type = 'P')
      BEGIN
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cConfirmSP) +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, ' + 
            ' @cToID, @cToLoc, @cFromLoc, @cFromID, ' + 
            ' @cUCC1, @cUCC2, @cUCC3, @cUCC4, @cUCC5, @cUCC6, @cUCC7, @cUCC8, @cUCC9, ' + 
            ' @i OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '
         SET @cSQLParam =
            '@nMobile        INT, ' +
            '@nFunc          INT, ' +
            '@cLangCode      NVARCHAR( 3),  ' +
            '@nStep          INT, ' +
            '@nInputKey      INT, ' + 
            '@cStorerKey     NVARCHAR( 15), ' +
            '@cFacility      NVARCHAR( 5),  ' +
            '@cToID          NVARCHAR( 18), ' +
            '@cToLoc         NVARCHAR( 10), ' +
            '@cFromLoc       NVARCHAR( 10), ' +
            '@cFromID        NVARCHAR( 18), ' +
            '@cUCC1          NVARCHAR( 20), ' +
            '@cUCC2          NVARCHAR( 20), ' +
            '@cUCC3          NVARCHAR( 20), ' +
            '@cUCC4          NVARCHAR( 20), ' +
            '@cUCC5          NVARCHAR( 20), ' +
            '@cUCC6          NVARCHAR( 20), ' +
            '@cUCC7          NVARCHAR( 20), ' +
            '@cUCC8          NVARCHAR( 20), ' +
            '@cUCC9          NVARCHAR( 20), ' +
            '@i              INT           OUTPUT, ' + 
            '@nErrNo         INT           OUTPUT, ' + 
            '@cErrMsg        NVARCHAR( 20) OUTPUT'
        
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, 
            @cToID, @cToLoc, @cFromLoc, @cFromID, 
            @cUCC1, @cUCC2, @cUCC3, @cUCC4, @cUCC5, @cUCC6, @cUCC7, @cUCC8, @cUCC9, 
            @i OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT 

         GOTO Quit
      END
   END
   
   /***********************************************************************************************
                                             Standard confirm
   ***********************************************************************************************/
   DECLARE @cUCC           NVARCHAR( 20)
   DECLARE @cUCCLOC        NVARCHAR( 10)
   DECLARE @cUCCID         NVARCHAR( 18)
   DECLARE @nUCCQTY        INT
   DECLARE @cMoveQTYAlloc  NVARCHAR( 1)
   DECLARE @cMoveQTYPick   NVARCHAR( 1)
   DECLARE @nQTYAlloc      INT
   DECLARE @nQTYPick       INT

   SET @cMoveQTYAlloc = rdt.RDTGetConfig( @nFunc, 'MoveQTYAlloc', @cStorerKey)
   SET @cMoveQTYPick = rdt.RDTGetConfig( @nFunc, 'MoveQTYPick', @cStorerKey)

   BEGIN TRAN
   SAVE TRAN rdt_Move_UCC_Confirm

   SET @i = 1
   WHILE @i < 10
   BEGIN
      IF @i = 1 SET @cUCC = @cUCC1
      IF @i = 2 SET @cUCC = @cUCC2
      IF @i = 3 SET @cUCC = @cUCC3
      IF @i = 4 SET @cUCC = @cUCC4
      IF @i = 5 SET @cUCC = @cUCC5
      IF @i = 6 SET @cUCC = @cUCC6
      IF @i = 7 SET @cUCC = @cUCC7
      IF @i = 8 SET @cUCC = @cUCC8
      IF @i = 9 SET @cUCC = @cUCC9
      
      IF @cUCC <> ''
      BEGIN
         -- Get FromLOC, FromID
         SELECT 
            @cUCCLOC = LOC, 
            @cUCCID = ID,
            @nUCCQTY = ISNULL( SUM( Qty), 0)
         FROM dbo.UCC (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND UCCNo = @cUCC
            AND Status = '1' -- Received
         GROUP BY LOC, ID

         -- Calc QTY to move
         IF @cMoveQTYAlloc = '1'
         BEGIN
            SET @nQTYAlloc = @nUCCQTY
            SET @nQTYPick = 0
         END
         ELSE IF @cMoveQTYPick = '1'
         BEGIN
            SET @nQTYAlloc = 0
            SET @nQTYPick = @nUCCQTY
         END
         ELSE
         BEGIN
            SET @nQTYAlloc = 0
            SET @nQTYPick = 0
         END

         EXEC RDT.rdt_Move
            @nMobile     = @nMobile,
            @cLangCode   = @cLangCode, 
            @nErrNo      = @nErrNo  OUTPUT,
            @cErrMsg     = @cErrMsg OUTPUT, 
            @cSourceType = 'rdt_Move_UCC_Confirm', 
            @cStorerKey  = @cStorerKey,
            @cFacility   = @cFacility, 
            @cFromLOC    = @cUCCLOC, 
            @cToLOC      = @cToLOC, 
            @cFromID     = @cUCCID,
            @cToID       = @cToID,
            @cSKU        = NULL, 
            @cUCC        = @cUCC,
            @nFunc       = @nFunc, 
            @nQTYAlloc   = @nQTYAlloc,
            @nQTYPick    = @nQTYPick,
            @cDropID     = @cUCC
         IF @nErrNo <> 0
            GOTO RollBackTran
         
         -- Log event
         EXEC RDT.rdt_STD_EventLog
            @cActionType   = '4', -- Move
            @nMobileNo     = @nMobile,
            @nFunctionID   = @nFunc,
            @cFacility     = @cFacility,
            @cStorerKey    = @cStorerkey,
            @cLocation     = @cUCCLOC,
            @cToLocation   = @cToLOC,
            @cID           = @cUCCID, 
            @cToID         = @cToID, 
            @cRefNo1       = @cUCC, 
            @cUCC          = @cUCC
      END
      SET @i = @i + 1
   END
   
   COMMIT TRAN rdt_Move_UCC_Confirm
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_Move_UCC_Confirm -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON RDT.rdt_Move_UCC_Confirm TO NSQL
GO
