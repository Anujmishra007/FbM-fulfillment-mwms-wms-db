SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_TM_PutawayFrom_Confirm_JCB                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author   Purposes                                   */
/* 2025-08-05  1.0  Dennis   FCR-3954 Created                           */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_TM_PutawayFrom_Confirm_JCB] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @cUserName      NVARCHAR( 18), 
   @cTaskDetailKey NVARCHAR( 10),
   @nErrNo         INT          OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @cFromLOT    NVARCHAR( 10)
   DECLARE @cFromLOC    NVARCHAR( 10)
   DECLARE @cFromID     NVARCHAR( 18)
   DECLARE @cToLOC      NVARCHAR( 10)
   DECLARE @cToID       NVARCHAR( 18)
   DECLARE @cStorerKey  NVARCHAR( 15)
   DECLARE @cSKU        NVARCHAR( 20)
   DECLARE @nQTY        INT
   DECLARE @cFacility   NVARCHAR( 5)
   DECLARE @cFinalLOC   NVARCHAR( 10)
   DECLARE @cTransitLOC NVARCHAR( 10)
   DECLARE @cListKey    NVARCHAR( 10)

   -- Init var
   SET @nErrNo = 0
   SET @cErrMsg = ''

   -- Get task info
   SELECT 
      @cListKey = ListKey, 
      @cStorerKey = StorerKey, 
      @cFromLOC = FromLOC, 
      @cFromID = FromID, 
      @cToLOC = ToLOC, 
      @cTransitLOC = TransitLOC, 
      @cFinalLOC = FinalLOC
   FROM dbo.TaskDetail WITH (NOLOCK) 
   WHERE TaskDetailKey = @cTaskDetailKey

   IF @cListKey = ''
      SET @cListKey = @cTaskdetailKey

   -- Get LoseID
   DECLARE @cLoseID NVARCHAR(1)
   SELECT @cLoseID = @cLoseID FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cToLOC
   IF @cLoseID = '1'
      SET @cToID = ''
   ELSE
      SET @cToID = @cFromID

   -- Get facility
   SELECT @cFacility = Facility FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cFromLOC

   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_TM_PutawayFrom_Confirm_JCB -- For rollback or commit only our own transaction

   -- Execute move process
   EXECUTE rdt.rdt_Move
      @nMobile     = @nMobile,
      @cLangCode   = @cLangCode, 
      @nErrNo      = @nErrNo  OUTPUT,
      @cErrMsg     = @cErrMsg OUTPUT, -- screen limitation, 20 char max
      @cSourceType = 'rdt_TM_PutawayFrom_Confirm_JCB', 
      @cStorerKey  = @cStorerKey,
      @cFacility   = @cFacility, 
      @cFromLOC    = @cFromLOC, 
      @cToLOC      = @cToLOC, 
      @cFromID     = @cFromID, 
      @cToID       = NULL,  -- NULL means not changing ID
      @nFunc       = @nFunc
   IF @nErrNo <> 0
      GOTO RollBackTran

   -- Update Task
   UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
      Status = '9', -- Picked
      ToID = @cToID, 
      EndTime = GETDATE(),
      EditDate = GETDATE(),
      EditWho  = @cUserName, 
      Trafficcop = NULL
   WHERE TaskDetailKey = @cTaskDetailKey
   IF @@ERROR <> 0
   BEGIN
      SET @nErrNo = 79251
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdTaskdetFail
      GOTO RollBackTran
   END

   -- Unlock SuggestedLOC
   EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK' 
      ,''       --@cLOC      
      ,@cToID   --@cID       
      ,@cToLOC  --@cFinalLOC 
      ,''       --@cStorerKey
      ,@nErrNo  OUTPUT
      ,@cErrMsg OUTPUT
   IF @nErrNo <> 0
      GOTO RollBackTran

   -- Create next task
   IF @cTransitLOC <> ''
   BEGIN
      EXEC rdt.rdt_TM_PutawayFrom_CreateNextTask @nMobile, @nFunc, @cLangCode,
         @cUserName,
         @cTaskDetailKey,
         @cFinalLOC, 
         @nErrNo  OUTPUT,
         @cErrMsg OUTPUT
      IF @nErrNo <> 0
         GOTO RollBackTran
   END

   --Cancel tasks that can no longer be fulfilled
   UPDATE TD WITH(ROWLOCK)
   SET TD.Status = 'X'
   FROM dbo.TaskDetail TD
      LEFT JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK)
         ON TD.FromID = LLI.Id 
		    AND LLI.Qty > 0
			AND TD.StorerKey = @cStorerKey
			AND LLI.StorerKey = @cStorerKey
   WHERE TD.Status = '0'
      AND TD.FromLoc <> LLI.Loc
      AND TD.StorerKey = @cStorerKey
      AND LLI.StorerKey = @cStorerKey

   --Delete RFPutaway that can no longer be done, to free up the location
   DELETE FROM RFPUTAWAY
   WHERE FromID IN (
      SELECT LLI1.ID
      FROM dbo.LOTxLOCxID LLI1 WITH(NOLOCK)
         LEFT JOIN dbo.LOTxLOCxID LLI2 WITH(NOLOCK)
            ON LLI1.Id = LLI2.Id 
	           AND LLI2.Qty > 0
		       AND LLI1.StorerKey = @cStorerKey
		       AND LLI2.StorerKey = @cStorerKey
         INNER JOIN LOC L WITH(NOLOCK)
            ON L.Loc = LLI2.Loc
	           AND LLI2.StorerKey = @cStorerKey
		       AND L.Facility = @cFacility
      WHERE LLI1.StorerKey = @cStorerKey
         AND LLI1.PendingMoveIN > 0
         AND LocationCategory NOT IN ('STAGE','PNDIN')
   )

   --Update pending qty that can no longer be done, to free up the location
   UPDATE LOTxLOCxID WITH(ROWLOCK)
   SET PendingMoveIN = 0
   WHERE ID IN (
      SELECT LLI1.ID
      FROM dbo.LOTxLOCxID LLI1 WITH(NOLOCK)
         LEFT JOIN dbo.LOTxLOCxID LLI2 WITH(NOLOCK)
            ON LLI1.Id = LLI2.Id 
	           AND LLI2.Qty > 0
		       AND LLI1.StorerKey = @cStorerKey
		       AND LLI2.StorerKey = @cStorerKey
         INNER JOIN LOC L WITH(NOLOCK)
            ON L.Loc = LLI2.Loc
	           AND LLI2.StorerKey = @cStorerKey
		       AND L.Facility = @cFacility
      WHERE LLI1.StorerKey = @cStorerKey
         AND LLI1.PendingMoveIN > 0
         AND LocationCategory NOT IN ('STAGE','PNDIN')
   )

   --Delete RFPUTAWAY that got tasks archived
   DELETE R
   FROM dbo.RFPUTAWAY R
      INNER JOIN (
         SELECT LLI1.Loc, LLI1.ID
         FROM dbo.LOTxLOCxID LLI1 WITH(NOLOCK)
            LEFT JOIN dbo.TaskDetail TD WITH(NOLOCK)
               ON (TD.ToLoc = LLI1.LOC OR TD.FinalLOC = LLI1.LOC)
                  AND TD.FromID = LLI1.ID
				  AND TD.StorerKey = @cStorerKey
				  AND LLI1.StorerKey = @cStorerKey
         WHERE LLI1.StorerKey = @cStorerKey
            AND LLI1.PendingMoveIN > 0
            AND TD.TaskDetailKey IS NULL
         ) AS Sub
         ON R.ID = Sub.ID 
	    AND R.SuggestedLoc = Sub.Loc;

   --Update pending that got task archived
   UPDATE LLI
   SET LLI.PendingMoveIN = '0'
   FROM dbo.LOTxLOCxID LLI WITH(ROWLOCK)
      LEFT JOIN dbo.TaskDetail TD WITH(NOLOCK)
         ON (TD.ToLoc = LLI1.LOC OR TD.FinalLOC = LLI1.LOC)
            AND TD.FromID = LLI.ID
            AND TD.StorerKey = @cStorerKey
            AND LLI.StorerKey = @cStorerKey
   WHERE LLI.StorerKey = @cStorerKey
      AND LLI.PendingMoveIN > 0
      AND TD.TaskDetailKey IS NULL;
	
   COMMIT TRAN rdt_TM_PutawayFrom_Confirm_JCB -- Only commit change made here
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_TM_PutawayFrom_Confirm_JCB -- Only rollback change made here
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

GRANT EXECUTE ON [rdt].[rdt_TM_PutawayFrom_Confirm_JCB] TO NSQL
GO
