CREATE TABLE [dbo].[LOTATTRIBUTE]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_LOTTABLE01] DEFAULT (' '),
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_LOTTABLE02] DEFAULT (' '),
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_LOTTABLE03] DEFAULT (' '),
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Flag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_Flag] DEFAULT (' '),
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_Lottable06] DEFAULT (' '),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_Lottable07] DEFAULT (' '),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_Lottable08] DEFAULT (' '),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_Lottable09] DEFAULT (' '),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_Lottable10] DEFAULT (' '),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_Lottable11] DEFAULT (' '),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_Lottable12] DEFAULT (' '),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[LOTATTRIBUTE] ADD CONSTRAINT [PKLOTAttribute] PRIMARY KEY CLUSTERED ([Lot]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_LOTATTRIBUTE_SKU_LOT] ON [dbo].[LOTATTRIBUTE] ([StorerKey], [Sku], [Lot]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [AK_LOTATTRIBUTE_01] ON [dbo].[LOTATTRIBUTE] ([StorerKey], [Sku], [Lottable01], [Lottable02], [Lottable03], [Lottable04], [Lottable05], [Lottable06], [Lottable07], [Lottable08], [Lottable09], [Lottable10], [Lottable11], [Lottable12], [Lottable13], [Lottable14]) INCLUDE ([Lottable15]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [AK_LOTATTRIBUTE02] ON [dbo].[LOTATTRIBUTE] ([StorerKey], [Sku], [Lottable01], [Lottable05]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LOTATTRIBUTE] WITH NOCHECK ADD CONSTRAINT [FK_LOTATTRIBUTE_STORER_01] FOREIGN KEY ([StorerKey]) REFERENCES [dbo].[STORER] ([StorerKey])
GO
GRANT SELECT ON  [dbo].[LOTATTRIBUTE] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[LOTATTRIBUTE] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LOTATTRIBUTE] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LOTATTRIBUTE] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LOTATTRIBUTE] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'A lottable is a specific attribute about the product that makes the lot unique. When the lottable values for a product change, a new lot is assigned.', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique re-populated numeric value associated with a  specific product.', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot attribute of the Commodity', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'Lottable01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot attribute of the Commodity  Standard - Batch No', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'Lottable02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot attribute of the Commodity', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'Lottable03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot attribute of the Commodity  Standard - Expiry date', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'Lottable04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot attribute of the Commodity  Standard - Incoming / Manufacturing date', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'Lottable05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies the Commodity associated with the prepopulated  lot number', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The owner of the product', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'TrafficCop'
GO
