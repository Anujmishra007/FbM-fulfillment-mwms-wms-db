SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****************************************************************************/
/* Store procedure: rdt_1836ConfirmSP05                                     */
/* Copyright      : Maersk                                                  */
/* Purpose        : Standard confirm for ASTRPT task                       */
/*                  Based on rdt_TM_Assist_ReplenTo_Confirm                 */
/*                                                                          */
/* Modifications log:                                                       */
/*                                                                          */
/* Date         Author    Ver.    Purposes                                  */
/* 2026-08-20   DennisA   1.0.0   UWP-64395 Created, Configkey=ConfirmSP   */
/****************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1836ConfirmSP05]
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cFacility       NVARCHAR( 5),
   @cStorerKey      NVARCHAR( 15),
   @cTaskdetailKey  NVARCHAR( 10),
   @cFinalLOC       NVARCHAR( 10),
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount INT
   DECLARE @cFromLOC   NVARCHAR( 10)
   DECLARE @cFromID    NVARCHAR( 18)
   DECLARE @cCaseID    NVARCHAR( 20)
   DECLARE @cSourceKey NVARCHAR( 10)

   SET @nTranCount = @@TRANCOUNT

   -- Get task info
   SELECT
      @cFromLOC = FromLOC,
      @cFromID  = FromID,
      @cCaseID  = CaseID
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE TaskDetailKey = @cTaskDetailKey

   -- Handling transaction
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_1836ConfirmSP05  -- For rollback or commit only our own transaction

   -- Move by UCC
   EXECUTE rdt.rdt_Move
      @nMobile     = @nMobile,
      @cLangCode   = @cLangCode,
      @nErrNo      = @nErrNo  OUTPUT,
      @cErrMsg     = @cErrMsg OUTPUT,
      @cSourceType = 'rdt_1836ConfirmSP05',
      @cStorerKey  = @cStorerKey,
      @cFacility   = @cFacility,
      @cFromLOC    = @cFromLOC,
      @cFromID     = @cFromID,
      @cToLOC      = @cFinalLoc,
      @cUCC        = @cCaseID,
      @cToID       = NULL,  -- NULL means not changing ID
      @nFunc       = @nFunc
   IF @nErrNo <> 0
      GOTO RollbackTran

   -- Unlock by ASTRPT task
   EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
      ,'' --FromLOC
      ,'' --FromID
      ,'' --SuggLOC
      ,@cStorerKey --Storer
      ,@nErrNo  OUTPUT
      ,@cErrMsg OUTPUT
      ,@cUCCNo = @cCaseID
   IF @nErrNo <> 0
      GOTO RollbackTran

   -- Unlock by SourceKey (PTCID)
   SELECT @cSourceKey = SourceKey
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE TaskDetailKey = @cTaskDetailKey

   EXEC rdt.rdt_Putaway_PendingMoveIn @cSourceKey, 'UNLOCK'
      ,'' --FromLOC
      ,'' --FromID
      ,'' --SuggLOC
      ,@cStorerKey --Storer
      ,@nErrNo  OUTPUT
      ,@cErrMsg OUTPUT
   IF @nErrNo <> 0
      GOTO RollbackTran

   -- Update task
   BEGIN TRY
      UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
         Status     = '9',
         ToLOC      = @cFinalLoc,
         UserKey    = SUSER_SNAME(),
         EditWho    = SUSER_SNAME(),
         EditDate   = GETDATE(),
         Trafficcop = NULL
      WHERE TaskDetailKey = @cTaskDetailKey
   END TRY
   BEGIN CATCH
      SET @nErrNo = 143001
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD Task Fail
      GOTO RollbackTran
   END CATCH

   COMMIT TRAN rdt_1836ConfirmSP05  -- Only commit change made here
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1836ConfirmSP05  -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount  -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1836ConfirmSP05 TO NSQL
GO
