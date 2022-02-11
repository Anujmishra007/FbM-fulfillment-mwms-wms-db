CREATE TABLE [dbo].[LOT]
(
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseCnt] [int] NOT NULL CONSTRAINT [DF_Lot_CaseCnt] DEFAULT ((0)),
[InnerPack] [int] NOT NULL CONSTRAINT [DF_Lot_Innerpack] DEFAULT ((0)),
[Qty] [int] NOT NULL CONSTRAINT [DF_LOT_QTY] DEFAULT ((0)),
[Pallet] [int] NOT NULL CONSTRAINT [DF_Lot_Pallet] DEFAULT ((0)),
[Cube] [float] NOT NULL CONSTRAINT [DF_Lot_Cube] DEFAULT ((0)),
[GrossWgt] [float] NOT NULL CONSTRAINT [DF_Lot_GrossWgt] DEFAULT ((0)),
[NetWgt] [float] NOT NULL CONSTRAINT [DF_Lot_NetWgt] DEFAULT ((0)),
[OtherUnit1] [float] NOT NULL CONSTRAINT [DF_Lot_OtherUnit1] DEFAULT ((0)),
[OtherUnit2] [float] NOT NULL CONSTRAINT [DF_Lot_OtherUnit2] DEFAULT ((0)),
[QtyPreAllocated] [int] NOT NULL CONSTRAINT [DF_LOT_QtyPreAllocated] DEFAULT ((0)),
[GrossWgtpreAllocated] [float] NOT NULL CONSTRAINT [DF_LOT_GrossWgtpreAllocated] DEFAULT ((0)),
[NetWgtpreAllocated] [float] NOT NULL CONSTRAINT [DF_LOT_NetWgtpreAllocated] DEFAULT ((0)),
[QtyAllocated] [int] NOT NULL CONSTRAINT [DF_LOT_QtyAllocated] DEFAULT ((0)),
[GrossWgtAllocated] [float] NOT NULL CONSTRAINT [DF_LOT_GrossWgtAllocated] DEFAULT ((0)),
[NetWgtAllocated] [float] NOT NULL CONSTRAINT [DF_LOT_NetWgtAllocated] DEFAULT ((0)),
[QtyPicked] [int] NOT NULL CONSTRAINT [DF_LOT_QtyPicked] DEFAULT ((0)),
[GrossWgtPicked] [float] NOT NULL CONSTRAINT [DF_LOT_GrossWgtPicked] DEFAULT ((0)),
[NetWgtPicked] [float] NOT NULL CONSTRAINT [DF_LOT_NetWgtPicked] DEFAULT ((0)),
[QtyOnHold] [int] NOT NULL CONSTRAINT [DF_LOT_QtyOnHold] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOT_Status] DEFAULT ('OK'),
[ArchiveQty] [int] NOT NULL CONSTRAINT [DF_LOT_ArchiveQty] DEFAULT ((0)),
[ArchiveDate] [datetime] NOT NULL CONSTRAINT [DF_LOT_ArchiveDate] DEFAULT ('01/01/1901'),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOT_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_LOT_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[LOT] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[LOT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LOT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LOT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LOT] TO [NSQL]
GO

ALTER TABLE [dbo].[LOT] WITH NOCHECK ADD CONSTRAINT [CK_LOT_01] CHECK (([Qty]>=(([QtyPreAllocated]+[QtyAllocated])+[QtyPicked])))
GO
ALTER TABLE [dbo].[LOT] WITH NOCHECK ADD CONSTRAINT [CK_LOT_QTY] CHECK (([Qty]>=(0)))
GO
ALTER TABLE [dbo].[LOT] WITH NOCHECK ADD CONSTRAINT [CK_LOT_QtyAllocated] CHECK (([QtyAllocated]>=(0)))
GO
ALTER TABLE [dbo].[LOT] WITH NOCHECK ADD CONSTRAINT [CK_LOT_QtyOnHold] CHECK (([QtyOnHold]>=(0)))
GO
ALTER TABLE [dbo].[LOT] WITH NOCHECK ADD CONSTRAINT [CK_LOT_QtyPicked] CHECK (([QtyPicked]>=(0)))
GO
ALTER TABLE [dbo].[LOT] WITH NOCHECK ADD CONSTRAINT [CK_LOT_QtyPreAllocated] CHECK (([QtyPreAllocated]>=(0)))
GO
ALTER TABLE [dbo].[LOT] ADD CONSTRAINT [PKLot] PRIMARY KEY CLUSTERED ([Lot]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_LOT_SKU_LOT] ON [dbo].[LOT] ([StorerKey], [Sku], [Lot]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [LOTQty] ON [dbo].[LOT] ([StorerKey], [Sku], [Lot], [Qty], [QtyPreAllocated], [QtyAllocated], [QtyPicked], [QtyOnHold], [Status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LOT] WITH NOCHECK ADD CONSTRAINT [FK_LOT_LOTATTRIBUTE_01] FOREIGN KEY ([Lot]) REFERENCES [dbo].[LOTATTRIBUTE] ([Lot])
GO
ALTER TABLE [dbo].[LOT] WITH NOCHECK ADD CONSTRAINT [FK_LOT_SKU_01] FOREIGN KEY ([StorerKey], [Sku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])
GO
ALTER TABLE [dbo].[LOT] WITH NOCHECK ADD CONSTRAINT [FK_LOT_STORER_01] FOREIGN KEY ([StorerKey]) REFERENCES [dbo].[STORER] ([StorerKey])
GO
EXEC sp_addextendedproperty N'MS_Description', 'A lot is a pre-populated number associated with a product that has a unique combination of lottable values.', 'SCHEMA', N'dbo', 'TABLE', N'LOT', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Records the maximum cubic size for a Commodity the carton can hold.', 'SCHEMA', N'dbo', 'TABLE', N'LOT', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LOT', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'LOT', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Gross weight of the Commodity currently allocated in the Location.', 'SCHEMA', N'dbo', 'TABLE', N'LOT', 'COLUMN', N'GrossWgtAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Gross weight of the Commodity currently picked In the Location.', 'SCHEMA', N'dbo', 'TABLE', N'LOT', 'COLUMN', N'GrossWgtPicked'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Gross weight of the product that has been pre-allocated from the lot associated to the product.', 'SCHEMA', N'dbo', 'TABLE', N'LOT', 'COLUMN', N'GrossWgtpreAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick method to use when picking inner packs in the zone.', 'SCHEMA', N'dbo', 'TABLE', N'LOT', 'COLUMN', N'InnerPack'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'LOT', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Net weight of the Commodity currently allocated in the Location.', 'SCHEMA', N'dbo', 'TABLE', N'LOT', 'COLUMN', N'NetWgtAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Net weight of the Commodity currently picked in the Location.', 'SCHEMA', N'dbo', 'TABLE', N'LOT', 'COLUMN', N'NetWgtPicked'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Net weight of the product that has been pre-allocated from the lot associated to the product.', 'SCHEMA', N'dbo', 'TABLE', N'LOT', 'COLUMN', N'NetWgtpreAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A portable platform designed to allow a forklift or pallet jack to lift, move and store various loads.', 'SCHEMA', N'dbo', 'TABLE', N'LOT', 'COLUMN', N'Pallet'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated with the Lot.', 'SCHEMA', N'dbo', 'TABLE', N'LOT', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity currently allocated in the Location.', 'SCHEMA', N'dbo', 'TABLE', N'LOT', 'COLUMN', N'QtyAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity currently picked in the Location.', 'SCHEMA', N'dbo', 'TABLE', N'LOT', 'COLUMN', N'QtyPicked'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product that has been pre-allocated from the lot associated to the product.', 'SCHEMA', N'dbo', 'TABLE', N'LOT', 'COLUMN', N'QtyPreAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'LOT', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'LOT', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'LOT', 'COLUMN', N'TrafficCop'
GO
