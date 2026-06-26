
/************************************************************************/
/* Store procedure: rdt_1764CfmExtUpd09                                 */
/* Copyright      : Maersk                                              */
/* Customer       : AMERICAN EAGLE                                      */
/*                                                                      */
/*                                                                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2026-01-16   NickT     1.0   FCR-12990 Created                       */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1764CfmExtUpd09
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

   DECLARE
      @cStorerKey                NVARCHAR(15),
      @cShortCode                NVARCHAR(10) = 'SHORTAEOMX',
      @cLocHoldKey               NVARCHAR(10),
      @cFromLOC                  NVARCHAR(10),
      @cPickMethod               NVARCHAR(10),
      @cSKU                      NVARCHAR(20),
      @cUserName                 NVARCHAR(128),
      @nRowCount                 INT,
      @nTranCount                INT,
      @bSuccess                  INT,

      @cAPP_DB_Name              NVARCHAR(20),
      @cDataStream               VARCHAR(10),
      @nThreadPerAcct            INT,
      @nThreadPerStream          INT,
      @nMilisecondDelay          INT,
      @cIP                       NVARCHAR(20),
      @cPORT                     NVARCHAR(5),
      @cIniFilePath              NVARCHAR(200),
      @cCmdType                  NVARCHAR(10),
      @cTaskType                 NVARCHAR(1),
      @cTaskDetailFinalLoc          NVARCHAR(10),
      @cExecStatements           NVARCHAR(MAX),
      @cExecArguments            NVARCHAR(MAX)

   DECLARE @tTaskDetails TABLE (
      RowRef INT IDENTITY(1,1),
      TaskDetailKey NVARCHAR(10) PRIMARY KEY
   )

   SELECT @cUserName = UserName
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SET @nTranCount = @@TRANCOUNT

   SELECT
      @cLocHoldKey = LocHoldKey
   FROM dbo.TASKMANAGERREASON WITH (NOLOCK)
   WHERE TaskManagerReasonKey = @cShortCode

   SELECT 
      @cFromLOC = FromLoc,
      @cPickMethod = PickMethod,
      @cTaskDetailFinalLoc = FinalLoc,
      @cStorerKey = StorerKey,
      @cSKU = SKU
   FROM dbo.TaskDetail WITH(NOLOCK)
   WHERE TaskDetailKey = @cTaskdetailKey
      AND TaskType = 'RPF'
      AND Status = '5'
      AND ReasonKey = @cShortCode
   SELECT @nRowCount = @@ROWCOUNT

   IF @nRowCount = 0
      GOTO QUIT

   -- Short happens, perform below actions
   -- 1. HOLD from Location
   -- 2. Generate CC Task, code change is no needed, setup TASKMANAGERREASON.DoCycleCount = 1
   -- 3. Call re-allocation SP
   -- 4. Delete FCP TaskDetails which is ON HOLD and FromLoc = @cTaskDetailFinalLoc and SKU = @cSKU, mark the PickDetail as SHORT

   IF @nTranCount = 0
      BEGIN TRANSACTION
   ELSE
      SAVE TRANSACTION rdt_1764CfmExtUpd09

   -- 1. HOLD LOC
   IF NOT EXISTS (SELECT 1 FROM dbo.INVENTORYHOLD WITH (NOLOCK) WHERE Loc = @cFromLOC AND Hold = '1')
   BEGIN
      IF ISNULL(@cLocHoldKey, '') = ''
         SET @cLocHoldKey = 'HOLD'

      BEGIN TRY
         EXECUTE dbo.nspInventoryHold
            ''          --lot
            , @cFromLOC --loc
            , ''        --ID
            , @cLocHoldKey -- status
            , '1'
            , @bSuccess OUTPUT
            , @nErrNo OUTPUT
            , @cErrMsg OUTPUT

            IF @bSuccess <> 1 OR @nErrNo <> 0
            BEGIN
               IF @nErrNo = 0
                  SET @nErrNo = 270351

               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Hold loc fail

               GOTO ROLLBACK_TRAN
            END
      END TRY
      BEGIN CATCH
         SET @nErrNo = 270353
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Execute InvHold fail
         GOTO ROLLBACK_TRAN
      END CATCH
   END

   -- 3.1 Delete FCP TaskDetails which is ON HOLD and FromLoc = @cTaskDetailFinalLoc and SKU = @cSKU
   DELETE FROM @tTaskDetails
   INSERT INTO @tTaskDetails (TaskDetailKey)
   SELECT TaskDetailKey
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND FromLoc = @cTaskDetailFinalLoc
      AND TaskType = 'FCP'
      AND Status = 'H'
      AND SKU = @cSKU

   BEGIN TRY
      DELETE TD WITH(ROWLOCK)
      FROM dbo.TaskDetail TD
      INNER JOIN @tTaskDetails TTD ON TD.TaskDetailKey = TTD.TaskDetailKey
   END TRY
   BEGIN CATCH
      SET @nErrNo = 270354
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Delete short FCP TaskDetails fail
      GOTO ROLLBACK_TRAN
   END CATCH

   --3.2 Mark the PickDetail as SHORT
   BEGIN TRY
      UPDATE PD WITH(ROWLOCK)
      SET 
         Status = '4',
         QtyMoved = Qty,
         Qty = 0,
         EditDate = GETDATE(),
         EditWho = @cUserName
      FROM dbo.PickDetail PD
      INNER JOIN @tTaskDetails TTD ON PD.TaskDetailKey = TTD.TaskDetailKey
   END TRY
   BEGIN CATCH
      SET @nErrNo = 270355
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Mark PickDetail as SHORT fail
      GOTO ROLLBACK_TRAN
   END CATCH

   -- 4. Call re-allocation SP
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
   WHERE TableName = 'SHORTRPF'
      AND App_Name = 'WMS'
      AND  StorerKey =  @cStorerKey

   SELECT @nRowCount = @@ROWCOUNT

   IF @nRowCount = 0
   BEGIN
      SET @nErrNo = 270356
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No reallocation QCommander Config
      GOTO ROLLBACK_TRAN
   END

   SET @cExecStatements = 'EXEC ' + @cAPP_DB_Name + '.dbo.' + LTRIM(@cExecStatements)
                        + ' @c_TaskDetailKey = ''' + @cTaskDetailKey + ''''

   -- Submit task to QCommander
   BEGIN TRY
      EXEC isp_QCmd_SubmitTaskToQCommander
            @cTaskType           = 'O'                  -- -- D=By Datastream, T=Transmitlog, O=Others
         , @cStorerKey          = @cStorerKey
         , @cDataStream         = @cDataStream
         , @cCmdType            = @cCmdType 
         , @cCommand            = @cExecStatements
         , @cTransmitlogKey     = @cTaskDetailKey 
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
   END TRY
   BEGIN CATCH
      SET @nErrNo = 270352
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Submit QCommanderTask Failed
      GOTO ROLLBACK_TRAN
   END CATCH

   IF @nErrNo <> 0
      GOTO ROLLBACK_TRAN

   IF @@TRANCOUNT > @nTranCount
   BEGIN
      IF XACT_STATE() = 1
         COMMIT TRANSACTION
   END
   GOTO QUIT

   ROLLBACK_TRAN:
   IF @nTranCount = 0
   BEGIN
      ROLLBACK TRANSACTION
   END
   ELSE
   BEGIN
      IF XACT_STATE() <> -1
         ROLLBACK TRANSACTION rdt_1764CfmExtUpd09
      ELSE
         ROLLBACK TRANSACTION 
   END

   QUIT:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1764CfmExtUpd09 TO NSQL
GO
