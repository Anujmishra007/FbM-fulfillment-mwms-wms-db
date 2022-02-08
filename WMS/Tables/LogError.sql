CREATE TABLE [dbo].[LogError]
(
[ErrId] [int] NOT NULL IDENTITY(1, 1),
[ErrDate] [datetime] NOT NULL CONSTRAINT [DF_LogError_ErrDate] DEFAULT (getdate()),
[ErrDb] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ErrSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ErrProc] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ErrLine] [int] NOT NULL,
[ErrMsg] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ErrNo] [int] NOT NULL,
[ErrSeverity] [tinyint] NOT NULL,
[ErrState] [tinyint] NOT NULL,
[Success] [bit] NOT NULL,
[SourceKey] [int] NOT NULL,
[SourceTable] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ErrUser] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LogError_ErrUser] DEFAULT (suser_sname()),
[ErrHost] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LogError_ErrHost] DEFAULT (isnull(host_name(),''))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LogError] ADD CONSTRAINT [PK_LogError] PRIMARY KEY CLUSTERED ([ErrId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LogError] ON [dbo].[LogError] ([SourceTable], [SourceKey]) INCLUDE ([ErrId], [ErrMsg], [ErrNo]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LogError] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LogError] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LogError] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LogError] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Master Error Log for all databases of current SQL Server Instance.', 'SCHEMA', N'dbo', 'TABLE', N'LogError', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'The date and time the error was logged.', 'SCHEMA', N'dbo', 'TABLE', N'LogError', 'COLUMN', N'ErrDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Database name of the error occurred that caused the CATCH block.', 'SCHEMA', N'dbo', 'TABLE', N'LogError', 'COLUMN', N'ErrDb'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Workstation name which caused the error.', 'SCHEMA', N'dbo', 'TABLE', N'LogError', 'COLUMN', N'ErrHost'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifier of the error.', 'SCHEMA', N'dbo', 'TABLE', N'LogError', 'COLUMN', N'ErrId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Line number of the error.', 'SCHEMA', N'dbo', 'TABLE', N'LogError', 'COLUMN', N'ErrLine'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Message text of the error.', 'SCHEMA', N'dbo', 'TABLE', N'LogError', 'COLUMN', N'ErrMsg'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of the error message.', 'SCHEMA', N'dbo', 'TABLE', N'LogError', 'COLUMN', N'ErrNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the stored procedure or trigger where an error occurred.', 'SCHEMA', N'dbo', 'TABLE', N'LogError', 'COLUMN', N'ErrProc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Schema name of the stored procedure or trigger.', 'SCHEMA', N'dbo', 'TABLE', N'LogError', 'COLUMN', N'ErrSchema'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Severity level of the message, between 1 and 25.', 'SCHEMA', N'dbo', 'TABLE', N'LogError', 'COLUMN', N'ErrSeverity'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State number of the error.', 'SCHEMA', N'dbo', 'TABLE', N'LogError', 'COLUMN', N'ErrState'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Login name who caused the error', 'SCHEMA', N'dbo', 'TABLE', N'LogError', 'COLUMN', N'ErrUser'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifier of the source table primary key. Only for integer-type PK for best practice & performance.', 'SCHEMA', N'dbo', 'TABLE', N'LogError', 'COLUMN', N'SourceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Source table of the SourceKey that raise the error.', 'SCHEMA', N'dbo', 'TABLE', N'LogError', 'COLUMN', N'SourceTable'
GO
EXEC sp_addextendedproperty N'MS_Description', '0 = Failed; 1 = Succeeded.', 'SCHEMA', N'dbo', 'TABLE', N'LogError', 'COLUMN', N'Success'
GO
