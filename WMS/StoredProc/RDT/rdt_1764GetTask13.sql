SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_1764GetTask13                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Get next replenish task                                     */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev    Author    Purposes                                */
/* 2025-06-11  1.0.0  Dennis    FCR-3959                                */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1764GetTask13] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @cUserName        NVARCHAR( 15),
   @cAreaKey         NVARCHAR( 10),
   @cListKey         NVARCHAR( 10),
   @cDropID          NVARCHAR( 20),
   @cNewTaskKey      NVARCHAR( 10)  OUTPUT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT  -- screen limitation, 20 char max
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @bDebugFlag     BINARY = 0

   DECLARE @bSuccess       INT
   DECLARE @bSkipTheTask   INT
   DECLARE @cFinalLOC      NVARCHAR( 10)
   DECLARE @cFinalID       NVARCHAR( 18)
   DECLARE @cFinalPAZone   NVARCHAR( 10)
   DECLARE @cFinalAisle    NVARCHAR( 10)

   DECLARE @cFacility      NVARCHAR( 5)
   DECLARE @cToLOC         NVARCHAR( 10)
   DECLARE @cToLOCAisle    NVARCHAR( 10)
   DECLARE @cToLOCCat      NVARCHAR( 10)
   DECLARE @cToPAZone      NVARCHAR( 10)

   DECLARE @cFromLOC       NVARCHAR( 10)
   DECLARE @cFromID        NVARCHAR( 18)
   DECLARE @cStorerKey     NVARCHAR( 10)
   DECLARE @cSKU           NVARCHAR( 20)
   DECLARE @cLOT           NVARCHAR( 10)
   DECLARE @nQTY           INT
   DECLARE @cToID          NVARCHAR( 18)
   DECLARE @cWaveKey       NVARCHAR( 10)
   DECLARE @cPalletFinalLOC NVARCHAR( 10)
   DECLARE @cOrderGroup    NVARCHAR( 20)
   DECLARE @cTaskType      NVARCHAR( 10)
   DECLARE @cPickMethod    NVARCHAR( 10)

   DECLARE @cLastToLoc     NVARCHAR( 10) --v1.0

   SET @cNewTaskKey = ''

   SELECT TOP 1 @cNewTaskKey = TaskDetailKey
   FROM dbo.TaskDetail TD WITH (NOLOCK)    
   JOIN dbo.LOC WITH(NOLOCK) ON LOC.LOC = TD.FromLOC
   WHERE TD.ListKey <> @cListKey  
   AND TD.UserKey = @cUserName  
   AND TD.Status = '3'
   AND TD.TaskType IN ('RPF','RP1')
   ORDER BY LOC.LogicalLocation,LOC.LOC

   IF @cNewTaskKey = ''
   BEGIN
      IF EXISTS( SELECT 1
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE ListKey = @cListKey
         AND UserKey = @cUserName
            AND Status = '5')
      BEGIN
         SET @nErrNo = 230301
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoTask.ClosePL
         GOTO Fail
      END
      ELSE
      BEGIN
         SET @nErrNo = 230302
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No more task
         GOTO Fail
      END
   END

   UPDATE TaskDetail WITH (ROWLOCK) SET    
      ListKey = @cListKey 
   WHERE TaskDetailKey = @cNewTaskKey   

Fail:

IF @bDebugFlag = 1
   SELECT 'Quit', @nErrNo, @cErrMsg

END
GO
GRANT EXECUTE ON  [RDT].[rdt_1764GetTask13] TO [NSQL]
GO
