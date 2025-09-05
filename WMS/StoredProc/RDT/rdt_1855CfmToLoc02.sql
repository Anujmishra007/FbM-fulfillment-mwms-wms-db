
/******************************************************************************/  
/* Store procedure: rdt_1855CfmToLoc02                                        */  
/* Copyright      : Maersk                                                    */  
/*                                                                            */  
/* Purpose: Levis Granite                                                     */
/*                                                                            */
/* Called from: rdtfnc_TM_Assist_ClusterPick_ConfirmToLoc                     */
/*                                                                            */
/* Date         Rev     Author   Purposes                                     */
/* 2025-05-07   1.0.0   Jackc    FCR-3925 fix groupkey is blank if there is   */
/*                               X status task                                */
/* 2025-08-18   1.1.0   NickT    UWP-39586 Performance tuning                 */
/******************************************************************************/  
  
CREATE OR ALTER PROC rdt.rdt_1855CfmToLoc02 (  
    @nMobile         INT,  
    @nFunc           INT,  
    @cLangCode       NVARCHAR( 3),  
    @nStep           INT,  
    @nInputKey       INT,  
    @cFacility       NVARCHAR( 5),  
    @cStorerKey      NVARCHAR( 15),  
    @cTaskDetailKey  NVARCHAR( 10),  
    @cToLOC          NVARCHAR( 10),  
    @tConfirm        VARIABLETABLE READONLY,
    @nErrNo          INT           OUTPUT,  
    @cErrMsg         NVARCHAR(250) OUTPUT  
)  
AS  
BEGIN  
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
   
   DECLARE @nDebugFlag  INT = 0
   DECLARE @cSQL        NVARCHAR( MAX)    
   DECLARE @cSQLParam   NVARCHAR( MAX)    
   DECLARE @nTranCount  INT    
   DECLARE @cConfirmToLocSP  NVARCHAR( 20)      
   
   --It follows base rdt_TM_assist_ClusterPick_ConfirmToLoc logic. Only customize the groupkey and deviceid retrieving logic
   --In case it get the blank values when taskdetailkey's status is X
   
   DECLARE @cur CURSOR  
   DECLARE @cGroupKey   NVARCHAR( 10)  
   DECLARE @cCartID     NVARCHAR( 20)  
   DECLARE @cTaskKey    NVARCHAR( 10)  
   DECLARE @cSKU        NVARCHAR( 20)  
   DECLARE @nQty        INT  
   DECLARE @cFromLOC    NVARCHAR( 10)  
   DECLARE @cFromID     NVARCHAR( 18)  
   DECLARE @cDropID     NVARCHAR( 20)  
   DECLARE @cConfirmToLocMoveInventory NVARCHAR( 1)  
   DECLARE @cUserName   NVARCHAR( 18)
   DECLARE @cTaskType   NVARCHAR( 10)
   DECLARE @nRowCount   INT

   --@cTaskKey, @cFromLOC, @cFromID, @cSKU, @nQty, @cDropID
   DECLARE @tTaskDetail TABLE
   (
      TaskDetailKey     NVARCHAR( 10) PRIMARY KEY
   )

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_1855CfmToLoc02'  

   SELECT @cUserName = UserName  
   FROM rdt.RDTMOBREC WITH (NOLOCK)  
   WHERE Mobile = @nMobile 
  
   SET @cConfirmToLocMoveInventory = rdt.rdtGetConfig( @nFunc, 'ConfirmToLocMoveInventory', @cStorerKey)  
   
   --V1.0.0 start
   SELECT TOP 1   
      @cGroupKey = Groupkey,  
      @cCartID = DeviceID,   
      @cTaskType = TaskType --v1.0.0
   FROM dbo.TaskDetail WITH (NOLOCK)  
   WHERE TaskDetailKey = @cTaskDetailKey  
   ORDER BY 1

   --Validate the groupkey and cartid
   IF ISNULL(@cGroupkey, '') = ''
   BEGIN
      SET @nErrNo = 237901    
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Groupkey empty   
      GOTO Quit
   END

   IF ISNULL(@cCartID, '') = ''
   BEGIN
      SET @nErrNo = 237902    
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --CartId empty    
      GOTO Quit
   END

   IF @nDebugFlag = 1
      SELECT 'Get group values ', @cGroupKey AS GroupKey, @cCartID AS CartID, @cTaskType AS TaskType

   IF NOT EXISTS (SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) 
                  WHERE Groupkey = @cGroupKey 
                     AND DeviceID = @cCartID 
                     AND [Status] = '5' 
                     AND TaskType = @cTaskType)
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'No task detail found'
      INSERT INTO TRACEINFO (TraceName, TimeIn, Step1, Step2, Step3, Step4, Step5, Col1, Col2, Col3, Col4, Col5) VALUES
         ('1855CfmToLoc02', GETDATE(), 'NoTaskDetail', @cGroupKey, @cCartID, @cTaskDetailKey, @cToLOC, @nMobile, '', '', '', '')
   END
   --V1.0.0 end
   
   SET @nTranCount = @@TRANCOUNT    
   BEGIN TRAN  -- Begin our own transaction    
   SAVE TRAN ConfirmToLoc -- For rollback or commit only our own transaction    
  
   SET @cur = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR  
   SELECT TaskdetailKey, FromLOC, FromID, Sku, Qty, DropID  
   FROM dbo.TASKDETAIL WITH (NOLOCK)  
   WHERE Groupkey = @cGroupKey   
   AND   DeviceID = @cCartID   
   AND   [Status] = '5'
   AND   TaskType = @cTaskType --v1.0.0   
   OPEN @cur  
   FETCH NEXT FROM @cur INTO @cTaskKey, @cFromLOC, @cFromID, @cSKU, @nQty, @cDropID  
   WHILE @@FETCH_STATUS = 0  
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Close Task', @cTaskKey AS TaskKey
  
      UPDATE dbo.TaskDetail WITH(ROWLOCK)
      SET   
         FinalLOC = @cToLoc,
         [Status] = '9',
         EditWho = SUSER_SNAME(),
         EditDate = GETDATE()
      WHERE TaskDetailKey = @cTaskKey
  
      IF @@ERROR <> 0 OR @@ROWCOUNT = 0  
      BEGIN  
         SET @nErrNo = 237903    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Confirm Fail    
         GOTO RollBackTran    
      END  
        
      IF @cConfirmToLocMoveInventory = '1'  
      BEGIN  
         -- Move inventory
         IF @nQty > 0 --V1.1
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'Move Inventory', @cFromLOC AS FromLoc, @cToLoc AS ToLoc, @cSKU AS SKU, @nQty AS Qty, @cDropID AS DropID

            EXECUTE rdt.rdt_Move  
               @nMobile     = @nMobile,  
               @cLangCode   = @cLangCode,  
               @nErrNo      = @nErrNo  OUTPUT,  
               @cErrMsg     = @cErrMsg OUTPUT,  
               @cSourceType = 'rdt_1855CfmToLoc02',  
               @cStorerKey  = @cStorerKey,  
               @cFacility   = @cFacility,  
               @cFromLOC    = @cFromLOC,  
               @cToLOC      = @cToLoc,  
               @cFromID     = @cFromID,  
               @cToID       = @cFromID,  
               @cSKU        = @cSKU,  
               @nQTY        = @nQTY,  
               @nQTYPick    = @nQTY,  
               @cDropID     = @cDropID,  
               @nFunc       = @nFunc  
         
            IF @nErrNo <> 0  
               GOTO RollBackTran
         END --Qty > 0 --V1.1 
      END  
  
      FETCH NEXT FROM @cur INTO @cTaskKey, @cFromLOC, @cFromID, @cSKU, @nQty, @cDropID  
   END

   --V1.0.0 start
   --Clear the groupkey and deviceid which status = x in this groupkey and deviceid
   DELETE FROM @tTaskDetail
   
   INSERT INTO @tTaskDetail (TaskDetailKey)
   SELECT DISTINCT TaskDetailKey 
   FROM dbo.TaskDetail WITH (NOLOCK) 
   WHERE StorerKey = @cStorerKey
      AND Groupkey = @cGroupKey
      AND DeviceID = @cCartID
      AND [Status] = 'X'
      AND TaskType = @cTaskType

   SELECT @nRowCount = @@ROWCOUNT

   IF @nRowCount > 0
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Clear X status task groupkey and deviceid'

      UPDATE TD
      SET
         Groupkey = '',
         DeviceID = '',
         TrafficCop = NULL
      FROM dbo.TaskDetail TD WITH(ROWLOCK)
      INNER JOIN @tTaskDetail TTD ON TD.TaskDetailKey = TTD.TaskDetailKey
   END

   GOTO Quit  
  
RollBackTran:  
   ROLLBACK TRAN ConfirmToLoc -- Only rollback change made here  
Quit:  
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
      COMMIT TRAN  
      IF @nErrNo <> 0
         INSERT INTO TRACEINFO (TraceName, TimeIn, Step1, Col1, Col2, Col3, Col4, Col5) VALUES
         ('1855CfmToLoc02', GETDATE(), 'ErrNo<>0', @cFromLOC, @cToLoc, @cSKU, @nQTY, @nErrNo)
      
Fail:
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1855CfmToLoc02 TO NSQL
GO
