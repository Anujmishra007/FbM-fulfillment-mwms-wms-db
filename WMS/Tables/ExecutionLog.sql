ALTER TABLE [dbo].[ExecutionLog] ADD
[ErrNo] [int] NOT NULL CONSTRAINT [DF_ExecutionLog_ErrNo] DEFAULT ((0)),
[ErrMsg] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ExecutionLog_ErrMsg] DEFAULT (''),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL

EXEC sp_addextendedproperty N'MS_Description', 'Execution Log statistics to trace the sql object performance', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Client application name for the current session, if the application sets that name value.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'AppName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Archive flag. When a record''s ArchiveCop is set (i.e. marked as ''9'') according to retention policy, that means it is ready to be archived by next scheduled archiving process.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer unique code or client identifier or storer key.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'ClientId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Message text of the error that caused the CATCH block of a TRY...CATCH construct to execute.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'ErrMsg'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Error Number of the error that caused the CATCH block of a TRY...CATCH construct to execute.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'ErrNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Workstation Host Name which caused the log.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'HostName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Client IP address that tries to connect to this server.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'IP'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identification number of the log.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'LogId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Nesting level of the current stored procedure execution (initially 0) on the local server.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'NestLvl'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Input parameters allow the caller to pass a data value to the stored procedure.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'ParamIn'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Output parameters here usually store useful values of the result, such as dynamic sql statement, etc.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'ParamOut'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of rows returned from queries.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'RowCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Schema name of the stored procedure or trigger.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'Sch'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the Stored Procedure or trigger where an execution occurred.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'SP'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Start and end times that indicate the duration of a execution process.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'TimeEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The date and time the execution was started to log.', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'TimeStart'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Name who logged', 'SCHEMA', N'dbo', 'TABLE', N'ExecutionLog', 'COLUMN', N'UserName'
GO
