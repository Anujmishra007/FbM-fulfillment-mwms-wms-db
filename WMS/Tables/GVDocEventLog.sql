CREATE TABLE [dbo].[GVDocEventLog]
(
[Rowref] [bigint] NOT NULL IDENTITY(1, 1),
[DocumentNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Transdate] [datetime] NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DocStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GVDocEventLog_DocStatus] DEFAULT (''),
[Event_LOC] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GVDocEventLog_Event_LOC] DEFAULT (''),
[Event_Country] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GVDocEventLog_Event_Country] DEFAULT (''),
[Source_Order] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GVDocEventLog_Source_Order] DEFAULT (''),
[Event_Code] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GVDocEventLog_Event_Code] DEFAULT (''),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GVDocEventLog_Status] DEFAULT ('0'),
[AddDate] [datetime] NULL CONSTRAINT [DF_GVDocEventLog_AddDate] DEFAULT (getdate()),
[EditDate] [datetime] NULL CONSTRAINT [DF_GVDocEventLog_EditDate] DEFAULT (getdate()),
[Source_LineNumber] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GVDocEventLog_Source_LineNumber] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GVDocEventLog] ADD CONSTRAINT [PK__GVDocEve__78C977970F0C377C] PRIMARY KEY CLUSTERED ([Rowref]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[GVDocEventLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[GVDocEventLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[GVDocEventLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[GVDocEventLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Data Add Date', 'SCHEMA', N'dbo', 'TABLE', N'GVDocEventLog', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tranasaction Document Status', 'SCHEMA', N'dbo', 'TABLE', N'GVDocEventLog', 'COLUMN', N'DocStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Transaction Document Number', 'SCHEMA', N'dbo', 'TABLE', N'GVDocEventLog', 'COLUMN', N'DocumentNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Data Edit Date', 'SCHEMA', N'dbo', 'TABLE', N'GVDocEventLog', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Event Code', 'SCHEMA', N'dbo', 'TABLE', N'GVDocEventLog', 'COLUMN', N'Event_Code'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Event DC Country', 'SCHEMA', N'dbo', 'TABLE', N'GVDocEventLog', 'COLUMN', N'Event_Country'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Event DC Location', 'SCHEMA', N'dbo', 'TABLE', N'GVDocEventLog', 'COLUMN', N'Event_LOC'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System Running number', 'SCHEMA', N'dbo', 'TABLE', N'GVDocEventLog', 'COLUMN', N'Rowref'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source Reference', 'SCHEMA', N'dbo', 'TABLE', N'GVDocEventLog', 'COLUMN', N'Source_Order'
GO
EXEC sp_addextendedproperty N'MS_Description', N'GVT Staging Data Status', 'SCHEMA', N'dbo', 'TABLE', N'GVDocEventLog', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storer Client ID', 'SCHEMA', N'dbo', 'TABLE', N'GVDocEventLog', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tranasaction Date', 'SCHEMA', N'dbo', 'TABLE', N'GVDocEventLog', 'COLUMN', N'Transdate'
GO
