SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BUILDWAVEDETAILLOG]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BUILDWAVEDETAILLOG](
	[RowRef] [bigint] IDENTITY(1,1) NOT NULL,
	[BatchNo] [bigint] NOT NULL,
	[Storerkey] [nvarchar](15) NOT NULL,
	[Wavekey] [nvarchar](10) NOT NULL,
	[Duration] [nvarchar](12) NOT NULL,
	[TotalOrderCnt] [int] NOT NULL,
	[TotalOrderQty] [int] NOT NULL,
	[TotalWeight] [float] NOT NULL,
	[TotalCube] [float] NOT NULL,
	[UDF01] [nvarchar](30) NOT NULL,
	[UDF02] [nvarchar](30) NOT NULL,
	[UDF03] [nvarchar](30) NOT NULL,
	[UDF04] [nvarchar](30) NOT NULL,
	[UDF05] [nvarchar](30) NOT NULL,
	[AddWho] [nvarchar](128) NOT NULL,
	[AddDate] [datetime] NOT NULL,
	[EditWho] [nvarchar](128) NOT NULL,
	[EditDate] [datetime] NOT NULL,
	[TrafficCop] [nchar](1) NULL,
	[ArchiveCop] [nchar](1) NULL,
	[TotalPallet] [float] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RowRef] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


SET ANSI_PADDING ON
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[BUILDWAVEDETAILLOG]') AND name = N'IDX_BuildWaveDetailLog_WaveKey')
CREATE NONCLUSTERED INDEX [IDX_BuildWaveDetailLog_WaveKey] ON [dbo].[BUILDWAVEDETAILLOG]
(
	[Wavekey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BUILDWAVEDETAILLOG_BatchNo]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD  CONSTRAINT [DF_BUILDWAVEDETAILLOG_BatchNo]  DEFAULT ((0)) FOR [BatchNo]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BUILDWAVEDETAILLOG_Storerkey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD  CONSTRAINT [DF_BUILDWAVEDETAILLOG_Storerkey]  DEFAULT ('') FOR [Storerkey]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BUILDWAVEDETAILLOG_Wavekey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD  CONSTRAINT [DF_BUILDWAVEDETAILLOG_Wavekey]  DEFAULT ('') FOR [Wavekey]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BUILDWAVEDETAILLOG_Duration]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD  CONSTRAINT [DF_BUILDWAVEDETAILLOG_Duration]  DEFAULT ('') FOR [Duration]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BUILDWAVEDETAILLOG_TotalOrderCnt]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD  CONSTRAINT [DF_BUILDWAVEDETAILLOG_TotalOrderCnt]  DEFAULT ((0)) FOR [TotalOrderCnt]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BUILDWAVEDETAILLOG_TotalOrderQty]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD  CONSTRAINT [DF_BUILDWAVEDETAILLOG_TotalOrderQty]  DEFAULT ((0)) FOR [TotalOrderQty]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BUILDWAVEDETAILLOG_TotalWeight]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD  CONSTRAINT [DF_BUILDWAVEDETAILLOG_TotalWeight]  DEFAULT ((0)) FOR [TotalWeight]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BUILDWAVEDETAILLOG_TotalCube]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD  CONSTRAINT [DF_BUILDWAVEDETAILLOG_TotalCube]  DEFAULT ((0)) FOR [TotalCube]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BUILDWAVEDETAILLOG_UDF01]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD  CONSTRAINT [DF_BUILDWAVEDETAILLOG_UDF01]  DEFAULT ('') FOR [UDF01]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BUILDWAVEDETAILLOG_UDF02]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD  CONSTRAINT [DF_BUILDWAVEDETAILLOG_UDF02]  DEFAULT ('') FOR [UDF02]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BUILDWAVEDETAILLOG_UDF03]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD  CONSTRAINT [DF_BUILDWAVEDETAILLOG_UDF03]  DEFAULT ('') FOR [UDF03]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BUILDWAVEDETAILLOG_UDF04]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD  CONSTRAINT [DF_BUILDWAVEDETAILLOG_UDF04]  DEFAULT ('') FOR [UDF04]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BUILDWAVEDETAILLOG_UDF05]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD  CONSTRAINT [DF_BUILDWAVEDETAILLOG_UDF05]  DEFAULT ('') FOR [UDF05]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BUILDWAVEDETAILLOG_AddWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD  CONSTRAINT [DF_BUILDWAVEDETAILLOG_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BUILDWAVEDETAILLOG_AddDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD  CONSTRAINT [DF_BUILDWAVEDETAILLOG_AddDate]  DEFAULT (getdate()) FOR [AddDate]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BUILDWAVEDETAILLOG_EditWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD  CONSTRAINT [DF_BUILDWAVEDETAILLOG_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BUILDWAVEDETAILLOG_EditDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD  CONSTRAINT [DF_BUILDWAVEDETAILLOG_EditDate]  DEFAULT (getdate()) FOR [EditDate]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BUILDWAVEDETAILLOG_TotalPallet]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BUILDWAVEDETAILLOG] ADD  CONSTRAINT [DF_BUILDWAVEDETAILLOG_TotalPallet]  DEFAULT ('0.00') FOR [TotalPallet]
END

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'RowRef'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identity row running no ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'RowRef'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'BatchNo'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Batch No' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'BatchNo'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'Storerkey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Storerkey' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'Storerkey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'Wavekey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Wave #' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'Wavekey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'Duration'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Duration' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'Duration'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'TotalOrderCnt'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Total Order Count' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'TotalOrderCnt'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'TotalOrderQty'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Total Order Qty' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'TotalOrderQty'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'TotalWeight'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Total Weight' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'TotalWeight'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'TotalCube'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Total Cube' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'TotalCube'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'UDF01'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Userdefine column 01' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'UDF01'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'UDF02'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Userdefine column 02' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'UDF02'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'UDF03'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Userdefine column 03' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'UDF03'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'UDF04'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Userdefine column 04' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'UDF04'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'UDF05'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Userdefine column 05' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'UDF05'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'AddWho'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID creates the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'AddWho'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'AddDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The date in which the load is created' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'AddDate'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'EditWho'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID edited/modified/updated the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'EditWho'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'EditDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of the information edited/modified/updated. (System date)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'EditDate'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'TrafficCop'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'TrafficCop'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'ArchiveCop'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ArchiveCop purpose, fields updated in this table will not trigger to update other tables that are linked with this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'ArchiveCop'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', N'COLUMN',N'TotalPallet'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Total Pallet' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'TotalPallet'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BUILDWAVEDETAILLOG', NULL,NULL))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Build WaveDetail Log' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG'

END
ELSE
BEGIN
   --[UWP-42506]
   IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'TotalPallet' AND Object_ID = Object_ID('DBO.BUILDWAVEDETAILLOG'))
   BEGIN
      ALTER TABLE DBO.BUILDWAVEDETAILLOG ADD TotalPallet [float] NOT NULL CONSTRAINT [DF_BUILDWAVEDETAILLOG_TotalPallet] DEFAULT ('0.00');
      EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Total Pallet' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDWAVEDETAILLOG', @level2type=N'COLUMN',@level2name=N'TotalPallet'
   END

END