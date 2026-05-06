SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_1764ExtUpd24                                       */
/* Customer: Cajamar                                                       */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date         Author   Ver.    Purposes                                  */
/* 2025-11-26   JackC    1.0.0   FCR-8648 Created                          */
/***************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1764ExtUpd25]
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

   DECLARE @cStorerKey     NVARCHAR( 15)
   DECLARE @cTaskStatus    NVARCHAR(10)
   DECLARE @cFacilily      NVARCHAR( 5)
   DECLARE @nInputKey      INT
   DECLARE @nRowCount      INT
   DECLARE @nLoopIndex     INT
   DECLARE @cErrMsg1       NVARCHAR(125)
   DECLARE @cErrMsg2       NVARCHAR(125)
   DECLARE @cErrMsg3       NVARCHAR(125)
   DECLARE @cErrMsg4       NVARCHAR(125)

   SET @nTranCount = @@TRANCOUNT

   DECLARE 
      @cTaskGroupKey    NVARCHAR(10)
      ,@cTaskType       NVARCHAR(10)
      ,@cUserName       NVARCHAR(18)
      ,@nFromStep       INT
      ,@cFromLoc        NVARCHAR(10)
      ,@cToLoc          NVARCHAR(10)
      ,@cFinalLOC       NVARCHAR(10)
      ,@cSKU            NVARCHAR(20)
      ,@cFromID         NVARCHAR(20)
      ,@nPABookingKey   INT
      ,@nTaskQty        INT


   DECLARE @tTaskDetail TABLE
   (
      ID             INT IDENTITY,
      TaskDetailKey  NVARCHAR(10)
   )

   DECLARE @tPKD TABLE
   (
      id            INT IDENTITY(1,1),
      PickDetailKey NVARCHAR(10) 
   )

   SELECT @cFacilily = Facility,
      @cStorerKey    = StorerKey,
      @cUserName     = UserName,
      @nInputKey     = InputKey,
      @nFromStep     = V_FromStep
   FROM RDT.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   -- TM Replen From
   IF @nFunc = 1764
   BEGIN
      IF @nstep = 0
      BEGIN
         SELECT 
            @cTaskGroupKey = GroupKey,
            @cTaskType  = TaskType
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE TaskDetailKey = @cTaskDetailKey

         IF @cTaskType = 'RPF'
         BEGIN
            INSERT INTO @tTaskDetail (Taskdetailkey)
            SELECT TaskDetailKey
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND TaskType = @cTaskType
               AND Status = '0'
               AND (UserKeyOverRide = '' OR UserKeyOverRide IS NULL)
               AND GroupKey = @cTaskGroupKey
               AND TaskDetailKey <> @cTaskDetailKey
            
            IF EXISTS (SELECT 1 FROM @tTaskDetail)
            BEGIN
               BEGIN TRY
                  UPDATE TD WITH (ROWLOCK) SET
                     UserKeyOverRide = @cUserName
                  FROM dbo.TaskDetail TD
                  JOIN @tTaskDetail t ON TD.Taskdetailkey = t.TaskDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 252151    
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd task detail fail  
                  GOTO Quit  
               END CATCH
            END
         END

         GOTO Quit

      END -- step0

      IF @nStep = 6 -- To loc
      BEGIN
         IF @nInputKey = 1
         BEGIN
            SELECT 
               @cTaskGroupKey = GroupKey,
               @cTaskType  = TaskType
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE TaskDetailKey = @cTaskDetailKey

            IF @cTaskType = 'RPF'
            BEGIN
               INSERT INTO @tTaskDetail (Taskdetailkey)
               SELECT TaskDetailKey
               FROM dbo.TaskDetail WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND TaskType = @cTaskType
                  AND Status = '0'
                  AND UserKeyOverRide = @cUserName
                  AND GroupKey = @cTaskGroupKey
                  AND TaskDetailKey <> @cTaskDetailKey
               
               IF EXISTS (SELECT 1 FROM @tTaskDetail)
               BEGIN
                  BEGIN TRY
                     UPDATE TD WITH (ROWLOCK) SET
                        UserKeyOverRide = ''
                     FROM dbo.TaskDetail TD
                     JOIN @tTaskDetail t ON TD.Taskdetailkey = t.TaskDetailKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 252153    
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd task detail fail  
                     GOTO Quit  
                  END CATCH
               END
            END
         END -- inputkey = 1
      END --st6

      IF @nStep = 9 --Reason
      BEGIN
         IF @nInputKey = 1
         BEGIN
            SELECT
               @cTaskGroupKey = GroupKey,
               @cTaskType     = TaskType,
               @cSKU          = SKU,
               @nTaskQty      = Qty,
               @cFromID       = FromID,
               @cFromLoc      = FromLoc,
               @cToLoc        = ToLoc,
               @cFinalLOC     = FinalLoc,
               @cTaskStatus   = Status
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE TaskdetailKey = @cTaskDetailKey
               AND StorerKey = @cStorerKey

            SET @nRowCount = @@ROWCOUNT
            IF @nFromStep = 1
            BEGIN 
               IF @cTaskType = 'RPF'
               BEGIN
                  INSERT INTO @tTaskDetail (Taskdetailkey)
                  SELECT TaskDetailKey
                  FROM dbo.TaskDetail WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND TaskType = @cTaskType
                     AND Status = '0'
                     AND UserKeyOverRide = @cUserName
                     AND GroupKey = @cTaskGroupKey
                     AND TaskDetailKey <> @cTaskDetailKey
                  
                  IF EXISTS (SELECT 1 FROM @tTaskDetail)
                  BEGIN
                     BEGIN TRY
                        UPDATE TD WITH (ROWLOCK) SET
                           UserKeyOverRide = ''
                        FROM dbo.TaskDetail TD
                        JOIN @tTaskDetail t ON TD.Taskdetailkey = t.TaskDetailKey
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 252152    
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd task detail fail  
                        GOTO Quit  
                     END CATCH
                  END
               END
            END --fromstep1

            --Unbook
            IF @nRowCount <> 0 AND @cToLOC <> @cFinalLOC AND @cFinalLoc <>'' AND @cToLOC <> '' 
               AND @cTaskStatus IN ('0', 'X','H')
            BEGIN
               SELECT TOP 1
                  @nPABookingKey = PABookingKey
               FROM dbo.RFPutaway WITH (NOLOCK) 
               WHERE StorerKey = @cStorerKey
                  AND FromLoc = @cFromLOC
                  AND FromID = @cFromID
                  AND SuggestedLOC = @cToLOC
                  AND SKU = @cSKU
                  AND Qty = @nTaskQty
                  AND ptcid = @cUserName
               ORDER BY AddDate DESC

               IF ISNULL(@nPABookingKey, '') <> ''
               BEGIN
                  EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
                     ,''      --@cFromLOC
                     ,''      --@cFromID
                     ,''      --@cSuggestedLOC
                     ,''      --@cStorerKey
                     ,@nErrNo  OUTPUT
                     ,@cErrMsg OUTPUT
                     ,@nPABookingKey = @nPABookingKey
                  IF @nErrNo <> 0
                     GOTO Quit
               END
            END

            GOTO Quit
         END--enter
      END --st9
   END

   GOTO Quit

   RollBackTran:
   IF @nTranCount > 0 AND XACT_STATE() <> -1
      ROLLBACK TRAN rdt_1764ExtUpd25
   ELSE
      ROLLBACK TRAN
   GOTO Quit

   Fail:
   
   Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN

END--SP
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1764ExtUpd25 TO NSQL
GO
