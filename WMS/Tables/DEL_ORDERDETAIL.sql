IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DEL_ORDERDETAIL]') AND type in (N'U'))
BEGIN

CREATE TABLE [dbo].[DEL_ORDERDETAIL](
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
[Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SalesChannel] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CancelReasonCode] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[DEL_ORDERDETAIL] ADD CONSTRAINT [DEL_PKOrderDetail] PRIMARY KEY CLUSTERED ([OrderKey], [OrderLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]

GRANT DELETE ON  [dbo].[DEL_ORDERDETAIL] TO [NSQL]

GRANT INSERT ON  [dbo].[DEL_ORDERDETAIL] TO [NSQL]

GRANT SELECT ON  [dbo].[DEL_ORDERDETAIL] TO [NSQL]

GRANT UPDATE ON  [dbo].[DEL_ORDERDETAIL] TO [NSQL]


IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'AddDate'))
	EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'AddDate'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'AddWho'))	
	EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information. ', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'AddWho'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'AdjustedQty'))	
	EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity after adjustment.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'AdjustedQty'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'AltSku'))	
	EXEC sp_addextendedproperty N'MS_Description', 'Alternate Commodity ID to be linked to the Master Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'AltSku'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'CartonGroup'))	
	EXEC sp_addextendedproperty N'MS_Description', 'Code used to identify the family of cartons used during cartonization.  ', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'CartonGroup'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'EditDate'))	
	EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'EditDate'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'EditWho'))		
	EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'EditWho'


IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'ExternOrderKey'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'ExternOrderKey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'ExternPOKey'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Purchase Order used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'ExternPOKey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'Facility'))		
	EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'Facility'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'ID'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'ID'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'LoadKey'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'LoadKey'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'Lot'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'Lot'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'MBOLKey'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Master Bill of Lading.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'MBOLKey'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'MinShelfLife'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Minimum number of days that the customer allows between the current date and either the expiration date or the manufacturing date for the item being shipped. ', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'MinShelfLife'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'OrderKey'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'OrderKey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'PackKey'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Name of pack code.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'PackKey'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'PickCode'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Picking.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'PickCode'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'POKey'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Purchase Order.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'POKey'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'QtyAllocated'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity currently allocated in the Location.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'QtyAllocated'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'QtyPicked'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity currently picked in the Location.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'QtyPicked'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'QtyPreAllocated'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product that has been pre-allocated from the lot associated to the product.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'QtyPreAllocated'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'ShippedQty'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product being shipped.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'ShippedQty'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'Sku'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'Sku'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'StorerKey'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'StorerKey'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'TariffKey'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Type of tariff assigned to the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'TariffKey'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'TrafficCop'))		
	EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'TrafficCop'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'UOM'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UOM'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'UserDefine01'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine01'
	
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'UserDefine02'))		
	EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine02'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'UserDefine03'))			
	EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine03'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'UserDefine04'))			
	EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine04'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'UserDefine05'))			
	EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine05'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'UserDefine06'))			
	EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine06'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'UserDefine07'))			
	EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine07'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'UserDefine08'))			
	EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine08'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'UserDefine09'))			
	EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine09'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'UserDefine10'))			
	EXEC sp_addextendedproperty N'MS_Description', 'Track additional static information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'UserDefine10'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'SalesChannel'))			
	EXEC sp_addextendedproperty N'MS_Description', 'Distribution channels like wholesalers, retailers, distributors along with Orders.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'SalesChannel'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'DEL_ORDERDETAIL', N'COLUMN',N'CancelReasonCode'))			
	EXEC sp_addextendedproperty N'MS_Description', 'The reason why an order detail is cancelled.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'CancelReasonCode'


END
ELSE
BEGIN


 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'SalesChannel' AND Object_ID = Object_ID('dbo.DEL_ORDERDETAIL'))
			BEGIN
				ALTER TABLE dbo.DEL_ORDERDETAIL ADD SalesChannel [nvarchar](50) NULL ;
				EXEC sp_addextendedproperty N'MS_Description', 'Distribution channels like wholesalers, retailers, distributors along with Orders.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'SalesChannel'

				
			END
			
			IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'CancelReasonCode' AND Object_ID = Object_ID('dbo.DEL_ORDERDETAIL'))
			BEGIN
				ALTER TABLE dbo.DEL_ORDERDETAIL ADD CancelReasonCode [nvarchar](60) NULL ;
				EXEC sp_addextendedproperty N'MS_Description', 'The reason why an order detail is cancelled.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERDETAIL', 'COLUMN', N'CancelReasonCode'
				
			END


END