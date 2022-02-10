CREATE TABLE [dbo].[TRANSMITLOG]
(
[transmitlogkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tablename] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG_tablename] DEFAULT (' '),
[key1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG_key1] DEFAULT (' '),
[key2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG_key2] DEFAULT (' '),
[key3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG_key3] DEFAULT (' '),
[transmitflag] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG_transmitflag] DEFAULT ('0'),
[transmitbatch] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSMITLOG_transmitbatch] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TRANSMITLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TRANSMITLOG_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TRANSMITLOG] ADD CONSTRAINT [PKTRANSMITLOG] PRIMARY KEY CLUSTERED ([transmitlogkey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TRANSMITLOG_KEY1] ON [dbo].[TRANSMITLOG] ([key1], [key2]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TRANSMITLOG_KEY3] ON [dbo].[TRANSMITLOG] ([key3]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TRANSMITLOG_CIdx] ON [dbo].[TRANSMITLOG] ([tablename], [key1], [key2], [key3]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[TRANSMITLOG] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[TRANSMITLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TRANSMITLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TRANSMITLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TRANSMITLOG] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TRANSMITLOG', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSMITLOG', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TRANSMITLOG', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSMITLOG', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSMITLOG', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Transmit Log.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSMITLOG', 'COLUMN', N'transmitlogkey'
GO
