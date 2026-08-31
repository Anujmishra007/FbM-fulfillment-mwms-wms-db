/************************************************************************/
/* Store procedure: rdt_1819ExtUpdPGPE                                  */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Purpose: create task PA1 with AreaKey                                */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2026-06-11   MLR024    1.0   RITM9002048/UWP-61800 PA1 Task insertion*/
/*                              with AreaKey                            */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1819ExtUpdPGPE]
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cFromID         NVARCHAR( 18),
   @cSuggLOC        NVARCHAR( 10),
   @cPickAndDropLOC NVARCHAR( 10),
   @cToLOC          NVARCHAR( 10),
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cStorerKey NVARCHAR( 15)
   DECLARE @cAreaKey   NVARCHAR( 30)

   -- Get storer
   SELECT @cStorerKey = StorerKey FROM rdt.rdtMobRec WITH (NOLOCK) WHERE Mobile = @nMobile

   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_1819ExtUpdPGPE -- For rollback or commit only our own transaction

   -- Putaway By ID
   IF @nFunc = 1819
   BEGIN
      IF @nStep = 2 -- ToLOC
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF @cPickAndDropLOC <> ''
            BEGIN
               DECLARE @nSuccess          INT
               DECLARE @cNewTaskDetailKey NVARCHAR( 10)

               -- Get new TaskDetailKey
               SET @nSuccess = 1
               EXECUTE dbo.nspg_getkey
                  'TASKDETAILKEY'
                  , 10
                  , @cNewTaskDetailKey OUTPUT
                  , @nSuccess          OUTPUT
                  , @nErrNo            OUTPUT
                  , @cErrMsg           OUTPUT
               IF @nSuccess <> 1
               BEGIN
                  SET @nErrNo = 275058
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
                  GOTO Fail
               END

               SELECT TOP 1 @cAreaKey = adt.AreaKey
               FROM dbo.LOC loc WITH (NOLOCK) LEFT JOIN dbo.AREADETAIL adt WITH (NOLOCK)
               ON loc.PutawayZone = adt.PutawayZone
               WHERE loc.LOC = @cSuggLOC

               -- Insert final task
               BEGIN TRY
                  INSERT INTO dbo.TaskDetail (
                     TaskDetailKey, TaskType, Status, UserKey, FromLOC, FromID, ToLOC, ToID,
                     PickMethod, StorerKey, ListKey, TransitCount, SourceType, Priority, SourcePriority, TrafficCop, AreaKey)
                  VALUES (
                     @cNewTaskDetailKey, 'PA1', '0', '', @cToLOC, @cFromID, @cSuggLOC, @cFromID,
                     'FP', @cStorerKey, '', 0, 'rdt_1819ExtUpdPGPE', '5', '5', NULL, @cAreaKey)
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 275051
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InsTaskDetFail
                  GOTO RollBackTran
               END CATCH
            END
         END
      END
   END

   COMMIT TRAN rdt_1819ExtUpdPGPE -- Only commit change made here
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1819ExtUpdPGPE -- Only rollback change made here
Fail:
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

GRANT EXECUTE ON [RDT].[rdt_1819ExtUpdPGPE] TO [NSQL]
GO
