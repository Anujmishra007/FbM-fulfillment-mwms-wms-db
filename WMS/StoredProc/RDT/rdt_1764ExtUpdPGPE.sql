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
/* 2026-06-15   FRO014   2.0   RITM9021237/UWP-62595 Remove SKU filter  */
/*                             RP1 task does not include SKU value      */
/* 2026-10-08   Sreeja   2.1   FCR-14583 Auto short reallocation        */
/************************************************************************/
 
CREATE OR ALTER PROCEDURE [RDT].[rdt_1764ExtUpdPGPE]
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
 
   -- DECLARE @tPickTaskList   TABLE (TaskDetailKey NVARCHAR(10))
   -- DECLARE @tPickDetailList TABLE (PickDetailKey NVARCHAR(10))
 
   
         insert into traceinfo (tracename, timein, step1, step2, col1, col2, col3)
         values ('1764ExtUpdPGPE', getdate(), 'my_code', 'start', 'Starting', @nfunc, @nStep)
 
 
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
        insert into traceinfo (tracename, timein, step1, step2, col1, col2, col3)
         values ('1764ExtUpdPGPE', getdate(), 'my_code', 'start', '=Step_9', @nfunc, @nStep)
         -- Read MobRec: V_FromStep must be 8 (ShortPick) to proceed
         SELECT
            @cStorerKey = StorerKey,
            @nQTY_RPL   = V_Integer1,
            @cFacility  = Facility,
            @nFromStep  = V_FromStep
         FROM rdt.rdtMobRec WITH (NOLOCK)
         WHERE Mobile = @nMobile
 
         INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, Col1, Col2, Col3)
         VALUES ('1764ExtUpdPGPE', GETDATE(), 'Step9', 'MobRec',
            @cTaskDetailKey, CAST(@nFromStep AS NVARCHAR(5)), CAST(@nQTY_RPL AS NVARCHAR(10)))
 
         -- IF ISNULL(@nFromStep, 0) <> 8
         --    GOTO Quit
 
         -- Read TaskDetail
         SELECT
            @cFromLOC    = FromLOC,
            @cFromID     = FromID,
            @cToLoc      = ToLoc,
            @cToID       = ToID,
            @cLOT        = LOT,
            @cSKU        = SKU,
            @cUOM        = UOM,
            @cPickMethod = PickMethod,
            @cCaseID     = CaseID,
            @cWaveKey    = WaveKey,
            @cFinalLoc   = FinalLoc,
            @cReasonCode = ReasonKey
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE TaskDetailKey = @cTaskDetailKey
 
         IF @@ROWCOUNT = 0
            GOTO Quit

         -- -- Guard: skip if RPF task already short-closed or cancelled
         -- -- Prevents duplicate CC tasks and Q_com triggers on re-entry
         IF EXISTS (
            SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE TaskDetailKey = @cTaskDetailKey
              AND Status IN ('9', 'X'))
            GOTO Quit
         
                  INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, Col1, Col2, Col3, Col4, Col5)
         VALUES ('1764ExtUpdPGPE', GETDATE(), 'Step9', 'TskDtl',
            @cTaskDetailKey, @cFromLOC, @cPickMethod, @cReasonCode, @cUOM)
 
         -- Guard 1: UOM=1 only (full pallet replenishment)
         IF ISNULL(@cUOM, '') <> '1'
            GOTO Quit
 
         -- Guard: EMPTY reason only
         IF ISNULL(@cReasonCode, '') <> 'EMPTY'
            GOTO Quit
 
         insert into traceinfo (tracename, timein, step1, step2, col1)
         values ('1764ExtUpdPGPE', getdate(), 'my_code', 'start', 'Step9-ShortReallo')
 
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
                  SET @nErrNo = 276352
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran
               END CATCH
            END
         END
 
                  INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, Col1, Col2)
         VALUES ('1764ExtUpdPGPE', GETDATE(), 'Step9', 'CCUpd',
            ISNULL(@cCCTaskDetailKey, 'none'), ISNULL(@cRCCycleCount, '0'))
 
 
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
                     SET @nErrNo = 276353
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran
               END
            END TRY
            BEGIN CATCH
               SET @nErrNo = 276354
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               GOTO RollBackTran
            END CATCH
         END
 
                  INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, Col1, Col2)
         VALUES ('1764ExtUpdPGPE', GETDATE(), 'Step9', 'Hold',
            @cFromLOC, CAST(@bSuccess AS NVARCHAR(3)))
 
 
         -- -- Find related FCP tasks: FCP.FromLoc = RPF.FinalLoc (or ToLoc)
         -- INSERT INTO @tPickTaskList (TaskDetailKey)
         --    SELECT TD1.TaskDetailKey
         --    FROM dbo.TaskDetail TD1 WITH (NOLOCK)
         --    JOIN dbo.TaskDetail TD2 WITH (NOLOCK)
         --       ON  TD1.Storerkey = TD2.Storerkey
         --       AND (
         --          (ISNULL(TD2.FinalLOC, '') <> '' AND TD2.FinalLOC = TD1.FromLoc)
         --       OR (ISNULL(TD2.FinalLOC, '') = ''  AND TD2.ToLoc    = TD1.FromLoc)
         --       )
         --       AND TD1.Status   = 'H'
         --       AND TD1.TaskType = 'FCP'
         --    WHERE TD2.Storerkey     = @cStorerKey
         --      AND TD2.TaskDetailKey = @cTaskDetailKey
 
         -- IF EXISTS (SELECT 1 FROM @tPickTaskList)
         -- BEGIN
         --    INSERT INTO @tPickDetailList (PickDetailKey)
         --       SELECT PKD.PickDetailKey
         --       FROM dbo.PickDetail PKD WITH (NOLOCK)
         --       JOIN @tPickTaskList PTL ON PKD.TaskDetailKey = PTL.TaskDetailKey
         --       WHERE PKD.Status = '0'
 
         --    IF EXISTS (SELECT 1 FROM @tPickDetailList)
         --    BEGIN
         --       BEGIN TRY
         --          UPDATE PKD WITH (ROWLOCK)
         --          SET    PKD.Qty    = 0,
         --                 PKD.Status = '4'
         --          FROM   dbo.PickDetail PKD
         --          JOIN   @tPickDetailList PTL ON PKD.PickDetailKey = PTL.PickDetailKey
         --       END TRY
         --       BEGIN CATCH
         --          SET @nErrNo = 276355
         --          SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         --          GOTO RollBackTran
         --       END CATCH
         --    END
         -- END
 
         -- Reduce QtyExpected on pick face (FinalLoc or ToLoc)
         -- IF ISNULL(@cFinalLoc, '') <> ''
         --    SET @cPickFromLoc = @cFinalLoc
         -- ELSE
            SET @cPickFromLoc = @cToLoc
 
         SELECT @cLoseID = LoseID
         FROM dbo.Loc WITH (NOLOCK)
         WHERE Loc = @cPickFromLoc
 
         SELECT @nQtyExpected = QtyExpected
         FROM dbo.LOTxLOCxID WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
           AND LOC       = @cPickFromLoc
           AND LOT       = @cLOT
           AND ID        = CASE WHEN @cLoseID = '1' THEN '' ELSE @cToID END
 
         IF ISNULL(@nQtyExpected, 0) > 0
         BEGIN
            BEGIN TRY
               UPDATE dbo.LOTxLOCxID WITH (ROWLOCK)
               SET    QtyExpected = 0
               WHERE  StorerKey = @cStorerKey
                 AND  LOC       = @cPickFromLoc
                 AND  LOT       = @cLOT
                 AND  ID        = CASE WHEN @cLoseID = '1' THEN '' ELSE @cToID END
            END TRY
            BEGIN CATCH

               SET @nErrNo = 276356
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --  @cPickFromLoc + ', ' + @cLOT + ', ' + @cLoseID + ', ' + @cToID
               GOTO RollBackTran
            END CATCH
         END
 
         -- Reduce QTYReplen booking on source LOC
         BEGIN TRY
            UPDATE dbo.LOTxLOCxID WITH (ROWLOCK)
            SET    QTYReplen = CASE
                                  WHEN (QTYReplen - @nQTY_RPL) > 0
                                  THEN (QTYReplen - @nQTY_RPL)
                                  ELSE 0
                               END
            WHERE  LOT = @cLOT
              AND  LOC = @cFromLOC
              AND  ID  = @cFromID
         END TRY
         BEGIN CATCH
            SET @nErrNo = 276357
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            GOTO RollBackTran
         END CATCH
 
                  INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, Col1, Col2, Col3)
         VALUES ('1764ExtUpdPGPE', GETDATE(), 'Step9', 'Committed',
            @cTaskDetailKey, @cFromLOC, CAST(@nQTY_RPL AS NVARCHAR(10)))

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
            SET @nErrNo = 276358
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            GOTO RollBackTran
         END CATCH
 
 
         COMMIT TRAN rdt_1764ExtUpdPGPE
 
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
            GOTO Quit
 
         IF ISNULL(@cSKU, '') = ''
         BEGIN
            SELECT @cErrMsg1='', @cErrMsg2='', @cErrMsg3=''
            SET @cErrMsg1 = '91007-SKUEmpty'
            SET @cErrMsg2 = 'Trigger realloc fail'
            EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
            GOTO Quit
         END
 
         IF ISNULL(@cCaseID, '') = '' AND ISNULL(@cUOM, '') <> '1'
BEGIN
   SELECT @cErrMsg1='', @cErrMsg2='', @cErrMsg3=''
   SET @cErrMsg1 = '91007-UCCNoEmpty'
   SET @cErrMsg2 = 'Trigger realloc fail'
   EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
   GOTO Quit
END

 
         SET @cExecStatements = 'EXEC ' + @cAPP_DB_Name + '.dbo.' + LTRIM(@cExecStatements)
                              + ' @c_Wavekey        = ''' + ISNULL(@cWaveKey, '') + ''''
                              + ', @c_SKU           = ''' + @cSKU + ''''
                              + ', @c_UCCNo         = ''' + @cCaseID + ''''
                              + ', @c_TaskDetailKey = ''' + @cTaskDetailKey + ''''
 
         BEGIN TRY
         insert into traceinfo (tracename, timein, step1, step2, col1)
         values ('1764ExtUpdPGPE', getdate(), 'Q_com', 'exec', 'Step9-ShortReallo')
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
            GOTO Quit
         END CATCH
 
         IF @nErrNo <> 0
         BEGIN
            SELECT @cErrMsg1='', @cErrMsg2='', @cErrMsg3=''
            SET @cErrMsg3 = 'Return err: ' + TRY_CAST(@nErrNo AS NVARCHAR(10))
            SET @cErrMsg1 = 'GenQcmdTaskFail'
            SET @cErrMsg2 = 'Trigger realloc fail'
            EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
            GOTO Quit
         END
 
      END -- Step 9
   END
 
   GOTO Quit
 
RollBackTran:
   ROLLBACK TRAN rdt_1764ExtUpdPGPE
   INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, Col1, Col2, Col3, Col4, Col5)
   VALUES ('1764ExtUpdPGPE', GETDATE(), 'RollBack', CAST(@nErrNo AS NVARCHAR(10)),
      @cTaskDetailKey, @cFromLOC, @cPickFromLoc,
      CAST(@nQtyExpected AS NVARCHAR(10)), @cErrMsg)

Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN
 
END
GO
 
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
GRANT EXECUTE ON [RDT].[rdt_1764ExtUpdPGPE] TO [NSQL]
GO
 