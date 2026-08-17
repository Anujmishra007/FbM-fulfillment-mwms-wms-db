SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO 
/************************************************************************/  
/* Store procedure: rdt_1764ExtUpdPGPE                                  */  
/* Copyright      : Maersk                                              */  
/* Customer       : PGPE                                                */  
/*                                                                      */  
/* Purpose: Active the hold pick task once the repl task is done        */  
/*                                                                      */  
/* Date         Author   Ver.  Purposes                                 */  
/* 2024-05-07   NLT013   1.0   UWP-19082 UWP-18889 Create Initial Ver  */  
/* 2026-06-15   FRO014   1.1   RITM9021237/UWP-62595 Remove SKU filter  */  
/*                             RP1 task does not include SKU value      */  
/* 2026-10-08   Sreeja   1.2   FCR-14583 Auto short reallocation        */  
/************************************************************************/  
   
CREATE OR ALTER  PROCEDURE [RDT].[rdt_1764ExtUpdPGPE]  
   @nMobile        INT,  
   @nFunc          INT,  
   @cLangCode      NVARCHAR( 3),  
   @nStep          INT,  
   @cTaskDetailKey NVARCHAR( 10),  
   @nErrNo         INT           OUTPUT,  
   @cErrMsg        NVARCHAR( 20) OUTPUT,  
   @nAfterStep     INT = 0,  
   @cDropID        NVARCHAR( 20) = ''  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
   
   DECLARE @nTranCount        INT  
   DECLARE @cStorerKey        NVARCHAR( 15)  
   DECLARE @cToLOC            NVARCHAR( 10)  
   DECLARE @cReplPickListName NVARCHAR( 10)  
   
      -- Step 9: short reallocation variables  
   DECLARE @bSuccess          INT  
   DECLARE @nFromStep         INT  
   DECLARE @cFacility         NVARCHAR(5)  
   DECLARE @cFromLOC          NVARCHAR(10)  
   DECLARE @cFromID           NVARCHAR(18)  
   DECLARE @cToID             NVARCHAR(18)  
   DECLARE @cLOT              NVARCHAR(10)  
   DECLARE @cSKU              NVARCHAR(30)  
   DECLARE @cUOM              NVARCHAR(5)  
   DECLARE @cPickMethod       NVARCHAR(10)  
   DECLARE @cCaseID           NVARCHAR(20)  
   DECLARE @cWaveKey          NVARCHAR(10)  
   DECLARE @cFinalLoc         NVARCHAR(10)  
   DECLARE @cReasonCode       NVARCHAR(10)  
   DECLARE @nQTY_RPL          INT  
   DECLARE @nQtyExpected      INT  
   DECLARE @cPickFromLoc      NVARCHAR(10)  
   DECLARE @cLoseID           NVARCHAR(1)  
   DECLARE @nQueueID          INT  
   DECLARE @cCCTaskDetailKey  NVARCHAR(10)  
   DECLARE @cRCCycleCount     NVARCHAR(1)  
   DECLARE @cLocHoldKey       NVARCHAR(20)  
   DECLARE @cErrMsg1          NVARCHAR(125)  
   DECLARE @cErrMsg2          NVARCHAR(125)  
   DECLARE @cErrMsg3          NVARCHAR(125)  
   DECLARE @cLogicalToLoc     NVARCHAR(10)  
   DECLARE @nPABookingKey     INT  
   DECLARE @nTaskQty          INT  
   DECLARE  
      @cAPP_DB_Name        NVARCHAR(20),  
      @cDataStream         VARCHAR(10),  
      @nThreadPerAcct      INT,  
      @nThreadPerStream    INT,  
      @nMilisecondDelay    INT,  
      @cIP                 NVARCHAR(20),  
      @cPORT               NVARCHAR(5),  
      @cIniFilePath        NVARCHAR(200),  
      @cCmdType            NVARCHAR(10),  
      @cExecStatements     NVARCHAR(MAX)  
   
   SET @nTranCount = @@TRANCOUNT  
   
   IF @nFunc = 1764  
   BEGIN  
      IF @nStep = 6 -- ToLOC  
      BEGIN  
         SELECT  
            @cStorerKey = StorerKey,  
            @cToLOC     = ToLoc  
         FROM dbo.TaskDetail WITH (NOLOCK)  
         WHERE TaskDetailKey = @cTaskDetailKey  
            AND TaskType IN ('RPF', 'RP1')  
   
         SET @cReplPickListName = rdt.RDTGetConfig(@nFunc, 'TM_RPLRELPICK', @cStorerKey)  
         IF ISNULL(@cReplPickListName, '') = ''  
            SET @cReplPickListName = '0'  
   
         BEGIN TRAN  
         SAVE TRAN rdt_1764ExtUpdPGPE  
   
         BEGIN TRY  
            UPDATE dbo.TaskDetail WITH (ROWLOCK)  
            SET Status   = '0',  
                EditWho  = SUSER_SNAME(),  
                EditDate = GETDATE()  
            FROM dbo.TaskDetail td  
            INNER JOIN dbo.CODELKUP lu WITH (NOLOCK)  
               ON  td.StorerKey = lu.StorerKey  
               AND td.TaskType  = ISNULL(lu.Code2, '')  
            WHERE td.StorerKey = @cStorerKey  
               AND lu.LISTNAME = @cReplPickListName  
               AND td.Status   = 'H'  
               AND td.FromLoc  = @cToLOC  
         END TRY  
         BEGIN CATCH  
            SET @nErrNo  = 275060  
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- UpdPKTaskFail  
            GOTO RollBackTran  
         END CATCH  
   
         COMMIT TRAN rdt_1764ExtUpdPGPE  
      END  
   
      -- Step 9: Reason screen — EMPTY pallet short reallocation (FCR-14583)  
      IF @nStep = 9  
      BEGIN  
         -- Read MobRec: V_FromStep must be 8 (ShortPick) to proceed  
         SELECT  
            @cStorerKey = StorerKey,  
            @nQTY_RPL   = V_Integer1,  
            @cFacility  = Facility,  
            @nFromStep  = V_FromStep  
         FROM rdt.RDTMOBREC WITH (NOLOCK)  
         WHERE Mobile = @nMobile  
   
         -- Read TaskDetail  
         SELECT  
            @cFromLOC      = FromLOC,  
            @cFromID       = FromID,  
            @cToLoc        = ToLoc,  
            @cToID         = ToID,  
            @cLogicalToLoc = LogicalToLoc,  
            @nTaskQty      = Qty,  
            @cLOT          = LOT,  
            @cSKU          = SKU,  
            @cUOM          = UOM,  
            @cPickMethod   = PickMethod,  
            @cCaseID       = CaseID,  
            @cWaveKey      = WaveKey,  
            @cFinalLoc     = FinalLoc,  
            @cReasonCode   = ReasonKey  
         FROM dbo.TaskDetail WITH (NOLOCK)  
         WHERE TaskDetailKey = @cTaskDetailKey  
   
         IF @@ROWCOUNT = 0  
            GOTO Quit  
  
         -- Guard 1: UOM=1 only (full pallet replenishment)  
         IF ISNULL(@cUOM, '') <> '1'  
            GOTO Quit  
   
         -- Guard: EMPTY reason only  
         IF ISNULL(@cReasonCode, '') <> 'EMPTY'  
            GOTO Quit  
   
         -- DoCycleCount flag: nspRFRSN01 created a CC task when '1'  
         SELECT @cRCCycleCount = DoCycleCount  
         FROM dbo.TASKMANAGERREASON WITH (NOLOCK)  
         WHERE TaskManagerReasonKey = @cReasonCode  
   
         BEGIN TRAN  
         SAVE TRAN rdt_1764ExtUpdPGPE  
  
         -- Update Message01 on the CC task created by nspRFRSN01  
         IF ISNULL(@cRCCycleCount, '') = '1'  
         BEGIN  
            SELECT TOP 1 @cCCTaskDetailKey = TaskDetailKey  
            FROM dbo.TaskDetail WITH (NOLOCK)  
            WHERE StorerKey = @cStorerKey  
              AND FromLOC   = @cFromLOC  
              AND TaskType  = 'CC'  
              AND Status    = '0'  
            ORDER BY TaskDetailKey DESC  
   
            IF ISNULL(@cCCTaskDetailKey, '') <> ''  
            BEGIN  
               BEGIN TRY  
                  UPDATE dbo.TaskDetail WITH (ROWLOCK)  
                  SET    Message01 = 'CC for short on LOC'  
                  WHERE  TaskDetailKey = @cCCTaskDetailKey  
               END TRY  
               BEGIN CATCH  
                  SET @nErrNo = 276351  
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  -- UpdPKTaskFail
                  GOTO RollBackTran  
               END CATCH  
            END  
         END  
   
         -- Hold source location  
         SET @cLocHoldKey = rdt.rdtGetConfig(@nFunc, 'LocHoldKey', @cStorerKey)  
         IF ISNULL(@cLocHoldKey, '') = ''  
            SET @cLocHoldKey = 'HOLD'  
   
         IF NOT EXISTS (  
            SELECT 1 FROM dbo.INVENTORYHOLD WITH (NOLOCK)  
            WHERE Loc  = @cFromLOC  
              AND Hold = '1')  
         BEGIN  
            BEGIN TRY  
               EXECUTE dbo.nspInventoryHold  
                  ''  
                  , @cFromLOC  
                  , ''  
                  , @cLocHoldKey  
                  , '1'  
                  , @bSuccess OUTPUT  
                  , @nErrNo   OUTPUT  
                  , @cErrMsg  OUTPUT  
   
               IF @bSuccess <> 1 OR @nErrNo <> 0  
               BEGIN  
                  IF @nErrNo = 0  
                     SET @nErrNo = 276352  
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --ExeInvHldFail
                  GOTO RollBackTran  
               END  
            END TRY  
            BEGIN CATCH  
               SET @nErrNo = 276353
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --ExeInvHldFail
               GOTO RollBackTran  
            END CATCH  
         END  
   
         SET @cPickFromLoc = ISNULL(NULLIF(@cLogicalToLoc, ''), @cFinalLoc)  

         SELECT @cLoseID = LoseID  
         FROM dbo.Loc WITH (NOLOCK)  
         WHERE Loc = @cPickFromLoc  
   
         -- FIFO: find oldest QtyExpected row at pick face (not filtered by task LOT)  
         DECLARE @cQtyExpLOT NVARCHAR(10)  
  
         SELECT TOP 1  
            @cQtyExpLOT   = LOT,  
            @nQtyExpected = QtyExpected  
         FROM dbo.LOTxLOCxID WITH (NOLOCK)  
         WHERE StorerKey   = @cStorerKey  
           AND LOC         = @cPickFromLoc  
           AND QtyExpected > 0  
         ORDER BY LOT ASC   -- FIFO: oldest LOT first  
   
         -- Reduce QTYReplen booking on source LOC  
         BEGIN TRY  
            UPDATE dbo.LOTxLOCxID WITH (ROWLOCK)  
            SET    QTYReplen = CASE  
                                  WHEN (QTYReplen - @nTaskQty) > 0  
                                  THEN (QTYReplen - @nTaskQty)  
                                  ELSE 0  
                               END  
            WHERE  LOT = @cLOT  
              AND StorerKey = @cStorerKey  
              AND  LOC = @cFromLOC  
         END TRY  
         BEGIN CATCH  
            SET @nErrNo = 276354  
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --UpdLOTxLOCxIDFail
            GOTO RollBackTran  
         END CATCH  
   
         -- UNLOCK: deletes RFPutaway record and releases PendingMoveIN at pick face  
         SELECT TOP 1 @nPABookingKey = PABookingKey  
         FROM dbo.RFPutaway WITH (NOLOCK)  
         WHERE StorerKey    = @cStorerKey  
           AND FromLoc      = @cFromLOC  
           AND FromID       = @cFromID  
           AND SuggestedLOC = @cFinalLoc  
           AND (ISNULL(@cSKU, '') = '' OR SKU = @cSKU) 
           AND Qty          = @nTaskQty  
         ORDER BY AddDate DESC  
  
         IF ISNULL(@nPABookingKey, 0) <> 0  
         BEGIN  
            BEGIN TRY  
               EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'  
                  , ''  -- @cFromLOC  
                  , ''  -- @cFromID  
                  , ''  -- @cSuggestedLOC  
                  , ''  -- @cStorerKey  
                  , @nErrNo  OUTPUT  
                  , @cErrMsg OUTPUT  
                  , @nPABookingKey = @nPABookingKey  
               IF @nErrNo <> 0  
               BEGIN  
                  SET @nErrNo = 276355  
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --ExePutawayFail
                  GOTO RollBackTran  
               END  
            END TRY  
            BEGIN CATCH  
               SET @nErrNo = 276356  
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --ExePutawayFail
               GOTO RollBackTran   
            END CATCH  
         END  

         -- Short-close the RPF task: mark as completed with 0 qty moved.  
         -- Without this, Fn1764 loops picker back to Step 2 of the same task.  
         BEGIN TRY  
            UPDATE dbo.TaskDetail WITH (ROWLOCK)  
            SET    Status   = '9',  
                   EditWho  = SUSER_SNAME(),  
                   EditDate = GETDATE()  
            WHERE  TaskDetailKey = @cTaskDetailKey  
              AND  Status NOT IN ('9', 'X')  
         END TRY  
         BEGIN CATCH  
            SET @nErrNo = 276357
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')   --UpdTskDtlFail
            GOTO RollBackTran  
         END CATCH  
   
         -- QCommander: trigger msp_ProcessShortReplenReAlloc_Std (runs after commit)  
         SELECT  
            @cAPP_DB_Name     = APP_DB_Name,  
            @cDataStream      = DataStream,  
            @nThreadPerAcct   = ThreadPerAcct,  
            @nThreadPerStream = ThreadPerStream,  
            @nMilisecondDelay = MilisecondDelay,  
            @cIP              = IP,  
            @cPORT            = PORT,  
            @cIniFilePath     = IniFilePath,  
            @cCmdType         = CmdType,  
            @cExecStatements  = StoredProcName  
         FROM dbo.QCmd_TransmitlogConfig WITH (NOLOCK)  
         WHERE TableName = '1764ShortPickReallo'  
           AND App_Name  = 'WMS'  
           AND StorerKey = @cStorerKey  
   
         IF @cExecStatements IS NULL  
         BEGIN  
            SET @nErrNo = 276358
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --GenQcmdTaskFail
            GOTO RollBackTran  
         END
   
         IF ISNULL(@cSKU, '') = ''  
         BEGIN  
            SELECT @cErrMsg1='', @cErrMsg2='', @cErrMsg3=''  
            SET @cErrMsg1 = '91007-SKUEmpty'  
            SET @cErrMsg2 = 'Trigger realloc fail'  
            EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3  
            GOTO RollBackTran  
         END  
   
         SET @cExecStatements = 'EXEC ' + @cAPP_DB_Name + '.dbo.' + LTRIM(@cExecStatements)  
                     + ' @c_Wavekey        = ''' + REPLACE(ISNULL(@cWaveKey, ''),    '''', '''''') + ''''  
                     + ', @c_SKU           = ''' + REPLACE(@cSKU,                    '''', '''''') + ''''  
                     + ', @c_UCCNo         = ''' + REPLACE(ISNULL(@cCaseID, ''),     '''', '''''') + ''''  
                     + ', @c_TaskDetailKey = ''' + REPLACE(@cTaskDetailKey,           '''', '''''') + ''''

         BEGIN TRY
            EXEC dbo.isp_QCmd_SubmitTaskToQCommander  
               @cTaskType        = 'O'  
               , @cStorerKey       = @cStorerKey  
               , @cDataStream      = @cDataStream  
               , @cCmdType         = @cCmdType  
               , @cCommand         = @cExecStatements  
               , @cTransmitlogKey  = @cTaskDetailKey  
               , @nThreadPerAcct   = @nThreadPerAcct  
               , @nThreadPerStream = @nThreadPerStream  
               , @nMilisecondDelay = @nMilisecondDelay  
               , @nSeq             = 1  
               , @cIP              = @cIP  
               , @cPORT            = @cPORT  
               , @cIniFilePath     = @cIniFilePath  
               , @cAPPDBName       = @cAPP_DB_Name  
               , @bSuccess         = @bSuccess   OUTPUT  
               , @nErr             = @nErrNo     OUTPUT  
               , @cErrMsg          = @cErrMsg    OUTPUT  
               , @nQueueID         = @nQueueID   OUTPUT  
         END TRY  
         BEGIN CATCH  
            SELECT @cErrMsg1='', @cErrMsg2='', @cErrMsg3=''  
            SET @cErrMsg3 = ERROR_MESSAGE()  
            SET @cErrMsg1 = 'QcmdFail'  
            SET @cErrMsg2 = 'Trigger realloc fail'  
            EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3  
            GOTO RollBackTran  
         END CATCH  
   
         IF @nErrNo <> 0  
         BEGIN  
            SELECT @cErrMsg1='', @cErrMsg2='', @cErrMsg3=''  
            SET @cErrMsg3 = 'Return err: ' + TRY_CAST(@nErrNo AS NVARCHAR(10))  
            SET @cErrMsg1 = 'GenQcmdTaskFail'  
            SET @cErrMsg2 = 'Trigger realloc fail'  
            EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3  
            GOTO RollBackTran  
         END  
         COMMIT TRAN rdt_1764ExtUpdPGPE 
   
      END -- Step 9  
   END  
   
   GOTO Quit  
   
RollBackTran:  
   IF XACT_STATE() = -1         -- Uncommittable — must full-rollback
      ROLLBACK TRAN
   ELSE IF XACT_STATE() = 1     -- Active and committable — rollback to savepoint only
      ROLLBACK TRAN rdt_1764ExtUpdPGPE 
  
Quit:  
   WHILE @@TRANCOUNT > @nTranCount  
      COMMIT TRAN  
   
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1764ExtUpdPGPE] TO NSQL
GO