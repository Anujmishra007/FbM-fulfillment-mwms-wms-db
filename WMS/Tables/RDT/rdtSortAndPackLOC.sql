CREATE TABLE [RDT].[rdtSortAndPackLOC]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortAndPackLOC_StorerKey] DEFAULT (''),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortAndPackLOC_LoadKey] DEFAULT (''),
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortAndPackLOC_ConsigneeKey] DEFAULT (''),
[SortLOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortAndPackLOC_SortLOC] DEFAULT (''),
[AddWho] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortAndPackLOC_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtSortAndPackLOC_AddDate] DEFAULT (getdate()),
[OptimizeCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtSortAndPackLOC] ADD CONSTRAINT [PK_rdtSortAndPackLOC] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtSortAndPackLOC] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtSortAndPackLOC] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtSortAndPackLOC] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtSortAndPackLOC] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Temporary table use in sorting, for distribute stock to logical LOC', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLOC', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'AddDate     ', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLOC', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'AddWho      ', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLOC', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ArchiveCop  ', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLOC', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ConsigneeKey', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLOC', 'COLUMN', N'ConsigneeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'LoadKey     ', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLOC', 'COLUMN', N'LoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OptimizeCop ', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLOC', 'COLUMN', N'OptimizeCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'RowRef      ', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLOC', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Logical LOC ', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLOC', 'COLUMN', N'SortLOC'
GO
EXEC sp_addextendedproperty N'MS_Description', 'StorerKey   ', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLOC', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'TrafficCop  ', 'SCHEMA', N'RDT', 'TABLE', N'rdtSortAndPackLOC', 'COLUMN', N'TrafficCop'
GO
