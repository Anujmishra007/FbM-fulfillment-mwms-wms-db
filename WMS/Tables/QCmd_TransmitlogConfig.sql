CREATE TABLE [dbo].[QCmd_TransmitlogConfig]
(
[RowRefNo] [int] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_StorerKey] DEFAULT (''),
[PhysicalTableName] [nvarchar] (50) NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_PhysicalTableName] DEFAULT (''),
[TableName] [nvarchar] (20) NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_TableName] DEFAULT (''),
[App_Name] [nvarchar] (20) NULL,
[App_DB_Name] [nvarchar] (20) NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_App_DB_Name] DEFAULT (''),
[StoredProcName] [nvarchar] (1024) NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_StoredProcName] DEFAULT (''),
[DataStream] [nvarchar] (10) NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_DataStream] DEFAULT (''),
[ThreadPerAcct] [int] NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_ThreadPerAcct] DEFAULT ((1)),
[ThreadPerStream] [int] NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_ThreadPerStream] DEFAULT ((1)),
[MilisecondDelay] [int] NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_MilisecondDelay] DEFAULT ((0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_EditWho] DEFAULT (suser_sname()),
[IP] [nvarchar] (20) NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_IP] DEFAULT (''),
[Port] [nvarchar] (5) NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_Port] DEFAULT ('0'),
[IniFilePath] [nvarchar] (200) NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_IniFilePath] DEFAULT (''),
[QCmdClass] [nvarchar] (10) NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_QCmdClass] DEFAULT (''),
[TargetDB] [nvarchar] (20) NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_TargetDB] DEFAULT (''),
[CmdType] [nvarchar] (10) NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_CmdType] DEFAULT (''),
[TaskType] [nvarchar] (1) NOT NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_TaskType] DEFAULT (''),
[SkipTryCheck] [nvarchar] (1) NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_SkipTryCheck] DEFAULT (''),
[Migration] [nvarchar] (1) NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_Migration] DEFAULT (''),
[Priority] [int] NOT NULL CONSTRAINT [DF_Qcmd_TransmitlogConfig_Priority] DEFAULT ('0'),
[StopSocketMsg] [nvarchar] (1) NULL CONSTRAINT [DF_QCmd_TransmitlogConfig_StopSocketMsg] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 

/************************************************************************/  
/* Trigger: ntrQcmd_TransmitlogConfigUpdate                             */  
/* Creation Date: 23-Oct-2017                                           */  
/* Copyright: IDS                                                       */  
/* Written by: MCTang                                                   */  
/*                                                                      */  
/* Purpose: Trigger related Update in Qcmd_TransmitlogConfig table.     */  
/*                                                                      */  
/* Input Parameters:                                                    */  
/*                                                                      */  
/* Output Parameters:                                                   */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Called By:  Interface                                                */  
/*                                                                      */  
/* PVCS Version: 1.1                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/* Date         Author    Ver.  Purposes                                */  
/************************************************************************/  
  
CREATE TRIGGER [dbo].[ntrQcmd_TransmitlogConfigUpdate]  
ON  [dbo].[QCmd_TransmitlogConfig]  
FOR UPDATE  
AS  
BEGIN   
   IF @@ROWCOUNT = 0  
   BEGIN  
      RETURN  
   END  
  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @b_debug int  
   SELECT @b_debug = 0  
   DECLARE     
     @b_Success            int         
   , @n_err                int         
   , @n_err2               int         
   , @c_errmsg             char(250)   
   , @n_continue           int  
   , @n_starttcnt          int  
   , @c_preprocess         char(250)   
   , @c_pstprocess         char(250)   
   , @n_cnt                int        
  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  
  
   IF @n_continue = 1 OR @n_continue = 2   
   BEGIN    

      UPDATE Qcmd_TransmitlogConfig   
      SET    EditWho  = SUSER_SNAME()
           , EditDate = GETDATE()
      FROM   Qcmd_TransmitlogConfig, INSERTED  
      WHERE  Qcmd_TransmitlogConfig.RowRefNo = INSERTED.RowRefNo
     
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
     
      IF @@ERROR <> 0
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=68002     
         SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))   
                           + ': Update Failed On Table Qcmd_TransmitlogConfig. (ntrQcmd_TransmitlogConfigUpdate) ( '   
                           + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '  
      END
   END
END
GO
ALTER TABLE [dbo].[QCmd_TransmitlogConfig] ADD CONSTRAINT [PK_QCmd_TransmitlogConfig] PRIMARY KEY CLUSTERED ([RowRefNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_QCmd_TransmitlogConfig_PhyClsStram] ON [dbo].[QCmd_TransmitlogConfig] ([PhysicalTableName], [App_Name], [QCmdClass], [DataStream]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_QCmd_TransmitlogConfig_PhysicalTableName_StorerKey_DataStream] ON [dbo].[QCmd_TransmitlogConfig] ([PhysicalTableName], [StorerKey], [DataStream]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_QCmd_TransmitlogConfig_StrTblPhy] ON [dbo].[QCmd_TransmitlogConfig] ([TableName], [StorerKey], [PhysicalTableName], [App_Name], [QCmdClass]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[QCmd_TransmitlogConfig] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[QCmd_TransmitlogConfig] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[QCmd_TransmitlogConfig] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[QCmd_TransmitlogConfig] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'CmdType SQL,TCL...', 'SCHEMA', N'dbo', 'TABLE', N'QCmd_TransmitlogConfig', 'COLUMN', N'CmdType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Queue Commander INIFilePath', 'SCHEMA', N'dbo', 'TABLE', N'QCmd_TransmitlogConfig', 'COLUMN', N'IniFilePath'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Queue Commander IP', 'SCHEMA', N'dbo', 'TABLE', N'QCmd_TransmitlogConfig', 'COLUMN', N'IP'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Queue Commander Port', 'SCHEMA', N'dbo', 'TABLE', N'QCmd_TransmitlogConfig', 'COLUMN', N'Port'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Queue Commander Class', 'SCHEMA', N'dbo', 'TABLE', N'QCmd_TransmitlogConfig', 'COLUMN', N'QCmdClass'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Target DataBase', 'SCHEMA', N'dbo', 'TABLE', N'QCmd_TransmitlogConfig', 'COLUMN', N'TargetDB'
GO
EXEC sp_addextendedproperty N'MS_Description', N'TaskType T/D...', 'SCHEMA', N'dbo', 'TABLE', N'QCmd_TransmitlogConfig', 'COLUMN', N'TaskType'
GO
