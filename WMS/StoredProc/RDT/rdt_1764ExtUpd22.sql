SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_1764ExtUpd22                                       */
/* Purpose:                                                                */
/* Customer: JCB                                                           */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date         Author   Ver.    Purposes                                  */
/* 2025-06-16   Dennis   1.0.0   FCR-3959 Created                          */
/* 2026-01-05   PPA374   2.0.0   Adding RDT.c_String28 update at step 2    */
/***************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1764ExtUpd22]
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
   DECLARE @cFinalLOC               NVARCHAR( 10)
   DECLARE @cTaskStatus             NVARCHAR( 10)
   DECLARE @cToLOCCat               NVARCHAR( 10)
   DECLARE @cFacilily               NVARCHAR( 5)
   DECLARE @cInputKey               NVARCHAR( 3)
   DECLARE @cAreaKey                NVARCHAR( 20)
   DECLARE @cPickMethod             NVARCHAR( 20)
   DECLARE @cFromLoc                NVARCHAR( 20)
   DECLARE  @nDebugFlag  INT = 0,
   @nScn             INT,
   @cUserName        NVARCHAR(128)

   SET @nTranCount = @@TRANCOUNT

   SELECT @cFacilily = Facility,
      @cUserName = UserName,
      @cStorerKey  = StorerKey,
      @nScn =      Scn,
      @cInputKey = InputKey
   FROM RDT.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   SELECT TOP 1 @cAreaKey = AreaKey, @cPickMethod = PickMethod, @cFromLoc = FromLoc FROM TaskDetail WITH(NOLOCK) WHERE TaskDetailKey = @cTaskdetailKey

   -- TM Replen From
   IF @nFunc = 1764
   BEGIN
      IF @nStep = 2
      BEGIN
         IF @cInputKey = 1
         BEGIN
            UPDATE RDT.RDTMOBREC
            SET C_String28 = V_LOC
            WHERE Mobile = @nMobile
            
            UPDATE RDT.RDTMOBREC
               SET C_DateTime1 = GETDATE()
               WHERE Mobile = @nMobile
         END
      END
      IF @nStep = 6
      BEGIN
         IF @cInputKey = 1
         BEGIN
            UPDATE RDT.RDTMOBREC
            SET C_DateTime1 = GETDATE()
            WHERE Mobile = @nMobile
         END -- Input 1
      END -- Step 6
      IF @nStep = 7 -- ExitTM, Next Task Scn
      BEGIN
         IF @cInputKey = 0
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'ST7 - MsgScn, ESC'

            IF EXISTS (
               SELECT 1
               FROM dbo.TaskDetail WITH (NOLOCK)
               WHERE TaskType IN ('RPF', 'RP1')
                  AND STATUS = '3'
                  AND UserKey = @cUserName
                  AND TaskDetailKey <> @cTaskdetailKey
            )
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Unlock locked tasks'

               UPDATE dbo.TaskDetail WITH (ROWLOCK)
               SET   
                  UserKey = '',
                  Status = '0'
               WHERE TaskType IN ('RPF','RP1')
                  AND UserKey = @cUserName
                  AND Status = '3'
                  AND TaskDetailKey <> @cTaskdetailKey
            END --Unlock Tasks
         END--inputkey = 0
      END --ST7
      IF @nStep = 99
      BEGIN
         IF @nScn = 6620
         BEGIN
            IF @cInputKey = 1
            BEGIN
               IF @cPickMethod = 'PP' AND @cAreaKey = 'MOTHERSONS'
               BEGIN
                  UPDATE TaskDetail
                  SET Status = '0'
                  WHERE UserKey = @cUserName
                     AND Status = '3'
                  AND AreaKey = 'MOTHERSONS'
                  AND FromLoc = @cFromLoc
                  AND TaskType IN ('RPF','RPF1','RP1')
               END
            END
         END
      END
   END

   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1764ExtUpd22 -- Only rollback change made here
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
GRANT EXECUTE ON RDT.rdt_1764ExtUpd22 TO NSQL
GO
