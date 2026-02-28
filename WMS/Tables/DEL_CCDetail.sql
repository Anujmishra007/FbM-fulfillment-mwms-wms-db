SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DEL_CCDetail]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[DEL_CCDetail](
	[CCKey] [nvarchar](10) NOT NULL,
	[CCDetailKey] [nvarchar](10) NOT NULL,
	[CCSheetNo] [nvarchar](10) NOT NULL,
	[TagNo] [nvarchar](10) NOT NULL,
	[Storerkey] [nvarchar](15) NOT NULL,
	[Sku] [nvarchar](20) NOT NULL,
	[Lot] [nvarchar](10) NOT NULL,
	[Loc] [nvarchar](10) NOT NULL,
	[Id] [nvarchar](18) NOT NULL,
	[SystemQty] [int] NOT NULL,
	[Qty] [int] NOT NULL,
	[Lottable01] [nvarchar](18) NULL,
	[Lottable02] [nvarchar](18) NULL,
	[Lottable03] [nvarchar](18) NULL,
	[Lottable04] [datetime] NULL,
	[Lottable05] [datetime] NULL,
	[FinalizeFlag] [nvarchar](1) NULL,
	[Qty_Cnt2] [int] NOT NULL,
	[Lottable01_Cnt2] [nvarchar](18) NULL,
	[Lottable02_Cnt2] [nvarchar](18) NULL,
	[Lottable03_Cnt2] [nvarchar](18) NULL,
	[Lottable04_Cnt2] [datetime] NULL,
	[Lottable05_Cnt2] [datetime] NULL,
	[FinalizeFlag_Cnt2] [nvarchar](1) NULL,
	[Qty_Cnt3] [int] NULL,
	[Lottable01_Cnt3] [nvarchar](18) NULL,
	[Lottable02_Cnt3] [nvarchar](18) NULL,
	[Lottable03_Cnt3] [nvarchar](18) NULL,
	[Lottable04_Cnt3] [datetime] NULL,
	[Lottable05_Cnt3] [datetime] NULL,
	[FinalizeFlag_Cnt3] [nvarchar](1) NULL,
	[Status] [nvarchar](10) NOT NULL,
	[StatusMsg] [nvarchar](255) NOT NULL,
	[AddDate] [datetime] NOT NULL,
	[AddWho] [nvarchar](128) NOT NULL,
	[EditDate] [datetime] NOT NULL,
	[EditWho] [nvarchar](128) NOT NULL,
	[TrafficCop] [nvarchar](1) NULL,
	[ArchiveCop] [nvarchar](1) NULL,
	[RefNo] [nvarchar](20) NULL,
	[EditDate_Cnt1] [datetime] NULL,
	[EditWho_Cnt1] [nvarchar](18) NULL,
	[EditDate_Cnt2] [datetime] NULL,
	[EditWho_Cnt2] [nvarchar](18) NULL,
	[EditDate_Cnt3] [datetime] NULL,
	[EditWho_Cnt3] [nvarchar](18) NULL,
	[Counted_Cnt1] [nvarchar](1) NULL,
	[Counted_Cnt2] [nvarchar](1) NULL,
	[Counted_Cnt3] [nvarchar](1) NULL,
	[Lottable06] [nvarchar](30) NULL,
	[Lottable07] [nvarchar](30) NULL,
	[Lottable08] [nvarchar](30) NULL,
	[Lottable09] [nvarchar](30) NULL,
	[Lottable10] [nvarchar](30) NULL,
	[Lottable11] [nvarchar](30) NULL,
	[Lottable12] [nvarchar](30) NULL,
	[Lottable13] [datetime] NULL,
	[Lottable14] [datetime] NULL,
	[Lottable15] [datetime] NULL,
	[Lottable06_Cnt2] [nvarchar](30) NULL,
	[Lottable07_Cnt2] [nvarchar](30) NULL,
	[Lottable08_Cnt2] [nvarchar](30) NULL,
	[Lottable09_Cnt2] [nvarchar](30) NULL,
	[Lottable10_Cnt2] [nvarchar](30) NULL,
	[Lottable11_Cnt2] [nvarchar](30) NULL,
	[Lottable12_Cnt2] [nvarchar](30) NULL,
	[Lottable13_Cnt2] [datetime] NULL,
	[Lottable14_Cnt2] [datetime] NULL,
	[Lottable15_Cnt2] [datetime] NULL,
	[Lottable06_Cnt3] [nvarchar](30) NULL,
	[Lottable07_Cnt3] [nvarchar](30) NULL,
	[Lottable08_Cnt3] [nvarchar](30) NULL,
	[Lottable09_Cnt3] [nvarchar](30) NULL,
	[Lottable10_Cnt3] [nvarchar](30) NULL,
	[Lottable11_Cnt3] [nvarchar](30) NULL,
	[Lottable12_Cnt3] [nvarchar](30) NULL,
	[Lottable13_Cnt3] [datetime] NULL,
	[Lottable14_Cnt3] [datetime] NULL,
	[Lottable15_Cnt3] [datetime] NULL,
 CONSTRAINT [PKDEL_CCDetail] PRIMARY KEY NONCLUSTERED 
(
	[CCDetailKey] ASC
)WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_CCSheetNo]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_CCSheetNo]  DEFAULT (' ') FOR [CCSheetNo]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_TagNo]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_TagNo]  DEFAULT (' ') FOR [TagNo]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_StorerKey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_StorerKey]  DEFAULT (' ') FOR [Storerkey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Sku]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Sku]  DEFAULT (' ') FOR [Sku]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lot]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lot]  DEFAULT (' ') FOR [Lot]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Loc]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Loc]  DEFAULT (' ') FOR [Loc]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_id]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_id]  DEFAULT (' ') FOR [Id]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_SystemQty]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_SystemQty]  DEFAULT ((0)) FOR [SystemQty]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Qty]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Qty]  DEFAULT ((0)) FOR [Qty]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_FinalizeFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_FinalizeFlag]  DEFAULT ('N') FOR [FinalizeFlag]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Qty2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Qty2]  DEFAULT ((0)) FOR [Qty_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_FinalizeFlag_Cnt2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_FinalizeFlag_Cnt2]  DEFAULT ('N') FOR [FinalizeFlag_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Qty_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Qty_Cnt3]  DEFAULT ((0)) FOR [Qty_Cnt3]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_FinalizeFlag_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_FinalizeFlag_Cnt3]  DEFAULT ('N') FOR [FinalizeFlag_Cnt3]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Status]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Status]  DEFAULT ('0') FOR [Status]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_StatusMsg]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_StatusMsg]  DEFAULT (' ') FOR [StatusMsg]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_AddDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_AddDate]  DEFAULT (getdate()) FOR [AddDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_AddWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_EditDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_EditDate]  DEFAULT (getdate()) FOR [EditDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_EditWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_REFNO]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_REFNO]  DEFAULT (' ') FOR [RefNo]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Counted_Cnt1]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Counted_Cnt1]  DEFAULT ('0') FOR [Counted_Cnt1]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Counted_Cnt2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Counted_Cnt2]  DEFAULT ('0') FOR [Counted_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Counted_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Counted_Cnt3]  DEFAULT ('0') FOR [Counted_Cnt3]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable06]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable06]  DEFAULT ('') FOR [Lottable06]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable07]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable07]  DEFAULT ('') FOR [Lottable07]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable08]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable08]  DEFAULT ('') FOR [Lottable08]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable09]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable09]  DEFAULT ('') FOR [Lottable09]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable10]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable10]  DEFAULT ('') FOR [Lottable10]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable11]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable11]  DEFAULT ('') FOR [Lottable11]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable12]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable12]  DEFAULT ('') FOR [Lottable12]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable06_Cnt2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable06_Cnt2]  DEFAULT ('') FOR [Lottable06_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable07_Cnt2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable07_Cnt2]  DEFAULT ('') FOR [Lottable07_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable08_Cnt2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable08_Cnt2]  DEFAULT ('') FOR [Lottable08_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable09_Cnt2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable09_Cnt2]  DEFAULT ('') FOR [Lottable09_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable10_Cnt2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable10_Cnt2]  DEFAULT ('') FOR [Lottable10_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable11_Cnt2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable11_Cnt2]  DEFAULT ('') FOR [Lottable11_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable12_Cnt2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable12_Cnt2]  DEFAULT ('') FOR [Lottable12_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable06_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable06_Cnt3]  DEFAULT ('') FOR [Lottable06_Cnt3]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable07_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable07_Cnt3]  DEFAULT ('') FOR [Lottable07_Cnt3]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable08_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable08_Cnt3]  DEFAULT ('') FOR [Lottable08_Cnt3]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable09_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable09_Cnt3]  DEFAULT ('') FOR [Lottable09_Cnt3]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable10_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable10_Cnt3]  DEFAULT ('') FOR [Lottable10_Cnt3]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable11_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable11_Cnt3]  DEFAULT ('') FOR [Lottable11_Cnt3]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_DEL_CCDetail_Lottable12_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DEL_CCDetail] ADD  CONSTRAINT [DF_DEL_CCDetail_Lottable12_Cnt3]  DEFAULT ('') FOR [Lottable12_Cnt3]
END
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_CCDetail', N'COLUMN',N'CCKey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique code identifying Cycle Count.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DEL_CCDetail', @level2type=N'COLUMN',@level2name=N'CCKey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_CCDetail', N'COLUMN',N'CCDetailKey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique code identifying Cycle Count Detail.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DEL_CCDetail', @level2type=N'COLUMN',@level2name=N'CCDetailKey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_CCDetail', N'COLUMN',N'CCSheetNo'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique number identifying Cycle Count Sheet.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DEL_CCDetail', @level2type=N'COLUMN',@level2name=N'CCSheetNo'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_CCDetail', N'COLUMN',N'TagNo'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique number identifying Tag.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DEL_CCDetail', @level2type=N'COLUMN',@level2name=N'TagNo'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_CCDetail', N'COLUMN',N'Storerkey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique key to the Storer record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DEL_CCDetail', @level2type=N'COLUMN',@level2name=N'Storerkey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_CCDetail', N'COLUMN',N'Sku'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique code identifying the product.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DEL_CCDetail', @level2type=N'COLUMN',@level2name=N'Sku'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_CCDetail', N'COLUMN',N'Lot'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique pre-pupulated numeric value associated with a specific product. A unique combination.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DEL_CCDetail', @level2type=N'COLUMN',@level2name=N'Lot'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_CCDetail', N'COLUMN',N'Loc'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique code identifying the physical Location in the facility.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DEL_CCDetail', @level2type=N'COLUMN',@level2name=N'Loc'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_CCDetail', N'COLUMN',N'Id'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DEL_CCDetail', @level2type=N'COLUMN',@level2name=N'Id'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_CCDetail', N'COLUMN',N'Qty'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Quantity of the product associated to the cycle count.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DEL_CCDetail', @level2type=N'COLUMN',@level2name=N'Qty'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_CCDetail', N'COLUMN',N'AddDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of the information added. (System date)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DEL_CCDetail', @level2type=N'COLUMN',@level2name=N'AddDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_CCDetail', N'COLUMN',N'AddWho'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID added the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DEL_CCDetail', @level2type=N'COLUMN',@level2name=N'AddWho'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_CCDetail', N'COLUMN',N'EditDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of the information edited/modified/updated. (System date)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DEL_CCDetail', @level2type=N'COLUMN',@level2name=N'EditDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_CCDetail', N'COLUMN',N'EditWho'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID edited/modified/updated the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DEL_CCDetail', @level2type=N'COLUMN',@level2name=N'EditWho'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_CCDetail', N'COLUMN',N'TrafficCop'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DEL_CCDetail', @level2type=N'COLUMN',@level2name=N'TrafficCop'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_CCDetail', N'COLUMN',N'RefNo'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique number for references purpose.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DEL_CCDetail', @level2type=N'COLUMN',@level2name=N'RefNo'
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DEL_CCDetail]') AND type in (N'U'))
   GRANT SELECT, INSERT, DELETE, UPDATE ON [dbo].[DEL_CCDetail] TO [NSQL]
GO
IF EXISTS(SELECT TOP 1 1 FROM sys.columns where object_id=OBJECT_ID(N'[dbo].[DEL_CCDetail]') AND name='Storerkey' AND TYPE_NAME(system_type_id)='nvarchar' AND max_length < 30)
   ALTER TABLE [dbo].[DEL_CCDetail] ALTER COLUMN [Storerkey] [nvarchar](15) NOT NULL
GO
