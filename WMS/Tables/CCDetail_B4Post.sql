SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCDetail_B4Post]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[CCDetail_B4Post](
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
	[Timestamp] [binary](1) NOT NULL,
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
 CONSTRAINT [PKCCDETAIL_B4Post] PRIMARY KEY NONCLUSTERED 
(
	[CCDetailKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_CCSheetNo]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_CCSheetNo]  DEFAULT (' ') FOR [CCSheetNo]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_TagNo]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_TagNo]  DEFAULT (' ') FOR [TagNo]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_StorerKey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_StorerKey]  DEFAULT (' ') FOR [Storerkey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Sku]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Sku]  DEFAULT (' ') FOR [Sku]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lot]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lot]  DEFAULT (' ') FOR [Lot]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Loc]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Loc]  DEFAULT (' ') FOR [Loc]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_id]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_id]  DEFAULT (' ') FOR [Id]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_SystemQty]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_SystemQty]  DEFAULT ((0)) FOR [SystemQty]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Qty]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Qty]  DEFAULT ((0)) FOR [Qty]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_FinalizeFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_FinalizeFlag]  DEFAULT ('N') FOR [FinalizeFlag]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Qty2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Qty2]  DEFAULT ((0)) FOR [Qty_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_FinalizeFlag_Cnt2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_FinalizeFlag_Cnt2]  DEFAULT ('N') FOR [FinalizeFlag_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Qty_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Qty_Cnt3]  DEFAULT ((0)) FOR [Qty_Cnt3]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_FinalizeFlag_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_FinalizeFlag_Cnt3]  DEFAULT ('N') FOR [FinalizeFlag_Cnt3]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Status]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Status]  DEFAULT ('0') FOR [Status]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_StatusMsg]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_StatusMsg]  DEFAULT (' ') FOR [StatusMsg]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_AddDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_AddDate]  DEFAULT (getdate()) FOR [AddDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_AddWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_EditDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_EditDate]  DEFAULT (getdate()) FOR [EditDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_EditWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_REFNO]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_REFNO]  DEFAULT (' ') FOR [RefNo]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_B4Post_Counted_Cnt1]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_B4Post_Counted_Cnt1]  DEFAULT ('0') FOR [Counted_Cnt1]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_B4Post_Counted_Cnt2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_B4Post_Counted_Cnt2]  DEFAULT ('0') FOR [Counted_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_B4Post_Counted_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_B4Post_Counted_Cnt3]  DEFAULT ('0') FOR [Counted_Cnt3]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable06]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable06]  DEFAULT ('') FOR [Lottable06]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable07]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable07]  DEFAULT ('') FOR [Lottable07]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable08]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable08]  DEFAULT ('') FOR [Lottable08]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable09]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable09]  DEFAULT ('') FOR [Lottable09]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable10]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable10]  DEFAULT ('') FOR [Lottable10]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable11]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable11]  DEFAULT ('') FOR [Lottable11]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable12]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable12]  DEFAULT ('') FOR [Lottable12]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable06_Cnt2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable06_Cnt2]  DEFAULT ('') FOR [Lottable06_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable07_Cnt2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable07_Cnt2]  DEFAULT ('') FOR [Lottable07_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable08_Cnt2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable08_Cnt2]  DEFAULT ('') FOR [Lottable08_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable09_Cnt2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable09_Cnt2]  DEFAULT ('') FOR [Lottable09_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable10_Cnt2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable10_Cnt2]  DEFAULT ('') FOR [Lottable10_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable11_Cnt2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable11_Cnt2]  DEFAULT ('') FOR [Lottable11_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable12_Cnt2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable12_Cnt2]  DEFAULT ('') FOR [Lottable12_Cnt2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable06_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable06_Cnt3]  DEFAULT ('') FOR [Lottable06_Cnt3]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable07_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable07_Cnt3]  DEFAULT ('') FOR [Lottable07_Cnt3]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable08_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable08_Cnt3]  DEFAULT ('') FOR [Lottable08_Cnt3]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable09_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable09_Cnt3]  DEFAULT ('') FOR [Lottable09_Cnt3]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable10_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable10_Cnt3]  DEFAULT ('') FOR [Lottable10_Cnt3]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable11_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable11_Cnt3]  DEFAULT ('') FOR [Lottable11_Cnt3]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CCDetail_B4Post_Lottable12_Cnt3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CCDetail_B4Post] ADD  CONSTRAINT [DF_CCDetail_B4Post_Lottable12_Cnt3]  DEFAULT ('') FOR [Lottable12_Cnt3]
END
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCDetail_B4Post]') AND type in (N'U'))
   GRANT SELECT, INSERT, DELETE, UPDATE ON [dbo].[CCDetail_B4Post] TO [NSQL]
GO
IF EXISTS(SELECT TOP 1 1 FROM sys.columns where object_id=OBJECT_ID(N'[dbo].[CCDetail_B4Post]') AND name='Storerkey' AND TYPE_NAME(system_type_id)='nvarchar' AND max_length < 30)
   ALTER TABLE [dbo].[CCDetail_B4Post] ALTER COLUMN [Storerkey] [nvarchar](15) NOT NULL
GO
