CREATE TABLE [dbo].[AutoAllocBatch_Log]
(
[AllocBatchNo] [bigint] NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AutoAllocBatch_Log_Facility] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AutoAllocBatch_Log_Storerkey] DEFAULT (''),
[BuildParmGroup] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AutoAllocBatch_Log_BuildParmGroup] DEFAULT (''),
[BuildParmCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AutoAllocBatch_Log_BuildParmCode] DEFAULT (''),
[BuildParmString] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AutoAllocBatch_Log_BuildParmString] DEFAULT (''),
[StrategyKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AutoAllocBatch_Log_StrategyKey] DEFAULT (''),
[Duration] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AutoAllocBatch_Log_Duration] DEFAULT (''),
[TotalOrderCnt] [int] NOT NULL CONSTRAINT [DF_AutoAllocBatch_Log_TotalOrderCnt] DEFAULT ((0)),
[Priority] [int] NULL CONSTRAINT [DF_AutoAllocBatch_Log_Priority] DEFAULT ((0)),
[UDF01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AutoAllocBatch_Log_UDF01] DEFAULT (''),
[UDF02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AutoAllocBatch_Log_UDF02] DEFAULT (''),
[UDF03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AutoAllocBatch_Log_UDF03] DEFAULT (''),
[UDF04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AutoAllocBatch_Log_UDF04] DEFAULT (''),
[UDF05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AutoAllocBatch_Log_UDF05] DEFAULT (''),
[Status] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AutoAllocBatch_Log_Status] DEFAULT ('0'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AutoAllocBatch_Log_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_AutoAllocBatch_Log_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AutoAllocBatch_Log_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_AutoAllocBatch_Log_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AutoAllocBatch_Log] ADD CONSTRAINT [PK_AutoAllocBatch_Log] PRIMARY KEY NONCLUSTERED ([AllocBatchNo]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AutoAllocBatch_Log] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[AutoAllocBatch_Log] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[AutoAllocBatch_Log] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[AutoAllocBatch_Log] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Loadplan Log', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID creates the information.', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Batch No', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'AllocBatchNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ArchiveCop purpose, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Load Plan Parameter Code', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'BuildParmCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Load Plan Parameter Group', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'BuildParmGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Load Plan Parameter SQL', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'BuildParmString'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Duration', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'Duration'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Allocation Strategy Key', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'StrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total Orders Count', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'TotalOrderCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 01', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'UDF01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 02', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'UDF02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 03', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'UDF03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 04', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'UDF04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 05', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatch_Log', 'COLUMN', N'UDF05'
GO
