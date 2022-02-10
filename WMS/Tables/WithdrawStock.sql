CREATE TABLE [dbo].[WithdrawStock]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LOT] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WithdrawStock_LOT] DEFAULT (' '),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WithdrawStock_ID] DEFAULT (' '),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL CONSTRAINT [DF_WithdrawStock_Qty] DEFAULT ((0)),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[RowId] [int] NOT NULL IDENTITY(1, 1),
[Sourcekey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sourcetype] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WithdrawStock_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WithdrawStock_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WithdrawStock_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WithdrawStock_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WithdrawStock_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WithdrawStock_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WithdrawStock_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WithdrawStock] ADD CONSTRAINT [PK_WithdrawStock] PRIMARY KEY CLUSTERED ([RowId]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WithdrawStock] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WithdrawStock] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WithdrawStock] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WithdrawStock] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'WithdrawStock', 'COLUMN', N'ID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying a physical location in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'WithdrawStock', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product.', 'SCHEMA', N'dbo', 'TABLE', N'WithdrawStock', 'COLUMN', N'LOT'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'WithdrawStock', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'WithdrawStock', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Source', 'SCHEMA', N'dbo', 'TABLE', N'WithdrawStock', 'COLUMN', N'Sourcekey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'WithdrawStock', 'COLUMN', N'StorerKey'
GO
