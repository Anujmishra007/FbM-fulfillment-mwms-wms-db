CREATE TABLE [dbo].[ORDERDETAIL]
(
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderDetailSysId] [int] NULL CONSTRAINT [DF_ORDERDETAIL_OrderDetailSysId] DEFAULT (rand()*(2147483647)),
[ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_ExternOrderKey] DEFAULT (' '),
[ExternLineNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_ExternLineNo] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Sku] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_StorerKey] DEFAULT (' '),
[ManufacturerSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_ManufacturerSku] DEFAULT (' '),
[RetailSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_RetailSku] DEFAULT (' '),
[AltSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_AltSku] DEFAULT (' '),
[OriginalQty] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_OriginalQty] DEFAULT ((0)),
[OpenQty] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_OpenQty] DEFAULT ((0)),
[ShippedQty] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_ShippedQty] DEFAULT ((0)),
[AdjustedQty] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_AdjustedQty] DEFAULT ((0)),
[QtyPreAllocated] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_QtyPreAllocated] DEFAULT ((0)),
[QtyAllocated] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_QtyAllocated] DEFAULT ((0)),
[QtyPicked] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_QtyPicked] DEFAULT ((0)),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_UOM] DEFAULT (' '),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_PackKey] DEFAULT ('STD'),
[PickCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_PickCode] DEFAULT (' '),
[CartonGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CartonGroup] DEFAULT (' '),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_LOT] DEFAULT (' '),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_ID] DEFAULT (' '),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Facility] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Status] DEFAULT ('0'),
[UnitPrice] [float] NULL CONSTRAINT [DF_ORDERDETAIL_UnitPrice] DEFAULT ((0)),
[Tax01] [float] NULL CONSTRAINT [DF_ORDERDETAIL_Tax01] DEFAULT ((0)),
[Tax02] [float] NULL CONSTRAINT [DF_ORDERDETAIL_Tax02] DEFAULT ((0)),
[ExtendedPrice] [float] NULL CONSTRAINT [DF_ORDERDETAIL_ExtendedPrice] DEFAULT ((0)),
[UpdateSource] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_UpdateSource] DEFAULT ('0'),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_LOTTABLE01] DEFAULT (' '),
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_LOTTABLE02] DEFAULT (' '),
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_LOTTABLE03] DEFAULT (' '),
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_ORDERDETAIL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ORDERDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ORDERDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TariffKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FreeGoodQty] [int] NULL CONSTRAINT [DF_ORDERDETAIL_FreeGoodQty] DEFAULT ((0)),
[GrossWeight] [float] NULL CONSTRAINT [DF_ORDERDETAIL_GROSSWEIGHT] DEFAULT ((0)),
[Capacity] [float] NULL CONSTRAINT [DF_ORDERDETAIL_CAPACITY] DEFAULT ((0)),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QtyToProcess] [int] NULL CONSTRAINT [DF_OrderDetail_QtyToProcess] DEFAULT ((0)),
[MinShelfLife] [int] NULL CONSTRAINT [DF_OrderDetail_MinShelfLife] DEFAULT ((0)),
[UserDefine01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine04] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine05] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine06] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine07] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine08] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine09] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POkey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine10] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnteredQTY] [int] NULL CONSTRAINT [DF_OrderDetail_EnteredQTY] DEFAULT ((0)),
[ConsoOrderKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternConsoOrderKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Orderdetail_ExternConsoOrderKey] DEFAULT (' '),
[ConsoOrderLineNo] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERDETAIL_ConsoOrderLineNo] DEFAULT (''),
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[Notes] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERDETAIL_Notes] DEFAULT (''),
[Notes2] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERDETAIL_Notes2] DEFAULT (''),
[Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERDETAIL_Channel] DEFAULT (''),
[HashValue] [tinyint] NULL CONSTRAINT [DF_Orderdetail_HashValue] DEFAULT ((1)),
[SalesChannel] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderDetail_SalesChannel] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ORDERDETAIL] WITH NOCHECK ADD CONSTRAINT [CK_ORDERDETAIL_QtyAllocated] CHECK (([QtyAllocated]>=(0) AND [QtyAllocated]<=([OpenQty]+[FreeGoodQty])))
GO
ALTER TABLE [dbo].[ORDERDETAIL] WITH NOCHECK ADD CONSTRAINT [CK_ORDERDETAIL_QtyPicked] CHECK (([QtyPicked]>=(0) AND [QtyPicked]<=([OpenQty]+[FreeGoodQty])))
GO
ALTER TABLE [dbo].[ORDERDETAIL] WITH NOCHECK ADD CONSTRAINT [CK_ORDERDETAIL_QtyPreAlloc] CHECK (([QtyPreAllocated]>=(0)))
GO
ALTER TABLE [dbo].[ORDERDETAIL] WITH NOCHECK ADD CONSTRAINT [CK_ORDERDETAIL_QtyPreAllocated] CHECK ((([QtyPreAllocated]+[QtyPicked])+[QtyAllocated]<=([OpenQty]+[FreeGoodQty])))
GO
ALTER TABLE [dbo].[ORDERDETAIL] WITH NOCHECK ADD CONSTRAINT [CK_ORDERDETAIL_Status] CHECK (([Status]='CANC' OR [Status]='9' OR [Status]='8' OR [Status]='7' OR [Status]='6' OR [Status]='5' OR [Status]='4' OR [Status]='3' OR [Status]='2' OR [Status]='1' OR [Status]='0'))
GO
ALTER TABLE [dbo].[ORDERDETAIL] ADD CONSTRAINT [PKOrderDetail] PRIMARY KEY CLUSTERED ([OrderKey], [OrderLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ORDERDETAIL_ConsoOrderKey] ON [dbo].[ORDERDETAIL] ([ConsoOrderKey], [ConsoOrderLineNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ORDERDETAIL_ExtOrdKey] ON [dbo].[ORDERDETAIL] ([ExternOrderKey], [ExternLineNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ORDERDETAIL6] ON [dbo].[ORDERDETAIL] ([LoadKey], [Status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ORDERDETAIL_MbolKey] ON [dbo].[ORDERDETAIL] ([MBOLKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ORDERDETAIL_SKU] ON [dbo].[ORDERDETAIL] ([StorerKey], [Sku]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[ORDERDETAIL] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[ORDERDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ORDERDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ORDERDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ORDERDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Adjustedqty', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'AdjustedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Altsku', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'AltSku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Capacity', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Capacity'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Code used to identify the family of cartons used during cartonization.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'CartonGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Consolidated order key', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ConsoOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Consolidated order detail line number imported', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ConsoOrderLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer should take place', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Entered quantity', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'EnteredQTY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Extended price', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ExtendedPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', 'External consolidated order key', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ExternConsoOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'External order detail line number imported', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ExternLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ExternOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer''s Purchase Order number. It is used to link ASN with order', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ExternPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'FOC quantity attached to the line item', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'FreeGoodQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Gross weight', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'GrossWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ID', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Updated when the Shipment Order is attached to a Load or when it''s moved to a new Load', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'LoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer defined lottable 01. Use for allocation', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer defined lottable 02. Use for allocation', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer defined lottable 03. Use for allocation', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Product expiry date which will be used as one of the criterias for allocation', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Product receipt date which will be used as one of the criterias for allocation', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable07', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable08', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable09', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable10', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable11', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable11'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable12', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable12'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable13', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable13'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable14', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable14'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable15', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable15'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Manufacturer SKU', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ManufacturerSku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Updated when the Shipment Order is attached to an MBOL or when it''s moved to a new MBOL', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'MBOLKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Minimum number of days that the customer allows between the current date and either the expiration date or the manufacturing date for the item being shipped.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'MinShelfLife'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Notes2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Open Quantity', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'OpenQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Order detail system ID', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'OrderDetailSysId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Order detail line number. System generated', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'OrderLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Original quantity', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'OriginalQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Packing configuration of the SKU. Will be defaulted to the pack key assigned in the Commodity screen. Changeable', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pick.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'PickCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'WMS Purchase Order number. It is used to process Crossdock orders, linking ASN with the order', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'POkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity allocated', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'QtyAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity picked', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'QtyPicked'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product that has been pre-allocated from the lot associated to the product.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'QtyPreAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Qty To Process', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'QtyToProcess'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Retail SKU', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'RetailSku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Distribution channels like wholesalers, retailers, distributors along with Orders', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'SalesChannel'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity shipped', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ShippedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The SKU being ordered', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Status', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The pricing model assigned to the SKU that defines the rates and method of billing for storage and associated charges', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'TariffKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tax ID 01', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Tax01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tax ID 02', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Tax02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Price per unit of the product ordered', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UnitPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measurement in which the SKU will be shipped', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Source update', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UpdateSource'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine01', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine02', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine03', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine04', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine05', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine06', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine07', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine08', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine09', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine10', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine10'
GO
