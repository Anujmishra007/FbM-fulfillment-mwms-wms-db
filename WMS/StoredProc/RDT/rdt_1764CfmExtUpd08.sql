
/************************************************************************/
/* Store procedure: rdt_1764CfmExtUpd08                                 */
/* Customer: UK Columbia                                                */
/*                                                                      */
/*                                                                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.    Purposes                              */
/* 2026-01-13   Jackc     1.0.0   FCR-10031 Created                     */
/* 2026-03-04   Jackc     1.0.1   FCR-10031 V1.5 Update PKD to 5        */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1764CfmExtUpd08
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
   DECLARE @cUserName      NVARCHAR(128)

   DECLARE @bSuccess                INT
   DECLARE @nQTY                    INT
   DECLARE @nQTY_RPL                INT
   DECLARE @nOrgTaskQty             INT
   DECLARE @nOrgSystemQTY           INT
   DECLARE @nPickQTY                INT
   DECLARE @nShortQTY               INT
   DECLARE @cReasonCode             NVARCHAR(10)
   DECLARE @cTMTaskType             NVARCHAR(10)
   DECLARE @cPickMethod             NVARCHAR(10)
   DECLARE @cLOT                    NVARCHAR(10)
   DECLARE @cFromLOC                NVARCHAR(10)
   DECLARE @cToLoc                  NVARCHAR(10)
   DECLARE @cTaskFromID             NVARCHAR(18)
   DECLARE @cTaskToID               NVARCHAR(18)
   DECLARE @cStorerKey              NVARCHAR(15)
   DECLARE @cFinalLoc               NVARCHAR(10) = ''
   DECLARE @cSKU                    NVARCHAR(30)
   DECLARE @cWavekey                NVARCHAR(10)
   DECLARE @cUCCNo                  NVARCHAR(20)
   DECLARE @cTaskUOM                NVARCHAR(5)
   DECLARE @cRealloFlag             NVARCHAR(1)
   DECLARE @cUpdPKDFlag             NVARCHAR(1)
   DECLARE @cTaskMsg02              NVARCHAR(20)
   DECLARE @cRealloNumberofRetry    NVARCHAR(5)
   DECLARE @nRealloNumberofRetry    INT
   DECLARE @nRealloCounter          INT
   DECLARE @nOrderCnt               INT
   DECLARE @cFinalLOCPAZone         NVARCHAR(10) = ''

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
      @cExecStatements           NVARCHAR(MAX)

   DECLARE
      @cErrMsg1      NVARCHAR(125),
      @cErrMsg2      NVARCHAR(125),
      @cErrMsg3      NVARCHAR(125)

   DECLARE @tPickDetailList TABLE
   (
      PickDetailKey  NVARCHAR(10)
   )

   DECLARE @nTranCount  INT
   SET @nTranCount = @@TRANCOUNT

   
   --RPLEN is UCC level. So it is full short only. @nQty always 0

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
      SELECT 'Executing 1764CfmExtUpd08', @cTaskDetailKey AS OrgTask, @cNewTaskDetailKey AS NewTask,
         @nQTY_RPL AS ExpectedQty, @nQTY AS ActualQty

   -- Get orginal task info
   SELECT 
      @cTMTaskType   = TaskType,
      @cPickMethod   = PickMethod, 
      @cReasonCode   = ReasonKey,
      @cSKU          = SKU, 
      @cLOT          = LOT,
      @cTaskUOM      = UOM, 
      @cFromLOC      = FromLOC, 
      @cTaskFromID   = FromID,
      @cToLoc        = ToLoc,
      @cTaskToID     = ToID,
      @cUCCNo        = Caseid,
      @cFinalLoc     = FinalLoc, 
      @nOrgSystemQTY = SystemQTY,
      @cTaskMsg02    = Message02,
      @nOrgTaskQty   = @nQTY_RPL, -- QTY for PickDetail
      @nShortQTY     = @nQTY_RPL - @nQTY
   FROM dbo.TaskDetail WITH (NOLOCK) 
   WHERE TaskDetailKey = @cTaskdetailKey

   -- FP, does not close pallet or short
   IF @cPickMethod = 'FP'
      RETURN

   --not short
   --V1.0.1
   --IF ISNULL(@cReasonCode, '') = ''
      --RETURN

   IF @cTMTaskType <> 'RPF'
      RETURN

   SET @cRealloFlag = '1'
   SET @cUpdPKDFlag = '1'

   --Get related pickdetail
   INSERT INTO @tPickDetailList (PickDetailKey)
      SELECT PickDetailKey
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE Storerkey = @cStorerKey
         AND Status = '0'
         AND DropID = @cUCCNo

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'RPF related pkd'
      SELECT * FROM @tPickDetailList
   END

   IF NOT EXISTS (SELECT 1 FROM @tPickDetailList) -- rpf with out PKD data
   BEGIN
      SET @cRealloFlag = '0' -- If not pkd rpf, not to trigger reallo
      SET @cUpdPKDFlag = '0' -- if rpf only, not to update pkd

      IF @nDebugFlag = 1
         SELECT 'No Picking detail, RPF only', @cRealloFlag AS RealloFlag, @cUpdPKDFlag AS UpdPKDFlag

      IF @nDebugFlag = 2
      BEGIN
         INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2,
            Col1, Col2, Col3, Col4, Col5)
         VALUES ('1764CfmUpd08', GETDATE(), @cUserName, CAST(@nMobile AS NVARCHAR(10)),
            @cTaskDetailKey, @cRealloFlag, @cUpdPKDFlag, '', 'NoPickDetl')
      END
   END -- PickDetail not found

   --V.1.0.1 start
   IF @cReasonCode = '' AND @nQty <> 0 -- normal picking
   BEGIN
      SET @cRealloFlag = '0'  --Not short, no need reallocation

      SELECT @nPickQty = ISNULL(SUM(Qty), 0), @nOrderCnt = ISNULL(COUNT(DISTINCT OrderKey), 0)
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND DropID = @cUCCNo

      SELECT @cFinalLOCPAZone = PutawayZone FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cFinalLOC

      IF @nPickQty = @nQTY AND @nOrderCnt = 1 AND @cFinalLOCPAZone IN ('CSCPACK', 'CSCCNVYR')
         SET @cUpdPKDFlag = '1'
      ELSE
         SET @cUpdPKDFlag = '0'

      IF @nDebugFlag = 1
         SELECT 'Normal picking', @cRealloFlag AS RealloFalg, @cUpdPKDFlag AS UpdPKDFlag,
            @cUCCNo AS UCC, @nPickQTY AS UCCPickQty, @cFinalLOCPAZone AS FinalPAZone
      
      IF @nDebugFlag = 2 AND @cUpdPKDFlag = '0'
      BEGIN
         INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2,
            Col1, Col2, Col3, Col4, Col5)
         VALUES ('1764CfmUpd08', GETDATE(), @cUserName, CAST(@nMobile AS NVARCHAR(10)),
            @cTaskDetailKey, @cRealloFlag, @cUpdPKDFlag, '', 'RsnCodeEmpty')
      END
   END
   --V.1.0.1 end

   IF @cUpdPKDFlag = '1' -- update pkd
   BEGIN
      -- Mark PickDetail as short, update Qty qty
      IF @nQTY = 0
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Short PKD'

         IF @nDebugFlag = 2
         BEGIN
            INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2,
               Col1, Col2, Col3, Col4, Col5)
            SELECT
               '1764CfmUpd08',
               GETDATE(),
               @cUserName,
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
               PKD.Status = '4',
               PKD.QtyMoved = PKD.Qty
            FROM dbo.PickDetail PKD
            JOIN @tPickDetailList PTL
               ON PKD.PickDetailKey = PTL.PickDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 256301
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKD Fail
            GOTO RollBackTran
         END CATCH

         --No need to handle task, reallo will do
      END -- full short
      ELSE IF @cReasonCode = '' --Normal picking, set pkd to 5
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Normal picking, set pkd to 5'

         IF @nDebugFlag = 2
         BEGIN
            INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2,
               Col1, Col2, Col3, Col4, Col5)
            SELECT
               '1764CfmUpd08',
               GETDATE(),
               @cUserName,
               CAST(@nMobile AS NVARCHAR(10)),
               @cTaskDetailKey,
               PKD.PickDetailKey,
               @cUCCNo,
               '',
               'SetPKDtoPick'
            FROM dbo.PickDetail PKD
            JOIN @tPickDetailList PTL
               ON PKD.PickDetailKey = PTL.PickDetailKey
         END

         BEGIN TRY
            UPDATE PKD WITH (ROWLOCK)
            SET
               PKD.Status = '5'
            FROM dbo.PickDetail PKD
            JOIN @tPickDetailList PTL
               ON PKD.PickDetailKey = PTL.PickDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 256312
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKD Fail
            GOTO RollBackTran
         END CATCH
      END--Normal Picking
      ELSE
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Not support partial short reallo'

         IF @nDebugFlag = 2
         BEGIN
            INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2,
               Col1, Col2, Col3, Col4, Col5)
            VALUES ('1764CfmUpd08', GETDATE(), @cUserName, CAST(@nMobile AS NVARCHAR(10)),
               @cTaskDetailKey, CAST (@nQty AS NVARCHAR(4)), '', '', 'PartialShort')
         END

         SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
         SET @cErrMsg1 = '256302-NotSupportPartialShort'
         SET @cErrMsg2 = 'Reallo is not triggered'
         EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3

         BEGIN TRY
         UPDATE dbo.LOTxLOCxID WITH (ROWLOCK) SET
               QTYReplen = CASE WHEN (QTYReplen - @nQty) > 0 THEN (QTYReplen - @nQTY) ELSE 0 END
         WHERE LOT = @cLOT
            AND LOC = @cFromLOC
            AND ID = @cTaskFromID
         END TRY
         BEGIN CATCH
            SET @nErrNo = 256303
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD LLI Fail
            GOTO RollBackTran
         END CATCH

         GOTO Quit
      END --partial short
   END

   --RealloNumberOfRetry check
   SET @cRealloNumberofRetry = rdt.RDTGetConfig( @nFunc, 'RealloNumberofRetry', @cStorerKey)
   IF LEN(@cTaskMsg02) > 4 AND LEFT(@cTaskMsg02,4) = 'SKIP'
      SET @nRealloCounter = ISNULL(TRY_CAST( RIGHT(@cTaskMsg02, LEN(@cTaskMsg02) - 4 ) AS INT), -1)
   ELSE
      SET @nRealloCounter = 0

   SET @nRealloNumberofRetry = ISNULL(TRY_CAST( @cRealloNumberofRetry AS INT), 0)

   IF @nRealloCounter < 0 OR @nRealloCounter > @nRealloNumberofRetry
   BEGIN
      SET @cRealloFlag = '0'

      IF @nDebugFlag = 1
         SELECT 'RealloNumberOfRetry check fail', @cTaskMsg02 AS cTaskMsg02, @cRealloNumberofRetry AS RealloNumberOfRetry
   END

   --Call reallocation logic
   IF @cRealloFlag = '1'
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Preparing reallo trigger'

      SELECT TOP 1
         @cWaveKey = WaveKey
      FROM dbo.PickDetail PKD WITH (NOLOCK)
      JOIN @tPickDetailList PTL
         ON PKD.PickDetailKey = PTL.PickDetailKey

      IF ISNULL(@cSKU, '') = ''
      BEGIN
         SET @nErrNo = 256304
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END

      IF ISNULL(@cUCCNo, '') = ''
      BEGIN
         SET @nErrNo = 256305
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END

      IF ISNULL(@cWaveKey, '') = '' --wavekey is required
      BEGIN
         SET @nErrNo = 256306
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
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
         @cExecStatements      = StoredProcName
      FROM dbo.QCmd_TransmitlogConfig WITH (NOLOCK)
      WHERE TableName = '1764ShortPickReallo'
         AND App_Name = 'WMS'
         AND StorerKey =  @cStorerKey

      IF @@ROWCOUNT <= 0
      BEGIN
         SET @nErrNo = 256307
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END

      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = LTRIM(RTRIM(@cExecStatements)) AND type = 'P')
      BEGIN
         SET @cExecStatements = 'EXEC ' + @cAPP_DB_Name + '.dbo.' + LTRIM(@cExecStatements)
                        + ' @c_Wavekey = ''' + ISNULL(@cWaveKey,'') + ''''
                        + ', @c_SKU = ''' + @cSKU + ''''
                        + ', @c_UCCNo = ''' + @cUCCNo + ''''
                        + ', @c_TaskDetailKey = ''' + @cTaskDetailKey + ''''

         IF @nDebugFlag = 1
            SELECT 'Start to submit Qcmd', @cExecStatements

         IF @nDebugFlag = 2
            INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, 
                                    Col1, Col2, Col3, Col4, Col5)  
            VALUES ('1764CfmUpd08', GETDATE(), @cUserName, CAST(@nMobile AS NVARCHAR(10)),
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
            SET @nErrNo = 256308
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
            GOTO RollBackTran
         END CATCH

         IF @nErrNo <> 0
         BEGIN
            GOTO RollBackTran
         END
      END -- submit Qcmd
      ELSE
      BEGIN
         SET @nErrNo = 256310
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END

      IF @nDebugFlag = 1
         SELECT 'Submit Qcmd task successfully', @nQueueID AS QueueID
   END -- reallo

   Reset_QtyReplen:
   -- Reduce booking (when short)
   IF @cReasonCode <> '' -- Short
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Update FromLoc QtyReplen', @cLOT AS Lot, @cFromLoc AS LOC, @cTaskFromID AS FromID

      BEGIN TRY
         UPDATE dbo.LOTxLOCxID WITH (ROWLOCK) SET
               QTYReplen = CASE WHEN (QTYReplen - @nQTY_RPL) > 0 THEN (QTYReplen - @nQTY_RPL) ELSE 0 END
         WHERE LOT = @cLOT
            AND LOC = @cFromLOC
            AND ID = @cTaskFromID
      END TRY
      BEGIN CATCH
         SET @nErrNo = 256311
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

GRANT EXECUTE ON rdt.rdt_1764CfmExtUpd08 TO NSQL
GO
