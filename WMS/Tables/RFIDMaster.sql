CREATE TABLE [dbo].[RFIDMaster]
(
[RFIDMasterKey] [bigint] NOT NULL IDENTITY(1, 1),
[RFIDNo] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RFIDMaster_RFIDNo] DEFAULT (''),
[TIDNo] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RFIDMaster_TIDNo] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Source] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RFIDMaster_Source] DEFAULT (''),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RFIDMaster_Status] DEFAULT ('0'),
[DocRefno1] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocRefno2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocRefno3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocRefno4] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocRefno5] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RFIDMaster_Addwho] DEFAULT (suser_sname()),
[Adddate] [datetime] NOT NULL CONSTRAINT [DF_RFIDMaster_Adddate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RFIDMaster_Editwho] DEFAULT (suser_sname()),
[Editdate] [datetime] NOT NULL CONSTRAINT [DF_RFIDMaster_Editdate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RFIDMaster] ADD CONSTRAINT [PKRFIDMaster] PRIMARY KEY CLUSTERED ([RFIDMasterKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RFIDMaster_RFIDNo] ON [dbo].[RFIDMaster] ([RFIDNo], [TIDNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RFIDMaster_SKU] ON [dbo].[RFIDMaster] ([Storerkey], [SKU]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RFIDMaster] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[RFIDMaster] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[RFIDMaster] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[RFIDMaster] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Added Date', 'SCHEMA', N'dbo', 'TABLE', N'RFIDMaster', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Added By Person', 'SCHEMA', N'dbo', 'TABLE', N'RFIDMaster', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'RFIDMaster', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Document Reference 1', 'SCHEMA', N'dbo', 'TABLE', N'RFIDMaster', 'COLUMN', N'DocRefno1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Document Reference 2', 'SCHEMA', N'dbo', 'TABLE', N'RFIDMaster', 'COLUMN', N'DocRefno2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Document Reference 3', 'SCHEMA', N'dbo', 'TABLE', N'RFIDMaster', 'COLUMN', N'DocRefno3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Document Reference 4', 'SCHEMA', N'dbo', 'TABLE', N'RFIDMaster', 'COLUMN', N'DocRefno4'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Document Reference 5', 'SCHEMA', N'dbo', 'TABLE', N'RFIDMaster', 'COLUMN', N'DocRefno5'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Last Updated Date', 'SCHEMA', N'dbo', 'TABLE', N'RFIDMaster', 'COLUMN', N'Editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Last Updated By Person', 'SCHEMA', N'dbo', 'TABLE', N'RFIDMaster', 'COLUMN', N'Editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Table Auto Running number', 'SCHEMA', N'dbo', 'TABLE', N'RFIDMaster', 'COLUMN', N'RFIDMasterKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RF ID number', 'SCHEMA', N'dbo', 'TABLE', N'RFIDMaster', 'COLUMN', N'RFIDNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The SKU being ordered.', 'SCHEMA', N'dbo', 'TABLE', N'RFIDMaster', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', N'From Source', 'SCHEMA', N'dbo', 'TABLE', N'RFIDMaster', 'COLUMN', N'Source'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Document Status', 'SCHEMA', N'dbo', 'TABLE', N'RFIDMaster', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'RFIDMaster', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RF TID number', 'SCHEMA', N'dbo', 'TABLE', N'RFIDMaster', 'COLUMN', N'TIDNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'RFIDMaster', 'COLUMN', N'TrafficCop'
GO
