IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BUILDWAVEDETAILLOG]') AND type in (N'U'))
BEGIN
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
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalPallet] [float] NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_TotalPallet] DEFAULT ('0.00')
) ON [PRIMARY]

ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD CONSTRAINT [PK__BUILDWAV__50738165783EB9A0] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=80) ON [PRIMARY]

GRANT DELETE ON  [dbo].[BUILDWAVEDETAILLOG] TO [NSQL]

GRANT INSERT ON  [dbo].[BUILDWAVEDETAILLOG] TO [NSQL]

GRANT SELECT ON  [dbo].[BUILDWAVEDETAILLOG] TO [NSQL]

GRANT UPDATE ON  [dbo].[BUILDWAVEDETAILLOG] TO [NSQL]

EXEC sp_addextendedproperty N'MS_Description', N'Build WaveDetail Log', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', NULL, NULL

EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'AddDate'

EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID creates the information.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'AddWho'

EXEC sp_addextendedproperty N'MS_Description', N'ArchiveCop purpose, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'ArchiveCop'

EXEC sp_addextendedproperty N'MS_Description', N'Batch No', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'BatchNo'

EXEC sp_addextendedproperty N'MS_Description', N'Duration', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'Duration'

EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'EditDate'

EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'EditWho'

EXEC sp_addextendedproperty N'MS_Description', N'Identity row running no ', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'RowRef'

EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'Storerkey'

EXEC sp_addextendedproperty N'MS_Description', N'Total Cube', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'TotalCube'

EXEC sp_addextendedproperty N'MS_Description', N'Total Order Count', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'TotalOrderCnt'

EXEC sp_addextendedproperty N'MS_Description', N'Total Order Qty', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'TotalOrderQty'

EXEC sp_addextendedproperty N'MS_Description', N'Total Weight', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'TotalWeight'

EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'TrafficCop'

EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 01', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'UDF01'

EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 02', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'UDF02'

EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 03', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'UDF03'

EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 04', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'UDF04'

EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 05', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'UDF05'

EXEC sp_addextendedproperty N'MS_Description', N'Wave #', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'Wavekey'

EXEC sp_addextendedproperty N'MS_Description', N'Total Pallet', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'TotalPallet'

END


ELSE 
BEGIN 

			IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'TotalPallet' AND Object_ID = Object_ID('dbo.BUILDWAVEDETAILLOG'))
			BEGIN
				ALTER TABLE dbo.BUILDWAVEDETAILLOG ADD TotalPallet [float] NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_TotalPallet] DEFAULT ('0.00');
				EXEC sp_addextendedproperty N'MS_Description', N'Total Pallet', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVEDETAILLOG', 'COLUMN', N'TotalPallet'
				
			END


END
