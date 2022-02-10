CREATE TABLE [dbo].[PHY_INV2A_LOT]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PHY_INV2A_LOT_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PHY_INV2A_LOT_Sku] DEFAULT (' '),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PHY_INV2A_LOT_Lot] DEFAULT (' '),
[QtyTeamA] [int] NOT NULL CONSTRAINT [DF_PHY_INV2A_LOT_QtyTeamA] DEFAULT ((0)),
[QtyLOTxLOCxID] [int] NOT NULL CONSTRAINT [DF_PHY_INV2A_LOT_QtyLOTxLOCxID] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PHY_INV2A_LOT] ADD CONSTRAINT [PKPHY_INV2A_LOT] PRIMARY KEY NONCLUSTERED ([StorerKey], [Sku], [Lot]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PHY_INV2A_LOT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PHY_INV2A_LOT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PHY_INV2A_LOT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PHY_INV2A_LOT] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'PHY_INV2A_LOT', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'PHY_INV2A_LOT', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'PHY_INV2A_LOT', 'COLUMN', N'StorerKey'
GO
