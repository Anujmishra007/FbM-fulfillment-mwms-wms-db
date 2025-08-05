SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_1764ExtUpd23                                       */
/* Customer: UL                                                            */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date         Author   Ver.    Purposes                                  */
/* 2025-07-09   Dennis   1.0.0   FCR-4498 Created                          */
/***************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1764ExtUpd23]
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
   DECLARE @cTaskType               NVARCHAR(10)
   DECLARE @cListKey                NVARCHAR(10),
   @nRowCount                       INT,
   @nLoopIndex                      INT

   SET @nTranCount = @@TRANCOUNT

   DECLARE @tTask TABLE
   (
      id            INT IDENTITY(1,1),
      TaskDetailKey NVARCHAR(10), 
      ToLOC         NVARCHAR(10),
      TaskType      NVARCHAR(10),
      Status        NVARCHAR(10),
      FinalLOC      NVARCHAR(10)
   )

   SELECT @cFacilily = Facility,
      @cStorerKey  = StorerKey,
      @cInputKey = InputKey
   FROM RDT.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   -- TM Replen From
   IF @nFunc = 1764
   BEGIN
      IF @nStep = 6 -- To loc
      BEGIN
         IF @cInputKey = '1'
         BEGIN
            -- Get task info
            SELECT
               @cToLoc        = ToLoc,
               @cFinalLOC     = FinalLoc,
               @cTaskType     = TaskType,
               @cListKey      = ListKey,
               @cTaskStatus   = Status
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE TaskdetailKey = @cTaskDetailKey

            INSERT INTO @tTask (TaskDetailKey, ToLOC, TaskType,Status, FinalLOC)
            SELECT TaskDetailKey,ToLoc, TaskType,Status, FinalLoc 
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE ListKey = @cListKey
            AND TOLOC = FinalLOC
            AND Status = '9'

            SET @nLoopIndex = -1
            WHILE 1 = 1
            BEGIN
               SELECT TOP 1
                  @cTaskDetailKey = TaskDetailKey,
                  @nLoopIndex = id
               FROM @tTask
               WHERE id > @nLoopIndex
               ORDER BY id

               SET @nRowCount = @@ROWCOUNT

               IF @nRowCount = 0
                  BREAK
               
               BEGIN TRY
                  UPDATE dbo.TaskDetail WITH (ROWLOCK)
                  SET Status = '0'
                  WHERE REFTASKKEY = @cTaskDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 242101
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Upd Task fail
                  GOTO Fail
               END CATCH
            END
         END
      END
   END

   GOTO Quit

   RollBackTran:

   Fail:
   
   Quit:

END--SP
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1764ExtUpd23 TO NSQL
GO
