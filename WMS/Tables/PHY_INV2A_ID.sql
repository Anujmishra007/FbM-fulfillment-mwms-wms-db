CREATE TABLE [dbo].[PHY_INV2A_ID]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PHY_INV2A_ID_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PHY_INV2A_ID_Sku] DEFAULT (' '),
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PHY_INV2A_ID_Id] DEFAULT (' '),
[QtyTeamA] [int] NOT NULL CONSTRAINT [DF_PHY_INV2A_ID_QtyTeamA] DEFAULT ((0)),
[QtyLOTxLOCxID] [int] NOT NULL CONSTRAINT [DF_PHY_INV2A_ID_QtyLOTxLOCxID] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PHY_INV2A_ID] ADD CONSTRAINT [PKPHY_INV2A_ID] PRIMARY KEY NONCLUSTERED ([Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PHY_INV2A_ID] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PHY_INV2A_ID] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PHY_INV2A_ID] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PHY_INV2A_ID] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'PHY_INV2A_ID', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'PHY_INV2A_ID', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'PHY_INV2A_ID', 'COLUMN', N'StorerKey'
GO
