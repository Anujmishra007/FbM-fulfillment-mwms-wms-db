CREATE TABLE [dbo].[BuildLoadLog]
(
[BatchNo] [bigint] NOT NULL IDENTITY(1, 1),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_Facility] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_Storerkey] DEFAULT (''),
[BuildParmGroup] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_BuildParmGroup] DEFAULT (''),
[BuildParmCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_BuildParmCode] DEFAULT (''),
[BuildParmString] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_BuildParmString] DEFAULT (''),
[Duration] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_Duration] DEFAULT (''),
[TotalLoadCnt] [int] NOT NULL CONSTRAINT [DF_BuildLoadLog_TotalLoadCnt] DEFAULT ((0)),
[UDF01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_UDF01] DEFAULT (''),
[UDF02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_UDF02] DEFAULT (''),
[UDF03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_UDF03] DEFAULT (''),
[UDF04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_UDF04] DEFAULT (''),
[UDF05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_UDF05] DEFAULT (''),
[Status] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_Status] DEFAULT ('0'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BuildLoadLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BuildLoadLog_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[BuildLoadLog] ADD CONSTRAINT [PK__BuildLoa__5D56EB970ADA8D4A] PRIMARY KEY CLUSTERED ([BatchNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_BuildLoadLog_Loadkey] ON [dbo].[BuildLoadLog] ([Facility], [Storerkey], [AddWho], [AddDate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BuildLoadLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BuildLoadLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BuildLoadLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BuildLoadLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Loadplan Log', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID creates the information.', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ArchiveCop purpose, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Batch No', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'BatchNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Load Plan Parameter Code', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'BuildParmCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Load Plan Parameter Group', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'BuildParmGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Load Plan Parameter SQL', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'BuildParmString'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Duration', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'Duration'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total Load Plan Count', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'TotalLoadCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 01', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'UDF01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 02', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'UDF02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 03', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'UDF03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 04', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'UDF04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 05', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'UDF05'
GO
