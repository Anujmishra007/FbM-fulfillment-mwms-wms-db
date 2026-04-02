SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/    
/* Store procedure: rdt_1855CfmToLoc05                                           */    
/* Copyright      : Maersk                                                       */    
/*                                                                               */    
/* Purpose: Confirm To Loc                                                       */  
/*                                                                               */  
/* Called from: rdt_TM_Assist_ClusterPick_ConfirmToLoc                           */  
/*                                                                               */  
/* Date         Rev  Author   Purposes                                           */  
/* 2026-04-01   1.0  NYE018    FCR-10039 Created                                 */
/*********************************************************************************/    
    
CREATE OR ALTER PROC rdt.rdt_1855CfmToLoc05 (    
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
    
   DECLARE @cSQL        NVARCHAR( MAX)    
   DECLARE @cSQLParam   NVARCHAR( MAX)    
   DECLARE @nTranCount  INT    
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
   DECLARE @nPickedQty  INT
   DECLARE @nTotalQty   INT  
     
   SELECT @cUserName = UserName  
   FROM rdt.RDTMOBREC WITH (NOLOCK)  
   WHERE Mobile = @nMobile  
     
   SET @cConfirmToLocMoveInventory = rdt.rdtGetConfig( @nFunc, 'ConfirmToLocMoveInventory', @cStorerKey)  

   SELECT TOP 1   
      @cGroupKey = Groupkey,  
      @cCartID = DeviceID  
   FROM dbo.TaskDetail WITH (NOLOCK)  
   WHERE TaskDetailKey = @cTaskDetailKey  
   ORDER BY 1  
     
   SET @nTranCount = @@TRANCOUNT    
   BEGIN TRAN  -- Begin our own transaction    
   SAVE TRAN ConfirmToLoc -- For rollback or commit only our own transaction    
  
   SET @cur = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR  
   SELECT TaskdetailKey, FromLOC, FromID, Sku, Qty, DropID  
   FROM dbo.TASKDETAIL WITH (NOLOCK)  
   WHERE Groupkey = @cGroupKey   
   AND   DeviceID = @cCartID   
   AND   [Status] = '5'  
   OPEN @cur  
   FETCH NEXT FROM @cur INTO @cTaskKey, @cFromLOC, @cFromID, @cSKU, @nQty, @cDropID  
   WHILE @@FETCH_STATUS = 0  
   BEGIN  
      UPDATE dbo.TaskDetail SET   
         FinalLOC = @cToLoc,  
         [Status] = '9',  
         EditWho = SUSER_SNAME(),  
         EditDate = GETDATE()  
      WHERE TaskDetailKey = @cTaskKey   
  
      IF @@ERROR <> 0 OR @@ROWCOUNT = 0  
      BEGIN  
         SET @nErrNo = 262901   
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD TskDtl fail   
         GOTO RollBackTran    
      END  
        
      IF @cConfirmToLocMoveInventory = '1'  
      BEGIN  
         -- Move inventory
         IF @nQty > 0 --V1.1
         BEGIN
            EXECUTE rdt.rdt_Move  
               @nMobile     = @nMobile,  
               @cLangCode   = @cLangCode,  
               @nErrNo      = @nErrNo  OUTPUT,  
               @cErrMsg     = @cErrMsg OUTPUT,  
               @cSourceType = 'rdt_1855CfmToLoc05',  
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

      -- Calculate picked and total qty from PickDetail
      SELECT @nPickedQty = ISNULL(SUM(Qty), 0)
      FROM dbo.PickDetail WITH(NOLOCK)
      WHERE TaskDetailKey = @cTaskKey
        AND Status = '5'
        AND Qty > 0

      SELECT @nTotalQty = ISNULL(SUM(Qty), 0)
      FROM dbo.PickDetail WITH(NOLOCK)
      WHERE TaskDetailKey = @cTaskKey

      -- Update TaskDetail with calculated quantities
      BEGIN TRY
         UPDATE dbo.TaskDetail SET
            SystemQty = @nTotalQty,
            Qty = ISNULL(@nPickedQty, 0),
            EditDate = GETDATE(),
            EditWho  = SUSER_SNAME()
         WHERE TaskDetailKey = @cTaskKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 262902
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
         GOTO RollBackTran
      END CATCH

      FETCH NEXT FROM @cur INTO @cTaskKey, @cFromLOC, @cFromID, @cSKU, @nQty, @cDropID  
   END  
     
    
   GOTO Quit    
    
RollBackTran:    
   ROLLBACK TRAN ConfirmToLoc -- Only rollback change made here    
Quit:    
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started    
      COMMIT TRAN    
        
Fail:  
END    
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1855CfmToLoc05 to nSQL
GO
