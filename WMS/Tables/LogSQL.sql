CREATE TABLE [dbo].[LogSQL]
(
[SQLId] [int] NOT NULL IDENTITY(1, 1),
[SQLDate] [datetime] NOT NULL CONSTRAINT [DF_LogSQL_SQLDate] DEFAULT (getdate()),
[SQLDb] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SQLSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SQLProc] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SQLText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Duration] [int] NOT NULL,
[RowCnt] [int] NOT NULL,
[SourceKey] [int] NOT NULL,
[SourceTable] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SQLUser] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LogSQL_SQLUser] DEFAULT (suser_sname()),
[SQLHost] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LogSQL_SQLHost] DEFAULT (isnull(host_name(),''))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LogSQL] ADD CONSTRAINT [PK_LogSQL] PRIMARY KEY CLUSTERED ([SQLId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LogSQL] ON [dbo].[LogSQL] ([SourceTable], [SourceKey]) INCLUDE ([SQLId], [SQLText], [Duration]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LogSQL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LogSQL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LogSQL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LogSQL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Master SQL query log for all databases of current SQL Server Instance.', 'SCHEMA', N'dbo', 'TABLE', N'LogSQL', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total elapsed time it took for the command to execute.', 'SCHEMA', N'dbo', 'TABLE', N'LogSQL', 'COLUMN', N'Duration'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifier of the source table primary key. Only for integer-type PK for best practice & performance.', 'SCHEMA', N'dbo', 'TABLE', N'LogSQL', 'COLUMN', N'SourceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Source table of the SourceKey to execute the statement where it is derived from', 'SCHEMA', N'dbo', 'TABLE', N'LogSQL', 'COLUMN', N'SourceTable'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The date and time the statement was logged.', 'SCHEMA', N'dbo', 'TABLE', N'LogSQL', 'COLUMN', N'SQLDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Database name of the statement.', 'SCHEMA', N'dbo', 'TABLE', N'LogSQL', 'COLUMN', N'SQLDb'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Workstation name which the statement executed.', 'SCHEMA', N'dbo', 'TABLE', N'LogSQL', 'COLUMN', N'SQLHost'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifier of the SQL statement.', 'SCHEMA', N'dbo', 'TABLE', N'LogSQL', 'COLUMN', N'SQLId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the stored procedure or trigger where an statement executed.', 'SCHEMA', N'dbo', 'TABLE', N'LogSQL', 'COLUMN', N'SQLProc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Schema name of the stored procedure or trigger.', 'SCHEMA', N'dbo', 'TABLE', N'LogSQL', 'COLUMN', N'SQLSchema'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full query text of the statement.', 'SCHEMA', N'dbo', 'TABLE', N'LogSQL', 'COLUMN', N'SQLText'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Login name who execute the statement', 'SCHEMA', N'dbo', 'TABLE', N'LogSQL', 'COLUMN', N'SQLUser'
GO
