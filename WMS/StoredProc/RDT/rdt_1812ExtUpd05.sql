
/************************************************************************/
/* Store procedure: rdt_1812ExtUpd05                                    */
/* Purpose: For Mattel                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author  Ver.  Purposes                                  */
/* 2025-12-12   Jackc   1.0   FCR-8481 Created                          */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1812ExtUpd05
   @nMobile         INT,          
   @nFunc           INT,          
   @cLangCode       NVARCHAR( 3), 
   @nStep           INT,          
   @nInputKey       INT,          
   @cTaskdetailKey  NVARCHAR( 10),
   @cDropID         NVARCHAR( 20),
   @nQTY            INT,          
   @cToLOC          NVARCHAR( 10),
   @nErrNo          INT OUTPUT,   
   @cErrMsg         NVARCHAR( 20) OUTPUT,
   @nAfterStep      INT      
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag           INT = 0

   DECLARE @bSuccess             INT   
   DECLARE @nExists              INT
   DECLARE @cShort               NVARCHAR(20)
   DECLARE @cUserName            NVARCHAR(18)
   DECLARE @cStorerKey           NVARCHAR(15)
   DECLARE @cFacility            NVARCHAR(5)
   DECLARE @cLastTaskDetailKey   NVARCHAR(10)
   DECLARE @cReasonKey           NVARCHAR(10)
   DECLARE @cTaskStatus          NVARCHAR(10)
   DECLARE @cTaskFromLoc         NVARCHAR(10)
   DECLARE @cTaskSKU             NVARCHAR(20)
   DECLARE @cTaskWaveKey         NVARCHAR(10)
   DECLARE @cTaskTaskType        NVARCHAR(10)

   DECLARE @cErrMsg1    NVARCHAR(125)
   DECLARE @cErrMsg2    NVARCHAR(125)
   DECLARE @cErrMsg3    NVARCHAR(125)
   
   IF @nDebugFlag = 1
      SELECT 'Executing 1812ExtUpd05'

   SELECT 
      @cUserName           = userName,
      @cStorerKey          = StorerKey,
      @cFacility           = Facility,
      @cLastTaskDetailKey  = V_TaskDetailKey 
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE mobile = @nMobile
   
   -- TM Case Pick
   IF @nFunc = 1812
   BEGIN
      IF @nStep = 5 -- Next task/close pallet
      BEGIN
         IF @nInputKey = 1 
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'St5, Enter', @cLastTaskDetailKey AS LastTaskDetailKey

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
            
            IF ISNULL(@cLastTaskDetailKey, '') = ''
            BEGIN
               SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
               SET @cErrMsg1 = '253651-LastTaskKey Empty'
               EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
               GOTO Quit 
            END

            SELECT 
               @cTaskTaskType = TaskType,
               @cTaskStatus   = Status,
               @cReasonKey    = ReasonKey,
               @cTaskFromLoc  = FromLoc,
               @cTaskSKU      = SKU,
               @cTaskWaveKey  = WaveKey
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerkey
               AND TaskDetailKey = @cLastTaskDetailKey

            IF @@ROWCOUNT <= 0
            BEGIN
               SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
               SET @cErrMsg1 = '253652-NoTaskFound'
               EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
               GOTO Quit 
            END

            IF @nDebugFlag = 1
               SELECT 'Task Info', @cLastTaskDetailKey AS Task, @cReasonKey AS ReasonKey, @cTaskStatus AS Status

            IF @cTaskStatus = '5' AND @cReasonKey <> ''
            BEGIN
               IF EXISTS (SELECT 1 
                           FROM dbo.PickDetail WITH (NOLOCK)
                           WHERE StorerKey = @cStorerKey
                              AND TaskDetailKey = @cLastTaskDetailKey
                              AND Status = '4'
                        )
               BEGIN
                  IF ISNULL(@cTaskFromLoc, '') = ''
                  BEGIN
                     SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
                     SET @cErrMsg1 = '253653-FromLocEmpty'
                     SET @cErrMsg2 = 'Trigger reallocation fail '
                     EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
                     GOTO Quit 
                  END

                  IF ISNULL(@cTaskSKU, '') = ''
                  BEGIN
                     SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
                     SET @cErrMsg1 = '253654-SKUEmpty'
                     SET @cErrMsg2 = 'Trigger reallocation fail '
                     EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
                     GOTO Quit 
                  END

                  IF ISNULL(@cTaskWaveKey, '') = ''
                  BEGIN
                     SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
                     SET @cErrMsg1 = '253655-WaveKeyEmpty'
                     SET @cErrMsg2 = 'Trigger reallocation fail '
                     EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
                     GOTO Quit 
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
                  WHERE TableName = '1812ShortPickReallo'
                     AND App_Name = 'WMS'
                     AND StorerKey =  @cStorerKey

                  IF @@ROWCOUNT <= 0
                  BEGIN
                     SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
                     SET @cErrMsg1 = '253656-NoQcmdConfig'
                     SET @cErrMsg2 = 'Trigger reallocation fail '
                     EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
                     GOTO Quit 
                  END

                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = LTRIM(RTRIM(@cExecStatements)) AND type = 'P')
                  BEGIN
                     SET @cExecStatements = 'EXEC ' + @cAPP_DB_Name + '.dbo.' + LTRIM(@cExecStatements)
                                    + ' @c_Wavekey = ''' + @cTaskWaveKey + ''''
                                    + ', @c_SKU = ''' + @cTaskSKU + ''''
                                    + ', @c_Loc = ''' + @cTaskFromLoc + ''''
                                    + ', @c_TaskDetailKey = ''' + @cLastTaskDetailKey + ''''

                     IF @nDebugFlag = 1
                        SELECT 'Start to submit Qcmd', @cExecStatements

                     IF @nDebugFlag = 2
                        INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, 
                                                Col1, Col2, Col3, Col4, Col5)  
                        VALUES ('1812ExtUpd05', GETDATE(), @cUserName, CAST(@nMobile AS NVARCHAR(10)),
                                @cLastTaskDetailKey,@cTaskWaveKey, @cTaskSKU, @cTaskFromLoc, 'SubmitQcmd') 

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
                        SET @cErrMsg1 = '253658-QcmdFail'
                        SET @cErrMsg2 = 'Trigger reallocation fail '
                        EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
                        GOTO Quit 
                     END CATCH

                     IF @nErrNo <> 0
                     BEGIN
                        SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
                        SET @cErrMsg3 = 'Retrun err: ' + CAST(@nErrNo AS NVARCHAR(10))
                        SET @cErrMsg1 = '253659-GenQcmdTaskFail'
                        SET @cErrMsg2 = 'Trigger reallocation fail '
                        EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
                        GOTO Quit 
                     END
                  END -- submit Qcmd
                  ELSE
                  BEGIN
                     SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
                     SET @cErrMsg1 = '253657-InvalidSPName'
                     SET @cErrMsg2 = 'Trigger reallocation fail '
                     EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
                     GOTO Quit 
                  END

                  IF @nDebugFlag = 1
                     SELECT 'Submit Qcmd task successfully', @nQueueID AS QueueID

               END
               ELSE
               BEGIN
                  IF @nDebugFlag = 1
                     SELECT 'No shourt pickdetail found', @cLastTaskDetailKey AS TaskKey

                  IF @nDebugFlag = 2
                     INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, 
                                                Col1, Col2, Col3, Col4, Col5)  
                     VALUES ('1812ExtUpd05', GETDATE(), @cUserName, CAST(@nMobile AS NVARCHAR(10)),
                            @cLastTaskDetailKey, '', '', '', 'NoShortPickDetl') 
                  GOTO Quit
               END -- No pkd
            END -- reallo
            ELSE
            BEGIN
               IF @nDebugFlag = 1
                     SELECT 'Task not short', @cLastTaskDetailKey AS TaskKey, @cTaskStatus AS Status, @cReasonKey AS ReasonKey

               IF @nDebugFlag = 2
                  INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, 
                                             Col1, Col2, Col3, Col4, Col5)  
                  VALUES ('1812ExtUpd05', GETDATE(), @cUserName, CAST(@nMobile AS NVARCHAR(10)),
                           @cLastTaskDetailKey, @cTaskStatus, @cReasonKey, '', 'TaskNotShort') 

               GOTO Quit
            END -- no need reallo

            GOTO Quit
         END -- inputkey=1
      END --st5
   END

Quit:


END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1812ExtUpd05 TO NSQL
GO
