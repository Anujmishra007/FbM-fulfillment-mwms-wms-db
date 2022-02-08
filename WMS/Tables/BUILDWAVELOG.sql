CREATE TABLE [dbo].[BUILDWAVELOG]
(
[BatchNo] [bigint] NOT NULL IDENTITY(1, 1),
[SessionNo] [bigint] NOT NULL CONSTRAINT [DF_BUILDWAVELOG_SessionNo] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_Facility] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_Storerkey] DEFAULT (''),
[BuildParmGroup] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_BuildParmGroup] DEFAULT (''),
[BuildParmKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_BuildParmKey] DEFAULT (''),
[BuildParmString] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_BuildParmString] DEFAULT (''),
[Duration] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_Duration] DEFAULT (''),
[TotalWaveCnt] [int] NOT NULL CONSTRAINT [DF_BUILDWAVELOG_TotalWaveCnt] DEFAULT ((0)),
[UDF01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_UDF01] DEFAULT (''),
[UDF02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_UDF02] DEFAULT (''),
[UDF03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_UDF03] DEFAULT (''),
[UDF04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_UDF04] DEFAULT (''),
[UDF05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_UDF05] DEFAULT (''),
[Status] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_Status] DEFAULT ('0'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BUILDWAVELOG_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BUILDWAVELOG_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BUILDWAVELOG] ADD CONSTRAINT [PK_BUILDWAVELOG] PRIMARY KEY CLUSTERED ([BatchNo]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_BUILDWAVELOG_SessionNo] ON [dbo].[BUILDWAVELOG] ([SessionNo]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BUILDWAVELOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BUILDWAVELOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BUILDWAVELOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BUILDWAVELOG] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Wave Log', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID creates the information.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ArchiveCop purpose, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Batch No', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'BatchNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Wave Parameter Group', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'BuildParmGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Wave Parameter Code', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'BuildParmKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Wave Parameter SQL', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'BuildParmString'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Duration', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'Duration'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Facility', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Wave SessionNo', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'SessionNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total Wave Count', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'TotalWaveCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 01', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'UDF01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 02', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'UDF02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 03', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'UDF03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 04', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'UDF04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 05', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'UDF05'
GO
