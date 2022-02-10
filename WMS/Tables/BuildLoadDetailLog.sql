CREATE TABLE [dbo].[BuildLoadDetailLog]
(
[RowRef] [bigint] NOT NULL IDENTITY(1, 1),
[BatchNo] [bigint] NOT NULL CONSTRAINT [DF_BuildLoadDetailLog_BatchNo] DEFAULT ((0)),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadDetailLog_Storerkey] DEFAULT (''),
[Loadkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadDetailLog_Loadkey] DEFAULT (''),
[Duration] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadDetailLog_Duration] DEFAULT (''),
[TotalOrderCnt] [int] NOT NULL CONSTRAINT [DF_BuildLoadDetailLog_TotalOrderCnt] DEFAULT ((0)),
[TotalOrderQty] [int] NOT NULL CONSTRAINT [DF_BuildLoadDetailLog_TotalOrderQty] DEFAULT ((0)),
[UDF01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadDetailLog_UDF01] DEFAULT (''),
[UDF02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadDetailLog_UDF02] DEFAULT (''),
[UDF03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadDetailLog_UDF03] DEFAULT (''),
[UDF04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadDetailLog_UDF04] DEFAULT (''),
[UDF05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadDetailLog_UDF05] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadDetailLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BuildLoadDetailLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadDetailLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BuildLoadDetailLog_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BuildLoadDetailLog] ADD CONSTRAINT [PK__BuildLoa__50738165A97B91AB] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_BuildLoadDetailLog_Loadkey] ON [dbo].[BuildLoadDetailLog] ([Loadkey], [BatchNo], [Storerkey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BuildLoadDetailLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BuildLoadDetailLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BuildLoadDetailLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BuildLoadDetailLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Loadplan Log', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadDetailLog', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadDetailLog', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID creates the information.', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadDetailLog', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ArchiveCop purpose, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadDetailLog', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Batch No', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadDetailLog', 'COLUMN', N'BatchNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Duration', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadDetailLog', 'COLUMN', N'Duration'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadDetailLog', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadDetailLog', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Load plan #', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadDetailLog', 'COLUMN', N'Loadkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Identity row running no ', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadDetailLog', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadDetailLog', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total Order Count', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadDetailLog', 'COLUMN', N'TotalOrderCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total Order Qty', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadDetailLog', 'COLUMN', N'TotalOrderQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadDetailLog', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 01', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadDetailLog', 'COLUMN', N'UDF01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 02', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadDetailLog', 'COLUMN', N'UDF02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 03', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadDetailLog', 'COLUMN', N'UDF03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 04', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadDetailLog', 'COLUMN', N'UDF04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 05', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadDetailLog', 'COLUMN', N'UDF05'
GO
