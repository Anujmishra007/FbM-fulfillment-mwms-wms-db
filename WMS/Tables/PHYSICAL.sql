CREATE TABLE [dbo].[PHYSICAL]
(
[Team] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PHYSICAL_Team] DEFAULT ('A'),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PHYSICAL_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PHYSICAL_Sku] DEFAULT (' '),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PHYSICAL_Loc] DEFAULT ('UNKNOWN'),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PHYSICAL_Lot] DEFAULT (' '),
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PHYSICAL_Id] DEFAULT (' '),
[InventoryTag] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PHYSICAL_InventoryTag] DEFAULT (' '),
[Qty] [int] NOT NULL CONSTRAINT [DF_PHYSICAL_Qty] DEFAULT ((0)),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PHYSICAL_PackKey] DEFAULT (' '),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PHYSICAL_UOM] DEFAULT (' '),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL,
[SheetNoKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PHYSICAL_SheetNoKey] DEFAULT (' ')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PHYSICAL] ADD CONSTRAINT [PKPhysical] PRIMARY KEY CLUSTERED ([Team], [StorerKey], [Sku], [Lot], [Loc], [Id], [InventoryTag]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PHYSICAL] WITH NOCHECK ADD CONSTRAINT [FK_PHYSICAL_ID_01] FOREIGN KEY ([Id]) REFERENCES [dbo].[ID] ([Id])
GO
ALTER TABLE [dbo].[PHYSICAL] WITH NOCHECK ADD CONSTRAINT [FK_PHYSICAL_LOC_01] FOREIGN KEY ([Loc]) REFERENCES [dbo].[LOC] ([Loc])
GO
ALTER TABLE [dbo].[PHYSICAL] WITH NOCHECK ADD CONSTRAINT [FK_PHYSICAL_SKU_01] FOREIGN KEY ([StorerKey], [Sku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])
GO
GRANT DELETE ON  [dbo].[PHYSICAL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PHYSICAL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PHYSICAL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PHYSICAL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'PHYSICAL', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the physical location in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'PHYSICAL', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'PHYSICAL', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the pack code.', 'SCHEMA', N'dbo', 'TABLE', N'PHYSICAL', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated.', 'SCHEMA', N'dbo', 'TABLE', N'PHYSICAL', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Sheet Number.', 'SCHEMA', N'dbo', 'TABLE', N'PHYSICAL', 'COLUMN', N'SheetNoKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the products.', 'SCHEMA', N'dbo', 'TABLE', N'PHYSICAL', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'PHYSICAL', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PHYSICAL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'PHYSICAL', 'COLUMN', N'UOM'
GO
