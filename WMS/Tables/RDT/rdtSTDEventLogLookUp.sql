CREATE TABLE [RDT].[rdtSTDEventLogLookUp]
(
[RowRef] [bigint] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLogLookUp_StorerKey] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSTDEventLogLookUp_Facility] DEFAULT (''),
[Category] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSTDEventLogLookUp_Category] DEFAULT (''),
[CategoryDescr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLogLookUp_CategoryDescr] DEFAULT (''),
[SubCategory] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLogLookUp_SubCategory] DEFAULT (''),
[SubCategoryDescr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLogLookUp_SubCategoryDescr] DEFAULT (''),
[FunctionID] [int] NULL CONSTRAINT [DF_rdtSTDEventLogLookUp_FunctionID] DEFAULT ('0'),
[AddDate] [datetime] NULL CONSTRAINT [DF_rdtSTDEventLogLookUp_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLogLookUp_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_rdtSTDEventLogLookUp_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLogLookUp_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtSTDEventLogLookUp] ADD CONSTRAINT [PK_rdtSTDEventLogLookUp] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtSTDEventLogLookUp] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtSTDEventLogLookUp] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtSTDEventLogLookUp] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtSTDEventLogLookUp] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'AddDate', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLogLookUp', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'AddWho', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLogLookUp', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ArchiveCop', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLogLookUp', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Category', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLogLookUp', 'COLUMN', N'Category'
GO
EXEC sp_addextendedproperty N'MS_Description', N'CategoryDescr', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLogLookUp', 'COLUMN', N'CategoryDescr'
GO
EXEC sp_addextendedproperty N'MS_Description', N'EditDate', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLogLookUp', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'EditWho', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLogLookUp', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Facility', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLogLookUp', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'FunctionID', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLogLookUp', 'COLUMN', N'FunctionID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RowRef', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLogLookUp', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', N'StorerKey', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLogLookUp', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'SubCategory', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLogLookUp', 'COLUMN', N'SubCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'SubCategoryDescr', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLogLookUp', 'COLUMN', N'SubCategoryDescr'
GO
EXEC sp_addextendedproperty N'MS_Description', N'TrafficCop', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLogLookUp', 'COLUMN', N'TrafficCop'
GO
