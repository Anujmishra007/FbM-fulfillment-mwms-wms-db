CREATE TABLE [RDT].[rdtSortAndPackLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Mobile] [int] NULL,
[Username] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSortAndPackLog_PickSlipNo] DEFAULT (''),
[CartonNo] [int] NULL CONSTRAINT [DF_rdtSortAndPackLog_CartonNo] DEFAULT ((0)),
[LabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSortAndPackLog_LabelNo] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortAndPackLog_SKU] DEFAULT (''),
[UCC] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortAndPackLog_UCC] DEFAULT (''),
[Qty] [int] NOT NULL CONSTRAINT [DF_rdtSortAndPackLog_Qty] DEFAULT ((0)),
[CartonType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortAndPackLog_CartonType] DEFAULT (''),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortAndPackLog_Status] DEFAULT ('0'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortAndPackLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtSortAndPackLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortAndPackLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtSortAndPackLog_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BatchKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSortAndPackLog_BatchKey] DEFAULT (''),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSortAndPackLog_WaveKey] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtSortAndPackLog] ADD CONSTRAINT [PK_rdtSortAndPackLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtSortAndPackLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtSortAndPackLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtSortAndPackLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtSortAndPackLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record addate', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLog', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record added by', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLog', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Batch Key', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLog', 'COLUMN', N'BatchKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Carton No for item sort/pack', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLog', 'COLUMN', N'CartonNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Carton type for item sort/pack', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLog', 'COLUMN', N'CartonType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record editdate', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLog', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record editded by', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLog', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Label No for item sort/pack', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLog', 'COLUMN', N'LabelNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'LoadKey for item sort/pack', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLog', 'COLUMN', N'LoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Mobile No', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLog', 'COLUMN', N'Mobile'
GO
EXEC sp_addextendedproperty N'MS_Description', N'PickSlipNo for item sort/pack', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLog', 'COLUMN', N'PickSlipNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'How many qty to pick/sort', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLog', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Table unique row reference', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLog', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', N'SKU code for item sort/pack', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLog', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record status', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLog', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'StorerKey for item sort/pack', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLog', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UCC no for item sort/pack', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLog', 'COLUMN', N'UCC'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Name', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLog', 'COLUMN', N'Username'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Wave Key', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLog', 'COLUMN', N'WaveKey'
GO
