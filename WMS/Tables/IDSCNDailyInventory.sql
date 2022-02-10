CREATE TABLE [dbo].[IDSCNDailyInventory]
(
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL,
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04] [datetime] NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_IDSCNDailyInventory_AddDate] DEFAULT (getdate()),
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_IDSCNDailyInventory_Addwho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_IDSCNDailyInventory_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_IDSCNDailyInventory_EditWho] DEFAULT (suser_sname()),
[InventoryDate] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[IDSCNDailyInventory] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[IDSCNDailyInventory] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[IDSCNDailyInventory] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[IDSCNDailyInventory] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'IDSCNDailyInventory', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'IDSCNDailyInventory', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'IDSCNDailyInventory', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'IDSCNDailyInventory', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'IDSCNDailyInventory', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the physical Location in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'IDSCNDailyInventory', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'IDSCNDailyInventory', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated.', 'SCHEMA', N'dbo', 'TABLE', N'IDSCNDailyInventory', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'IDSCNDailyInventory', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'IDSCNDailyInventory', 'COLUMN', N'Storerkey'
GO
