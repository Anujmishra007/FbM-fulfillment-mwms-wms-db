CREATE TABLE [dbo].[ids_inventory_balance]
(
[exportdate] [datetime] NOT NULL CONSTRAINT [DF_ids_inventory_balance_exportdate] DEFAULT (getdate()),
[storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[putawayzone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[qty] [int] NOT NULL,
[qtyallocated] [int] NOT NULL,
[qtypicked] [int] NOT NULL,
[archivecop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inventorydate] [date] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ids_inventory_balance] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ids_inventory_balance] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ids_inventory_balance] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ids_inventory_balance] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'ids_inventory_balance', 'COLUMN', N'id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the physical Location in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'ids_inventory_balance', 'COLUMN', N'loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'ids_inventory_balance', 'COLUMN', N'lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Putaway location for the Commodity in the facility. Can be used by the putaway strategy as a default putaway Location.', 'SCHEMA', N'dbo', 'TABLE', N'ids_inventory_balance', 'COLUMN', N'putawayzone'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated.', 'SCHEMA', N'dbo', 'TABLE', N'ids_inventory_balance', 'COLUMN', N'qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the inventory currently allocated in the location.', 'SCHEMA', N'dbo', 'TABLE', N'ids_inventory_balance', 'COLUMN', N'qtyallocated'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the inventory currently picked in the location.', 'SCHEMA', N'dbo', 'TABLE', N'ids_inventory_balance', 'COLUMN', N'qtypicked'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'ids_inventory_balance', 'COLUMN', N'sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record. ', 'SCHEMA', N'dbo', 'TABLE', N'ids_inventory_balance', 'COLUMN', N'storerkey'
GO
