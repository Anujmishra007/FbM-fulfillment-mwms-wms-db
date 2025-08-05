SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_TM_PutawayFrom_SwapTask_JCB                     */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev    Author   Purposes                                 */
/* 2025-04-24  1.0.0  NLT013   FCR-3954. Created                        */
/* 2025-06-27  1.0.1  Dennis   FCR-3954. Update Dispatch strategy       */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_TM_PutawayFrom_SwapTask_JCB] (
   @nMobile           INT,
   @nFunc             INT,
   @cLangCode         NVARCHAR( 3),
   @cUserName         NVARCHAR( 18),
   @cTaskDetailKey    NVARCHAR( 10),
   @cNewID            NVARCHAR( 18),
   @cNewTaskDetailKey NVARCHAR( 10) OUTPUT,
   @nErrNo         INT          OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cStorerKey        NVARCHAR( 15)
   DECLARE @cTaskType         NVARCHAR( 10)
   DECLARE @cSuggFromLOC      NVARCHAR( 10)
   DECLARE @cSuggID           NVARCHAR( 18)
   DECLARE @cSuggToLOC        NVARCHAR( 10)
   DECLARE @cPickAndDropLOC   NVARCHAR( 10)
   DECLARE @cFitCasesInAisle  NVARCHAR( 1)
   DECLARE @nTransitCount     INT
   DECLARE @cAreakey          NVARCHAR( 10)

   DECLARE @cNewFromLOC        NVARCHAR( 10)
   DECLARE @cNewSuggToLOC      NVARCHAR( 10)
   DECLARE @nNewTransitCount   INT
   DECLARE @cNewPickAndDropLOC NVARCHAR( 10)

   DECLARE @cFacility         NVARCHAR( 10),
   @cLocAisle                 NVARCHAR(10)
   DECLARE @tAisleInUsed TABLE
   (
      RowIndex                 INT IDENTITY(1,1),
      LocAisle                 NVARCHAR(10),
      Userkey                  NVARCHAR(30)
   )

   SELECT 
      @cFacility = Facility,
      @cStorerKey = StorerKey
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   -- Init var
   SET @nErrNo = 0
   SET @cErrMsg = ''

   -- Get existing task info
   SELECT
      @cTaskType = TD.TaskType,
      @cSuggFromLOC = TD.FromLOC,
      @cSuggID = TD.FromID, 
      @cSuggToLOC = TD.ToLOC, 
      @nTransitCount = TD.TransitCount,
      @cPickAndDropLOC = TD.TransitLOC,
      @cAreakey = AD.AreaKey
   FROM dbo.TaskDetail TD WITH (NOLOCK)
   INNER JOIN dbo.LOC LOC WITH(NOLOCK)
      ON TD.FromLoc = LOC.Loc
   INNER JOIN dbo.AreaDetail AD WITH(NOLOCK)
      ON LOC.PutawayZone = AD.PutawayZone
   WHERE StorerKey = @cStorerKey
         AND TaskDetailKey = @cTaskDetailKey

   DELETE FROM @tAisleInUsed
   INSERT INTO @tAisleInUsed
   (
      LocAisle, UserKey
   )
   SELECT DISTINCT v.LocAisle, Td.UserKey
   FROM TaskDetail TD WITH (NOLOCK)
   LEFT JOIN LOC FromLoc WITH (NOLOCK)
      ON TD.FromLOC = FromLoc.Loc
      AND FromLoc.LocationCategory = 'VNA'
      AND FromLOC.Facility = @cFacility
   LEFT JOIN LOC ToLoc WITH (NOLOCK)
      ON TD.ToLOC = ToLoc.Loc
      AND ToLoc.LocationCategory = 'VNA'
      AND ToLoc.Facility = @cFacility
   CROSS APPLY (
      SELECT FromLoc.LocAisle WHERE ISNULL(FromLoc.LocAisle,'') <> ''
      UNION ALL
      SELECT ToLoc.LocAisle WHERE ISNULL(ToLoc.LocAisle,'') <> ''
   ) v(LocAisle)
   WHERE TD.UserKey <> @cUsername
   AND TD.Status = '3'
   AND (FromLoc.Loc IS NOT NULL OR ToLoc.Loc IS NOT NULL)

   -- Get new task info
   SET @cNewTaskDetailKey = ''
   IF @cSuggID = @cNewID AND @cSuggToLOC = ''
      SELECT TOP 1
         @cNewTaskDetailKey = TaskDetailKey, 
         @cNewFromLOC = FromLOC,
         @cNewSuggToLOC = ToLOC,
         @nNewTransitCount = TransitCount,
         @cNewPickAndDropLOC = TransitLOC
      FROM dbo.TaskDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND TaskDetailKey = @cTaskDetailKey
   ELSE
      SELECT TOP 1
         @cNewTaskDetailKey = TD.TaskDetailKey, 
         @cNewFromLOC = TD.FromLOC,
         @cNewSuggToLOC = TD.ToLOC,
         @nNewTransitCount = TD.TransitCount,
         @cNewPickAndDropLOC = TD.TransitLOC
      FROM dbo.TaskDetail TD WITH (NOLOCK)
      INNER JOIN dbo.LOC WITH(NOLOCK) ON TD.FromLoc = LOC.Loc
      INNER JOIN dbo.AreaDetail AD WITH(NOLOCK) ON AD.PutawayZone = LOC.PutawayZone
      WHERE TD.StorerKey = @cStorerKey
         AND LOC.Facility = @cFacility
         AND TD.TaskType = @cTaskType
         AND AD.AreaKey = @cAreakey
         AND TD.FromID = @cNewID
         AND (TD.Status = '0' OR (TD.Status = '3' AND TD.UserKey = @cUserName))
         AND TD.UserKeyOverRide IN (@cUserName, '')

   -- Check new task exist
   IF ISNULL(@cNewTaskDetailKey, '') = ''
   BEGIN
      -- Check if other user taken this task
      DECLARE @cOtherUserName NVARCHAR(18)
      SET @cOtherUserName = ''
      SELECT TOP 1 
         @cOtherUserName = TD.UserKey 
      FROM dbo.TaskDetail TD WITH (NOLOCK)
      INNER JOIN dbo.LOC WITH(NOLOCK) ON TD.FromLoc = LOC.Loc
      INNER JOIN dbo.AreaDetail AD WITH(NOLOCK) ON AD.PutawayZone = LOC.PutawayZone
      WHERE TD.StorerKey = @cStorerKey
         AND LOC.Facility = @cFacility
         AND TD.TaskType = @cTaskType
         AND AD.AreaKey = @cAreakey
         AND TD.FromID = @cNewID
         AND TD.Status = '3' 
         AND TD.UserKey <> @cUserName
      IF ISNULL(@cOtherUserName, '') <> ''
      BEGIN
         SET @nErrNo = 237554
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- The Task Is Locked By Another User
         SET @cErrMsg = RTRIM( @cErrMsg) + RTRIM( @cOtherUserName) 
      END
      ELSE
      BEGIN
         SET @nErrNo = 237551
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- NoTaskOnThisID
      END
      GOTO Quit
   END

   IF EXISTS (SELECT 1 FROM dbo.TaskDetail TD WITH (NOLOCK)  
              INNER JOIN dbo.LOC WITH (NOLOCK) ON TD.ToLoc = LOC.Loc AND LOC.Facility = @cFacility
              WHERE TD.TaskDetailKey = @cNewTaskDetailKey AND TD.Message03 = 'VNA'
              AND EXISTS (SELECT 1 FROM @tAisleInUsed t WHERE t.LocAisle = LOC.LocAisle))
   BEGIN
      SET @cNewTaskDetailKey = ''
      SET @nErrNo = 237555
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- LocAisleInUsed
      GOTO Quit
   END
   
   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_TM_PutawayFrom_SwapTask_JCB -- For rollback or commit only our own transaction

   -- Release current task
   UPDATE dbo.TaskDetail SET
         UserKey = ''
      ,ReasonKey = ''
      ,Status = '0'
      ,EditDate = GETDATE()
      ,EditWho  = SUSER_SNAME()
      ,TrafficCop = NULL
   WHERE TaskDetailKey = @cTaskDetailKey
      
   IF @@ERROR <> 0
   BEGIN
      SET @nErrNo = 237553
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdTaskdetFail
      GOTO RollBackTran
   END

   UPDATE dbo.TaskDetail SET
         ToLOC      = @cNewSuggToLOC
      ,UserKey    = @cUserName
      ,Status     = '3'
      ,EditDate   = GETDATE()
      ,EditWho    = SUSER_SNAME()
      ,TrafficCop = NULL
   WHERE TaskDetailKey = @cNewTaskDetailKey

   IF @@ERROR <> 0
   BEGIN
      SET @nErrNo = 237552
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdTaskdetFail
      GOTO RollBackTran
   END

   -- Log swapped task
   IF @cTaskDetailKey <> @cNewTaskDetailKey
   BEGIN
      INSERT INTO rdt.rdtPAFSwapTaskLog (FromTaskKey, FromLOC, FromID, NewTaskKey, NewFromLOC, NewFromID)
      VALUES (@cTaskDetailKey, @cSuggFromLOC, @cSuggID, @cNewTaskDetailKey, @cNewFromLOC, @cNewID)
   END

   COMMIT TRAN rdt_TM_PutawayFrom_SwapTask_JCB -- Only commit change made here
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_TM_PutawayFrom_SwapTask_JCB -- Only rollback change made here
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

GRANT EXECUTE ON [rdt].[rdt_TM_PutawayFrom_SwapTask_JCB] TO NSQL
GO
