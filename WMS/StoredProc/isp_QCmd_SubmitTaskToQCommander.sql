IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_QCmd_SubmitTaskToQCommander]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_QCmd_SubmitTaskToQCommander]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Stored Procedure: isp_QCmd_SubmitTaskToQCommander                    */  
/* Creation Date: 10-Jun-2003                                           */  
/* Copyright: LF Logistics                                              */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose: Submitting task to Q commander                              */
/*          Duplicate from isp_SubmitTaskToQCommander                   */  
/*                                                                      */  
/*                                                                      */  
/* Called By:  Any other related Store Procedures.                      */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 1.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date        Author   Purposes                                        */  
/* 30-Aug-2016 KTLow    Add SEQ Column (KT01)                           */
/* 06-Oct-2016 MCTang   Add Port (MC01)                                 */
/* 10-Oct-2016 KTLow    Filter By Port (KT02)                           */
/* 01-Nov-2016 MCTang   Filter By Port (MC02)                           */
/* 14-Apr-2017 MCTang   Enhancement QueueData (MC03)                    */
/* 12-Oct-2017 MCTang   Include Retry (MC04)                            */
/************************************************************************/  
CREATE PROC [dbo].[isp_QCmd_SubmitTaskToQCommander]
            @cTaskType           NVARCHAR(10)
          , @cStorerKey          NVARCHAR(15) 
          , @cDataStream         NVARCHAR(10)
          , @cCmdType            NVARCHAR(10)
          , @cCommand            NVARCHAR(1024) 
          , @cTransmitlogKey     NVARCHAR(10)   = '' 
          , @nThreadPerAcct      INT            = 0 
          , @nThreadPerStream    INT            = 0
          , @nMilisecondDelay    INT            = 0
          , @nSeq                INT            = 1   --(KT01)
          , @cIP                 NVARCHAR(20)   = ''  --(MC01)
          , @cPORT               NVARCHAR(5)    = ''  --(MC01)
          , @cIniFilePath        NVARCHAR(200)  = ''  --(MC01)
          , @cAPPDBName          NVARCHAR(20)   = ''  --(MC03)
          , @bSuccess            INT            OUTPUT 
          , @nErr                INT            OUTPUT 
          , @cErrMsg             NVARCHAR(256)  OUTPUT

AS  
BEGIN  
   SET NOCOUNT ON   
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF  
   
   DECLARE @nQueueID         BIGINT
         , @cDataReceived    NVARCHAR(4000)
         , @cData            NVARCHAR(4000) 
         , @cCurrentDBName   NVARCHAR(20)       --(MC03)
  
   SET @nQueueID = 0 
   SET @cCurrentDBName = DB_NAME()              --(MC03)

   IF @cTaskType = 'T' AND @cTransmitlogKey <>'' -- By TransmitlogKey
   BEGIN
      IF EXISTS(SELECT 1 FROM TCPSocket_QueueTask AS tqt WITH (NOLOCK)
                WHERE tqt.DataStream = @cDataStream
                AND   tqt.TransmitLogKey = @cTransmitlogKey  
                AND   tqt.SEQ  = @nSeq     --(KT01)
                AND   tqt.Port = @cPORT    --(KT02)
                AND   tqt.[Status] IN ('0','1'))
      BEGIN
         GOTO SKIP_INSERT 
      END
   END
   ELSE IF @cTaskType='D' AND @cTransmitlogKey='' -- By Data Stream 
   BEGIN
      IF EXISTS(SELECT 1 FROM TCPSocket_QueueTask AS tqt WITH (NOLOCK)
                WHERE tqt.DataStream = @cDataStream
                AND   tqt.Port       = @cPORT        --(MC02)
                AND   tqt.[Status]   IN ('0','1') )  --(MC02)
                --AND   tqt.[Status] ='0')           --(MC02)
      BEGIN
         GOTO SKIP_INSERT 
      END         
      SET @nThreadPerAcct=1
      SET @nThreadPerStream=1
   END             
   
   INSERT INTO TCPSocket_QueueTask
   (   CmdType        , Cmd             , StorerKey
     , ThreadPerAcct  , ThreadPerStream , MilisecondDelay
     , DataStream     , TransmitLogKey
     , SEQ           --(KT01)
     , PORT          --(MC01)
     , TargetDB      --(MC03)
     , IP            --(MC04)
   )
   VALUES
   (   @cCmdType        , @cCommand          , @cStorerKey
     , @nThreadPerAcct  , @nThreadPerStream  , @nMilisecondDelay
     , @cDataStream     , @cTransmitlogKey
     , @nSeq            --(KT01)
     , @cPORT           --(MC01)
     , @cAPPDBName      --(MC03)
     , @cIP             --(MC04)
   )
      
   SELECT @nQueueID = @@IDENTITY, @nErr = @@ERROR
   
   IF @nQueueID IS NULL OR @nQueueID = 0 
   BEGIN
      SET @cErrMsg = 'Insert into TCPSocket_QueueTask fail, Error# ' + CAST(@nErr AS VARCHAR(10))
      SET @bSuccess = 0 
      GOTO SKIP_INSERT 
   END 

   --(MC03) - S
   IF @cAPPDBName <> ''
   BEGIN
      --SQL|176657|CNDTSITF|EXEC CNDTSITF..isp_QCmd_ExecuteSQL @cAPPDBName=CNDTSITF, @nQTaskID=176657 
      SET @cData = '<STX>'
                 + @cCmdType+'|' 
                 + CAST(@nQueueID AS VARCHAR(20)) + '|' 
                 + RTRIM(@cAPPDBName) + '|'
                 + 'EXEC ' + RTRIM(@cAPPDBName) + '..isp_QCmd_ExecuteSQL @cTargetDB=''' + RTRIM(@cCurrentDBName) + ''', @nQTaskID=' + CAST(@nQueueID AS VARCHAR(20))
                 + '<ETX>'   
   END
   --(MC03) - E
   ELSE
   BEGIN
      SET @cData = '<STX>'+ CAST(@nQueueID AS VARCHAR(20)) + '<ETX>'     
   END  
   
   EXEC isp_QCmd_SendTCPSocketMsg
         @cApplication     = 'QCommander'
       , @cStorerKey       = @cStorerKey 
       , @cMessageNum      = ''
       , @cData            = @cData
       , @cIP              = @cIP            --(MC01)
       , @cPORT            = @cPORT          --(MC01)
       , @cIniFilePath     = @cIniFilePath   --(MC01)
       , @cDataReceived    = @cDataReceived  OUTPUT
       , @bSuccess         = @bSuccess       OUTPUT 
       , @nErr             = @nErr           OUTPUT 
       , @cErrMsg          = @cErrMsg        OUTPUT

   --(MC04) - S
   IF ISNULL(@cErrMsg, '') <> ''
   BEGIN
      
      UPDATE TCPSocket_QueueTask  WITH (ROWLOCK)           
      SET    STATUS     = 'R' 
           , EditDate   = GETDATE()
           , EditWho    = SUSER_SNAME()
      WHERE  ID   = @nQueueID
   
   END
   --(MC04) - E

   RETURN  
   
   SKIP_INSERT:
   
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_QCmd_SubmitTaskToQCommander] TO nSQL 
GO
