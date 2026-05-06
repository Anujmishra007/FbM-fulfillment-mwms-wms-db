
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO  

/************************************************************************/
/* Store procedure: rdt_TM_Assist_Putaway_PP_Confirm                    */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author   Purposes                                   */
/* 2021-08-30  1.0  Ung      WMS-17016 Created                          */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_TM_Assist_Putaway_PP_Confirm] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT, 
   @nInputKey        INT, 
   @cStorerKey       NVARCHAR( 15), 
   @cFacility        NVARCHAR( 5), 
   @cTaskDetailKey   NVARCHAR( 10), 
   @cFromLOC         NVARCHAR( 10), 
   @cFromID          NVARCHAR( 18), 
   @cSKU             NVARCHAR( 20), 
   @nQTY             INT, 
   @cSuggLOC         NVARCHAR( 10), 
   @cToLOC           NVARCHAR( 10), 
   @nPABookingKey    INT           OUTPUT,
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cToID          NVARCHAR( 18),
           @cPPConfirmSP   NVARCHAR( 20),
           @cSQL           NVARCHAR( MAX),   
           @cSQLParam      NVARCHAR( MAX)  

   -- Get storer config  
   SET @cPPConfirmSP = rdt.rdtGetConfig( @nFunc, 'PPConfirmSP', @cStorerKey)  
   IF @cPPConfirmSP = '0'  
      SET @cPPConfirmSP = ''  

   /***********************************************************************************************  
                                          Custom confirm  
   ***********************************************************************************************/  
   IF @cPPConfirmSP <> ''  
   BEGIN  
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cPPConfirmSP AND type = 'P')  
      BEGIN  
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cPPConfirmSP) +  
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cTaskDetailKey, @cFromLOC, @cFromID, '+
            ' @cSKU, @nQTY, @cSuggLOC, @cToLOC, @nPABookingKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '
         SET @cSQLParam =  
            ' @nMobile          INT,                  ' +
            ' @nFunc            INT,                  ' +
            ' @cLangCode        NVARCHAR( 3),         ' +
            ' @nStep            INT,                  ' +
            ' @nInputKey        INT,                  ' +
            ' @cStorerKey       NVARCHAR( 15),        ' +
            ' @cFacility        NVARCHAR( 5),         ' +
            ' @cTaskDetailKey   NVARCHAR( 10),        ' +
            ' @cFromLOC         NVARCHAR( 10),        ' +
            ' @cFromID          NVARCHAR( 18),        ' +
            ' @cSKU             NVARCHAR( 20),        ' +
            ' @nQTY             INT,                  ' +
            ' @cSuggLOC         NVARCHAR( 10),        ' +
            ' @cToLOC           NVARCHAR( 10),        ' +
            ' @nPABookingKey    INT           OUTPUT, ' + 
            ' @nErrNo           INT           OUTPUT, ' +
            ' @cErrMsg          NVARCHAR( 20) OUTPUT  '             
  
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
            @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cTaskDetailKey, @cFromLOC, @cFromID, 
            @cSKU, @nQTY, @cSuggLOC, @cToLOC, @nPABookingKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT 
  
         GOTO Quit  
      END  
   END  
  
   /***********************************************************************************************  
                                          Standard confirm   
   ***********************************************************************************************/  
   -- Init var
   SET @nErrNo = 0
   SET @cErrMsg = ''

   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_TM_Assist_Putaway_PP_Confirm -- For rollback or commit only our own transaction

   -- Execute putaway process
   EXEC rdt.rdt_Putaway @nMobile, @nFunc, @cLangCode, '', @cFacility,
      '', -- @cLOT
      @cFromLOC,
      @cFromID,
      @cStorerKey,
      @cSKU,
      @nQTY,
      @cToLOC,
      @nErrNo  = @nErrNo  OUTPUT,
      @cErrMsg = @cErrMsg OUTPUT
   IF @nErrNo <> 0
      GOTO RollBackTran

   -- Unlock current session suggested LOC
   IF @nPABookingKey <> 0
   BEGIN
      EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
         ,'' --FromLOC
         ,'' --FromID
         ,'' --SuggLOC
         ,'' --Storer
         ,@nErrNo        = @nErrNo  OUTPUT
         ,@cErrMsg       = @cErrMsg OUTPUT
         ,@nPABookingKey = @nPABookingKey OUTPUT
      IF @nErrNo <> 0  
         GOTO RollBackTran
   
      SET @nPABookingKey = 0
   END

   -- Unlock by task
   EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
      ,'' --FromLOC
      ,@cFromID
      ,'' --SuggLOC
      ,'' --Storer
      ,@nErrNo         = @nErrNo  OUTPUT
      ,@cErrMsg        = @cErrMsg OUTPUT
      ,@cSKU           = @cSKU
      ,@cTaskDetailKey = @cTaskDetailKey
   IF @nErrNo <> 0  
      GOTO RollBackTran

   COMMIT TRAN rdt_TM_Assist_Putaway_PP_Confirm -- Only commit change made here
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_TM_Assist_Putaway_PP_Confirm -- Only rollback change made here
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

GRANT EXECUTE ON rdt.rdt_TM_Assist_Putaway_PP_Confirm to nSQL
GO