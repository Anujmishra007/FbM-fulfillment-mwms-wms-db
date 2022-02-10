CREATE TABLE [dbo].[DEL_ORDERDETAIL]
(
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderDetailSysId] [int] NULL CONSTRAINT [DF_DEL_ORDERDETAIL_OrderDetailSysId] DEFAULT (rand()*(2147483647)),
[ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_ExternOrderKey] DEFAULT (' '),
[ExternLineNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_ORDERDETAIL_ExternLineNo] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_Sku] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_StorerKey] DEFAULT (' '),
[ManufacturerSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_ManufacturerSku] DEFAULT (' '),
[RetailSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_RetailSku] DEFAULT (' '),
[AltSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_AltSku] DEFAULT (' '),
[OriginalQty] [int] NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_OriginalQty] DEFAULT ((0)),
[OpenQty] [int] NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_OpenQty] DEFAULT ((0)),
[ShippedQty] [int] NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_ShippedQty] DEFAULT ((0)),
[AdjustedQty] [int] NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_AdjustedQty] DEFAULT ((0)),
[QtyPreAllocated] [int] NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_QtyPreAllocated] DEFAULT ((0)),
[QtyAllocated] [int] NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_QtyAllocated] DEFAULT ((0)),
[QtyPicked] [int] NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_QtyPicked] DEFAULT ((0)),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_UOM] DEFAULT (' '),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_PackKey] DEFAULT ('STD'),
[PickCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_PickCode] DEFAULT (' '),
[CartonGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_CartonGroup] DEFAULT (' '),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_Lot] DEFAULT (' '),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_ID] DEFAULT (' '),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_Facility] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_Status] DEFAULT ('0'),
[UnitPrice] [float] NULL CONSTRAINT [DF_DEL_ORDERDETAIL_UnitPrice] DEFAULT ((0)),
[Tax01] [float] NULL CONSTRAINT [DF_DEL_ORDERDETAIL_Tax01] DEFAULT ((0)),
[Tax02] [float] NULL CONSTRAINT [DF_DEL_ORDERDETAIL_Tax02] DEFAULT ((0)),
[ExtendedPrice] [float] NULL CONSTRAINT [DF_DEL_ORDERDETAIL_ExtendedPrice] DEFAULT ((0)),
[UpdateSource] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_UpdateSource] DEFAULT ('0'),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_Lottable01] DEFAULT (' '),
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_Lottable02] DEFAULT (' '),
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_Lottable03] DEFAULT (' '),
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TariffKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FreeGoodQty] [int] NULL CONSTRAINT [DF_DEL_ORDERDETAIL_FreeGoodQty] DEFAULT ((0)),
[GrossWeight] [float] NULL CONSTRAINT [DF_DEL_ORDERDETAIL_GrossWeight] DEFAULT ((0)),
[Capacity] [float] NULL CONSTRAINT [DF_DEL_ORDERDETAIL_Capacity] DEFAULT ((0)),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QtyToProcess] [int] NULL CONSTRAINT [DF_DEL_ORDERDETAIL_QtyToProcess] DEFAULT ((0)),
[MinShelfLife] [int] NULL CONSTRAINT [DF_DEL_ORDERDETAIL_MinShelfLife] DEFAULT ((0)),
[UserDefine01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine04] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine05] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine06] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine07] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine08] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine09] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine10] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnteredQTY] [int] NULL CONSTRAINT [DF_Del_OrderDetail_EnteredQTY] DEFAULT ((0)),
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERDETAIL_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[ConsoOrderKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Del_OrderDetail_ConsoOrderKey] DEFAULT (''),
[ExternConsoOrderKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Del_OrderDetail_ExternConsoOrderKey] DEFAULT (''),
[ConsoOrderLineNo] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Del_OrderDetail_ConsoOrderLineNo] DEFAULT (''),
[Notes] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Del_OrderDetail_Notes] DEFAULT (''),
[Notes2] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Del_OrderDetail_Notes2] DEFAULT (''),
[Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DEL_ORDERDETAIL] ADD CONSTRAINT [DEL_PKOrderDetail] PRIMARY KEY CLUSTERED ([OrderKey], [OrderLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DEL_ORDERDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[DEL_ORDERDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[DEL_ORDERDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[DEL_ORDERDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information. ', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity after adjustment.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'AdjustedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Alternate Commodity ID to be linked to the Master Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'AltSku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Code used to identify the family of cartons used during cartonization.  ', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'CartonGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'ExternOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Purchase Order used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'ExternPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'ID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'LoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Master Bill of Lading.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'MBOLKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Minimum number of days that the customer allows between the current date and either the expiration date or the manufacturing date for the item being shipped. ', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'MinShelfLife'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of pack code.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Picking.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'PickCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Purchase Order.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'POKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity currently allocated in the Location.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'QtyAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity currently picked in the Location.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'QtyPicked'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product that has been pre-allocated from the lot associated to the product.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'QtyPreAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product being shipped.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'ShippedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of tariff assigned to the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'TariffKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine10'
GO
