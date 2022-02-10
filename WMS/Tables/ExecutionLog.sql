CREATE TABLE [dbo].[ExecutionLog]
(
[LogId] [int] NOT NULL IDENTITY(1, 1),
[TimeStart] [datetime] NOT NULL CONSTRAINT [DF_ExecutionLog_TimeStart] DEFAULT (getdate()),
[TimeEnd] [datetime] NULL,
[ClientId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ExecutionLog_ClientId] DEFAULT (''),
[ParamIn] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ExecutionLog_ParamIn] DEFAULT (''),
[ParamOut] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowCnt] [int] NOT NULL CONSTRAINT [DF_ExecutionLog_RowCnt] DEFAULT ((0)),
[Sch] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ExecutionLog_LogSchema] DEFAULT (isnull(object_schema_name(@@procid),'')),
[SP] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ExecutionLog_LogProc] DEFAULT (isnull(object_name(@@procid),'')),
[UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ExecutionLog_LogUser] DEFAULT (suser_sname()),
[HostName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ExecutionLog_LogHost] DEFAULT (isnull(host_name(),'')),
[IP] [varchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ExecutionLog_IP] DEFAULT (isnull(TRY_CAST(connectionproperty('client_net_address') AS [varchar](48)),'')),
[AppName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ExecutionLog_LogApp] DEFAULT (isnull(app_name(),'')),
[NestLvl] [tinyint] NOT NULL CONSTRAINT [DF_ExecutionLog_NestLvl] DEFAULT (@@nestlevel)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ExecutionLog] ADD CONSTRAINT [PK_ExecutionLog] PRIMARY KEY CLUSTERED  ([LogId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ExecutionLog_TimeStart] ON [dbo].[ExecutionLog] ([TimeStart]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Execution Log statistics to trace the sql object performance', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Workstation Host Name which caused the log.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'HostName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifier of the log.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'LogId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Schema name of the stored procedure or trigger.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'Sch'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the Stored Procedure or trigger where an execution occurred.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'SP'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The date and time the execution was logged.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'TimeStart'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Name who logged', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'UserName'
GO
