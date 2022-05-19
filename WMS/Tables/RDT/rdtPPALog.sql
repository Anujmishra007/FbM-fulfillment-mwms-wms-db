
IF EXISTS ( SELECT * FROM INFORMATION_SCHEMA.tables WHERE table_name = 'rdtPPALog' AND table_schema = 'RDT' )
BEGIN
DROP TABLE  [RDT].[rdtPPALog]
END
GO

CREATE TABLE [RDT].[rdtPPALog](
	[RowRef] [int] IDENTITY(1,1) NOT NULL,
	[Refkey] [nvarchar](18) NULL,
	[PickSlipno] [nvarchar](10) NULL,
	[LoadKey] [nvarchar](10) NULL,
	[Store] [nvarchar](15) NULL,
	[StorerKey] [nvarchar](15) NULL,
	[Sku] [nvarchar](20) NULL,
	[Descr] [nvarchar](60) NULL,
	[PQty] [int] NULL,
	[CQty] [int] NULL,
	[Status] [nvarchar](1) NULL,
	[UserName] [nvarchar](128) NULL,
	[AddDate] [datetime] NULL,
	[NoofCheck] [int] NULL,
	[UOMQty] [int] NULL,
	[UCC] [nvarchar](20) NULL,
	[ArchiveCop] [nvarchar](1) NULL,
	[OrderKey] [nvarchar](10) NULL,
	[DropID] [nvarchar](20) NULL,
	[EditDate] [datetime] NOT NULL,
	[EditWho] [nvarchar](128) NOT NULL,
	[Lottable01] [nvarchar](18) NOT NULL,
	[Lottable02] [nvarchar](18) NOT NULL,
	[Lottable03] [nvarchar](18) NOT NULL,
	[Lottable04] [datetime] NULL,
	[Lottable05] [datetime] NULL,
	[Lottable06] [nvarchar](30) NOT NULL,
	[Lottable07] [nvarchar](30) NOT NULL,
	[Lottable08] [nvarchar](30) NOT NULL,
	[Lottable09] [nvarchar](30) NOT NULL,
	[Lottable10] [nvarchar](30) NOT NULL,
	[Lottable11] [nvarchar](30) NOT NULL,
	[Lottable12] [nvarchar](30) NOT NULL,
	[Lottable13] [datetime] NULL,
	[Lottable14] [datetime] NULL,
	[Lottable15] [datetime] NULL,
	[ID] [nvarchar](18) NULL,
	[TaskDetailKey] [nvarchar](10) NULL,
   [DELDate] [datetime] NOT NULL,
	[DELWho] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_rdtPPALog] PRIMARY KEY CLUSTERED 
(
	[RowRef] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_RDTPPAlog_AddDate]  DEFAULT (getdate()) FOR [AddDate]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_rdtPPAlog_UCC]  DEFAULT ('') FOR [UCC]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_rdtPPAlog_OrderKey]  DEFAULT ('') FOR [OrderKey]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_rdtPPAlog_DropID]  DEFAULT ('') FOR [DropID]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_RDTPPAlog_EditDate]  DEFAULT (getdate()) FOR [EditDate]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_RDTPPAlog_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_RDTPPAlog_DelDate]  DEFAULT (getdate()) FOR [DelDate]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_RDTPPAlog_DelWho]  DEFAULT (suser_sname()) FOR [DelWho]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_RDTPPAlog_Lottable01]  DEFAULT (' ') FOR [Lottable01]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_RDTPPAlog_Lottable02]  DEFAULT (' ') FOR [Lottable02]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_RDTPPAlog_Lottable03]  DEFAULT (' ') FOR [Lottable03]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_RDTPPAlog_Lottable06]  DEFAULT (' ') FOR [Lottable06]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_RDTPPAlog_Lottable07]  DEFAULT (' ') FOR [Lottable07]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_RDTPPAlog_Lottable08]  DEFAULT (' ') FOR [Lottable08]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_RDTPPAlog_Lottable09]  DEFAULT (' ') FOR [Lottable09]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_RDTPPAlog_Lottable10]  DEFAULT (' ') FOR [Lottable10]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_RDTPPAlog_Lottable11]  DEFAULT (' ') FOR [Lottable11]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_RDTPPAlog_Lottable12]  DEFAULT (' ') FOR [Lottable12]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_rdtPPAlog_ID]  DEFAULT ('') FOR [ID]
GO

ALTER TABLE [RDT].[RDTPPAlog] ADD  CONSTRAINT [DF_rdtPPAlog_TaskDetailKey]  DEFAULT ('') FOR [TaskDetailKey]
GO

EXEC sys.sp_addextendedproperty @name=N'Lottable01', @value=N'Lottable01' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'RDTPPAlog', @level2type=N'COLUMN',@level2name=N'Lottable01'
GO

EXEC sys.sp_addextendedproperty @name=N'Lottable02', @value=N'Lottable01' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'RDTPPAlog', @level2type=N'COLUMN',@level2name=N'Lottable02'
GO

EXEC sys.sp_addextendedproperty @name=N'Lottable03', @value=N'Lottable01' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'RDTPPAlog', @level2type=N'COLUMN',@level2name=N'Lottable03'
GO

EXEC sys.sp_addextendedproperty @name=N'Lottable04', @value=N'Lottable01' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'RDTPPAlog', @level2type=N'COLUMN',@level2name=N'Lottable04'
GO

EXEC sys.sp_addextendedproperty @name=N'Lottable05', @value=N'Lottable01' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'RDTPPAlog', @level2type=N'COLUMN',@level2name=N'Lottable05'
GO

EXEC sys.sp_addextendedproperty @name=N'Lottable06', @value=N'Lottable01' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'RDTPPAlog', @level2type=N'COLUMN',@level2name=N'Lottable06'
GO

EXEC sys.sp_addextendedproperty @name=N'Lottable07', @value=N'Lottable01' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'RDTPPAlog', @level2type=N'COLUMN',@level2name=N'Lottable07'
GO

EXEC sys.sp_addextendedproperty @name=N'Lottable08', @value=N'Lottable01' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'RDTPPAlog', @level2type=N'COLUMN',@level2name=N'Lottable08'
GO

EXEC sys.sp_addextendedproperty @name=N'Lottable09', @value=N'Lottable01' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'RDTPPAlog', @level2type=N'COLUMN',@level2name=N'Lottable09'
GO

EXEC sys.sp_addextendedproperty @name=N'Lottable10', @value=N'Lottable01' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'RDTPPAlog', @level2type=N'COLUMN',@level2name=N'Lottable10'
GO

EXEC sys.sp_addextendedproperty @name=N'Lottable11', @value=N'Lottable01' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'RDTPPAlog', @level2type=N'COLUMN',@level2name=N'Lottable11'
GO

EXEC sys.sp_addextendedproperty @name=N'Lottable12', @value=N'Lottable01' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'RDTPPAlog', @level2type=N'COLUMN',@level2name=N'Lottable12'
GO

EXEC sys.sp_addextendedproperty @name=N'Lottable13', @value=N'Lottable01' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'RDTPPAlog', @level2type=N'COLUMN',@level2name=N'Lottable13'
GO

EXEC sys.sp_addextendedproperty @name=N'Lottable14', @value=N'Lottable01' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'RDTPPAlog', @level2type=N'COLUMN',@level2name=N'Lottable14'
GO

EXEC sys.sp_addextendedproperty @name=N'Lottable15', @value=N'Lottable01' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'RDTPPAlog', @level2type=N'COLUMN',@level2name=N'Lottable15'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Store TaskDetailKey Value' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'RDTPPAlog', @level2type=N'COLUMN',@level2name=N'TaskDetailKey'
GO

