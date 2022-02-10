CREATE TABLE [dbo].[INVENTORYHOLD]
(
[InventoryHoldKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_InventoryHoldKey] DEFAULT (' '),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Lot] DEFAULT (' '),
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Id] DEFAULT (' '),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Loc] DEFAULT (' '),
[Hold] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Hold] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Status] DEFAULT (' '),
[DateOn] [datetime] NOT NULL CONSTRAINT [DF_INVENTORYHOLD_DateOn] DEFAULT (getdate()),
[WhoOn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_WhoOn] DEFAULT (suser_sname()),
[DateOff] [datetime] NOT NULL CONSTRAINT [DF_INVENTORYHOLD_DateOff] DEFAULT (getdate()),
[WhoOff] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_WhoOff] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_INVENTORYHOLD_SKU] DEFAULT (' '),
[Storerkey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_INVENTORYHOLD_Storerkey] DEFAULT (' '),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[Remark] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Lottable06] DEFAULT (' '),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Lottable07] DEFAULT (' '),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Lottable08] DEFAULT (' '),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Lottable09] DEFAULT (' '),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Lottable10] DEFAULT (' '),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Lottable11] DEFAULT (' '),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Lottable12] DEFAULT (' '),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[INVENTORYHOLD] WITH NOCHECK ADD CONSTRAINT [CK_IH_01] CHECK ((NOT ltrim(rtrim([Lot]))='' AND ltrim(rtrim([Loc]))='' AND ltrim(rtrim([id]))='' AND isnull(ltrim(rtrim([lottable01])),' ')=' ' AND isnull(ltrim(rtrim([lottable02])),' ')=' ' AND isnull(ltrim(rtrim([lottable03])),' ')=' ' AND isnull([lottable04],' ')=' ' AND isnull([lottable05],' ')=' ' AND isnull(ltrim(rtrim([lottable06])),' ')=' ' AND isnull(ltrim(rtrim([lottable07])),' ')=' ' AND isnull(ltrim(rtrim([lottable08])),' ')=' ' AND isnull(ltrim(rtrim([lottable09])),' ')=' ' AND isnull(ltrim(rtrim([lottable10])),' ')=' ' AND isnull(ltrim(rtrim([lottable11])),' ')=' ' AND isnull(ltrim(rtrim([lottable12])),' ')=' ' AND isnull([lottable13],' ')=' ' AND isnull([lottable14],' ')=' ' AND isnull([lottable15],' ')=' ' OR ltrim(rtrim([Lot]))='' AND NOT ltrim(rtrim([Loc]))='' AND ltrim(rtrim([id]))='' AND isnull(ltrim(rtrim([lottable01])),' ')=' ' AND isnull(ltrim(rtrim([lottable02])),' ')=' ' AND isnull(ltrim(rtrim([lottable03])),' ')=' ' AND isnull([lottable04],' ')=' ' AND isnull([lottable05],' ')=' ' AND isnull(ltrim(rtrim([lottable06])),' ')=' ' AND isnull(ltrim(rtrim([lottable07])),' ')=' ' AND isnull(ltrim(rtrim([lottable08])),' ')=' ' AND isnull(ltrim(rtrim([lottable09])),' ')=' ' AND isnull(ltrim(rtrim([lottable10])),' ')=' ' AND isnull(ltrim(rtrim([lottable11])),' ')=' ' AND isnull(ltrim(rtrim([lottable12])),' ')=' ' AND isnull([lottable13],' ')=' ' AND isnull([lottable14],' ')=' ' AND isnull([lottable15],' ')=' ' OR ltrim(rtrim([Lot]))='' AND ltrim(rtrim([Loc]))='' AND NOT ltrim(rtrim([id]))='' AND isnull(ltrim(rtrim([lottable01])),' ')=' ' AND isnull(ltrim(rtrim([lottable02])),' ')=' ' AND isnull(ltrim(rtrim([lottable03])),' ')=' ' AND isnull([lottable04],' ')=' ' AND isnull([lottable05],' ')=' ' AND isnull(ltrim(rtrim([lottable06])),' ')=' ' AND isnull(ltrim(rtrim([lottable07])),' ')=' ' AND isnull(ltrim(rtrim([lottable08])),' ')=' ' AND isnull(ltrim(rtrim([lottable09])),' ')=' ' AND isnull(ltrim(rtrim([lottable10])),' ')=' ' AND isnull(ltrim(rtrim([lottable11])),' ')=' ' AND isnull(ltrim(rtrim([lottable12])),' ')=' ' AND isnull([lottable13],' ')=' ' AND isnull([lottable14],' ')=' ' AND isnull([lottable15],' ')=' ' OR ltrim(rtrim([Lot]))='' AND ltrim(rtrim([Loc]))='' AND ltrim(rtrim([id]))='' AND NOT ltrim(rtrim([storerkey]))='' AND NOT ltrim(rtrim([sku]))='' AND (NOT ltrim(rtrim([lottable01]))='' OR NOT ltrim(rtrim([lottable02]))='' OR NOT ltrim(rtrim([lottable03]))='' OR NOT [lottable04]='' OR NOT [lottable05]='' OR NOT ltrim(rtrim([lottable06]))='' OR NOT ltrim(rtrim([lottable07]))='' OR NOT ltrim(rtrim([lottable08]))='' OR NOT ltrim(rtrim([lottable09]))='' OR NOT ltrim(rtrim([lottable10]))='' OR NOT ltrim(rtrim([lottable11]))='' OR NOT ltrim(rtrim([lottable12]))='' OR NOT [lottable13]='' OR NOT [lottable14]='' OR NOT [lottable15]='')))
GO
ALTER TABLE [dbo].[INVENTORYHOLD] ADD CONSTRAINT [PKINVENTORYHOLD] PRIMARY KEY CLUSTERED ([InventoryHoldKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INVENTORYHOLD_ID] ON [dbo].[INVENTORYHOLD] ([Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INVENTORYHOLD_LOC] ON [dbo].[INVENTORYHOLD] ([Loc]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INVENTORYHOLD_LOT] ON [dbo].[INVENTORYHOLD] ([Lot]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INVENTORYHOLD_LOTATT] ON [dbo].[INVENTORYHOLD] ([Storerkey], [SKU], [Lottable01], [Lottable02], [Lottable03], [Lottable04], [Lottable06], [Lottable07], [Lottable08], [Lottable09], [Lottable10], [Lottable11], [Lottable12], [Lottable13], [Lottable14], [Lottable15]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[INVENTORYHOLD] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[INVENTORYHOLD] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[INVENTORYHOLD] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[INVENTORYHOLD] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[INVENTORYHOLD] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'In WMS, an Inventory Hold is used to maintain inventory visibility but prevent shipments. User is able to put inventory on hold according to the lot#, pallet id and location via the inventory hold window. Locations can also be put on hold on the location window.', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date and time the transaction was last entered.', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'DateOff'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date and time the transaction was entered.', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'DateOn'
GO
EXEC sp_addextendedproperty N'MS_Description', 'To hold the item', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Hold'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable Unit ID for the Commodity being received', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The Inventory Hold unique key', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'InventoryHoldKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Physical location of the Commodity in the warehouse', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot number assigned to the Commodity', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot attribute of the Commodity', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Lottable01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot attribute of the Commodity', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Lottable02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot attribute of the Commodity', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Lottable03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Expiry Date', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Lottable04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Receipt Date', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Lottable05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Remarks', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Remark'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Reason for the hold', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the storer record', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User ID of the person signed onto the system when the transaction was last entered.', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'WhoOff'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User ID of the person signed onto the system when the transaction was entered.', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'WhoOn'
GO
