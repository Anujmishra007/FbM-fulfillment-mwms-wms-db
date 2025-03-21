SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_1764ExtUpd21                                       */
/* Purpose: Rollback FinalLoc and TransitLoc once quit the task            */
/* Customer: Grainte Levis                                                 */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date         Author   Ver.    Purposes                                  */
/* 2025-02-21   NLT013   1.0.0   UWP-30476 Create Intial Version           */
/* 2025-02-25   JCH507   1.0.1   UWP-30476 Clear Final loc when status = H */
/* 2025-03-22   NLT013   1.1.0   UWP-31321 Clear ListKey while cancel task */
/***************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1764ExtUpd21]
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR( 3)
   ,@nStep           INT
   ,@cTaskdetailKey  NVARCHAR( 10)
   ,@nErrNo          INT           OUTPUT
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
   ,@nAfterStep      INT = 0
   ,@cDropID         NVARCHAR( 20) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount  INT

   DECLARE @cStorerKey              NVARCHAR( 15)
   DECLARE @cToLOC                  NVARCHAR( 10)
   DECLARE @cFinalLOC               NVARCHAR(10)
   DECLARE @cTaskStatus             NVARCHAR(10)
   DECLARE @cToLOCCat               NVARCHAR( 10)
   DECLARE @cFacilily               NVARCHAR( 5)
   DECLARE @cInputKey               NVARCHAR(3)

   SET @nTranCount = @@TRANCOUNT

   SELECT @cFacilily = Facility,
      @cStorerKey  = StorerKey,
      @cInputKey = InputKey
   FROM RDT.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   -- TM Replen From
   IF @nFunc = 1764
   BEGIN
      IF @nStep = 9 -- REASON CODE
      BEGIN
         IF @cInputKey = '1'
         BEGIN
            -- Get task info
            SELECT
               @cToLoc        = ToLoc,
               @cFinalLOC     = FinalLoc,
               @cTaskStatus   = Status
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE TaskdetailKey = @cTaskDetailKey
               AND TaskType = 'RPF'
               AND StorerKey = @cStorerKey

            IF @cToLoc <> '' AND @cFinalLOC <> '' AND @cFinalLOC <> @cToLoc
            BEGIN
               SELECT @cToLOCCat = LocationCategory
               FROM dbo.LOC WITH(NOLOCK)
               WHERE Facility = @cFacilily
                  AND Loc = @cToLoc
            END

            BEGIN TRAN
            SAVE TRAN rdt_1764ExtUpd21

            BEGIN TRY
               IF @cToLOCCat IN ('PND', 'PND_IN', 'PND_OUT') AND @cTaskStatus IN ('0', 'X','H') AND @cFinalLOC <> '' 
               BEGIN
                  UPDATE dbo.TaskDetail WITH (ROWLOCK)
                  SET ToLoc = @cFinalLOC,
                     FinalLoc = '',
                     EditDate = GETDATE(),
                     EditWho  = SUSER_SNAME(),
                     TransitLoc = '',
                     ListKey = '',
                     Priority = IIF( @cTaskStatus = 'X', 1, Priority),
                     TransitCount = 0,
                     TrafficCop = NULL
                  WHERE TaskDetailKey = @cTaskdetailKey
                     AND StorerKey = @cStorerKey
               END
            END TRY
            BEGIN CATCH
               SET @nErrNo = 233651
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPKTaskFail
               GOTO RollBackTran
            END CATCH

            COMMIT TRAN rdt_1764ExtUpd21 -- Only commit change made here
         END
      END
   END

   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1764ExtUpd21 -- Only rollback change made here
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
GRANT EXECUTE ON RDT.rdt_1764ExtUpd21 TO NSQL
GO
