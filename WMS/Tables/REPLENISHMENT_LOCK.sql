CREATE TABLE [dbo].[REPLENISHMENT_LOCK]
(
[PTCID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[adddate] [datetime] NOT NULL CONSTRAINT [DF_REPLENISHMENT_LOCK_adddate] DEFAULT (getdate()),
[UserID] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[REPLENISHMENT_LOCK] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[REPLENISHMENT_LOCK] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[REPLENISHMENT_LOCK] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[REPLENISHMENT_LOCK] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT_LOCK', 'COLUMN', N'adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Current location of the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT_LOCK', 'COLUMN', N'FromLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT_LOCK', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric values associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT_LOCK', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT_LOCK', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT_LOCK', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Destination (location) for the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT_LOCK', 'COLUMN', N'ToLoc'
GO
