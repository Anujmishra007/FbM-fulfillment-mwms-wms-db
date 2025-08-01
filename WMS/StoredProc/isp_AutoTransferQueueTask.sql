SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store Procedure: isp_AutoTransferQueueTask                           */
/* Creation Date: 2025-03-11                                            */
/* Copyright: Maersk                                                    */
/* Written by: Shreekanth                                               */
/*                                                                      */
/* Purpose: UWP-30045 Scheduling Auto Transfer with QCommander          */
/*                                                                      */
/* Called By: SCE                                                       */
/*          :                                                           */
/* PVCS Version: 1.7                                                    */
/*                                                                      */
/* Version: 8.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author     Ver.  Purposes                                */
/* 2025-03-11  Shreekanth 1.1   Inserting for TCPSocket_QueueTask       */
/*                                              for QCmd to pick        */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_AutoTransferQueueTask]
@c_Listname             NVARCHAR(10)
,  @c_Storerkey            NVARCHAR(15)
,  @b_Success              INT = 1                OUTPUT
,  @n_Err                  INT = 0                OUTPUT
,  @c_ErrMsg               NVARCHAR(255) = ''     OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    SET ANSI_NULLS OFF
    SET QUOTED_IDENTIFIER OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE @n_Continue                   INT = 1
        ,  @c_Facility                   NVARCHAR(5)  = ''
        ,  @c_APP_DB_Name                NVARCHAR(20)   = ''
        ,  @c_DataStream                 NVARCHAR(10)   = ''
        ,  @c_CmdType                    NVARCHAR(10)   = ''
        ,  @c_TaskType                   NVARCHAR(1)    = ''
        ,  @n_Priority                   INT            = 0
        ,  @n_ThreadPerAcct              INT            = 0
        ,  @n_ThreadPerStream            INT            = 0
        ,  @n_MilisecondDelay            INT            = 0
        ,  @c_IP                         NVARCHAR(20)   = ''
        ,  @c_PORT                       NVARCHAR(5)    = ''
        ,  @c_IniFilePath                NVARCHAR(200)  = ''
        ,  @c_ExecCmd                    NVARCHAR(1024) = ''
        ,  @c_TransmitlogKey             NVARCHAR(10)   = ''

    SELECT TOP 1
            @c_APP_DB_Name     = ISNULL(qcfg.APP_DB_Name,'')
                   ,  @c_DataStream      = qcfg.DataStream
         ,  @n_ThreadPerAcct   = qcfg.ThreadPerAcct
         ,  @n_ThreadPerStream = qcfg.ThreadPerStream
         ,  @n_MilisecondDelay = qcfg.MilisecondDelay
         ,  @c_IP              = qcfg.[IP]
         ,  @c_PORT            = qcfg.[PORT]
         ,  @c_IniFilePath     = qcfg.IniFilePath
         ,  @c_CmdType         = qcfg.CmdType
         ,  @c_TaskType        = qcfg.TaskType
         ,  @n_Priority        = qcfg.[Priority]
    FROM  dbo.QCmd_TransmitlogConfig qcfg WITH (NOLOCK)
    WHERE qcfg.TableName      = 'BEAutoTransfer'
          AND   qcfg.[App_Name]     = 'WMS'
          AND   qcfg.StorerKey      IN ( @c_Storerkey, 'ALL')
          AND   qcfg.Facility       IN ( @c_Facility,  'ALL', '')
    ORDER BY CASE WHEN qcfg.StorerKey = @c_Storerkey AND
        qcfg.Facility  = @c_Facility
        THEN 1
        WHEN qcfg.StorerKey = @c_Storerkey AND
        qcfg.Facility  IN ( 'ALL', '')
        THEN 2
        WHEN qcfg.StorerKey = 'ALL' AND
        qcfg.Facility  = @c_Facility
        THEN 6
        WHEN qcfg.StorerKey = 'ALL' AND
        qcfg.Facility  IN ( 'ALL', '')
        THEN 7
        ELSE 9
        END
    , qcfg.RowRefNo

    IF @c_PORT = ''
    BEGIN
        SET @n_Continue = 3
        SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err)
        SET @n_Err      = 62100
        SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Q-Commander TCP Socket not setup'
            + '. (isp_AutoTransferQueueTask)( SQLSvr MESSAGE='
            + RTRIM(@c_Errmsg) + ' ) '
        GOTO EXIT_SP
    END

    SET @c_ExecCmd = '[dbo].[ispAutoTransferShortDateStock] @c_Listname=''' + @c_Listname + ''',@c_Storerkey=''' + @c_Storerkey + ''''

    BEGIN TRY
        EXEC isp_QCmd_SubmitTaskToQCommander
                 @cTaskType         = @c_TaskType -- D=By Datastream, T=Transmitlog, O=Others
                ,  @cStorerKey        = @c_StorerKey
                ,  @cDataStream       = @c_DataStream
                ,  @cCmdType          = @c_CmdType
                ,  @cCommand          = @c_ExecCmd
                ,  @cTransmitlogKey   = @c_TransmitlogKey
                ,  @nThreadPerAcct    = @n_ThreadPerAcct
                ,  @nThreadPerStream  = @n_ThreadPerStream
                ,  @nMilisecondDelay  = @n_MilisecondDelay
                ,  @nSeq              = 1
                ,  @cIP               = @c_IP
                ,  @cPORT             = @c_PORT
                ,  @cIniFilePath      = @c_IniFilePath
                ,  @cAPPDBName        = @c_APP_DB_Name
                ,  @bSuccess          = @b_Success   OUTPUT
                ,  @nErr              = @n_Err       OUTPUT
                ,  @cErrMsg           = @c_ErrMsg    OUTPUT
                ,  @nPriority         = @n_Priority
    END TRY

    BEGIN CATCH
        SET @n_Continue = 3
                SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err)
                SET @n_Err      = 62105
                SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Failed to execute isp_QCmd_SubmitTaskToQCommander'
                    + '. (isp_AutoTransferQueueTask)( SQLSvr MESSAGE='
                    + RTRIM(@c_Errmsg) + ' ) '
    END CATCH

    EXIT_SP:
END
GO
GRANT EXECUTE ON [dbo].[isp_AutoTransferQueueTask] TO nSQL
GO
