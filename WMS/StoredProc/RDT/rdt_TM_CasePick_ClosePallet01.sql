
/************************************************************************/
/* Store procedure: rdt_TM_CasePick_ClosePallet01                       */
/* Copyright      : Maersk                                              */
/* Customer       : Unilever                                            */
/*                                                                      */
/* Purpose: Confirm pick                                                */
/*                                                                      */
/* Date        Rev  Author    Purposes                                  */
/* 25-Oct-2024 1.0  YYS027    FCR-989 Created from                      */
/*                            v1.4 rdt_TM_CasePick_ClosePallet to       */
 /*                           trigger new replenishment                 */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_TM_CasePick_ClosePallet01] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR(3),
   @cUserName      NVARCHAR(18),
   @cListKey       NVARCHAR(10),
   @nErrNo         INT          OUTPUT,
   @cErrMsg        NVARCHAR(20) OUTPUT  -- screen limitation, 20 char max
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount     INT
   DECLARE @cSQL           NVARCHAR(MAX)
   DECLARE @cSQLParam      NVARCHAR(MAX)

   DECLARE @cClosePalletSP NVARCHAR(20)
   DECLARE @cReplenFlag    NVARCHAR(20)
   DECLARE @cStorerKey     NVARCHAR( 15)
   DECLARE @cSKU           NVARCHAR( 20)
   DECLARE @cFromLOC       NVARCHAR( 10)
   DECLARE @cFacility      NVARCHAR( 5)
   DECLARE @b_Success      INT
   DECLARE @bDebug         INT = 0

   -- Get storer
   SELECT TOP 1 
      @cStorerKey = StorerKey
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE ListKey = @cListKey
      AND UserKey = @cUserName
      AND Status = '5' -- 3=Fetch, 5=Picked, 9=Complete
   ORDER BY TaskDetailKey   
/*
   -- Get storer config
   SET @cClosePalletSP = rdt.rdtGetConfig( @nFunc, 'ClosePalletSP', @cStorerKey)
   IF @cClosePalletSP = '0'
      SET @cClosePalletSP = ''

   -- Get storer config
   SET @cReplenFlag = rdt.rdtGetConfig( @nFunc, 'ReplenFlag', @cStorerKey)
   IF @cReplenFlag = '0'
      SET @cReplenFlag = ''

   SET @nTranCount = @@TRANCOUNT
   
   /***********************************************************************************************
                                          Custom close pallet
   ***********************************************************************************************/
   IF @cClosePalletSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cClosePalletSP AND type = 'P')
      BEGIN
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cClosePalletSP) +
            ' @nMobile, @nFunc, @cLangCode, @cUserName, @cListKey, @nErrNo OUTPUT, @cErrMsg OUTPUT '
         SET @cSQLParam =
            '@nMobile   INT,           ' +
            '@nFunc     INT,           ' +
            '@cLangCode NVARCHAR( 3),  ' +
            '@cUserName NVARCHAR(18),  ' +
            '@cListKey  NVARCHAR( 10), ' +
            '@nErrNo    INT           OUTPUT, ' +
            '@cErrMsg   NVARCHAR( 20) OUTPUT  ' 

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, @cUserName, @cListKey, @nErrNo OUTPUT, @cErrMsg OUTPUT

         GOTO REPLEN_TASK
      END
   END
*/
   /***********************************************************************************************
                                          Standard close pallet
   ***********************************************************************************************/
   DECLARE @cTaskDetailKey NVARCHAR( 10)
   DECLARE @cPickMethod    NVARCHAR( 10)
   DECLARE @cWaveKey       NVARCHAR( 10)
   DECLARE @cToLOC         NVARCHAR( 10)
   DECLARE @cFromID        NVARCHAR( 18)
   DECLARE @cToID          NVARCHAR( 18)
   DECLARE @cLOT           NVARCHAR( 10)
   DECLARE @cUCCNo         NVARCHAR( 20)
   DECLARE @cPickConfirmStatus NVARCHAR( 1)
   DECLARE @cMoveQTYAlloc  NVARCHAR( 1)
   DECLARE @cMoveQTYPick   NVARCHAR( 1)
   DECLARE @nQTYAlloc      INT
   DECLARE @nQTYPick       INT
   DECLARE @nQTY           INT
   DECLARE @nSystemQTY     INT
   DECLARE @nUCCQTY        INT

   -- Init var
   SET @nErrNo = 0
   SET @cErrMsg = ''

   -- Handling transaction
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_TM_CasePick_ClosePallet01 -- For rollback or commit only our own transaction

   -- Loop tasks
   DECLARE @curRPTask CURSOR
   SET @curRPTask = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
      SELECT TaskDetailKey, PickMethod, StorerKey, FromLOC, FromID, ToLOC, ToID, SKU, LOT, QTY, SystemQTY, WaveKey
      FROM dbo.TaskDetail WITH (NOLOCK)
      WHERE ListKey = @cListKey
         AND UserKey = @cUserName
         AND Status = '5' -- 3=Fetch, 5=Picked, 9=Complete
      ORDER BY TaskDetailKey
   OPEN @curRPTask
   FETCH NEXT FROM @curRPTask INTO @cTaskDetailKey, @cPickMethod, @cStorerKey, @cFromLOC, @cFromID, @cToLOC, @cToID, @cSKU, @cLOT, @nQTY, @nSystemQTY, @cWaveKey
   WHILE @@FETCH_STATUS = 0
   BEGIN
      SET @cMoveQTYAlloc = rdt.RDTGetConfig( @nFunc, 'MoveQTYAlloc', @cStorerKey)
      SET @cMoveQTYPick = rdt.RDTGetConfig( @nFunc, 'MoveQTYPick', @cStorerKey)
      SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
      IF @cPickConfirmStatus = '0'
         SET @cPickConfirmStatus = '5'
   
      -- Check move alloc, but picked
      IF @cMoveQTYAlloc = '1' AND @cPickConfirmStatus = '5'
      BEGIN
         SET @nErrNo = 51153
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --IncorrectSetup
         GOTO RollBackTran
      END
         
      -- Check move picked, but not pick confirm
      IF @cMoveQTYPick = '1' AND @cPickConfirmStatus < '5'
      BEGIN
         SET @nErrNo = 51154
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --IncorrectSetup
         GOTO RollBackTran
      END
   
      SELECT @cFacility = Facility FROM LOC WITH (NOLOCK) WHERE LOC = @cFromLOC

      -- Full pallet pick
      IF @cPickMethod = 'FP'
         EXEC RDT.rdt_STD_EventLog
            @cActionType    = '3', -- Pick
            @cUserID        = @cUserName,
            @nMobileNo      = @nMobile,
            @nFunctionID    = @nFunc,
            @cFacility      = @cFacility,
            @cStorerKey     = @cStorerKey,
            @cLocation      = @cFromLOC,
            @cToLocation    = @cToLOC,
            @cID            = @cFromID,
            @cToID          = @cToID,
            @cTaskDetailKey = @cTaskDetailKey

      -- Partial pallet pick
      IF @cPickMethod = 'PP'
      BEGIN
         -- Move inventory
         IF EXISTS( SELECT 1 FROM rdt.rdtFCPLog WITH (NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey)
         BEGIN
            DECLARE @curUCC CURSOR
            SET @curUCC = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
               SELECT UCCNo, QTY
               FROM rdt.rdtFCPLog WITH (NOLOCK) 
               WHERE TaskDetailKey = @cTaskDetailKey
            OPEN @curUCC
            FETCH NEXT FROM @curUCC INTO @cUCCNo, @nUCCQTY
            WHILE @@FETCH_STATUS = 0
            BEGIN
               IF @cMoveQTYAlloc = '1' OR @cMoveQTYPick = '1'
               BEGIN
                  -- Calc QTY to move
                  IF @cMoveQTYAlloc = '1'
                  BEGIN
                     SET @nQTYAlloc = @nUCCQTY
                     SET @nQTYPick = 0
                  END
                  ELSE IF @cMoveQTYPick = '1'
                  BEGIN
                     SET @nQTYAlloc = 0
                     SET @nQTYPick = @nUCCQTY
                  END
                  ELSE
                  BEGIN
                     SET @nQTYAlloc = 0
                     SET @nQTYPick = 0
                  END

                  -- Move by UCC
                  EXECUTE rdt.rdt_Move
                     @nMobile     = @nMobile,
                     @cLangCode   = @cLangCode,
                     @nErrNo      = @nErrNo  OUTPUT,
                     @cErrMsg     = @cErrMsg OUTPUT,
                     @cSourceType = 'rdt_TM_CasePick_ClosePallet01',
                     @cStorerKey  = @cStorerKey,
                     @cFacility   = @cFacility,
                     @cFromLOC    = @cFromLOC,
                     @cToLOC      = @cToLOC,
                     @cFromID     = @cFromID,
                     @cToID       = @cToID,
                     @cUCC        = @cUCCNo,
                     @nQTYAlloc   = @nQTYAlloc,
                     @nQTYPick    = @nQTYPick,
                     @nFunc       = @nFunc,
                     @cDropID     = @cUCCNo
                  IF @nErrNo <> 0
                     GOTO RollBackTran
               END
               
               -- Clear rdtFCPLog
               DELETE rdt.rdtFCPLog WHERE TaskDetailKey = @cTaskDetailKey AND UCCNo = @cUCCNo
               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 51151
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- DelRPFLogFail
                  GOTO RollBackTran
               END

               -- Eventlog
               EXEC RDT.rdt_STD_EventLog
                  @cActionType    = '3', -- Pick
                  @cUserID        = @cUserName,
                  @nMobileNo      = @nMobile,
                  @nFunctionID    = @nFunc,
                  @cFacility      = @cFacility,
                  @cStorerKey     = @cStorerKey,
                  @cLocation      = @cFromLOC,
                  @cToLocation    = @cToLOC,
                  @cID            = @cFromID,
                  @cToID          = @cToID,
                  @cRefNo1        = @cUCCNo,
                  @cRefNo5        = @cListKey,
                  @cTaskDetailKey = @cTaskDetailKey

               FETCH NEXT FROM @curUCC INTO @cUCCNo, @nUCCQTY
            END
         END
         ELSE
         BEGIN
            -- Calc QTY to move
            IF @cMoveQTYAlloc = '1'
            BEGIN
               SET @nQTYAlloc = @nQTY
               SET @nQTYPick = 0
            END
            ELSE IF @cMoveQTYPick = '1'
            BEGIN
               SET @nQTYAlloc = 0
               SET @nQTYPick = @nQTY
            END
            ELSE
            BEGIN
               SET @nQTYAlloc = 0
               SET @nQTYPick = 0
            END
               
            IF @cLOT = ''
               SET @cLOT = NULL
            
            -- Move by SKU
            IF @nQTY > 0
            BEGIN
               IF (@cMoveQTYAlloc = '1' OR @cMoveQTYPick = '1') 
               BEGIN
                  EXECUTE rdt.rdt_Move
                     @nMobile     = @nMobile,
                     @cLangCode   = @cLangCode,
                     @nErrNo      = @nErrNo  OUTPUT,
                     @cErrMsg     = @cErrMsg OUTPUT,
                     @cSourceType = 'rdt_TM_CasePick_ClosePallet01',
                     @cStorerKey  = @cStorerKey,
                     @cFacility   = @cFacility,
                     @cFromLOC    = @cFromLOC,
                     @cToLOC      = @cToLOC,
                     @cFromID     = @cFromID,
                     @cToID       = @cToID,
                     @cSKU        = @cSKU,
                     @nQTY        = @nQTY,
                     @nQTYAlloc   = @nQTYAlloc,
                     @nQTYPick    = @nQTYPick,
                     @cFromLOT    = @cLOT,
                     @nFunc       = @nFunc,
                     @cTaskDetailKey = @cTaskDetailKey
                  IF @nErrNo <> 0
                     GOTO RollBackTran
               END
               
               -- Eventlog
               EXEC RDT.rdt_STD_EventLog
                  @cActionType    = '3', -- Pick
                  @cUserID        = @cUserName,
                  @nMobileNo      = @nMobile,
                  @nFunctionID    = @nFunc,
                  @cFacility      = @cFacility,
                  @cStorerKey     = @cStorerKey,
                  @cLocation      = @cFromLOC,
                  @cToLocation    = @cToLOC,
                  @cID            = @cFromID,
                  @cToID          = @cToID,
                  @cSKU           = @cSKU,
                  @nQTY           = @nQTY,
                  @cLOT           = @cLOT, 
                  @cTaskDetailKey = @cTaskDetailKey
            END
         END
      END

      -- Unlock  suggested location
      EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
         ,''      --@cFromLOC
         ,@cFromID--@cFromID
         ,@cToLOC --@cSuggestedLOC
         ,''      --@cStorerKey
         ,@nErrNo  OUTPUT
         ,@cErrMsg OUTPUT
      IF @nErrNo <> 0
         GOTO REPLEN_TASK

      -- Update Task
      UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
         Status = '9', -- Closed
         -- UserPosition = @cUserPosition,
         EndTime = GETDATE(),
         EditDate = GETDATE(),
         EditWho  = @cUserName, 
         Trafficcop = NULL
      WHERE TaskDetailKey = @cTaskDetailKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 51152
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdTaskdetFail
         GOTO RollBackTran
      END
      FETCH NEXT FROM @curRPTask INTO @cTaskDetailKey, @cPickMethod, @cStorerKey, @cFromLOC, @cFromID, @cToLOC, @cToID, @cSKU, @cLOT, @nQTY, @nSystemQTY, @cWaveKey
   END

   -- Create next task
   EXEC rdt.rdt_TM_CasePick_CreateNextTask @nMobile, @nFunc, @cLangCode,
      @cUserName,
      @cListKey,
      @nErrNo  OUTPUT,
      @cErrMsg OUTPUT
   IF @nErrNo <> 0
      GOTO RollBackTran

   COMMIT TRAN rdt_TM_CasePick_ClosePallet01 -- Only commit change made here

   GOTO REPLEN_TASK

RollBackTran:
   ROLLBACK TRAN rdt_TM_CasePick_ClosePallet01 -- Only rollback change made here
Fail:

REPLEN_TASK:
   --FOR FCR-989 the trigger replenishment is changed to submitted to QCommander
   IF @cReplenFlag = '1'
   BEGIN
      DECLARE @cLocEmptyOption  NVARCHAR(20)
      DECLARE @cSQlCommand      NVARCHAR(MAX)
      DECLARE @cAPP_DB_Name     NVARCHAR(20)  
      , @cDataStream            VARCHAR(10)  
      , @nThreadPerAcct         INT  
      , @nThreadPerStream       INT  
      , @nMilisecondDelay       INT  
      , @cIP                    NVARCHAR(20)  
      , @cPORT                  NVARCHAR(5)  
      , @cIniFilePath           NVARCHAR(200)  
      , @cCmdType               NVARCHAR(10)  
      , @cTaskType              NVARCHAR(1)   
      , @bSuccess               INT        
      -- Get storer
      SELECT TOP 1
            @cStorerKey = StorerKey,
            @cSKU       = Sku,
            @cFromLOC     = FromLoc
      FROM dbo.TaskDetail WITH (NOLOCK)
      WHERE ListKey = @cListKey
        AND UserKey = @cUserName
      ORDER BY TaskDetailKey

      SELECT @cFacility = Facility FROM LOC WITH (NOLOCK) WHERE LOC = @cFromLOC
      SELECT @cLocEmptyOption = V_String14 FROM   RDT.RDTMOBREC WITH (NOLOCK) WHERE  Mobile = @nMobile

      IF @bDebug>0
         INSERT INTO DocInfo(TableName,key1,key2,key3,StorerKey,[Data],DataType)
         VALUES('YSLOG',@cSKU,@cFromLOC,@cLocEmptyOption,@cStorerKey,'Enter to replenishment','LOG')


      --Operator say the location is empty /or/ qty hits min threshold
      IF ISNULL(RTRIM(@cLocEmptyOption), '') = '1' OR EXISTS(
         SELECT 1 FROM SKUXLOC SL(NOLOCK)
                          JOIN LOTxLOCxID LLI WITH (NOLOCK) ON SL.StorerKey = LLI.StorerKey AND SL.SKU = LLI.SKU AND SL.LOC = LLI.LOC
         WHERE SL.StorerKey = @cStorerKey
           AND SL.SKU = @cSKU
           AND SL.LOC = @cFromLOC
           AND SL.LocationType IN ( 'CASE','PALLET','PICK')
         GROUP BY
            SL.StorerKey,
            SL.SKU,
            SL.LOC,
            SL.QtyLocationMinimum
         HAVING (SUM(LLI.Qty) - SUM(LLI.QtyPicked) + SUM(LLI.PendingMoveIn)) <= SL.QtyLocationMinimum
      )
      BEGIN
         /*  --- original statement for trigger replenishment
         EXEC isp_ODMRPL01
               @c_Facility = @cFacility,
               @c_Storerkey = @cStorerKey,
               @c_SKU = @cSKU,
               @c_LOC = @cFromLOC,
               @c_ReplenType = N'T',
               @b_Success = @b_Success OUTPUT,
               @n_Err = @nErrNo OUTPUT,
               @c_ErrMsg = @cErrMsg OUTPUT,
               @b_Debug = 0
         */
         -----New code

         SET @cSQlCommand = N'
            DECLARE  @bSuccess INT,
                     @nErrNo   INT,
                     @cErrMsg  NVARCHAR(255) 
            EXEC [dbo].[isp_ODMRPL01]
               @c_Facility = ''' + @cFacility + ''',
               @c_Storerkey = ''' + @cStorerKey + ''',
               @c_SKU = ''' + @cSKU + ''',
               @c_LOC = ''' + @cFromLOC + ''',
               @c_ReplenType = N''T'',
               @b_Success = @bSuccess OUTPUT,
               @n_Err = @nErrNo OUTPUT,
               @c_ErrMsg = @cErrMsg OUTPUT,
               @b_Debug = 0'
         
         SELECT TOP 1 @cAPP_DB_Name       = APP_DB_Name,
                     @cDataStream        = DataStream,
                     @nThreadPerAcct     = ThreadPerAcct,
                     @nThreadPerStream   = ThreadPerStream,
                     @nMilisecondDelay   = MilisecondDelay,
                     @cIP                = [IP],
                     @cPORT              = [PORT],
                     @cIniFilePath       = IniFilePath,
                     @cCmdType           = CmdType,
                     @cTaskType          = TaskType
         FROM QCmd_TransmitlogConfig WITH (NOLOCK)
         WHERE TableName  = 'Replenishment'
            AND [App_Name] = 'WMS'
            AND  (StorerKey = @cStorerKey OR StorerKey = 'ALL')
         ORDER BY
            CASE WHEN StorerKey = @cStorerKey THEN 0 ELSE 1 END ASC 

         IF @@ROWCOUNT<=0
         BEGIN
            SET @nErrNo = 51152
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- NO replenishment config
            GOTO Quit
         END
         BEGIN TRY
            IF @bDebug>0
               INSERT INTO DocInfo(TableName,key1,key2,key3,StorerKey,[Data],DataType)
               VALUES('YSLOG',@cFacility,@cIP,@cPORT,@cStorerKey,'Prepare:'+@cSQlCommand,'LOG')         
            EXEC isp_QCmd_SubmitTaskToQCommander
                  @cTaskType           = 'O' -- D=By Datastream, T=Transmitlog, O=Others
                  , @cStorerKey        = @cStorerKey
                  , @cDataStream       = ''
                  , @cCmdType          = 'SQL'
                  , @cCommand          = @cSQlCommand
                  , @cTransmitlogKey   = ''
                  , @nThreadPerAcct    = @nThreadPerAcct
                  , @nThreadPerStream  = @nThreadPerStream
                  , @nMilisecondDelay  = @nMilisecondDelay
                  , @nSeq              = 1
                  , @cIP               = @cIP
                  , @cPORT             = @cPORT
                  , @cIniFilePath      = @cIniFilePath
                  , @cAPPDBName        = @cAPP_DB_Name
                  , @bSuccess          = @bSuccess OUTPUT
                  , @nErr              = @nErrNo OUTPUT
                  , @cErrMsg           = @cErrMsg OUTPUT   
            END TRY
            BEGIN CATCH
           	   SET @cErrMsg = ERROR_MESSAGE()
           	   PRINT @cErrMsg     
               IF @bDebug>0
                  INSERT INTO DocInfo(TableName,key1,key2,key3,StorerKey,[Data],DataType)
                  VALUES('YSLOG',@cFacility,@cIP,@cPORT,@cStorerKey,'ERROR:' + @cErrMsg ,'LOG')                        
            	GOTO Quit               
            END CATCH   
            IF @bDebug>0
               INSERT INTO DocInfo(TableName,key1,key2,key3,StorerKey,[Data],DataType)
               VALUES('YSLOG',@cFacility,@cIP,@cPORT,@cStorerKey,'DONE:'+@cSQlCommand,'LOG')                                 
      END
   END
   GOTO Quit

Quit:
WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
   COMMIT TRAN
END
IF @bDebug>0
   INSERT INTO DocInfo(TableName,key1,key2,key3,StorerKey,[Data],DataType)
   VALUES('YSLOG','','','','','Exit rdt_TM_CasePick_ClosePallet01','LOG')   
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_TM_CasePick_ClosePallet01 TO NSQL
GO
