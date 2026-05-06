
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1815ExtUpd02                                    */
/*                                                                      */
/* Purpose: SCHNEIDER BE                                                */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author    Purposes                                  */
/* 2026-04-07  1.0  Jackc     FCR-10346 Created                         */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1815ExtUpd02] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT, 
   @nInputKey        INT, 
   @cTaskDetailKey   NVARCHAR( 10),
   @cToLOC           NVARCHAR( 10),
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
   
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   

   DECLARE 
      @cTaskFromLoc     NVARCHAR(20),
      @cTaskFromID      NVARCHAR(18),
      @cOrderKey        NVARCHAR(10),
      @cMbolKey         NVARCHAR(10),
      @cStorerKey       NVARCHAR( 15),
      @cMbolStatus      NVARCHAR( 1),
      @cMsg01           NVARCHAR(60),
      @cMsg02           NVARCHAR(60),
      @cMsg03           NVARCHAR(60),
      @cSuggToLOC       NVARCHAR(20)
   
   IF @nFunc = 1815
   BEGIN
      IF @nStep = 1 -- FinalLoc
      BEGIN
         IF @nInputKey = 1
         BEGIN
            SELECT 
               @cTaskFromLoc  = FromLoc,
               @cTaskFromID   = FromID,
               @cStorerKey    = StorerKey 
            FROM dbo.TaskDetail WITH (NOLOCK) 
            WHERE TaskDetailKey = @cTaskDetailKey

            IF ISNULL(@cTaskFromLoc, '') = ''
            BEGIN
               SET @nErrNo = 263351
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --FromLoc is empty
               GOTO Fail
            END

            IF ISNULL(@cTaskFromID, '') = ''
            BEGIN
               SET @nErrNo = 263352
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --FromID is empty
               GOTO Fail
            END

            IF NOT EXISTS (SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) 
                           WHERE TaskType = 'ASTLO'
                              AND FromLoc = @cTaskFromLoc
                              AND TaskDetailKey <> @cTaskDetailKey
                              AND Status <> '9')
            BEGIN
               SELECT TOP 1 @cOrderKey = OrderKey
               FROM dbo.PickDetail WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND ID = @cTaskFromID

               IF ISNULL(@cOrderKey, '') = ''
               BEGIN
                  SET @nErrNo = 263355
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --OrderKey is empty
                  GOTO Fail
               END

               SELECT TOP 1
                  @cMbolKey = MB.MbolKey,
                  @cMbolStatus = MB.Status
               FROM dbo.MBOL MB WITH (NOLOCK)
               JOIN dbo.MBOLDETAIL MBD WITH (NOLOCK)
                  ON MB.MbolKey = MBD.MbolKey
               WHERE OrderKey = @cOrderKey

               IF ISNULL(@cMbolKey, '') = ''
               BEGIN
                  SET @nErrNo = 263356
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MbolKey is empty
                  GOTO Fail
               END
               
               DECLARE @nTranCount INT

               SET @nTranCount = @@TRANCOUNT
               BEGIN TRAN  -- Begin our own transaction
               SAVE TRAN rdt_1815ExtUpd02

               IF @cMbolStatus NOT IN ('6','9')
               BEGIN
                  BEGIN TRY
                     UPDATE dbo.MBOL WITH (ROWLOCK)
                     SET Status = '5'
                     WHERE MbolKey = @cMbolKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 263353
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update MBOL Fail
                     GOTO RollBackTran
                  END CATCH
               END

               BEGIN TRY
                  UPDATE dbo.LOC WITH (ROWLOCK)
                  SET Status = 'OK'
                  WHERE LOC = @cTaskFromLoc
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 263354
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update LOC Fail
                  GOTO RollBackTran
               END CATCH
            END -- no open task

            GOTO Quit
         END -- enter
      END--st1
   END --1815
   
   GOTO Quit

   RollBackTran:
      ROLLBACK TRAN rdt_1815ExtUpd02 -- Only rollback change made here

   Fail:
      IF ISNULL(@nErrNo, 0) <> 0
      BEGIN
         SET @cMsg01 = @cErrMsg
         SET @cMsg02 = 'Failed to update MBOL & FromLoc'
         SET @cMsg03 = ''

         EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT,   
         @cMsg01, @cMsg02, @cMsg03

         --Do not block process
         SET @nErrNo = 0
         SET @cErrMsg = ''
      END

   Quit:
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
         COMMIT TRAN
END
GO


SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1815ExtUpd02 TO NSQL
GO