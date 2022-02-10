CREATE TABLE [dbo].[BUILDWAVEDETAILLOG]
(
[RowRef] [bigint] NOT NULL IDENTITY(1, 1),
[BatchNo] [bigint] NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_BatchNo] DEFAULT ((0)),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_Storerkey] DEFAULT (''),
[Wavekey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_Wavekey] DEFAULT (''),
[Duration] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_Duration] DEFAULT (''),
[TotalOrderCnt] [int] NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_TotalOrderCnt] DEFAULT ((0)),
[TotalOrderQty] [int] NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_TotalOrderQty] DEFAULT ((0)),
[TotalWeight] [float] NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_TotalWeight] DEFAULT ((0)),
[TotalCube] [float] NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_TotalCube] DEFAULT ((0)),
[UDF01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_UDF01] DEFAULT (''),
[UDF02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_UDF02] DEFAULT (''),
[UDF03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_UDF03] DEFAULT (''),
[UDF04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_UDF04] DEFAULT (''),
[UDF05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_UDF05] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD CONSTRAINT [PK__BUILDWAV__50738165783EB9A0] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BUILDWAVEDETAILLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BUILDWAVEDETAILLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BUILDWAVEDETAILLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BUILDWAVEDETAILLOG] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build WaveDetail Log', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID creates the information.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ArchiveCop purpose, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Batch No', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'BatchNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Duration', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'Duration'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Identity row running no ', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total Cube', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'TotalCube'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total Order Count', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'TotalOrderCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total Order Qty', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'TotalOrderQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total Weight', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'TotalWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 01', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'UDF01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 02', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'UDF02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 03', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'UDF03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 04', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'UDF04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 05', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'UDF05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Wave #', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'Wavekey'
GO
