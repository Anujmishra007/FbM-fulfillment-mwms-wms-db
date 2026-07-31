SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_1764CfmExtUpd10                                       */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date       Rev  Author                 Purposes                            */
/* 2026-07-31 1.0  sudhagani-sai-sreeja  FCR-14583 Auto short reallocation   */
/*                                        UOM=1 (full pallet) for PELURINDC   */
/******************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1764CfmExtUpd10
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR(3),
   @cTaskdetailKey      NVARCHAR(10),
   @cNewTaskDetailKey   NVARCHAR(10),
   @nErrNo              INT           OUTPUT,
   @cErrMsg             NVARCHAR(20)  OUTPUT
AS
BEGIN

DECLARE @nTranCount      INT
DECLARE @bSuccess        BIT
DECLARE @nDebugFlag      INT = 0
DECLARE @cUserName       NVARCHAR(128)

-- Task info
DECLARE @cStorerKey      NVARCHAR(15)
DECLARE @cFacility       NVARCHAR(5)
DECLARE @cFromLOC        NVARCHAR(10)
DECLARE @cFromID         NVARCHAR(18)
DECLARE @cToLoc          NVARCHAR(10)
DECLARE @cToID           NVARCHAR(18)
DECLARE @cLOT            NVARCHAR(10)
DECLARE @cSKU            NVARCHAR(30)
DECLARE @cUOM            NVARCHAR(5)
DECLARE @cCaseID         NVARCHAR(20)
DECLARE @cPickMethod     NVARCHAR(10)
DECLARE @cWaveKey        NVARCHAR(10)
DECLARE @cFinalLoc       NVARCHAR(10)
DECLARE @cReasonCode     NVARCHAR(10)
DECLARE @cTaskType       NVARCHAR(3)
DECLARE @nQTY_RPL        INT    -- replenishment qty (from MobRec V_Integer1)
DECLARE @nShortQTY       INT
DECLARE @nQtyExpected    INT
DECLARE @cPickFromLoc    NVARCHAR(10)
DECLARE @cLoseID         NVARCHAR(1)

-- CC task
DECLARE @cCCTaskDetailKey NVARCHAR(10)
DECLARE @cRCCycleCount    NVARCHAR(1)

-- Hold LOC
DECLARE @cLocHoldKey     NVARCHAR(20)

-- Msg queue
DECLARE @cErrMsg1        NVARCHAR(125)
DECLARE @cErrMsg2        NVARCHAR(125)
DECLARE @cErrMsg3        NVARCHAR(125)

-- QCommander async variables
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

-- Table variables for FCP task/PickDetail list
DECLARE @tPickTaskList TABLE (TaskDetailKey NVARCHAR(10))
DECLARE @tPickDetailList TABLE (PickDetailKey NVARCHAR(10))

SET @nTranCount = @@TRANCOUNT

-- ============================================================
-- SECTION 1: Read MobRec + TaskDetail
-- ============================================================

-- Read MobRec: StorerKey, Facility, replen qty
SELECT
   @cStorerKey = StorerKey,
   @cUserName  = UserName,
   @nQTY_RPL   = V_Integer1
FROM rdt.rdtMobRec WITH (NOLOCK)
WHERE Mobile = @nMobile

SELECT @cFacility = Facility
FROM rdt.rdtMobRec WITH (NOLOCK)
WHERE Mobile = @nMobile

-- Read TaskDetail
SELECT
   @cFromLOC     = FromLOC,
   @cFromID      = FromID,
   @cToLoc       = ToLoc,
   @cToID        = ToID,
   @cLOT         = LOT,
   @cSKU         = SKU,
   @cUOM         = UOM,
   @cCaseID      = CaseID,
   @cPickMethod  = PickMethod,
   @cWaveKey     = WaveKey,
   @cFinalLoc    = FinalLoc,
   @cReasonCode  = ReasonKey,
   @cTaskType    = TaskType
FROM dbo.TaskDetail WITH (NOLOCK)
WHERE TaskDetailKey = @cTaskdetailKey

IF @@ROWCOUNT = 0
BEGIN
   SET @nErrNo = 91001
   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
   GOTO Fail
END

-- ============================================================
-- SECTION 2: Guards
-- ============================================================

-- Guard 1: UOM=1 only (full pallet replenishment)
IF ISNULL(@cUOM, '') <> '1'
   GOTO Quit

-- Guard 2: Reason = 'EMPTY' only
IF ISNULL(@cReasonCode, '') <> 'EMPTY'
   GOTO Quit

-- ============================================================
-- SECTION 3: Read TASKMANAGERREASON for DoCycleCount
-- ============================================================

-- DoCycleCount flag indicates whether nspRFRSN01 already created a CC task
SELECT @cRCCycleCount = DoCycleCount
FROM dbo.TASKMANAGERREASON WITH (NOLOCK)
WHERE TaskManagerReasonKey = @cReasonCode

-- ============================================================
-- SECTION 4: BEGIN TRAN + SAVE TRAN
-- ============================================================

BEGIN TRAN
SAVE TRAN rdt_1764CfmExtUpd10

-- ============================================================
-- SECTION 5: CC Task Message01 update
-- ============================================================

-- Update Message01 on the CC task created by nspRFRSN01
IF ISNULL(@cRCCycleCount, '') = '1'
BEGIN
   -- Find the most recently created CC task for this StorerKey + FromLOC
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
         SET    Message01 = 'CC for shorting on the location'
         WHERE  TaskDetailKey = @cCCTaskDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 91002
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END CATCH
   END
END

-- ============================================================
-- SECTION 6: Hold LOC
-- ============================================================

-- Read hold key from StorerConfig
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
           ''              -- lot (blank = whole LOC)
         , @cFromLOC       -- loc
         , ''              -- ID (blank = whole LOC)
         , @cLocHoldKey    -- hold key
         , '1'             -- hold flag (1=hold)
         , @bSuccess  OUTPUT
         , @nErrNo    OUTPUT
         , @cErrMsg   OUTPUT

      IF @bSuccess <> 1 OR @nErrNo <> 0
      BEGIN
         IF @nErrNo = 0
            SET @nErrNo = 91003
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END
   END TRY
   BEGIN CATCH
      SET @nErrNo = 91004
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
      GOTO RollBackTran
   END CATCH
END

-- ============================================================
-- SECTION 7: PickDetail identification and update
-- ============================================================

-- Find related FCP tasks: FCP.FromLoc = RPF.FinalLoc (or ToLoc if FinalLoc is empty)
INSERT INTO @tPickTaskList (TaskDetailKey)
   SELECT TD1.TaskDetailKey
   FROM dbo.TaskDetail TD1 WITH (NOLOCK)
   JOIN dbo.TaskDetail TD2 WITH (NOLOCK)
      ON  TD1.Storerkey = TD2.Storerkey
      AND (
           (ISNULL(TD2.FinalLOC, '') <> '' AND TD2.FinalLOC = TD1.FromLoc)
        OR (ISNULL(TD2.FinalLOC, '') = ''  AND TD2.ToLoc = TD1.FromLoc)
          )
      AND TD1.Status   = 'H'
      AND TD1.TaskType = 'FCP'
   WHERE TD2.Storerkey     = @cStorerKey
     AND TD2.TaskDetailKey = @cTaskdetailKey

IF EXISTS (SELECT 1 FROM @tPickTaskList)
BEGIN
   -- Get related PickDetail rows
   INSERT INTO @tPickDetailList (PickDetailKey)
      SELECT PKD.PickDetailKey
      FROM dbo.PickDetail PKD WITH (NOLOCK)
      JOIN @tPickTaskList PTL ON PKD.TaskDetailKey = PTL.TaskDetailKey
      WHERE PKD.Status = '0'

   -- UOM=1 is always full short — set Qty=0 and Status=4 (shorted)
   IF EXISTS (SELECT 1 FROM @tPickDetailList)
   BEGIN
      BEGIN TRY
         UPDATE PKD WITH (ROWLOCK)
         SET    PKD.Qty    = 0,
                PKD.Status = '4'
         FROM   dbo.PickDetail PKD
         JOIN   @tPickDetailList PTL ON PKD.PickDetailKey = PTL.PickDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 91005
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END CATCH
   END
END

-- ============================================================
-- SECTION 8: LOTxLOCxID.QtyExpected update (pick face)
-- ============================================================

-- Reduce QtyExpected on the pick face (RPF FinalLoc or ToLoc)
IF ISNULL(@cFinalLoc, '') <> ''
   SET @cPickFromLoc = @cFinalLoc
ELSE
   SET @cPickFromLoc = @cToLoc

SELECT @cLoseID = LoseID
FROM dbo.Loc WITH (NOLOCK)
WHERE Loc = @cPickFromLoc

SELECT @nQtyExpected = QtyExpected
FROM dbo.LOTxLOCxID WITH (NOLOCK)
WHERE StorerKey = @cStorerKey
  AND LOC       = @cPickFromLoc
  AND LOT       = @cLot
  AND ID        = CASE WHEN @cLoseID = '1' THEN '' ELSE @cToID END

IF ISNULL(@nQtyExpected, 0) > 0
BEGIN
   BEGIN TRY
      UPDATE dbo.LOTxLOCxID WITH (ROWLOCK)
      SET    QtyExpected = 0
      WHERE  StorerKey = @cStorerKey
        AND  LOC       = @cPickFromLoc
        AND  LOT       = @cLot
        AND  ID        = CASE WHEN @cLoseID = '1' THEN '' ELSE @cToID END
   END TRY
   BEGIN CATCH
      SET @nErrNo = 91006
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
      GOTO RollBackTran
   END CATCH
END

-- ============================================================
-- SECTION 9: LOTxLOCxID.QTYReplen update (source LOC — reduce booking)
-- ============================================================

-- Reduce replenishment booking on source LOC
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
   SET @nErrNo = 91006
   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
   GOTO RollBackTran
END CATCH

-- ============================================================
-- SECTION 10: COMMIT TRAN (own savepoint) — BEFORE QCommander
-- ============================================================

-- Per template Key Note 2: QCommander must be called AFTER own transaction commits
COMMIT TRAN rdt_1764CfmExtUpd10

-- ============================================================
-- SECTION 11: QCommander async call
-- ============================================================

-- Read QCommander config
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

IF @@ROWCOUNT <= 0
BEGIN
   SELECT @cErrMsg1='', @cErrMsg2='', @cErrMsg3=''
   SET @cErrMsg1 = '91007-NoQcmdConfig'
   SET @cErrMsg2 = 'Trigger reallocation fail'
   EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
   GOTO Quit
END

IF ISNULL(@cSKU, '') = ''
BEGIN
   SELECT @cErrMsg1='', @cErrMsg2='', @cErrMsg3=''
   SET @cErrMsg1 = '91007-SKUEmpty'
   SET @cErrMsg2 = 'Trigger reallocation fail'
   EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
   GOTO Quit
END

IF ISNULL(@cCaseID, '') = ''
BEGIN
   SELECT @cErrMsg1='', @cErrMsg2='', @cErrMsg3=''
   SET @cErrMsg1 = '91007-UCCNoEmpty'
   SET @cErrMsg2 = 'Trigger reallocation fail'
   EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
   GOTO Quit
END

IF EXISTS (SELECT 1 FROM dbo.sysobjects WITH (NOLOCK) WHERE name = LTRIM(RTRIM(@cExecStatements)) AND type = 'P')
BEGIN
   SET @cExecStatements = 'EXEC ' + @cAPP_DB_Name + '.dbo.' + LTRIM(@cExecStatements)
                        + ' @c_Wavekey        = ''' + ISNULL(@cWaveKey, '') + ''''
                        + ', @c_SKU           = ''' + @cSKU + ''''
                        + ', @c_UCCNo         = ''' + @cCaseID + ''''
                        + ', @c_TaskDetailKey = ''' + @cTaskdetailKey + ''''

   BEGIN TRY
      DECLARE @bQCmdSuccess BIT
      DECLARE @nQueueID     INT
      EXEC isp_QCmd_SubmitTaskToQCommander
           @cTaskType        = 'O'
         , @cStorerKey       = @cStorerKey
         , @cDataStream      = @cDataStream
         , @cCmdType         = @cCmdType
         , @cCommand         = @cExecStatements
         , @cTransmitlogKey  = @cTaskdetailKey
         , @nThreadPerAcct   = @nThreadPerAcct
         , @nThreadPerStream = @nThreadPerStream
         , @nMilisecondDelay = @nMilisecondDelay
         , @nSeq             = 1
         , @cIP              = @cIP
         , @cPORT            = @cPORT
         , @cIniFilePath     = @cIniFilePath
         , @cAPPDBName       = @cAPP_DB_Name
         , @bSuccess         = @bQCmdSuccess OUTPUT
         , @nErr             = @nErrNo       OUTPUT
         , @cErrMsg          = @cErrMsg      OUTPUT
         , @nQueueID         = @nQueueID     OUTPUT
   END TRY
   BEGIN CATCH
      SELECT @cErrMsg1='', @cErrMsg2='', @cErrMsg3=''
      SET @cErrMsg3 = ERROR_MESSAGE()
      SET @cErrMsg1 = '91008-QcmdFail'
      SET @cErrMsg2 = 'Trigger reallocation fail'
      EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
      GOTO Quit
   END CATCH

   IF @nErrNo <> 0
   BEGIN
      SELECT @cErrMsg1='', @cErrMsg2='', @cErrMsg3=''
      SET @cErrMsg3 = 'Return err: ' + TRY_CAST(@nErrNo AS NVARCHAR(10))
      SET @cErrMsg1 = '91008-GenQcmdTaskFail'
      SET @cErrMsg2 = 'Trigger reallocation fail'
      EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
      GOTO Quit
   END
END
ELSE
BEGIN
   SELECT @cErrMsg1='', @cErrMsg2='', @cErrMsg3=''
   SET @cErrMsg1 = '91008-InvalidSPName'
   SET @cErrMsg2 = 'Trigger reallocation fail'
   EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
   GOTO Quit
END

-- ============================================================
-- SECTION 12: Error handling labels
-- ============================================================

GOTO Quit

CommitTran:
   COMMIT TRAN rdt_1764CfmExtUpd10
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1764CfmExtUpd10
Fail:
   SET @nErrNo = ISNULL(NULLIF(@nErrNo, 0), 91009)
   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1764CfmExtUpd10 TO NSQL
GO
