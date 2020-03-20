IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_QCmd_UpdateQueueTaskStatus]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_QCmd_UpdateQueueTaskStatus]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Stored Procedure: isp_QCmd_UpdateQueueTaskStatus                     */  
/* Creation Date: 25-Feb-2017                                           */  
/* Copyright: LF Logistics                                              */  
/* Written by: TKLIM                                                    */  
/*                                                                      */  
/* Purpose: Update status into TCPSocket_QueueTask table                */  
/*                                                                      */  
/* Called By: QCommander program                                        */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 1.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author     Purposes                                     */ 
/* 04-Aug-2017  SHONG      Move Record to TCPSocket_QueueTask_Log       */
/*                         instead of update                            */
/* 08-Aug-2017  TKLIM      Get ThreadStartdate time from existing record*/
/* 13-Aug-2018  TKLIM      Update MsgRecvDate                           */
/* 15-Aug-2018  TKLIM      Update ThreadID                              */
/* 30-Aug-2018  TKLIM      Bug Fix ThreadID                             */
/************************************************************************/  
CREATE PROC [dbo].[isp_QCmd_UpdateQueueTaskStatus]
   @cTargetDB        NVARCHAR(30),
   @nQTaskID         BIGINT, 
   @cQStatus         NVARCHAR(1),
   @cThreadID        NVARCHAR(20),
   @cMsgRecvDate     NVARCHAR(30),
   @cQErrMsg         NVARCHAR(256),
   @bSuccess         INT=1            OUTPUT, 
   @nErr             INT=0            OUTPUT, 
   @cErrMsg          NVARCHAR(256)='' OUTPUT

AS  
BEGIN  
   SET NOCOUNT ON   
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF  
   
   DECLARE 
           @nRowCount         INT, 
           @cSQLStatement     NVARCHAR(4000),
           @cSQLParms         NVARCHAR(4000), 
           @cTableSchema      NVARCHAR(200),
           @dThreadStartTime  DATETIME 
           
   SET @cTargetDB = ISNULL(@cTargetDB, '')
   SET @cTableSchema = ''
   
   /*******************************************
    *  Getting Schema Name for TCPSocket_QueueTask, 
    *  For OMS this table schema is IML
    *******************************************/
   SET @cSQLStatement = N'SELECT TOP 1 @cTableSchema = TBL.TABLE_SCHEMA ' + 
                         ' FROM ' + QUOTENAME(@cTargetDB) + '.[INFORMATION_SCHEMA].[TABLES] TBL ' +     
                         ' WHERE tbl.TABLE_NAME = ''TCPSocket_QueueTask'' '
   EXEC master.sys.sp_ExecuteSQL @cSQLStatement, N'@cTableSchema   NVARCHAR(200) OUTPUT',  @cTableSchema OUTPUT

   /*******************************************
    *  Start update QueueTask table
    *******************************************/

   IF @cQStatus = '1'
   BEGIN
   	SET @cSQLStatement = 
      N'UPDATE ' + QUOTENAME(@cTargetDB) + '.' + QUOTENAME(@cTableSchema) + '.' + '[TCPSocket_QueueTask] WITH (ROWLOCK) ' + 
      N' SET [Status] = @cQStatus ' +
      N', EditDate = Getdate(), EditWho = sUser_sName() '  + 
   	N', Try = ISNULL(Try,0) + 1, ThreadStartTime = Getdate(), ThreadEndTime= NULL' + 
      N', ThreadID = @cThreadID '  + 
      N', MsgRecvDate = @cMsgRecvDate '  + 
   	N' WHERE ID = @nQTaskID; ' + 
      N'SET @nRowCount = @@ROWCOUNT '   
   END
   ELSE 
   BEGIN
      SET @cSQLStatement = 
         N'BEGIN TRANSACTION; ' + CHAR(13) + 
         N'INSERT INTO ' + QUOTENAME(@cTargetDB) + '.' + QUOTENAME(@cTableSchema) + '.' + '[TCPSocket_QueueTask_Log] ' + 
         N'( ID, CmdType, Cmd, StorerKey, ThreadPerAcct, ThreadPerStream, MilisecondDelay, DataStream, TransmitLogKey, '+ 
	      N'[Status], ThreadId, ThreadStartTime, ThreadEndTime, ErrMsg, [Try], SEQ, Port, TargetDB, ' + 
	      N'AddDate, AddWho, EditDate, EditWho, ArchiveCop, TrafficCop, IP, MsgRecvDate ) ' +   
            	
         N'SELECT ID, CmdType, Cmd, StorerKey, ThreadPerAcct, ThreadPerStream, ' +
	      N'MilisecondDelay, DataStream, TransmitLogKey, ' + 
	      N'[Status] = @cQStatus, ' +
	      --N'ThreadId, ThreadStartTime = @dThreadStartTime, ThreadEndTime = Getdate(), ' +
	      N'@cThreadID, ThreadStartTime, ThreadEndTime = Getdate(), ' +
	      N'ErrMsg = CASE WHEN @cQStatus = ''9'' THEN '''' ELSE @cQErrMsg END, ' +   
	      N'[Try], SEQ, Port, TargetDB, ' + 
	      N'AddDate, AddWho,' +
	      N'EditDate = Getdate(), EditWho = sUser_sName(), ' + 
	      N'ArchiveCop, TrafficCop, IP, @cMsgRecvDate  ' +
         N'FROM ' + QUOTENAME(@cTargetDB) + '.' + QUOTENAME(@cTableSchema) + '.' + '[TCPSocket_QueueTask] WITH (NOLOCK) ' + 
         N'WHERE ID = @nQTaskID; ' + CHAR(13) +
         N'SET @nRowCount = @@ROWCOUNT; ' + CHAR(13) + 
         N'IF @@ERROR = 0 AND @nRowCount = 1 ' + CHAR(13) + 
         N'BEGIN ' + CHAR(13) + 
         N'   DELETE FROM ' + QUOTENAME(@cTargetDB) + '.' + QUOTENAME(@cTableSchema) + '.' + '[TCPSocket_QueueTask] ' + CHAR(13) +
         N'   WHERE ID = @nQTaskID; ' + CHAR(13) +
         N'   COMMIT TRANSACTION; ' + CHAR(13) + 
         N'END '+ CHAR(13) +
         N'ELSE '+ CHAR(13) +
         N'BEGIN ' + CHAR(13) +
         N'   ROLLBACK TRANSACTION; '+ CHAR(13) + 
         N'END '+ CHAR(13)    	
   END 
      
   SET @cSQLParms = N'@nQTaskID  BIGINT, @cQStatus  NVARCHAR(1), @cQErrMsg NVARCHAR(256), @cThreadID NVARCHAR(20), @cMsgRecvDate NVARCHAR(30), @nRowCount INT OUTPUT' --, @dThreadStartTime DATETIME'   	

   EXEC master.sys.sp_ExecuteSQL @cSQLStatement, @cSQLParms, @nQTaskID, @cQStatus, @cQErrMsg, @cThreadID, @cMsgRecvDate, @nRowCount OUTPUT --, @dThreadStartTime   
    

   QUIT_PROC:
   
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_QCmd_UpdateQueueTaskStatus] TO nSQL 
GO


