CREATE TABLE [dbo].[ITFTriggerConfig]
(
[SeqNo] [int] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITFTriggerConfig_Facility] DEFAULT (' '),
[ConfigKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Tablename] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITFTriggerConfig_RecordType] DEFAULT (' '),
[RecordStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITFTriggerConfig_RecordStatus] DEFAULT (' '),
[sValue] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITFTriggerConfig_sValue] DEFAULT (' '),
[SourceTable] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TargetTable] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StoredProc] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITFTriggerConfig_StoredProc] DEFAULT (' '),
[UpdatedColumns] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITFTriggerConfig_UpdatedColumns] DEFAULT (''),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ITFTriggerConfig_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITFTriggerConfig_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ITFTriggerConfig_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITFTriggerConfig_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QCommanderSP] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ITFTriggerConfig_QCommanderSP] DEFAULT (' ')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ITFTriggerConfig] ADD CONSTRAINT [PKITFTriggerConfig] PRIMARY KEY CLUSTERED ([SeqNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ITFTRIGGERCONFIG_SOURCETABLE] ON [dbo].[ITFTriggerConfig] ([SourceTable], [StorerKey], [sValue]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ITFTriggerConfig_CIdx] ON [dbo].[ITFTriggerConfig] ([StorerKey], [Facility], [ConfigKey], [Tablename], [SourceTable]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ITFTriggerConfig] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ITFTriggerConfig] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ITFTriggerConfig] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ITFTriggerConfig] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Queue Commander Stored Procedure', 'SCHEMA', N'dbo', 'TABLE', N'ITFTriggerConfig', 'COLUMN', N'QCommanderSP'
GO
