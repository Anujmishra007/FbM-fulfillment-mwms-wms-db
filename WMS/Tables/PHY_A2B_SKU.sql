CREATE TABLE [dbo].[PHY_A2B_SKU]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PHY_A2B_SKU_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PHY_A2B_SKU_Sku] DEFAULT (' '),
[QtyTeamA] [int] NOT NULL CONSTRAINT [DF_PHY_A2B_SKU_QtyTeamA] DEFAULT ((0)),
[QtyTeamB] [int] NOT NULL CONSTRAINT [DF_PHY_A2B_SKU_QtyTeamB] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PHY_A2B_SKU] ADD CONSTRAINT [PKPHY_A2B_SKU] PRIMARY KEY NONCLUSTERED ([StorerKey], [Sku]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PHY_A2B_SKU] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PHY_A2B_SKU] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PHY_A2B_SKU] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PHY_A2B_SKU] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'PHY_A2B_SKU', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'PHY_A2B_SKU', 'COLUMN', N'StorerKey'
GO
