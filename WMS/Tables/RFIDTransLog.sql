CREATE TABLE [dbo].[RFIDTransLog]
(
[RFIDTransLogKey] [bigint] NOT NULL IDENTITY(1, 1),
[RFIDNo] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RFIDTransLog_RFIDNo] DEFAULT (''),
[TIDNo] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RFIDTransLog_TIDNo] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TranType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RFIDTransLog_TranType] DEFAULT (''),
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RFIDTransLog_Addwho] DEFAULT (suser_sname()),
[Adddate] [datetime] NOT NULL CONSTRAINT [DF_RFIDTransLog_Adddate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RFIDTransLog_Editwho] DEFAULT (suser_sname()),
[Editdate] [datetime] NOT NULL CONSTRAINT [DF_RFIDTransLog_Editdate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RFIDTransLog] ADD CONSTRAINT [PKRFIDTransLog] PRIMARY KEY CLUSTERED ([RFIDTransLogKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RFIDTransLog_RFIDNo] ON [dbo].[RFIDTransLog] ([RFIDNo], [TIDNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RFIDTransLog_Storerkey] ON [dbo].[RFIDTransLog] ([Storerkey], [SKU]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RFIDTransLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[RFIDTransLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[RFIDTransLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[RFIDTransLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Added Date', 'SCHEMA', N'dbo', 'TABLE', N'RFIDTransLog', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Added By Person', 'SCHEMA', N'dbo', 'TABLE', N'RFIDTransLog', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'RFIDTransLog', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Last Updated Date', 'SCHEMA', N'dbo', 'TABLE', N'RFIDTransLog', 'COLUMN', N'Editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Last Updated By Person', 'SCHEMA', N'dbo', 'TABLE', N'RFIDTransLog', 'COLUMN', N'Editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RF ID number', 'SCHEMA', N'dbo', 'TABLE', N'RFIDTransLog', 'COLUMN', N'RFIDNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Table Auto Running number', 'SCHEMA', N'dbo', 'TABLE', N'RFIDTransLog', 'COLUMN', N'RFIDTransLogKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The SKU being ordered.', 'SCHEMA', N'dbo', 'TABLE', N'RFIDTransLog', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'RFIDTransLog', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RF TID number', 'SCHEMA', N'dbo', 'TABLE', N'RFIDTransLog', 'COLUMN', N'TIDNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'RFIDTransLog', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Transaction Type.', 'SCHEMA', N'dbo', 'TABLE', N'RFIDTransLog', 'COLUMN', N'TranType'
GO
