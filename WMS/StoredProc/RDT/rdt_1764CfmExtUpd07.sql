
/************************************************************************/
/* Store procedure: rdt_1764CfmExtUpd07                                 */
/* Purpose: 1. Short PickDetail                                         */
/*          2.                                          */
/*             2.1 Remove booking (QTYReplen)                           */
/*                                                                      */
/*                                                                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2025-12-17   Jackc     1.0   FCR-8534 Created                        */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1764CfmExtUpd07
    @nMobile            INT 
   ,@nFunc              INT 
   ,@cLangCode          NVARCHAR( 3) 
   ,@cTaskdetailKey     NVARCHAR( 10) 
   ,@cNewTaskdetailKey  NVARCHAR( 10) 
   ,@nErrNo             INT           OUTPUT 
   ,@cErrMsg            NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag     INT = 0
   DECLARE @CUsername      NVARCHAR(128)

   DECLARE @cPickDetailKey NVARCHAR(10)
   DECLARE @cDropID        NVARCHAR(20)
   DECLARE @bSuccess       INT
   DECLARE @nQTY           INT
   DECLARE @nQTY_PD        INT
   DECLARE @nQTY_RPL       INT
   DECLARE @nNewTaskQty    INT
   DECLARE @nOrgTaskQty    INT
   DECLARE @nSystemQTY     INT
   DECLARE @nOrgSystemQTY  INT
   DECLARE @nNewSystemQTY  INT
   DECLARE @nPickQTY       INT
   DECLARE @nShortQTY      INT
   DECLARE @nQTYReplen     INT
   DECLARE @nQtyExpected   INT
   DECLARE @cReasonCode    NVARCHAR(10)
   DECLARE @cTask          NVARCHAR(3)
   DECLARE @cPickMethod    NVARCHAR(10)
   DECLARE @cLOT           NVARCHAR(10)
   DECLARE @cFromLOC       NVARCHAR(10)
   DECLARE @cToLoc         NVARCHAR(10)
   DECLARE @cPickFromLoc   NVARCHAR(10)
   DECLARE @cLoseID        NVARCHAR(1)
   DECLARE @cTaskFromID    NVARCHAR(18)
   DECLARE @cTaskToID      NVARCHAR(18)
   DECLARE @cStorerKey     NVARCHAR(15)
   DECLARE @cFinalLoc      NVARCHAR(10) = ''
   DECLARE @cSKU           NVARCHAR(30)
   DECLARE @cWavekey       NVARCHAR(10)
   DECLARE @cUCCNo         NVARCHAR(20)

   DECLARE 
      @cAPP_DB_Name              NVARCHAR(20),
      @cDataStream               VARCHAR(10),
      @nThreadPerAcct            INT,
      @nThreadPerStream          INT,
      @nMilisecondDelay          INT,
      @nQueueID                  INT,
      @cIP                       NVARCHAR(20),
      @cPORT                     NVARCHAR(5),
      @cIniFilePath              NVARCHAR(200),
      @cCmdType                  NVARCHAR(10),
      @cTaskType                 NVARCHAR(1),
      @c_TransmitlogKey          NVARCHAR(10),
      @cExecStatements           NVARCHAR(MAX),
      @cExecArguments            NVARCHAR(MAX)

   DECLARE 
      @cErrMsg1      NVARCHAR(125),
      @cErrMsg2      NVARCHAR(125),
      @cErrMsg3      NVARCHAR(125)

   DECLARE @tPickTaskList TABLE
   (
      TaskDetailKey  NVARCHAR(10)
   )

   DECLARE @tPickDetailList TABLE
   (
      PickDetailKey  NVARCHAR(10)
   )

   DECLARE @nTranCount  INT
   SET @nTranCount = @@TRANCOUNT

   
   --ONBR RPLEN is UCC level. So it is full short only. @nQty always 0

   -- Get suggested replen QTY and actual QTY
   SET @nQTY_RPL = 0
   SET @nQTY = 0
   SELECT 
      @cStorerKey    = StorerKey,
      @cUserName     = UserName,
      @nQTY_RPL      = V_Integer1, 
      @nQTY          = V_Integer4 
   FROM rdt.rdtMobRec WITH (NOLOCK) 
   WHERE Mobile = @nMobile

   IF @nDebugFlag = 1
      SELECT 'Executing 1764CfmExtUpd07', @cTaskDetailKey AS OrgTask, @cNewTaskDetailKey AS NewTask,
         @nQTY_RPL AS ExpectedQty, @nQTY AS ActualQty

   -- Get orginal task info
   SELECT 
      @cPickMethod   = PickMethod, 
      @cReasonCode   = ReasonKey,
      @cSKU          = SKU, 
      @cLOT          = LOT, 
      @cFromLOC      = FromLOC, 
      @cTaskFromID   = FromID,
      @cToLoc        = ToLoc,
      @cTaskToID     = ToID,
      @cUCCNo        = Caseid,
      @cFinalLoc     = FinalLoc, 
      @nOrgSystemQTY = SystemQTY, 
      @nOrgTaskQty   = @nQTY_RPL, -- QTY for PickDetail
      @nShortQTY     = @nQTY_RPL - @nQTY
   FROM dbo.TaskDetail WITH (NOLOCK) 
   WHERE TaskDetailKey = @cTaskdetailKey

   --upd task Message01
   IF (SELECT DoCycleCount   -- (ChewKP03)
         FROM TASKMANAGERREASON WITH (NOLOCK)      
         WHERE TaskManagerReasonKey = @cReasonCode) = '1'
   BEGIN
      BEGIN TRY
         UPDATE dbo.TaskDetail WITH (ROWLOCK)
         SET 
            Message01 = 'CCForShortOnLoc',
            Trafficcop = NULL
         WHERE TaskDetailKey = @cTaskdetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 254163
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD TD Fail
         GOTO RollBackTran
      END CATCH
   END

   -- FP, does not close pallet or short
   IF @cPickMethod = 'FP'
      RETURN

   --not short
   IF ISNULL(@cReasonCode, '') = ''
      RETURN

   --Get related pick task
   INSERT INTO @tPickTaskList (TaskDetailKey)
      SELECT TD1.TaskDetailKey 
      FROM dbo.TaskDetail TD1 WITH (NOLOCK)
      JOIN dbo.TaskDetail TD2 (NOLOCK)
         ON TD1.Storerkey = TD2.Storerkey
         AND (
            (ISNULL(TD2.FinalLOC, '') <> '' AND TD2.FinalLOC = TD1.FromLoc)
            OR
            (ISNULL(TD2.FinalLOC, '') = '' AND TD2.ToLoc = TD1.FromLoc)
         )
         AND TD1.Status = 'H'
         AND TD1.TaskType = 'FCP'
      WHERE TD2.Storerkey = @cStorerKey
         AND TD2.TaskDetailKey = @cTaskDetailKey

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'RPF related picking tasks'
      SELECT * FROM @tPickTaskList
   END

   IF NOT EXISTS (SELECT 1 FROM @tPickTaskList)
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'No Picking task'

      IF @nDebugFlag = 2
         INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2,
            Col1, Col2, Col3, Col4, Col5)
         VALUES ('1764CfmUpd07', GETDATE(), @CUsername, CAST(@nmobile AS NVARCHAR(10)),
            @cTaskDetailKey, '', '', '', 'NoPickTask')

      GOTO Reset_QtyReplen
   END -- No Pick task

   --Get related pickdetail
   INSERT INTO @tPickDetailList (PickDetailKey)
      SELECT PickDetailKey
      FROM dbo.PickDetail PKD WITH (NOLOCK)
      JOIN @tPickTaskList PTL
         ON PKD.TaskDetailKey = PTL.TaskDetailKey
      WHERE PKD.Status = '0'

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'RPF related pkd'
      SELECT * FROM @tPickDetailList
   END

   IF NOT EXISTS (SELECT 1 FROM @tPickDetailList)
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'No Picking detail'

      IF @nDebugFlag = 2
      BEGIN
         INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2,
            Col1, Col2, Col3, Col4, Col5)
         VALUES ('1764CfmUpd07', GETDATE(), @CUsername, CAST(@nmobile AS NVARCHAR(10)),
            @cTaskDetailKey, '', '', '', 'NoPickDetl')
      END

      GOTO Reset_QtyReplen
   END -- No Pick task

   -- Mark PickDetail as short, update taskdetail qty
   IF @nQTY = 0
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Short PKD'

      IF @nDebugFlag = 2
      BEGIN
         INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2,
            Col1, Col2, Col3, Col4, Col5)
         SELECT
            '1764CfmUpd07',
            GETDATE(),
            @CUsername,
            CAST(@nMobile AS NVARCHAR(10)),
            @cTaskDetailKey,
            PKD.PickDetailKey,
            CAST(PKD.Qty AS NVARCHAR(10)),
            '',
            'ShortPickDetlQty'
         FROM dbo.PickDetail PKD
         JOIN @tPickDetailList PTL
            ON PKD.PickDetailKey = PTL.PickDetailKey
      END

      BEGIN TRY
         UPDATE PKD WITH (ROWLOCK)
         SET
            PKD.Qty = 0, 
            PKD.Status = '4'
         FROM dbo.PickDetail PKD
         JOIN @tPickDetailList PTL
            ON PKD.PickDetailKey = PTL.PickDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 254152
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKD Fail
         GOTO RollBackTran
      END CATCH

      --No need to handle task, reallo will do

      --Handle QtyExpected
      IF ISNULL(@cFinalLoc, '') <> ''
         SET @cPickFromLoc = @cFinalLoc
      ELSE
         SET @cPickFromLoc = @cToLOC

      SELECT @cLoseID = LoseID FROM dbo.Loc WITH (NOLOCK) WHERE Loc = @cPickFromLoc

      SELECT @nQtyExpected = QtyExpected
      FROM dbo.LOTxLOCxID WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND LOC = @cPickFromLoc
         AND LOT = @cLot
         AND ID = CASE WHEN @cLoseID = '1' THEN '' ELSE @cTaskToID END

      IF @nDebugFlag = 1
         SELECT 'Handle LLI QtyExpected', @nQtyExpected AS QtyExpected, @nShortQTY AS ShortQty, 
            @cPickFromLoc AS cPickFromLoc, @cLot AS Lot, @cLoseID AS LoseIDFlag, @cTaskToID AS TaskToID

      IF ISNULL(@nQtyExpected,0) > 0
      BEGIN
         IF @nQtyExpected <= @nShortQTY
         BEGIN
            BEGIN TRY
               UPDATE LOTxLOCxID WITH (ROWLOCK)
               SET
                  QtyExpected = 0
               WHERE StorerKey = @cStorerKey
                  AND LOC = @cPickFromLoc
                  AND LOT = @cLot
                  AND ID = CASE WHEN @cLoseID = '1' THEN '' ELSE @cTaskToID END
            END TRY
            BEGIN CATCH
               SET @nErrNo = 254153
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKD Fail
               GOTO RollBackTran
            END CATCH
         END --QtyExpected <= Qtyshort
         ELSE
         BEGIN
            BEGIN TRY
               UPDATE LOTxLOCxID WITH (ROWLOCK)
               SET
                  QtyExpected = @nQtyExpected - @nShortQTY
               WHERE StorerKey = @cStorerKey
                  AND LOC = @cPickFromLoc
                  AND LOT = @cLot
                  AND ID = CASE WHEN @cLoseID = '1' THEN '' ELSE @cTaskToID END
            END TRY
            BEGIN CATCH
               SET @nErrNo = 254154
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKD Fail
               GOTO RollBackTran
            END CATCH
         END
      END --QtyExpected > 0
   END -- full short
   ELSE
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Not support partial short reallo'

      IF @nDebugFlag = 2
      BEGIN
         INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2,
            Col1, Col2, Col3, Col4, Col5)
         VALUES ('1764CfmUpd07', GETDATE(), @CUsername, CAST(@nmobile AS NVARCHAR(10)),
            @cTaskDetailKey, '', '', '', 'PartialShort')
      END

      GOTO Reset_QtyReplen
   END --partial short

   --Call reallocation logic
   IF @cReasonCode <> ''
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Preparing reallo trigger'

      SELECT TOP 1
         @cWaveKey = WaveKey
      FROM dbo.TaskDetail TD WITH (NOLOCK)
      JOIN @tPickTaskList PTL
         ON TD.TaskDetailKey = PTL.TaskDetailKey

      IF ISNULL(@cSKU, '') = ''
      BEGIN
         SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
         SET @cErrMsg1 = '254155-SKUEmpty'
         SET @cErrMsg2 = 'Trigger reallocation fail '
         EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
         GOTO Reset_QtyReplen
      END

      IF ISNULL(@cUCCNo, '') = ''
      BEGIN
         SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
         SET @cErrMsg1 = '254156-UCCNoEmpty'
         SET @cErrMsg2 = 'Trigger reallocation fail '
         EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
         GOTO Reset_QtyReplen 
      END

      IF ISNULL(@cWaveKey, '') = ''
      BEGIN
         SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
         SET @cErrMsg1 = '254157-WaveKeyEmpty'
         SET @cErrMsg2 = 'Trigger reallocation fail '
         EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
         GOTO Reset_QtyReplen 
      END

      SELECT 
         @cAPP_DB_Name         = APP_DB_Name,
         @cDataStream          = DataStream,
         @nThreadPerAcct       = ThreadPerAcct,
         @nThreadPerStream     = ThreadPerStream,
         @nMilisecondDelay     = MilisecondDelay,
         @cIP                  = IP,
         @cPORT                = PORT,
         @cIniFilePath         = IniFilePath,
         @cCmdType             = CmdType,
         @cTaskType            = TaskType,
         @cExecStatements      = StoredProcName
      FROM dbo.QCmd_TransmitlogConfig WITH (NOLOCK)
      WHERE TableName = '1764ShortPickReallo'
         AND App_Name = 'WMS'
         AND StorerKey =  @cStorerKey

      IF @@ROWCOUNT <= 0
      BEGIN
         SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
         SET @cErrMsg1 = '254158-NoQcmdConfig'
         SET @cErrMsg2 = 'Trigger reallocation fail '
         EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
         GOTO Reset_QtyReplen 
      END

      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = LTRIM(RTRIM(@cExecStatements)) AND type = 'P')
      BEGIN
         SET @cExecStatements = 'EXEC ' + @cAPP_DB_Name + '.dbo.' + LTRIM(@cExecStatements)
                        + ' @c_Wavekey = ''' + @cWaveKey + ''''
                        + ', @c_SKU = ''' + @cSKU + ''''
                        + ', @c_UCCNo = ''' + @cUCCNo + ''''
                        + ', @c_TaskDetailKey = ''' + @cTaskDetailKey + ''''

         IF @nDebugFlag = 1
            SELECT 'Start to submit Qcmd', @cExecStatements

         IF @nDebugFlag = 2
            INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, 
                                    Col1, Col2, Col3, Col4, Col5)  
            VALUES ('1764CfmUpd07', GETDATE(), @cUserName, CAST(@nMobile AS NVARCHAR(10)),
                     @cTaskDetailKey,@cWaveKey, @cSKU, @cUCCNo, 'SubmitQcmd') 

         -- Submit task to QCommander
         BEGIN TRY
            EXEC isp_QCmd_SubmitTaskToQCommander
               @cTaskType           = 'O'        -- 'T' - TransmitlogKey, 'D' - Data Stream, 'O' - Other
               , @cStorerKey          = @cStorerKey
               , @cDataStream         = @cDataStream
               , @cCmdType            = @cCmdType 
               , @cCommand            = @cExecStatements
               , @cTransmitlogKey     = '' 
               , @nThreadPerAcct      = @nThreadPerAcct 
               , @nThreadPerStream    = @nThreadPerStream 
               , @nMilisecondDelay    = @nMilisecondDelay  
               , @nSeq                = 1
               , @cIP                 = @cIP
               , @cPORT               = @cPORT
               , @cIniFilePath        = @cIniFilePath
               , @cAPPDBName          = @cAPP_DB_Name
               , @bSuccess            = @bSuccess     OUTPUT 
               , @nErr                = @nErrNo       OUTPUT 
               , @cErrMsg             = @cErrMsg      OUTPUT
               , @nQueueID            = @nQueueID     OUTPUT
         END TRY
         BEGIN CATCH
            SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
            SET @cErrMsg3 = ERROR_MESSAGE()
            SET @cErrMsg1 = '254159-QcmdFail'
            SET @cErrMsg2 = 'Trigger reallocation fail '
            EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
            GOTO Reset_QtyReplen 
         END CATCH

         IF @nErrNo <> 0
         BEGIN
            SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
            SET @cErrMsg3 = 'Retrun err: ' + CAST(@nErrNo AS NVARCHAR(10))
            SET @cErrMsg1 = '254160-GenQcmdTaskFail'
            SET @cErrMsg2 = 'Trigger reallocation fail '
            EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
            GOTO Reset_QtyReplen 
         END
      END -- submit Qcmd
      ELSE
      BEGIN
         SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
         SET @cErrMsg1 = '254161-InvalidSPName'
         SET @cErrMsg2 = 'Trigger reallocation fail '
         EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
         GOTO Reset_QtyReplen 
      END

      IF @nDebugFlag = 1
         SELECT 'Submit Qcmd task successfully', @nQueueID AS QueueID
   END -- reallo

   Reset_QtyReplen:
   -- Reduce booking (when short)
   IF @cReasonCode <> '' -- Short
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Update FromLoc QtyRelen', @cLot AS Lot, @cFromLoc AS LOC, @cTaskFromID AS FromID

      BEGIN TRY
         UPDATE dbo.LOTxLOCxID WITH (ROWLOCK) SET
               QTYReplen = @nQty
         WHERE LOT = @cLOT
            AND LOC = @cFromLOC
            AND ID = @cTaskFromID
      END TRY
      BEGIN CATCH
         SET @nErrNo = 254162
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD LLI Fail
         GOTO RollBackTran
      END CATCH
   END

   GOTO Quit

   RollBackTran: -- If error, rollback the tran in rdt_TM_Replen_Confirm
      IF @nDebugFlag = 1
         SELECT 'RollbackTran', @nErrNo AS ErrNo

      IF @nTranCount > 0 AND @nErrNo <> 0
         ROLLBACK TRAN
      ELSE
         GOTO Quit

   Fail:
   Quit:
      IF @nDebugFlag = 1
         SELECT 'Quit', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg, @cErrMsg1 AS ErrMsg1
   --TM replen confirm will commit tran
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1764CfmExtUpd07 TO NSQL
GO
