SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1812ExtUpd07                                    */
/* Purpose: For American Eagle Mexico                                   */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author  Ver.  Purposes                                  */
/* 2026-06-16   Jackc   1.0   FCR-12989 Created                          */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1812ExtUpd07
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
   DECLARE @cReasonKey           NVARCHAR(10)
   DECLARE @cTaskStatus          NVARCHAR(10)
   DECLARE @cTaskTaskType        NVARCHAR(10)
   DECLARE @cGroupKey            NVARCHAR(10)
   DECLARE @cAreaKey             NVARCHAR(10)

   DECLARE @cErrMsg1    NVARCHAR(125)
   DECLARE @cErrMsg2    NVARCHAR(125)
   DECLARE @cErrMsg3    NVARCHAR(125)
   
   IF @nDebugFlag = 1
      SELECT 'Executing 1812ExtUpd07'

   SELECT 
      @cUserName           = userName,
      @cStorerKey          = StorerKey,
      @cFacility           = Facility
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE mobile = @nMobile
   
   -- TM Case Pick
   IF @nFunc = 1812
   BEGIN
      IF @nStep = 9 -- Reason Screen
      BEGIN
         IF @nInputKey = 1 
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'St9, Enter', @cTaskdetailKey AS TaskDetailKey

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
            
            IF ISNULL(@cTaskdetailKey, '') = ''
            BEGIN
               SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
               SET @cErrMsg1 = '270101-TaskKey Empty'
               EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
               GOTO FAIL 
            END

            SELECT
               @cTaskTaskType = TaskType,
               @cTaskStatus   = Status,
               @cReasonKey    = ReasonKey
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerkey
               AND TaskDetailKey = @cTaskDetailKey

            IF @@ROWCOUNT = 0
            BEGIN
               SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
               SET @cErrMsg1 = '270102-NoTaskFound'
               EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
               GOTO FAIL
            END

            IF @nDebugFlag = 1
               SELECT 'Task Info', @cTaskdetailKey AS Task, @cReasonKey AS ReasonKey, @cTaskStatus AS Status

            IF @cTaskStatus = '5' AND @cReasonKey IN ('SHORTAEOMX','SPLITAEOMX')
            BEGIN
               IF EXISTS (SELECT 1 
                           FROM dbo.PickDetail WITH (NOLOCK)
                           WHERE StorerKey = @cStorerKey
                              AND TaskDetailKey = @cTaskDetailKey
                              AND Status = '4'
                        )
               BEGIN
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
                     SET @cErrMsg1 = '270106-NoQcmdConfig'
                     SET @cErrMsg2 = 'Trigger reallocation fail '
                     EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
                     GOTO FAIL 
                  END

                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = LTRIM(RTRIM(@cExecStatements)) AND type = 'P')
                  BEGIN
                     SET @cExecStatements = 'EXEC ' + @cAPP_DB_Name + '.dbo.' + LTRIM(@cExecStatements)
                                    + ' @c_TaskDetailKey = ''' + @cTaskDetailKey + ''''

                     IF @nDebugFlag = 1
                        SELECT 'Start to submit Qcmd', @cExecStatements

                     IF @nDebugFlag = 2
                     BEGIN
                        BEGIN TRY   
                           INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2,
                                                   Col1, Col2, Col3, Col4, Col5)
                           VALUES ('1812ExtUpd07', GETDATE(), @cUserName, CAST(@nMobile AS NVARCHAR(10)),
                                 @cTaskDetailKey, '', '', '', 'SubmitQcmd')
                        END TRY
                        BEGIN CATCH
                           PRINT 'Insert TraceInfo failed'
                        END CATCH
                     END 

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
                        SET @cErrMsg1 = '270108-QcmdFail'
                        SET @cErrMsg2 = 'Trigger reallocation fail '
                        EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
                        GOTO FAIL 
                     END CATCH

                     IF @nErrNo <> 0
                     BEGIN
                        SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
                        SET @cErrMsg3 = 'Return err: ' + CAST(@nErrNo AS NVARCHAR(10))
                        SET @cErrMsg1 = '270109-GenQcmdTaskFail'
                        SET @cErrMsg2 = 'Trigger reallocation fail '
                        EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
                        GOTO FAIL 
                     END
                  END -- submit Qcmd
                  ELSE
                  BEGIN
                     SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
                     SET @cErrMsg1 = '270107-InvalidSPName'
                     SET @cErrMsg2 = 'Trigger reallocation fail '
                     EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
                     GOTO FAIL 
                  END

                  IF @nDebugFlag = 1
                     SELECT 'Submit Qcmd task successfully', @nQueueID AS QueueID
               END
               ELSE
               BEGIN
                  IF @nDebugFlag = 1
                     SELECT 'No short pickdetail found', @cTaskDetailKey AS TaskKey

                  IF @nDebugFlag = 2
                  BEGIN
                     BEGIN TRY
                        INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, 
                                                   Col1, Col2, Col3, Col4, Col5)  
                        VALUES ('1812ExtUpd07', GETDATE(), @cUserName, CAST(@nMobile AS NVARCHAR(10)),
                              @cTaskDetailKey, '', '', '', 'NoShortPickDetl')
                     END TRY
                     BEGIN CATCH
                        PRINT 'Insert trace info failed'
                     END CATCH
                  END 
                  GOTO Quit
               END -- No pkd
            END -- reallo
            ELSE
            BEGIN
               IF @nDebugFlag = 1
                     SELECT 'Task not short', @cTaskDetailKey AS TaskKey, @cTaskStatus AS Status, @cReasonKey AS ReasonKey

               IF @nDebugFlag = 2
               BEGIN
                  BEGIN TRY
                     INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, 
                                                Col1, Col2, Col3, Col4, Col5)  
                     VALUES ('1812ExtUpd07', GETDATE(), @cUserName, CAST(@nMobile AS NVARCHAR(10)),
                              @cTaskDetailKey, @cTaskStatus, @cReasonKey, '', 'TaskNotShort') 
                  END TRY
                  BEGIN CATCH
                     PRINT 'Insert trace info failed'
                  END CATCH
               END

               GOTO Quit
            END -- no need reallo

            GOTO Quit
         END -- inputkey=1
      END --st9
   END --1812

   FAIL:
      IF @nStep = 9
      BEGIN
         --do not block process for reason code, just log the error and move on
         SET @nErrNo = 0
         SET @cErrMsg = ''
      END

   Quit:
   IF @nDebugFlag = 1
      SELECT 'Finished 1812ExtUpd07', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1812ExtUpd07 TO NSQL
GO
