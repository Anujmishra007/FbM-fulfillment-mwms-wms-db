CREATE TABLE [dbo].[InvRptLog]
(
[invrptlogkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tablename] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_InvRptLog_tablename] DEFAULT (' '),
[key1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_InvRptLog_key1] DEFAULT (' '),
[key2] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_InvRptLog_key2] DEFAULT (' '),
[key3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_InvRptLog_key3] DEFAULT (' '),
[invrptflag] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_InvRptLog_invrptflag] DEFAULT ('0'),
[flag2] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adddate] [datetime] NULL CONSTRAINT [DF_InvRptLog_adddate] DEFAULT (getdate()),
[addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_InvRptLog_addwho] DEFAULT (suser_sname()),
[editdate] [datetime] NULL CONSTRAINT [DF_InvRptLog_editdate] DEFAULT (getdate()),
[editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_InvRptLog_editwho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[InvRptLog] ADD CONSTRAINT [PKINVRPTLOG] PRIMARY KEY CLUSTERED ([invrptlogkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_INVRPTLOG_KEY1] ON [dbo].[InvRptLog] ([key1]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_INVRPTLOG_KEY1_2] ON [dbo].[InvRptLog] ([key1], [key2]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_INVRPTLOG_TABLENAME] ON [dbo].[InvRptLog] ([tablename]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IDS_INVRPTLOG_TBNM_key1_key2_key3] ON [dbo].[InvRptLog] ([tablename], [key1], [key2], [key3]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[InvRptLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[InvRptLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[InvRptLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[InvRptLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'InvRptLog', 'COLUMN', N'adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'InvRptLog', 'COLUMN', N'addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'InvRptLog', 'COLUMN', N'editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'InvRptLog', 'COLUMN', N'editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Inventory Report Log.', 'SCHEMA', N'dbo', 'TABLE', N'InvRptLog', 'COLUMN', N'invrptlogkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'InvRptLog', 'COLUMN', N'TrafficCop'
GO
