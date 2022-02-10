CREATE TABLE [dbo].[CCDetail]
(
[CCKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CCDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CCSheetNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_CCSheetNo] DEFAULT (' '),
[TagNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_TagNo] DEFAULT (' '),
[Storerkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_Sku] DEFAULT (' '),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_Lot] DEFAULT (' '),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_Loc] DEFAULT (' '),
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_id] DEFAULT (' '),
[SystemQty] [int] NOT NULL CONSTRAINT [DF_CCDetail_SystemQty] DEFAULT ((0)),
[Qty] [int] NOT NULL CONSTRAINT [DF_CCDetail_Qty] DEFAULT ((0)),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[FinalizeFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_FinalizeFlag] DEFAULT ('N'),
[Qty_Cnt2] [int] NOT NULL CONSTRAINT [DF_CCDetail_Qty_Cnt2] DEFAULT ((0)),
[Lottable01_Cnt2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02_Cnt2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03_Cnt2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04_Cnt2] [datetime] NULL,
[Lottable05_Cnt2] [datetime] NULL,
[FinalizeFlag_Cnt2] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_FinalizeFlag_Cnt2] DEFAULT ('N'),
[Qty_Cnt3] [int] NULL CONSTRAINT [DF_CCDetail_Qty_Cnt3] DEFAULT ((0)),
[Lottable01_Cnt3] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02_Cnt3] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03_Cnt3] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04_Cnt3] [datetime] NULL,
[Lottable05_Cnt3] [datetime] NULL,
[FinalizeFlag_Cnt3] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_FinalizeFlag_Cnt3] DEFAULT ('N'),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_Status] DEFAULT ('0'),
[StatusMsg] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_StatusMsg] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_CCDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_CCDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL,
[RefNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDETAIL_REFNO] DEFAULT (' '),
[EditDate_Cnt1] [datetime] NULL,
[EditWho_Cnt1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate_Cnt2] [datetime] NULL,
[EditWho_Cnt2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate_Cnt3] [datetime] NULL,
[EditWho_Cnt3] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Counted_Cnt1] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDETAIL_Counted_Cnt1] DEFAULT ('0'),
[Counted_Cnt2] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDETAIL_Counted_Cnt2] DEFAULT ('0'),
[Counted_Cnt3] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDETAIL_Counted_Cnt3] DEFAULT ('0'),
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[Lottable06_Cnt2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable06_Cnt2] DEFAULT (''),
[Lottable07_Cnt2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable07_Cnt2] DEFAULT (''),
[Lottable08_Cnt2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable08_Cnt2] DEFAULT (''),
[Lottable09_Cnt2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable09_Cnt2] DEFAULT (''),
[Lottable10_Cnt2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable10_Cnt2] DEFAULT (''),
[Lottable11_Cnt2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable11_Cnt2] DEFAULT (''),
[Lottable12_Cnt2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable12_Cnt2] DEFAULT (''),
[Lottable13_Cnt2] [datetime] NULL,
[Lottable14_Cnt2] [datetime] NULL,
[Lottable15_Cnt2] [datetime] NULL,
[Lottable06_Cnt3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable06_Cnt3] DEFAULT (''),
[Lottable07_Cnt3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable07_Cnt3] DEFAULT (''),
[Lottable08_Cnt3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable08_Cnt3] DEFAULT (''),
[Lottable09_Cnt3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable09_Cnt3] DEFAULT (''),
[Lottable10_Cnt3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable10_Cnt3] DEFAULT (''),
[Lottable11_Cnt3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable11_Cnt3] DEFAULT (''),
[Lottable12_Cnt3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable12_Cnt3] DEFAULT (''),
[Lottable13_Cnt3] [datetime] NULL,
[Lottable14_Cnt3] [datetime] NULL,
[Lottable15_Cnt3] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CCDetail] ADD CONSTRAINT [PKCCDETAIL] PRIMARY KEY NONCLUSTERED ([CCDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_CCDetail_CCKey] ON [dbo].[CCDetail] ([CCKey], [CCDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CCDetail_CCKey_LOC] ON [dbo].[CCDetail] ([CCKey], [Loc]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CCDetail_LOC] ON [dbo].[CCDetail] ([Loc], [CCKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CCDetail_01] ON [dbo].[CCDetail] ([RefNo], [Storerkey], [Sku]) INCLUDE ([Status]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[CCDetail] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[CCDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CCDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CCDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CCDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Cycle Count Detail.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'CCDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Cycle Count.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'CCKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Cycle Count Sheet.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'CCSheetNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the physical Location in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-pupulated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated to the cycle count.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number for references purpose.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'RefNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Tag.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'TagNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'TrafficCop'
GO
