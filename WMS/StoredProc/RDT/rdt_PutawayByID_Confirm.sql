
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_PutawayByID_Confirm                             */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author   Purposes                                   */
/* 23-03-2015  1.0  Ung      SOS336606. Created                         */
/* 25-03-2020  1.1  Ung      WMS-12631 Add ConfirmSP                    */
/* 13-04-2026  1.3  Ung      FCR-8113 Add suggest alternate LOC         */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_PutawayByID_Confirm] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @cUserName        NVARCHAR( 18), 
   @cStorerKey       NVARCHAR( 15), 
   @cFacility        NVARCHAR( 5), 
   @cFromLOC         NVARCHAR( 10), 
   @cFromID          NVARCHAR( 18), 
   @cSuggLOC         NVARCHAR( 10), 
   @cPickAndDropLOC  NVARCHAR( 10), 
   @cToLOC           NVARCHAR( 10), 
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cToID       NVARCHAR( 18)
   DECLARE @cSQL        NVARCHAR( MAX)
   DECLARE @cSQLParam   NVARCHAR( MAX)
   DECLARE @cConfirmSP  NVARCHAR( 20)

   -- Init var
   SET @nErrNo = 0
   SET @cErrMsg = ''

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
            ' @nMobile, @nFunc, @cLangCode, @cUserName, @cStorerKey, @cFacility, @cFromLOC, @cFromID, @cSuggLOC, @cPickAndDropLOC, @cToLOC, ' + 
            ' @nErrNo OUTPUT, @cErrMsg OUTPUT'
         SET @cSQLParam =
            '@nMobile         INT,                    ' +
            '@nFunc           INT,                    ' +
            '@cLangCode       NVARCHAR( 3),           ' +
            '@cUserName       NVARCHAR( 18),          ' +
            '@cStorerKey      NVARCHAR( 15),          ' +
            '@cFacility       NVARCHAR( 5),           ' + 
            '@cFromLOC        NVARCHAR( 10),          ' +
            '@cFromID         NVARCHAR( 18),          ' +
            '@cSuggLOC        NVARCHAR( 10),          ' +
            '@cPickAndDropLOC NVARCHAR( 10),          ' +
            '@cToLOC          NVARCHAR( 10),          ' +  
            '@nErrNo          INT           OUTPUT,   ' +
            '@cErrMsg         NVARCHAR( 20) OUTPUT    '

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, @cUserName, @cStorerKey, @cFacility, @cFromLOC, @cFromID, @cSuggLOC, @cPickAndDropLOC, @cToLOC, 
            @nErrNo OUTPUT, @cErrMsg OUTPUT

         GOTO Quit
      END
   END
   
   /***********************************************************************************************
                                             Standard confirm
   ***********************************************************************************************/
   -- Get LoseID
   DECLARE @cLoseID NVARCHAR(1)
   SELECT @cLoseID = @cLoseID FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cToLOC
   IF @cLoseID = '1'
      SET @cToID = ''
   ELSE
      SET @cToID = @cFromID

   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_PutawayByID_Confirm -- For rollback or commit only our own transaction

   -- Execute move process
   EXECUTE rdt.rdt_Move
      @nMobile     = @nMobile,
      @cLangCode   = @cLangCode, 
      @nErrNo      = @nErrNo  OUTPUT,
      @cErrMsg     = @cErrMsg OUTPUT, -- screen limitation, 20 char max
      @cSourceType = 'rdt_PutawayByID_Confirm', 
      @cStorerKey  = @cStorerKey,
      @cFacility   = @cFacility, 
      @cFromLOC    = @cFromLOC, 
      @cToLOC      = @cToLOC, 
      @cFromID     = @cFromID, 
      @cToID       = NULL,  -- NULL means not changing ID
      @nFunc       = @nFunc
   IF @nErrNo <> 0
      GOTO RollBackTran

   IF @cPickAndDropLOC <> ''
      SET @cSuggLOC = @cPickAndDropLOC

   -- Unlock SuggestedLOC
   EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK' 
      ,''        --@cLOC      
      ,@cToID    --@cID       
      ,@cSuggLOC --@cSuggLOC 
      ,''        --@cStorerKey
      ,@nErrNo  OUTPUT
      ,@cErrMsg OUTPUT
   IF @nErrNo <> 0
      GOTO RollBackTran

   -- Unlock putaway skipped LOC
   IF EXISTS( SELECT TOP 1 1
      FROM rdt.rdtPutawaySkipLOCLog WITH (NOLOCK) 
      WHERE Mobile = @nMobile
         AND Func = @nFunc)
   BEGIN
      DECLARE @nRowRef INT 
      DECLARE @curSkipLOC CURSOR 
      SET @curSkipLOC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT RowRef
         FROM rdt.rdtPutawaySkipLOCLog WITH (NOLOCK) 
         WHERE Mobile = @nMobile
            AND Func = @nFunc
      OPEN @curSkipLOC
      FETCH NEXT FROM @curSkipLOC INTO @nRowRef
      WHILE @@FETCH_STATUS = 0
      BEGIN
         DELETE rdt.rdtPutawaySkipLOCLog WHERE RowRef = @nRowRef
         FETCH NEXT FROM @curSkipLOC INTO @nRowRef
      END
   END

   COMMIT TRAN rdt_PutawayByID_Confirm -- Only commit change made here
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_PutawayByID_Confirm -- Only rollback change made here
Fail:
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_PutawayByID_Confirm] TO NSQL
GO
